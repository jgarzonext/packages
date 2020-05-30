--------------------------------------------------------
--  DDL for Function F_FITXER_PB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FITXER_PB" (pempres IN NUMBER,pidioma IN NUMBER,
                                                pmes NUMBER, pany NUMBER)
RETURN NUMBER AUTHID current_user IS
/***********************************************************************
	F_fitxer_PB    : Crea el fitxer de la participació en beneficis
	                  per companyia, contracte i concepte.
************************************************************************/
   v_tempres      VARCHAR2(40);
   v_cia          VARCHAR2(40);
   v_movim        VARCHAR2(60);
   v_contra       VARCHAR2(60);
   linia          VARCHAR2(1000);
   fitxer         UTL_FILE.file_type;
   lpath          VARCHAR2(200);
   ltfitxer       VARCHAR2(20);
   pmensa         VARCHAR2(100);
   v_tipo         VARCHAR2(30);
   v_data         DATE;
   CURSOR c_pb IS
     SELECT ccompani, scontra, cconceppb, tipo, iimport, cempres
     FROM CTAPBAUX
     WHERE fcierre = LAST_DAY(TO_DATE('01/'||LPAD(pmes,2,'0')||'/'||pany,'dd/mm/yyyy'))
       AND cconceppb <> 62
     GROUP BY ccompani, scontra, cconceppb, tipo, iimport, cempres;
BEGIN
   lpath := F_Parinstalacion_T('PATH_ALTRE');
   IF lpath IS NULL THEN
      DBMS_OUTPUT.put_line( 112443);
   END IF;
   v_data := LAST_DAY(TO_DATE('01/'||LPAD(pmes,2,'0')||'/'||pany,'dd/mm/yyyy'));
BEGIN
   ltfitxer := 'CTAPB.TXT';
   fitxer := utl_file.fopen (lpath, ltfitxer, 'w');
   linia :=  'Cia Asseguradora;Contracte; '||
             'Cia Reasseguradora;Tipus compte;Concepte;Import;';
   utl_file.Put_Line(fitxer, linia);
   FOR a IN c_pb
      LOOP
          EXIT WHEN c_pb%NOTFOUND;
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
          --descripció del contracte
         IF a.scontra IS NOT NULL THEN
            BEGIN
              SELECT tcontra
              INTO   v_contra
              FROM   CONTRATOS
              WHERE  scontra = a.scontra AND
                     nversio = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_contra := '??';
                  WHEN OTHERS THEN
                    v_contra := '??';
            END;
         END IF;
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
          -- Descripció del tipus de compte
          BEGIN
	         SELECT tatribu
	         INTO v_tipo
	         FROM DETVALORES
             WHERE cvalor = 915 AND
	              catribu = a.tipo AND
	              cidioma = pidioma;
    	  EXCEPTION
     	      WHEN OTHERS THEN
	            NULL;
				DBMS_OUTPUT.put_line( SQLERRM);
		        RETURN 6;
     	  END;
          -- Descripció del concepte
          BEGIN
	      SELECT tatribu
	      INTO v_movim
	      FROM DETVALORES
	      WHERE cvalor = 920 AND
	           catribu = a.cconceppb AND
	           cidioma = pidioma;
	  EXCEPTION
	      WHEN OTHERS THEN
	         NULL;
			 RETURN 7;
	  END;
          linia :=  v_tempres||';'||v_contra||';'||
                    v_cia||';'||v_tipo||';'||v_movim||';'||
                    a.iimport;
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

  GRANT EXECUTE ON "AXIS"."F_FITXER_PB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FITXER_PB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FITXER_PB" TO "PROGRAMADORESCSI";
