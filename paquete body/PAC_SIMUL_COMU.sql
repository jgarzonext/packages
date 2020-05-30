--------------------------------------------------------
--  DDL for Package Body PAC_SIMUL_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIMUL_COMU" 
AS

   FUNCTION f_actualiza_riesgo(pssolicit IN NUMBER, pnriesgo IN NUMBER, pfnacimi IN DATE, psexo IN NUMBER,
      pnombre IN VARCHAR2,  ptapelli IN VARCHAR2) RETURN NUMBER IS
	  /*********************************************************************************************************************************
      11-1-2007.  CSI
	  Vida Ahorro
	 Función que modifica los datos del riesgo en la tabla SOLRIESGOS

   ********************************************************************************************************************************/
   BEGIN

      UPDATE SOLRIESGOS SET
	     fnacimi = pfnacimi,
		 csexper = psexo,
		 tnombre = pnombre,
		 tapelli = ptapelli
		 WHERE ssolicit = pssolicit
		 AND nriesgo = pnriesgo;

		 RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
	  	   p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_actualiza_riesgo',NULL,
                       'parametros: ssolicit ='||pssolicit||' pnriesgo ='||pnriesgo||' pfnacimi='||pfnacimi||
                       ' psexo='||psexo||' pnombre='||pnombre||' ptapelli='||ptapelli,
                      SQLERRM);
		   RETURN 108190; -- error general
   END f_actualiza_riesgo;

FUNCTION f_actualiza_asegurado(pssolicit IN NUMBER, pnorden IN NUMBER, pfnacimi IN DATE, psexo IN NUMBER,
      pnombre IN VARCHAR2,  ptapelli IN VARCHAR2) RETURN NUMBER IS
	  /*********************************************************************************************************************************
      11-1-2007.  CSI
	  Vida Ahorro
	 Función que modifica los datos del asegurado en la tabla SOLASEGURADOS

   ********************************************************************************************************************************/
   BEGIN
      UPDATE SOLASEGURADOS SET
	     fnacimi = pfnacimi,
		 csexper = psexo,
		 tnombre = pnombre,
		 tapelli = ptapelli
		 WHERE ssolicit = pssolicit
		 AND norden = pnorden;

		 RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
	  	   p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_actualiza_asegurado',NULL,
                       'parametros: ssolicit ='||pssolicit||' pnorden ='||pnorden||' pfnacimi='||pfnacimi||
                       ' psexo='||psexo||' pnombre='||pnombre||' ptapelli='||ptapelli,
                      SQLERRM);
           RETURN 108190; -- error general
   END f_actualiza_asegurado;

   FUNCTION f_crea_solasegurado (pssolicit IN NUMBER, pnorden IN NUMBER,
      ptapelli IN VARCHAR2 DEFAULT '*', ptnombre IN VARCHAR2 DEFAULT '*', pfnacimi IN DATE DEFAULT NULL,
	  pcsexper IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
	    INSERT INTO SOLASEGURADOS
		     (ssolicit, norden, fnacimi, csexper, tapelli, tnombre)
			VALUES(pssolicit,pnorden, NVL(pfnacimi,f_sysdate),NVL(pcsexper,0), ptapelli, ptnombre
			);

         RETURN 0;

   EXCEPTION
      WHEN OTHERS THEN
		    p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_crea_solasegurado',NULL, 'parametros: ssolicit ='||pssolicit||
                        ' pnorden='||pnorden||' ptapelli='||ptapelli||' ptnombre='||ptnombre||' pfnacimi='||pfnacimi||
                        ' pcsexper='||pcsexper,
                        SQLERRM);
            RETURN 151707;                -- Error al insertar en solasegurados
   END;

   FUNCTION f_actualiza_capital(pssolicit IN NUMBER, pnriesgo IN NUMBER, pcgarant IN NUMBER, picapital IN NUMBER)
    RETURN NUMBER IS
   /*********************************************************************************************************************************
      11-1-2007.  CSI
	  Vida Ahorro
	 Función que modifica el capital de una garantía en la tabla SOLGARANSEG

   ********************************************************************************************************************************/
   	  BEGIN
	     UPDATE SOLGARANSEG SET
		 ICAPITAL = picapital
		 WHERE ssolicit = pssolicit
		 AND nriesgo = pnriesgo
		 AND cgarant = pcgarant;

		 RETURN 0;
      EXCEPTION
	     WHEN OTHERS THEN
		    p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_actualiza_capital',NULL, 'parametros: ssolicit ='||pssolicit||
                        ' pnriesgo ='||pnriesgo||' pcgarant ='||pcgarant||' picapital='||picapital,
                      SQLERRM);
		   RETURN 140266; -- ERROR modificando en la tabla SOLGARANSEG
   END f_actualiza_capital;

   FUNCTION f_actualiza_duracion_periodo(pssolicit IN NUMBER, pndurper IN NUMBER)
    RETURN NUMBER IS
   /*********************************************************************************************************************************
      11-1-2007.  CSI
	  Vida Ahorro
	 Función que modifica la duración del periodo garantizado en SOLSEGUROS_AHO

   ********************************************************************************************************************************/
   	  BEGIN
	     UPDATE SOLSEGUROS_AHO SET
		 NDURPER = pndurper
		 WHERE ssolicit = pssolicit;

		 RETURN 0;
      EXCEPTION
	     WHEN OTHERS THEN
		    p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_actualiza_duracion_periodo',NULL, 'parametros: ssolicit ='||pssolicit||
                        ' pndurper='||pndurper, SQLERRM);
		   RETURN 140266; -- ERROR modificando la tabla sogaranseg
   END f_actualiza_duracion_periodo;

   -- MSR 4/7/2007. Afegir paràmetre pfvencim amb defecte a NULL per no afectar cap programa ja funcionant.
    FUNCTION f_actualiza_duracion(pssolicit IN NUMBER, pndurper IN NUMBER, pfvencim IN DATE DEFAULT NULL)
    RETURN NUMBER IS
   /*********************************************************************************************************************************
      26-2-2007.  CSI
	  Vida Ahorro
	 Función que modifica la duración del periodo garantizado en SOLSEGUROS

   ********************************************************************************************************************************/
   	  BEGIN
	     UPDATE SOLSEGUROS SET
		 NDURACI = pndurper,
		 FVENCIM = NVL(pfvencim,ADD_MONTHS ( FALTA, pndurper * 12))
		 WHERE ssolicit = pssolicit;

         RETURN 0;
      EXCEPTION
	     WHEN OTHERS THEN
		    p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_actualiza_duracion',1, 'parametros: ssolicit ='||pssolicit||
                        ' pndurper='||pndurper||' pfvencim ='||pfvencim, SQLERRM);
		   RETURN 140260; -- Error modificando la tabla SOLSEGUROS
   END f_actualiza_duracion;



   FUNCTION f_ins_inttec (pssolicit IN NUMBER, pfefemov IN DATE, ppinttec IN NUMBER)
      RETURN NUMBER IS
   /*********************************************************************************************************************************
      27-2-2007.  CSI
	  Vida Ahorro
	 Función que inserta el interés técnico en SOLINTERTECSEG

   ********************************************************************************************************************************/
   BEGIN
      INSERT INTO solintertecseg
                        (ssolicit, nmovimi,  fefemov, fmovdia, pinttec
                        )
                 VALUES (pssolicit, 1, trunc(pfefemov), trunc(f_sysdate), ppinttec
                        );

		RETURN 0;

   EXCEPTION
      WHEN OTHERS THEN
		     p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_ins_inttec',NULL, 'parametros: ssolicit ='||pssolicit||
                         ' pfefemov='||pfefemov||' ppinttec='||ppinttec,
                         SQLERRM);
		   RETURN 153048; -- Error insertando datos en la tabla SOLINTERTECSEG
   END;


   FUNCTION f_actualiza_inttec(pssolicit IN NUMBER, ppinttec IN NUMBER)
   RETURN NUMBER IS
   /*********************************************************************************************************************************
      26-2-2007.  CSI
	  Vida Ahorro
	 Función que actualiza el interés técnico en SOLINTERTECSEG

   ********************************************************************************************************************************/
   BEGIN
	     UPDATE SOLINTERTECSEG SET
		 PINTTEC = ppinttec
		 WHERE ssolicit = pssolicit;

		 RETURN 0;
   EXCEPTION
     WHEN OTHERS THEN
		  p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_actualiza_inttec',NULL, 'parametros: ssolicit ='||pssolicit||
                      ' ppinttec='||ppinttec,
                      SQLERRM);
		  RETURN 153047; -- Error modificando la tabla SOLINTERTECSEG
   END f_actualiza_inttec;


   FUNCTION f_ins_simulaestadist (pcagente IN NUMBER, psproduc IN NUMBER, ptipo IN NUMBER)
      RETURN NUMBER IS
   /*********************************************************************************************************************************
      05-3-2007.  CSI
	  Vida Ahorro
	 Función que inserta un registro en SIMULAESTADIST. Se utiliza para llevar un control (hacer estadísticas)
	 de las simulaciones que se han realizado.

   ********************************************************************************************************************************/

	BEGIN
      INSERT INTO SIMULAESTADIST
                        (ssimula, cagente, sproduc,  ctipo, fecha, cusuari, sseguro
                        )
                 VALUES (ssimula.nextval, pcagente, psproduc, ptipo, to_date(to_char(f_sysdate,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss'), f_user, null
                        );

		return 0;

    EXCEPTION
	  WHEN OTHERS THEN
		   p_tab_error(f_sysdate,  F_USER,  'Pac_Simul_Comu.f_ins_simulaestadist',NULL, 'parametros: pcagente ='||pcagente||
                      ' psproduc ='||psproduc||' ptipo ='||ptipo,
                      SQLERRM);
		   RETURN 180044; -- Error insertando datos en la tabla SIMULAESTADIST

	END f_ins_simulaestadist;

END Pac_Simul_Comu;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_COMU" TO "PROGRAMADORESCSI";
