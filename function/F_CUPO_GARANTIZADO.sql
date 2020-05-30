--------------------------------------------------------
--  DDL for Function F_CUPO_GARANTIZADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CUPO_GARANTIZADO" (psperson IN per_personas.sperson%TYPE) RETURN NUMBER IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  /***********************************************************************
    Nombre:        F_CUPO_GARANTIZADO
    Proposito:     Permite retornar el cupo garantizado.

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        13/12/2019   JLTS              1. CP0151M_SYS_PERS_val Creación de la función.
     2.0        24/02/2019   JLTS              2. TCS_9998 IAXIS-2490 Se adicionan campos PNCONTPOL y PNANIOSVINC en la
                                                  funcion F_CALCULA_MODELO
     3.0        13/03/2019   JLTS              3. IAXIS-3070 Se ajusta la funcion para que tenga en cuenta el cupo de persona natural y juridica
  ******************************************************************************/
  mensajes    t_iax_mensajes;
  v_mensaje   VARCHAR2(3200) := NULL;
  v_resultado NUMBER := 0;
  v_sfinanci  fin_indicadores.sfinanci%TYPE;
  v_nmovimi   fin_indicadores.nmovimi%TYPE;
  v_estvalor CONSTANT NUMBER := 1; -- valores en miles
  v_cuposug   NUMBER := 0;
  v_cupogar   NUMBER := 0;
  v_capafin   NUMBER := 0;
  v_cuposugv1 NUMBER := 0;
  v_cupogarv1 NUMBER := 0;
  v_capafinv1 NUMBER := 0;
  -- INI -IAXIS-3070 -JLTS - 13/03/2019
  v_ctipper   per_personas.ctipper%TYPE;
  -- FIN -IAXIS-3070 -JLTS - 13/03/2019
  -- INI - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adicionan campos V_NCONTPOL y V_NANIOSVINC
  v_ncontpol   NUMBER := 0;
  v_naniosvinc NUMBER := 0;
  -- FIN - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS
  vobjectname VARCHAR2(200) := 'F_CUPO_GERANTIZADO';
BEGIN
  -- Call the function
  -- INI -IAXIS-3070 -JLTS - 13/03/2019
  SELECT p.ctipper INTO v_ctipper FROM per_personas p WHERE p.sperson = psperson;
  IF v_ctipper = 2 THEN
    BEGIN
      SELECT fi.sfinanci, fi.nmovimi
        INTO v_sfinanci, v_nmovimi
        FROM fin_general f, fin_indicadores fi
       WHERE f.sperson = psperson
         AND f.sfinanci = fi.sfinanci
         AND fi.nmovimi = (SELECT MAX(fi2.nmovimi) FROM fin_indicadores fi2 WHERE fi2.sfinanci = fi.sfinanci);
    EXCEPTION
      WHEN no_data_found THEN
        RETURN v_resultado;
    END;
  ELSE
    BEGIN
      SELECT f.sfinanci
        INTO v_sfinanci
        FROM fin_general f
       WHERE f.sperson = psperson;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN v_resultado;
    END;
  END IF;

  -- FIN -IAXIS-3070 -JLTS - 13/03/2019
  v_resultado := pac_md_financiera.f_calcula_modelo(psfinanci   => v_sfinanci,
                                                    pnmovimi    => v_nmovimi,
                                                    pcesvalor   => v_estvalor,
                                                    pcuposug    => v_cuposug,
                                                    pcupogar    => v_cupogar,
                                                    pcapafin    => v_capafin,
                                                    pcuposugv1  => v_cuposugv1,
                                                    pcupogarv1  => v_cupogarv1,
                                                    pcapafinv1  => v_capafinv1,
                                                    pncontpol   => v_ncontpol,
                                                    pnaniosvinc => v_naniosvinc,
                                                    pcmonori    => NULL,
                                                    pcmondes    => NULL,
                                                    mensajes    => mensajes);
  IF mensajes IS NOT NULL THEN
    FOR i IN mensajes.first .. mensajes.last LOOP
      v_mensaje := v_mensaje || ' - ' || mensajes(i).terror;
      v_cupogar := 0;
    END LOOP;
    p_tab_error(f_sysdate, USER, vobjectname, 0, 'Error Funcion F_CUPO_GARANTIZADO', v_mensaje);
    RETURN v_cupogar; -- Error no envía valor
  END IF;
  COMMIT; -- IAXIS-3070 -JLTS - 13/03/2019. Se adiciona commit para que no presente problema en las consultas, incluyendo el PRAGMA
  RETURN v_cupogar;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END f_cupo_garantizado;

/

  GRANT EXECUTE ON "AXIS"."F_CUPO_GARANTIZADO" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."F_CUPO_GARANTIZADO" TO "R_AXIS";
