--------------------------------------------------------
--  DDL for Function F_IMP_CTIPAPOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMP_CTIPAPOR" (psseguro IN NUMBER,panyo IN NUMBER,
                   pmodo IN NUMBER, pcmovimi IN NUMBER DEFAULT 3 )
RETURN NUMBER AUTHID current_user IS
-- PMODO : 1 - Aportaciones Promotor
--         2 - Aportaciones Participe Obligatorias
--         3 - Aportaciones Participe Voluntarias

-- PCMOVIMI  1 - Aportacion Extraordinaria
--           2 - Aportacion Periodica
--           3 - Ambas
   vimporte    number := 0;
BEGIN
   IF pmodo = 1 THEN
      select nvl(sum(imovimi),0)
	  into vimporte
	  from ctaseguro
	  where sseguro = psseguro
        and TO_DATE (TO_CHAR (panyo,'9999'),'YYYY') = TO_DATE (TO_CHAR (fvalmov,'yyyy'),'YYYY')
	    and spermin is not null
		and nvl(ctipapor,'O') <> 'SP'
		and ( cmovimi = pcmovimi or pcmovimi = 3 );
	ELSIF pmodo = 2 THEN
      select nvl(sum(imovimi),0)
	  into vimporte
	  from ctaseguro
	  where sseguro = psseguro
	    and TO_DATE (TO_CHAR (panyo,'9999'),'YYYY') = TO_DATE (TO_CHAR (fvalmov,'yyyy'),'YYYY')
	    and spermin is null
		and ctipapor = 'O'
		and ( cmovimi = pcmovimi or pcmovimi = 3 );
	ELSIF pmodo = 3 THEN
      select nvl(sum(imovimi),0)
	  into vimporte
	  from ctaseguro
	  where sseguro = psseguro
	    and TO_DATE (TO_CHAR (panyo,'9999'),'YYYY') = TO_DATE (TO_CHAR (fvalmov,'yyyy'),'YYYY')
	    and spermin is null
		and nvl(ctipapor,'V') <> 'O'
		and ( cmovimi = pcmovimi or pcmovimi = 3 );
	END IF;
   RETURN vimporte;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IMP_CTIPAPOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMP_CTIPAPOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMP_CTIPAPOR" TO "PROGRAMADORESCSI";
