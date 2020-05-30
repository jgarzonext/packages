--------------------------------------------------------
--  DDL for Function F_CAPASEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPASEG" (
   psesi IN NUMBER,
   pempr IN NUMBER,
   pfini IN NUMBER,
   pffin IN NUMBER,
   pprod IN NUMBER)
   RETURN NUMBER IS
   total          NUMBER;
   sigcapital     NUMBER;
   vnmov          NUMBER;
   vseguro        NUMBER;
   nerror         NUMBER;
   vramo          NUMBER;
   vmodali        NUMBER;
   vtipseg        NUMBER;
   vcolect        NUMBER;
   vfini          VARCHAR2(8);
   vffin          VARCHAR2(8);

   CURSOR producte IS
      SELECT cramo, cmodali, ctipseg, ccolect
        FROM productos
       WHERE sproduc = pprod;

   CURSOR polizas IS
      SELECT sseguro
        FROM seguros
       WHERE cramo = vramo
         AND cmodali = vmodali
         AND ctipseg = vtipseg
         AND ccolect = vcolect
         AND(fanulac IS NULL
             OR(fanulac BETWEEN TO_DATE(vfini, 'YYYYMMDD') AND TO_DATE(vffin, 'YYYYMMDD')));

   --SELECT S.SSEGURO FROM PRODUCTOS P, SEGUROS S  WHERE P.CRAMO=S.CRAMO AND P.CMODALI=S.CMODALI
   --AND P.CTIPSEG=S.CTIPSEG AND P.CCOLECT=S.CCOLECT AND P.CRAMO=PRAMO AND P.CMODALI=PMODA
   --AND P.CTIPSEG=PTIPS AND P.CCOLECT=PCOLE AND (S.FANULAC IS NULL OR (S.FANULAC BETWEEN TO_DATE(PFINI,'DDMMYYYY') AND TO_DATE(PFFIN,'DDMMYYYY')));
   CURSOR capital IS
      SELECT icapital
        FROM garanseg
       WHERE sseguro = vseguro
         AND nmovimi = vnmov
         AND cgarant = 1;
        --AND FINIEFE=FECHA ************ pendent de preguntar ************
/*************************************************************************
    F_CAPASEG        Calcula el capital a aplicar en el capital
                    asegurado.
*************************************************************************/
BEGIN
   vfini := LPAD(TO_CHAR(pfini), 8, '00000000');
   vffin := LPAD(TO_CHAR(pffin), 8, '00000000');

   OPEN producte;

   FETCH producte
    INTO vramo, vmodali, vtipseg, vcolect;

   CLOSE producte;

   IF polizas%ISOPEN THEN
      CLOSE polizas;
   END IF;

   total := 0;

   OPEN polizas;

   LOOP
      FETCH polizas
       INTO vseguro;

      EXIT WHEN polizas%NOTFOUND;
      nerror := f_buscanmovimi(vseguro, 1, 1, vnmov);

      IF nerror = 0 THEN
         -- miramos el capital al que se le han
         -- de aplicar los gastos de gestión.
         IF capital%ISOPEN THEN
            CLOSE capital;
         END IF;

         OPEN capital;

         LOOP
            FETCH capital
             INTO sigcapital;

            EXIT WHEN capital%NOTFOUND;
            total := total + sigcapital;
         END LOOP;

         CLOSE capital;
      END IF;
   END LOOP;

   CLOSE polizas;

   RETURN total;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- BUG 21546_108724 - 04/02/2012 - JLTS - Se cierran los cursores
      IF producte%ISOPEN THEN
         CLOSE producte;
      END IF;

      IF polizas%ISOPEN THEN
         CLOSE polizas;
      END IF;

      RETURN -1;
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 04/02/2012 - JLTS - Se cierran los cursores
      IF producte%ISOPEN THEN
         CLOSE producte;
      END IF;

      IF polizas%ISOPEN THEN
         CLOSE polizas;
      END IF;

      RETURN -1;
END f_capaseg;

/

  GRANT EXECUTE ON "AXIS"."F_CAPASEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPASEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPASEG" TO "PROGRAMADORESCSI";
