--------------------------------------------------------
--  DDL for Package Body PK_FIS_MOD347
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_FIS_MOD347" AS
-- ********************************************************
  PROCEDURE inicializa (psfiscab IN NUMBER,perror OUT NUMBER) IS
-- ********************************************************
  BEGIN
	PERROR := 0;
	NSFISCAB := PSFISCAB;
  EXCEPTION
    WHEN OTHERS THEN
      PERROR := 1;
  END inicializa;
-- ********************************************************
  PROCEDURE BORRAR (psfiscab IN NUMBER,perror OUT NUMBER) IS
-- ********************************************************
  BEGIN
    DELETE FIS_MOD347 WHERE SFISCAB=psfiscab;
	DELETE FIS_ERROR_CARGA WHERE SFISCAB = psfiscab;
	PERROR := 0;
	NSFISCAB := PSFISCAB;
	COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      PERROR := 1;
  END BORRAR;

-- ****************************************************************
-- Carga de la tabla FIS_MOD347
-- ****************************************************************
PROCEDURE carga_MOD347 (psfiscab   IN NUMBER,
						pleidos   OUT NUMBER,
						pgrabad   OUT NUMBER,
						prechaz   OUT NUMBER,
						perror    OUT NUMBER) IS

  CURSOR c_mod IS
         SELECT d.sfiscab,d.nnumnifp,d.nnumnif1,
		        RTRIM(LTRIM(P.TAPELLI))||' '||RTRIM(LTRIM(P.TNOMBRE))TOTNOM,
		        d.cprovin,d.cpaisret,SUM(d.IIMPORTE)IMPORTE
           FROM FIS_DETCIERRECOBRO d, personas p
          WHERE d.sfiscab = psfiscab
		    AND d.spersonp = p.sperson
            AND d.csubtipo = 347
		HAVING SUM(d.IIMPORTE) > 3005.06
        GROUP BY sfiscab,nnumnifp,nnumnif1,
		 RTRIM(LTRIM(P.TAPELLI))||' '||RTRIM(LTRIM(P.TNOMBRE)),cprovin,cpaisret
	ORDER BY sfiscab,nnumnifp,nnumnif1,cprovin,cpaisret;

  XNIFDEC   VARCHAR2(09);
  XNNIFPER  VARCHAR2(09);
  XNNIFREP  VARCHAR2(09);
  XTNOMPER  VARCHAR2(40);
  XCPROVIN  VARCHAR2(02);
  XCCLAVE   VARCHAR2(01);
-- ------------------------------------------------------------
 BEGIN
  pleidos := 0;
  pgrabad := 0;
  prechaz := 0;
  perror  := 0;

  FOR reg IN c_mod LOOP
   BEGIN
	pleidos := pleidos + 1;
        -- Nif del declarante por producto
    XNIFDEC := NULL; XTNOMPER := NULL; XCPROVIN := NULL;
    XCCLAVE := NULL; XNNIFPER:= NULL;  XNNIFREP := NULL;
	xnifdec := 'A58774308';

    -- Nif del Perceptor
	IF reg.NNUMNIF1 IS NOT NULL THEN -- Si es un menor Nif del perceptor=blanco.
	   XNNIFPER := NULL;
	   XNNIFREP := Pk_Fis_Hacienda.DNI_POS(reg.NNUMNIF1);
	ELSE
	   XNNIFPER := Pk_Fis_Hacienda.DNI_POS(reg.NNUMNIFP);
	   XNNIFREP := NULL;
	END IF;

	-- Nombre y Año de nacimiento del declarado
	XTNOMPER := reg.TOTNOM;
    xtnomper := REPLACE(REPLACE(REPLACE(REPLACE(
			    REPLACE(REPLACE(REPLACE(xtnomper,'.',' '),'0','O')
                      ,'  ',' '),'ª',' '),'  ',' '),'#','Ñ'),'Á','A');
	-- Provincia del declarado
	xcprovin := reg.cprovin;
	IF XCPROVIN IS NULL OR XCPROVIN = 0 THEN
	   XCPROVIN := 8;
	END IF;

-- Grabo los datos
    BEGIN
	    INSERT INTO FIS_MOD347 (SFISCAB,NNIFDEC,NNIFPER,NNIFREP,TNOMPER,CPROVIN,
	             CPAIS,CCLAVE,IMPORTE,CERROR)
	     VALUES (reg.sfiscab,xnifdec,xnnifper,xnnifrep,xtnomper,
	             REPLACE(LPAD(xcprovin,2),' ','0'),
				 DECODE(reg.cpaisret,100,0,reg.cpaisret),'B',reg.importe,NULL);
	    pgrabad := pgrabad + 1;
        COMMIT;
	EXCEPTION
	    WHEN OTHERS THEN
	     perror := perror + 1;
    END;
--
   EXCEPTION
     WHEN OTHERS THEN
	      perror := perror + 1;
   END;
  END LOOP;
 END;
-- ********************************************************
  PROCEDURE obtener_datos_cab IS
-- ********************************************************
  BEGIN
    Pk_Fis_Mod347.tr0_ntotdec := 0;
	Pk_Fis_Mod347.tr0_ntotper := 0;
    Pk_Fis_Mod347.tr1_ntotpos := 0;
    Pk_Fis_Mod347.tr1_itotoper:= 0;
    Pk_Fis_Mod347.tr1_ntotinm := 0;
    Pk_Fis_Mod347.tr1_itotinm := 0;

  EXCEPTION
    WHEN OTHERS THEN
      Pk_Autom.traza(Pk_Autom.TRAZAS,1,SQLERRM);
  END obtener_datos_cab;
-- ********************************************************
  PROCEDURE lee IS
-- ********************************************************
  BEGIN
     IF NOT Pk_Fis_Mod347.c_MOD347%ISOPEN THEN
      OPEN Pk_Fis_Mod347.c_MOD347(NSFISCAB);
    END IF;
    FETCH c_MOD347
     INTO Pk_Fis_Mod347.tr2_nnifdec,
	 	  Pk_Fis_Mod347.tr2_nnifper,
          Pk_Fis_Mod347.tr2_nnifrep,
          Pk_Fis_Mod347.tr2_tnomper,
          Pk_Fis_Mod347.tr2_cprovin,
          Pk_Fis_Mod347.tr2_cpais,
          Pk_Fis_Mod347.tr2_cclave,
          Pk_Fis_Mod347.tr2_impoper;

    IF Pk_Fis_Mod347.c_MOD347%NOTFOUND THEN
      Pk_Fis_Mod347.v_fin := TRUE;
      CLOSE Pk_Fis_Mod347.c_MOD347;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Pk_Autom.traza(Pk_Autom.TRAZAS,1,SQLERRM);
  END lee;
-- ********************************************************
  FUNCTION fin RETURN BOOLEAN IS
-- ********************************************************
  BEGIN
    RETURN Pk_Fis_Mod347.v_fin;
  END fin;
END Pk_Fis_Mod347;

/

  GRANT EXECUTE ON "AXIS"."PK_FIS_MOD347" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FIS_MOD347" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FIS_MOD347" TO "PROGRAMADORESCSI";
