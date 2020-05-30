--------------------------------------------------------
--  DDL for Package Body PAC_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FORMULAS" IS
   FUNCTION f_permf2000(
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnacim IN NUMBER,
      ptipo IN NUMBER,
      psimbolo IN VARCHAR2)
      RETURN NUMBER IS
      v_lx           NUMBER := 0;
      v_dx           NUMBER := 0;
      v_qx           NUMBER := 0;
      v_px           NUMBER := 0;
      resultado      NUMBER := 0;
   BEGIN
      BEGIN
         SELECT DECODE(psexo, 1, vmascul, 2, vfemeni)
           INTO v_lx
           FROM mortalidad
          WHERE ctabla = ptabla
            AND nedad = pedad
            AND nano_nacim = pnacim
            AND ctipo = ptipo;

         SELECT v_lx - DECODE(psexo, 1, vmascul, 2, vfemeni),
                DECODE(psexo, 1, vmascul, 2, vfemeni) / v_lx
           INTO v_dx,
                v_px
           FROM mortalidad
          WHERE ctabla = ptabla
            AND nedad = pedad + 1
            AND nano_nacim = pnacim
            AND ctipo = ptipo;

         SELECT v_dx / v_lx
           INTO v_qx
           FROM DUAL;
      END;

      SELECT DECODE(UPPER(psimbolo), 'LX', v_lx, 'DX', v_dx, 'QX', v_qx, 'PX', v_px)
        INTO resultado
        FROM DUAL;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_permf2000;

   FUNCTION f_lx_i(
      pfecha1 IN DATE,
      pfecha2 IN DATE,
      psexo IN NUMBER,
      pnacim IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER IS
      -- Devuelve la LX interpolada entre dos fechas
      v_edad         NUMBER(7, 4) := 0;
      v_mod1         NUMBER;
      v_mod2         NUMBER;
      v_lx1          NUMBER;
      v_lx2          NUMBER;
      v_lxi          NUMBER;
      --v_qxi    number;
      resultado      NUMBER;
   BEGIN
      v_edad := TRUNC((MONTHS_BETWEEN(pfecha1, pfecha2) / 12), 4);
      v_mod2 := v_edad - TRUNC(v_edad);
      v_mod1 := 1 - v_mod2;
      v_lx1 := pac_formulas.f_permf2000(6, TRUNC(v_edad), psexo, pnacim, ptipo, 'LX');
      v_lx2 := pac_formulas.f_permf2000(6, TRUNC(v_edad) + 1, psexo, pnacim, ptipo, 'LX');
      v_lxi := TRUNC((v_mod1 * v_lx1) +(v_mod2 * v_lx2), 4);
      -- v_qxi  := trunc(((v_lx1 - v_lx2) / v_lx1),4);
      RETURN v_lxi;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -2;
   END f_lx_i;

   FUNCTION f_cr(
      pfecha1 IN DATE,
      pfecha2 IN DATE,
      psexo IN NUMBER,
      pnacim IN NUMBER,
      ptipo IN NUMBER,
      paportacion IN NUMBER,
      pinteres IN NUMBER)
      RETURN NUMBER IS
      v_lx1          NUMBER;
      v_lx2          NUMBER;
      v_fecha1       DATE;
      v_qx           NUMBER;
      v_ndias        NUMBER;
      v_ndias_anyo   NUMBER;   --> número de dias exactos que tiene el año con el que estamos trabajando (365 o 366)
      v_periodo      NUMBER;
      v_pr           NUMBER;
   BEGIN
      -- QX = ((lx1 - lx2) / lx1), siendo:
      --      Lx1 la lx interpolada a la fecha de efecto
      --   Lz2 la lx interpolada al último dia del mes de la fecha de efecto.
      v_lx1 := pac_formulas.f_lx_i(pfecha1, pfecha2, psexo, pnacim, ptipo);
      v_fecha1 := LAST_DAY(pfecha1);
      v_lx2 := pac_formulas.f_lx_i(v_fecha1, pfecha2, psexo, pnacim, ptipo);
      v_qx :=((v_lx1 - v_lx2) / v_lx1);
      v_ndias := TO_DATE(v_fecha1, 'dd/mm/yyyy') - TO_DATE(pfecha1, 'dd/mm/yyyy');
      v_ndias_anyo := TO_DATE('31/12/' || TO_CHAR(pfecha2, 'yyyy'))
                      - TO_DATE('01/01/' || TO_CHAR(pfecha2, 'yyyy')) + 1;
      v_periodo :=((v_ndias / v_ndias_anyo) * .5);
      -- v_pr := TRUNC(power((paportacion + (paportacion * 10/100)) * (1+pinteres/100),v_periodo),4);
      v_pr := TRUNC(((paportacion +(paportacion * 10 / 100)) * v_qx)
                    * POWER((1 +(pinteres / 100)), v_periodo),
                    4);
      RETURN v_pr;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -3;
   END f_cr;

   -- BUG24926:DRA:29/01/2013:Inici
   FUNCTION f_tabmort(
      sesion IN NUMBER,
      ptabla IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnano_nacim IN NUMBER,
      ptipo IN NUMBER,
      psimbolo IN VARCHAR2)
      RETURN NUMBER IS
      resultado      NUMBER := 0;
      vl1            NUMBER;
      vl2            NUMBER;
      v_edad_min     NUMBER;
      v_edad         NUMBER;
   -- MSR 14/6/2007  Evitar que falli amb un DIVIDE_BY_ZERO quan v_lx valgui 0 i demanin psimbolo='LX' o 'DX'
   BEGIN
      v_edad := pedad;

      -- Primero miramos si la edad que nos pasan está dentro de los valores parametrizados en la tabla de mortalidad
      SELECT MIN(a.nedad)
        INTO v_edad_min
        FROM mortalidad a
       WHERE (a.nano_nacim = pnano_nacim
              OR pnano_nacim IS NULL)
         AND a.ctabla = ptabla
         AND(a.ctipo = ptipo
             OR ptipo IS NULL);

      IF v_edad_min > v_edad THEN
         v_edad := v_edad_min;
      END IF;

      -- L1
      IF psimbolo IS NOT NULL THEN
         SELECT DECODE(psexo, 1, a.vmascul, 2, a.vfemeni, NULL)
           INTO vl1
           FROM mortalidad a
          WHERE (a.nano_nacim = pnano_nacim
                 OR pnano_nacim IS NULL)
            AND a.ctabla = ptabla
            AND a.nedad = v_edad
            AND(a.ctipo = ptipo
                OR ptipo IS NULL);
      END IF;

      -- L2
      IF UPPER(psimbolo) IN('DX', 'PX', 'QX') THEN
         SELECT DECODE(psexo, 1, b.vmascul, 2, b.vfemeni, NULL)
           INTO vl2
           FROM mortalidad b
          WHERE (b.nano_nacim = pnano_nacim
                 OR pnano_nacim IS NULL)
            AND b.ctabla = ptabla
            AND b.nedad = v_edad + 1
            AND(b.ctipo = ptipo
                OR ptipo IS NULL);
      END IF;

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
      WHEN NO_DATA_FOUND THEN
         RETURN 0;   -- Si no ha trobat dades (p.ex. és major que 127) torna 0
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_formulas.f_tabmort', 99,
                     sesion || '-' || ptabla || '-' || pedad || '-' || psexo || '-'
                     || pnano_nacim || '-' || ptipo || '-' || psimbolo,
                     SQLERRM);
         RETURN 111419;
   END f_tabmort;
-- BUG24926:DRA:29/01/2013:Fi
END pac_formulas;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMULAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMULAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMULAS" TO "PROGRAMADORESCSI";
