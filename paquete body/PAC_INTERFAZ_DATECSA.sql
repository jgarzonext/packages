--------------------------------------------------------
--  DDL for Package Body PAC_INTERFAZ_DATECSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_INTERFAZ_DATECSA" IS
--SUC. NUM. POL.   CLIENT                USU
--1  >2          >3                   >4          >5             >6          >7          >8       >9                >10
--02 >RO012422   >SPS ASOCIADOS S.A.S >EBUELVAS   >NUEVO CON DB  >RO023332   >900284476  >MULTIF  >192.168.23.200   >.PDF>
--10 >9          >8                   >7          >6             >5          >4          >3       >2                >1
   /******************************************************************************
      NOMBRE:    PAC_INTERFAZ_DATECSA
      PROP¿SITO: FUNCIONES INTERFACE DATECSA

      REVISIONES:
      VER        FECHA        AUTOR             DESCRIPCI¿N
      ---------  ----------  ---------------  ------------------------------------
      1.0        20/09/2016  NMM              1. CREACI¿N DEL OBJETO.

   ******************************************************************************/
   --
   /*************************************************************************
      PROCEDURE P_GEST_ERROR

   *************************************************************************/
      PROCEDURE P_GEST_ERROR IS
        WFILE2    UTL_FILE.FILE_TYPE;
        WLINE2    VARCHAR2(10000);
        WERROR    NUMBER;
        WSTEP     PLS_INTEGER := 0;
        WOBJECT   VARCHAR2(1000) := 'PAC_INTERFAZ_DATECSA.P_GEST_ERROR';
        WNAME_ERR VARCHAR2(10000);
        WNAME_PDF VARCHAR2(10000);
        WNAME_SP9 VARCHAR2(10000);
      BEGIN
        WSTEP := 9020;
        UPDATE INTERFAZ_DATECSA
        SET    META_DATA = 'ERROR',
               ESTADO_PROC = 0,
               ERROR = 99
        WHERE  CODIGO    = WCODE;
        COMMIT;
        WSTEP := 9030;
        DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### WRITE .ERROR ### ');
        WFILE2 := UTL_FILE.FOPEN('DATECSA', WNAME||'.ERROR', 'W');
        WSTEP := 9040;
        DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'STEP:'||WSTEP||' ;WLINE:'||WLINE||' ;WLINEBAK:'||WLINEBAK);
        UTL_FILE.PUT_LINE( WFILE2, WLINEBAK);
        WSTEP := 9050;
        UTL_FILE.FCLOSE( WFILE2);
        WSTEP := 9060;
        DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### CLOSE .ERROR ### ');
        WNAME_ERR := WNAME    ||'.ERROR';
        WNAME_PDF := WNOM_PDF ||'.pdf';
        WNAME_SP9 := WNAME    ||'.sp9';
        DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'WNAME_ERR:'||WNAME_ERR);
        DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'WNAME_PDF:'||WNAME_PDF);
        DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'WNAME_SP9:'||WNAME_SP9);
        -- MOVE
        begin
        UTL_FILE.FRENAME('DATECSA', WNAME_ERR, 'DATECSA_ERROR', WNAME_ERR);
        WSTEP := 9070;
        DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### MOVE .ERROR ### ');
        exception
          when others then
          WSTEP := 9071;
          DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### ERROR at MOVE .ERROR ### '||SQLERRM);
        end;

        begin
          UTL_FILE.FRENAME('DATECSA', WNAME_PDF, 'DATECSA_ERROR', WNAME_PDF);
          WSTEP := 9080;
          DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### MOVE .pdf ### ');
        exception
          when others then
          WSTEP := 9081;
          DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### ERROR at MOVE .pdf ### '||SQLERRM);
        end;

        begin
          UTL_FILE.FRENAME('DATECSA', WNAME_SP9, 'DATECSA_ERROR', WNAME_SP9);
          WSTEP := 9090;
          DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### MOVE .sp9 ### ');
        exception
          when others then
          WSTEP := 9091;
          DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### ERROR at MOVE .sp9 ### '||SQLERRM);
        end;
      --
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          IF UTL_FILE.IS_OPEN(WFILE2) THEN
            UTL_FILE.FCLOSE( WFILE2);
          END IF;
          DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, ' *** OTHERS SQLERRM *** '||SQLERRM||' ;WNAME:'||WNAME);
      END P_GEST_ERROR;
      --------------------------------------------------------------------------
   /*************************************************************************
      FUNCTION F_EJECUTA_INTERFAZ_DATECSA

      PARAM IN PSSEGURO  : IDENTIFICADOR SEGURO
      RETURN             : NUMBER
   *************************************************************************/
   FUNCTION F_EJECUTA_INTERFAZ_DATECSA
                    ( PCODE     IN NUMBER
                    , PNAME     IN VARCHAR2
                    , PNAMEPDF  IN VARCHAR2 ) RETURN NUMBER IS
      WSTEP                 PLS_INTEGER := 0;
      WOBJECT               VARCHAR2(1000)  := 'PAC_INTERFAZ_DATECSA.F_EJECUTA_INTERFAZ_DATECSA';
      WPARAM                VARCHAR2(10000) := 'CODE:'||PCODE||' - NAME:'||PNAME;
      E_PARAM_NULL          EXCEPTION;
      E_ERROR               EXCEPTION;
      E_SSEGURO_NOT_NUMBER  EXCEPTION;
      WNUMERR               NUMBER;
      WFILE                 UTL_FILE.FILE_TYPE;
      WPATH                 VARCHAR2(1000);
      W1                    VARCHAR2(1000);
      WIDFICHERO            NUMBER := 0;
      WIDDOCGEDOX           NUMBER := 0;
      --
      WNMOVIMI              MOVSEGURO.NMOVIMI%TYPE;
      WCAGENTE              AGENTES.CAGENTE%TYPE;
      WPIDDOC               NUMBER;

      WCONTRA  NUMBER;--DVA DATECSA

      WSINIEST sin_siniestro.nsinies%TYPE; --DVA DATECSA 17/08/2017
      WSINDOC NUMBER;--DVA DATECSA	17/08/201
      -------------------------------------------------------------
      FUNCTION ISNUMBER( W IN VARCHAR2) RETURN CHAR IS
        WW  NUMBER;
      BEGIN
        WW := TO_NUMBER(W);
        -- NUMBER
        RETURN('N');
      EXCEPTION
        WHEN OTHERS THEN
          -- CHAR
          RETURN('C');
      END ISNUMBER;
      -------------------------------------------------------------
      -------------------------------------------------------------
      FUNCTION F_TO_TAB( PLINE IN OUT VARCHAR2) RETURN CHAR IS
        FILENAME      VARCHAR2(1000);
        I             PLS_INTEGER;
        WSTEP         PLS_INTEGER;
      BEGIN
        PLINE := TRIM(PLINE);
        I := 0;
        -- SE CARGAN EN ORDEN INVERSO AL QUE NOS ENCONTRAMOS ( ULTIMO ES EL 1¿)
        LOOP EXIT WHEN PLINE IS NULL;
          WSTEP := 30;
          FILENAME := SUBSTR(PLINE, INSTR(PLINE, '>', -1) + 1);
          WSP9TAB(I) := FILENAME;
          PLINE := SUBSTR(PLINE, 1, INSTR(PLINE, '>', -1) - 1);
          I := I+1;
        END LOOP;
        RETURN(0);
      EXCEPTION
        WHEN OTHERS THEN
          DATECSA_TRACE( 'F_TO_TAB', WOBJECT, ' - SQLERRM - '||SQLERRM);
          RETURN(-1);

      END F_TO_TAB;
      -------------------------------------------------------------
      -------------------------------------------------------------
      FUNCTION F_GET_NPOLIZA( PNPOLIZA IN SEGUROS.NPOLIZA%TYPE
                            , PNMOVIMI IN OUT MOVSEGURO.NMOVIMI%TYPE
                            ) RETURN NUMBER IS
        WSSEGURO  NUMBER;
      BEGIN
        DATECSA_TRACE( 'F_GET_NPOLIZA', WOBJECT, 'POL.:'||PNPOLIZA);
        SELECT SSEGURO INTO WSSEGURO FROM SEGUROS WHERE NPOLIZA = PNPOLIZA;
        --
        SELECT MAX(NMOVIMI) INTO PNMOVIMI FROM MOVSEGURO WHERE SSEGURO = WSSEGURO;
        --
        RETURN(WSSEGURO);
      EXCEPTION
        WHEN OTHERS THEN
          DATECSA_TRACE( 'F_GET_NPOLIZA', WOBJECT, 'SSEGURO NO EXISTENTE, POL.:'||PNPOLIZA||' - SQLERRM - '||SQLERRM);
          RAISE;
          --RETURN(-1);
      END F_GET_NPOLIZA;
      -------------------------------------------------------------
      -------------------------------------------------------------
      FUNCTION F_GET_SPERSON( PNUMIDE   IN      PER_PERSONAS.NNUMIDE%TYPE
                            , PCAGENTE  IN OUT  AGENTES.CAGENTE%TYPE
                            ) RETURN NUMBER IS
        WSPERSON  NUMBER;
      BEGIN
        SELECT SPERSON, CAGENTE INTO WSPERSON, PCAGENTE FROM PER_PERSONAS WHERE NNUMIDE = PNUMIDE AND ROWNUM = 1;
        --
        RETURN(WSPERSON);
      --
      EXCEPTION
        WHEN OTHERS THEN
          DATECSA_TRACE( 'F_GET_SPERSON', WOBJECT, 'SPERSON NO EXISTENTE, NNUMIDE.:'||PNUMIDE||' - SQLERRM - '||SQLERRM);
          RAISE;
          --RETURN(-1);
      END F_GET_SPERSON;
      -------------------------------------------------------------
      --------------------------------------------------------------------------
  --
  BEGIN
    WSTEP := 10010;
    DATECSA_TRACE('STEP:'||WSTEP, WOBJECT, '### INIT MAIN ### PARAMS:'||WPARAM);
    WCODE   := PCODE;
    WNAME   := PNAME;
    SELECT SEQ_DATECSA_ERR.NEXTVAL INTO WDATECSA_LIN FROM DUAL;
    DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, ' #### CTRL_LINEA INI #### PROCES:'||WSPROCES
      ||' ;WDATECSA_LIN:'||WDATECSA_LIN);
    WNUMERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(  PSPROCES    => WSPROCES
                                                           ,  PNLINEA     => WDATECSA_LIN
                                                           ,  PCTIPO      => 1
                                                           ,  PIDINT      => 1
                                                           ,  PIDEXT      => NULL
                                                           ,  PCESTADO    => 3          -- Pendiente
                                                           ,  PCVALIDADO  => NULL
                                                           ,  PSSEGURO    => null
                                                           ,  PIDEXTERNO  => null -- NPOLIZA
                                                           ,  PNCARGA     => NULL
                                                           ,  PNSINIES    => NULL
                                                           ,  PNTRAMIT    => NULL
                                                           ,  PSPERSON    => null
                                                           ,  PNRECIBO    => NULL
                                                           );
    WSTEP := 10020;
    IF  PCODE IS NULL OR PNAME IS NULL THEN
      WSTEP := 10030;
      RAISE E_PARAM_NULL;
    END IF;
    WSTEP := 10040;
    DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### READ SP9 ### ');
    WFILE := UTL_FILE.FOPEN('DATECSA', PNAME||'.sp9', 'R');
    WSTEP := 10050;
    UTL_FILE.GET_LINE(WFILE, WLINE);
    WSTEP := 10060;
    UTL_FILE.FCLOSE( WFILE);
    WLINEBAK := WLINE;
    WSTEP := 10070;
    DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, '### CLOSE SP9 ### ');
    WNUMERR := F_TO_TAB( WLINE);
    WSTEP := 10080;
    DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'PNAME:'||PNAME);
    --SELECT SEQ_DATECSA_ERR.NEXTVAL INTO WDATECSA_LIN FROM DUAL;
    ----------------------------------------------------------------------------
    IF ISNUMBER(WSP9TAB(WSP9TAB.LAST)) = 'N' THEN
      WSTEP := 10081;
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'PNAME:'||PNAME);
      WSSEGURO := F_GET_NPOLIZA(WSP9TAB(9), WNMOVIMI);
      IF WSSEGURO IS NULL OR WNMOVIMI IS NULL THEN
        WSTEP := 10082;
        RAISE E_ERROR;
      END IF;
 --   ELSE
 --     WSTEP := 10083;
 --     DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'PNAME:'||PNAME);
 --     WSPERSON := F_GET_SPERSON(WSP9TAB(9), WCAGENTE);
 --     IF WSPERSON IS NULL OR WCAGENTE IS NULL THEN
--        WSTEP := 10084;
--        RAISE E_ERROR;
--      END IF;
    ELSIF   WSP9TAB(WSP9TAB.LAST)='SAR'  THEN --DVA DATECSA 17/08/2017 inicio
     -- ARCHIVO SARLAFT
      WSTEP := 10083;
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'PNAME:'||PNAME);
      WSPERSON := F_GET_SPERSON(WSP9TAB(8), WCAGENTE);

      IF WSPERSON IS NULL  THEN
        WSTEP := 10084;
        RAISE E_ERROR;
      END IF;
    ELSIF   WSP9TAB(WSP9TAB.LAST)='CON'  THEN
     -- ARCHIVO CONTRAGARANTIA
      WSTEP := 10085;
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'PNAME:'||PNAME);
      WSPERSON := F_GET_SPERSON(WSP9TAB(7), WCAGENTE);
       WCONTRA := WSP9TAB(3); -- EL NUMERO DE RADICADO EN LA TABLA CTGAR_CONTRAGARANTIA ES IGUAL AL ID DE LA CONTRAGARANTIA.

       SELECT NVL(MAX(NMOVIMI),0) INTO WNMOVIMI  FROM  ctgar_contragarantia WHERE SCONTGAR=WCONTRA;


      IF WSPERSON IS NULL OR WCONTRA IS NULL OR WNMOVIMI IS NULL OR WNMOVIMI=0 THEN
        WSTEP := 10086;
        RAISE E_ERROR;
      END IF;

       ELSIF   WSP9TAB(WSP9TAB.LAST)='AIFDS'  THEN
     -- ARCHIVO SINIESTROS
      WSTEP := 10087;
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'PNAME:'||PNAME);
      WSINIEST := WSP9TAB(9);

      SELECT nvl(MAX(NDOCUME),0)+1 INTO WSINDOC FROM sin_tramita_documento WHERE NSINIES=WSINIEST;


      IF WSINIEST IS NULL OR WSINDOC IS NULL THEN
        WSTEP := 10088;
        RAISE E_ERROR;
      END IF;
    ELSE
    ---ARCHIVO GENERAL O COMERCIAL
      WSTEP := 10089;
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'PNAME:'||PNAME);
      WSPERSON := F_GET_SPERSON(WSP9TAB(9), WCAGENTE);

      IF WSPERSON IS NULL OR WCAGENTE IS NULL THEN
        WSTEP := 10090;
        RAISE E_ERROR;
      END IF;  --DVA DATECSA 17/08/2017  FIN

    END IF;
    ----------------------------------------------------------------------------
    WSTEP := 10091;
    DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, ' #### CTRL_LINEA INI #### PROCES:'||WSPROCES
      ||' ;WDATECSA_LIN:'||WDATECSA_LIN);
    WNUMERR := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA(  PSPROCES    => WSPROCES
                                                           ,  PNLINEA     => WDATECSA_LIN
                                                           ,  PCTIPO      => 1
                                                           ,  PIDINT      => 1
                                                           ,  PIDEXT      => NULL
                                                           ,  PCESTADO    => 1          -- ERROR
                                                           ,  PCVALIDADO  => NULL
                                                           ,  PSSEGURO    => WSSEGURO
                                                           ,  PIDEXTERNO  => WSP9TAB(WSP9TAB.LAST) --DVA DATECSA 17/08/2017 -- NPOLIZA WSP9TAB(9)
                                                           ,  PNCARGA     => NULL
                                                           ,  PNSINIES    => NULL
                                                           ,  PNTRAMIT    => NULL
                                                           ,  PSPERSON    => WSPERSON
                                                           ,  PNRECIBO    => NULL
                                                           );

    WSTEP := 10100;
    DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' #### CTRL_LINEA END #### ERR:'||WNUMERR);
    IF ISNUMBER(WSP9TAB(WSP9TAB.LAST)) = 'N' THEN
      -- ES POLIZA
      WSTEP := 10110;
      DATECSA_TRACE( 'STEP:'||WSTEP,'F_GET_NPOLIZA', ' ##### ES POLIZA INI ##### .WSP9TAB(9):'||WSP9TAB(9)||'; WNMOVIMI:'||WNMOVIMI||';ISNUM:'||ISNUMBER(WSP9TAB(9)));
      IF ISNUMBER(WSP9TAB(9)) = 'C' THEN
        WSTEP := 10120;
        RAISE E_SSEGURO_NOT_NUMBER;
      END IF;
      WSTEP := 10140;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ###### SET DOCUMGEDOX INI ###### WSSEGURO:'||WSSEGURO||' ;WNMOVIMI:'||WNMOVIMI||' ;USER:'||WSP9TAB(7)
          ||' ;FILENAME:'||PNAME||' ;PIDFICH:'||WCODE||' ;PTDESC:'||WSP9TAB(3));
      WNUMERR := PAC_MD_IMPRESION.F_SET_DOCUMGEDOX ( PSSEGURO   => WSSEGURO
                                                   , PNMOVIMI   => WNMOVIMI
                                                   , PUSER      => WSP9TAB(7)
                                                   , PTFILENAME => PNAMEPDF||'.pdf'
                                                   , PTDESC     => WSP9TAB(3)
                                                   , PIDCAT     => 1
                                                   , PIDDOC     => WPIDDOC
                                                   , MENSAJES   => MENSAJES
                                                   , DIRPDFGDX  => 'DATECSA'
                                                   );
      WSTEP := 10145;
      DATECSA_TRACE( 'STEP:'||WSTEP,' --- '||WOBJECT||' --- ',' ###### SET DOCUMGEDOX END ###### WNUMERR:'||WNUMERR);
      WSTEP := 10150;
      DATECSA_TRACE( 'STEP:'||WSTEP,' --- '||WOBJECT||' --- ',' ##### ES POLIZA END #####');

     ELSIF  WSP9TAB(WSP9TAB.LAST) = 'SAR' THEN --DVA DATECSA 17/08/2017 inicio
       -- ARCHIVO SARLAFT
      WSTEP := 10151;

      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ##### ES SARLAFT INI ##### ..WSP9TAB(8):'||WSP9TAB(8)||'; WNMOVIMI:'||WNMOVIMI||';ISNUM:'||ISNUMBER(WSP9TAB(8)));
      WSTEP := 10152;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ###### SET DOCUMPERSGEDOX INI ###### WSPERSON:'||WSPERSON||' ;AGENT:'||WCAGENTE
        ||' ;USER:'||WSP9TAB(6)||' ;PTFILENAME:'||PNAMEPDF||'.pdf'||' ;PIDCAT:'||1);
      WNUMERR := PAC_MD_GEDOX.F_SET_DOCUMPERSGEDOX ( PSPERSON    => WSPERSON
                                                   , PCAGENTE    => WCAGENTE
                                                   , PUSER       => WSP9TAB(6)
                                                   , PFCADUCA    => SYSDATE
                                                   , PTOBSERVA   => 'OBS.'
                                                   , PTFILENAME  => PNAMEPDF||'.pdf'
                                                   , PIDDOCGEDOX => WIDDOCGEDOX
                                                   , PTDESC      => WSP9TAB(2)
                                                   , PIDCAT      => 1
                                                   , PTDOCUMENTO => NULL
                                                   , PEDOCUMENTO => NULL
                                                   , PFEDO       => NULL
                                                   , MENSAJES    => MENSAJES
                                                   , PDIR        => 'DATECSA'
                                                   );
      WSTEP := 10153;
      DATECSA_TRACE( 'STEP:'||WSTEP,' --- '||WOBJECT||' --- ','##### ES SARLAFT END ##### WNUMERR:'||WNUMERR);

      ELSIF  WSP9TAB(WSP9TAB.LAST) = 'CON' THEN
       -- ARCHIVO CONTRAGARANTIA
      WSTEP := 10154;

      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ##### ES CONTRAGARANTIA INI ##### ..WSP9TAB(7):'||WSP9TAB(7)||'; WNMOVIMI:'||WNMOVIMI||';ISNUM:'||ISNUMBER(WSP9TAB(7)));
      WSTEP := 10155;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ###### SET DOCUMPERSGEDOX INI ###### WSPERSON:'||WSPERSON||' ;WCONTRA:'||WCONTRA
        ||' ;USER:'||WSP9TAB(5)||' ;PTFILENAME:'||PNAMEPDF||'.pdf'||' ;PIDCAT:'||2);

      WNUMERR := PAC_MD_GEDOX.F_SET_DOCUMCONTRAGEDOX ( PSPERSON    => WSPERSON
                                                   , PCONTRA    => WCONTRA
                                                   , PNMOVIMI   => WNMOVIMI
                                                   , PUSER       => WSP9TAB(5)
                                                   , PFCADUCA    => SYSDATE
                                                   , PTOBSERVA   => 'OBS.'
                                                   , PTFILENAME  => PNAMEPDF||'.pdf'
                                                   , PIDDOCGEDOX => WIDDOCGEDOX
                                                   , PTDESC      => WSP9TAB(2)
                                                   , PIDCAT      => 2
                                                   , PTDOCUMENTO => NULL
                                                   , PEDOCUMENTO => NULL
                                                   , PFEDO       => NULL
                                                   , MENSAJES    => MENSAJES
                                                   , PDIR        => 'DATECSA'
                                                   );
      WSTEP := 10156;
      DATECSA_TRACE( 'STEP:'||WSTEP,' --- '||WOBJECT||' --- ','##### ES CONTRAGARANTIA END ##### WNUMERR:'||WNUMERR);

   ELSIF  WSP9TAB(WSP9TAB.LAST) = 'AIFDS' THEN
       -- ARCHIVO SINIESTRO
      WSTEP := 10157;

      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ##### ES SINIESTRO INI ##### ..WSP9TAB(9):'||WSP9TAB(9)||'; WNMOVIMI:'||WNMOVIMI||';ISNUM:'||ISNUMBER(WSP9TAB(9)));
      WSTEP := 10158;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ###### SET DOCUMPERSGEDOX INI ###### WSINIEST:'||WSINIEST||' ;WSINDOC:'||WSINDOC
        ||' ;USER:'||WSP9TAB(8)||' ;PTFILENAME:'||PNAMEPDF||'.pdf'||' ;PIDCAT:'||3);

      WNUMERR := PAC_MD_GEDOX.f_set_documsinistresgedox ( pnsinies    => WSINIEST
                                                   , pntramit    => 0
                                                   , pndocume   => WSINDOC
                                                   , PUSER       => WSP9TAB(8)
                                                   , PTFILENAME  => PNAMEPDF||'.pdf'
                                                   , pidfichero => WIDDOCGEDOX
                                                   , ptdesc      => WSP9TAB(2)
                                                   , pidcat      => 3
                                                   , porigen => 'DATECSA'
                                                    , MENSAJES    => MENSAJES
                                                    );
      WSTEP := 10159;
      DATECSA_TRACE( 'STEP:'||WSTEP,' --- '||WOBJECT||' --- ','##### ES SINIESTRO END ##### WNUMERR:'||WNUMERR);
      --DVA DATECSA 17/08/2017 FIN
    ELSE
      -- ARCHIVO GENERAL O COMERCIAL
      WSTEP := 10160;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ##### ES GENERAL INI ##### ..WSP9TAB(9):'||WSP9TAB(9)||'; WNMOVIMI:'||WNMOVIMI||';ISNUM:'||ISNUMBER(WSP9TAB(9)));
      WSTEP := 10170;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ###### SET DOCUMPERSGEDOX INI ###### WSPERSON:'||WSPERSON||' ;AGENT:'||WCAGENTE
        ||' ;USER:'||WSP9TAB(7)||' ;PTFILENAME:'||PNAMEPDF||'.pdf'||' ;PIDCAT:'||1);
      WNUMERR := PAC_MD_GEDOX.F_SET_DOCUMPERSGEDOX ( PSPERSON    => WSPERSON
                                                   , PCAGENTE    => WCAGENTE
                                                   --, PUSER       => WSP9TAB(8)
												   , PUSER       => WSP9TAB(7)--DVA DATECSA 17/08/2017
                                                   , PFCADUCA    => SYSDATE
                                                   , PTOBSERVA   => 'OBS.'
                                                   , PTFILENAME  => PNAMEPDF||'.pdf'
                                                   , PIDDOCGEDOX => WIDDOCGEDOX
                                                   --, PTDESC      => WSP9TAB(3)
												   , PTDESC      => WSP9TAB(2)--DVA DATECSA 17/08/2017
                                                   , PIDCAT      => 1
                                                   , PTDOCUMENTO => NULL
                                                   , PEDOCUMENTO => NULL
                                                   , PFEDO       => NULL
                                                   , MENSAJES    => MENSAJES
                                                   , PDIR        => 'DATECSA'
                                                   );
      WSTEP := 10180;
      DATECSA_TRACE( 'STEP:'||WSTEP,' --- '||WOBJECT||' --- ','##### ES GENERAL END ##### WNUMERR:'||WNUMERR);
    END IF;
    --
    WSTEP := 10190;
    DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,'WNUMERR:'||WNUMERR);
    IF WNUMERR <> 0 THEN
      WSTEP := 10200;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,' ###### GEST ERROR GEDOX INI ###### WNUMERR:'||WNUMERR);
      P_GEST_ERROR;
      WSTEP := 10210;
      RAISE E_ERROR;
    ELSE
      WSTEP := 10220;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,'PNAME:'||PNAMEPDF||'.pdf');
      UTL_FILE.FREMOVE( 'DATECSA', PNAMEPDF||'.pdf');
      WSTEP := 10230;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,'PNAME:'||PNAME||'.sp9');
      UTL_FILE.FREMOVE( 'DATECSA', PNAME||'.sp9');
      WSTEP := 10240;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,'WNUMERR:'||WNUMERR);
      UPDATE INTERFAZ_DATECSA
      SET   ERROR         = 4 -- CORRECTO
        ,   ESTADO_PROC   = 1
        ,   FFIN_PROC     = SYSDATE
        ,   ID_GEDOX      = NVL( WPIDDOC, WIDDOCGEDOX)
        ,   ID_SPROCES    = WSPROCES
        ,   META_DATA     = WLINEBAK
      WHERE  CODIGO    = PCODE;
      WSTEP := 10250;
      DATECSA_TRACE( 'STEP:'||WSTEP,WOBJECT,'WNUMERR:'||WNUMERR);
    END IF;
    WSTEP := 10260;
    COMMIT;
    WSTEP := 10270;
    RETURN(0);
  EXCEPTION
    WHEN E_SSEGURO_NOT_NUMBER THEN
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'E_SSEGURO_NOT_NUMBER -- '||SQLERRM);
      -- POLIZA NO EXISTE ( O SSEGURO NO NUMERICO )
      RETURN( 9900973);
    WHEN E_PARAM_NULL THEN
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'E_PARAM_NULL -- '||SQLERRM||' -- '||WSTEP);
      -- HAY PAR¿METROS QUE NO DEBER¿AN SER NULOS
      RETURN(9000480);
    WHEN E_ERROR THEN
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, 'E_ERROR -- '||SQLERRM||' -- '||WSTEP);
      RETURN(SQLCODE);
    WHEN OTHERS THEN
      IF UTL_FILE.IS_OPEN(WFILE) THEN
        UTL_FILE.FCLOSE( WFILE);
      END IF;
      DATECSA_TRACE( 'STEP:'||WSTEP, WOBJECT, ' -- OTHERS -- '||SQLERRM||' -- '||WSTEP);
      RETURN(SQLCODE);

  END F_EJECUTA_INTERFAZ_DATECSA;
  --
  /*************************************************************************
      FUNCTION F_DIR_DATECSA
      RETURN             : NUMBER
  *************************************************************************/
  FUNCTION F_DIR_DATECSA RETURN NUMBER IS
    WLIST     CLOB;--VARCHAR2(32767);
    FILENAME  VARCHAR2(1000);
    NOM       VARCHAR2(1000);
    EXT       VARCHAR2(100);
    WSEQ      PLS_INTEGER;
    WSTEP     PLS_INTEGER := 0;
    L         PLS_INTEGER;
    WOBJECT   VARCHAR2(1000) := 'PAC_INTERFAZ_DATECSA.F_DIR_DATECSA';

   BEGIN
      WSTEP := 1000;
      -- DIR
      --WLIST := PAC_UTIL_JAVA.F_GET_LIST_FILES(PAC_UTIL_JAVA.GET_PATH_ORACLE('DATECSA'), ',');
      PAC_UTIL_JAVA.F_GET_LIST_FILES(PAC_UTIL_JAVA.GET_PATH_ORACLE('DATECSA'), WSPROCES);
      WSTEP := 1020;
      --LOOP EXIT WHEN WLIST IS NULL;
      FOR i in (select * from dir_list where sproces = WSPROCES) loop
         WSTEP := 1030;
         --FILENAME := SUBSTR(WLIST, INSTR(WLIST, ',', -1) + 1);
         FILENAME := i.filename;
         L := LENGTH( FILENAME);
         NOM := SUBSTR( FILENAME, 1, L -4);
         EXT := SUBSTR( FILENAME, L -3, 4);
         IF UPPER(EXT) = '.SP9' THEN
           WSTEP := 1040;
           SELECT NVL(MAX(CODIGO), 0) +1 INTO WSEQ FROM INTERFAZ_DATECSA;
           WSTEP := 1050;
           BEGIN
             INSERT INTO INTERFAZ_DATECSA ( CODIGO, NOMBRE, EXTENSION
                                          , UPPERNAME, id_sproces, finicio_proc)
             VALUES ( WSEQ
                    , NOM
                    , EXT
                    , UPPER(NOM)
                    , WSPROCES
                    , sysdate
                    );
             WSTEP := 1060;
           EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              UPDATE  INTERFAZ_DATECSA
              SET     NOMBRE    = NOM
              WHERE   UPPERNAME = UPPER(NOM)
                and   ID_SPROCES = WSPROCES;
           END;
         ELSIF UPPER(EXT) = '.PDF' THEN
           BEGIN
             SELECT NVL(MAX(CODIGO), 0) +1 INTO WSEQ FROM INTERFAZ_DATECSA;
             INSERT INTO INTERFAZ_DATECSA ( CODIGO, ADJUNTO, EXTENSION
                                          , UPPERNAME, id_sproces, finicio_proc)
             VALUES ( WSEQ
                    , NOM
                    , EXT
                    , UPPER(NOM)
                    , WSPROCES
                    , sysdate
                    );
             WSTEP := 1060;
           EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              UPDATE  INTERFAZ_DATECSA
              SET     ADJUNTO   = NOM
              WHERE   UPPERNAME = UPPER(NOM)
                and   ID_SPROCES = WSPROCES;
           END;
         END IF;
         WLIST := SUBSTR(WLIST, 1, INSTR(WLIST, ',', -1) - 1);
      END LOOP;
      WSTEP := 1070;
      COMMIT;
      RETURN(0);
  EXCEPTION WHEN OTHERS THEN
      DATECSA_TRACE( WSTEP, WOBJECT, 'OTHERS -- '||SQLERRM||' -- '||WSTEP);
      ROLLBACK;
      RETURN(-1*WSTEP);

  END F_DIR_DATECSA;
  --
  /*************************************************************************
      FUNCTION P_EXEC_DATECSA
  *************************************************************************/
  PROCEDURE P_EXEC_DATECSA IS
    WSTEP     PLS_INTEGER := 0;
    WRETURN   PLS_INTEGER;
    WPROCESADOS PLS_INTEGER := 0;
    WERRONEOS PLS_INTEGER := 0;
    E_ERROR   EXCEPTION;
    WOBJECT   VARCHAR2(1000) := 'PAC_INTERFAZ_DATECSA.P_EXEC_DATECSA';
    WMENSAJES VARCHAR2(4000);
    CURSOR CDATECSA IS SELECT * FROM INTERFAZ_DATECSA
                        WHERE META_DATA IS NULL AND ID_SPROCES = WSPROCES;
  BEGIN
    WSTEP := 0;
    SELECT SPROCES.NEXTVAL INTO WSPROCES FROM DUAL;
    ----------------------------------------------------------------------------
    -- HEADER
    WSTEP := 10;
    DATECSA_TRACE( WSTEP, WOBJECT, ' ---- HEADER INI ---- SPROCES:'||WSPROCES);
    WRETURN := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA
                  ( WSPROCES, 'CARGA_DATECSA', F_SYSDATE, NULL, 3, 1313, NULL, NULL);
    ----------------------------------------------------------------------------
    WSTEP := 20;
    DATECSA_TRACE( WSTEP, WOBJECT, ' ----- HEADER END ----- WRETURN:'||WRETURN||' PROCES:'||WSPROCES);
    WSTEP := 30;
    DATECSA_TRACE( WSTEP||' ------ INIT ------ ', WOBJECT, ' --- LECTURA DIR INI --- START ---------------------');
    WRETURN := F_DIR_DATECSA;
    WSTEP := 40;
    DATECSA_TRACE( WSTEP, WOBJECT, ' --- LECTURA DIR END --- WRETURN:'||WRETURN);
    IF WRETURN < 0 THEN
      WSTEP := 50;
      DATECSA_TRACE( WSTEP, WOBJECT, 'WRETURN:'||WRETURN);
      RAISE E_ERROR;
    END IF;
    WSTEP := 60;
    DATECSA_TRACE( WSTEP, WOBJECT, 'WRETURN:'||WRETURN);
    FOR R IN CDATECSA LOOP
      WSTEP := 70;
      DATECSA_TRACE( WSTEP, WOBJECT, ' ------ INICIO BUCLE ------ R.NOMBRE:'||R.NOMBRE);
      --SELECT ADJUNTO INTO WNOM_PDF FROM INTERFAZ_DATECSA WHERE UPPER(NOMBRE) = UPPER(R.NOMBRE) AND META_DATA IS NULL;
      WNOM_PDF := R.ADJUNTO;
      WSTEP := 80;
      DATECSA_TRACE( WSTEP, WOBJECT, ' ------- EJEC INTERFAZ DATECSA INI ------- WNOM_PDF:'||WNOM_PDF);
      WRETURN := F_EJECUTA_INTERFAZ_DATECSA( R.CODIGO, R.NOMBRE, R.ADJUNTO);
      WSTEP := 90;
      DATECSA_TRACE( WSTEP, WOBJECT, ' ------- EJEC INTERFAZ DATECSA END ------- WRETURN:'||WRETURN);
      IF WRETURN <> 0 THEN
        WSTEP := 100;
        DATECSA_TRACE( WSTEP, WOBJECT, ' -------- GEST ERROR INI -------- PROCES:'||WSPROCES);
        P_GEST_ERROR;
        WSTEP := 110;
        DATECSA_TRACE( WSTEP, WOBJECT, ' -------- GEST ERROR END -------- PROCES:'||WSPROCES);
        WMENSAJES := WRETURN;
        WSTEP := 120;
        DATECSA_TRACE( WSTEP, WOBJECT, ' -------- ESTADO_LINEAPROCESO INI -------- ');
        WRETURN := PAC_GESTION_PROCESOS.F_SET_CESTADO_LINEAPROCESO( WSPROCES, WDATECSA_LIN, 1); -- ERROR
        DATECSA_TRACE( WSTEP, WOBJECT, ' -------- CTRL_LINEA_ERROR INI -------- PROCES:'||WSPROCES||' ;LIN:'||WDATECSA_LIN);
        WRETURN := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_LINEA_ERROR
                                              ( PSPROCES  => WSPROCES
                                              , PNLINEA   => WDATECSA_LIN
                                              , PNERROR   => 1
                                              , PCTIPO    => 1
                                              , PCERROR   => 1
                                              , PTMENSAJE => WMENSAJES );
        WSTEP := 130;
        DATECSA_TRACE( WSTEP, WOBJECT, ' -------- CTRL_LINEA_ERROR END -------- WRETURN:'||WRETURN);
        --RAISE E_ERROR; --Pa que!?
        WERRONEOS := WERRONEOS + 1;
      ELSE
        WSTEP := 140;
        DATECSA_TRACE( WSTEP, WOBJECT, ' -------- ESTADO_LINEAPROCESO INI -------- ');
        WRETURN := PAC_GESTION_PROCESOS.F_SET_CESTADO_LINEAPROCESO( WSPROCES, WDATECSA_LIN, 4); -- CORRECTO
        WSTEP := 150;
        DATECSA_TRACE( WSTEP, WOBJECT, ' -------- ESTADO_LINEAPROCESO END --------  WRETURN:'||WRETURN);
      END IF;
      WPROCESADOS := WPROCESADOS + 1;
    END LOOP;
    WSTEP := 160;
    DATECSA_TRACE( WSTEP, WOBJECT, ' ---- HEADER UPDATE INI ---- ');
    WRETURN := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA
                  ( WSPROCES, 'CARGA_DATECSA', NULL, F_SYSDATE, 4, 1313, 0, 'Se han procesado '||WPROCESADOS||' ficheros. '||WERRONEOS||' han sido erroneos.');
    WSTEP := 170;
    DATECSA_TRACE( WSTEP, WOBJECT, ' ---- HEADER UPDATE END ---- WRETURN:'||WRETURN);
  EXCEPTION
    WHEN E_ERROR THEN
      DATECSA_TRACE( WSTEP, WOBJECT, ' *** E_ERROR *** WRETURN:'||WRETURN);
      P_TAB_ERROR(F_SYSDATE, F_USER, WOBJECT, WSTEP, WRETURN, 'ERROR:'||WRETURN);
      WRETURN := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA
                  ( WSPROCES, 'CARGA_DATECSA', NULL, F_SYSDATE, 1, 1313, 1, 'ERROR:'||WRETURN);
    WHEN OTHERS THEN
      DATECSA_TRACE( WSTEP, WOBJECT, ' *** OTHERS *** '||SQLERRM||' -- '||WSTEP||' -- '||WRETURN);
      P_TAB_ERROR(F_SYSDATE, F_USER, WOBJECT, WSTEP, WRETURN, 'ERROR:'||' *** OTHERS *** '||SQLERRM||' -- '||WSTEP||' -- '||WRETURN);
      WRETURN := PAC_GESTION_PROCESOS.F_SET_CARGA_CTRL_CABECERA
                  ( WSPROCES, 'CARGA_DATECSA', NULL, F_SYSDATE, 1, 1313, 1, 'ERROR:'||' *** OTHERS *** '||SQLERRM||' -- '||WSTEP||' -- '||WRETURN);
  END P_EXEC_DATECSA;
  --
  PROCEDURE DATECSA_TRACE ( P1 IN VARCHAR2, P2 IN VARCHAR2, P3  IN VARCHAR2)IS
    WTRACE NUMBER := 0;
  BEGIN
    WTRACE := NVL( F_PARINSTALACION_N('DATECSA_TRACE'), 0);
    IF WTRACE != 0 THEN
      P_CONTROL_ERROR( P1, P2, P3);
    END IF;
  END DATECSA_TRACE ;

END PAC_INTERFAZ_DATECSA;

/

  GRANT EXECUTE ON "AXIS"."PAC_INTERFAZ_DATECSA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INTERFAZ_DATECSA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INTERFAZ_DATECSA" TO "PROGRAMADORESCSI";
