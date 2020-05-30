--------------------------------------------------------
--  DDL for Function FIPROV_T1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FIPROV_T1" (sesion in number, psseguro in number, pnriesgo in number,
                                   pcgarant in number, pnanyo in NUMBER)
return number authid current_user is

  v_iprovt1     number;

begin
   select iprovt1
   into  v_iprovt1
   from garansegprovmat p
   where p.sseguro = psseguro
   and p.nriesgo = pnriesgo
   and p.cgarant = pcgarant
   and p.nanyo = pnanyo
   and p.nmovimi = (select max(gg.nmovimi)
                  from garansegprovmat gg
				  where gg.sseguro = psseguro
				  and gg.nriesgo = pnriesgo
				  and gg.cgarant = pcgarant
				  and gg.nanyo = pnanyo);
   return v_iprovt1;
exception
   when others then
   --   p_tab_error(f_sysdate, F_USER, 'FPROV_T1', 1,
     --         'SSEGURO ='||PSSEGURO||' NRIESGO ='||pnriesgo||' PCGARANT ='||pcgarant||
		--	  ' PFECHA='||PFECHA,sqlerrm);
         return null; -- error al leer de garanseg
end;
 
 

/

  GRANT EXECUTE ON "AXIS"."FIPROV_T1" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FIPROV_T1" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FIPROV_T1" TO "PROGRAMADORESCSI";
