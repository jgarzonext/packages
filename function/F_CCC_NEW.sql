--------------------------------------------------------
--  DDL for Function F_CCC_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CCC_NEW" (pncuenta IN NUMBER, pctipban in number,
                                        pncontrol IN OUT NUMBER,pnsalida IN OUT NUMBER
                                        )
RETURN NUMBER authid current_user IS
/**************************************************************************
    F_CCC        Valida una cuenta bancaria y devuelve como parámetros
            el número incluyendo los dígitos de control.
            Devuelve como valor el código del error. 0 si está bien.
    JFD - 28-09-2007 Se cambia la función para adaptarla a los diferentes
    formatos de cuentas.
        Se añade el parámetro  de entrada pctipban (tipo de cuenta, 
        tipos_cuenta). En función del valor de este parámetro se llama a una 
        función u otra:
                3 - Andorra => f_ccc_and
                2 - Iban => F_iban
                1 - España  => f_ccc_esp (es la antigua f_ccc).
**************************************************************************/
    verror    NUMBER;
BEGIN

   if pctipban = 1 or pctipban is null then
      verror := f_ccc_esp(to_number(pncuenta), pncontrol ,pnsalida);
      return verror;   
   elsif pctipban = 2 then
      verror    := f_valida_iban (pncuenta);
      pnsalida  := pncuenta;
      pncontrol := null;
      return verror;
   elsif pctipban = 3  then
      verror := f_ccc_and (pncuenta, pnsalida);
      pncontrol := null;
      return verror;  
   end if;

exception
   when others then
      return 102494; -- Error grave
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CCC_NEW" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CCC_NEW" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CCC_NEW" TO "PROGRAMADORESCSI";
