--------------------------------------------------------
--  DDL for Package Body PK_PROVMATEMATICAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_PROVMATEMATICAS" IS
-- ¡¡¡¡OJO!!!! este package está obsoleto
-- No se elimina pues sino descompila otros package
-- Se comenta el código obsoleto para que pueda compilar y no deje invalidos otros objetos
   FUNCTION f_provmat(
      pssesion IN NUMBER,   -- NO SERVEIX PER RES
      psseguro IN NUMBER,   -- NUM. DE SEGURO
      pfecha IN DATE,
      -- DATA DE CALCUL DE LA PROVISIÓ MATEMATICA
      ppenalitzacio IN NUMBER,
           -- 1 --> PROVISIÓ MATEMÀTICA.
           -- 0 --> PROVISIÓ MATEMATICA - PENALITZACIÓ.
       -- 2 --> PENALITZACIO PER TOTS EL PRODUCTES MENYS RVI,PER RVI SERÀ EL RESCAT DEL RVI.
         -- 4 --> PPP, PIP, PJP) Import Brut de la Renda.
         -- 3 --> COMISSIÓ RVI PER GASTOS EXT EXT.
       -- 5 --> COMISSIÓ RVI PER GASTOS EXT INT.
      -- 6 --> COMISSIÓ RVI PER GASTOS INT.
      -- 8 --> Calcula PM.,
           --> COM. GTOS. EXT EXT.,
          --> COM. GTOS. EXT INT.,
          --> COM. GTOS. INT.
      pimportrescat IN NUMBER DEFAULT 0
                         -- Import del Rescat per tots els productes d'estalvi
/*****************************************************************************/
/*******       DADES DE SORTIDA                              *******/
/* PROVISIÓ MATEMATICA(1) -->  -2 Error, la data de calcul és més petita que
/*                           la data d' efecte
/*                      -1 Error, la data de calcul és més gran que
/*                           la data de venciment de la pòlissa.
/*                      -3 Error, Algun dada ne es trova.
/*
/* PROVISIÓ MATEMATICA    -->  -8 Error, Dades no trobades
/* MENYS PENALITZACIÓ (0)
/*
/* PENALITZACIÓ (2)       -->  -8 Error, No hi ha cap rescat
/*
/**********                                                 ********/
/*****************************************************************************/
   )
      RETURN NUMBER IS   -- PRAGMA AUTONOMOUS_TRANSACTION;
      -- CURSOR QUE AGAFA TOTES LES DADES DE LA POLISSA.
      CURSOR c_polizas_provmat IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, NVL(s.fcaranu, s.fvencim) ffinal,
                s.fefecto, s.ncertif, s.nduraci nduraci, p.pinttec, p.sproduc, p.pgasint,
                p.pgasext, s.cactivi, s.cforpag, s.fvencim, p.pgaexin, p.pgaexex, p.cdivisa
           FROM productos p, seguros s
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect;

      vactividad     NUMBER;   -- Activitat de la garantia
      vmoviment      NUMBER;   -- Moviment
      vcontador      NUMBER;
      vprov1         NUMBER;   -- Provisió matemàtica 1 per fer la interpolació
      vprov1_aux     NUMBER;
      vprov1_aux1    NUMBER;
      vprov2         NUMBER;   -- Provisió matemàtica 2 per fer la interpolació
      cieprovmat2    NUMBER;   -- Provisió matemàtica 2 per fer la interpolació Cierre RVI
      -- VARIABLES PER EL CALCUL DE DATES.
      vdata          DATE;   -- Data on es calcula la primera provmat.
      vdata_segon    DATE;   -- Data on es calcula la segona provmat.
      vdata_segon1   DATE;   -- Data on es calcula la segona provmat.
      vdata_segon2   DATE;   -- Data on es calcula la segona provmat.
      vdia_efec      VARCHAR2(2);
      vdia           VARCHAR2(2);
      vmes_efec      NUMBER;
      vanyo_efec     NUMBER;
      vanyo_venci    NUMBER;
      vmes           VARCHAR2(6);
      vmes1          VARCHAR2(6);
      vmes2          VARCHAR2(2);
      vanyo          VARCHAR2(6);
      vanyo1         VARCHAR2(6);
      vanyo2         VARCHAR2(6);
      vdia_efec1     VARCHAR2(6);
      -- DADES DE LA POLISSA
      vfinici        DATE;   -- DATA EFECTE PÒLISSA
      vfvencim       DATE;   -- DATA VENCIMENT DE LA PÒLISSA
      vnduraci       NUMBER;   -- DURACIÓ EN MESOS DE LA POLISSA
      vd1            NUMBER;   -- DIFERÈNCIA DE DIES ENTRE LA DATA DE CALCUL I EL MES ANTERIOR
      vd2            NUMBER;   -- DIFERÈNCIA DE DIES ENTRE LA DATA POSTERIOR I LA DATA ANTERIOR
      vdd1           NUMBER;
      vdd2           NUMBER;
      vpinttec1      NUMBER;   -- INTERES TÉCNIC A NIVELL DE PRODUCTE
      vpinttecc1     NUMBER;
      vpinttecc2     NUMBER;
      xgasto         NUMBER;   -- Cierre RVI Gastos
      vpinttec11     NUMBER;   -- INTERES TÉCNIC
      vpinttec2      NUMBER;
      vgasint        NUMBER;   -- PORCENTATGE DE GASTOS INT
      vgasext        NUMBER;   -- PORCENTATGE DE GASTOS EXT
      vgasext1       NUMBER;   -- PORCENTATGE DE GASTOS EXT EXT
      vsproduc       NUMBER;   -- SPRODUC
      vfecha29       DATE;   -- FECHA A PARTIR DE LA QUAL S'APLICA UN ALTRE INTERES
      vipcmort       NUMBER;   -- PRESTACIONES CIERTAS EN TANTO MUERTE
      vipcmort1      NUMBER;
      vtpxi          NUMBER;   -- TPX
      vtpxi1         NUMBER;
      vprima_riesgo  NUMBER;   -- VALOR DE LA PRIMA RIESGO
      vnum_err       NUMBER;
      vtipo          NUMBER;   -- CODIGO DEL TIPO DE PRODUCTO
      vicompra       NUMBER;   -- Preu de compra (Comissions per el producte RVI)
      viventa        NUMBER;   -- Preu de venta  (Comissions per el producte RVI)
      vnpoliza       NUMBER;   -- NÚMERO DE POLIZA ANTIGUA
      it1p           seguros_aho.pinttec%TYPE;   --Interès tècnic primer periode
--  FEIMTEC             SEGUROS_AHO.FEIMTEC%TYPE;    --Data de finalització del primer periode (PIG)
      penalitzacio   BOOLEAN;   --Per saber si hi ha penalitzacio
      penalitzacio_anys NUMBER;   --Anys amb penalitzacio
      penalitzacio_premi BOOLEAN;   --PIP amb premi
      penalitzacio_pta NUMBER;
      penalitzacio_perc detprodtraresc.ppenali%TYPE;   --Percentatge de penalitzacio
      penalitzacio_tipus NUMBER;   --PEr saber si la penalitzacio esta indicada com a import o com a percentatge
      anys_sense_penalitzacio NUMBER;
      penalitzacio_f NUMBER;   --Pot ser l'import de la penalitzacio o el percentatge
      rescat_total   BOOLEAN;   -- Si cert és recat total, sinó és rescat parcial
      import_brut_rescat NUMBER;
      n_rescats_parcials_anteriors NUMBER;
      pm_diaabans    NUMBER;
      k_euros_pta    NUMBER := 166.386;
      fecha_efecto   DATE;
      sproduc        NUMBER;
      primaspagadas  NUMBER;
      primasconsumidas NUMBER;
      vindice        NUMBER;
      p_cdivisa      NUMBER;
      xagru          NUMBER;
      xdia           NUMBER;

      FUNCTION troba_penalitzacio(
         codi_rescat IN NUMBER,
         anys IN NUMBER,
         p_sproduc IN parproductos.sproduc%TYPE,
         penalitzacio_tipus OUT NUMBER,
         p_f1perio IN DATE)
         RETURN NUMBER IS
         p_ipenali      detprodtraresc.ipenali%TYPE;
         p_ppenali      detprodtraresc.ppenali%TYPE;
         p_clave        detprodtraresc.clave%TYPE;
         p_valor        NUMBER;
         xformula       VARCHAR2(100);
         xxsesion       NUMBER;
         num_err        NUMBER;
      BEGIN
         SELECT d.ipenali, d.ppenali, d.clave
           INTO p_ipenali, p_ppenali, p_clave
           FROM detprodtraresc d, prodtraresc p
          WHERE d.sidresc = p.sidresc
            AND p.sproduc = p_sproduc
            AND p.ctipmov = codi_rescat
            AND d.niniran = (SELECT MIN(dp.niniran)
                               FROM detprodtraresc dp
                              WHERE dp.sidresc = d.sidresc
                                AND anys BETWEEN dp.niniran AND dp.nfinran);

         --Miro si la penalitzacio es una formula
         IF p_clave IS NOT NULL THEN
            penalitzacio_tipus := 2;   --Percentatge

            SELECT sgt_sesiones.NEXTVAL
              INTO xxsesion
              FROM DUAL;

            IF xxsesion IS NULL THEN
               ROLLBACK;
               RETURN -31;
            ELSE
                 -- I- JLB - OPTIMI
               --  INSERT INTO sgt_parms_transitorios
                --             (sesion, parametro, valor)
                --      VALUES (xxsesion, 'SESION', xxsesion);
               num_err := pac_sgt.put(xxsesion, 'SESION', xxsesion);
               -- INSERT INTO sgt_parms_transitorios
                --            (sesion, parametro, valor)
                --     VALUES (xxsesion, 'SSEGURO', psseguro);
               num_err := pac_sgt.put(xxsesion, 'SSEGURO', psseguro);
               -- INSERT INTO sgt_parms_transitorios
               --             (sesion, parametro, valor)
                --     VALUES (xxsesion, 'F1PERIO', TO_CHAR(p_f1perio, 'YYYYMMDD'));
               num_err := pac_sgt.put(xxsesion, 'F1PERIO', TO_CHAR(p_f1perio, 'YYYYMMDD'));
               --INSERT INTO sgt_parms_transitorios
               --            (sesion, parametro, valor)
               --     VALUES (xxsesion, 'FECMOV', TO_CHAR(pfecha, 'YYYYMMDD'));
               num_err := pac_sgt.put(xxsesion, 'FECMOV', TO_CHAR(pfecha, 'YYYYMMDD'));
            -- F - JLB - OPTIMI
            END IF;

            BEGIN
               SELECT formula
                 INTO xformula
                 FROM sgt_formulas
                WHERE clave = p_clave;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN -32;
               WHEN OTHERS THEN
                  RETURN -33;
            END;

            p_valor := pk_formulas.eval(xformula, xxsesion);

            IF p_valor IS NULL THEN
               RETURN -34;
            ELSE
               RETURN(p_valor);
            END IF;
         ELSIF p_ppenali IS NOT NULL THEN
            penalitzacio_tipus := 2;   --Percentatge
            RETURN(p_ppenali);   --PErcentatge de la penalitzacio
         ELSIF p_ipenali IS NOT NULL THEN
            penalitzacio_tipus := 1;   --Import
            RETURN(p_ipenali);   --Import de la penalitzacio
         ELSE
            RETURN(-33);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(-33);
      END troba_penalitzacio;

      FUNCTION calculaprimaspagadas
         RETURN NUMBER IS
      BEGIN
         SELECT SUM(NVL(imovimi, 0))
           INTO primaspagadas
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND(cmovimi = 1
                OR cmovimi = 2
                OR cmovimi = 4)   --1,2,4 APORTACIONS
            AND fvalmov <=(f_sysdate - 1);

         RETURN(primaspagadas);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(-39);
      END;

      FUNCTION calculaprimasconsumidas
         RETURN NUMBER IS
      BEGIN
         SELECT SUM(NVL(ipricons, 0))
           INTO primasconsumidas
           FROM primas_consumidas
          WHERE sseguro = psseguro;

         RETURN(primasconsumidas);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(-40);
      END;
--
--
--
--
   BEGIN
      vnum_err := 0;

      DELETE FROM matrizprovmatgen
            WHERE cindice > -1;

      SELECT s.fefecto, s.fvencim, s.nduraci, p.pinttec, p.pgasint, p.pgasext, p.sproduc
        INTO vfinici, vfvencim, vnduraci, vpinttec1, vgasint, vgasext, vsproduc
        FROM productos p, seguros s
       WHERE s.sseguro = psseguro
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND s.csituac <> 4
         AND s.fefecto <= pfecha;

      SELECT cvalpar
        INTO vtipo
        FROM parproductos
       WHERE sproduc = vsproduc
         AND cparpro = 'DESPRODPROVMAT';

--------------------------------------------------------
-- Si la data de venciment no està informada la calculem
--------------------------------------------------------
      IF (vfvencim IS NULL) THEN
         IF (vnduraci IS NOT NULL) THEN
            vfvencim := ADD_MONTHS(vfinici,(vnduraci * 12));
         ELSE   -- Aquest cas es dona quan és una renta vitalicia, ja que no té duració ni data fi
            vnduraci := 1560;
            vfvencim := ADD_MONTHS(vfinici,(vnduraci * 12));
         END IF;
      END IF;

---------------------------------------------------------------------------------------------
-- Si la data de càlcul és més petita que la data de venciment
-- o més gran que la data d'inici
---------------------------------------------------------------------------------------------
      IF (TO_CHAR(pfecha, 'YYYYMMDD') <= TO_CHAR(vfvencim, 'YYYYMMDD')
          AND TO_CHAR(vfinici, 'YYYYMMDD') <= TO_CHAR(pfecha, 'YYYYMMDD')) THEN
         IF (vnum_err = 0) THEN
            BEGIN
               xdia := ROUND(MONTHS_BETWEEN(pfecha, vfinici), 0);
               vdata := ADD_MONTHS(vfinici, xdia);

--
               IF vdata > pfecha THEN
                  vdata := ADD_MONTHS(vdata, -1);
--
                  vdia_efec := TO_CHAR(vfinici, 'DD');
                  vdia := TO_CHAR(vdata, 'DD');

                  IF vdia > vdia_efec THEN
                     xdia := vdia - vdia_efec;
                     vdata := vdata - xdia;
                  END IF;
               END IF;

--
               vdata_segon := ADD_MONTHS(vdata, 1);
               vdia_efec := TO_CHAR(vfinici, 'DD');
               vdia := TO_CHAR(vdata_segon, 'DD');

               IF vdia > vdia_efec THEN
                  xdia := vdia - vdia_efec;
                  vdata_segon := vdata_segon - xdia;
               END IF;

               IF vdata < vfinici THEN
                  vdata := vfinici;
               END IF;

               IF vdata_segon > vfvencim THEN
                  vdata_segon := vfvencim;
               END IF;

               vd1 := pfecha - vdata;
               vd2 := vdata_segon - vdata;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN(-10);
            END;

---------------------------------------------------------
-- CALCULEM LA PROVISIÓ MATEMÀTICA  I IMPORT DE LA RENTA
---------------------------------------------------------
            IF (ppenalitzacio = 1
                OR ppenalitzacio = 4) THEN
  ----------------------------
--  CV5,  CV10,    PFV
  ----------------------------
               IF (vtipo = 1
                   OR vtipo = 2
                   OR vtipo = 3) THEN
                  vnum_err := 0;

                  IF (vnum_err = 0) THEN
                     -- Carreguem la taula matrizprovmatgen amb les dades per poder calcular la provisió matemàtica amb la data calculada.
                     vnum_err := pk_provmatematicas.f_matriz_provmat(psseguro, vdata, 0, 0);

                     BEGIN
                        SELECT NVL(SUM(ippvid), 0) + NVL(SUM(ippmort), 0)
                               + NVL(SUM(ipgascapv), 0)
                          INTO vprov1
                          FROM matrizprovmatgen
                         WHERE cindice > -1;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vnum_err := -1;
                     END;

                     IF (vnum_err = -1) THEN
                        vprov1 := 0;
                     END IF;
                  END IF;

                  -- Esborrem les dades de la taula matrizprovmatgen per poder fer el segon calcul
                  DELETE FROM matrizprovmatgen
                        WHERE cindice > -1;

                  IF (vnum_err = 0) THEN
                     -- Fem el segon calcul per la segona data ....
                     vnum_err := pk_provmatematicas.f_matriz_provmat(psseguro, vdata_segon, 0,
                                                                     0);
                     vprov2 := 0;

                     BEGIN
                        SELECT NVL(SUM(ippvid), 0) + NVL(SUM(ippmort), 0)
                               + NVL(SUM(ipgascapv), 0)
                          INTO vprov2
                          FROM matrizprovmatgen
                         WHERE cindice > -1;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vnum_err := -1;
                     END;

                     IF (vnum_err = -1) THEN
                        vprov2 := 0;
                     END IF;
                  END IF;

                  vprov1 := (vprov1 *((vd2 -(vd1 + 1)) / vd2)) +(vprov2 *((vd1 + 1) / vd2));
       -------------
         --  RVI
       -------------
/*
       ELSIF( vtipo = 4 )THEN

            -- Esborrem les dades de la taula matrizprovmatgen per poder fer el calcul
               DELETE FROM MATRIZPROVMATGEN WHERE CINDICE > -1;
             BEGIN
            -- L'interes tècnic para el segundo periodo
            SELECT NVL(pinttec,0),feimtec
              INTO vpinttec2, vfecha29
            FROM SEGUROS_AHO
            WHERE sseguro = psseguro;
            -- Fem el calcul per el producte RVI aplicant la formula Provisió matemàtica en al data de calcul amb un interes net de gastos.
            vnum_err := -1;


            vnum_err := Pk_Provmatematicas.f_matriz_provmat(psseguro,vdata,0,0);

            SELECT NVL(SUM(IPPMORT),0)+ NVL(SUM(IPPVID),0)
              INTO vPROV1
            FROM MATRIZPROVMATGEN WHERE CINDICE > -1;
            vindice := ((TO_NUMBER(TO_CHAR(pfecha,'yyyy'))*12)+TO_NUMBER((TO_CHAR(pfecha,'MM'))))-((TO_NUMBER(TO_CHAR(vFINICI,'yyyy'))*12)+TO_NUMBER((TO_CHAR(vFINICI,'MM'))));
            SELECT tpxi, ipcmort
              INTO vTPXI, vIPCMORT
            FROM MATRIZPROVMATGEN
            WHERE cindice = vindice;
          EXCEPTION  WHEN OTHERS THEN
            vnum_err := -13501;
          END;
          IF( vFECHA29 < pfecha ) THEN  -- APLIQUEM EL PRIMER INTERES
               vpinttec1 := ((1+(vpinttec1/100))*(1-((vgasint/100)+(vgasext/100)))) -1;
               vpinttec11 := POWER(((1+ (vpinttec1/100))*( 1-(vgasint/100) - (vgasext/100))),(1/12) ) - 1;
          ELSE -- APLIQUEM EL SEGON INTERES
            vpinttec1 := ((1+(vpinttec2/100))*(1-((vgasint/100)+(vgasext/100))))-1 ;
            vpinttec11 := POWER(((1+ (vpinttec2/100))*( 1-(vgasint/100) - (vgasext/100))),(1/12) ) - 1;
          END IF;

          BEGIN
            vdata_segon := TO_DATE( TO_CHAR(vdata_segon, 'dd')||'/'||TO_CHAR(ADD_MONTHS(pfecha, 1),'mm')||'/'||TO_CHAR(vdata_segon,'yyyy') , 'DD/MM/YYYY');
            vd1 := (pfecha - vdata );
            vd2 := (vdata_segon - vdata);
            vprima_riesgo := (1 - vtpxi)* ( POWER((1 + vpinttec11), -(1/2))     ) * vipcmort * ((vd1+1)/vd2);
            vprov1 := (vprov1 - vprima_riesgo)*(POWER(( vpinttec1+1 ),((vd1+1)/365)))*( 1/(1-( (vd1+1)/vd2 ) *(1- vtpxi) )    );
            EXCEPTION WHEN OTHERS THEN
            VPROV1 := -104;
          END ;
*/
      ---------------
       --    ASSP
      ---------------
               ELSIF(vtipo = 5) THEN
                  -- Esborrem les dades de la taula matrizprovmatgen per poder fer el calcul
                  DELETE FROM matrizprovmatgen
                        WHERE cindice > -1;

                  IF (vnum_err = 0) THEN
                     -- Carreguem la taula matrizprovmatgen amb les dades per poder calcular la provisió matemàtica amb la data calculada.
                     vnum_err := pk_provmatematicas.f_matriz_provmat(psseguro, vdata, 0, 0);

                     BEGIN
                        SELECT SUM(ipgascapv) + SUM(ippmort) + NVL(SUM(ippvid), 0)
                               + NVL(SUM(pinv), 0)
                          INTO vprov1
                          FROM matrizprovmatgen
                         WHERE cindice > -1;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vnum_err := -108;
                     END;

                     IF (vnum_err = -108) THEN
                        vprov1 := 0;
                     END IF;
                  END IF;

                  -- Esborrem les dades de la taula matrizprovmatgen per poder fer el segon calcul
                  DELETE FROM matrizprovmatgen
                        WHERE cindice > -1;

                  IF (vnum_err = 0) THEN
                     -- Fem el segon calcul per la segona data ....
                     vnum_err := pk_provmatematicas.f_matriz_provmat(psseguro, vdata_segon, 0,
                                                                     0);
                     vprov2 := 0;

                     BEGIN
                        SELECT SUM(ipgascapv) + SUM(ippmort) + NVL(SUM(ippvid), 0)
                               + NVL(SUM(pinv), 0)
                          INTO vprov2
                          FROM matrizprovmatgen
                         WHERE cindice > -1;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vnum_err := -109;
                     END;

                     IF (vnum_err = -109) THEN
                        vprov2 := 0;
                     END IF;
                  END IF;

                  vprov1 := (vprov1 *((vd2 - vd1) / vd2)) +(vprov2 *(vd1 / vd2));
               --------------------------------------------------------------------------
--      PRODUCTOS AHORRO:: ( També calculem l'import brut de la renda )
--------------------------------------------------------------------------
               ELSIF(vtipo = 6
                     OR vtipo = 7
                     OR vtipo = 8
                     OR vtipo = 9
                     OR vtipo = 10
                     OR vtipo = 11) THEN
                  -- Seleccionem la data a partir de la qual s'ha de calcular com si fòs un RVI
                  BEGIN
                     vfecha29 := vfinici;

                     SELECT f1paren, ibruren
                       INTO vfinici, vprov1_aux
                       FROM seguros_ren
                      WHERE sseguro = psseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        vprov1_aux := 0;
                  END;

---------------------------------------
 -- Calculem l'import brut de la renda
  ---------------------------------------
                  IF (ppenalitzacio = 4
                      AND TO_CHAR(pfecha, 'yyyymmdd') >= TO_CHAR(vfinici, 'yyyymmdd')) THEN
                     IF (vprov1_aux = 0) THEN
                        -- la prima unica serà la provisió matematica un dia abans de la data.
                        vfinici := pfecha - 1;
                        vprov1_aux := pk_provmatematicas.f_provmat(1, psseguro, vfinici, 1);
                     END IF;

                     vprov1 := pk_provmatematicas.f_matriz_provmat(psseguro, pfecha, 2,
                                                                   vprov1_aux);
                  ELSIF (vtipo = 9
                         OR vtipo = 10
                         OR vtipo = 8)
                        AND(ppenalitzacio = 1)
                        AND(TO_CHAR(pfecha, 'YYYYMMDD') > TO_CHAR(vfinici, 'YYYYMMDD')) THEN
                     BEGIN
                        vdia_efec := TO_CHAR(vfinici, 'DD');
                        vdia := TO_CHAR(pfecha, 'DD');

                        IF (vdia_efec > vdia) THEN
                           IF vdia_efec IN('29', '30', '31')
                              AND TO_CHAR(pfecha, 'MM') = '02' THEN
                              vdata := LAST_DAY(pfecha);
                              vdata_segon := TO_DATE(vdia_efec || '/'
                                                     || TO_CHAR(ADD_MONTHS(pfecha, 1),
                                                                'MM/YYYY'),
                                                     'DD/MM/YYYY');
                           ELSE
                              IF vdia_efec IN('31', '30') THEN
                                 vdata := LAST_DAY(ADD_MONTHS(pfecha, -1));
                                 vdata_segon := LAST_DAY(pfecha);
                              ELSE
                                 vdata := TO_DATE(vdia_efec || '/'
                                                  || TO_CHAR(ADD_MONTHS(pfecha, -1),
                                                             'MM/YYYY'),
                                                  'DD/MM/YYYY');
                                 vdata_segon := TO_DATE(vdia_efec || '/'
                                                        || TO_CHAR(pfecha, 'MM/YYYY'),
                                                        'DD/MM/YYYY');
                              END IF;
                           END IF;
                        ELSIF(vdia_efec < vdia) THEN
                           IF vdia_efec IN('29', '31', '30')
                              AND TO_CHAR(pfecha, 'MM') = '01' THEN
                              vdata := LAST_DAY(pfecha);
                              vdata_segon := TO_DATE('28/02/' || TO_CHAR(pfecha, 'YYYY'),
                                                     'DD/MM/YYYY');
                           ELSE
                              IF vdia_efec IN('31', '30') THEN
                                 vdata := LAST_DAY(pfecha);
                                 vdata_segon := LAST_DAY(ADD_MONTHS(pfecha, 1));
                              ELSE
                                 vdata := TO_DATE(vdia_efec || '/'
                                                  || TO_CHAR(pfecha, 'MM/YYYY'),
                                                  'DD/MM/YYYY');
                                 vdata_segon := TO_DATE(TO_CHAR(vfinici, 'DD') || '/'
                                                        || TO_CHAR(ADD_MONTHS(pfecha, 1),
                                                                   'MM/YYYY'),
                                                        'DD/MM/YYYY');
                              END IF;
                           END IF;
                        ELSIF vdia_efec = vdia THEN
                           IF TO_CHAR(pfecha, 'YYYYMMDD') = TO_CHAR(vfinici, 'YYYYMMDD') THEN
                              vdata := vfinici;
                              vdata_segon := ADD_MONTHS(pfecha, 1);
                           ELSE
                              vdata := ADD_MONTHS(pfecha, -1);
                              vdata_segon := ADD_MONTHS(pfecha, 1);
                           END IF;
                        END IF;

                        IF vdata < vfinici THEN
                           vdata := vfinici;
                        END IF;

                        IF vdata_segon > vfvencim THEN
                           vdata_segon := vfvencim;
                        END IF;

                        vd1 := pfecha - vdata;
                        vd2 := vdata_segon - vdata;

                        IF (TO_CHAR(pfecha, 'YYYYMMDD') = TO_CHAR(vfinici, 'YYYYMMDD'))
                           OR(TO_CHAR(pfecha, 'YYYYMMDD') = TO_CHAR(vfvencim, 'YYYYMMDD')) THEN
                           vdata := vfinici;
                           vdata_segon := vfinici;
                           vd1 := 0;
                           vd2 := 1;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-10);
                     END;

                     IF (vprov1_aux = 0
                         OR vprov1_aux IS NULL)
                        AND(TO_CHAR(pfecha, 'yyyymmdd') > TO_CHAR(vfinici, 'yyyymmdd')) THEN
                        -- la prima unica serà la provisió matematica un dia abans de la data.
                        vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vfinici - 1, 1);
                     ELSE
                        IF (vprov1_aux = 0) THEN
                           -- la prima unica serà la provisió matematica un dia abans de la data.
                           vfinici := pfecha - 1;
                           vprov1_aux := pk_provmatematicas.f_provmat(1, psseguro, vfinici, 1);
                        END IF;

                        --
                        -- Calculem la provisió matematica.
                        IF (TO_CHAR(vdata, 'yyyymmd') <= TO_CHAR(vfinici, 'yyyymmd')) THEN
                           vprov1 := pk_provmatematicas.f_matriz_provmat(psseguro, vdata - 1,
                                                                         1, vprov1_aux);
                        ELSE
                           vprov1 := pk_provmatematicas.f_matriz_provmat(psseguro, vdata, 0,
                                                                         vprov1_aux);
                        END IF;

                        vprov2 := pk_provmatematicas.f_matriz_provmat(psseguro, vdata_segon, 0,
                                                                      vprov1_aux);
                        vprov1 := (vprov1 *((vd2 - vd1) / vd2))
                                  +((vd1 / vd2) *(vprov2 + vprov1_aux));
                     END IF;
                  ELSE
                     vprov1 := pk_provmatematicas.f_matriz_provmat(psseguro, pfecha, 1, 0);
                  END IF;
               END IF;
---------------------------------------------------
--    PROVISIÓ MATEMÀTICA MENYS PENALITZACIÓ
---------------------------------------------------
            ELSIF(ppenalitzacio = 0) THEN
               FOR reg IN c_polizas_provmat LOOP
                  vnum_err := 0;

                  IF reg.cactivi <> 0 THEN   -- Averiguamos que actividad de garanpro es la que hay que coger
                     BEGIN
                        SELECT COUNT(*)
                          INTO vcontador
                          FROM garanpro
                         WHERE cramo = reg.cramo
                           AND cmodali = reg.cmodali
                           AND ctipseg = reg.ctipseg
                           AND ccolect = reg.ccolect
                           AND cactivi = reg.cactivi;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vcontador := 0;
                     END;

                     IF vcontador <> 0 THEN
                        vactividad := reg.cactivi;
                     ELSE
                        vactividad := 0;
                     END IF;
                  ELSE
                     vactividad := 0;
                  END IF;

                  vnum_err := f_buscanmovimi(psseguro, 1, 1, vmoviment);

                  IF vnum_err != 0 THEN
                     RETURN -1;
                  END IF;

                  -- Prima unica -------
                  SELECT SUM(icapital), MIN(g.cgarant)
                    INTO vprima_riesgo, vtpxi
                    FROM garanpro gp, garanseg g
                   WHERE g.sseguro = psseguro
                     AND g.cgarant = gp.cgarant
                     AND gp.cramo = reg.cramo
                     AND gp.cmodali = reg.cmodali
                     AND gp.ctipseg = reg.ctipseg
                     AND gp.ccolect = reg.ccolect
                     AND gp.cactivi = reg.cactivi
                     AND g.nmovimi = vmoviment
                     AND g.cgarant = (SELECT cgarant
                                        FROM pargaranpro
                                       WHERE cvalpar = 3
                                         AND cramo = reg.cramo
                                         AND cmodali = reg.cmodali
                                         AND ccolect = reg.ccolect
                                         AND ctipseg = reg.ctipseg
                                         AND cactivi = reg.cactivi
                                         AND cpargar = 'GARPROVMAT');   --282

                  -- Busquem el pordentatge de penalització com és rescat Total tenim només un
                  BEGIN
                     SELECT cvalpar
                       INTO vtipo
                       FROM parproductos
                      WHERE sproduc = reg.sproduc
                        AND cparpro = 'DESPRODPROVMAT';
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

-----------------------------------------------------------------
  --   CV5 O PFV:::       PROV - PENALITZACIÓ PER UN PRODUCTE
  -----------------------------------------------------------------
                  IF (vtipo = 1
                      OR vtipo = 3) THEN
                     BEGIN
                        SELECT d.ppenali
                          INTO vpinttec1
                          FROM detprodtraresc d, prodtraresc p
                         WHERE d.sidresc = p.sidresc
                           AND p.sproduc = reg.sproduc;
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     IF (TO_CHAR(pfecha, 'YYYYMMDD') = TO_CHAR(vfvencim, 'YYYYMMDD')) THEN
                        --Calculem la provisió matemàtica  a la data de vencimen
                        vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vfvencim, 1);
                     ELSE
                        --Calculem el dia on s'ha de calcular la provisió matemàtica.(El dia anterior)
                        vdata := pfecha - 1;
                        --Calculem la provisió matemàtica en el dia d'abans del rescat.
                        vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vdata, 1);
                        vprov1 := vprov1 -(vprov1 *(vpinttec1 / 100));

                        IF (vprov1 <= vprima_riesgo) THEN
                           vprov1 := vprima_riesgo;
                        END IF;
                     END IF;
-----------------------------------------------------------------
--     CV10::  PROVISIÓ MENYS PENALITZACIÓ PER UN PRODUCTE
-----------------------------------------------------------------
                  ELSIF(vtipo = 2) THEN
                     -- vmes := to_char(pfecha,'yyyy'); -- Anyo de calculo
                     -- vanyo := to_char(reg.fefecto,'yyyy'); -- Anyo de efecto de la poliza
                     IF (TO_CHAR(pfecha, 'YYYYMMDD') = TO_CHAR(vfvencim, 'YYYYMMDD')) THEN
                        --Calculem la provisió matemàtica  a la data de venciment
                        vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vfvencim, 1);
                     ELSIF(TO_CHAR(reg.fefecto, 'yyyy') = TO_CHAR(pfecha, 'yyyy')) THEN   -- Estem en el primer any, li tornem la prima unica
                        BEGIN
                           SELECT d.ppenali
                             INTO vpinttec1
                             FROM detprodtraresc d, prodtraresc p
                            WHERE d.sidresc = p.sidresc
                              AND p.sproduc = reg.sproduc
                              AND d.niniran = 0
                              AND d.nfinran = 1;
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        vprov1 := vprima_riesgo;
                     ELSE
                        IF (TO_CHAR(TO_NUMBER(TO_CHAR(reg.fefecto, 'yyyy')) + 1) =
                                                                        TO_CHAR(pfecha, 'yyyy')) THEN   -- Estem en le segon any li tornem el 7%
                           BEGIN
                              SELECT d.ppenali
                                INTO vpinttec1
                                FROM detprodtraresc d, prodtraresc p
                               WHERE d.sidresc = p.sidresc
                                 AND p.sproduc = reg.sproduc
                                 AND d.niniran = 1
                                 AND d.nfinran = 2;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           --Calculem el dia on s'ha de calcular la provisió matemàtica.(El dia anterior)
                           vdata := pfecha - 1;
                           --Calculem la provisió matemàtica en el dia d'abans del rescat.
                           vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vdata, 1);
                           vprov1 := vprov1 -(vprov1 *(vpinttec1 / 100));

                           IF (vprov1 <= vprima_riesgo) THEN
                              vprov1 := vprima_riesgo;
                           END IF;
                        ELSE   -- tornem la provisió Matematica en el dia d'abans, ja no podem haver-hi rescats
                               --Calculem el dia on s'ha de calcular la provisió matemàtica.(El dia anterior)
                           vdata := pfecha - 1;
                           --Calculem la provisió matemàtica en el dia d'abans del rescat.
                           vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vdata, 1);
                           vprov1 := vprov1;
                        END IF;
                     END IF;
-----------------------------------------------------------------
  --     PIG::::   PROVISIÓ MATEMÀTICA MENYS PENALITZACIÓ: PIG: PLA D'INTERES GARANTIT
  -----------------------------------------------------------------
                  ELSIF(vtipo = 6) THEN
                     --Calculem l'import de la penalitzacio del dia d'abans
                     penalitzacio_pta := pk_provmatematicas.f_provmat(1, psseguro, pfecha, 2,
                                                                      pimportrescat);

                     IF penalitzacio_pta < 0 THEN
                        RETURN(-31);
                     END IF;

                     --Calculem la provisió matemàtica en el dia d'abans del rescat.
                     import_brut_rescat := pk_provmatematicas.f_matriz_provmat(psseguro,
                                                                               pfecha - 1, 1)
                                           - penalitzacio_pta;
                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);

                     --Calcula si abans de la data actual hi ha hagut rescats parcials
                     BEGIN
                        SELECT COUNT(*)
                          INTO n_rescats_parcials_anteriors
                          FROM ctaseguro
                         WHERE sseguro = psseguro
                           AND cmovimi = 33   --33 RESCAT PARCIAL
                           AND fvalmov >= reg.fefecto
                           AND fvalmov <= f_sysdate   --LES DATES ES CORRESPONEN AL MES
                           AND cmovanu != 1;   --EL MOVIMENT NO HA ESTAT ANULAT
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-32);
                     END;

                     --En cas de rescat total
                     IF rescat_total THEN
                        IF n_rescats_parcials_anteriors = 0 THEN
                           --Calculamos las primas pagadas hasta la fecha
                           primaspagadas := calculaprimaspagadas();

                           IF primaspagadas < 0 THEN
                              RETURN(-39);
                           END IF;

                           --Import_Brut_Rescat:= Min (  Import_Brut_Rescat, primas pagadas hasta fecha rescate
                           IF import_brut_rescat < primaspagadas THEN
                              import_brut_rescat := primaspagadas;
                           END IF;
                        END IF;
                     END IF;

                     --L'import brut del rescat  es retorna a la variable vprov1
                     vprov1 := import_brut_rescat;
-----------------------------------------------------------------
  --     PEG:::  PROVISIÓ MATEMÀTICA - PENALITZACIÓ: PEG: PLA D'ESTALVI GARANTIT
  -----------------------------------------------------------------
                  ELSIF(vtipo = 7) THEN
                     --Calculem l'import de la penalitzacio del dia d'abans
                     penalitzacio_pta := pk_provmatematicas.f_provmat(1, psseguro, pfecha, 2,
                                                                      pimportrescat);

                     IF penalitzacio_pta < 0 THEN
                        RETURN(-31);
                     END IF;

                     --Calculem la provisió matemàtica en el dia d'abans del rescat.
                     import_brut_rescat := pk_provmatematicas.f_matriz_provmat(psseguro,
                                                                               pfecha - 1, 1)
                                           - penalitzacio_pta;
                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);

                     --Calcula si abans de la data actual hi ha hagut rescats parcials
                     BEGIN
                        SELECT COUNT(*)
                          INTO n_rescats_parcials_anteriors
                          FROM ctaseguro
                         WHERE sseguro = psseguro
                           AND cmovimi = 33   --33 RESCAT PARCIAL
                           AND fvalmov >= reg.fefecto
                           AND fvalmov <= f_sysdate   --LES DATES ES CORRESPONEN AL MES
                           AND cmovanu != 1;   --EL MOVIMENT NO HA ESTAT ANULAT
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-32);
                     END;

                     --En cas de rescat total
                     IF rescat_total THEN
                        IF n_rescats_parcials_anteriors = 0 THEN
                           --Calculamos las primas pagadas hasta la fecha
                           primaspagadas := calculaprimaspagadas();

                           IF primaspagadas < 0 THEN
                              RETURN(-39);
                           END IF;

                           --Import_Brut_Rescat:= Min (  Import_Brut_Rescat, primas pagadas hasta fecha rescate
                           IF import_brut_rescat < primaspagadas THEN
                              import_brut_rescat := primaspagadas;
                           END IF;
                        END IF;
                     END IF;

                     --L'import brut del rescat  es retorna a la variable vprov1
                     vprov1 := import_brut_rescat;
-----------------------------------------------------------------
  --     PPP ::::: PROVISIÓ MATEMÀTICA - PENALITZACIÓ: PPP: PLA PERSONAL DE PREVISIÓ
  -----------------------------------------------------------------
                  ELSIF(vtipo = 8) THEN
                     --Calculem l'import de la penalitzacio del dia d'abans
                     penalitzacio_pta := pk_provmatematicas.f_provmat(1, psseguro, pfecha, 2,
                                                                      pimportrescat);

                     IF penalitzacio_pta < 0 THEN
                        RETURN(-31);
                     END IF;

                     --Calculem la provisió matemàtica en el dia d'abans del rescat.
                     import_brut_rescat := pk_provmatematicas.f_matriz_provmat(psseguro,
                                                                               pfecha - 1, 1)
                                           - penalitzacio_pta;
                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);

                     --Calcula si abans de la data actual hi ha hagut rescats parcials
                     BEGIN
                        SELECT COUNT(*)
                          INTO n_rescats_parcials_anteriors
                          FROM ctaseguro
                         WHERE sseguro = psseguro
                           AND cmovimi = 33   --33 RESCAT PARCIAL
                           AND fvalmov >= reg.fefecto
                           AND fvalmov <= f_sysdate   --LES DATES ES CORRESPONEN AL MES
                           AND cmovanu != 1;   --EL MOVIMENT NO HA ESTAT ANULAT
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-32);
                     END;

                     --En cas de rescat total
                     IF rescat_total THEN
                        IF n_rescats_parcials_anteriors = 0 THEN
                           --Calculamos las primas pagadas hasta la fecha
                           primaspagadas := calculaprimaspagadas();

                           IF primaspagadas < 0 THEN
                              RETURN(-39);
                           END IF;

                           --Import_Brut_Rescat:= Min (  Import_Brut_Rescat, primas pagadas hasta fecha rescate
                           IF import_brut_rescat < primaspagadas THEN
                              import_brut_rescat := primaspagadas;
                           END IF;
                        END IF;
                     END IF;

                     --L'import brut del rescat  es retorna a la variable vprov1
                     vprov1 := import_brut_rescat;
-----------------------------------------------------------------
  --   PIP ::
--   PROVISIÓ MATEMÀTICA - PENALITZACIÓ: PIP: PLA INFANTIL DE PREVISIÓ
  --   PROVISIÓ MATEMÀTICA -PENALITZACIÓ AMB PREMI
  -----------------------------------------------------------------
                  ELSIF(vtipo = 9) THEN
                     --Calculem l'import de la penalitzacio del dia d'abans
                     penalitzacio_pta := pk_provmatematicas.f_provmat(1, psseguro, pfecha, 2,
                                                                      pimportrescat);

                     IF penalitzacio_pta < 0 THEN
                        RETURN(-31);
                     END IF;

                     --Calculem la provisió matemàtica en el dia d'abans del rescat.
                     import_brut_rescat := pk_provmatematicas.f_matriz_provmat(psseguro,
                                                                               pfecha - 1, 1)
                                           - penalitzacio_pta;
                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);

                     --Calcula si abans de la data actual hi ha hagut rescats parcials
                     BEGIN
                        SELECT COUNT(*)
                          INTO n_rescats_parcials_anteriors
                          FROM ctaseguro
                         WHERE sseguro = psseguro
                           AND cmovimi = 33   --33 RESCAT TOTAL, 34 RESCAT PARCIAL
                           AND fvalmov >= reg.fefecto
                           AND fvalmov <= f_sysdate   --LES DATES ES CORRESPONEN AL MES
                           AND cmovanu != 1;   --EL MOVIMENT NO HA ESTAT ANULAT
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-32);
                     END;

                     --En cas de rescat total
                     IF rescat_total THEN
                        IF n_rescats_parcials_anteriors = 0 THEN
                           --Calculamos las primas pagadas hasta la fecha
                           primaspagadas := calculaprimaspagadas();

                           IF primaspagadas < 0 THEN
                              RETURN(-39);
                           END IF;

                           --Import_Brut_Rescat:= Min (   Import_Brut_Rescat, primas pagadas hasta fecha rescate
                           IF import_brut_rescat < primaspagadas THEN
                              import_brut_rescat := primaspagadas;
                           END IF;
                        END IF;
                     END IF;

                     --L'import brut del rescat  es retorna a la variable vprov1
                     vprov1 := import_brut_rescat;
-----------------------------------------------------------------
  --   PJP::::: PROVISIÓ MATEMÀTICA - PENALITZACIÓ:PJP: PLA JUVENIL DE PREVISIÓ
  -----------------------------------------------------------------
                  ELSIF(vtipo = 10) THEN
                     --Calculem l'import de la penalitzacio del dia d'abans
                     penalitzacio_pta := pk_provmatematicas.f_provmat(1, psseguro, pfecha, 2,
                                                                      pimportrescat);

                     IF penalitzacio_pta < 0 THEN
                        RETURN(-31);
                     END IF;

                     --Calculem la provisió matemàtica en el dia d'abans del rescat.
                     import_brut_rescat := pk_provmatematicas.f_matriz_provmat(psseguro,
                                                                               pfecha - 1, 1)
                                           - penalitzacio_pta;
                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);

                     --Calcula si abans de la data actual hi ha hagut rescats parcials
                     BEGIN
                        SELECT COUNT(*)
                          INTO n_rescats_parcials_anteriors
                          FROM ctaseguro
                         WHERE sseguro = psseguro
                           AND cmovimi = 33   --33 RESCAT TOTAL, 34 RESCAT PARCIAL
                           AND fvalmov >= reg.fefecto
                           AND fvalmov <= f_sysdate   --LES DATES ES CORRESPONEN AL MES
                           AND cmovanu != 1;   --EL MOVIMENT NO HA ESTAT ANULAT
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-32);
                     END;

                     --En cas de rescat total
                     IF rescat_total THEN
                        IF n_rescats_parcials_anteriors = 0 THEN
                           --Calculamos las primas pagadas hasta la fecha
                           primaspagadas := calculaprimaspagadas();

                           IF primaspagadas < 0 THEN
                              RETURN(-39);
                           END IF;

                           --Import_Brut_Rescat:= Min (  Import_Brut_Rescat, primas pagadas hasta fecha rescate
                           IF import_brut_rescat < primaspagadas THEN
                              import_brut_rescat := primaspagadas;
                           END IF;
                        END IF;
                     END IF;

                     --L'import brut del rescat  es retorna a la variable vprov1
                     vprov1 := import_brut_rescat;
-----------------------------------------------------------------
  --   PLA18 :::: PROVISIÓ MATEMÀTICA - PENALITZACIÓ:
  -----------------------------------------------------------------
                  ELSIF(vtipo = 11) THEN
                     --Calculem l'import de la penalitzacio del dia d'abans
                     penalitzacio_pta := pk_provmatematicas.f_provmat(1, psseguro, pfecha, 2,
                                                                      pimportrescat);

                     IF penalitzacio_pta < 0 THEN
                        RETURN(-31);
                     END IF;

                     --Calculem la provisió matemàtica en el dia d'abans del rescat.
                     import_brut_rescat := pk_provmatematicas.f_matriz_provmat(psseguro,
                                                                               pfecha - 1, 1)
                                           - penalitzacio_pta;
                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);

                     --Calcula si abans de la data actual hi ha hagut rescats parcials
                     BEGIN
                        SELECT COUNT(*)
                          INTO n_rescats_parcials_anteriors
                          FROM ctaseguro
                         WHERE sseguro = psseguro
                           AND cmovimi = 33   --33 RESCAT TOTAL, 34 RESCAT PARCIAL
                           AND fvalmov >= reg.fefecto
                           AND fvalmov <= f_sysdate   --LES DATES ES CORRESPONEN AL MES
                           AND cmovanu != 1;   --EL MOVIMENT NO HA ESTAT ANULAT
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-32);
                     END;

                     --En cas de rescat total
                     IF rescat_total THEN
                        IF n_rescats_parcials_anteriors = 0 THEN
                           --Calculamos las primas pagadas hasta la fecha
                           primaspagadas := calculaprimaspagadas();

                           IF primaspagadas < 0 THEN
                              RETURN(-39);
                           END IF;

                           --Import_Brut_Rescat:= Min (  Import_Brut_Rescat, primas pagadas hasta fecha rescate
                           IF import_brut_rescat < primaspagadas THEN
                              import_brut_rescat := primaspagadas;
                           END IF;
                        END IF;
                     END IF;

                     --L'import brut del rescat  es retorna a la variable vprov1
                     vprov1 := import_brut_rescat;
                  END IF;

                  IF (vprov1 IS NULL) THEN
                     vprov1 := -8;   --SIGNIFICA QUE NO HI HAGUT CAP RESCAT
                  END IF;
               END LOOP;
            /****************               PENALITZACIÓ               ********************/
            ELSIF(ppenalitzacio = 2) THEN   -- CACULEM LA PENALITZACIÓ
               FOR reg IN c_polizas_provmat LOOP
                  vnum_err := 0;

                  IF reg.cactivi <> 0 THEN   -- Averiguamos que actividad de garanpro es la que hay que coger
                     BEGIN
                        SELECT COUNT(*)
                          INTO vcontador
                          FROM garanpro
                         WHERE cramo = reg.cramo
                           AND cmodali = reg.cmodali
                           AND ctipseg = reg.ctipseg
                           AND ccolect = reg.ccolect
                           AND cactivi = reg.cactivi;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vcontador := 0;
                     END;

                     IF vcontador <> 0 THEN
                        vactividad := reg.cactivi;
                     ELSE
                        vactividad := 0;
                     END IF;
                  ELSE
                     vactividad := 0;
                  END IF;

                  vnum_err := f_buscanmovimi(psseguro, 1, 1, vmoviment);

                  IF vnum_err != 0 THEN
                     vprov1 := -1;
                     EXIT;
                  END IF;

                  -- Prima unica -------
                  SELECT SUM(icapital), MIN(g.cgarant)
                    INTO vprima_riesgo, vtpxi
                    FROM garanpro gp, garanseg g
                   WHERE g.sseguro = psseguro
                     AND g.cgarant = gp.cgarant
                     AND gp.cramo = reg.cramo
                     AND gp.cmodali = reg.cmodali
                     AND gp.ctipseg = reg.ctipseg
                     AND gp.ccolect = reg.ccolect
                     AND gp.cactivi = reg.cactivi
                     AND g.nmovimi = vmoviment
                     AND g.cgarant = (SELECT cgarant
                                        FROM pargaranpro
                                       WHERE cvalpar = 3
                                         AND cramo = reg.cramo
                                         AND cmodali = reg.cmodali
                                         AND ccolect = reg.ccolect
                                         AND ctipseg = reg.ctipseg
                                         AND cactivi = reg.cactivi
                                         AND cpargar = 'GARPROVMAT');   --282

                  -- Busquem el pordentatge de penalització com és rescat Total tenim només un
                  BEGIN
                     SELECT d.ppenali
                       INTO vpinttec1
                       FROM detprodtraresc d, prodtraresc p
                      WHERE d.sidresc = p.sidresc
                        AND p.sproduc = reg.sproduc;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  BEGIN
                     SELECT cvalpar
                       INTO vtipo
                       FROM parproductos
                      WHERE sproduc = reg.sproduc
                        AND cparpro = 'DESPRODPROVMAT';
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF (vtipo = 1
                      OR vtipo = 3) THEN   /********** CV5, PFV ::::: PENALITZACIÓ PER UN PRODUCTE CV5 O PFV ********/
                     --Calculem el dia on s'ha de calcular la provisió matemàtica.(El dia anterior)
                     vdata := pfecha - 1;
                     --Calculem la provisió matemàtica en el dia d'abans del rescat .
                     vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vdata, 1);
                     vprov1 :=(vprov1 *(vpinttec1 / 100));
                  ELSIF(vtipo = 4) THEN   /********  RVI : VALOR DEL RESCATE  ***********/
                     --Calculem el dia on s'ha de calcular la provisió matemàtica.(Un dia  abans)
                     vdata := pfecha - 1;
                     --Calculem la provisió matemàtica dos dies abans .
                     vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vdata, 1);
                     --Calculem el dia on s'ha de calcular el preu de cotització. (Un dia abans)
                     vdata := pfecha - 1;
                     --Busco a que agrupación de activos pertenece el producto
                     vnum_err := f_parproductos(reg.sproduc, 'AGRACTIVOS', xagru);

                     IF vnum_err <> 0 THEN
                        RETURN -1;
                     END IF;

                     BEGIN
                        SELECT ipreadq
                          INTO vicompra
                          FROM activos
                         WHERE cactivo = (SELECT cactivo
                                            FROM seguros_act
                                           WHERE sseguro = psseguro)
                           AND cdivisa = (SELECT cdivisa
                                            FROM productos
                                           WHERE sproduc = reg.sproduc)
                           AND TO_NUMBER(polissa_ini) <= (SELECT TO_NUMBER(polissa_ini)
                                                            FROM cnvpolizas
                                                           WHERE sseguro = psseguro)
                           AND TO_NUMBER(polissa_fi) >= (SELECT TO_NUMBER(polissa_ini)
                                                           FROM cnvpolizas
                                                          WHERE sseguro = psseguro)
                           AND cagrupa = xagru;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           vprov1 := -21;
                           vnum_err := -1;
                        WHEN OTHERS THEN
                           vprov1 := -8;
                     END;

                     BEGIN
                        SELECT iactvent
                          INTO viventa
                          FROM activosventas
                         WHERE cactivo = xagru
                           AND cdivisa = (SELECT cdivisa
                                            FROM productos
                                           WHERE sproduc = reg.sproduc)
                           AND TO_CHAR(factvent, 'YYYYMMDD') = TO_CHAR(vdata, 'YYYYMMDD');
                     EXCEPTION
                        WHEN OTHERS THEN
                           vprov1 := -9;
                     END;

                     BEGIN
                        SELECT cvalpar
                          INTO vnum_err
                          FROM parproductos
                         WHERE cparpro = 'DESCALCRVI'
                           AND sproduc = reg.sproduc;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           vnum_err := 0;
                        WHEN OTHERS THEN
                           vnum_err := -1;
                     END;

                     IF vnum_err < 0 THEN   -- Error
                        RETURN -1;
                     ELSIF vnum_err = 1 THEN   -- RVI MENSUAL 2002
                        IF vprov1 <= vprov1 *(viventa / vicompra) THEN
                           RETURN vprov1;
                        ELSE
                           RETURN vprov1 *(viventa / vicompra);
                        END IF;
                     ELSE   -- RVI
                        RETURN vprov1 *(viventa / vicompra);
                     END IF;
                  ELSIF(vtipo = 2) THEN   /*************** CV10::::: PENALITZACIÓ PER UN PRODUCTE CV10    **********/
                     IF (TO_CHAR(pfecha, 'yyyy') = TO_CHAR(reg.fefecto, 'yyyy')) THEN   -- Estem en el primer any, li tornem la prima unica
                        BEGIN
                           SELECT d.ppenali
                             INTO vpinttec1
                             FROM detprodtraresc d, prodtraresc p
                            WHERE d.sidresc = p.sidresc
                              AND p.sproduc = reg.sproduc
                              AND d.niniran = 0
                              AND d.nfinran = 1;
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        --Calculem el dia on s'ha de calcular la provisió matemàtica.(El dia anterior)
                        vdata := pfecha - 1;
                        --Calculem la provisió matemàtica en el dia d'abans del rescat.
                        vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vdata, 1);
                        vprov1 := vprov1 - vprima_riesgo;
                     ELSE
                        IF (TO_CHAR(TO_NUMBER(TO_CHAR(reg.fefecto, 'yyyy')) + 1) =
                                                                        TO_CHAR(pfecha, 'yyyy')) THEN   -- Estem en le segon any li tornem el 7%
                           BEGIN
                              SELECT d.ppenali
                                INTO vpinttec1
                                FROM detprodtraresc d, prodtraresc p
                               WHERE d.sidresc = p.sidresc
                                 AND p.sproduc = reg.sproduc
                                 AND d.niniran = 1
                                 AND d.nfinran = 2;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;

                           --Calculem el dia on s'ha de calcular la provisió matemàtica.(El dia anterior)
                           vdata := pfecha - 1;
                           --Calculem la provisió matemàtica en el dia d'abans del rescat.
                           vprov1 := pk_provmatematicas.f_provmat(1, psseguro, vdata, 1);
                           vprov1 :=(vprov1 *(vpinttec1 / 100));
                        ELSE   -- No tornem res ja no podem haver-hi rescats
                           vprov1 := -8;
                        END IF;
                     END IF;
--      ELSIF (vtipo = 6)THEN          /*********  PENALITZACIÓ PIG: PLA D'INTERES GARANTIT   ************/
/*
               --Fora del primer periode Penalització 0
               --Dins del primer periode SI que hi ha penalització
               --Calculem la data d'efecte
               BEGIN
                 SELECT  S.FEFECTO,P.SPRODUC   INTO FECHA_EFECTO,SPRODUC
                 FROM PRODUCTOS P,SEGUROS S
                 WHERE  S.SSEGURO = PSSEGURO
                   AND P.CRAMO = S.CRAMO
                   AND P.CMODALI = S.CMODALI
                   AND P.CTIPSEG = S.CTIPSEG
                   AND P.CCOLECT = S.CCOLECT
                   AND S.CSITUAC <> 4
                   AND (S.FVENCIM >= PFECHA OR S.FVENCIM IS NULL)
                   AND (S.FANULAC >= PFECHA OR S.FANULAC IS NULL)
                   AND S.FEFECTO <= PFECHA;
               EXCEPTION WHEN OTHERS THEN RETURN (-35);
               END;

               --Calculem l'interes del primers periode i la durada
                BEGIN
                  SELECT PINTTEC,FEIMTEC
                  INTO IT1P,FEIMTEC
                  FROM SEGUROS_AHO
                  WHERE SSEGURO = PSSEGURO;
                  EXCEPTION WHEN OTHERS THEN
                        RETURN(-30);
                END;

                IF FEIMTEC IS NULL THEN
                  --Si no existeix data del primer periode són 5 anys desde al data d'efecte
                  FEIMTEC := ADD_MONTHS(60,fecha_efecto);
                  --RETURN (-32);
                END IF;

             Penalitzacio := TRUNC(pfecha) <= TRUNC(FEIMTEC); --ok!!!!!!!!!
             IF Penalitzacio THEN
                  --El rescat es total o parcial?
                  Rescat_Total:= (pImportRescat = 0 OR pImportRescat IS NULL);
                  Penalitzacio_Anys:= MONTHS_BETWEEN(pfecha, fecha_efecto)/12;
                  --Rescat total: 3 --Rescat parcial: 2
                  --Calculem el percentatge/import de penalitzacio
                  IF Rescat_Total THEN
                               Penalitzacio_F:=TROBA_PENALITZACIO(3,Penalitzacio_Anys,SPRODUC,Penalitzacio_Tipus,FEIMTEC);
                     ELSE
                                 Penalitzacio_F:=TROBA_PENALITZACIO(2,Penalitzacio_Anys,SPRODUC,Penalitzacio_Tipus,FEIMTEC);
                     END IF;
                  IF Penalitzacio_F <0 THEN RETURN(-33); END IF;
                  --PENALITZACIO_TIPUS=1 IMPORT
                  IF Penalitzacio_Tipus = 1 THEN
                           Penalitzacio_PTA:=Penalitzacio_F;
                           --Penalitzacio_Tipus=2 Percentatge
                           ELSIF Penalitzacio_Tipus = 2 THEN
                           IF Rescat_Total THEN
                              PM_DiaAbans:=  F_Matriz_Provmat_Acumulat(psseguro, PfECHA-1);
                              IF  PM_DiaAbans < 0 THEN RETURN (-32); END IF;
                                 Penalitzacio_PTA:=  PM_DiaAbans * (Penalitzacio_F); --Penalitzacio en PTA
                               ELSE
                              Penalitzacio_PTA:=   pImportRescat * (Penalitzacio_F); --Penalitzacio en PTA
                               END IF;
                  END IF;
                  --Calculamos las primas pagadas hasta la fecha
                  PrimasPagadas:=CalculaPrimasPagadas();
                  IF PrimasPagadas < 0 THEN RETURN (-39);   END IF;
                  IF (PM_DiaAbans - Penalitzacio_PTA) < PrimasPagadas THEN
                           Penalitzacio_PTA:= PM_DiaAbans - PrimasPagadas;
                  END IF;
               ELSE
                     Penalitzacio_PTA:=0;
                  END IF;
                  --La penalitzacio en PTA es retorna a la variable  vprov1
                  vprov1:=Penalitzacio_PTA;

*/
                  ELSIF(vtipo = 7) THEN   --PENALITZACIÓ PEG: PLA D'ESTALVI GARANTIT
                     --Calculem la data d'efecte
                     BEGIN
                        SELECT s.fefecto, p.sproduc
                          INTO fecha_efecto, sproduc
                          FROM productos p, seguros s
                         WHERE s.sseguro = psseguro
                           AND p.cramo = s.cramo
                           AND p.cmodali = s.cmodali
                           AND p.ctipseg = s.ctipseg
                           AND p.ccolect = s.ccolect
                           AND s.csituac <> 4
                           AND(s.fvencim >= pfecha
                               OR s.fvencim IS NULL)
                           AND(s.fanulac >= pfecha
                               OR s.fanulac IS NULL)
                           AND s.fefecto <= pfecha;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-35);
                     END;

                     penalitzacio_anys := MONTHS_BETWEEN(pfecha, fecha_efecto) / 12;
                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);

                     --Rescat total: 3   --Rescat parcial: 2
                       --Calculem el percentatge/import de penalitzacio
                     IF rescat_total THEN
                        penalitzacio_f := troba_penalitzacio(3, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, pfecha);
                     ELSE
                        penalitzacio_f := troba_penalitzacio(2, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, pfecha);
                     END IF;

                     IF penalitzacio_f < 0 THEN
                        RETURN(-33);
                     END IF;

                     --Penalitzacio_Tipus=1 Import
                     IF penalitzacio_tipus = 1 THEN
                        penalitzacio_pta := penalitzacio_f;
                     --Penalitzacio_Tipus=2 Percentatge
                     ELSIF penalitzacio_tipus = 2 THEN
                        IF rescat_total THEN
                           pm_diaabans := f_matriz_provmat_acumulat(psseguro, pfecha - 1);

                           IF pm_diaabans < 0 THEN
                              RETURN(-32);
                           END IF;

                           penalitzacio_pta := pm_diaabans *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        ELSE
                           penalitzacio_pta := pimportrescat *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        END IF;
                     END IF;

                     --Calculamos las primas pagadas hasta la fecha
                     primaspagadas := calculaprimaspagadas();

                     IF primaspagadas < 0 THEN
                        RETURN(-39);
                     END IF;

                     IF (pm_diaabans - penalitzacio_pta) < primaspagadas THEN
                        penalitzacio_pta := pm_diaabans - primaspagadas;
                     END IF;

                     --La penalitzacio en PTA es retorna a la variable  vprov1
                     vprov1 := penalitzacio_pta;
                  ELSIF(vtipo = 8) THEN   --PENALITZACIÓ PPP: PLA PERSONAL DE PREVISIÓ
                     --Calcula la penalitzacio del dia pfecha
                              --Fora dels primers 1 any  Penalització 0
                              --Dins dels primers 1 any  SI que hi ha penalització
                              --Calculem la data d'efecte
                     BEGIN
                        SELECT s.fefecto, p.sproduc
                          INTO fecha_efecto, sproduc
                          FROM productos p, seguros s
                         WHERE s.sseguro = psseguro
                           AND p.cramo = s.cramo
                           AND p.cmodali = s.cmodali
                           AND p.ctipseg = s.ctipseg
                           AND p.ccolect = s.ccolect
                           AND s.csituac <> 4
                           AND(s.fvencim >= pfecha
                               OR s.fvencim IS NULL)
                           AND(s.fanulac >= pfecha
                               OR s.fanulac IS NULL)
                           AND s.fefecto <= pfecha;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-35);
                     END;

                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);
                     penalitzacio_anys := MONTHS_BETWEEN(pfecha, fecha_efecto) / 12;

                     --Rescat total: 3 --Rescat parcial: 2
                        --Calculem el percentatge/import de penalitzacio
                     IF rescat_total THEN
                        penalitzacio_f := troba_penalitzacio(3, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, fecha_efecto);
                     ELSE
                        penalitzacio_f := troba_penalitzacio(2, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, fecha_efecto);
                     END IF;

                     IF penalitzacio_f < 0 THEN
                        RETURN(-33);
                     END IF;

                     --Penalitzacio_Tipus=1 Import
                     IF penalitzacio_tipus = 1 THEN
                        penalitzacio_pta := penalitzacio_f;
                     --Penalitzacio_Tipus=2 Percentatge
                     ELSIF penalitzacio_tipus = 2 THEN
                        IF rescat_total THEN
                           pm_diaabans := f_matriz_provmat_acumulat(psseguro, pfecha - 1);

                           IF pm_diaabans < 0 THEN
                              RETURN(-32);
                           END IF;

                           penalitzacio_pta := pm_diaabans *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        ELSE
                           penalitzacio_pta := pimportrescat *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        END IF;
                     END IF;

                     --Calculamos las primas pagadas hasta la fecha
                     primaspagadas := calculaprimaspagadas();

                     IF primaspagadas < 0 THEN
                        RETURN(-39);
                     END IF;

                     IF (pm_diaabans - penalitzacio_pta) < primaspagadas THEN
                        penalitzacio_pta := pm_diaabans - primaspagadas;
                     END IF;

                     --La penalitzacio en PTA es retorna a la variable  vprov1
                     vprov1 := penalitzacio_pta;
                  END IF;

                  --PENALITZACIÓ PIP: PLA INFANTIL DE PREVISIÓ
                  IF (vtipo = 9) THEN
                     --Calcula la penalitzacio del dia pfecha
                     BEGIN
                        SELECT s.fefecto, p.sproduc, cdivisa
                          INTO fecha_efecto, sproduc, p_cdivisa
                          FROM productos p, seguros s
                         WHERE s.sseguro = psseguro
                           AND p.cramo = s.cramo
                           AND p.cmodali = s.cmodali
                           AND p.ctipseg = s.ctipseg
                           AND p.ccolect = s.ccolect
                           AND s.csituac <> 4
                           AND(s.fvencim >= pfecha
                               OR s.fvencim IS NULL)
                           AND(s.fanulac >= pfecha
                               OR s.fanulac IS NULL)
                           AND s.fefecto <= pfecha;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-35);
                     END;

                     --Fora dels primers 1 any  Penalització 0
                        --Dins dels primers 1 any  SI que hi ha penalització
                      --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);
                     penalitzacio_anys := MONTHS_BETWEEN(pfecha, fecha_efecto) / 12;

                     --Rescat total: 3 --Rescat parcial: 2
                        --Calculem el percentatge/import de penalitzacio
                     IF rescat_total THEN
                        penalitzacio_f := troba_penalitzacio(3, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, fecha_efecto);
                     ELSE
                        penalitzacio_f := troba_penalitzacio(2, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, fecha_efecto);
                     END IF;

                     IF penalitzacio_f < 0 THEN
                        RETURN(-33);
                     END IF;

                     --Penalitzacio_Tipus=1 Import
                     IF penalitzacio_tipus = 1 THEN
                        penalitzacio_pta := penalitzacio_f;
                     --Penalitzacio_Tipus=2 Percentatge
                     ELSIF penalitzacio_tipus = 2 THEN
                        IF rescat_total THEN
                           pm_diaabans := f_matriz_provmat_acumulat(psseguro, pfecha - 1);

                           IF pm_diaabans < 0 THEN
                              RETURN(-32);
                           END IF;

                           penalitzacio_pta := pm_diaabans *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        ELSE
                           penalitzacio_pta := pimportrescat *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        END IF;
                     END IF;

                     --Comprobem que hagin passat 5 anys de la data d'efecte
                     IF ADD_MONTHS(fecha_efecto, 12 * 5) > pfecha THEN
                        --si és premi, li restem (Sumem) 5000 PTA
                        IF p_cdivisa = 2
                           AND sproduc IN(545, 546, 547, 548, 595, 596, 597, 601)
                           AND rescat_total THEN
                           penalitzacio_pta := penalitzacio_pta + 5000;
                        ELSIF rescat_total
                              AND sproduc IN(545, 546, 547, 548, 595, 596, 597, 601) THEN
                           penalitzacio_pta := penalitzacio_pta + f_eurospesetas(5000, 2);
                        END IF;
                     END IF;

                     --Calculamos las primas pagadas hasta la fecha
                     primaspagadas := calculaprimaspagadas();

                     IF primaspagadas < 0 THEN
                        RETURN(-39);
                     END IF;

                     IF (pm_diaabans - penalitzacio_pta) < primaspagadas THEN
                        penalitzacio_pta := pm_diaabans - primaspagadas;
                     END IF;

                     --La penalitzacio en PTA es retorna a la variable  vprov1
                     vprov1 := penalitzacio_pta;
                  ELSIF(vtipo = 10) THEN   --PENALITZACIÓ PJP: PLA JUVENIL DE PREVISIÓ
                     BEGIN
                        SELECT s.fefecto, p.sproduc
                          INTO fecha_efecto, sproduc
                          FROM productos p, seguros s
                         WHERE s.sseguro = psseguro
                           AND p.cramo = s.cramo
                           AND p.cmodali = s.cmodali
                           AND p.ctipseg = s.ctipseg
                           AND p.ccolect = s.ccolect
                           AND s.csituac <> 4
                           AND(s.fvencim >= pfecha
                               OR s.fvencim IS NULL)
                           AND(s.fanulac >= pfecha
                               OR s.fanulac IS NULL)
                           AND s.fefecto <= pfecha;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-35);
                     END;

                     --Fora dels primers 1 any  Penalització 0
                        --Dins dels primers 1 any  SI que hi ha penalització
                              --El rescat es total o parcial?
                           --Calcula la penalitzacio del dia pfecha
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);
                     penalitzacio_anys := MONTHS_BETWEEN(pfecha, fecha_efecto) / 12;

                     --Rescat total: 3 --Rescat parcial: 2
                        --Calculem el percentatge/import de penalitzacio
                     IF rescat_total THEN
                        penalitzacio_f := troba_penalitzacio(3, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, fecha_efecto);
                     ELSE
                        penalitzacio_f := troba_penalitzacio(2, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, fecha_efecto);
                     END IF;

                     IF penalitzacio_f < 0 THEN
                        RETURN(-33);
                     END IF;

                     --Penalitzacio_Tipus=1 Import
                     IF penalitzacio_tipus = 1 THEN
                        penalitzacio_pta := penalitzacio_f;
                     --Penalitzacio_Tipus=2 Percentatge
                     ELSIF penalitzacio_tipus = 2 THEN
                        IF rescat_total THEN
                           pm_diaabans := f_matriz_provmat_acumulat(psseguro, pfecha - 1);

                           IF pm_diaabans < 0 THEN
                              RETURN(-32);
                           END IF;

                           penalitzacio_pta := pm_diaabans *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        ELSE
                           penalitzacio_pta := pimportrescat *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        END IF;
                     END IF;

                     --Calculamos las primas pagadas hasta la fecha
                     primaspagadas := calculaprimaspagadas();

                     IF primaspagadas < 0 THEN
                        RETURN(-39);
                     END IF;

                     IF (pm_diaabans - penalitzacio_pta) < primaspagadas THEN
                        penalitzacio_pta := pm_diaabans - primaspagadas;
                     END IF;

                     --La penalitzacio en PTA es retorna a la variable  vprov1
                     vprov1 := penalitzacio_pta;
                  ELSIF(vtipo = 11) THEN   --PENALITZACIÓ PLAN 18:
                     --Calculem la data d'efecte
                     BEGIN
                        SELECT s.fefecto, p.sproduc
                          INTO fecha_efecto, sproduc
                          FROM productos p, seguros s
                         WHERE s.sseguro = psseguro
                           AND p.cramo = s.cramo
                           AND p.cmodali = s.cmodali
                           AND p.ctipseg = s.ctipseg
                           AND p.ccolect = s.ccolect
                           AND s.csituac <> 4
                           AND(s.fvencim >= pfecha
                               OR s.fvencim IS NULL)
                           AND(s.fanulac >= pfecha
                               OR s.fanulac IS NULL)
                           AND s.fefecto <= pfecha;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(-35);
                     END;

                     --Calcula la penalitzacio del dia pfecha
                     --El rescat es total o parcial?
                     rescat_total :=(pimportrescat = 0
                                     OR pimportrescat IS NULL);
                     penalitzacio_anys := MONTHS_BETWEEN(pfecha, fecha_efecto) / 12;

                     --Rescat total: 3 --Rescat parcial: 2
                     --Calculem el percentatge/import de penalitzacio
                     IF rescat_total THEN
                        penalitzacio_f := troba_penalitzacio(3, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, fecha_efecto);
                     ELSE
                        penalitzacio_f := troba_penalitzacio(2, penalitzacio_anys, sproduc,
                                                             penalitzacio_tipus, fecha_efecto);
                     END IF;

                     IF penalitzacio_f < 0 THEN
                        RETURN(-33);
                     END IF;

                     --Penalitzacio_Tipus=1 Import
                     IF penalitzacio_tipus = 1 THEN
                        penalitzacio_pta := penalitzacio_f;
                     --Penalitzacio_Tipus=2 Percentatge
                     ELSIF penalitzacio_tipus = 2 THEN
                        pm_diaabans := f_matriz_provmat_acumulat(psseguro, pfecha - 1);

                        IF rescat_total THEN
                           IF pm_diaabans < 0 THEN
                              RETURN(-32);
                           END IF;

                           penalitzacio_pta := pm_diaabans *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        ELSE
                           penalitzacio_pta := pimportrescat *(penalitzacio_f / 100);   --Penalitzacio en PTA
                        END IF;
                     END IF;

                     IF rescat_total THEN
                        --Calculamos las primas pagadas hasta la fecha
                        primaspagadas := calculaprimaspagadas();

                        IF primaspagadas < 0 THEN
                           RETURN(-39);
                        END IF;

                        BEGIN
                           SELECT COUNT(*)
                             INTO n_rescats_parcials_anteriors
                             FROM ctaseguro
                            WHERE sseguro = psseguro
                              AND cmovimi = 33   --33 RESCAT PARCIAL
                              AND fvalmov >= reg.fefecto
                              AND fvalmov <= f_sysdate   --LES DATES ES CORRESPONEN AL MES
                              AND cmovanu != 1;   --El moviment no ha estat anulat
                        EXCEPTION
                           WHEN OTHERS THEN
                              RETURN(-32);
                        END;

                        IF n_rescats_parcials_anteriors = 0 THEN
                           IF (pm_diaabans - penalitzacio_pta) < primaspagadas THEN
                              penalitzacio_pta := pm_diaabans - primaspagadas;
                           END IF;
                        ELSE
                           --Calculamos las primas consumidas hasta la fecha
                           primasconsumidas := calculaprimasconsumidas();

                           IF primasconsumidas < 0 THEN
                              RETURN(-39);
                           END IF;

                           --IF (PM_DiaAbans - Penalitzacio_PTA) < (PrimasPagadas - PrimasConsumidas) THEN
                           penalitzacio_pta := pm_diaabans * penalitzacio_f / 100;
                        --END IF;
                        END IF;
                     END IF;   -- FI DE RESCTAE TOTAL

                     --La penalitzacio en PTA es retorna a la variable  vprov1
                     vprov1 := penalitzacio_pta;
                  END IF;

                  IF (vprov1 IS NULL) THEN
                     vprov1 := -8;
                  END IF;   --SIGNIFICA QUE NO HI HAGUT CAP RESCAT
               END LOOP;
   /* COMISSIÓ PER EL RVI  PER GASTOS EXT EXT, EXT INT i INTERNS */
--   ELSIF (ppenalitzacio = 8) THEN
     /* COMISIO RVI*/
/*     CIEPROVMAT := Pk_Provmatematicas.f_provmat(1, psseguro, pfecha, 1);
     VPROV1 := CIEPROVMAT;
    VPINTTECC1 := VPINTTEC1;
     vdata_segon1 :=  vdata_Segon;
         -- Tenim la provisió matematica.
     BEGIN
      vgasext := 0; vgasext1 := 0;
        SELECT s.fefecto, p.pgasint, p.pgaexin, p.pgaexex
          INTO vfinici, vgasint , vgasext, vgasext1
            FROM PRODUCTOS p, SEGUROS s
           WHERE  s.sseguro  = psseguro AND p.CTIPSEG = s.CTIPSEG
             AND p.cmodali = s.cmodali AND p.CRAMO = s.cramo AND p.CCOLECT = s.ccolect;
     EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
--
     BEGIN
           -- L'interes tècnic para el segundo periodo
        SELECT NVL(pinttec,0),feimtec INTO vpinttec2, vfecha29
             FROM SEGUROS_AHO WHERE sseguro = psseguro;
        vindice := ((TO_NUMBER(TO_CHAR(pfecha,'yyyy'))*12)+
                  TO_NUMBER((TO_CHAR(pfecha,'MM'))))-
                ((TO_NUMBER(TO_CHAR(vfinici,'yyyy'))*12)+
                  TO_NUMBER((TO_CHAR(vfinici,'MM'))));
        SELECT tpxi, ipcmort  INTO vTPXI, vIPCMORT
          FROM MATRIZPROVMATGEN
         WHERE cindice = vindice;
     EXCEPTION
        WHEN OTHERS THEN
             vnum_err := 103501;
    END;

--     Busco Provmat 2on. Periodo
    IF( TO_CHAR(vfinici, 'yyyymm') <> TO_CHAR(pfecha, 'yyyymm'))THEN
        vdata_segon2 := TO_CHAR(LAST_DAY(ADD_MONTHS(pfecha, -1)),'dd/mm/yyyy');
        CIEPROVMAT2 := Pk_Provmatematicas.f_provmat(1,psseguro, vdata_segon2, 1);
        VPINTTECC2 := VPINTTEC1;
         -- Tenim la provisió matematica.
           BEGIN
           vindice := ((TO_NUMBER(TO_CHAR(pfecha-1,'yyyy'))*12)+
                       TO_NUMBER((TO_CHAR(pfecha-1,'MM'))))-
                  ((TO_NUMBER(TO_CHAR(vfinici,'yyyy'))*12)+
                    TO_NUMBER((TO_CHAR(vfinici,'MM'))));
             SELECT tpxi, ipcmort  INTO VTPXI1, VIPCMORT1
            FROM MATRIZPROVMATGEN
           WHERE cindice = vindice;
          EXCEPTION
          WHEN OTHERS THEN
              vnum_err := 103501;
        END;
    END IF;
--
    FOR xgasto IN 1..3 LOOP
       IF xgasto = 1 THEN -- Calcula Gastos Externos Externos
         vgasext1 := vgasext1;
      ELSIF xgasto = 2 THEN -- Calcula Gastos Externos Internos
         vgasext1 := vgasext;
      ELSIF  xgasto = 3 THEN -- Calcula Gastos Internos
         vgasext1 := vgasint;
      END IF;
       IF( vFECHA29 < pfecha ) THEN  -- APLIQUEM EL PRIMER INTERES
           vpinttec1 := (  (1+(vpinttecc1/100)   )*(1- (vgasext1/100) )) -1;
             vpinttec11 := POWER(((1 +(vpinttecc1/100))*(1 -(vgasext1 /100) ) ),(1/12) )-1;
      ELSE -- APLIQUEM EL SEGON INTERES
             vpinttec1 := ((1+(vpinttec2/100))*(1- (vgasext1/100) )) -1 ;
             vpinttec11 := POWER(((1 +(vpinttec2/100))*(1 -(vgasext1 /100))),(1/12) )-1;
      END IF;
--
      vdata_segon := ADD_MONTHS( vdata_Segon1 , 1);
      vd2 := (vdata_segon - pfecha);
         vprima_riesgo := (1 - vtpxi)*(POWER((1 + vpinttec11), -(1/2))) * vipcmort * ((vd1+1)/vd2);
      vprov1_aux := (CIEPROVMAT - vprima_riesgo)*(POWER(( vpinttec1+1 ),((vd1+1)/365)))*( 1/(1-( (vd1+1)/vd2 ) *(1- vtpxi)));
      IF( vFECHA29 < pfecha ) THEN  -- APLIQUEM EL PRIMER INTERES
             vpinttec1  :=  (vpinttec1/100);
             vpinttec11 := POWER( ((1 +(vpinttec1/100))),(1/12) )-1;
      ELSE -- APLIQUEM EL SEGON INTERES
             vpinttec1 := (vpinttec2/100);
             vpinttec11 := POWER( ((1 +(vpinttec2/100))),(1/12) )-1;
      END IF;
      vdata_segon := ADD_MONTHS( vdata_Segon , 1);
      vd2 := (vdata_segon - pfecha);
      vprima_riesgo := (1 - vtpxi)*(POWER((1 + vpinttec11), -(1/2))) * vipcmort * ((vd1+1)/vd2);
      vprov1 := (CIEPROVMAT - vprima_riesgo)*(POWER(( vpinttec1+1 ),((vd1+1)/365)))*( 1/(1-((vd1+1)/vd2 )*(1- vtpxi)));
      vprov1 :=  vprov1 - vprov1_aux;
-- 2on. Periodo
      IF( TO_CHAR(vfinici, 'yyyymm') <> TO_CHAR(pfecha, 'yyyymm'))THEN
        IF( vFECHA29 < pfecha ) THEN  -- APLIQUEM EL PRIMER INTERES
               vpinttec1 := ((1+(vpinttecc2/100))*(1- (vgasext1/100) )) -1;
               vpinttec11 := POWER(((1 +(vpinttecc2/100))*(1 -(vgasext1 /100))),(1/12) )-1;
           ELSE -- APLIQUEM EL SEGON INTERES
               vpinttec1 := ((1+(vpinttec2/100))*(1- (vgasext1/100) )) -1 ;
               vpinttec11 := POWER(((1 +(vpinttec2/100))*(1 -(vgasext1 /100))),(1/12))-1;
           END IF;
          vdd2 := pfecha - vdata_segon2 ;
        vdd1 := vdata  - vdata_Segon2 ;
        vprima_riesgo := (1 - vtpxi1)*(POWER((1 + vpinttec11), -(1/2))) * vipcmort1 * ((vdd1+1)/vdd2);
            vprov1_aux := (CIEPROVMAT2 - vprima_riesgo)*(POWER(( vpinttec1+1 ),((vdd1+1)/365)))*( 1/(1-( (vdd1+1)/vdd2 ) *(1- vtpxi1) ));
         -- Sin gastos
        IF( vfecha29 < pfecha ) THEN  -- APLIQUEM EL PRIMER INTERES
            vpinttec1 :=   (vpinttec1/100);
            vpinttec11 := POWER(((1 +(vpinttec1/100))),(1/12) )-1;
          ELSE -- APLIQUEM EL SEGON INTERES
            vpinttec1 := (vpinttec2/100);
            vpinttec11 := POWER(((1 +(vpinttec2/100)) ),(1/12) )-1;
          END IF;
        vprima_riesgo := (1 - vtpxi1)*    (POWER((1 + vpinttec11), -(1/2))) * vipcmort1 * ((vdd1+1)/vdd2);
        vprov2 := (CIEPROVMAT2 - vprima_riesgo)*(POWER(( vpinttec1+1 ),((vdd1+1)/365)))*( 1/(1-( (vdd1+1)/vdd2 ) *(1- vtpxi1) ));
        vprov2 :=  vprov2 - vprov1_aux;
          vprov1 := vprov1 + vprov2;
      END IF;
--
      IF xgasto = 1 THEN
         CIEGASEXEX  := F_Round(vprov1,1);
      ELSIF  xgasto = 2 THEN
         CIEGASEXIN := F_Round(vprov1,1);
      ELSIF  xgasto = 3 THEN
         CIEGASINTE := F_Round(vprov1,1);
      END IF;
    END LOOP;
*/
            END IF;   -- Tipo penalizacion
         ELSE
            -- si la data de calcul és més gran que la data de venciment de la pòlissa retornem un 1
            IF (pfecha > vfvencim) THEN
               vprov1 := -1;
            -- Si la data de calcul és més petita que la data inici (efecte) de la pòlissa retornem un 2
            ELSIF(pfecha < vfinici) THEN
               vprov1 := -2;
            -- Error
            ELSE
               vprov1 := -3;
            END IF;
         END IF;
      END IF;

      IF (vprov1 IS NULL) THEN
         /*
           Error no controlat.
           (Degut a que no troba les dades corresponents o alguna operació no la realtiza correctament)
         */
         vprov1 := 0;
      END IF;

      BEGIN
         vd1 := 0;

         SELECT p.cdivisa
           INTO vd1
           FROM seguros s, productos p
          WHERE s.sseguro = psseguro
            AND p.cmodali = s.cmodali
            AND p.ctipseg = s.ctipseg
            AND p.ccolect = s.ccolect
            AND p.cramo = s.cramo;

         IF (vd1 = 3) THEN   -- Euros
            vprov1 := f_round(vprov1, 1);   --1 codi EUROS
         END IF;

         IF (vd1 = 2) THEN   -- Pesetas
            vprov1 := ROUND(vprov1);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(vprov1);
      END;

      RETURN(vprov1);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_provmat;

--- F_MATRIZ_PROVMAT --
   FUNCTION f_matriz_provmat(
      psseguro IN NUMBER,
      fecha IN DATE,
      estat IN NUMBER DEFAULT 1,
        -- Si 0 --> la data és més gran que la data de venciment
        -- Si 1 --> la data és més petita que la data de venciment.
      -- Si 2 --> Calculem l'import Brut de la renta
      provmat IN NUMBER DEFAULT 0
                                 -- Provisió matematica (provmat el dia d'abans).
   )
      RETURN NUMBER IS
      moviment       NUMBER;   -- Número del moviment
      /* interes, gastos interns i gastos externs*/
      pinttec        NUMBER;
      pinttec2       NUMBER;   -- interes tecnic a partir del 31/01/2029
      var_pgasint    NUMBER;
      var_pgasext    NUMBER;
      /* Edat is sexe del assegurats*/
      pedad          NUMBER;   -- Edad en mesos de l'assegurat
      xedad          NUMBER;
      psexo          NUMBER;   -- Sexe del primer assegurat
      xsexo          NUMBER;
      pedad1         NUMBER;   -- Edad en mesos del segon assegurat
      xedad1         NUMBER;
      psexo1         NUMBER;   -- Sexe del segon assegurat
      xsexo1         NUMBER;
      /* Any de càlcul i duracions del diferents periodes*/
      panyo          NUMBER;   -- Any de calcul
      nduraci        NUMBER;   -- Duació de la pòlissa
      nduraci2       NUMBER;
      psproces       NUMBER;   -- Codi del proces
      picapital      NUMBER;   -- Capital assegurat
      pprima         NUMBER;   -- Prima unica
      primeraquant   NUMBER;   -- Primera quantia
      segonaquant    NUMBER;   -- Segona quantia
      cmodali        NUMBER;   -- Modalitat (80% , 90% o 110%)
      fecha29        DATE;
      fduraci        DATE;   -- Data de venciment menys un dia.
      num_err        NUMBER;
      contador       NUMBER;
      actividad      NUMBER;
      cont           NUMBER;
      /* Variable per el ASSP */
      vncaren        NUMBER;   -- Duració de la carència
      vcforamor      NUMBER;   -- Forma de amortització o de pagament.
      nduraci1       NUMBER;   -- Duració en mesos del primer periode. (En el cas de que no hi hagin primas fraccionaries = nduraci1 + nduraci2 )
      piniciduraci2  NUMBER;   -- Fecha d' inici del segon periode.
      vprimafrac     NUMBER;   -- Prima fraccionaria
      vinvalidessa   NUMBER;   -- Variable per sapiguer si existeix la garantia de invalidessa per el producte ASSP.
      /*  nduraci2 : Duració del segon periode ( En el cas de que es tracti com un unic periode = 0)*/
      pcalculo       DATE;   -- Fecha d'inici del segon periode.
      vfcarult       DATE;   -- Data últim cobro de prima fraccionaria
      nduraci3       NUMBER;   -- Duració de l'últim periode.
      --XT
      fnacimi1       DATE;
      fnacimi2       DATE;
      it1p           seguros_aho.pinttec%TYPE;   --Interès tècnic primer periode
--  pFEIMTEC                     SEGUROS_AHO.FEIMTEC%TYPE;      --Data de finalització del primer periode
      k_icapmaxaseguradopta garanpro.icapmax%TYPE := 2000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
      k_icapmaxasegurado2pta garanpro.icapmax%TYPE := 5000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
      k_icapmaxasegurado65pta garanpro.icapmax%TYPE := 100000;   --Capital Màxim Assegurat als 65 anys fixat a 100000 PTA
      k_euros_pta    NUMBER := 166.386;   --Canvi de PTA a Euros
      k_icapmaxasegurado garanpro.icapmax%TYPE := 2000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
      k_icapmaxasegurado2 garanpro.icapmax%TYPE := 5000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
      k_icapmaxasegurado65 garanpro.icapmax%TYPE := 100000;   --Capital Màxim Assegurat als 65 anys fixat a 100000 PTA
      durada_periode1 NUMBER;   --Durada del 1r periode (mesos)
      pinttot        interesprod.pinttot%TYPE;
      k_des_ext_risc NUMBER := 1;   --Despeses Externes de Risc
      k_int_tec_risc NUMBER := 4;   --Interes tècnic de risc
      pta            BOOLEAN;   --Cert Producte en pessetes, sino en euros
      --fXT
      vpiprimuni     NUMBER;

      -- Cursor que agafa totes les dades de la pòlissa
      CURSOR c_polizas_provmat IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, p.pinttec,
                NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.ncertif, s.nduraci nduraci,
                p.pgasint, p.pgasext, s.cactivi, s.cforpag, s.fvencim, p.pgaexin, p.pgaexex,
                p.cdivisa
           FROM productos p, seguros s
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect
            AND s.csituac <> 4
            AND s.fefecto <= fecha;

--    and (s.fvencim >= fecha OR s.fvencim IS NULL)
--    AND (s.fanulac >= fecha OR s.fanulac IS NULL)
  -- Seleccionem les garanties vigents de la polissa que calculen provisions matemàticas
      CURSOR c_garantias_provmat(
         seguro NUMBER,
         ramo NUMBER,
         modalidad NUMBER,
         tipseg NUMBER,
         colect NUMBER,
         actividad NUMBER,
         fecha DATE) IS
         SELECT DISTINCT nriesgo, g.cgarant, ctabla, cprovis
                    FROM garanpro gp, garanseg g
                   WHERE g.sseguro = psseguro
                     AND cprovis IS NOT NULL
                     AND g.cgarant = gp.cgarant
                     AND gp.cramo = ramo
                     AND gp.cmodali = modalidad
                     AND gp.ctipseg = tipseg
                     AND gp.ccolect = colect
                     AND gp.cactivi = actividad
                     AND(ffinefe > fecha
                         OR ffinefe IS NULL);

      -- Cursor per el producte ASSP ( Exclusiu per sapiguer si té la garantia de invalidesa )
      CURSOR c_garantias_assp(
         seguro NUMBER,
         ramo NUMBER,
         modalidad NUMBER,
         tipseg NUMBER,
         colect NUMBER,
         actividad NUMBER,
         fecha DATE) IS
         SELECT DISTINCT nriesgo, g.cgarant, ctabla, cprovis
                    FROM garanpro gp, garanseg g
                   WHERE g.sseguro = psseguro
                     AND(TO_CHAR(ffinefe, 'YYYYMMDD') > TO_CHAR(fecha, 'YYYYMMDD')
                         OR ffinefe IS NULL)
                     AND g.cgarant = gp.cgarant
                     AND gp.cramo = ramo
                     AND gp.cmodali = modalidad
                     AND gp.ctipseg = tipseg
                     AND gp.ccolect = colect
                     AND gp.cactivi = actividad;

      -- Cursor que agafa la data de naixament i el sexe de les persones asegurades.
      CURSOR c_personas(seguro NUMBER) IS
         SELECT p.fnacimi, p.csexper, s.norden
           FROM personas p, asegurados s
          WHERE s.sseguro = seguro
            AND p.sperson = s.sperson;

      PROCEDURE act_max_cap_asse(pta IN BOOLEAN) IS
      BEGIN
         --Producte en pessetes
         IF pta THEN
            k_icapmaxasegurado := k_icapmaxaseguradopta;
            k_icapmaxasegurado2 := k_icapmaxasegurado2pta;
            k_icapmaxasegurado65 := k_icapmaxasegurado65pta;
         --Producte en euros
         ELSE
            k_icapmaxasegurado := f_eurospesetas(k_icapmaxaseguradopta, 2);
            k_icapmaxasegurado2 := f_eurospesetas(k_icapmaxasegurado2pta, 2);
            k_icapmaxasegurado65 := f_eurospesetas(k_icapmaxasegurado65pta, 2);
         END IF;
      END;
   BEGIN
-- Abrimos el cursor general de las pólizas
      FOR reg IN c_polizas_provmat LOOP
         num_err := 0;

         IF reg.cactivi <> 0 THEN
            -- Averiguamos que actividad de garanpro es la que hay que coger
            BEGIN
               SELECT COUNT(*)
                 INTO contador
                 FROM garanpro
                WHERE cramo = reg.cramo
                  AND cmodali = reg.cmodali
                  AND ctipseg = reg.ctipseg
                  AND ccolect = reg.ccolect
                  AND cactivi = reg.cactivi;
            EXCEPTION
               WHEN OTHERS THEN
                  contador := 0;
            END;

            IF contador <> 0 THEN
               actividad := reg.cactivi;
            ELSE
               actividad := 0;
            END IF;
         ELSE
            actividad := 0;
         END IF;

         cont := 0;
         pedad1 := NULL;
         psexo1 := NULL;
         pedad := 0;

         FOR per IN c_personas(psseguro) LOOP
            IF (cont = 0) THEN
               -- Sexo y meses de la persona asegurada
               psexo := per.csexper;
               pedad := ROUND(((reg.fefecto - per.fnacimi) / 365.25) * 12);
               fnacimi1 := per.fnacimi;
            ELSE   /* Agafem el segon assegurat  */
               -- Sexo y meses de la persona asegurada
               psexo1 := per.csexper;
               pedad1 := ROUND(((reg.fefecto - per.fnacimi) / 365.25) * 12);
               fnacimi2 := per.fnacimi;
            END IF;

            cont := cont + 1;
         END LOOP;

         --Pasamos a meses la fecha de calculo
         panyo := 0;
-- panyo := ((TO_NUMBER(TO_CHAR(fecha,'yyyy'))*12)+TO_NUMBER((TO_CHAR(fecha,'MM'))))-((TO_NUMBER(TO_CHAR(reg.fefecto,'yyyy'))*12)+TO_NUMBER((TO_CHAR(reg.fefecto,'MM'))));
         panyo := ROUND(((fecha - reg.fefecto) / 365.25) * 12, 0);

         -- Si nduraci del seguro no está informado, calculamos nosotros la duración. Calculamos la duración del seguro ..
         IF reg.nduraci IS NULL THEN
            fduraci := reg.fvencim - 1;
            nduraci :=(((TO_NUMBER(TO_CHAR(fduraci, 'yyyy')) * 12)
                        + TO_NUMBER((TO_CHAR(fduraci, 'MM'))))
                       -((TO_NUMBER(TO_CHAR(reg.fefecto, 'yyyy')) * 12)
                         + TO_NUMBER((TO_CHAR(reg.fefecto, 'MM')))));
         ELSE
            nduraci := reg.nduraci * 12;
         END IF;

         BEGIN
            num_err := f_buscanmovimi(psseguro, 1, 1, moviment);

            IF num_err != 0 THEN
               RETURN -1;
            END IF;

            -- Prima unica -------
            SELECT SUM(imovimi)
              INTO pprima
              FROM ctaseguro
             WHERE sseguro = psseguro
               AND TO_CHAR(fvalmov, 'YYYYMMDD') = TO_CHAR(reg.fefecto, 'YYYYMMDD')
               AND cmovimi = 1;

            -- Capital final -------
            SELECT SUM(icapital)
              INTO picapital
              FROM garanpro gp, garanseg g
             WHERE g.sseguro = psseguro
               AND g.cgarant = gp.cgarant
               AND gp.cramo = reg.cramo
               AND gp.cmodali = reg.cmodali
               AND gp.ctipseg = reg.ctipseg
               AND gp.ccolect = reg.ccolect
               AND gp.cactivi = reg.cactivi
               AND g.nmovimi = moviment
               AND g.cgarant = (SELECT cgarant
                                  FROM pargaranpro
                                 WHERE cvalpar = 2
                                   AND cramo = reg.cramo
                                   AND cmodali = reg.cmodali
                                   AND ccolect = reg.ccolect
                                   AND ctipseg = reg.ctipseg
                                   AND cactivi = reg.cactivi
                                   AND cpargar = 'GARPROVMAT');   --283;

            -- Import prima fraccionaria per ASSP
            SELECT SUM(g.iprianu)
              INTO vprimafrac
              FROM garanpro gp, garanseg g
             WHERE g.sseguro = psseguro
               AND gp.cramo = reg.cramo
               AND gp.cmodali = reg.cmodali
               AND gp.ctipseg = reg.ctipseg
               AND gp.ccolect = reg.ccolect
               AND gp.cactivi = reg.cactivi
               AND g.nmovimi = moviment
               AND g.cgarant = gp.cgarant
               AND g.cgarant = (SELECT cgarant
                                  FROM pargaranpro
                                 WHERE cvalpar = 1
                                   AND cramo = reg.cramo
                                   AND cmodali = reg.cmodali
                                   AND ccolect = reg.ccolect
                                   AND ctipseg = reg.ctipseg
                                   AND cactivi = reg.cactivi
                                   AND cpargar = 'GARPROVMAT');   -- MORT 1
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               num_err := 0;
         END;

  -- En el cas de que sigui una provisió per el producte RVI
/*
  BEGIN
     SELECT NVL(pinttec,0),feimtec INTO pinttec, fecha29 FROM SEGUROS_AHO WHERE sseguro = psseguro;
     nduraci2 := TRUNC( (((FECHA29 - REG.fefecto )/365.25)*12), 0 );
     -- La primera quantia, la segona quantia i el tipus de modalitat
    SELECT NVL(ibruren,0), NVL(ibrure2,0), NVL(cmodali,0) INTO primeraquant, segonaquant, cmodali
    FROM SEGUROS_REN WHERE sseguro = psseguro;
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
*/
         BEGIN
            DELETE FROM matrizprovmatgen
                  WHERE cindice > -1;

            psproces := 1;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF num_err = 0 THEN
            FOR reggar IN c_garantias_provmat(psseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                              reg.ccolect, actividad, fecha) LOOP
               -- Provisions Matemàtiques per el CV5 o CV10 o PFV
               IF reggar.cprovis = 14
                  OR reggar.cprovis = 15 THEN
                  num_err := pk_provmatematicas.f_matriz_provmat9(panyo, pedad, pedad1, psexo,
                                                                  psexo1, nduraci, psproces,
                                                                  pinttec, pprima,
                                                                  reggar.ctabla, reg.pgasint,
                                                                  picapital);
               -- provisiones matematicas para RVI
               ELSIF reggar.cprovis = 16 THEN
                  IF (nduraci IS NULL) THEN
                     nduraci := 1560;
                  END IF;

                  var_pgasint := reg.pgasint;
                  var_pgasext := reg.pgaexin + reg.pgaexex;

--- Ini AFM
                  IF pedad > pedad1 THEN
                     xedad := pedad1;
                     xsexo := psexo1;
                     xedad1 := pedad;
                     xsexo1 := psexo;
                  ELSE
                     xedad := pedad;
                     xsexo := psexo;
                     xedad1 := pedad1;
                     xsexo1 := psexo1;
                  END IF;

                  num_err := pk_provmatematicas.f_matriz_provmat10(panyo, xedad, xedad1, xsexo,
                                                                   xsexo1, nduraci, nduraci2,
                                                                   psproces, pinttec,
                                                                   reg.pinttec, var_pgasint,
                                                                   var_pgasext, pprima,
                                                                   primeraquant, segonaquant,
                                                                   reggar.ctabla, cmodali,
                                                                   reg.cdivisa);
--       num_err := Pk_Provmatematicas.F_MATRIZ_PROVMAT10( panyo, edad, edad1, psexo, psexo1, nduraci, nduraci2, psproces, pinttec, reg.pinttec,var_pgasint,var_pgasext,pprima, primeraquant, segonaquant, reggar.ctabla, cmodali, reg.cdivisa);
--- Fin AFM
      -- provisiones matematicas para ASSP
/*
        ELSIF reggar.cprovis = 17  THEN
           BEGIN
              SELECT iimppre, pintpre, ncaren, cforamor, fcarult  INTO pprima, pinttec,  vncaren, vcforamor , vfcarult
                FROM SEGUROS_ASSP WHERE sseguro = psseguro;
                -- Data inici segon periode
              SELECT feimtec INTO pcalculo
                 FROM SEGUROS_AHO WHERE sseguro = psseguro;
            EXCEPTION WHEN OTHERS THEN NULL; END;
            IF(vncaren = 0 OR vncaren IS NULL )THEN
                vncaren := NULL;
            ELSE    vncaren := vncaren * 12;   END IF;
           BEGIN
            IF( pcalculo IS NOT NULL )THEN
              nduraci1 := ROUND( (( pcalculo - reg.fefecto )/365.25)*12) ;
              nduraci2 :=  ROUND( (( vfcarult - reg.fefecto )/365.25)*12) ; -- meses duracio periode 2 + periode 1
              piniciduraci2 := ( ((TO_NUMBER(TO_CHAR( pcalculo ,'yyyy')    )    *12       )+TO_NUMBER((TO_CHAR( pcalculo,'MM'))))-
                                ((TO_NUMBER(TO_CHAR(reg.fefecto ,'yyyy'))*12)+TO_NUMBER((TO_CHAR(reg.fefecto ,'MM')))));
              nduraci3 := nduraci - (nduraci1 + nduraci2);
         ELSE
              nduraci1 := nduraci;
              piniciduraci2 := NULL;
              nduraci2 := NULL;
              nduraci3 := NULL;
            END IF;
            IF (vcforamor <> 0 )THEN  vprimafrac:= vprimafrac /vcforamor ; END IF;
           EXCEPTION WHEN OTHERS THEN num_err := 1; END;
              vinvalidessa := 0;
              --Mirem si te garantia de invalidessa.
               FOR regassp IN  c_garantias_assp(psseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                           reg.ccolect, actividad, fecha) LOOP
               -- Existeix garantia de invalidessa absoluta i permanent es tracta de diferent forma.
                 IF(regassp.cgarant = 5)THEN
                    vinvalidessa := 1;
                 END IF;
               END LOOP;
               IF ( vinvalidessa = 0 ) THEN
                  num_err := Pk_Provmatematicas.f_matriz_provmat11(psseguro, panyo, pedad, pedad1, psexo, psexo1, reg.fefecto, fecha, nduraci, nduraci1, piniciduraci2,nduraci2, nduraci3,vncaren, psproces,pinttec,reg.pgasint, reggar.ctabla, reg.pgasext,vcforamor, vprimafrac );
               ELSE
                  num_err := Pk_Provmatematicas.f_matriz_provmat16(psseguro, panyo, pedad, pedad1, psexo, psexo1, reg.fefecto, fecha, nduraci, nduraci1, piniciduraci2,nduraci2, nduraci3,vncaren, psproces,pinttec,reg.pgasint, reggar.ctabla, reg.pgasext,vcforamor, vprimafrac );
               END IF;
*/
     -- PROVISIó MATEMATICA PER PIG
               ELSIF reggar.cprovis = 18 THEN
                  num_err := f_matriz_provmat_acumulat(psseguro, fecha);

                  IF num_err < 0 THEN
                     num_err := -1;
                  END IF;
               -- PROVISIó MATEMATICA PER EL PEG
               ELSIF reggar.cprovis = 19 THEN
                  num_err := f_matriz_provmat_acumulat(psseguro, fecha);

                  IF num_err < 0 THEN
                     num_err := -1;
                  END IF;
                    --A num_err tenim la previsió matemàtica (indefinit )
               -- PROVISIó MATEMATICA PER EL PPP (PLA PERSONA DE PREVISIÓ, PLA INFANTIL DE PREVISIÓ, PLA JUVENIL DE PREVISIÓ)
               ELSIF reggar.cprovis = 20 THEN
                  IF (estat = 1) THEN
                     num_err := f_matriz_provmat_acumulat(psseguro, fecha);

                     IF num_err < 0 THEN
                        num_err := -1;
                     END IF;
                  --A num_err tenim la provisió matemàtica
                  ELSIF(estat = 0
                        OR estat = 2) THEN
                     BEGIN
                        SELECT f1paren
                          INTO vfcarult
                          FROM seguros_ren
                         WHERE sseguro = psseguro;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN(0);
                     END;

                     nduraci := 2000;

                     FOR per IN c_personas(psseguro) LOOP
                        pedad := ROUND(((vfcarult - per.fnacimi) / 365.25) * 12);
                        psexo := per.csexper;
                     END LOOP;

                     panyo := 0;
                     panyo := ROUND(((fecha - vfcarult) / 365.25) * 12);

                     -- Calculem la prov. matematica a partir de la data de venciment
                     IF (estat = 0) THEN
                        num_err := pk_provmatematicas.f_matriz_provmat17(panyo, pedad, psexo,
                                                                         nduraci, psproces,
                                                                         reg.pinttec, provmat,
                                                                         reggar.ctabla,
                                                                         reg.pgasint, 1,
                                                                         psseguro);
                     ELSE
  ----------------------------------------------------------------------
-- Calculem l'import brut de la renda a partir de la data de venciment.
  ----------------------------------------------------------------------
                        num_err := pk_provmatematicas.f_matriz_provmat17(panyo, pedad, psexo,
                                                                         nduraci, psproces,
                                                                         reg.pinttec, provmat,
                                                                         reggar.ctabla,
                                                                         reg.pgasint, 0,
                                                                         psseguro);
                     END IF;
                  END IF;
               -- Provisió matematica  per PIP, PJP ( 60 mesos )
               ELSIF reggar.cprovis = 21
                     OR reggar.cprovis = 22 THEN
                  IF (estat = 1) THEN
                     -- Abans de la data de venciment
                     num_err := f_matriz_provmat_acumulat(psseguro, fecha);

                     IF num_err < 0 THEN
                        num_err := -1;
                     END IF;
                  -- A partir de la data de venciment
                  ELSIF(estat = 0
                        OR estat = 2) THEN
                     nduraci := 60 - 1;   -- al ser anticipada.

                     BEGIN
                        SELECT f1paren
                          INTO vfcarult
                          FROM seguros_ren
                         WHERE sseguro = psseguro;
                     EXCEPTION
                        WHEN OTHERS THEN
                           NULL;
                     END;

                     panyo := 0;
                     panyo := ROUND(((fecha - vfcarult) / 365.25) * 12);

                     FOR per IN c_personas(psseguro) LOOP
                        IF per.norden = 1 THEN
                           pedad := ROUND(((vfcarult - per.fnacimi) / 365.25) * 12);
                           psexo := per.csexper;
                        END IF;
                     END LOOP;

-------------------------------------------------------------------
-- Calculem la prov. matematica  a partir de la data de venciment
-------------------------------------------------------------------
                     IF (estat = 0) THEN   -- Calculem la prov. matematica
                        num_err := pk_provmatematicas.f_matriz_provmat17(panyo, pedad, psexo,
                                                                         nduraci, psproces,
                                                                         reg.pinttec, provmat,
                                                                         reggar.ctabla,
                                                                         reg.pgasint, 1,
                                                                         psseguro);
-------------------------------------------------------------------
-- Calculem l'import brut de la renda
-------------------------------------------------------------------
                     ELSE
                        num_err := pk_provmatematicas.f_matriz_provmat17(panyo, pedad, psexo,
                                                                         nduraci, psproces,
                                                                         reg.pinttec, provmat,
                                                                         reggar.ctabla,
                                                                         reg.pgasint, 0,
                                                                         psseguro);
                     END IF;
                  END IF;
               --
               -- Provisió matematica per  el PLA18: Pla perosnal de previsió
               --
               ELSIF reggar.cprovis = 23 THEN
                  num_err := f_matriz_provmat_acumulat(psseguro, fecha);

                  IF num_err < 0 THEN
                     num_err := -1;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      RETURN num_err;
   END f_matriz_provmat;

--
--
   FUNCTION f_matriz_provmat9(
/***************************************************************************************
      Carrega de la taula MATRIZPROVMATGEN mab totes les columnes necessaries per
      calcular la provisió Matemàtica dels productes CV5 / CV10 I PFV
***************************************************************************************/
      panyo IN NUMBER,   -- Any de calcul
      pedad IN NUMBER,   -- Edad primer assegurat
      pedad2 IN NUMBER,   -- Edad segon assegurat
      psexo IN NUMBER,   -- sexo del primer asegurado
      psexo2 IN NUMBER,   -- sexo del segon asegurado
      nduraci IN NUMBER,   -- Duració en mesos de la pòlissa
      psproces IN NUMBER,   -- Codi (No serveix per res)
      pinttec IN NUMBER,   -- Interès tècnic que s'aplica
      piprimuni IN NUMBER,   -- Prima unica (ve donada en la pòlissa)
      pctiptab IN NUMBER,   -- Codi de la taula de mortalitat
      ppgasint IN NUMBER,   -- Porcentatge de gastos interns (ve donat en la pòlissa)
      picapital IN NUMBER   -- Capital garantitzat al venciment (ve donat en la pòlissa)
                         )
      RETURN NUMBER IS   --PRAGMA AUTONOMOUS_TRANSACTION;
      actuarial      NUMBER;
      indice         NUMBER;   -- 0.. N meses de duració de la pòlissa
      anoreserva     NUMBER;
      edad           NUMBER;   -- Edat del primer assegurat
      edad2          NUMBER;   -- Edat del segon assegurat
      anyo           NUMBER;   --  Ano de calculo
      /* Valors de la taula de Mortalitat*/
      p_factor       NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel primer assegurat
      p_factorseg    NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel segon assegurat
      p_factor1      NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Primer assegurat)
      p_factor1seg   NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Segon assegurat)
      anyories       NUMBER;
      var_lx1        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Primer assegurat)
      var_lx2        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Segon assegurat)
   BEGIN
      indice := 0;
      edad := pedad;
      edad2 := pedad2;
      anyories := panyo;
      anyo := 0;

      -- Calculem el valor de la taula de mortalitat per l'edat del primer assegurat
      BEGIN
         SELECT /*+ index(mortalidad,mortalidad_pk)*/
                DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = pedad
            AND ctabla = pctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN -1;
      END;

      IF (pedad2 IS NOT NULL) THEN
         BEGIN   -- Pel segon assegurat
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factorseg
              FROM mortalidad
             WHERE nedad = pedad2
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN -1;
         END;
      END IF;

      -- Calculs abans de l'any de calcul
      FOR anyo IN 0 ..(anyories - 1) LOOP
         -- Seleccionem el valor en la taula de mortalitat que correspon
         -- a l'edat en l'any en el que fem els calculs.
         BEGIN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;

            IF (pedad2 IS NOT NULL) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factor1seg
                 FROM mortalidad
                WHERE nedad = edad2 + 1
                  AND ctabla = pctiptab;
            ELSE
               p_factor1seg := 0;
            END IF;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO var_lx1
              FROM mortalidad
             WHERE nedad = edad
               AND ctabla = pctiptab;

            IF (pedad2 IS NOT NULL) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx2
                 FROM mortalidad
                WHERE nedad = edad2
                  AND ctabla = pctiptab;
            ELSE
               var_lx2 := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN -1;
         END;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2, tpx1, tpx2, tpxi,
                         tsumpx1, tsumpx2, tsumpxi, tqx, vn, vn2, vecvida, vecmort, icapital,
                         itotprim, igascapv, ipgascapv,
                         ipcmort,
                         ippmort, ipcvid, ippvid, sproces)
                 VALUES (indice, edad, edad2, NULL, var_lx1, var_lx2, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0, picapital,
                         DECODE(indice, 0, piprimuni, 0),(picapital *(ppgasint / 100)), 0,
                         DECODE(indice,
                                nduraci, 0,
                                piprimuni
                                * POWER((1 +(POWER((1 +(pinttec / 100)),(1 / 12)) - 1)),
                                        indice)),
                         0, DECODE(indice, nduraci, picapital, 0), 0, psproces);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 999;
         END;

         indice := indice + 1;
         edad := edad + 1;

         IF (pedad2 IS NOT NULL) THEN
            edad2 := edad2 + 1;
         END IF;
      END LOOP;

      -- A partir de l'any de calcul
      anoreserva := 0;
      anyo := anyories;

      -- Calculem el valor de mortalitat per l'edat de l'assegurat en l'any de calcul
      BEGIN
         p_factor := 0;
         p_factorseg := 0;

         SELECT /*+ index(mortalidad,mortalidad_pk)*/
                DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = edad
            AND ctabla = pctiptab;

         IF (pedad2 IS NOT NULL) THEN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
              INTO p_factorseg
              FROM mortalidad
             WHERE nedad = edad2
               AND ctabla = pctiptab;
         ELSE
            p_factorseg := 1;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN -1;
      END;

      actuarial := 0;

      FOR anyo IN anyories .. nduraci LOOP
         anyories := 0;

         BEGIN
            var_lx1 := 0;
            var_lx2 := 0;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO var_lx1
              FROM mortalidad
             WHERE nedad = edad
               AND ctabla = pctiptab;

            IF (pedad2 IS NOT NULL) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx2
                 FROM mortalidad
                WHERE nedad = edad2
                  AND ctabla = pctiptab;
            ELSE
               var_lx2 := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN -1;
         END;

         BEGIN
            p_factor1 := 0;
            p_factor1seg := 0;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;

            IF (pedad2 IS NOT NULL) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factor1seg
                 FROM mortalidad
                WHERE nedad = edad2 + 1
                  AND ctabla = pctiptab;
            ELSE
               p_factor1seg := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN -1;
         END;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2,
                         tpx1, tpx2,
                         tpxi,
                         tsumpx1, tsumpx2,
                         tsumpxi,
                         tqx,
                         vn,
                         vn2,
                         vecvida,
                         vecmort,
                         icapital, itotprim,
                         igascapv,
                         ipgascapv,
                         ipcmort,
                         ippmort,
                         ipcvid,
                         ippvid,
                         sproces)
                 VALUES (indice, edad, edad2, actuarial, var_lx1, var_lx2,
                         var_lx1 / p_factor, var_lx2 / p_factorseg,
                         (1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))),
                         p_factor1 / p_factor, p_factor1seg / p_factorseg,
                         (1 -((1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg)))),
                         (((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                          -(1 -((1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg))))),
                         POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)), -anoreserva),
                         POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                               -(anoreserva + 1)),
                         ((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg)))
                          *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                  -anoreserva))),
                         (((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                          -((1 - (1 -(p_factor1 / p_factor))
                                 *(1 -(p_factor1seg / p_factorseg)))))
                         *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                 -(anoreserva + 1))),
                         picapital, DECODE(indice, 0, piprimuni, 0),
                         DECODE(indice, nduraci, 0,(picapital *(ppgasint / 100))),
                         ((DECODE(indice, nduraci, 0,(picapital *(ppgasint / 100))))
                          *((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg)))
                            *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                    -anoreserva))))
                         / 12,
                         DECODE(indice,
                                nduraci, 0,
                                DECODE(pctiptab,
                                       2,(piprimuni
                                          * POWER((1
                                                   +(POWER((1 +(pinttec / 100)),(1 / 12)) - 1)),
                                                  indice)),
                                       (picapital * 1.5))),
                         ((DECODE(indice,
                                  nduraci, 0,
                                  DECODE(pctiptab,
                                         2,(piprimuni
                                            * POWER((1
                                                     +(POWER((1 +(pinttec / 100)),(1 / 12)) - 1)),
                                                    indice)),
                                         (picapital * 1.5))))
                          *((((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                             -((1
                                - (1 -(p_factor1 / p_factor))
                                  *(1 -(p_factor1seg / p_factorseg)))))
                            *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                    -(anoreserva + 1))))),
                         DECODE(indice, nduraci, picapital, 0),
                         (DECODE(indice, nduraci, picapital, 0))
                         *(((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg)))
                            *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                    -anoreserva)))),
                         psproces);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN -1;
         END;

         indice := indice + 1;
         anoreserva := anoreserva + 1;
         actuarial := actuarial + 1;
         edad := edad + 1;

         IF (pedad2 IS NOT NULL) THEN
            edad2 := edad2 + 1;
         END IF;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat9;

   FUNCTION f_matriz_provmat10(
/***************************************************************************************
      Carrega de la taula MATRIZPROVMATGEN mab totes les columnes necessaries per
      calcular la provisió Matemàtica dels productes RVI
***************************************************************************************/
      panyo IN NUMBER,   -- Ano de calculo
      pedad IN NUMBER,   -- Edad primer asegurado
      pedad2 IN NUMBER,   -- Edad segundo asegurado
      psexo IN NUMBER,   --sexo del primer asegurado
      psexo2 IN NUMBER,   --sexo del segon asegurado
      /* Duranció en mesos */
      nduraci IN NUMBER,
      nduraci2 IN NUMBER,
      psproces IN NUMBER,   -- Codigo del proceso
      /* Duranció en mesos */
      pinttec IN NUMBER,   -- Interes tecnico que se aplica hasta el 2029
      pinttec2 IN NUMBER,   -- Interes tecnico que se aplica desde el 2029 (nduraci2)
      ppgasint IN NUMBER,   -- Porcentage de gastos hasta el 2029
      ppgasext IN NUMBER,   -- Porcentatge de gastos exteriors fins el 2029
      pprima IN NUMBER,   -- Prima unica
      piprimuni IN NUMBER,   -- Primera quantia
      piprimuni2 IN NUMBER,   -- Segona quantia a partir, s'aplica a partir del 31/01/2029
      pctiptab IN NUMBER,   -- Codigo de la tabla de mortalidad ( 4 )
      pmodali IN NUMBER,   -- Codigo de la Modalidad que s'ha d'aplicar (1--> 80%, 2-->90%, 3--> 110%)
      pcdivisa IN NUMBER   -- Codigo de la divisa
                        )
      RETURN NUMBER IS   --PRAGMA AUTONOMOUS_TRANSACTION;
      estat          NUMBER;   -- Variable para saber si estamos ya en el segundo periodo(a partir del 2029)
      estat2         NUMBER;   -- Variable para saber si estamos ya en el segundo periodo(a partir del 2029)
      actuarial      NUMBER;
      indice         NUMBER;   -- 0.. N meses de duració de la pòlissa
      anoreserva     NUMBER;
      edad           NUMBER;   -- Edat del primer assegurat
      edad2          NUMBER;   -- Edat del segon assegurat
      anyo           NUMBER;   --  Any de calcul
      p_factor       NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel primer assegurat
      p_factorseg    NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel segon assegurat
      p_factor1      NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Primer assegurat)
      p_factor1seg   NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Segon assegurat)
      v_lxvar        NUMBER;
      p_factseg      NUMBER;
      p_fact         NUMBER;
      anyories       NUMBER;
      var_lx1        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Primer assegurat)
      var_lx2        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Segon assegurat)
      var_lx11       NUMBER;
      var_lx22       NUMBER;
      var_pinttec1   NUMBER;
      var_pinttec2   NUMBER;
      importmodali   NUMBER;
   BEGIN
      -- Mensualizamos el interes tecnico del primer periodo y del segundo periodo
      var_pinttec1 := POWER(((1 +(pinttec / 100)) *(1 -(ppgasint / 100) -(ppgasext / 100))),
                            (1 / 12))
                      - 1;
      var_pinttec2 := POWER(((1 +(pinttec2 / 100)) *(1 -(ppgasint / 100) -(ppgasext / 100))),
                            (1 / 12))
                      - 1;

      --  Comprovem la modalidad
      IF (pmodali = 80) THEN
         importmodali := pprima * 0.80;
      END IF;   -- Modalidad de 1

      IF (pmodali = 90) THEN
         importmodali := pprima * 0.90;
      END IF;   --Modalidad 2

      indice := 0;
      edad := pedad;
      edad2 := pedad2;
      anyories := panyo;
      anyo := 0;
      estat := 0;

      BEGIN
         p_factor := 0;
         p_factorseg := 0;

         IF edad <= 1524 THEN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor
              FROM mortalidad
             WHERE nedad = edad
               AND ctabla = pctiptab;
         END IF;

         IF (pedad2 IS NOT NULL
             AND edad2 <= 1524) THEN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
              INTO p_factorseg
              FROM mortalidad
             WHERE nedad = edad2
               AND ctabla = pctiptab;
         ELSE
            p_factorseg := 1;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- Calculs abans de l'any de calcul
      FOR anyo IN 0 ..(anyories - 1) LOOP
         BEGIN
            var_lx11 := 0;
            var_lx22 := 0;

            IF edad <= 1524 THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx11
                 FROM mortalidad
                WHERE nedad = edad
                  AND ctabla = pctiptab;
            END IF;

            IF (pedad2 IS NOT NULL
                AND edad2 <= 1524) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx22
                 FROM mortalidad
                WHERE nedad = edad2
                  AND ctabla = pctiptab;
            ELSE
               var_lx22 := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            var_lx1 := 0;
            var_lx2 := 0;

            IF (edad + 1 <= 1524) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx1
                 FROM mortalidad
                WHERE nedad = edad + 1
                  AND ctabla = pctiptab;
            ELSE
               var_lx1 := 0;
            END IF;

            IF (pedad2 IS NOT NULL
                AND edad2 + 1 <= 1524) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx2
                 FROM mortalidad
                WHERE nedad = edad2 + 1
                  AND ctabla = pctiptab;
            ELSE
               var_lx2 := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         p_factor1 := 0;
         p_factor1seg := 0;

         BEGIN
            IF (edad + 2) <= 1524 THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factor1
                 FROM mortalidad
                WHERE nedad = edad + 2
                  AND ctabla = pctiptab;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_factor1 := 0;
         END;

         BEGIN
            IF (pedad2 IS NOT NULL
                AND((edad2 + 2) <= 1524)) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factor1seg
                 FROM mortalidad
                WHERE nedad = edad2 + 2
                  AND ctabla = pctiptab;
            ELSE
               p_factor1seg := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_factor1seg := 0;
         END;

         IF (pmodali = 110
             AND(edad >= 780
                 OR edad2 >= 780)) THEN   --Modalidad 3
            IF (pcdivisa = 2) THEN   -- Pesetes
               IF (0.10 * pprima) <(100000) THEN
                  importmodali := pprima +(0.10 * pprima);
               ELSE
                  importmodali := pprima + 100000;
               END IF;
            ELSE   -- Euros
               IF (0.10 * pprima) <(100000 / 166.386) THEN
                  importmodali := pprima +(0.10 * pprima);
               ELSE
                  importmodali := pprima +(100000 / 166.386);
               END IF;
            END IF;
         ELSIF(pmodali = 110
               AND(edad <= 780
                   OR edad2 <= 780)) THEN
            IF (pcdivisa = 2) THEN   -- Pesetes
               IF (0.10 * pprima) <(1000000) THEN
                  importmodali := pprima +(0.10 * pprima);
               ELSE
                  importmodali := pprima + 1000000;
               END IF;
            ELSE   -- Euros
               IF (0.10 * pprima) <(1000000 / 166.386) THEN
                  importmodali := pprima +(0.10 * pprima);
               ELSE
                  importmodali := pprima +(1000000 / 166.386);
               END IF;
            END IF;
         END IF;

         anyories := 0;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2, tpx1, tpx2, tpxi,
                         tsumpx1, tsumpx2, tsumpxi, tqx, vn, vn2, vecvida, vecmort, icapital,
                         itotprim, igascapv, ipgascapv, ipcmort, ippmort, ipcvid, ippvid,
                         sproces)
               (SELECT /*+ index(mortalidad,mortalidad_pk)*/
                       indice, edad, edad2, actuarial, var_lx11 lx1, var_lx22 lx2,
                       var_lx1 / p_factor tpx1, var_lx2 / p_factorseg tpx2,
                       (1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))) tpxi,
                       p_factor1 / p_factor tsumpx1, p_factor1seg / p_factorseg tsumpx2,
                       (1 -((1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg))))
                                                                                      tsumpxi,
                       0 tqx, 0 vn, 0 vn2, 0 vecvida, 0 vecmort, 0 icapital, 0 itotprim,
                       0 igascapv, 0 ipgascapv, 0 ipcmort, 0 ippmort, 0 ipcvid, 0 ippvid,
                       psproces
                  FROM mortalidad
                 WHERE nedad = edad
                   AND ctabla = pctiptab);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         indice := indice + 1;
         anoreserva := anoreserva + 1;
         actuarial := actuarial + 1;
         edad := edad + 1;

         IF (pedad2 IS NOT NULL) THEN
            edad2 := edad2 + 1;
         END IF;
      END LOOP;

      -- A PARTIR DE L'ANY DE CÀLCUL --
      anoreserva := 0;
      anyo := anyories;

      -- Calculamos el valor de la tabla de mortalidad para la edad del asegurado en el ano de calculo
      BEGIN
         p_factor := 0;
         p_factorseg := 0;

         IF (edad <= 1524) THEN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor
              FROM mortalidad
             WHERE nedad = edad
               AND ctabla = pctiptab;
         END IF;

         IF (pedad2 IS NOT NULL
             AND(edad2 <= 1524)) THEN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
              INTO p_factorseg
              FROM mortalidad
             WHERE nedad = edad2
               AND ctabla = pctiptab;
         ELSE
            p_factorseg := 1;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- Si apliquem les formules per el primer calcul (1 si estem en el primer periode)
      estat := 0;

      IF (panyo < nduraci2) THEN
         estat := 1;
      END IF;

      actuarial := 0;

      FOR anyo IN anyories .. nduraci LOOP
         -- Si apliquem la primera quantia o la segona. (1 si estem en el primer periode)
         BEGIN
            p_fact := 0;
            p_factseg := 0;

            IF edad + 2 <= 1524 THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
                 INTO p_fact
                 FROM mortalidad
                WHERE nedad = edad + 2
                  AND ctabla = pctiptab;
            END IF;

            IF (pedad2 IS NOT NULL
                AND((edad2 + 2) <= 1524)) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factseg
                 FROM mortalidad
                WHERE nedad = edad2 + 2
                  AND ctabla = pctiptab;
            ELSE
               p_factseg := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         estat2 := 0;

         IF (indice < nduraci2) THEN
            estat2 := 1;
         END IF;

         anyories := 0;

         BEGIN
            var_lx1 := 0;
            var_lx2 := 0;

            IF (edad <= 1524) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx1
                 FROM mortalidad
                WHERE nedad = edad
                  AND ctabla = pctiptab;
            END IF;

            IF (pedad2 IS NOT NULL
                AND edad2 <= 1524) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx2
                 FROM mortalidad
                WHERE nedad = edad2
                  AND ctabla = pctiptab;

               v_lxvar := var_lx2;
            ELSE
               var_lx2 := 0;
               v_lxvar := 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            p_factor1 := 0;
            p_factor1seg := 0;

            IF (edad <= 1524) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factor1
                 FROM mortalidad
                WHERE nedad = edad + 1
                  AND ctabla = pctiptab;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_factor1 := 0;
         END;

         BEGIN
            IF (pedad2 IS NOT NULL
                AND edad2 <= 1524) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factor1seg
                 FROM mortalidad
                WHERE nedad = edad2 + 1
                  AND ctabla = pctiptab;
            ELSE
               p_factor1seg := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_factor1seg := 0;
         END;

         IF (pmodali = 110
             AND(edad >= 780
                 OR edad2 >= 780)) THEN   --Modalidad 3
            IF (pcdivisa = 2) THEN   -- Pesetes
               IF (0.10 * pprima) <(100000) THEN
                  importmodali := pprima +(0.10 * pprima);
               ELSE
                  importmodali := pprima + 100000;
               END IF;
            ELSE   -- Euros
               IF (0.10 * pprima) <(100000 / 166.386) THEN
                  importmodali := pprima +(0.10 * pprima);
               ELSE
                  importmodali := pprima +(100000 / 166.386);
               END IF;
            END IF;
         ELSIF(pmodali = 110
               AND(edad <= 780
                   OR edad2 <= 780)) THEN
            IF (pcdivisa = 2) THEN   -- Pesetes
               IF (0.10 * pprima) <(1000000) THEN
                  importmodali := pprima +(0.10 * pprima);
               ELSE
                  importmodali := pprima + 1000000;
               END IF;
            ELSE   -- Euros
               IF (0.10 * pprima) <(1000000 / 166.386) THEN
                  importmodali := pprima +(0.10 * pprima);
               ELSE
                  importmodali := pprima +(1000000 / 166.386);
               END IF;
            END IF;
         END IF;

         BEGIN
   --  IF (INDICE = 372 ) THEN
--     END IF;
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2, tpx1, tpx2, tpxi,
                         tsumpx1, tsumpx2, tsumpxi, tqx, vn, vn2, vecvida, vecmort, icapital,
                         itotprim, igascapv, ipgascapv, ipcmort, ippmort, ipcvid, ippvid,
                         sproces)
               (SELECT /*+ index(mortalidad,mortalidad_pk)*/
                       indice, edad, edad2, actuarial, var_lx1 lx1, var_lx2 lx2,
                       p_factor1 / p_factor tpx1, p_factor1seg / p_factorseg tpx2,
                       (1 - (1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg)))
                                                                                         tpxi,
                       p_fact / p_factor tsumpx1, p_factseg / p_factorseg tsumpx2,
                       (1 -((1 -(p_fact / p_factor)) *(1 -(p_factseg / p_factorseg))))
                                                                                      tsumpxi,
                       DECODE(indice,
                              0,(1
                                 -(1
                                   -((1 -(p_factor1 / var_lx1)) *(1 -(p_factor1seg / v_lxvar))))),
                              (((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                               -((1
                                  -((1 -(p_factor1 / p_factor))
                                    *(1 -(p_factor1seg / p_factorseg))))))) tqx,
                       DECODE(estat2,
                              1,(POWER((var_pinttec1 + 1), -(actuarial + 1))),
                              DECODE(estat,
                                     1,(POWER((1 + var_pinttec1), -(nduraci2 - panyo))
                                        * POWER((1 + var_pinttec2), -(indice + 1 - nduraci2))),
                                     (POWER((1 + var_pinttec2), -(actuarial + 1))))) vn,   -- decode(estat,1,((POWER((1+ var_pinttec2),-((actuarial +1)- nduraci2)))*(POWER((1 + var_pinttec1),-nduraci2 ))) , (POWER((1+ var_pinttec2),-( actuarial - nduraci2))))) VN,
                       DECODE(estat2,
                              1,(POWER((var_pinttec1 + 1), -(actuarial + 0.5))),
                              DECODE(estat,
                                     1,(POWER((1 + var_pinttec1), -(nduraci2 - panyo))
                                        * POWER((1 + var_pinttec2), -(indice + 0.5 - nduraci2))),
                                     (POWER((1 + var_pinttec2), -(actuarial + 0.5))))) vn2,   -- decode(estat,1,((POWER((1+var_pinttec2),-(actuarial + 0.5 - nduraci2)))*(POWER((1+var_pinttec1),-nduraci2))),(POWER((1+var_pinttec2),-(actuarial + 0.5 - nduraci2))))) VN2,
                       ((DECODE(estat2,
                                1,(POWER((var_pinttec1 + 1), -(actuarial + 1))),
                                DECODE(estat,
                                       1,(POWER((1 + var_pinttec1), -(nduraci2 - panyo))
                                          * POWER((1 + var_pinttec2), -(indice + 1 - nduraci2))),
                                       (POWER((1 + var_pinttec2), -(actuarial + 1))))))
                        *((1 - (1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg)))))
                                                                                      vecvida,
                       ((DECODE(indice,
                                0,(1
                                   -(1
                                     -((1 -(p_factor1 / var_lx1))
                                       *(1 -(p_factor1seg / v_lxvar))))),
                                (((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                                 -((1
                                    -((1 -(p_factor1 / p_factor))
                                      *(1 -(p_factor1seg / p_factorseg))))))))
                        *(DECODE(estat2,
                                 1,(POWER((var_pinttec1 + 1), -(actuarial + 0.5))),
                                 DECODE(estat,
                                        1,(POWER((1 + var_pinttec1), -(nduraci2 - panyo))
                                           * POWER((1 + var_pinttec2),
                                                   -(indice + 0.5 - nduraci2))),
                                        (POWER((1 + var_pinttec2), -(actuarial + 0.5)))))))
                                                                                      vecmort,
                       0 icapital, 0 itotprim, 0 igascapv, 0 ipgascapv, importmodali ipcmort,
                       ((importmodali)
                        *(((DECODE(indice,
                                   0,(1
                                      -(1
                                        -((1 -(p_factor1 / var_lx1))
                                          *(1 -(p_factor1seg / v_lxvar))))),
                                   (((1
                                      - (1 -(var_lx1 / p_factor))
                                        *(1 -(var_lx2 / p_factorseg))))
                                    -((1
                                       -((1 -(p_factor1 / p_factor))
                                         *(1 -(p_factor1seg / p_factorseg))))))))
                           *(DECODE(estat2,
                                    1,(POWER((var_pinttec1 + 1), -(actuarial + 0.5))),
                                    DECODE(estat,
                                           1,(POWER((1 + var_pinttec1), -(nduraci2 - panyo))
                                              * POWER((1 + var_pinttec2),
                                                      -(indice + 0.5 - nduraci2))),
                                           (POWER((1 + var_pinttec2), -(actuarial + 0.5)))))))))
                                                                                      ippmort,
                       DECODE(estat2, 0, piprimuni2, piprimuni) ipcvid,
                       ((DECODE(estat2, 0, piprimuni2, piprimuni))
                        *(((DECODE(estat2,
                                   1,(POWER((var_pinttec1 + 1), -(actuarial + 1))),
                                   DECODE(estat,
                                          1,(POWER((1 + var_pinttec1), -(nduraci2 - panyo))
                                             * POWER((1 + var_pinttec2),
                                                     -(indice + 1 - nduraci2))),
                                          (POWER((1 + var_pinttec2), -(actuarial + 1))))))
                           *((1 - (1 -(p_factor1 / p_factor))
                                  *(1 -(p_factor1seg / p_factorseg))))))) ippvid,
                       psproces
                  FROM mortalidad
                 WHERE nedad = edad
                   AND ctabla = pctiptab);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         indice := indice + 1;
         anoreserva := anoreserva + 1;
         actuarial := actuarial + 1;
         edad := edad + 1;

         IF (pedad2 IS NOT NULL) THEN
            edad2 := edad2 + 1;
         END IF;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat10;

   FUNCTION f_matriz_provmat11(
/***************************************************************************************
      Carrega de la taula MATRIZPROVMATGEN mab totes les columnes necessaries per
      calcular la provisió Matemàtica dels productes ASSP
      En el cas de que no hi hagi garantia de mort
***************************************************************************************/
      psseguro IN NUMBER,   -- sseguro
      panyo IN NUMBER,   -- Any de calcul
      pedad IN NUMBER,   -- Edad primer assegurat
      pedad2 IN NUMBER,   -- Edad segon assegurat
      psexo IN NUMBER,   -- sexo del primer asegurado
      psexo2 IN NUMBER,   -- sexo del segon asegurado
      /* Dates per poder calcular el capital assegurat*/
      pefecto IN DATE,   -- fecha efecto
      pcalculo IN DATE,   -- fecha de calculo
      /* DURACIONS*/
      nduraci IN NUMBER,   -- Duració en mesos de la pòlissa
      nduraci1 IN NUMBER,                    /* Duració del primer periode
                             ( En el cas de només hi hagi un prima unica es tracta tot com el primer periode
                            i per tant la nduraci1 serà igual a la duració del prestam. )
                                          */
      piniciduraci2 IN NUMBER,   -- Mesos en que comença el periode 2
      nduraci2 IN NUMBER,                     /* Duració del segon periode
                            ( Aquesta duració pot ser nul·la en el cas de que tot es tracti com un unci periode)
                                           */
      nduraci3 IN NUMBER,   -- L'ultim periode (ja no hi han primas fraccionaris només i han prov. al morir)
      nduracicaren IN NUMBER,   -- Duració del periode de carència
      psproces IN NUMBER,   -- Codi (No serveix per res)
      pinttec IN NUMBER,   -- Interès tècnic que s'aplica
      pgasint IN NUMBER,   -- Porcentatge de gastos
      pctiptab IN NUMBER,   -- Codi de la taula de mortalitat
      ppgasext IN NUMBER,   -- Porcentatge de gastos interns (ve donat en la pòlissa)
      pfpago IN NUMBER,   -- Forma de pagament o d'amortització
      pprimafrac IN NUMBER   -- Primes fraccionaries
                          )
      RETURN NUMBER IS   -- PRAGMA AUTONOMOUS_TRANSACTION;
      actuarial      NUMBER;
      indice         NUMBER;   -- 0.. N meses de duració de la pòlissa
      anoreserva     NUMBER;
      edad           NUMBER;   -- Edat del primer assegurat
      edad2          NUMBER;   -- Edat del segon assegurat
      anyo           NUMBER;   --  Ano de calculo
      vcarencia      NUMBER;   -- si carencia = 1 estamos en el periodo de carencia.
      vprimerperiodo NUMBER;   -- si vprimerperiodo = 1 estamos en el primer periodo si no estamos en el segundo.
      vpiniciduraci2 NUMBER;   -- inici en mesos del segon periode.
      vduraci2       NUMBER;   -- Duració del segon periode.
      /* Valors de la taula de Mortalitat*/
      p_factor       NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel primer assegurat
      p_factorseg    NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel segon assegurat
      p_factor1      NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Primer assegurat)
      p_factor1seg   NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Segon assegurat)
      anyories       NUMBER;
      var_lx1        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Primer assegurat)
      var_lx2        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Segon assegurat)
      vcapitalmort   NUMBER;   -- Capital assegurat per la part de prestacions la morir.
      vcapitalmort_aux NUMBER;
      vcapitalgas    NUMBER;   -- Capital assegurat per la part de gastos.
      vcapitalgas_aux NUMBER;
      /* Per poder treballar amb les dates per le capital assegurat i ipcmort */
      vdia           NUMBER;
      vmes           NUMBER;
      vany           NUMBER;
      vmeses         NUMBER;
      vcalculo       DATE;
      vaux           DATE;
      vfprimerperiode DATE;
      vfsegonperiode DATE;
      v_primeranyo   DATE;
      vfprimerperiode_gas DATE;
      vfsegonperiode_gas DATE;
      vpmort         DATE;
      vpgastos       DATE;
      vaux1          DATE;
      vcontanual     NUMBER;   -- Per saber en quin any ens trobem
      cont           NUMBER;
      -- part prima fraccionaria
      vitotprim      NUMBER;   -- Import de la prima fraccionaria
      vcontpag       NUMBER;   -- contador per saber quan ha de pagar . Forma de pagament
      vfpago         NUMBER;   -- Forma de pagament
   BEGIN
      vduraci2 := nduraci2;
      vpiniciduraci2 := piniciduraci2;
      vcontpag := 0;
      cont := 0;
      vcontanual := 1;
      vmes := TO_NUMBER(TO_CHAR(pefecto, 'MM'));
      vdia := TO_NUMBER(TO_CHAR(pefecto, 'DD'));
      vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));

      IF (vmes = 1
          OR vmes = 3
          OR vmes = 5
          OR vmes = 7
          OR vmes = 8
          OR vmes = 10
          OR vmes = 12) THEN
         vdia := 31;
      ELSE
         IF (vmes = 2) THEN
            vdia := 28;
         ELSE
            vdia := 30;
         END IF;
      END IF;

      -- Tenim la data d'efecte i on finalitza el primer periode
      vaux := TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                      'dd/mm/yyyy');
      vaux1 := ADD_MONTHS(TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                                  'dd/mm/yyyy'),
                          12);
      vfsegonperiode := vaux;

      -- Mesos que hi ha des de la data efecte fins que finalitza el primer periode
      -- El primer periode depent de la forma de pago.
      /* SON NATURALS S'HA DE MODIFICAR */
      IF (pfpago = 12
          OR pfpago = 0) THEN   -- MENSUAL
         vfpago := 12;
         vmes := TO_NUMBER(TO_CHAR(pefecto, 'MM'));
         vdia := TO_NUMBER(TO_CHAR(pefecto, 'DD'));
         vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));

         IF (vmes = 1
             OR vmes = 3
             OR vmes = 5
             OR vmes = 7
             OR vmes = 8
             OR vmes = 10
             OR vmes = 12) THEN
            vdia := 31;
         ELSE
            IF (vmes = 2) THEN
               vdia := 28;
            ELSE
               vdia := 30;
            END IF;
         END IF;

         v_primeranyo := TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                                 'dd/mm/yyyy');
         vmeses := ROUND(((v_primeranyo - pefecto) / 365.25) * 12);
      END IF;

      IF (pfpago = 1) THEN   -- ANUAL
         vfpago := 1;
         vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));
         v_primeranyo := TO_DATE(31 || '/' || 12 || '/' || TO_CHAR(vany), 'dd/mm/yyyy');
         vmeses := ROUND(((v_primeranyo - pefecto) / 365.25) * 12);
      END IF;

      IF (pfpago = 3) THEN   -- TRIMESTRAL --4
         vfpago := 3;
         vmes := TO_NUMBER(TO_CHAR(pefecto, 'MM'));

         IF (vmes <= 3) THEN
            vmes := 3;
         ELSE
            IF (vmes > 3
                AND vmes <= 6) THEN
               vmes := 6;
            ELSE
               vmes := 12;
            END IF;
         END IF;

         vdia := TO_NUMBER(TO_CHAR(pefecto, 'DD'));
         vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));

         IF (vmes = 1
             OR vmes = 3
             OR vmes = 5
             OR vmes = 7
             OR vmes = 8
             OR vmes = 10
             OR vmes = 12) THEN
            vdia := 31;
         ELSE
            IF (vmes = 2) THEN
               vdia := 28;
            ELSE
               vdia := 30;
            END IF;
         END IF;

         v_primeranyo := TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                                 'dd/mm/yyyy');
         vmeses := ROUND(((v_primeranyo - pefecto) / 365.25) * 12);
      END IF;

      IF (pfpago = 2) THEN   -- SEMESTRAL
         vfpago := 6;
         vmes := TO_NUMBER(TO_CHAR(pefecto, 'MM'));

         IF (vmes <= 6) THEN
            vmes := 6;
         ELSE
            vmes := 12;
         END IF;

         vdia := TO_NUMBER(TO_CHAR(pefecto, 'DD'));
         vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));

         IF (vmes = 12) THEN
            vdia := 31;
         ELSE
            vdia := 30;
         END IF;

         v_primeranyo := TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                                 'dd/mm/yyyy');
         vmeses := ROUND(((v_primeranyo - pefecto) / 365.25) * 12);
      END IF;

/*  PRIMER BUCLE DES DE EL MES 0 FINS EL MES DE CÀLCUL.( PRIMER PERIODE )  */
      indice := 0;
      edad := pedad;
      edad2 := pedad2;
      anyories := panyo;
      anyo := 0;
      vcalculo := pcalculo;

      -- Calculs abans de l'any de calcul
      FOR anyo IN 0 ..(anyories - 1) LOOP
         /* PRESTACIONS AL MORIR */
         BEGIN
            --  Mentres estem en el primer periode es igual a la data d'efecte
            IF (anyo < vmeses) THEN   -- Estem dins el primer periode és mensual
               vcapitalmort := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                        vcalculo);
               vcontanual := 1;
               cont := 0;
            -- si no estem dins el primer periode fem la mitja per any.
            -- Pot haver periode carencia
            ELSE
               IF (vcontanual = 1
                   AND cont < 12) THEN
                  vfprimerperiode := vaux;
                  vfsegonperiode := vaux1;
               END IF;

               IF (cont = 12) THEN
                  IF (pfpago = 3) THEN   --TRIMESTRAL ha de ser un 4
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 4);
                  END IF;

                  IF (pfpago = 12
                      OR pfpago = 0) THEN   -- MENSUAL O UNICA
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 1);
                  END IF;

                  IF (pfpago = 2) THEN   -- SEMESTRAL
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 6);
                  END IF;

                  IF (pfpago = 1) THEN   -- ANUAL
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 12);
                  END IF;

                  vfsegonperiode := ADD_MONTHS(vfprimerperiode, 12);
                  cont := 0;
                  vcontanual := vcontanual + 1;
               END IF;

               vcapitalmort := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                        vfprimerperiode);
               vcapitalmort_aux := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                            vfsegonperiode);
               vcapitalmort := (vcapitalmort_aux + vcapitalmort) / 2;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalmort := 0;
         END;

         vitotprim := 0;

         /* PRIMA UNICA  O PRIMA FRACCIONARIA */
         IF (pprimafrac IS NOT NULL) THEN   -- S'ha de mirar la forma de pagament
            IF (vmeses = indice) THEN
               vitotprim := pprimafrac *(1 -(ppgasext / 100));   --Prima fraccionaria menos % de gastos
               vcontpag := 0;
            ELSE
               IF (vcontpag = vfpago) THEN
                  vcontpag := 0;
                  vitotprim := pprimafrac *(1 -(ppgasext / 100));   --Prima fraccionaria menos % de gastos externos
               ELSE
                  vcontpag := vcontpag + 1;
               END IF;
            END IF;
         ELSE
            vitotprim := 0;
         END IF;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2, tpx1, tpx2, tpxi,
                         tsumpx1, tsumpx2, tsumpxi, tqx, vn, vn2, vecvida, vecmort, icapital,
                         itotprim, igascapv, ipgascapv, ipcmort, ippmort, ipcvid, ippvid,
                         sproces)
                 VALUES (indice, edad, edad2, NULL, 0, 0, 0,   -- tpx1
                                                            0,   -- tpx2
                                                              0,   -- tpxi
                         0,   -- tsumpx1
                           0,   -- tsumpx2
                             0,   -- tsumpxi
                               0,   -- tqx
                                 0,   -- vn
                                   0,   -- vn2
                                     0,   -- vecvida
                                       0,   -- vecmort
                                         0,   --icapital
                         0,   --decode(indice,0,piprimuni,0) ,--ittotprim
                           0,   --igascapv
                             0,   --ipgascapv
                               vcapitalmort,   -- ipcmort
                                            0,   --ippmort
                                              0,   --ipcvida
                                                0,   --ippvid
                         psproces);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         edad := edad + 1;

         IF (pedad2 IS NOT NULL) THEN
            edad2 := edad2 + 1;
         END IF;

         vcalculo := ADD_MONTHS(vcalculo, 1);
         cont := cont + 1;

         IF (indice >= piniciduraci2) THEN
            vduraci2 := vduraci2 - 1;
         END IF;
      END LOOP;

       /*
          COMENÇA BUCLE DES DE EL MES DE CALCUL FINS EL fINAL :
          Tenim en compte la carencia i la forma de pagament
      */
      anoreserva := 0;
      anyo := anyories;

      BEGIN   -- Calculem el valor de mortalitat per l'edat de l'assegurat en l'any de calcul
         p_factor := 0;
         p_factorseg := 0;

         SELECT /*+ index(mortalidad,mortalidad_pk)*/
                DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = edad
            AND ctabla = pctiptab;

         IF (pedad2 IS NOT NULL) THEN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
              INTO p_factorseg
              FROM mortalidad
             WHERE nedad = edad2
               AND ctabla = pctiptab;
         ELSE
            p_factorseg := 1;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107108;
      END;

      vfprimerperiode_gas := vaux;
      vfsegonperiode_gas := vaux1;
      actuarial := 0;

      FOR anyo IN anyories .. nduraci1 LOOP
         anyories := 0;

         BEGIN
            var_lx1 := 0;
            var_lx2 := 0;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO var_lx1
              FROM mortalidad
             WHERE nedad = edad
               AND ctabla = pctiptab;

            IF (pedad2 IS NOT NULL) THEN
               SELECT DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx2
                 FROM mortalidad
                WHERE nedad = edad2
                  AND ctabla = pctiptab;
            ELSE
               var_lx2 := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         BEGIN
            p_factor1 := 0;
            p_factor1seg := 0;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;

            IF (pedad2 IS NOT NULL) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factor1seg
                 FROM mortalidad
                WHERE nedad = edad2 + 1
                  AND ctabla = pctiptab;
            ELSE
               p_factor1seg := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         /* Capital assegurat per la part de prestacions al morir */
         BEGIN   /*   S'ha de tenir en compte les dates  */
            --  Mentres estem en el primer periode
            IF (anyo < vmeses) THEN   -- Estem dins el primer periode és mensual
               vcapitalmort := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                        vaux);
               vcontanual := 1;
               cont := 0;
            -- si no estem dins el primer periode fem la mitja per any.
            -- Pot haver periode carencia
            ELSE
               IF (vcontanual = 1
                   AND cont < 12) THEN
                  vfprimerperiode := vaux;
                  vfsegonperiode := vaux1;
               END IF;

/*********************************************/
               IF (cont = 12) THEN
                  IF (pfpago = 3) THEN   --TRIMESTRAL ha de ser un 4
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 4);
                  END IF;

                  IF (pfpago = 12
                      OR pfpago = 0) THEN   -- MENSUAL O UNICA
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 1);
                  END IF;

                  IF (pfpago = 2) THEN   -- SEMESTRAL
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 6);
                  END IF;

                  IF (pfpago = 1) THEN   -- ANUAL
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 12);
                  END IF;

                  vfsegonperiode := ADD_MONTHS(vfprimerperiode, 12);
                  cont := 0;
                  vcontanual := vcontanual + 1;
               END IF;

               vcapitalmort := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                        vfprimerperiode);
               vcapitalmort_aux := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                            vfsegonperiode);
               vcapitalmort := (vcapitalmort_aux + vcapitalmort) / 2;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalmort := 0;
         END;

         /* CAPITAL ASSEGURAT PER LA PART DE GASTOS */
         BEGIN
            IF (nduracicaren IS NOT NULL) THEN
               vcapitalgas := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                       vaux);
            ELSE
               vcapitalgas := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                       vaux);
               vcapitalgas_aux := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                           vaux1);
               vcapitalgas := (vcapitalgas + vcapitalgas_aux) / 2;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalgas := 0;
         END;

         vitotprim := 0;

         /* PRIMA UNICA  O PRIMA FRACCIONARIA */
         IF (pprimafrac IS NOT NULL) THEN   -- S'ha de mirar la forma de pagament
            IF (vmeses = indice) THEN
               vitotprim := pprimafrac *(1 -(ppgasext / 100));   --Prima fraccionaria menos % de gastos
               vcontpag := 0;
            ELSE
               IF (vcontpag = vfpago) THEN
                  vcontpag := 0;
                  vitotprim := pprimafrac *(1 -(ppgasext / 100));   --Prima fraccionaria menos % de gastos
               ELSE
                  vcontpag := vcontpag + 1;
               END IF;
            END IF;
         ELSE
            vitotprim := 0;
         END IF;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2,
                         tpx1, tpx2,
                         tpxi,
                         tsumpx1, tsumpx2,
                         tsumpxi,
                         tqx,
                         vn,
                         vn2,
                         vecvida,
                         vecmort,
                         icapital, itotprim, igascapv,
                         ipgascapv,
                         ipcmort,
                         ippmort,
                         ipcvid,
                         ippvid,
                         sproces)
                 VALUES (indice, edad, edad2, actuarial, var_lx1, var_lx2,
                         var_lx1 / p_factor,   -- TPX1
                                            var_lx2 / p_factorseg,   -- TPX2
                         (1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))),   --TPXI
                         p_factor1 / p_factor,   --TPSUMPX1
                                              p_factor1seg / p_factorseg,   --TSUMPX2
                         (1 -((1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg)))),   -- TSUMPXI
                         (((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                          -(1 -((1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg))))),   --TQX
                         POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)), -anoreserva),   --VN
                         POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                               -(anoreserva + 1)),   --VN2
                         ((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg)))
                          *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                  -anoreserva))),   --VECVIDA
                         (((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                          -((1 - (1 -(p_factor1 / p_factor))
                                 *(1 -(p_factor1seg / p_factorseg)))))
                         *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                 -(anoreserva + 1))),   -- VECMORT
                         0,   --ICAPITAL
                           vitotprim,   -- ITOTPRIM
                                     (vcapitalgas *(pgasint / 100)),   -- IGASCAPV /* cap. asseg. en el momento 0 */ ,vcapitalgas /* IPCMORT LA PRIMERA DEL SEGUNDO PERIODO */ )
                         (((vcapitalgas *(pgasint / 100)))
                          *(((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg)))
                             *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                     -anoreserva))))),   --IPGASCAPV :: IGASCAPV * VECVIDA
                         vcapitalmort,   --IPCMORT
                         ((vcapitalmort)
                          *((((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                             -((1
                                - (1 -(p_factor1 / p_factor))
                                  *(1 -(p_factor1seg / p_factorseg)))))
                            *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                    -(anoreserva + 1))))),   --IPPMORT /* ipcmort * vecmort*/
                         0,   -- IPCVID
                         (vitotprim
                          *(((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg)))
                             *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                     -anoreserva))))),   -- IPPVID : VECVIDA * VITOTPRIM
                         psproces);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         anoreserva := anoreserva + 1;
         actuarial := actuarial + 1;
         edad := edad + 1;

         IF (pedad2 IS NOT NULL) THEN
            edad2 := edad2 + 1;
         END IF;

         vcalculo := ADD_MONTHS(vcalculo, 1);
         cont := cont + 1;

         IF (indice >= piniciduraci2) THEN
            vduraci2 := vduraci2 - 1;
         END IF;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat11;

   FUNCTION f_matriz_provmat16(
/***************************************************************************************
      Carrega de la taula MATRIZPROVMATGEN mab totes les columnes necessaries per
      calcular la provisió Matemàtica dels productes ASSP
      En el cas de que hi hagi garantia de mort
***************************************************************************************/
      psseguro IN NUMBER,   -- sseguro
      panyo IN NUMBER,   -- Any de calcul
      pedad IN NUMBER,   -- Edad primer assegurat
      pedad2 IN NUMBER,   -- Edad segon assegurat
      psexo IN NUMBER,   -- sexo del primer asegurado
      psexo2 IN NUMBER,   -- sexo del segon asegurado
      /* Dates per poder calcular el capital assegurat*/
      pefecto IN DATE,   -- fecha efecto
      pcalculo IN DATE,   -- fecha de calculo
      /* DURACIONS*/
      nduraci IN NUMBER,   -- Duració en mesos de la pòlissa
      nduraci1 IN NUMBER,                    /* Duració del primer periode
                             ( En el cas de només hi hagi un prima unica es tracta tot com el primer periode
                            i per tant la nduraci1 serà igual a la duració del prestam. )
                                          */
      piniciduraci2 IN NUMBER,   -- Mesos en que comença el periode 2
      nduraci2 IN NUMBER,                     /* Duració del segon periode
                            ( Aquesta duració pot ser nul·la en el cas de que tot es tracti com un unci periode)
                                           */
      nduraci3 IN NUMBER,   -- L'ultim periode (ja no hi han primas fraccionaris només i han prov. al morir)
      nduracicaren IN NUMBER,   -- Duració del periode de carència
      psproces IN NUMBER,   -- Codi (No serveix per res)
      pinttec IN NUMBER,   -- Interès tècnic que s'aplica
      pgasint IN NUMBER,   -- Porcentatge per gastos
      pctiptab IN NUMBER,   -- Codi de la taula de mortalitat
      ppgasext IN NUMBER,   -- Porcentatge de gastos interns (ve donat en la pòlissa)
      pfpago IN NUMBER,   -- Forma de pagament o d'amortització
      pprimafrac IN NUMBER   -- Primes fraccionaries
                          )
      RETURN NUMBER IS   -- PRAGMA AUTONOMOUS_TRANSACTION;
      actuarial      NUMBER;
      indice         NUMBER;   -- 0.. N meses de duració de la pòlissa
      anoreserva     NUMBER;
      edad           NUMBER;   -- Edat del primer assegurat
      edad2          NUMBER;   -- Edat del segon assegurat
      anyo           NUMBER;   --  Ano de calculo
      vcarencia      NUMBER;   -- si carencia = 1 estamos en el periodo de carencia.
      vprimerperiodo NUMBER;   -- si vprimerperiodo = 1 estamos en el primer periodo si no estamos en el segundo.
      vpiniciduraci2 NUMBER;   -- inici en mesos del segon periode.
      vduraci2       NUMBER;   -- Duració del segon periode.
      /* Valors de la taula de Mortalitat*/
      p_factor       NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel primer assegurat
      p_factorseg    NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel segon assegurat
      p_factor1      NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Primer assegurat)
      p_factor1seg   NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Segon assegurat)
      anyories       NUMBER;
      var_lx1        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Primer assegurat)
      var_lx2        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Segon assegurat)
      var_lmix       NUMBER;   -- Valor en la taula simbolconmu de mortalitat i invalidessa
      var_inv        NUMBER;   -- Valor en la taula simbolconmu d'invalidessa.
      p_lmix         NUMBER;   -- Probabilitat inv/mort a edat fixa.(inici pòlissa)
      vcapitalmort   NUMBER;   -- Capital assegurat per la part de prestacions la morir.
      vcapitalmort_aux NUMBER;
      vcapitalgas    NUMBER;   -- Capital assegurat per la part de gastos.
      vcapitalgas_aux NUMBER;
      /* Per poder treballar amb les dates per le capital assegurat i ipcmort */
      vdia           NUMBER;
      vmes           NUMBER;
      vany           NUMBER;
      vmeses         NUMBER;
      vcalculo       DATE;
      vaux           DATE;
      vfprimerperiode DATE;
      vfsegonperiode DATE;
      v_primeranyo   DATE;
      vfprimerperiode_gas DATE;
      vfsegonperiode_gas DATE;
      vpmort         DATE;
      vpgastos       DATE;
      vaux1          DATE;
      vcontanual     NUMBER;   -- Per saber en quin any ens trobem
      cont           NUMBER;
      -- part prima fraccionaria
      vitotprim      NUMBER;   -- Import de la prima fraccionaria
      vcontpag       NUMBER;   -- contador per saber quan ha de pagar . Forma de pagament
      vfpago         NUMBER;   -- Forma de pagament
   BEGIN
      vduraci2 := nduraci2;
      vpiniciduraci2 := piniciduraci2;
      vcontpag := 0;
      cont := 0;
      vcontanual := 1;
      vmes := TO_NUMBER(TO_CHAR(pefecto, 'MM'));
      vdia := TO_NUMBER(TO_CHAR(pefecto, 'DD'));
      vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));

      IF (vmes = 1
          OR vmes = 3
          OR vmes = 5
          OR vmes = 7
          OR vmes = 8
          OR vmes = 10
          OR vmes = 12) THEN
         vdia := 31;
      ELSE
         IF (vmes = 2) THEN
            vdia := 28;
         ELSE
            vdia := 30;
         END IF;
      END IF;

      -- Tenim la data d'efecte i on finalitza el primer periode
      vaux := TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                      'dd/mm/yyyy');
      vaux1 := ADD_MONTHS(TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                                  'dd/mm/yyyy'),
                          12);
      vfsegonperiode := vaux;

      -- Mesos que hi ha des de la data efecte fins que finalitza el primer periode
      -- El primer periode depent de la forma de pago.
      /* SON NATURALS S'HA DE MODIFICAR */
      IF (pfpago = 12
          OR pfpago = 0) THEN   -- MENSUAL
         vfpago := 12;
         vmes := TO_NUMBER(TO_CHAR(pefecto, 'MM'));
         vdia := TO_NUMBER(TO_CHAR(pefecto, 'DD'));
         vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));

         IF (vmes = 1
             OR vmes = 3
             OR vmes = 5
             OR vmes = 7
             OR vmes = 8
             OR vmes = 10
             OR vmes = 12) THEN
            vdia := 31;
         ELSE
            IF (vmes = 2) THEN
               vdia := 28;
            ELSE
               vdia := 30;
            END IF;
         END IF;

         v_primeranyo := TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                                 'dd/mm/yyyy');
         vmeses := ROUND(((v_primeranyo - pefecto) / 365.25) * 12);
      END IF;

      IF (pfpago = 1) THEN   -- ANUAL
         vfpago := 1;
         vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));
         v_primeranyo := TO_DATE(31 || '/' || 12 || '/' || TO_CHAR(vany), 'dd/mm/yyyy');
         vmeses := ROUND(((v_primeranyo - pefecto) / 365.25) * 12);
      END IF;

      IF (pfpago = 3) THEN   -- TRIMESTRAL --4
         vfpago := 3;
         vmes := TO_NUMBER(TO_CHAR(pefecto, 'MM'));

         IF (vmes <= 3) THEN
            vmes := 3;
         ELSE
            IF (vmes > 3
                AND vmes <= 6) THEN
               vmes := 6;
            ELSE
               vmes := 12;
            END IF;
         END IF;

         vdia := TO_NUMBER(TO_CHAR(pefecto, 'DD'));
         vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));

         IF (vmes = 1
             OR vmes = 3
             OR vmes = 5
             OR vmes = 7
             OR vmes = 8
             OR vmes = 10
             OR vmes = 12) THEN
            vdia := 31;
         ELSE
            IF (vmes = 2) THEN
               vdia := 28;
            ELSE
               vdia := 30;
            END IF;
         END IF;

         v_primeranyo := TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                                 'dd/mm/yyyy');
         vmeses := ROUND(((v_primeranyo - pefecto) / 365.25) * 12);
      END IF;

      IF (pfpago = 2) THEN   -- SEMESTRAL
         vfpago := 6;
         vmes := TO_NUMBER(TO_CHAR(pefecto, 'MM'));

         IF (vmes <= 6) THEN
            vmes := 6;
         ELSE
            vmes := 12;
         END IF;

         vdia := TO_NUMBER(TO_CHAR(pefecto, 'DD'));
         vany := TO_NUMBER(TO_CHAR(pefecto, 'YYYY'));

         IF (vmes = 12) THEN
            vdia := 31;
         ELSE
            vdia := 30;
         END IF;

         v_primeranyo := TO_DATE(TO_CHAR(vdia) || '/' || TO_CHAR(vmes) || '/' || TO_CHAR(vany),
                                 'dd/mm/yyyy');
         vmeses := ROUND(((v_primeranyo - pefecto) / 365.25) * 12);
      END IF;

/*  PRIMER BUCLE DES DE EL MES 0 FINS EL MES DE CÀLCUL.( PRIMER PERIODE )  */
      indice := 0;
      edad := pedad;
      edad2 := pedad2;
      anyories := panyo;
      anyo := 0;
      vcalculo := pcalculo;

      -- Calculs abans de l'any de calcul
      FOR anyo IN 0 ..(anyories - 1) LOOP
         /* PRESTACIONS AL MORIR */
         BEGIN
            --  Mentres estem en el primer periode es igual a la data d'efecte
            IF (anyo < vmeses) THEN   -- Estem dins el primer periode és mensual
               vcapitalmort := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                        vcalculo);
               vcontanual := 1;
               cont := 0;
            -- si no estem dins el primer periode fem la mitja per any.
            -- Pot haver periode carencia
            ELSE
               IF (vcontanual = 1
                   AND cont < 12) THEN
                  vfprimerperiode := vaux;
                  vfsegonperiode := vaux1;
               END IF;

               IF (cont = 12) THEN
                  IF (pfpago = 3) THEN   --TRIMESTRAL ha de ser un 4
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 4);
                  END IF;

                  IF (pfpago = 12
                      OR pfpago = 0) THEN   -- MENSUAL O UNICA
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 1);
                  END IF;

                  IF (pfpago = 2) THEN   -- SEMESTRAL
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 6);
                  END IF;

                  IF (pfpago = 1) THEN   -- ANUAL
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 12);
                  END IF;

                  vfsegonperiode := ADD_MONTHS(vfprimerperiode, 12);
                  cont := 0;
                  vcontanual := vcontanual + 1;
               END IF;

               vcapitalmort := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                        vfprimerperiode);
               vcapitalmort_aux := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                            vfsegonperiode);
               vcapitalmort := (vcapitalmort_aux + vcapitalmort) / 2;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalmort := 0;
         END;

         vitotprim := 0;

         /* PRIMA UNICA  O PRIMA FRACCIONARIA */
         IF (pprimafrac IS NOT NULL) THEN   -- S'ha de mirar la forma de pagament
            IF (vmeses = indice) THEN
               vitotprim := pprimafrac *(1 -(ppgasext / 100));   --Prima fraccionaria menos % de gastos
               vcontpag := 0;
            ELSE
               IF (vcontpag = vfpago) THEN
                  vcontpag := 0;
                  vitotprim := pprimafrac *(1 -(ppgasext / 100));   --Prima fraccionaria menos % de gastos
               ELSE
                  vcontpag := vcontpag + 1;
               END IF;
            END IF;
         ELSE
            vitotprim := 0;
         END IF;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lmix, tpmix, pfalle, pinv,
                         lx1, lx2, tpx1, tpx2, tpxi, tsumpx1, tsumpx2, tsumpxi, tqx, vn, vn2,
                         vecvida, vecmort, icapital, itotprim, igascapv, ipgascapv, ipcmort,
                         ippmort, ipcvid, ippvid, ipinvmort, sproces)
                 VALUES (indice, edad, edad2, NULL, 0, 0, 0, 0,
                         0, 0, 0,   -- tpx1
                                 0,   -- tpx2
                                   0,   -- tpxi
                                     0,   -- tsumpx1
                                       0,   -- tsumpx2
                                         0,   -- tsumpxi
                                           0,   -- tqx
                                             0,   -- vn
                                               0,   -- vn2
                         0,   -- vecvida
                           0,   -- vecmort
                             0,   --icapital
                               0,   --decode(indice,0,piprimuni,0) ,--ittotprim
                                 0,   --igascapv
                                   0,   --ipgascapv
                                     vcapitalmort,   -- ipcmort
                         0,   --ippmort
                           0,   --ipcvida
                             0,   --ippvid
                               0,   -- IPINVMORT
                                 psproces);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         edad := edad + 1;

         IF (pedad2 IS NOT NULL) THEN
            edad2 := edad2 + 1;
         END IF;

         vcalculo := ADD_MONTHS(vcalculo, 1);
         cont := cont + 1;

         IF (indice >= piniciduraci2) THEN
            vduraci2 := vduraci2 - 1;
         END IF;
      END LOOP;

       /*
          COMENÇA BUCLE DES DE EL MES DE CALCUL FINS EL fINAL :
          Tenim en compte la carencia i la forma de pagament
      */
      anoreserva := 0;
      anyo := anyories;

      BEGIN   -- Calculem el valor de mortalitat per l'edat de l'assegurat en l'any de calcul
         p_factor := 0;
         p_factorseg := 0;

         SELECT /*+ index(mortalidad,mortalidad_pk)*/
                DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = edad
            AND ctabla = pctiptab;

         SELECT DECODE(psexo, 1, ly, 2, lx, 0)
           INTO p_lmix
           FROM simbolconmu
          WHERE nedad = edad
            AND ctabla = pctiptab
            AND pinttec = 0;

         IF (pedad2 IS NOT NULL) THEN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
              INTO p_factorseg
              FROM mortalidad
             WHERE nedad = edad2
               AND ctabla = pctiptab;
         ELSE
            p_factorseg := 1;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107108;
      END;

      vfprimerperiode_gas := vaux;
      vfsegonperiode_gas := vaux1;
      actuarial := 0;

      FOR anyo IN anyories .. nduraci1 LOOP
         anyories := 0;

         BEGIN
            var_lx1 := 0;
            var_lx2 := 0;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO var_lx1
              FROM mortalidad
             WHERE nedad = edad
               AND ctabla = pctiptab;

            var_lmix := 0;

            SELECT DECODE(psexo, 1, lx, 2, ly, 0), iy
              INTO var_lmix, var_inv   -- Si es un hombre lx, sino ly
              FROM simbolconmu
             WHERE nedad = edad
               AND ctabla = pctiptab;

            IF (pedad2 IS NOT NULL) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO var_lx2
                 FROM mortalidad
                WHERE nedad = edad2
                  AND ctabla = pctiptab;
            ELSE
               var_lx2 := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         BEGIN
            p_factor1 := 0;
            p_factor1seg := 0;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;

            IF (pedad2 IS NOT NULL) THEN
               SELECT /*+ index(mortalidad,mortalidad_pk)*/
                      DECODE(psexo2, 1, vmascul, 2, vfemeni, 0)
                 INTO p_factor1seg
                 FROM mortalidad
                WHERE nedad = edad2 + 1
                  AND ctabla = pctiptab;
            ELSE
               p_factor1seg := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107108;
         END;

         /* Capital assegurat per la part de prestacions al morir */
         BEGIN   /*   S'ha de tenir en compte les dates  */
            --  Mentres estem en el primer periode
            IF (anyo < vmeses) THEN   -- Estem dins el primer periode és mensual
               vcapitalmort := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                        vaux);
               vcontanual := 1;
               cont := 0;
            -- si no estem dins el primer periode fem la mitja per any.
            -- Pot haver periode carencia
            ELSE
               IF (vcontanual = 1
                   AND cont < 12) THEN
                  vfprimerperiode := vaux;
                  vfsegonperiode := vaux1;
               END IF;

/*********************************************/
               IF (cont = 12) THEN
                  IF (pfpago = 3) THEN   --TRIMESTRAL ha de ser un 4
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 4);
                  END IF;

                  IF (pfpago = 12
                      OR pfpago = 0) THEN   -- MENSUAL O UNICA
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 1);
                  END IF;

                  IF (pfpago = 2) THEN   -- SEMESTRAL
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 6);
                  END IF;

                  IF (pfpago = 1) THEN   -- ANUAL
                     vfprimerperiode := ADD_MONTHS(vfsegonperiode, 12);
                  END IF;

                  vfsegonperiode := ADD_MONTHS(vfprimerperiode, 12);
                  cont := 0;
                  vcontanual := vcontanual + 1;
               END IF;

               vcapitalmort := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                        vfprimerperiode);
               vcapitalmort_aux := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                            vfsegonperiode);
               vcapitalmort := (vcapitalmort_aux + vcapitalmort) / 2;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalmort := 0;
         END;

         /* CAPITAL ASSEGURAT PER LA PART DE GASTOS */
         BEGIN
            IF (nduracicaren IS NOT NULL) THEN
               vcapitalgas := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                       vaux);
            ELSE
               vcapitalgas := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                       vaux);
               vcapitalgas_aux := pk_cuadro_amortizacion.capital_pendiente(psseguro, pefecto,
                                                                           vaux1);
               vcapitalgas := (vcapitalgas + vcapitalgas_aux) / 2;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalgas := 0;
         END;

         vitotprim := 0;

         /* PRIMA UNICA  O PRIMA FRACCIONARIA */
         IF (pprimafrac IS NOT NULL) THEN   -- S'ha de mirar la forma de pagament
            IF (vmeses = indice) THEN
               vitotprim := pprimafrac *(1 -(ppgasext / 100));   --Prima fraccionaria menos % de gastos
               vcontpag := 0;
            ELSE
               IF (vcontpag = vfpago) THEN
                  vcontpag := 0;
                  vitotprim := pprimafrac *(1 -(ppgasext / 100));   --Prima fraccionaria menos % de gastos
               ELSE
                  vcontpag := vcontpag + 1;
               END IF;
            END IF;
         ELSE
            vitotprim := 0;
         END IF;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2,
                         lmix, pfalle, pinv,
                         tpx1,
                         tpx2, tpxi, tpmix,
                         tsumpx1, tsumpx2,
                         tsumpxi,
                         tqx,
                         vn,
                         vn2,
                         vecvida,
                         vecmort,
                         vecinv,
                         icapital, itotprim, igascapv,
                         ipgascapv,
                         ipcmort,
                         ippmort,
                         ipcvid,
                         ippvid,
                         ipinvmort,
                         sproces)
                 VALUES (indice, edad, edad2, actuarial, 0 /*var_lx1*/, 0 /* var_lx2 */,   -- No hi ha probabitat de mortalitat
                         var_lmix,   -- LMIX
                                  0 /*var_lx1/p_factor */,   -- TPX1
                                                          0 /*var_lx2/p_factorseg*/,   -- TPX2
                         0 /*(1- (1- (var_lx1/p_factor))*(1- (var_lx2/p_factorseg) ))*/,   --TPXI
                         var_lmix / p_lmix,   --TPMIX
                                           (var_lx1 - p_factor1) / var_lx1,   -- PFALLE
                                                                           var_inv,   -- PINV
                         0 /*p_factor1/p_factor */,   --TPSUMPX1
                                                   0 /*p_factor1seg/p_factorseg*/,   --TSUMPX2
                         (1 -((1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg)))),   -- TSUMPXI
                         (((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg))))
                          -(1 -((1 -(p_factor1 / p_factor)) *(1 -(p_factor1seg / p_factorseg))))),   --TQX
                         POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)), -anoreserva),   --VN
                         POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                               -(anoreserva + 1)),   --VN2
                         ((var_lmix / p_lmix)
                          *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                  -anoreserva))),   --VECVIDA : VN * TPMIX
                         ((POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                 -(anoreserva + 1)))
                          *((var_lx1 - p_factor1) / var_lx1) *(var_lmix / p_lmix)),   -- VECMORT : VN2 * PFALLE * TPMIX
                         ((var_lmix / p_lmix) *(var_inv)
                          *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                  -(anoreserva + 1)))),   -- VECINV : TPMIX * PINV * VN2
                         0,   --ICAPITAL
                           vitotprim,   -- ITOTPRIM
                                     (vcapitalgas *(pgasint / 100)),   -- IGASCAPV /* cap. asseg. en el momento 0 */ ,vcapitalgas /* IPCMORT LA PRIMERA DEL SEGUNDO PERIODO */ )
                         (((vcapitalgas *(pgasint / 100)))
                          *(((1 - (1 -(var_lx1 / p_factor)) *(1 -(var_lx2 / p_factorseg)))
                             *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                     -anoreserva))))),   --IPGASCAPV :: IGASCAPV * VECVIDA
                         vcapitalmort,   --IPCMORT
                         (vcapitalmort
                          *(((POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                    -(anoreserva + 1)))
                             *((var_lx1 - p_factor1) / var_lx1) *(var_lmix / p_lmix)))),   --IPPMORT /* ipcmort * vecmort*/
                         0,   -- IPCVID
                         ((vitotprim)
                          *(((var_lmix / p_lmix)
                             *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                     -anoreserva))))),   -- IPPVID : PRIMA PERIODICA * VECTOR VIDA
                         (vcapitalmort
                          *(((POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                    -(anoreserva + 1)))
                             *((var_lx1 - p_factor1) / var_lx1) *(var_lmix / p_lmix)))),   -- IPINVMORT : PRESTACI. AL MORT * VECTOR MORT
                         psproces);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 107109;
         END;

         indice := indice + 1;
         anoreserva := anoreserva + 1;
         actuarial := actuarial + 1;
         edad := edad + 1;

         IF (pedad2 IS NOT NULL) THEN
            edad2 := edad2 + 1;
         END IF;

         vcalculo := ADD_MONTHS(vcalculo, 1);
         cont := cont + 1;

         IF (indice >= piniciduraci2) THEN
            vduraci2 := vduraci2 - 1;
         END IF;
      END LOOP;

      RETURN 0;
   END f_matriz_provmat16;

   FUNCTION f_matriz_provmat17(
/***************************************************************************************
      Carrega de la taula MATRIZPROVMATGEN  amb totes les columnes corresponents
      per poder calcular el vector vida i l' import brut de la renda.
***************************************************************************************/
      panyo IN NUMBER,   -- Any de calcul
      pedad IN NUMBER,   -- Edad primer assegurat
      psexo IN NUMBER,   -- sexo del primer asegurado
      nduraci IN NUMBER,   -- Duració en mesos de la pòlissa
      psproces IN NUMBER,   -- Codi (No serveix per res)
      pinttec IN NUMBER,   -- Interès tècnic que s'aplica (a nivell de producte)
      piprimuni IN NUMBER,   -- Prima unica ( Provisió matematica el dia abans del venciment de la polissa)
      pctiptab IN NUMBER,   -- Codi de la taula de mortalitat segons el producte
      ppgasint IN NUMBER,   -- Porcentatge de gastos interns (a nivell de producte)
      estat IN NUMBER,   -- Si és un 1 --> Provisió matematica
                         -- Si és un 0 --> Import brut de la renda
      psseguro IN NUMBER   -- seguro
                        )
      RETURN NUMBER IS   -- PRAGMA AUTONOMOUS_TRANSACTION;
      vprov1_aux     NUMBER;
      actuarial      NUMBER;
      indice         NUMBER;   -- 0.. N meses de duració de la pòlissa
      anoreserva     NUMBER;
      edad           NUMBER;   -- Edat del primer assegurat
      anyo           NUMBER;   --  Ano de calculo
      /* Valors de la taula de Mortalitat*/
      p_factor       NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel primer assegurat
      p_factorseg    NUMBER;   -- Valor en la taula de mortalitat de l'edad de càlcul pel segon assegurat
      p_factor1      NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Primer assegurat)
      p_factor1seg   NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Segon assegurat)
      anyories       NUMBER;
      var_lx1        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Primer assegurat)
      var_lx2        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Segon assegurat)
      vvecvida       NUMBER;   -- Sumatori del vector vida.
      num_err        NUMBER;   -- Control d'erors
      resultado      NUMBER;
      vigas          NUMBER;
      vaux           NUMBER;
   BEGIN
      indice := 0;
      edad := pedad;
      anyories := panyo;
      anyo := 0;

      BEGIN
         DELETE FROM matrizprovmatgen
               WHERE cindice > -1;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- Calculem el valor de la taula de mortalitat per l'edat del primer assegurat
      BEGIN
         SELECT /*+ index(mortalidad,mortalidad_pk)*/
                DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = pedad
            AND ctabla = pctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN -2;
      END;

      -- Calculs abans de l'any de calcul: Només tindrem les probabilitats.
      FOR anyo IN 0 ..(anyories - 1) LOOP
         -- Seleccionem el valor en la taula de mortalitat que correspon
         -- a l'edat en l'any en el que fem els calculs.
         BEGIN
            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO var_lx1
              FROM mortalidad
             WHERE nedad = edad
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2, tpx1, tpx2, tpxi,
                         tsumpx1, tsumpx2, tsumpxi, tqx, vn, vn2, vecvida, vecmort, icapital,
                         itotprim, igascapv, ipgascapv, ipcmort, ippmort, ipcvid, ippvid,
                         sproces)
                 VALUES (indice, edad, NULL, NULL, var_lx1, NULL, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0,
                         psproces);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         indice := indice + 1;
         edad := edad + 1;
      END LOOP;

      -- A partir de l'any de calcul
      anoreserva := 0;
      anyo := anyories;

      -- Calculem el valor de mortalitat per l'edat de l'assegurat en l'any de calcul
      BEGIN
         p_factor := 0;
         p_factorseg := 0;

         SELECT /*+ index(mortalidad,mortalidad_pk)*/
                DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor
           FROM mortalidad
          WHERE nedad = edad
            AND ctabla = pctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN -5;
      END;

      actuarial := 0;

      FOR anyo IN anyories .. nduraci LOOP
         anyories := 0;

         BEGIN
            var_lx1 := 0;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO var_lx1
              FROM mortalidad
             WHERE nedad = edad
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            p_factor1 := 0;
            p_factor1seg := 0;

            SELECT /*+ index(mortalidad,mortalidad_pk)*/
                   DECODE(psexo, 1, vmascul, 2, vfemeni, 0)
              INTO p_factor1
              FROM mortalidad
             WHERE nedad = edad + 1
               AND ctabla = pctiptab;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            INSERT INTO matrizprovmatgen
                        (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2, tpx1, tpx2,
                         tpxi, tsumpx1, tsumpx2, tsumpxi, tqx,
                         vn,
                         vn2,
                         vecvida,
                         vecmort, icapital, itotprim, igascapv, ipgascapv, ipcmort, ippmort,
                         ipcvid, ippvid, sproces)
                 VALUES (indice, edad, NULL, actuarial, var_lx1, NULL, var_lx1 / p_factor,   -- TPX1
                                                                                          0,   --TPX2  (No existeix : Només tenim un assegurat )
                         var_lx1 / p_factor,   -- TPXI
                                            0,   -- TSUMPX1
                                              0,   -- TSUMPX2
                                                0,   -- TSUMPXI
                                                  0,   -- TQX
                         POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)), -anoreserva),   --VN
                         0,   -- VN2
                         ((var_lx1 / p_factor)
                          *(POWER((1 +((POWER((1 +(pinttec / 100)),(1 / 12))) - 1)),
                                  -anoreserva))),   -- VECVIDA ((p_factor1/p_factor)*(  POWER((1 + ((POWER( (1+(pinttec/100)),(1/12)))-1) ),- anoreserva)))
                         0,   -- VECMORT
                           0,   -- ICAPITAL
                             0,   -- ITOTPRIM
                               0,   -- IGASCAPV
                                 0,   -- IPGASCAPV
                                   0,   -- IPPCMORT
                                     0,   -- IPPMORT
                         0,   -- IPCVID
                           0,   -- IPPVID
                             psproces);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         indice := indice + 1;
         anoreserva := anoreserva + 1;
         actuarial := actuarial + 1;
         edad := edad + 1;
      END LOOP;

      num_err := 0;
      -- Tenim el sumatori del vector vida
      vvecvida := 0;

      BEGIN
         SELECT SUM(vecvida)
           INTO vvecvida
           FROM matrizprovmatgen
          WHERE cindice > -1;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := -9;
      END;

      -- Anem a calcular la provisió per gastos
      BEGIN
         UPDATE matrizprovmatgen
            SET igascapv =(ppgasint / 100);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := -10;
      END;

      -- Seleccionem l'import brut de la renta
      BEGIN
         SELECT ibruren
           INTO vprov1_aux
           FROM seguros_ren
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            vprov1_aux := 1;
            NULL;
      END;

      FOR i IN 0 .. nduraci LOOP
         BEGIN
            -- Provisió per gastos mientras viva.( Antes del ano de calculo 0,(El vector vida sera cero))
            UPDATE matrizprovmatgen
               SET ipgascapv = (SELECT (vecvida * igascapv * vprov1_aux)
                                  FROM matrizprovmatgen
                                 WHERE sproces = psproces
                                   AND cindice = i)
             WHERE sproces = psproces
               AND cindice = i;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := -11;
         END;
      END LOOP;

      -- CALCULEM L'IMPORT BRUT DE LA RENDA (El guardem a la variable resultado)
      BEGIN
         SELECT ibruren
           INTO resultado
           FROM seguros_ren
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            resultado := 0;
      END;

      IF (resultado = 0) THEN
         BEGIN
            SELECT SUM(ipgascapv)
              INTO resultado
              FROM matrizprovmatgen
             WHERE sproces = psproces;

            resultado := piprimuni /(resultado + vvecvida);   -- ( Provisió mat. el dia d'abans de venciment / prov.gastos + sumatori vec. vida)
         EXCEPTION
            WHEN OTHERS THEN
               num_err := -12;
         END;
      END IF;

      -- CALCULEM LA PROVISIÓ MATEMATICA
      IF (estat = 1) THEN
         BEGIN
            UPDATE matrizprovmatgen
               SET ipcvid = resultado
             WHERE sproces = psproces;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         FOR i IN 0 .. nduraci LOOP
            BEGIN
               UPDATE matrizprovmatgen
                  SET ippvid = (SELECT ipcvid * vecvida
                                  FROM matrizprovmatgen
                                 WHERE cindice = i
                                   AND sproces = psproces)
                WHERE sproces = psproces
                  AND cindice = i;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END LOOP;

         BEGIN
            SELECT SUM(ippvid) + SUM(ipgascapv)
              INTO resultado
              FROM matrizprovmatgen
             WHERE sproces = psproces;
         EXCEPTION
            WHEN OTHERS THEN
               resultado := -4;
         END;
      END IF;

      RETURN resultado;
   END f_matriz_provmat17;

   FUNCTION f_matriz_provmat_acumulat(psseguro IN NUMBER, f_calcul_pm IN DATE)
      RETURN NUMBER IS
/**************************************************************************************/
/**************************************************************************************/
/*                                                                  */
/*    Funcio que calcula la provisio matemàtica de l'assegurança PSSEGURO  a data        */
/* F_CALCUL_PM. El PSSEGURO ha de ser d'un producte PIG, PEG, PLA18, PPP, PIP, PJP   */
/*                                                                        */
/*    Per fer-ho es busca a CTASEGURO la provisio matemàtica del mes anterior         */
/*    sino existeix mira que el mes i l'any de la data de càlcul coincideixi amb la     */
/*  d'efecte (Es tracta d'una assegurança nova).                                      */
/*  Si no existeix és error                                                        */
/*                                                                        */
/*  INPUT         PSSEGURO          Número d'assegurança                  */
/*             F_CALCUL_PM       Data de càlcul                           */
/*                                                               */
/*    OUTPUT            <0                ERROR                                 */
/*                                                               */
/* ERRORS -50 Data de càlcul superior a la data de venciment                    */
/*       -52 Error al buscar la Provisió Matmètica del mes anterior             */
/*         -53 No es troba l'interes a la taula INTERESPROD                     */
/*       -54 Error a la búsqueda de la taula SEGUROS_AHO                     */
/*       -55 Error a la funcio C_InteresTecnic                               */
/*       -56 Error al insertar a MATRIZPROVMATGEN                              */
/*                                                                        */
/**************************************************************************************/
/**************************************************************************************/
      pinttec        NUMBER;
      psexo          NUMBER;   -- Sexe del primer assegurat
      psexo1         NUMBER;   -- Sexe del segon assegurat
      psproces       NUMBER;   -- Codi del proces
      num_err        NUMBER;
      contador       NUMBER;
      actividad      NUMBER;
      cont           NUMBER;
      fnacimi1       DATE;
      fnacimi2       DATE;
      it1p           seguros_aho.pinttec%TYPE;   --Interès tècnic primer periode
--  pFEIMTEC                    SEGUROS_AHO.FEIMTEC%TYPE;      --Data de finalització del primer periode
  --
      k_icapmaxaseguradopta garanpro.icapmax%TYPE := 2000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
      k_icapmaxasegurado2pta garanpro.icapmax%TYPE := 5000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
      k_icapmaxasegurado65pta garanpro.icapmax%TYPE := 100000;   --Capital Màxim Assegurat als 65 anys fixat a 100000 PTA
      k_icapmaxasegurado garanpro.icapmax%TYPE := 2000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
      k_icapmaxasegurado2 garanpro.icapmax%TYPE := 5000000;   --Capital Màxim Assegurat fixat a 5000000 PTA
      k_icapmaxasegurado65 garanpro.icapmax%TYPE := 100000;   --Capital Màxim Assegurat als 65 anys fixat a 100000 PTA
      --
      pta            BOOLEAN;   --Cert Producte en pessetes, sino en euros
      p_data_pm_inicial DATE;   --Data de la primera provisio matmàtica
      p_pm_inicial   NUMBER;   --Provisio matemàtica d ela data  p_Data_PM_Inicial
      --
      k_euros_pta    NUMBER := 166.386;   --Canvi de PTA a Euros
      k_des_ext_risc NUMBER := 1;   --Despeses Externes de Risc
      k_int_tec_risc NUMBER := 4;   --Interes tècnic de risc
      k_por_cap_risc NUMBER := 0.1;   --% Capital de Riesgo
      p_cdivisa      NUMBER;
      psproduc       NUMBER;

-----------------
-- CURSORS
-----------------
-- CURSOR QUE AGAFA TOTES LES DADES DE LA PòLISSA
      CURSOR c_polizas_provmat IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, p.pinttec,
                NVL(s.fcaranu, s.fvencim) ffinal, s.fefecto, s.ncertif, s.nduraci nduraci,
                p.pgasint, p.pgasext, s.cactivi, s.cforpag, s.fvencim, p.pgaexin, p.pgaexex,
                p.cdivisa
           FROM productos p, seguros s
          WHERE s.sseguro = psseguro
            AND p.ctipseg = s.ctipseg
            AND p.cmodali = s.cmodali
            AND p.cramo = s.cramo
            AND p.ccolect = s.ccolect
            AND s.csituac <> 4;

                --AND s.fefecto <= F_CALCUL_PM;
      -- SELECCIONEM LES GARANTIES VIGENTS DE LA POLISSA QUE CALCULEN PROVISIONS MATEMàTICAS
      CURSOR c_garantias_provmat(
         seguro NUMBER,
         p_ramo NUMBER,
         p_modalidad NUMBER,
         p_tipseg NUMBER,
         p_colect NUMBER) IS
         SELECT cprovis, ctabla
           FROM garanpro
          WHERE cramo = p_ramo
            AND cmodali = p_modalidad
            AND ctipseg = p_tipseg
            AND ccolect = p_colect
            AND cgarant = 283;

      -- CURSOR QUE AGAFA LA DATA DE NAIXAMENT I EL SEXE DE LES PERSONES ASEGURADES.
      CURSOR c_personas(seguro NUMBER) IS
         SELECT p.fnacimi, p.csexper
           FROM personas p, asegurados s
          WHERE s.sseguro = seguro
            AND p.sperson = s.sperson;

      --APORTACIONS
      --CALCULA LES APORTACIONS REALITZADES PER L'ASSEGURANçA PSSEGURO ENTRE LES DATES F_INI I F_FINAL
      CURSOR c_aportacions(psseguro NUMBER, f_ini DATE, f_final DATE) IS
         SELECT imovimi, ffecmov, fvalmov
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND(cmovimi = 1
                OR cmovimi = 2
                OR cmovimi = 4)   --1,2,4 APORTACIONS
            AND(TO_CHAR(ffecmov, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini, 'YYYYMMDD')
                                                 AND TO_CHAR(f_final, 'YYYYMMDD')
                OR(TO_CHAR(fcontab, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini, 'YYYYMMDD')
                                                    AND TO_CHAR(f_final, 'YYYYMMDD')
                   AND TO_CHAR(ffecmov, 'YYYYMM') <=
                                              TO_CHAR(ADD_MONTHS(LAST_DAY(f_ini), -1),
                                                      'YYYYMM')))
            --AND CMOVANU!=1                                 --EL MOVIMENT NO HA ESTAT ANULAT
            AND nnumlin != 1;   --Em salto el primer rebut

      --RESCATS
      --CALCULA EL RESCATS REALITZATS PER L'ASSEGURANçA PSSEGURO ENTRE LES DATES F_INI I F_FINAL
      CURSOR c_rescats(psseguro NUMBER, f_ini DATE, f_final DATE) IS
         SELECT imovimi, fvalmov
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND(cmovimi = 33
                OR cmovimi = 34
                OR cmovimi = 27)   --33,34 RESCATS (TOAL, PARCIAL) O 27 PENALITZACIO
            AND(TO_CHAR(ffecmov, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini, 'YYYYMMDD')
                                                 AND TO_CHAR(f_final, 'YYYYMMDD')
                OR(TO_CHAR(fcontab, 'YYYYMMDD') BETWEEN TO_CHAR(f_ini, 'YYYYMMDD')
                                                    AND TO_CHAR(f_final, 'YYYYMMDD')
                   AND TO_CHAR(ffecmov, 'YYYYMM') <=
                                              TO_CHAR(ADD_MONTHS(LAST_DAY(f_ini), -1),
                                                      'YYYYMM')));

              --AND cmovanu!=1;                                --El moviment no ha estat anulat
      --RETORNA LA PRIMERA APORTACIO I LA DATA D'AQUESTA
      CURSOR c_primeraaportacio(psseguro NUMBER, pfefecto DATE) IS
         SELECT   imovimi
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND cmovimi = 1   --1,2,4 APORTACIONS
              AND cmovanu != 1   --EL MOVIMENT NO HA ESTAT ANULAT
              AND TO_CHAR(fvalmov, 'YYYYMMDD') = TO_CHAR(pfefecto, 'YYYYMMDD')
         ORDER BY fvalmov, nnumlin;

-----------------
--FUNCIONS
-----------------
--FUNCIO QUE RETORNA LA PM A DATA D'ENTRADA
      FUNCTION pm_a_data_inicial(p_data_pm DATE, p_sseguro seguros.sseguro%TYPE)
         RETURN NUMBER IS
      BEGIN
         SELECT imovimi
           INTO p_pm_inicial
           FROM ctaseguro
          WHERE sseguro = p_sseguro
            AND cmovimi = 0   -- 0 SALDO
            AND fvalmov = p_data_pm
            AND cmovanu != 1;

         RETURN(p_pm_inicial);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN SQLCODE;
      --    RETURN (-52);
      END;

      --CALCULA INTERèS TèCNIC
      FUNCTION c_interestecnic(periode IN DATE, p_seguro IN seguros.sseguro%TYPE)
         RETURN NUMBER IS
         it             interesprod.pinttot%TYPE;
         p_cramo        seguros.cramo%TYPE;
         p_ccolect      seguros.ccolect%TYPE;
         p_ctipseg      seguros.ctipseg%TYPE;
         p_cmodali      seguros.cmodali%TYPE;
      BEGIN
         SELECT cramo, ccolect, ctipseg, cmodali
           INTO p_cramo, p_ccolect, p_ctipseg, p_cmodali
           FROM seguros
          WHERE sseguro = p_seguro;

         SELECT NVL(pinttot, 0)
           INTO it
           FROM interesprod
          WHERE cramo = p_cramo
            AND ccolect = p_ccolect
            AND ctipseg = p_ctipseg
            AND cmodali = p_cmodali
            AND finivig <= periode
            AND(ffinvig > periode
                OR ffinvig IS NULL);

         RETURN it;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(-55);
      END;

      FUNCTION insertamatrizprovmatgen(
         cindice IN matrizprovmatgen.cindice%TYPE,
         nmeses1 IN matrizprovmatgen.nmeses1%TYPE,
         lx1 IN matrizprovmatgen.lx1%TYPE,
         tpx1 IN matrizprovmatgen.tpx1%TYPE,
         tpxi IN matrizprovmatgen.tpxi%TYPE,
         tsumpx1 IN matrizprovmatgen.tsumpx1%TYPE,
         tsumpxi IN matrizprovmatgen.tsumpxi%TYPE,
         tqx IN matrizprovmatgen.tqx%TYPE,
         vn IN matrizprovmatgen.vn%TYPE,
         vn2 IN matrizprovmatgen.vn2%TYPE,
         vecvida IN matrizprovmatgen.vecvida%TYPE,
         vecmort IN matrizprovmatgen.vecmort%TYPE,   --VECMORT,
         icapital IN matrizprovmatgen.icapital%TYPE,   --ICAPITAL,
         ipcmort IN matrizprovmatgen.ipcmort%TYPE,   --IPCMORT,
         ippmort IN matrizprovmatgen.ippmort%TYPE,   --IPPMORT,
         ipcvid IN matrizprovmatgen.ipcvid%TYPE,   --IPCVID,
         ippvid IN matrizprovmatgen.ippvid%TYPE,   --IPPVID,
         sproces IN matrizprovmatgen.sproces%TYPE)   --SPROCES
         RETURN NUMBER IS
      BEGIN
         DELETE      matrizprovmatgen
               WHERE cindice = 0;

         INSERT INTO matrizprovmatgen
                     (cindice, nmeses1, lx1, tpx1, tpxi, tsumpx1, tsumpxi, tqx, vn, vn2,
                      vecvida, vecmort, icapital, ipcmort, ippmort, ipcvid, ippvid, sproces)
              VALUES (cindice, nmeses1, lx1, tpx1, tpxi, tsumpx1, tsumpxi, tqx, vn, vn2,
                      vecvida, vecmort,   --PRIMA RISC ,
                                       icapital, ipcmort, ippmort,   --DESPESES GESTIO INTERNA ,
                                                                  ipcvid,   --DESPESES GESTIO EXTERNA INTERNA,
                                                                         ippvid,   --DESPESES GESTIO EXTERNA EXTERNA,
                                                                                sproces);

         RETURN(0);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN(0);
         WHEN OTHERS THEN
            RETURN(-56);
      END;

      --Retorna l'edat actuarial a data p_Data_final
      FUNCTION edat_actuarial_fecha_efecto(
         p_data_naix IN DATE,
         p_fecha_efecto IN DATE,
         f_calcul_pm IN DATE)
         RETURN NUMBER IS
         edat_actuarial_fefecto FLOAT;
         error          NUMBER;
         anys           NUMBER;
         mesos          NUMBER;
      BEGIN
         --Calculem l'edat a data d'efecte
         error := f_difdata(p_data_naix, p_fecha_efecto, 2, 1, edat_actuarial_fefecto);

         IF error < 0 THEN
            RETURN error;
         END IF;

         -- Es cumpleiexen els anys
         -- el dia to_char(LAST_DAY(p_fecha_efecto),'MMDD'))
         -- A edat_Actuarial_fefecto
         mesos := MONTHS_BETWEEN(f_calcul_pm, p_fecha_efecto);
         anys := mesos / 12;
         anys := TRUNC(anys);
         RETURN edat_actuarial_fefecto + anys;
      END;

-----------------
--PROCEDIMENTS
-----------------
      PROCEDURE act_max_cap_asse(pta IN BOOLEAN) IS
      BEGIN
         --Producte en pessetes
         IF pta THEN
            k_icapmaxasegurado := k_icapmaxaseguradopta;
            k_icapmaxasegurado2 := k_icapmaxasegurado2pta;
            k_icapmaxasegurado65 := k_icapmaxasegurado65pta;
         --Producte en euros
         ELSE
            k_icapmaxasegurado := f_eurospesetas(k_icapmaxaseguradopta, 2);
            k_icapmaxasegurado2 := f_eurospesetas(k_icapmaxasegurado2pta, 2);
            k_icapmaxasegurado65 := f_eurospesetas(k_icapmaxasegurado65pta, 2);
         END IF;
      END;

/**************************************************************************************/
/**************************************************************************************/
/* PEG I PIG : PLÀ D'ESTALVI GARANTIT                               */
/*       INPUT:         Veure capçalera de la funció                            */
/*    OUTPUT: <0     Error                                          */
/*          >= 0  Retorna la provisió matemàtica del Plà d'Estalvi Garantit     */
/*                                                                              */
/*                                                                              */
/*                                                                              */
/*                                                                              */
/*                                                                              */
/*                                                                              */
/**************************************************************************************/
/**************************************************************************************/
      FUNCTION f_matriz_provmat13_acumulat(
         p_data_pm_inicial IN DATE,   -- Data de la primera provisio matmàtica
         p_pm_inicial IN NUMBER,   -- Provisio matemàtica Inicial
         p_data_final IN DATE,   -- Data de càlcul (pot ser qualssevol dia)
         p_fecha_efecto IN DATE,   -- Fecha d'efecto de la póliza
         p_sexo IN NUMBER,   -- Sexe del primer assegurat (1: home, 2: dona)
         p_sexo2 IN NUMBER,   -- Sexe del segon assegurat (1: home; 2 dona; NULL: només hi ha un assegurat)
         p_data_naix IN DATE,   -- Data naixement individu 1
         p_data_naix2 IN DATE,   -- Data naixement individu 2
         p_int_tec_risc_perc IN NUMBER,   -- Interes tecnic de risc (Expressat en %)
         p_por_cap_risc IN NUMBER,   -- % Capital de Risc
         p_it1p IN NUMBER,   -- Interès tècnic del primer periode
         p_feimtec IN DATE,   -- Durada del primer periode
         p_des_ginternasi_perc IN NUMBER,   -- Despeses de gestió interna sobre interès
         p_des_gexternaintsi_perc IN NUMBER,   --  Despeses de gestió externa  (PEl càlcul de l'interès tècnic')
         p_des_gexternaextsi_perc IN NUMBER,   --  Despeses de gestió externa  (PEl càlcul de l'interès tècnic')
         p_des_ext_risc IN NUMBER,   -- Despeses de gestió externa  (Càlcul de la prima de Risc)
         p_limit_max_capital_ass1 IN NUMBER,   -- Límit màxim de capital assegurat (1 cabeza)
         p_limit_max_capital_ass2 IN NUMBER,   -- Límit màxim de capital assegurat (2 cabeza)
         p_limit_max_65 IN NUMBER,   -- Limit màxim de capital assegurat als 65 anys
         p_ctiptab IN NUMBER,   -- Codi de la taula de mortalitat (ha de ser 1)
         p_seguro IN garanseg.sseguro%TYPE,
         p_sproces IN matrizprovmatgen.sproces%TYPE,
         p_cprovis IN NUMBER,   -- 18 PIG i 19 PEG
         p_cdivisa IN NUMBER   --2 PTA, 3 EUROS
                            )
         RETURN NUMBER IS
------------------------
--Variables de la funció
------------------------
   --Dates
         data_inici_mes DATE;
         data_final_mes DATE;
         ultim_dia_mes_anterior DATE;
         --Valors de mortalitat i invalidesa
         q              FLOAT;
         qx1            FLOAT;
         qx2            FLOAT;
         qy1            FLOAT;
         qy2            FLOAT;
         ix1            FLOAT;
         ix2            FLOAT;
         q1r            FLOAT;
         q2n            FLOAT;
         --Altres
         edat_actuarial FLOAT;
         edat_actuarial2 FLOAT;
         p_int_tec_perc_actual FLOAT;   --Percentatge d'interès tècnic (Pot variar)
         prov_matfinalmes FLOAT;
         capital_maximassegurat NUMBER;
         capital_risc   NUMBER;
         prima_purarisc FLOAT;
         prima_risc     FLOAT;   --Percentatge
         prima_riscpta  FLOAT;   --PTA
         prima_riscptainval FLOAT;   --Desglos per invalidesa
         prima_riscptafall FLOAT;   --Desglos per mort
         i_tecnicaplicat_perc FLOAT;
         comissio_pta   FLOAT;
         comissiogesinterna_pta NUMBER;
         comissiogesexternaint_pta NUMBER;
         comissiogesexternaext_pta NUMBER;
         pm_int_tecnic  NUMBER;
         pm_int_tecnic_net_ggi NUMBER;
         pm_int_tecnic_net_ggei NUMBER;
         pm_int_tecnic_net_ggee NUMBER;
         --Interessos
         i_tecnicaplicat_net_ggi_perc NUMBER;
         i_tecnicaplicat_net_ggei_perc NUMBER;
         i_tecnicaplicat_net_ggee_perc NUMBER;
         --Rescats i Aportacions
         suma_rescats2  NUMBER;
         suma_rescats3  NUMBER;
         suma_rescats4  NUMBER;
         suma_rescats5  NUMBER;
         suma_aportacions2 NUMBER;
         suma_aportacions3 NUMBER;
         suma_aportacions4 NUMBER;
         suma_aportacions5 NUMBER;
         ips            FLOAT;   --Impuesto Prima seguro
         pips_perc      FLOAT;   --Porcentaje del impuesto
         d              NUMBER;   --dies 1..31
         d_rescat       NUMBER;
         d_aportacions  NUMBER;
         n_iteracions   NUMBER;
         parella        BOOLEAN;   --Per saber si és 1 ó 2 cabezas
         suma_rescats   NUMBER;
         suma_aportacions NUMBER;
         --Errors
         error1         NUMBER := 0;
         error2         NUMBER;
         retornaerror   NUMBER;

------------------------
--Funcions
------------------------
--INVALIDESA
         FUNCTION c_invalidesa(
            p_ctiptab IN NUMBER,
            p_pinttec IN NUMBER,
            p_edat_actuarial NUMBER)
            RETURN NUMBER IS
         BEGIN
            SELECT NVL(ix, 0)
              INTO ix2
              FROM simbolconmu
             WHERE ctabla = p_ctiptab   --TAULA 2
               AND pinttec = p_pinttec   --DADA FIXA
               AND nedad = p_edat_actuarial;

            RETURN(ix2);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN(-2);
         END;

--MORTALITAT
         FUNCTION c_mortalitat(
            p_ctiptab IN NUMBER,
            p_pinttec IN NUMBER,
            p_edat_actuarial IN NUMBER,
            sexe IN NUMBER)
            RETURN NUMBER IS
         BEGIN
            SELECT NVL(qx, 0), NVL(qy, 0)
              INTO qx1, qy1
              FROM simbolconmu
             WHERE ctabla = p_ctiptab   --TAULA 1
               AND pinttec = 0   --DADA FIXA
               AND nedad = p_edat_actuarial;

            IF sexe = 1 THEN
               RETURN(qx1);
            ELSE
               RETURN(qy1);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN(-3);
         END;
      BEGIN
------------------------
--Tractaments inicials
------------------------
--1 ó 2 cabezas
         parella :=(p_data_naix2 IS NOT NULL);

--Càlcul del número d'iteracions
--Si és el mateix mes i any el numero d'iteracions és 0,0..0 S'executarà 1 vegada
         IF TO_CHAR(p_data_final, 'YYYY') = TO_CHAR(p_data_pm_inicial, 'YYYY')
            AND TO_CHAR(p_data_final, 'MM') = TO_CHAR(p_data_pm_inicial, 'MM') THEN
            n_iteracions := 0;
         ELSE
            n_iteracions := CEIL(MONTHS_BETWEEN(p_data_final, p_data_pm_inicial));   -- pot tenir fraccions
         END IF;

--ML PRovision MAtemàtica Inicial és la primera aportacio
         prov_matfinalmes := p_pm_inicial;
         capital_risc := p_pm_inicial;

--Obtenemos el porcentaje de IPS
         BEGIN
            SELECT NVL(pimpips, 0)
              INTO pips_perc
              FROM impuestos;
         EXCEPTION
            WHEN OTHERS THEN
               error1 := -6;
               RETURN error1;
         END;

         FOR i IN 0 .. n_iteracions LOOP
            --Ultim dia de final mes anterior
            IF i <> 0 THEN
               ultim_dia_mes_anterior := data_final_mes;
            ELSE
               ultim_dia_mes_anterior := LAST_DAY(ADD_MONTHS(p_data_pm_inicial, -1));
            END IF;

            --Data d'inici del mes
            IF i <> 0 THEN
               data_inici_mes := ultim_dia_mes_anterior + 1;
            ELSE
               data_inici_mes := p_data_pm_inicial;
            END IF;

            --Data final de mes
            IF LAST_DAY(ultim_dia_mes_anterior + 1) >= p_data_final THEN
               data_final_mes := p_data_final;
            ELSE
               data_final_mes := LAST_DAY(ultim_dia_mes_anterior + 1);
            END IF;

            --Calculem l'edat Actuarial a data de calcyl de la Proviso matemàtica antiga
            edat_actuarial := edat_actuarial_fecha_efecto(p_data_naix, p_fecha_efecto,
                                                          p_data_pm_inicial - 1);

            IF edat_actuarial < 0 THEN
               RETURN(-30);
            END IF;

            IF parella = TRUE THEN
               edat_actuarial2 := edat_actuarial_fecha_efecto(p_data_naix2, p_fecha_efecto,
                                                              p_data_pm_inicial - 1);

               IF edat_actuarial2 < 0 THEN
                  RETURN(-31);
               END IF;
            END IF;

            --d: Dies de càlcul del mes actual
            d := data_final_mes - data_inici_mes + 1;

            IF p_cprovis = 18 THEN
               --Càlcul del interès tècnic  en el cas del PIG
                  --Actualitzem l'interes tècnic Actual en el cas que hagi passat el 1r periode
               IF p_feimtec > data_inici_mes THEN
                  p_int_tec_perc_actual := p_it1p;
               ELSE
                  p_int_tec_perc_actual := c_interestecnic(data_inici_mes, p_seguro);
               END IF;
            ELSE
               --Càlcul del interès tècnic  en el cas del PEG
               p_int_tec_perc_actual := c_interestecnic(data_inici_mes, p_seguro);

               IF (p_int_tec_perc_actual < 0) THEN
                  RETURN(-7);
               END IF;
            END IF;

            IF parella = FALSE THEN
               --Actualitzem l'edat actuarial cada any
               IF MOD(i, 12) = 1
                  AND i != 1 THEN
                  edat_actuarial := edat_actuarial + 1;
               END IF;

               --Calculem el capital_MaximAssegurat (funció edat)
               IF edat_actuarial < 65 THEN
                  capital_maximassegurat := p_limit_max_capital_ass1;
               ELSE
                  capital_maximassegurat := p_limit_max_65;
               END IF;

               --CAPITAL RSIC éS EL 10% DE LA PROV MATE DE FINALS DEL MES ANETERIOR
               capital_risc := p_por_cap_risc * prov_matfinalmes;

               IF capital_risc > capital_maximassegurat THEN
                  capital_risc := capital_maximassegurat;
               END IF;

               --Calculem el percentatge de mortalitat i invalidesa
               -- Calculamos el valor de la tabla de mortalitat pel primer assegurat
               --Si home q=qx otherwise q=qy
               IF p_sexo = 1 THEN
                  q := c_mortalitat(p_ctiptab, 0, edat_actuarial, 1);

                  IF (q < 0) THEN
                     RETURN(-8);
                  END IF;
               ELSIF p_sexo = 2 THEN
                  q := c_mortalitat(p_ctiptab, 0, edat_actuarial, 2);

                  IF (q < 0) THEN
                     RETURN(-9);
                  END IF;
               ELSE
                  RETURN(-11);
               END IF;

               -- Calculamos el valor de la tabla de invalidez
               ix1 := c_invalidesa(p_ctiptab, 0, edat_actuarial);

               IF (ix1 < 0) THEN
                  RETURN(-11);
               END IF;
            ELSE   --2 cabezas
               --Actualitzem l'edat actuarial cada any
               IF MOD(i, 12) = 1
                  AND i != 1 THEN
                  edat_actuarial := edat_actuarial + 1;
                  edat_actuarial2 := edat_actuarial2 + 1;
               END IF;

               --Si home q=qx otherwise q=qy
               IF p_sexo = 1 THEN
                  q1r := c_mortalitat(p_ctiptab, 0, edat_actuarial, 1);

                  IF (q1r < 0) THEN
                     RETURN(-12);
                  END IF;
               ELSIF p_sexo = 2 THEN
                  q1r := c_mortalitat(p_ctiptab, 0, edat_actuarial, 2);

                  IF (q1r < 0) THEN
                     RETURN(-13);
                  END IF;
               ELSE
                  RETURN(-11);
               END IF;

               -- Calculamos el valor de la tabla de mortalitat pel segon assegurat
               IF p_sexo2 = 1 THEN
                  q2n := c_mortalitat(p_ctiptab, 0, edat_actuarial2, 1);

                  IF (q2n < 0) THEN
                     RETURN(-14);
                  END IF;
               ELSIF p_sexo2 = 2 THEN
                  q2n := c_mortalitat(p_ctiptab, 0, edat_actuarial2, 2);

                  IF (q2n < 0) THEN
                     RETURN(-15);
                  END IF;
               ELSE
                  RETURN(-16);
               END IF;

               -- Calculamos el valor de la tabla de invalidez
               ix1 := c_invalidesa(p_ctiptab, 0, edat_actuarial);
               ix2 := c_invalidesa(p_ctiptab, 0, edat_actuarial2);

               IF (ix1 < 0)
                  OR(ix2 < 0) THEN
                  RETURN(-17);
               END IF;

               --Calculem el capital_MaximAssegurat (funció edat) i el capital Risc
               IF edat_actuarial < 65
                  AND edat_actuarial2 < 65 THEN
                  capital_maximassegurat := p_limit_max_capital_ass2;
               ELSE
                  capital_maximassegurat := p_limit_max_65;
               END IF;

               --CAPITAL RSIC éS EL 300% DE LA PROV MATE DE FINALS DEL MES ANETERIOR
               capital_risc := 3 * prov_matfinalmes;

               IF capital_risc > capital_maximassegurat THEN
                  capital_risc := capital_maximassegurat;
               END IF;
            END IF;

            i_tecnicaplicat_perc := ROUND((1 +(p_int_tec_perc_actual / 100))
                                          *(1 -(p_des_ginternasi_perc / 100)
                                            -((p_des_gexternaintsi_perc
                                               + p_des_gexternaextsi_perc)
                                              / 100))
                                          - 1,
                                          4)
                                    * 100;
            i_tecnicaplicat_net_ggi_perc := ROUND((1 +(p_int_tec_perc_actual / 100))
                                                  *(1 -(p_des_ginternasi_perc / 100))
                                                  - 1,
                                                  4)
                                            * 100;
            i_tecnicaplicat_net_ggei_perc := ROUND((1 +(p_int_tec_perc_actual / 100))
                                                   *(1 -(p_des_gexternaintsi_perc / 100))
                                                   - 1,
                                                   4)
                                             * 100;
            i_tecnicaplicat_net_ggee_perc := ROUND((1 +(p_int_tec_perc_actual / 100))
                                                   *(1 -(p_des_gexternaextsi_perc / 100))
                                                   - 1,
                                                   4)
                                             * 100;
            --Calculem tots els rescats realitzats entre les dates Data_Inici_Mes i Data_final_Mes
            suma_aportacions := 0;
            suma_aportacions2 := 0;
            suma_aportacions3 := 0;
            suma_aportacions4 := 0;
            suma_aportacions5 := 0;
            d_aportacions := 0;

            --lES APORTACIONS NOMÉS ES CALCULEN PEL PEG
            IF p_cprovis = 19 THEN
               FOR c1 IN c_aportacions(p_seguro, data_inici_mes, data_final_mes) LOOP
                  --Cal calcular els dies fins al minim (final de mes, data_Calcul)
                  d_aportacions := data_final_mes - c1.fvalmov + 1;
                  suma_aportacions := suma_aportacions
                                      + c1.imovimi
                                        * POWER(1 +(i_tecnicaplicat_perc / 100.0),
                                                d_aportacions / 365);
                  suma_aportacions2 := suma_aportacions2
                                       + c1.imovimi
                                         * POWER(1 +(p_int_tec_perc_actual / 100.0),
                                                 d_aportacions / 365);
                  suma_aportacions3 := suma_aportacions3
                                       + c1.imovimi
                                         * POWER(1 +(i_tecnicaplicat_net_ggi_perc / 100.0),
                                                 d_aportacions / 365);
                  suma_aportacions4 := suma_aportacions4
                                       + c1.imovimi
                                         * POWER(1 +(i_tecnicaplicat_net_ggei_perc / 100.0),
                                                 d_aportacions / 365);
                  suma_aportacions5 := suma_aportacions5
                                       + c1.imovimi
                                         * POWER(1 +(i_tecnicaplicat_net_ggee_perc / 100.0),
                                                 d_aportacions / 365);
               END LOOP;
            END IF;

            --Calculem tots els rescats realitzats entre les dates Data_Inici_Mes i Data_final_Mes
            suma_rescats := 0;
            suma_rescats2 := 0;
            suma_rescats3 := 0;
            suma_rescats4 := 0;
            suma_rescats5 := 0;
            d_rescat := 0;

            --Si l'aportació és el dia x cal trobar els dies que falten fins a final de mes
            FOR c2 IN c_rescats(p_seguro, data_inici_mes, data_final_mes) LOOP
               --Cal calcular els dies fins al minim (final de mes, data_Calcul)
               d_rescat := data_final_mes - c2.fvalmov + 1;
               suma_rescats := suma_rescats
                               + c2.imovimi
                                 * POWER(1 +(i_tecnicaplicat_perc / 100.0), d_rescat / 365);
               suma_rescats2 := suma_rescats2
                                + c2.imovimi
                                  * POWER(1 +(p_int_tec_perc_actual / 100.0), d_rescat / 365);
               suma_rescats3 := suma_rescats3
                                + c2.imovimi
                                  * POWER(1 +(i_tecnicaplicat_net_ggi_perc / 100.0),
                                          d_rescat / 365);
               suma_rescats4 := suma_rescats4
                                + c2.imovimi
                                  * POWER(1 +(i_tecnicaplicat_net_ggei_perc / 100.0),
                                          d_rescat / 365);
               suma_rescats5 := suma_rescats5
                                + c2.imovimi
                                  * POWER(1 +(i_tecnicaplicat_net_ggee_perc / 100.0),
                                          d_rescat / 365);
            END LOOP;

            comissio_pta := ROUND(prov_matfinalmes
                                  *((POWER(1 +(p_int_tec_perc_actual / 100.0)
                                           -(i_tecnicaplicat_perc / 100),
                                           d / 365.0))
                                    - 1.0),
                                  2);

            IF parella = FALSE THEN
               --Arrodonim al decimal 8
               prima_purarisc := ROUND((q + ix1)
                                       * POWER(1 +(p_int_tec_risc_perc / 100.0), -0.5),
                                       8);
               --Arrodinim al decimal 8
               prima_risc := ROUND(prima_purarisc /(1 -(p_des_ext_risc / 100.0)), 8);
               --Arrodinim al decimal 8
               prima_riscpta := ROUND((ROUND(((q + ix1)
                                              * POWER(1 +(p_int_tec_risc_perc / 100.0), -0.5)),
                                             8)
                                       /((1 -(p_des_ext_risc / 100.0))) * capital_risc * d)
                                      / 365.0,
                                      10);
               --Desglossat per invalidesa i fallecimiento
               prima_riscptainval := ROUND((ROUND((ix1
                                                   * POWER(1 +(p_int_tec_risc_perc / 100.0),
                                                           -0.5)),
                                                  8)
                                            /((1 -(p_des_ext_risc / 100.0))) * capital_risc * d)
                                           / 365.0,
                                           10);
               prima_riscptafall := ROUND((ROUND((q
                                                  * POWER(1 +(p_int_tec_risc_perc / 100.0),
                                                          -0.5)),
                                                 8)
                                           /((1 -(p_des_ext_risc / 100.0))) * capital_risc * d)
                                          / 365.0,
                                          10);
               ips := ROUND(pips_perc * prima_riscptainval);
            ELSE
               prima_purarisc := ROUND(((q1r * q2n) +(q1r * ix2) +(q2n * ix1) +(ix1 * ix2))
                                       * POWER(1 +(p_int_tec_risc_perc / 100.0), -0.5),
                                       8);
               --Arrodinim al decimal 8
               prima_risc := ROUND(prima_purarisc /(1 -(p_des_ext_risc / 100.0)), 8);
               --Arrodinim al decimal 8
               prima_riscpta := ROUND((ROUND((((q1r * q2n) +(q1r * ix2) +(q2n * ix1)
                                               +(ix1 * ix2))
                                              * POWER(1 +(p_int_tec_risc_perc / 100.0), -0.5)),
                                             8)
                                       /((1 -(p_des_ext_risc / 100.0))) * capital_risc * d)
                                      / 365.0,
                                      10);
               --Desglossat per invalidesa i fallecimiento
               prima_riscptainval := ROUND((ROUND((((q1r * ix2) +(q2n * ix1) +(ix1 * ix2))
                                                   * POWER(1 +(p_int_tec_risc_perc / 100.0),
                                                           -0.5)),
                                                  8)
                                            /((1 -(p_des_ext_risc / 100.0))) * capital_risc * d)
                                           / 365.0,
                                           10);
               prima_riscptafall := ROUND((ROUND(((q1r * q2n)
                                                  * POWER(1 +(p_int_tec_risc_perc / 100.0),
                                                          -0.5)),
                                                 8)
                                           /((1 -(p_des_ext_risc / 100.0))) * capital_risc * d)
                                          / 365.0,
                                          10);
               ips := ROUND(pips_perc * prima_riscptainval);
            END IF;

            prov_matfinalmes := ROUND((prov_matfinalmes - prima_riscpta)
                                      * POWER(1 + i_tecnicaplicat_perc / 100.0, d / 365.0)
                                      - suma_rescats + suma_aportacions,
                                      2);
            pm_int_tecnic := f_round((prov_matfinalmes - prima_riscpta)
                                     * POWER(1 + p_int_tec_perc_actual / 100.0, d / 365.0)
                                     - suma_rescats2);
            pm_int_tecnic_net_ggi := f_round((prov_matfinalmes - prima_riscpta)
                                             * POWER(1 + i_tecnicaplicat_net_ggi_perc / 100.0,
                                                     d / 365.0)
                                             - suma_rescats3);   --I
            pm_int_tecnic_net_ggei := f_round((prov_matfinalmes - prima_riscpta)
                                              * POWER(1 + i_tecnicaplicat_net_ggei_perc / 100.0,
                                                      d / 365.0)
                                              - suma_rescats4);   --EI
            pm_int_tecnic_net_ggee := f_round((prov_matfinalmes - prima_riscpta)
                                              * POWER(1 + i_tecnicaplicat_net_ggee_perc / 100.0,
                                                      d / 365.0)
                                              - suma_rescats5);   --EE
            comissiogesinterna_pta := pm_int_tecnic - pm_int_tecnic_net_ggi;
            comissiogesexternaint_pta := pm_int_tecnic - pm_int_tecnic_net_ggei;
            comissiogesexternaext_pta := pm_int_tecnic - pm_int_tecnic_net_ggee;
         END LOOP;

--Inserto les dades a InsertaMatrizProvMatGen
--Si inserto 1 vol dir que el camp és irrellevant
         IF p_cdivisa = 2 THEN   --PTA
            prima_riscpta := ROUND(prima_riscpta);   --PRIMA RISC
            capital_risc := ROUND(capital_risc);
            comissiogesinterna_pta := ROUND(comissiogesinterna_pta);   -- DESPESES GESTIÓ INTERNA
            comissiogesexternaint_pta := ROUND(comissiogesexternaint_pta);   -- DESPESES GESTIÓ EXTERNA INTERNA
            comissiogesexternaext_pta := ROUND(comissiogesexternaext_pta);   -- DESPESES GESTIO EXTERNA EXTERNA
            prov_matfinalmes := ROUND(prov_matfinalmes);
         ELSE
            prima_riscpta := f_round(prima_riscpta, 1);   --PRIMA RISC
            capital_risc := f_round(capital_risc, 1);
            comissiogesinterna_pta := f_round(comissiogesinterna_pta, 1);   -- DESPESES GESTIÓ INTERNA
            comissiogesexternaint_pta := f_round(comissiogesexternaint_pta, 1);   -- DESPESES GESTIÓ EXTERNA INTERNA
            comissiogesexternaext_pta := f_round(comissiogesexternaext_pta, 1);   -- DESPESES GESTIO EXTERNA EXTERNA
            prov_matfinalmes := f_round(prov_matfinalmes, 1);
         END IF;

         error1 :=
            insertamatrizprovmatgen
                                  (0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, prima_riscpta,   --PRIMA RISC
                                   capital_risc, 1, comissiogesinterna_pta,   -- DESPESES GESTIÓ INTERNA
                                   comissiogesexternaint_pta,   -- DESPESES GESTIÓ EXTERNA INTERNA
                                   comissiogesexternaext_pta,   -- DESPESES GESTIO EXTERNA EXTERNA
                                   p_sproces);

         IF error1 < 0 THEN
            RETURN error1;
         ELSE
            RETURN prov_matfinalmes;
         END IF;
      END f_matriz_provmat13_acumulat;

/**************************************************************************************/
/**************************************************************************************/
/* PPP: PLÀ PERSONAL PREVISIÓ                                    */
/*  PIP: PLÀ INFANTIL PREVISIÓ                                   */
/*  PJP: PLÀ JUVENIL  PREVISIÓ                                   */
/*       INPUT:         Veure capçalera de la funció                            */
/*    OUTPUT: <0     Error                                          */
/*          >= 0  Retorna la provisió matemàtica                          */
/*                      Inserta a la taula MATRIZPROVMATGEN                     */
/*                                                                        */
/**************************************************************************************/
/**************************************************************************************/
      FUNCTION f_matriz_provmat14_acumulat(
         p_data_pm_inicial IN DATE,   --Data de la primera provisio matmàtica
         p_pm_inicial IN NUMBER,   --Provisio matemàtica Inicial
         p_data_final IN DATE,   -- Data de càlcul(pot ser qualssevol dia)
         p_int_tec_perc IN NUMBER,   -- Interes tecnic fixe (durant tot el periode)
         p_despeses_si_prima_perc IN NUMBER,
         p_seguro IN NUMBER,   --
         p_sproces IN matrizprovmatgen.sproces%TYPE,
         p_cdivisa IN NUMBER   --2 PTA, 3 EUROS
                            )
         RETURN NUMBER IS
------------------------
--Variables de la funció
------------------------
   --Dates
         data_calcul_inici_mes DATE;
         ultim_dia_mes_anterior DATE;   --Data del bucle
         data_inici_mes DATE;
         data_final_mes DATE;
         prov_mat_mes_actual FLOAT;   --Provisió Matemàtica amb interes i_tecnic
         prov_mat_mes_anterior FLOAT;   --Provisió matemàtica amb interès i_tecnic
         prov_mat_mes_actual2 FLOAT;   --Provisió matemàtica amb interès  Prov_Beneficis_Perc
         prov_mat_mes_anterior2 FLOAT;
         d              NUMBER;   --dies 1..31
         d_aportacions  NUMBER;   --dies que falten pel minim (data de rescat,final de mes)
         d_rescat       NUMBER;
         n_iteracions   NUMBER;
         suma_rescats   NUMBER;   --Rescats amb interès  p_int_tec_Perc
         suma_aportacions NUMBER;   --APortacions amb interès  p_int_tec_Perc
         suma_rescats2  NUMBER;   --Rescats amb interès  p_prov_Beneficis_Perc
         suma_aportacions2 NUMBER;   --APortacions amb interès  p_prov_Beneficis_Perc
         despeses_si_primapta NUMBER;
         suma_despeses_si_primapta NUMBER := 0.0;
         prov_beneficis_perc NUMBER;
         p_despeses_pta NUMBER;
         pb_pta         NUMBER;
         suma_pb_pta    NUMBER := 0;
         retornaerror   NUMBER;

----------------
--Funcions
----------------
--Calcula el percentatge de proviaió en beneficis
         FUNCTION c_prov_beneficis_perc(periode IN DATE, p_seguro IN seguros.sseguro%TYPE)
            RETURN NUMBER IS
            p_cramo        seguros.cramo%TYPE;
            p_ccolect      seguros.ccolect%TYPE;
            p_ctipseg      seguros.ctipseg%TYPE;
            p_cmodali      seguros.cmodali%TYPE;
         BEGIN
            SELECT cramo, ccolect, ctipseg, cmodali
              INTO p_cramo, p_ccolect, p_ctipseg, p_cmodali
              FROM seguros
             WHERE sseguro = p_seguro;

            SELECT pinttot
              INTO prov_beneficis_perc
              FROM interesprod
             WHERE cramo = p_cramo
               AND ccolect = p_ccolect
               AND ctipseg = p_ctipseg
               AND cmodali = p_cmodali
               AND finivig <= periode
               AND(ffinvig > periode
                   OR ffinvig IS NULL);

            RETURN prov_beneficis_perc;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN(-1);
         END;
      BEGIN
------------------------
--Tractaments inicials
------------------------
--Inicialment no hi ha error
         retornaerror := 0;

--Càlcul del número d'iteracions
--Si és el mateix mes i any el numero d'iteracions és 0,0..0 S'executarà 1 vegada
         IF TO_CHAR(p_data_final, 'YYYY') = TO_CHAR(p_data_pm_inicial, 'YYYY')
            AND TO_CHAR(p_data_final, 'MM') = TO_CHAR(p_data_pm_inicial, 'MM') THEN
            n_iteracions := 0;
         ELSE
            n_iteracions := CEIL(MONTHS_BETWEEN(p_data_final, p_data_pm_inicial));   -- pot tenir fraccions
         END IF;

--La provisió matemàtica inicial és 0
         prov_mat_mes_actual := p_pm_inicial;
         prov_mat_mes_actual2 := p_pm_inicial;
         prov_mat_mes_anterior := p_pm_inicial;

--Calcul dels percentatges inicials;
         FOR i IN 0 .. n_iteracions LOOP
            prov_mat_mes_anterior := prov_mat_mes_actual2;
            prov_mat_mes_anterior2 := prov_mat_mes_actual2;

            --Ultim dia de final mes anterior
            IF i <> 0 THEN
               ultim_dia_mes_anterior := data_final_mes;
            ELSE
               ultim_dia_mes_anterior := LAST_DAY(ADD_MONTHS(p_data_pm_inicial, -1));
            END IF;

            --Data d'inici del mes
            IF i <> 0 THEN
               data_inici_mes := ultim_dia_mes_anterior + 1;
            ELSE
               data_inici_mes := p_data_pm_inicial;
            END IF;

            --Data final de mes
            IF LAST_DAY(ultim_dia_mes_anterior + 1) >= p_data_final THEN
               data_final_mes := p_data_final;
            ELSE
               data_final_mes := LAST_DAY(ultim_dia_mes_anterior + 1);
            END IF;

            --d: Dies de càlcul del mes actual
            d := data_final_mes - data_inici_mes + 1;
            --Calculem el percentatge de provisió en beneficis
            prov_beneficis_perc := c_prov_beneficis_perc(data_inici_mes, p_seguro);

            IF prov_beneficis_perc < 0 THEN
               RETURN(-15);
            END IF;

            --Calculem tots els rescats realitzats entre les dates Data_Inici_Mes i Data_final_Mes
            suma_aportacions := 0;
            suma_aportacions2 := 0;
            d_aportacions := 0;

            FOR c1 IN c_aportacions(p_seguro, data_inici_mes, data_final_mes) LOOP
               --Cal calcular els dies fins al minim (final de mes, data_Calcul)
               d_aportacions := data_final_mes - c1.fvalmov + 1;
               despeses_si_primapta := c1.imovimi * p_despeses_si_prima_perc / 100;
               suma_despeses_si_primapta := suma_despeses_si_primapta + despeses_si_primapta;
               suma_aportacions := suma_aportacions
                                   + (c1.imovimi - despeses_si_primapta)
                                     * POWER(1 +(p_int_tec_perc / 100), d_aportacions / 365);
               suma_aportacions2 := suma_aportacions2
                                    + (c1.imovimi - despeses_si_primapta)
                                      * POWER(1 +(prov_beneficis_perc / 100),
                                              d_aportacions / 365);
            END LOOP;

            --Calculem tots els rescats realitzats entre les dates Data_Inici_Mes i Data_final_Mes
            suma_rescats := 0;
            suma_rescats2 := 0;
            d_rescat := 0;

            --Si l'aportació és el dia x cal trobar els dies que falten fins a final de mes
            FOR c2 IN c_rescats(p_seguro, data_inici_mes, data_final_mes) LOOP
               --Cal calcular els dies fins al minim (final de mes, data_Calcul)
               d_rescat := data_final_mes - c2.fvalmov + 1;
               suma_rescats := suma_rescats
                               + c2.imovimi * POWER(1 +(p_int_tec_perc / 100), d_rescat / 365);
               suma_rescats2 := suma_rescats2
                                + c2.imovimi
                                  * POWER(1 +(prov_beneficis_perc / 100), d_rescat / 365);
            END LOOP;

            --Arrodinim al decimal 8 restant rescats i sumant aportacions
            prov_mat_mes_actual := ROUND(prov_mat_mes_anterior2
                                         * POWER(1 +(p_int_tec_perc / 100.0), d / 365.0)
                                         - suma_rescats + suma_aportacions,
                                         2);
            prov_mat_mes_actual2 := ROUND(prov_mat_mes_anterior2
                                          * POWER(1 +(prov_beneficis_perc / 100.0), d / 365.0)
                                          - suma_rescats2 + suma_aportacions2,
                                          2);
            --Calculem la participacio dels beneficis en PTA, mensual i acumulat
            pb_pta := prov_mat_mes_actual2 - prov_mat_mes_actual;
            suma_pb_pta := suma_pb_pta + pb_pta;
         --Insertem a la taula InsertaMatrizProvMatGen (CINDICE IN MATRIZPROVMATGEN.CINDICE,
         END LOOP;

--Inserto les dades a InsertaMatrizProvMatGen
         IF p_cdivisa = 2 THEN   --PTA
            pb_pta := ROUND(pb_pta);
            prov_mat_mes_actual2 := ROUND(prov_mat_mes_actual2);
            prov_mat_mes_actual := ROUND(prov_mat_mes_actual);
         ELSE
            pb_pta := f_round(pb_pta, 1);
            prov_mat_mes_actual2 := f_round(prov_mat_mes_actual2, 1);
            prov_mat_mes_actual := f_round(prov_mat_mes_actual, 1);
         END IF;

--Si inserto 1 vol dir que el camp és irrellevant
         retornaerror := insertamatrizprovmatgen(0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,   --PRIMA RISC
                                                 1, 1, pb_pta,   -- DESPESES GESTIÓ INTERNA
                                                 1,   -- DESPESES GESTIÓ EXTERNA INTERNA
                                                 1,   -- DESPESES GESTIO EXTERNA EXTERNA
                                                 p_sproces);

         IF retornaerror < 0 THEN
            RETURN retornaerror;
         ELSE
            IF p_data_final = LAST_DAY(p_data_final) THEN
               RETURN prov_mat_mes_actual2;
            ELSE
               RETURN prov_mat_mes_actual;
            END IF;
         END IF;
      END f_matriz_provmat14_acumulat;

/**************************************************************************************/
/**************************************************************************************/
/* PLA 18                                                           */
/*       INPUT:         Veure capçalera de la funció                            */
/*    OUTPUT: <0     Error                                          */
/*          >= 0  Retorna la provisió matemàtica                          */
/*                      Inserta a la taula MATRIZPROVMATGEN                     */
/*                                                                        */
/**************************************************************************************/
/**************************************************************************************/
      FUNCTION f_matriz_provmat15_acumulat(
         p_data_pm_inicial IN DATE,   --Data de la primera provisio matmàtica
         p_pm_inicial IN NUMBER,   --Provisio matemàtica Inicial
         p_data_final IN DATE,   -- Data de càlcul(pot ser qualssevol dia)
         p_despeses_prod_perc IN NUMBER,   -- Despeses del producte PLA 18
         p_des_ginternasi_perc IN NUMBER,   -- Despeses de gestió interna sobre interès
         p_des_gexternaintsi_perc IN NUMBER,   -- Despeses de gestió externa  (PEl càlcul de l'interès tècnic')
         p_des_gexternaextsi_perc IN NUMBER,   -- Despeses de gestió externa  (PEl càlcul de l'interès tècnic')
         p_seguro IN NUMBER,   -- Número del seguro
         p_sproces IN matrizprovmatgen.sproces%TYPE,
         p_cdivisa IN NUMBER   --2 PTA, 3 EUROS
                            )
         RETURN NUMBER IS
------------------------
--Variables de la funció
------------------------
         k_prima_risc_perc NUMBER := 0.5;
         ultim_dia_mes_anterior DATE;
         data_inici_mes DATE;
         data_final_mes DATE;
         prov_mat_mes_actual FLOAT;   --Provisió Matemàtica amb interes i_tecnic
         prov_mat_mes_anterior FLOAT;   --Provisió matemàtica amb interès i_tecnic
         d              NUMBER;   --dies 1..31
         d_aportacions  NUMBER;   --dies que falten pel minim (data de rescat,final de mes)
         d_rescat       NUMBER;
         n_iteracions   NUMBER;
         suma_aportacions NUMBER;
         suma_rescats   NUMBER;
         int_tec_aplicat_perc NUMBER;
         int_tec_perc   NUMBER;
         prima_riscpta  NUMBER;
         comissiogesinterna_pta NUMBER;
         comissiogesexternaint_pta NUMBER;
         comissiogesexternaext_pta NUMBER;
         pm_int_tecnic  NUMBER;
         pm_int_tecnic_net_ggi NUMBER;
         pm_int_tecnic_net_ggei NUMBER;
         pm_int_tecnic_net_ggee NUMBER;
         pm_int_tecnic_net_risc NUMBER;
         i_tecnicaplicat_perc NUMBER;
         i_tecnicaplicat_net_ggi_perc NUMBER;
         i_tecnicaplicat_net_ggei_perc NUMBER;
         i_tecnicaplicat_net_ggee_perc NUMBER;
         i_tecnicaplicat_net_risc NUMBER;
         suma_rescats2  NUMBER;
         suma_rescats3  NUMBER;
         suma_rescats4  NUMBER;
         suma_rescats5  NUMBER;
         suma_rescats6  NUMBER;
         suma_aportacions2 NUMBER;
         suma_aportacions3 NUMBER;
         suma_aportacions4 NUMBER;
         suma_aportacions5 NUMBER;
         suma_aportacions6 NUMBER;
         retornaerror   NUMBER;
         pta            BOOLEAN;
      BEGIN
------------------------
--Tractaments inicials
------------------------
--Càlcul del número d'iteracions
--Si és el mateix mes i any el numero d'iteracions és 0,0..0 S'executarà 1 vegada
         IF TO_CHAR(p_data_final, 'YYYY') = TO_CHAR(p_data_pm_inicial, 'YYYY')
            AND TO_CHAR(p_data_final, 'MM') = TO_CHAR(p_data_pm_inicial, 'MM') THEN
            n_iteracions := 0;
         ELSE
            n_iteracions := CEIL(MONTHS_BETWEEN(p_data_final, p_data_pm_inicial));   -- pot tenir fraccions
         END IF;

--La provisió matemàtica inicial és 0
         prov_mat_mes_actual := p_pm_inicial;
         prov_mat_mes_anterior := p_pm_inicial;

--Calcul dels percentatges inicials;
         FOR i IN 0 .. n_iteracions LOOP
            prov_mat_mes_anterior := prov_mat_mes_actual;

            --Ultim dia de final mes anterior
            IF i <> 0 THEN
               ultim_dia_mes_anterior := data_final_mes;
            ELSE
               ultim_dia_mes_anterior := LAST_DAY(ADD_MONTHS(p_data_pm_inicial, -1));
            END IF;

            --Data d'inici del mes
            IF i <> 0 THEN
               data_inici_mes := ultim_dia_mes_anterior + 1;
            ELSE
               data_inici_mes := p_data_pm_inicial;
            END IF;

            --Data final de mes
            IF LAST_DAY(ultim_dia_mes_anterior + 1) >= p_data_final THEN
               data_final_mes := p_data_final;
            ELSE
               data_final_mes := LAST_DAY(ultim_dia_mes_anterior + 1);
            END IF;

            --d: Dies de càlcul del mes actual
            d := data_final_mes - data_inici_mes + 1;
            -- Actualitzem l'interès tècnic
            int_tec_perc := c_interestecnic(data_inici_mes, p_seguro);

            IF int_tec_perc < 0 THEN
               RETURN -1;
            END IF;

            --Càlcul de l'interès tècnic Aplicat
            int_tec_aplicat_perc := int_tec_perc - p_despeses_prod_perc - k_prima_risc_perc;
            i_tecnicaplicat_net_ggi_perc := ROUND((1 +(int_tec_perc / 100))
                                                  *(1 -(p_des_ginternasi_perc / 100))
                                                  - 1,
                                                  4)
                                            * 100;
            i_tecnicaplicat_net_ggei_perc := ROUND((1 +(int_tec_perc / 100))
                                                   *(1 -(p_des_gexternaintsi_perc / 100))
                                                   - 1,
                                                   4)
                                             * 100;
            i_tecnicaplicat_net_ggee_perc := ROUND((1 +(int_tec_perc / 100))
                                                   *(1 -(p_des_gexternaextsi_perc / 100))
                                                   - 1,
                                                   4)
                                             * 100;
            i_tecnicaplicat_net_risc := ROUND((1 +(int_tec_perc / 100))
                                              *(1 -(k_prima_risc_perc / 100))
                                              - 1,
                                              4)
                                        * 100;
            suma_aportacions := 0;
            suma_aportacions2 := 0;
            suma_aportacions3 := 0;
            suma_aportacions4 := 0;
            suma_aportacions5 := 0;
            suma_aportacions6 := 0;
            d_aportacions := 0;

            FOR c1 IN c_aportacions(p_seguro, data_inici_mes, data_final_mes) LOOP
               --Cal calcular els dies fins al minim (final de mes, data_Calcul)
               d_aportacions := data_final_mes - c1.fvalmov + 1;
               suma_aportacions := suma_aportacions
                                   + c1.imovimi
                                     * POWER(1 +(int_tec_aplicat_perc / 100),
                                             d_aportacions / 365);
               suma_aportacions2 := suma_aportacions2
                                    + c1.imovimi
                                      * POWER(1 +(int_tec_perc / 100.0), d_aportacions / 365);
               suma_aportacions3 := suma_aportacions3
                                    + c1.imovimi
                                      * POWER(1 +(i_tecnicaplicat_net_ggi_perc / 100.0),
                                              d_aportacions / 365);
               suma_aportacions4 := suma_aportacions4
                                    + c1.imovimi
                                      * POWER(1 +(i_tecnicaplicat_net_ggei_perc / 100.0),
                                              d_aportacions / 365);
               suma_aportacions5 := suma_aportacions5
                                    + c1.imovimi
                                      * POWER(1 +(i_tecnicaplicat_net_ggee_perc / 100.0),
                                              d_aportacions / 365);
               suma_aportacions6 := suma_aportacions6
                                    + c1.imovimi
                                      * POWER(1 +(i_tecnicaplicat_net_risc / 100.0),
                                              d_aportacions / 365);
            END LOOP;

            --Calculem tots els rescats realitzats entre les dates Data_Inici_Mes i Data_final_Mes
            suma_rescats := 0;
            suma_rescats2 := 0;
            suma_rescats3 := 0;
            suma_rescats4 := 0;
            suma_rescats5 := 0;
            suma_rescats6 := 0;
            d_rescat := 0;

            --Si l'aportació és el dia x cal trobar els dies que falten fins a final de mes
            FOR c2 IN c_rescats(p_seguro, data_inici_mes, data_final_mes) LOOP
               d_rescat := data_final_mes - c2.fvalmov + 1;
               suma_rescats := suma_rescats
                               + c2.imovimi
                                 * POWER((1 +(int_tec_aplicat_perc / 100.0)), d_rescat / 365);
               suma_rescats2 := suma_rescats2
                                + c2.imovimi
                                  * POWER(1 +(int_tec_perc / 100.0), d_rescat / 365);
               suma_rescats3 := suma_rescats3
                                + c2.imovimi
                                  * POWER(1 +(i_tecnicaplicat_net_ggi_perc / 100.0),
                                          d_rescat / 365);
               suma_rescats4 := suma_rescats4
                                + c2.imovimi
                                  * POWER(1 +(i_tecnicaplicat_net_ggei_perc / 100.0),
                                          d_rescat / 365);
               suma_rescats5 := suma_rescats5
                                + c2.imovimi
                                  * POWER(1 +(i_tecnicaplicat_net_ggee_perc / 100.0),
                                          d_rescat / 365);
               suma_rescats6 := suma_rescats6
                                + c2.imovimi
                                  * POWER(1 +(i_tecnicaplicat_net_risc / 100.0),
                                          d_rescat / 365);
            END LOOP;

            IF p_cdivisa = 2 THEN   --PTA
               prov_mat_mes_actual := ROUND(prov_mat_mes_anterior
                                            * POWER(1 + int_tec_aplicat_perc / 100.0,
                                                    d / 365.0)
                                            + suma_aportacions - suma_rescats,
                                            2);
               pm_int_tecnic := f_round(prov_mat_mes_anterior
                                        * POWER(1 + int_tec_perc / 100.0, d / 365.0)
                                        + suma_aportacions2 - suma_rescats2);
               pm_int_tecnic_net_ggi := f_round(prov_mat_mes_anterior
                                                * POWER(1
                                                        + i_tecnicaplicat_net_ggi_perc / 100.0,
                                                        d / 365.0)
                                                + suma_aportacions3 - suma_rescats3);   --I
               pm_int_tecnic_net_ggei := f_round(prov_mat_mes_anterior
                                                 * POWER(1
                                                         + i_tecnicaplicat_net_ggei_perc
                                                           / 100.0,
                                                         d / 365.0)
                                                 + suma_aportacions4 - suma_rescats4);   --EI
               pm_int_tecnic_net_ggee := f_round(prov_mat_mes_anterior
                                                 * POWER(1
                                                         + i_tecnicaplicat_net_ggee_perc
                                                           / 100.0,
                                                         d / 365.0)
                                                 + suma_aportacions5 - suma_rescats5);   --EE
               pm_int_tecnic_net_risc := f_round(prov_mat_mes_anterior
                                                 * POWER(1 + i_tecnicaplicat_net_risc / 100.0,
                                                         d / 365.0)
                                                 + suma_aportacions6 - suma_rescats6);   --EE
               comissiogesinterna_pta := ROUND(pm_int_tecnic - pm_int_tecnic_net_ggi);
               comissiogesexternaint_pta := ROUND(pm_int_tecnic - pm_int_tecnic_net_ggei);
               comissiogesexternaext_pta := ROUND(pm_int_tecnic - pm_int_tecnic_net_ggee);
               prima_riscpta := ROUND(pm_int_tecnic - pm_int_tecnic_net_risc);
            ELSE   --EUROS
               prov_mat_mes_actual := f_round(prov_mat_mes_anterior
                                              * POWER(1 + int_tec_aplicat_perc / 100.0,
                                                      d / 365.0)
                                              + suma_aportacions - suma_rescats,
                                              1);
               pm_int_tecnic := f_round(prov_mat_mes_anterior
                                        * POWER(1 + int_tec_perc / 100.0, d / 365.0)
                                        + suma_aportacions2 - suma_rescats2,
                                        1);
               pm_int_tecnic_net_ggi := f_round(prov_mat_mes_anterior
                                                * POWER(1
                                                        + i_tecnicaplicat_net_ggi_perc / 100.0,
                                                        d / 365.0)
                                                + suma_aportacions3 - suma_rescats3,
                                                1);   --I
               pm_int_tecnic_net_ggei := f_round(prov_mat_mes_anterior
                                                 * POWER(1
                                                         + i_tecnicaplicat_net_ggei_perc
                                                           / 100.0,
                                                         d / 365.0)
                                                 + suma_aportacions4 - suma_rescats4,
                                                 1);   --EI
               pm_int_tecnic_net_ggee := f_round(prov_mat_mes_anterior
                                                 * POWER(1
                                                         + i_tecnicaplicat_net_ggee_perc
                                                           / 100.0,
                                                         d / 365.0)
                                                 + suma_aportacions5 - suma_rescats5,
                                                 1);   --EE
               pm_int_tecnic_net_risc := f_round(prov_mat_mes_anterior
                                                 * POWER(1 + i_tecnicaplicat_net_risc / 100.0,
                                                         d / 365.0)
                                                 + suma_aportacions6 - suma_rescats6,
                                                 1);   --EE
               comissiogesinterna_pta := ROUND(pm_int_tecnic - pm_int_tecnic_net_ggi, 2);
               comissiogesexternaint_pta := ROUND(pm_int_tecnic - pm_int_tecnic_net_ggei, 2);
               comissiogesexternaext_pta := ROUND(pm_int_tecnic - pm_int_tecnic_net_ggee, 2);
               prima_riscpta := ROUND(pm_int_tecnic - pm_int_tecnic_net_risc, 2);
            END IF;
         END LOOP;

--Inserto les dades a InsertaMatrizProvMatGen
--Si inserto 1 vol dir que el camp és irrellevant
         retornaerror :=
            insertamatrizprovmatgen
                                  (0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, prima_riscpta,   --PRIMA RISC
                                   1, 1, comissiogesinterna_pta,   -- DESPESES GESTIÓ INTERNA
                                   comissiogesexternaint_pta,   -- DESPESES GESTIÓ EXTERNA INTERNA
                                   comissiogesexternaext_pta,   -- DESPESES GESTIO EXTERNA EXTERNA
                                   p_sproces);

         IF retornaerror < 0 THEN
            RETURN retornaerror;
         ELSE
            RETURN prov_mat_mes_actual;
         END IF;

         RETURN prov_mat_mes_actual;
      END f_matriz_provmat15_acumulat;
/**************************************************************************************/
/**************************************************************************************/
/*                                                               */
/*    INICI DE LA FUNCIO PRINCIPAL                                        */
/*                                                                  */
/*                                                                        */
/**************************************************************************************/
/**************************************************************************************/
   BEGIN
      --La data a la que busco la PM és la data de l'ultim dia del mes anterior al mes actual
      -- Busco Valores del Producto: Capitales Maximos por siniestro, % Capital Riesgo,
      -- % Gtos ext.Riesgo, % Interes Tecnico de Riesgo.
      BEGIN
         SELECT sproduc
           INTO psproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            psproduc := NULL;
      END;

      k_icapmaxaseguradopta := 0;
      k_icapmaxasegurado2pta := 0;
      k_icapmaxasegurado65pta := 0;
      k_por_cap_risc := 0;
      k_des_ext_risc := 0;
      k_int_tec_risc := 0;

      FOR param IN (SELECT dpa.cparpro, dpa.cvalpar, dpa.tvalpar
                      FROM parproductos par, detparpro dpa
                     WHERE par.sproduc = psproduc
                       AND par.cparpro IN('IMMAXCAPSIN1ASE', 'IMMAXCAPSIN2ASE',
                                          'IMMAXCAPSIN65', 'PORCAPITALRISC', 'PORGTOSEXTRISC',
                                          'PORINTTECNRISC')
                       AND par.cparpro = dpa.cparpro
                       AND dpa.cidioma = 1
                       AND par.cvalpar = dpa.cvalpar) LOOP
         IF param.cparpro = 'IMMAXCAPSIN1ASE' THEN
            k_icapmaxaseguradopta := NVL(TO_NUMBER(param.tvalpar), 0);
         ELSIF param.cparpro = 'IMMAXCAPSIN2ASE' THEN
            k_icapmaxasegurado2pta := NVL(TO_NUMBER(param.tvalpar), 0);
         ELSIF param.cparpro = 'IMMAXCAPSIN65' THEN
            k_icapmaxasegurado65pta := NVL(TO_NUMBER(param.tvalpar), 0);
         ELSIF param.cparpro = 'PORCAPITALRISC' THEN
            k_por_cap_risc := NVL(TO_NUMBER(param.tvalpar), 0);
         ELSIF param.cparpro = 'PORGTOSEXTRISC' THEN
            k_des_ext_risc := NVL(TO_NUMBER(param.tvalpar), 0);
         ELSIF param.cparpro = 'PORINTTECNRISC' THEN
            k_int_tec_risc := NVL(TO_NUMBER(param.tvalpar), 0);
         END IF;
      END LOOP;

      --Caluclo l'ultim dia del mes anterior de la data F_CALCUL_PM
      p_data_pm_inicial := LAST_DAY(ADD_MONTHS(f_calcul_pm, -1));
      --Inicialment no hi ha error
      num_err := 0;
      psproces := 34;

      -- Abrimos el cursor general de las pólizas
      FOR reg IN c_polizas_provmat LOOP
         cont := 0;
         p_cdivisa := reg.cdivisa;
         psexo1 := NULL;
         fnacimi2 := NULL;

         FOR per IN c_personas(psseguro) LOOP
            IF (cont = 0) THEN
               psexo := per.csexper;
               fnacimi1 := per.fnacimi;
            ELSE
               psexo1 := per.csexper;
               fnacimi2 := per.fnacimi;
            END IF;

            cont := cont + 1;
         END LOOP;

         FOR reggar IN c_garantias_provmat(psseguro, reg.cramo, reg.cmodali, reg.ctipseg,
                                           reg.ccolect) LOOP
            p_pm_inicial := pm_a_data_inicial(p_data_pm_inicial, psseguro);

            IF p_pm_inicial = 100 THEN
               IF TO_CHAR(f_calcul_pm, 'YYYYMM') = TO_CHAR(reg.fefecto, 'YYYYMM') THEN
                  --La PM es la 1a Aportacio
                  cont := 1;

                  FOR c1 IN c_primeraaportacio(psseguro, reg.fefecto) LOOP
                     IF cont = 1 THEN
                        p_pm_inicial := c1.imovimi;
                        p_data_pm_inicial := reg.fefecto - 1;
                        cont := 2;
                     END IF;
                  END LOOP;

                  IF cont = 1 THEN
                     RETURN -100;
                  END IF;
               ELSE
                  RETURN -100;
               END IF;
            END IF;

            --La provisió matemàtica a data posterior és 0
            IF f_calcul_pm > reg.fvencim THEN
               RETURN(0);
            END IF;

            -- Provisió matematica per el PEG i PIG
            IF reggar.cprovis = 18
               OR reggar.cprovis = 19 THEN
               IF p_cdivisa = 2 THEN
                  pta := TRUE;
               ELSE
                  pta := FALSE;
               END IF;

               --Actualitzem el màximd el capital assegurat (PTA o Euros)
               act_max_cap_asse(pta);
/*       IF REGGAR.CPROVIS = 18 THEN   --PIG
                 BEGIN
                  SELECT PINTTEC,FEIMTEC
                  INTO IT1P,PFEIMTEC
                  FROM SEGUROS_AHO
                  WHERE SSEGURO = PSSEGURO;
                     EXCEPTION WHEN OTHERS THEN
                     RETURN(-54);
                 END;
         ELSE  --PEG
*/
               it1p := NULL;
--          pFEIMTEC:=NULL;
--       END IF;
               num_err :=
                  f_matriz_provmat13_acumulat
                     (p_data_pm_inicial + 1,   -- és el primer dia despres de p_data_PM_Inicial
                      p_pm_inicial, f_calcul_pm,   --p_Data_Final       -- Data de càlcul (pot ser qualssevol dia)
                      reg.fefecto, psexo,   --p_sexo             -- Sexe del primer assegurat (1: home, 2: dona)
                      psexo1,   --p_sexo2            -- Sexe del segon assegurat (1: home; 2 dona; NULL: només hi ha un assegurat)
                      fnacimi1,   --p_data_Naix        -- Data naixement individu 1
                      fnacimi2,   --p_data_Naix2       -- Data naixement individu 2
                      k_int_tec_risc,   --p_int_tec_risc_Perc  -- Interes tecnic de risc (Expressat en %)
                      k_por_cap_risc,   --p_por_Cap_Risc        -- % de Capital de Riesgo
                      it1p,   --p_int_tec_Perc SEGUROS_AHO.PINTECC      -- Interes tecnic 1r periode (Expressat en %)
--                             pFEIMTEC,           --Data de finalittzacio del primer periode
                      NULL, reg.pgasint,   --PRODUCTOS.PGASINT  --p_des_GInternaSI_Perc  -- Despeses de gestió interna sobre interès
                      reg.pgaexin, reg.pgaexex,   --PRODUCTOS.PGASEXT      --p_des_GExternaRisc_Perc -- Despeses de gestió externa (risc)
                      k_des_ext_risc, k_icapmaxasegurado,   --Límit màxim de capital assegurat (1 cabeza)
                      k_icapmaxasegurado2,   --Límit màxim de capital assegurat (2 cabezas)
                      k_icapmaxasegurado65,   -- Limit màxim de capital assegurat als 65 anys
                      reggar.ctabla,   --p_ctiptab     -- Codi de la taula de mortalitat
                      psseguro,   --Número d'assegurança
                      psproces,   --Número de procès
                      reggar.cprovis, p_cdivisa);
            -- Provisió matematica per el PPP (PLA PERSONA DE PREVISIÓ, PLA INFANTIL DE PREVISIÓ, PLA JUVENIL DE PREVISIÓ)
            ELSIF reggar.cprovis = 20   --PPP
                  OR reggar.cprovis = 21   --PIPPJP
                  OR reggar.cprovis = 22   -- ?
                  OR reggar.cprovis = 24   --PIP
                                        THEN
               --Cridem a la funció que retorna la provisió matemàtica
               --si és negatiu s'ha produït un error
               num_err :=
                  f_matriz_provmat14_acumulat
                         (p_data_pm_inicial + 1,   -- és el primer dia despres de p_data_PM_Inicial
                          p_pm_inicial, f_calcul_pm, reg.pinttec, reg.pgaexex, psseguro,
                          psproces, p_cdivisa);
            -- PROVISIó MATEMATICA PER  EL PLA18: PLA PEROSNAL DE PREVISIó
            ELSIF reggar.cprovis = 23 THEN
               num_err :=
                  f_matriz_provmat15_acumulat
                         (p_data_pm_inicial + 1,   -- és el primer dia despres de p_data_PM_Inicial
                          p_pm_inicial, f_calcul_pm,   --p_Data_Final
                          reg.pgaexex + reg.pgasint + reg.pgaexin,   -- Despeses del producte PLA 18
                          reg.pgasint,   --PRODUCTOS.PGASINT
                          reg.pgaexin, reg.pgaexex,   --PRODUCTOS.PGASEXT
                          psseguro,   --Número d'assegurança
                          psproces,   --Número de procès
                          p_cdivisa);
            END IF;
         END LOOP;
      END LOOP;

      RETURN num_err;
   END f_matriz_provmat_acumulat;

   FUNCTION f_eurospesetas(pvalor IN NUMBER, pcdivisa IN NUMBER)
      RETURN NUMBER IS
/***********************************************************************
 pvalor --> Valor en pesetas o euros, que se quiere transformar
 pcdivisa --> Codigo de la divisa en el que esta el pvalor
 Siempre transforma  a la divisa contraria a la introducida.

***********************************************************************/
   BEGIN
      IF (pcdivisa = 2) THEN
         /* Transformamos el pvalor a euros*/
         RETURN(pvalor / 166.386);
      ELSIF(pcdivisa = 3) THEN
         /* Transformamos el pvalor a pesetas*/
         RETURN(166.386 * pvalor);
      ELSE
         RETURN(0);
      END IF;
   END;

   FUNCTION f_cierre(
      psseguro IN NUMBER,
      pfecha IN DATE,
      provmat OUT NUMBER,
      gastos_int OUT NUMBER,
      gastos_ext_ext OUT NUMBER,
      gastos_ext_int OUT NUMBER,
      prima_risc OUT NUMBER,
      pb OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vsproduc       NUMBER;
      vfvencim       NUMBER;
      vtipo          NUMBER;
      tcdivisa       NUMBER;
   BEGIN
      provmat := 0;
      gastos_int := 0;
      gastos_ext_ext := 0;
      gastos_ext_int := 0;
      prima_risc := 0;
      pb := 0;

      BEGIN
         SELECT p.sproduc, cdivisa
           INTO vsproduc, tcdivisa
           FROM productos p, seguros s
          WHERE s.sseguro = psseguro
            AND p.cramo = s.cramo
            AND p.cmodali = s.cmodali
            AND p.ctipseg = s.ctipseg
            AND p.ccolect = s.ccolect
            AND s.csituac <> 4
            AND(s.fvencim >= pfecha
                OR s.fvencim IS NULL)
            AND(s.fanulac >= pfecha
                OR s.fanulac IS NULL)
            AND s.fefecto <= pfecha;

--
         SELECT cvalpar
           INTO vtipo
           FROM parproductos
          WHERE sproduc = vsproduc
            AND cparpro = 'DESPRODPROVMAT';
--
      EXCEPTION
         WHEN OTHERS THEN
            num_err := -1;
      END;

      BEGIN
--    IF( VTIPO = 6 OR VTIPO = 7 OR VTIPO = 8 OR VTIPO = 9 OR VTIPO = 10 OR VTIPO = 11)THEN
--      PROVMAT := F_MATRIZ_PROVMAT_ACUMULAT(PSSEGURO, PFECHA);
--    ELSE
         IF vtipo <> 4 THEN
            provmat := pk_provmatematicas.f_provmat(1, psseguro, pfecha, 1, 0);
         END IF;

-- END IF;
         IF tcdivisa = 2 THEN   --PTA
            provmat := ROUND(provmat);
         ELSE
            provmat := f_round(provmat, 1);   --EUROS
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := -1;
      END;

      IF (vtipo = 4) THEN   --RVI
         BEGIN
/* AFM Optimizar Cierre */
            cieprovmat := 0;
            ciegasinte := 0;
            ciegasexin := 0;
            ciegasexex := 0;
            gastos_int := f_provmat(1, psseguro, pfecha, 8, 0);
            provmat := cieprovmat;
            gastos_int := ciegasinte;
            gastos_ext_ext := ciegasexex;
            gastos_ext_int := ciegasexin;
--    GASTOS_INT :=  F_PROVMAT(1, PSSEGURO, PFECHA, 6 , 0);
--    GASTOS_EXT_EXT :=  F_PROVMAT(1, PSSEGURO, PFECHA, 3 , 0);
--    GASTOS_EXT_INT :=  F_PROVMAT(1, PSSEGURO, PFECHA, 5 , 0);
         EXCEPTION
            WHEN OTHERS THEN
               num_err := -1;
         END;
      -- PPP, VUITON, PULITUB, PJP, PIP
      ELSIF(vtipo = 8
            OR vtipo = 9
            OR vtipo = 10) THEN
         SELECT ippmort
           INTO pb
           FROM matrizprovmatgen
          WHERE cindice = 0;
      -- PIG, PEG, PLA18:  --6 PIG, 7 PEG ,11--PLA 18
      ELSIF(vtipo = 6
            OR vtipo = 7
            OR vtipo = 11) THEN
         SELECT ippmort, ipcvid, ippvid, vecmort
           INTO gastos_int, gastos_ext_int, gastos_ext_ext, prima_risc
           FROM matrizprovmatgen
          WHERE cindice = 0;
      END IF;

      RETURN(num_err);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_cierre;

   FUNCTION f_cierre_provmat(psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      v_cramo        NUMBER := 0;
      v_cmodali      NUMBER := 0;
      v_ctipseg      NUMBER := 0;
      v_ccolect      NUMBER := 0;
      v_fcalcul      NUMBER := 0;
      v_provmat      NUMBER := 0;
      v_cramdgs      NUMBER := 0;
      v_cactivi      NUMBER := 0;
      v_nriesgo      NUMBER := 0;
      v_cgarant      NUMBER := 0;
      v_ctabla       NUMBER := 0;
      v_cprovis      NUMBER := 0;
      v_ipriini      NUMBER := 0;
      v_icapgar      NUMBER := 0;
      v_efecto       DATE;
      v_moviment     NUMBER := 0;
      v_sproces      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.fefecto
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, v_efecto
           FROM seguros s
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_err := -1;
         WHEN OTHERS THEN
            num_err := -2;
      END;

      BEGIN
         SELECT cramdgs
           INTO v_cramdgs
           FROM productos
          WHERE cramo = v_cramo
            AND cmodali = v_cmodali
            AND ccolect = v_ccolect
            AND ctipseg = v_ctipseg;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_err := -1;
         WHEN OTHERS THEN
            num_err := -2;
      END;

      BEGIN
         SELECT imovimi
           INTO v_provmat
           FROM ctaseguro
          WHERE cmovimi = 0
            AND TO_CHAR(LAST_DAY(fvalmov), 'YYYYMMDD') = TO_CHAR(LAST_DAY(pfecha), 'YYYYMMDD')
            AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_err := -3;
         WHEN OTHERS THEN
            num_err := -4;
      END;

      BEGIN
         SELECT DISTINCT g.nriesgo, g.cgarant, gp.ctabla, gp.cprovis
                    INTO v_nriesgo, v_cgarant, v_ctabla, v_cprovis
                    FROM garanpro gp, garanseg g
                   WHERE g.sseguro = psseguro
                     AND cprovis IS NOT NULL
                     AND g.cgarant = gp.cgarant
                     AND gp.cramo = v_cramo
                     AND gp.cmodali = v_cmodali
                     AND gp.ctipseg = v_ctipseg
                     AND gp.ccolect = v_ccolect
                     AND gp.cactivi = v_cactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_err := -5;
         WHEN OTHERS THEN
            num_err := -6;
      END;

      BEGIN
         SELECT SUM(imovimi)
           INTO v_ipriini
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND TO_CHAR(fcontab, 'YYYYMMDD') = TO_CHAR(v_efecto, 'YYYYMMDD')
            AND cmovimi = 1;

         IF (v_ipriini IS NULL) THEN
            v_ipriini := 0;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_err := -7;
         WHEN OTHERS THEN
            num_err := -8;
      END;

      num_err := f_buscanmovimi(psseguro, 1, 1, v_moviment);

      IF num_err != 0 THEN
         RETURN -1;
      END IF;

      BEGIN
         SELECT SUM(icapital)
           INTO v_icapgar
           FROM garanseg g
          WHERE g.sseguro = psseguro
            AND g.nmovimi = v_moviment
            AND g.cgarant = (SELECT cgarant
                               FROM pargaranpro
                              WHERE cvalpar = 2
                                AND cramo = v_cramo
                                AND cmodali = v_cmodali
                                AND ccolect = v_ccolect
                                AND ctipseg = v_ctipseg
                                AND cactivi = v_cactivi
                                AND cpargar = 'GARPROVMAT');

         IF (v_icapgar IS NULL) THEN
            v_icapgar := 0;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_err := -11;
         WHEN OTHERS THEN
            num_err := -12;
      END;

      BEGIN
         SELECT sproces.NEXTVAL
           INTO v_sproces
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_err := -13;
         WHEN OTHERS THEN
            num_err := -14;
      END;

      -- Anem a inserir a provmat
      BEGIN
         INSERT INTO provmat
                     (cempres, fcalcul, sproces, cramdgs, cramo, cmodali,
                      ctipseg, ccolect, sseguro, cgarant, cprovis, ipriini, ivalact,
                      icapgar, ipromat, cerror, nriesgo)
              VALUES (2, LAST_DAY(pfecha), v_sproces, v_cramdgs, v_cramo, v_cmodali,
                      v_ctipseg, v_ccolect, psseguro, v_cgarant, v_cprovis, v_ipriini, 0,
                      v_icapgar, v_provmat, num_err, v_nriesgo);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := -15;
      END;

      RETURN(num_err);
   END f_cierre_provmat;
END pk_provmatematicas;

/

  GRANT EXECUTE ON "AXIS"."PK_PROVMATEMATICAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_PROVMATEMATICAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_PROVMATEMATICAS" TO "PROGRAMADORESCSI";
