--------------------------------------------------------
--  DDL for Package PK_IFSREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_IFSREC" AS
   TYPE tbenef IS TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;

   benefs         tbenef;
   r              NUMBER := 0;
   codramo        VARCHAR2(4) := 'IA02';
   num_certificado VARCHAR2(14) := NULL;
   certificado    VARCHAR2(6);
   poliza_ini     VARCHAR2(6) := NULL;
   moneda         VARCHAR2(3) := '???';
   subproducto    NUMBER(2, 0) := 0;
   cod_oficina    NUMBER(4, 0) := 0;
   aport_periodica NUMBER := 0;
   aport_inicial  NUMBER := 0;
   tiprec         VARCHAR2(1);
   ano            NUMBER;
   vaproc         NUMBER;
   vmproc         NUMBER;

   CURSOR rec_cv IS
      SELECT   s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.fefecto fefepol,
               s.npoliza, r.fefecto, v.itotalr, m.fmovdia, m.fmovini, r.ctiprec, r.nrecibo,
               TO_NUMBER(c.polissa_ini) "ANTIGUA", s.ncertif
          FROM cnvpolizas c, seguros s, vdetrecibos v, recibos r, movrecibo m
         WHERE (s.cramo, s.cmodali, s.ctipseg, s.ccolect) IN(
                  SELECT tp.cramo, tp.cmodali, tp.ctipseg, tp.ccolect
                    FROM tipos_producto tp
                   WHERE tp.tipo_producto = DECODE(pk_autom.mensaje,
                                                   'SLFCOBRO', 'ASSP',
                                                   'TAR'))
           AND m.nrecibo = r.nrecibo
           AND r.sseguro = s.sseguro
           AND r.nrecibo = v.nrecibo
           AND s.sseguro = c.sseguro
           AND s.npoliza = c.npoliza
           AND r.ctiprec IN(3, 0)
           AND m.cestrec = 1
           AND NOT EXISTS(SELECT mr.nrecibo
                            FROM movrecibo mr
                           WHERE mr.nrecibo = m.nrecibo
                             AND TRUNC(mr.fmovdia) BETWEEN TO_DATE(vaproc * 10000
                                                                   + vmproc * 100 + 1,
                                                                   'yyyymmdd')
                                                       AND LAST_DAY(TO_DATE(vaproc * 10000
                                                                            + vmproc * 100 + 1,
                                                                            'yyyymmdd'))
                             AND mr.smovrec > m.smovrec
                             AND((mr.cestrec = 0
                                  AND mr.cestant = 1)
                                 OR(mr.cestrec = 2
                                    AND mr.cestant = 0)))
           AND TRUNC(m.fmovdia) BETWEEN TO_DATE(vaproc * 10000 + vmproc * 100 + 1, 'yyyymmdd')
                                    AND LAST_DAY(TO_DATE(vaproc * 10000 + vmproc * 100 + 1,
                                                         'yyyymmdd'))
      ORDER BY TO_NUMBER(polissa_ini);

   TYPE regrectyp IS RECORD(
      sseguro        NUMBER,
      cramo          NUMBER(8),
      cmodali        NUMBER(2, 0),
      ctipseg        NUMBER(2, 0),
      ccolect        NUMBER(2, 0),
      fefepol        DATE,
      npoliza        VARCHAR2(13),
      fefecto        DATE,
      itotalr        NUMBER(25, 2),
      fmovdia        DATE,
      fmovini        DATE,
      ctiprec        NUMBER,
      nrecibo        NUMBER,
      antigua        NUMBER,
      ncertif        NUMBER   -- Bug 28462 - 04/10/2013 - DEV - la precisión debe ser NUMBER
   );

   regrec         regrectyp;

   PROCEDURE inicializar(aaproc IN NUMBER, mmproc IN NUMBER);

   PROCEDURE lee;

   PROCEDURE tratamiento;

   FUNCTION fin
      RETURN BOOLEAN;
END pk_ifsrec;

/

  GRANT EXECUTE ON "AXIS"."PK_IFSREC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_IFSREC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_IFSREC" TO "PROGRAMADORESCSI";
