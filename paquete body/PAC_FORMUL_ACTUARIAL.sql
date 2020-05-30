--------------------------------------------------------
--  DDL for Package Body PAC_FORMUL_ACTUARIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FORMUL_ACTUARIAL" IS

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


  FUNCTION FF_ProgresionAcum (psesion IN NUMBER,
                          gg in number,
                          ig in number,
                          nduraci in number,
                          pfracc IN NUMBER DEFAULT 12,
                          p_es_mensual IN NUMBER DEFAULT 0) Return NUMBER IS

  Valor number:=0;
  prog number;
  pduraci number;
  BEGIN

    if p_es_mensual <> 0 then

      pduraci:=nduraci*12;

      for i in 0..pduraci loop

        if mod(i,12)=0 then
          prog:=power((1+gg/100),floor(i/12)) + floor((i/12))*(ig/100) ;
        end if;

        Valor:=Valor+prog;

      end loop;

    else

      pduraci:=nduraci;

      for i in 0..pduraci loop

        prog:=power((1+gg/100),i) + (i)*(ig/100) ;

        Valor:=Valor+prog;

      end loop;

    end if;

    Return Valor;

  END;

 FUNCTION FF_Progresion  (psesion IN NUMBER,
                          gg in number,
                          ig in number,
                          nduraci in number,
                          pfracc IN NUMBER DEFAULT 12,
                          p_es_mensual IN NUMBER DEFAULT 0) Return NUMBER IS

  Valor number:=0;
  prog number;
  pduraci number;
  BEGIN

    if p_es_mensual <> 0 then

      pduraci:=nduraci*12;

      for i in 0..pduraci loop

        if mod(i,12)=0 then
          prog:=power((1+gg/100),i/12) + (i/12)*(ig/100) ;
        end if;

      end loop;

    else

      pduraci:=nduraci;

      for i in 0..pduraci loop

        prog:=power((1+gg/100),i) + (i)*(ig/100) ;


      end loop;

    end if;

    Return Prog;

  END;

FUNCTION FF_LXProg (psesion IN NUMBER, ptabla IN NUMBER, pedad IN NUMBER, psexo IN NUMBER, p_es_mensual IN NUMBER,
                 gg number  default  null,ig number default null,edadIni in number)
  RETURN NUMBER IS

  retorno  NUMBER := 0;
  v_lx 	   NUMBER := 0;
  vedad	   NUMBER := pedad;
  residuo	   NUMBER := 0;
  v_lx2 	   NUMBER := 0;
  Prog Number;
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


    if gg is not null or ig is not null then
      Prog:= FF_Progresion (psesion,gg  ,ig ,pedad-edadIni,12 , p_es_mensual);

    else
      Prog:=1;
    end if;

    dbms_output.put_line('Prog:'||Prog);
    dbms_output.put_line('retorno:'||retorno);

    RETURN Prog*retorno;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END FF_LXProg;


  FUNCTION FF_axProg (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,gg in number,ig in number, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;
    SUM_a      NUMBER;
    Ex         NUMBER;
    lduraci number;
    Prog number;
    var number; --años de menos
    bb number:=0;
    sumtot number:=1500;
  BEGIN


    SUM_a := 0;

    var:=2;

    if p_es_mensual <>0 then
      lduraci:=pduraci*12;
    end if;

    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD-2-pduraci, pSEXO, p_es_mensual);

    dbms_output.put_line('LX_EDAD:'||LX_EDAD||'    '||(LX_EDAD) * POWER(pv,pEdad));

    LXI := LX_EDAD;

    sumtot:=(128-pedad)*12;

    FOR i IN 0..sumtot LOOP

      if gg is not null or ig is not null then
        Prog:= FF_Progresion (psesion,gg  ,ig ,pduraci+i/12,12 , p_es_mensual);
      else
        Prog:=1;
      end if;

      LXI := ff_LX(Psesion, pTABLA, pEDAD-2 +(i/12), pSEXO, p_es_mensual);

      --La verdadera SUM_a := SUM_a + Prog*(LXI/LX_EDAD) * POWER(pv,i/12);
      --SUM_a := SUM_a + (Prog*(LXI) * POWER(pv,pEdad + i/12)  ) / (  (LX_EDAD) * POWER(pv,pEdad) );
      SUM_a := SUM_a + Prog*(LXI/LX_EDAD) * POWER(pv, pduraci + i/12)  ;

      dbms_output.put_line(12*pEDAD +i ||'   '||Prog||'   '|| 'Valor'||LXI * POWER(pv,pEdad + i/12) / 1000000       );

      bb:=bb+   (LXI / (1000000 * POWER(pv,round(pEdad + i/12,2)) ));
      --dbms_output.put_line('--------'||bb    );
    END LOOP;
dbms_output.put_line('SUM_a:'||SUM_a);
    Ex := (LXI/LX_EDAD)*POWER(pv,pduraci);

    RETURN (SUM_a + (1-Ex)*(mes-1)/(mes*2));

  END FF_axProg;

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
    --IF v.FNAC2 IS NOT NULL THEN
    IF v.sexo2 <> 0 THEN
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
  --  dbms_output.put_line('lx mensualizada (edad '||pedad||')='||retorno);
    ELSE
        retorno := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    END IF;



    RETURN retorno;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END FF_LX;

  FUNCTION FF_A (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;
    LXI1        NUMBER;
    SUM_AX      NUMBER;

  BEGIN

    SUM_AX := 0;
    dbms_output.put_line('pTABLA='||pTABLA||'pEDAD'||pEDAD||'pSEXO'||pSEXO);
    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD, pSEXO,p_es_mensual);



    dbms_output.put_line('LX_EDAD='||LX_EDAD);
    FOR i IN 0..pduraci LOOP
      LXI := ff_LX(Psesion, pTABLA, pEDAD+i, pSEXO,p_es_mensual);
      LXI1 := ff_LX(Psesion, pTABLA, pEDAD+i+1, pSEXO, p_es_mensual);
      SUM_AX := SUM_AX + ((LXI-LXI1)/LX_EDAD) * POWER(pv, i+0.5);
--      SUM_AX := SUM_AX + (LXI-LXI1) * POWER(pv, i+0.5);
--    dbms_output.put_line('SUM_AX'||i||'='||SUM_AX);
    END LOOP;
    RETURN SUM_AX;

  END FF_A;

  FUNCTION FF_A2 (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    psexo2 IN NUMBER, pedad2 IN NUMBER, pduraci IN NUMBER, pv IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
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
    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD, pSEXO, p_es_mensual);



    LY_EDAD := ff_LX(Psesion, pTABLA, pEDAD2, pSEXO2,p_es_mensual);
--    dbms_output.put_line('LX_EDAD='||LX_EDAD);
    FOR i IN 0..pduraci LOOP
      LXI := ff_LX(Psesion, pTABLA, pEDAD+i, pSEXO, p_es_mensual);
      LXI1 := ff_LX(Psesion, pTABLA, pEDAD+i+1, pSEXO, p_es_mensual);
      LYI := ff_LX(Psesion, pTABLA, pEDAD2+i, pSEXO2, p_es_mensual);
      LYI1 := ff_LX(Psesion, pTABLA, pEDAD2+i+1, pSEXO2, p_es_mensual);
      SUM_A2 := SUM_A2 + ((LXI*LYI-LXI1*LYI1)/(LX_EDAD*LY_EDAD)) * POWER(pv,i+0.5);
--    dbms_output.put_line('SUM_A2'||i||'='||SUM_A2);
    END LOOP;
    RETURN SUM_A2;

  END FF_A2;

  FUNCTION FF_A_cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
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

      Axy := FF_A(psesion, ptabla, psexo, pedad, vdurax, pv,mes,p_es_mensual);

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

      Axy := FF_A(psesion, ptabla, psexo, pedad, vdurax, pv,mes,p_es_mensual)
             + FF_A(psesion, ptabla, psexo2, pedad2, vduray, pv,mes,p_es_mensual)
             - FF_A2(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv,mes,p_es_mensual);

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
    pduraci IN NUMBER, pv IN NUMBER,pfrac number default 12, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    LX_EDAD     NUMBER;
    LXI         NUMBER;
    SUM_a      NUMBER;
    Ex         NUMBER;

  BEGIN

    SUM_a := 0;
    --LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');

    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD, pSEXO, p_es_mensual);


   -- LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+pduraci, pSEXO, null, null, 'LX');
    LXI := ff_LX(Psesion, pTABLA, pEDAD+pduraci, pSEXO, p_es_mensual);
    Ex := (LXI/LX_EDAD)*POWER(pv,pduraci);
    dbms_output.put_line('!!!!!!Ex='||Ex);

    RETURN Ex;

  END FF_Ex;

  FUNCTION FF_factorprovi (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,
    pRo IN NUMBER, preserva IN NUMBER, pgastos IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER IS

    Axy     NUMBER;
    a_xym   NUMBER;
    retorno NUMBER;

  BEGIN

    Axy := FF_A_cab(psesion, ptabla, psexo, pedad, psexo2, pedad2, pduraci, pv,mes,p_es_mensual);
    a_xym := FF_axy_cab(psesion, ptabla, psexo, pedad, psexo2, pedad2, pduraci, pv,mes,p_es_mensual);
    dbms_output.put_line('Axy='||Axy||' a_xym='||a_xym);

    retorno := pRo * (1+pgastos) * a_xym + preserva * Axy;

    dbms_output.put_line('factorprovi='||retorno);
    RETURN retorno;

  END FF_factorprovi;

  FUNCTION FF_factorgaran (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,
    pRo IN NUMBER, preserva IN NUMBER, pgastos IN NUMBER,
    pv_E IN NUMBER, nitera IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
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
                         pRo, preserva, pgastos,mes,p_es_mensual);
    dbms_output.put_line('nVxy='||nVxy);
    dbms_output.put_line('  edad lx_edad='||(pEDAD+nitera));
    LX_EDAD := ff_lx(Psesion, pTABLA, pEDAD+nitera, pSEXO, p_es_mensual);
    dbms_output.put_line('  edad lxi='||(pEDAD+pduraci));
    LXI := ff_lx(Psesion, pTABLA, pEDAD+pduraci, pSEXO, p_es_mensual);
    dbms_output.put_line('  lxi='||lxi ||'  lx_edad='||lx_edad);

    IF nvl(psexo2,0) = 0 THEN --Una cabeza

    dbms_output.put_line('Ex='||((LXI/LX_EDAD)*POWER(pv,pduraci-nitera)));
    dbms_output.put_line('nitera='||nitera||' power='||POWER(pv,pduraci-nitera));
        resul := nVxy * (LXI/LX_EDAD)*POWER(pv_E,pduraci-nitera);

    ELSE

        -- Provision si vive solo x
        nVx:= FF_factorprovi(psesion, ptabla, psexo, pedad+pduraci, 0, 0, FIN_MORTA, pv,
                             pRo, preserva, pgastos,mes,p_es_mensual);
        -- Provision si vive solo y
        nVy:= FF_factorprovi(psesion, ptabla, psexo2, pedad2+pduraci, 0, 0, FIN_MORTA, pv,
                             pRo, preserva, pgastos,mes,p_es_mensual);

        LY_EDAD := ff_lx(Psesion, pTABLA, pEDAD2+nitera, pSEXO2,p_es_mensual);
        LYI := ff_lx(Psesion, pTABLA, pEDAD2+pduraci, pSEXO2,p_es_mensual);

    dbms_output.put_line('factor NVxy='||nVxy||' nVx='||nVx||' nVy='||nVy);
    dbms_output.put_line('factor LXI='||LXI||' LYI='||LYI||' LY_EDAD='||LY_EDAD);
        resul := nVxy * (LXI*LYI/(LX_EDAD*LY_EDAD))*POWER(pv_E,pduraci-nitera)
               + nVx * (LXI*(LY_EDAD-LYI)/(LX_EDAD*LY_EDAD))*POWER(pv_E,pduraci-nitera)
               + nVy * (LYI*(LX_EDAD-LXI)/(LX_EDAD*LY_EDAD))*POWER(pv_E,pduraci-nitera);

    END IF;

    dbms_output.put_line('factorgaran='||resul);
    RETURN resul;

  END FF_factorgaran;

FUNCTION FF_Exy (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    psexo2 IN NUMBER, pedad2 IN NUMBER,pduraci IN NUMBER, pv IN NUMBER,pfrac number default 12, p_es_mensual IN NUMBER DEFAULT 0)
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
    --LX_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD, pSEXO, null, null, 'LX');
    --LXI := ff_mortalidad(Psesion, pTABLA, pEDAD+pduraci, pSEXO, null, null, 'LX');



    LX_EDAD := ff_LX(Psesion, pTABLA, pEDAD, pSEXO,  p_es_mensual);
    LXI := ff_LX(Psesion, pTABLA, pEDAD+pduraci, pSEXO, p_es_mensual);

    --LY_EDAD := ff_mortalidad(Psesion, pTABLA, pEDAD2, pSEXO2, null, null, 'LX');
    --LYI := ff_mortalidad(Psesion, pTABLA, pEDAD2+pduraci, pSEXO2, null, null, 'LX');

    LY_EDAD := ff_LX(Psesion, pTABLA, pEDAD2, pSEXO2,p_es_mensual);
    LYI := ff_LX(Psesion, pTABLA, pEDAD2+pduraci, pSEXO2, p_es_mensual);

    Exy := (LXI/LX_EDAD)*(LYI/LY_EDAD)*POWER(pv,pduraci);

    RETURN Exy;

  END FF_Exy;

 FUNCTION FF_Exy_Cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,pfrac number default 12, p_es_mensual IN NUMBER DEFAULT 0)
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

      Axy := FF_Ex(psesion, ptabla, psexo, pedad, vdurax, pv,pfrac,p_es_mensual);

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
      Axy := FF_Ex(psesion, ptabla, psexo, pedad, vdurax, pv,pfrac,p_es_mensual)
             + FF_Ex(psesion, ptabla, psexo2, pedad2, vduray, pv,pfrac,p_es_mensual)
             - FF_Exy(psesion, ptabla, psexo, pedad, psexo2, pedad2, vduraxy, pv,pfrac,p_es_mensual);

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


FUNCTION F_CPG_PPJ (sesion IN NUMBER)
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
  v_sseguro NUMBER:=0;
  v_capital NUMBER:=0;
  NRIESGO NUMBER:=0;
  BEGIN

    --  GASTOS:= pac_GFI.f_sgt_parms ('GASTOS', sesion)/100;
    FECEFE:= pac_GFI.f_sgt_parms ('FEFEPOL', sesion); --No esta fecefec
    NRIESGO:= pac_GFI.f_sgt_parms ('NRIESGO', sesion);
    SEXO:= pac_GFI.f_sgt_parms ('SEXO', sesion);
     v_SSEGURO:= pac_GFI.f_sgt_parms ('SSEGURO', sesion);

    select TO_CHAR(FNACIMI,'YYYYMMDD')
    INTO FNACIMI
    from ESTPER_PERSONAS
    where
    sperson = (select sperson from estriesgos where sseguro = v_SSEGURO and nriesgo = NRIESGO);


    PTIPOINT:= pac_GFI.f_sgt_parms ('PTIPOINT', sesion);
    NDURACI:= nvl(pac_GFI.f_sgt_parms ('NDURPER', sesion),10);


    begin
     select sum(icapital)
     into v_capital
      from estgaranseg
      where
      sseguro = v_SSEGURO and
      cgarant in (48,282);
    EXCEPTION
    when others then
        v_capital:=1;
    end;

    V_INT_GARAN := 1/(1+PTIPOINT/100);

    TABLA_MORTA := 8;
--CPM    TABLA_MORTA := 5;

    EDAD_X := FEDAD (sesion, FNACIMI, FECEFE, 2);

    --Axy := FF_A_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);
    --a_xym := FF_axy_cab(sesion, TABLA_MORTA, SEXO, EDAD_X, SEXO_ASE2, EDAD_Y, NDURACI, V_INT_GARAN);

    Axy:=FF_Ex(sesion,TABLA_MORTA,SEXO,EDAD_X,NDURACI,V_INT_GARAN ,12,1);


    RETURN v_capital*Axy;

  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,  F_USER,  'PAC_FORMUL_ACTUARIAL.F_CPG_PPJ',NULL, 'parametros: FECEFE = '||FECEFE||' FNACIMI ='||FNACIMI||' NDURACI ='||NDURACI||' V_INT_GARAN ='||V_INT_GARAN,
                      SQLERRM);
      RETURN -1;
  END F_CPG_PPJ;

END PAC_FORMUL_ACTUARIAL;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_ACTUARIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_ACTUARIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_ACTUARIAL" TO "PROGRAMADORESCSI";
