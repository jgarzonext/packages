--------------------------------------------------------
--  DDL for Function F_ESTINSRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTINSRECIBO" (PSSEGURO IN NUMBER, PCAGENTE IN NUMBER, PFEMISIO IN
DATE, PFEFECTO IN DATE, PFVENCIM IN DATE, PCTIPREC IN NUMBER, PNANUALI IN
NUMBER, PNFRACCI IN NUMBER, PCCOBBAN IN NUMBER, PCESTIMP IN NUMBER,
PNRIESGO IN NUMBER, PNRECIBO IN OUT NUMBER, PMODO IN VARCHAR2, PSPROCES IN
NUMBER, PCMOVIMI IN NUMBER, PNMOVIMI IN NUMBER, PFMOVINI IN DATE) RETURN
NUMBER authid current_user IS
/****************************************************************************
   F_INSRECIBO : INSERTAR UN REGISTRO EN LA TABLA DE RECIBOS.
   ALLIBADM - GESTI�N DE DATOS REFERENTES A LOS RECIBOS
    CONTROLAR ERROR DE SI F_CONTADOR RETORNA 0
   (QUIERE DECIR QUE NRECIBO = 0 (ERROR))
   AFEGIM LES INSERCIONS EN RECIBOSREDCOM
   AFEGIM EL CAMP CDELEGA A LA TAULA RECIBOS
   AFEGIM ELS PAR�METRES PNRIESGO, PSMOVSEG,
   I LA FUNCI� F_MOVRECIBO.
   SEGONS EL NOU PAR�METRE PMODO, S' HA DE
   GRABAR A LA TAULA RECIBOS O RECIBOSCAR(ES GRABA EL NOU PAR�METRE
   PSPROCES).
    S' AFEGEIX LA FUNCI� F_INSRECIBOR, PER A GRABAR
   LES DADES A LA XARXA COMERCIAL.

    
    JFD 01/10/2007  Se a�ade el ctipban (tipo de CCC) y se mofica la llamada a F_CCC
****************************************************************************/
   ERROR      NUMBER := 0;
   NUM_ERR   NUMBER := 0;
   XCAGENTE   NUMBER;
   XNANUALI   NUMBER;
   XNFRACCI   NUMBER;
   XCCOBBAN   NUMBER;
   XCESTIMP   NUMBER;
   XCEMPRES   NUMBER;
   XSMOVREC   NUMBER;
   XNLIQMEN   NUMBER;
   XCFORPAG   NUMBER;
   xcbancar seguros.cbancar%type;
   DUMMY      NUMBER;
   XNBANCAR      seguros.cbancar%type;
   XNBANCARF   seguros.cbancar%type;
   XTBANCAR      seguros.cbancar%type;
   AUX_RAM      NUMBER;
   xctipban    seguros.ctipban%type;
BEGIN
BEGIN
   SELECT NVL(PCAGENTE,S.CAGENTE), NVL(PNANUALI,S.NANUALI),
      NVL(PNFRACCI, S.NFRACCI), NVL(PCCOBBAN,S.CCOBBAN),
      NVL(PCESTIMP, DECODE (A.CSOPREC, NULL, DECODE(PCCOBBAN, NULL, 1,
      4), 7)), S.CFORPAG, S.CBANCAR, S.CRAMO, S.CTIPBAN
   INTO XCAGENTE, XNANUALI, XNFRACCI, XCCOBBAN, XCESTIMP, XCFORPAG,
      XCBANCAR, AUX_RAM, XCTIPBAN
   FROM AGENTES A, ESTSEGUROS S
   WHERE S.SSEGURO = PSSEGURO
      AND A.CAGENTE = S.CAGENTE;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RETURN 101903;      -- ASSEGURAN�A NO TROBADA A SEGUROS
WHEN OTHERS THEN
    RETURN 101919;      -- ERROR AL LLEGIR DE SEGUROS
END;
------EST
--   ERROR := F_EMPRESA(PSSEGURO, NULL, NULL, XCEMPRES);
ERROR := F_EMPRESA(NULL, NULL, AUX_RAM, XCEMPRES);
IF ERROR = 0 THEN
IF XCBANCAR IS NOT NULL THEN
    XNBANCAR := xcbancar; --TO_NUMBER(XCBANCAR);----JFD - 28/09/2007
    ERROR := F_CCC(XNBANCAR, XCTIPBAN, DUMMY, XNBANCARF);
     --ERROR := F_CCC(XNBANCAR,DUMMY, XNBANCARF);
    IF ERROR = 0 THEN
      XTBANCAR := XCBANCAR;--LPAD(XNBANCARF, 20, '0'); --JFD - 28/09/2007
    ELSE
      RETURN ERROR;
    END IF;
END IF;
ELSE
RETURN ERROR;
END IF;
IF PMODO = 'P' THEN
    IF PNRECIBO IS NOT NULL AND PNRECIBO <> 0 AND PSPROCES IS NOT NULL
      AND PSPROCES <> 0 THEN
      BEGIN
        INSERT INTO RECIBOSCAR
       (SPROCES, NRECIBO, SSEGURO, CAGENTE, FEMISIO, FEFECTO, FVENCIM,
       CTIPREC, CESTAUX, NANUALI, NFRACCI, CCOBBAN, CESTIMP, CEMPRES,
       CDELEGA, NRIESGO)
        VALUES
      (PSPROCES, PNRECIBO, PSSEGURO, XCAGENTE, PFEMISIO, PFEFECTO,
      PFVENCIM, PCTIPREC, NULL, XNANUALI, XNFRACCI, XCCOBBAN, XCESTIMP,
      XCEMPRES, F_DELEGACION (NULL, XCEMPRES, XCAGENTE, PFEFECTO),
      PNRIESGO);
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        RETURN 103355;      -- REGISTRE DUPLICAT A RECIBOSCAR
      WHEN OTHERS THEN
        RETURN 103848;      -- ERROR A L' INSERIR A RECIBOSCAR
      END;
      RETURN 0;
    ELSE
      RETURN 101901;      -- PAS INCORRECTE DE PAR�METRES A LA FUNCI�
    END IF;
ELSIF PMODO = 'N' THEN
    IF PNRECIBO IS NOT NULL AND PNRECIBO <> 0 AND PSPROCES IS NOT NULL
      AND PSPROCES <> 0 THEN
      BEGIN
        INSERT INTO RECIBOSCAR
       (SPROCES, NRECIBO, SSEGURO, CAGENTE, FEMISIO, FEFECTO, FVENCIM,
       CTIPREC, CESTAUX, NANUALI, NFRACCI, CCOBBAN, CESTIMP, CEMPRES,
       CDELEGA, NRIESGO)
        VALUES
      (PSPROCES, PNRECIBO, PSSEGURO, XCAGENTE, SYSDATE, SYSDATE,
      SYSDATE, 0, NULL, NULL, NULL, NULL, NULL, XCEMPRES, NULL, NULL);
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        RETURN 103355;      -- REGISTRE DUPLICAT A RECIBOSCAR
      WHEN OTHERS THEN
        RETURN 103848;      -- ERROR A L' INSERIR A RECIBOSCAR
      END;
      RETURN 0;
    ELSE
      RETURN 101901;      -- PAS INCORRECTE DE PAR�METRES A LA FUNCI�
    END IF;
ELSE
    RETURN 101901;      -- PAS INCORRECTE DE PAR�METRES A LA FUNCI�
END IF;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTINSRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTINSRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTINSRECIBO" TO "PROGRAMADORESCSI";
