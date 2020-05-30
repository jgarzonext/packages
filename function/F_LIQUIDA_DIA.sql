--------------------------------------------------------
--  DDL for Function F_LIQUIDA_DIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_LIQUIDA_DIA" (pcempres IN NUMBER, pccompani IN NUMBER, pfecini IN DATE,
                        pfecfin IN DATE , psproces OUT NUMBER )
         RETURN NUMBER authid current_user IS

CURSOR c_liq (wemp NUMBER, wcia NUMBER ) IS
   SELECT c.cempres, c.ccompani, l.icomliq, l.nrecibo, l.smovrec
   FROM liquidalincia l, liquidacabcia c
   WHERE c.cempres  = wemp
     AND l.cempres  = c.cempres
     AND l.CCOMPANI = c.CCOMPANI
     AND l.NLIQMEN  = c.NLIQMEN
     AND c.FLIQUID IS NULL
     AND (c.CCOMPANI = wcia OR wcia IS NULL)
     AND (l.CESTLIN IS NULL OR l.CESTLIN=1);

num_err  NUMBER:= 0;
lfmovini DATE;
lctiprec NUMBER;
lcgescob NUMBER;
litotalr NUMBER;
licomcia NUMBER;
liprinet NUMBER;
lcestrec NUMBER;
lfmovdia DATE;
lsseguro NUMBER;

BEGIN
   -- Numero de proces

   num_err := f_procesini(F_USER,pcempres,'PRE_LIQUIDA','Pre-Liquidación por días ',psproces);

   IF num_err = 0 THEN
      commit;

      -- Obtenim tots el registres de les liquidacions obertes, ja filtrarem els moviments
      FOR v_liq IN c_liq (pcempres, pccompani ) LOOP
         BEGIN
            SELECT trunc(fmovini), cestrec, trunc(fmovdia)
              INTO lfmovini, lcestrec, lfmovdia
            FROM movrecibo
            WHERE smovrec = v_liq.smovrec;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 104043;
               RETURN num_err;
         END;
--dbms_output.put_line(v_liq.smovrec||'-'||lfmovini||'-'||lfmovdia);

	 --IF lfmovini <= pfecfin AND lfmovdia BETWEEN  pfecini AND pfecfin THEN
         IF lfmovini <= pfecfin THEN

            -- El moviment és del periode corresponent.
            -- Pot ser una anul. de cobrament de mesos anteriors, i se li està posant
            -- data de descobrament la de l'efecte de cobrament --> la modifiquem
            -- amb data fmovdia si és del més actual
            IF lfmovini <pfecini THEN
               IF lfmovdia BETWEEN  pfecini AND pfecfin THEN
                  lfmovini := lfmovdia;
               ELSE
                  lfmovini := pfecfin;
               END IF;
            END IF;
--dbms_output.put_line('NOU '||lfmovini);
            -- Busquem el tipus de rebut i qui gestiona el cobrament
            -- Si és extorn cal canviar el signe de l'import
            BEGIN
               SELECT ctiprec, cgescob, sseguro
                 INTO lctiprec, lcgescob, lsseguro
               FROM recibos
               WHERE nrecibo = v_liq.nrecibo;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 102367 ;
                  RETURN num_err;
            END;

            BEGIN
               SELECT decode(lcestrec,1,itotalr,-itotalr),
                      decode(lcestrec,1,icomcia,-icomcia),
                      decode(lcestrec,1,iprinet,-iprinet)
                 INTO litotalr, licomcia, liprinet
               FROM vdetrecibos
               WHERE nrecibo = v_liq.nrecibo;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 102367 ;
                  RETURN num_err;
            END;

            BEGIN
               INSERT INTO liquida_dia (sproces, nrecibo, cempres, ccompani,
                                        fmovini, sseguro,
                                        liq_cobro,
                                        liq_cobrocia,
                                        liq_cobro_com,
                                        liq_cobcia_com,
                                        liq_cobro_net,
                                        liq_cobrocia_net,
                                        ctiprec, cgescob)
                      VALUES (psproces,v_liq.nrecibo, pcempres, v_liq.ccompani,
                             lfmovini, lsseguro,
                             litotalr * decode(lcgescob,1,1,0)*decode(lctiprec,9,-1,1) ,
                             litotalr * decode(lcgescob,2,1,0)*decode(lctiprec,9,-1,1),
                             licomcia * decode(lcgescob,1,1,0)*decode(lctiprec,9,-1,1) ,
                             licomcia * decode(lcgescob,2,1,0)*decode(lctiprec,9,-1,1),
                             liprinet * decode(lcgescob,1,1,0)*decode(lctiprec,9,-1,1) ,
                             liprinet * decode(lcgescob,2,1,0)*decode(lctiprec,9,-1,1),
                             lctiprec, lcgescob
                                        );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE liquida_dia SET liq_cobro     = liq_cobro +
                                                         litotalr *
                                                         decode(lcgescob,1,1,0) *
                                                         decode(lctiprec,9,-1,1) ,
                                         liq_cobrocia = liq_cobrocia +
                                                         litotalr *
                                                         decode(lcgescob,2,1,0) *
                                                         decode(lctiprec,9,-1,1) ,
                                         liq_cobro_com   = liq_cobro_com +
                                                         licomcia *
                                                         decode(lcgescob,1,1,0) *
                                                         decode(lctiprec,9,-1,1) ,
                                         liq_cobcia_com = liq_cobcia_com +
                                                         licomcia *
                                                         decode(lcgescob,2,1,0) *
                                                         decode(lctiprec,9,-1,1),
                                         liq_cobro_net   = liq_cobro_net +
                                                         liprinet *
                                                         decode(lcgescob,1,1,0) *
                                                         decode(lctiprec,9,-1,1),
                                         liq_cobrocia_net = liq_cobrocia_net +
                                                         liprinet *
                                                         decode(lcgescob,2,1,0) *
                                                         decode(lctiprec,9,-1,1)
                  WHERE sproces = psproces
                    AND nrecibo = v_liq.nrecibo;

               WHEN OTHERS THEN
                  num_err := 103767;
                  RETURN num_err;
            END;
         END IF;
      END LOOP;
      -- Esborrem els que no tenen import
--      DELETE FROM liquida_dia
--      WHERE sproces = psproces
--        AND cempres = pcempres
--        AND liq_cobro = 0
--        AND liq_cobrocia = 0;
      COMMIT;
   END IF;
   num_err := f_procesfin(psproces,num_err);
RETURN num_err;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_LIQUIDA_DIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_LIQUIDA_DIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_LIQUIDA_DIA" TO "PROGRAMADORESCSI";
