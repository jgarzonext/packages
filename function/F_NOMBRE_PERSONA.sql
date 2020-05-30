CREATE OR REPLACE FUNCTION F_NOMBRE_PERSONA(psperson IN NUMBER,
										    pnformat IN NUMBER,
										    pcagente IN agentes.cagente%TYPE DEFAULT NULL)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/****************************************************************************
    F_NOMBRE: DEVUELVE EL NOMBRE DE UNA PERSONA FORMATEADO NOMBRE Y APELLIDO

              PNFORMAT = 1 => < NOMBRE APELLIDOS >

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/04/2020   JRVG              1. IAXIS-4102: CUENTA 27
****************************************************************************/
   vntraza        NUMBER := 0;
   pnombre        VARCHAR2(200);
   pnombre2       VARCHAR2(200);
   letra1         VARCHAR2(1);
   pnnumnif       per_personas.nnumide%TYPE;
   v_tapelli1     per_detper.tapelli1%TYPE;
   v_tapelli2     per_detper.tapelli2%TYPE;
   v_tnombre      per_detper.tnombre%TYPE;

 BEGIN
   BEGIN
      vntraza := 1;
      SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)), LTRIM(RTRIM(pd.tnombre)),
             p.nnumide
        INTO v_tapelli1, v_tapelli2, v_tnombre,
             pnnumnif
        FROM per_personas p, per_detper pd
       WHERE p.sperson = pd.sperson
         AND p.sperson = psperson
         --  AND p.swpubli = 1   -- No se tiene en cuenta p.swpubli
         AND pd.cagente = p.cagente;
     vntraza := 2;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         vntraza := 3;
         IF pcagente IS NOT NULL THEN
            vntraza := 4;
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

   IF pnformat = 1 THEN

     IF v_tnombre IS NULL AND v_tapelli2 IS NULL THEN
       pnombre := v_tapelli1;
     ELSE
       pnombre := v_tnombre || ' ' || v_tapelli1 || ' ' || v_tapelli2;
     END IF;

  END IF;

  RETURN pnombre;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN('**');
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_NOMBRE_PERSONA', vntraza,
                  'Parametros - psperson = ' || psperson || '  nformat = ' || pnformat
                  || ' pcagente = ' || pcagente,
                  SQLERRM);
      RETURN('**');
  END;
/