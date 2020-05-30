--------------------------------------------------------
--  DDL for Function F_ACT_FEFEADM_NULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ACT_FEFEADM_NULL" RETURN NUMBER authid current_user IS

  CURSOR cur_movrecibo IS
    SELECT * FROM movrecibo
    where fefeadm is null
    order by smovrec;

  vfefeadm DATE;
  error    NUMBER;

BEGIN

  FOR reg IN cur_movrecibo LOOP

    error := f_fefeadm ( reg.fmovdia,reg.cestrec,reg.cestant, reg.fmovini, reg.nrecibo, reg.smovrec, reg.ctipcob, vfefeadm );
    IF error <> 0 THEN
      RETURN error;
    END IF;

    UPDATE movrecibo SET fefeadm = vfefeadm, fcontab = vfefeadm WHERE smovrec = reg.smovrec;

  END LOOP;

  RETURN 0;

END f_act_fefeadm_null;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ACT_FEFEADM_NULL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ACT_FEFEADM_NULL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ACT_FEFEADM_NULL" TO "PROGRAMADORESCSI";
