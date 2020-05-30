--------------------------------------------------------
--  DDL for Function F_ES_VINCULADA_SNV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ES_VINCULADA_SNV" ( psseguro IN NUMBER, pnriesgo IN NUMBER DEFAULT 1,
          pfecha in date default null) RETURN NUMBER IS
/******************************************************************************
Función que nos indica si una póliza está vinculada a un préstamo para la instalación de SNV
 1.- indica que si,
 0.- indica que no

 -- Sabemos si una póliza está vinculada a un préstamo porque tiene un 1 en la pregunta cpregun = 5

******************************************************************************/
 V_NMOVIMI		NUMBER;
 v_crespue		number;

BEGIN
   if pfecha is null then  -- queremos saber la situación a día de hoy
      select max(nmovimi)
	  into v_nmovimi
	  from pregunseg
	  where sseguro = psseguro;
   else
      select max(nmovimi)
	  into v_nmovimi
	  from garanseg
	  where sseguro = psseguro
	    and nriesgo = pnriesgo
		and finiefe <= pfecha
		and (ffinefe > pfecha or ffinefe is null);
   end if;

   begin
      select crespue
	  into  v_crespue
	  from pregunseg e, seguros s
	  where e.sseguro = psseguro
		 and s.sseguro = e.sseguro
		 and e.nriesgo = pnriesgo
		 and e.nmovimi = v_nmovimi
		 and cpregun = 5;
   exception
	   when others then
		    return 0;
   end;

   return v_crespue;

exception
   when others then
      p_tab_error (f_sysdate, F_USER, 'f_es_vinculada_snv', 1,'when others SSEGURO ='
                      || psseguro
					  || 'NRIESGO ='
					  || PNRIESGO
                      || ' PFECHA='
                      || pfecha,
                      SQLERRM
                     );
         RETURN 108953;
              -- error de ejecución
END f_es_vinculada_snv;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ES_VINCULADA_SNV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ES_VINCULADA_SNV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ES_VINCULADA_SNV" TO "PROGRAMADORESCSI";
