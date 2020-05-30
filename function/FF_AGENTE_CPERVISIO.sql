--------------------------------------------------------
--  DDL for Function FF_AGENTE_CPERVISIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_AGENTE_CPERVISIO" (
/******************************************************************************
   NOMBRE:       ff_agente_cpervisio
   PROPÓSITO: Funciones para gestionar vision

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   4.0        16/05/2009   ICV                0010422: IAX - PERSONAS - Se añade la empresa como parametro por defecto la del contexto.
   5.0        24/07/2009   DCT                0010612: Modificar la funcion ff_agente_cpervisio,
                                                       para que si el parametro pfecha NO llega informado, coja el f_sysdate.
******************************************************************************/
   pcagente IN agentes.cagente%TYPE,
   pfecha IN DATE DEFAULT f_sysdate,
   pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa)
   RETURN NUMBER AUTHID CURRENT_USER IS
   xcpervisio     redcomercial.cpervisio%TYPE;
   vfecha         DATE;
BEGIN
   vfecha := pfecha;

   IF vfecha IS NULL THEN
      vfecha := f_sysdate;
   END IF;

   SELECT cpervisio
     INTO xcpervisio
     FROM redcomercial a
    WHERE a.cagente = pcagente
      AND a.fmovini <= vfecha
      AND a.cempres =
            pcempres   --Bug.: 0010422 - 25/06/2009 - ICV - Se añade la empresa como parametro por defecto la del contexto.
      AND(a.fmovfin >= vfecha
          OR a.fmovfin IS NULL);

--p_tab_error (f_sysdate, f_user, 'ff_agente_cpervisio   svj', 1, 'El agente de visión es = '||xcpervisio , NULl); -->QUITAR
   RETURN xcpervisio;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_AGENTE_CPERVISIO ', 1,
                  '-- pcagente =' || pcagente || ' --  Pfecha ' || pfecha, SQLERRM);
      RETURN NULL;   -- error al leer el campo cpervisio de la redcomercial
END ff_agente_cpervisio;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPERVISIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPERVISIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPERVISIO" TO "PROGRAMADORESCSI";
