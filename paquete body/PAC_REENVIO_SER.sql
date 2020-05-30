CREATE OR REPLACE PACKAGE BODY PAC_REENVIO_SER IS

  /******************************************************************************
     NOMBRE:    PAC_REENVIO_SER
     PROPÃ“SITO: PACKAGE TO RETRY FAILED WEBSERVICE REQUESTS

     REVISIONES:
     VER        FECHA        AUTOR             DESCRIPCIÃ“N
     ---------  ----------  ---------------  ------------------------------------
      1.0       14/06/2019   SWAPNIL             CREACION
      2.0       25/06/2019   PK                  IAXIS-4191: Added procedures for getting solicitud data on screen.
      3.0       26/12/2019   JRVG                IAXIS-7735: Pagador Alternativo
      4.0       28/01/2020   JRVG                IAXIS-4704 - BUG 10574 Ajuste REENVIO PANTALLA  [axisadm200] Reenvío de Servicios
      5.0       18/03/2020   SP                  Cambios de  tarea IAXIS-13044
      6.0       13/04/2020   JRVG                IAXIS-4191 - Ajuste del filtro Num_Pago (PANTALLA[axisadm200]-Recaudo)
  */

  PROCEDURE P_REINTENTAR_I017 (PI_SINTERF IN NUMBER,
                               PI_ESTADO  IN NUMBER,
                               PSINTERF OUT VARCHAR2,
                               mensajes OUT t_iax_mensajes) IS
    VCOUNT NUMBER := 0;
    VOBJ   VARCHAR2(500) := 'PAC_REENVIO_SER.P_REINTENTAR_I017';
    VTRAZA NUMBER := 0;

    VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;
    VSPERSON       PER_PERSONAS.SPERSON%TYPE;
    VSINTERF       INT_MENSAJES.SINTERF%TYPE;
    VEMPRESA       NUMBER := 24;
    VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;
    VOPERATION     VARCHAR2(10);
    V_HOST         VARCHAR2(10);
    VLINEAINI      VARCHAR2(1000);
    VTERMINAL      VARCHAR2(50);
    VRESULTADO     NUMBER;
    VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    VSINTERF_SEL   INT_MENSAJES.SINTERF%TYPE;
    VENTRADA       SERVICIO_LOGS.ENTRADA%TYPE;

    VERROR_NNUMID    EXCEPTION;
    VERROR_PERSONA   EXCEPTION;
    VERROR_OPERATION EXCEPTION;
    VERROR_DIGIT     EXCEPTION;

    CURSOR CUR_REINTENTAR_I017 IS(
      SELECT *
        FROM SERVICIO_LOGS S
       WHERE CINTERF = 'I017'
         AND ESTADO = 2);
	--
  BEGIN

    VTRAZA := 1;
    SELECT COUNT(*)
      INTO VCOUNT
      FROM SERVICIO_LOGS S
     WHERE CINTERF = 'I017'
       AND ESTADO = 2
       AND S.SINTERF = PI_SINTERF;
    --
    IF VCOUNT > 0 THEN
		--
        SELECT ENTRADA
            INTO VENTRADA
            FROM SERVICIO_LOGS SL
        WHERE SL.SINTERF = PI_SINTERF;

        VSINTERF_SEL := PI_SINTERF;

        IF VENTRADA IS NOT NULL THEN
          BEGIN
            VTRAZA := 2;
            SELECT XMLTYPE(S.ENTRADA).EXTRACT('//PIn/Busqueda/text()')
                   .GETSTRINGVAL()
              INTO VPERSON_NUM_ID
              FROM SERVICIO_LOGS S
             WHERE CINTERF = 'I017'
               AND ESTADO = 2
               AND SINTERF = PI_SINTERF;
          EXCEPTION
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'No puedes encontrar Número identificación.',
                          'Error :' || SQLERRM || ' : SINTERF : ' ||
                          VSINTERF_SEL);
				--
          END;

          BEGIN
            VTRAZA := 3;
            SELECT XMLTYPE(S.ENTRADA).EXTRACT('//PIn/Grcuentas/text()')
                   .GETSTRINGVAL()
              INTO VOPERATION
              FROM SERVICIO_LOGS S
             WHERE CINTERF = 'I017'
               AND ESTADO = 2
               AND SINTERF = PI_SINTERF;
          EXCEPTION
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'No puedes encontrar código de operación.',
                          'Error :' || SQLERRM || ' : SINTERF : ' ||
                          VSINTERF_SEL);
				--
          END;

          BEGIN
            VTRAZA := 4;
            SELECT PP.SPERSON
              INTO VSPERSON
              FROM PER_PERSONAS PP
             WHERE PP.NNUMIDE LIKE VPERSON_NUM_ID || '%'
               AND ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'No puedes encontrar código de persona.',
                          'Error :' || SQLERRM || ' : SINTERF : ' ||
                          VSINTERF_SEL);
				--
          END;

          BEGIN
            VTRAZA := 5;
            SELECT PP.TDIGITOIDE
              INTO VDIGITOIDE
              FROM PER_PERSONAS PP
             WHERE PP.SPERSON = VSPERSON
               AND ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              SELECT PP.CTIPIDE
                INTO VCTIPIDE
                FROM PER_PERSONAS PP
               WHERE PP.SPERSON = VSPERSON;
              VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                             UPPER(VPERSON_NUM_ID));
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'No puedes encontrar código de verificación de dígitos.',
                          'Error :' || SQLERRM || ' : SINTERF : ' ||
                          VSINTERF_SEL);
				--
          END;

          BEGIN
            VTRAZA := 6;
            PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
            VSINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;

            V_HOST := PAC_PARAMETROS.F_PAREMPRESA_T(PAC_MD_COMMON.F_GET_CXTEMPRESA,
                                                    'ALTA_PROV_HOST');

            IF VOPERATION <> V_HOST THEN
              V_HOST := PAC_PARAMETROS.F_PAREMPRESA_T(PAC_MD_COMMON.F_GET_CXTEMPRESA,
                                                      'DUPL_DEUDOR_HOST');
            END IF;
            VTRAZA     := 7;
            VLINEAINI  := VEMPRESA || '|' || VSPERSON || '|' || 'MOD' || '|' ||
                          VTERMINAL || '|' ||
                          PAC_MD_COMMON.F_GET_CXTUSUARIO || '|' ||
                          VDIGITOIDE || '|' || V_HOST;
            VTRAZA     := 8;
			--
            VRESULTADO := PAC_INT_ONLINE.F_INT(VEMPRESA,
                                               VSINTERF,
                                               'I017',
                                               VLINEAINI);
            VTRAZA     := 9;
            UPDATE SERVICIO_LOGS SL
               SET SL.ESTADO = 3, SL.RT_SINTERF = VSINTERF
             WHERE SL.SINTERF = PI_SINTERF;
            COMMIT;

          EXCEPTION
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'P_REINTENTAR_I017 : Error en reintentar para crear persona',
                          'Error : ' || SQLERRM || ' : SINTERF : ' ||
                          VSINTERF_SEL);
            --
          END;
        ELSE
          UPDATE SERVICIO_LOGS SL
             SET SL.ESTADO = 3
           WHERE SL.SINTERF = PI_SINTERF;
          COMMIT;
        END IF;
		--
		PSINTERF := VSINTERF;
		--
    ELSE
      DBMS_OUTPUT.PUT_LINE('No se encontraron datos para ejecutar.');
    END IF;

  END P_REINTENTAR_I017;

-- INICIO IAXIS-4704 - BUG 10574 - JRVG -  28/01/2020
  PROCEDURE P_REINTENTAR_I031 (PI_SINTERF IN NUMBER,
                               PI_ESTADO  IN NUMBER,
                               PSINTERF OUT VARCHAR2,
                               PNUMINTENTO OUT NUMBER,
                               mensajes OUT t_iax_mensajes) IS
    VCOUNT NUMBER := 0;
    VOBJ   VARCHAR2(500) := 'PAC_REENVIO_SER.P_REINTENTAR_I031';
    VTRAZA NUMBER := 0;
    --V_MSG  VARCHAR2(32700);
    --V_MSG1 VARCHAR2(32700);
    V_EVENTO MOVCONTASAP.EVENTO%TYPE;
    V_NUMINTENTO MOVCONTASAP.NUM_INTENTO%TYPE;
    V_ROWID VARCHAR2(50);

  BEGIN

    VTRAZA := 1;
    SELECT COUNT(S.SINTERF)
      INTO VCOUNT
      FROM SERVICIO_LOGS S,INT_MENSAJES IM, MOVCONTASAP MV
     WHERE IM.SINTERF = S.SINTERF
       AND MV.SINTERF = S.SINTERF
       AND S.SINTERF = PI_SINTERF
       AND S.CINTERF = 'I031'
       AND S.ESTADO = 2;

    IF VCOUNT > 0 THEN
      VTRAZA := 2;
		
          BEGIN
            VTRAZA := 3;
            --
            SELECT M.EVENTO, M.NUM_INTENTO, ROWID
              INTO V_EVENTO,V_NUMINTENTO, V_ROWID
              FROM MOVCONTASAP M
             WHERE M.SINTERF  = PI_SINTERF;
            --
            VTRAZA := 4;
            
              IF V_EVENTO = 'PRODUCCION' THEN
                 PAC_CONTA_SAP.GENERA_REINTENTO_PRD(PI_SINTERF);
            
            VTRAZA := 5;      
              ELSIF V_EVENTO = 'SINIESTROS' THEN
                 PAC_CONTA_SAP.GENERA_REINTENTO_SIN(PI_SINTERF);
                 
            VTRAZA := 6;      
              ELSIF V_EVENTO = 'RESERVA' THEN
                 PAC_CONTA_SAP.GENERA_REINTENTO_RES(PI_SINTERF);
            
              END IF ;
              
              SELECT SINTERF
                INTO PSINTERF
                FROM MOVCONTASAP 
               WHERE ROWID = V_ROWID;
            
          EXCEPTION
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'P_REINTENTAR_I031 : Error en reintentar para I031 servicio.',
                          'Error : ' || SQLERRM || ' : SINTERF : ' ||
                          PI_SINTERF);
            --
          END;
        --  
      PNUMINTENTO := V_NUMINTENTO;
    ELSE
        P_TAB_ERROR(F_SYSDATE,
                    F_USER,
                    VOBJ,
                    VTRAZA,
                    'P_REINTENTAR_I031 : No se encontraron datos para ejecutar.',
                    'Error : ' || SQLERRM || ' : SINTERF : ' ||
                    PI_SINTERF);
    END IF;
  END P_REINTENTAR_I031;
-- FIN IAXIS-4704 - BUG 10574 - JRVG -  28/01/2020

  PROCEDURE P_BUSCAR_INTERFACE(PO_RESULT OUT SYS_REFCURSOR) IS
    VOBJ   VARCHAR2(500) := 'PAC_REENVIO_SER.P_BUSCAR_INTERFACE';
    VTRAZA NUMBER := 0;

  BEGIN
    VTRAZA := 1;
    OPEN PO_RESULT FOR
      SELECT IH.CINTERF, IH.NOMBRE
        FROM INT_SERVICIO_DETAIL IH
       WHERE IH.EMPRESA = 24
         AND IH.ESTADO = 'S'
       ORDER BY IH.CINTERF;

  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en P_BUSCAR_INTERFACE.',
                  'Error : ' || SQLERRM);

  END P_BUSCAR_INTERFACE;

  PROCEDURE P_BUSCAR_SOLICITUD(PI_CINTERF IN VARCHAR2,
                               PI_ESTADO  IN NUMBER,
                               PO_RESULT  OUT SYS_REFCURSOR) IS
    VOBJ   VARCHAR2(500) := 'PAC_REENVIO_SER.P_BUSCAR_SOLICITUD';
    VTRAZA NUMBER := 0;

  BEGIN
    VTRAZA := 1;
    OPEN PO_RESULT FOR
      SELECT SL.*
        FROM SERVICIO_LOGS SL,INT_MENSAJES IM
       WHERE IM.SINTERF = SL.SINTERF
         AND SL.CINTERF = PI_CINTERF
         AND SL.ESTADO = PI_ESTADO
       ORDER BY SL.SINTERF DESC;

  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en P_BUSCAR_SOLICITUD.',
                  'Error : ' || SQLERRM);

  END P_BUSCAR_SOLICITUD;

  PROCEDURE P_BUSCAR_ESTADO(PO_RESULT OUT SYS_REFCURSOR) IS
        VOBJ   VARCHAR2(500) := 'PAC_REENVIO_SER.P_BUSCAR_ESTADO';
        VTRAZA NUMBER := 0;
        --
      BEGIN
        VTRAZA := 1;
        /* Success	->	Éxito, Failed	->	Fallado */
        OPEN PO_RESULT FOR
            SELECT DISTINCT ESTADO, DECODE(ESTADO, 1, 'Éxito', 2, 'Fallado') TESTADO
            FROM SERVICIO_LOGS
            WHERE ESTADO <> 3
            ORDER BY ESTADO;
        --
      EXCEPTION
        WHEN OTHERS THEN
          P_TAB_ERROR(F_SYSDATE,
                      F_USER,
                      VOBJ,
                      VTRAZA,
                      'Error en P_BUSCAR_ESTADO.',
                      'Error : ' || SQLERRM);
        --
  END P_BUSCAR_ESTADO;

    /* Cambios de  tarea IAXIS-13044 : Start */
	PROCEDURE P_GET_SERVICIO(PI_CINTERF VARCHAR2,
                           PI_ESTADO  NUMBER,
                           PI_NNUMIDE VARCHAR2,
                           PI_FINICIO DATE,
                           PI_FFIN    DATE,
                           PI_NUMPAGO VARCHAR2,
                           PO_RESULT  OUT SYS_REFCURSOR) IS
    VOBJ    VARCHAR2(500) := 'PAC_REENVIO_SER.P_GET_SERVICIO';
    VTRAZA  NUMBER := 0;
    VSQUERY VARCHAR2(1000);
    VSQUERY1 VARCHAR2(1000);
    VSQUERY2 VARCHAR2(1000);
    
    --
  BEGIN
    VTRAZA := 1;
    IF PI_CINTERF IS NULL THEN
      VTRAZA := 2;
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en P_GET_SERVICIO.',
                  'Error : ' || SQLERRM);
      --
    ELSIF PI_CINTERF = 'CONVI' THEN
      VSQUERY := 'SELECT A.SINTERF,
              ''CONVI'' CINTERF,
              A.NNUMIDE,
              TO_CHAR(A.FECHA, ''DD/MM/YYYY HH24:MI:SS'') FECHA_SOLICITUD,
              A.ESTADO,
              DECODE(A.ESTADO, 1, ''Éxito'', 2, ''Fallado'')||''-''||A.TABLA_OSIRIS||''-''||A.NNUMIDE TESTADO
         FROM CONVIVENCIA_LOG A,
              (SELECT DISTINCT C.TABLA_OSIRIS,
                               C.NNUMIDE,
                               MAX(C.FECHA) FECHA
                 FROM CONVIVENCIA_LOG C
                GROUP BY C.TABLA_OSIRIS, C.NNUMIDE) B
        WHERE A.NNUMIDE = B.NNUMIDE
          AND A.TABLA_OSIRIS = B.TABLA_OSIRIS
          AND A.FECHA = B.FECHA';
    
      IF PI_ESTADO IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND A.ESTADO = ' || PI_ESTADO || '';
      END IF;
      --
      IF PI_NNUMIDE IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND A.NNUMIDE = ' || PI_NNUMIDE || '';
      END IF;
      --
      IF PI_FINICIO IS NOT NULL AND PI_FFIN IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND TRUNC(A.FECHA) BETWEEN ''' ||
                   PI_FINICIO || ''' AND ''' || PI_FFIN || '''';
      END IF;
     
     -- INI IAXIS-4191 JRVG 13/04/2020
     ELSIF PI_CINTERF = 'l003' THEN
      VTRAZA := 3;
      -- VALIDACION PARA BUSCAR EN HISTORICOS - HISINT_MENSAJES
      VSQUERY1:= 'SELECT SL.SINTERF, SL.CINTERF, TO_CHAR(SL.FECHA_SOLICITUD, ''DD/MM/YYYY HH24:MI:SS'') FECHA_SOLICITUD, ' ||
                 'SL.ESTADO, DECODE(SL.ESTADO, 1, ''Éxito'', 2, ''Fallado'') TESTADO ' ||
                 'FROM SERVICIO_LOGS SL,INT_MENSAJES IM WHERE IM.SINTERF = SL.SINTERF  AND SL.CINTERF = ''' ||
                 PI_CINTERF ||'''';
      VSQUERY2:= 'SELECT SL.SINTERF, SL.CINTERF, TO_CHAR(SL.FECHA_SOLICITUD, ''DD/MM/YYYY HH24:MI:SS'') FECHA_SOLICITUD, ' ||
                 'SL.ESTADO, DECODE(SL.ESTADO, 1, ''Éxito'', 2, ''Fallado'') TESTADO ' ||
                 'FROM SERVICIO_LOGS SL,HISINT_MENSAJES IM WHERE IM.SINTERF = SL.SINTERF  AND SL.CINTERF = ''' || --AND SL.ESTADO IN (1, 2)
                 PI_CINTERF || '''';
      --
      IF PI_ESTADO IS NOT NULL THEN
        VSQUERY1:= VSQUERY1 || ' AND SL.ESTADO = ' || PI_ESTADO ||'';                  
        VSQUERY2:= VSQUERY2 || ' AND SL.ESTADO = ' || PI_ESTADO ||'';
        VSQUERY := VSQUERY1 ||' '||'UNION'||' '|| VSQUERY2;
      ELSE
        VSQUERY1:= VSQUERY1 ||'AND SL.ESTADO IN (1,2)'||'';                  
        VSQUERY2:= VSQUERY2 ||'AND SL.ESTADO IN (1,2)'||'';
        VSQUERY := VSQUERY1 ||' '||'UNION'||' '|| VSQUERY2;
      END IF;
      --           
      IF PI_NUMPAGO IS NOT NULL THEN
        VSQUERY1:= VSQUERY1 || ' AND SL.UNI_ID LIKE ''' || PI_NUMPAGO || '%''' ;
        VSQUERY2:= VSQUERY2 || ' AND SL.UNI_ID LIKE ''' || PI_NUMPAGO || '%''';
        VSQUERY := VSQUERY1 ||' '||'UNION'||' '|| VSQUERY2;
        
      END IF;
      --
      IF PI_FINICIO IS NOT NULL AND PI_FFIN IS NOT NULL THEN
        VSQUERY1:= VSQUERY1 || ' AND TRUNC(SL.FECHA_SOLICITUD) BETWEEN ''' || PI_FINICIO || ''' AND ''' || PI_FFIN || '''';
        VSQUERY2:= VSQUERY2 || ' AND TRUNC(SL.FECHA_SOLICITUD) BETWEEN ''' || PI_FINICIO || ''' AND ''' || PI_FFIN || '''';
        VSQUERY := VSQUERY1 ||' '||'UNION'||' '|| VSQUERY2;
                   
      END IF;
      --
      VSQUERY := 'SELECT * FROM '||'('|| VSQUERY ||')'||'ORDER BY FECHA_SOLICITUD DESC';
    -- FIN IAXIS-4191 JRVG 13/04/2020 
    
    ELSIF PI_CINTERF <> 'I031' THEN
      VTRAZA := 3;
      --
      VSQUERY := 'SELECT SL.SINTERF, SL.CINTERF, TO_CHAR(SL.FECHA_SOLICITUD, ''DD/MM/YYYY HH24:MI:SS'') FECHA_SOLICITUD, ' ||
                 'SL.ESTADO, DECODE(SL.ESTADO, 1, ''Éxito'', 2, ''Fallado'') TESTADO ' ||
                 'FROM SERVICIO_LOGS SL,INT_MENSAJES IM WHERE IM.SINTERF = SL.SINTERF AND SL.ESTADO IN (1, 2) AND SL.CINTERF = ''' ||
                 PI_CINTERF || '''';
      --
      IF PI_ESTADO IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND SL.ESTADO = ' || PI_ESTADO || '';
      END IF;
      --
      IF PI_NNUMIDE IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND SL.UNI_ID LIKE ''' || PI_NNUMIDE ||
                   '%''';
      END IF;
      --
      IF PI_FINICIO IS NOT NULL AND PI_FFIN IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND TRUNC(SL.FECHA_SOLICITUD) BETWEEN ''' ||
                   PI_FINICIO || ''' AND ''' || PI_FFIN || '''';
      END IF;
      --
      VSQUERY := VSQUERY || ' ORDER BY SL.FECHA_SOLICITUD DESC';
    ELSE
      VTRAZA  := 4;
    -- INICIO IAXIS-4704 - BUG 10574 - JRVG -  28/01/2020
        VTRAZA :=4;
        VSQUERY := 'SELECT SL.SINTERF, SL.CINTERF, TO_CHAR(SL.FECHA_SOLICITUD, ''DD/MM/YYYY HH24:MI:SS'') FECHA_SOLICITUD, '
                    ||'SL.ESTADO, DECODE(SL.ESTADO, 1, ''Éxito'', 2, ''Fallado'') TESTADO '
                    ||'FROM SERVICIO_LOGS SL,INT_MENSAJES IM, MOVCONTASAP  MV WHERE IM.SINTERF = SL.SINTERF AND MV.SINTERF = SL.SINTERF AND SL.ESTADO IN (1, 2) AND SL.CINTERF = '''||PI_CINTERF||'''';
    -- FIN IAXIS-4704 - BUG 10574 - JRVG -  28/01/2020      
      --
      IF PI_NUMPAGO IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND SL.UNI_ID LIKE ''' || PI_NUMPAGO ||
                   '%''';
      END IF;
      --
      IF PI_ESTADO IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND SL.ESTADO = ' || PI_ESTADO || '';
      END IF;
      --
      IF PI_FINICIO IS NOT NULL AND PI_FFIN IS NOT NULL THEN
        VSQUERY := VSQUERY || ' AND TRUNC(SL.FECHA_SOLICITUD) BETWEEN ''' ||
                   PI_FINICIO || ''' AND ''' || PI_FFIN || '''';
      END IF;
      --
      VSQUERY := VSQUERY || ' ORDER BY SL.FECHA_SOLICITUD DESC';
    END IF;
  
    --
    OPEN PO_RESULT FOR VSQUERY;
    VTRAZA := 5;
    --
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en P_BUSCAR_SERVICIO.',
                  'Error : ' || SQLERRM);
      --
  END P_GET_SERVICIO;
/* Cambios de  tarea IAXIS-13044 :end */

/* Cambios de  tarea IAXIS-13044 : start */
    PROCEDURE P_GET_ENTSALIDA(PI_SINTERF IN NUMBER,
                            PI_ESTADO  IN NUMBER,
                            PI_CINTERF IN VARCHAR2,
                            PO_RESULT  OUT SYS_REFCURSOR) IS
    VOBJ   VARCHAR2(500) := 'PAC_REENVIO_SER.P_GET_ENTSALIDA';
    VTRAZA NUMBER := 0;
    --
  BEGIN
    VTRAZA := 1;
    IF PI_SINTERF IS NULL OR PI_ESTADO IS NULL THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en P_GET_ENTSALIDA.',
                  'Error : ' || SQLERRM);
      --
    ELSE
      VTRAZA := 2;
      IF PI_CINTERF = 'CONVI' THEN
        OPEN PO_RESULT FOR
          SELECT TO_CLOB(XMLELEMENT("ENTRADA",
                                    XMLATTRIBUTES('http://www.w3.org/2001/XMLSchema' AS
                                                  "xmlns:xsi",
                                                  'http://www.oracle.com/ENTRADA.xsd' AS
                                                  "xsi:nonamespaceSchemaLocation"),
                                    XMLFOREST(A.NNUMIDE,
                                              A.TABLA_OSIRIS,
                                              A.OPERACION))) AS "ENTRADA",
                 TO_CLOB(XMLELEMENT("SALIDA",
                                    XMLATTRIBUTES('http://www.w3.org/2001/XMLSchema' AS
                                                  "xmlns:xsi",
                                                  'http://www.oracle.com/SALIDA.xsd' AS
                                                  "xsi:nonamespaceSchemaLocation"),
                                    XMLFOREST(DECODE(A.ESTADO,
                                                     1,
                                                     'Éxito',
                                                     2,
                                                     'Fallado') AS "ESTADO",
                                              A.FECHA,
                                              A.RESPUESTA))) AS "SALIDA"
            FROM CONVIVENCIA_LOG A,
                 (SELECT DISTINCT C.TABLA_OSIRIS,
                                  C.NNUMIDE,
                                  MAX(C.FECHA) FECHA
                    FROM CONVIVENCIA_LOG C
                   GROUP BY C.TABLA_OSIRIS, C.NNUMIDE) B
           WHERE A.NNUMIDE = B.NNUMIDE
             AND A.TABLA_OSIRIS = B.TABLA_OSIRIS
             AND A.FECHA = B.FECHA
             AND A.SINTERF = PI_SINTERF
             AND A.ESTADO = PI_ESTADO;
      ELSE
        OPEN PO_RESULT FOR
          SELECT SL.ENTRADA ENTRADA, SL.SALIDA SALIDA
            FROM SERVICIO_LOGS SL
           WHERE SL.SINTERF = PI_SINTERF
             AND SL.ESTADO = PI_ESTADO;
        --
      END IF;
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'Error en P_GET_ENTSALIDA.',
                  'Error : ' || SQLERRM);
      --
  END P_GET_ENTSALIDA;
/* Cambios de  tarea IAXIS-13044 : end */
  
 --Inicio IAXIS-7735 JRVG 26/12/2019 Pagador Alternativo
  PROCEDURE P_PAGADOR_I017 (PI_SINTERF IN NUMBER,
                            PI_SPERSON  IN NUMBER) IS
    VOBJ   VARCHAR2(500) := 'PAC_REENVIO_SER.P_PAGADOR_ALT';
    VTRAZA NUMBER := 0;

    VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;
    VSPERSON       PER_PERSONAS.SPERSON%TYPE;
    VSINTERF       INT_MENSAJES.SINTERF%TYPE;
    VEMPRESA       NUMBER := 24;
    VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;
    V_HOST         VARCHAR2(10);
    VLINEAINI      VARCHAR2(1000);
    VTERMINAL      VARCHAR2(50);
    VRESULTADO     NUMBER;
    VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
    VSINTERF_SEL   INT_MENSAJES.SINTERF%TYPE;

    VERROR_NNUMID    EXCEPTION;
    VERROR_PERSONA   EXCEPTION;
    VERROR_OPERATION EXCEPTION;
    VERROR_DIGIT     EXCEPTION;
  --
  BEGIN

    VTRAZA := 1;

          BEGIN
            VTRAZA := 2;
            SELECT PP.SPERSON
              INTO VSPERSON
              FROM PER_PERSONAS PP
             WHERE PP.SPERSON = PI_SPERSON
               AND ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'No puedes encontrar código de persona.',
                          'Error :' || SQLERRM || ' : SINTERF : ' ||
                          VSINTERF_SEL);
				--
          END;

          BEGIN
            VTRAZA := 3;
            SELECT PP.TDIGITOIDE
              INTO VDIGITOIDE
              FROM PER_PERSONAS PP
             WHERE PP.SPERSON = VSPERSON
               AND ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              SELECT PP.CTIPIDE
                INTO VCTIPIDE
                FROM PER_PERSONAS PP
               WHERE PP.SPERSON = VSPERSON;
              VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
                                                             UPPER(VPERSON_NUM_ID));
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'No puedes encontrar código de verificación de dígitos.',
                          'Error :' || SQLERRM || ' : SINTERF : ' ||
                          VSINTERF_SEL);
        --
          END;

          BEGIN
            
            VTRAZA := 4;
            PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
            
            VSINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;

            V_HOST := PAC_PARAMETROS.F_PAREMPRESA_T(VEMPRESA,'ALTA_PROV_HOST');

            VTRAZA     := 5;
            VLINEAINI  := VEMPRESA || '|' || VSPERSON || '|' || 'MOD' || '|' ||
                          VTERMINAL || '|' ||
                          PAC_MD_COMMON.F_GET_CXTUSUARIO || '|' ||
                          VDIGITOIDE || '|' || V_HOST;
            VTRAZA     := 6;
     
            VRESULTADO := PAC_INT_ONLINE.F_INT(VEMPRESA,
                                               VSINTERF,
                                               'I017',
                                               VLINEAINI);
            VTRAZA     := 7;

       ----
       
            V_HOST := PAC_PARAMETROS.F_PAREMPRESA_T(VEMPRESA,'DUPL_DEUDOR_HOST');
                                                                  
            PAC_INT_ONLINE.P_INICIALIZAR_SINTERF;
                        VSINTERF := PAC_INT_ONLINE.F_OBTENER_SINTERF;       
                        
            VLINEAINI  := VEMPRESA || '|' || VSPERSON || '|' || 'MOD' || '|' ||
                                      VTERMINAL || '|' ||
                                      PAC_MD_COMMON.F_GET_CXTUSUARIO || '|' ||
                                      VDIGITOIDE || '|' || V_HOST;      
                                      
            VRESULTADO := PAC_INT_ONLINE.F_INT(VEMPRESA,
                                               VSINTERF,
                                               'I017',
                                               VLINEAINI);                                                                                           

          EXCEPTION
            WHEN OTHERS THEN
              P_TAB_ERROR(F_SYSDATE,
                          F_USER,
                          VOBJ,
                          VTRAZA,
                          'P_PAGADOR_ALT : Error en reintentar para crear persona',
                          'Error : ' || SQLERRM || ' : SINTERF : ' ||
                          VSINTERF_SEL);
            --
          END;
       
  END P_PAGADOR_I017;
 --Fin IAXIS-7735 JRVG 26/12/2019 Pagador Alternativo
 
 /*Cambios de  tarea IAXIS-13044 : start */
  PROCEDURE P_REINTENTAR_CONVI(PI_SINTERF IN NUMBER,
                               PI_NNUMIDE IN VARCHAR2) IS
    VOBJ   VARCHAR2(500) := 'PAC_REENVIO_SER.P_REINTENTAR_CONVI';
    VTRAZA NUMBER := 0;
  
  BEGIN
    PAC_CONVIVENCIA.P_SEND_DATA_CONVI(PNNUMIDE => PI_NNUMIDE,
                                      PFLAG    => 0,
                                      PTABLA   => NULL,
                                      PSINTERF => PI_SINTERF);
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  VOBJ,
                  VTRAZA,
                  'P_SEND_DATA_CONVI : Error en reintentar para convivencia',
                  'Error : ' || SQLERRM || ' : SINTERF : ' || PI_SINTERF);
    
  END P_REINTENTAR_CONVI;

  /*Cambios de  tarea IAXIS-13044 : end */  

END PAC_REENVIO_SER;
/

GRANT EXECUTE ON "AXIS"."PAC_REENVIO_SER" TO "R_AXIS";
GRANT EXECUTE ON "AXIS"."PAC_REENVIO_SER" TO "CONF_DWH";
GRANT EXECUTE ON "AXIS"."PAC_REENVIO_SER" TO "PROGRAMADORESCSI";
GRANT EXECUTE ON "AXIS"."PAC_REENVIO_SER" TO "AXIS00";

create or replace synonym AXIS00.PAC_REENVIO_SER for AXIS.PAC_REENVIO_SER;
