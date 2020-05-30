CREATE OR REPLACE PACKAGE BODY "PAC_CONVIVENCIA" AS

  /****************************************************************************
      F_GET_IAXIS: DEVUELVE EL VALOR (STRING) DE UN DETALLE O COLUMNA BASADA EN LA TABLA CON_HOMOLOGA_OSIAX
      PARAMETERS:
                   PSPERSON : IDENTIFICACIÃƒÂ³N DE LA PERSONA EN IAXIS (PER_PERSONA)
                   PQUERY_SELECT : QUERY SELECT A EJECUTAR QUE DEVUELVE EL VALOR DE DETALLE O CAMPO DE IAXIS
                   PTIPO_CAMPO: TIPO DE CAMPO (VARCHAR, DATE, NUMBER).
     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCIÃƒÂ³N
     ---------  ----------  ---------------  ------------------------------------
     1.0        26/02/2019   CES             FUNCIÃƒÂ³N PARA OBTENER EL VALOR DE UN DETALLE O CAMPO EN IAXIS AMARRADO AL SPERSON
     2.0        26/02/2019   CES             IAXIS-3060: AJUSTE DE LA FUNCIÃ³N PARA INTEGRACIÃ³N DE CONSORCIOS
     3.0        15/04/2019   CES             IAXIS-3671: AJUSTE CONVIVENCIA DE CUPOS FIN_IDICADORES
     4.0        18/03/2020   SP              IAXIS-13044 
  ****************************************************************************/

  FUNCTION F_GET_IAXIS(PSPERSON      VARCHAR2,
                       PQUERY_SELECT VARCHAR2,
                       PTIPO_CAMPO   VARCHAR2) RETURN VARCHAR2 IS
    TDATE      DATE;
    TNUMBER    NUMBER(23, 2);
    TSTRING    VARCHAR2(4000);
    X_VINCULO  NUMBER;
    X_POSICION NUMBER;
    X_PERSON   NUMBER;
    X_ESTADO   NUMBER;
  
  BEGIN
  
    IF PTIPO_CAMPO = 'DATE' THEN
      BEGIN
        EXECUTE IMMEDIATE PQUERY_SELECT
          INTO TDATE
          USING PSPERSON;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          TDATE := NULL;
        WHEN OTHERS THEN
          IF SQLCODE = -01008 THEN
            BEGIN
              EXECUTE IMMEDIATE PQUERY_SELECT
                INTO TDATE
                USING PSPERSON, PSPERSON;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                TDATE := NULL;
            END;
          END IF;
      END;
      IF TDATE IS NOT NULL THEN
        RETURN TO_CHAR(TDATE, 'DD/MM/YYYY');
      ELSE
        RETURN TDATE;
      END IF;
    ELSIF PTIPO_CAMPO = 'VARCHAR' THEN
      BEGIN
        -- DBMS_OUTPUT.PUT_LINE(PQUERY_SELECT);
        EXECUTE IMMEDIATE PQUERY_SELECT
          INTO TSTRING
          USING PSPERSON;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          TSTRING := NULL;
        WHEN OTHERS THEN
          IF SQLCODE = -01008 THEN
            BEGIN
              EXECUTE IMMEDIATE PQUERY_SELECT
                INTO TSTRING
                USING PSPERSON, PSPERSON;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                TSTRING := NULL;
            END;
          END IF;
        
      END;
      --    DBMS_OUTPUT.PUT_LINE('respuestas en el tstring :::::::::::::: '||TSTRING);
      RETURN TSTRING;
    ELSIF PTIPO_CAMPO = 'NUMBER' THEN
      BEGIN
        EXECUTE IMMEDIATE PQUERY_SELECT
          INTO TNUMBER
          USING PSPERSON;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          TNUMBER := 0;
        WHEN OTHERS THEN
          IF SQLCODE = -01008 THEN
            BEGIN
              EXECUTE IMMEDIATE PQUERY_SELECT
                INTO TNUMBER
                USING PSPERSON, PSPERSON;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                TNUMBER := 0;
            END;
          END IF;
      END;
      RETURN TO_CHAR(TNUMBER);
    ELSIF (PTIPO_CAMPO = 'S03501' OR PTIPO_CAMPO = 'S03501B') THEN
      X_POSICION := INSTR(PSPERSON, ';');
      X_PERSON   := SUBSTR(PSPERSON, 1, X_POSICION - 1);
      X_VINCULO  := TO_NUMBER(SUBSTR(PSPERSON, X_POSICION + 1, 3));
      BEGIN
        EXECUTE IMMEDIATE PQUERY_SELECT
          INTO TSTRING
          USING X_VINCULO, X_PERSON, X_PERSON;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          TSTRING := NULL;
      END;
      RETURN TO_CHAR(TSTRING);
      IF SQLCODE = -01008 THEN
        BEGIN
          EXECUTE IMMEDIATE PQUERY_SELECT
            INTO TNUMBER
            USING PSPERSON, PSPERSON;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            TNUMBER := NULL;
        END;
      END IF;
    ELSE
      --  X_POSICION :=  INSTR(PSPERSON,';');
      -- X_PERSON := SUBSTR(PSPERSON,1,X_POSICION-1);
      --X_PERSON := X_PERSON||F_CONVIVENCIA_OSIRIS(PSPERSON,2);
      --  X_VINCULO := TO_NUMBER(SUBSTR(PSPERSON, X_POSICION+1,3));
      -- X_ESTADO := TO_NUMBER(PTIPO_CAMPO);
      X_VINCULO := TO_NUMBER(PTIPO_CAMPO);
      BEGIN
        EXECUTE IMMEDIATE PQUERY_SELECT
          INTO TNUMBER
          USING PSPERSON, X_VINCULO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          TNUMBER := NULL;
        WHEN OTHERS THEN
          IF SQLCODE = -01008 THEN
            BEGIN
              EXECUTE IMMEDIATE PQUERY_SELECT
                INTO TNUMBER
                USING X_PERSON, PSPERSON;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                TNUMBER := NULL;
            END;
          END IF;
      END;
      RETURN TO_CHAR(TNUMBER);
    END IF;
  
  END F_GET_IAXIS;

  /****************************************************************************
      P_SEND_DATA: REALIZA LA EJECUCIÃƒÂ³N DE LOS SCRIPT DE INTEGRACIÃƒÂ³N OSIRIS - IAXIS
      PARAMETERS:
                   PSPERSON : IDENTIFICACIÃƒÂ³N DE LA PERSONA EN IAXIS (PER_PERSONA)
                   PFLAG :    BANDERA PARA SABER SI ES UN INSERT(0) O UPDATE(1)
                   PTABLA:    NOMBRE DE LA TABLA A UTILIZAR EN LA ACTUALIZACIÃƒÂ³N.
     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCIÃƒÂ³N
     ---------  ----------  ---------------  ------------------------------------
     1.0        26/02/2019   CES - WAJ       PROCEDIMIENTO ENCARGADO DE REALIZAR EL ENVIO DE LOS DATOS A CORE OSIRIS
  ****************************************************************************/

  PROCEDURE P_SEND_DATA(PSPERSON IN VARCHAR2,
                        PFLAG    IN NUMBER,
                        PTABLA   IN VARCHAR2) AS
  
    CURSOR CURINSERT IS
      SELECT *
        FROM (SELECT *
                FROM CON_HOMOLOGA_OSIAX
               WHERE 0 = PFLAG
              UNION
              SELECT *
                FROM CON_HOMOLOGA_OSIAX
               WHERE TIAXIS = PTABLA
                 AND 1 = PFLAG
              UNION
              SELECT *
                FROM CON_HOMOLOGA_OSIAX
               WHERE 3 = PFLAG
              ------------------
              UNION
              SELECT *
                FROM CON_HOMOLOGA_OSIAX
               WHERE TIAXIS = 'PER_AGR_MARCAS'
                 AND TOSIRIS = 'S03501B'
                 AND CAMPO_EXTRA = 'INSERT501'
                 AND 2 = PFLAG
              UNION
              SELECT *
                FROM CON_HOMOLOGA_OSIAX
               WHERE TIAXIS = 'PER_AGR_MARCAS'
                 AND TOSIRIS = 'S03501'
                 AND 2 = PFLAG) ABC
       ORDER BY ABC.TOSIRIS, ABC.NORDEN;
  
    SQL_QUERY      VARCHAR2(4000) := '';
    SQL_QUERYINI   VARCHAR2(4000) := '';
    SQL_QUERYFIN   VARCHAR2(4000) := '';
    CONTEXTO       NUMBER(10);
    X_CONTA        NUMBER := 0;
    PCODIGO        VARCHAR2(16) := '';
    SI_CONVIVENCIA VARCHAR2(1); -- 0 => APAGADO | 1 => ENCENDIDO
    NBDLINK_NAME   VARCHAR2(200);
    X_PERSON       VARCHAR(20);
    X_POSICION     NUMBER;
    X_VINCULO      NUMBER := NULL;
    PEXISTE        VARCHAR2(2) := NULL;
    X_FLAG         NUMBER(1) := PFLAG;
  
  BEGIN
  
    SI_CONVIVENCIA := F_PAREMPRESA_T('CONVIVENCIA', 24);
  
    IF SI_CONVIVENCIA = '1' THEN
    
      SELECT PAC_CONTEXTO.F_INICIALIZARCTX(PAC_PARAMETROS.F_PAREMPRESA_T(24,
                                                                         'USER_BBDD'))
        INTO CONTEXTO
        FROM DUAL;
    
      NBDLINK_NAME := F_PARINSTALACION_T('DBLINK');
    
      X_POSICION := INSTR(PSPERSON, ';');
      --DBMS_OUTPUT.PUT_LINE('x_posicion ::'||X_POSICION);
      IF X_POSICION > 0 THEN
        X_PERSON  := SUBSTR(PSPERSON, 1, X_POSICION - 1);
        X_VINCULO := TO_NUMBER(SUBSTR(PSPERSON, X_POSICION + 1, 3));
      ELSE
        X_PERSON := PSPERSON;
      END IF;
    
      PCODIGO := F_GET_COD_OSIRIS(X_PERSON, NBDLINK_NAME, PEXISTE);
    
      -- VALIDACIÃƒÂ€ŒN SI EXISTE LA PERSONA EN OSIRIS Y SE PRETENDE CREAR SOLO ACTUALIZA LOS DATOS
    
      IF PEXISTE = 'SI' AND PFLAG = 0 THEN
        X_FLAG := 1;
      END IF;
    
      -- INSERT
      IF X_FLAG = 0 THEN
      
        FOR RINSERT IN CURINSERT LOOP
        
          IF RINSERT.TOSIRIS IN ('S03500', 'S03501') AND
             RINSERT.CAMPO_EXTRA = 'INSERT' THEN
            SQL_QUERY := 'INSERT INTO ' || RINSERT.TOSIRIS || NBDLINK_NAME ||
                         ' VALUES (';
            SQL_QUERY := SQL_QUERY || '''' ||
                         F_GET_IAXIS(PSPERSON,
                                     RINSERT.QUERY_INSERT,
                                     RINSERT.CAMPO_OSI) || ')';
            -- DBMS_OUTPUT.PUT_LINE(SQL_QUERY);
            EXECUTE IMMEDIATE SQL_QUERY;
            EXECUTE IMMEDIATE 'COMMIT';
          END IF;
        
          IF RINSERT.TOSIRIS = 'S03502' THEN
            SQL_QUERY := 'INSERT INTO ' || RINSERT.TOSIRIS || NBDLINK_NAME ||
                         ' VALUES (''' || PCODIGO || ''',' || '''' ||
                         RINSERT.CAMPO_OSI || '''' || ',';
            IF RINSERT.TIPVALOR_OSI = 'DATE' THEN
            
              SQL_QUERY := SQL_QUERY || '''' ||
                           F_GET_IAXIS(PSPERSON,
                                       RINSERT.QUERY_SELECT,
                                       RINSERT.TIPVALOR_IAX) || '''' ||
                           ',0,NULL,NULL,';
            
            ELSIF RINSERT.TIPVALOR_OSI = 'VARCHAR' THEN
              SQL_QUERY := SQL_QUERY || 'NULL,0,' || '''' ||
                           REPLACE(F_GET_IAXIS(PSPERSON,
                                               RINSERT.QUERY_SELECT,
                                               RINSERT.TIPVALOR_IAX),
                                   '''',
                                   '') || '''' || ',NULL,';
            ELSE
            
              SQL_QUERY := SQL_QUERY || 'NULL,' || '''' ||
                           F_GET_IAXIS(PSPERSON,
                                       RINSERT.QUERY_SELECT,
                                       RINSERT.TIPVALOR_IAX) || '''' ||
                           ',NULL,NULL,';
            END IF;
            SQL_QUERY := SQL_QUERY || '''' || F_USER || '''' || ',' || '''' ||
                         F_USER || '''' || ',' || 'TO_DATE(' || '''' ||
                         TO_CHAR(SYSDATE, 'DD/MM/YYYY') ||
                         ''', ''DD/MM/YYYY''),' || 'TO_DATE(' || '''' ||
                         TO_CHAR(SYSDATE, 'DD/MM/YYYY') ||
                         ''', ''DD/MM/YYYY'') )';
            -- DBMS_OUTPUT.PUT_LINE(SQL_QUERY);
            EXECUTE IMMEDIATE SQL_QUERY;
            EXECUTE IMMEDIATE 'COMMIT';
          END IF;
        
        END LOOP;
      
        -- UPDATE
      ELSIF X_FLAG = 1 THEN
      
        FOR RINSERT IN CURINSERT LOOP
        
          IF RINSERT.TOSIRIS = 'S03500' AND RINSERT.CAMPO_EXTRA = 'UPDATE' THEN
          
            IF X_CONTA = 0 THEN
              SQL_QUERYINI := 'UPDATE ' || RINSERT.TOSIRIS || NBDLINK_NAME ||
                              ' SET ';
              SQL_QUERYFIN := ' WHERE CODIGO = ''' || PSPERSON ||
                              F_CONVIVENCIA_OSIRIS(PSPERSON, 2) || '''';
              X_CONTA      := 1;
            END IF;
          
            SQL_QUERY    := RINSERT.CAMPO_OSI || ' = ' ||
                            F_GET_IAXIS(PSPERSON,
                                        RINSERT.QUERY_SELECT,
                                        RINSERT.TIPVALOR_OSI);
            SQL_QUERYINI := SQL_QUERYINI || SQL_QUERY;
          
          END IF;
        
          IF RINSERT.TOSIRIS = 'S03502' THEN
            SQL_QUERY := 'UPDATE ' || RINSERT.TOSIRIS || NBDLINK_NAME ||
                         ' SET ';
            IF RINSERT.TIPVALOR_OSI = 'DATE' THEN
              --INI-CES-IAXIS-3671
              SQL_QUERY := SQL_QUERY || 'VALDATE=' || 'TO_DATE(''' ||
                           F_GET_IAXIS(PSPERSON,
                                       RINSERT.QUERY_SELECT,
                                       RINSERT.TIPVALOR_IAX) ||
                           ''', ''DD/MM/YYYY'') ';
              --END-CES-IAXIS-3671
            ELSIF RINSERT.TIPVALOR_OSI = 'VARCHAR' THEN
              SQL_QUERY := SQL_QUERY || 'VALNUMBER=0, VALSTRING=' || '''' ||
                           F_GET_IAXIS(PSPERSON,
                                       RINSERT.QUERY_SELECT,
                                       RINSERT.TIPVALOR_IAX) || ''' ';
            ELSE
              SQL_QUERY := SQL_QUERY || 'VALNUMBER=' || '''' ||
                           F_GET_IAXIS(PSPERSON,
                                       RINSERT.QUERY_SELECT,
                                       RINSERT.TIPVALOR_IAX) || ''' ';
            END IF;
          
            SQL_QUERY := SQL_QUERY || ', SUCMOD=' || '''' || F_USER ||
                         ''', FECMOD=TO_DATE(' || '''' ||
                         TO_CHAR(SYSDATE, 'DD/MM/YYYY') ||
                         ''', ''DD/MM/YYYY'') ';
            SQL_QUERY := SQL_QUERY || 'WHERE CODDET = ' || '''' ||
                         RINSERT.CAMPO_OSI || ''' AND CODIGO=' || '''' ||
                         PCODIGO || '''';
            -- DBMS_OUTPUT.PUT_LINE(SQL_QUERY);
            EXECUTE IMMEDIATE SQL_QUERY;
            EXECUTE IMMEDIATE 'COMMIT';
          END IF;
        
        END LOOP;
      
        -- ESTO ES PARA EJECUTAR EL UPDATE MASIVO DE ENCABEZADO.
        IF X_CONTA = 1 THEN
          SQL_QUERYINI := SQL_QUERYINI || SQL_QUERYFIN;
          -- DBMS_OUTPUT.PUT_LINE(SQL_QUERYINI);
          EXECUTE IMMEDIATE SQL_QUERYINI;
          EXECUTE IMMEDIATE 'COMMIT';
        
        END IF;
      
        /* VALIDACION PARA HACER LLAMADO DE LA ACTUALIZACIÃƒÂ€ŒN DE UNA MARCA CONCRETA*/
        IF X_VINCULO IS NOT NULL THEN
        
          SQL_QUERY := 'INSERT INTO S03501B' || NBDLINK_NAME ||
                       '  (SELECT CODIGO, CODVIN, ESTADO, FECESTADO, SUCREA
                                    FROM S03501' ||
                       NBDLINK_NAME || ' WHERE CODIGO  = ''' || PCODIGO || '''' ||
                       'AND CODVIN =' || X_VINCULO || ')';
          -- DBMS_OUTPUT.PUT_LINE(SQL_QUERY);
          EXECUTE IMMEDIATE SQL_QUERY;
          EXECUTE IMMEDIATE 'COMMIT';
        
          SQL_QUERYINI := 'UPDATE S03501' || NBDLINK_NAME ||
                          ' SET ESTADO =' || TO_NUMBER(PTABLA);
          SQL_QUERYFIN := ' WHERE CODIGO = ''' || PCODIGO || '''' ||
                          'AND CODVIN =' || X_VINCULO;
          -- DBMS_OUTPUT.PUT_LINE(SQL_QUERYINI||SQL_QUERYFIN);
          EXECUTE IMMEDIATE SQL_QUERYINI || SQL_QUERYFIN;
          EXECUTE IMMEDIATE 'COMMIT';
        END IF;
      
      ELSIF X_FLAG = 2 THEN
        --MARCAS
        FOR RINSERT IN CURINSERT LOOP
          IF RINSERT.TOSIRIS IN ('S03501') AND
             RINSERT.CAMPO_EXTRA = 'INSERT501' AND
             RINSERT.TIAXIS = 'PER_AGR_MARCAS' THEN
            SQL_QUERY := 'INSERT INTO ' || RINSERT.TOSIRIS || NBDLINK_NAME ||
                         ' VALUES (';
            SQL_QUERY := SQL_QUERY || '''' ||
                         F_GET_IAXIS(PSPERSON || ';' || PTABLA,
                                     RINSERT.QUERY_INSERT,
                                     RINSERT.TOSIRIS) || ')';
            --  DBMS_OUTPUT.PUT_LINE(SQL_QUERY);
            EXECUTE IMMEDIATE SQL_QUERY;
            EXECUTE IMMEDIATE 'COMMIT';
          END IF;
        
          IF RINSERT.TOSIRIS IN ('S03501B') AND
             RINSERT.CAMPO_EXTRA = 'INSERT' AND
             RINSERT.TIAXIS = 'PER_AGR_MARCAS' THEN
            SQL_QUERY := 'INSERT INTO ' || RINSERT.TOSIRIS || NBDLINK_NAME ||
                         ' VALUES (';
            SQL_QUERY := SQL_QUERY || '''' ||
                         F_GET_IAXIS(PSPERSON || ';' || PTABLA,
                                     RINSERT.QUERY_INSERT,
                                     RINSERT.TOSIRIS) || ')';
            --   DBMS_OUTPUT.PUT_LINE(SQL_QUERY);
            EXECUTE IMMEDIATE SQL_QUERY;
            EXECUTE IMMEDIATE 'COMMIT';
          END IF;
        
        END LOOP;
      
      ELSIF X_FLAG = 3 THEN
        -- FCC
        BEGIN
          FOR RINSERT IN CURINSERT LOOP
            --INI TCS-1560 27/02/2019 AP
            IF RINSERT.TOSIRIS = 'S03512' AND
               RINSERT.CAMPO_EXTRA = 'INSERT' THEN
            
              SQL_QUERY := 'INSERT INTO ' || RINSERT.TOSIRIS ||
                           NBDLINK_NAME || ' VALUES (';
              SQL_QUERY := SQL_QUERY || '''' ||
                           F_GET_IAXIS(PSPERSON,
                                       RINSERT.QUERY_INSERT,
                                       RINSERT.CAMPO_OSI) || ')';
              --  DBMS_OUTPUT.PUT_LINE(SQL_QUERY);
              EXECUTE IMMEDIATE SQL_QUERY;
              EXECUTE IMMEDIATE 'COMMIT';
            END IF;
            --INI TCS-1560 27/02/2019 AP
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            -- DBMS_OUTPUT.PUT_LINE('ERROR EN FCC CODE:'||SQLCODE||' MENSAJE:'||SQLERRM);
            P_TAB_ERROR(F_SYSDATE,
                        F_USER,
                        'PAC_CONVIVENCIA.P_SEND_DATA',
                        1,
                        'ERROR EN FCC CODE :' || SQL_QUERY,
                        SQLERRM);
        END;
      END IF; -- FLAG  => INSERT/UPDATE
    
    END IF; -- SI_CONVIVENCIA
  
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'PAC_CONVIVENCIA.P_SEND_DATA',
                  1,
                  'SQL_QUERY : ' || SQL_QUERY,
                  SQLERRM);
    
  END P_SEND_DATA;

  /****************************************************************************
      F_CONVIVENCIA_OSIRIS: DEVUELVE LA DATA NECESARIA PARA EL PROCESO DE CONVIVENCIA
              PNFORMAT = 1 = HOMOLOGACION TIPPER PARA OSIRIS
              PNFORMAT = 2 = TREAR EL CAMPO CDOMICI PARA CONCATENAR CON EL SPERSON
  
     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCIÃƒÂ³N
     ---------  ----------  ---------------  ------------------------------------
     1.0        15/02/2019   WAJ           FUNCION CONVIVENCIA IAXIS - OSIRIS
  ****************************************************************************/

  FUNCTION F_CONVIVENCIA_OSIRIS(PSPERSON IN NUMBER, PNFORMAT IN NUMBER)
    RETURN VARCHAR2 IS
  
    X_CTIPPER     NUMBER;
    X_CTIPIDE     NUMBER;
    X_SALIDA      VARCHAR(10);
    X_TIPSOCIEDAD NUMBER;
    X_NUMIDE      VARCHAR(20);
    X_SINUMIDE    NUMBER;
    X_CDOMICI     NUMBER;
  
  BEGIN
  
    IF PNFORMAT = 1 THEN
    
      BEGIN
        SELECT CTIPPER, CTIPIDE, NNUMIDE
          INTO X_CTIPPER, X_CTIPIDE, X_NUMIDE
          FROM PER_PERSONAS
         WHERE SPERSON = PSPERSON;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          X_CTIPPER := 0;
          X_CTIPIDE := 0;
          X_NUMIDE  := '';
      END;
    
      IF X_CTIPPER = 1 THEN
        IF X_CTIPIDE = 33 THEN
          X_SALIDA := '92';
        ELSIF X_CTIPIDE = 34 THEN
          X_SALIDA := '80';
        ELSIF X_CTIPIDE = 35 THEN
          X_SALIDA := '80';
        ELSIF X_CTIPIDE = 36 THEN
          X_SALIDA := '10';
        ELSIF X_CTIPIDE = 40 THEN
          X_SALIDA := '91';
        ELSIF X_CTIPIDE = 69 THEN
          X_SALIDA := '92';
        ELSIF X_CTIPIDE = 93 THEN
          X_SALIDA := '94';
        ELSIF X_CTIPIDE = 96 THEN
          X_SALIDA := '70';
        ELSIF X_CTIPIDE = 98 THEN
          X_SALIDA := '89';
        END IF;
      END IF;
      IF X_CTIPPER = 2 THEN
      
        BEGIN
          SELECT CTIPSOCI
            INTO X_TIPSOCIEDAD
            FROM FIN_GENERAL
           WHERE SPERSON = PSPERSON;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            X_TIPSOCIEDAD := 25;
        END;
      
        IF X_CTIPIDE = 98 THEN
          X_SALIDA := '89';
        ELSIF X_CTIPIDE = 96 THEN
          X_SALIDA := '70';
        ELSIF X_CTIPIDE = 0 THEN
          IF X_TIPSOCIEDAD = 10 OR X_TIPSOCIEDAD = 9 THEN
            X_SALIDA := '60';
          END IF;
        ELSIF X_CTIPIDE = 37 THEN
          IF X_TIPSOCIEDAD = 10 THEN
            X_SALIDA := '50';
          ELSE
            X_SALIDA := '20';
          END IF;
        END IF;
      END IF;
    
      IF X_SALIDA IS NULL THEN
        X_SALIDA := 0;
      END IF;
    END IF;
  
    IF PNFORMAT = 2 THEN
      BEGIN
        SELECT MIN(CDOMICI)
          INTO X_CDOMICI
          FROM PER_DIRECCIONES
         WHERE SPERSON = PSPERSON;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          X_CDOMICI := 1;
      END;
    
      X_SALIDA := X_CDOMICI;
    END IF;
  
    RETURN(X_SALIDA);
  END F_CONVIVENCIA_OSIRIS;

  /****************************************************************************
      F_GET_COD_OSIRIS: DEVUELVE EL CÃƒÂ³DIGO DE LA PERSONA EL TABLA S03500 DE OSIRIS
      PARAMETERS:
              PSPERSON : IDENTIFICACIÃƒÂ³N DE LA PERSONA EN IAXIS (PER_PERSONA)
              PDBLINK :  NMBRE DEL DBLINK
  
     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCIÃƒÂ³N
     ---------  ----------  ---------------  ------------------------------------
     1.0        26/02/2019   CESS            FUNCIÃƒÂ³N QUE DEVUELVE EL VALOR DE CODIGO O CODIGO PRINCIPAL DE LA TABLA DE OSIRIS S03500, PARA LOS QUE HAYAN SIDO MIGRADOS DEVOLVERA EL CÃƒÂ³DIGO PARA LOS NUEVOS EN LA TABLA NO EXISTEN ENTONCES DEVOLVERA PSPERSON+IDDOMICI
  ****************************************************************************/

  FUNCTION F_GET_COD_OSIRIS(PSPERSON VARCHAR2,
                            PDBLINK  VARCHAR2,
                            PEXISTE  OUT VARCHAR) RETURN VARCHAR2 IS
  
    NNIT      VARCHAR2(16);
    SQL_QUERY VARCHAR2(2000) := 'SELECT A.CODIGO FROM S03500' || PDBLINK ||
                                ' A WHERE A.NIT = :PNIT AND A.CODIGOPPAL IS NULL
UNION
SELECT A.CODIGOPPAL FROM S03500' || PDBLINK ||
                                ' A WHERE A.NIT = :PNIT AND A.CODIGOPPAL IS NOT NULL';
    PCODIGO   VARCHAR2(16) := NULL;
  
  BEGIN
  
    BEGIN
      SELECT (CASE
               WHEN (A.CTIPIDE = '37') THEN
                SUBSTR(A.NNUMIDE, 0, LENGTH(A.NNUMIDE) - 1)
               ELSE
                A.NNUMIDE
             END)
        INTO NNIT
        FROM PER_PERSONAS A
       WHERE A.SPERSON = PSPERSON;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NNIT := NULL;
    END;
  
    BEGIN
      EXECUTE IMMEDIATE SQL_QUERY
        INTO PCODIGO
        USING NNIT, NNIT;
      PEXISTE := 'SI';
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        PEXISTE := 'NO';
        PCODIGO := PSPERSON ||
                   PAC_CONVIVENCIA.F_CONVIVENCIA_OSIRIS(PSPERSON, 2);
    END;
  
    --DBMS_OUTPUT.PUT_LINE('El cÃƒÂ³digo para el SPERSON:: '||PSPERSON||' es ::'||PCODIGO);
    RETURN PCODIGO;
  END F_GET_COD_OSIRIS;
  /****************************************************************************
      F_MARCAS_VINCULO: DEVUELVE LOS VINCULOS Y SU VALOR (0,1) SI LA PERSONA TIENE MARCA
      PARAMETERS:
              PSPERSON : IDENTIFICACIÃƒÂ³N DE LA PERSONA EN IAXIS (PER_PERSONA)
  
     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCIÃƒÂ³N
     ---------  ----------  ---------------  ------------------------------------
     1.0        28/02/2019   WAJ            FUNCIÃƒÂ³N QUE DEVUELVE EL VALOR DEL VINCULO SEGUN LA MARCA QUE TENGA
  ****************************************************************************/
  FUNCTION F_MARCAS_VINCULO(PSPERSON IN NUMBER) RETURN MARCAS_TYPE_MARCAS IS
  
    ROLE_USER_REC MARCAS_TYPE_MARCAS;
  
  BEGIN
  
    SELECT DATA_MARCAS(CMARCA,
                       CTOMADOR,
                       CCONSORCIO,
                       CASEGURADO,
                       CCODEUDOR,
                       CBENEF,
                       CACCIONISTA,
                       CINTERMED,
                       CREPRESEN,
                       CAPODERADO,
                       CPAGADOR,
                       CPROVEEDOR)
      BULK COLLECT
      INTO ROLE_USER_REC
      FROM PER_AGR_MARCAS A,
           (SELECT DISTINCT (CMARCA) MARCA, MAX(NMOVIMI) MOVIMI
              FROM PER_AGR_MARCAS
             WHERE SPERSON = PSPERSON
             GROUP BY CMARCA) B
     WHERE A.CMARCA = B.MARCA
       AND A.NMOVIMI = B.MOVIMI
       AND A.SPERSON = PSPERSON;
  
    RETURN ROLE_USER_REC;
  
  END F_MARCAS_VINCULO;
  /****************************************************************************
      F_OSIRIS_MARCAS: REALIZA VALIDACION SI EL TERCERO TIENE MARCA EN OSIRIS, SI LA TIENE LA ACTUALIZA, SI NO LA CREA EN OSIRIS
      PARAMETERS:
              PSPERSON : IDENTIFICACIÃƒÂ³N DE LA PERSONA EN IAXIS (PER_PERSONA)
  
     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCIÃƒÂ³N
     ---------  ----------  ---------------  ------------------------------------
     1.0        28/02/2019   WAJ            REALIZA VALIDACION SI EL TERCERO TIENE MARCA EN OSIRIS, SI LA TIENE LA ACTUALIZA, SI NO LA CREA EN OSIRIS
  ****************************************************************************/
  FUNCTION F_OSIRIS_MARCAS(PSPERSON IN NUMBER) RETURN VARCHAR2 IS
  
    X_SALIDA       VARCHAR2(1) := '0';
    PSMARCAS       MARCAS_TYPE_MARCAS;
    X_QUERY_COUNT  VARCHAR2(4000);
    X_QUERY_ESTADO VARCHAR2(4000);
    X_VINCULO      NUMBER;
    X_CONTEO       NUMBER;
    X_CONTEO1      NUMBER;
    X_PERSON       NUMBER;
    SI_CONVIVENCIA VARCHAR2(1); -- 0 => APAGADO | 1 => ENCENDIDO
  
  BEGIN
  
    SI_CONVIVENCIA := F_PAREMPRESA_T('CONVIVENCIA', 24);
  
    IF SI_CONVIVENCIA = '1' THEN
    
      SELECT QUERY_SELECT
        INTO X_QUERY_COUNT
        FROM CON_HOMOLOGA_OSIAX
       WHERE TOSIRIS = 'S03501'
         AND LABEL_CAMPO_OSI = 'SELECT'
         AND CAMPO_EXTRA1 = 'COUNT';
    
      SELECT QUERY_SELECT
        INTO X_QUERY_ESTADO
        FROM CON_HOMOLOGA_OSIAX
       WHERE TOSIRIS = 'S03501'
         AND LABEL_CAMPO_OSI = 'SELECT'
         AND CAMPO_EXTRA1 = 'ESTADO';
    
      X_PERSON := PSPERSON || F_CONVIVENCIA_OSIRIS(PSPERSON, 2);
    
      PSMARCAS := F_MARCAS_VINCULO(PSPERSON);
      IF PSMARCAS IS NOT NULL THEN
        FOR I IN PSMARCAS.FIRST .. PSMARCAS.LAST LOOP
          --TOMADOR/GARANTIZADO
          X_VINCULO := 1;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).TOMADOR = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).TOMADOR = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).TOMADOR);
              END IF;
            ELSE
              IF PSMARCAS(I).TOMADOR = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --CONSORCIO/CONSORCIOS - UNION TEMPOR
          X_VINCULO := 99;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).CONSORCIO = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).CONSORCIO = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).CONSORCIO);
              END IF;
            ELSE
              IF PSMARCAS(I).CONSORCIO = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --ASEGURADO/ASEGURADO 
          X_VINCULO := 60;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).ASEGURADO = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).ASEGURADO = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).ASEGURADO);
              END IF;
            ELSE
              IF PSMARCAS(I).ASEGURADO = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --CODEUDOR/CODEUDORES   
          X_VINCULO := 31;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).CODEUDOR = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).CODEUDOR = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).CODEUDOR);
              END IF;
            ELSE
              IF PSMARCAS(I).CODEUDOR = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --BENEFICIARIO/BENEFICIARIOS 
          X_VINCULO := 5;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).BENEFICIARIO = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).BENEFICIARIO = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).BENEFICIARIO);
              END IF;
            ELSE
              IF PSMARCAS(I).BENEFICIARIO = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --ACCIONISTA/ACCIONISTAS O ASOCIADOS  
          X_VINCULO := 50;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).ACCIONISTA = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).ACCIONISTA = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).ACCIONISTA);
              END IF;
            ELSE
              IF PSMARCAS(I).ACCIONISTA = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --INTERMEDIARIO/INTERMEDIARIO
          X_VINCULO := 2;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).INTERMEDIARIO = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).INTERMEDIARIO = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).INTERMEDIARIO);
              END IF;
            ELSE
              IF PSMARCAS(I).INTERMEDIARIO = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --REPRESENTANTE/REPRESENTANTE LEGAL
          X_VINCULO := 13;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).REPRESENTANTE = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).REPRESENTANTE = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).REPRESENTANTE);
              END IF;
            ELSE
              IF PSMARCAS(I).REPRESENTANTE = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --PROVEEDOR/PROVEEDORES
          X_VINCULO := 16;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).PROVEEDOR = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).PROVEEDOR = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).PROVEEDOR);
              END IF;
            ELSE
              IF PSMARCAS(I).PROVEEDOR = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
          --APODERADO
          X_VINCULO := 114;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).APODERADO = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).APODERADO = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).APODERADO);
              END IF;
            ELSE
              IF PSMARCAS(I).APODERADO = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
          --PAGADOR
          X_VINCULO := 113;
          X_CONTEO  := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                             X_QUERY_COUNT,
                                             X_VINCULO));
          IF X_CONTEO = 0 THEN
            IF PSMARCAS(I).PAGADOR = 1 THEN
              P_SEND_DATA(PSPERSON, 2, X_VINCULO);
            END IF;
          ELSE
            X_CONTEO1 := TO_NUMBER(F_GET_IAXIS(X_PERSON,
                                               X_QUERY_ESTADO,
                                               X_VINCULO));
            IF (X_CONTEO1 = PSMARCAS(I).MARCA OR X_CONTEO1 = 0) THEN
              IF PSMARCAS(I).PAGADOR = 1 THEN
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).MARCA);
              ELSE
                P_SEND_DATA(PSPERSON || ';' || X_VINCULO,
                            1,
                            PSMARCAS(I).PAGADOR);
              END IF;
            ELSE
              IF PSMARCAS(I).APODERADO = 1 THEN
                P_SEND_DATA(PSPERSON, 2, X_VINCULO);
              END IF;
            END IF;
          END IF;
        
        END LOOP;
      END IF;
      RETURN(X_SALIDA);
    
    END IF;
  
    RETURN '0';
  
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'PAC_CONVIVENCIA.f_Osiris_marcas',
                  1,
                  'Error en convivencia' || SQLCODE,
                  SQLERRM);
    
      RETURN '0';
    
  END F_OSIRIS_MARCAS;

  /*CAMBIOS PARA TAREA IAXIS-13044 : START */

  PROCEDURE P_SEND_DATA_CONVI(PNNUMIDE IN VARCHAR2,
                              PFLAG    IN NUMBER,
                              PTABLA   IN VARCHAR2,
                              PSINTERF IN NUMBER) AS
  
    V_SI_CONVIVENCIA    VARCHAR2(1); -- 0 => APAGADO | 1 => ENCENDIDO
    V_NBDLINK_NAME      VARCHAR2(200);
    V_CONTEXTO          NUMBER(10);
    V_CODIGO            VARCHAR2(20);
    V_CODIGO_OSI        VARCHAR2(20);
    V_CODIGO_COUNT      NUMBER := 0;
    V_CTIPPER           NUMBER;
    V_SIGLA             VARCHAR2(200);
    V_NOMBRE            VARCHAR2(250);
    V_SUCMOD            VARCHAR2(200);
    V_FECMOD            DATE;
    V_PRIMERAPELLIDO    VARCHAR2(200);
    V_SEGUNDOAPELLIDO   VARCHAR2(200);
    V_PRIMERNOMBRE      VARCHAR2(200);
    V_SEGUNDONOMBRE     VARCHAR2(200);
    V_QUERY             VARCHAR2(3000);
    V_MARCAS_COUNT      NUMBER := 0;
    V_OBJ_MARCAS        MARCAS_TYPE_MARCAS;
    V_VINCULO           NUMBER;
    V_SELECT_RESULT     VARCHAR2(2000);
    V_SSARLAFT          NUMBER;
    V_OPERACION         VARCHAR2(20);
    V_NO_DATA_ROWS_3502 NUMBER := 0;
    V_DATA_ROWS_3502    NUMBER := 0;
    V_ROWS_3502         NUMBER := 0;
    V_ROWS_3501         NUMBER := 0;
    V_COUNT_3512        NUMBER := 0;
    V_COUNT_SARLAFT     NUMBER := 0;
    V_FRADICA           DATE;
    V_FDILIGENCIA       DATE;
    V_NUMRADICACION     VARCHAR2(50);
    E_INSERT_S03500 EXCEPTION;
    V_FLAG             NUMBER;
    V_COUNT_MARCAS_OSI NUMBER := 0;
    V_TIPIDE_OSI       NUMBER;
    V_NNUMID_OSI       VARCHAR2(50);
    V_INSERT_S03501    VARCHAR2(3000);
    V_COUNT_3502       NUMBER :=0;
  
    CURSOR CUR_HOMOLOGAR(P_TOSIRIS    VARCHAR2,
                         P_FLAG       NUMBER,
                         P_TIPPERSONA NUMBER) IS
      SELECT *
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.TOSIRIS = P_TOSIRIS
         AND C.FLAG = P_FLAG
         AND C.TIPPERSONA IN (0, P_TIPPERSONA)
       ORDER BY C.NORDEN;
  
    CURSOR DEFAULT_MARCAS IS
      SELECT TRIM(REGEXP_SUBSTR((SELECT '1, 5, 60' FROM DUAL),
                                '[^,]+',
                                1,
                                LEVEL)) VINCULO
        FROM DUAL
      CONNECT BY INSTR((SELECT '1, 5, 60' FROM DUAL), ',', 1, LEVEL - 1) > 0;
  
    CURSOR CUR_INS_S03502(P_TIPPERSONA NUMBER) IS
      SELECT C.TOSIRIS,
             C.OSIRIS_CODIGO,
             C.SELECT_QUERY,
             'INSERT INTO ' || C.TOSIRIS || ':PARAM3' ||
             '(CODIGO,CODDET,VALDATE,VALNUMBER,VALSTRING,TEXTO,SUCREA,SUCMOD,FECREA,FECMOD)' ||
             ' VALUES (' || CHR(39) || ':PARAM1' || CHR(39) || ',' ||
             CHR(39) || C.OSIRIS_CODIGO || CHR(39) || ',' 
             || CHR(39) ||DECODE(C.TIPVALOR_OSI, 'DATE', ':PARAM2', NULL) || CHR(39) || ',' 
             || DECODE(C.TIPVALOR_OSI, 'NUMBER', ':PARAM2', 0) || ',' 
             || CHR(39) || DECODE(C.TIPVALOR_OSI, 'VARCHAR', ':PARAM2', NULL) || CHR(39) || ',' 
             || 'NULL,' || CHR(39) || F_USER || CHR(39) || ',' || CHR(39) ||
             F_USER || CHR(39) || ',' || CHR(39) ||
             TO_DATE(TO_CHAR(F_SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') ||
             CHR(39) || ',' || CHR(39) ||
             TO_DATE(TO_CHAR(F_SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') ||
             CHR(39) || ')' L_INSERT
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.TIPPERSONA IN (0, P_TIPPERSONA)
         AND C.TOSIRIS = 'S03502'
       ORDER BY C.NORDEN;
  
    CURSOR CUR_UPD_S03502(P_TIPPERSONA NUMBER) IS
      SELECT C.TOSIRIS,
             C.OSIRIS_CODIGO,
             C.SELECT_QUERY,
             'UPDATE ' || C.TOSIRIS || ':PARAM3' || ' SET ' ||
             DECODE(C.TIPVALOR_OSI,
                    'DATE',
                    'VALDATE',
                    'NUMBER',
                    'VALNUMBER',
                    'VARCHAR',
                    'VALSTRING') || ' = ' ||
             DECODE(C.TIPVALOR_OSI,
                    'DATE',
                    CHR(39) || ':PARAM2' || CHR(39),
                    'NUMBER',
                    ':PARAM2',
                    'VARCHAR',
                    CHR(39) || ':PARAM2' || CHR(39)) ||
                    ', SUCMOD = '|| CHR(39) || F_USER || CHR(39) ||
                    ', FECMOD = '|| CHR(39) || TO_DATE(TO_CHAR(F_SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY')|| CHR(39) ||
                    ' WHERE CODDET = ' || CHR(39) || C.OSIRIS_CODIGO || CHR(39) || 
                    ' AND CODIGO  = ' || CHR(39) || ':PARAM1' || CHR(39)
                     L_UPDATE
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.TIPPERSONA IN (0, P_TIPPERSONA)
         AND C.TOSIRIS = 'S03502'
       ORDER BY C.NORDEN;
  
      CURSOR CUR_CURR_S03502(P_TIPPERSONA NUMBER,P_OSIRIS_CODIGO VARCHAR2) IS
      SELECT C.TOSIRIS,
             C.OSIRIS_CODIGO,
             C.SELECT_QUERY,
             'INSERT INTO ' || C.TOSIRIS || ':PARAM3' ||
             '(CODIGO,CODDET,VALDATE,VALNUMBER,VALSTRING,TEXTO,SUCREA,SUCMOD,FECREA,FECMOD)' ||
             ' VALUES (' || CHR(39) || ':PARAM1' || CHR(39) || ',' ||
             CHR(39) || C.OSIRIS_CODIGO || CHR(39) || ',' 
             || CHR(39) ||DECODE(C.TIPVALOR_OSI, 'DATE', ':PARAM2', NULL) || CHR(39) || ',' 
             || DECODE(C.TIPVALOR_OSI, 'NUMBER', ':PARAM2', 0) || ',' 
             || CHR(39) || DECODE(C.TIPVALOR_OSI, 'VARCHAR', ':PARAM2', NULL) || CHR(39) || ',' 
             || 'NULL,' || CHR(39) || F_USER || CHR(39) || ',' || CHR(39) ||
             F_USER || CHR(39) || ',' || CHR(39) ||
             TO_DATE(TO_CHAR(F_SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') ||
             CHR(39) || ',' || CHR(39) ||
             TO_DATE(TO_CHAR(F_SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') ||
             CHR(39) || ')' L_INSERT
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.TIPPERSONA IN (0, P_TIPPERSONA)
         AND C.TOSIRIS = 'S03502'
         AND C.OSIRIS_CODIGO = P_OSIRIS_CODIGO;
  
  BEGIN
  
    EXECUTE IMMEDIATE 'alter session set global_names = true';
  
    V_SI_CONVIVENCIA := F_PAREMPRESA_T('CONVIVENCIA', 24);
  
    IF V_SI_CONVIVENCIA = '1' THEN
    
      SELECT PAC_CONTEXTO.F_INICIALIZARCTX(PAC_PARAMETROS.F_PAREMPRESA_T(24,
                                                                         'USER_BBDD'))
        INTO V_CONTEXTO
        FROM DUAL;
    
      V_NBDLINK_NAME := F_PARINSTALACION_T('DBLINK');
    
      SELECT PP.CTIPIDE
        INTO V_TIPIDE_OSI
        FROM PER_PERSONAS PP
       WHERE PP.NNUMIDE = PNNUMIDE;
    
      SELECT DECODE(V_TIPIDE_OSI,
                    37,
                    SUBSTR(PNNUMIDE, 1, LENGTH(PNNUMIDE) - 1),
                    PNNUMIDE)
        INTO V_NNUMID_OSI
        FROM DUAL;
    
      IF PTABLA IS NULL THEN
        -- FOR COMPLETE INSERT OR UPDATE PTABLA WILL BE NULL           
      
        V_QUERY := 'SELECT COUNT(*)
          FROM S03500:PARAM1 S500
         WHERE S500.NIT =' || CHR(39) || V_NNUMID_OSI ||
                   CHR(39);
      
        V_QUERY := REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME);
      
        EXECUTE IMMEDIATE V_QUERY
          INTO V_CODIGO_COUNT;
      
        IF V_CODIGO_COUNT = 0 THEN
        
          -- INSERT
          V_OPERACION := 'INSERT';
          V_FLAG      := 0;
          --S03500
          BEGIN
            BEGIN
              SELECT PP.SPERSON, PP.CTIPPER
                INTO V_CODIGO, V_CTIPPER
                FROM PER_PERSONAS PP
               WHERE PP.NNUMIDE = PNNUMIDE;
            
              FOR FILA IN CUR_HOMOLOGAR('S03500', V_FLAG, V_CTIPPER) LOOP
              
                V_QUERY := REPLACE(REPLACE(FILA.INSERT_QUERY,
                                           ':PSPERSON',
                                           V_CODIGO),
                                   ':PARAM1',
                                   V_NBDLINK_NAME);
                EXECUTE IMMEDIATE V_QUERY;
              END LOOP;
              COMMIT;
              PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                           PI_NNUMIDE      => PNNUMIDE,
                                           PI_TABLA_OSIRIS => 'S03500',
                                           PI_OPERACION    => V_OPERACION,
                                           PI_ESTADO       => 1,
                                           PI_RESPUESTA    => 'Datos insertados correctamente para S03500');
            
            EXCEPTION
              WHEN OTHERS THEN
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                            1,
                            'ERROR S03500 = ' || V_OPERACION || ' :' ||
                            SQLERRM,
                            'QUERY = ' || V_QUERY);
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03500',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 2,
                                             PI_RESPUESTA    => SQLERRM);
                RAISE E_INSERT_S03500;
              
            END;
          
            --S03501
            BEGIN
              SELECT C.INSERT_QUERY
                INTO V_INSERT_S03501
                FROM CON_HOMOLOGA_CONVI C
               WHERE C.OSIRIS_CODIGO = 'V_INS_S03501';
            
              BEGIN
                SELECT COUNT(*)
                  INTO V_MARCAS_COUNT
                  FROM PER_AGR_MARCAS P
                 WHERE P.SPERSON = V_CODIGO
                   AND P.NMOVIMI =
                       (SELECT MAX(PAM.NMOVIMI)
                          FROM PER_AGR_MARCAS PAM
                         WHERE PAM.SPERSON = V_CODIGO);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_MARCAS_COUNT := 0;
              END;
            
              IF V_MARCAS_COUNT = 0 THEN
                -- WHEN DOES NOT EXISTS MARCAS
                -- NEED TO PUT DEFAULT MARCAS
                FOR DEFMAR IN DEFAULT_MARCAS LOOP
                  V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                     ':PSPERSON',
                                                                     V_CODIGO),
                                                             ':PESTADO',
                                                             0),
                                                     ':PCODVIN',
                                                     DEFMAR.VINCULO),
                                             ':PARAM1',
                                             V_NBDLINK_NAME),
                                     ':OSI_CODIGO',
                                     V_CODIGO);
                  EXECUTE IMMEDIATE V_QUERY;
                  COMMIT;
                END LOOP;
              
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03501',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 1,
                                             PI_RESPUESTA    => 'Datos insertados correctamente para S03501');
              ELSE
                -- NEED TO PUT MARCAS BASED ON TABLE PER_AGR_MARCAS
                V_OBJ_MARCAS := F_MARCAS_VINCULO(V_CODIGO);
                FOR MAR IN V_OBJ_MARCAS.FIRST .. V_OBJ_MARCAS.LAST LOOP
                  IF TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA) = 301 THEN
                    CONTINUE;
                  ELSE                    
                    IF V_OBJ_MARCAS(MAR).TOMADOR = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 1;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).CONSORCIO = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 99;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).ASEGURADO = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 60;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).CODEUDOR = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 31;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).BENEFICIARIO = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 5;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).ACCIONISTA = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 50;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).INTERMEDIARIO = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 2;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).REPRESENTANTE = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 13;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).APODERADO = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 14;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).PAGADOR = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 113;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                    IF V_OBJ_MARCAS(MAR).PROVEEDOR = 1 THEN
                      V_ROWS_3501 := V_ROWS_3501 + 1;
                      V_VINCULO   := 16;
                      V_QUERY     := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                             ':PSPERSON',
                                                                             V_CODIGO),
                                                                     ':PARAM1',
                                                                     V_NBDLINK_NAME),
                                                             ':PCODVIN',
                                                             V_VINCULO),
                                                     ':PESTADO',
                                                     TO_NUMBER(V_OBJ_MARCAS(MAR)
                                                               .MARCA)),
                                             ':OSI_CODIGO',
                                             V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END IF;
                  END IF;                    
                  END LOOP;
                
                  IF V_ROWS_3501 > 0 THEN
                    PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                                 PI_NNUMIDE      => PNNUMIDE,
                                                 PI_TABLA_OSIRIS => 'S03501',
                                                 PI_OPERACION    => V_OPERACION,
                                                 PI_ESTADO       => 1,
                                                 PI_RESPUESTA    => 'Datos insertados correctamente para S03501');
                  ELSE
                    FOR DEFMAR IN DEFAULT_MARCAS LOOP
                      V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                         ':PSPERSON',
                                                                         V_CODIGO),
                                                                 ':PESTADO',
                                                                 0),
                                                         ':PCODVIN',
                                                         DEFMAR.VINCULO),
                                                 ':PARAM1',
                                                 V_NBDLINK_NAME),
                                         ':OSI_CODIGO',
                                         V_CODIGO);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    END LOOP;
                    PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                                 PI_NNUMIDE      => PNNUMIDE,
                                                 PI_TABLA_OSIRIS => 'S03501',
                                                 PI_OPERACION    => V_OPERACION,
                                                 PI_ESTADO       => 1,
                                                 PI_RESPUESTA    => 'Datos insertados correctamente para S03501');
                  END IF;
                END IF;       
            EXCEPTION
              WHEN OTHERS THEN
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                            1,
                            'ERROR S03501 = ' || V_OPERACION || ' :' ||
                            SQLERRM,
                            'QUERY = ' || V_QUERY);
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03501',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 2,
                                             PI_RESPUESTA    => SQLERRM);
            END;
          
            --S03512
            -- WHILE CREATING PERSON DATSARLF TABLE DOES NOT HAVE DATA
          
            --S03502
            BEGIN
            
              FOR FILA IN CUR_INS_S03502(V_CTIPPER) LOOP
                V_ROWS_3502 := V_ROWS_3502 + 1;
                BEGIN
                  EXECUTE IMMEDIATE REPLACE(FILA.SELECT_QUERY,
                                            ':PSPERSON',
                                            V_CODIGO)
                    INTO V_SELECT_RESULT;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_NO_DATA_ROWS_3502 := V_NO_DATA_ROWS_3502 + 1;
                    V_QUERY             := REPLACE(REPLACE(REPLACE(FILA.L_INSERT,
                                                                   ':PARAM1',
                                                                   V_CODIGO),
                                                           ':PARAM2',
                                                           NULL),
                                                   ':PARAM3',
                                                   V_NBDLINK_NAME);
                  
                    EXECUTE IMMEDIATE V_QUERY;
                    COMMIT;
                    CONTINUE;
                END;
                BEGIN
                  IF V_SELECT_RESULT IS NOT NULL THEN
                  
                    V_DATA_ROWS_3502 := V_DATA_ROWS_3502 + 1;
                  
                    V_QUERY := REPLACE(REPLACE(REPLACE(FILA.L_INSERT,
                                                       ':PARAM1',
                                                       V_CODIGO),
                                               ':PARAM2',
                                               V_SELECT_RESULT),
                                       ':PARAM3',
                                       V_NBDLINK_NAME);
                  
                    EXECUTE IMMEDIATE V_QUERY;
                    COMMIT;
                  ELSE
                    V_NO_DATA_ROWS_3502 := V_NO_DATA_ROWS_3502 + 1;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    P_TAB_ERROR(F_SYSDATE,
                                F_USER,
                                'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                                1,
                                'ERROR S03502 = ' || V_OPERACION || ' :' ||
                                SQLERRM,
                                'QUERY = ' || V_QUERY);
                END;
              END LOOP;
            
              IF (V_ROWS_3502 = (V_NO_DATA_ROWS_3502 + V_DATA_ROWS_3502)) THEN
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03502',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 1,
                                             PI_RESPUESTA    => 'Datos insertados correctamente para S03502');
              ELSE
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03502',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 2,
                                             PI_RESPUESTA    => SQLERRM);
              END IF;
            
            EXCEPTION
              WHEN OTHERS THEN
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                            1,
                            'ERROR S03502 = ' || V_OPERACION || ' :' ||
                            SQLERRM,
                            'Error fin S03502'); -- TESTING
            END;
          
          EXCEPTION
            WHEN E_INSERT_S03500 THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                          1,
                          'ERROR E_INSERT_S03500 = ' || V_OPERACION || ' :' ||
                          SQLERRM,
                          'QUERY = ' || V_QUERY);
          END;
        ELSE
          -- UPDATE                   
          V_OPERACION := 'UPDATE';
          V_FLAG      := 1;
          BEGIN
            V_QUERY := 'SELECT MAX(S500.CODIGO)
                      FROM S03500:PARAM1 S500
                     WHERE S500.NIT =' || CHR(39) ||
                       V_NNUMID_OSI || CHR(39);
          
            EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
              INTO V_CODIGO_OSI;
          
            SELECT PP.SPERSON, PP.CTIPPER
              INTO V_CODIGO, V_CTIPPER
              FROM PER_PERSONAS PP
             WHERE PP.NNUMIDE = PNNUMIDE;
          
            --S03500            
            BEGIN
              IF V_CTIPPER = 1 THEN
                SELECT CUSUARI
                  INTO V_SUCMOD
                  FROM PER_PERSONAS
                 WHERE SPERSON = V_CODIGO;
                SELECT FMOVIMI
                  INTO V_FECMOD
                  FROM PER_PERSONAS
                 WHERE SPERSON = V_CODIGO;
                SELECT TAPELLI1
                  INTO V_PRIMERAPELLIDO
                  FROM PER_DETPER
                 WHERE SPERSON = V_CODIGO;
                SELECT TAPELLI2
                  INTO V_SEGUNDOAPELLIDO
                  FROM PER_DETPER
                 WHERE SPERSON = V_CODIGO;
                SELECT TNOMBRE1
                  INTO V_PRIMERNOMBRE
                  FROM PER_DETPER
                 WHERE SPERSON = V_CODIGO;
                SELECT TNOMBRE2
                  INTO V_SEGUNDONOMBRE
                  FROM PER_DETPER
                 WHERE SPERSON = V_CODIGO;
              
                SELECT SUBSTR(PAC_CONVIVENCIA.F_GET_NOMBRE(V_CODIGO),
                              1,
                              20)
                  INTO V_SIGLA
                  FROM DUAL;
                SELECT SUBSTR(PAC_CONVIVENCIA.F_GET_NOMBRE(V_CODIGO),
                              1,
                              250)
                  INTO V_NOMBRE
                  FROM DUAL;
              
                FOR FILA IN CUR_HOMOLOGAR('S03500', V_FLAG, V_CTIPPER) LOOP
                  V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(FILA.UPDATE_QUERY,
                                                                                                             ':PSPERSON',
                                                                                                             V_CODIGO_OSI),
                                                                                                     ':PSEGUNDONOMBRE',
                                                                                                     V_SEGUNDONOMBRE),
                                                                                             ':PPRIMERNOMBRE',
                                                                                             V_PRIMERNOMBRE),
                                                                                     ':PSEGUNDOAPELLIDO',
                                                                                     V_SEGUNDOAPELLIDO),
                                                                             ':PPRIMERAPELLIDO',
                                                                             V_PRIMERAPELLIDO),
                                                                     ':PFECMOD',
                                                                     V_FECMOD),
                                                             ':PSUCMOD',
                                                             V_SUCMOD),
                                                     ':PSIGLA',
                                                     V_SIGLA),
                                             ':PNOMBRE',
                                             V_NOMBRE),
                                     ':PARAM1',
                                     V_NBDLINK_NAME);
                  --DBMS_OUTPUT.PUT_LINE('Update :' || V_QUERY); -- TESTING
                  EXECUTE IMMEDIATE V_QUERY;
                END LOOP;
              
              ELSE
                SELECT CUSUARI
                  INTO V_SUCMOD
                  FROM PER_PERSONAS
                 WHERE SPERSON = V_CODIGO;
                SELECT FMOVIMI
                  INTO V_FECMOD
                  FROM PER_PERSONAS
                 WHERE SPERSON = V_CODIGO;
                SELECT SUBSTR(TAPELLI1, 1, 20)
                  INTO V_SIGLA
                  FROM PER_DETPER
                 WHERE SPERSON = V_CODIGO;
                SELECT SUBSTR(TAPELLI1, 1, 250)
                  INTO V_NOMBRE
                  FROM PER_DETPER
                 WHERE SPERSON = V_CODIGO;
              
                FOR FILA IN CUR_HOMOLOGAR('S03500', V_FLAG, V_CTIPPER) LOOP
                  V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(FILA.UPDATE_QUERY,
                                                                             ':PSPERSON',
                                                                             V_CODIGO_OSI),
                                                                     ':PFECMOD',
                                                                     V_FECMOD),
                                                             ':PSUCMOD',
                                                             V_SUCMOD),
                                                     ':PNOMBRE',
                                                     V_NOMBRE),
                                             ':PSIGLA',
                                             V_SIGLA),
                                     ':PARAM1',
                                     V_NBDLINK_NAME);
                  --DBMS_OUTPUT.PUT_LINE('Update :' || V_QUERY); -- TESTING
                  EXECUTE IMMEDIATE V_QUERY;
                END LOOP;
              
              END IF;
              COMMIT;
              PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                           PI_NNUMIDE      => PNNUMIDE,
                                           PI_TABLA_OSIRIS => 'S03500',
                                           PI_OPERACION    => V_OPERACION,
                                           PI_ESTADO       => 1,
                                           PI_RESPUESTA    => 'Datos actualizado correctamente para S03500');
            EXCEPTION
              WHEN OTHERS THEN
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                            1,
                            'ERROR S03500 = ' || V_OPERACION || ' :' ||
                            SQLERRM,
                            'QUERY = ' || V_QUERY);
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03500',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 2,
                                             PI_RESPUESTA    => SQLERRM);
            END;
          
            --S03501
            BEGIN
              -- WHEN EXISTS MARCAS
              --FIRST NEED TO COPY MARCAS FROM S03501 TO S03501B TABLA AND REMOVE OLD MARCAS FROM S03501 TABLA  
            
              PAC_CONVIVENCIA.P_SET_MARCAS_VINDULO(PI_NNUMIDE    => PNNUMIDE,
                                                   PI_CODIGO     => V_CODIGO,
                                                   PI_CODIGO_OSI => V_CODIGO_OSI,
                                                   PI_CTIPPER    => V_CTIPPER,
                                                   PI_SINTERF    => PSINTERF,
                                                   PI_DBLINK     => V_NBDLINK_NAME);
            EXCEPTION
              WHEN OTHERS THEN
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                            1,
                            'ERROR S03501 = ' || V_OPERACION || ' :' ||
                            SQLERRM,
                            'QUERY = ' || V_QUERY);
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03501',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 2,
                                             PI_RESPUESTA    => SQLERRM);
            END;
          
            --S03512
            BEGIN
              V_QUERY := 'SELECT COUNT(*)
                      FROM S03512:PARAM1 S512
                      WHERE S512.PERSONA =' ||
                         CHR(39) || V_CODIGO_OSI || CHR(39);
            
              EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
                INTO V_COUNT_3512;
            
              BEGIN
                SELECT D.SSARLAFT
                  INTO V_SSARLAFT
                  FROM DATSARLATF D
                 WHERE SPERSON = V_CODIGO
                   AND FRADICA = (SELECT MAX(FRADICA)
                                    FROM DATSARLATF
                                   WHERE SPERSON = V_CODIGO);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_SSARLAFT := NULL;
              END;
            
              IF V_SSARLAFT IS NOT NULL THEN
                BEGIN
                  SELECT D.FRADICA, D.FDILIGENCIA
                    INTO V_FRADICA, V_FDILIGENCIA
                    FROM DATSARLATF D
                   WHERE SPERSON = V_CODIGO
                     AND SSARLAFT = V_SSARLAFT;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_FRADICA     := NULL;
                    V_FDILIGENCIA := NULL;
                END;
              
                IF V_COUNT_3512 > 0 AND V_SSARLAFT IS NOT NULL THEN
                
                  V_QUERY := 'SELECT MAX(S512.NUMRADICACION) FROM S03512:PARAM1 S512 WHERE S512.PERSONA =' ||
                             CHR(39) || V_CODIGO_OSI || CHR(39);
                
                  EXECUTE IMMEDIATE REPLACE(V_QUERY,
                                            ':PARAM1',
                                            V_NBDLINK_NAME)
                    INTO V_NUMRADICACION;
                
                  FOR FILA IN CUR_HOMOLOGAR('S03512', V_FLAG, V_CTIPPER) LOOP
                    V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(FILA.UPDATE_QUERY,
                                                                       ':PSPERSON',
                                                                       V_CODIGO_OSI),
                                                               ':PARAM1',
                                                               V_NBDLINK_NAME),
                                                       ':PSSARLAFT',
                                                       V_NUMRADICACION),
                                               ':FDILIGENCIA',
                                               V_FDILIGENCIA),
                                       ':FRADICA',
                                       V_FRADICA);
                    EXECUTE IMMEDIATE V_QUERY;
                  END LOOP;
                  COMMIT;
                  PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                               PI_NNUMIDE      => PNNUMIDE,
                                               PI_TABLA_OSIRIS => 'S03512',
                                               PI_OPERACION    => V_OPERACION,
                                               PI_ESTADO       => 1,
                                               PI_RESPUESTA    => 'Datos actualizado correctamente para S03512');
                END IF;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                            1,
                            'ERROR S03512 = ' || V_OPERACION || ' :' ||
                            SQLERRM,
                            'QUERY = ' || V_QUERY);
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03512',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 2,
                                             PI_RESPUESTA    => SQLERRM);
            END;
          
            --S03502
            BEGIN
              V_DATA_ROWS_3502 := 0;
              V_ROWS_3502      := 0;
              V_ROWS_3502      := 0;
              FOR FILA IN CUR_UPD_S03502(V_CTIPPER) LOOP
                V_ROWS_3502 := V_ROWS_3502 + 1;
                BEGIN
                  V_QUERY := REPLACE(FILA.SELECT_QUERY,
                                     ':PSPERSON',
                                     V_CODIGO);
                  EXECUTE IMMEDIATE V_QUERY
                    INTO V_SELECT_RESULT;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_NO_DATA_ROWS_3502 := V_NO_DATA_ROWS_3502 + 1;
                    
                    V_COUNT_3502 := 0;
                    V_QUERY := 'SELECT COUNT(*)
                              FROM S03502:PARAM1 S502
                              WHERE S502.CODIGO =' || CHR(39) ||V_CODIGO_OSI || CHR(39)||
                              ' AND S502.CODDET ='|| CHR(39) ||FILA.OSIRIS_CODIGO || CHR(39);                                
                  
                    EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
                    INTO V_COUNT_3502;                              
                    IF V_COUNT_3502 > 0 THEN
                      V_DATA_ROWS_3502 := V_DATA_ROWS_3502 + 1;
                      V_QUERY          := REPLACE(REPLACE(REPLACE(FILA.L_UPDATE,
                                                                  ':PARAM1',
                                                                  V_CODIGO_OSI),
                                                          ':PARAM2',
                                                          NULL),
                                                  ':PARAM3',
                                                  V_NBDLINK_NAME);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    ELSE
                       FOR FILA_CUR IN CUR_CURR_S03502(V_CTIPPER,FILA.OSIRIS_CODIGO) LOOP
                           V_ROWS_3502 := V_ROWS_3502 + 1;
                             V_QUERY := REPLACE(REPLACE(REPLACE(FILA_CUR.L_INSERT,
                                                                         ':PARAM1',
                                                                         V_CODIGO_OSI),
                                                                 ':PARAM2',
                                                                 NULL),
                                                         ':PARAM3',
                                                         V_NBDLINK_NAME);
                    
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                       END LOOP;
                    END IF;
                CONTINUE;
                END;
                BEGIN
                  IF V_SELECT_RESULT IS NOT NULL THEN
                    
                  V_COUNT_3502 := 0;
                  V_QUERY := 'SELECT COUNT(*)
                              FROM S03502:PARAM1 S502
                              WHERE S502.CODIGO =' || CHR(39) ||V_CODIGO_OSI || CHR(39)||
                              ' AND S502.CODDET ='|| CHR(39) ||FILA.OSIRIS_CODIGO || CHR(39);                                
                  
                   EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
                    INTO V_COUNT_3502;                              
                    IF V_COUNT_3502 > 0 THEN
                      V_DATA_ROWS_3502 := V_DATA_ROWS_3502 + 1;
                      V_QUERY          := REPLACE(REPLACE(REPLACE(FILA.L_UPDATE,
                                                                  ':PARAM1',
                                                                  V_CODIGO_OSI),
                                                          ':PARAM2',
                                                          V_SELECT_RESULT),
                                                  ':PARAM3',
                                                  V_NBDLINK_NAME);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    ELSE
                       FOR FILA_CUR IN CUR_CURR_S03502(V_CTIPPER,FILA.OSIRIS_CODIGO) LOOP
                           V_ROWS_3502 := V_ROWS_3502 + 1;
                             V_QUERY := REPLACE(REPLACE(REPLACE(FILA_CUR.L_INSERT,
                                                                         ':PARAM1',
                                                                         V_CODIGO_OSI),
                                                                 ':PARAM2',
                                                                 V_SELECT_RESULT),
                                                         ':PARAM3',
                                                         V_NBDLINK_NAME);
                    
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                       END LOOP;
                    END IF;
                  ELSE
                    V_NO_DATA_ROWS_3502 := V_NO_DATA_ROWS_3502 + 1;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    P_TAB_ERROR(F_SYSDATE,
                                F_USER,
                                'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                                1,
                                'ERROR S03502 = ' || V_OPERACION || ' :' ||
                                SQLERRM,
                                'QUERY = ' || V_QUERY);
                END;
              END LOOP;
            
              IF (V_ROWS_3502 = (V_NO_DATA_ROWS_3502 + V_DATA_ROWS_3502)) THEN
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03502',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 1,
                                             PI_RESPUESTA    => 'Datos actualizado correctamente para S03502');
              ELSE
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03502',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 2,
                                             PI_RESPUESTA    => SQLERRM);
              END IF;
            
            EXCEPTION
              WHEN OTHERS THEN
                P_TAB_ERROR(F_SYSDATE,
                            F_USER,
                            'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                            1,
                            'ERROR S03502 = ' || V_OPERACION || ' :' ||
                            SQLERRM,
                            'Error fin S03502');
            END;
          END;
        END IF;
      
      ELSE
        -- TO UPDATE OR INSERT CORRESPONDING DATA NEED OSRIS TABLE NAME IN PTABLA 
        V_QUERY := 'SELECT MAX(S500.CODIGO)
                      FROM S03500:PARAM1 S500
                    WHERE S500.NIT =' || CHR(39) ||
                   V_NNUMID_OSI || CHR(39);
      
        EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
          INTO V_CODIGO_OSI;
      
        SELECT PP.SPERSON, PP.CTIPPER
          INTO V_CODIGO, V_CTIPPER
          FROM PER_PERSONAS PP
         WHERE PP.NNUMIDE = PNNUMIDE;
      
        IF PTABLA = 'S03512' THEN
          BEGIN
            V_QUERY := 'SELECT COUNT(*)
                      FROM S03512:PARAM1 S512
                      WHERE S512.PERSONA =' ||
                       CHR(39) || V_CODIGO_OSI || CHR(39);
          
            EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
              INTO V_COUNT_3512;
          
            BEGIN
              SELECT D.SSARLAFT
                INTO V_SSARLAFT
                FROM DATSARLATF D
               WHERE SPERSON = V_CODIGO
                 AND FRADICA = (SELECT MAX(FRADICA)
                                  FROM DATSARLATF
                                 WHERE SPERSON = V_CODIGO);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_SSARLAFT := NULL;
            END;
          
            IF V_COUNT_3512 = 0 AND V_SSARLAFT IS NOT NULL THEN
              V_OPERACION := 'INSERT';
              FOR FILA IN CUR_HOMOLOGAR('S03512', 0, V_CTIPPER) LOOP
                V_QUERY := REPLACE(REPLACE(FILA.INSERT_QUERY,
                                           ':PSPERSON',
                                           V_CODIGO),
                                   ':PARAM1',
                                   V_NBDLINK_NAME);
                EXECUTE IMMEDIATE V_QUERY;
              END LOOP;
              COMMIT;
              PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                           PI_NNUMIDE      => PNNUMIDE,
                                           PI_TABLA_OSIRIS => 'S03512',
                                           PI_OPERACION    => V_OPERACION,
                                           PI_ESTADO       => 1,
                                           PI_RESPUESTA    => 'Datos insertados correctamente para S03512');
            ELSIF V_COUNT_3512 > 0 AND V_SSARLAFT IS NOT NULL THEN
              V_OPERACION := 'UPDATE';
            
              V_QUERY := 'SELECT MAX(S512.NUMRADICACION)
                          FROM S03512:PARAM1 S512
                          WHERE S512.PERSONA =' ||
                         CHR(39) || V_CODIGO_OSI || CHR(39);
            
              EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
                INTO V_NUMRADICACION;
            
              IF V_SSARLAFT IS NOT NULL THEN
                BEGIN
                  SELECT D.FRADICA, D.FDILIGENCIA
                    INTO V_FRADICA, V_FDILIGENCIA
                    FROM DATSARLATF D
                   WHERE SPERSON = V_CODIGO
                     AND SSARLAFT = V_SSARLAFT;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    V_FRADICA     := NULL;
                    V_FDILIGENCIA := NULL;
                END;
              
                FOR FILA IN CUR_HOMOLOGAR('S03512', 1, V_CTIPPER) LOOP
                  V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(FILA.UPDATE_QUERY,
                                                                     ':PSPERSON',
                                                                     V_CODIGO_OSI),
                                                             ':PARAM1',
                                                             V_NBDLINK_NAME),
                                                     ':PSSARLAFT',
                                                     V_NUMRADICACION),
                                             ':FDILIGENCIA',
                                             V_FDILIGENCIA),
                                     ':FRADICA',
                                     V_FRADICA);
                  EXECUTE IMMEDIATE V_QUERY;
                END LOOP;
                COMMIT;
                PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                             PI_NNUMIDE      => PNNUMIDE,
                                             PI_TABLA_OSIRIS => 'S03512',
                                             PI_OPERACION    => V_OPERACION,
                                             PI_ESTADO       => 1,
                                             PI_RESPUESTA    => 'Datos actualizado correctamente para S03512');
              END IF;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                          1,
                          'ERROR S03512 = ' || V_OPERACION || ' :' ||
                          SQLERRM,
                          'Query : ' || V_QUERY);
              PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                           PI_NNUMIDE      => PNNUMIDE,
                                           PI_TABLA_OSIRIS => 'S03512',
                                           PI_OPERACION    => V_OPERACION,
                                           PI_ESTADO       => 2,
                                           PI_RESPUESTA    => SQLERRM);
          END;
        
        ELSIF PTABLA = 'S03502' THEN
        
          BEGIN
            V_OPERACION      := 'UPDATE';
            V_DATA_ROWS_3502 := 0;
            V_ROWS_3502      := 0;
            V_ROWS_3502      := 0;
            FOR FILA IN CUR_UPD_S03502(V_CTIPPER) LOOP
              V_ROWS_3502 := V_ROWS_3502 + 1;
              BEGIN
                V_QUERY := REPLACE(FILA.SELECT_QUERY, ':PSPERSON', V_CODIGO);
                EXECUTE IMMEDIATE V_QUERY
                  INTO V_SELECT_RESULT;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_NO_DATA_ROWS_3502 := V_NO_DATA_ROWS_3502 + 1;
                  
                  V_COUNT_3502 := 0;
                  V_QUERY := 'SELECT COUNT(*)
                              FROM S03502:PARAM1 S502
                              WHERE S502.CODIGO =' || CHR(39) ||V_CODIGO_OSI || CHR(39)||
                              ' AND S502.CODDET ='|| CHR(39) ||FILA.OSIRIS_CODIGO || CHR(39);  
                  
                    EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
                    INTO V_COUNT_3502;                              
                    IF V_COUNT_3502 > 0 THEN
                      V_DATA_ROWS_3502 := V_DATA_ROWS_3502 + 1;
                      V_QUERY          := REPLACE(REPLACE(REPLACE(FILA.L_UPDATE,
                                                                  ':PARAM1',
                                                                  V_CODIGO_OSI),
                                                          ':PARAM2',
                                                          NULL),
                                                  ':PARAM3',
                                                  V_NBDLINK_NAME);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    ELSE
                       FOR FILA_CUR IN CUR_CURR_S03502(V_CTIPPER,FILA.OSIRIS_CODIGO) LOOP
                           V_ROWS_3502 := V_ROWS_3502 + 1;
                             V_QUERY := REPLACE(REPLACE(REPLACE(FILA_CUR.L_INSERT,
                                                                         ':PARAM1',
                                                                         V_CODIGO_OSI),
                                                                 ':PARAM2',
                                                                 NULL),
                                                         ':PARAM3',
                                                         V_NBDLINK_NAME);
                    
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                       END LOOP;
                    END IF;
                  CONTINUE;
              END;
              BEGIN
                  IF V_SELECT_RESULT IS NOT NULL THEN
                  V_COUNT_3502 := 0;
                  V_QUERY := 'SELECT COUNT(*)
                              FROM S03502:PARAM1 S502
                              WHERE S502.CODIGO =' || CHR(39) ||V_CODIGO_OSI || CHR(39)||
                             ' AND S502.CODDET ='|| CHR(39) ||FILA.OSIRIS_CODIGO || CHR(39);   
                  
                    EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
                    INTO V_COUNT_3502;                              
                    IF V_COUNT_3502 > 0 THEN
                      V_DATA_ROWS_3502 := V_DATA_ROWS_3502 + 1;
                      V_QUERY          := REPLACE(REPLACE(REPLACE(FILA.L_UPDATE,
                                                                  ':PARAM1',
                                                                  V_CODIGO_OSI),
                                                          ':PARAM2',
                                                          V_SELECT_RESULT),
                                                  ':PARAM3',
                                                  V_NBDLINK_NAME);
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                    ELSE
                       FOR FILA_CUR IN CUR_CURR_S03502(V_CTIPPER,FILA.OSIRIS_CODIGO) LOOP
                           V_ROWS_3502 := V_ROWS_3502 + 1;
                             V_QUERY := REPLACE(REPLACE(REPLACE(FILA_CUR.L_INSERT,
                                                                         ':PARAM1',
                                                                         V_CODIGO_OSI),
                                                                 ':PARAM2',
                                                                 V_SELECT_RESULT),
                                                         ':PARAM3',
                                                         V_NBDLINK_NAME);
                    
                      EXECUTE IMMEDIATE V_QUERY;
                      COMMIT;
                       END LOOP;
                    END IF;
                  ELSE
                    V_NO_DATA_ROWS_3502 := V_NO_DATA_ROWS_3502 + 1;
                  END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  P_TAB_ERROR(F_SYSDATE,
                              F_USER,
                              'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                              1,
                              'ERROR S03502 = ' || V_OPERACION || ' :' ||
                              SQLERRM,
                              'QUERY = ' || V_QUERY);
              END;
            END LOOP;
          
            IF (V_ROWS_3502 = (V_NO_DATA_ROWS_3502 + V_DATA_ROWS_3502)) THEN
              PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                           PI_NNUMIDE      => PNNUMIDE,
                                           PI_TABLA_OSIRIS => 'S03502',
                                           PI_OPERACION    => V_OPERACION,
                                           PI_ESTADO       => 1,
                                           PI_RESPUESTA    => 'Datos actualizado correctamente para S03502');
            ELSE
              PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                           PI_NNUMIDE      => PNNUMIDE,
                                           PI_TABLA_OSIRIS => 'S03502',
                                           PI_OPERACION    => V_OPERACION,
                                           PI_ESTADO       => 2,
                                           PI_RESPUESTA    => SQLERRM);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                          1,
                          'ERROR S03502 only = ' || V_OPERACION || ' :' ||
                          SQLERRM,
                          'Error fin S03502');
              PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                           PI_NNUMIDE      => PNNUMIDE,
                                           PI_TABLA_OSIRIS => 'S03502',
                                           PI_OPERACION    => V_OPERACION,
                                           PI_ESTADO       => 2,
                                           PI_RESPUESTA    => SQLERRM);
          END;
        
        ELSIF PTABLA = 'S03501' THEN
          BEGIN
            PAC_CONVIVENCIA.P_SET_MARCAS_VINDULO(PI_NNUMIDE    => PNNUMIDE,
                                                 PI_CODIGO     => V_CODIGO,
                                                 PI_CODIGO_OSI => V_CODIGO_OSI,
                                                 PI_CTIPPER    => V_CTIPPER,
                                                 PI_SINTERF    => PSINTERF,
                                                 PI_DBLINK     => V_NBDLINK_NAME);
          EXCEPTION
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                          1,
                          'ERROR S03501 = ' || V_OPERACION || ' :' ||
                          SQLERRM,
                          'QUERY = ' || V_QUERY);
              PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PSINTERF,
                                           PI_NNUMIDE      => PNNUMIDE,
                                           PI_TABLA_OSIRIS => 'S03501',
                                           PI_OPERACION    => V_OPERACION,
                                           PI_ESTADO       => 2,
                                           PI_RESPUESTA    => SQLERRM);
          END;
        END IF;
      END IF; -- OF TABLE
    
    ELSE
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                  1,
                  'Convivencia es inactivo.',
                  'Convivencia es inactivo.');
    END IF;
  
  END P_SEND_DATA_CONVI;

  PROCEDURE P_SET_ESTADO(PI_SINTERF      IN NUMBER,
                         PI_NNUMIDE      IN VARCHAR2,
                         PI_TABLA_OSIRIS IN VARCHAR2,
                         PI_OPERACION    IN VARCHAR2,
                         PI_ESTADO       IN NUMBER,
                         PI_RESPUESTA    IN VARCHAR2) AS
  
    V_SINTERF NUMBER;
  
  BEGIN
  
    IF PI_SINTERF IS NULL THEN
      SELECT MAX(SL.SINTERF)
        INTO V_SINTERF
        FROM SERVICIO_LOGS SL
       WHERE SL.UNI_ID = PI_NNUMIDE;
    ELSE
      V_SINTERF := PI_SINTERF;
    END IF;
  
    IF V_SINTERF IS NULL THEN
      PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
      V_SINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;
    END IF;
  
    IF V_SINTERF IS NOT NULL THEN
      INSERT INTO CONVIVENCIA_LOG
        (SINTERF,
         NNUMIDE,
         TABLA_OSIRIS,
         OPERACION,
         ESTADO,
         FECHA,
         RESPUESTA)
      VALUES
        (V_SINTERF,
         PI_NNUMIDE,
         PI_TABLA_OSIRIS,
         PI_OPERACION,
         PI_ESTADO,
         F_SYSDATE,
         PI_RESPUESTA);
      COMMIT;
    ELSE
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'PAC_CONVIVENCIA.P_SET_ESTADO',
                  1,
                  'Error : SINTERF is null',
                  SQLERRM);
    END IF;
  END P_SET_ESTADO;

  PROCEDURE P_SET_MARCAS_VINDULO(PI_NNUMIDE    IN VARCHAR2,
                                 PI_CODIGO     IN NUMBER,
                                 PI_CODIGO_OSI IN VARCHAR2,
                                 PI_CTIPPER    IN NUMBER,
                                 PI_SINTERF    IN NUMBER,
                                 PI_DBLINK     IN VARCHAR2) AS
  
    V_QUERY            VARCHAR2(3000);
    V_MARCAS_COUNT     NUMBER := 0;
    V_OBJ_MARCAS       MARCAS_TYPE_MARCAS;
    V_CODIGO           VARCHAR2(20);
    V_CODIGO_OSI       VARCHAR2(20);
    V_COUNT_MARCAS_OSI NUMBER := 0;
    V_ROWS_3501        NUMBER := 0;
    V_NBDLINK_NAME     VARCHAR2(200);
    V_CTIPPER          NUMBER;
    V_VINCULO          NUMBER;
    V_OPERACION        VARCHAR2(50);
    V_ROW_COUNT_DUPLI  NUMBER := 0;
  
    V_TOMADOR_MARCA       NUMBER := 0;
    V_CONSORCIO_MARCA     NUMBER := 0;
    V_ASEGURADO_MARCA     NUMBER := 0;
    V_CODEUDOR_MARCA      NUMBER := 0;
    V_BENEFICIARIO_MARCA  NUMBER := 0;
    V_ACCIONISTA_MARCA    NUMBER := 0;
    V_INTERMEDIARIO_MARCA NUMBER := 0;
    V_REPRESENTANTE_MARCA NUMBER := 0;
    V_APODERADO_MARCA     NUMBER := 0;
    V_PAGADOR_MARCA       NUMBER := 0;
    V_PROVEEDOR_MARCA     NUMBER := 0;
  
    V_TOMADOR_MARCA_EXISTE       NUMBER := 0;
    V_CONSORCIO_MARCA_EXISTE     NUMBER := 0;
    V_ASEGURADO_MARCA_EXISTE     NUMBER := 0;
    V_CODEUDOR_MARCA_EXISTE      NUMBER := 0;
    V_BENEFICIARIO_MARCA_EXISTE  NUMBER := 0;
    V_ACCIONISTA_MARCA_EXISTE    NUMBER := 0;
    V_INTERMEDIARIO_MARCA_EXISTE NUMBER := 0;
    V_REPRESENTANTE_MARCA_EXISTE NUMBER := 0;
    V_APODERADO_MARCA_EXISTE     NUMBER := 0;
    V_PAGADOR_MARCA_EXISTE       NUMBER := 0;
    V_PROVEEDOR_MARCA_EXISTE     NUMBER := 0;
  
    V_INSERT_S03501              VARCHAR2(3000);
    V_INSERT_S03501B             VARCHAR2(3000);
    V_SELECT_S03501              VARCHAR2(3000);
    V_UPDATE_S03501_ESTADO_0     VARCHAR2(3000);
    V_UPDATE_S03501_ESTADO_NOT_0 VARCHAR2(3000);
    V_DELETE_S03501              VARCHAR2(3000);
    V_CURRENT_QUERY              VARCHAR2(3000);
  
    CURSOR DEFAULT_MARCAS IS
      SELECT TRIM(REGEXP_SUBSTR((SELECT '1, 5, 60' FROM DUAL),
                                '[^,]+',
                                1,
                                LEVEL)) VINCULO
        FROM DUAL
      CONNECT BY INSTR((SELECT '1, 5, 60' FROM DUAL), ',', 1, LEVEL - 1) > 0;
  
  BEGIN
    V_CODIGO       := PI_CODIGO;
    V_CODIGO_OSI   := PI_CODIGO_OSI;
    V_CTIPPER      := PI_CTIPPER;
    V_NBDLINK_NAME := PI_DBLINK;
    V_OPERACION    := 'UPDATE';
  
    EXECUTE IMMEDIATE 'alter session set global_names = true';
  
    BEGIN
      SELECT COUNT(*)
        INTO V_MARCAS_COUNT
        FROM PER_AGR_MARCAS P
       WHERE P.SPERSON = V_CODIGO
         AND P.NMOVIMI = (SELECT MAX(PAM.NMOVIMI)
                            FROM PER_AGR_MARCAS PAM
                           WHERE PAM.SPERSON = V_CODIGO);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_MARCAS_COUNT := 0;
    END;
  
    V_QUERY := 'SELECT COUNT(*)
                            FROM S03501:PARAM1 S501
                           WHERE S501.CODIGO =' || CHR(39) ||
               V_CODIGO_OSI || CHR(39);
  
    EXECUTE IMMEDIATE REPLACE(V_QUERY, ':PARAM1', V_NBDLINK_NAME)
      INTO V_COUNT_MARCAS_OSI;
  
    -- THEN
    -- NEED TO PUT MARCAS BASED ON TABLE PER_AGR_MARCAS
    IF V_MARCAS_COUNT > 0 AND V_COUNT_MARCAS_OSI > 0 THEN
    
      SELECT C.INSERT_QUERY
        INTO V_INSERT_S03501
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.OSIRIS_CODIGO = 'V_INS_S03501';
    
      SELECT C.INSERT_QUERY
        INTO V_INSERT_S03501B
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.OSIRIS_CODIGO = 'V_INS_S03501B';
    
      SELECT C.SELECT_QUERY
        INTO V_SELECT_S03501
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.OSIRIS_CODIGO = 'V_SEL_S03501';
    
      SELECT C.UPDATE_QUERY
        INTO V_UPDATE_S03501_ESTADO_0
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.OSIRIS_CODIGO = 'V_UPD_S03501_E_0';
    
      SELECT C.UPDATE_QUERY
        INTO V_UPDATE_S03501_ESTADO_NOT_0
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.OSIRIS_CODIGO = 'V_UPD_S03501_E_NOT_0';
    
      SELECT C.UPDATE_QUERY
        INTO V_DELETE_S03501
        FROM CON_HOMOLOGA_CONVI C
       WHERE C.OSIRIS_CODIGO = 'V_DEL_S03501';
    
      V_OBJ_MARCAS := F_MARCAS_VINCULO(V_CODIGO);
    
      FOR MAR IN V_OBJ_MARCAS.FIRST .. V_OBJ_MARCAS.LAST LOOP
        IF TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA) = 301 THEN
          CONTINUE;
        ELSE  
          V_TOMADOR_MARCA       := 0;
          V_CONSORCIO_MARCA     := 0;
          V_ASEGURADO_MARCA     := 0;
          V_CODEUDOR_MARCA      := 0;
          V_BENEFICIARIO_MARCA  := 0;
          V_ACCIONISTA_MARCA    := 0;
          V_INTERMEDIARIO_MARCA := 0;
          V_REPRESENTANTE_MARCA := 0;
          V_APODERADO_MARCA     := 0;
          V_PAGADOR_MARCA       := 0;
          V_PROVEEDOR_MARCA     := 0;
        
          V_TOMADOR_MARCA_EXISTE       := 0;
          V_CONSORCIO_MARCA_EXISTE     := 0;
          V_ASEGURADO_MARCA_EXISTE     := 0;
          V_CODEUDOR_MARCA_EXISTE      := 0;
          V_BENEFICIARIO_MARCA_EXISTE  := 0;
          V_ACCIONISTA_MARCA_EXISTE    := 0;
          V_INTERMEDIARIO_MARCA_EXISTE := 0;
          V_REPRESENTANTE_MARCA_EXISTE := 0;
          V_APODERADO_MARCA_EXISTE     := 0;
          V_PAGADOR_MARCA_EXISTE       := 0;
          V_PROVEEDOR_MARCA_EXISTE     := 0;
        
          IF V_OBJ_MARCAS(MAR).TOMADOR = 1 THEN
          
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 1;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA_EXISTE;
          
            IF V_TOMADOR_MARCA = 0 AND V_TOMADOR_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_TOMADOR_MARCA > 0 AND V_TOMADOR_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
              
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 1;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).CONSORCIO = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 99;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_CONSORCIO_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_CONSORCIO_MARCA_EXISTE;
          
            IF V_CONSORCIO_MARCA = 0 AND V_CONSORCIO_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_CONSORCIO_MARCA > 0 AND V_CONSORCIO_MARCA_EXISTE = 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
              
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 99;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).ASEGURADO = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 60;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ASEGURADO_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ASEGURADO_MARCA_EXISTE;
          
            IF V_ASEGURADO_MARCA = 0 AND V_ASEGURADO_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_ASEGURADO_MARCA > 0 AND V_ASEGURADO_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 60;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            END IF;
          
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).CODEUDOR = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 31;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_CODEUDOR_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_CODEUDOR_MARCA_EXISTE;
          
            IF V_CODEUDOR_MARCA = 0 AND V_CODEUDOR_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_CODEUDOR_MARCA > 0 AND V_CODEUDOR_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 31;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).BENEFICIARIO = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 5;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_BENEFICIARIO_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_BENEFICIARIO_MARCA_EXISTE;
          
            IF V_BENEFICIARIO_MARCA = 0 AND V_BENEFICIARIO_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_BENEFICIARIO_MARCA > 0 AND
                  V_BENEFICIARIO_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
              
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 5;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).ACCIONISTA = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 50;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ACCIONISTA_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ACCIONISTA_MARCA_EXISTE;
          
            IF V_ACCIONISTA_MARCA = 0 AND V_ACCIONISTA_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_ACCIONISTA_MARCA > 0 AND V_ACCIONISTA_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
              
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 50;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).INTERMEDIARIO = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 2;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_INTERMEDIARIO_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_INTERMEDIARIO_MARCA_EXISTE;
          
            IF V_INTERMEDIARIO_MARCA = 0 AND V_INTERMEDIARIO_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_INTERMEDIARIO_MARCA > 0 AND
                  V_INTERMEDIARIO_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 2;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).REPRESENTANTE = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 13;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_REPRESENTANTE_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_REPRESENTANTE_MARCA_EXISTE;
          
            IF V_REPRESENTANTE_MARCA = 0 AND V_REPRESENTANTE_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_REPRESENTANTE_MARCA > 0 AND
                  V_REPRESENTANTE_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
              
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 13;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).APODERADO = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 14;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_APODERADO_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_APODERADO_MARCA_EXISTE;
          
            IF V_APODERADO_MARCA = 0 AND V_APODERADO_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_APODERADO_MARCA > 0 AND V_APODERADO_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
              
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 14;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).PAGADOR = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 113;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_PAGADOR_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_PAGADOR_MARCA_EXISTE;
          
            IF V_PAGADOR_MARCA = 0 AND V_PAGADOR_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_PAGADOR_MARCA > 0 AND V_PAGADOR_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
              
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 113;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
            END IF;
            COMMIT;
          END IF;
        
          IF V_OBJ_MARCAS(MAR).PROVEEDOR = 1 THEN
            V_ROWS_3501 := V_ROWS_3501 + 1;
            V_VINCULO   := 16;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_PROVEEDOR_MARCA;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_PROVEEDOR_MARCA_EXISTE;
          
            IF V_PROVEEDOR_MARCA = 0 AND V_PROVEEDOR_MARCA_EXISTE = 0 THEN
            
              V_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501,
                                                                 ':PSPERSON',
                                                                 V_CODIGO),
                                                         ':PARAM1',
                                                         V_NBDLINK_NAME),
                                                 ':PCODVIN',
                                                 V_VINCULO),
                                         ':PESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA)),
                                 ':OSI_CODIGO',
                                 V_CODIGO_OSI);
              EXECUTE IMMEDIATE V_QUERY;
            ELSIF V_PROVEEDOR_MARCA > 0 AND V_PROVEEDOR_MARCA_EXISTE = 0 THEN
              V_ROW_COUNT_DUPLI := 0;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY
                INTO V_ROW_COUNT_DUPLI;
            
              IF V_ROW_COUNT_DUPLI > 1 THEN
              
                V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                   ':PARAM_DB',
                                                                   V_NBDLINK_NAME),
                                                           ':PARAM_CODIGO',
                                                           V_CODIGO_OSI),
                                                   ':PARAM_VINCULO',
                                                   V_VINCULO),
                                           ':PARAM_ESTADO',
                                           0);
                EXECUTE IMMEDIATE V_CURRENT_QUERY;
              END IF;
            
            END IF;
            COMMIT;
          ELSE
            V_VINCULO         := 16;
            V_ROW_COUNT_DUPLI := 0;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_TOMADOR_MARCA;
          
            IF V_TOMADOR_MARCA > 0 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_INSERT_S03501B,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_UPDATE_S03501_ESTADO_NOT_0,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         TO_NUMBER(V_OBJ_MARCAS(MAR).MARCA));
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
              COMMIT;
            END IF;
          
            V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_SELECT_S03501,
                                                               ':PARAM_DB',
                                                               V_NBDLINK_NAME),
                                                       ':PARAM_CODIGO',
                                                       V_CODIGO_OSI),
                                               ':PARAM_VINCULO',
                                               V_VINCULO),
                                       ':PARAM_ESTADO',
                                       0);
          
            EXECUTE IMMEDIATE V_CURRENT_QUERY
              INTO V_ROW_COUNT_DUPLI;
          
            IF V_ROW_COUNT_DUPLI > 1 THEN
            
              V_CURRENT_QUERY := REPLACE(REPLACE(REPLACE(REPLACE(V_DELETE_S03501,
                                                                 ':PARAM_DB',
                                                                 V_NBDLINK_NAME),
                                                         ':PARAM_CODIGO',
                                                         V_CODIGO_OSI),
                                                 ':PARAM_VINCULO',
                                                 V_VINCULO),
                                         ':PARAM_ESTADO',
                                         0);
              EXECUTE IMMEDIATE V_CURRENT_QUERY;
            
            END IF;
            COMMIT;
          END IF;       
       END IF;
     END LOOP;
    
      IF V_ROWS_3501 > 0 AND V_COUNT_MARCAS_OSI > 0 THEN
        PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PI_SINTERF,
                                     PI_NNUMIDE      => PI_NNUMIDE,
                                     PI_TABLA_OSIRIS => 'S03501',
                                     PI_OPERACION    => V_OPERACION,
                                     PI_ESTADO       => 1,
                                     PI_RESPUESTA    => 'Datos actualizado correctamente para S03501B y S03501');
      ELSIF V_ROWS_3501 > 0 AND V_COUNT_MARCAS_OSI = 0 THEN
        PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PI_SINTERF,
                                     PI_NNUMIDE      => PI_NNUMIDE,
                                     PI_TABLA_OSIRIS => 'S03501',
                                     PI_OPERACION    => V_OPERACION,
                                     PI_ESTADO       => 1,
                                     PI_RESPUESTA    => 'Datos actualizado correctamente para S03501');
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
                  1,
                  'ERROR S03501 = ' || V_OPERACION || ' :' || SQLERRM,
                  'QUERY = ' || V_QUERY);
      PAC_CONVIVENCIA.P_SET_ESTADO(PI_SINTERF      => PI_SINTERF,
                                   PI_NNUMIDE      => PI_NNUMIDE,
                                   PI_TABLA_OSIRIS => 'S03501',
                                   PI_OPERACION    => V_OPERACION,
                                   PI_ESTADO       => 2,
                                   PI_RESPUESTA    => SQLERRM);
  END P_SET_MARCAS_VINDULO;

  FUNCTION F_GET_NOMBRE(PI_SPERSON IN NUMBER) RETURN VARCHAR2 IS
  
    V_NOMBRE  VARCHAR2(2000) := NULL;
    V_APELLI1 VARCHAR2(500) := NULL;
    V_APELLI2 VARCHAR2(500) := NULL;
    V_NOMBRE1 VARCHAR2(500) := NULL;
    V_NOMBRE2 VARCHAR2(500) := NULL;
  BEGIN
    SELECT PD.TAPELLI1, PD.TAPELLI2, PD.TNOMBRE1, PD.TNOMBRE2
      INTO V_APELLI1, V_APELLI2, V_NOMBRE1, V_NOMBRE2
      FROM PER_DETPER PD
     WHERE PD.SPERSON = PI_SPERSON;
  
    IF V_APELLI1 IS NOT NULL AND V_APELLI2 IS NOT NULL AND
       V_NOMBRE1 IS NOT NULL AND V_NOMBRE2 IS NOT NULL THEN
      V_NOMBRE := V_APELLI1 || ' ' || V_APELLI2 || ' ' || V_NOMBRE1 || ' ' ||
                  V_NOMBRE2;
    ELSIF V_APELLI1 IS NOT NULL AND V_APELLI2 IS NOT NULL AND
          V_NOMBRE1 IS NOT NULL AND V_NOMBRE2 IS NULL THEN
      V_NOMBRE := V_APELLI1 || ' ' || V_APELLI2 || ' ' || V_NOMBRE1;
    ELSIF V_APELLI1 IS NOT NULL AND V_APELLI2 IS NULL AND
          V_NOMBRE1 IS NOT NULL AND V_NOMBRE2 IS NOT NULL THEN
      V_NOMBRE := V_APELLI1 || ' ' || V_NOMBRE1 || ' ' || V_NOMBRE2;
    ELSIF V_APELLI1 IS NOT NULL AND V_APELLI2 IS NULL AND
          V_NOMBRE1 IS NOT NULL AND V_NOMBRE2 IS NULL THEN
      V_NOMBRE := V_APELLI1 || ' ' || V_NOMBRE1;
    END IF;
  
    RETURN V_NOMBRE;
  END F_GET_NOMBRE;
  /*CAMBIOS PARA TAREA IAXIS-13044 : END */
END PAC_CONVIVENCIA;
/