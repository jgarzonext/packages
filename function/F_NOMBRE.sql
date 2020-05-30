--------------------------------------------------------
--  DDL for Function F_NOMBRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_NOMBRE" (
   psperson IN NUMBER,
   pnformat IN NUMBER,
   pcagente IN agentes.cagente%TYPE DEFAULT NULL)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/****************************************************************************
    F_NOMBRE: DEVUELVE EL NOMBRE DE UNA PERSONA FORMATEADO, SEGÚN EL
            FORMATO DESEADO.
            PNFORMAT = 1 => < APELLIDOS, NOMBRE >
            PNFORMAT = 2 => < NIF   APELLIDOS, NOMBRE >
            PNFORMAT = 3 => < NOMBRE APELLIDOS >
            PNFORMAT = 4 => < APELLIDOS NOMBRE SIN COMA>
    ALLIBMFM.
    MODIFICO EL FORMAT 2, PER FER-LO UNA MICA MÉS ESPAIAT.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   2.0        01/09/2010   JMF              1. 0015857: ENSA101 - Canvi ordre nom i cognoms en transferencies
   3.0        15/02/2019   WAJ             SE ADICIONA OPCION 4 PARA GENERAR APELLIDOS Y NOMBRE SIN COMA PARA ENVIAR A FUNCION CONVIVENCIA IAXIS - OSIRIS
****************************************************************************/
   vntraza        NUMBER := 0;
   pnombre        VARCHAR2(200);
   pnombre2       VARCHAR2(200);
   letra1         VARCHAR2(1);
   pnnumnif       per_personas.nnumide%TYPE;
   -- BUG 0015857 - 01/09/2010 - JMF
   v_tapelli1     per_detper.tapelli1%TYPE;
   v_tapelli2     per_detper.tapelli2%TYPE;
   v_tnombre      per_detper.tnombre%TYPE;
BEGIN
   BEGIN
      vntraza := 1;

      -- PERSONA PÚBLICA
      -- BUG 0015857 - 01/09/2010 - JMF
      SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)), LTRIM(RTRIM(pd.tnombre)),
             p.nnumide
        INTO v_tapelli1, v_tapelli2, v_tnombre,
             pnnumnif
        FROM per_personas p, per_detper pd
       WHERE p.sperson = pd.sperson
         AND p.sperson = psperson
         AND p.swpubli = 1   -- Persona Pública, nos da igual el agente.
         -- Bug 29166/160004 - 29/11/2013 - AMC
         /*AND pd.fmovimi = (SELECT MAX(d.fmovimi)
                             FROM per_detper d
                            WHERE d.sperson = pd.sperson)*/
         AND pd.cagente = p.cagente;

      vntraza := 2;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         vntraza := 3;

         IF pcagente IS NOT NULL THEN
            vntraza := 4;

            -- BUG 0015857 - 01/09/2010 - JMF
            SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)),
                   LTRIM(RTRIM(pd.tnombre)), p.nnumide
              INTO v_tapelli1, v_tapelli2,
                   v_tnombre, pnnumnif
              FROM per_detper pd, per_personas p
             WHERE pd.sperson = psperson
               AND pd.cagente = ff_agente_cpervisio(pcagente)
               AND pd.sperson = p.sperson;

            vntraza := 5;
         ELSE
            vntraza := 6;

            -- BUG 0015857 - 01/09/2010 - JMF
            SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)),
                   LTRIM(RTRIM(pd.tnombre)), nnumnif
              INTO v_tapelli1, v_tapelli2,
                   v_tnombre, pnnumnif
              FROM personas pd
             WHERE sperson = psperson;

            vntraza := 7;
         END IF;
   END;

   vntraza := 8;

   -- ini BUG 0015857 - 01/09/2010 - JMF
   IF pnformat = 3 THEN
      pnombre := v_tnombre || ' ' || v_tapelli1 || ' ' || v_tapelli2;
   ELSE
    --INI WAJ
      IF pnformat = 4 THEN
         pnombre := v_tapelli1 || ' ' || v_tapelli2 || ' ' || v_tnombre;
      ELSE
      --FIN WAJ
      -- Para pnformat 1 y 2.
         IF v_tnombre IS NULL THEN
             pnombre := v_tapelli1 || ' ' || v_tapelli2;
         ELSE
             pnombre := v_tapelli1 || ' ' || v_tapelli2 || ', ' || v_tnombre;
         END IF;
      --INI WAJ
      END IF;
      --FIN WAJ
   END IF;

   -- fin BUG 0015857 - 01/09/2010 - JMF
   --INI WAJ
   --IF pnformat IN(1, 3,) THEN
   IF pnformat IN(1, 3, 4) THEN
   --FIN WAJ
      vntraza := 9;
      RETURN pnombre;
   ELSIF pnformat = 2 THEN
      vntraza := 10;

      IF pnnumnif IS NOT NULL THEN
         vntraza := 11;

         --letra1 := SUBSTR (pnnumnif, 1, 1);
         IF SUBSTR(pnnumnif, 1, 2) = 'ZZ' THEN
            vntraza := 12;
            pnombre2 := SUBSTR('            ' || pnombre, 1, 80);
         ELSE
            vntraza := 13;
            pnombre2 := SUBSTR(pnnumnif || '   ' || pnombre, 1, 80);
         END IF;
      END IF;

      vntraza := 14;
      RETURN pnombre2;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN('**');
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_NOMBRE', vntraza,
                  'Parametros - psperson = ' || psperson || '  nformat = ' || pnformat
                  || ' pcagente = ' || pcagente,
                  SQLERRM);
      RETURN('**');
END;

/

  GRANT EXECUTE ON "AXIS"."F_NOMBRE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_NOMBRE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_NOMBRE" TO "PROGRAMADORESCSI";
