--------------------------------------------------------
--  DDL for Package Body PK_CUADRO_AMORTIZACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_CUADRO_AMORTIZACION" 
IS


 PROCEDURE CUADRO_AMORTIZACION (p_sseguro  IN NUMBER,
	   	  					    p_capital  IN NUMBER,
	   	  		  				p_interes  IN NUMBER,
								p_carencia IN NUMBER,
								p_fefecto  IN DATE,
								p_periodos IN NUMBER,
								p_frecuencia IN NUMBER)
 IS

 i NUMBER:=p_interes/(p_frecuencia*100);
 capital_aseg NUMBER;
 capital_pend NUMBER;
 capital      NUMBER;
 interes      NUMBER;
 amort        NUMBER;
 n   NUMBER;
 factor NUMBER;
 fecha  DATE;
 grabados NUMBER:=0;
 k        NUMBER:=0;

BEGIN

   cuadro.DELETE;

   IF p_frecuencia = 12 THEN
   	  n := 3;
   ELSE
      n := 1;
   END IF;

   IF p_periodos > 0 THEN
      factor := i / (1-(power((1+i),-p_periodos)));
   END IF;
   capital_aseg := ROUND((p_capital * power((1+i), n)),2);
   capital_pend := capital_aseg;



		-- Grabación del capital pendiente inicial
		k := k + 1;
		cuadro(k).famort    := p_fefecto;
		cuadro(k).interes   := NULL;
		cuadro(k).capital   := NULL;
		cuadro(k).pendiente := capital_pend;
		cuadro(k).periodo   := NULL;
/*
		  BEGIN
             INSERT INTO cuadro_amortizacion (sseguro, fefecto, famort, interes, capital, pendiente)
		  		 VALUES (p_sseguro, p_fefecto, p_fefecto, 0, 0, capital_pend);
			 grabados := grabados + 1;
          EXCEPTION
	  		   WHEN OTHERS THEN
			   		RAISE_APPLICATION_ERROR(-20101, 'ERROR al insertar en cuadro_amortizacion: '||sqlerrm);
	      END;
*/

   IF NVL(p_carencia, 0) > 0 THEN
      FOR j IN 1..p_carencia
      LOOP

	      amort := 0;
	  	  interes := ROUND((capital_pend * i),2);
		  capital := 0;
		  capital_pend := capital_pend - capital;
		  fecha := ADD_MONTHS(p_fefecto, j*12);

--
    		k := k + 1;
    		cuadro(k).famort    := fecha;
    		cuadro(k).interes   := interes;
    		cuadro(k).capital   := capital;
    		cuadro(k).pendiente := capital_pend;
    		cuadro(k).periodo   := NULL;
/*
          BEGIN
             INSERT INTO cuadro_amortizacion (sseguro, fefecto, famort, interes, capital, pendiente)
		  		 VALUES (p_sseguro, p_fefecto, fecha, interes, capital, capital_pend);
			 grabados := grabados + 1;
          EXCEPTION
	  		   WHEN OTHERS THEN
			   		RAISE_APPLICATION_ERROR(-20101, 'ERROR al insertar en cuadro_amortizacion: '||sqlerrm);
	      END;
*/
      END LOOP;
   END IF;

   FOR j IN 1..p_periodos
   LOOP
      amort := ROUND((capital_aseg * factor),2);
	  interes := ROUND((capital_pend * i),2);
	  capital := amort - interes;
	  capital_pend := capital_pend - capital;
	  fecha := ADD_MONTHS(p_fefecto, NVL(p_carencia, 0)*12+ j*12/p_frecuencia);
 	  k := k + 1;
      cuadro(k).famort    := fecha;
      cuadro(k).interes   := interes;
      cuadro(k).capital   := capital;
      cuadro(k).pendiente := capital_pend;
      cuadro(k).periodo   := j;
/*
      BEGIN
          INSERT INTO cuadro_amortizacion (sseguro, fefecto, famort, interes, capital, pendiente, periodo)
		  		 VALUES (p_sseguro, p_fefecto, fecha, interes, capital, capital_pend, j);
			 grabados := grabados + 1;
      EXCEPTION
	  	  WHEN OTHERS THEN
			  RAISE_APPLICATION_ERROR(-20101, 'ERROR al insertar en cuadro_amortizacion: '||sqlerrm);
	  END;
*/
   END LOOP;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
       Null;
END CUADRO_AMORTIZACION;
-- ****************************************************************
--  Devuelve mensaje cuadro
-- ****************************************************************
PROCEDURE ver_mensajes(nerr IN NUMBER, result out t_amortizacion)
   IS
BEGIN
   RESULT := PK_CUADRO_AMORTIZACION.cuadro(nerr);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RESULT := NULL;
END ver_mensajes;

PROCEDURE pinta_cuadro
IS
BEGIN
 dbms_output.put_line('Fecha      Periodo Amortización Cuota Interes Cuota Capital Capital Pendiente');
 dbms_output.put_line('---------- -------------------- ------------- ------------- -----------------');
 dbms_output.new_line;
 for j in 1..pk_cuadro_amortizacion.cuadro.count
 loop
   dbms_output.put_line(TO_CHAR(pk_cuadro_amortizacion.cuadro(j).famort, 'dd/mm/yyyy')||'  '||
   					    SUBSTR(to_char(NVL(pk_cuadro_amortizacion.cuadro(j).periodo,0),'999G999G999'),2,11)||' '||
   						SUBSTR(to_char(NVL(pk_cuadro_amortizacion.cuadro(j).interes,0),'99G999G990D00'),2,13)||' '||
   						SUBSTR(to_char(NVL(pk_cuadro_amortizacion.cuadro(j).capital,0),'99G999G990D00'),2,13)||' '||
   						SUBSTR(to_char(NVL(pk_cuadro_amortizacion.cuadro(j).pendiente,0),'9G999G999G990D00'),2,16));
 end loop;
end pinta_cuadro;

PROCEDURE calcular_cuadro(p_sseguro IN NUMBER, p_fefecto IN DATE)
IS
  p_capital      NUMBER;
  p_interes      NUMBER;
  p_carencia     NUMBER;
  p_periodos     NUMBER;
  p_frecuencia   NUMBER;
  p_fec1per      NUMBER;

BEGIN

	 SELECT iimppre, pintpre, ncaren, nnumreci, cforamor
	 INTO p_capital, p_interes, p_carencia, p_periodos, p_frecuencia
	 FROM seguros_assp
	 WHERE sseguro = p_sseguro;

	 IF fvenc IS NULL or f1per IS NULL THEN
   	  BEGIN
	  	   SELECT fvencim, fefecto
		   INTO fvenc, f1per
		   FROM seguros
		   WHERE sseguro = p_sseguro;
   	  EXCEPTION
	  	WHEN OTHERS THEN
			 fvenc := TO_DATE('31/12/2100','dd/mm/yyyy');
	  END;
	 END IF;

	 IF p_fefecto IS NULL or p_fefecto = f1per THEN
	   p_fec1per := ffinfpago(1,p_frecuencia,to_number(to_char(f1per,'yyyymmdd')));
	   f1per := to_date(p_fec1per,'yyyymmdd');
	 ELSE
	   f1per := p_fefecto;
	 END IF;

	 p_periodos := nvl(ROUND(((fvenc-add_months(f1per,p_carencia * 12))*p_frecuencia/365.25)),0);

--     p_periodos := ROUND(((fvenc-p_fefecto)*p_frecuencia/365.25));
--   cuadro_amortizacion(p_sseguro, p_capital, p_interes, p_carencia, p_fefecto, p_periodos, p_frecuencia);
	 cuadro_amortizacion(p_sseguro, p_capital, p_interes, p_carencia, f1per, p_periodos, p_frecuencia);
	 F1PER := NULL;
	 FVENC := NULL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20101, 'ERROR: No existen datos para el sseguro: '||to_char(p_sseguro)||' con fecha: '||to_char(p_fefecto,'dd/mm/yyyy'));
END calcular_cuadro;
--
FUNCTION capital_pendiente (p_sseguro IN NUMBER, p_fefecto IN DATE, p_fecha IN DATE)
	RETURN NUMBER
IS
   j   NUMBER;
   pend NUMBER;
BEGIN
	 F1PER := NULL;
	 FVENC := NULL;

    BEGIN
	     SELECT fvencim, fefecto
		   INTO fvenc, f1per
		   FROM seguros
		  WHERE sseguro = p_sseguro;
	EXCEPTION
	    WHEN OTHERS THEN
			 fvenc := TO_DATE('31/12/2100','dd/mm/yyyy');
	END;

	IF fvenc < p_fecha THEN
	    RETURN 0;
	END IF;

	calcular_cuadro(p_sseguro, p_fefecto);
	FOR i IN 1..cuadro.count
	LOOP
	   j := i;
	   IF cuadro(i).famort >= p_fecha THEN
	   		EXIT;
	   END IF;
	END LOOP;

	IF j < 2 THEN j := 2; END IF;

	pend := cuadro(j-1).pendiente;
	RETURN pend;

END capital_pendiente;

END PK_CUADRO_AMORTIZACION;

/

  GRANT EXECUTE ON "AXIS"."PK_CUADRO_AMORTIZACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CUADRO_AMORTIZACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CUADRO_AMORTIZACION" TO "PROGRAMADORESCSI";
