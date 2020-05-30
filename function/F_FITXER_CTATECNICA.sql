--------------------------------------------------------
--  DDL for Function F_FITXER_CTATECNICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FITXER_CTATECNICA" (pempres IN NUMBER,pidioma IN NUMBER,pmes IN NUMBER,
                                                pany IN NUMBER,pcompani IN NUMBER, pconagr IN NUMBER,ptram IN NUMBER)
RETURN NUMBER AUTHID current_user IS
/***********************************************************************
	F_fitxer_ctatecnica    : Crea el fitxer del compte tècnic.
************************************************************************/
   v_tempres      VARCHAR2(40);
   v_cia          VARCHAR2(40);
   v_tram         VARCHAR2(30);
   v_movim        VARCHAR2(30);
   v_contra       VARCHAR2(30);
   v_tipo         NUMBER;
   v_data         DATE;

   linia          VARCHAR2(1000);
   fitxer         UTL_FILE.file_type;
   lpath          VARCHAR2(200);
   ltfitxer       VARCHAR2(20);
   pmensa         VARCHAR2(100);


   CURSOR c_cta IS
     SELECT ccompani,tipo,cconcep,ccorred, sconagr, scontra, nversio, ctramo,
        	DECODE(SIGN(SUM(iimport)),-1,-SUM(iimport),0) saldo10,
			DECODE(SIGN(SUM(iimport)),-1,0,SUM(iimport)) saldo54
	 FROM MOVCTATECNICAAUX
	 WHERE (ccompani = pcompani OR pcompani IS NULL)
	  AND (ctramo = ptram OR ptram IS NULL)
	  GROUP BY ccompani,tipo,cconcep,ccorred, sconagr, scontra, nversio, ctramo;
BEGIN
   lpath := F_Parinstalacion_T('PATH_ALTRE');
   IF lpath IS NULL THEN
      DBMS_OUTPUT.put_line( 112443);
   END IF;
   v_data := LAST_DAY(TO_DATE('01/'||LPAD(pmes,2,'0')||'/'||pany,'dd/mm/yyyy'));
 BEGIN
   ltfitxer := 'CTATECNICA.txt';
   fitxer := utl_file.fopen (lpath, ltfitxer, 'w');
   linia :=  'Cia Asseguradora;Contracte;Tram; '||
             'Cia Reasseguradora;Tipus compte;Concepte;Debe;Haber;';
   utl_file.Put_Line(fitxer, linia);
   FOR a IN c_cta
      LOOP
          EXIT WHEN c_cta%NOTFOUND;
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
         IF pconagr IS NOT NULL THEN
            BEGIN
             SELECT tconagr
             INTO   v_contra
             FROM   DESCONTRATOSAGR
             WHERE  sconagr = pconagr AND
                    cidioma = pidioma;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 v_contra := '????';
                 WHEN OTHERS THEN
                   v_contra := '????';
            END;
         END IF;
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
         -- descripció del tram (si es 0 a pinyó posem 'PROPI', sino busquem a valors fixes)
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
	         NULL;
			 RETURN 4;
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
	         WHERE cvalor = 913 AND
	              catribu = a.tipo AND
	              cidioma = pidioma;
    	  EXCEPTION
	      WHEN OTHERS THEN
	         NULL;
	      END;
          -- Descripció del concepte
          BEGIN
	      SELECT tatribu
	      INTO v_movim
	      FROM DETVALORES
	      WHERE cvalor = 124 AND
	           catribu = a.cconcep AND
	           cidioma = pidioma;
	  EXCEPTION
	      WHEN OTHERS THEN
	         NULL;
			 RETURN 6;
	  END;
          linia :=  v_tempres||';'||v_contra||';'||
                    v_tram||';'||v_cia||';'||v_tipo||';'||v_movim||';'||
                    a.saldo10||';'||a.saldo54;
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

  GRANT EXECUTE ON "AXIS"."F_FITXER_CTATECNICA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FITXER_CTATECNICA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FITXER_CTATECNICA" TO "PROGRAMADORESCSI";
