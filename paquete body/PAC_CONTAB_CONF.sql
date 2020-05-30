--------------------------------------------------------
--  DDL for Package Body PAC_CONTAB_CONF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_CONTAB_CONF AS


 /*************************************************************************
       NOMBRE              : f_contab_trm
       Funci?3n que trae el trm de la expedici?3n de la p?3liza
       param in  p_sseguro : sseguro
       param in  p_cagente : c?3digo del agente
       param out  v_trm    : valor del trm
       
        1.0        23/05/2019  ECP               IAXIS-3592.Proceso de terminaci¨®n por no pago
    *************************************************************************/

 FUNCTION f_contab_trm(
      p_sseguro IN seguros.sseguro%TYPE,
      p_cagente IN seguros.cagente%TYPE)
      RETURN eco_tipocambio.itasa%TYPE AS
      v_trm       eco_tipocambio.itasa%TYPE;
       e_parms        EXCEPTION;
  BEGIN
    -- TAREA: Se necesita implantaci?3n para FUNCTION PAC_CONTAB_CONF.f_contab_trm
      IF p_sseguro IS NULL
         AND p_cagente IS NULL
         THEN
         RAISE e_parms;
      END IF;

      IF p_sseguro IS NOT NULL
         AND p_cagente IS NULL
      THEN
       -- BEGIN*/
            SELECT PAC_ECO_TIPOCAMBIO.F_CAMBIO(DECODE(M.CMONINT,'COP',' ',M.CMONINT),'COP',S.FEFECTO)
              INTO v_trm
              FROM SEGUROS S,MONEDAS M
             WHERE M.CIDIOMA=8
              AND M.CMONEDA=S.CMONEDA
              AND S.SSEGURO=p_sseguro
              group by  PAC_ECO_TIPOCAMBIO.F_CAMBIO(DECODE(M.CMONINT,'COP',' ',M.CMONINT),'COP',S.FEFECTO)
              ;

      ELSIF p_sseguro IS NULL
         AND p_cagente IS NOT NULL
      THEN
            SELECT PAC_ECO_TIPOCAMBIO.F_CAMBIO(DECODE(M.CMONINT,'COP',' ',M.CMONINT),'COP',S.FEFECTO)
              INTO v_trm
              FROM SEGUROS S,MONEDAS M, CTACTES C
             WHERE M.CIDIOMA=8
              AND M.CMONEDA=S.CMONEDA
              AND C.CAGENTE=S.CAGENTE
              AND C.CAGENTE=p_cagente
              --AND S.SSEGURO=p_sseguro
              AND S.CMONEDA<>'8'
              group by  PAC_ECO_TIPOCAMBIO.F_CAMBIO(DECODE(M.CMONINT,'COP',' ',M.CMONINT),'COP',S.FEFECTO);

      ELSIF p_sseguro IS NOT NULL
         AND p_cagente IS NOT NULL
      THEN
            SELECT DISTINCT PAC_ECO_TIPOCAMBIO.F_CAMBIO(DECODE(M.CMONINT,'COP',' ',M.CMONINT),'COP',S.FEFECTO)
              INTO v_trm
              FROM SEGUROS S,MONEDAS M, CTACTES C
             WHERE M.CIDIOMA=8
              AND M.CMONEDA=S.CMONEDA
              AND C.CAGENTE=S.CAGENTE
              AND C.CAGENTE=p_cagente
              AND S.SSEGURO=p_sseguro
              AND S.CMONEDA<>'8'
              group by  PAC_ECO_TIPOCAMBIO.F_CAMBIO(DECODE(M.CMONINT,'COP',' ',M.CMONINT),'COP',S.FEFECTO);

      END IF;




    RETURN v_trm;
  END f_contab_trm;


  /*************************************************************************
       NOMBRE              : f_mon_poliza
       Funci?3n Trae la moneda correspondiente de una p?3liza
       param in  p_sseguro : sseguro
       param out  v_moneda : moneda de la p?3liza
    *************************************************************************/

 FUNCTION f_mon_poliza(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN monedas.cmonint%TYPE AS
      v_moneda       monedas.cmonint%TYPE;
      e_parms        EXCEPTION;
      BEGIN
    -- TAREA: Se necesita implantaci?3n para FUNCTION PAC_CONTAB_CONF.f_contab_trm
      IF p_sseguro IS NULL
      THEN RAISE e_parms;
      END IF;

      IF p_sseguro IS NOT NULL
      THEN

        SELECT M.CMONINT
           INTO v_moneda
          FROM SEGUROS S,MONEDAS M
          WHERE M.CIDIOMA=8
            AND M.CMONEDA=S.CMONEDA
            AND S.SSEGURO=p_sseguro ;

      END IF;


    RETURN v_moneda;
  END f_mon_poliza;



  FUNCTION f_moneda(
      p_cmonint IN monedas.cmonint%TYPE)
      RETURN monedas.cmonint%TYPE AS
      v_mone       monedas.cmonint%TYPE;
      e_parms        EXCEPTION;
      BEGIN
    -- TAREA: Se necesita implantaci?3n para FUNCTION PAC_CONTAB_CONF.f_contab_trm
      IF p_cmonint IS NULL
      THEN v_mone:='0';
      END IF;


      IF p_cmonint IS NOT NULL
      AND p_cmonint='COP'
      THEN
          v_mone:='0';

       ELSIF p_cmonint IS NOT NULL
         AND p_cmonint<>'COP'
      THEN
         v_mone:=p_cmonint ;


      END IF;


    RETURN v_mone;
  END f_moneda;

     /*************************************************************************
       NOMBRE              : f_tipo
       Funci?3n Trae el tipo de registro de cuentas
       param in  p_ctaniif : cuenta niif
       param out  v_tipo   : tipo de registro(K, D, A, C, I) seg?on la cuenta
    *************************************************************************/

 FUNCTION f_tipo(
      p_ctaniif IN cuentasniif_tipo.cta_niif%TYPE)
      RETURN cuentasniif_tipo.tipo%TYPE AS
      v_tipo      cuentasniif_tipo.cta_niif%TYPE;
      e_parms        EXCEPTION;
      BEGIN

      IF p_ctaniif IS NULL
      THEN RAISE e_parms;
      END IF;

      IF p_ctaniif IS NOT NULL
      THEN
          SELECT c.tipo
          INTO v_tipo
          FROM cuentasniif_tipo c
          WHERE c.cta_niif=p_ctaniif;




      END IF;


    RETURN v_tipo;
  END f_tipo;

   /*************************************************************************
       NOMBRE              : f_libro
       Funci??n Trae el tipo de libro de cuentas
       param in  p_ctaniif : cuenta niif
       param out  v_libro   : tipo de libro(0L,1L,0L1L) seg??n la cuenta
    *************************************************************************/

 FUNCTION f_libro(
      p_ctaniif IN cuentasniif_tipo.cta_niif%TYPE)
      RETURN cuentasniif_tipo.libro%TYPE AS
      v_libro      cuentasniif_tipo.cta_niif%TYPE;
      e_parms        EXCEPTION;
      BEGIN

      IF p_ctaniif IS NULL
      THEN RAISE e_parms;
      END IF;

      IF p_ctaniif IS NOT NULL
      THEN
          SELECT c.libro
          INTO v_libro
          FROM cuentasniif_tipo c
          WHERE c.cta_niif = p_ctaniif;

      END IF;

    RETURN v_libro;
  END f_libro;
 /*************************************************************************
 		IAXIS-4504 AABC 2019-08-13
       NOMBRE              : f_division_ica
       Funci?3n Trae la sucursal del siniestro
       param in  pnsinies : pnsinies, este par??metro no es siempre obligatorio, puede ser null
       param in  p_cagente : c?3digo del agente, este par??metro es obligatorio
       param out  v_division : c?3digo sucursal de la p?3liza
    *************************************************************************/

FUNCTION F_DIVISION_ICA(PNSINIES  IN SIN_SINIESTRO.NSINIES%TYPE,
                        PSIDEPAG  IN SIN_TRAMITA_PAGO.SIDEPAG%TYPE,
                        PDIVISION IN AGENTES.CAGENTE%TYPE)
  RETURN AGENTES.CAGENTE%TYPE AS
  V_DIVISION AGENTES.CAGENTE%TYPE;
  E_PARMS EXCEPTION;
  --
  vtipindi NUMBER := 0;
  vccindid VARCHAR2(10);
  vcindsap varchar2(10);  
  --
BEGIN

  IF PNSINIES IS NULL AND PSIDEPAG IS NULL THEN
    RAISE E_PARMS;
  END IF;
  --
  BEGIN 
     --
    SELECT DISTINCT (nvl(nval1,NULL)) 
      INTO V_DIVISION
      FROM sgt_subtabs_det 
     WHERE csubtabla = 9000021
       AND cversubt  = 1 
       AND nval1     = PDIVISION
       AND nval7     IN ( SELECT DISTINCT tp.cindsap
                            FROM sin_tramita_pago sp , per_indicadores pi , tipos_indicadores tp
                           WHERE  tp.cimpret = 4
                             AND tp.ctipind = pi.ctipind
                             AND pi.sperson = sp.sperson
                             AND sp.sidepag = PSIDEPAG
                             AND sp.nsinies = PNSINIES) 
       AND nval8     IN ( SELECT DISTINCT tp.ccindid
       FROM sin_tramita_pago sp , per_indicadores pi , tipos_indicadores tp
                           WHERE  tp.cimpret = 4
                             AND tp.ctipind = pi.ctipind
        AND pi.sperson = sp.sperson
        AND sp.sidepag = PSIDEPAG
                             AND sp.nsinies = PNSINIES);
     --
  EXCEPTION WHEN OTHERS THEN       
     --
     V_DIVISION := NULL;  
     --
  END; 
  --
   IF V_DIVISION IS NULL THEN 
     --
      BEGIN
        --
        SELECT DISTINCT (nvl(nval1,NULL)) 
       INTO V_DIVISION
       FROM sgt_subtabs_det 
      WHERE csubtabla = 9000021
        AND cversubt  = 1 
           AND nval7     IN ( SELECT DISTINCT tp.cindsap
                                FROM sin_tramita_pago sp , per_indicadores pi , tipos_indicadores tp
                               WHERE  tp.cimpret = 4
                                 AND tp.ctipind = pi.ctipind
                                 AND pi.sperson = sp.sperson
                                 AND sp.sidepag = PSIDEPAG
                                 AND sp.nsinies = PNSINIES) 
           AND nval8     IN ( SELECT DISTINCT tp.ccindid
                                FROM sin_tramita_pago sp , per_indicadores pi , tipos_indicadores tp
                               WHERE  tp.cimpret = 4
                                 AND tp.ctipind = pi.ctipind
                                 AND pi.sperson = sp.sperson
                                 AND sp.sidepag = PSIDEPAG
                                 AND sp.nsinies = PNSINIES); 
     --
      EXCEPTION WHEN OTHERS THEN 
     --
     V_DIVISION := NULL;
        --
      END;                                                       
     --   
  END IF;      
  --
  RETURN V_DIVISION;
  --
END F_DIVISION_ICA;
--
     /*************************************************************************
       NOMBRE              : f_persona
       Funci?3n Trae la identificaci?3n de la persona, seg?on la casuistica
       param in  p_sperson : se trae la identificaci?3n de tomadores cuando es una emisi?3n
       param in  p_cagente : se trae la identificaci?3n de agentes cuando son comisiones
       param in  p_compania: se trae el nit  de la compa?¡À?-a para coaseguro o reaseguro
       param in  p_ctipcom : 0 para reaseguro, 3 para coaseguro
       param out  v_tipo   : tipo de registro(K, D, A, C, I) seg?on la cuenta
    *************************************************************************/

      FUNCTION f_persona(
      p_sperson IN tomadores.sperson%TYPE,
      p_cagente IN agentes.cagente%TYPE,
      p_compania IN companias.ccompani%TYPE,
      p_ctipcom IN companias.ctipcom%TYPE)
      RETURN per_personas.nnumide%TYPE AS
      v_numide     per_personas.nnumide%TYPE;
       e_parms        EXCEPTION;
  BEGIN
    -- TAREA: Se necesita implantaci?3n para FUNCTION PAC_CONTAB_CONF.f_contab_trm
      IF p_sperson IS NULL
         AND p_cagente IS NULL
         AND p_compania IS NULL
         AND p_ctipcom IS NULL
         THEN
         RAISE e_parms;
      END IF;

      IF p_sperson IS NOT NULL
         AND p_cagente IS NULL
         AND p_compania IS NULL
         AND p_ctipcom IS NULL
      THEN
       -- BEGIN
          SELECT DISTINCT P.NNUMIDE
           INTO v_numide
           FROM TOMADORES T, PER_PERSONAS P
          WHERE T.SPERSON=P.SPERSON
            AND T.SPERSON=p_sperson;


      ELSIF p_sperson IS NULL
         AND p_cagente IS NOT NULL
         AND p_compania IS NULL
         AND p_ctipcom IS NULL
      THEN

         SELECT DISTINCT P.NNUMIDE
          INTO v_numide
           FROM AGENTES A, PER_PERSONAS P
         WHERE A.SPERSON=P.SPERSON
           AND A.CAGENTE=p_cagente;

      ELSIF p_sperson IS NULL
         AND p_cagente IS  NULL
         AND p_compania IS NOT NULL
         AND p_ctipcom  IS NOT NULL
      THEN

         SELECT DISTINCT P.NNUMIDE
          INTO v_numide
           FROM ctacoaseguro CC, PER_PERSONAS P, COMPANIAS C
         WHERE C.SPERSON=P.SPERSON
           AND c.ccompani=cc.ccompani
           AND c.ccompani=p_compania
           AND c.ctipcom=p_ctipcom;


      END IF;


    RETURN v_numide;
  END f_persona;


    /*************************************************************************
       NOMBRE              : f_division
       Funci?3n Trae la sucursal de la p?3liza
       param in  p_sseguro : sseguro, este par??metro no es siempre obligatorio, puede ser null
       param in  p_cagente : c?3digo del agente, este par??metro es obligatorio
       param out  v_division : c?3digo sucursal de la p?3liza
    *************************************************************************/

     FUNCTION f_division(
     p_sseguro IN seguros.sseguro%TYPE,
      p_cagente IN seguros.cagente%TYPE)
      RETURN agentes.cagente%TYPE AS
      v_division     agentes.cagente%TYPE;
       e_parms        EXCEPTION;
  BEGIN
    -- TAREA: Se necesita implantaci?3n para FUNCTION PAC_CONTAB_CONF.f_contab_trm
      IF p_sseguro IS NULL
         AND p_cagente IS NULL
         THEN
         RAISE e_parms;
      END IF;

      IF p_sseguro IS NOT NULL
         AND p_cagente IS NOT NULL
      THEN
       -- BEGIN

        SELECT AP.TVALPAR
        INTO v_division
        FROM age_paragentes AP,
         (SELECT  CASE WHEN A.CTIPAGE IN (2,3) THEN A.CAGENTE
                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (3) THEN  CA.AGE_PADRE
                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (2) THEN  CA.AGE_PADRE
                         END SUC

                  FROM
                     SEGUROS S, AGENTES A,
                     (SELECT X.CAGENTE, X.CTIPAGE_AGE, X.AGE_PADRE, A.CTIPAGE CTIPAGE_PADRE FROM
                     (SELECT CAGENTE,CTIPAGE CTIPAGE_AGE, TO_NUMBER(NVL(pac_redcomercial.f_busca_padre(24, cagente, NULL, NULL), 0) )AGE_PADRE
                      FROM AGENTES )X,
                      AGENTES A
                      WHERE AGE_PADRE=A.CAGENTE)CA

                  WHERE A.CAGENTE=S.CAGENTE
                    AND A.CAGENTE=CA.CAGENTE
                    AND A.CAGENTE=p_cagente
                    AND S.SSEGURO=p_sseguro
                  )A
          WHERE A.SUC=AP.CAGENTE;

      ELSIF p_sseguro IS NULL
         AND p_cagente IS NOT NULL
      THEN

          SELECT DISTINCT AP.TVALPAR
        INTO v_division
        FROM age_paragentes AP,
         (SELECT  CASE WHEN A.CTIPAGE IN (2,3) THEN A.CAGENTE
                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (3) THEN  CA.AGE_PADRE
                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (2) THEN  CA.AGE_PADRE
                         END SUC

                  FROM
                     SEGUROS S, AGENTES A,
                     (SELECT X.CAGENTE, X.CTIPAGE_AGE, X.AGE_PADRE, A.CTIPAGE CTIPAGE_PADRE FROM
                     (SELECT CAGENTE,CTIPAGE CTIPAGE_AGE, TO_NUMBER(NVL(pac_redcomercial.f_busca_padre(24, cagente, NULL, NULL), 0) )AGE_PADRE
                      FROM AGENTES )X,
                      AGENTES A
                      WHERE AGE_PADRE=A.CAGENTE)CA

                  WHERE A.CAGENTE=S.CAGENTE
                    AND A.CAGENTE=CA.CAGENTE
                    AND A.CAGENTE=p_cagente
                  )A
          WHERE A.SUC=AP.CAGENTE;


        ELSIF p_sseguro IS NOT NULL
         AND p_cagente IS NULL
      THEN

            SELECT DISTINCT AP.TVALPAR
        INTO v_division
        FROM age_paragentes AP,
         (SELECT  CASE WHEN A.CTIPAGE IN (2,3) THEN A.CAGENTE
                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (3) THEN  CA.AGE_PADRE
                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (2) THEN  CA.AGE_PADRE
                         END SUC

                  FROM
                     SEGUROS S, AGENTES A,
                     (SELECT X.CAGENTE, X.CTIPAGE_AGE, X.AGE_PADRE, A.CTIPAGE CTIPAGE_PADRE FROM
                     (SELECT CAGENTE,CTIPAGE CTIPAGE_AGE, TO_NUMBER(NVL(pac_redcomercial.f_busca_padre(24, cagente, NULL, NULL), 0) )AGE_PADRE
                      FROM AGENTES )X,
                      AGENTES A
                      WHERE AGE_PADRE=A.CAGENTE)CA

                  WHERE A.CAGENTE=S.CAGENTE
                    AND A.CAGENTE=CA.CAGENTE
                    AND s.SSEGURO=p_sseguro
                  )A
          WHERE A.SUC=AP.CAGENTE;

      END IF;


    RETURN v_division;
  END f_division;

 /*************************************************************************
 		IAXIS-4504 EA 2019-08-13
       NOMBRE              : f_division_sin
       Funci?3n Trae la sucursal del siniestro
       param in  pnsinies : pnsinies, este par??metro no es siempre obligatorio, puede ser null
       param in  p_cagente : c?3digo del agente, este par??metro es obligatorio
       param out  v_division : c?3digo sucursal de la p?3liza
    *************************************************************************/

FUNCTION F_DIVISION_SIN(PNSINIES  IN SIN_SINIESTRO.NSINIES%TYPE,
                        PSIDEPAG  IN SIN_TRAMITA_PAGO.SIDEPAG%TYPE,
                        P_CAGENTE IN SEGUROS.CAGENTE%TYPE)
  RETURN AGENTES.CAGENTE%TYPE AS
  V_DIVISION AGENTES.CAGENTE%TYPE;
  V_DIVISICA AGENTES.CAGENTE%TYPE;
  E_PARMS EXCEPTION;

BEGIN
  -- TAREA: Se necesita implantaci?3n para FUNCTION PAC_CONTAB_CONF.f_contab_trm

 
  IF PNSINIES IS NULL AND P_CAGENTE IS NULL THEN
    RAISE E_PARMS;
  END IF;

  IF PNSINIES IS NOT NULL AND P_CAGENTE IS NOT NULL THEN
    
    -- BEGIN
  
    SELECT DISTINCT AP.TVALPAR
      INTO V_DIVISION
      FROM AGE_PARAGENTES AP,
           SIN_SINIESTRO S,
           (SELECT CASE
                     WHEN A.CTIPAGE IN (2, 3) THEN
                      A.CAGENTE
                     WHEN A.CTIPAGE NOT IN (2, 3) AND CA.CTIPAGE_PADRE IN (3) THEN
                      CA.AGE_PADRE
                     WHEN A.CTIPAGE NOT IN (2, 3) AND CA.CTIPAGE_PADRE IN (2) THEN
                      CA.AGE_PADRE
                   END SUC
            
              FROM SIN_TRAMITA_PAGO S,
                   AGENTES A,
                   (SELECT X.CAGENTE,
                           X.CTIPAGE_AGE,
                           X.AGE_PADRE,
                           A.CTIPAGE CTIPAGE_PADRE
                      FROM (SELECT CAGENTE,
                                   CTIPAGE CTIPAGE_AGE,
                                   TO_NUMBER(NVL(PAC_REDCOMERCIAL.F_BUSCA_PADRE(24,
                                                                                CAGENTE,
                                                                                NULL,
                                                                                NULL),
                                                 0)) AGE_PADRE
                              FROM AGENTES) X,
                           AGENTES A
                     WHERE AGE_PADRE = A.CAGENTE) CA
            
             WHERE A.CAGENTE = S.CAGENTE
               AND A.CAGENTE = CA.CAGENTE
               AND A.CAGENTE = P_CAGENTE
               AND S.NSINIES = PNSINIES) A
     WHERE A.SUC = AP.CAGENTE
       AND S.NSINIES = PNSINIES;
  
  ELSIF PNSINIES IS NULL AND P_CAGENTE IS NOT NULL THEN
    
    SELECT DISTINCT AP.TVALPAR
      INTO V_DIVISION
      FROM AGE_PARAGENTES AP,
           (SELECT CASE
                     WHEN A.CTIPAGE IN (2, 3) THEN
                      A.CAGENTE
                     WHEN A.CTIPAGE NOT IN (2, 3) AND CA.CTIPAGE_PADRE IN (3) THEN
                      CA.AGE_PADRE
                     WHEN A.CTIPAGE NOT IN (2, 3) AND CA.CTIPAGE_PADRE IN (2) THEN
                      CA.AGE_PADRE
                   END SUC
            
              FROM SIN_TRAMITA_PAGO S,
                   AGENTES A,
                   (SELECT X.CAGENTE,
                           X.CTIPAGE_AGE,
                           X.AGE_PADRE,
                           A.CTIPAGE CTIPAGE_PADRE
                      FROM (SELECT CAGENTE,
                                   CTIPAGE CTIPAGE_AGE,
                                   TO_NUMBER(NVL(PAC_REDCOMERCIAL.F_BUSCA_PADRE(24,
                                                                                CAGENTE,
                                                                                NULL,
                                                                                NULL),
                                                 0)) AGE_PADRE
                              FROM AGENTES) X,
                           AGENTES A
                     WHERE AGE_PADRE = A.CAGENTE) CA
            
             WHERE A.CAGENTE = S.CAGENTE
               AND A.CAGENTE = CA.CAGENTE
               AND A.CAGENTE = P_CAGENTE) A
     WHERE A.SUC = AP.CAGENTE;
  
  ELSIF PNSINIES IS NOT NULL AND P_CAGENTE IS NULL THEN
   
    SELECT DISTINCT AP.TVALPAR
      INTO V_DIVISION
      FROM AGE_PARAGENTES AP,
           SIN_SINIESTRO S,
           (SELECT CASE
                     WHEN A.CTIPAGE IN (2, 3) THEN
                      A.CAGENTE
                     WHEN A.CTIPAGE NOT IN (2, 3) AND CA.CTIPAGE_PADRE IN (3) THEN
                      CA.AGE_PADRE
                     WHEN A.CTIPAGE NOT IN (2, 3) AND CA.CTIPAGE_PADRE IN (2) THEN
                      CA.AGE_PADRE
                   END SUC
            
              FROM SIN_SINIESTRO S,
                   AGENTES A,
                   (SELECT X.CAGENTE,
                           X.CTIPAGE_AGE,
                           X.AGE_PADRE,
                           A.CTIPAGE CTIPAGE_PADRE
                      FROM (SELECT CAGENTE,
                                   CTIPAGE CTIPAGE_AGE,
                                   TO_NUMBER(NVL(PAC_REDCOMERCIAL.F_BUSCA_PADRE(24,
                                                                                CAGENTE,
                                                                                NULL,
                                                                                NULL),
                                                 0)) AGE_PADRE
                              FROM AGENTES) X,
                           AGENTES A
                     WHERE AGE_PADRE = A.CAGENTE) CA
            
             WHERE A.CAGENTE = S.CAGENTE
               AND A.CAGENTE = CA.CAGENTE
               AND S.NSINIES = PNSINIES) A
     WHERE A.SUC = AP.CAGENTE
       AND S.NSINIES = PNSINIES;
  
  END IF;
  --Iaxis 4504 AABC validacion de division 09/09/2019
  V_DIVISICA := F_DIVISION_ICA(PNSINIES,PSIDEPAG,V_DIVISION); 
  --
  IF V_DIVISION = V_DIVISICA THEN 
     --  
     RETURN V_DIVISICA;
     --
  ELSIF V_DIVISICA IS NULL THEN   
     --
  RETURN V_DIVISION;
     --
  ELSIF NVL(V_DIVISICA,0) <> 0 AND  V_DIVISION <> V_DIVISICA THEN
    --
    RETURN V_DIVISICA;   
    --
  END IF;
  --Iaxis 4504 AABC validacion de division 09/09/2019 
END F_DIVISION_SIN;
--
     /*************************************************************************
       NOMBRE              : f_region
       Funci?3n Trae la regi?3n de emisi?3n de la p?3liza
       param in  p_sseguro : sseguro, este par??metro no es siempre obligatorio, puede ser null
       param in  p_cagente : c?3digo del agente, este par??metro no es siempre obligatorio, puede ser null
       param out  v_region : c?3digo de la regi?3n de emisi?3n de la p?3liza
    *************************************************************************/

     FUNCTION f_region(
     p_sseguro IN seguros.sseguro%TYPE,
      p_cagente IN seguros.cagente%TYPE)
      RETURN agentes.cagente%TYPE AS
      v_region     agentes.cagente%TYPE;
       e_parms        EXCEPTION;
  BEGIN
    -- TAREA: Se necesita implantaci?3n para FUNCTION PAC_CONTAB_CONF.f_contab_trm
      IF p_sseguro IS NULL
         AND p_cagente IS NULL
         THEN
         RAISE e_parms;
      END IF;

      IF p_sseguro IS NOT NULL
         AND p_cagente IS NOT NULL
      THEN
       -- BEGIN

       SELECT DISTINCT PD.CPROVIN
            INTO v_region
            FROM PER_DIRECCIONES PD, AGENTES A, SEGUROS S
            WHERE PD.SPERSON IN (
              SELECT   DISTINCT  A.SPERSON FROM
               (SELECT    A.CAGENTE, A.CTIPAGE,
                 CASE WHEN A.CTIPAGE IN (2,3) THEN A.CAGENTE
                                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (3) THEN  CA.AGE_PADRE
                                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (2) THEN  CA.AGE_PADRE
                                         END SUC, CA.AGE_PADRE, CA.CTIPAGE_PADRE
                FROM SEGUROS S, AGENTES A,
                     (SELECT X.CAGENTE, X.CTIPAGE_AGE, X.AGE_PADRE, A.CTIPAGE CTIPAGE_PADRE FROM
                         (SELECT CAGENTE,CTIPAGE CTIPAGE_AGE, TO_NUMBER(NVL(pac_redcomercial.f_busca_padre(24, cagente, NULL, NULL), 0) )AGE_PADRE
                          FROM AGENTES )X,
                      AGENTES A
                      WHERE AGE_PADRE=A.CAGENTE)CA

                WHERE A.CAGENTE=CA.CAGENTE(+)

                  AND A.CAGENTE=p_cagente
                  AND S.SSEGURO=p_sseguro
                  )X, AGENTES A
              WHERE X.SUC=A.CAGENTE  )
            AND PD.SPERSON=A.SPERSON
            AND A.CAGENTE=S.CAGENTE(+)

           ;

            /*SELECT PD.CPROVIN
            INTO v_region
            FROM PER_DIRECCIONES PD, AGENTES A, SEGUROS S
            WHERE PD.SPERSON=A.SPERSON
              AND S.CAGENTE=A.CAGENTE
              AND PD.CDOMICI=A.CDOMICI
              AND A.CAGENTE=p_cagente
              AND S.SSEGURO=p_sseguro;*/


      ELSIF p_sseguro IS NULL
         AND p_cagente IS NOT NULL
      THEN
            SELECT DISTINCT PD.CPROVIN
            INTO v_region
            FROM PER_DIRECCIONES PD, AGENTES A, SEGUROS S
            WHERE PD.SPERSON IN (
              SELECT   DISTINCT  A.SPERSON FROM
               (SELECT    A.CAGENTE, A.CTIPAGE,
                 CASE WHEN A.CTIPAGE IN (2,3) THEN A.CAGENTE
                                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (3) THEN  CA.AGE_PADRE
                                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (2) THEN  CA.AGE_PADRE
                                         END SUC, CA.AGE_PADRE, CA.CTIPAGE_PADRE
                FROM SEGUROS S, AGENTES A,
                     (SELECT X.CAGENTE, X.CTIPAGE_AGE, X.AGE_PADRE, A.CTIPAGE CTIPAGE_PADRE FROM
                         (SELECT CAGENTE,CTIPAGE CTIPAGE_AGE, TO_NUMBER(NVL(pac_redcomercial.f_busca_padre(24, cagente, NULL, NULL), 0) )AGE_PADRE
                          FROM AGENTES )X,
                      AGENTES A
                      WHERE AGE_PADRE=A.CAGENTE)CA

                WHERE A.CAGENTE=CA.CAGENTE(+)
                  AND A.CAGENTE=p_cagente
                  )X, AGENTES A
              WHERE X.SUC=A.CAGENTE  )
            AND PD.SPERSON=A.SPERSON
            AND A.CAGENTE=S.CAGENTE(+)

           ;

              /*SELECT PD.CPROVIN
            INTO v_region
            FROM PER_DIRECCIONES PD, AGENTES A, SEGUROS S
            WHERE PD.SPERSON=A.SPERSON
              AND S.CAGENTE=A.CAGENTE
              AND PD.CDOMICI=A.CDOMICI
              AND A.CAGENTE=p_cagente;*/

      ELSIF p_sseguro IS NOT NULL
         AND p_cagente IS NULL
      THEN

           SELECT DISTINCT PD.CPROVIN
            INTO v_region
            FROM PER_DIRECCIONES PD, AGENTES A, SEGUROS S
            WHERE PD.SPERSON IN (
              SELECT   DISTINCT  A.SPERSON FROM
               (SELECT    A.CAGENTE, A.CTIPAGE,
                 CASE WHEN A.CTIPAGE IN (2,3) THEN A.CAGENTE
                                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (3) THEN  CA.AGE_PADRE
                                              WHEN A.CTIPAGE NOT IN (2,3) AND CA.CTIPAGE_PADRE IN (2) THEN  CA.AGE_PADRE
                                         END SUC, CA.AGE_PADRE, CA.CTIPAGE_PADRE
                FROM SEGUROS S, AGENTES A,
                     (SELECT X.CAGENTE, X.CTIPAGE_AGE, X.AGE_PADRE, A.CTIPAGE CTIPAGE_PADRE FROM
                         (SELECT CAGENTE,CTIPAGE CTIPAGE_AGE, TO_NUMBER(NVL(pac_redcomercial.f_busca_padre(24, cagente, NULL, NULL), 0) )AGE_PADRE
                          FROM AGENTES )X,
                      AGENTES A
                      WHERE AGE_PADRE=A.CAGENTE)CA

                WHERE A.CAGENTE=CA.CAGENTE(+)

                  )X, AGENTES A
              WHERE X.SUC=A.CAGENTE  )
            AND PD.SPERSON  = A.SPERSON
            AND A.CAGENTE   = S.CAGENTE
            AND S.SSEGURO   = p_sseguro
           ;


      END IF;


    RETURN v_region;
  END f_region;


   /*************************************************************************
       NOMBRE               : f_segmento
       Funci?3n Trae la sucursal de un agente o un seguro
       param in  p_sseguro  : sseguro, este par??metro es obligatorio
       param out v_segmento : c?3digo SAP que indica el ramo
    *************************************************************************/

   FUNCTION f_segmento(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN cnvproductos_ext.cnv_spr%TYPE AS
      v_segmento       cnvproductos_ext.cnv_spr%TYPE;
      e_parms        EXCEPTION;
      BEGIN
      IF p_sseguro IS NULL
      THEN RAISE e_parms;
      END IF;

      IF p_sseguro IS NOT NULL
      THEN
          SELECT   SUBSTR(CE.CNV_SPR,1,INSTR(CE.CNV_SPR,'|')-1)
          INTO v_segmento
          FROM SEGUROS S,CNVPRODUCTOS_EXT CE
          WHERE S.SPRODUC = CE.SPRODUC
            AND S.SSEGURO = p_sseguro;

      END IF;


    RETURN v_segmento;
  END f_segmento;

   /*************************************************************************
       NOMBRE               : f_zzproducto
       Funci?3n Trae el producto al que corresponde un seguro
       param in  p_sseguro  : sseguro, este par??metro es obligatorio
       param out v_producto : c?3digo SAP que indica el producto
    *************************************************************************/

   FUNCTION f_zzproducto(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN cnvproductos_ext.cnv_spr%TYPE AS
      v_producto       cnvproductos_ext.cnv_spr%TYPE;
      e_parms        EXCEPTION;
      BEGIN
      IF p_sseguro IS NULL
      THEN RAISE e_parms;
      END IF;

      IF p_sseguro IS NOT NULL
      THEN
          SELECT    SUBSTR(CE.CNV_SPR,INSTR(CE.CNV_SPR,'|')+1,LENGTH(CE.CNV_SPR))
          INTO v_producto
          FROM SEGUROS S,CNVPRODUCTOS_EXT CE
          WHERE S.SPRODUC = CE.SPRODUC
            AND S.SSEGURO = p_sseguro;

      END IF;


    RETURN v_producto;
  END f_zzproducto;

 /*************************************************************************
       NOMBRE              : f_pagador_alt
       Funci?3n Trae intermediario principal de la p?3liza
       param in  p_sseguro : sseguro, este par??metro no es siempre obligatorio, puede ser null
       param out  v_pagador_alt : intermediario principal de la p?3liza
    *************************************************************************/


       FUNCTION f_pagador_alt(
         p_sseguro IN seguros.sseguro%TYPE)
      RETURN per_personas.nnumide%TYPE AS
       v_pagador_alt    per_personas.nnumide%TYPE;
       e_parms        EXCEPTION;
  BEGIN
      IF p_sseguro IS NULL
         THEN
         RAISE e_parms;
      END IF;

      IF p_sseguro IS NOT NULL

      THEN

            SELECT X.PAGADOR_ALT
              INTO v_pagador_alt
            FROM
            (
            SELECT S.SSEGURO,S.CAGENTE AGE_SEGURO, A.CAGENTE,A.SPERSON,
            CASE WHEN A.CAGENTE IS NOT NULL THEN A.SPERSON
                 WHEN A.CAGENTE IS NULL AND AG.CTIPAGE NOT in(0,1,2,3)  THEN AG.SPERSON
                 END PAGADOR_ALT
            FROM SEGUROS S,


                  (SELECT  S.SSEGURO, S.NPOLIZA, A.CTIPAGE, A.CAGENTE, AC.ISLIDER, A.SPERSON
                  FROM AGENTES A,
                  AGE_CORRETAJE AC, SEGUROS S
                  WHERE A.CAGENTE=AC.CAGENTE
                  AND S.CAGENTE=A.CAGENTE
                  AND AC.ISLIDER=1)A, AGENTES AG
                  WHERE S.SSEGURO=A.SSEGURO(+)
                      AND S.CAGENTE=AG.CAGENTE

                      )X
                  WHERE X.SSEGURO=p_sseguro
                  GROUP BY X.SSEGURO, X.PAGADOR_ALT;

           /* SELECT X.NNUMIDE
            INTO v_pagador_alt
            FROM
            (SELECT  S.SSEGURO, S.NPOLIZA, A.CTIPAGE, A.CAGENTE, AC.ISLIDER,
            P.NNUMIDE

            FROM AGENTES A,
            AGE_CORRETAJE AC, SEGUROS S, PER_PERSONAS P
            WHERE A.CAGENTE=AC.CAGENTE
            AND S.CAGENTE=A.CAGENTE
            AND A.SPERSON=P.SPERSON
            AND A.CTIPAGE in(0,1,2,3)

            UNION


            SELECT  S.SSEGURO, S.NPOLIZA, A.CTIPAGE, A.CAGENTE, AC.ISLIDER,
            P.NNUMIDE

            FROM AGENTES A,
            AGE_CORRETAJE AC, SEGUROS S, PER_PERSONAS P
            WHERE A.CAGENTE=AC.CAGENTE
            AND S.CAGENTE=A.CAGENTE
            AND A.SPERSON=P.SPERSON
            AND AC.ISLIDER=1)X
            WHERE X.SSEGURO=p_sseguro;*/


      END IF;


    RETURN v_pagador_alt;
  END f_pagador_alt;

   /*************************************************************************
       NOMBRE : f_zzfipoliza
       Funcion que retorna el numero de poliza proveniente de Osiris
       param in  p_sseguro : sseguro, este parametro es siempre obligatorio
       param out  v_zzfipoliza :  Poliza Antigua
       Fecha : 20191129
       Tarea : IAXIS-7643
    *************************************************************************/


     FUNCTION F_ZZFIPOLIZA(
      P_SSEGURO IN SEGUROS.SSEGURO%TYPE)
      RETURN VARCHAR2 AS
      
      V_ZZFIPOLIZA SEGUROS.CPOLCIA%TYPE;
      X_POSICION SEGUROS.CPOLCIA%TYPE;
      V_CPOLCIA  SEGUROS.CPOLCIA%TYPE;
      V_NPOLIZA  SEGUROS.NPOLIZA%TYPE;
      E_PARMS   EXCEPTION;
      
      BEGIN
        
        SELECT CPOLCIA,NPOLIZA
          INTO V_CPOLCIA,V_NPOLIZA
          FROM SEGUROS 
         WHERE SSEGURO = P_SSEGURO;
        
        IF P_SSEGURO IS NULL
          THEN RAISE E_PARMS;
        END IF;
        
        IF P_SSEGURO IS NOT NULL  THEN
        
          IF V_CPOLCIA IS NULL THEN
             V_ZZFIPOLIZA := V_NPOLIZA;
           
          ELSE
            SELECT SUBSTR(V_CPOLCIA,-8)
				      INTO X_POSICION
	            FROM DUAL;
              
             V_ZZFIPOLIZA := X_POSICION;
          
          END IF;  
        END IF;
        
       RETURN V_ZZFIPOLIZA;
    
     END F_ZZFIPOLIZA;

    /*************************************************************************
       NOMBRE              : f_zzcertific
       Funci?3n Trae la moneda correspondiente de una p?3liza
       param in  p_sseguro : sseguro, este par??metro es siempre obligatorio
       param out  v_zzcertific : certificado o suplemento
    *************************************************************************/

       FUNCTION f_zzcertific(
      p_sseguro IN seguros.sseguro%TYPE)
      RETURN rango_dian_movseguro.ncertdian%TYPE AS
      v_zzcertific      rango_dian_movseguro.ncertdian%TYPE;
      e_parms        EXCEPTION;
      BEGIN
      IF p_sseguro IS NULL
      THEN RAISE e_parms;
      END IF;

      IF p_sseguro IS NOT NULL
      THEN

          select rdm.ncertdian
          into v_zzcertific
          from rango_dian_movseguro rdm
          where rdm.nmovimi=(select max(rd.nmovimi)
                          from rango_dian_movseguro rd
                          where rd.sseguro=rdm.sseguro
                          group by rd.sseguro)
           and rdm.sseguro=p_sseguro;


           /*select m.nsuplem
           INTO v_zzcertific
           from movseguro m
           where nmovimi=(select max(ms.nmovimi)
                          from movseguro ms
                          where ms.sseguro=m.sseguro
                          group by ms.sseguro)
           and m.sseguro=p_sseguro;*/



      END IF;


    RETURN v_zzcertific;
  END f_zzcertific;

   /*************************************************************************
       NOMBRE              : f_importe_base_iva
       Funci?3n Trae el valor base sobre el que se calcula el iva
       param in  p_nrecibo : sseguro, este par??metro es siempre obligatorio
       param in  p_cagente : c?3digo del agente, este par??metro es obligatorio
       param out  v_importe_base_iva : valor base sobre el que se calcula el iva
    *************************************************************************/

  FUNCTION f_importe_base_iva(
      p_nrecibo IN recibos.nrecibo%TYPE,
      p_cagente IN ctactes.cagente%TYPE)
      RETURN vdetrecibos.iprinet%TYPE AS
      v_importe_base_iva    vdetrecibos.iprinet%TYPE;
      e_parms        EXCEPTION;
  BEGIN
    -- TAREA: Se necesita implantaci?3n para FUNCTION PAC_CONTAB_CONF.f_contab_trm
      IF p_nrecibo IS NULL
         AND p_cagente IS NULL
         THEN
         RAISE e_parms;
      END IF;

      IF p_nrecibo IS NOT NULL
         AND p_cagente IS NOT NULL
      THEN
       -- BEGIN

             SELECT DISTINCT
              pac_corretaje.f_impcor_agente(NVL(vm.iprinet, v.iprinet), c.cagente, s.sseguro,   r.nmovimi)
              INTO v_importe_base_iva
             FROM movrecibo m, recibos r, vdetrecibos_monpol vm, vdetrecibos v,ctactes c, seguros s
             WHERE C.NRECIBO=R.NRECIBO
               AND R.NRECIBO=V.NRECIBO
               AND V.NRECIBO=VM.NRECIBO
               AND C.CAGENTE=R.CAGENTE
               AND S.SSEGURO=R.SSEGURO
               AND C.CAGENTE=p_cagente
               AND C.NRECIBO=p_nrecibo;

      END IF;

    RETURN v_importe_base_iva;
  END f_importe_base_iva;
 --
 /*************************************************************************
  NOMBRE: f_importe_provision
  Funci?3n Trae el valor base del importe dependiendo de los registros
  param in  p_sproces: Numero de proceso
  param in  p_tip_provisi :Tipo de Provision, 1 Prima Devengada, 2  Octavos.
  param in  p_fech_cierre :Fecha de cierre.
  param in  p_sucursal   :Sucursal de la provisi?3n.
  param out Error : Error
 *************************************************************************/
 -- Version 2.0
 FUNCTION f_importe_provision(p_sproces     IN NUMBER,
                              p_tip_provisi IN NUMBER,
                              p_fech_cierre IN DATE,
                              p_sucursal    IN NUMBER)
 RETURN NUMBER AS
   --
   mes_ant         VARCHAR2(10):= NULL;
   ano_ant         VARCHAR2(4) := NULL;
   l_fecha_cierre  DATE;
   Import_mes_act  NUMBER;
   Import_mes_ant  NUMBER;
   Import_ano_ant  NUMBER;
   import_contra   NUMBER ;
   import_contra_h NUMBER ;
   import_contra_d NUMBER ;
   import_liberac  NUMBER ;
   import_ampliado NUMBER ;
   import_disminuc NUMBER ;
   l_periodo       VARCHAR2(8);
   --
   BEGIN
      --Inicializacion de variables de acumulaci?3n
      import_contra    := 0;
      import_contra_h  := 0;
      import_contra_d  := 0;
      import_liberac   := 0;
      import_ampliado  := 0;
      import_disminuc  := 0;
      l_periodo        := NULL;
      --Provision por Octavos
      --Mes Anterior a la fecha de corte de la provision
      mes_ant := LPAD (to_char(p_fech_cierre,'MM') - 1,2,0);
      ano_ant := LPAD (to_char(p_fech_cierre,'YYYY') - 1,4,0);
      l_periodo := to_char(p_fech_cierre,'MM/YYYY');
      --
      IF p_tip_provisi = 2 THEN
         --
         --Importe Mes Actual
         SELECT NVL(SUM(o.iprovfecoct),0) importe
           INTO Import_mes_act
           FROM PPPC_CONF_OCT o
          WHERE o.fcalcul = p_fech_cierre
            AND pac_contab_conf.f_division(o.sseguro,NULL) = p_sucursal;
         --
         --Importe Mes Anterior, A?¡Ào Anterior
          BEGIN
             SELECT nvl(p.ipppc,0),nvl(p.ipppc_an_ant,0)
               INTO Import_mes_ant,Import_ano_ant
               FROM suc_pppc_octo_resu p
              WHERE p.sucursal = p_sucursal
                AND p.fecha_per = (SELECT MAX (pp.fecha_per)
                                     FROM suc_pppc_octo_resu pp
                                    WHERE sucursal = p_sucursal);
          EXCEPTION WHEN NO_DATA_FOUND THEN
             --
             Import_mes_ant := 0;
             Import_ano_ant := 0;
             --
          END;
          IF Import_ano_ant = 0 THEN
            --
            SELECT NVL(SUM(o.iprovfecoct),0) importe
              INTO Import_ano_ant
              FROM PPPC_CONF_OCT o
             WHERE pac_contab_conf.f_division(o.sseguro,NULL) = p_sucursal
               AND o.fcalcul = (SELECT MAX (p.fcalcul)
                                  FROM pppc_conf_oct p
                                 WHERE to_number(to_char(p.fcalcul,'YYYY'))      = to_char(p_fech_cierre,'YYYY') - 1
                                   AND pac_contab_conf.f_division(p.sseguro,NULL)= p_sucursal);
            --
          END IF;
       --
       --Prima Devengada
       ELSIF p_tip_provisi = 1 THEN
          --
          --Importe Mes Actual
          SELECT NVL(SUM(ipppc_moncon),0) importe
            INTO Import_mes_act
            FROM PPPC_CONF  p
           WHERE p.fcalcul =  p_fech_cierre
             AND pac_contab_conf.f_division(p.sseguro,NULL) = p_sucursal;
         --Importe Mes Anterior, A?¡Ào Anterior
         BEGIN
          SELECT nvl(p.ipppc,0),nvl(p.ipppc_an_ant,0)
            INTO Import_mes_ant,Import_ano_ant
            FROM suc_pppc_resu p
           WHERE p.sucursal = p_sucursal
             AND p.fecha_per = (SELECT MAX (pp.fecha_per)
                                  FROM suc_pppc_resu pp
                                 WHERE sucursal = p_sucursal);
         EXCEPTION WHEN NO_DATA_FOUND THEN
            --
            Import_mes_ant := 0;
            Import_ano_ant := 0;
            --
        END;
        --
        IF Import_ano_ant = 0 THEN
            --
            SELECT NVL(SUM(o.ipppc_moncon),0) importe
              INTO Import_ano_ant
              FROM PPPC_CONF o
             WHERE pac_contab_conf.f_division(o.sseguro,NULL) = p_sucursal
               AND o.fcalcul = (SELECT MAX (p.fcalcul)
                                  FROM PPPC_CONF p
                                 WHERE to_number(to_char(p.fcalcul,'YYYY'))      = to_char(p_fech_cierre,'YYYY') - 1
                                   AND pac_contab_conf.f_division(p.sseguro,NULL)= p_sucursal);
           --
        END IF;
        --
     END IF;
     --
     --Inicializacion de variables de acumulaci?3n
     IF mes_ant = 0 THEN
        --
        Import_mes_ant := Import_ano_ant;
        --
     END IF;
     --Importe contrapartida
     import_contra := Import_mes_act - Import_mes_ant;
     --Si la contrapartida es negativa la cambia a positiva.
     IF import_contra > 0 AND Import_mes_ant = 0 THEN
        --
        import_contra_d := import_contra;
        --
     END IF;
     --Si el A?¡Ào Anterior es mayor al mes Actual calcula importe de liberacion.
     IF Import_ano_ant  > Import_mes_act  THEN
        --
        import_liberac := Import_ano_ant - Import_mes_act;
        --
     END IF;
     --Si el Importe del a?¡Ào Anterior es mayor al importe del mes actual calcula Importe de disminucion.
     IF Import_mes_ant > nvl(Import_mes_act,0)   THEN
        --
        Import_disminuc := (Import_mes_ant - NVL(Import_mes_act,0)) - import_liberac;
        --De lo contrario calcula el importe de ampliacion.
     ELSIF  Import_mes_act > Import_mes_ant AND import_contra_d <> Import_mes_act THEN
        --
        import_ampliado := Import_mes_act - Import_mes_ant;
        --
     END IF;
     --
        IF p_tip_provisi = 1 THEN
           --
           INSERT INTO SUC_PPPC_RESU(SUCURSAL,SPROCES,PERIODO,FECHA_PER,IPPPC,IPPPC_AN_ANT,IPPPC_AMPL,IPPPC_DISM,
                                     IPPPC_LIBE,IPPPC_CON_D,USUARIO,FECHA_PROC)
                VALUES              (p_sucursal,p_sproces,l_periodo,p_fech_cierre,Import_mes_act,Import_ano_ant,import_ampliado,Import_disminuc,
                                     import_liberac,import_contra_d,USER,SYSDATE);
           RETURN 0;
           --
        ELSIF p_tip_provisi = 2 THEN
           --
           INSERT INTO SUC_PPPC_OCTO_RESU(SUCURSAL,SPROCES,PERIODO,FECHA_PER,IPPPC,IPPPC_AN_ANT,
                                          IPPPC_AMPL,IPPPC_DISM,IPPPC_LIBE,IPPPC_CON_D,
                                          USUARIO,FECHA_PROC)
                VALUES                   (p_sucursal,p_sproces,l_periodo,p_fech_cierre,Import_mes_act,Import_ano_ant,
                                          import_ampliado,Import_disminuc,import_liberac,import_contra_d,
                                          USER,SYSDATE);
           RETURN 0;
           --
        END IF;
     --
 END f_importe_provision;
 -- Version 2.0
 -- Version 3.0
/*************************************************************************
 NOMBRE              : f_catribu
 Funcion que obtine el catribu de la tabla detvalores para los nuevos
 ttippag creados.
*************************************************************************/
FUNCTION f_catribu(p_cvalor  IN detvalores.cvalor%TYPE,
                     p_cidioma IN detvalores.cidioma%TYPE,
                     p_tatribu IN detvalores.tatribu%TYPE)
RETURN NUMBER AS
   --
   l_catribu detvalores.catribu%TYPE;
   --
BEGIN
   --
   BEGIN
     SELECT d.catribu
     INTO l_catribu
     FROM detvalores d
    WHERE d.cvalor  = p_cvalor
      AND d.cidioma = p_cidioma
      AND d.tatribu = p_tatribu;
EXCEPTION WHEN no_data_found THEN
   --
   l_catribu := NULL;
   --
   END;
   p_control_error('JRVG','f_catribu l_catribu2 ',l_catribu);
   RETURN l_catribu;
   --
END f_catribu;
--
/*************************************************************************
 NOMBRE              : f_sseguro_coretaje
 Funcion que obtine el catribu de la tabla detvalores para los nuevos
 ttippag creados.
*************************************************************************/
FUNCTION f_sseguro_coretaje(p_nrecibo IN recibos.nrecibo%TYPE)
RETURN NUMBER AS
   --
   l_sseguro recibos.sseguro%TYPE;
   --
BEGIN
   --
   BEGIN
   SELECT DISTINCT ac.sseguro
     INTO l_sseguro
     FROM recibos r,age_corretaje ac
    WHERE ac.sseguro = r.sseguro
      AND ac.nmovimi = r.nmovimi
      AND r.nrecibo  = p_nrecibo;
   --
        EXCEPTION WHEN no_data_found THEN
   --
      l_sseguro := 0;
   --
   END;
   RETURN l_sseguro;
   --
END f_sseguro_coretaje;
-- Version 3.0

--CONF-403
/*************************************************************************
 NOMBRE              : f_coa_por_garant
 Funcion que obtiene el valor proporcional por garant¨ªa para cada importe del coaseguro.
*************************************************************************/
FUNCTION f_coa_por_garant(
                    p_nrecibo IN recibos.nrecibo%TYPE,
                    p_cgarant  IN NUMBER,
                    p_import   IN NUMBER)
RETURN NUMBER IS
      v_object           VARCHAR2(500) := 'pac_contan_conf.f_coa_por_garant';
      v_param           VARCHAR2(500)
         := 'params : p_nrecibo : ' || p_nrecibo || ', p_cgarant : ' || p_cgarant
            || ', p_import : ' || p_import;
      v_pasexec        NUMBER := 0;
      ximptot            NUMBER := 0;
      ximpgar           NUMBER := 0;
      xpor                NUMBER := 0;
      ximpcoagar      NUMBER := 0;

BEGIN

    SELECT SUM(dr.iconcep_monpol)
        INTO ximptot
      FROM detrecibos dr
    WHERE dr.nrecibo = p_nrecibo
         AND dr.cconcep = 0
         AND dr.nmovima = (SELECT MAX(dr2.nmovima)
                                          FROM detrecibos dr2
                                        WHERE dr2.nrecibo = dr.nrecibo);

    v_pasexec:=1;

    SELECT dr.iconcep_monpol
        INTO ximpgar
      FROM detrecibos dr
    WHERE dr.nrecibo = p_nrecibo
         AND dr.cgarant = p_cgarant
         AND dr.cconcep = 0;

    v_pasexec:=2;

    IF ximpgar <> 0 THEN
        IF ximptot <> 0 THEN
            xpor := ximpgar / ximptot;
        ELSE
            xpor := 0;
        END IF;
        IF xpor <> 0 THEN
            ximpcoagar := p_import * xpor;
        ELSE
            ximpcoagar := 0;
        END IF;
    ELSE
        ximpcoagar := 0;
    END IF;

    RETURN ximpcoagar;

EXCEPTION
  WHEN OTHERS THEN
     p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
     RETURN 0;
END f_coa_por_garant;

/*************************************************************************
 NOMBRE              : f_comision_por_coa
 Funcion que obtiene el valor proporcional de la comisi¨®n para un agente, corredor, etc., en relaci¨®n al coaseguro.
*************************************************************************/
FUNCTION f_comision_por_coa(
                    p_sseguro IN NUMBER,
                    p_ccompani IN NUMBER,
                    p_iimport  IN NUMBER)
RETURN NUMBER IS
      v_object           VARCHAR2(500) := 'pac_contan_conf.f_coa_por_garant';
      v_param           VARCHAR2(500)
         := 'params : p_sseguro : ' || p_sseguro || ', p_ccompani : ' || p_ccompani
            || ', p_iimport : ' || p_iimport;
      v_pasexec        NUMBER := 0;
      xpcescoa         NUMBER := 0;
      xpcesion          NUMBER := 0;
      xempresa         NUMBER := 24;
      xresultado        NUMBER := 0;

      CURSOR coacedido_cur(wsseguro IN NUMBER, wccompani IN NUMBER) IS
                SELECT pcescoa, pcesion
                  FROM coacedido
                WHERE sseguro = wsseguro
                    AND ccompan = wccompani
                    AND ncuacoa = (SELECT MAX(ncuacoa)
                                                FROM coacedido
                                              WHERE sseguro = wsseguro
                                                   AND ccompan = wccompani);

BEGIN

    v_pasexec:=1;
                FOR cc IN coacedido_cur(p_sseguro, p_ccompani) LOOP

                    xpcescoa := cc.pcescoa;
                    xpcesion := cc.pcesion;

                    xresultado := (p_iimport*(xpcescoa/100))*(xpcesion/100);

                END LOOP;

                IF xresultado = 0 THEN
                    xresultado := p_iimport;
                END IF;

    v_pasexec:=3;

    RETURN xresultado;

EXCEPTION
  WHEN OTHERS THEN
     p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
     RETURN 0;
END f_comision_por_coa;

-- Ini IAXIS- 3592 -- ECP -- 23/05/2019
/*************************************************************************
 NOMBRE              :  f_valor_cancel
 Funcion que obtiene el valor cancelado
*************************************************************************/
FUNCTION f_valor_cancel(p_nrecibo IN recibos.nrecibo%TYPE,p_cconcep IN detmovrecibo_parcial.cconcep%type)
RETURN NUMBER AS
   --
   v_importe NUMBER;
   --
BEGIN
   --
   BEGIN
   SELECT sum(iconcep_monpol)
     INTO v_importe
     FROM detmovrecibo_parcial 
    WHERE nrecibo  = p_nrecibo
      and cconcep  = p_cconcep;
   --
        EXCEPTION WHEN no_data_found THEN
   --
      v_importe := 0;
   --
   END;
   RETURN v_importe;
   --
END f_valor_cancel;
-- Fin IAXIS- 3592 -- ECP -- 23/05/2019
END PAC_CONTAB_CONF;

/