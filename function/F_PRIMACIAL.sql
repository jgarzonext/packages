--------------------------------------------------------
--  DDL for Function F_PRIMACIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRIMACIAL" (
   psesi IN NUMBER,
   pempr IN NUMBER,
   pfini IN NUMBER,
   pffin IN NUMBER,
   pprod IN NUMBER)
   RETURN NUMBER IS
   total          NUMBER;
   sigcapital     NUMBER;
   vffin          DATE;
   vfini          DATE;
   vramo          NUMBER;
   vmodali        NUMBER;
   vtipseg        NUMBER;
   vcolect        NUMBER;

   CURSOR producte IS
      SELECT cramo, cmodali, ctipseg, ccolect
        FROM productos
       WHERE sproduc = pprod
         AND ccalcom = 1;

   CURSOR capital IS
      SELECT SUM(DECODE(r.ctiprec,
                        9, DECODE(m.cestrec, 0, icombru, -icombru),
                        DECODE(m.cestrec, 0, -icombru, icombru)))
        FROM movrecibo m, seguros s, recibos r, vdetrecibos v
       WHERE m.nrecibo = r.nrecibo
         AND r.sseguro = s.sseguro
         AND s.cramo = vramo
         AND s.cmodali = vmodali
         AND s.ctipseg = vtipseg
         AND s.ccolect = vcolect
         AND r.nrecibo = v.nrecibo
         AND m.fmovdia BETWEEN vfini AND vffin
         AND m.cestrec IN(0, 1)
         AND(m.cestant NOT IN(0)
             OR m.cestrec IN(1))
         AND(r.ctiprec <> 9
             OR(r.ctiprec = 9
                AND m.cestrec IN(1, 0)))
         AND m.cestrec <> 2;
/************************************************************************
   F_PRIMACIAL    Calcula el capital a aplicar la comisión
            sobre prima comercial
            sino devuelve 1
*************************************************************************/
BEGIN
   total := 0;
   vfini := TO_DATE(pfini, 'YYYYMMDD');
   vffin := TO_DATE(pffin, 'YYYYMMDD');

   OPEN producte;

   FETCH producte
    INTO vramo, vmodali, vtipseg, vcolect;

   CLOSE producte;

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

   RETURN total;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF producte%ISOPEN THEN
         CLOSE producte;
      END IF;

      IF capital%ISOPEN THEN
         CLOSE capital;
      END IF;

      RETURN 0;
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF producte%ISOPEN THEN
         CLOSE producte;
      END IF;

      IF capital%ISOPEN THEN
         CLOSE capital;
      END IF;

      RETURN 0;
END f_primacial;

/

  GRANT EXECUTE ON "AXIS"."F_PRIMACIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRIMACIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRIMACIAL" TO "PROGRAMADORESCSI";
