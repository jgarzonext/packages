--------------------------------------------------------
--  DDL for Package Body PAC_CASLIQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CASLIQ" AS
   PROCEDURE inicialitzar(vempres IN NUMBER, vcia IN NUMBER, vsproces IN DATE) AS
   BEGIN
      p_cempres := vempres;
      p_ccompani := vcia;
      p_datamov := vsproces;
   END inicialitzar;

   PROCEDURE lee AS
      leido          BOOLEAN := FALSE;
      wfanulac       DATE;
   BEGIN
      IF NOT rebut_cv%ISOPEN THEN
         OPEN rebut_cv;
      END IF;

      sortir := FALSE;

      FETCH rebut_cv
       INTO regliq;

      IF rebut_cv%NOTFOUND THEN
         leido := FALSE;
         sortir := TRUE;

         CLOSE rebut_cv;

         indemnit := indemnit * 100;
         tot_reb_liq := tot_reb_liq * 100;
         comis_cesgrup := comis_cesgrup * 100;
         tot_reb_cob_cent := tot_reb_cob_cent * 100;
         pag_compte := pag_compte * 100;
         pag_cia := pag_cia * 100;
      ELSE
         leido := TRUE;

         -- BUG -21546_108724- 13/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF rebut_cv%ISOPEN THEN
            CLOSE rebut_cv;
         END IF;
      END IF;

-- Inicializar variables
      IF leido THEN
         p_sseguro := 0;
         p_cramo := 0;
         p_cmodali := 0;
         p_ctipseg := 0;
         p_ccolect := 0;
         p_cproducto := NULL;
         p_efe := NULL;
         num_certificado := NULL;
         tip_reb := NULL;
         data_cobr_rec := NULL;
         data_cobr_sinis := NULL;
         itotal_rec := 0;
         itotal_sinis := 0;
         p_carrec_cia := NULL;
         p_nsincoa := NULL;
         p_sseguro := regliq.sseguro;
         --data_cobr_sinis := RegLiq.fecha_movimiento;
         data_cobr_rec := regliq.fecha_movimiento;

         BEGIN
            -- Se mira la situación del seguro
            SELECT csituac
              INTO situacion
              FROM seguros
             WHERE sseguro = regliq.sseguro;

            IF situacion IN(2, 3) THEN
               anulada := 'SI';
            ELSE
               anulada := NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               anulada := NULL;
         END;

         -- Obtención de campos para siniestros y recibos
         IF regliq.nsinies != 0 THEN
            BEGIN
               SELECT fsinies, nsincoa, crefint
                 INTO p_efe, p_nsincoa, refint
                 FROM siniestros
                WHERE nsinies = regliq.nsinies;

               regliq.fefecto := p_efe;
            EXCEPTION
               WHEN OTHERS THEN
                  --DBMS_OUTPUT.put_line('(Siniestros 1) nsinies = ' || TO_CHAR(regliq.nsinies)
                  --                     || ' - ' || SQLERRM);
                  NULL;
            END;

            cont := cont + 1;
            itotal_rec := regliq.itotalr * 100;
            indemnit := indemnit + regliq.itotalr;

            -- obtenemos la referencia
            BEGIN
               SELECT crefer
                 INTO refer
                 FROM pagosinitrami
                WHERE nsinies = regliq.nsinies
                  AND sidepag = regliq.sidepag;
            EXCEPTION
               WHEN OTHERS THEN
                  refer := NULL;
            END;
         ELSIF regliq.nrecibo != 0 THEN   -- Datos para recibos
            itotal_rec := regliq.itotalr * 100;
            tot_reb_liq := tot_reb_liq + regliq.itotalr;
            comis_cesgrup := comis_cesgrup + regliq.icomcia / 100;

            IF regliq.cgescob = 1 THEN   -- Gestiona la corredoria
               p_carrec_cia := 'N';
            ELSIF regliq.cgescob = 2 THEN   -- Gestiona la compañía
               p_carrec_cia := 'S';
               tot_reb_cob_cent := tot_reb_cob_cent + regliq.itotalr;
            ELSE
               p_carrec_cia := '?';
            END IF;

            cont := cont + 1;
         ELSE   -- apunts manuals
            IF regliq.cdebhab = 1 THEN   -- Debe (pagament a compte)
               pag_compte := pag_compte + regliq.itotalr;
            ELSIF regliq.cdebhab = 2 THEN   -- Haber (pagaments fets per Cia)
               pag_cia := pag_cia + regliq.itotalr;
            ELSE
               pag_compte := 0;
               pag_cia := 0;
            END IF;

            cont := cont + 1;
         END IF;

         -- Lectura del número de certificado
         BEGIN
            SELECT LPAD(polissa_ini, 10, '0')
              INTO num_certificado
              FROM cnvpolizas
             WHERE sseguro = p_sseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               num_certificado := '0000000000';
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line('(Cnvpolizas 1) sseguro = ' || TO_CHAR(p_sseguro) || ' - '
               --                     || SQLERRM);
               NULL;
         END;

         -- Acceso a seguros
         BEGIN
            IF p_sseguro <> 0 THEN
               SELECT LPAD(cramo, 2, 0), LPAD(cmodali, 2, 0), LPAD(ctipseg, 2, 0),
                      LPAD(ccolect, 2, 0), cforpag
                 INTO p_cramo, p_cmodali, p_ctipseg,
                      p_ccolect, codforpag
                 FROM seguros
                WHERE sseguro = p_sseguro;

               SELECT tatribu
                 INTO forpag
                 FROM detvalores
                WHERE cvalor = 17
                  AND cidioma = 1
                  AND catribu = codforpag;

               p_cproducto := TO_CHAR(p_cramo, 'fm00') || TO_CHAR(p_cmodali, 'fm00')
                              || TO_CHAR(p_ctipseg, 'fm00') || TO_CHAR(p_ccolect, 'fm00');
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line('(Seguros 1) sseguro = ' || TO_CHAR(p_sseguro) || ' - '
               --                     || SQLERRM);
               NULL;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         leido := FALSE;
         sortir := TRUE;

         CLOSE rebut_cv;

         -- multipliquem per 100 els totals
         indemnit := indemnit * 100;
         tot_reb_liq := tot_reb_liq * 100;
         comis_cesgrup := comis_cesgrup * 100;
         tot_reb_cob_cent := tot_reb_cob_cent * 100;
         pag_compte := pag_compte * 100;
         pag_cia := pag_cia * 100;
   END lee;

   FUNCTION fin
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF sortir THEN
         balance := tot_reb_liq - tot_reb_cob_cent - comis_cesgrup - pag_compte - indemnit
                    + pag_cia;

         IF balance > 0 THEN
            t_balance := 'A FAVOR CIA';
         ELSIF balance < 0 THEN
            t_balance := 'A FAVOR CORREDORIA';
         ELSE
            t_balance := 'A LIQUIDAR';
         END IF;

         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('sseguro = ' || TO_CHAR(p_sseguro) || ' - ' || SQLERRM);
         NULL;
   END fin;
END pac_casliq;

/

  GRANT EXECUTE ON "AXIS"."PAC_CASLIQ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CASLIQ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CASLIQ" TO "PROGRAMADORESCSI";
