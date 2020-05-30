create or replace PACKAGE BODY          PAC_RIESGO_FINANCIERO IS
  /******************************************************************************
     NOMBRE:     PAC_RIESGO_FINANCIERO
     PROPÃ“SITO:  Funciones Cálculo Nivel de Riesgo

   ********************************************f**********************************/
e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;


  FUNCTION f_calc_indfin_pruacida(TPRBACI IN FIN_INDICADORES.TPRBACI%TYPE, ACT_CORR IN NUMBER , CARTE_CLIE IN NUMBER ,  PAS_CORR  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - TPRBACI = ' || TPRBACI||'- ACT_CORR =  '||ACT_CORR||'- CARTE_CLIE = '|| CARTE_CLIE ||'- PAS_CORR '||PAS_CORR;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.f_calc_indfin_pruacida';
      pPruacida NUMBER;
  BEGIN

    --IF(TPRBACI IS NOT NULL AND TPRBACI > 0)THEN

    --RETURN TPRBACI;

    --ELSE

    pPruacida := TRUNC((ACT_CORR - CARTE_CLIE)/ PAS_CORR, 2);
    RETURN pPruacida;
    --END IF;

  END f_calc_indfin_pruacida;

  FUNCTION F_CALC_INDFIN_ROTCARTERA(NDIACAR IN FIN_INDICADORES.TPRBACI%TYPE, CARTE_CLIE IN NUMBER ,  VENTAS  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NDIACAR = ' || NDIACAR||'- CARTE_CLIE =  '||CARTE_CLIE||'- VENTAS = '|| VENTAS ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ROTCARTERA';
      pRotCart  NUMBER;
  BEGIN

    --IF(NDIACAR IS NOT NULL AND NDIACAR > 0)THEN

   -- RETURN NDIACAR;

    --ELSE

    pRotCart := TRUNC((CARTE_CLIE * 360)/ VENTAS, 2);
    RETURN pRotCart;
    --END IF;

  END F_CALC_INDFIN_ROTCARTERA;

  FUNCTION F_CALC_INDFIN_ROTCTASXPAG(NROTPRO IN FIN_INDICADORES.NROTPRO%TYPE, PROVEE_CORTO_PLAZO IN NUMBER ,  VENTAS  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NROTPRO = ' || NROTPRO||'- PROVEE_CORTO_PLAZO =  '||PROVEE_CORTO_PLAZO||'- VENTAS = '|| VENTAS ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ROTCTASXPAG';
      pRotCtaxPag   NUMBER;
  BEGIN

    --IF(NROTPRO IS NOT NULL AND NROTPRO > 0)THEN

    --RETURN NROTPRO;

    --ELSE

    pRotCtaxPag  := TRUNC((PROVEE_CORTO_PLAZO * 360)/ (VENTAS * 0.65), 2);
    RETURN pRotCtaxPag;
    --END IF;

  END F_CALC_INDFIN_ROTCTASXPAG;


  FUNCTION F_CALC_INDFIN_PARTICART(PPCARTE IN FIN_INDICADORES.PPCARTE%TYPE, CARTE_CLIE   IN NUMBER ,  ACT_CORR  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - PPCARTE = ' || PPCARTE||'- PROVEE_CORTO_PLAZO =  '||CARTE_CLIE  ||'- CARTE_CLIE   = '|| ACT_CORR ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_PARTICART';
      pPartCart    NUMBER;
  BEGIN

    --IF(PPCARTE IS NOT NULL AND PPCARTE > 0)THEN

    --RETURN PPCARTE / 100;

    --ELSE

    pPartCart   := CARTE_CLIE / ACT_CORR;
    RETURN pPartCart ;
    --END IF;

  END F_CALC_INDFIN_PARTICART;


    FUNCTION F_CALC_INDFIN_ROTACTIVO(NROTINV IN FIN_INDICADORES.NROTINV%TYPE, VENTAS   IN NUMBER ,  ACT_TOTAL  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NROTINV = ' || NROTINV||'- VENTAS =  '||VENTAS  ||'- ACT_TOTAL   = '|| ACT_TOTAL ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ROTACTIVO';
      pRotActivo     NUMBER;
  BEGIN

    --IF(NROTINV IS NOT NULL AND NROTINV > 0)THEN

    --RETURN NROTINV;

    --ELSE

    pRotActivo    := TRUNC(VENTAS / ACT_TOTAL, 2);
    RETURN pRotActivo  ;
    --END IF;

  END F_CALC_INDFIN_ROTACTIVO;


   FUNCTION F_CALC_INDFIN_PARTACTSTOTACT(NACTCOR IN FIN_INDICADORES.NACTCOR%TYPE, ACT_CORR   IN NUMBER ,  ACT_TOTAL  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NACTCOR = ' || NACTCOR||'- ACT_CORR =  '||ACT_CORR  ||'- ACT_TOTAL   = '|| ACT_TOTAL ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_PARTACTSTOTACT';
      pActTotAct      NUMBER;
  BEGIN

    --IF(NACTCOR IS NOT NULL AND NACTCOR > 0)THEN

    --RETURN NACTCOR / 100;

    --ELSE

    pActTotAct     := ACT_CORR / ACT_TOTAL;
    RETURN pActTotAct   ;
    --END IF;

  END F_CALC_INDFIN_PARTACTSTOTACT;


     FUNCTION F_CALC_INDFIN_ENDEUDAMTOT(IENDUADA IN FIN_INDICADORES.IENDUADA%TYPE, PAS_TOTAL   IN NUMBER ,  ACT_TOTAL  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - IENDUADA = ' || IENDUADA||'- PAS_TOTAL =  '||PAS_TOTAL  ||'- ACT_TOTAL   = '|| ACT_TOTAL ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ENDEUDAMTOT';
      pEndeudTot       NUMBER;
  BEGIN

    --IF(IENDUADA IS NOT NULL AND IENDUADA > 0)THEN

    --RETURN IENDUADA / 100;

    --ELSE

    pEndeudTot      := PAS_TOTAL / ACT_TOTAL;
    RETURN pEndeudTot    ;
    --END IF;

  END F_CALC_INDFIN_ENDEUDAMTOT;


 FUNCTION F_CALC_INDFIN_CIRCULANTE(NCIRCULA IN FIN_INDICADORES.NCIRCULA%TYPE, ACT_CORR   IN NUMBER ,  PAS_CORR  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NCIRCULA = ' || NCIRCULA||'- ACT_CORR =  '||ACT_CORR  ||'- PAS_CORR   = '|| PAS_CORR ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_CIRCULANTE';
      pCirculante        NUMBER;
  BEGIN

    --IF(NCIRCULA IS NOT NULL AND NCIRCULA > 0)THEN

    --RETURN NCIRCULA;

    --ELSE

    pCirculante       := TRUNC(ACT_CORR / PAS_CORR, 2);
    RETURN pCirculante     ;
    --END IF;

  END F_CALC_INDFIN_CIRCULANTE;


   FUNCTION F_CALC_INDFIN_PASIVCTESPATRIM(IPASCORR IN FIN_INDICADORES.IPASCORR%TYPE, PAS_CORR   IN NUMBER ,  PATRI_ANO_ACTUAL  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - IPASCORR = ' || IPASCORR||'- PAS_CORR =  '||PAS_CORR  ||'- PATRI_ANO_ACTUAL   = '|| PATRI_ANO_ACTUAL ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_PASIVCTESPATRIM';
      pPasCtesPat         NUMBER;
  BEGIN

    --IF(IPASCORR IS NOT NULL AND IPASCORR > 0)THEN

   -- RETURN IPASCORR;

    --ELSE

    pPasCtesPat        := TRUNC(PAS_CORR / PATRI_ANO_ACTUAL, 2);
    RETURN pPasCtesPat      ;
    --END IF;

  END F_CALC_INDFIN_PASIVCTESPATRIM;



   FUNCTION F_CALC_INDFIN_RENTABPAT(IRENTPT IN FIN_INDICADORES.IRENTPT%TYPE, UTIL_NETA   IN NUMBER ,  PATRI_ANO_ACTUAL  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - IRENTPT = ' || IRENTPT||'- UTIL_NETA =  '||UTIL_NETA  ||'- PATRI_ANO_ACTUAL   = '|| PATRI_ANO_ACTUAL ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_RENTABPAT';
      pRentPat         NUMBER;
  BEGIN

    --IF(IRENTPT IS NOT NULL AND IRENTPT > 0)THEN

    --RETURN IRENTPT;

    --ELSE

    pRentPat        := TRUNC(UTIL_NETA / PATRI_ANO_ACTUAL, 2);
    RETURN pRentPat      ;
    --END IF;

  END F_CALC_INDFIN_RENTABPAT;


  FUNCTION F_CALC_INDFIN_MARGENOPE(IMARGEN IN FIN_INDICADORES.IMARGEN%TYPE, UTIL_OPERAC   IN NUMBER ,  VENTAS  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - IMARGEN = ' || IMARGEN||'- UTIL_OPERAC =  '||UTIL_OPERAC  ||'- VENTAS   = '|| VENTAS ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_MARGENOPE';
      pMargenOpe         NUMBER;
  BEGIN

    --IF(IMARGEN IS NOT NULL AND IMARGEN > 0)THEN

    --RETURN IMARGEN / 100;

    --ELSE

    pMargenOpe        := UTIL_OPERAC / VENTAS;
    RETURN pMargenOpe      ;
    --END IF;

  END F_CALC_INDFIN_MARGENOPE;


  FUNCTION F_CALC_INDFIN_MARGENNETO(NMGNET IN FIN_INDICADORES.IMARGEN%TYPE, UTIL_NETA   IN NUMBER ,  VENTAS  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NMGNET = ' || NMGNET||'- UTIL_NETA =  '||UTIL_NETA  ||'- VENTAS   = '|| VENTAS ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_MARGENNETO';
      pMargenNeto          NUMBER;
  BEGIN

    --IF(NMGNET IS NOT NULL AND NMGNET > 0)THEN

    --RETURN NMGNET / 100;

    --ELSE

    pMargenNeto         := UTIL_NETA / VENTAS;
    RETURN pMargenNeto       ;
    --END IF;

  END F_CALC_INDFIN_MARGENNETO;




      FUNCTION F_CALC_INDFIN_ACTFIJSVENTAS(IVENTAS IN FIN_INDICADORES.IVENTAS%TYPE, PROP_PLNT_EQP   IN NUMBER ,  VENTAS  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - IVENTAS = ' || IVENTAS||'- PROP_PLNT_EQP =  '||PROP_PLNT_EQP  ||'- VENTAS   = '|| VENTAS ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ACTFIJSVENTAS';
      pActFijsVen           NUMBER;
  BEGIN

    --IF(IVENTAS IS NOT NULL AND IVENTAS > 0)THEN

    --RETURN IVENTAS;

    --ELSE

    pActFijsVen          := ROUND(PROP_PLNT_EQP / VENTAS, 2);
    RETURN pActFijsVen        ;
    --END IF;

  END F_CALC_INDFIN_ACTFIJSVENTAS;


     FUNCTION F_CALC_INDFIN_ACTFIJSTOTACT(NACTFIJ IN FIN_INDICADORES.NACTFIJ%TYPE, PROP_PLNT_EQP   IN NUMBER ,  ACT_TOTAL  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NACTFIJ = ' || NACTFIJ||'- PROP_PLNT_EQP =  '||PROP_PLNT_EQP  ||'- ACT_TOTAL   = '|| ACT_TOTAL ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ACTFIJSTOTACT';
      pActFijsTotAct            NUMBER;
  BEGIN

    --IF(NACTFIJ IS NOT NULL AND NACTFIJ > 0)THEN

    --RETURN NACTFIJ;

    --ELSE

    pActFijsTotAct           := ROUND(PROP_PLNT_EQP / ACT_TOTAL, 2);
    RETURN pActFijsTotAct         ;
    --END IF;

  END F_CALC_INDFIN_ACTFIJSTOTACT;


  FUNCTION F_CALC_INDFIN_LEVERAGETOT(NLEVER IN FIN_INDICADORES.NLEVER%TYPE, PAS_TOTAL   IN NUMBER ,  PATRI_ANO_ACTUAL  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NLEVER = ' || NLEVER||'- PAS_TOTAL =  '||PAS_TOTAL  ||'- PATRI_ANO_ACTUAL   = '|| PATRI_ANO_ACTUAL ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_LEVERAGETOT';
      pLeverageTot             NUMBER;
  BEGIN

    --IF(NLEVER IS NOT NULL AND NLEVER > 0)THEN

    --RETURN NLEVER;

    --ELSE

    pLeverageTot            := ROUND(PAS_TOTAL / PATRI_ANO_ACTUAL, 2);
    RETURN pLeverageTot          ;
    --END IF;

  END F_CALC_INDFIN_LEVERAGETOT;


  FUNCTION F_CALC_INDFIN_CONCTACORTPLAZO(NCONCEN IN FIN_INDICADORES.NCONCEN%TYPE, PAS_CORR   IN NUMBER ,  PAS_TOTAL  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NCONCEN = ' || NCONCEN||'- PAS_CORR =  '||PAS_CORR  ||'- PAS_TOTAL   = '|| PAS_TOTAL ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_CONCTACORTPLAZO';
      pConcCorPlazo              NUMBER;
  BEGIN

    --IF(NCONCEN IS NOT NULL AND NCONCEN > 0)THEN

    --RETURN NCONCEN / 100;

    --ELSE

    pConcCorPlazo             := PAS_CORR / PAS_TOTAL;
    RETURN pConcCorPlazo           ;
   -- END IF;

  END F_CALC_INDFIN_CONCTACORTPLAZO;


     FUNCTION F_CALC_INDFIN_VENTASPASCTE(NPASCOR IN FIN_INDICADORES.NPASCOR%TYPE, VENTAS   IN NUMBER ,  PAS_CORR  IN NUMBER )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NPASCOR = ' || NPASCOR||'- VENTAS =  '||VENTAS  ||'- PAS_CORR   = '|| PAS_CORR ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_VENTASPASCTE';
      pVentasPasCte               NUMBER;
  BEGIN

    --IF(NPASCOR IS NOT NULL AND NPASCOR > 0)THEN

    --RETURN NPASCOR;

    --ELSE

    pVentasPasCte              := ROUND(VENTAS / PAS_CORR, 2);
    RETURN pVentasPasCte            ;
    --END IF;

  END F_CALC_INDFIN_VENTASPASCTE;


  FUNCTION F_CALC_INDFIN_DMYPRUACIDA(TPRBACI IN FIN_INDICADORES.TPRBACI%TYPE, CTE_PRUACIDA   IN NUMBER  )
      RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - TPRBACI = ' || TPRBACI||'- CTE_PRUACIDA =  '||CTE_PRUACIDA ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYPRUACIDA';
      pDmyPruAcida                NUMBER;
  BEGIN

    IF(TPRBACI < CTE_PRUACIDA )THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;

  END F_CALC_INDFIN_DMYPRUACIDA;

  FUNCTION F_CALC_INDFIN_DMYROTACTIVO(TNROTINV  IN FIN_INDICADORES.TNROTINV%TYPE, CTE_ROTACTIVO   IN NUMBER  )
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - TNROTINV = ' || TNROTINV||'- CTE_ROTACTIVO =  '||CTE_ROTACTIVO ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYROTACTIVO';
      pDmyRotAct                NUMBER;
  BEGIN

    IF(TNROTINV < CTE_ROTACTIVO )THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
     END F_CALC_INDFIN_DMYROTACTIVO;


  FUNCTION F_CALC_INDFIN_DMYRENDPAT(IRENTPT  IN FIN_INDICADORES.IRENTPT%TYPE, CTE_RENPATRIMONIO   IN NUMBER  )
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - IRENTPT = ' || IRENTPT||'- CTE_RENPATRIMONIO =  '||CTE_RENPATRIMONIO ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYRENDPAT';
      pDmyRendPat                NUMBER;
  BEGIN

    IF(IRENTPT < CTE_RENPATRIMONIO )THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
     END F_CALC_INDFIN_DMYRENDPAT;


      FUNCTION F_CALC_INDFIN_DMYMARGENNETO(NMGNET  IN FIN_INDICADORES.NMGNET%TYPE, CTE_MARNETO   IN NUMBER  )
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - NMGNET = ' || NMGNET||'- CTE_MARNETO =  '||CTE_MARNETO ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYMARGENNETO';
      pDmyMargenNeto                NUMBER;
  BEGIN

    IF(NMGNET < CTE_MARNETO )THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
     END F_CALC_INDFIN_DMYMARGENNETO;



       FUNCTION F_CALC_INDFIN_TRAECTELOGIT(CTE_LOGIT   IN NUMBER  )
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - CTE_LOGIT = ' || CTE_LOGIT;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYRENDPAT';
      pCteLogit                 NUMBER;
  BEGIN
    pCteLogit :=CTE_LOGIT ;
      RETURN pCteLogit;

     END F_CALC_INDFIN_TRAECTELOGIT;


     FUNCTION F_CALC_INDFIN_VARIABLE_Z(pCteLogit IN NUMBER, pDmyPruAcida   IN NUMBER, pDmyRotAct IN NUMBER, pDmyRendPat IN NUMBER, pDmyMargenNeto  IN NUMBER, NBETAPRUACIDA  RIE_VOLATILIDAD_BETA.NBETAPRUACIDA%TYPE,NBETAROTACTIVO  RIE_VOLATILIDAD_BETA.NBETAROTACTIVO%TYPE,NBETARENPATRIMO RIE_VOLATILIDAD_BETA.NBETARENPATRIMO%TYPE, NBETAMARNETO RIE_VOLATILIDAD_BETA.NBETAMARNETO%TYPE)
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - pCteLogit = ' || pCteLogit||'pDmyPruAcida = ' || pDmyPruAcida||'pDmyRotAct = ' || pDmyRotAct||'pDmyRendPat = ' || pDmyRendPat||'pDmyMargenNeto = ' || pDmyMargenNeto||'NBETAPRUACIDA = ' || NBETAPRUACIDA||'NBETAROTACTIVO = ' || NBETAROTACTIVO||'NBETARENPATRIMO = ' || NBETARENPATRIMO||'NBETAROTACTIVO = ' || NBETAROTACTIVO;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_VARIABLE_Z';
      pVariableZ                  NUMBER;
  BEGIN
    pVariableZ  := pCteLogit+ (pDmyPruAcida * NBETAPRUACIDA )
    + (pDmyRotAct * NBETAROTACTIVO )
    + (pDmyRendPat * NBETARENPATRIMO)
    + (pDmyMargenNeto  * NBETAMARNETO) ;
      RETURN pVariableZ;

     END F_CALC_INDFIN_VARIABLE_Z;


          FUNCTION F_CALC_INDFIN_PROB_INCUM(pVariableZ IN NUMBER)
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - pVariableZ = ' || pVariableZ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_PROB_INCUM';
      pProbIncum                    NUMBER;
  BEGIN
    pProbIncum   := exp(pVariableZ)/ (1+ exp(pVariableZ)) ;
      RETURN pProbIncum;

     END F_CALC_INDFIN_PROB_INCUM;

    FUNCTION F_CALC_INDFIN_NIVEL_RIESGO(pProbIncum IN NUMBER)
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
                       := 'Parametros - pProbIncum = ' || pProbIncum ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_NIVEL_RIESGO';
      pNivelRiesgo                     NUMBER;
  BEGIN

     --p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, '1: '||pProbIncum);
      FOR rec IN (select PRANGOINI, PRANGOFIN,NRIESGOFIN from RIE_NIVELRIESGO) LOOP
          --      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, '2: '||pProbIncum||' > '||rec.PRANGOINI||' AND '||pProbIncum||' < '||rec.PRANGOFIN);
               IF(pProbIncum > rec.PRANGOINI and pProbIncum< rec.PRANGOFIN) THEN
            --   p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, '3'||pProbIncum);
                  RETURN rec.NRIESGOFIN;
              END IF;

            END LOOP;

    RETURN 0;
     END F_CALC_INDFIN_NIVEL_RIESGO;

       FUNCTION F_CALCULO_RIESGO( sperson IN NUMBER,  fefecto IN DATE, monto IN NUMBER)
        RETURN NUMBER IS
        vpasexec       NUMBER(8) := 0;
       vparam         VARCHAR2(2000)
                       := 'Parametros - sperson = ' || sperson||' fefecto'|| fefecto||' monto'|| monto ;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_CALCULO_RIESGO';
      pNivelRiesgo                     NUMBER;
      pSFINANCI                               NUMBER;
      pCTIPPER                               NUMBER;
      pCodigoUsuario NUMBER;
      pNMOVIMI                         NUMBER;
      pPruacida                        NUMBER;
      pRotCart                         NUMBER;
      pRotCtaxPag                       NUMBER;
       pPartCart    NUMBER;
        pRotActivo     NUMBER;
        pActTotAct      NUMBER;
         pEndeudTot       NUMBER;
       pCirculante        NUMBER;
       pPasCtesPat         NUMBER;
      pRentPat       NUMBER;
      pMargenOpe   NUMBER;
       pMargenNeto          NUMBER;
        pActFijsVen           NUMBER;
        pActFijsTotAct            NUMBER;
        pLeverageTot             NUMBER;
        pConcCorPlazo              NUMBER;
           pVentasPasCte               NUMBER;
           pDmyRendPat  NUMBER;
           pDmyMargenNeto  NUMBER;
           pDmyRotAct NUMBER;
           pDmyPruAcida NUMBER;
           pCteLogit NUMBER;
           pVariableZ NUMBER;
           pProbIncum NUMBER;
          pDescripcionRiesgo VARCHAR2(100) := '';

          --PARA NATURAL
          pScore NUMBER;
          pCalificaA NUMBER;
          pCalificaB NUMBER;
          pCalificaC NUMBER;
          pCalificaD NUMBER;
          pCalificaE NUMBER;
          pIngMinimoProb NUMBER;
          pCupoGarant NUMBER;
          pCalificacionTexto VARCHAR2(200);
          pValidarIndicador NUMBER;
          pMovimientoActivo NUMBER;
          pExisteInfoFinan NUMBER;

  BEGIN

  pCodigoUsuario := sperson;

   vpasexec:=1;
   p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'entro y va a hacer la select con el sperson: '||sperson);

	BEGIN
  select fin.SFINANCI
  into pSFINANCI
  from FIN_GENERAL fin WHERE fin.sperson=pCodigoUsuario;
  exception
when NO_DATA_FOUND then
p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'No consiguio ningun registro sperson: '||sperson);

when TOO_MANY_ROWS then
p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'mas de 1 registro para financi con sperson: '||sperson);
end;

   vpasexec:=2;
   p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'FINANCIA: '||pSFINANCI);

   --INI - AXIS 2554 - 08/5/2019 - AABG - SE CONSULTA EL TIPO DE PERSONA (1-> Natural, 2-> Juridica)
   vpasexec:=2.1;
   p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'SE PROCEDE A CONSULTAR EL TIPO DE USUARIO: '||sperson);
   BEGIN
       SELECT pers.ctipper INTO pCTIPPER FROM per_personas pers WHERE pers.sperson = pCodigoUsuario;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
       p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'No consiguio ningun registro ctipper: '||pCodigoUsuario);
       when TOO_MANY_ROWS then
        p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'consiguo mas de uno con tipo de usuario: '||pCodigoUsuario);
   END;
   --FIN - AXIS 2554 - 08/5/2019 - AABG - SE CONSULTA EL TIPO DE PERSONA (1-> Natural, 2-> Juridica)

   IF pCTIPPER = 1 THEN

   --INI - AXIS 2554 - 08/5/2019 - AABG - Si es Natural se valida si tiene informacion, se construye mensaje
   -- de calificacion y se inserta el historico con los respectivos parametros
   BEGIN
   SELECT nscore, ncalifa, ncalifb, ncalifc, ncalifd, ncalife, iminimo, icupog 
   INTO pScore, pCalificaA, pCalificaB, pCalificaC, pCalificaD, pCalificaE, pIngMinimoProb, pCupoGarant
      FROM fin_endeudamiento WHERE sfinanci = pSFINANCI 
      AND fconsulta = (SELECT MAX(fconsulta) FROM fin_endeudamiento fend WHERE fend.sfinanci = pSFINANCI);
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
       p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'No consiguio ningun registro de endeudamiento: '||pCodigoUsuario);
       RETURN 2;
   END;  

   --SE CONSTRUYE EL TEXTO DE LA CALIFICACION
   pCalificacionTexto := '';
   IF (pCalificaA IS NOT NULL AND pCalificaA > 0) THEN
    pCalificacionTexto := pCalificacionTexto || 'Calificacion A: ' || pCalificaA || ', ';
   END IF;
   IF (pCalificaB IS NOT NULL AND pCalificaB > 0) THEN
    pCalificacionTexto := pCalificacionTexto || 'Calificacion B: ' || pCalificaB || ', ';
   END IF;
   IF (pCalificaC IS NOT NULL AND pCalificaC > 0) THEN
    pCalificacionTexto := pCalificacionTexto || 'Calificacion C: ' || pCalificaC || ', ';
   END IF;
   IF (pCalificaD IS NOT NULL AND pCalificaD > 0) THEN
    pCalificacionTexto := pCalificacionTexto || 'Calificacion D: ' || pCalificaD || ', ';
   END IF;
   IF (pCalificaE IS NOT NULL AND pCalificaE > 0) THEN
    pCalificacionTexto := pCalificacionTexto || 'Calificacion E: ' || pCalificaE || ', ';
   END IF;

   INSERT INTO RIE_HIS_RIESGO (SPERSON, NRIESGO, NMOVIMI ,SFINANCI,MONTO,FEFECTO, NPROBINCUMPLIMIENTO, SDESCRIPCION, NPUNTAJESCORE,
        SCALIFICACION, NINGMINIMOPROBABLE, NCUPOGARANTIZADO, STIPOPERSONA) 
        VALUES (sperson,0,SEQ_RIE_HIS_RIESGO.NEXTVAL,pSFINANCI, monto, fefecto, 0, NULL, pScore,
        pCalificacionTexto, pIngMinimoProb, pCupoGarant, 'N');

    --FIN - AXIS 2554 - 08/5/2019 - AABG - Si es Natural se valida si tiene informacion, se construye mensaje
   -- de calificacion y se inserta el historico con los respectivos parametros        
        RETURN 0;

   ELSE

    --INI - AXIS 2554 - 08/5/2019 - AABG - Si es Juridica se valida si tiene informacion, se aplica las respectivas
    -- formulas que construyen el historico e internamente por cada formula se realiza validacion de nulidad y mayor a 0.
    -- tambien se aplica la division por 100 de los porcentajes en la aplicacion de formulas, se realiza el calculo de nivel
    -- de riesgo y su respectivo mensaje, finalmente se inserta el historico.
   BEGIN
   
   --INI - AXIS 2554 - 02/09/2019 - AABG -Validacion para obtener el Sfinanci del registro activo
    SELECT SFINANCI, NMOVIMI 
    INTO pValidarIndicador, pMovimientoActivo 
    FROM FIN_INDICADORES INDIC 
    WHERE INDIC.sfinanci=pSFINANCI AND FINDICAD = (SELECT MAX(FINDICAD) FROM FIN_INDICADORES WHERE sfinanci = pSFINANCI);
    --FIN - AXIS 2554 - 02/09/2019 - AABG -Validacion para obtener el Sfinanci del registro activo
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
       p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'No consiguio ningun registro de indicadores: '||pCodigoUsuario);
       RETURN 2;
   END;   
   
   --VALIDACION PARA INFORMACION FINANCIERA DE UNA PERSONA
    SELECT COUNT(*) INTO pExisteInfoFinan FROM FIN_PARAMETROS WHERE SFINANCI = pValidarIndicador AND NMOVIMI = pMovimientoActivo;
    IF pExisteInfoFinan <= 0 THEN
        p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'No consiguio ningun registro de indicadores: '||pCodigoUsuario);
       RETURN 2;
    END IF;

   -- PRUEBA ACIDA
   select PAC_RIESGO_FINANCIERO.f_calc_indfin_pruacida((select nvl(TPRBACI,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'ACT_CORR' AND NMOVIMI = pMovimientoActivo), 'ACT_CORR')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'CARTE_CLIE' AND NMOVIMI = pMovimientoActivo), 'CARTE_CLIE')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PAS_CORR' AND NMOVIMI = pMovimientoActivo), 'PAS_CORR')  from dual)) pPruacida
                            into pPruacida
    from dual;
     vpasexec:=3;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'PACIDA: '||pPruacida);
   -----------------------------------------------------------------------------------------------------------------------
     --  ROTACION DE CARTERA(DIAS)
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ROTCARTERA((select nvl(NDIACAR,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'CARTE_CLIE' AND NMOVIMI = pMovimientoActivo), 'CARTE_CLIE')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'VENTAS' AND NMOVIMI = pMovimientoActivo), 'VENTAS')  from dual)) pRotCart
                            into pRotCart  from dual;
        vpasexec:=4;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pRotCart: '||pRotCart);
    -----------------------------------------------------------------------------------------------------------------------
     -- ROTACION CUENTAS POR PAGAR
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ROTCTASXPAG((select nvl(NROTPRO,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PROVEE_CORTO_PLAZO' AND NMOVIMI = pMovimientoActivo), 'PROVEE_CORTO_PLAZO')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'VENTAS' AND NMOVIMI = pMovimientoActivo), 'VENTAS')  from dual)) pRotCart
                            into pRotCtaxPag  from dual;
        vpasexec:=5;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pRotCtaxPag: '||pRotCtaxPag);
   -----------------------------------------------------------------------------------------------------------------------
     -- PARTICIPACION (%) CARTERA
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_PARTICART((select nvl(PPCARTE,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'CARTE_CLIE' AND NMOVIMI = pMovimientoActivo), 'CARTE_CLIE')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'ACT_CORR' AND NMOVIMI = pMovimientoActivo), 'ACT_CORR')  from dual)) pPartCart
                            into pPartCart  from dual;
        vpasexec:=6;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pPartCart: '||pPartCart);
   -----------------------------------------------------------------------------------------------------------------------
     -- ROTACION DEL ACTIVO (VECES)
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ROTACTIVO((select nvl(NROTINV,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'VENTAS' AND NMOVIMI = pMovimientoActivo), 'VENTAS')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'ACT_TOTAL' AND NMOVIMI = pMovimientoActivo), 'ACT_TOTAL')  from dual)) pRotCart
                            into pRotActivo  from dual;
        vpasexec:=7;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pRotActivo: '||pRotActivo);
    -----------------------------------------------------------------------------------------------------------------------
     -- PART ACT CORR / TOTAL ACTIVO
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_PARTACTSTOTACT((select nvl(NACTCOR,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'ACT_CORR' AND NMOVIMI = pMovimientoActivo), 'ACT_CORR')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'ACT_TOTAL' AND NMOVIMI = pMovimientoActivo), 'ACT_TOTAL')  from dual)) pRotCart
                            into pActTotAct  from dual;
        vpasexec:=8;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pActTotAct: '||pActTotAct);
   -----------------------------------------------------------------------------------------------------------------------
     -- ENDEUDAMIENTO TOTAL
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ENDEUDAMTOT((select nvl(IENDUADA,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PAS_TOTAL' AND NMOVIMI = pMovimientoActivo), 'PAS_TOTAL')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'ACT_TOTAL' AND NMOVIMI = pMovimientoActivo), 'ACT_TOTAL')  from dual)) pRotCart
                            into pEndeudTot  from dual;
        vpasexec:=9;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pEndeudTot: '||pEndeudTot);

    -----------------------------------------------------------------------------------------------------------------------
     -- CIRCULANTE
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_CIRCULANTE((select nvl(NCIRCULA,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'ACT_CORR' AND NMOVIMI = pMovimientoActivo), 'ACT_CORR')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PAS_CORR' AND NMOVIMI = pMovimientoActivo), 'PAS_CORR')  from dual)) pCirculante
                            into pCirculante  from dual;
        vpasexec:=10;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pCirculante: '||pCirculante);
    -----------------------------------------------------------------------------------------------------------------------
      --PAS CORR/PATRIMONIO
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_PASIVCTESPATRIM((select nvl(IPASCORR,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PAS_CORR' AND NMOVIMI = pMovimientoActivo), 'PAS_CORR')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PATRI_ANO_ACTUAL' AND NMOVIMI = pMovimientoActivo), 'PATRI_ANO_ACTUAL')  from dual)) pPasCtesPat
                            into pPasCtesPat  from dual;
        vpasexec:=11;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pPasCtesPat: '||pPasCtesPat);
  -----------------------------------------------------------------------------------------------------------------------
      --RENTABILIDAD PATRIMONIO
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_RENTABPAT((select nvl(IRENTPT,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'UTIL_NETA' AND NMOVIMI = pMovimientoActivo), 'UTIL_NETA')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PATRI_ANO_ACTUAL' AND NMOVIMI = pMovimientoActivo), 'PATRI_ANO_ACTUAL')  from dual)) pPasCtesPat
                            into pRentPat  from dual;
        vpasexec:=12;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pRentPat: '||pRentPat);
  -----------------------------------------------------------------------------------------------------------------------
      -- MG OPERACIONAL
    select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_MARGENOPE((select nvl(IMARGEN,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'UTIL_OPERAC' AND NMOVIMI = pMovimientoActivo), 'UTIL_OPERAC')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'VENTAS' AND NMOVIMI = pMovimientoActivo), 'VENTAS')  from dual)) pMargenOpe
                            into pMargenOpe  from dual;
        vpasexec:=13;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pMargenOpe: '||pMargenOpe);
  ------------------------------------------------------------------------------------------------------------------------
      --MARGEN NETO
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_MARGENNETO((select nvl(NMGNET,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'UTIL_NETA' AND NMOVIMI = pMovimientoActivo), 'UTIL_NETA')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'VENTAS' AND NMOVIMI = pMovimientoActivo), 'VENTAS')  from dual)) pMargenNeto
                            into pMargenNeto  from dual;
        vpasexec:=14;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pMargenNeto: '||pMargenNeto);
  ------------------------------------------------------------------------------------------------------------------------
      --ACTIVOS FIJOS / VENTAS
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ACTFIJSVENTAS((select nvl(IVENTAS,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PROP_PLNT_EQP' AND NMOVIMI = pMovimientoActivo), 'PROP_PLNT_EQP')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'VENTAS' AND NMOVIMI = pMovimientoActivo), 'VENTAS') from dual)) pActFijsVen
                            into pActFijsVen  from dual;
        vpasexec:=15;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pActFijsVen: '||pActFijsVen);
   ------------------------------------------------------------------------------------------------------------------------
      --ACTIVOS FIJOS / TOTAL ACTIVOS
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_ACTFIJSTOTACT((select nvl(NACTFIJ,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PROP_PLNT_EQP' AND NMOVIMI = pMovimientoActivo), 'PROP_PLNT_EQP')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'ACT_TOTAL' AND NMOVIMI = pMovimientoActivo), 'ACT_TOTAL')  from dual)) pActFijsTotAct
                            into pActFijsTotAct  from dual;
        vpasexec:=16;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pActFijsTotAct: '||pActFijsTotAct);
   ------------------------------------------------------------------------------------------------------------------------
      --LEVERAGE TOTAL
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_LEVERAGETOT((select nvl(NLEVER,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PAS_TOTAL' AND NMOVIMI = pMovimientoActivo), 'PAS_TOTAL')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PATRI_ANO_ACTUAL' AND NMOVIMI = pMovimientoActivo), 'PATRI_ANO_ACTUAL')  from dual)) pLeverageTot
                            into pLeverageTot  from dual;
        vpasexec:=17;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pLeverageTot: '||pLeverageTot);
   ------------------------------------------------------------------------------------------------------------------------
      --CONCENTRACION A CORTO PLAZO
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_CONCTACORTPLAZO((select nvl(NCONCEN,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PAS_CORR' AND NMOVIMI = pMovimientoActivo), 'PAS_CORR')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PAS_TOTAL' AND NMOVIMI = pMovimientoActivo), 'PAS_TOTAL')  from dual)) pConcCorPlazo
                            into pConcCorPlazo  from dual;
        vpasexec:=18;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pConcCorPlazo: '||pConcCorPlazo);
   ------------------------------------------------------------------------------------------------------------------------
      --VENTAS / PASIVO CORRIENTE
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_VENTASPASCTE((select nvl(NPASCOR,0) from FIN_INDICADORES where sfinanci=pSFINANCI AND NMOVIMI = pMovimientoActivo),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'VENTAS' AND NMOVIMI = pMovimientoActivo), 'VENTAS')  from dual),
                            (select PAC_FINANCIERA.F_GET_FIN_PARAM(pSFINANCI, (SELECT NMOVIMI FROM FIN_PARAMETROS where sfinanci = pSFINANCI and  cparam = 'PAS_CORR' AND NMOVIMI = pMovimientoActivo), 'PAS_CORR')  from dual)) pVentasPasCte
                            into pVentasPasCte  from dual;
        vpasexec:=19;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pVentasPasCte: '||pVentasPasCte);
   ------------------------------------------------------------------------------------------------------------------------
      -- DUMMY PRUEBA ACIDA
      --0.9344 Constante excel de simulacion de Confianza
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYPRUACIDA(pPruacida, (SELECT TO_NUMBER(TVALPAR) FROM PAREMPRESAS
              WHERE CPARAM='CTE_PRUACIDA' AND CEMPRES=24)) pDmyPruAcida
                            into pDmyPruAcida  from dual;
        vpasexec:=20;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pDmyPruAcida: '||pDmyPruAcida);
   ------------------------------------------------------------------------------------------------------------------------
      -- DUMMY ROTACION DEL ACTIVO
      --3.2798 Constante excel de simulacion de Confianza
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYROTACTIVO(pRotActivo, (SELECT TO_NUMBER(TVALPAR) FROM PAREMPRESAS
              WHERE CPARAM='CTE_ROTACTIVO' AND CEMPRES=24)) pDmyRotAct
                            into pDmyRotAct  from dual;
        vpasexec:=21;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pDmyRotAct: '||pDmyRotAct);
   ------------------------------------------------------------------------------------------------------------------------
      -- DUMMY Rend patrimonio
      --4% Constante excel de simulacion de Confianza
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYRENDPAT(pRentPat, (SELECT TO_NUMBER(TVALPAR) FROM PAREMPRESAS
              WHERE CPARAM='CTE_RENDPATRIMONIO' AND CEMPRES=24)) pDmyRendPat
                            into pDmyRendPat  from dual;
        vpasexec:=22;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pDmyRendPat: '||pDmyRendPat);
    ------------------------------------------------------------------------------------------------------------------------
      -- DUMMY MARGEN NETO
      --2.6% Constante excel de simulacion de Confianza
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_DMYMARGENNETO(pMargenNeto, (SELECT TO_NUMBER(TVALPAR) FROM PAREMPRESAS
              WHERE CPARAM='CTE_MARGENNETO' AND CEMPRES=24)) pDmyMargenNeto
                            into pDmyMargenNeto  from dual;
        vpasexec:=23;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pDmyMargenNeto: '||pDmyMargenNeto);
   ------------------------------------------------------------------------------------------------------------------------
      -- CONSTANTE LOGIN
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_TRAECTELOGIT((SELECT TO_NUMBER(TVALPAR) FROM PAREMPRESAS
              WHERE CPARAM='CTE_LOGIT' AND CEMPRES=24)) pCteLogit
                            into pCteLogit  from dual;
        vpasexec:=24;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pCteLogit: '||pCteLogit);
  ------------------------------------------------------------------------------------------------------------------------
      -- Z
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_VARIABLE_Z( pCteLogit,pDmyPruAcida,pDmyRotAct,pDmyRendPat,pDmyMargenNeto,
       (select NBETAPRUACIDA from RIE_VOLATILIDAD_BETA),
       (select NBETAROTACTIVO from RIE_VOLATILIDAD_BETA),
       (select NBETARENPATRIMO from RIE_VOLATILIDAD_BETA),
       (select NBETAMARNETO from RIE_VOLATILIDAD_BETA)
       ) pVariableZ
         into pVariableZ  from dual;
        vpasexec:=25;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pVariableZ: '||pVariableZ);
  ------------------------------------------------------------------------------------------------------------------------
      BEGIN
      -- PROB INCUMPLIMIENTO
       select ROUND(PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_PROB_INCUM(NVL(pVariableZ,0))*100, 2) pProbIncum
                            into pProbIncum  from dual;
        vpasexec:=26666;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pProbIncum: '||pProbIncum);
      EXCEPTION WHEN NO_DATA_FOUND THEN
   vpasexec:=266;
    pProbIncum:=0;
   END;
   ------------------------------------------------------------------------------------------------------------------------
      -- NIVEL DE RIESGO

   BEGIN
    p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'INTENTA: '||pProbIncum);
       select PAC_RIESGO_FINANCIERO.F_CALC_INDFIN_NIVEL_RIESGO(NVL(pProbIncum,0)) pNivelRiesgo
                            into pNivelRiesgo  from dual;
        vpasexec:=27;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'pNivelRiesgo: '||pNivelRiesgo);

       IF (pNivelRiesgo = 1 OR pNivelRiesgo = 2) THEN
     	pDescripcionRiesgo := 'MINIMO RIESGO DE CREDITO. EMPRESA LIQUIDA Y RENTABLE';
       ELSE IF (pNivelRiesgo = 3) THEN
     		pDescripcionRiesgo := 'RIESGO BAJO. LIQUIDEZ Y RENTABILIDAD SATISFACTORIA';
     	  ELSE IF (pNivelRiesgo = 4) THEN
     	  			pDescripcionRiesgo := 'RIESGO DE CREDITO ACEPTABLE. NEGOCIO CREDITICIO PROMEDIO, CON CONDICIONES FINANCIERAS NORMALES';
     	  		ELSE IF (pNivelRiesgo = 5 OR pNivelRiesgo = 6) THEN
     	  					pDescripcionRiesgo := 'RIESGO MEDIO. CAPACIDAD DE DEUDA LIMITADA';
     	  				ELSE IF (pNivelRiesgo = 7) THEN
     	  						pDescripcionRiesgo := 'RIESGO ALTO. CAPACIDAD DE DEUDA CUESTIONABLE';
     	  					  ELSE IF (pNivelRiesgo = 8) THEN
     	  					  			pDescripcionRiesgo := 'RIESGO DE CREDITO MUY ALTO. PERDIDA ESPERADA ALTA';
     	  					  		ELSE IF (pNivelRiesgo = 0) THEN
     	  					  				pDescripcionRiesgo := 'NIVEL 0';
     	  					  			  ELSE
     	  					  			  	pDescripcionRiesgo := '';
     	  					  			  END IF;
     	  					  		END IF;
     	  					  END IF;
     	  				END IF;
     	  		END IF;
     	  END IF;
     END IF;


      EXCEPTION WHEN NO_DATA_FOUND THEN

    pNivelRiesgo:=0;
   END;
  ------------------------------------------------------------------------------------------------------------------------
      -- Insert del calculo
      vpasexec:=28;

        INSERT INTO RIE_HIS_RIESGO (SPERSON, NRIESGO, NMOVIMI ,SFINANCI,MONTO,FEFECTO, NPROBINCUMPLIMIENTO, SDESCRIPCION, NPUNTAJESCORE,
        SCALIFICACION, NINGMINIMOPROBABLE, NCUPOGARANTIZADO, STIPOPERSONA) 
        VALUES (sperson,pNivelRiesgo,SEQ_RIE_HIS_RIESGO.NEXTVAL,pSFINANCI, monto, fefecto, pProbIncum, pDescripcionRiesgo, NULL,
        NULL, NULL, NULL, 'J');
        vpasexec:=29;

    --FIN - AXIS 2554 - 08/5/2019 - AABG - Si es Juridica se valida si tiene informacion, se aplica las respectivas
    -- formulas que construyen el historico e internamente por cada formula se realiza validacion de nulidad y mayor a 0.
    -- tambien se aplica la division por 100 de los porcentajes en la aplicacion de formulas, se realiza el calculo de nivel
    -- de riesgo y su respectivo mensaje, finalmente se inserta el historico.
      RETURN 0;

   END IF;



  EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM || DBMS_UTILITY.format_error_backtrace);


   RETURN 1;

     END F_CALCULO_RIESGO;

      FUNCTION F_GET_RIESGOS_CALCULADOS(sperson IN NUMBER)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'sperson= ' || sperson;
      vobject        VARCHAR2(200) := 'PAC_RIESGO_FINANCIERO.F_GET_RIESGOS_CALCULADOS';
      terror         VARCHAR2(200);
      num_err        axis_literales.slitera%TYPE := 0;
      cur            sys_refcursor;
   BEGIN
      OPEN CUR FOR
        SELECT his.NRIESGO,
        (select TDESRIESGO from RIE_NIVELRIESGO  where SNIVRIESGO = his.NRIESGO) DESRIESGO,
        his.MONTO ,
        his.FEFECTO
        FROM RIE_HIS_RIESGO his
        WHERE his.sperson = sperson;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
  END F_GET_RIESGOS_CALCULADOS;


END PAC_RIESGO_FINANCIERO;