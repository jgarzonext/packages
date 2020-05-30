--------------------------------------------------------
--  DDL for Package Body PAC_ZONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ZONA" IS
/***************************************************************
	PAC_ZONA: Cuerpo de las funciones de zonas

***************************************************************/
FUNCTION f_zona (zonificacion IN NUMBER, provincia IN NUMBER, poblacion IN NUMBER,
  		 cp IN NUMBER, fefecto IN DATE, fcuando IN DATE, pczona OUT NUMBER,
                 pszona OUT NUMBER)
    -- fefecto: Fecha a tener en cuenta para buscar la zona activa
    -- fcuando: Fecha para simular que la búsqueda se está haciendo un dia en concreto
  RETURN NUMBER IS
  NO_CP_NUL  EXCEPTION;
  zonifich   NUMBER;
BEGIN
  -- Seleccionar la versió correcta
  SELECT DISTINCT HISZONIF.szonifh
    INTO zonifich
    FROM CODZONIF, HISZONIF
    WHERE CODZONIF.szonif = zonificacion
      AND CODZONIF.szonif = HISZONIF.szonif
      AND HISZONIF.CZONIFE = 2
      AND TRUNC(HISZONIF.fzonifi) <= TRUNC(fefecto)
      AND ( HISZONIF.fzoniff IS NULL OR TRUNC(HISZONIF.FZONIFF) > TRUNC(fefecto) )
      AND  HISZONIF.FZONIFA  = (SELECT  MAX(HISZONIF.FZONIFA)
                                     FROM CODZONIF, HISZONIF
                                     WHERE CODZONIF.szonif = zonificacion
                                       AND CODZONIF.szonif = HISZONIF.szonif
                                       AND HISZONIF.czonife = 2
                                       AND TRUNC(HISZONIF.fzonifi)<= TRUNC(fefecto)
				       AND (HISZONIF.fzoniff IS NULL OR TRUNC(HISZONIF.fzoniff)>TRUNC(fefecto))
                                       AND HISZONIF.FZONIFA <= fcuando
                                     );
  IF poblacion IS NULL THEN
    IF cp IS NULL THEN
      -- Población y cp nulos
      SELECT  DISTINCT  CODZONAS.czona, CODZONAS.szona
        INTO pczona, pszona
	FROM CODZONIF, CODZONAS, DETZONAS
	WHERE CODZONAS.szonifh = zonifich
	  AND CODZONAS.szona = DETZONAS.szona
	  AND CODZONIF.szonif = zonificacion
	  AND DETZONAS.cprovin = provincia
	  AND DETZONAS.cpoblac IS NULL
	  AND DETZONAS.cpostal IS NULL;
    ELSE
      -- Error, no puede haber CP si la poblacion es nula.
      RAISE NO_CP_NUL;
    END IF;
  ELSE
    -- poblacion no es nula
    IF cp IS NULL THEN
      BEGIN
        SELECT  DISTINCT CODZONAS.czona, CODZONAS.szona
          INTO pczona, pszona
	  FROM CODZONIF, CODZONAS,DETZONAS
	  WHERE CODZONAS.szonifh = zonifich
	    AND CODZONAS.szona = DETZONAS.szona
	    AND CODZONIF.szonif = zonificacion
	    AND DETZONAS.cprovin = provincia
	    AND DETZONAS.cpoblac = poblacion
	    AND DETZONAS.cpostal IS NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
	      -- si no hay registros busco por poblacion nula y cp nulo
              SELECT  DISTINCT CODZONAS.czona, CODZONAS.szona
                INTO pczona, pszona
		FROM CODZONIF, CODZONAS, DETZONAS
		WHERE CODZONAS.szonifh = zonifich
		  AND CODZONAS.szona = DETZONAS.szona
		  AND CODZONIF.szonif = zonificacion
		  AND DETZONAS.cprovin = provincia
		  AND DETZONAS.cpoblac IS NULL
		  AND DETZONAS.cpostal IS NULL;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
      		  RAISE NO_DATA_FOUND;
            END;
      END;
    -- cp no es nulo
    ELSE
      BEGIN
        SELECT  DISTINCT CODZONAS.czona, CODZONAS.szona
          INTO pczona, pszona
	  FROM CODZONIF, CODZONAS,DETZONAS
	  WHERE CODZONAS.szonifh = zonifich
	    AND CODZONAS.szona = DETZONAS.szona
	    AND CODZONIF.szonif = zonificacion
	    AND DETZONAS.cprovin = provincia
	    AND DETZONAS.cpoblac = poblacion
	    AND DETZONAS.cpostal = cp;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
--            dbms_output.put_line(' Erro no hemos encotrado datos  '||zonifich||' '||zonificacion||' '||provincia||' '||poblacion||' '||cp);
            BEGIN
	      -- si no hay registros busco por cp nulo
              SELECT  DISTINCT CODZONAS.czona, CODZONAS.szona
                INTO pczona, pszona
		FROM CODZONIF, CODZONAS, DETZONAS
		WHERE CODZONAS.szonifh = zonifich
		  AND CODZONAS.szona = DETZONAS.szona
		  AND CODZONIF.szonif = zonificacion
		  AND DETZONAS.cprovin = provincia
		  AND DETZONAS.cpoblac = poblacion
		  AND DETZONAS.cpostal IS NULL;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   -- caso provincia, NULL, NULL
                   SELECT  DISTINCT CODZONAS.czona, CODZONAS.szona
                     INTO pczona, pszona
       	  	       FROM CODZONIF, CODZONAS, DETZONAS
       		       WHERE CODZONAS.szonifh = zonifich
       		         AND CODZONAS.szona = DETZONAS.szona
        		     AND CODZONIF.szonif = zonificacion
       		         AND DETZONAS.cprovin = provincia
       		         AND DETZONAS.cpoblac IS NULL
       		         AND DETZONAS.cpostal IS NULL;
            END;
      END;
    END IF;
  END IF;
  RETURN 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 40202;
    WHEN NO_CP_NUL THEN
      RETURN 101901; -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
    WHEN OTHERS THEN
	 -- dbms_output.put_line(' Error en f_zona : '||SQLERRM);
      RETURN 1;
END f_zona;
---------------------------------------------------------------------------------
FUNCTION f_zonif (pcactpro IN NUMBER, psseguro IN NUMBER, pzonif OUT NUMBER)
RETURN NUMBER IS
cont NUMBER;
BEGIN
SELECT COUNT(*) INTO cont
FROM ACTPROZONIF a, CODZONIF c, SEGUROS s, PRODUCTOS p
WHERE a.cactpro = pcactpro
  AND a.szonif = c.szonif
  AND c.CRAMO = p.cramo
  AND c.SPRODUC = p.sproduc
  AND c.cactivi = s.cactivi
  AND p.ctipseg = s.ctipseg
  AND p.CCOLECT = s.ccolect
  AND p.CRAMO = s.cramo
  AND p.CMODALI = s.cmodali
  AND s.sseguro = psseguro;
  IF (cont = 1) THEN
    SELECT c.szonif INTO pzonif
    FROM ACTPROZONIF a, CODZONIF c, SEGUROS s, PRODUCTOS p
    WHERE a.cactpro = pcactpro
      AND a.szonif = c.szonif
      AND c.CRAMO = p.cramo
      AND c.SPRODUC = p.sproduc
      AND c.cactivi = s.cactivi
      AND p.ctipseg = s.ctipseg
      AND p.CCOLECT = s.ccolect
      AND p.CRAMO = s.cramo
      AND p.CMODALI = s.cmodali
      AND s.sseguro = psseguro;
  ELSIF (cont = 0) THEN
    SELECT COUNT(*) INTO cont
    FROM ACTPROZONIF a, CODZONIF c, SEGUROS s, PRODUCTOS p
    WHERE a.cactpro = pcactpro
      AND a.szonif = c.szonif
      AND c.CRAMO = p.cramo
      AND c.SPRODUC = p.sproduc
      AND c.cactivi IS NULL
      AND p.ctipseg = s.ctipseg
      AND p.CCOLECT = s.ccolect
      AND p.CRAMO = s.cramo
      AND p.CMODALI = s.cmodali
      AND s.sseguro = psseguro;
      IF (cont = 1) THEN
        SELECT c.szonif INTO pzonif
        FROM ACTPROZONIF a, CODZONIF c, SEGUROS s, PRODUCTOS p
        WHERE a.cactpro = pcactpro
          AND a.szonif = c.szonif
          AND c.CRAMO = p.cramo
          AND c.SPRODUC = p.sproduc
          AND c.cactivi IS NULL
          AND p.ctipseg = s.ctipseg
          AND p.CCOLECT = s.ccolect
          AND p.CRAMO = s.cramo
          AND p.CMODALI = s.cmodali
          AND s.sseguro = psseguro;
      ELSIF (cont = 0) THEN
         SELECT COUNT(*) INTO cont
         FROM ACTPROZONIF a, CODZONIF c, SEGUROS s, PRODUCTOS p
         WHERE a.cactpro = pcactpro
           AND a.szonif = c.szonif
           AND c.CRAMO = p.cramo
           AND c.SPRODUC IS NULL
           AND c.cactivi = s.cactivi
           AND p.ctipseg = s.ctipseg
           AND p.CCOLECT = s.ccolect
           AND p.CRAMO = s.cramo
           AND p.CMODALI = s.cmodali
           AND s.sseguro = psseguro;
           IF (cont = 1) THEN
             SELECT c.szonif INTO pzonif
             FROM ACTPROZONIF a, CODZONIF c, SEGUROS s, PRODUCTOS p
             WHERE a.cactpro = pcactpro
               AND a.szonif = c.szonif
               AND c.CRAMO = p.cramo
               AND c.SPRODUC IS NULL
               AND c.cactivi = s.cactivi
               AND p.ctipseg = s.ctipseg
               AND p.CCOLECT = s.ccolect
               AND p.CRAMO = s.cramo
               AND p.CMODALI = s.cmodali
               AND s.sseguro = psseguro;
           ELSIF (cont = 0) THEN
             SELECT c.szonif INTO pzonif
             FROM ACTPROZONIF a, CODZONIF c, SEGUROS s, PRODUCTOS p
             WHERE a.cactpro = pcactpro
               AND a.szonif = c.szonif
               AND c.CRAMO = p.cramo
               AND c.SPRODUC IS NULL
               AND c.cactivi IS NULL
               AND p.ctipseg = s.ctipseg
               AND p.CCOLECT = s.ccolect
               AND p.CRAMO = s.cramo
               AND p.CMODALI = s.cmodali
               AND s.sseguro = psseguro;
           END IF;
        END IF;
END IF;
RETURN 0;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN 109862;--NO EXISTE ZONIFICACION
  WHEN OTHERS THEN RETURN NULL;--ERROR
END f_zonif;
--------------------------------------------------------------------
FUNCTION f_szonif (pcactpro IN NUMBER, psseguro IN NUMBER, pszonif OUT NUMBER)
  RETURN NUMBER IS
BEGIN
  SELECT c.szonif
  INTO pszonif
  FROM ACTPROZONIF a,CODZONIF c, SEGUROS s
  WHERE c.szonif = a.szonif
    AND a.cactpro = pcactpro
    AND c.cramo = s.cramo
    AND s.sseguro = psseguro;
RETURN 0;
EXCEPTION
  WHEN OTHERS THEN RETURN SQLCODE;
END f_szonif;
--------------------------------------------------------------------
FUNCTION F_Copiazonif (PSZONIF IN NUMBER, PTCAT IN VARCHAR2,
    	         PTESP IN VARCHAR2, PUSUARIO IN VARCHAR2) RETURN NUMBER IS
 V_SZONIF 		  NUMBER;
 V_SDETZON		  NUMBER;
 V_SZONA		  NUMBER;
 V_SZONA_OLD	  	  NUMBER;
 V_SZONIFH		  NUMBER;
 V_SZONIFH_OLD	          NUMBER;
 VALOR 			  NUMBER;
 IND 			  NUMBER;
 IND1			  NUMBER;
 IND2			  NUMBER;
 CURSOR codz IS
  SELECT SZONA,SZONIFH,FALTA,CUSUALT,FMODIF,CUSUMOD,CZONIFT,CZONA
  FROM CODZONAS
  WHERE SZONIFH=V_SZONIFH_OLD;
 CURSOR detz IS
  SELECT DZ.SDETZON,DZ.SZONA,DZ.CPROVIN,DZ.CPOBLAC,DZ.CPOSTAL,DZ.FALTA,DZ.CUSUALT,
         DZ.FMODIF,DZ.CUSUMOD
  FROM DETZONAS DZ,CODZONAS CZ
  WHERE CZ.SZONA=DZ.SZONA AND
        CZ.SZONA=V_SZONA_OLD AND
        CZ.SZONIFH=V_SZONIFH_OLD;
 CURSOR desz IS
  SELECT D.SZONA,D.CIDIOMA,D.TZONA,D.FALTA,D.CUSUALT,D.FMODIF,D.CUSUMOD
  FROM DESZONAS D,CODZONAS C
  WHERE D.SZONA=C.SZONA
    AND C.SZONA=V_SZONA_OLD
    AND C.SZONIFH=V_SZONIFH_OLD;
BEGIN
  SELECT SZONIFH
  INTO V_SZONIFH_OLD
  FROM HISZONIF H1
  WHERE H1.SZONIF=PSZONIF
    AND H1.CZONIFE=2
    AND H1.FZONIFA <= F_Sysdate
    AND (H1.FZONIFF >= F_Sysdate OR H1.fzoniff IS NULL)
    AND H1.FZONIFA = (SELECT MAX(H2.FZONIFA)
                      FROM HISZONIF H2
		      WHERE H2.SZONIF=H1.SZONIF AND
			    H2.CZONIFE=H1.CZONIFE AND
			    H2.FZONIFA<=F_Sysdate AND
  		      (H2.FZONIFF>=F_Sysdate OR H2.FZONIFF IS NULL));
 SELECT SZONIF.NEXTVAL INTO V_SZONIF FROM DUAL;
 INSERT INTO CODZONIF (SZONIF,CRAMO,FALTA,CUSUALT,FMODIF,CUSUMOD,SPRODUC,CACTIVI,CTIPZON)
  SELECT V_SZONIF,CRAMO,F_Sysdate,PUSUARIO,FMODIF,CUSUMOD,SPRODUC,CACTIVI,CTIPZON
  FROM CODZONIF C
  WHERE C.SZONIF=PSZONIF;
 INSERT INTO DESZONIF (SZONIF,CIDIOMA,TZONIF,FALTA,CUSUALT)
  SELECT V_SZONIF,D.CIDIOMA,D.TZONIF,F_Sysdate,PUSUARIO
    FROM CODZONIF C, DESZONIF D
    WHERE C.SZONIF=PSZONIF AND
          C.SZONIF=D.SZONIF;
  UPDATE DESZONIF SET TZONIF=PTCAT WHERE SZONIF=V_SZONIF AND CIDIOMA=1;
  UPDATE DESZONIF SET TZONIF=PTESP WHERE SZONIF=V_SZONIF AND CIDIOMA=2;
  SELECT SZONIFH.NEXTVAL INTO V_SZONIFH FROM DUAL;
  INSERT INTO HISZONIF(SZONIFH,SZONIF,CZONIFT,CZONIFE,FALTA,CUSUALT,FMODIF,CUSUMOD)
  SELECT V_SZONIFH,V_SZONIF,CZONIFT,1,F_Sysdate,PUSUARIO,FMODIF,PUSUARIO
    FROM HISZONIF
    WHERE SZONIF=PSZONIF
      AND SZONIFH=V_SZONIFH_OLD;
   FOR v1 IN CODZ LOOP
       V_SZONA_OLD := V1.SZONA;
   	   SELECT SZONA.NEXTVAL INTO V_SZONA FROM DUAL;
       INSERT INTO CODZONAS (SZONA,SZONIFH,FALTA,CUSUALT,FMODIF,CUSUMOD,CZONIFT,CZONA)
       VALUES (V_SZONA,V_SZONIFH,F_Sysdate,PUSUARIO,V1.FMODIF,V1.CUSUMOD,
  	          V1.CZONIFT,V1.CZONA);
	   FOR v2 IN DETZ LOOP
       	   SELECT SDETZON.NEXTVAL INTO V_SDETZON FROM DUAL;
 		   INSERT INTO DETZONAS (SDETZON,SZONA,CPROVIN,CPOBLAC,CPOSTAL,FALTA,CUSUALT,
		                         FMODIF,CUSUMOD)
  		   VALUES (V_SDETZON,V_SZONA,V2.CPROVIN,V2.CPOBLAC,V2.CPOSTAL,V2.FALTA,
		           PUSUARIO,V2.FMODIF,V2.CUSUMOD);
           ind1 := ind1 + 1;
	   END LOOP;
	   FOR v3 IN DESZ LOOP
 		   INSERT INTO DESZONAS (SZONA,CIDIOMA,TZONA,FALTA,CUSUALT,FMODIF,CUSUMOD)
  		   VALUES(V_SZONA,V3.CIDIOMA,V3.TZONA,F_Sysdate,PUSUARIO,V3.FMODIF,V3.CUSUMOD);
           ind2 := ind2 + 1;
	   END LOOP;
       ind := ind + 1;
   END LOOP;
  RETURN 0;
EXCEPTION
 WHEN OTHERS THEN
   ROLLBACK;
   RETURN SQLCODE;
END F_Copiazonif;
-----------------------------------------------------------------------------------------------------
FUNCTION F_COPIAZONIFH (PSZONIF IN NUMBER, PSZONIFH IN NUMBER, PUSUARIO IN VARCHAR2)
 RETURN NUMBER IS
 --Esta función permite copiar una versión de zonificación.
 V_SDETZON		  NUMBER;
 V_SZONA		  NUMBER;
 V_SZONA_OLD	  	  NUMBER;
 V_SZONIFH		  NUMBER;
 VALOR 			  NUMBER;
 IND 			  NUMBER;
 IND1			  NUMBER;
 IND2			  NUMBER;
 CURSOR codz IS
    SELECT SZONA,SZONIFH,FALTA,CUSUALT,FMODIF,CUSUMOD,CZONIFT,CZONA
    FROM CODZONAS
    WHERE SZONIFH=PSZONIFH;
 CURSOR detz IS
    SELECT DZ.SDETZON,DZ.SZONA,DZ.CPROVIN,DZ.CPOBLAC,DZ.CPOSTAL,DZ.FALTA,DZ.CUSUALT,
         DZ.FMODIF,DZ.CUSUMOD
    FROM DETZONAS DZ,CODZONAS CZ
    WHERE CZ.SZONA=DZ.SZONA AND
        CZ.SZONA=V_SZONA_OLD AND
        CZ.SZONIFH=PSZONIFH;
 CURSOR desz IS
    SELECT D.SZONA,D.CIDIOMA,D.TZONA,D.FALTA,D.CUSUALT,D.FMODIF,D.CUSUMOD
    FROM DESZONAS D,CODZONAS C
    WHERE D.SZONA=C.SZONA
      AND C.SZONA=V_SZONA_OLD
      AND C.SZONIFH=PSZONIFH;
BEGIN
  SELECT SZONIFH.NEXTVAL INTO V_SZONIFH FROM DUAL;
  INSERT INTO HISZONIF (SZONIFH,SZONIF,CZONIFT,CZONIFE,FALTA,CUSUALT,FMODIF,CUSUMOD)
   SELECT V_SZONIFH,PSZONIF,CZONIFT,1,F_Sysdate,PUSUARIO,FMODIF,PUSUARIO
     FROM HISZONIF
    WHERE SZONIF=PSZONIF
      AND SZONIFH=PSZONIFH;
   FOR v1 IN CODZ LOOP
       V_SZONA_OLD := V1.SZONA;
       SELECT SZONA.NEXTVAL INTO V_SZONA FROM DUAL;
       INSERT INTO CODZONAS (SZONA,SZONIFH,FALTA,CUSUALT,FMODIF,CUSUMOD,CZONIFT,CZONA)
       VALUES (V_SZONA,V_SZONIFH,F_Sysdate,PUSUARIO,V1.FMODIF,V1.CUSUMOD,
  	          V1.CZONIFT,V1.CZONA);
	   FOR v2 IN DETZ LOOP
       	   SELECT SDETZON.NEXTVAL INTO V_SDETZON FROM DUAL;
 		   INSERT INTO DETZONAS (SDETZON,SZONA,CPROVIN,CPOBLAC,CPOSTAL,FALTA,CUSUALT,
		                             FMODIF,CUSUMOD)
  		   VALUES (V_SDETZON,V_SZONA,V2.CPROVIN,V2.CPOBLAC,V2.CPOSTAL,V2.FALTA,
		           PUSUARIO,V2.FMODIF,V2.CUSUMOD);
           ind1 := ind1 + 1;
	   END LOOP;
	   FOR v3 IN DESZ LOOP
 		   INSERT INTO DESZONAS (SZONA,CIDIOMA,TZONA,FALTA,CUSUALT,FMODIF,CUSUMOD)
  		   VALUES(V_SZONA,V3.CIDIOMA,V3.TZONA,F_Sysdate,PUSUARIO,V3.FMODIF,V3.CUSUMOD);
           ind2 := ind2 + 1;
	   END LOOP;
       ind := ind + 1;
   END LOOP;
  RETURN 0;
EXCEPTION
 WHEN OTHERS THEN
   ROLLBACK;
   RETURN SQLCODE;
END F_COPIAZONIFH;
---------------------------------------------------------------------------------------------
FUNCTION F_zonagarantia (PSZONIF IN NUMBER,
                         PCPOSTAL IN codpostal.cpostal%TYPE,
                         PCPOBLAC IN NUMBER,
                         PCPROVIN IN NUMBER,
                         PSPRODUC IN NUMBER,
                         PCACTIVI IN NUMBER,
                         PCGARANT IN NUMBER,
                         PFEFECTO IN DATE,
                         PFCUANDO IN DATE,
                         PCPERMIS OUT NUMBER)
RETURN NUMBER IS
/************************************************************************************************
    Comprobará que un código postal, población o provincia determinada esté
                      en una zona de contratación permitida para una garantia a una fecha
                      determinada
    -- fefecto: Fecha a tener en cuenta para buscar la zona activa
    -- fcuando: Fecha para simular que la búsqueda se está haciendo un dia en concreto
************************************************************************************************/
pczona                   NUMBER;
pszona                   NUMBER;
num_err                  NUMBER;
v_zona                 NUMBER;
BEGIN
    BEGIN
      SELECT DISTINCT ( CZONA)
	   INTO v_zona
      FROM   GARANZONA
      WHERE  CGARANT = PCGARANT
         AND SPRODUC = PSPRODUC
         AND CACTIVI = PCACTIVI
         AND SZONIF  = pszonif;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       pcpermis :=  0;      -- Localización permitida
       RETURN 0;
	 WHEN OTHERS THEN
  	   RETURN 112042; -- Error en la función f_zonagarantia
   END;
   --
   -- Tenemos grabada las zonas permitidas.
   IF v_zona = 1 THEN
     -- Miramos qué zona me corresponde por el código postal o provincia o población
     -- que introducimos
     num_err := Pac_Zona.f_zona(pszonif, pcprovin, pcpoblac, pcpostal, pfefecto, pfcuando,
                                pczona,pszona);
     IF num_err = 40202 THEN -- Si no hay zona
        pcpermis := 1; -- localización NO permitida
        num_err := 0;
     ELSIF num_err = 0 THEN
        -- Miramos si la zona está asignada a la garantía
        BEGIN
           SELECT CZONA
           INTO   v_zona
           FROM   GARANZONA
           WHERE  CGARANT = PCGARANT
              AND SPRODUC = PSPRODUC
              AND CACTIVI = PCACTIVI
              AND SZONIF  = pszonif
              AND SZONA =   PSZONA;
           IF v_zona = 0 THEN
              pcpermis := 1;       -- Localización NO permitida
           ELSIF v_zona = 1 THEN
              pcpermis :=  0;      -- Localización permitida
           END IF;
           num_err := 0;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              pcpermis := 1;       -- No encuentra registros en Garanzona, localización NO permitida
              num_err := 0;
           WHEN OTHERS THEN
    		  pcpermis := 1;
              num_err := 112042; -- Error en la función f_zonagarantia
        END;
     END IF;
   --
   -- Tenemos grabada las zonas NO permitidas.
   ELSIF v_zona = 0 THEN
     -- Miramos qué zona me corresponde por el código postal o provincia o población
     -- que introducimos
     num_err := Pac_Zona.f_zona(pszonif, pcprovin, pcpoblac, pcpostal, pfefecto, pfcuando,
                                pczona,pszona);
     IF num_err = 40202 THEN -- Si no hay zona
        pcpermis := 0; -- localización permitida
        num_err := 0;
     ELSIF num_err = 0 THEN
        -- Miramos si la zona está asignada a la garantía
        BEGIN
           SELECT CZONA
           INTO   v_zona
           FROM   GARANZONA
           WHERE  CGARANT = PCGARANT
              AND SPRODUC = PSPRODUC
              AND CACTIVI = PCACTIVI
              AND SZONIF  = pszonif
              AND SZONA =   PSZONA;
           IF v_zona = 0 THEN
              pcpermis := 1;       -- Localización NO permitida
           ELSIF v_zona = 1 THEN
              pcpermis :=  0;      -- Localización permitida
           END IF;
           num_err := 0;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              pcpermis := 0;       -- No encuentra registros en Garanzona, localización permitida
              num_err := 0;
           WHEN OTHERS THEN
    		  pcpermis := 1;
              num_err := 112042; -- Error en la función f_zonagarantia
        END;
     END IF;
   END IF;
   RETURN num_err;
EXCEPTION WHEN OTHERS THEN
   RETURN NVL( num_err, 112042);
END f_zonagarantia;
--------------------------------------------------------------------------------------------
FUNCTION f_zona2 (zonificacion IN NUMBER, provincia IN NUMBER, poblacion IN NUMBER,
  		 cp IN NUMBER, fefecto IN DATE, fcuando IN DATE)
    -- fefecto: Fecha a tener en cuenta para buscar la zona activa
    -- fcuando: Fecha para simular que la búsqueda se está haciendo un dia en concreto
  RETURN NUMBER IS
  NO_CP_NUL  EXCEPTION;
  zonifich   NUMBER;
  pczona	 NUMBER;
  pszona	 NUMBER;
BEGIN
  -- Seleccionar la versió correcta
  SELECT DISTINCT HISZONIF.szonifh
    INTO zonifich
    FROM CODZONIF, HISZONIF
    WHERE CODZONIF.szonif = zonificacion
      AND CODZONIF.szonif = HISZONIF.szonif
      AND HISZONIF.CZONIFE = 2
      AND TRUNC(HISZONIF.fzonifi) <= TRUNC(fefecto)
      AND ( HISZONIF.fzoniff IS NULL OR TRUNC(HISZONIF.FZONIFF) > TRUNC(fefecto) )
      AND  HISZONIF.FZONIFA  = (SELECT  MAX(HISZONIF.FZONIFA)
                                     FROM CODZONIF, HISZONIF
                                     WHERE CODZONIF.szonif = zonificacion
                                       AND CODZONIF.szonif = HISZONIF.szonif
                                       AND HISZONIF.czonife = 2
                                       AND TRUNC(HISZONIF.fzonifi)<= TRUNC(fefecto)
				       AND (HISZONIF.fzoniff IS NULL OR TRUNC(HISZONIF.fzoniff)>TRUNC(fefecto))
                                       AND HISZONIF.FZONIFA <= fcuando
                                     );
  IF poblacion IS NULL THEN
    IF cp IS NULL THEN
      -- Población y cp nulos
      SELECT CODZONAS.czona, CODZONAS.szona
        INTO pczona, pszona
	FROM CODZONIF, CODZONAS, DETZONAS
	WHERE CODZONAS.szonifh = zonifich
	  AND CODZONAS.szona = DETZONAS.szona
	  AND CODZONIF.szonif = zonificacion
	  AND DETZONAS.cprovin = provincia
	  AND DETZONAS.cpoblac IS NULL
	  AND DETZONAS.cpostal IS NULL;
    ELSE
      -- Error, no puede haber CP si la poblacion es nula.
      RAISE NO_CP_NUL;
    END IF;
  ELSE
    -- poblacion no es nula
    IF cp IS NULL THEN
      BEGIN
        SELECT CODZONAS.czona, CODZONAS.szona
          INTO pczona, pszona
	  FROM CODZONIF, CODZONAS,DETZONAS
	  WHERE CODZONAS.szonifh = zonifich
	    AND CODZONAS.szona = DETZONAS.szona
	    AND CODZONIF.szonif = zonificacion
	    AND DETZONAS.cprovin = provincia
	    AND DETZONAS.cpoblac = poblacion
	    AND DETZONAS.cpostal IS NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
	      -- si no hay registros busco por poblacion nula y cp nulo
              SELECT CODZONAS.czona, CODZONAS.szona
                INTO pczona, pszona
		FROM CODZONIF, CODZONAS, DETZONAS
		WHERE CODZONAS.szonifh = zonifich
		  AND CODZONAS.szona = DETZONAS.szona
		  AND CODZONIF.szonif = zonificacion
		  AND DETZONAS.cprovin = provincia
		  AND DETZONAS.cpoblac IS NULL
		  AND DETZONAS.cpostal IS NULL;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
      		  RAISE NO_DATA_FOUND;
            END;
      END;
    -- cp no es nulo
    ELSE
      BEGIN
        SELECT CODZONAS.czona, CODZONAS.szona
          INTO pczona, pszona
	  FROM CODZONIF, CODZONAS,DETZONAS
	  WHERE CODZONAS.szonifh = zonifich
	    AND CODZONAS.szona = DETZONAS.szona
	    AND CODZONIF.szonif = zonificacion
	    AND DETZONAS.cprovin = provincia
	    AND DETZONAS.cpoblac = poblacion
	    AND DETZONAS.cpostal = cp;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
--            dbms_output.put_line(' Erro no hemos encotrado datos  '||zonifich||' '||zonificacion||' '||provincia||' '||poblacion||' '||cp);
            BEGIN
	      -- si no hay registros busco por cp nulo
              SELECT CODZONAS.czona, CODZONAS.szona
                INTO pczona, pszona
		FROM CODZONIF, CODZONAS, DETZONAS
		WHERE CODZONAS.szonifh = zonifich
		  AND CODZONAS.szona = DETZONAS.szona
		  AND CODZONIF.szonif = zonificacion
		  AND DETZONAS.cprovin = provincia
		  AND DETZONAS.cpoblac = poblacion
		  AND DETZONAS.cpostal IS NULL;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   -- caso provincia, NULL, NULL
                   SELECT CODZONAS.czona, CODZONAS.szona
                     INTO pczona, pszona
       	  	       FROM CODZONIF, CODZONAS, DETZONAS
       		       WHERE CODZONAS.szonifh = zonifich
       		         AND CODZONAS.szona = DETZONAS.szona
        		     AND CODZONIF.szonif = zonificacion
       		         AND DETZONAS.cprovin = provincia
       		         AND DETZONAS.cpoblac IS NULL
       		         AND DETZONAS.cpostal IS NULL;
            END;
      END;
    END IF;
  END IF;
  RETURN pczona;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN NO_CP_NUL THEN
      RETURN NULL; -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
    WHEN OTHERS THEN
	  dbms_output.put_line(' Error en f_zona : '||SQLERRM);
      RETURN 1;
END f_zona2;
--------------------------------------------------------------------------------------------
END Pac_Zona;

/

  GRANT EXECUTE ON "AXIS"."PAC_ZONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ZONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ZONA" TO "PROGRAMADORESCSI";
