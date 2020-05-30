--------------------------------------------------------
--  DDL for Package PK_085E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_085E" AUTHID CURRENT_USER IS
   CURSOR cpersones IS
      SELECT   /*+ALL_ROWS ORDERED*/
               pu.sperson, cli.cperhos
          FROM tmp_clients_patrimoni cli, personas_ulk pu
         WHERE cli.cperhos = pu.cperhos
      ORDER BY 1, 2;

   rpers          cpersones%ROWTYPE;

   ---
   CURSOR ccontra(psperson NUMBER) IS
      SELECT cpol.sseguro, cpol.polissa_ini, cpol.producte, cpol.ram, cpol.moda, cpol.tipo,
             cpol.cole
        FROM asegurados ass, cnvpolizas cpol, productos prod
       WHERE ass.sperson = psperson
         AND ass.sseguro = cpol.sseguro
         AND ass.ffecfin IS NULL
         AND prod.cramo = cpol.ram
         AND prod.cmodali = cpol.moda
         AND prod.ctipseg = cpol.tipo
         AND prod.ccolect = cpol.cole
         AND EXISTS(SELECT 1
                      FROM parproductos
                     WHERE sproduc = prod.sproduc
                       AND cparpro = 'ENVPATR'
                       AND cvalpar = 1);

   rcontra        ccontra%ROWTYPE;

   ---
   CURSOR cctas(vsseguro NUMBER, ultimdia DATE, avui DATE) IS
      SELECT   DECODE(cmovimi,
                      1, 28,
                      2, 28,
                      6, 48,
                      8, 18,
                      10, 28,
                      31, 17,
                      32, 17,
                      33, 29,
                      34, 17,
                      46, 47,
                      47, 19,
                      49, 28,
                      51, 28,
                      52, 28,
                      53, 28,
                      54, 17,
                      NULL) tipope,
               cmovimi, imovimi, fcontab, fvalmov, nnumlin
          FROM ctaseguro
         WHERE sseguro = vsseguro
           AND fcontab BETWEEN ultimdia AND avui
      ORDER BY nnumlin;

   rcta           cctas%ROWTYPE;

   ---
   CURSOR cren(vsseguro NUMBER, ultimdia DATE, avui DATE) IS
      SELECT   16 tipope, NULL, isinret, ffecpag, ffecefe, srecren
          FROM pagosrenta
         WHERE sseguro = vsseguro
           AND ffecpag BETWEEN ultimdia AND avui
      ORDER BY srecren;

   rrend          cren%ROWTYPE;
   ---Variables del segment
   tiporeg        NUMBER(2);
   noperaci       VARCHAR2(20);
   subprod        VARCHAR2(2);
   polini         VARCHAR2(13);
   fecoper        DATE;
   fecvalo        DATE;
   fecini         DATE;
   tipope         NUMBER(2);
   oficina        NUMBER(4);
   import1        NUMBER;   --NUMBER(17, 2);
   timport1       VARCHAR2(17);
   sigimp1        VARCHAR2(1);
   ---
   avui           DATE;
   ultimdia       DATE;
   enviar         BOOLEAN := TRUE;
   nomesmov       BOOLEAN := FALSE;
   nomesrend      BOOLEAN := FALSE;

   ---
   FUNCTION f_ultimdia
      RETURN DATE;

   PROCEDURE inicialitzar;

   PROCEDURE contracte;

   PROCEDURE ctaseg(psseguro IN NUMBER);

   PROCEDURE crendes(psseguro IN NUMBER);

   PROCEDURE finalitzar;
END pk_085e;

/

  GRANT EXECUTE ON "AXIS"."PK_085E" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_085E" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_085E" TO "PROGRAMADORESCSI";
