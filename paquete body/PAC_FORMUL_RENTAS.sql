--------------------------------------------------------
--  DDL for Package Body PAC_FORMUL_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FORMUL_RENTAS" IS

  TYPE rt_parametres IS RECORD
  (
    FECEFE DATE,
    FNAC1 DATE,     -- Data naixement assegurat 1
    SEXO1  NUMBER(1), -- Sexe assegurat 1
    EDAD1  NUMBER(3),
    FNAC2 DATE,     -- Data naixement assegurat 2
    SEXO2  NUMBER(1), -- Sexe aswegurat 2
    EDAD2  NUMBER(3),
    N NUMBER(4),
    SPRODUC PRODUCTOS.SPRODUC%TYPE,
    INT_MIN NUMBER,     -- Interès mínim (ig)
    INT_GARAN NUMBER,   -- Interes garantit (i1)
    INT_FIN NUMBER,     -- Interès financer (ifi)
    PTIPOINT NUMBER,
    GASTOS NUMBER,
    TABLA_MORTA NUMBER,

    -- Agafat de RESP
    VT NUMBER,    -- Valor taxació
    PXVT NUMBER,
    GTOS_NOTARIO NUMBER,
    GTOS_REGISTRO NUMBER,
    IMPTO_AJD NUMBER,
    GTOS_TASACION NUMBER,
    GTOS_GESTORIA NUMBER,
    CAP_DISPONIBLE NUMBER
  )
  ;

  -- Funció privada per carregar els paràmetres utilitzats a la majoria de funcions
  FUNCTION CarregarParametres (pSesion IN NUMBER, pTablaMorta IN NUMBER) RETURN rt_parametres IS
    v rt_parametres;
  BEGIN
    v.TABLA_MORTA:= pTablaMorta;

    -- NOTA : Intencionadament, els dades del segon cap, si només n'hi ha un han de quedar a NULL
    -- Sgt Params
    v.FECEFE:= TO_DATE(pac_GFI.f_sgt_parms ('FECEFE', psesion),'YYYYMMDD');
    v.FNAC1:= TO_DATE(pac_GFI.f_sgt_parms ('FNACIMI', psesion),'YYYYMMDD');
    v.FNAC2:= TO_DATE(pac_GFI.f_sgt_parms ('FNAC_ASE2', psesion),'YYYYMMDD');
    v.SEXO1:= pac_GFI.f_sgt_parms ('SEXO', psesion);
    v.SEXO2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', psesion);
    v.PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', psesion);
    v.SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', psesion);
    v.GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', psesion)/100;

    -- RESP
    v.N := RESP(pSesion,105);  -- Busca periodo "N" de la operacion
    v.VT := RESP(pSesion,100); -- Valor taxació
    v.PXVT := RESP(pSesion,101)/100; -- % valor taxació
    v.GTOS_NOTARIO := RESP(pSesion, 107);
    v.GTOS_REGISTRO := RESP(pSesion, 108);
    v.IMPTO_AJD := RESP(pSesion, 109);
    v.GTOS_TASACION := RESP(pSesion, 110);
    v.GTOS_GESTORIA := RESP(pSesion, 112);
    v.CAP_DISPONIBLE := RESP(pSesion,102);

    -- Calculats
    v.INT_GARAN := 1/(1+v.PTIPOINT/100);
    v.INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (v.SPRODUC, 1, v.FECEFE, v.N))/100);
		v.INT_FIN := pac_inttec.Ff_int_producto (v.SPRODUC, 9, v.FECEFE, v.N)/100;


    v.EDAD1 := FEDAD (psesion, TO_CHAR(v.FNAC1,'YYYYMMDD'), TO_CHAR(v.FECEFE,'YYYYMMDD'), 2);
    IF v.FNAC2 IS NOT NULL THEN
      v.EDAD2 := FEDAD (psesion, TO_CHAR(v.FNAC2,'YYYYMMDD'), TO_CHAR(v.FECEFE,'YYYYMMDD'), 2);
    END IF;
/*
    DBMS_OUTPUT.PUT_LINE('CarregarParametres');
    DBMS_OUTPUT.PUT_LINE('------------------');
    DBMS_OUTPUT.PUT_LINE('v.FECEFE='||v.FECEFE);
    DBMS_OUTPUT.PUT_LINE('v.FNAC1='||v.FNAC1);
    DBMS_OUTPUT.PUT_LINE('v.SEXO1='||v.SEXO1);
    DBMS_OUTPUT.PUT_LINE('v.EDAD1='||v.EDAD1);
    DBMS_OUTPUT.PUT_LINE('v.FNAC2='||v.FNAC2);
    DBMS_OUTPUT.PUT_LINE('v.SEXO2='||v.SEXO2);
    DBMS_OUTPUT.PUT_LINE('v.EDAD2='||v.EDAD2);
    DBMS_OUTPUT.PUT_LINE('v.PTIPOINT='||v.PTIPOINT);
    DBMS_OUTPUT.PUT_LINE('INTTEC='||pac_inttec.Ff_int_producto (v.SPRODUC, 1, v.FECEFE, v.N));
    DBMS_OUTPUT.PUT_LINE('v.SPRODUC='||v.SPRODUC);
    DBMS_OUTPUT.PUT_LINE('v.GASTOS='||v.GASTOS);
    DBMS_OUTPUT.PUT_LINE('v.N='||v.N);
    DBMS_OUTPUT.PUT_LINE('v.VT='||v.VT);
    DBMS_OUTPUT.PUT_LINE('v.PXVT='||v.PXVT);
    DBMS_OUTPUT.PUT_LINE('v.GTOS_NOTARIO='||v.GTOS_NOTARIO);
    DBMS_OUTPUT.PUT_LINE('v.GTOS_REGISTRO='||v.GTOS_REGISTRO);
    DBMS_OUTPUT.PUT_LINE('v.IMPTO_AJD='||v.IMPTO_AJD);
    DBMS_OUTPUT.PUT_LINE('v.GTOS_TASACION='||v.GTOS_TASACION);
    DBMS_OUTPUT.PUT_LINE('v.GTOS_GESTORIA='||v.GTOS_GESTORIA);
    DBMS_OUTPUT.PUT_LINE('v.CAP_DISPONIBLE='||v.CAP_DISPONIBLE);
    DBMS_OUTPUT.PUT_LINE('v.INT_MIN='||v.INT_MIN);
    DBMS_OUTPUT.PUT_LINE('v.INT_GARAN='||v.INT_GARAN);
    DBMS_OUTPUT.PUT_LINE('------------------');
*/
    RETURN v;
  END;

  FUNCTION FF_LX (psesion IN NUMBER, ptabla IN NUMBER, pedad IN NUMBER, psexo IN NUMBER, p_es_mensual IN NUMBER)
  RETURN NUMBER IS

  retorno  NUMBER := 0;
  v_lx 	   NUMBER := 0;
  vedad	   NUMBER := pedad;
  residuo	   NUMBER := 0;
  v_lx2 	   NUMBER := 0;

  BEGIN

    -- Si volem LX mensualitzada tindrem p_es_mensual = 1
    IF p_es_mensual = 1 THEN
        vedad := TRUNC(pedad);
        residuo := pedad - vedad;
        v_lx := ff_mortalidad(Psesion, pTABLA, vEDAD, pSEXO, null, null, 'LX');
        v_lx2:= ff_mortalidad(Psesion, pTABLA, vEDAD+1, pSEXO, null, null, 'LX');
        retorno := v_lx*(1-residuo) + v_lx2*residuo;
    dbms_output.put_line('lx mensualizada (edad '||pedad||')='||retorno);
    ELSE
        retorno := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    END IF;

    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END FF_LX;

  FUNCTION FF_A (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;
    LXI1        NUMBER;
    SUM_AX      NUMBER;

  BEGIN

    SUM_AX := 0;
    dbms_output.put_line('pTABLA='||pTABLA||'pEDAD'||pEDAD||'pSEXO'||pSEXO);
    LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    dbms_output.put_line('LX_EDAD='||LX_EDAD);
    FOR i IN 0..pduraci LOOP
      LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+i, pSEXO, null, null, 'LX');
      LXI1 := ff_mortalidad(Psesion, pTABLA, pEDAD+i+1, pSEXO, null, null, 'LX');
      SUM_AX := SUM_AX + ((LXI-LXI1)/LX_EDAD) * POWER(pv, i+0.5);
--      SUM_AX := SUM_AX + (LXI-LXI1) * POWER(pv, i+0.5);
--    dbms_output.put_line('SUM_AX'||i||'='||SUM_AX);
    END LOOP;
    RETURN SUM_AX;

  END FF_A;

  FUNCTION FF_A2 (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    psexo2 IN NUMBER, pedad2 IN NUMBER, pduraci IN NUMBER, pv IN NUMBER)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;
    LXI1        NUMBER;
    LY_EDAD     NUMBER;
    LYI         NUMBER;
    LYI1        NUMBER;
    SUM_A2      NUMBER;

  BEGIN

    SUM_A2 := 0;
--    dbms_output.put_line('pTABLA='||pTABLA||'pEDAD'||pEDAD||'pSEXO'||pSEXO);
    LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2, pSEXO2, null, null, 'LX');
--    dbms_output.put_line('LX_EDAD='||LX_EDAD);
    FOR i IN 0..pduraci LOOP
      LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+i, pSEXO, null, null, 'LX');
      LXI1 := ff_mortalidad(Psesion, pTABLA, pEDAD+i+1, pSEXO, null, null, 'LX');
      LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+i, pSEXO2, null, null, 'LX');
      LYI1 := ff_mortalidad(Psesion, pTABLA, pEDAD2+i+1, pSEXO2, null, null, 'LX');
      SUM_A2 := SUM_A2 + ((LXI*LYI-LXI1*LYI1)/(LX_EDAD*LY_EDAD)) * POWER(pv,i+0.5);
--    dbms_output.put_line('SUM_A2'||i||'='||SUM_A2);
    END LOOP;
    RETURN SUM_A2;

  END FF_A2;

  FUNCTION FF_A_cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER)
    RETURN NUMBER IS

    vdurax   NUMBER;
    vduray   NUMBER;
    vduraxy   NUMBER;
    Axy     NUMBER;

  BEGIN

    IF pduraci >= FIN_MORTA THEN
        vdurax:= pduraci-pedad-1;
        vduray:= pduraci-pedad2-1;
    ELSE
        vdurax:= pduraci-1;
        vduray:= pduraci-1;
    END IF;

    IF nvl(psexo2,0) = 0 THEN --Una cabeza

      Axy := FF_A(psesion, ptabla, psexo, pedad, vdurax, pv);

    ELSE

      IF pduraci >= FIN_MORTA THEN
          IF pedad > pedad2 THEN
             vduraxy := pduraci-pedad2-1;
          ELSE
             vduraxy := pduraci-pedad-1;
          END IF;
      ELSE
         vduraxy := pduraci-1;
      END IF;

      Axy := FF_A(psesion, ptabla, psexo, pedad, vdurax, pv)
             + FF_A(psesion, ptabla, psexo2, pedad2, vduray, pv)
             - FF_A2(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv);

    END IF;

    dbms_output.put_line('Axy='||Axy);
    RETURN Axy;

  END FF_A_cab;

  FUNCTION FF_ax (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;
    SUM_a      NUMBER;
    Ex         NUMBER;

  BEGIN

    SUM_a := 0;
--    LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD, pSEXO, p_es_mensual);
--dbms_output.put_line('-LX_EDAD='||LX_EDAD||'  pduraci='||pduraci);
    LXI := LX_EDAD;
    FOR i IN 1..pduraci LOOP
      --LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+i, pSEXO, null, null, 'LX');
--dbms_output.put_line(Psesion||':'|| pTABLA||':'|| pEDAD||':'||i||':'|| pSEXO||':'|| p_es_mensual);
      LXI := ff_LX(Psesion, pTABLA, pEDAD+i, pSEXO, p_es_mensual);
--dbms_output.put_line('1=>'||SUM_a||':'||(LXI/LX_EDAD)||':'||POWER(pv,i));
      SUM_a := SUM_a + (LXI/LX_EDAD) * POWER(pv,i);
--dbms_output.put_line('2=>');
--    dbms_output.put_line('ax-lx'||i||'='||LXI/LX_EDAD);
--    dbms_output.put_line('ax-v'||i||'='||POWER(pv,i));
--    dbms_output.put_line('ax'||i||'='||(LXI/LX_EDAD)*POWER(pv,i));
--    dbms_output.put_line('SUM_a'||i||'='||SUM_a);
    END LOOP;
    dbms_output.put_line('SUM_a='||SUM_a);

    Ex := (LXI/LX_EDAD)*POWER(pv,pduraci);
    dbms_output.put_line('Ex='||Ex ||'  Q='||((1-Ex)*(mes-1)/(mes*2)));

    RETURN (SUM_a + (1-Ex)*(mes-1)/(mes*2));

  END FF_ax;

  FUNCTION FF_axy (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER,
    pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LY_EDAD     NUMBER;
    LXI         NUMBER;
    LYI         NUMBER;
    SUM_axy     NUMBER;
    Exy         NUMBER;

  BEGIN

    SUM_axy := 0;
    --LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD, pSEXO, p_es_mensual);
    --LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2, pSEXO2, null, null, 'LX');
    LY_EDAD := ff_LX(Psesion, pTABLA, pEDAD2, pSEXO2, p_es_mensual);
    LXI := LX_EDAD;
    LYI := LY_EDAD;
    FOR i IN 1..pduraci LOOP
      --LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+i, pSEXO, null, null, 'LX');
      LXI := ff_LX(Psesion, pTABLA, pEDAD+i, pSEXO, p_es_mensual);
      --LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+i, pSEXO2, null, null, 'LX');
      LYI := ff_LX(Psesion, pTABLA, pEDAD2+i, pSEXO2, p_es_mensual);
--    dbms_output.put_line('axy'||i||'='||(LXI/LX_EDAD)*(LYI/LY_EDAD)*POWER(pv,i));
      SUM_axy := SUM_axy + (LXI/LX_EDAD)*(LYI/LY_EDAD) * POWER(pv,i);
    END LOOP;
    dbms_output.put_line('SUM_axy='||SUM_axy);

    Exy := (LXI/LX_EDAD)*(LYI/LY_EDAD)*POWER(pv,pduraci);
    dbms_output.put_line('Exy='||Exy ||'  Q='||((1-Exy)*(mes-1)/(mes*2)));

    RETURN (SUM_axy + (1-Exy)*(mes-1)/(mes*2));

  END FF_axy;

  FUNCTION FF_axy_cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, pfracc IN NUMBER DEFAULT 12,
    p_es_mensual IN NUMBER DEFAULT 0, prever IN NUMBER DEFAULT 100)
    RETURN NUMBER IS

    vdurax   NUMBER;
    vduray   NUMBER;
    vduraxy   NUMBER;
    a_xym     NUMBER;

  BEGIN

    IF pduraci >= FIN_MORTA THEN
        vdurax:= pduraci-pedad;
        vduray:= pduraci-pedad2;
    ELSE
        vdurax:= pduraci;
        vduray:= pduraci;
    END IF;

    IF nvl(psexo2,0) = 0 THEN --Una cabeza
      a_xym := FF_ax(psesion, ptabla, psexo, pedad, vdurax, pv, pfracc, p_es_mensual);
    ELSE

      IF pduraci >= FIN_MORTA THEN
          IF pedad > pedad2 THEN
             vduraxy := pduraci-pedad2;
          ELSE
             vduraxy := pduraci-pedad;
          END IF;
      ELSE
         vduraxy := pduraci;
      END IF;

      a_xym := FF_ax(psesion, ptabla, psexo, pedad, vdurax, pv, pfracc,p_es_mensual)
               + prever/100 * (  FF_ax(psesion, ptabla, psexo2, pedad2, vduray, pv, pfracc, p_es_mensual)
                               - FF_axy(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv, pfracc, p_es_mensual)
                              );

    END IF;

    dbms_output.put_line('a_xym='||a_xym);
    RETURN a_xym;

  END FF_axy_cab;

  FUNCTION FF_axy_rever (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, pvmin IN NUMBER, prever IN NUMBER, preval IN NUMBER DEFAULT 0,
    pfracc IN NUMBER DEFAULT 12,
    p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS
/* Se calcula el factor axy pero con un factor de reversión y con un porcentaje de revalorizacion
   Si pfracc = 1, no le aplicamos factor Q
   */
    vdurax   NUMBER;
    vduray   NUMBER;
    vduraxy   NUMBER;
    a_xym     NUMBER;
    ax        NUMBER;
    ay        NUMBER;
    axy       NUMBER;

  BEGIN

    IF pduraci >= FIN_MORTA THEN
        vdurax:= pduraci-pedad;
        vduray:= pduraci-pedad2;
    ELSE
        vdurax:= pduraci;
        vduray:= pduraci;
    END IF;

/* En la hoja excel:
SI(REVAL=0;ax+11/24+REVER*CONY*(ay-axy);
        11/24*((ax*(1+REVAL)+1)+REVER*CONY*((ay*(1+REVAL)+1)-(axy*(1+REVAL)+1)))+13/24*(ax+REVER*CONY*(ay-axy))
  )*1,02*12
En nuestra implementación:
        11/24+11/24*(1+REVAL)*(ax+REVER*CONY*(ay-axy))
        +13/24*(ax+REVER*CONY*(ay-axy))
*/

    ax := FF_ax(psesion, ptabla, psexo, pedad, vdurax, pv, 1, p_es_mensual);

    IF nvl(psexo2,0) = 0 THEN --Una cabeza

      a_xym := (pfracc-1)/(pfracc*2)+ ((pfracc-1)/(pfracc*2))*(1-preval/100)*ax
                + ((pfracc+1)/(pfracc*2))*ax;
    dbms_output.put_line('pfracc='||pfracc||' ax='||ax||' preval='||preval);

    ELSE

      IF pduraci >= FIN_MORTA THEN
          IF pedad > pedad2 THEN
             vduraxy := pduraci-pedad2;
          ELSE
             vduraxy := pduraci-pedad;
          END IF;
      ELSE
         vduraxy := pduraci;
      END IF;

      ay := FF_ax(psesion, ptabla, psexo2, pedad2, vduray, pv, 1, p_es_mensual);
      axy := FF_axy(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv, 1, p_es_mensual);

      a_xym := (pfracc-1)/(pfracc*2)+ ((pfracc-1)/(pfracc*2))*(1-preval/100)*(ax + prever/100*(ay-axy))
                + ((pfracc+1)/(pfracc*2))*(ax + prever/100*(ay-axy));

    END IF;

    dbms_output.put_line('a_xym_rever='||a_xym||' resul='||(a_xym*12*1/pvmin)||' int='||1/pvmin);
    RETURN a_xym*12*1/pvmin;

  END FF_axy_rever;


  FUNCTION FF_Ex (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;
    SUM_a      NUMBER;
    Ex         NUMBER;

  BEGIN

    SUM_a := 0;
    LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+pduraci, pSEXO, null, null, 'LX');
    Ex := (LXI/LX_EDAD)*POWER(pv,pduraci);
    dbms_output.put_line('!!!!!!Ex='||Ex);

    RETURN Ex;

  END FF_Ex;

  FUNCTION FF_factorprovi (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,
    pRo IN NUMBER, preserva IN NUMBER, pgastos IN NUMBER)
    RETURN NUMBER IS

    Axy     NUMBER;
    a_xym   NUMBER;
    retorno NUMBER;

  BEGIN

    Axy := FF_A_cab(psesion, ptabla, psexo, pedad, psexo2, pedad2, pduraci, pv);
    a_xym := FF_axy_cab(psesion, ptabla, psexo, pedad, psexo2, pedad2, pduraci, pv);
    dbms_output.put_line('Axy='||Axy||' a_xym='||a_xym);

    retorno := pRo * (1+pgastos) * a_xym + preserva * Axy;

    dbms_output.put_line('factorprovi='||retorno);
    RETURN retorno;

  END FF_factorprovi;

  FUNCTION FF_factorgaran (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,
    pRo IN NUMBER, preserva IN NUMBER, pgastos IN NUMBER,
    pv_E IN NUMBER, nitera IN NUMBER)
    RETURN NUMBER IS

    nVx     NUMBER;
    nVy     NUMBER;
    nVxy    NUMBER;
    LX_EDAD     NUMBER;
    LXI         NUMBER;
    LY_EDAD     NUMBER;
    LYI         NUMBER;
    resul       NUMBER;

  BEGIN

    -- Provision si viven los dos (o solo tenemos una cabeza)
    nVxy:= FF_factorprovi(psesion, ptabla, psexo, pedad+pduraci, psexo2, pedad2+pduraci, FIN_MORTA, pv,
                         pRo, preserva, pgastos);
    dbms_output.put_line('nVxy='||nVxy);
    dbms_output.put_line('  edad lx_edad='||(pEDAD+nitera));
    LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD+nitera, pSEXO, null, null, 'LX');
    dbms_output.put_line('  edad lxi='||(pEDAD+pduraci));
    LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+pduraci, pSEXO, null, null, 'LX');
    dbms_output.put_line('  lxi='||lxi ||'  lx_edad='||lx_edad);

    IF nvl(psexo2,0) = 0 THEN --Una cabeza

    dbms_output.put_line('Ex='||((LXI/LX_EDAD)*POWER(pv,pduraci-nitera)));
    dbms_output.put_line('nitera='||nitera||' power='||POWER(pv,pduraci-nitera));
        resul := nVxy * (LXI/LX_EDAD)*POWER(pv_E,pduraci-nitera);

    ELSE

        -- Provision si vive solo x
        nVx:= FF_factorprovi(psesion, ptabla, psexo, pedad+pduraci, 0, 0, FIN_MORTA, pv,
                             pRo, preserva, pgastos);
        -- Provision si vive solo y
        nVy:= FF_factorprovi(psesion, ptabla, psexo2, pedad2+pduraci, 0, 0, FIN_MORTA, pv,
                             pRo, preserva, pgastos);

        LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2+nitera, pSEXO2, null, null, 'LX');
        LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+pduraci, pSEXO2, null, null, 'LX');

    dbms_output.put_line('factor NVxy='||nVxy||' nVx='||nVx||' nVy='||nVy);
    dbms_output.put_line('factor LXI='||LXI||' LYI='||LYI||' LY_EDAD='||LY_EDAD);
        resul := nVxy * (LXI*LYI/(LX_EDAD*LY_EDAD))*POWER(pv_E,pduraci-nitera)
               + nVx * (LXI*(LY_EDAD-LYI)/(LX_EDAD*LY_EDAD))*POWER(pv_E,pduraci-nitera)
               + nVy * (LYI*(LX_EDAD-LXI)/(LX_EDAD*LY_EDAD))*POWER(pv_E,pduraci-nitera);

    END IF;

    dbms_output.put_line('factorgaran='||resul);
    RETURN resul;

  END FF_factorgaran;

  FUNCTION FF_min_RVI (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS   NUMBER;
  FECEFE   NUMBER;
  --FECHA    NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    RC:= pac_GFI.f_sgt_parms ('PCAPFALL', sesion)/100;
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, FIN_MORTA, V_INT_MIN);
    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, FIN_MORTA, V_INT_MIN);

    retorno := ICAPREN*( 1 - RC * Axy )/ ( (1+GASTOS) * a_xym );
    dbms_output.put_line('Ro1='||retorno);

    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_min_RVI;

  FUNCTION FF_provi_RVI (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Ro1   NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    RC:= pac_GFI.f_sgt_parms ('PCAPFALL', sesion)/100;
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    --NDURPER:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
    --V_INT_MIN_16 := 1/(1+(VTRAMO(sesion, 370, SPRODUC))/100);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
    --dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    Ro1 := FF_min_RVI(sesion);
    retorno := FF_factorprovi(sesion, TABLA_MORTA, SEXO, EDAD_X+NDURACI, SEXO_ASE2,
                              EDAD_Y+NDURACI, FIN_MORTA, V_INT_MIN, Ro1, RC * ICAPREN, GASTOS);

    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_provi_RVI;

  FUNCTION FF_temp_RVI (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;
  nfactor   NUMBER;
  Ro        NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    RC:= pac_GFI.f_sgt_parms ('PCAPFALL', sesion)/100;
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);
    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);

    Ro := FF_min_RVI(sesion);
    nfactor := FF_factorgaran(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2,
                              EDAD_Y, NDURACI, V_INT_MIN, Ro, RC * ICAPREN, GASTOS, V_INT_GARAN, 0);
    dbms_output.put_line('numerador='||(ICAPREN*( 1 - RC * Axy ) - nfactor));
    dbms_output.put_line('denominador='||( (1+GASTOS) * a_xym ));
    retorno := (ICAPREN*( 1 - RC * Axy ) - nfactor)/ ( (1+GASTOS) * a_xym );
    dbms_output.put_line('R11='||retorno);
    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line ('Error rentatemp='||sqlerrm);
      RETURN -1;
  END FF_temp_RVI;

  FUNCTION FF_pranu_RVI (sesion IN NUMBER, pany IN NUMBER)
    RETURN NUMBER IS
/* Provisión anual por periodo */

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;
  nfactor   NUMBER;
  Ro        NUMBER;
  R1        NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    RC:= pac_GFI.f_sgt_parms ('PCAPFALL', sesion)/100;
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X+pany, SEXO_ASE2, EDAD_Y+pany, NDURACI-pany, V_INT_GARAN);
    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X+pany, SEXO_ASE2, EDAD_Y+pany, NDURACI-pany, V_INT_GARAN);

    Ro := FF_min_RVI(sesion);
    dbms_output.put_line('!!!Ro='||Ro);
    R1 := FF_temp_RVI(sesion);
    dbms_output.put_line('!!!R1='||R1);
    nfactor := FF_factorgaran(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2,
                              EDAD_Y, NDURACI, V_INT_MIN, Ro, RC * ICAPREN, GASTOS, V_INT_GARAN, pany);
--    dbms_output.put_line('AXYN ='||(1-FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X+pany, SEXO_ASE2, EDAD_Y+pany, NDURACI-pany+1, V_INT_GARAN,-1)
--                                    +FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X+pany, SEXO_ASE2, EDAD_Y+pany, NDURACI-pany, V_INT_GARAN,-1)
--                                    *V_INT_GARAN)*power(1+0.02,0.5));

    dbms_output.put_line('Axy='||Axy);
    dbms_output.put_line('a_xym='||a_xym);
    retorno := R1 * (1+GASTOS) * a_xym + (ICAPREN * RC * Axy) + nfactor;
    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line ('Error periodo_provi='||sqlerrm);
      RETURN -1;
  END FF_pranu_RVI;

  FUNCTION FF_min_RO (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;
  Reserva NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
--    RC:= pac_GFI.f_sgt_parms ('RC', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, FIN_MORTA, V_INT_MIN);
    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, FIN_MORTA, V_INT_MIN);

    IF ICAPREN * 0.03 > 1000 THEN
        Reserva := ICAPREN + 1000;
        RC := Reserva / ICAPREN;
    ELSE
        Reserva := ICAPREN * 1.03;
        RC := 1.03;
    END IF;

    dbms_output.put_line('Ro1=('||ICAPREN||' - '||Reserva||' * '||Axy||' )/ ( (1+'||GASTOS||') * '||a_xym||' )');
    retorno := (ICAPREN - Reserva * Axy )/ ( (1+GASTOS) * a_xym );
    dbms_output.put_line('Ro1_RO='||retorno);

    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_min_RO;

  FUNCTION FF_provi_RO (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Ro1   NUMBER;
  Reserva NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    --NDURPER:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
    --V_INT_MIN_16 := 1/(1+(VTRAMO(sesion, 370, SPRODUC))/100);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
    --dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    IF ICAPREN * 0.03 > 1000 THEN
        Reserva := ICAPREN + 1000;
        RC := Reserva / ICAPREN;
    ELSE
        Reserva := ICAPREN * 1.03;
        RC := 1.03;
    END IF;

    Ro1 := FF_min_RO(sesion);
    retorno := FF_factorprovi(sesion, TABLA_MORTA, SEXO, EDAD_X+NDURACI, SEXO_ASE2,
                              EDAD_Y+NDURACI, FIN_MORTA, V_INT_MIN, Ro1, Reserva, GASTOS);

    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_provi_RO;

  FUNCTION FF_temp_RO (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;
  nfactor   NUMBER;
  Ro        NUMBER;
  Reserva NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);
    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);

    IF ICAPREN * 0.03 > 1000 THEN
        Reserva := ICAPREN + 1000;
        RC := Reserva / ICAPREN;
    ELSE
        Reserva := ICAPREN * 1.03;
        RC := 1.03;
    END IF;

    Ro := FF_min_RO(sesion);
    nfactor := FF_factorgaran(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2,
                              EDAD_Y, NDURACI, V_INT_MIN, Ro, Reserva, GASTOS, V_INT_GARAN, 0);
    dbms_output.put_line('numerador='||(ICAPREN*( 1 - RC * Axy ) - nfactor));
    dbms_output.put_line('denominador='||( (1+GASTOS) * a_xym ));
    retorno := ((ICAPREN - Reserva * Axy ) - nfactor)/ ( (1+GASTOS) * a_xym );
    dbms_output.put_line('R11='||retorno);
    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line ('Error rentatemp='||sqlerrm);
      RETURN -1;
  END FF_temp_RO;

  FUNCTION FF_pranu_RO (sesion IN NUMBER, pany IN NUMBER)
    RETURN NUMBER IS
/* Provisión anual por periodo */

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;
  nfactor   NUMBER;
  Ro        NUMBER;
  R1        NUMBER;
  Reserva NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X+pany, SEXO_ASE2, EDAD_Y+pany, NDURACI-pany, V_INT_GARAN);
    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X+pany, SEXO_ASE2, EDAD_Y+pany, NDURACI-pany, V_INT_GARAN);

    IF ICAPREN * 0.03 > 1000 THEN
        Reserva := ICAPREN + 1000;
        RC := Reserva / ICAPREN;
    ELSE
        Reserva := ICAPREN * 1.03;
        RC := 1.03;
    END IF;

    Ro := FF_min_RO(sesion);
    dbms_output.put_line('!!!Ro='||Ro);
    R1 := FF_temp_RO(sesion);
    dbms_output.put_line('!!!R1='||R1);
    nfactor := FF_factorgaran(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2,
                              EDAD_Y, NDURACI, V_INT_MIN, Ro, Reserva, GASTOS, V_INT_GARAN, pany);
    dbms_output.put_line('Axy='||Axy);
    dbms_output.put_line('a_xym='||a_xym);
    retorno := R1 * (1+GASTOS) * a_xym + (Reserva * Axy) + nfactor;
    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line ('Error periodo_provi='||sqlerrm);
      RETURN -1;
  END FF_pranu_RO;

  FUNCTION FF_renta_RVT (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;
  PDOSCAB  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;
  nfactor   NUMBER;
  Ro        NUMBER;
  Reserva NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);
    PDOSCAB:= NVL(pac_GFI.f_sgt_parms ('PDOSCAB', sesion),100);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

--    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    EDAD_X := round(months_between(to_date(FECEFE,'yyyymmdd'), to_date(FNACIMI,'yyyymmdd'))/12,2);

    dbms_output.put_line('EDAD_X='||EDAD_X);
--    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);
    EDAD_Y := round(months_between(to_date(FECEFE,'yyyymmdd'), to_date(FNAC_ASE2,'yyyymmdd'))/12,2);

--    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);
    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN, 12, 1, PDOSCAB);

    retorno := (ICAPREN/a_xym)/ (1+GASTOS);
    dbms_output.put_line('RentaVT='||retorno);
    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line ('Error rentaRVT='||sqlerrm);
      RETURN -1;
  END FF_renta_RVT;

  FUNCTION FF_prima_RVT (sesion IN NUMBER, panual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  IBRUREN NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;
  PDOSCAB  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;
  nfactor   NUMBER;
  Ro        NUMBER;
  Reserva NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    IBRUREN:= pac_GFI.f_sgt_parms ('IBRUREN', sesion);  --Renta minima
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    PDOSCAB:= NVL(pac_GFI.f_sgt_parms ('PDOSCAB', sesion),100);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

--    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    EDAD_X := (-1)*months_between(to_date(FNACIMI,'yyyymmdd'), to_date(FECEFE,'yyyymmdd'))/12;

    dbms_output.put_line('EDAD_X='||EDAD_X);
--    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);
    EDAD_Y := (-1)*months_between(to_date(FNAC_ASE2,'yyyymmdd'), to_date(FECEFE,'yyyymmdd'))/12;

--    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);
    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-panual, V_INT_GARAN, 12, 1, PDOSCAB);

    retorno := (IBRUREN * a_xym)* (1+GASTOS);
    dbms_output.put_line('RentaVT='||retorno);
    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line ('Error primaRVT='||sqlerrm);
      RETURN -1;
  END FF_prima_RVT;

  FUNCTION FF_renta_RVD (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  PCAPFALL NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;
  PDOSCAB  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
--    PCAPFALL:= pac_GFI.f_sgt_parms ('PCAPFALL', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    PDOSCAB:= NVL(pac_GFI.f_sgt_parms ('PDOSCAB', sesion),100);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    dbms_output.put_line('1+PTIPOINT/100='||(1+PTIPOINT/100));
    dbms_output.put_line('V_INT_GARAN='||V_INT_GARAN);
--CPM    V_INT_MIN := 1/(1+(2)/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
--    dbms_output.put_line('interes='||pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI));

    TABLA_MORTA := pac_GFI.f_sgt_parms ('TABLA_MORTALIDAD', sesion);

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    a_xym := FF_axy_rever(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, FIN_MORTA,
                        V_INT_GARAN, V_INT_MIN, PDOSCAB);

    retorno := ICAPREN / a_xym;
    dbms_output.put_line('Ro1='||retorno);

    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_renta_RVD;

  FUNCTION FF_insub_LCR (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X   NUMBER;
  EDAD_Y   NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;
  CFORPAG_REN NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  ppx_inter1    NUMBER;
  ppx_inter2    NUMBER;
  wk1           NUMBER;
  wkp1          NUMBER;
  wkp2          NUMBER;

    LX_EDAD     NUMBER;
    LY_EDAD     NUMBER;
    LXI         NUMBER;
    LYI         NUMBER;
    LXI1        NUMBER;
    LYI1        NUMBER;
    SUM_axy     NUMBER;
    wk          NUMBER;
    x_int1      NUMBER;
    x_int2      NUMBER;

  retorno  NUMBER := 0;

   FUNCTION calculo_var (pv_inter IN NUMBER)
     RETURN NUMBER IS

  BEGIN

    x_int1 := pac_inttec.Ff_int_producto (SPRODUC, 3, to_date(FECEFE,'yyyymmdd'), NDURACI*100000+1*100+CFORPAG_REN)/100;
    SUM_axy := ICAPREN * x_int1 * POWER(pv_inter,0.5) * 0.5;
    LX_EDAD := ff_LX(sesion, TABLA_MORTA, EDAD_X, SEXO, 0);
    dbms_output.put_line('LX_EDAD='||LX_EDAD);

    IF nvl(SEXO_ASE2,0) <> 0 THEN --Dos cabezas
        LY_EDAD := ff_LX(sesion, TABLA_MORTA, EDAD_Y, SEXO_ASE2, 0);
    dbms_output.put_line('LY_EDAD='||LY_EDAD);
    END IF;

    FOR i IN 1..Nduraci LOOP

      x_int2 := nvl(pac_inttec.Ff_int_producto (SPRODUC, 3, to_date(FECEFE,'yyyymmdd'), NDURACI*100000+(i+1)*100+CFORPAG_REN),0)/100;
      LXI := ff_LX(sesion, TABLA_MORTA, EDAD_X+i, SEXO, 0);
      IF nvl(SEXO_ASE2,0) = 0 THEN --Una cabeza
        wk := (LXI/LX_EDAD);
      ELSE
        LYI := ff_LX(sesion, TABLA_MORTA, EDAD_Y+i, SEXO_ASE2, 0);
        wk := (LXI/LX_EDAD) + (LYI/LY_EDAD) - (LXI/LX_EDAD)*(LYI/LY_EDAD);
      END IF;
--    dbms_output.put_line('wk'||i||'='||wk);
      SUM_axy := SUM_axy + ICAPREN * x_int1 * 0.5 * POWER(pv_inter,i-0.5) * wk
                         + ICAPREN * x_int2 * 0.5 * POWER(pv_inter,i+0.5) * wk;
      x_int1 := x_int2;

    END LOOP;
    dbms_output.put_line('SUM_axy_var='||SUM_axy);
    dbms_output.put_line('var='||SUM_axy * (1+GASTOS));

    RETURN (SUM_axy * (1+GASTOS));

  END calculo_var;

   FUNCTION calculo_vaf (pv_inter IN NUMBER)
     RETURN NUMBER IS

  BEGIN

    SUM_axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, pv_inter);
    dbms_output.put_line('SUM_axy_vaf='||SUM_axy);
    dbms_output.put_line('vaf='||SUM_axy * ICAPREN);

    RETURN (SUM_axy * ICAPREN);

  END calculo_vaf;

   FUNCTION calculo_vas (pv_inter IN NUMBER)
     RETURN NUMBER IS

  BEGIN

    LX_EDAD := ff_LX(sesion, TABLA_MORTA, EDAD_X, SEXO, 0);
    LXI := ff_LX(sesion, TABLA_MORTA, EDAD_X+NDURACI, SEXO, 0);

    IF nvl(SEXO_ASE2,0) = 0 THEN --Una cabeza
        wk := (LXI/LX_EDAD);
    ELSE
        LY_EDAD := ff_LX(sesion, TABLA_MORTA, EDAD_Y, SEXO_ASE2, 0);
        LYI := ff_LX(sesion, TABLA_MORTA, EDAD_Y+NDURACI, SEXO_ASE2, 0);
        wk := (LXI/LX_EDAD) + (LYI/LY_EDAD) - (LXI/LX_EDAD)*(LYI/LY_EDAD);
    END IF;
--    dbms_output.put_line('wk'||i||'='||wk);
    SUM_axy := ICAPREN * POWER(pv_inter,NDURACI) * wk;
    dbms_output.put_line('SUM_axy_vas='||SUM_axy);

    RETURN SUM_axy;

  END calculo_vas;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    CFORPAG_REN:= pac_GFI.f_sgt_parms ('CFORPAG_REN', sesion);

    ppx_inter1 := pac_inttec.Ff_int_producto (SPRODUC, 7, to_date(FECEFE,'yyyymmdd'), NDURACI*100000+100+CFORPAG_REN)/100;
    ppx_inter2 := pac_inttec.Ff_int_producto (SPRODUC, 8, to_date(FECEFE,'yyyymmdd'), NDURACI*100000+100+CFORPAG_REN)/100;

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);
    dbms_output.put_line('EDAD_X='||EDAD_X);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECEFE, 2);

    wkp1 := calculo_var(1/(1+ppx_inter1)) + calculo_vaf(1/(1+ppx_inter1)) + calculo_vas(1/(1+ppx_inter1));
    wkp2 := calculo_var(1/(1+ppx_inter2)) + calculo_vaf(1/(1+ppx_inter2)) + calculo_vas(1/(1+ppx_inter2));
    dbms_output.put_line('wkp1='||wkp1||' wkp2='||wkp2);

    wk1 := (wkp2 - ICAPREN) / (wkp2 - wkp1);
--
    retorno := ppx_inter2 + wk1 * (ppx_inter1 - ppx_inter2);

    RETURN retorno*100; --JRH Lo devolvemos multiplicado por 100

  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END FF_insub_LCR;

  FUNCTION FF_provi_LCR (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  SUM_RENTAS     NUMBER;
  FECEFE   NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;
  CFORPAG_REN NUMBER;

  tir NUMBER;
  VT  NUMBER;
  TABLA_MORTA NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    SUM_RENTAS:= pac_GFI.f_sgt_parms ('SUM_RENTAS', sesion);
    -- Se ha de definir a nivel de SGT_CARGA_ARG_PREDE de donde se sacará esta información
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);

    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    CFORPAG_REN:= pac_GFI.f_sgt_parms ('CFORPAG_REN', sesion);

    tir := pac_inttec.Ff_int_producto (SPRODUC, 6, to_date(FECEFE,'yyyymmdd'), NDURACI*100000+100+CFORPAG_REN)/100;
    VT := 1/(1+tir/100);

    retorno := ICAPREN * VT - SUM_RENTAS;
    dbms_output.put_line('Provi LCR='||retorno);
    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line ('Error rentaLRC='||sqlerrm);
      RETURN -1;
  END FF_provi_LCR;

  -- HI. MSR 3/12/2007
  -- Funcions privades per les funciosn HI
--
--   CalculSumatoriMorta
-- Paràmetres :
--  pSesion       Identificador
--  pTablaMorta   Codi de la taula de mortalitat (MORTALIDAD.CTABLA)
--  pInici        Edat inici del sumatori
--  pFinal        Edat final del sumatori
--  pInteres      Tipus d'interès a aplicar
--  pExpSumaEdat  Suma l'edad a l'exponent dels interessos
--  Assegurat 1
--    pEdatX         Edat de l'assegurat
--    pSexeX         Sexe de l'assegurat :   1 Home, 2 Dona
--    pDivisorX      Valor pel qual dividir la probalilitat de supervivència
--  Assegurat 2
--    pEdatY         Edat de l'assegurat
--    pSexeY         Sexe de l'assegurat :   1 Home, 2 Dona
--    pDivisorY      Valor pel qual dividir la probalilitat de supervivència
--
--  En cas que no s'envii les dades de l'assegurat 2 només es calcula per l'assegurat 1
------------------------------------------------------------------------------------------
  FUNCTION CalculSumatoriMorta ( pSesion IN NUMBER, pTablaMorta IN MORTALIDAD.CTABLA%TYPE,
                                 pInici IN NUMBER, pFinal IN NUMBER , pInteres IN NUMBER,
                                 pExpSumaEdat IN BOOLEAN,
                                 pEdatX IN NUMBER, pSexeX IN NUMBER,  pDivisorX IN NUMBER DEFAULT 1,
                                 pEdatY IN NUMBER DEFAULT NULL, pSexeY IN NUMBER DEFAULT NULL,  pDivisorY IN NUMBER DEFAULT 1 )
                                  RETURN NUMBER IS
    v_value NUMBER;
    v_exp   NUMBER;
    v_sx    NUMBER;
    v_sy    NUMBER;
  BEGIN
      v_value := 0;
      FOR i IN pInici .. pFinal LOOP
         v_sx := ( ff_mortalidad(pSesion, pTablaMorta, pEdatX + i, pSexeX, null, null, 'LX') );
         IF pEdatY IS NOT NULL AND pSexeY IS NOT NULL THEN
           v_sy := ( ff_mortalidad(pSesion, pTablaMorta, pEdatY + i, pSexeY, null, null, 'LX') );
         ELSE
           v_sy := 1;
         END IF;
         v_exp := i + CASE WHEN pExpSumaEdat THEN pEdatX ELSE 0 END;
         v_value := v_value
                      + v_sx * v_sy
                      * ( pInteres ** v_exp );

      END LOOP;
      IF NVL(pDivisorX,0) != 0 AND NVL(pDivisorY,0) != 0 THEN
        v_value := v_value / ( NVL(pDivisorX,1) * NVL(pDivisorY,1) );
      END IF;
      RETURN v_value;
  END;
--
------------------------------------------------------------------------------------------
  FUNCTION calculo_hi_amxn(pSesion IN NUMBER, pIntMinim IN NUMBER, xn IN NUMBER, sex IN NUMBER, pTablaMorta IN MORTALIDAD.CTABLA%TYPE) RETURN NUMBER IS
    vxn  NUMBER;
    lxn  NUMBER;
    amxn NUMBER;
  BEGIN
    vxn := pIntMinim ** xn;
    lxn := ff_mortalidad(pSesion, pTablaMorta, xn, sex, null, null, 'LX');
    amxn := CalculSumatoriMorta(pSesion, pTablaMorta, 1, maxtaula - xn + 1, pIntMinim, TRUE, xn , sex, vxn * lxn );
    RETURN  amxn + m_1div2m;
  END;

--
------------------------------------------------------------------------------------------
  FUNCTION calculo_hi_amxyn( pSesion IN NUMBER, pTablaMorta IN MORTALIDAD.CTABLA%TYPE, pIntMin IN NUMBER, xn IN NUMBER, sex IN NUMBER, yn IN NUMBER, sey IN NUMBER) RETURN NUMBER IS
    omega NUMBER;
    lxn  NUMBER;
    lyn  NUMBER;
    amxyn NUMBER;
  BEGIN
    lxn := ff_mortalidad(pSesion, pTablaMorta, xn, sex, null, null, 'LX');
    lyn := ff_mortalidad(pSesion, pTablaMorta, yn, sey, null, null, 'LX');

    omega := maxtaula - LEAST(xn,yn);

    amxyn := CalculSumatoriMorta ( pSesion, pTablaMorta, 1, omega, pIntMin, FALSE, xn, sex,  lxn, yn, sey,  lyn );

    RETURN amxyn + m_1div2m;
  END;
--
------------------------------------------------------------------------------------------
  -- Si Y és NULL és calcula només per X
   FUNCTION calculo_hi_pu( pSesion IN NUMBER, pTablaMorta IN MORTALIDAD.CTABLA%TYPE,
                           pIntMin IN NUMBER, pIntGaran IN NUMBER, pGastos IN NUMBER,
                           n IN NUMBER,
                           x IN NUMBER, sex IN NUMBER,
                           y IN NUMBER DEFAULT NULL, sey IN NUMBER DEFAULT NULL) RETURN NUMBER IS
     lxn NUMBER;
     lyn NUMBER;
     amxyn NUMBER;
     amxn NUMBER;
     amyn NUMBER;
     lx   NUMBER;
     ly   NUMBER;

     ope_x NUMBER;
     ope_y NUMBER;
     ope_xy NUMBER;
   BEGIN
------------------------------------------------------------------------------------------

      lx := ff_mortalidad(pSesion, pTablaMorta, x, sex, null, null, 'LX');
      lxn := ff_mortalidad(pSesion, pTablaMorta, x + n, sex, null, null, 'LX');
      amxn := calculo_hi_amxn(pSesion, pIntMin, x + n, sex, pTablaMorta);
      ope_x := amxn * lxn / lx;

      IF y IS NOT NULL THEN
        ly := ff_mortalidad(pSesion, pTablaMorta, y, sey, null, null, 'LX');
        lyn := ff_mortalidad(pSesion, pTablaMorta, y + n, sey, null, null, 'LX');
        amyn := calculo_hi_amxn(pSesion, pIntMin, y + n, sey, pTablaMorta);
        ope_y := amyn * lyn / ly;

        amxyn := calculo_hi_amxyn(pSesion, pTablaMorta, pIntMin, x + n, sex, y + n, sey);
        ope_xy := ((amxyn * lyn * lxn) / (ly * lx));
      ELSE
        ope_y := 0;
        ope_xy := 0;
      END IF;

      RETURN (ope_x + ope_y - ope_xy) * (pIntGaran ** n) * (1 + pGastos);
   END;
------------------------------------------------------------------------------------------
  PROCEDURE calculo_renta_hi( pSesion IN NUMBER,
                              pPrima OUT NUMBER, pRenda OUT NUMBER)   IS
    v_tot_gastos NUMBER;

    pu  NUMBER;
    -- Variables locals
    renta               NUMBER (13, 7);
    varf                NUMBER;         -- Valor Actual de una Renta Financiera
    numer               NUMBER;
    denom               NUMBER;
    w rt_parametres;
  BEGIN
    w := CarregarParametres(pSesion, pTablaMorta=>8);
    v_tot_gastos := w.gtos_notario + w.gtos_registro + w.impto_ajd + w.gtos_tasacion + w.gtos_gestoria + w.cap_disponible;
    -- Les EDAD2 i SEXO2 es passen a NULL si només hi ha 1 cap
    pu  := calculo_hi_pu(pSesion, w.TABLA_MORTA, w.INT_MIN, w.INT_GARAN, w.GASTOS, w.N, w.EDAD1, w.SEXO1, w.EDAD2, w.SEXO2);

    numer := (1 - (1 / (1 + w.INT_FIN) ** w.N));
    denom := (1 + w.INT_FIN) ** (1/12) - 1;
    varf := ( numer / (denom * 12));
    numer := (w.pxvt * w.vt) - v_tot_gastos * (1 + w.INT_FIN) ** w.N;
    denom := (varf + pu) * (1 + w.INT_FIN) ** w.N;
    renta := numer / denom;

    pPrima:= renta * pu;
    pRenda:= renta / 12;
  END;

  -- pAny : quin any de 0 en endavant hem de tornar
  FUNCTION calculo_provi_hi(pSesion IN NUMBER, pAny IN NUMBER) RETURN NUMBER IS
    lxn NUMBER;
    lyn NUMBER;
    lxk NUMBER;
    lyk NUMBER;
    lxj NUMBER;
    lyj NUMBER;
    amx NUMBER;
    amy NUMBER;
    amxy NUMBER;
    ope_x NUMBER;
    ope_y NUMBER;
    ope_xy NUMBER;
    j NUMBER;
    t NUMBER;
    vega NUMBER;
    omega NUMBER;
    beta NUMBER;
    gamma NUMBER;

     renta               NUMBER (13, 7);

    w rt_parametres;
  BEGIN
    w := CarregarParametres(pSesion,pTablaMorta=>8);
------------------------------------------------------------------------------------------
      renta := FF_renta_HI(pSesion) * 12;   -- Volem la renda anual

    IF pAny <= w.N THEN
      lxn := ff_mortalidad(pSesion, w.Tabla_Morta, w.EDAD1 + w.N, w.SEXO1, null, null, 'LX');
      lxk := ff_mortalidad(pSesion, w.Tabla_Morta, w.EDAD1 + pAny, w.SEXO1, null, null, 'LX');
      amx := calculo_hi_amxn(pSesion, w.INT_MIN, w.EDAD1 + w.N, w.sexo1, w.Tabla_Morta);
      ope_x := amx * lxn / lxk;

      IF w.edad2 IS NOT NULL THEN
        lyn := ff_mortalidad(pSesion, w.Tabla_Morta, w.EDAD2 + w.N, w.SEXO2, null, null, 'LX');
        lyk := ff_mortalidad(pSesion, w.Tabla_Morta, w.EDAD2 + pAny, w.SEXO2, null, null, 'LX');

        amy := calculo_hi_amxn(pSesion, w.INT_MIN, w.EDAD2 + w.N, w.sexo2, w.Tabla_Morta);
        ope_y := amy * lyn / lyk;

        amxy := calculo_hi_amxyn(pSesion, w.Tabla_Morta, w.INT_MIN, w.EDAD1 + w.N, w.sexo1, w.EDAD2 + w.N, w.sexo2);
        ope_xy := amxy * (lxn * lyn) / (lxk * lyk);
      ELSE
        ope_y := 0;
        ope_xy := 0;
      END IF;

      RETURN  renta * (ope_x + ope_y - ope_xy) * ( w.INT_GARAN ** (w.N - pAny) ) * (1 + w.GASTOS);
    ELSE
  -- ------------------------------------------------------------
  -- --  Calculo provision a partir de "N" (abono de rentas)
  -- ------------------------------------------------------------
      j := pany;     -- j és l'any que s'ha de calcular

      omega := maxtaula - LEAST(w.EDAD1,w.EDAD2) - 1;

      IF w.edad2 IS NOT NULL THEN
        vega := maxtaula - j - w.EDAD1 - 1;
        lxj := ff_mortalidad(pSesion, w.Tabla_Morta, w.EDAD1 + j, w.sexo1, null, null, 'LX');
        amx := CalculSumatoriMorta(pSesion, w.Tabla_Morta, 1, vega, w.INT_MIN, FALSE, w.EDAD1 + j, w.sexo1, lxj  );
        amx := amx + m_1div2m;
        --
        beta := maxtaula - j - w.EDAD2 - 1;
        lyj := ff_mortalidad(pSesion, w.Tabla_Morta, w.EDAD2 + j, w.sexo2, null, null, 'LX');
        amy := CalculSumatoriMorta(pSesion, w.Tabla_Morta, 1, beta, w.INT_MIN, FALSE, w.EDAD2 + j, w.sexo2, lyj  );
        --
        gamma := maxtaula - j - LEAST(w.EDAD1,w.EDAD2) - 1;
        amxy := CalculSumatoriMorta(pSesion, w.Tabla_Morta, 1, gamma, w.INT_MIN, FALSE, w.EDAD1 + j, w.sexo1, lxj, w.EDAD2 + j, w.sexo2, lyj  );
        --
        amy := amy + m_1div2m;
        amxy := amxy + m_1div2m;
      ELSE
        t := w.EDAD1 + j - 2;
        -- Aparenment quan és un sol AMX és calculada de manera diferent
        lxj := ff_mortalidad(pSesion, w.Tabla_Morta, t, w.sexo1, null, null, 'LX');
        amx := CalculSumatoriMorta(pSesion, w.Tabla_Morta, t + 1, maxtaula + 1, w.INT_MIN, FALSE, 0, w.sexo1 );
        amx := amx / (  (w.int_min ** t) * lxj + m_1div2m );

        amy := 0;
        amxy := 0;
      END IF;
      --
      RETURN renta * (amx + amy - amxy) * (1 + w.GASTOS);
    END IF;

    RETURN 0;
  END;

  -- Funcions públiques
  FUNCTION FF_provi_HI (pSesion IN NUMBER, pAny IN NUMBER) RETURN NUMBER IS
    SEXO_ASE2 CONSTANT NUMBER := NVL(pac_GFI.f_sgt_parms ('SEXO_ASE2', psesion),0);
  BEGIN
    -- pAny-1, perquè pels càlculs perquè a la formula l'any 0 correspon al primer any
    RETURN ROUND(calculo_provi_hi(pSesion, pAny-1),2);
  END;

  FUNCTION FF_prima_HI (pSesion IN NUMBER) RETURN NUMBER IS
    v_prima NUMBER;
    v_renda NUMBER;
  BEGIN
    calculo_renta_hi( pSesion, v_prima, v_renda);
    RETURN ROUND(v_prima,2);
  END;

  FUNCTION FF_renta_HI (pSesion IN NUMBER) RETURN NUMBER IS
    v_prima NUMBER;
    v_renda NUMBER;
  BEGIN
    calculo_renta_hi( pSesion, v_prima, v_renda);
    RETURN ROUND(v_renda,2);
  END;





  --JRH 01/2008

	FUNCTION FF_coef_RVI (sesion IN NUMBER,psseguro IN NUMBER,Fecha NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  PCAPFALL NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;
  PDOSCAB  NUMBER;
 -- FECHA NUMBER;
	FREVISIO NUMBER;
	FPPREN NUMBER;
  V_INT_GARAN NUMBER;
  V_INT_CERC NUMBER;
  TABLA_MORTA NUMBER;
	capGaran NUMBER;
	nDura NUMBER;
	IBRUREN NUMBER;

	T1 NUMBER;
	Numerador NUMBER;
	Denominador NUMBER;
	N NUMBER;

  Axy   NUMBER;
  a_xym  NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);
    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion)/100;
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    --FECHA:= pac_GFI.f_sgt_parms ('FECHA', sesion);
    FREVISIO:= pac_GFI.f_sgt_parms ('FREVISIO', sesion);
    FPPREN:=pac_GFI.f_sgt_parms ('FPPREN', sesion);
    IBRUREN:=pac_GFI.f_sgt_parms ('IBRUREN', sesion);

    PDOSCAB:= NVL(pac_GFI.f_sgt_parms ('PDOSCAB', sesion),100);
    V_INT_GARAN := 1/(1+PTIPOINT/100);

    V_INT_CERC := (pac_inttec.Ff_int_prodcercano (SPRODUC, 4, to_date(FECHA,'yyyymmdd'), round((to_date(FREVISIO,'yyyymmdd')-to_date(FECHA,'yyyymmdd'))/365)));
		V_INT_CERC:=V_INT_CERC/100;

		capGaran:=PAC_FORMUL_RENTAS.FF_provi_RVI(sesion);

		T1:=((to_date(FPPREN,'yyyymmdd')-to_date(FECHA,'yyyymmdd'))/365);
		Numerador:=0;
		Denominador:=0;

		N:=ABS(MONTHS_BETWEEN(to_date(FREVISIO,'yyyymmdd'),to_date(FECHA,'yyyymmdd')));

		For i in 1..N LOOP
			Numerador:=Numerador+(T1+(i-1)/12)*IBRUREN/POWER((1+V_INT_CERC),(T1+(i-1)/12));

			Denominador:=Denominador+IBRUREN/POWER((1+V_INT_CERC),(T1+(i-1)/12));
		END LOOP;

		Numerador:=Numerador+	 (T1+(n-1)/12)* capGaran/POWER((1+V_INT_CERC),(T1+(n-1)/12));
		Denominador:=Denominador+	capGaran/POWER((1+V_INT_CERC),(T1+(n-1)/12));

		nDura:=Numerador/	Denominador;


		retorno:=POWER((1+V_INT_CERC),nDura)/POWER((1+PTIPOINT),nDura);

    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_coef_RVI;




/**************************************************************************************************
AQUI EMPIEZA RP
**************************************************************************************************/



FUNCTION FF_Exy (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    psexo2 IN NUMBER, pedad2 IN NUMBER,pduraci IN NUMBER, pv IN NUMBER)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;

    LY_EDAD     NUMBER;
    LYI         NUMBER;

    SUM_a      NUMBER;
    Ex         NUMBER;
      Exy Number;
  BEGIN
    SUM_a := 0;
    LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+pduraci, pSEXO, null, null, 'LX');

    LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2, pSEXO2, null, null, 'LX');
    LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+pduraci, pSEXO2, null, null, 'LX');
    Exy := (LXI/LX_EDAD)*(LYI/LY_EDAD)*POWER(pv,pduraci);

    RETURN Exy;

  END FF_Exy;

 FUNCTION FF_Exy_Cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER)
    RETURN NUMBER IS

    vdurax   NUMBER;
    vduray   NUMBER;
    vduraxy   NUMBER;
    Axy     NUMBER;

  BEGIN

    IF pduraci >= FIN_MORTA THEN
        vdurax:= pduraci-pedad;
        vduray:= pduraci-pedad2;
    ELSE
        vdurax:= pduraci;
        vduray:= pduraci;
    END IF;

    IF nvl(psexo2,0) = 0 THEN --Una cabeza

      Axy := FF_Ex(psesion, ptabla, psexo, pedad, vdurax, pv);

    ELSE

      IF pduraci >= FIN_MORTA THEN
          IF pedad > pedad2 THEN
             vduraxy := pduraci-pedad2;
          ELSE
             vduraxy := pduraci-pedad;
          END IF;
      ELSE
         vduraxy := pduraci;
      END IF;
      Axy := FF_Ex(psesion, ptabla, psexo, pedad, vdurax, pv)
             + FF_Ex(psesion, ptabla, psexo2, pedad2, vduray, pv)
             - FF_Exy(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv);

    END IF;

    RETURN Axy;

  END FF_Exy_Cab;




--Igual que la FF_ax pero empieza por i=0 hasta n-1
 FUNCTION FF_ax2 (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;
    SUM_a      NUMBER;
    Ex         NUMBER;

  BEGIN

    SUM_a := 0;
    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD, pSEXO, p_es_mensual);
    LXI := LX_EDAD;
    FOR i IN 0..pduraci-1 LOOP
       LXI := ff_LX(Psesion, pTABLA, pEDAD+i, pSEXO, p_es_mensual);
       SUM_a := SUM_a + (LXI/LX_EDAD) * POWER(pv,i);
    END LOOP;
--    dbms_output.put_line('SUM_a='||SUM_a);

    Ex := (LXI/LX_EDAD)*POWER(pv,pduraci);
   -- dbms_output.put_line('------------AAAAA:'||(SUM_a + (1-Ex)*(mes-1)/(mes*2)));

    RETURN (SUM_a + (1-Ex)*(mes-1)/(mes*2));

  END FF_ax2;

 --Igual que la FF_axy pero empieza por i=0 hasta n-1
 FUNCTION FF_axy2 (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER,
    pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LY_EDAD     NUMBER;
    LXI         NUMBER;
    LYI         NUMBER;
    SUM_axy     NUMBER;
    Exy         NUMBER;

  BEGIN

    SUM_axy := 0;
    --LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD, pSEXO, p_es_mensual);
    --LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2, pSEXO2, null, null, 'LX');
    LY_EDAD := ff_LX(Psesion, pTABLA, pEDAD2, pSEXO2, p_es_mensual);
    LXI := LX_EDAD;
    LYI := LY_EDAD;
    FOR i IN 0..pduraci-1 LOOP
      --LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+i, pSEXO, null, null, 'LX');
      LXI := ff_LX(Psesion, pTABLA, pEDAD+i, pSEXO, p_es_mensual);
      --LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+i, pSEXO2, null, null, 'LX');
      LYI := ff_LX(Psesion, pTABLA, pEDAD2+i, pSEXO2, p_es_mensual);
--    dbms_output.put_line('axy'||i||'='||(LXI/LX_EDAD)*(LYI/LY_EDAD)*POWER(pv,i));
      SUM_axy := SUM_axy + (LXI/LX_EDAD)*(LYI/LY_EDAD) * POWER(pv,i);

    END LOOP;
  --  dbms_output.put_line('SUM_axy='||SUM_axy);

    Exy := (LXI/LX_EDAD)*(LYI/LY_EDAD)*POWER(pv,pduraci);

    RETURN (SUM_axy + (1-Exy)*(mes-1)/(mes*2));

  END FF_axy2;

  FUNCTION FF_axy_cab2 (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, pfracc IN NUMBER DEFAULT 12,
    p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    vdurax   NUMBER;
    vduray   NUMBER;
    vduraxy   NUMBER;
    a_xym     NUMBER;

  BEGIN

    IF pduraci >= FIN_MORTA THEN
        vdurax:= pduraci-pedad;
        vduray:= pduraci-pedad2;
    ELSE
        vdurax:= pduraci;
        vduray:= pduraci;
    END IF;

    IF nvl(psexo2,0) = 0 THEN --Una cabeza
      a_xym := FF_ax2(psesion, ptabla, psexo, pedad, vdurax, pv, pfracc, p_es_mensual);
    ELSE

      IF pduraci >= FIN_MORTA THEN
          IF pedad > pedad2 THEN
             vduraxy := pduraci-pedad2;
          ELSE
             vduraxy := pduraci-pedad;
          END IF;
      ELSE
         vduraxy := pduraci;
      END IF;



      a_xym := FF_ax2(psesion, ptabla, psexo, pedad, vdurax, pv, pfracc,p_es_mensual)
               + FF_ax2(psesion, ptabla, psexo2, pedad2, vduray, pv, pfracc, p_es_mensual)
               - FF_axy2(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv, pfracc, p_es_mensual);

    END IF;

 --   dbms_output.put_line('a_xym2222='||a_xym);
    RETURN a_xym;

  END FF_axy_cab2;



FUNCTION FF_min_RP (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  RC       NUMBER;
  GASTOS     NUMBER;
  FECEFE   NUMBER;
  FECHA    NUMBER;
  FNACIMI  NUMBER;
  FNAC_ASE2 NUMBER;
  SEXO     NUMBER;
  SEXO_ASE2 NUMBER;
  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  PTIPOINT NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;

  V_INT_GARAN NUMBER;
  V_INT_MIN NUMBER;
  TABLA_MORTA NUMBER;

  Axy   NUMBER;
  Exy   NUMBER;
  a_xym  NUMBER;
  Reserva NUMBER;
  a_xym2  NUMBER;

  retorno  NUMBER := 0;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
--    RC:= pac_GFI.f_sgt_parms ('RC', sesion);
    GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/1000;
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    FECHA:= pac_GFI.f_sgt_parms ('FECHA', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);

    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);

    V_INT_GARAN := 1/(1+PTIPOINT/100);
    V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);
    TABLA_MORTA := 8;
    EDAD_X := FEDAD (sesion, FNACIMI, FECHA, 2);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECHA, 2);
    Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_MIN);
    Exy := FF_Exy_Cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_MIN);


    a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_MIN);

    --con lo de abajo sale exacto el a_xym
    --a_xym := FF_axy_cab2(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_MIN,1);
    --a_xym := a_xym - m_1div2m * (1 - FF_Exy_Cab(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_MIN));


    a_xym2:=FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_MIN);

    --con lo de abajo sale exacto el a_xym
    --a_xym2:=FF_axy_cab(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_MIN,1) + m_1div2m * (1 - FF_Exy_Cab(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_MIN));--- FF_axy_cab(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, 1, V_INT_MIN);

    retorno :=(ICAPREN-ICAPREN*Axy-ICAPREN*Exy-ICAPREN*GASTOS*a_xym)/a_xym2;



    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_min_RP;

FUNCTION FF_temp_RP (sesion IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  PTIPOINT NUMBER;
  V_INT_MIN NUMBER;
  FECEFE   NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;


  retorno  NUMBER := 0;
  ro NUMBER;
  BEGIN


		ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion)/100;
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
    V_INT_MIN := pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI)/100;



    ro:=FF_min_RP(sesion); --Calculamos la renta mínima

    retorno := ro + ICAPREN*(PTIPOINT-V_INT_MIN);


    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_temp_RP;

FUNCTION FF_provi_RP (sesion IN NUMBER,pany IN NUMBER)
    RETURN NUMBER IS

  ICAPREN  NUMBER;
  PTIPOINT NUMBER;
  V_INT_MIN NUMBER;
  FECEFE   NUMBER;
  SPRODUC  NUMBER;
  NDURACI  NUMBER;
  GASTOS NUMBER;

  vf NUMBER;
  vgar NUMBER;
  vg NUMBER;
  vr NUMBER;
  ro number;
  retorno  NUMBER := 0;
  FECHA number;
  FNACIMI number;
  FNAC_ASE2 number;
  SEXO number;
  SEXO_ASE2 number;

  a_xym NUMBER;
  Axy NUMBER;
  Exy NUMBER;
  a_xym2 NUMBER;
  k number;

  EDAD_X NUMBER;
  EDAD_Y NUMBER;
  TABLA_MORTA NUMBER;
  Tot NUMBER;

  BEGIN

    ICAPREN:= pac_GFI.f_sgt_parms ('ICAPREN', sesion);
    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion)/100;
    SPRODUC:= pac_GFI.f_sgt_parms ('SPRODUC', sesion);
    NDURACI:= pac_GFI.f_sgt_parms ('NDURPER', sesion);
    FECEFE:= pac_GFI.f_sgt_parms ('FECEFE', sesion);
		GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/1000;
		FECHA:= pac_GFI.f_sgt_parms ('FECHA', sesion);
    FNACIMI:= pac_GFI.f_sgt_parms ('FNACIMI', sesion);
    FNAC_ASE2:= pac_GFI.f_sgt_parms ('FNAC_ASE2', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
    SEXO_ASE2:= pac_GFI.f_sgt_parms ('SEXO_ASE2', sesion);
		V_INT_MIN := 1/(1+(pac_inttec.Ff_int_producto (SPRODUC, 1, to_date(FECEFE,'yyyymmdd'), NDURACI))/100);

		EDAD_X := FEDAD (sesion, FNACIMI, FECHA, 2);
    EDAD_Y := FEDAD (sesion, FNAC_ASE2, FECHA, 2);

		ro:=FF_min_RP(sesion); --Calculamos la renta mínima

    k:=pany;
     TABLA_MORTA := 8;
    --For k in 0..pany LOOP

		 EDAD_X:=EDAD_X+k;
		 EDAD_Y:=EDAD_Y+k;

		 Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-k, V_INT_MIN);
		 vf:=ICAPREN*Axy;

		 Exy := FF_Exy_Cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-k, V_INT_MIN);
		 vgar:=ICAPREN*Exy;

		 --a_xym := FF_axy_cab2(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-k, V_INT_MIN,1);
	   --a_xym := a_xym - m_1div2m * (1 - FF_Exy_Cab(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-k, V_INT_MIN));

		 a_xym :=FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-k, V_INT_MIN);
		 vg:=ICAPREN*GASTOS*a_xym;


		 --a_xym2:=FF_axy_cab(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-k, V_INT_MIN,1) + m_1div2m * (1 - FF_Exy_Cab(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-k, V_INT_MIN));--- FF_axy_cab(xsesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, 1, V_INT_MIN);

	   a_xym2:=FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI-k, V_INT_MIN);
	   vr:=a_xym2*ro;

	   Tot:=vf+vgar+vg+vr;


    --End Loop;

    RETURN Tot;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Error='||sqlerrm);
      RETURN -1;
  END FF_provi_RP;
END pac_formul_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_RENTAS" TO "PROGRAMADORESCSI";
