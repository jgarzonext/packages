--------------------------------------------------------
--  DDL for Package Body PK_AUDRECIBOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_AUDRECIBOS" AS
	--***************************************************************
	--***
	--*** Descripción del tipo de plantilla en función de la var. <tipo>
	--***
	--*** (1) - Recibos extornados de anulados
	--*** (2) - Recibos emitidos
	--*** (3) - Recibos cobrados
	--*** (4) - Recibos extornados de cobrados
	--*** (5) - Recibos pendientes de cobro
	--*** (6) - Recibos anulados emitidos en el ejercicio
	--*** (7) - Recibos anulados emitidos en ejercicios anteriores
    --***
    --***************************************************************
	cadena 			  VARCHAR2(100) := null;
	cobrado_anulado   NUMBER := 0;
	pendiente_anulado NUMBER := 0;
	recibo            NUMBER(9);
	ramo              NUMBER;
	modalidad         NUMBER;
	tipseg            NUMBER;
	colect            NUMBER;
	coprinet          NUMBER(25,10) := 0;
    peprinet          NUMBER(25,10) := 0;
	cosobrep          NUMBER(25,10) := 0;
	pesobrep          NUMBER(25,10) := 0;
	codeducc          NUMBER(25,10) := 0;
	pededucc          NUMBER(25,10) := 0;
	cototpri          NUMBER(25,10) := 0;
	petotpri          NUMBER(25,10) := 0;
	coimpues          NUMBER(25,10) := 0;
	peimpues          NUMBER(25,10) := 0;
	coconsor          NUMBER(25,10) := 0;
	peconsor          NUMBER(25,10) := 0;
	cocomisi          NUMBER(25,10) := 0;
	pecomisi          NUMBER(25,10) := 0;
	cototal           NUMBER(25,10) := 0;
	petotal           NUMBER(25,10) := 0;
	cocuenta          SEGUROS.CBANCAR%TYPE;
	reprecibo         NUMBER;
FUNCTION inicializar RETURN NUMBER IS
    err NUMBER;
BEGIN
	cadena 			  := null;
	cobrado_anulado   := 0;
	pendiente_anulado := 0;
	recibo            := 0;
	ramo              := NULL;
	modalidad         := NULL;
	tipseg            := NULL;
	colect            := NULL;
	coprinet          := 0;
    peprinet          := 0;
	cosobrep          := 0;
	pesobrep          := 0;
	codeducc          := 0;
	pededucc          := 0;
	cototpri          := 0;
	petotpri          := 0;
	coimpues          := 0;
	peimpues          := 0;
	coconsor          := 0;
	peconsor          := 0;
	cocomisi          := 0;
	pecomisi          := 0;
	cototal           := 0;
	petotal           := 0;
	cocuenta          := NULL;
	reprecibo         := 0;
RETURN ( 0 );
END inicializar;
FUNCTION generar ( mesaño IN DATE , ptipo IN NUMBER) RETURN NUMBER IS
    err NUMBER;
BEGIN
INSERT INTO TMP_PLANTILLAS_RECIBOS
	 						 ( CRAMO		  ,CMODALI
							  ,CTIPSEG		  ,CCOLECT
							  ,MES			  ,ANYO
							  ,CTIPO		  ,ICONETA
							  ,ICOSOBR		  ,ICODEDU
							  ,ICOPRIM		  ,ICOIMPU
							  ,ICOCONS		  ,ICOCOMI
							  ,ICOTOTA		  ,CCOBANC
							  ,IPENETA		  ,IPESOBR
							  ,IPEDEDU		  ,IPEPRIM
							  ,IPEIMPU		  ,IPECONS
							  ,IPECOMI		  ,IPETOTA )
VALUES ( ramo 	        ,modaliDAD
		,NVL(tipseg,0)		,nvl(colect,0)
	    ,TO_CHAR(mesaño,'MM'),TO_CHAR(mesaño,'YYYY')
		,ptipo	 	    ,coprinet
  	    ,cosobrep		,codeducc
		,cototpri		,coimpues
		,coconsor		,cocomisi
		,cototal		,cocuenta
		,peprinet  	    ,pesobrep
		,pededucc		,petotpri
		,peimpues		,peconsor
		,pecomisi		,petotal ) ;
ERR := INICIALIZAR;
RETURN ( 1 );
EXCEPTION
		 WHEN DUP_VAL_ON_INDEX THEN
		   BEGIN
		 	  UPDATE TMP_PLANTILLAS_RECIBOS
	 		  SET  	 ICONETA =  coprinet,
			  		 ICOSOBR = cosobrep	,
					 ICODEDU = codeducc ,
					 ICOPRIM = cototpri	,
					 ICOIMPU = coimpues	,
					 ICOCONS = coconsor	,
					 ICOCOMI = cocomisi	,
					 ICOTOTA = cototal	,
					 CCOBANC = cocuenta ,
					 IPENETA = peprinet ,
					 IPESOBR = pesobrep ,
					 IPEDEDU = pededucc ,
					 IPEPRIM = petotpri ,
					 IPEIMPU = peimpues ,
					 IPECONS = peconsor ,
					 IPECOMI = pecomisi ,
					 IPETOTA = petotal
		 	  WHERE   ramo   			= cramo
			  		  and modaliDAD 	= cmodali
					  and NVL(tipseg,0) = ctipseg
					  and nvl(colect,0) = ccolect
					  and mes 			= TO_CHAR(mesaño,'MM')
					  and anyo 			= TO_CHAR(mesaño,'YYYY')
					  and ctipo 		= ptipo;

     	EXCEPTION WHEN OTHERS THEN
       		dbms_output.put_line (' Error final update' || sqlerrm );
       		return ( -2 );
 	 	END;
 WHEN OTHERS THEN
   dbms_output.put_line (' Error final ' || sqlerrm );
   return ( -2 );
END generar;
--*******************************************************************
--************* EMITIDOS ********************************************
--*******************************************************************
FUNCTION emitidos ( pramo IN NUMBER , pmodali IN NUMBER
                   ,ptipseg IN NUMBER ,pcolect IN NUMBER
				   ,mesaño IN DATE
  			       ,ptipo IN NUMBER) RETURN NUMBER is
    err NUMBER;
    Cursor recibos
	 is SELECT /*+ rule */ recibos.nrecibo
  	  		 , seguros.sseguro  	  		 , movrecibo.FMOVINI
           	 , movrecibo.fmovfin			 , movrecibo.CESTREC
			 , movrecibo.CESTANT			 , seguros.CRAMO
			 , SEGUROS.CMODALI 			     , seguros.ctipseg
			 , SEGUROS.CCOLECT 			     , RECIBOS.CBANCAR
			 , VDETRECIBOS.IPRINET			 , VDETRECIBOS.IIPS
			 , VDETRECIBOS.ICONSOR			 , VDETRECIBOS.ICOMBRU
			 , VDETRECIBOS.ITOTALR
			 , PRODUCTOS.CCALCOM
	   FROM movrecibo, seguros, recibos, productos, vdetrecibos
      WHERE movrecibo.nrecibo = recibos.nrecibo
	    AND recibos.sseguro = seguros.sseguro
		AND seguros.cramo = productos.cramo
		AND seguros.cmodali = productos.cmodali
		AND seguros.ctipseg = productos.ctipseg
		AND seguros.ccolect = productos.ccolect
		AND productos.cramo = pramo
		AND productos.cmodali = DECODE(nvl(pmodali,0),0,productos.cmodali,pmodali)
		AND productos.ctipseg = DECODE(nvl(ptipseg,0),0,productos.ctipseg,ptipseg)
		AND productos.ccolect = DECODE(nvl(pcolect,0),0,productos.ccolect,pcolect)
		AND recibos.nrecibo = vdetrecibos.NRECIBO
		AND TO_CHAR(recibos.femisio,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
        AND ( RECIBOS.CTIPREC <> 9
            OR ( RECIBOS.CTIPREC = 9 AND SEGUROS.CRAMO = 15 )
			)
		AND FMOVFIN IS NULL
		ORDER BY seguros.sseguro ,movrecibo.nrecibo, smovrec;
BEGIN
-- Generamos una cadena con las situaciones del recibo
reprecibo := -1 ;
FOR registro IN recibos LOOP
	recibo    := REGISTRO.NRECIBO;
	ramo      := PRAMO;
	modalidad := PMODALI;
	tipseg    := PTIPSEG;
    colect    := PCOLECT;
    IF REGISTRO.FMOVFIN IS NOT NULL THEN
        reprecibo  := registro.nrecibo;
        cadena  := cadena || to_char(registro.cestrec,'FM9');
	ELSE
        cadena  := cadena || to_char(registro.cestrec,'FM9');
        cobrado_anulado := 1;
	 	coprinet := nvl(coprinet,0) + nvl(registro.iprinet,0);
        cosobrep := nvl(cosobrep,0) + 0;
		codeducc := nvl(codeducc,0) + 0;
		cototpri := coprinet + cosobrep - codeducc;
		coimpues := nvl(coimpues,0) + nvl(registro.iips,0);
		coconsor := nvl(coconsor,0) + nvl(registro.iconsor,0);
		IF registro.ccalcom = 1 then
  		  cocomisi := nvl(cocomisi,0) + nvl(registro.icombru,0);
		END IF;
		cototal  := nvl(cototal,0)  + nvl(registro.itotalr,0);
		reprecibo := registro.nrecibo;
		cadena := null;
	END IF;
END LOOP;
err := generar ( mesaño, ptipo );
RETURN ( 1 );
EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line (' Se ha producido un error ' || sqlerrm);
   return ( -1 );
END EMITIDOS;
--*******************************************************************
--************* COBRADOS*********************************************
--*******************************************************************
FUNCTION COBRADOS ( pramo IN NUMBER , pmodali IN NUMBER
                   ,ptipseg IN NUMBER ,pcolect IN NUMBER
				   ,mesaño IN DATE
  			       ,ptipo IN NUMBER) RETURN NUMBER is
    err NUMBER;
    Cursor recibos
	 is SELECT /*+ rule */ recibos.nrecibo
  	  		 , seguros.sseguro  	  		 , movrecibo.FMOVINI
           	 , movrecibo.fmovfin			 , movrecibo.CESTREC
			 , movrecibo.CESTANT			 , seguros.CRAMO
			 , SEGUROS.CMODALI 			     , seguros.ctipseg
			 , SEGUROS.CCOLECT 			     , RECIBOS.CBANCAR
			 , VDETRECIBOS.IPRINET			 , VDETRECIBOS.IIPS
			 , VDETRECIBOS.ICONSOR			 , VDETRECIBOS.ICOMBRU
			 , VDETRECIBOS.ITOTALR
			 , recibos.ctiprec
 			 , PRODUCTOS.CCALCOM
	   FROM movrecibo, seguros, recibos, productos, vdetrecibos
      WHERE movrecibo.nrecibo = recibos.nrecibo
	    AND recibos.sseguro = seguros.sseguro
		AND seguros.cramo = productos.cramo
		AND seguros.cmodali = productos.cmodali
		AND seguros.ctipseg = productos.ctipseg
		AND seguros.ccolect = productos.ccolect
		AND productos.cramo = pramo
		AND productos.cmodali = DECODE(nvl(pmodali,0),0,productos.cmodali,pmodali)
		AND productos.ctipseg = DECODE(nvl(ptipseg,0),0,productos.ctipseg,ptipseg)
		AND productos.ccolect = DECODE(nvl(pcolect,0),0,productos.ccolect,pcolect)
		AND recibos.nrecibo = vdetrecibos.NRECIBO
		AND TO_CHAR(movrecibo.fmovdia,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
		AND MOVRECIBO.SMOVREC = ( SELECT MAX(SMOVREC) FROM MOVRECIBO M
		                          WHERE TO_CHAR(M.fmovdia,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
								  AND M.NRECIBO = RECIBOS.NRECIBO )
		--AND RECIBOS.CTIPREC <> 9
		AND MOVRECIBO.CESTREC = 1
		ORDER BY seguros.sseguro ,movrecibo.nrecibo, smovrec;
BEGIN
-- Generamos una cadena con las situaciones del recibo
reprecibo := -1 ;
ramo      := PRAMO;
modalidad := PMODALI;
tipseg    := PTIPSEG;
colect    := PCOLECT;
FOR registro IN recibos LOOP
	recibo    := REGISTRO.NRECIBO;
	ramo      := PRAMO;
	modalidad := PMODALI;
	tipseg    := PTIPSEG;
    colect    := PCOLECT;
    IF REGISTRO.FMOVFIN IS NOT NULL THEN
        reprecibo  := registro.nrecibo;
        cadena  := cadena || to_char(registro.cestrec,'FM9');
	ELSE
        cadena  := cadena || to_char(registro.cestrec,'FM9');
        cobrado_anulado := 1;
		if registro.ctiprec <> 9 then
  	 	    coprinet := nvl(coprinet,0) + nvl(registro.iprinet,0);
            cosobrep := nvl(cosobrep,0) + 0;
			codeducc := nvl(codeducc,0) + 0;
			cototpri := coprinet + cosobrep - codeducc;
			coimpues := nvl(coimpues,0) + nvl(registro.iips,0);
			coconsor := nvl(coconsor,0) + nvl(registro.iconsor,0);
			cocomisi := nvl(cocomisi,0) + nvl(registro.icombru,0);
			cototal  := nvl(cototal,0)  + nvl(registro.itotalr,0);
		else
		  	coprinet := nvl(coprinet,0) - nvl(registro.iprinet,0);
            cosobrep := nvl(cosobrep,0) + 0;
			codeducc := nvl(codeducc,0) + 0;
			cototpri := coprinet + cosobrep - codeducc;
			coimpues := nvl(coimpues,0) - nvl(registro.iips,0);
			coconsor := nvl(coconsor,0) - nvl(registro.iconsor,0);
			cocomisi := nvl(cocomisi,0) - nvl(registro.icombru,0);
			cototal  := nvl(cototal,0)  - nvl(registro.itotalr,0);
		end if;
		reprecibo := registro.nrecibo;
		cadena := null;
	END IF;
	--XT
	--IF registro.ccalcom = 1 then
	--    cocomisi := null;
	--	pecomisi := null;
	--END IF;
END LOOP;
err := generar ( mesaño, ptipo );
RETURN ( 1 );
EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line (' Se ha producido un error ' || sqlerrm);
   return ( -1 );
END COBRADOS;
--*******************************************************************
--************* Extornados de cobrados ******************************
--*******************************************************************
FUNCTION EXTORNADOS_DE_COBRADOS ( pramo IN NUMBER , pmodali IN NUMBER
                   ,ptipseg IN NUMBER ,pcolect IN NUMBER
				   ,mesaño IN DATE
  			       ,ptipo IN NUMBER) RETURN NUMBER is
    err NUMBER;
    Cursor recibos
	 is SELECT /*+ rule */ recibos.nrecibo
  	  		 , seguros.sseguro  	  		 , movrecibo.FMOVINI
           	 , movrecibo.fmovfin			 , movrecibo.CESTREC
			 , movrecibo.CESTANT			 , seguros.CRAMO
			 , SEGUROS.CMODALI 			     , seguros.ctipseg
			 , SEGUROS.CCOLECT 			     , RECIBOS.CBANCAR
			 , VDETRECIBOS.IPRINET			 , VDETRECIBOS.IIPS
			 , VDETRECIBOS.ICONSOR			 , VDETRECIBOS.ICOMBRU
			 , VDETRECIBOS.ITOTALR
			 , PRODUCTOS.CCALCOM
	   FROM movrecibo, seguros, recibos, productos, vdetrecibos
      WHERE movrecibo.nrecibo = recibos.nrecibo
	    AND recibos.sseguro = seguros.sseguro
		AND seguros.cramo = productos.cramo
		AND seguros.cmodali = productos.cmodali
		AND seguros.ctipseg = productos.ctipseg
		AND seguros.ccolect = productos.ccolect
		AND productos.cramo = pramo
		AND productos.cmodali = DECODE(nvl(pmodali,0),0,productos.cmodali,pmodali)
		AND productos.ctipseg = DECODE(nvl(ptipseg,0),0,productos.ctipseg,ptipseg)
		AND productos.ccolect = DECODE(nvl(pcolect,0),0,productos.ccolect,pcolect)
		AND recibos.nrecibo = vdetrecibos.NRECIBO
		AND TO_CHAR(recibos.femisio,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
		AND RECIBOS.CTIPREC = 9
		AND MOVRECIBO.CESTREC = 1
		AND FMOVFIN IS NULL
		ORDER BY seguros.sseguro ,movrecibo.nrecibo, smovrec;
BEGIN
-- Generamos una cadena con las situaciones del recibo
reprecibo := -1 ;
ramo      := PRAMO;
modalidad := PMODALI;
tipseg    := PTIPSEG;
colect    := PCOLECT;
FOR registro IN recibos LOOP
	recibo    := REGISTRO.NRECIBO;
	ramo      := PRAMO;
	modalidad := PMODALI;
	tipseg    := PTIPSEG;
    colect    := PCOLECT;
    IF REGISTRO.FMOVFIN IS NOT NULL THEN
        reprecibo  := registro.nrecibo;
        cadena  := cadena || to_char(registro.cestrec,'FM9');
	ELSE
        cadena  := cadena || to_char(registro.cestrec,'FM9');
        cobrado_anulado := 1;
	 	coprinet := nvl(coprinet,0) + nvl(registro.iprinet,0);
        cosobrep := nvl(cosobrep,0) + 0;
		codeducc := nvl(codeducc,0) + 0;
		cototpri := coprinet + cosobrep - codeducc;
		coimpues := nvl(coimpues,0) + nvl(registro.iips,0);
		coconsor := nvl(coconsor,0) + nvl(registro.iconsor,0);
		cocomisi := nvl(cocomisi,0) + nvl(registro.icombru,0);
		cototal  := nvl(cototal,0)  + nvl(registro.itotalr,0);
		reprecibo := registro.nrecibo;
		cadena := null;
	END IF;
	--XT
	--IF registro.ccalcom = 1 then
	--    cocomisi := null;
	--	pecomisi := null;
	--END IF;
END LOOP;
err := generar ( mesaño, ptipo );
RETURN ( 1 );
EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line (' Se ha producido un error ' || sqlerrm);
   return ( -1 );
END EXTORNADOS_DE_COBRADOS;
--*******************************************************************
--************* Extornados de anulados ******************************
--*******************************************************************
FUNCTION EXTORNADOS_DE_ANULADOS ( pramo IN NUMBER , pmodali IN NUMBER
                   ,ptipseg IN NUMBER ,pcolect IN NUMBER
				   ,mesaño IN DATE
  			       ,ptipo IN NUMBER) RETURN NUMBER is
    err NUMBER;
    Cursor recibos
	 is SELECT /*+ rule */ recibos.nrecibo
  	  		 , seguros.sseguro  	  		 , movrecibo.FMOVINI
           	 , movrecibo.fmovfin			 , movrecibo.CESTREC
			 , movrecibo.CESTANT			 , seguros.CRAMO
			 , SEGUROS.CMODALI 			     , seguros.ctipseg
			 , SEGUROS.CCOLECT 			     , RECIBOS.CBANCAR
			 , VDETRECIBOS.IPRINET			 , VDETRECIBOS.IIPS
			 , VDETRECIBOS.ICONSOR			 , VDETRECIBOS.ICOMBRU
			 , VDETRECIBOS.ITOTALR
			 , PRODUCTOS.CCALCOM
	   FROM movrecibo, seguros, recibos, productos, vdetrecibos
      WHERE movrecibo.nrecibo = recibos.nrecibo
	    AND recibos.sseguro = seguros.sseguro
		AND seguros.cramo = productos.cramo
		AND seguros.cmodali = productos.cmodali
		AND seguros.ctipseg = productos.ctipseg
		AND seguros.ccolect = productos.ccolect
		AND productos.cramo = pramo
		AND productos.cmodali = DECODE(nvl(pmodali,0),0,productos.cmodali,pmodali)
		AND productos.ctipseg = DECODE(nvl(ptipseg,0),0,productos.ctipseg,ptipseg)
		AND productos.ccolect = DECODE(nvl(pcolect,0),0,productos.ccolect,pcolect)
		AND recibos.nrecibo = vdetrecibos.NRECIBO
		AND TO_CHAR(recibos.femisio,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
		ORDER BY seguros.sseguro ,movrecibo.nrecibo, smovrec;
BEGIN
-- Generamos una cadena con las situaciones del recibo
reprecibo := -1 ;
ramo      := PRAMO;
modalidad := PMODALI;
tipseg    := PTIPSEG;
colect    := PCOLECT;
FOR registro IN recibos LOOP
	recibo    := REGISTRO.NRECIBO;
	ramo      := PRAMO;
	modalidad := PMODALI;
	tipseg    := PTIPSEG;
    colect    := PCOLECT;
    IF REGISTRO.FMOVFIN IS NOT NULL THEN
        reprecibo  := registro.nrecibo;
        cadena  := cadena || to_char(registro.cestrec,'FM9');
	ELSE
        cadena  := cadena || to_char(registro.cestrec,'FM9');
   		-- Buscamos si el recibo ha pasado de cobrado a anulado
		-- o solo ha sido ha anulado de pendiente por primera vez.
		IF instr(cadena,'0102') > 0 then
   		    --dbms_output.put_line ('ca: ' || registro.sseguro || ' cad: ' || cadena || ' imp: ' || registro.iprinet);
	        cobrado_anulado := 1;
		 	coprinet := nvl(coprinet,0) + nvl(registro.iprinet,0);
   	        cosobrep := nvl(cosobrep,0) + 0;
			codeducc := nvl(codeducc,0) + 0;
			cototpri := coprinet + cosobrep - codeducc;
			coimpues := nvl(coimpues,0) + nvl(registro.iips,0);
			coconsor := nvl(coconsor,0) + nvl(registro.iconsor,0);
			cocomisi := nvl(cocomisi,0) + nvl(registro.icombru,0);
			cototal  := nvl(cototal,0)  + nvl(registro.itotalr,0);
		ELSIF instr(cadena,'02') = 1 then
			--dbms_output.put_line ('pa: ' || registro.sseguro || 'cad: ' || cadena || ' imp: ' || registro.iprinet );
	    	pendiente_anulado := 1;
 		 	peprinet := nvl(peprinet,0) + nvl(registro.iprinet,0);
   	        pesobrep := nvl(pesobrep,0) + 0;
			pededucc := nvl(pededucc,0) + 0;
			petotpri := peprinet + pesobrep - pededucc;
			peimpues := nvl(peimpues,0) + nvl(registro.iips,0);
			peconsor := nvl(peconsor,0) + nvl(registro.iconsor,0);
			pecomisi := nvl(pecomisi,0) + nvl(registro.icombru,0);
			petotal  := nvl(petotal,0)  + nvl(registro.itotalr,0);
		END IF;
		reprecibo := registro.nrecibo;
		cadena := null;
	END IF;
	--XT
	--IF registro.ccalcom = 1 then
	--    cocomisi := null;
	--	pecomisi := null;
	--END IF;
END LOOP;
err := generar ( mesaño, ptipo );
RETURN ( 1 );
EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line (' Se ha producido un error ' || sqlerrm);
   return ( -1 );
END EXTORNADOS_DE_ANULADOS;
--*******************************************************************
--************* PENDIENTES DE COBRO *********************************
--*******************************************************************
FUNCTION PENDIENTES_DE_COBRO ( pramo IN NUMBER , pmodali IN NUMBER
                   ,ptipseg IN NUMBER ,pcolect IN NUMBER
				   ,mesaño IN DATE
  			       ,ptipo IN NUMBER) RETURN NUMBER is
    err NUMBER;
    Cursor recibos
	 is SELECT /*+ rule */ recibos.nrecibo
  	  		 , seguros.sseguro  	  		 , movrecibo.FMOVINI
           	 , movrecibo.fmovfin			 , movrecibo.CESTREC
			 , movrecibo.CESTANT			 , seguros.CRAMO
			 , SEGUROS.CMODALI 			     , seguros.ctipseg
			 , SEGUROS.CCOLECT 			     , RECIBOS.CBANCAR
			 , VDETRECIBOS.IPRINET			 , VDETRECIBOS.IIPS
			 , VDETRECIBOS.ICONSOR			 , VDETRECIBOS.ICOMBRU
			 , VDETRECIBOS.ITOTALR
			 , PRODUCTOS.CCALCOM
	   FROM movrecibo, seguros, recibos, productos, vdetrecibos
      WHERE movrecibo.nrecibo = recibos.nrecibo
	    AND recibos.sseguro = seguros.sseguro
		AND seguros.cramo = productos.cramo
		AND seguros.cmodali = productos.cmodali
		AND seguros.ctipseg = productos.ctipseg
		AND seguros.ccolect = productos.ccolect
		AND productos.cramo = pramo
		AND productos.cmodali = DECODE(nvl(pmodali,0),0,productos.cmodali,pmodali)
		AND productos.ctipseg = DECODE(nvl(ptipseg,0),0,productos.ctipseg,ptipseg)
		AND productos.ccolect = DECODE(nvl(pcolect,0),0,productos.ccolect,pcolect)
		AND recibos.nrecibo = vdetrecibos.NRECIBO
		AND  TO_CHAR(recibos.femisio,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
		AND  TO_CHAR(movrecibo.fmovini,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
		--AND movrecibo.CESTREC = 0
		ORDER BY seguros.sseguro ,movrecibo.nrecibo, smovrec;
BEGIN
-- Generamos una cadena con las situaciones del recibo
reprecibo := -1 ;
ramo      := PRAMO;
modalidad := PMODALI;
tipseg    := PTIPSEG;
colect    := PCOLECT;
FOR registro IN recibos LOOP
    IF REGISTRO.FMOVFIN IS NOT NULL THEN
        reprecibo  := registro.nrecibo;
        cadena  := cadena || to_char(registro.cestrec,'FM9');
	ELSE
        cadena  := cadena || to_char(registro.cestrec,'FM9');
		IF substr('cadena',-1,1) = '0' then
   		    --dbms_output.put_line ('ca: ' || registro.sseguro || ' cad: ' || cadena || ' imp: ' || registro.iprinet);
	        cobrado_anulado := 1;
		 	coprinet := nvl(coprinet,0) + nvl(registro.iprinet,0);
   	        cosobrep := nvl(cosobrep,0) + 0;
			codeducc := nvl(codeducc,0) + 0;
			cototpri := coprinet + cosobrep - codeducc;
			coimpues := nvl(coimpues,0) + nvl(registro.iips,0);
			coconsor := nvl(coconsor,0) + nvl(registro.iconsor,0);
			cocomisi := nvl(cocomisi,0) + nvl(registro.icombru,0);
			cototal  := nvl(cototal,0)  + nvl(registro.itotalr,0);
		END IF;
		reprecibo := registro.nrecibo;
		cadena := null;
	END IF;
	--XT
	--IF registro.ccalcom = 1 then
	--    cocomisi := null;
	--	pecomisi := null;
	--END IF;
END LOOP;
err := generar ( mesaño, ptipo );
RETURN ( 1 );
EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line (' Se ha producido un error ' || sqlerrm);
   return ( -1 );
END PENDIENTES_DE_COBRO;
--*******************************************************************
--************* ANULADOS EMITIDOS EN EL EJERCICIO *******************
--*******************************************************************
FUNCTION ANULADOS_EMITIDOS_EJERCICIO ( pramo IN NUMBER , pmodali IN NUMBER
                   ,ptipseg IN NUMBER ,pcolect IN NUMBER
				   ,mesaño IN DATE
  			       ,ptipo IN NUMBER) RETURN NUMBER is
    err NUMBER;
    Cursor recibos
	 is SELECT /*+ rule */ recibos.nrecibo
  	  		 , seguros.sseguro  	  		 , movrecibo.FMOVINI
           	 , movrecibo.fmovfin			 , movrecibo.CESTREC
			 , movrecibo.CESTANT			 , seguros.CRAMO
			 , SEGUROS.CMODALI 			     , seguros.ctipseg
			 , SEGUROS.CCOLECT 			     , RECIBOS.CBANCAR
			 , VDETRECIBOS.IPRINET			 , VDETRECIBOS.IIPS
			 , VDETRECIBOS.ICONSOR			 , VDETRECIBOS.ICOMBRU
			 , VDETRECIBOS.ITOTALR
			 , PRODUCTOS.CCALCOM
	   FROM movrecibo, seguros, recibos, productos, vdetrecibos
      WHERE movrecibo.nrecibo = recibos.nrecibo
	    AND recibos.sseguro = seguros.sseguro
		AND seguros.cramo = productos.cramo
		AND seguros.cmodali = productos.cmodali
		AND seguros.ctipseg = productos.ctipseg
		AND seguros.ccolect = productos.ccolect
		AND productos.cramo = pramo
		AND productos.cmodali = DECODE(nvl(pmodali,0),0,productos.cmodali,pmodali)
		AND productos.ctipseg = DECODE(nvl(ptipseg,0),0,productos.ctipseg,ptipseg)
		AND productos.ccolect = DECODE(nvl(pcolect,0),0,productos.ccolect,pcolect)
		AND recibos.nrecibo = vdetrecibos.NRECIBO
		AND TO_CHAR(recibos.femisio,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
		AND movrecibo.CESTREC = 2
		AND TO_CHAR(MESAÑO,'YYYY') = TO_CHAR(RECIBOS.FEMISIO,'YYYY')
    	AND FMOVFIN IS NULL
		ORDER BY seguros.sseguro ,movrecibo.nrecibo, smovrec;
BEGIN
-- Generamos una cadena con las situaciones del recibo
reprecibo := -1 ;
ramo      := PRAMO;
modalidad := PMODALI;
tipseg    := PTIPSEG;
colect    := PCOLECT;
FOR registro IN recibos LOOP
   	    recibo    := REGISTRO.NRECIBO;
	    ramo      := PRAMO;
	    modalidad := PMODALI;
	    tipseg    := PTIPSEG;
        colect    := PCOLECT;
        cadena  := cadena || to_char(registro.cestrec,'FM9');
        cobrado_anulado := 1;
	 	coprinet := nvl(coprinet,0) + nvl(registro.iprinet,0);
        cosobrep := nvl(cosobrep,0) + 0;
		codeducc := nvl(codeducc,0) + 0;
		cototpri := coprinet + cosobrep - codeducc;
		coimpues := nvl(coimpues,0) + nvl(registro.iips,0);
		coconsor := nvl(coconsor,0) + nvl(registro.iconsor,0);
		cocomisi := nvl(cocomisi,0) + nvl(registro.icombru,0);
		cototal  := nvl(cototal,0)  + nvl(registro.itotalr,0);
		reprecibo := registro.nrecibo;
		cadena := null;
		--XT
		--IF registro.ccalcom = 1 then
		--	    cocomisi := null;
		--		pecomisi := null;
		--END IF;
END LOOP;
err := generar ( mesaño, ptipo );
RETURN ( 1 );
EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line (' Se ha producido un error ' || sqlerrm);
   return ( -1 );
END ANULADOS_EMITIDOS_EJERCICIO;
--*******************************************************************
--************* ANULADOS EMITIDOS EN EJERCICIOS ANTERIORES***********
--*******************************************************************
FUNCTION ANULADOS_EMITIDOS_ANTERIORES ( pramo IN NUMBER , pmodali IN NUMBER
                   ,ptipseg IN NUMBER ,pcolect IN NUMBER
				   ,mesaño IN DATE
  			       ,ptipo IN NUMBER) RETURN NUMBER is
    err NUMBER;
    Cursor recibos
	 is SELECT /*+ rule */ recibos.nrecibo
  	  		 , seguros.sseguro  	  		 , movrecibo.FMOVINI
           	 , movrecibo.fmovfin			 , movrecibo.CESTREC
			 , movrecibo.CESTANT			 , seguros.CRAMO
			 , SEGUROS.CMODALI 			     , seguros.ctipseg
			 , SEGUROS.CCOLECT 			     , RECIBOS.CBANCAR
			 , VDETRECIBOS.IPRINET			 , VDETRECIBOS.IIPS
			 , VDETRECIBOS.ICONSOR			 , VDETRECIBOS.ICOMBRU
			 , VDETRECIBOS.ITOTALR
			 , PRODUCTOS.CCALCOM
	   FROM movrecibo, seguros, recibos, productos, vdetrecibos
      WHERE movrecibo.nrecibo = recibos.nrecibo
	    AND recibos.sseguro = seguros.sseguro
		AND seguros.cramo = productos.cramo
		AND seguros.cmodali = productos.cmodali
		AND seguros.ctipseg = productos.ctipseg
		AND seguros.ccolect = productos.ccolect
		AND productos.cramo = pramo
		AND productos.cmodali = DECODE(nvl(pmodali,0),0,productos.cmodali,pmodali)
		AND productos.ctipseg = DECODE(nvl(ptipseg,0),0,productos.ctipseg,ptipseg)
		AND productos.ccolect = DECODE(nvl(pcolect,0),0,productos.ccolect,pcolect)
		AND recibos.nrecibo = vdetrecibos.NRECIBO
		AND TO_CHAR(MOVRECIBO.FMOVINI,'yyyymm') = TO_CHAR(mesaño,'yyyymm')
		AND movrecibo.CESTREC = 2
		AND TO_CHAR(MESAÑO,'YYYY') > ( SELECT TO_CHAR(FEMISIO,'YYYY')
		                               FROM RECIBOS R
									   WHERE R.NRECIBO = VDETRECIBOS.NRECIBO )
    	AND FMOVFIN IS NULL
		ORDER BY seguros.sseguro ,movrecibo.nrecibo, smovrec;
BEGIN
-- Generamos una cadena con las situaciones del recibo
reprecibo := -1 ;
ramo      := PRAMO;
modalidad := PMODALI;
tipseg    := PTIPSEG;
colect    := PCOLECT;
FOR registro IN recibos LOOP
   	    recibo    := REGISTRO.NRECIBO;
	    ramo      := PRAMO;
	    modalidad := PMODALI;
	    tipseg    := PTIPSEG;
        colect    := PCOLECT;
        cadena  := cadena || to_char(registro.cestrec,'FM9');
        cobrado_anulado := 1;
	 	coprinet := nvl(coprinet,0) + nvl(registro.iprinet,0);
        cosobrep := nvl(cosobrep,0) + 0;
		codeducc := nvl(codeducc,0) + 0;
		cototpri := coprinet + cosobrep - codeducc;
		coimpues := nvl(coimpues,0) + nvl(registro.iips,0);
		coconsor := nvl(coconsor,0) + nvl(registro.iconsor,0);
		cocomisi := nvl(cocomisi,0) + nvl(registro.icombru,0);
		cototal  := nvl(cototal,0)  + nvl(registro.itotalr,0);
		reprecibo := registro.nrecibo;
		cadena := null;
		--XT
		--IF registro.ccalcom = 1 then
	    --   cocomisi := null;
		--   pecomisi := null;
		--END IF;
END LOOP;
err := generar ( mesaño, ptipo );
RETURN ( 1 );
EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line (' Se ha producido un error ' || sqlerrm);
   return ( -1 );
END ANULADOS_EMITIDOS_ANTERIORES;
END pk_audrecibos; 

/

  GRANT EXECUTE ON "AXIS"."PK_AUDRECIBOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_AUDRECIBOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_AUDRECIBOS" TO "PROGRAMADORESCSI";
