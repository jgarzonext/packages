--------------------------------------------------------
--  DDL for Package Body PK_CUMULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_CUMULOS" AS
FUNCTION IMPORTDIVISA(MONEDA IN VARCHAR2, IMPORT IN NUMBER) RETURN NUMBER IS
	ImpRetorn NUMBER;
BEGIN
	IF MONEDA = 'PTA' OR MONEDA = '???' THEN
		ImpRetorn := ROUND(IMPORT);	 ----Sense decimals
	ELSIF MONEDA = 'EUR' THEN
		ImpRetorn := ROUND(IMPORT*100); ----Amb decimals
	END IF;
	RETURN ImpRetorn;
END IMPORTDIVISA;
----
PROCEDURE Inicializa IS
BEGIN
	IF NOT seg_cv%ISOPEN AND SORTIR=FALSE THEN
		open seg_cv;
		actual.subproducto := 0;
		actual.CMONEDA := '???';
		actual.compania := 'C569';
		actual.vsperson1:= 0;
		actual.vsperson2:=0;
		actual.cperhos1:= 0;
		actual.cperhos2:= 0;
		actual.riesgocont:= 0;
		actual.riessol:= 0;
		actual.cancont:= 0;
	END IF;
	acumulat.subproducto:= actual.subproducto;
	acumulat.CMONEDA:= actual.CMONEDA;
	acumulat.compania := actual.compania;
	acumulat.vsperson1:=actual.vsperson1;
	acumulat.vsperson2:=actual.vsperson2;
	acumulat.cperhos1:=actual.cperhos1;
	acumulat.cperhos2:=actual.cperhos2;
	acumulat.riesgocont:=actual.riesgocont;
	acumulat.riessol:=actual.riessol;
	acumulat.cancont:=actual.cancont;
	----
	IF SORTIR = TRUE THEN
		ACABAR := TRUE;
	END IF;
	----
EXCEPTION
	WHEN OTHERS THEN
		PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'ERROR INICIALITZANT: '||SQLERRM);
		SORTIR := TRUE;
END Inicializa;
PROCEDURE lee IS
	CLlegir BOOLEAN := TRUE;
	Nou BOOLEAN := TRUE;
BEGIN
	----
	Inicializa;
	----
	----
	WHILE CLlegir AND SORTIR = FALSE LOOP
		FETCH seg_cv INTO RegPila;
		IF seg_cv%NOTFOUND THEN
			------
			SORTIR := TRUE;
			CLlegir := FALSE;
			------RegPila.sseguro := -1;
			close seg_cv;
		ELSE
		PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,TO_CHAR(RegPila.sseguro));
			Tratamiento;
			IF seg_cv%rowcount = 1 then  ----La primera vegada.
		PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'Primer');
				acumulat.subproducto := actual.subproducto;
				acumulat.cperhos1 := actual.cperhos1;
				acumulat.cperhos2 := actual.cperhos2;
				acumulat.compania := actual.compania;
				acumulat.cmoneda  := actual.cmoneda;
				acumulat.riesgocont  := Actual.riesgocont;
				acumulat.cancont := Actual.cancont;
			ELSIF acumulat.subproducto <> actual.subproducto OR
				acumulat.CMONEDA <> actual.CMONEDA OR
				acumulat.compania <> actual.compania OR
				acumulat.cperhos1 <> actual.cperhos1 OR
				NVL(acumulat.cperhos2,0) <> NVL(actual.cperhos2,0) THEN
		PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'Diferent');
					CLlegir := FALSE;
			ELSE
				Acumulat.riesgocont  := Actual.riesgocont + Acumulat.riesgocont;
		PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'Acumulem: '||TO_CHAR(Actual.riesgocont));
		PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'Nou Total: '||TO_CHAR(Acumulat.riesgocont));
				Acumulat.cancont := Actual.cancont + Acumulat.cancont;
			END IF;
		END IF;
	END LOOP;
	Sortida.subproducto := Acumulat.subproducto;
	Sortida.CMONEDA	    := Acumulat.CMONEDA;
	Sortida.compania	:= Acumulat.compania;
	Sortida.vsperson1   := Acumulat.vsperson1;
	Sortida.vsperson2   := Acumulat.vsperson2;
	Sortida.cperhos1    := Acumulat.cperhos1;
	Sortida.cperhos2    := Acumulat.cperhos2;
	Sortida.riesgocont  := Importdivisa(Acumulat.CMONEDA,Acumulat.riesgocont);
	Sortida.riessol	    := Importdivisa(Acumulat.CMONEDA,Acumulat.riessol);
	Sortida.cancont	    := Acumulat.cancont;
EXCEPTION
   WHEN NoEnviar THEN
   		NULL;
   	WHEN OTHERS THEN
		PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'ERROR: '||SQLERRM);
END lee;
-------
PROCEDURE tratamiento IS
	vcompa varchar2(4);
BEGIN
	-- Datos de Seguros
	SELECT sseguro, cramo, cmodali, ctipseg, ccolect, npoliza, cidioma, fefecto,
		fanulac, DECODE(fanulac,  NULL, 'A', 'V'),
	    fvencim, DECODE(cforpag, 1,  'A',
								 2,  'S',
								 3,  'C',
							  	 4,  'T',
								 6,  'B',
								12,  'M',
								 0,  'U'
				  ),
		cbancar
	INTO RegSeg
	FROM seguros
	WHERE sseguro = RegPila.sseguro;
	Actual.CMONEDA:= RegPila.cmoneda;
	Actual.vsperson1:= RegPila.sperson1;
	Actual.vsperson2:= RegPila.sperson2;
	Actual.riessol:= 0;
	IF RegPila.Importes IN (-999, -9999, -99999) THEN
		IF RegPila.Motivo in (1,2) THEN ----Suposem que per pòlissa només hi ha un suplement
										----econòmic per dia.
			actual.cancont := 0;
			DECLARE
				importe      NUMBER;
				ult_importe  NUMBER;
				ant_importe  NUMBER;
				ult_mov      NUMBER;
				ant_mov      NUMBER;
			BEGIN
				SELECT icapital, nmovimi
				INTO ult_importe, ult_mov
				FROM garanseg
				WHERE cgarant = 1
				AND sseguro = RegPila.sseguro
				AND nmovimi = (SELECT MAX(nmovimi)
				   		   	 FROM garanseg
							 WHERE cgarant = 1
							 AND sseguro = RegPila.sseguro);
				SELECT icapital, nmovimi
				INTO ant_importe, ant_mov
				FROM garanseg
				WHERE cgarant = 1
				AND sseguro = RegPila.sseguro
				AND nmovimi = (SELECT MAX(nmovimi)
				   		   	 FROM garanseg
							 WHERE cgarant = 1
							 AND nmovimi < ult_mov
							 AND sseguro = RegPila.sseguro);
				Actual.riesgocont := ult_importe - ant_importe;
			EXCEPTION
				WHEN OTHERS THEN
					Actual.riesgocont := 0;
			END;
		ELSIF RegPila.Motivo = 3 THEN
			actual.cancont := 0;
			DECLARE
				importe      NUMBER;
				ult_importe  NUMBER;
				ant_importe  NUMBER;
				ult_mov      NUMBER;
				ant_mov      NUMBER;
			BEGIN
				SELECT icapital*-1, nmovimi
				INTO ult_importe, ult_mov
				FROM garanseg
				WHERE cgarant = 1
				AND sseguro = RegPila.sseguro
				AND nmovimi = (SELECT MAX(nmovimi)
								FROM garanseg
								WHERE cgarant = 1
								AND sseguro = RegPila.sseguro);
				Actual.riesgocont := ult_importe;
			EXCEPTION
				WHEN OTHERS THEN
					Actual.riesgocont := 0;
			END;
		END IF;
	ELSIF RegPila.Importes <> 0 THEN
		actual.cancont := 0;
		Actual.riesgocont := RegPila.Importes;
	ELSIF RegPila.Unidades IS NOT NULL OR RegPila.Unidades <> 0 THEN
		Actual.cancont:= RegPila.Unidades;
		Actual.riesgocont := 0;
	ELSE
		Actual.riesgocont := 0;
		Actual.cancont:= 0;
	END IF;
	-- Datos de Seguros
	SELECT sseguro, cramo, cmodali, ctipseg, ccolect, npoliza, cidioma, fefecto,
		fanulac, DECODE(fanulac,  NULL, 'A', 'V'),
	    fvencim, DECODE(cforpag, 1,  'A',
								 2,  'S',
								 3,  'C',
							  	 4,  'T',
								 6,  'B',
								12,  'M',
								 0,  'U'
				  ),
		cbancar
	INTO RegSeg
	FROM seguros
	WHERE sseguro = RegPila.sseguro;
	-- Lectura del numero de certificado
	BEGIN
		SELECT LPAD(polissa_ini, 13, '0')
		INTO num_certificado
		FROM cnvpolizas
		WHERE npoliza = RegSeg.npoliza;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			num_certificado := '0000000000000';
		WHEN OTHERS THEN
          p_tab_error(f_sysdate,  F_USER,  'Pk_Cumulos.Tratamiento',1,'Error no controlado',
          '(CnvPolizas) 1sseguro = '|| TO_CHAR(RegSeg.sseguro)||' - '||sqlerrm);
	END;
  if RegPila.cmoneda = 'PTA' or RegPila.CMONEDA = '???' then
    -- Determinar código    de subproducto
    BEGIN
      SELECT producte_mu, nvl(numpol, 0), cia
	  INTO subproducto, RegSeg.npoliza, vcompa
	  FROM cnvproductos
	  WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin, 999999999999999)
	     AND cramo   = RegSeg.cramo
	     AND cmodal  = RegSeg.cmodali
         AND ctipseg = RegSeg.ctipseg
         AND ccolect = RegSeg.ccolect;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    subproducto := 0;
      WHEN OTHERS THEN
          p_tab_error(f_sysdate,  F_USER,  'Pk_Cumulos.Tratamiento',2,'Error no controlado',
          '(CnvProductos 1) sseguro = '|| TO_CHAR(RegSeg.sseguro)||' - '||sqlerrm);
    END;
  elsif RegPila.CMONEDA = 'EUR' then
    -- Determinar código de subproducto
    BEGIN
      SELECT producte_mu, nvl(numpol, 0), cia
      INTO subproducto, RegSeg.npoliza, vcompa
      FROM cnvproductos
      WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin, 999999999999999)
      AND cramo_E   = RegSeg.cramo
      AND cmodali_E = RegSeg.cmodali
      AND ctipseg_E = RegSeg.ctipseg
      AND ccolect_E = RegSeg.ccolect;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    subproducto := 0;
      WHEN OTHERS THEN
          p_tab_error(f_sysdate,  F_USER,  'Pk_Cumulos.Tratamiento',3,'Error no controlado',
          '(CnvProductos 1) sseguro = '|| TO_CHAR(RegSeg.sseguro)||' - '||sqlerrm);
    END;
  end if;
  Actual.subproducto:= subproducto;
  Actual.compania := 'C569';
/*******
  IF subproducto = 91 THEN
	Actual.compania := 'G038';
  ELSIF subproducto = 92 THEN
	Actual.compania := 'G069';
  ELSE
	Actual.compania := 'C569';
  END IF;
************/
  -- Datos de Personas_ulk
  BEGIN
    SELECT sperson, cperhos, cnifhos
	  INTO personaULK
	  FROM personas_ulk
	 WHERE sperson = RegPila.Sperson1;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	    personaULK.sperson := 0;
	    personaULK.cperhos := 0;
	    personaULK.cnifhos := NULL;
  END;
  Actual.cperhos1:= personaULK.cperhos;
  ----Mentre no estiguin ben migrats.
  declare
    aux varchar2(1);
  begin
    aux := substr(personaULK.cnifhos,1,1);
	if aux='D' then
	  personaULK.cnifhos:=aux||lpad(trim(substr(personaULK.cnifhos,2,10)),10,'0')||'00';
    end if;
  end;
  Actual.vsperson1:= 0;
  IF RegPila.Sperson2 <> 0 THEN
	  -- Datos de Personas_ulk 2
	  BEGIN
	    SELECT sperson, cperhos, cnifhos
		  INTO personaULK2
		  FROM personas_ulk
		 WHERE sperson = RegPila.Sperson2;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    personaULK2.sperson := 0;
		    personaULK2.cperhos := 0;
		    personaULK2.cnifhos := NULL;
	  WHEN OTHERS THEN
          p_tab_error(f_sysdate,  F_USER,  'Pk_Cumulos.Tratamiento',4,'Error no controlado',
          '(PersonaULK2) 1sseguro = '|| TO_CHAR(RegSeg.sseguro)||' - '||sqlerrm);
	  END;
	  Actual.cperhos2:= personaULK2.cperhos;
	  ----Mentre no estiguin ben migrats.
	  declare
	    aux varchar2(1);
	  begin
	    aux := substr(personaULK2.cnifhos,1,1);
		if aux='D' then
		  personaULK2.cnifhos:=aux||lpad(trim(substr(personaULK2.cnifhos,2,10)),10,'0')||'00';
	    end if;
	  end;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
          p_tab_error(f_sysdate,  F_USER,  'Pk_Cumulos.Tratamiento',5,'Error no controlado',
          '(tratamiento) sseguro = '|| TO_CHAR(RegPila.sseguro)||' - '||sqlerrm);
     PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'TRATAMIENTO: '||SQLERRM);
END tratamiento;
PROCEDURE close_seg (seg_cv IN OUT if_seguros.SegCurTyp) AS
BEGIN
  CLOSE seg_cv;
END close_seg;
PROCEDURE marcar_pila IS
BEGIN
     UPDATE pila_cumulos pc SET
	    fecha_envio = sysdate
	  WHERE fecha_envio IS NULL
        AND (pk_autom.mensaje = 'FSE0700'
		AND NOT EXISTS (SELECT sperson
		 	          FROM asegurados
				     WHERE sseguro = pc.sseguro
					   AND norden = 2)
			     )
	  ;
     UPDATE pila_cumulos pc SET
	    fecha_envio = sysdate
	  WHERE fecha_envio IS NULL
        AND (pk_autom.mensaje = 'FSE0750'
		AND EXISTS (SELECT sperson
		 	          FROM asegurados
				     WHERE sseguro = pc.sseguro
					   AND norden = 2)
			     )
	  ;
	COMMIT;
END marcar_pila;
FUNCTION Fin RETURN BOOLEAN IS
   fins   BOOLEAN:=FALSE;
BEGIN
   IF ACABAR = TRUE THEN
     fins := TRUE;
   END IF;
   RETURN fins;
EXCEPTION
  WHEN OTHERS THEN
      p_tab_error(f_sysdate,  F_USER,  'Pk_Cumulos.Enviar',1,'Error no controlado',
      '(fin) sseguro = '|| TO_CHAR(RegPila.sseguro)||' - '||sqlerrm);
END Fin;
FUNCTION Enviar RETURN BOOLEAN IS
	Retorn   BOOLEAN:=FALSE;
BEGIN
	IF sortida.cancont IS NULL OR sortida.cancont = 0 THEN
		IF sortida.Riesgocont < 0 THEN
		    AD := 'D';
			sortida.Riesgocont := sortida.Riesgocont * -1;
		ELSE
		    AD := 'A';
		END IF;
	ELSE
		IF sortida.cancont < 0 THEN
		    AD := 'D';
			sortida.cancont := sortida.cancont * -1;
		ELSE
		    AD := 'A';
		END IF;
	END IF;
IF ACABAR= FALSE  THEN
PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'SUBPRODUCTO: '||TO_CHAR(SORTIDA.SUBPRODUCTO));
PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'CPERHOS1: '||TO_CHAR(SORTIDA.CPERHOS1));
PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'CPERHOS2: '||TO_CHAR(SORTIDA.CPERHOS2));
PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'RIESGOCONT: '||TO_CHAR(sortida.riesgocont));
PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'CANCONT: '||TO_CHAR(sortida.cancont));
END IF;
	IF ACABAR= FALSE AND (sortida.riesgocont <> 0 OR sortida.cancont <> 0) THEN
PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'ENVIAR');
		Retorn := TRUE;
	ELSE
IF ACABAR = FALSE THEN
PK_ENV_COMU.TRAZA(PK_AUTOM.trazas, pk_autom.depurar,'NO ENVIAR');
END IF;
	END IF;
	RETURN Retorn;
EXCEPTION
	WHEN OTHERS THEN
          p_tab_error(f_sysdate,  F_USER,  'Pk_Cumulos.Enviar',2,'Error no controlado',
          '(Enviar) sseguro = '|| TO_CHAR(RegPila.sseguro)||' - '||sqlerrm);
		RETURN TRUE;
END Enviar;
END pk_cumulos;

/

  GRANT EXECUTE ON "AXIS"."PK_CUMULOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CUMULOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CUMULOS" TO "PROGRAMADORESCSI";
