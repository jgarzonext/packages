--------------------------------------------------------
--  DDL for Function FBPRIMASPAGADAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBPRIMASPAGADAS" (
   psesion    IN   NUMBER,
   psseguro   IN   NUMBER,
   pnriesgo   IN   NUMBER,
   pcgarant   IN   NUMBER,
   pfecha     IN   NUMBER,
   ptipo      IN   NUMBER DEFAULT 1)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       FBPRIMASPAGADAS
   DESCRIPCION:  Retorna la suma de las primas pagadas de una garantía en el
                 ejercicio que indica la fecha o desde el inicio hasta la fecha

   REVISIONES:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/12/2004   yil                CREACION DE LA FUNCIÓN

         ptipo: 1.- en el ejercicio
              2.- hasta la fecha
******************************************************************************/
   primas      NUMBER;
   v_fini      DATE;
   v_ffin      DATE;
   anyo        NUMBER;
   v_existe    NUMBER;
BEGIN
   IF ptipo = 1 THEN
      anyo := TO_CHAR (TO_DATE (pfecha, 'yyyymmdd'), 'yyyy');
      v_fini := TO_DATE ('0101' || anyo, 'ddmmyyyy');
      v_ffin := TO_DATE ('3112' || anyo, 'ddmmyyyy');
   ELSIF ptipo = 2 THEN
      SELECT MIN (finiefe)
        INTO v_fini
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant;

      v_ffin := TO_DATE (pfecha, 'yyyymmdd');
   END IF;

   SELECT NVL (SUM (NVL (f_impgarant (r.nrecibo, 'PRIMA TOTAL', pcgarant,
                                      pnriesgo),
                         0)),
               0)
     INTO primas
     FROM recibos r, movrecibo m
    WHERE sseguro = psseguro
      AND m.nrecibo = r.nrecibo
      AND m.cestrec = 1
      AND m.cestant = 0
      AND m.smovrec = (SELECT MAX (mm.smovrec)
                         FROM movrecibo mm
                        WHERE mm.nrecibo = r.nrecibo)
      AND r.fefecto BETWEEN v_fini AND v_ffin;

   SELECT COUNT (*)
     INTO v_existe
     FROM tmp_fis_rescate
    WHERE sseguro = psseguro
      AND frescat = TO_DATE (pfecha, 'yyyymmdd')
      AND nriesgo = pnriesgo;

   IF v_existe = 0 THEN
      INSERT INTO tmp_fis_rescate
                  (sseguro, frescat, nriesgo, ivalora,
                   isum_primas, irendim, ireduc, ireg_trans, ircm, iretenc,
                   npmp)
           VALUES (psseguro, TO_DATE (pfecha, 'yyyymmdd'), pnriesgo, NULL,
                   primas, NULL, NULL, NULL, NULL, NULL,
                   NULL);
   END IF;

   RETURN primas;
END fbprimaspagadas; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FBPRIMASPAGADAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBPRIMASPAGADAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBPRIMASPAGADAS" TO "PROGRAMADORESCSI";
