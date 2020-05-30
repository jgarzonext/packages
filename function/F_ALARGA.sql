--------------------------------------------------------
--  DDL for Function F_ALARGA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ALARGA" (
   psproces IN NUMBER,
   psseguro IN NUMBER,
   pnmovimi IN NUMBER,
   pfinici_old IN DATE,
   pffin IN DATE,
   pmoneda IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_ALARGA: Aquesta funció permet crear moviments d'allargament o
                escurçament de cessions per canvis de data de renovació
                de pòlisses a CESIONESREA.
                Poden allargar-se els moviments amb els següents CGENERA:
                  1 - regularitzacions
                  3 - nova producció
                  4 - suplement
                  5 - renovació
                  9 - rehabilitació
                 40 - allargament
                Es crean moviments amb els següents CGENERA:
                 40 - allargament positiu cap al futur
                 41 - escurçament (moviment negatiu)
       Adaptación para corregir errores relativos
                          a la 'pfinici'.
***************************************************************************/
/*
     lnmovigen     NUMBER;
     codi_error    NUMBER := 0;
     w_dias_origen NUMBER;
     w_dias        NUMBER;
     w_icesion     NUMBER(13,2);
     w_cgenera     NUMBER(2);
     w_scesrea     NUMBER(8);
     w_finici      DATE;
     w_ffin        DATE;
     w_cduraci     NUMBER(1);

     pfinici       DATE;
      w_cforpag     NUMBER(2);
      w_sproduc     NUMBER(6);
*/
   lnmovigen      cesionesrea.nmovigen%TYPE;
   codi_error     NUMBER := 0;
   w_dias_origen  NUMBER;
   w_dias         NUMBER;
   w_icesion      cesionesrea.icesion%TYPE;
   w_cgenera      cesionesrea.cgenera%TYPE;
   w_scesrea      cesionesrea.scesrea%TYPE;
   w_finici       cesionesrea.fefecto%TYPE;
   w_ffin         cesionesrea.fvencim%TYPE;
   w_cduraci      seguros.cduraci%TYPE;
   pfinici        cesionesrea.fvencim%TYPE;
   w_cforpag      seguros.cforpag%TYPE;
   w_sproduc      seguros.sproduc%TYPE;

   CURSOR cur_ces IS
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND cgenera IN(1, 3, 4, 5, 9, 40)
         AND fregula IS NULL
         AND fanulac IS NULL
         AND TRUNC(fvencim) = TRUNC(pfinici);
BEGIN
   -- Obtención de la fecha de renovación antigua
   -- basandonos en CESIONESREA y el movimiento pasado
     -- Obtenim el nº nmovigen
   BEGIN
      SELECT NVL(MAX(nmovigen), 0) + 1
        INTO lnmovigen
        FROM cesionesrea
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         lnmovigen := 1;
   END;

   BEGIN
      SELECT MAX(fvencim)
        INTO pfinici
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND cgenera IN(1, 3, 4, 5, 9, 40)
         AND fregula IS NULL
         AND fanulac IS NULL
         AND nmovimi <= pnmovimi;
   EXCEPTION
      WHEN OTHERS THEN
         codi_error := 101919;
         RETURN(codi_error);
   END;

   FOR reg IN cur_ces LOOP
      codi_error := f_difdata(reg.fefecto, reg.fvencim, 1, 3, w_dias_origen);

      IF codi_error <> 0 THEN
         RETURN(codi_error);
      END IF;

      IF w_dias_origen = 0 THEN
         w_dias_origen := 1;
      END IF;

      BEGIN
         SELECT cduraci, sproduc, cforpag
           INTO w_cduraci, w_sproduc, w_cforpag
           FROM seguros
          WHERE sseguro = reg.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            codi_error := 101919;
            RETURN(codi_error);
      END;

      IF pffin >= pfinici THEN   -- Moviment d'allargament...
         codi_error := f_difdata(pfinici, pffin, 1, 3, w_dias);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         IF w_dias = 0 THEN
            w_dias := 1;
         END IF;

         w_icesion := (reg.icesion / w_dias_origen) * w_dias;
         --w_icesion := f_round(w_icesion,pmoneda);
         w_icesion := f_round_forpag(w_icesion, w_cforpag, pmoneda, w_sproduc);
         w_cgenera := 40;
         w_finici := pfinici;
         w_ffin := pffin;
      ELSE   -- Moviment d'escurçament...
         codi_error := f_difdata(pffin, pfinici, 1, 3, w_dias);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         IF w_dias = 0 THEN
            w_dias := 1;
         END IF;

         w_icesion := ((reg.icesion / w_dias_origen) * w_dias) * -1;
         --w_icesion := f_round(w_icesion,pmoneda);
         w_icesion := f_round_forpag(w_icesion, w_cforpag, pmoneda, w_sproduc);
         w_cgenera := 41;
         w_finici := pffin;
         w_ffin := pfinici;

         BEGIN
            UPDATE cesionesrea
               SET fanulac = pffin
             WHERE scesrea = reg.scesrea;
         END;
      END IF;

      SELECT scesrea.NEXTVAL
        INTO w_scesrea
        FROM DUAL;

      BEGIN
         INSERT INTO cesionesrea
                     (scesrea, ncesion, icesion, icapces, sseguro,
                      nversio, scontra, ctramo, sfacult, nriesgo,
                      icomisi, icomreg, scumulo, cgarant, spleno,
                      ccalif1, ccalif2, nmovimi, fefecto, fvencim, pcesion,
                      sproces, cgenera, fgenera, nmovigen, ipleno, icapaci,
                      iextrap, iextrea)
              VALUES (w_scesrea, reg.ncesion, w_icesion, reg.icapces, reg.sseguro,
                      reg.nversio, reg.scontra, reg.ctramo, reg.sfacult, reg.nriesgo,
                      reg.icomisi, reg.icomreg, reg.scumulo, reg.cgarant, reg.spleno,
                      reg.ccalif1, reg.ccalif2, pnmovimi, w_finici, w_ffin, reg.pcesion,
                      psproces, w_cgenera, f_sysdate, lnmovigen, reg.ipleno, reg.icapaci,
                      reg.iextrap, reg.iextrea);
      EXCEPTION
         WHEN OTHERS THEN
            codi_error := 104740;
            RETURN(codi_error);
      END;
   END LOOP;

   RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_ALARGA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ALARGA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ALARGA" TO "PROGRAMADORESCSI";
