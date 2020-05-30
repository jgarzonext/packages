--------------------------------------------------------
--  DDL for Function FF_PRIMAS_PAGADAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_PRIMAS_PAGADAS" (
   pnsesion IN NUMBER,
   psseguro IN NUMBER,
   pfdesde IN DATE,
   pfhasta IN DATE)
   RETURN NUMBER IS
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   v_pprimas      NUMBER := 0;
   v_num_err      NUMBER := 0;
BEGIN
   v_num_err := f_primas_pagadas(psseguro, pfdesde, pfhasta, v_pprimas);
   RETURN v_pprimas;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'FF_PRIMAS_PAGADAS', 1,
                  'psseguro = ' || psseguro || '  pfdesde = ' || pfdesde || '  pfhasta = '
                  || pfhasta,
                  SQLERRM);
      RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."FF_PRIMAS_PAGADAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_PRIMAS_PAGADAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_PRIMAS_PAGADAS" TO "PROGRAMADORESCSI";
