--------------------------------------------------------
--  DDL for Function F_FITXER_PAGSINREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FITXER_PAGSINREA" (psproces IN NUMBER,pidioma IN NUMBER,
                                                pempres NUMBER, pinici DATE, pfin DATE)
RETURN NUMBER AUTHID current_user IS
/***********************************************************************
	F_fitxer_Pagsinrea : Crea el fitxer de la liquidació de pagaments de sinistres
	                     per companyia, contracte i concepte.
************************************************************************/
   v_tempres      VARCHAR2(40);
   v_cia          VARCHAR2(40);
   v_tram         VARCHAR2(40);
   v_producte     VARCHAR2(60);
   v_tgarant      VARCHAR2(60);
   v_pol_ini      VARCHAR2(20);
   linia          VARCHAR2(1000);
   fitxer         UTL_FILE.file_type;
   lpath          VARCHAR2(200);
   ltfitxer       VARCHAR2(20);
   pmensa         VARCHAR2(100);
   v_tipo         VARCHAR2(30);
   v_data         VARCHAR2(10);
   CURSOR c_pago IS
     SELECT *
     FROM LIQPAGREAAUX
     WHERE sproces = psproces
       AND (ctramo = ptramo
        OR ptramo IS NULL);
BEGIN
   lpath := F_Parinstalacion_T('PATH_ALTRE');
   IF lpath IS NULL THEN
      DBMS_OUTPUT.put_line( 112443);
   END IF;
--   v_data := LAST_DAY(TO_DATE('01/'||LPAD(pmes,2,'0')||'/'||pany,'dd/mm/yyyy'));
BEGIN
   v_data := pinici||' - '||pfin;
   ltfitxer := 'PAGSINREA.TXT';
   fitxer := utl_file.fopen (lpath, ltfitxer, 'w');
   linia :=  'Cia Asseguradora;Data liquidació;Producte;Tram;Cia Reasseguradora; '||
             'Any contractacio;Sinistre;Pòlissa;D.Efecte;D.Venciment;D.Ocurrencia; '||
			 'D.Pagament;Situació risc;Garantia;Import;%Propi;Imp.Propi;%Tram;Imp.Tram; '||
			 '%Cia;Imp.Cia;';
   utl_file.Put_Line(fitxer, linia);
   FOR a IN c_pago
      LOOP
          EXIT WHEN c_pago%NOTFOUND;
          --busquem les descripcions i altres camps necessaris.
          -- empresa asseguradora
          BEGIN
            SELECT tempres
            INTO v_tempres
            FROM EMPRESAS
            WHERE cempres = pempres ;
          EXCEPTION
            WHEN OTHERS THEN
               NULL;
	       RETURN 3;
          END;
          -- Cia reasseguradora
          BEGIN
            SELECT tcompani
            INTO v_cia
            FROM COMPANIAS
            WHERE ccompani = a.ccompani;
          EXCEPTION
            WHEN OTHERS THEN
               NULL;
			   RETURN 5;
          END;
	      -- Descripció de la garantia
          BEGIN
            SELECT tgarant
            INTO v_tgarant
            FROM GARANGEN
            WHERE cgarant = a.cgarant AND
                  cidioma = pidioma;
          EXCEPTION
            WHEN OTHERS THEN
               RETURN 6;
	      END;
          -- descripció del producte
           BEGIN
            SELECT t.ttitulo
            INTO v_producte
            FROM TITULOPRO t, SEGUROS s
            WHERE s.sseguro = a.sseguro AND
                  t.cramo = s.cramo AND
                  t.cmodali = s.cmodali AND
                  t.ccolect = s.ccolect AND
                  t.ctipseg = s.ctipseg AND
                  t.cidioma = pidioma;
          EXCEPTION
            WHEN OTHERS THEN
               RETURN 2;
          END;
          -- descripció del tram (si es 0 a pinyó posem 'PROPI',
		  -- sino busquem a valors fixes)
          IF a.ctramo = 0 THEN
             v_tram := 'propi';
          ELSE
	    BEGIN
	      SELECT tatribu
	      INTO v_tram
	      FROM DETVALORES
	      WHERE cvalor = 105 AND
	           catribu = a.ctramo AND
	           cidioma = pidioma;
	    EXCEPTION
	      WHEN OTHERS THEN
--               NULL;
               RETURN 3;
	    END;
	  END IF;
          -- polissa ini, num.polissa i certificat, venciment pòlissa
          BEGIN
            SELECT c.polissa_ini
            INTO v_pol_ini
            FROM CNVPOLIZAS c, SEGUROS s
            WHERE s.sseguro = c.sseguro AND
                 s.sseguro = a.sseguro;
          EXCEPTION
            WHEN OTHERS THEN
--               NULL;
               RETURN 5;
          END;

          linia :=  v_tempres||';'||v_data||';'||v_producte||';'||
                    v_tram||';'||v_cia||';'||a.nanyo||';'||a.nsinies||';'||
                    v_pol_ini||';'||a.fefecto||';'||a.fvencim||';'||a.fnotifi||';'||
					a.fefepag||';'||a.tsitrie||';'||v_tgarant||';'||a.itotal||';'||
					a.ppropio||';'||a.ipropio||';'||a.ptramo||';'||a.itramo||';'||
					a.pcompan||';'||a.icompan;

          utl_file.Put_Line(fitxer, linia);
     END LOOP;
     UTL_FILE.fclose(fitxer);
 EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(' Error global '||SQLERRM);
      pmensa := ' Error global '||SQLERRM;
      DBMS_OUTPUT.put_line( 999);
	  UTL_FILE.fclose(fitxer);
	  RETURN 1;
 END;
 RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_FITXER_PAGSINREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FITXER_PAGSINREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FITXER_PAGSINREA" TO "PROGRAMADORESCSI";
