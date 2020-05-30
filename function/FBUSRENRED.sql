--------------------------------------------------------
--  DDL for Function FBUSRENRED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBUSRENRED" (nsesion  IN NUMBER,
                                       pseguro  IN NUMBER,
                                       pfecha   IN NUMBER,
                                       pcgarant IN NUMBER,
                                       piprima  IN NUMBER,
				                       pfconting IN NUMBER,
                                       pctipo    IN NUMBER,
									   pccausin  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:

   PARAMETROS:
   INPUT: NSESION(number)  -->
          PSEGURO(number)  -->
          PFECHA(number)   --> Fecha de Rescate
          PCGARANT(number) --> Garantía
          PIPRIMA(number)  --> Prima
		  PFCONTING(number)--> Fecha de Contingencia
          PCTIPO(number)   --> 0 - Rendimiento
                               1 - Reducción
   RETORNA VALUE:
          NUMBER------------> Retorna el total de Aportaciones realizadas
******************************************************************************/
valor     NUMBER;
xiprima	  NUMBER;
xfecha    DATE;
--
XSPRODUC  NUMBER;
xpaso     NUMBER;
--
xdia 	  NUMBER;
xtotdia   NUMBER;
--
xcoefic   NUMBER;
xtotcoe   NUMBER;
xrendim   NUMBER;
xtotren   NUMBER;
preduc    NUMBER;
xreducc   NUMBER;
xtotred   NUMBER;
xtprima   NUMBER;
xfconting DATE;
xcumple   NUMBER;
xsumppa   NUMBER;
xsumpri   NUMBER;
xanys     NUMBER;
xfefecto  DATE;
cuantos   NUMBER;
xredprima NUMBER;
xcoeprima NUMBER;
xrenprima NUMBER;
--
BEGIN
 valor := NULL;
 xfecha:= TO_DATE(pfecha,'yyyymmdd');
 IF pfconting <> 0 THEN
    xfconting:= TO_DATE(pfconting,'yyyymmdd');
 ELSE
    xfconting := NULL;
 END IF;
 --
 BEGIN
	SELECT SPRODUC,fefecto INTO XSPRODUC,xfefecto
      FROM SEGUROS
     WHERE SSEGURO = PSEGURO;
 EXCEPTION
     WHEN OTHERS THEN
          RETURN NULL;
 END;
 --
 BEGIN
   -- total Dias
   xtotdia := 0;
   FOR dia IN (SELECT fvalmov,nnumlin, iprima FROM PRIMAS_APORTADAS
                WHERE sseguro = pseguro
                  AND fvalmov <= xfecha)
   LOOP
     xiprima := Prima_Consumida(pseguro,dia.nnumlin, dia.fvalmov);
     IF xiprima <  dia.iprima THEN
        xdia := xfecha - dia.fvalmov;
        xtotdia := xtotdia + xdia;
     END IF;
   END LOOP;

   -- Total Coeficiente
   xtotcoe := 0;
   xtprima := 0;
   FOR coe IN (SELECT fvalmov, nnumlin, iprima FROM PRIMAS_APORTADAS
                WHERE sseguro = pseguro
                  AND fvalmov <= xfecha)
   LOOP
     xiprima := Prima_Consumida(pseguro,coe.nnumlin, coe.fvalmov);
     IF xiprima <  coe.iprima THEN
        xdia := xfecha - coe.fvalmov;
		xcoeprima := coe.iprima - xiprima;
		IF (xfconting IS NOT NULL AND coe.fvalmov <= xfconting) THEN
            xcoefic := (xdia/ xtotdia) * (xcoeprima/2);
            xtprima := xtprima + (xcoeprima/2);

        ELSE
            xcoefic := (xdia / xtotdia) * xcoeprima;
            xtprima := xtprima + xcoeprima;

		END IF;
        xtotcoe := xtotcoe + xcoefic;
     END IF;
   END LOOP;

   -- Rendimientos
   xtotren := 0;
   FOR ren IN (SELECT fvalmov, nnumlin, iprima FROM PRIMAS_APORTADAS
                WHERE sseguro = pseguro
                  AND fvalmov <= xfecha)
   LOOP
     xiprima := Prima_Consumida(pseguro,ren.nnumlin, ren.fvalmov);
     IF xiprima <  ren.iprima THEN
        xdia := xfecha - ren.fvalmov;
		xrenprima := ren.iprima - xiprima;
        IF (xfconting IS NOT NULL AND ren.fvalmov <= xfconting) THEN
		    xcoefic := (xdia/ xtotdia) * (xrenprima/2);
        ELSE
            xcoefic := (xdia / xtotdia) * xrenprima;
        END IF;
        xrendim := (xcoefic / xtotcoe) * (piprima-xtprima);
        xtotren := xtotren + xrendim;
     END IF;
   END LOOP;

   -- Reducciones
   IF PCTIPO = 1 THEN
     -- Averigüo si se aplicara una deducción de coeficientes parametrizada
	 -- o la máxima, siempre y cuando no sobrepase el limite de 3 rescates
	 -- parciales que será una deducción 0.
	 XCUMPLE := 0;
     IF pccausin IN (204,504,904) THEN
      IF xfefecto > TO_DATE('31121994','DDMMYYYY') THEN
 	   IF CEIL((XFECHA - XFEFECTO) / 365.25) > 8 THEN
	      xsumppa := 0;
	      xsumpri := 0;
		  --
	      FOR r IN (SELECT (IPRIMA - Prima_Consumida(pseguro,nnumlin, F_Sysdate)) prima, fvalmov
        	  	    FROM primas_aportadas
                    WHERE sseguro = pseguro
			   	    AND fvalmov <= xfecha)
  	      LOOP
		     xsumpri := xsumpri + r.prima;
		     xsumppa := xsumppa + (r.prima * (xfecha - r.fvalmov));
	      END LOOP;
	      xanys := CEIL((xsumppa / xsumpri) / 365.25);
		  --
	      IF xanys > 4 THEN
           xcumple := 1;
	      ELSE
           xcumple := 0;
	      END IF;
		  --
       END IF;
      END IF;
     END IF;
     --
     xtotred := 0;
     FOR red IN (SELECT fvalmov, nnumlin, iprima FROM PRIMAS_APORTADAS
                  WHERE sseguro = pseguro
                    AND fvalmov <= xfecha)
     LOOP
       xiprima := Prima_Consumida(pseguro,red.nnumlin, red.fvalmov);
       IF xiprima <  red.iprima THEN
          xdia := xfecha - red.fvalmov;
		  xredprima := red.iprima - xiprima;
          IF (xfconting IS NOT NULL AND red.fvalmov <= xfconting) THEN
		      xcoefic := (xdia/ xtotdia) * (xredprima/2);
		  ELSE
			  xcoefic := (xdia / xtotdia) * xredprima;
          END IF;
          xrendim := (xcoefic / xtotcoe) * (piprima-xtprima);
  	      IF XCUMPLE = 1 THEN
	         XANYS := 900;
	      ELSE
	         xanys := (xdia/365.25);
	      END IF;
          preduc := Fbuscapreduc(nsesion,xsproduc,0,999,pfecha,xanys);
DBMS_OUTPUT.PUT_LINE (red.fvalmov||' Reduccio: '||preduc);
          IF preduc IS NULL THEN
             RETURN NULL;
          END IF;
          xreducc := xrendim * (1 - preduc);
          xtotred := xtotred + xreducc;
       END IF;
     END LOOP;
     --
     RETURN XTOTRED;
   ELSE
     RETURN XTOTREN;
   END IF;
   --
 EXCEPTION
   WHEN NO_DATA_FOUND THEN	 	  RETURN NULL;
   WHEN OTHERS THEN   	 	      RETURN NULL;
 END;
END Fbusrenred;
 
 

/

  GRANT EXECUTE ON "AXIS"."FBUSRENRED" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBUSRENRED" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBUSRENRED" TO "PROGRAMADORESCSI";
