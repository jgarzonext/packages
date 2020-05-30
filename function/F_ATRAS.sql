--------------------------------------------------------
--  DDL for Function F_ATRAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ATRAS" (psproces IN NUMBER,
   psseguro IN NUMBER,
   pfinici IN DATE,
   pmotiu IN NUMBER,
   pmoneda IN NUMBER,
   pnmovigen IN NUMBER DEFAULT NULL,
   pfdatagen IN DATE DEFAULT f_sysdate,
   ptablas IN VARCHAR2 DEFAULT 'REA')
   RETURN NUMBER IS
/***********************************************************************************
 OBJETO:     FUNCI¿N
 SISTEMA:    REASEGURO
 ENTRADAS:
             PSPROCES
               Identificador de proceso que genera la anulaci¿n
             PSSEGURO
                  Identificador de seguro
             PFINICI
                  Fecha a partir de la cual se retroceder¿n cesiones
             PMOTIU
                  Motivo del retroceso ( 6,7,8)
             PMONEDA
                  Moneda (1-Euros,2-Pesetas)
 SALIDAS:
 DESCRIPCION:
      Aquesta funci¿ permet crear moviments d'anul-laci¿ de cessions a CESIONESREA.
      Aquest moviments poden estar originats per l'entrada d'un suplement o per
     l'anul-laci¿ de p¿lissa o suplement...
      Els tipus o motius de moviments anul-lables son:
         01 - REGULARITZACI¿
         03 - NOVA PRODUCCI¿
         04 - SUPLEMENT
         05 - CARTERA
         09 - REHABILITACI¿
         40 - ALLARGAMENT POSITIU ( RENOVACI¿ CAP AL FUTUR)
      Els tipus o motius que es crean son:
         06 - ANUL.LACI¿ DE P¿LISSA
         07 - ANUL.LACI¿ PER CAUSA DE SUPLEMENT
     ALLIBREA

     HISTORICO DE MODIFICACIONES:
                           No se anulaban cesiones con fecha de anulaci¿n
                           que cubriese m¿s de un movimiento.

                           El moviment d'anul.laci¿ es far¿ sempre en funci¿ de la
                           data d'efecte d'aquesta i considerant nom¿s la part en
                           vig¿ncia de cada un dels moviments que afecti, sense
                           que influeixi les formes de pagament ni duraci¿

                           Controlar el prorrateig tamb¿ en funci¿ de la data FREGULA
                           informada en els registres afectats per un canvi de
                           versi¿ del contracte

 REVISIONES:
 Ver    Fecha       Autor             Descripci¿n
 -----  ----------  ------  ------------------------------------
 1.0    XX/XX/XXXX  XXX     1. Creaci¿n de la funci¿n.
 2.0    03/03/2011  JGR     2. 0017672: CEM800 - Contracte Reaseguro 2011 - A¿adir nuevo par¿metro w_cdetces
 3.0    14/02/2012  JMF     3. 0021242: CCAT998-CEM - Anulaci¿n pol vto 60160497
 4.0    25/05/2013  LCF     4. 0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
 5.0    16/10/2013  MMM     5. 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision
 6.0    04/09/2014  DFD     6. 0028056: NOTA 82706 QT_8672 extraprima en caso de suplemento.
 7.0    21/01/2015  EDA     7. 0037052: No realice el prorrateo cuando exista el parametro del producto y sea un suplemento NO_PRORRATEA_REA_SUP'
 8.0     09/11/2016 HRE     8. CONF-294: manejo de detalle por garantia
**********************************************************************************/

   -- ini Bug 0021242 - 14/02/2012 - JMF
   vpas           NUMBER := 0;
   vobj           VARCHAR2(200) := 'f_atras';
   vpar           VARCHAR2(500)
      := 'p=' || psproces || ' s=' || psseguro || ' i=' || pfinici || ' m=' || pmotiu || ' m='
         || pmoneda || ' g=' || pnmovigen || ' f=' || pfdatagen;
   -- fin Bug 0021242 - 14/02/2012 - JMF
   codi_error     NUMBER := 0;
   w_dias         NUMBER;
   w_dias_origen  NUMBER;
   w_icesion      cesionesrea.icesion%TYPE;   -- bug 25803
   w_ipritarrea   cesionesrea.ipritarrea%TYPE;   -- bug 25803
   w_iextrea      cesionesrea.iextrea%TYPE;   -- bug 28056
   w_icomext      cesionesrea.icomext%TYPE;
   w_idtosel      cesionesrea.idtosel%TYPE;   -- bug 25803
   w_scesrea      cesionesrea.scesrea%TYPE;   -- bug 25803
   avui           DATE;
   w_finianulces  cesionesrea.fefecto%TYPE;   --- bug 25803
   w_ffinanulces  cesionesrea.fefecto%TYPE;   -- bug 25803
   -- w_cduraci        NUMBER;
   w_cforpag      seguros.cforpag%TYPE;   -- bug 25803
   lsproduc       seguros.sproduc%TYPE;   -- bug 25803
   ldetces        NUMBER;
   lnmovigen      cesionesrea.nmovigen%TYPE;   -- bug 25803
   w_sdetcesrea   det_cesionesrea.sdetcesrea%TYPE; --BUG CONF-294  Fecha (09/11/2016) - HRE
   w_ssegpol      estseguros.ssegpol%TYPE;
   w_npoliza      estseguros.npoliza%TYPE;
   w_ncertif      estseguros.ncertif%TYPE;

   CURSOR cur_movim IS
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09
             OR cgenera = 40)
         AND fvencim > GREATEST(pfinici, fefecto)
         -- CPM 6/3/06: Se coge la fecha m¿s grande pues es la que luego se updatar¿
         AND(fanulac > GREATEST(pfinici, fefecto)
             OR fanulac IS NULL)
         AND(fregula > GREATEST(pfinici, fefecto)
             OR fregula IS NULL);

	 CURSOR cur_movim_est IS

      SELECT *
        FROM estcesionesrea
       WHERE sseguro = psseguro
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09
             OR cgenera = 40)
         AND fvencim > GREATEST(pfinici, fefecto)
         -- CPM 6/3/06: Se coge la fecha m¿s grande pues es la que luego se updatar¿
         AND(fanulac > GREATEST(pfinici, fefecto)
             OR fanulac IS NULL)
         AND(fregula > GREATEST(pfinici, fefecto)
             OR fregula IS NULL);


      --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
      CURSOR cur_detalle_rea(pscesrea NUMBER) IS
         SELECT *
           FROM det_cesionesrea
          WHERE scesrea = pscesrea;
      --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE
-- 13195 01-03-2010 AVT actualitzem tamb¿ els registres negatiu perque no els reculli el detall
   CURSOR cur_movim_anula(proces IN NUMBER) IS
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND(cgenera = 06
             OR cgenera = 07)
         AND fvencim > GREATEST(pfinici, fefecto)
         -- CPM 6/3/06: Se coge la fecha m¿s grande pues es la que luego se updatar¿
         AND(fanulac > GREATEST(pfinici, fefecto)
             OR fanulac IS NULL)
         AND(fregula > GREATEST(pfinici, fefecto)
             OR fregula IS NULL)
         AND sproces <> NVL(proces, 0);

	CURSOR cur_movim_anula_est(proces IN NUMBER) IS
      SELECT *
        FROM estcesionesrea
       WHERE sseguro = psseguro
         AND(cgenera = 06
             OR cgenera = 07)
         AND fvencim > GREATEST(pfinici, fefecto)
         -- CPM 6/3/06: Se coge la fecha m¿s grande pues es la que luego se updatar¿
         AND(fanulac > GREATEST(pfinici, fefecto)
             OR fanulac IS NULL)
         AND(fregula > GREATEST(pfinici, fefecto)
             OR fregula IS NULL)
         AND sproces <> NVL(proces, 0);

BEGIN
   vpas := 1000;
   p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 1');
   IF pnmovigen IS NULL THEN
      -- Obtenim el n¿ nmovigen
      BEGIN
         vpas := 1010;

         IF ptablas = 'EST' THEN
            BEGIN
               SELECT NVL(MAX(nmovigen), 0) + 1
                 INTO lnmovigen
                 FROM estcesionesrea   --cambiado
                WHERE sseguro = psseguro;
            END;
         ELSE
            BEGIN
               SELECT NVL(MAX(nmovigen), 0) + 1
                 INTO lnmovigen
                 FROM cesionesrea
                WHERE sseguro = psseguro;
            END;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            lnmovigen := 1;
      END;
   ELSE
      lnmovigen := pnmovigen;
   END IF;

   vpas := 1020;
   avui := pfdatagen;

   BEGIN
      vpas := 1030;


p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'F_ATRAS', 'F_ATRAS', NULL, 1, 'Error: paso 1'||
                  'ptablas:'||ptablas||'psseguro:'||psseguro);


      IF ptablas = 'EST' THEN
         BEGIN
            SELECT sproduc, cforpag, ssegpol, npoliza, ncertif
              INTO lsproduc, w_cforpag, w_ssegpol, w_npoliza, w_ncertif
              FROM estseguros
             WHERE sseguro = psseguro;
         END;
      ELSE
         BEGIN
            SELECT sproduc, cforpag
              INTO lsproduc, w_cforpag
              FROM seguros
             WHERE sseguro = psseguro;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- Bug 0021242 - 14/02/2012 - JMF
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 101919;
   END;

   vpas := 1040;

   IF ptablas = 'EST' THEN
      p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 2');
      BEGIN
         FOR regmovim IN cur_movim_est LOOP
            -- Controlamos que no se haya anulado ya una parte de la cesi¿n
            IF regmovim.fregula IS NOT NULL THEN   -- Control dels registres afectats per un
               w_ffinanulces := regmovim.fregula;   -- canvi de versi¿ de contracte
            ELSIF regmovim.fanulac IS NOT NULL THEN
               w_ffinanulces := regmovim.fanulac;
            ELSE
               w_ffinanulces := regmovim.fvencim;
            END IF;

            -- Se controla la fecha de inicio de anulaci¿n.
            IF regmovim.fefecto < pfinici THEN
               w_finianulces := pfinici;
            ELSE
               w_finianulces := regmovim.fefecto;
            END IF;

            BEGIN
               vpas := 1050;

               UPDATE estcesionesrea
                  SET fanulac = w_finianulces
                WHERE scesrea = regmovim.scesrea;
--          POST;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- Bug 0021242 - 14/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              vpar || ' c=' || regmovim.scesrea || ' a=' || w_finianulces,
                              SQLCODE || ' ' || SQLERRM);
                  codi_error := 104738;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  -- Bug 0021242 - 14/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              vpar || ' c=' || regmovim.scesrea || ' a=' || w_finianulces,
                              SQLCODE || ' ' || SQLERRM);
                  codi_error := 104739;
                  RETURN(codi_error);
            END;

            vpas := 1060;
            -- 5.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
            --codi_error := f_difdata(regmovim.fefecto, regmovim.fvencim, 1, 3, w_dias_origen);
            codi_error := f_difdata(regmovim.fefecto, regmovim.fvencim, 3, 3, w_dias_origen);

            -- 5.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
            IF codi_error <> 0 THEN
               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' ini=' || regmovim.fefecto || ' fin=' || regmovim.fvencim,
                           SQLCODE || ' ' || SQLERRM);
               RETURN(codi_error);
            END IF;

            vpas := 1070;
            -- 5.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
            --codi_error := f_difdata(w_finianulces, w_ffinanulces, 1, 3, w_dias);
            codi_error := f_difdata(w_finianulces, w_ffinanulces, 3, 3, w_dias);

            -- 5.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
            IF codi_error <> 0 THEN
               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' ini=' || w_finianulces || ' fin=' || w_ffinanulces,
                           SQLCODE || ' ' || SQLERRM);
               RETURN(codi_error);
            END IF;

            IF w_dias_origen = 0 THEN
               w_dias_origen := 1;
            END IF;

            IF w_dias = 0 THEN
               w_dias := 1;
            END IF;

            vpas := 1080;
            w_icesion := f_round((regmovim.icesion * w_dias) / w_dias_origen, pmoneda);
            vpas := 1090;
            w_ipritarrea := f_round((regmovim.ipritarrea * w_dias) / w_dias_origen, pmoneda);
            vpas := 1100;
            -- Bug 28056 - 04/09/2014 - DF: extraprima en caso de suplemento Inicio
            w_iextrea := f_round((regmovim.iextrea * w_dias) / w_dias_origen, pmoneda);

            -- Bug 28056 - 04/09/2014 - DF: extraprima en caso de suplemento Fin
            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            BEGIN
               vpas := 1120;

               INSERT INTO estcesionesrea
                           (scesrea, ncesion, icesion, icapces,
                            sseguro, ssegpol, npoliza, ncertif,
                            nversio, scontra, ctramo,
                            sfacult, nriesgo, icomisi,
                            scumulo, cgarant, spleno,
                            nmovimi, fefecto, fvencim, pcesion,
                            sproces, cgenera, fgenera, ipritarrea, psobreprima,
                            cdetces, nmovigen, ipleno, icapaci,
                            iextrea, itarifrea)
                    VALUES (w_scesrea, regmovim.ncesion, w_icesion * -1, regmovim.icapces,
                            regmovim.sseguro, w_ssegpol, w_npoliza, w_ncertif,
                            regmovim.nversio, regmovim.scontra, regmovim.ctramo,
                            regmovim.sfacult, regmovim.nriesgo, regmovim.icomisi,
                            regmovim.scumulo, regmovim.cgarant, regmovim.spleno,
                            regmovim.nmovimi, w_finianulces, w_ffinanulces, regmovim.pcesion,
                            psproces, pmotiu, avui, -w_ipritarrea, regmovim.psobreprima,
                            regmovim.cdetces, lnmovigen, regmovim.ipleno, regmovim.icapaci,
                            -w_iextrea, regmovim.itarifrea);
--          POST;
            EXCEPTION
               WHEN OTHERS THEN
                  -- Bug 0021242 - 14/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              's=' || regmovim.sseguro || ' r=' || regmovim.nriesgo || ' c='
                              || regmovim.scontra || ' v=' || regmovim.nversio || ' g='
                              || regmovim.cgarant,
                              SQLCODE || ' ' || SQLERRM);
                  codi_error := 104740;
                  RETURN(codi_error);
            END;
         END LOOP;
      END;
   ELSE
      p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 3');
      BEGIN

		   FOR regmovim IN cur_movim LOOP
			  -- Controlamos que no se haya anulado ya una parte de la cesi¿n
			  --INI IAXIS BUG 10563 AABG: Se comenta condicioon para fecha anulacion para evitar division por 0 en cesiones manuales
			  IF regmovim.fregula IS NOT NULL THEN   -- Control dels registres afectats per un
				 w_ffinanulces := regmovim.fregula;   -- canvi de versi¿ de contracte
			  /*ELSIF regmovim.fanulac IS NOT NULL THEN
				 w_ffinanulces := regmovim.fanulac;*/
			  ELSE
				 w_ffinanulces := regmovim.fvencim;
			  END IF;
              --FIN IAXIS BUG 10563 AABG: Se comenta condicioon para fecha anulacion para evitar division por 0 en cesiones manuales

			  -- Se controla la fecha de inicio de anulaci¿n.
			  IF regmovim.fefecto < pfinici THEN
				 w_finianulces := pfinici;
			  ELSE
				 w_finianulces := regmovim.fefecto;
			  END IF;

			  BEGIN
				 vpas := 1050;

				 UPDATE cesionesrea
					SET fanulac = w_finianulces
				  WHERE scesrea = regmovim.scesrea;
		--          POST;
			  EXCEPTION
				 WHEN NO_DATA_FOUND THEN
					-- Bug 0021242 - 14/02/2012 - JMF
					p_tab_error(f_sysdate, f_user, vobj, vpas,
								vpar || ' c=' || regmovim.scesrea || ' a=' || w_finianulces,
								SQLCODE || ' ' || SQLERRM);
					codi_error := 104738;
					RETURN(codi_error);
				 WHEN OTHERS THEN
					-- Bug 0021242 - 14/02/2012 - JMF
					p_tab_error(f_sysdate, f_user, vobj, vpas,
								vpar || ' c=' || regmovim.scesrea || ' a=' || w_finianulces,
								SQLCODE || ' ' || SQLERRM);
					codi_error := 104739;
					RETURN(codi_error);
			  END;

			  vpas := 1060;
			  -- Inicio EDA Bug 38513 21/01/2016
			  vpas := 1061;
			  w_icesion := f_round(regmovim.icesion, pmoneda);
			  w_ipritarrea := f_round(regmovim.ipritarrea, pmoneda);
			  w_idtosel := f_round(regmovim.idtosel, pmoneda);
			  w_iextrea := f_round(regmovim.iextrea, pmoneda);
			  w_icomext := f_round(regmovim.icomext, pmoneda);


			  IF pmotiu = 7
				 AND NVL(f_parproductos_v(lsproduc, 'NO_PRORRATEA_REA_SUP'), 0) = 1 THEN
				 NULL;   -- >> NO PRORRATEJA!
			  ELSE
				 -- Fin EDA Bug 38513 21/01/2016

				 -- 5.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
				 --codi_error := f_difdata(regmovim.fefecto, regmovim.fvencim, 1, 3, w_dias_origen);
				 codi_error := f_difdata(regmovim.fefecto, regmovim.fvencim, 3, 3, w_dias_origen);

				 -- 5.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
				 IF codi_error <> 0 THEN
					-- Bug 0021242 - 14/02/2012 - JMF
					p_tab_error(f_sysdate, f_user, vobj, vpas,
								vpar || ' ini=' || regmovim.fefecto || ' fin=' || regmovim.fvencim,
								SQLCODE || ' ' || SQLERRM);
					RETURN(codi_error);
				 END IF;

				 vpas := 1070;
				 -- 5.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
				 --codi_error := f_difdata(w_finianulces, w_ffinanulces, 1, 3, w_dias);
				 codi_error := f_difdata(w_finianulces, w_ffinanulces, 3, 3, w_dias);

				 -- 5.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
				 IF codi_error <> 0 THEN
					-- Bug 0021242 - 14/02/2012 - JMF
					p_tab_error(f_sysdate, f_user, vobj, vpas,
								vpar || ' ini=' || w_finianulces || ' fin=' || w_ffinanulces,
								SQLCODE || ' ' || SQLERRM);
					RETURN(codi_error);
				 END IF;

				 IF w_dias_origen = 0 THEN
					w_dias_origen := 1;
				 END IF;

				 IF w_dias = 0 THEN
					w_dias := 1;
				 END IF;

				 vpas := 1080;
				 -- INI IAXIS 13084 AABG: Se aplica prorrateo o no a la prima cedida 1 -> No Aplica prorrateo / 0 -> Aplica prorrateo     
                 IF NVL(f_parproductos_v(lsproduc, 'APLICA_PRORRATEAR'), 0) = 1 THEN
                    w_icesion := f_round((regmovim.icesion), pmoneda);
                 ELSE
                    w_icesion := f_round((regmovim.icesion * w_dias) / w_dias_origen, pmoneda);
                 END IF;
                 -- FIN IAXIS 13084 AABG: Se aplica prorrateo o no a la prima cedida 1 -> Aplica prorrateo / 0 -> No Aplica prorrateo
				 vpas := 1090;
				 w_ipritarrea := f_round((regmovim.ipritarrea * w_dias) / w_dias_origen, pmoneda);
				 vpas := 1100;
				 w_idtosel := f_round((regmovim.idtosel * w_dias) / w_dias_origen, pmoneda);
				 -- fin Bug 0011802 - 17/11/2009 - JMF: canvi calcul.
				 vpas := 1110;
				 -- Bug 28056 - 04/09/2014 - DF: extraprima en caso de suplemento Inicio
				 w_iextrea := f_round((regmovim.iextrea * w_dias) / w_dias_origen, pmoneda);

				 w_icomext := f_round((regmovim.icomext * w_dias) / w_dias_origen, pmoneda);
			  END IF;   -- EDA Bug 38513 21/01/2016

			  -- Bug 28056 - 04/09/2014 - DF: extraprima en caso de suplemento Fin
			  SELECT scesrea.NEXTVAL
				INTO w_scesrea
				FROM DUAL;

			  BEGIN
				 vpas := 1120;
         p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 4');
				 INSERT INTO cesionesrea
							 (scesrea, ncesion, icesion, icapces,
							  sseguro, nversio, scontra, ctramo,
							  sfacult, nriesgo, icomisi, icomreg,
							  scumulo, cgarant, spleno, ccalif1,
							  ccalif2, nmovimi, fefecto, fvencim,
							  pcesion, sproces, cgenera, fgenera, ipritarrea, idtosel,
							  psobreprima, cdetces, nmovigen, ipleno,
							  icapaci, iextrea, itarifrea, icomext)
					  VALUES (w_scesrea, regmovim.ncesion, w_icesion * -1, regmovim.icapces,
							  regmovim.sseguro, regmovim.nversio, regmovim.scontra, regmovim.ctramo,
							  regmovim.sfacult, regmovim.nriesgo, regmovim.icomisi, regmovim.icomreg,
							  regmovim.scumulo, regmovim.cgarant, regmovim.spleno, regmovim.ccalif1,
							  regmovim.ccalif2, regmovim.nmovimi, w_finianulces, w_ffinanulces,
							  regmovim.pcesion, psproces, pmotiu, avui, -w_ipritarrea, -w_idtosel,
							  regmovim.psobreprima, regmovim.cdetces, lnmovigen, regmovim.ipleno,
							  regmovim.icapaci, -w_iextrea, regmovim.itarifrea, w_icomext*-1);
		--          POST;
         p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 5');       
				 --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
				 FOR rg_detalle_rea IN cur_detalle_rea(regmovim.scesrea) LOOP
           p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 6');
					SELECT sdetcesrea.NEXTVAL
					  INTO w_sdetcesrea
					  FROM DUAL;

					INSERT INTO det_cesionesrea(scesrea, sdetcesrea, sseguro, nmovimi, ptramo, cgarant, icesion, icapces,
												pcesion, psobreprima, iextrap , iextrea , ipritarrea , itarifrea, icomext,
												ccompani, falta, cusualt, fmodifi, cusumod, cdepura, fefecdema,
												nmovidep, sperson)

					VALUES (w_scesrea, w_sdetcesrea, rg_detalle_rea.sseguro, rg_detalle_rea.nmovimi, rg_detalle_rea.ptramo,
							rg_detalle_rea.cgarant, -rg_detalle_rea.icesion, rg_detalle_rea.icapces, rg_detalle_rea.pcesion,
							rg_detalle_rea.psobreprima, rg_detalle_rea.iextrap , -rg_detalle_rea.iextrea , -rg_detalle_rea.ipritarrea ,
							rg_detalle_rea.itarifrea, -rg_detalle_rea.icomext,rg_detalle_rea.ccompani, rg_detalle_rea.falta,
							rg_detalle_rea.cusualt, f_sysdate, f_user, rg_detalle_rea.cdepura, rg_detalle_rea.fefecdema,
							rg_detalle_rea.nmovidep, rg_detalle_rea.sperson);

				 END LOOP;
				 --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE

			  EXCEPTION
				 WHEN OTHERS THEN
					-- Bug 0021242 - 14/02/2012 - JMF
					p_tab_error(f_sysdate, f_user, vobj, vpas,
								's=' || regmovim.sseguro || ' r=' || regmovim.nriesgo || ' c='
								|| regmovim.scontra || ' v=' || regmovim.nversio || ' g='
								|| regmovim.cgarant,
								SQLCODE || ' ' || SQLERRM);
					codi_error := 104740;
					RETURN(codi_error);
			  END;
		   END LOOP;
		END;
   END IF;

   -- 13195 AVT 01-03-2010
   vpas := 1130;

   IF ptablas = 'EST' THEN
     p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 7');
      BEGIN
         FOR regmov IN cur_movim_anula_est(psproces) LOOP
           p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 7');
            BEGIN
               UPDATE estcesionesrea
                  SET fanulac = w_finianulces
                WHERE scesrea = regmov.scesrea;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- Bug 0021242 - 14/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              vpar || ' ces=' || regmov.scesrea || ' anu=' || w_finianulces,
                              SQLCODE || ' ' || SQLERRM);
                  codi_error := 104738;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  -- Bug 0021242 - 14/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              vpar || ' ces=' || regmov.scesrea || ' anu=' || w_finianulces,
                              SQLCODE || ' ' || SQLERRM);
                  codi_error := 104739;
                  RETURN(codi_error);
            END;
         END LOOP;
      END;
   ELSE
      BEGIN
      p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 8');
		   FOR regmov IN cur_movim_anula(psproces) LOOP
         p_control_error('F_ATRAS', 'F_ATRAS','1 PASO 9');
			  BEGIN
				 UPDATE cesionesrea
					SET fanulac = w_finianulces
				  WHERE scesrea = regmov.scesrea;
			  EXCEPTION
				 WHEN NO_DATA_FOUND THEN
					-- Bug 0021242 - 14/02/2012 - JMF
					p_tab_error(f_sysdate, f_user, vobj, vpas,
								vpar || ' ces=' || regmov.scesrea || ' anu=' || w_finianulces,
								SQLCODE || ' ' || SQLERRM);
					codi_error := 104738;
					RETURN(codi_error);
				 WHEN OTHERS THEN
					-- Bug 0021242 - 14/02/2012 - JMF
					p_tab_error(f_sysdate, f_user, vobj, vpas,
								vpar || ' ces=' || regmov.scesrea || ' anu=' || w_finianulces,
								SQLCODE || ' ' || SQLERRM);
					codi_error := 104739;
					RETURN(codi_error);
			  END;
		   END LOOP;
		END;
   END IF;
   -- Si estem anul¿lant una p¿lissa cessions d'un producte que es calcula
   -- la cessio al quadre d'amortitzaci¿, tamb¿ haurem d'anul¿lar
   -- el detall de reasegemi i detreasegemi. Les que no s'hi calculen ja s'anul.len
   -- quan s'anul.la el rebut
   IF codi_error = 0 THEN
      ldetces := NULL;
      --codi_error := f_parproductos(lsproduc, 'REASEGURO', ldetces); -- BUG: 17672 JGR 23/02/2011
      vpas := 1140;
       ldetces := f_cdetces(psseguro, NULL, ptablas);   -- BUG: 17672 JGR 23/02/2011

      --IF codi_error = 0 THEN                                        -- BUG: 17672 JGR 23/02/2011
      IF NVL(ldetces, 0) = 2 THEN   -- calcul a q amort.
         vpas := 1150;
         codi_error := pac_cesionesrea.f_cesdet_anu_per(psseguro, pfinici, 2);

         -- Bug 0021242 - 14/02/2012 - JMF
         IF codi_error <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         END IF;
      -- 2 Anul.laci¿
      END IF;
   --END IF;                                                       -- BUG: 17672 JGR 23/02/2011
   END IF;

   RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_ATRAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ATRAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ATRAS" TO "PROGRAMADORESCSI";
