--------------------------------------------------------
--  DDL for Package Body PAC_FORMUL_PE_PPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FORMUL_PE_PPA" IS
  -- Variables per salvar resultats anteriors
  gFechaSaldo DATE;
  gsSeguro SEGUROS.SSEGURO%TYPE;
  gFecMov DATE;
  gOrigen VARCHAR2(1);
  --
  --
  --
  PROCEDURE CalculaOperacion
  (
    pSesion           IN              NUMBER,
    psSolit_Seguro    IN              SEGUROS.SSEGURO%TYPE,
    pTablas           IN              VARCHAR2,
    pOPERACION        IN              VARCHAR2,
    pFE_VENCI         IN              DATE,
    pFE_ALTA          IN              DATE,
    pFE_REVINT        IN              DATE,
    pFE_INTERES       IN              DATE,     -- Data a utilitzar per calcular l'interès
    pFE_ULT_OPER      IN              DATE,
    pFE_PROCESO       IN              DATE,
    pPRIMES           IN              NUMBER,
    pCAP_SUPER        IN OUT          NUMBER,
    pCAP_FALL         IN OUT          NUMBER,
    pPROV_MAT         IN OUT          NUMBER
  )
  IS
    xCAP_SUPER        NUMBER(13,2);
    xFE_REVINT        date;
    xFE_INTERES       DATE;

    PRIMES           NUMBER(13,2);
    CAP_SUPER        NUMBER(13,2);
    CAP_FALL         NUMBER(13,2);
    PROV_MAT         NUMBER(13,2);

    v_anyos         NUMBER;
    v_error         LITERALES.SLITERA%TYPE;
    v_traza               TAB_ERROR.NTRAZA%TYPE;

    PROCEDURE CALCULO_G IS   --- CALCULO DEL CAPITAL GARANTIZADO AL VENCIMIENTO.
    BEGIN
      v_traza := 10;
      CAP_SUPER := PAC_FORMUL_PE_PPA_CALC.CAPGARAN(psesion, psSolit_Seguro, pTablas, pOPERACION, pFE_VENCI, pFE_ALTA, xFE_REVINT, pFE_INTERES, pFE_ULT_OPER,
                                            pFE_PROCESO, PRIMES, CAP_SUPER, pCAP_FALL, PROV_MAT);
    END;

    PROCEDURE CALCULO_F IS -- CALCULO DEL CAPITAL DE FALLECIMIENTO
    BEGIN
      v_traza := 20;
      cap_fall := PAC_FORMUL_PE_PPA_CALC.capital_fallecimiento (psesion, psSolit_Seguro, pTablas, pOperacion,pFE_ULT_OPER, pFE_PROCESO, xFE_INTERES, PRIMES , pCAP_FALL) ;
    END;

    PROCEDURE CALCULO_P IS -- CALCULO DE LA PROVISION MATEMATICA
    BEGIN
      v_traza := 30;
      PROV_MAT := PAC_FORMUL_PE_PPA_CALC.PROVMAT(psesion, psSolit_Seguro, pTablas, pOPERACION, pFE_VENCI,pFE_ALTA, xFE_REVINT, xFE_INTERES, pFE_ULT_OPER,
               pFE_PROCESO, PRIMES, CAP_SUPER, pCAP_FALL, PROV_MAT);
    END;

    PROCEDURE CALCULO_Z IS   --- CAPITAL SUPERVIVENCIA AMB UN CANVI DE VENCIMENT
    BEGIN
      v_traza := 40;
      CAP_SUPER := PAC_FORMUL_PE_PPA_CALC.PROVMATZ(psesion, psSolit_Seguro, pTablas, pOPERACION, pFE_VENCI, pFE_ALTA, xFE_REVINT, pFE_INTERES,
                                            pFE_PROCESO, CAP_SUPER, pCAP_FALL, PROV_MAT);
    END;
  BEGIN
    v_traza := 1;
    PRIMES     := pPRIMES;
    CAP_SUPER  := pCAP_SUPER;
    CAP_FALL   := pCAP_FALL;
    PROV_MAT   := pPROV_MAT;
    xFE_REVINT := pFE_REVINT;
    xFE_INTERES := pFE_INTERES;

--dbms_output.put_line('calcula operacion con poperacion ='||poperacion||' y xfe_interes ='||xfe_interes);

    IF pOPERACION IN ('PRIMA') THEN
      CALCULO_F;
      CALCULO_P;
      CALCULO_G;
    ELSIF pOPERACION IN ('CIERRE MENSUAL') THEN
      PRIMES:=0;
      CALCULO_F;
      CALCULO_P;
    ELSIF pOPERACION IN ('REVISION') THEN
      PRIMES:=0;
      xFE_INTERES := pFE_INTERES-1;
      CALCULO_F;
--DBMS_OUTPUT.PUT_LINE('cap_fall despues de calculo_f ='||cap_fall);
      CAP_SUPER := pCAP_SUPER;  -- Necessita el CAP_SUPER original, no el modificat
--DBMS_OUTPUT.PUT_LINE('CAP SUPER PARA CALCULO PROVISION ='||CAP_SUPER);
      CALCULO_P;
      DBMS_OUTPUT.PUT_LINE('prov_mat despues de calculo_p ='||prov_mat);
--DBMS_OUTPUT.PUT_LINE('llamamos a calculo_g');
      calculo_g;
--DBMS_OUTPUT.PUT_LINE('cap_super despues de calculo_g ='||cap_super);
    ELSIF pOPERACION IN ('Z') THEN
      PRIMES:=0;
      CALCULO_Z;
    END IF;
    v_traza := 2;

--DBMS_OUTPUT.PUT_LINE('*******************************************');
--DBMS_OUTPUT.PUT_LINE('  CAP_SUPER'  ||':='||CAP_SUPER);
--DBMS_OUTPUT.PUT_LINE('  CAP_FALL'   ||':='||CAP_FALL);
--DBMS_OUTPUT.PUT_LINE('  PROV_MAT'   ||':='||PROV_MAT);
--DBMS_OUTPUT.PUT_LINE('*******************************************');
    pCAP_SUPER  := CAP_SUPER;
    pCAP_FALL   := CAP_FALL;
    pPROV_MAT   := PROV_MAT;
--DBMS_OUTPUT.PUT_LINE('CAP_SUPER'||'='||CAP_SUPER||' CAP_FALL'||'='||CAP_FALL||' PROV_MAT'||'='||PROV_MAT||' pOPERACION'||'='||pOPERACION);
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,  F_USER,  'PAC_FORMUL_PE_PAA.CalculoOperacion',v_traza, 'parametros: psesion ='||psesion||' psseguro='||psSolit_Seguro,
           SQLERRM);
      RAISE;
  END;

  --
  --
  --
  PROCEDURE Calculo( pSesion IN NUMBER, psSolit_Seguro IN NUMBER) IS
    vFechaSaldo DATE;

    v_siguiente_revision  DATE;     -- Data de la següent revisió a calcular
    v_siguiente_cierre    DATE;     -- Data del següent tancament
    v_fecha_tratado_hasta DATE;     -- Fins quina data s'ha fet el tractament dins aquesta rutina
    v_tratar_revision     BOOLEAN;
    v_tratar_cierre       BOOLEAN;
    v_fecha_interes       DATE;
    v_fecha_proceso       DATE;
    v_comptador           NUMBER(1);
    vPrimaInicial         NUMBER;
    v_sSolit_Seguro       NUMBER;
    v_traza               TAB_ERROR.NTRAZA%TYPE;
    v_primariesgo         number;
    vnnumlin              number;
    v_prima                 number;
    v_fvencim_canvia      BOOLEAN;
    v_fvencim_ant         DATE;
    v_aport_ext             number;
    calcula_interes_prom    boolean := false;

    vOrigen  CONSTANT NUMBER(1) := TO_NUMBER(pac_GFI.f_sgt_parms ('ORIGEN', psesion));
    vTablas  CONSTANT VARCHAR2(3) := CASE vOrigen  WHEN '0' THEN 'SOL' WHEN '1' THEN 'EST' WHEN '2' THEN 'SEG' ELSE 'XXX' END;
    vFecMov  CONSTANT DATE := TO_DATE(NVL(pac_GFI.f_sgt_parms ('FECHA', psesion),pac_GFI.f_sgt_parms ('FECMOV', psesion)),'YYYYMMDD');
    vFVencim CONSTANT DATE := TO_DATE(pac_GFI.f_sgt_parms ('FECVEN', psesion),'YYYYMMDD');
    vFecAlta CONSTANT DATE := TO_DATE(pac_GFI.f_sgt_parms ('FEFEPOL', psesion),'YYYYMMDD');
  BEGIN
--DBMS_OUTPUT.PUT_LINE('entramos en el sn_t01**************************************');
    v_traza := 1;

    IF vOrigen = '2' THEN   -- SEG
      v_sSolit_Seguro := psSolit_Seguro;
      P_DATOS_ULT_SALDO( v_sSolit_Seguro, vfecmov, vFechaSaldo, gProvMat, gCapGar, gCapFall, vnnumlin );
    ELSIF vOrigen = '1' THEN  -- EST
      v_traza := 11;
      SELECT ssegpol INTO v_sSolit_Seguro FROM estseguros WHERE sseguro = psSolit_Seguro;
      v_traza := 12;

--DBMS_OUTPUT.PUT_LINE('*********************** v_sSolit_Seguro = '||v_sSolit_Seguro);

      P_DATOS_ULT_SALDO( v_sSolit_Seguro, vfecmov, vFechaSaldo, gProvMat, gCapGar, gCapFall, vnnumlin );

--DBMS_OUTPUT.PUT_LINE('*********************** gProvMat = '||gProvMat);
--DBMS_OUTPUT.PUT_LINE('*********************** gCapGar = '||gCapGar);
--DBMS_OUTPUT.PUT_LINE('*********************** gCapFall = '||gCapFall);

    ELSE -- vOrigen = '0' -- SOL
      v_sSolit_Seguro := psSolit_Seguro;
      gProvMat := 0;
      gCapGar := 0;
      gCapFall := 0;
      vFechaSaldo := NULL;
      vnnumlin := 0;
    END IF;

    v_traza := 3;
    IF vFechaSaldo IS NULL THEN
      gProvMat := 0;
      gCapGar  := 0;
      gCapFall := 0;
      vnnumlin := 0;
      vFechaSaldo := vFecAlta;
    END IF;

    -- Ordre de processament en cas que la data coincideixi
    --    1.- Revisió interès
    --    2.- Primes
    --    3.- Tancament Mensual

    v_traza := 5;
    if vOrigen in (1,2) then
       begin
          select frevisio into v_siguiente_revision
          from seguros_aho
          where sseguro = v_sSolit_Seguro;
       exception
          when others then
             v_siguiente_revision := null;
       end;
    end if;
    if v_siguiente_revision is null then
       v_siguiente_revision := ADD_MONTHS(vFecAlta, CEIL(ABS(MONTHS_BETWEEN(vFechaSaldo, vFecAlta))/12) * 12 );
    end if;
    IF  v_siguiente_revision = vFechaSaldo THEN
      v_siguiente_revision := ADD_MONTHS(v_siguiente_revision,12);
    END IF;

    -- A l'alta no tenim prima a ctaseguro
    IF vOrigen IN ('1','2') THEN  -- tablas 'EST' y 'SEG'
        SELECT COUNT(1) c
        INTO v_comptador
        FROM ctaseguro
        WHERE sseguro = v_sSolit_Seguro AND cmovimi IN (1,2,8) AND ROWNUM = 1;
    END IF;


    -- Guardem a v_fvencim_canvia si canvia la data venciment entre SEG i EST
    v_fvencim_canvia := FALSE;

--dbms_output.put_line('*********************** psSolit_Seguro = '||psSolit_Seguro);

    FOR r IN ( SELECT s.fvencim s_fvencim, es.fvencim  es_fvencim FROM seguros s, estseguros es WHERE s.sseguro = es.ssegpol AND es.sseguro = psSolit_Seguro )  LOOP
      v_fvencim_canvia := NOT NVL(r.s_fvencim = r.es_fvencim,FALSE) OR ( r.s_fvencim IS NULL AND  r.es_fvencim IS NULL );
      v_fvencim_ant := r.s_fvencim;
    END LOOP;

    -- gProvMat = 0 és per incloure quan hi ha hagut extorns com primers moviments
    --IF (v_comptador = 0 and vFecAlta = vFechaSaldo) OR vOrigen = '0'  OR gProvMat = 0 THEN
    -- se quita gProvmat = 0 porque no queremos que entren las anuladas las cuales tienen provmat = 0
    IF (v_comptador = 0 and vFecAlta = vFechaSaldo) OR vOrigen = '0' THEN
      v_traza := 6;
      v_prima := PAC_FORMUL_PE_PPA_CALC.Interes_Promocional ( pSesion ,
                                 psSolit_Seguro,
                                 vTablas,
                                 vFecAlta,
                                 vFecAlta,    -- pFecProceso
                                 nvl(RESP(pSesion,1002),0),  -- pPrimaInicial
                                 nvl(RESP(pSesion,6),0)  -- pInteresPromocional
                                );
      v_traza := 6;
      CalculaOperacion ( pSesion, psSolit_Seguro, vTablas, 'PRIMA', vFVencim, vFecAlta, v_siguiente_revision, vFecAlta, vFecAlta, vFecAlta, v_prima, gCapGar, gCapFall, gProvMat ) ;

      -- Per SOL calcular fins la data demanada
      -- La simulació pot incloure calcular les futures revisions
      IF vOrigen = '0' THEN
          v_traza := 64;
          v_fecha_tratado_hasta := vFecAlta;
          WHILE vFecMov >  v_fecha_tratado_hasta LOOP
            v_traza := 65;
            v_fecha_proceso := ADD_MONTHS(v_fecha_tratado_hasta,12)-1;
            v_fecha_interes := ADD_MONTHS(v_fecha_tratado_hasta,12);
            v_siguiente_revision := ADD_MONTHS(v_fecha_tratado_hasta,12);
            CalculaOperacion ( pSesion, psSolit_Seguro,vTablas, 'CIERRE MENSUAL', vFVencim, vFecAlta, v_siguiente_revision, v_fecha_interes, v_fecha_tratado_hasta, v_fecha_proceso, 0, gCapGar, gCapFall, gProvMat ) ;
            v_fecha_tratado_hasta := ADD_MONTHS(v_fecha_tratado_hasta,12);
          END LOOP;
      END IF;
    ELSIF vOrigen = '1' AND v_fvencim_canvia THEN

       v_fecha_interes := vFecMov; --v_fvencim_ant; --vFecMov;
       v_fecha_proceso := vFecMov; --v_fvencim_ant;
/*
       vFechaSaldo := v_fvencim_ant;
       v_siguiente_revision := ADD_MONTHS(vFecAlta, CEIL(ABS(MONTHS_BETWEEN(v_fvencim_ant, vFecAlta))/12) * 12 );
       IF v_siguiente_revision = v_fvencim_ant THEN
          v_siguiente_revision := ADD_MONTHS(v_siguiente_revision, 12);
       END IF;
*/


      -- Canvi de data de venciment
      CalculaOperacion ( pSesion, psSolit_Seguro,vTablas, 'Z', vFVencim, vFecAlta, v_siguiente_revision, v_fecha_interes, vFechaSaldo, v_fecha_proceso, 0, gCapGar, gCapFall, gProvMat ) ;
    ELSE
      v_fecha_tratado_hasta := vFechaSaldo;
      -- Contemplem possibles primes encara no comptabilitzades
      v_traza := 7;
/*
      FOR rCtaSeguro IN ( SELECT * FROM ctaseguro WHERE sseguro = v_sSolit_Seguro AND fvalmov >= vFechaSaldo
                          AND fvalmov <= vFecMov
                          AND ((cmovimi IN (1,2,51) and nnumlin > vnnumlin and cmovanu = 0)
                             or (nnumlin < vnnumlin and cmovimi in (1,2,51))) ORDER BY sseguro, fvalmov, nnumlin)  LOOP
*/

      FOR rCtaSeguro IN ( SELECT * FROM ctaseguro WHERE sseguro = v_sSolit_Seguro AND fvalmov >= vFechaSaldo
                          AND fvalmov <= vFecMov AND cmovimi IN (1,2,51,8,47)
                          --and nnumlin > vnnumlin
                          and ccalint = 0
                          and cmovanu = 0 ORDER BY sseguro, fvalmov, nnumlin ) LOOP
        -- Miramos si tenemos que aplicar interés promocional
        if rCtaseguro.fvalmov < add_months(vFecAlta,1) then
           calcula_interes_prom := true;
        else
           calcula_interes_prom := false;
        end if;
        -- Tractar tots els tancaments de mes i tots les revisions d'interes que falten abans de la prima
        WHILE rCtaSeguro.fvalmov >  v_siguiente_revision-- OR rCtaSeguro.fvalmov >  v_siguiente_cierre
          LOOP
            v_fecha_proceso := v_siguiente_revision;
            v_tratar_revision := ( v_siguiente_revision = v_fecha_proceso );
            v_fecha_interes := v_siguiente_revision;
            IF v_tratar_revision THEN
              v_traza := 8;
              CalculaOperacion ( pSesion, psSolit_Seguro, vTablas, 'REVISION', vFVencim, vFecAlta, v_siguiente_revision, v_fecha_interes, v_fecha_tratado_hasta, v_fecha_proceso, 0, gCapGar, gCapFall, gProvMat ) ;
              v_siguiente_revision := ADD_MONTHS(v_siguiente_revision,12);
            END IF;

            v_fecha_tratado_hasta := v_fecha_proceso;
          END LOOP;

          -- Tractar la prima
          v_traza := 10;
          v_fecha_proceso := LEAST(v_siguiente_revision, rCtaSeguro.fvalmov);
          v_tratar_revision := ( v_siguiente_revision = v_fecha_proceso );
          v_fecha_interes := v_siguiente_revision;
          IF v_tratar_revision THEN
            v_traza := 11;
            CalculaOperacion ( pSesion, psSolit_Seguro, vTablas,'REVISION', vFVencim, vFecAlta, v_siguiente_revision, v_fecha_interes, v_fecha_tratado_hasta, v_fecha_proceso, 0, gCapGar, gCapFall, gProvMat ) ;
            v_siguiente_revision := ADD_MONTHS(v_siguiente_revision,12);
          END IF;
          v_traza := 12;
          if rCtaSeguro.nnumlin = 1 or rCtaseguro.cmovimi IN (1,8) then --si es el alta o aport. extr. no se resta prima de riesgo
             v_primariesgo := 0;
          elsif rCtaseguro.cmovimi = 51 then
             -- tenemos que saber el tipo de aportación por el recibo
             begin
                select distinct decode(cmovimi, 1, 0, nvl(resp(pSesion,1007),0))
                into v_primariesgo
                from ctaseguro
                where sseguro = v_sSolit_Seguro
                and nrecibo = rCtaseguro.nrecibo
                and cmovimi <> 51;
              exception
                 when others then
                    -- miramos si hay una aportación extraordinaria que coincida en importe.
                    -- si es así no cobramos la prima de riesgo
                    select count(*) into v_aport_ext
                    from ctaseguro
                    where cmovimi = 1
                    and sseguro = v_sSolit_Seguro
                    and imovimi = rCtaseguro.imovimi;
                    if v_aport_ext > 0 then
                       v_primariesgo := 0;
                    else
                       v_primariesgo := nvl(resp(pSesion,1007),0);
                    end if;
              end;
          ELSIF rCtaseguro.cmovimi = 47 then
             v_primariesgo := 0;
          else
             v_primariesgo := nvl(resp(pSesion,1007),0);
          end if;

          v_prima := case rCtaseguro.cmovimi when 51 then -rCtaseguro.imovimi+v_primariesgo
                      when 47 then -rCtaseguro.imovimi+v_primariesgo
                      else rCtaseguro.imovimi-v_primariesgo end;
          if calcula_interes_prom then
             v_prima := PAC_FORMUL_PE_PPA_CALC.Interes_Promocional ( pSesion ,
                                 psSolit_Seguro,
                                 vTablas,
                                 vFecAlta,
                                 vFecAlta,    -- pFecProceso
                                 v_prima,  -- pPrimaInicial
                                 nvl(RESP(pSesion,6),0)  -- pInteresPromocional
                                );

          end if;

          CalculaOperacion ( pSesion, psSolit_Seguro,vTablas, 'PRIMA', vFVencim, vFecAlta, v_siguiente_revision, v_fecha_interes, v_fecha_tratado_hasta, v_fecha_proceso, v_prima, gCapGar, gCapFall, gProvMat ) ;
          v_fecha_tratado_hasta := v_fecha_proceso;
        END LOOP;

        -- Tractar revisions i tancaments fins la data de l'operació
        v_traza := 14;
        WHILE vFecMov >  v_fecha_tratado_hasta LOOP
            v_fecha_proceso   := LEAST(v_siguiente_revision, vFecMov);
            v_tratar_revision := ( v_siguiente_revision = v_fecha_proceso );
            v_fecha_interes := v_siguiente_revision;
            IF v_tratar_revision THEN
              v_traza := 15;
--DBMS_OUTPUT.PUT_LINE('llamamos a calculaoperacion con revision v_siguiente_revision ='||v_siguiente_revision||'v_fecha_interes ='||v_fecha_interes||' v_fecha_tratado_hasta ='||v_fecha_tratado_hasta);
--DBMS_OUTPUT.PUT_LINE(' v_fecha_proceso ='||v_fecha_proceso||'gcapgar ='||gcapgar||' gcapfall ='||gcapfall||'gcapgar ='||gcapgar);
              CalculaOperacion ( pSesion, psSolit_Seguro,vTablas, 'REVISION', vFVencim, vFecAlta, v_siguiente_revision, v_fecha_interes, v_fecha_tratado_hasta, v_fecha_proceso, 0, gCapGar, gCapFall, gProvMat ) ;
              v_siguiente_revision := ADD_MONTHS(v_siguiente_revision,12);
            ELSE
dbms_output.put_line('LLAMA A CALCULA OPERACION CON CIERRE MENSUAL');
DBMS_OUTPUT.PUT_LINE('llamamos a calculaoperacion con revision v_siguiente_revision ='||v_siguiente_revision||'v_fecha_interes ='||v_fecha_interes||' v_fecha_tratado_hasta ='||v_fecha_tratado_hasta);
              v_fecha_interes := greatest(v_siguiente_revision-1, vFecAlta);
              CalculaOperacion ( pSesion, psSolit_Seguro, vTablas,'CIERRE MENSUAL', vFVencim, vFecAlta, v_siguiente_revision, v_fecha_interes, v_fecha_tratado_hasta, v_fecha_proceso, 0, gCapGar, gCapFall, gProvMat ) ;
            END IF;

            v_fecha_tratado_hasta := v_fecha_proceso;
        END LOOP;


    END IF;

    v_traza := 17;
    gFechaSaldo   := vFechaSaldo;
    gsSeguro      := psSolit_Seguro;
    gFecMov       := vFecMov;
    gOrigen       := vOrigen;

  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,  F_USER,  'PAC_FORMUL_PE_PAA.CALCULO',v_traza, 'parametros: psesion ='||psesion||' psseguro='||psSolit_Seguro||' vfVencim='||vfVencim,
           SQLERRM);
      RAISE;
  END;

  --
  --
  --
  FUNCTION CAPFALL ( pSesion IN NUMBER, psSeguro IN SEGUROS.SSEGURO%TYPE ) RETURN NUMBER IS
  BEGIN
    Calculo( pSesion, psSeguro);
    RETURN gCapFall;
  END;

  --
  --
  --
  FUNCTION CAPGAR ( pSesion IN NUMBER, psSeguro IN SEGUROS.SSEGURO%TYPE ) RETURN NUMBER IS
  BEGIN
-- ******
--FOR r IN (SELECT norden, fnacimi,csexper FROM solasegurados WHERE ssolicit = psSeguro ORDER BY norden ) LOOP
--DBMS_OUTPUT.PUT_LINE('norden='||r.norden||' fnacimi='||r.fnacimi||' csexper='||r.csexper);
--END LOOP;
--FOR r IN (SELECT parametro, valor FROM SGT_PARMS_TRANSITORIOS WHERE sesion = psesion ORDER BY parametro ) LOOP
--DBMS_OUTPUT.PUT_LINE('parametro='||r.parametro||' valor='||r.valor);
--END LOOP;
--dbms_output.PUT_LINE('yil: entramos en capgar');
         Calculo( pSesion, psSeguro);
    RETURN gCapGar;
  END;

  --
  --
  --
  FUNCTION PROVMAT ( pSesion IN NUMBER, psSeguro IN SEGUROS.SSEGURO%TYPE ) RETURN NUMBER IS
  BEGIN
    Calculo( pSesion, psSeguro);
    RETURN gProvMat;
  END;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA" TO "PROGRAMADORESCSI";
