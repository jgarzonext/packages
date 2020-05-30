--------------------------------------------------------
--  DDL for Function FF_TVAL_DOCUREQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_TVAL_DOCUREQ" (ptfuncio IN VARCHAR2,
                                           ptablas IN VARCHAR2,
                                           pcactivi IN NUMBER,
                                           psseguro IN NUMBER,
                                           pnmovimi IN NUMBER,
                                           pnriesgo IN NUMBER,
                                           psperson IN NUMBER)
   RETURN NUMBER IS
   --
   vobjectname VARCHAR2(500) := 'ff_tval_docureq';
   vparam      VARCHAR2(500) := 'parámetros - ptfuncio:' || ptfuncio;
   vpasexec    NUMBER(5) := 1;
   vnum_err    NUMBER := 0;
   v_result    NUMBER;
   e_object_error EXCEPTION;
   --
BEGIN
   --
   IF ptfuncio IS NOT NULL THEN
     vnum_err := pac_albsgt.f_tval_docureq(ptfuncio,
                                           ptablas,
                                           pcactivi,
                                           psseguro,
                                           pnmovimi,
                                           pnriesgo,
                                           psperson,
                                           v_result);
   ELSE
      v_result := 1;
   END IF;
   --
   IF vnum_err <> 0
   THEN
      RAISE e_object_error;
   END IF;
   --
   RETURN v_result;
EXCEPTION
   WHEN e_object_error THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobjectname,
                  vpasexec,
                  vparam,
                  'Error ff_tval_docureq. Num_err:' || vnum_err);
      RETURN 0;
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLERRM);
      RETURN 0;
END FF_TVAL_DOCUREQ;

/

  GRANT EXECUTE ON "AXIS"."FF_TVAL_DOCUREQ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_TVAL_DOCUREQ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_TVAL_DOCUREQ" TO "PROGRAMADORESCSI";
