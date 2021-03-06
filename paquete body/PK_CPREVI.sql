--------------------------------------------------------
--  DDL for Package Body PK_CPREVI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_CPREVI" AS
PROCEDURE Llegir AS
BEGIN
	UTL_FILE.get_line (pk_autom.entrada, pk_autom.varlin);
	pk_autom.varlin := REPLACE(pk_autom.varlin,';',null);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		SORTIR := TRUE;
END Llegir;
PROCEDURE Comprovar AS
BEGIN
   IF (NIF_CLI IS NOT NULL) OR (TASAS IS NOT NULL) THEN
	-- Par�metros para WIN.
	DBMS_OUTPUT.PUT_LINE('POLISSA:    '||POLISSA);	 -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('POL_COLEC:    '||POL_COLEC);	 -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('NOM_CLI:    '||NOM_CLI);
	DBMS_OUTPUT.PUT_LINE('DATAEFEC:   '||DATAEFEC);
	DBMS_OUTPUT.PUT_LINE('DATAVENCIM: '||DATAVENCIM);
	DBMS_OUTPUT.PUT_LINE('PRIMANETA:  '||PRIMANETA); -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('PRIMABRUTA: '||PRIMABRUTA);
	DBMS_OUTPUT.PUT_LINE('CONTINENT:  '||CONTINENT); -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('CONTINGUT:  '||CONTINGUT); -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('COMISSIO:   '||COMISSIO);
	DBMS_OUTPUT.PUT_LINE('PRODUCTE:   '||PRODUCTE);  -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('----------------------------------------');
   ELSE
	-- Par�metros para CASER.
	--DBMS_OUTPUT.PUT_LINE('CIA:        '||CIA);
	--DBMS_OUTPUT.PUT_LINE('REBUT:      '||REBUT);
	DBMS_OUTPUT.PUT_LINE('POLISSA:    '||POLISSA);	 -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('D_REFECTE:  '||D_REFECTE);
	DBMS_OUTPUT.PUT_LINE('D_RVENCIM:  '||D_RVENCIM);
	DBMS_OUTPUT.PUT_LINE('PRIMANETA:  '||PRIMANETA); -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('PRIMABRUTA:  '||PRIMABRUTA); -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('CONTINENT:  '||CONTINENT); -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('CONTINGUT:  '||CONTINGUT); -- CASER, WIN
	DBMS_OUTPUT.PUT_LINE('COMI_AGENT: '||COMI_AGENT);
	DBMS_OUTPUT.PUT_LINE('COMISSIO: '||COMISSIO);
	DBMS_OUTPUT.PUT_LINE('NOM_CLI:    '||NOM_CLI);
	DBMS_OUTPUT.PUT_LINE('AVMAQUI:    '||AVMAQUI);
	DBMS_OUTPUT.PUT_LINE('DETALIME:   '||DETALIME);
	DBMS_OUTPUT.PUT_LINE('POL_COLEC:  '||POL_COLEC);
	DBMS_OUTPUT.PUT_LINE('SSEGURO:  '||SSEGURO);
	DBMS_OUTPUT.PUT_LINE('BONIFICA:   '||BONIFICA);
	DBMS_OUTPUT.PUT_LINE('CRAMO:        '||CRAMO);
	DBMS_OUTPUT.PUT_LINE('CMODALI:  '||CMODALI);
	DBMS_OUTPUT.PUT_LINE('CTIPSEG:   '||CTIPSEG);
	DBMS_OUTPUT.PUT_LINE('CCOLECT:   '||CCOLECT);
	DBMS_OUTPUT.PUT_LINE('REC_EXTER:  '||REC_EXTER);
	DBMS_OUTPUT.PUT_LINE('IMPOSTOS:   '||IMPOSTOS);
	DBMS_OUTPUT.PUT_LINE('CONSORCI:   '||CONSORCI);
	DBMS_OUTPUT.PUT_LINE('DGS:        '||DGS);
	DBMS_OUTPUT.PUT_LINE('ARBITRIO:   '||ARBITRIO);
	DBMS_OUTPUT.PUT_LINE('FNG:        '||FNG);
	DBMS_OUTPUT.PUT_LINE('PERROR:   '||PERROR);
	DBMS_OUTPUT.PUT_LINE('----------------------------------------');
   END IF;
END;
PROCEDURE Tractar AS
	vcramo	   NUMBER := null;
	vcmodali   NUMBER := null;
	vctipseg   NUMBER := null;
	vcolect    NUMBER := null;
	xsseguro   NUMBER := null;
	error	   NUMBER := null;
	xcidioma   NUMBER := null;
	XPrimaBruta	 NUMBER := null;
	xcomis		NUMBER;
	NoGRAVAR EXCEPTION;
BEGIN
	IF TIPO = 'C' THEN
	   PRIMABRUTA := NULL;
	   COMISSIO := NULL;
	ELSE
		NOM_CLI := NULL;
	END IF;
	-- Buscar el seguro.
	BEGIN
		SELECT CRAMO, CMODAL, CTIPSEG, CCOLECT
		INTO vcramo, vcmodali, vctipseg, vcolect
		FROM CNVPRODUCTOS
		WHERE NUMPOL = LTRIM(POL_COLEC); -- P�liza colectiva
		----
		SELECT SSEGURO
		INTO xsseguro
		FROM CNVPOLIZAS
		WHERE POLISSA_INI = LTRIM(POLISSA)  -- Certificado
		AND RAM = vcramo
		AND MODA = vcmodali
		AND TIPO = vctipseg
		AND COLE = vcolect;
	EXCEPTION
		WHEN OTHERS THEN
			 NULL;
	END;
	IF POLISSA IS NOT NULL THEN
	   POLISSA := LPAD(LTRIM(POLISSA), 10, '0');
	END IF;
	IF D_REFECTE IS NOT NULL THEN
	   D_REFECTE := LPAD(LTRIM(D_REFECTE), 6, '0');
	END IF;
	IF D_RVENCIM IS NOT NULL THEN
	   D_RVENCIM := LPAD(LTRIM(D_RVENCIM), 6, '0');
	END IF;
	IF PRIMANETA IS NOT NULL THEN
	   PRIMANETA := TO_CHAR(TO_NUMBER(PRIMANETA), '0999999999999D09');
	END IF;
	IF PRIMABRUTA IS NOT NULL THEN
	   PRIMABRUTA := TO_CHAR(TO_NUMBER(PRIMABRUTA), '0999999999999D09');
	ELSE
		XPrimaBruta := TO_NUMBER(NVL(PRIMANETA, 0)) + TO_NUMBER(NVL(REC_EXTER, 0)) +
					   TO_NUMBER(NVL(IMPOSTOS, 0)) + TO_NUMBER(NVL(CONSORCI, 0)) +
					   TO_NUMBER(NVL(DGS, 0)) + TO_NUMBER(NVL(ARBITRIO, 0)) +
					   TO_NUMBER(NVL(FNG, 0)) - TO_NUMBER(NVL(BONIFICA, 0));
		PRIMABRUTA := TO_CHAR(XPrimaBruta, '0999999999999D09');
	END IF;
	IF CONTINENT IS NOT NULL THEN
	   CONTINENT := TO_CHAR(TO_NUMBER(CONTINENT), '0999999999999D09');
	END IF;
	IF CONTINGUT IS NOT NULL THEN
	   CONTINGUT := TO_CHAR(TO_NUMBER(CONTINGUT), '0999999999999D09');
	END IF;
	IF COMI_AGENT IS NOT NULL THEN
	   COMI_AGENT := LTRIM(COMI_AGENT);
	   IF INSTR(COMI_AGENT, ',') = 1 THEN
	   	  COMI_AGENT := LPAD(COMI_AGENT, LENGTH(COMI_AGENT)+1, '0');
	   END IF;
	   COMI_AGENT := TO_CHAR(TO_NUMBER(COMI_AGENT), '0D0999');
	ELSE
	   COMI_AGENT := TO_CHAR(0, '0D0999');
	END IF;
	xcomis := TO_NUMBER(COMI_AGENT);
	COMISSIO := TO_CHAR((TO_NUMBER(PRIMABRUTA) * xcomis), '0999999999999D09');
	IF NOM_CLI IS NULL THEN
		error := f_asegurado(xsseguro, 1, NOM_CLI, xcidioma);
	END IF;
	IF AVMAQUI IS NOT NULL THEN
	   AVMAQUI := TO_CHAR(TO_NUMBER(AVMAQUI), '0999999999999D09');
	END IF;
	IF DETALIME IS NOT NULL THEN
	   DETALIME := TO_CHAR(TO_NUMBER(DETALIME), '0999999999999D09');
	END IF;
	IF POL_COLEC IS NOT NULL THEN
	   POL_COLEC := LPAD(LTRIM(POL_COLEC), 10, '0');
	END IF;
	SSEGURO := LPAD(TO_CHAR(xsseguro), 6, '0');
	IF BONIFICA IS NOT NULL THEN
	   BONIFICA := TO_CHAR(TO_NUMBER(BONIFICA), '0999999999999D09');
	END IF;
	CRAMO := LPAD(TO_CHAR(vcramo), 2, '0');
	CMODALI := LPAD(TO_CHAR(vcmodali), 2, '0');
	CTIPSEG := LPAD(TO_CHAR(vctipseg), 2, '0');
	CCOLECT := LPAD(TO_CHAR(vcolect), 2, '0');
EXCEPTION
	WHEN OTHERS THEN
		 NULL;
END Tractar;
END PK_CPREVI;

/

  GRANT EXECUTE ON "AXIS"."PK_CPREVI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CPREVI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CPREVI" TO "PROGRAMADORESCSI";
