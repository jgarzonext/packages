--------------------------------------------------------
--  DDL for Function FF_AGENTE_CPOLVISIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_AGENTE_CPOLVISIO" (
/******************************************************************************
   NOMBRE:       ff_agente_cpolvisio
   PROPÓSITO:    Funciones para gestionar vision

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/07/2012   MDS               0022791: IAX - Error de visibilidad por agente en listados de PRODUCCION
******************************************************************************/
   pcagente IN agentes.cagente%TYPE,
   pfecha IN DATE DEFAULT f_sysdate,
   pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa)
   RETURN NUMBER AUTHID CURRENT_USER IS
   xcpolvisio     redcomercial.cpolvisio%TYPE;
   vfecha         DATE;
BEGIN
   vfecha := pfecha;

   IF vfecha IS NULL THEN
      vfecha := f_sysdate;
   END IF;

   SELECT cpolvisio
     INTO xcpolvisio
     FROM redcomercial a
    WHERE a.cagente = pcagente
      AND a.fmovini <= vfecha
      AND a.cempres = pcempres
      AND(a.fmovfin >= vfecha
          OR a.fmovfin IS NULL);

   RETURN xcpolvisio;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'FF_AGENTE_CPOLVISIO ', 1,
                  '-- pcagente =' || pcagente || ' --  pfecha ' || pfecha, SQLERRM);
      RETURN NULL;
END ff_agente_cpolvisio;

/

  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPOLVISIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPOLVISIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_AGENTE_CPOLVISIO" TO "PROGRAMADORESCSI";
