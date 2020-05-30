--------------------------------------------------------
--  DDL for Function F_TRASPASO_TMP_PRIMAS_CONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TRASPASO_TMP_PRIMAS_CONS" (
   psseguro   IN   NUMBER,
   pnriesgo   in    NUMBER,
   pnsinies   in number)
   RETURN NUMBER AUTHID CURRENT_USER IS
BEGIN
   BEGIN
      INSERT INTO primas_consumidas
                  (sseguro, nnumlin, norden, ipricons, ircm, fecha, frescat,
                   nriesgo, ndias, ncoefic, nanys, preduc, ireduc,
                   preg_trans, ireg_trans, ircm_neto, nsinies,
                   ncoef_regtrans, ibrut_regtrans, rcmbrut_reducido, ircm_netocomp,
                   ireg_transcomp)
         SELECT sseguro, nnumlin, norden, ipricons, ircm, fecha, frescat,
                nriesgo, ndias, ncoefic, nanys, preduc, ireduc, preg_trans,
                ireg_trans, ircm_neto, pnsinies,
                ncoef_regtrans, ibrut_regtrans, rcmbrut_reducido, ircm_netocomp,
                ireg_transcomp
           FROM tmp_primas_consumidas
          WHERE sseguro = psseguro
            AND nriesgo = nvl(pnriesgo, nriesgo);

      INSERT INTO fis_rescate
                  (sseguro, frescat, nriesgo, ivalora, isum_primas, irendim,
                   ireduc, ireg_trans, ircm, iretenc, npmp)
         SELECT sseguro, frescat, nriesgo, ivalora, isum_primas, irendim,
                ireduc, ireg_trans, ircm, iretenc, npmp
           FROM tmp_fis_rescate
          WHERE sseguro = psseguro
            AND nriesgo = nvl(pnriesgo, nriesgo);

	DELETE FROM tmp_primas_consumidas
	WHERE sseguro = psseguro AND
		nriesgo = nvl(pnriesgo, nriesgo);

	DELETE FROM tmp_fis_rescate
	WHERE sseguro = psseguro AND
		nriesgo = nvl(pnriesgo, nriesgo);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error (f_sysdate, f_user, 'f_traspaso_tmp_primas_cons',
                      null, 'Error no controlado con psseguro ='||psseguro||' pnriesgo ='||pnriesgo||' pnsinies ='||pnsinies, SQLERRM);
         RETURN 140999;
   END;
END f_traspaso_tmp_primas_cons;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TRASPASO_TMP_PRIMAS_CONS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TRASPASO_TMP_PRIMAS_CONS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TRASPASO_TMP_PRIMAS_CONS" TO "PROGRAMADORESCSI";
