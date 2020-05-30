--------------------------------------------------------
--  DDL for Function F_IMPSEGUROREDCOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMPSEGUROREDCOM" 
(pnseguro IN NUMBER)
RETURN NUMBER authid current_user IS
   l_c NUMBER;
   L_ERR NUMBER;
   l_error NUMBER;
   empres  number(2);
   CURSOR c_rec IS
      SELECT sSEGURO,cagente,femisio,CRAMO
      FROM seguros
      WHERE SSEGURO=pnseguro;
BEGIN
   FOR vrec in c_rec LOOP
   SELECT DECODE(VREC.CRAMO,1,2,
                            2,2,
                            3,2,
                            4,2,
                            5,2,
                            6,2,
                            7,2,
                            8,2,
                            9,2,
                           10,2,
                           11,2,
                           12,2,
                           14,2,
                           15,2,
                           16,2,
                           30,2,
                           31,2,
                           33,1,
                           40,1,
                           41,1,
                           42,1,
                           43,1,
                           32,1,
                           34,2,
                           50,3,
                           51,3,
                           99,4) INTO EMPRES FROM DUAL;
     SELECT COUNT(*) INTO l_c
     FROM SEGUROSredcom
     WHERE sseguro = vrec.sseguro;
      IF l_c = 0 THEN
         l_error := f_insseguror(vrec.sseguro, empres, vrec.cagente,
                               sysdate);
         IF l_error <> 0 THEN
            dbms_output.put_line(l_error || '-' || to_char(vrec.sseguro));
         END IF;
      ELSE
	DELETE segurosredcom
	WHERE sseguro = vrec.sseguro;
        l_error := f_insseguror(vrec.sseguro, empres, vrec.cagente,
                               sysdate);
        IF l_error <> 0 THEN
            dbms_output.put_line(l_error || '-' || to_char(vrec.SSEGURO));
        END IF;
      END IF;
      commit;
   END LOOP;
COMMIT;
RETURN 0;
EXCEPTION
   WHEN value_error THEN
        dbms_output.put_line('ERROR');
        rollback;
        RETURN 1;
   WHEN others THEN
        dbms_output.put_line('ERROR');
        rollback;
        RETURN 1;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_IMPSEGUROREDCOM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMPSEGUROREDCOM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMPSEGUROREDCOM" TO "PROGRAMADORESCSI";
