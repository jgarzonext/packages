--------------------------------------------------------
--  DDL for Package Body PAC_MD_SIN_FRANQUICIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SIN_FRANQUICIAS" AS
/******************************************************************************
   NOMBRE    : PAC_MD_SIN_FRANQUICIAS
   ARCHIVO   : PAC_MD_SIN_FRANQUICIAS.sql
   PROPÓSITO : Package con funciones propias de la funcionalidad de Franquicias en siniestros

   REVISIONES:
   Ver    Fecha      Autor     Descripción
   ------ ---------- --------- ------------------------------------------------
   1.0    22-01-2014  NSS      Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   e_aux_error  EXCEPTION;

   FUNCTION f_fran_tot(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_importe IN NUMBER,
      p_fecha IN DATE,
      p_ifranq OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100) := '';
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(200) := 'PAC_MD_SINIESTROS.f_fran_tot';
      vnmovimi       NUMBER;
   BEGIN
      vnumerr := pac_sin_franquicias.f_get_nmovimi_gar(p_sseguro, p_cgarant, p_fecha,
                                                       vnmovimi);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, p_ifranq);
         RAISE e_object_error;
      END IF;

      p_ifranq := pac_sin_franquicias.f_fran_tot(p_sseguro, vnmovimi, p_nriesgo, p_cgarant,
                                                 p_importe, NULL);

      IF p_ifranq = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, p_ifranq);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_fran_tot;
   
    /*calcular deducible IFRANQ  para realizar un pago
      f_calcular_deducible 
      ANB: 30/07/2019
      */
   FUNCTION f_calcular_deducible(
        psseguro IN NUMBER,
		pnriesgo IN  NUMBER,
		pcgarant IN NUMBER,
		isinret IN NUMBER,
        p_nmovimi IN NUMBER,
		ifranqui OUT NUMBER,
        mensajes OUT t_iax_mensajes)
		
      RETURN NUMBER IS
       vpasexec       NUMBER := 1;
       vnumerr       NUMBER := 0;
       vparam         VARCHAR2(100) := psseguro||'-'||pnriesgo ||'-'||pcgarant ||'-'|| isinret;
       vobjectname    VARCHAR2(200) := 'PAC_MD_SIN_FRANQUICIAS.f_calcular_deducible';
      
	    V_MOVIMIENTO NUMBER;
		V_SALARIOMIN NUMBER;
		V_FECHA DATE;
		V_MONEDA STRING(10);
		V_PRODUC NUMBER;
		
		PCVALOR1 NUMBER;
		PIMPVALOR1 NUMBER;
		PCIMPMIN NUMBER;
		PIMPMIN NUMBER;
		AUXCALCULO NUMBER;
	
        PCRAMO NUMBER;
		VTASA NUMBER;
	
   BEGIN
   
    SELECT CRAMO  INTO PCRAMO FROM SEGUROS WHERE SSEGURO=psseguro;   
         IF PCRAMO=801 THEN 
         ifranqui:=0;
         RETURN 0;
         END IF;
   
    -- obtenemos el tipo de moneda 
    BEGIN
      SELECT SPRODUC  INTO V_PRODUC FROM SEGUROS WHERE SSEGURO=psseguro;
      V_MONEDA:= pac_monedas.f_cmoneda_t (pac_monedas.f_moneda_producto(V_PRODUC));
      EXCEPTION
      WHEN OTHERS THEN
      V_MONEDA:='COP';       
     END;
	 
	 -- obtenemos el valor del salario minimo acorde a el tipo de moneda bug 4714
	 BEGIN 
    SELECT  pac_eco_tipocambio.f_importe_cambio
       ('SMV','COP',  pac_eco_tipocambio.f_fecha_max_cambio('COP', 'SMV', f_sysdate), 1 )  INTO V_SALARIOMIN FROM DUAL; 
        
       IF V_MONEDA != 'COP' THEN
       SELECT  pac_eco_tipocambio.f_cambio( V_MONEDA,  'COP',f_sysdate) INTO VTASA FROM DUAL;
       V_SALARIOMIN :=V_SALARIOMIN/VTASA;
       END IF;
          
          
     EXCEPTION
      WHEN OTHERS THEN
      -- salario minimo 2019 por defecto
      V_SALARIOMIN:=828116;
     END;

		  
		   SELECT CVALOR1,IMPVALOR1,CIMPMIN,IMPMIN 
			 INTO PCVALOR1,PIMPVALOR1,PCIMPMIN,PIMPMIN FROM BF_BONFRANSEG BF WHERE SSEGURO =psseguro AND 
			 NMOVIMI= (SELECT MAX(NMOVIMI) FROM BF_BONFRANSEG bb WHERE BB.SSEGURO =BF.SSEGURO AND BB.CGRUP = BF.CGRUP) -- BUG-4723
			 AND 
			 CGRUP=(
					SELECT CODGRUP FROM BF_PROGARANGRUP WHERE CGARANT=pcgarant AND 
					CACTIVI=(SELECT CACTIVI FROM SEGUROS WHERE SSEGURO = psseguro) -- BUG-4723
					AND SPRODUC=(
					SELECT SPRODUC FROM SEGUROS WHERE SSEGURO=psseguro)); 
					
					 IF V_MONEDA != 'COP' THEN
                         IF VTASA!=NULL THEN
                         RAISE e_aux_error;
                         END IF;
                         IF PCVALOR1 =2 THEN
                         PIMPVALOR1 :=PIMPVALOR1/VTASA;
                         END IF;
                         IF PCIMPMIN=2 THEN
                         PIMPMIN :=PIMPMIN/VTASA;
                         END IF;
                      
                     END IF;
       
--PCVALOR1 SI ES : 1= PORCENTAJE 2= IMPORTE FIJO  Y PCIMPMIN SI ES:  2= IMPORTE FIJO 4= SALARIOS MINIMOS;
	   
     IF PCVALOR1=2 AND   PCIMPMIN=2  THEN
            IF PIMPVALOR1<PIMPMIN THEN 
            ifranqui:=PIMPMIN;
            ELSE
            ifranqui:=PIMPVALOR1;
            END IF;
     ELSIF PCVALOR1=1 AND   PCIMPMIN=2 THEN 
     
        AUXCALCULO:=(ISINRET*PIMPVALOR1)/100; 
        
            IF AUXCALCULO<PIMPMIN THEN 
            ifranqui:=PIMPMIN;
            ELSE
            ifranqui:=AUXCALCULO;
            END IF;
     ELSIF  PCVALOR1=1 AND PCIMPMIN=4 THEN  
     
          AUXCALCULO:=(ISINRET*PIMPVALOR1)/100;
          
          IF AUXCALCULO>(V_SALARIOMIN*PIMPMIN) THEN
          ifranqui:=AUXCALCULO;
          ELSE
          ifranqui:=(V_SALARIOMIN*PIMPMIN);
          END IF;
      ELSIF  PCVALOR1=2 AND PCIMPMIN=4 THEN 
      
      AUXCALCULO:=(V_SALARIOMIN*PIMPMIN);
       IF PIMPVALOR1<AUXCALCULO THEN 
            ifranqui:=AUXCALCULO;
            ELSE
            ifranqui:=PIMPVALOR1;
            END IF;
     END IF;
		     
      RETURN 0;
	  
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vnumerr;
   END f_calcular_deducible;
   
END pac_md_sin_franquicias;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FRANQUICIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FRANQUICIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FRANQUICIAS" TO "PROGRAMADORESCSI";
