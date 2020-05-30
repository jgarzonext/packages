--------------------------------------------------------
--  DDL for Package Body PAC_MORTALIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MORTALIDAD" IS
   FUNCTION ff_mortalidad_mr_mk(
      sesion IN NUMBER,
      ptabla IN NUMBER,
      pedad_1 IN NUMBER,
      pedad_2 IN NUMBER,
      psexo IN NUMBER,
      psimbolo IN VARCHAR2)
      RETURN NUMBER IS
      resultado      NUMBER := 0;
      vl1            NUMBER;
      vl2            NUMBER;
      k              NUMBER;
      s              NUMBER;
      g              NUMBER;
      c              NUMBER;
      ntraza         NUMBER;
      error          EXCEPTION;
   BEGIN
      -- L1
      ntraza := 1;

      IF psimbolo IS NOT NULL THEN
         ntraza := 2;

         SELECT DECODE(psexo, 1, a.vmascul, 2, a.vfemeni, NULL)
           INTO k
           FROM mortalidad a
          WHERE a.ctabla = ptabla
            AND a.ctipo = 1;

         ntraza := 3;

         SELECT DECODE(psexo, 1, a.vmascul, 2, a.vfemeni, NULL)
           INTO s
           FROM mortalidad a
          WHERE a.ctabla = ptabla
            AND a.ctipo = 2;

         ntraza := 4;

         SELECT DECODE(psexo, 1, a.vmascul, 2, a.vfemeni, NULL)
           INTO g
           FROM mortalidad a
          WHERE a.ctabla = ptabla
            AND a.ctipo = 3;

         ntraza := 5;

         SELECT DECODE(psexo, 1, a.vmascul, 2, a.vfemeni, NULL)
           INTO c
           FROM mortalidad a
          WHERE a.ctabla = ptabla
            AND a.ctipo = 4;
      END IF;

      IF k IS NULL
         OR s IS NULL
         OR g IS NULL
         OR c IS NULL THEN
         RAISE error;
      END IF;

      vl1 := k * POWER(s, pedad_1) * POWER(g, POWER(c, pedad_1));
      ntraza := 6;

      IF UPPER(psimbolo) IN('DX', 'PX', 'QX') THEN
         vl2 := k * POWER(s, pedad_2) * POWER(g, POWER(c, pedad_2));
      END IF;

      ntraza := 7;

      IF UPPER(psimbolo) = 'LX' THEN
         resultado := vl1;
      ELSIF UPPER(psimbolo) = 'DX' THEN
         resultado := vl1 - vl2;
      ELSIF UPPER(psimbolo) = 'PX' THEN
         resultado := vl2 / vl1;
      ELSIF UPPER(psimbolo) = 'QX' THEN
         resultado := (vl1 - vl2) / vl1;
      ELSE
         resultado := NULL;
      END IF;

      RETURN resultado;
   EXCEPTION
      WHEN error THEN
         p_tab_error(f_sysdate, f_user, 'pac_mortalidad.ff_mortalidad_mr_mk', ntraza,
                     'parametros ptabla =' || ptabla || 'pedad_1 =' || pedad_1 || ' pedad_2 ='
                     || pedad_2 || ' psexp =' || psexo || ' psimbolo =' || psimbolo,
                     'una constante es NULL');
         RETURN NULL;
      WHEN NO_DATA_FOUND THEN
         RETURN 0;   -- Si no ha trobat dades (p.ex. és major que 127) torna 0
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mortalidad.ff_mortalidad_mr_mk', ntraza,
                     'parametros ptabla =' || ptabla || 'pedad_1 =' || pedad_1 || ' pedad_2 ='
                     || pedad_2 || ' psexp =' || psexo || ' psimbolo =' || psimbolo,
                     'sqlerrm =' || SQLERRM);
         RETURN NULL;
   END ff_mortalidad_mr_mk;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_MORTALIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MORTALIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MORTALIDAD" TO "PROGRAMADORESCSI";
