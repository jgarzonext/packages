--------------------------------------------------------
--  DDL for Function F_RETENSIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_RETENSIN" 
  (PSSEGURO NUMBER,
   PNMOVIMI NUMBER,
   PNSINIES NUMBER,
   PFEFECTO DATE,
   PFRESCAT DATE,
   PCTIPRES NUMBER,
   PIMPRES  NUMBER,
   IRETENCION OUT NUMBER,
   PFRESCAT2 DATE DEFAULT NULL,
   PFMUERTE DATE DEFAULT NULL)
RETURN NUMBER authid current_user IS
  R   NUMBER;	  		 -- Rendimiento total antes de reducciones
  RN  NUMBER;	  		 -- Rendimiento total antes de reducciones
  Rt  NUMBER;			 -- Rendimiento asociado a la prima
  Rtr NUMBER;			 -- Rendimiento reducido
  Rtra NUMBER;			 -- Rendimiento reducido por antigüedad
  PASE NUMBER;
  valores_rescate_dia NUMBER;
  sumRt NUMBER;			 -- Sumatorio de rendimientos antes de reducciones
  sumPa NUMBER;			 -- Sumatorio de prestaciones pagadas
  sumRa NUMBER;			 -- Sumatorio de rendimientos asociados a prestaciones
  Rbruto NUMBER;		 -- Suma de rendimientos reducidos
  red    NUMBER;		 -- Porcentaje de reducción
  ret    NUMBER;		 -- Porcentaje de retención
  resto  NUMBER;
  PrimasAportadas NUMBER;
  rescate_pend NUMBER:=pimpres;
  rescate_acum NUMBER;
  sumprim      NUMBER;
  kyt          NUMBER;
  kat          NUMBER;
  SumatorioBruto   NUMBER;
  SumatorioBruto_1 NUMBER;
  sumando          NUMBER;
  sumaRentas       NUMBER;
  movimiento_ult NUMBER;
  num_orden      NUMBER;
  seqresc        NUMBER;
  fcontabresc    DATE;
  rescates       NUMBER;
  ramo		NUMBER;
  modalidad	NUMBER;
  CAGRPRO	NUMBER;
BEGIN
   PASE := 1;
   -- Determinación del valor del rendimiento antes de reducciones
   SELECT NVL(SUM(ipricons), 0)+NVL(SUM(ircm), 0), NVL(SUM(ircm), 0)
   INTO sumPa, sumRa
   FROM PRIMAS_CONSUMIDAS
   WHERE sseguro = psseguro
   AND fecha < pfrescat;
   sumprim := 0;
   SumatorioBruto := 0;
   SumatorioBruto_1 := 0;
   -- Cálculo del denominador para la determinación del rendimiento a nivel prima
   PASE := 2;
   FOR r IN (SELECT iprima - Prima_Consumida(psseguro, /*pnmovimi*/ nnumlin, fvalmov) prima, fvalmov
             FROM primas_aportadas
             WHERE sseguro = psseguro
			   AND fvalmov <= pfrescat)
   LOOP
       sumprim := sumprim + r.prima * (pfrescat - r.fvalmov)/365;
   END LOOP;
   --Cálculo de PrimasAportadas
   SELECT NVL(SUM(iprima), 0)
     INTO PrimasAportadas
     FROM primas_aportadas
    WHERE sseguro = psseguro
      AND fvalmov < pfrescat;
   PASE := 3;
   --Cálculo de Valores de Rescate
   SELECT NVL(SUM(imovimi), 0)
     INTO valores_rescate_dia
     FROM CTASEGURO
    WHERE sseguro = psseguro
    AND cmovimi IN (33,34)
    AND fvalmov BETWEEN Primera_Hora(pfrescat) AND Ultima_Hora(pfrescat);
begin
   PASE := 4;
   --Cálculo de Rentas
   SELECT NVL(SUM(NVL(isinret,0)-NVL(ibase,0)), 0)
     INTO sumaRentas
     FROM PAGOSRENTA
    WHERE sseguro = psseguro
    AND ffecefe <= Ultima_Hora(pfrescat);
exception
    when others then
      RETURN ( -1 );
end;
   PASE := 5;
   -- Rendimiento total antes de reducciones
   SELECT cramo, cmodali, CAGRPRO
     INTO ramo, modalidad, CAGRPRO
	 FROM SEGUROS
	WHERE sseguro = psseguro;
   IF CAGRPRO = 21 THEN
         R :=  F_Saldo_Poliza_Ulk (psseguro, pfrescat) + valores_rescate_dia - (PrimasAportadas - sumPa) - sumRa;
   ELSIF CAGRPRO = 21 THEN
   	   R := GREATEST(NVL(Pk_Provmatematicas.f_provmat(1, psseguro, pfrescat, 2, 0), 0), 0)
	   - PrimasAportadas + sumaRentas;
dbms_output.put_line('(2) pm='||Pk_Provmatematicas.f_provmat(1, psseguro, pfrescat, 2, 0)||', priapor='||PrimasAportadas||', sumPa='||sumPa||', sumRa='||sumRa);
   ELSE
     IF pctipres = 34 THEN
	   R :=	GREATEST(NVL(Pk_Provmatematicas.f_provmat(1, psseguro, pfrescat, 0, 0), 0), 0) - (PrimasAportadas - sumPa) - sumRa; -- Penalización
     ELSIF pctipres IN (  33,31 ) THEN
 	   R :=	GREATEST(NVL(Pk_Provmatematicas.f_provmat(0, psseguro, pfrescat-1, 1, pimpres), 0), 0) - (PrimasAportadas - sumPa) - sumRa; -- Penalización
     ELSE
	   R :=	GREATEST(NVL(Pk_Provmatematicas.f_provmat(1, psseguro, pfefecto-1, 1, 0), 0), 0) - (PrimasAportadas - sumPa) - sumRa; -- Penalización
     END IF;
dbms_output.put_line('(0) pm='||Pk_Provmatematicas.f_provmat(1, psseguro, pfrescat, 0, 0)||', priapor='||PrimasAportadas||', sumPa='||sumPa||', sumRa='||sumRa);
   END IF;
   PASE := 6;
   sumRt := 0;
   Rbruto := 0;
   rescate_acum := 0;
   Rtra := 0;
     -- Cálculo del rendimiento antes de reducciones a nivel de prima
	 movimiento_ult:=0;
   FOR p IN (SELECT  sseguro, nnumlin, fvalmov, iprima - Prima_Consumida(sseguro, nnumlin, fvalmov) imovimi
   	   	 	   FROM primas_aportadas
			  WHERE sseguro = psseguro
			    AND fvalmov <= pfrescat
				ORDER BY fvalmov
			)
   LOOP
        PASE := 7;
        movimiento_ult := p.nnumlin;
	  Rt := R * (p.imovimi*((pfrescat-p.fvalmov)/365)) / sumprim;
	  sumando := (p.imovimi + Rt);
	  SumatorioBruto := SumatorioBruto + sumando;
        kat := 1;
	  IF pctipres IN (  33,31 ) THEN
         IF  p.imovimi = 0 THEN
            kat := 0;
         ELSIF pimpres > SumatorioBruto THEN
            kat := 1;
         ELSIF pimpres BETWEEN SumatorioBruto_1 AND SumatorioBruto THEN
              kat := (pimpres - SumatorioBruto_1) / (p.imovimi + Rt);
         ELSE
              kat := 0;
         END IF;
         rt := ROUND(rt * kat, 2);
     END IF;
     PASE := 8;
	  rescate_acum := rescate_acum + (p.imovimi+Rt);
	  rescate_pend := pimpres - rescate_acum;
	  resto := ROUND(p.imovimi * kat, 2);
      IF p.imovimi > 0 THEN
	  	 -- Grabación de la prima consumida
		  DECLARE
		    orden NUMBER;
		  BEGIN
		     SELECT NVL(MAX(norden), 0)
			   INTO orden
			   FROM PRIMAS_CONSUMIDAS
			  WHERE sseguro = p.sseguro
			    AND nnumlin = p.nnumlin;
		     INSERT INTO PRIMAS_CONSUMIDAS
			 			 (sseguro, nnumlin, norden, ipricons, ircm, fecha)
					VALUES
						 (p.sseguro, p.nnumlin, orden+1, resto, Rt, pfrescat);
		  EXCEPTION
		    WHEN OTHERS THEN
			    dbms_output.put_line(SQLERRM);
				RETURN NULL;
		  END;
      END IF;
      PASE := 9;
	  -- Determinación del % de reducción
	  BEGIN
	     SELECT preduc
		   INTO red
		   FROM ULPREDE
		  WHERE cramo = 35 AND cmodali = 1 AND ctipseg = 0 AND ccolect = 0
		    AND finicio = (SELECT MAX(finicio)
						     FROM ULPREDE
							WHERE cramo = 35 AND cmodali = 1 AND ctipseg = 0 AND ccolect = 0
							  AND finicio <= pfrescat)
			AND (pfrescat - p.fvalmov)/365.25 BETWEEN nduraci AND nperman;
	  EXCEPTION
	    WHEN OTHERS THEN
	    dbms_output.put_line('Buscando % reduccion '||'años='||(pfrescat - p.fvalmov)/365.25||' '||SQLERRM);
		      RETURN 107710;
	  END;
dbms_output.put_line('Rt='||Rt||', reducc='||red);
	  Rtr  := Rt * (1-red);
	  Rtra := Rtra + Rtr;
	  -- Reducción adicional (primas anteriores a 31/12/1994)
	  IF p.fvalmov < TO_DATE('31/12/1994','dd/mm/yyyy') THEN
	  	 Rtr := Rtr * GREATEST(0, 1-0.1428*CEIL((TO_DATE('31/12/1994','dd/mm/yyyy')-p.fvalmov)/365));
	  END IF;
	  Rbruto := Rbruto + Rtr;
	  sumRt := sumRt + Rtr;
      SumatorioBruto_1 := SumatorioBruto;
   END LOOP;
   PASE := 10;
   -- Determinación del % de retención
   BEGIN
      SELECT preten
        INTO ret
        FROM ULPRETE
       WHERE cramo = 35 AND cmodali = 1 AND ctipseg = 0 AND ccolect = 0
         AND finicio = (SELECT MAX(finicio)
   			              FROM ULPRETE
   				         WHERE cramo = 35 AND cmodali = 1 AND ctipseg = 0 AND ccolect = 0
   				           AND finicio <= pfrescat);
   EXCEPTION
     WHEN OTHERS THEN
	    dbms_output.put_line('Buscando % retencion '||SQLERRM);
        RETURN 107710;
   END;
   PASE := 11;
   iretencion := GREATEST(ROUND(Rbruto * ret/100, 2), 0);
   IF (Rbruto IS NULL OR Rbruto < 0) and CAGRPRO<>21 THEN
      -- En caso de que no calcule retención omitimos esta opcion.
      if pfmuerte is null and pctipres <> 31 then
          RETURN 111217;
      end if;
   END IF;
   BEGIN
       SELECT NVL(MAX(norden), 0)
	     INTO num_orden
		 FROM ULRETEN
		WHERE sseguro = psseguro;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	     num_orden := 0;
   END;
   num_orden := num_orden + 1;
      --INSERTAR REGISTRO EN ULRETEN
   --***************************************************************
   --*** Si el tipo de rescate es 31 y la fecha de muerte es nula
   --*** indicamos que es contingencia sin retención
   --*** Si el tipo de rescate es 31 y la fecha de muerte NO es nula
   --*** indicamos que es contingencia CON retención
   --***************************************************************
   PASE := 12;
   IF pctipres = 31 AND Pfmuerte is null THEN
      BEGIN
         iretencion := 0;
         INSERT INTO ULRETEN
         (sseguro,nmovimi,frescat,crescat,nsinies,irescat,iimpred,ireten,norden,
         iprima,iprircm,iprinet,iprired,iprires,iresrcm,iresret,iresred,cproces)
         VALUES(psseguro,movimiento_ult,pfrescat,pctipres,pnsinies,pimpres,0,0,num_orden,
         NULL,0,NULL,NULL,0,0,NULL,0,'0');
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
		 	dbms_output.put_line(SQLERRM);
            RETURN 107611;
      END;
   ELSIF pctipres = 33 THEN
   --SI ES RESCATE PARCIAL
   dbms_output.put_line('Graba rescate parcial');
      BEGIN
         INSERT INTO ULRETEN
         (sseguro,nmovimi,frescat,crescat,nsinies,irescat,iimpred,ireten,norden,
         iprima,iprircm,iprinet,iprired,iprires,iresrcm,iresret,iresred,cproces)
         VALUES(psseguro,movimiento_ult,pfrescat,pctipres,pnsinies,pimpres,ROUND(sumRt,2),iretencion,num_orden,
         NULL,ROUND(sumRt,2),NULL,NULL,ROUND(resto,2),ROUND(R,2),NULL,ROUND(Rtra,2),'0');
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
		 	dbms_output.put_line(SQLERRM);
            RETURN 107611;
      END;
   ELSE
   --SI ES RESCATE TOTAL
   dbms_output.put_line('Graba rescate total');
      BEGIN
         INSERT INTO ULRETEN
         (sseguro,nmovimi,frescat,crescat,nsinies,irescat,iimpred,ireten,norden,iresrcm, iresred, cproces)
         VALUES(psseguro,movimiento_ult,pfrescat,pctipres,pnsinies,pimpres,ROUND(sumRt,2),ROUND(iretencion,2),num_orden,ROUND(R,2), ROUND(Rtra,2), '0');
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
		 	dbms_output.put_line(SQLERRM);
			dbms_output.put_line('sseguro='||psseguro||', nmovimi='||movimiento_ult||', orden='||num_orden);
         RETURN 107801;
      END;
   END IF;
   RETURN 0;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN NULL;
     WHEN OTHERS THEN
       RETURN NULL;
END F_Retensin;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_RETENSIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_RETENSIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_RETENSIN" TO "PROGRAMADORESCSI";
