--------------------------------------------------------
--  DDL for Function F_PREVRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PREVRECIBO" (pprimany IN NUMBER, pproppol IN NUMBER, psproces IN
	NUMBER, psseguro IN NUMBER, pcmovimi IN NUMBER, pnmovimi IN NUMBER,
	piprinet OUT NUMBER, pirecext	OUT NUMBER, piconsor OUT NUMBER, pireccon
	OUT NUMBER, piips OUT NUMBER, pidgs OUT NUMBER, piarbitr OUT NUMBER,
	pifng OUT NUMBER, pirecfra OUT NUMBER, pidtotec OUT NUMBER, pidtocom
	OUT NUMBER, picombru OUT NUMBER, picomret OUT NUMBER, pidtoom OUT
	NUMBER, pipridev OUT NUMBER, pitotpri OUT NUMBER, pitotdto OUT NUMBER,
	pitotcon OUT NUMBER, pitotimp OUT NUMBER, pitotalr OUT NUMBER, pnriesgo
	IN NUMBER DEFAULT NULL) RETURN number authid current_user IS
-- ALLIBADM. Fa un previ dels detalls del rebut
-- abans de crear-los fisicament. Crida a la funció f_detrecibo amb el pmodo
-- 'P' (Proves)  o 'N'. Abans de cridar a aquesta funció, s' ha d' haver grabat un
-- número de procés.
--
--
--   	Si es extorno devuelve 1er recibo con importes negativos
--  	Se suman importes en los casos de coaseguro (decode...)
--
      --  Se mira el min(nrecibo) que no esté anulado a la fecha
	-- de efecto del movimiento
--  Reduir el nombre d'accessos per millorar rendiment.
--   Para encontrar el recibo generado por ese movimiento, se mirará el estado
--			    del recibo a fecha efecto del movimiento del seguro
--			    si ésta es mayor que la fecha de hoy,sino se mirará a fecha efecto del movimiento,
--			    Cogeremos el mínimo recibo asociado al movimiento de la
--			    póliza para evitar problemas con los recibos fraccionados.
error		NUMBER;
xnrecibo	NUMBER;
xfvencim	DATE;
xtipomovim	NUMBER;
xcagente	NUMBER;
xcforpag	NUMBER;
xfcaranu	DATE;
xfefecto	DATE;
xxfvencim	DATE;
dummy		NUMBER;
xnrecibo1	NUMBER;
xffecmov	DATE;
BEGIN
	BEGIN
	   SELECT cagente, fefecto, NVL(fvencim, fefecto), fcaranu, NVL(cforpag, 1)
    	   INTO xcagente, xfefecto, xfvencim, xfcaranu, xcforpag
	   FROM seguros
	   WHERE sseguro = psseguro;
	   EXCEPTION
	     WHEN no_data_found THEN
		RETURN 101903;		-- Seguro no encontrado en la tabla SEGUROS
	     WHEN others THEN
		RETURN 101919;		-- Error al llegir de SEGUROS
	END;
	IF pprimany = 0 THEN	-- 1 Rebut
	-- Calculamos la fecha de efecto del movimiento
	-- Elegimos la fecha adecuada
	-- Comparamos la fecha efecto, con la fecha de emisión
	--  con la fecha de hoy, y cogemos la más grande.
	   BEGIN
		SELECT greatest(fefecto, femisio, sysdate)
		INTO xffecmov
		FROM MOVSEGURO
		WHERE sseguro = psseguro
		  AND nmovimi = pnmovimi;
	   EXCEPTION
		WHEN OTHERS THEN
			RETURN 104349;  -- Error al leer en MOVSEGURO
	   END;
	-- Se mira el min(nrecibo) que no esté anulado a la fecha
	-- de efecto del movimiento
	   BEGIN
/*
		SELECT min(nrecibo)
	  	INTO xnrecibo
	  	FROM recibos
	  	WHERE sseguro = psseguro AND
			nmovimi = pnmovimi AND
			(nriesgo = pnriesgo OR pnriesgo is NULL)
	     	AND f_cestrec(nrecibo,xffecmov) <> 2;
*/
 -- Buscamos el mínimo que su último movimiento no sea el de anulado
                SELECT min(m.nrecibo)
                  INTO xnrecibo
                  FROM movrecibo m, recibos r
                 WHERE sseguro = psseguro
                   AND nmovimi = pnmovimi
                   AND m.nrecibo = r.nrecibo
		   AND (nriesgo = pnriesgo OR pnriesgo is NULL)
                   AND m.fmovfin is null
                   AND m.cestrec <> 2;
	   EXCEPTION
	  	WHEN others THEN
	    	   RETURN 102367;	-- Error al llegir de RECIBOS
	   END;
	   BEGIN
	   	SELECT
		  DECODE(r.ctipcoa,1,v.iprinet+v.icednet, v.iprinet)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.irecext+v.icedrex, v.irecext)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.iconsor+v.icedcon, v.iconsor)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.ireccon+v.icedrco, v.ireccon)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.iips+v.icedips, v.iips)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.idgs+v.iceddgs, v.idgs)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.iarbitr+v.icedarb, v.iarbitr)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.ifng+v.icedfng, v.ifng)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.irecfra+v.icedrfr, v.irecfra)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.idtotec+v.iceddte, v.idtotec)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.idtocom+v.iceddco, v.idtocom)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.icombru+v.icedcbr, v.icombru)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.icomret+v.icedcrt, v.icomret)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.idtocom+v.iceddom, v.idtocom)*DECODE(r.ctiprec,9,-1,1),
		  DECODE(r.ctipcoa,1,v.ipridev+v.icedpdv, v.ipridev)*DECODE(r.ctiprec,9,-1,1),
		  itotpri*DECODE(r.ctiprec,9,-1,1),
		  itotdto*DECODE(r.ctiprec,9,-1,1),
		  itotcon*DECODE(r.ctiprec,9,-1,1),
		  itotimp*DECODE(r.ctiprec,9,-1,1),
		  itotalr*DECODE(r.ctiprec,9,-1,1)
	    	INTO piprinet, pirecext, piconsor, pireccon, piips, pidgs, piarbitr,
		 pifng, pirecfra, pidtotec, pidtocom, picombru, picomret, pidtoom,
		 pipridev, pitotpri, pitotdto, pitotcon, pitotimp, pitotalr
	    	FROM recibos r,vdetrecibos v
		WHERE r.nrecibo=xnrecibo
		 AND v.nrecibo=r.nrecibo;
	   EXCEPTION
	 	WHEN no_data_found THEN
			RETURN 103936;		-- Rebut no trobat a VDETRECIBOS
	    	WHEN others THEN
			RETURN 103920;		-- Error al llegir de VDETRECIBOS
	   END;
	   RETURN 0;
	ELSIF pprimany = 1 THEN		-- Rebut anual
	   BEGIN
	  	SELECT NVL(max(nrecibo), 0)
	  	INTO xnrecibo
	  	FROM reciboscar
	  	WHERE sproces = psproces;
	  	xnrecibo1 := xnrecibo + 1;
	   EXCEPTION
	  	WHEN others THEN
		   xnrecibo1 := 1;
	   END;
	   xxfvencim := add_months(xfefecto, 12);
	   IF xxfvencim > xfvencim THEN
	  	xxfvencim := xfvencim;
	   END IF;
	   error := f_insrecibo(psseguro, xcagente, sysdate, xfefecto, xxfvencim,
		0, null, null, null, 0, pnriesgo, xnrecibo1, 'N', psproces,
		pcmovimi, pnmovimi, sysdate);
	   IF error = 0 THEN
	  	xtipomovim := 0;		-- Nova producció
	  	xfcaranu := NVL(xfcaranu, xxfvencim);
	  	error := f_detrecibo(psproces, psseguro, xnrecibo1, xtipomovim, 'N',
		   1, sysdate, xfefecto, xxfvencim, xfcaranu, NULL, pnriesgo,
		   pnmovimi, pproppol, dummy);
	  	IF error = 0 THEN
		   BEGIN
		     SELECT DECODE(r.ctipcoa,1,v.iprinet+v.icednet, v.iprinet),
			DECODE(r.ctipcoa,1,v.irecext+v.icedrex, v.irecext),
			DECODE(r.ctipcoa,1,v.iconsor+v.icedcon, v.iconsor),
			DECODE(r.ctipcoa,1,v.ireccon+v.icedrco, v.ireccon),
			DECODE(r.ctipcoa,1,v.iips+v.icedips, v.iips),
			DECODE(r.ctipcoa,1,v.idgs+v.iceddgs, v.idgs),
			DECODE(r.ctipcoa,1,v.iarbitr+v.icedarb, v.iarbitr),
			DECODE(r.ctipcoa,1,v.ifng+v.icedfng, v.ifng),
			DECODE(r.ctipcoa,1,v.irecfra+v.icedrfr, v.irecfra),
			DECODE(r.ctipcoa,1,v.idtotec+v.iceddte, v.idtotec),
			DECODE(r.ctipcoa,1,v.idtocom+v.iceddco, v.idtocom),
			DECODE(r.ctipcoa,1,v.icombru+v.icedcbr, v.icombru),
			DECODE(r.ctipcoa,1,v.icomret+v.icedcrt, v.icomret),
			DECODE(r.ctipcoa,1,v.idtocom+v.iceddom, v.idtocom),
			DECODE(r.ctipcoa,1,v.ipridev+v.icedpdv, v.ipridev),
			itotpri, itotdto, itotcon, itotimp, itotalr
		      INTO piprinet, pirecext, piconsor, pireccon, piips, pidgs, piarbitr,
			pifng, pirecfra, pidtotec, pidtocom, picombru, picomret, pidtoom,
			pipridev, pitotpri, pitotdto, pitotcon, pitotimp, pitotalr
		      FROM reciboscar r, vdetrecibosCAR v
		      WHERE r.sproces = psproces
			AND r.nrecibo = xnrecibo1
			AND v.nrecibo = r.nrecibo
			AND v.sproces = r.sproces;
		  EXCEPTION
			WHEN no_data_found THEN
			   RETURN 104440;	-- Rebut no trobat a VDETRECIBOSCAR
			WHEN others THEN
			   RETURN 104441;	-- Error al llegir de VDETRECIBOSCAR
		  END;
		  RETURN 0;
	  	ELSE
		   RETURN error;
	  	END IF;
	   ELSE
	  	RETURN error;
	   END IF;
	ELSE
	   RETURN 101901;		-- Pas de paràmetres incorrecte a la funció
	END IF;
END;

/

  GRANT EXECUTE ON "AXIS"."F_PREVRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PREVRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PREVRECIBO" TO "PROGRAMADORESCSI";
