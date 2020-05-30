--------------------------------------------------------
--  DDL for Package PAC_VINCULADOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VINCULADOS" AUTHID CURRENT_USER
IS

FUNCTION f_cap_prestcuadroseg (
   p_in_sseguro   IN   prestcuadroseg.sseguro%TYPE,
   p_in_fecha     IN   prestcuadroseg.fefecto%TYPE,
   p_in_nmovimi	  in   prestcuadroseg.nmovimi%TYPE default null
)
   RETURN prestcuadroseg.icappend%TYPE
;

FUNCTION f_insertar_cuadro (ptablas in varchar2,psproces in number, psseguro  IN NUMBER,
							   pfecha in date)
    RETURN number;

end pac_vinculados;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_VINCULADOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VINCULADOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VINCULADOS" TO "PROGRAMADORESCSI";
