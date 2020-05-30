--------------------------------------------------------
--  DDL for Function FF_ICAPITAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_ICAPITAL" (psseguro IN NUMBER)
RETURN NUMBER authid current_user IS
/****************************************************************************
	FF_ICAPITAL: LLama a la función f_icapital y devuelve el capital
                     de un seguro.
	ALLIBADM
****************************************************************************/
    capital     NUMBER;
    num_err     NUMBER;
    salir       EXCEPTION;
BEGIN
    num_err := f_icapital(psseguro,capital);
    IF num_err <> 0 THEN
        RAISE salir;
    END IF;
    RETURN(capital);
EXCEPTION
    WHEN salir THEN
        RETURN 105134;  -- Error en la función.
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_ICAPITAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_ICAPITAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_ICAPITAL" TO "PROGRAMADORESCSI";
