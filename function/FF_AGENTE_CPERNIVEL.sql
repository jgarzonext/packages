--------------------------------------------------------
--  DDL for Function FF_AGENTE_CPERNIVEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_AGENTE_CPERNIVEL" (
/******************************************************************************
   NOMBRE:       ff_agente_cpernivel
   PROPÓSITO: Funciones para gestionar nivel

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   3.0        16/05/2009   ICV                0010422: IAX - PERSONAS - Se añade la empresa como parametro por defecto la del contexto.
******************************************************************************/
   pcagente IN agentes.cagente%TYPE,
   pfecha IN DATE DEFAULT f_sysdate,
   pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa)
   RETURN NUMBER AUTHID CURRENT_USER IS
   xcpernivel     redcomercial.cpernivel%TYPE;
BEGIN
   SELECT cpernivel
     INTO xcpernivel
     FROM redcomercial a
    WHERE a.cagente = pcagente
      AND a.fmovini <= pfecha
      AND a.cempres =
            pcempres   --Bug.: 0010422 - 25/06/2009 - ICV - Se añade la empresa como parametro por defecto la del contexto.
      AND(a.fmovfin >= pfecha
          OR a.fmovfin IS NULL);

--p_tab_error (f_sysdate, f_user, 'FF_Agente_cpernivel   svj', 1, 'El nivel de visión es = '||xcpernivel , NULl); -->QUITAR
   RETURN xcpernivel;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_Agente_CPERNIVEL', 1,
                  '-- pcagente =' || pcagente || ' --  Pfecha ' || pfecha, SQLERRM);
      RETURN NULL;   -- error al leer el campo cpervisio de la redcomercial
END ff_agente_cpernivel;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPERNIVEL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPERNIVEL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPERNIVEL" TO "PROGRAMADORESCSI";
