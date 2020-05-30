--------------------------------------------------------
--  DDL for Package Body PAC_TRANS_DIFERITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_TRANS_DIFERITS" IS

  FUNCTION f_valida (psseguro IN NUMBER,data IN DATE) RETURN NUMBER IS
      lvalida  NUMBER;
      lfcarpro DATE;
      BEGIN
         lvalida := 1;
         -- Obtenim dades de la pòlissa
         SELECT fcarpro into lfcarpro
         FROM seguros
         WHERE sseguro = psseguro;
         -- No podem traspassar el suplement si no s'ha fet la cartera
         IF lfcarpro < data THEN
            lvalida := 0;
         END IF;
      RETURN lvalida;
   END f_valida;

  PROCEDURE p_traspaso_diferits (pdata IN DATE, pcramo NUMBER  DEFAULT NULL,
                                  pcmodali NUMBER  DEFAULT NULL, pctipseg NUMBER  DEFAULT NULL,
                                  pccolect NUMBER DEFAULT NULL) IS
 /******************************************************************************
   Sergi : Procediment per traspassar els suplements diferits a suplements reals
 *****************************************************************************/
   --cursor amb tots aquell suplements diferits (informació necessària per
   --generar el moviment de la polissa)
   --pdata: data en que s'ha de generar el suplement
   ----------------------------------------------------------------
   pcesion     NUMBER;
   num_err     NUMBER;
   v_nsuplem   NUMBER;--variable per controlar el número de suplements
   v_nmovimi   NUMBER;--variable del moviments de la polissa
   v_sproces   NUMBER;--variable per el numero de procés
   v_numlin    NUMBER;
   prim_total  NUMBER;
   v_Mens      VARCHAR2(100):= null;
   l_csituac   NUMBER;
   l_femisio   DATE;
   ------------------------------------------
      CURSOR cur_mov (pdata DATE, pcramo NUMBER, pcmodali NUMBER, pctipseg NUMBER,
                      pccolect NUMBER) IS
      SELECT d.sseguro,d.ssegpol,d.cmotmov,d.fsuplement,d.fcarpro,
             d.nsuplem,d.ndomiciliar,d.npoliza,d.nmoneda,d.fcaranu,d.fefecto
      FROM difseguros d
      WHERE d.fsuplement <= pdata
        AND ( (cramo = pcramo     AND
               cmodali = pcmodali AND
               ctipseg = pctipseg AND
               ccolect = pccolect )
             OR
               (pcramo IS NULL)
             )
        AND f_valida(d.ssegpol,d.fsuplement ) = 1;

   ------------------------------------------
   BEGIN
      --Creem una línea a la taula de processos.
      num_err:=F_PROCESINI (F_USER, 1 ,1001 , 'SUPLEMENTS DIFERITS',
                              v_sproces );
      COMMIT;
        -- Obrim el cursor amb els suplements a tractar
	-- dbms_output.put_line('procesini '||num_err);
      FOR c in cur_mov( pdata,pcramo, pcmodali, pctipseg, pccolect  ) LOOP

         --Guardem el moviment.
         IF c.cmotmov <> 216 THEN
            v_nsuplem := c.nsuplem + 1;
         ELSE
            v_nsuplem := c.nsuplem;
         END IF;
         -- El suplement quedarà emès, si la data és la de cartera
         -- sino, el deixarem en proposta de suplement
         IF c.fsuplement = c.fcaranu OR c.fsuplement = c.fcarpro THEN
            l_csituac:= 0;
            l_femisio := f_sysdate;
         ELSE
            l_csituac := 5;
            l_femisio := null;
         END IF;
         --Generem el moviment a movseguro.
         num_err:=f_movseguro(c.ssegpol,null,c.cmotmov,1,c.fsuplement,null,v_nsuplem,
                              0,null,v_nmovimi,l_femisio,c.ndomiciliar);
		--
		-- dbms_output.put_line('movseguro '||num_err);
		--
         IF num_err <> 0 then
            num_err:=F_proceslin(v_sproces,'E. generar movseguro ' ||c.npoliza,
				101992,v_numlin);
			--
            -- dbms_output.put_line('E. generar movseguro '||num_err);
			--
         ELSE
            --Guardem el registre a  historicoseguros
            num_err:=f_act_hisseg(c.ssegpol,v_nmovimi-1);
			--
			-- dbms_output.put_line('f_act_his '||num_err);
			--
            IF num_err <> 0 THEN
               v_numlin:=v_numlin+1;
               num_err:=F_proceslin(v_sproces,'E. gravar a historicoseguro '||c.npoliza,
			   							109383,v_numlin);
            ELSE
               --traspassem el suplement a les taules reals de seguros...
--               pac_alctr126.traspaso_tablas_diferides(c.sseguro,c.ssegpol,v_Mens);
			   --
			   -- dbms_output.put_line(' traspaso tablas dif '||v_mens);
			   --
               --Assignem una targeta aquells riscos que tenen el camp ntarget informat.
--               num_err:=pac_alctr126.INSERTAR_TARJETAS(c.sseguro,c.ssegpol,v_sproces);
               IF num_err <> 0 THEN
                  num_err:=F_proceslin(v_sproces,'E. traspaso tarjetas ',110433,v_numlin);
               ELSE
                  --guardem els valors per els rescats
                  num_err := pac_capital_garantit.f_traspaso_respar(c.ssegpol, v_nmovimi,
                                             c.fcaranu, c.fsuplement,c.fefecto, c.nmoneda);
                  IF num_err <> 0 THEN
                     v_numlin:=v_numlin+1;
                     num_err:=F_proceslin(v_sproces,'E. gravar a rescats',107405,v_numlin);
                  ELSE
                     --Control de les coassegurances per calcular ipritot i icaptot
                     BEGIN
                        SELECT d.ploccoa
                        INTO   pcesion
                        FROM   COACUADRO d, SEGUROS s
                        WHERE  d.ncuacoa = s.ncuacoa
                          AND d.sseguro = s.sseguro
                          AND s.sseguro = c.ssegpol;
                     EXCEPTION
                        WHEN others THEN
                          pcesion := 100;
                     END;
                     num_err := f_garancoa ('R',pcesion, c.ssegpol, v_nmovimi);
                     IF num_err <> 0 THEN
                        v_numlin:=v_numlin+1;
                        num_err:=F_proceslin(v_sproces,'E. gravar a rescats',101959,v_numlin);
                     ELSE
                        prim_total := f_segprima(c.ssegpol, c.fsuplement);
                        -- Sólo modificamos la el iprianu del seguro
                        UPDATE SEGUROS SET iprianu = prim_total,
                                           nsuplem = v_nsuplem,
                                           csituac = l_csituac
                        WHERE sseguro = c.ssegpol;
                        num_err := f_dupgaran(c.sseguro, c.fsuplement, v_nmovimi);
                        IF num_err <> 0 THEN
                           v_numlin:=v_numlin+1;
                           num_err:=F_proceslin(v_sproces,'E. duplica garan',101959,v_numlin);
                        ELSE
--                           pac_alctr126.BORRAR_TABLAS_DIF(c.ssegpol);
						   --
                           null;
						   --
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;
--COMENTAT TEMPORALMENT (FASE PROVES)
	  commit;


   EXCEPTION
      WHEN OTHERS THEN
	  rollback;
--         DBMS_OUTPUT.PUT_LINE('ERROR '||SQLERRM);
END p_traspaso_diferits;


END pac_trans_diferits;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRANS_DIFERITS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRANS_DIFERITS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRANS_DIFERITS" TO "PROGRAMADORESCSI";
