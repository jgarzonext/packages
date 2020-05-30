--------------------------------------------------------
--  DDL for Function F_CUMULO_PERSONA
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION F_CUMULO_PERSONA (psperson IN per_personas.sperson%TYPE)
  RETURN NUMBER IS
  /***********************************************************************
    Nombre:        F_CUPO_GARANTIZADO
    Proposito:     Permite retornar el cupo garantizado.

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        13/12/2018   JLTS              1. CP0151M_SYS_PERS_val Creación de la función.
     2.0        12/12/2019   ECP               2. IAXIS-4785. Cumulo Depurado y ajustes a pantalla axisrea052
  ******************************************************************************/
  -- Ini IAXIS-4785 -- ECP -- 12/12/2019
  mensajes       t_iax_mensajes;
  v_cursor       SYS_REFCURSOR;
  v_nnumide      per_personas.nnumide%TYPE;
  v_cumulo_total NUMBER := 0;
  v_estvalor CONSTANT NUMBER := 1000; -- valores en miles
  vobject VARCHAR2(50):='f_cumulo_persona';
  vpasexec number:=1;
  vparam VARCHAR(2000):= 'XXXXXX';
BEGIN
  v_nnumide := pac_isqlfor.f_dades_persona(psperson,
                                           1);

  v_cumulo_total := pac_cumulos_conf.f_cum_total_tom(p_nnumide => v_nnumide, p_fcorte => f_sysdate );

  p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
         'v_v_nnumide '||v_nnumide ||'v_cumulo_total'||v_cumulo_total);
   
  -- Dummy result set for demo instead
  
  -- Fin IAXIS-4785 -- ECP -- 12/12/2019
  RETURN v_cumulo_total;
END f_cumulo_persona;

/
