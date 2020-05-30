--------------------------------------------------------
--  DDL for Function F_CDETCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CDETCES" (
   psseguro NUMBER,
   pnmovimi NUMBER DEFAULT NULL,
   ptablas VARCHAR2 DEFAULT 'REA')
   RETURN NUMBER IS
   /******************************************************************************
      NOMBRE:       F_CDETCES
      PROP¿SITO:
      REVISIONES:

    Ver        Fecha      Autor  Descripci¿n
   ---------  ----------  -----  ------------------------------------
    1.0       03/03/2011  JGR    1. Creaci¿n de funci¿n
    2.0       07/03/2012  AVT    2. 21559: LCOL999-Cambios en el Reaseguro: ceder con la versi¿n inicial de la p¿liza o con la temporalidad del plan
    3.0       17/10/2013  DCT    3.0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
   ******************************************************************************/

   /***********************************************************************
    F_CDETCES:
      Devuelve el valor que corresponde para CDETCES:
        1¿ Busca en CONTRATOS (reaseguro)
        2¿ Busca en PARINSTALACI¿N "REASEGURO"
      El campo CDETCES indica si se ha de grabar el detalle de las cesiones en
      REASEGEMI y DETREASEGEMI, lo que tambi¿n hace que en los cierres se graben
      las cesiones anuales y no por recibo (REASEGURO.NRECIBO = NULL, etc.).
      En este patch el cambio consistia en que el CDETCES se pueda definir a nivel
      de CONTRATO de reaseguro, por lo que primero buscamos en la tabla CONTRATOS
      y si all¿ es nulo lo buscamos como estaba antes en el f_parproductos_v(s.sproduc, 'REASEGURO')
   ***********************************************************************/
   w_scontra      contratos.scontra%TYPE;
   w_nversio      contratos.nversio%TYPE;
   w_ipleno       contratos.iretenc%TYPE;
   w_icapci       contratos.icapaci%TYPE;
   w_cdetces      contratos.cdetces%TYPE;
   w_cdetces2     contratos.cdetces%TYPE;
   w_sproduc      seguros.sproduc%TYPE;
   w_result       NUMBER;
   w_return       NUMBER;
   w_error        NUMBER;
   w_traza        NUMBER;
   w_fpolefe      DATE;   -- 21559 AVT 07/03/2012
BEGIN
   w_traza := 1;

   IF ptablas = 'EST' THEN
      BEGIN
         FOR r1 IN (SELECT DISTINCT s.cempres, g.finiefe, g.cgarant, s.cramo, s.cmodali,
                                    s.ctipseg, s.ccolect, s.cactivi, s.sproduc
                               FROM estgaranseg g, estseguros s
                              WHERE g.sseguro = psseguro
                                AND s.sseguro = psseguro
                                AND(g.nmovimi = pnmovimi
                                    OR(g.ffinefe IS NULL
                                       AND pnmovimi IS NULL))) LOOP
            w_traza := 2;
            w_sproduc := r1.sproduc;

            -- 21559 AVT 07/03/2012 segons temporalitat -------
            IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'PER_REV_NO_ANUAL'), 0) > 1) THEN
               w_fpolefe := pac_cesionesrea.f_renovacion_anual_rea(psseguro, r1.finiefe);
            ELSE
               w_fpolefe := r1.finiefe;
            END IF;

-- 21559 AVT 07/03/2012 fi-------------------------
            w_result := f_buscacontrato(psseguro, r1.finiefe, r1.cempres, r1.cgarant, r1.cramo,
                                        r1.cmodali, r1.ctipseg, r1.ccolect, r1.cactivi, 2,
                                        w_scontra, w_nversio, w_ipleno, w_icapci, w_cdetces);
            w_traza := 3;

            -- BUG 28492 - INICIO - DCT - 17/10/2013 - pmotiu = 11
            IF w_result = 104485 THEN
               w_result := f_buscacontrato(psseguro, r1.finiefe, r1.cempres, r1.cgarant,
                                           r1.cramo, r1.cmodali, r1.ctipseg, r1.ccolect,
                                           r1.cactivi, 11, w_scontra, w_nversio, w_ipleno,
                                           w_icapci, w_cdetces);
            END IF;

            -- BUG 28492 - FIN - DCT - 17/10/2013 - pmotiu = 11
            IF w_result != 0
               OR NVL(w_cdetces2, w_cdetces) != w_cdetces THEN
               w_return := NULL;
               EXIT;
            ELSE
               w_cdetces2 := w_cdetces;
               w_return := w_cdetces;
            END IF;
         END LOOP;
      END;
   ELSE
      BEGIN
         FOR r1 IN (SELECT DISTINCT s.cempres, g.finiefe, g.cgarant, s.cramo, s.cmodali,
                                    s.ctipseg, s.ccolect, s.cactivi, s.sproduc
                               FROM garanseg g, seguros s
                              WHERE g.sseguro = psseguro
                                AND s.sseguro = psseguro
                                AND(g.nmovimi = pnmovimi
                                    OR(g.ffinefe IS NULL
                                       AND pnmovimi IS NULL))) LOOP
            w_traza := 2;
            w_sproduc := r1.sproduc;

            -- 21559 AVT 07/03/2012 segons temporalitat -------
            IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'PER_REV_NO_ANUAL'), 0) > 1) THEN
               w_fpolefe := pac_cesionesrea.f_renovacion_anual_rea(psseguro, r1.finiefe);
            ELSE
               w_fpolefe := r1.finiefe;
            END IF;

-- 21559 AVT 07/03/2012 fi-------------------------
            w_result := f_buscacontrato(psseguro, r1.finiefe, r1.cempres, r1.cgarant, r1.cramo,
                                        r1.cmodali, r1.ctipseg, r1.ccolect, r1.cactivi, 2,
                                        w_scontra, w_nversio, w_ipleno, w_icapci, w_cdetces);
            w_traza := 3;

            -- BUG 28492 - INICIO - DCT - 17/10/2013 - pmotiu = 11
            IF w_result = 104485 THEN
               w_result := f_buscacontrato(psseguro, r1.finiefe, r1.cempres, r1.cgarant,
                                           r1.cramo, r1.cmodali, r1.ctipseg, r1.ccolect,
                                           r1.cactivi, 11, w_scontra, w_nversio, w_ipleno,
                                           w_icapci, w_cdetces);
            END IF;

            -- BUG 28492 - FIN - DCT - 17/10/2013 - pmotiu = 11
            IF w_result != 0
               OR NVL(w_cdetces2, w_cdetces) != w_cdetces THEN
               w_return := NULL;
               EXIT;
            ELSE
               w_cdetces2 := w_cdetces;
               w_return := w_cdetces;
            END IF;
         END LOOP;
      END;
   END IF;

   IF w_return IS NULL THEN
      w_error := f_parproductos(w_sproduc, 'REASEGURO', w_return);
   END IF;

   w_traza := 4;
   RETURN w_return;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_CDETCES', w_traza, 'SSEGURO: ' || psseguro, SQLERRM);
      RETURN NULL;
END f_cdetces;

/

  GRANT EXECUTE ON "AXIS"."F_CDETCES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CDETCES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CDETCES" TO "PROGRAMADORESCSI";
