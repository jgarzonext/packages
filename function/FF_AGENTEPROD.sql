--------------------------------------------------------
--  DDL for Function FF_AGENTEPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_AGENTEPROD" 
--BUG 12264 07-12-2009 JMC : Eliminar codi superflu
RETURN NUMBER
-- FIN BUG 12264 07-12-2009 JMC
AUTHID CURRENT_USER IS
/***********************************************************************
    MCA 01/2007  Recuperación del usuario guardado
                 en la variable de contexto Usuario
   REVISIONS:
   Ver        Data         Autor             Descripció
   ---------  ----------  ---------------  ----------------------------------
   1.0        02/06/2009   MSR               Optimització
   2.0        07-12-2009   JMC               Se cambia el RETURN de VARCHAR2
                                             a NUMBER
***********************************************************************/
BEGIN
   --BUG9903 02/06/2009 MSR : Eliminar codi superflu
   RETURN to_number(NVL(pac_contexto.f_contextovalorparametro('IAX_AGENTEPROD'),
              pac_contexto.f_contextovalorparametro('IAX_AGENTE')));
--FI BUG9903 02/06/2009 MSR : Eliminar codi superflu
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'FF_AgenteProd', 1,
                  'Error al buscar el atributo contextual Agente Producción', SQLERRM);
      RETURN NULL;
END ff_agenteprod;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_AGENTEPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_AGENTEPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_AGENTEPROD" TO "PROGRAMADORESCSI";
