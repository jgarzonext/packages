--------------------------------------------------------
--  DDL for Function FF_CAPGARAN_EUROPLAZO16_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_CAPGARAN_EUROPLAZO16_CALC" (sesion IN NUMBER,
                                       XINICI NUMBER,
                                       pfefecto IN NUMBER,
                                       pfefepol IN NUMBER,
                                       psseguro IN NUMBER,
                                       psproduc IN NUMBER,
                                       pcgarant IN NUMBER,
                                       pnriesgo IN NUMBER,
                                       porigen IN NUMBER,
                                       pnmovimi IN NUMBER,
                                       pnduraci IN NUMBER,
                                       pndurper IN NUMBER,
                                       pfnacimi1 IN NUMBER,
                                       pfnacimi2 IN NUMBER,
                                       psexo1 IN NUMBER,
                                       psexo2 IN NUMBER,
                                       pinttec IN NUMBER,
                                       paccion  IN NUMBER,
                                       pgastos IN NUMBER,
                                       picapital IN NUMBER DEFAULT NULL) RETURN NUMBER AUTHID current_user IS
    FECEFE NUMBER;
    PTIPOINT NUMBER;
    FNACIMI NUMBER;
    FNAC_ASE2 NUMBER;
    PDOSCAB NUMBER;
    SEXO NUMBER;
    SEXO_ASE2 NUMBER;
    SPRODUC NUMBER;
    NBUCLE NUMBER;
    EDAD_X_16 NUMBER;
    EDAD_Y_16 NUMBER;
    LX_GARAN_16 NUMBER;
    LX_MIN_16 NUMBER;
    LX_VENCIM_16 NUMBER;
    LX_ITERA_16 NUMBER;
    LY_GARAN_16 NUMBER;
    LY_MIN_16 NUMBER;
    LY_VENCIM_16 NUMBER;
    LY_ITERA_16 NUMBER;
    GASTOS NUMBER;
    SSEGURO NUMBER;
    NRIESGO NUMBER;
    GARANTIA NUMBER;
    NMOVIMI NUMBER;
    ORIGEN NUMBER;
    ACCION  NUMBER;
    FEFEPOL NUMBER;

    ANYOS_TRANSCURRIDOS NUMBER;
    V_INT_GARAN_16 NUMBER;
    V_INT_MIN_16 NUMBER;
    --TABLA_MORTA NUMBER;
    --TABLA_MORTA_Y NUMBER;
    NVOLTES NUMBER;
    NDURPER NUMBER;
    NDURACI NUMBER;
    PERIODO NUMBER;
    CAP_SUPERVIVE_16 NUMBER;
    PRIMA_GARAN_16 NUMBER;
    PROV_GARAN_16 NUMBER;
    V_INTERES_16 NUMBER;
    DURA_16 NUMBER;
    ITERA_16 NUMBER;
    ITERA_DX2_16 NUMBER;
    COMPO_CAPITAL_16 NUMBER;
    COMPO_PRIMA_16 NUMBER;
    COMPO_D2_16 NUMBER;
    SUM_DX_16 NUMBER;
    SUM_DX2_16 NUMBER;
    SUM_AX_16 NUMBER;
    SUM_CAP_GARAN_Z_16 NUMBER;
    SUM_DX_PRIMA_16 NUMBER;
    SUM_DX2_PRIMA_16 NUMBER;
    SUM_AX_PRIMA_16 NUMBER;
    SUM_DX_CAP_16 NUMBER;
    SUM_AX_CAP_16 NUMBER;
    LXY_GARAN_16 NUMBER;
    LXY_SUPER_16 NUMBER;
    LXY_RECUR_16 NUMBER;
    LXY_DX_ITERA_16 NUMBER;
    LXY_AX_ITERA_16 NUMBER;
    LXY_DX_ITERASUP_16 NUMBER;
    LXY_AX_ITERASUP_16 NUMBER;
    LXY_DX_RECUR_16 NUMBER;
    LXY_AX_RECUR_16 NUMBER;
    CAP_FALL_16 NUMBER;

    -- RSC 22/11/2007 -- Necesarias para la ejecución cuando picapital IS NOT NULL
    xfecha    DATE;
    v_fefecto DATE;
    v_anyo    NUMBER;

    RETORNO NUMBER;
BEGIN

    dbms_output.put_line('ENTRAMOS EN FF_CAPGARAN_EUROPLAZO16************************************************'); 
    FECEFE:= pfefecto;
    PTIPOINT:= pinttec;
    FNACIMI:= pfnacimi1;
    FNAC_ASE2:= pfnacimi2; 
    SEXO:= psexo1;
    SEXO_ASE2:= psexo2;
    SPRODUC:= psproduc;
    NDURPER:= pndurper;
    NDURACI:= pnduraci;
    SSEGURO:= psseguro;
    NRIESGO:= pnriesgo;
    GARANTIA:= pcgarant;
    NMOVIMI:= pnmovimi;
    ORIGEN:= porigen;
    GASTOS:= pgastos;
    ACCION:= paccion;
    FEFEPOL:= pfefepol;
 
    dbms_output.put_line('FECEFE ='||FECEFE);
    V_INT_GARAN_16 := 1/(1+PTIPOINT/100);
    --V_INT_MIN_16 := 1/(1+(VTRAMO(sesion, 370, SPRODUC))/100);
    V_INT_MIN_16 := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));
    dbms_output.put_line('V_INT_MIN_16='||V_INT_MIN_16);

    SELECT DECODE (nvl(SEXO_ASE2,0), 0, 0, 1) INTO PDOSCAB FROM DUAL;
    dbms_output.put_line('SEXO_ASE2='||SEXO_ASE2);
    dbms_output.put_line('PDOSCAB='||PDOSCAB);

    SELECT MONTHS_BETWEEN(TO_DATE(FECEFE, 'YYYYMMDD'),TO_DATE(FEFEPOL, 'YYYYMMDD'))/12 INTO ANYOS_TRANSCURRIDOS FROM DUAL;
    dbms_output.put_line('ANYOS_TRANSCURRIDOS ='||ANYOS_TRANSCURRIDOS);

    EDAD_X_16 := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X_16='||EDAD_X_16);
    EDAD_Y_16 := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);
    dbms_output.put_line('EDAD_Y_16='||EDAD_Y_16);

    --SELECT DECODE(SEXO, 1, 8, 9) INTO TABLA_MORTA FROM DUAL;
    --LX_GARAN_16 := VTRAMO(sesion, TABLA_MORTA, EDAD_X_16);
    LX_GARAN_16 := ff_mortalidad(sesion, 8, EDAD_X_16, SEXO, null, null, 'LX');
    dbms_output.put_line('LX_GARAN_16='||LX_GARAN_16);
    --LX_MIN_16 := VTRAMO(sesion, TABLA_MORTA, EDAD_X_16+NDURPER);
    LX_MIN_16 := ff_mortalidad(sesion, 8, EDAD_X_16+NDURPER, SEXO, null, null, 'LX');
    dbms_output.put_line('LX_MIN_16='||LX_MIN_16);
    --LX_VENCIM_16 := VTRAMO(sesion, TABLA_MORTA, EDAD_X_16+NDURACI);
    LX_VENCIM_16 := ff_mortalidad(sesion, 8, EDAD_X_16+NDURACI, SEXO, null, null, 'LX');
    dbms_output.put_line('LX_VENCIM_16='||LX_VENCIM_16);

    --SELECT DECODE(SEXO_ASE2, 1, 8, 9) INTO TABLA_MORTA_Y FROM DUAL;
    --LY_GARAN_16 := VTRAMO(sesion, TABLA_MORTA_Y, EDAD_Y_16);
    LY_GARAN_16 := ff_mortalidad(sesion, 8, EDAD_Y_16, SEXO_ASE2, null, null, 'LX');
    dbms_output.put_line('LY_GARAN_16='||LY_GARAN_16);

    --LY_MIN_16 := VTRAMO(sesion, TABLA_MORTA_Y, EDAD_Y_16+NDURPER);
    LY_MIN_16 := ff_mortalidad(sesion, 8, EDAD_Y_16+NDURPER, SEXO_ASE2, null, null, 'LX');
    dbms_output.put_line('LY_MIN_16='||LY_MIN_16);
    --LY_VENCIM_16 := VTRAMO(sesion, TABLA_MORTA_Y, EDAD_Y_16+NDURACI);
    LY_VENCIM_16 := ff_mortalidad(sesion, 8, EDAD_Y_16+NDURACI, SEXO_ASE2, null, null, 'LX');
    dbms_output.put_line('LY_VENCIM_16='||LY_VENCIM_16);

    SELECT DECODE (PDOSCAB, 0, LX_MIN_16 / LX_GARAN_16,
                            LX_MIN_16 / LX_GARAN_16 + LY_MIN_16 / LY_GARAN_16
                            - LX_MIN_16 * LY_MIN_16 / (LX_GARAN_16 * LY_GARAN_16) )
    INTO LXY_GARAN_16 FROM DUAL;
        
                
    SELECT DECODE (PDOSCAB, 0, LX_VENCIM_16 / LX_MIN_16,
                            LX_VENCIM_16 / LX_MIN_16 + LY_VENCIM_16 / LY_MIN_16
                            - LX_VENCIM_16 * LY_VENCIM_16 / (LX_MIN_16 * LY_MIN_16)) 
    INTO LXY_SUPER_16 FROM DUAL;

    -- Calculamos la Provisión garantizada al final del periodo n
    NBUCLE := NDURPER;
    SUM_DX_PRIMA_16 := 0;
    FOR NITERAC IN 1 .. NBUCLE LOOP

        SELECT DECODE (PDOSCAB, 0, ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'DX') / LX_GARAN_16,
                        ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'DX')
                          * ff_mortalidad(sesion, 8, EDAD_Y_16+NITERAC-1, SEXO_ASE2, null, null, 'DX') /(LX_GARAN_16*LY_GARAN_16)
                        + (ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'DX') / LX_GARAN_16)
                           * (1 - ff_mortalidad(sesion, 8, EDAD_Y_16+NITERAC-1, SEXO_ASE2, null, null, 'LX')/LY_GARAN_16) 
                        + (ff_mortalidad(sesion, 8, EDAD_Y_16+NITERAC-1, SEXO_ASE2, null, null, 'DX') / LY_GARAN_16)
                           * (1 - ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'LX')/LX_GARAN_16) 
                       )
        INTO LXY_DX_ITERA_16 FROM DUAL;

        SUM_DX_PRIMA_16 := SUM_DX_PRIMA_16 + POWER(V_INT_GARAN_16, NITERAC-1+0.5) * LXY_DX_ITERA_16; 
    --dbms_output.put_line('v1-'||NITERAC||'= '||POWER(V_INT_GARAN_16, NITERAC-1+0.5));
    --dbms_output.put_line('dX1-'||NITERAC||'= '||(VTRAMO(sesion, TABLA_MORTA, EDAD_X_16+NITERAC-1)-VTRAMO(sesion, TABLA_MORTA, EDAD_X_16+NITERAC)));
    --dbms_output.put_line('LX_permf2000-'||NITERAC||'='||ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null,null,'DX'));
    --dbms_output.put_line('DX1/lx-'||NITERAC||'= '||((VTRAMO(sesion, TABLA_MORTA, EDAD_X_16+NITERAC-1)-VTRAMO(sesion, TABLA_MORTA, EDAD_X_16+NITERAC)) / LX_GARAN_16));
    END LOOP;
    dbms_output.put_line('SUM_DX_PRIMA_16='||SUM_DX_PRIMA_16);
  
    NBUCLE := NDURPER;
    SUM_DX2_PRIMA_16 := 0;
    FOR NITERAC IN 1 .. NBUCLE LOOP

        SELECT DECODE (PDOSCAB, 0, ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'DX') / LX_GARAN_16,
                        ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'DX')
                          * ff_mortalidad(sesion, 8, EDAD_Y_16+NITERAC-1, SEXO_ASE2, null, null, 'DX') /(LX_GARAN_16*LY_GARAN_16)
                        + (ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'DX') / LX_GARAN_16)
                           * (1 - ff_mortalidad(sesion, 8, EDAD_Y_16+NITERAC-1, SEXO_ASE2, null, null, 'LX')/LY_GARAN_16) 
                        + (ff_mortalidad(sesion, 8, EDAD_Y_16+NITERAC-1, SEXO_ASE2, null, null, 'DX') / LY_GARAN_16)
                           * (1 - ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'LX')/LX_GARAN_16) 
                       )
        INTO LXY_DX_ITERA_16 FROM DUAL;

        SUM_DX2_PRIMA_16 := SUM_DX2_PRIMA_16 + (NITERAC-1) *POWER(V_INT_GARAN_16, NITERAC-1+0.5) *LXY_DX_ITERA_16;
     
    END LOOP;
    dbms_output.put_line('SUM_DX2_PRIMA_16='||SUM_DX2_PRIMA_16);
  
    NBUCLE := NDURPER;
    SUM_AX_PRIMA_16 := 0;
    FOR NITERAC IN 1 .. NBUCLE LOOP

        SELECT DECODE (PDOSCAB, 0, ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'LX') / LX_GARAN_16,
                                ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'LX') / LX_GARAN_16 
                                + ff_mortalidad(sesion, 8, EDAD_Y_16+NITERAC-1, SEXO_ASE2, null, null, 'LX') / LY_GARAN_16
                                - ff_mortalidad(sesion, 8, EDAD_X_16+NITERAC-1, SEXO, null, null, 'LX') 
                                  * ff_mortalidad(sesion, 8, EDAD_Y_16+NITERAC-1, SEXO_ASE2, null, null, 'LX') / (LX_GARAN_16 * LY_GARAN_16) )
        INTO LXY_AX_ITERA_16 FROM DUAL;

        SUM_AX_PRIMA_16 := SUM_AX_PRIMA_16 + POWER(V_INT_GARAN_16, NITERAC-1) * LXY_AX_ITERA_16;
     
    END LOOP;
    dbms_output.put_line('SUM_AX_PRIMA_16='||SUM_AX_PRIMA_16);
    IF picapital IS NOT NULL THEN
      dbms_output.put_line('CAPITAL='||picapital);
    ELSE
      dbms_output.put_line('CAPITAL='||RESP(sesion, 1001));
    END IF;
    dbms_output.put_line('NDURPER='||NDURPER);

    GASTOS := GASTOS/100;

    IF picapital IS NOT NULL THEN
      PRIMA_GARAN_16 := (picapital * (1 - SUM_DX_PRIMA_16 + (1/NDURPER)*SUM_DX2_PRIMA_16)) 
              /(POWER(V_INT_GARAN_16, NDURPER) * LXY_GARAN_16 
                + (1/NDURPER)*SUM_DX2_PRIMA_16 + GASTOS * SUM_AX_PRIMA_16);
    ELSE
      PRIMA_GARAN_16 := (RESP(sesion, 1001) * (1 - SUM_DX_PRIMA_16 + (1/NDURPER)*SUM_DX2_PRIMA_16)) 
                /(POWER(V_INT_GARAN_16, NDURPER) * LXY_GARAN_16 
                  + (1/NDURPER)*SUM_DX2_PRIMA_16 + GASTOS * SUM_AX_PRIMA_16);
    END IF;

    dbms_output.put_line('Gastos='||GASTOS);
    dbms_output.put_line('PRIMA_GARAN_16='||PRIMA_GARAN_16);

    -- Calculamos el Capital de supervivencia al vencimiento
    NBUCLE := NDURACI-NDURPER-ANYOS_TRANSCURRIDOS;
    SUM_DX_CAP_16 := 0;
    FOR NITERAC IN 1 .. NBUCLE LOOP

        SELECT DECODE (PDOSCAB, 0, ff_mortalidad(sesion, 8, EDAD_X_16+NDURPER+NITERAC-1, SEXO, null, null, 'DX') / LX_MIN_16,
                        ff_mortalidad(sesion, 8, EDAD_X_16+NDURPER+NITERAC-1, SEXO, null, null, 'DX')
                          * ff_mortalidad(sesion, 8, EDAD_Y_16+NDURPER+NITERAC-1, SEXO_ASE2, null, null, 'DX') /(LX_MIN_16*LY_MIN_16)
                        + (ff_mortalidad(sesion, 8, EDAD_X_16+NDURPER+NITERAC-1, SEXO, null, null, 'DX') / LX_MIN_16)
                           * (1 - ff_mortalidad(sesion, 8, EDAD_Y_16+NDURPER+NITERAC-1, SEXO_ASE2, null, null, 'LX')/LY_MIN_16) 
                        + (ff_mortalidad(sesion, 8, EDAD_Y_16+NDURPER+NITERAC-1, SEXO_ASE2, null, null, 'DX') / LY_MIN_16)
                           * (1 - ff_mortalidad(sesion, 8, EDAD_X_16+NDURPER+NITERAC-1, SEXO, null, null, 'LX')/LX_MIN_16) 
                       )
        INTO LXY_DX_ITERASUP_16 FROM DUAL;

        SUM_DX_CAP_16 := SUM_DX_CAP_16 + POWER(V_INT_MIN_16, NITERAC-1+0.5) * LXY_DX_ITERASUP_16;
      
    END LOOP;
    --dbms_output.put_line('SUM_DX_CAP_16='||SUM_DX_CAP_16);
  
    NBUCLE := NDURACI-NDURPER-ANYOS_TRANSCURRIDOS;
    SUM_AX_CAP_16 := 0;
    FOR NITERAC IN 1 .. NBUCLE LOOP

        SELECT DECODE (PDOSCAB, 0, ff_mortalidad(sesion, 8, EDAD_X_16+NDURPER+NITERAC-1, SEXO, null, null, 'LX') / LX_MIN_16,
                                ff_mortalidad(sesion, 8, EDAD_X_16+NDURPER+NITERAC-1, SEXO, null, null, 'LX') / LX_MIN_16 
                                + ff_mortalidad(sesion, 8, EDAD_Y_16+NDURPER+NITERAC-1, SEXO_ASE2, null, null, 'LX') / LY_MIN_16
                                - ff_mortalidad(sesion, 8, EDAD_X_16+NDURPER+NITERAC-1, SEXO, null, null, 'LX') 
                                  * ff_mortalidad(sesion, 8, EDAD_Y_16+NDURPER+NITERAC-1, SEXO_ASE2, null, null, 'LX') / (LX_MIN_16 * LY_MIN_16) )
        INTO LXY_AX_ITERASUP_16 FROM DUAL;

        SUM_AX_CAP_16 := SUM_AX_CAP_16 + POWER(V_INT_MIN_16, NITERAC-1)*LXY_AX_ITERASUP_16;
     
    --dbms_output.put_line('SUM_AX_CAP_16('||Niterac||')='||(POWER(V_INT_MIN_16, NITERAC-1)
    --      *VTRAMO(sesion, TABLA_MORTA, EDAD_X_16+NDURPER+NITERAC-1) / LX_MIN_16) );
    END LOOP;
    --dbms_output.put_line('SUM_AX_CAP_16='||SUM_AX_CAP_16);

    CAP_SUPERVIVE_16 := (PRIMA_GARAN_16 * (1 - SUM_DX_CAP_16)) 
            /(POWER(V_INT_MIN_16, NDURACI-NDURPER) * LXY_SUPER_16 
              + GASTOS * SUM_AX_CAP_16);
    dbms_output.put_line('CAP_SUPERVIVE_16='||CAP_SUPERVIVE_16);

    -- Calculamos las Provisiones garantizadas
    NVOLTES := XINICI;
    SUM_CAP_GARAN_Z_16 := 0;
    FOR NRECURS IN 1 .. NVOLTES LOOP

      PERIODO := SIGN (NDURPER-NRECURS+1);
    dbms_output.put_line('PERIODO-'||NRECURS||'='||PERIODO);

      SELECT DECODE (PERIODO, 1, PRIMA_GARAN_16, CAP_SUPERVIVE_16) 
      INTO COMPO_CAPITAL_16 FROM DUAL; 

      IF picapital IS NOT NULL THEN
        SELECT DECODE (PERIODO, 1, picapital + (PRIMA_GARAN_16 - picapital)*NRECURS/NDURPER, PRIMA_GARAN_16) 
        INTO COMPO_PRIMA_16 FROM DUAL; 
      ELSE
        SELECT DECODE (PERIODO, 1, RESP(sesion, 1001) + (PRIMA_GARAN_16 - RESP(sesion, 1001))*NRECURS/NDURPER, PRIMA_GARAN_16) 
        INTO COMPO_PRIMA_16 FROM DUAL; 
      END IF;
  

      SELECT DECODE (PERIODO, 1, V_INT_GARAN_16, V_INT_MIN_16) 
      INTO V_INTERES_16 FROM DUAL; 
  
      SELECT DECODE (PERIODO, 1, NDURPER, NDURACI) INTO DURA_16 FROM DUAL; 

      SELECT (DURA_16 - NRECURS) INTO ITERA_16 FROM DUAL; 
  
      SELECT DECODE (PERIODO, 1, ITERA_16, 0) INTO ITERA_DX2_16 FROM DUAL; 
  
    --  LX_ITERA_16 := VTRAMO(sesion, TABLA_MORTA, EDAD_X_16+NRECURS);
    --  LY_ITERA_16 := VTRAMO(sesion, TABLA_MORTA_Y, EDAD_Y_16+NRECURS);
      LX_ITERA_16 := ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS, SEXO, null, null, 'LX');
      LY_ITERA_16 := ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS, SEXO_ASE2, null, null, 'LX');

      NBUCLE := ITERA_16;
      SUM_DX_16 := 0;
      FOR NITERAC IN 1 .. NBUCLE LOOP
            SELECT DECODE (PDOSCAB, 0, ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'DX') / LX_ITERA_16,
                            ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'DX')
                              * ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS+NITERAC-1, SEXO_ASE2, null, null, 'DX') /(LX_ITERA_16*LY_ITERA_16)
                            + (ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'DX') / LX_ITERA_16)
                               * (1 - ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS+NITERAC-1, SEXO_ASE2, null, null, 'LX')/LY_ITERA_16) 
                            + (ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS+NITERAC-1, SEXO_ASE2, null, null, 'DX') / LY_ITERA_16)
                               * (1 - ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'LX')/LX_ITERA_16) 
                           )
            INTO LXY_DX_RECUR_16 FROM DUAL;
            SUM_DX_16 := SUM_DX_16 + POWER(V_INTERES_16, NITERAC-1+0.5) * LXY_DX_RECUR_16; 
      END LOOP;
    dbms_output.put_line('SUM_DX_16-'||NRECURS||'='||SUM_DX_16);
  
      NBUCLE := ITERA_DX2_16;
      SUM_DX2_16 := 0;
      FOR NITERAC IN 1 .. NBUCLE LOOP
            SELECT DECODE (PDOSCAB, 0, ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'DX') / LX_ITERA_16,
                            ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'DX')
                              * ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS+NITERAC-1, SEXO_ASE2, null, null, 'DX') /(LX_ITERA_16*LY_ITERA_16)
                            + (ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'DX') / LX_ITERA_16)
                               * (1 - ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS+NITERAC-1, SEXO_ASE2, null, null, 'LX')/LY_ITERA_16) 
                            + (ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS+NITERAC-1, SEXO_ASE2, null, null, 'DX') / LY_ITERA_16)
                               * (1 - ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'LX')/LX_ITERA_16) 
                           )
            INTO LXY_DX_RECUR_16 FROM DUAL;
            SUM_DX2_16 := SUM_DX2_16 + (NITERAC-1) * POWER(V_INTERES_16, NITERAC-1+0.5) * LXY_DX_RECUR_16; 
      END LOOP;
    dbms_output.put_line('SUM_DX2_16-'||NRECURS||'='||SUM_DX2_16);
  
      NBUCLE := ITERA_16;
      SUM_AX_16 := 0;
      FOR NITERAC IN 1 .. NBUCLE LOOP
            SELECT DECODE (PDOSCAB, 0, ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'LX') / LX_ITERA_16,
                                    ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'LX') / LX_ITERA_16 
                                    + ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS+NITERAC-1, SEXO_ASE2, null, null, 'LX') / LY_ITERA_16
                                    - ff_mortalidad(sesion, 8, EDAD_X_16+NRECURS+NITERAC-1, SEXO, null, null, 'LX') 
                                      * ff_mortalidad(sesion, 8, EDAD_Y_16+NRECURS+NITERAC-1, SEXO_ASE2, null, null, 'LX') 
                                      / (LX_ITERA_16 * LY_ITERA_16) )
            INTO LXY_AX_RECUR_16 FROM DUAL;
            SUM_AX_16 := SUM_AX_16 + POWER(V_INTERES_16, NITERAC-1) * LXY_AX_RECUR_16; 
      END LOOP;
    dbms_output.put_line('SUM_AX_16-'||NRECURS||'='||SUM_AX_16);
  
      IF picapital IS NOT NULL THEN
        SELECT DECODE (PERIODO, 1, (PRIMA_GARAN_16 - picapital)/NDURPER*SUM_DX2_16, 0) INTO COMPO_D2_16 FROM DUAL; 
        dbms_output.put_line('COMPO_D2_16-'||NRECURS||'='||COMPO_D2_16);
      ELSE
        SELECT DECODE (PERIODO, 1, (PRIMA_GARAN_16 - RESP(sesion, 1001))/NDURPER*SUM_DX2_16, 0) INTO COMPO_D2_16 FROM DUAL; 
        dbms_output.put_line('COMPO_D2_16-'||NRECURS||'='||COMPO_D2_16);
      END IF;

      SELECT DECODE (PDOSCAB, 0, DECODE (PERIODO, 1, LX_MIN_16, LX_VENCIM_16) / LX_ITERA_16,
                            DECODE (PERIODO, 1, LX_MIN_16, LX_VENCIM_16) / LX_ITERA_16
                            + DECODE (PERIODO, 1, LY_MIN_16, LY_VENCIM_16) / LY_ITERA_16
                            - DECODE (PERIODO, 1, LX_MIN_16, LX_VENCIM_16) 
                              * DECODE (PERIODO, 1, LY_MIN_16, LY_VENCIM_16) 
                              / (LX_ITERA_16 * LY_ITERA_16) )
      INTO LXY_RECUR_16 FROM DUAL;
    dbms_output.put_line('LXY_RECUR_16-'||NRECURS||'= '||LXY_RECUR_16);

      PROV_GARAN_16:=  COMPO_CAPITAL_16 * POWER(V_INTERES_16, ITERA_16) * LXY_RECUR_16
            + COMPO_PRIMA_16 * SUM_DX_16 
            + COMPO_D2_16
            + COMPO_CAPITAL_16 * GASTOS * SUM_AX_16; 
    dbms_output.put_line('PROV_GARAN_16-'||NRECURS||'= '||PROV_GARAN_16);

      IF picapital IS NOT NULL THEN
        SELECT DECODE (PERIODO, 1, picapital+(NRECURS-1)*(PRIMA_GARAN_16-picapital)/NDURPER,NULL) 
        INTO CAP_FALL_16 FROM DUAL;
      ELSE
        SELECT DECODE (PERIODO, 1, RESP(sesion, 1001)+(NRECURS-1)*(PRIMA_GARAN_16-RESP(sesion, 1001))/NDURPER,NULL) 
        INTO CAP_FALL_16 FROM DUAL;
      END IF;
  
      IF picapital IS NOT NULL THEN
        xfecha := TO_DATE(FECEFE,'yyyymmdd');

        IF ORIGEN = 0 THEN
            if ACCION = 3 then  -- renovación
               select falta into v_fefecto from solseguros where ssolicit = sseguro;
               v_anyo := NRECURS + trunc(months_between(xfecha, v_fefecto)/12);
            ELSE
               v_anyo := NRECURS;
            END IF;
        ELSIF ORIGEN = 1 THEN
            if ACCION = 3 then --RENOVACION
               select fefecto into v_fefecto from estseguros where sseguro = sseguro;
               v_anyo := NRECURS + trunc(months_between(xfecha, v_fefecto)/12);
            ELSE
               v_anyo := NRECURS;
            END IF;
        ELSE
            if ACCION = 3 then --RENOVACIÓN
               select fefecto into v_fefecto from seguros where sseguro = sseguro;
               v_anyo := NRECURS + trunc(months_between(xfecha, v_fefecto)/12);
            ELSE
               v_anyo := NRECURS;
            END IF;
        END IF;
  
        IF NDURACI IS NULL OR NDURACI = v_anyo THEN
          SUM_CAP_GARAN_Z_16 := SUM_CAP_GARAN_Z_16 + PROV_GARAN_16;
        END IF;
      ELSE
        SUM_CAP_GARAN_Z_16 := SUM_CAP_GARAN_Z_16 
                                + ff_graba_provisio(sesion, SSEGURO, NMOVIMI, FECEFE, NRECURS, NDURACI, ORIGEN, 
                                        SPRODUC, PROV_GARAN_16, ((1/V_INTERES_16)-1)*100, CAP_FALL_16, accion);
      END IF;
    END LOOP;

    Retorno :=  SUM_CAP_GARAN_Z_16;
    RETURN Retorno;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_CAPGARAN_EUROPLAZO16_CALC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_CAPGARAN_EUROPLAZO16_CALC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_CAPGARAN_EUROPLAZO16_CALC" TO "PROGRAMADORESCSI";
