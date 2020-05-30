--------------------------------------------------------
--  DDL for Function F_COBBAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COBBAN" (
   pcempres IN NUMBER,
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pfefecto IN DATE,
   psproces IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /******************************************************************************
     NOMBRE:       f_cobban
     PROPÓSITO:
     --
     --   Crea els registres de DOMICILIACIONES amb els
     -- rebuts pendents de generar domiciliació bancària, i actualitza el seu estat.
     --
     -- Excloure el tipus de rebut 9 (Extorns), 13 (Retorno)
     -- Incloure unicament rebuts validats (cestaux=0)

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        03/11/2011   JMF               1. 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
   ******************************************************************************/
   estat          NUMBER;
   xcontad        NUMBER := 0;
   xfsituac       DATE;
   xmincobdom     DATE;
   xfmovim        DATE;

   CURSOR cur_recibos IS
      SELECT r.nrecibo, r.ccobban, c.tsufijo, c.cdoment, c.cdomsuc, s.cramo, s.cmodali,
             s.ctipseg, s.ccolect, m.fmovini
        FROM seguros s, cobbancario c, recibos r, movrecibo m
       WHERE r.cempres = pcempres
         AND r.cestimp = 4
         AND r.ctiprec <> 9
         AND r.ctiprec <> 13   -- bug 0019791
         AND r.fefecto < pfefecto + 1
         AND r.ccobban = c.ccobban
         AND(s.cramo = pcramo
             OR pcramo IS NULL)
         AND(s.cmodali = pcmodali
             OR pcmodali IS NULL)
         AND r.sseguro = s.sseguro
         AND r.nrecibo = m.nrecibo
         AND m.cestrec = 0   -- Sólo los recibos pendientes
         AND m.fmovfin IS NULL
         AND r.cestaux = 0
         AND NVL(r.cgescob, 1) = 1;   -- Per corredoria, que gestioni el cobrament la corredoria
BEGIN
-- Buscamos el nº de días de carencia para el cobro desde la generación del soporte
   BEGIN
      SELECT TRUNC(f_sysdate) + NVL(ncardom, 0)
        INTO xmincobdom
        FROM empresas
       WHERE cempres = pcempres;
   EXCEPTION
      WHEN OTHERS THEN
         xmincobdom := TRUNC(f_sysdate);
   END;

   IF pcmodali IS NOT NULL
      AND pcramo IS NULL THEN
      RETURN 101901;   -- Pas incorrecte de paràmetres a la funció
   ELSE
      FOR rec IN cur_recibos LOOP
         IF f_produsu(rec.cramo, rec.cmodali, rec.ctipseg, rec.ccolect, 5) = 1 THEN
            IF rec.fmovini < xmincobdom THEN
               xfmovim := xmincobdom;
            ELSE
               xfmovim := rec.fmovini;
            END IF;

            BEGIN
               INSERT INTO domiciliaciones
                           (sproces, nrecibo, ccobban, cempres, fefecto,
                            cdoment, cdomsuc, tsufijo, smovrec)
                    VALUES (psproces, rec.nrecibo, rec.ccobban, pcempres, xfmovim,
                            rec.cdoment, rec.cdomsuc, rec.tsufijo, NULL);

               xcontad := xcontad + 1;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 102920;   -- Registre repetit a DOMICILIACIONES
               WHEN OTHERS THEN
                  RETURN 105058;   -- Error a l' inserir a DOMICILIACIONES
            END;
         END IF;
      END LOOP;

      IF xcontad > 0 THEN
         RETURN 0;
      ELSE
         RETURN 102903;   -- No s' ha trobat cap registre
      END IF;
   END IF;
END;
 

/

  GRANT EXECUTE ON "AXIS"."F_COBBAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COBBAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COBBAN" TO "PROGRAMADORESCSI";
