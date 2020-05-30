--------------------------------------------------------
--  DDL for Package Body PAC_CONMUTADORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CONMUTADORS" AS
/******************************************************************************
   NOMBRE:       PAC_CONMUTADORS
   PROPÓSITO:  Cuerpo del paquete de las funciones para
                el cáculo de los conmutadores actuariales.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/04/2009   JRH               1. Creación del package.
   2.0        01/05/2009   JRH               2. Bug 9172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   3.0        01/05/2009   JRH               3. Bug 10228: CRE055 - Adaptar el PAC_CONMUTADORS per a que pugui treballar amb sobremortalitats
   4.0        20/06/2009   JRH               4. Bug-10336 : CRE - Simular producto de rentas a partir del importe de renta y no de la prima
   5.0        11/11/2009   JRH               5. Bug-0011462: CEM - RVI - Definición y parametrización básica del producto
   6.0        09/12/2009   JRH               6. Bug-0011268: CEM - Migración de los productos ahorro
   7.0        07/01/2010    JRH              7.0011463:CEM - RT - Definición y parametrización básica del producto
   8.0        03/03/2010    JRH              8. 12136: CEM - RVI - Verificación productos RVI
   9.0        17/03/2010    JRH              9. 13969: CEM301 - RVI - Ajustes formulación provisiones
   10.0       10/04/2010    JRH             10. 13969: CEM301 - RVI - Ajustes formulación provisiones
   11.0       10/04/2010    JRH             11. 13969: CEM301 - RVI - Ajustes formulación provisiones
   12.0       22/04/2010    JRH             12. 13969: CEM301 - RVI - Ajustes formulación provisiones
   13.0       27/05/2013    APD             13. 0026947: LCOL - Fase Mejoras - Diseño Funcional Seguros Especiales - Vida Individual
   14.0       02/09/2013    DCT             14. 0028033: LCOL_MILL - Ajustar la sobremortalitat
******************************************************************************/
   erroracctab    EXCEPTION;
   errorparam     EXCEPTION;
   vmaxsize       NUMBER := 2;
   indice         NUMBER := 2;
   -- BUG 10228 - 05/2009 - JRH  - CRE - Adaptar el PAC_CONMUTADORS per a que pugui treballar amb sobremortalitats
   vmaxvalortabla NUMBER;
   vmaxvalortabla1 NUMBER;

   -- fi bug
   TYPE vparametros IS RECORD(
      pedadx         NUMBER,
      psexo          NUMBER,
      pnacim         NUMBER,
      pedady         NUMBER,
      psexo2         NUMBER,
      pnacim2        NUMBER,
      ptabla         NUMBER,
      pinter         NUMBER,
      pinter2        NUMBER,
      periodo        NUMBER,
      pgg            NUMBER,
      pig            NUMBER,
      panyos         NUMBER,
      panyos_rent    NUMBER,
      var            NUMBER,
      p_es_mensual   NUMBER,
      pforpag        NUMBER,
      pmesini        NUMBER,
      preemb         NUMBER,
      psobremort     NUMBER,
      pesahorr       NUMBER,
      prevers        NUMBER,
      ptabprogresiones VARCHAR2(32000),
      ptabpagasextras VARCHAR2(32000),
      pmesefecto     NUMBER,
      vesrevision    NUMBER,
      vtipoact       NUMBER,
      vincrementoriesg NUMBER,
      vanyostab      NUMBER,
      vtipoextrap    NUMBER,
      tab_conmu      t_conmutador
   );

   TYPE vtab_parametros IS TABLE OF vparametros
      INDEX BY BINARY_INTEGER;

   reg            vtab_parametros;

-- BUG 13969- 04/2010 - JRH  - Buscamos el maxTabla

   /*************************************************************************
        -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
        Calcula máximo años tabla
        ptabla in : Tabla
        return : Máximo años
   *************************************************************************/
   FUNCTION f_anyos_maxtabla(ptabla NUMBER)
      RETURN NUMBER IS
      vanyosmaxtab   NUMBER;
   BEGIN
      IF ptabla NOT IN(2, 3, 4) THEN
         BEGIN
            SELECT MAX(nedad)
              INTO vanyosmaxtab
              FROM mortalidad
             WHERE ctabla = ptabla;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vanyosmaxtab := 126;
         END;
      ELSE
         BEGIN
            SELECT MAX(nedad)
              INTO vanyosmaxtab
              FROM mortalidad
             WHERE ctabla = ptabla;

            vanyosmaxtab := TRUNC(vanyosmaxtab / 12);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vanyosmaxtab := 126;
         END;
      END IF;

      RETURN vanyosmaxtab;
   END f_anyos_maxtabla;

-- Fi BUG 13969- 04/2010 - JRH
/*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      f_buscarConm:Busca tabla de conmutadores en cache
      psesion in : Sesión
      pedadx  in : Edad primera cabeza (Siempre en años)
      psexo in  : Sexo primera cabeza
      pnacim in : Año nacimiento primera cabeza (Siempre en años)
      pedady in : Edad segunda cabeza (Siempre en años) (Puede ser nulo)
      psexo2 in : Sexo segunda cabeza (Puede ser nulo)
      pnacim2 in : Año nacimiento segunda cabeza (Siempre en años) (Puede ser nulo)
      ptabla in : Tabla mortalidad (0 si no hay riesgo)
      pinter in : Interes inicial
      pinter2 in : Segundo interés (Puede ser nulo)
      periodo  in : Años del periodo para el cambio interés (Puede ser nulo)
      pgg in : Progresión geom.
      pig in : Progre. lineal
      panyos in : Años hasta vencimiento (Puede ser nulo en pólizas vitalicias)
      panyos_rent in  Años hasta meritamiento para renta (Puede ser nulo en pólizas vitalicias)
      var number in : Factor correción en años
      p_es_mensual in : Tratamiento mensual en lugar de anual (si <>0)
      pforpag number in : Forma de pago (Ahorro o renta).
      pmesini number in : Mes inicio de la póliza (1 si la póliza renueva de forma contractual).
      preemb number in : Factor de reembolso del capital.
      psobremort number in : Factor de sobremortalidad.
      pesahorr number in : Si es póliza de ahorro (Hay casos en rentas que se considera la progresión 0 hasta el segundo mes)
      prevers number in : % Revers.
      return             : La tabla
   *************************************************************************/
   FUNCTION f_buscarconm(
      pedadx NUMBER,
      psexo NUMBER,
      pnacim NUMBER,
      pedady NUMBER,
      psexo2 NUMBER,
      pnacim2 NUMBER,
      ptabla NUMBER,
      pinter NUMBER,
      pinter2 NUMBER,
      periodo NUMBER,
      pgg NUMBER,
      pig NUMBER,
      panyos NUMBER,
      panyos_rent NUMBER,
      var NUMBER DEFAULT 0,
      p_es_mensual NUMBER DEFAULT 1,
      pforpag NUMBER DEFAULT 12,
      pmesini NUMBER DEFAULT 1,
      preemb NUMBER DEFAULT 0,
      psobremort NUMBER DEFAULT 0,
      pesahorr NUMBER DEFAULT 1,
      prevers NUMBER DEFAULT 0,
      ptabprogresiones VARCHAR2 DEFAULT NULL,
      ptabpagasextras VARCHAR2 DEFAULT NULL,
      pmesefecto NUMBER DEFAULT NULL,
      pesrevision NUMBER,
      ptipoact NUMBER,
      pincrementoriesg NUMBER,
      panyostab NUMBER,
      ptipoextrap NUMBER)
      RETURN t_conmutador IS
   BEGIN
      IF reg.COUNT > 0 THEN
         FOR i IN 1 .. vmaxsize LOOP
            IF reg.EXISTS(i) THEN
               IF NVL(reg(i).pedadx, -2.1) = NVL(pedadx, -2.1)
                  AND NVL(reg(i).psexo, -2.1) = NVL(psexo, -2.1)
                  AND NVL(reg(i).pnacim, -2.1) = NVL(pnacim, -2.1)
                  AND NVL(reg(i).pedady, -2.1) = NVL(pedady, -2.1)
                  AND NVL(reg(i).psexo2, -2.1) = NVL(psexo2, -2.1)
                  AND NVL(reg(i).pnacim2, -2.1) = NVL(pnacim2, -2.1)
                  AND NVL(reg(i).ptabla, -2.1) = NVL(ptabla, -2.1)
                  AND NVL(reg(i).pinter, -2.1) = NVL(pinter, -2.1)
                  AND NVL(reg(i).pinter2, -2.1) = NVL(pinter2, -2.1)
                  AND NVL(reg(i).periodo, -2.1) = NVL(periodo, -2.1)
                  AND NVL(reg(i).pgg, -2.1) = NVL(pgg, -2.1)
                  AND NVL(reg(i).pig, -2.1) = NVL(pig, -2.1)
                  AND NVL(reg(i).panyos, -2.1) = NVL(panyos, -2.1)
                  AND NVL(reg(i).panyos_rent, -2.1) = NVL(panyos_rent, -2.1)
                  AND NVL(reg(i).var, -2.1) = NVL(var, -2.1)
                  AND NVL(reg(i).p_es_mensual, -2.1) = NVL(p_es_mensual, -2.1)
                  AND NVL(reg(i).pforpag, -2.1) = NVL(pforpag, -2.1)
                  AND NVL(reg(i).pmesini, -2.1) = NVL(pmesini, -2.1)
                  AND NVL(reg(i).preemb, -2.1) = NVL(preemb, -2.1)
                  AND NVL(reg(i).psobremort, -2.1) = NVL(psobremort, -2.1)
                  AND NVL(reg(i).pesahorr, -2.1) = NVL(pesahorr, -2.1)
                  AND NVL(reg(i).ptabprogresiones, 'x') = NVL(ptabprogresiones, 'x')
                  AND NVL(reg(i).ptabpagasextras, 'x') = NVL(ptabpagasextras, 'x')
                  AND NVL(reg(i).pmesefecto, -2.1) = NVL(pmesefecto, -2.1)
                  AND NVL(reg(i).vesrevision, -2.1) = NVL(pesrevision, -2.1)
                  AND NVL(reg(i).vtipoact, -2.1) = NVL(ptipoact, -2.1)
                  AND NVL(reg(i).vincrementoriesg, -2.1) = NVL(pincrementoriesg, -2.1)
                  AND NVL(reg(i).prevers, -2.1) = NVL(prevers, -2.1)
                  AND NVL(reg(i).vtipoextrap, -2.1) = NVL(ptipoextrap, -2.1)   --JRH
                  AND NVL(reg(i).vanyostab, -2.1) = NVL(panyostab, -2.1) THEN
                  RETURN reg(i).tab_conmu;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CONMUTADORS.f_buscarConm', 1, 'OTHERS',
                     SUBSTR(SQLERRM, 1, 2500));
         RETURN NULL;
   END f_buscarconm;

/*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      p_AnadirConm:Añade tabla de conmutadores en cache
      psesion in : Sesión
      pedadx  in : Edad primera cabeza (Siempre en años)
      psexo in  : Sexo primera cabeza
      pnacim in : Año nacimiento primera cabeza (Siempre en años)
      pedady in : Edad segunda cabeza (Siempre en años) (Puede ser nulo)
      psexo2 in : Sexo segunda cabeza (Puede ser nulo)
      pnacim2 in : Año nacimiento segunda cabeza (Siempre en años) (Puede ser nulo)
      ptabla in : Tabla mortalidad (0 si no hay riesgo)
      pinter in : Interes inicial
      pinter2 in : Segundo interés (Puede ser nulo)
      periodo  in : Años del periodo para el cambio interés (Puede ser nulo)
      pgg in : Progresión geom.
      pig in : Progre. lineal
      panyos in : Años hasta vencimiento (Puede ser nulo en pólizas vitalicias)
      panyos_rent in  Años hasta meritamiento para renta (Puede ser nulo en pólizas vitalicias)
      var number in : Factor correción en años
      p_es_mensual in : Tratamiento mensual en lugar de anual (si <>0)
      pforpag number in : Forma de pago (Ahorro o renta).
      pmesini number in : Mes inicio de la póliza (1 si la póliza renueva de forma contractual).
      preemb number in : Factor de reembolso del capital.
      psobremort number in : Factor de sobremortalidad.
      pesahorr number in : Si es póliza de ahorro (Hay casos en rentas que se considera la progresión 0 hasta el segundo mes)
      prevers number in : % Revers.
      tab_Conmu : Tabla conmut
   *************************************************************************/
   PROCEDURE p_anadirconm(
      pedadx NUMBER,
      psexo NUMBER,
      pnacim NUMBER,
      pedady NUMBER,
      psexo2 NUMBER,
      pnacim2 NUMBER,
      ptabla NUMBER,
      pinter NUMBER,
      pinter2 NUMBER,
      periodo NUMBER,
      pgg NUMBER,
      pig NUMBER,
      panyos NUMBER,
      panyos_rent NUMBER,
      var NUMBER DEFAULT 0,
      p_es_mensual NUMBER DEFAULT 1,
      pforpag NUMBER DEFAULT 12,
      pmesini NUMBER DEFAULT 1,
      preemb NUMBER DEFAULT 0,
      psobremort NUMBER DEFAULT 0,
      pesahorr NUMBER DEFAULT 1,
      prevers NUMBER DEFAULT 0,
      ptabprogresiones VARCHAR2 DEFAULT NULL,
      ptabpagasextras VARCHAR2 DEFAULT NULL,
      pmesefecto NUMBER DEFAULT NULL,
      pesrevision NUMBER,
      ptipoact NUMBER,
      pincrementoriesg NUMBER,
      panyostab NUMBER,
      ptipoextrap NUMBER,
      tab_conmu t_conmutador) IS
      registro       vparametros;
   BEGIN
      registro.pedadx := pedadx;
      registro.psexo := psexo;
      registro.pnacim := pnacim;
      registro.pedady := pedady;
      registro.psexo2 := psexo2;
      registro.pnacim2 := pnacim2;
      registro.ptabla := ptabla;
      registro.pinter := pinter;
      registro.pinter2 := pinter2;
      registro.periodo := periodo;
      registro.pgg := pgg;
      registro.pig := pig;
      registro.panyos := panyos;
      registro.panyos_rent := panyos_rent;
      registro.var := var;
      registro.p_es_mensual := p_es_mensual;
      registro.pforpag := pforpag;
      registro.pmesini := pmesini;
      registro.preemb := preemb;
      registro.psobremort := psobremort;
      registro.pesahorr := pesahorr;
      registro.prevers := prevers;
      registro.ptabprogresiones := ptabprogresiones;
      registro.ptabpagasextras := ptabpagasextras;
      registro.pmesefecto := pmesefecto;
      registro.vesrevision := pesrevision;
      registro.vtipoact := ptipoact;
      registro.vincrementoriesg := pincrementoriesg;
      registro.vanyostab := panyostab;
      registro.vtipoextrap := ptipoextrap;
      registro.tab_conmu := tab_conmu;

      IF reg.COUNT < vmaxsize THEN
         reg(reg.COUNT + 1) := registro;
      ELSE
         reg(MOD(indice, vmaxsize) + 1) := registro;
         indice := indice + 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CONMUTADORS.f_AnadirConm', 1, 'OTHERS',
                     SUBSTR(SQLERRM, 1, 2500));
   END p_anadirconm;

/*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      obtenerCadena:Obtiene la progresión para un mes o año
      ptabprogresiones in : Tabla con progresiones separadas por comas
      nduraci  in : Posición que se busca
      p_es_mensua in  : Indica si viene en meses o años
      return : La progresión.
********************************************************************/
   FUNCTION obtenercadena(ptabprogresiones VARCHAR2, nduraci NUMBER, p_es_mensual NUMBER)
      RETURN NUMBER IS
      vposini        NUMBER;
      vposfin        NUMBER;
      pduraci        NUMBER;
      valorprog      VARCHAR2(10);
      -- Bug 10336 - 10/06/2009 - JRH  - Rentas irregulares
      valorprogfin   VARCHAR2(10);
   -- fi Bug 10336 - 10/06/2009 - JRH
   BEGIN
      IF ptabprogresiones IS NULL THEN
         RETURN 0;
      END IF;

      IF p_es_mensual <> 0 THEN
         pduraci := ROUND(nduraci * 12, 0);
      ELSE
         pduraci := nduraci;
      END IF;

      IF pduraci = 0 THEN
         vposini := 0;
      ELSE
         vposini := INSTR(ptabprogresiones, ',', 1, pduraci);
         vposini := NVL(vposini, LENGTH(ptabprogresiones) - 1);

         IF vposini = 0
            AND INSTR(ptabprogresiones, ',', 1, 1) > 0 THEN
            vposini := LENGTH(ptabprogresiones) - 1;
         ELSIF vposini = 0
               AND INSTR(ptabprogresiones, ',', 1, 1) <= 0 THEN
            RETURN 0;
         END IF;

         IF INSTR(ptabprogresiones, ',', 1, pduraci) <= 0 THEN
            RETURN 0;
         END IF;
      END IF;

      vposfin := INSTR(ptabprogresiones, ',', 1, pduraci + 1);
      vposfin := NVL(vposfin, LENGTH(ptabprogresiones));

      IF vposfin = 0 THEN
         vposfin := LENGTH(ptabprogresiones) + 1;
      END IF;

      valorprog := SUBSTR(ptabprogresiones, vposini + 1, vposfin - vposini - 1);
      -- Bug 10336 - 10/06/2009 - JRH  - Rentas irregulares
      valorprogfin := NVL((valorprog), 0);
      -- fi Bug 10336 - 10/06/2009 - JRH
      RETURN TO_NUMBER(REPLACE(valorprogfin, '.', ','));
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CONMUTADORS.ff_progresionnat Irregular', 2,
                     SQLERRM, 'v');
         RAISE;
   END obtenercadena;

/*************************************************************************
     Calcula la progresión a una fecha (nduraci)
      psesion in : Sesion
      gg in : prog. geom.
      ig in : prog. lineal.
      nduraci  in : duración (en años)
      fpagprima in forma de pago
      mesini  in primer mes del contrato
      p_es_mensual in tratamiento mensual en lugar de anual si es <>0
      esahorr in    1 si es ahorro (las rentas pueden cambiar la forma de calcular la progresión para el primer mes)
   *************************************************************************/
   FUNCTION ff_progresionnat(
      psesion IN NUMBER,
      gg IN NUMBER,
      ig IN NUMBER,
      nduraci IN NUMBER,
      fpagprima IN NUMBER,
      mesini IN NUMBER DEFAULT 0,
      p_es_mensual IN NUMBER DEFAULT 0,
      esahorr NUMBER DEFAULT 1,
      ptabprogresiones VARCHAR2 DEFAULT NULL,
      pesrevision NUMBER)
      RETURN NUMBER IS
      valor          NUMBER := 0;
      prog           NUMBER;
      prog2          NUMBER;
      pduraci        NUMBER;
      primeravez     BOOLEAN := TRUE;
      --fpagprima      NUMBER;
      v_cgarant      NUMBER;   --JRH IMP Temporal
   BEGIN
      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
         --fpagprima := NVL(pac_gfi.f_sgt_parms('FPAGPRIMA', psesion), 12);

      --IF fpagprima = 0 THEN
      --   fpagprima := 1;
      --END IF;
       -- BUG 9172 - 04/2009 - JRH  - CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      IF ptabprogresiones IS NOT NULL THEN   --JRH Hay pagos irregulares
         RETURN(obtenercadena(ptabprogresiones, nduraci, p_es_mensual));
      END IF;

      -- Fi BUG 9172

      --dbms_output.put_line('nduraci:'||nduraci);
      IF p_es_mensual <> 0 THEN
         pduraci := ROUND(nduraci * 12, 0);

         IF MOD(pduraci,(12 / fpagprima)) <> 0 THEN
            RETURN 0;
         END IF;

         IF NVL(gg, 0) = 0
            AND NVL(ig, 0) = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               IF pduraci = 0 THEN
                  -- BUG 13969- 03/2010 - JRH  - Caso de revisión
                  IF pesrevision = 1 THEN
                     RETURN 1;
                  ELSE
                     RETURN 0;
                  END IF;
               -- Fi BUG 13969- 03/2010 - JRH
               ELSE
                  RETURN 1;
               END IF;
            ELSE
               RETURN 1;
            END IF;
         END IF;

         primeravez := FALSE;
         prog := POWER((1 + gg / 100), FLOOR((mesini + pduraci - 1) / 12))
                 + FLOOR(((mesini + pduraci - 1) / 12)) *(ig / 100);
         prog2 := prog;

          --dbms_output.put_line('prog:'||prog);
         -- END IF;
         IF pduraci = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               prog := 0;

               IF pesrevision = 1 THEN
                  prog := prog2;
               END IF;
            ELSE
               prog := prog2;
            END IF;
         ELSE
            prog := prog2;
         END IF;
      ELSE
         pduraci := nduraci;

         IF NVL(gg, 0) = 0
            AND NVL(ig, 0) = 0 THEN
            IF esahorr <> 1 THEN   --En rentas no incluimos el inicial
               IF pduraci = 0 THEN
                  IF pesrevision = 1 THEN   --En la revisión si
                     RETURN 1;
                  ELSE
                     RETURN 0;
                  END IF;
               ELSE
                  RETURN 1;
               END IF;
            ELSE
               RETURN 1;
            END IF;
         END IF;

         prog := POWER((1 + gg / 100), pduraci) + (pduraci) *(ig / 100);
      -- END LOOP;
      END IF;

      -- dbms_output.put_line('prog3:'||prog);
      RETURN prog;
   END ff_progresionnat;

/*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      Invierte el vector de conmutadores y rellena algunos que pueden faltar
      vtConmut El vector de entrada
      El vector convertido.
   *************************************************************************/
   FUNCTION invertir(vtconmut t_conmutador)
      RETURN t_conmutador IS
      vconmut2       ob_conmutador;
      vconmut3       ob_conmutador;
      vconmut21      ob_conmutador;
      v_mx0          NUMBER;
      v_cx0          NUMBER;
      v_my0          NUMBER;
      v_cy0          NUMBER;
      v_ux0          NUMBER;
      v_uy0          NUMBER;
      v_nx0          NUMBER;
      v_ny0          NUMBER;
      v_nnx0         NUMBER;
      v_nny0         NUMBER;
      v_sx0          NUMBER;
      v_sy0          NUMBER;
      v_rx0          NUMBER;
      v_ry0          NUMBER;
      vtconmut2      t_conmutador;
      progacumesp    NUMBER;
      vmx1           NUMBER;
   BEGIN
      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
      vtconmut2 := t_conmutador();
      vconmut2 := vtconmut(vtconmut.LAST);
      v_mx0 := vconmut2.vmx;
      v_cx0 := vconmut2.vcx;
      v_my0 := vconmut2.vmy;
      v_cy0 := vconmut2.vcy;
      v_ux0 := vconmut2.vux;
      v_uy0 := vconmut2.vuy;
      v_nx0 := vconmut2.vnx;
      v_ny0 := vconmut2.vny;
      v_nnx0 := vconmut2.vnnx;
      v_nny0 := vconmut2.vnny;
      v_sx0 := vconmut2.vsx0;
      v_sy0 := vconmut2.vsy0;
      v_rx0 := vconmut2.vrx0;
      v_ry0 := vconmut2.vry0;

      --dbms_output.put_line('A:');
      FOR j IN vtconmut.FIRST .. vtconmut.LAST LOOP
         --dbms_output.put_line('1:'||TO_CHAR(vduraci+1-j));
         --dbms_output.put_line('1:'||TO_CHAR(j));
         IF vtconmut.EXISTS(j) THEN
            vconmut2 := vtconmut(vtconmut.LAST + 1 - j);

            /*
            --jrh antes
            if vtConmut.exists(vtConmut.LAST+1-j-1) then
               vConmut21:=vtConmut(vtConmut.LAST+1-j-1);
               vmx1:=vConmut21.vmx;
            else
               vmx1:=0;
            end if;
            */
            IF vtconmut.EXISTS(vtconmut.LAST + 1 - j) THEN
               vconmut21 := vtconmut(vtconmut.LAST + 1 - j);
               vmx1 := vconmut21.vmx;
            ELSE
               vmx1 := 0;
            END IF;

            IF vconmut2.vanyos IS NOT NULL THEN
               IF vtconmut.EXISTS(vtconmut.LAST - vconmut2.vanyos + j + 1) THEN
                  vconmut3 := vtconmut(vtconmut.LAST - vconmut2.vanyos + j + 1);
                  progacumesp := vconmut3.vprogacum;
               ELSE
                  progacumesp := 0;
                  vconmut3 := vtconmut(j);
               END IF;
            ELSE
               progacumesp := 0;
               vconmut3 := vtconmut(j);
            END IF;

            /*
            --antes
            if vConmut2.vanyos is not null then
               if   vtConmut.exists(vtConmut.LAST-vConmut2.vanyos+j)  then
                   vConmut3:=vtConmut(vtConmut.LAST-vConmut2.vanyos+j);
                   progAcumesp:=vConmut3.vprogAcum;
               else
                   progAcumesp:=0;
                   vConmut3:=vtConmut(j);
               end if;
            else
               progAcumesp:=0;
               vConmut3:=vtConmut(j);
            end if;




            */
            vconmut2.vmx0 := v_mx0;
            vconmut2.vmy0 := v_my0;
            vconmut2.vcx0 := v_cx0;
            vconmut2.vcy0 := v_cy0;
            vconmut2.vux0 := v_ux0;
            vconmut2.vuy0 := v_uy0;
            vconmut2.vnx0 := v_nx0;
            vconmut2.vny0 := v_ny0;
            vconmut2.vnnx0 := v_nnx0;
            vconmut2.vnny0 := v_nny0;
            vconmut2.vsx0 := v_sx0;
            vconmut2.vsy0 := v_sy0;
            vconmut2.vrx0 := v_rx0;
            vconmut2.vry0 := v_ry0;

            IF NVL(vconmut2.vdx0, 0) <> 0 THEN
               vconmut2.l_nvaxpp := ((vconmut2.vcxn -(vconmut2.vmx0 - vmx1))) / vconmut2.vdx0;
               vconmut2.l_nvaxpp := vconmut2.l_nvaxpp * progacumesp;
            ELSE
               vconmut2.l_nvaxpp := 0;
            END IF;

            IF NVL(vconmut2.vdx, 0) <> 0 THEN
               vconmut2.axtkpu := (vconmut2.vmx0 - vconmut2.vmxn) / vconmut2.vdx;   --Cambiado vMxn1 por vMxn
            ELSE
               vconmut2.axtkpu := 0;
            END IF;

            vtconmut2.EXTEND;
            vtconmut2(vtconmut2.LAST) := vconmut2;
         END IF;
      END LOOP;

      --dbms_output.put_line('A:'||vtConmut2.last);
      RETURN vtconmut2;
   END invertir;

/*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      Busca en tabla de mortalidad
      psesion in : Sesion
      ptabla in Tabla
      vEdadActx in edad primera cabeza
      psexo   in sexo primera cabeza
      pnacim   in año nacimiento primera cabeza
      vEdadActy   in edad segunda cabeza (puede ser nulo)
      psexo2    in sexo segunda cabeza (puede ser nulo)
      pnacim2    in año nacimiento segunda  cabeza (puede ser nulo)
      var   in factor corrección
      p_es_mensual in tramtamiento mensual si <>0
      vlxi out  las lx's
      vlyi out  las lx's
   *************************************************************************/
   PROCEDURE accesotablas(
      psesion NUMBER,
      ptabla NUMBER,
      vedadactx NUMBER,
      psexo NUMBER,
      pnacim NUMBER,
      vedadacty NUMBER,
      psexo2 NUMBER,
      pnacim2 NUMBER,
      var NUMBER,
      p_es_mensual NUMBER,
      vlxi OUT NUMBER,
      vlyi OUT NUMBER) IS
   BEGIN
      IF ptabla = 0 THEN
         vlxi := 1;

         IF NVL(psexo2, 0) <> 0 THEN
            vlyi := 1;
         ELSE
            vlyi := 0;
         END IF;

         RETURN;
      END IF;

      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
      IF ptabla = 6 THEN
         vlxi := pac_frm_actuarial.f_morta_mes(psesion, ptabla, 12 *(vedadactx - var), psexo,
                                               pnacim);

         IF NVL(psexo2, 0) <> 0 THEN
            vlyi := pac_frm_actuarial.f_morta_mes(psesion, ptabla, 12 *(vedadacty - var),
                                                  psexo2, pnacim2);
         ELSE
            vlyi := 0;
         END IF;
      ELSE
         vlxi := pac_frm_actuarial.ff_lx(psesion, ptabla, vedadactx - var, psexo,
                                         p_es_mensual);

         IF NVL(psexo2, 0) <> 0 THEN
            vlyi := pac_frm_actuarial.ff_lx(psesion, ptabla, vedadacty - var, psexo2,
                                            p_es_mensual);
         ELSE
            vlyi := 0;
         END IF;
      END IF;

      IF vlxi < 0 THEN
         vlxi := 0;
      END IF;

      IF vlyi < 0 THEN
         vlyi := 0;
      END IF;

      -- BUG 10228 - 05/2009 - JRH  - CRE - Adaptar el PAC_CONMUTADORS per a que pugui treballar amb sobremortalitats
      IF vmaxvalortabla IS NULL THEN
         RETURN;   --La primera vez devuelve el malor máximo sin normalizar.
      END IF;

      IF vedadactx < 1 THEN
         vlxi := NVL(vmaxvalortabla, 100000);
      END IF;

      IF vedadacty < 1 THEN
         vlyi := NVL(vmaxvalortabla, 100000);
      END IF;

      vlxi := vlxi / NVL(vmaxvalortabla, 100000);
      vlyi := vlyi / NVL(vmaxvalortabla, 100000);

      --fi bug
      IF (vlxi IS NULL)
         OR(vlyi IS NULL) THEN
         --dbms_output.put_line('vEdadActy:'||vEdadActy||'psexo2:'||psexo2||'vlyi:'||vlyi);
         --RAISE erroracctab;
         vlxi := NVL(vlxi, 0);
         vlyi := NVL(vlyi, 0);
         p_tab_error(f_sysdate, f_user, 'PAC_CONMUTADORS', 3, 'accesotablas', 'Valores nulos');
      END IF;
   END accesotablas;

/*************************************************************************
      -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
      Calcula tabla de conmutadores.
      psesion in : Sesión
      pedadx  in : Edad primera cabeza (Siempre en años)
      psexo in  : Sexo primera cabeza
      pnacim in : Año nacimiento primera cabeza (Siempre en años)
      pedady in : Edad segunda cabeza (Siempre en años) (Puede ser nulo)
      psexo2 in : Sexo segunda cabeza (Puede ser nulo)
      pnacim2 in : Año nacimiento segunda cabeza (Siempre en años) (Puede ser nulo)
      ptabla in : Tabla mortalidad (0 si no hay riesgo)
      pinter in : Interes inicial
      pinter2 in : Segundo interés (Puede ser nulo)
      periodo  in : Años del periodo para el cambio interés (Puede ser nulo)
      pgg in : Progresión geom.
      pig in : Progre. lineal
      panyos in : Años hasta vencimiento (En pólizas vitalicias poner valor elevado (inferior a 125-edad))
      panyos_rent in  Años hasta meritamiento para renta (En pólizas vitalicias poner valor elevado (inferior a 125-edad))
      var number in : Factor correción en años
      p_es_mensual in : Tratamiento mensual en lugar de anual (si <>0)
      pforpag number in : Forma de pago (Ahorro o renta).
      pmesini number in : Mes inicio de la póliza (1 si la póliza renueva de forma contractual).
      preemb number in : Factor de reembolso del capital.
      psobremort number in : Factor de sobremortalidad.
      pesahorr number in : Si es póliza de ahorro (Hay casos en rentas que se considera la progresión 0 hasta el segundo mes)
      prevers number in : % Revers.
      ptabprogresiones  varchar2 in: Vector (string separado por comas) con la progresión de cada mes de la póliza (rentas irregulares).
      ptabpagasextras varchar2 in: Pagas extras de la póliza según SEGUROS_REN
      pmesefecto number in : Mes en que comienza la póliza (número). Nos sireve para las pagas extras.
      return             : La tabla
   *************************************************************************/
   FUNCTION calculaconmu(
      psesion NUMBER,
      pedadx NUMBER,
      psexo NUMBER,
      pnacim NUMBER,
      pedady NUMBER,
      psexo2 NUMBER,
      pnacim2 NUMBER,
      ptabla NUMBER,
      pinter NUMBER,
      pinter2 NUMBER,
      periodo NUMBER,
      pgg NUMBER,
      pig NUMBER,
      panyos NUMBER,
      panyos_rent NUMBER,
      var NUMBER DEFAULT 0,
      p_es_mensual NUMBER DEFAULT 1,
      pforpag NUMBER DEFAULT 12,
      pmesini NUMBER DEFAULT 1,
      preemb NUMBER DEFAULT 0,
      psobremort NUMBER DEFAULT 0,
      pesahorr NUMBER DEFAULT 1,
      prevers NUMBER DEFAULT 0,
      -- BUG 9172 - 04/2009 - JRH  - CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      ptabprogresiones VARCHAR2 DEFAULT NULL,
      ptabpagasextras VARCHAR2 DEFAULT NULL,
      pmesefecto NUMBER DEFAULT NULL,
      -- fi bug
      -- BUG 11268 - 12/2009 - JRH  - Bug-0011268: CEM - Migración de los productos ahorro
      pesrevision NUMBER DEFAULT 0,
      ptipoact NUMBER DEFAULT 0,
      pincrementoriesg NUMBER DEFAULT 0.5,
      panyostab NUMBER DEFAULT 125,
      ptipoextrap NUMBER
            DEFAULT 0   --JRH Tipo Extraprima 0 Porcentage 1 Suma a qx 2 Valor directo qx
                     -- Fi BUG 11268 - 12/2009 - JRH
   )
      RETURN t_conmutador IS
      a              NUMBER;
      vfactor        NUMBER;
      --Edades
      vedadactx      NUMBER;
      vedadacty      NUMBER;
      vedadactx1     NUMBER;
      vedadacty1     NUMBER;
      --tablas
      vlxi           NUMBER;
      vlxi1          NUMBER;
      vlyi           NUMBER;
      vlyi1          NUMBER;
      vprimeravez    BOOLEAN := TRUE;
      vlxiini        NUMBER;
      vlyiini        NUMBER;
      vlxi1_ant      NUMBER := NULL;
      vlyi1_ant      NUMBER := NULL;
      --Progresión
      vprog          NUMBER;
      vprogacum      NUMBER;
      vduraci        NUMBER;
      vfactreemb     NUMBER;
      i              NUMBER;
      --Conmutadores
      vqx            NUMBER;
      vqy            NUMBER;
      vdx            NUMBER;
      vdy            NUMBER;
      vdxy           NUMBER;
      vcx            NUMBER;
      vcy            NUMBER;
      vcxy           NUMBER;
      vacumdx        NUMBER := 0;
      vacumdy        NUMBER := 0;
      vacumdxy       NUMBER := 0;
      vacumdx2       NUMBER := 0;
      vacumdy2       NUMBER := 0;
      vacumdxy2      NUMBER := 0;
      vnx            NUMBER;
      vny            NUMBER;
      vnxy           NUMBER;
      vnnx           NUMBER;
      vnny           NUMBER;
      vnnxy          NUMBER;
      vacumcx        NUMBER := 0;
      vacumcy        NUMBER := 0;
      vacumcxy       NUMBER := 0;
      vmx            NUMBER;
      vmy            NUMBER;
      vmxy           NUMBER;
      vacumcx2       NUMBER := 0;
      vacumcy2       NUMBER := 0;
      vacumcxy2      NUMBER := 0;
      vux            NUMBER;
      vuy            NUMBER;
      vuxy           NUMBER;
      vjx            NUMBER;
      vjy            NUMBER;
      vjxy           NUMBER;
      vnx0           NUMBER;
      vny0           NUMBER;
      vnxy0          NUMBER;
      vux0           NUMBER;
      vuy0           NUMBER;
      vuxy0          NUMBER;
      vmx0           NUMBER;
      vmy0           NUMBER;
      vmxy0          NUMBER;
      vdx0           NUMBER;
      vdy0           NUMBER;
      vdxy0          NUMBER;
      vnnx0          NUMBER;
      vnny0          NUMBER;
      vnnxy0         NUMBER;
      vnnxn          NUMBER;
      vnnyn          NUMBER;
      vnnxyn         NUMBER;
      vnxn           NUMBER;
      vnyn           NUMBER;
      vnxyn          NUMBER;
      vuxn           NUMBER;
      vuyn           NUMBER;
      vuxyn          NUMBER;
      vmxn           NUMBER;
      vmyn           NUMBER;
      vmxyn          NUMBER;
      vdxn           NUMBER;
      vdyn           NUMBER;
      vdxyn          NUMBER;
      vnnxn1         NUMBER;
      vnnyn1         NUMBER;
      vnnxyn1        NUMBER;
      vnxn1          NUMBER;
      vnyn1          NUMBER;
      vnxyn1         NUMBER;
      vuxn1          NUMBER;
      vuyn1          NUMBER;
      vuxyn1         NUMBER;
      vmxn1          NUMBER;
      vmyn1          NUMBER;
      vmxyn1         NUMBER;
      vdxn1          NUMBER;
      vdyn1          NUMBER;
      vdxyn1         NUMBER;
      vcxn           NUMBER;
      vcyn           NUMBER;
      vcxyn          NUMBER;
      vcxn1          NUMBER;
      vcyn1          NUMBER;
      vcxyn1         NUMBER;
      vexn1          NUMBER;
      veyn1          NUMBER;
      vmxnr1         NUMBER;
      vmynr1         NUMBER;
      vmxynr1        NUMBER;
      vaxnpp         NUMBER;
      n_vaxpp        NUMBER;
      l_nvaxpp       NUMBER;
      axtkpp         NUMBER;
      axtnkpp        NUMBER;
      vaxnpu         NUMBER;
      n_vaxpu        NUMBER;
      l_nvaxpu       NUMBER;
      axtkpu         NUMBER;
      axtnkpu        NUMBER;
      vsobremort     NUMBER;
      --Interes
      vfacint1       NUMBER;
      vfacint2       NUMBER;
      vinter         NUMBER;
      vanyos         NUMBER;
      vanyos_rent    NUMBER;
      factreemb      NUMBER;
      vedadini       NUMBER;
      vacumnx        NUMBER := 0;
      vacumny        NUMBER := 0;
      vacumnxy       NUMBER := 0;
      -- Bug 10228 - JRH - 01/05/2009 - Nueva Función : Bug Adaptar el pac_conmutadors_2 per a que pugui treballar amb sobremortalitats: CRE055 - Rentas temporales
      vsx            NUMBER;
      vsy            NUMBER;
      vsxy           NUMBER;
      vsx0           NUMBER;
      vsy0           NUMBER;
      vsxn           NUMBER;
      vsyn           NUMBER;
      vsxyn          NUMBER;
      vsxn1          NUMBER;
      vsyn1          NUMBER;
      vsxyn1         NUMBER;
      vnxnr1         NUMBER;
      vnynr1         NUMBER;
      vnxynr1        NUMBER;
      vuxnr1         NUMBER;
      vuynr1         NUMBER;
      vuxynr1        NUMBER;
      vsxnr1         NUMBER;
      vsynr1         NUMBER;
      vsxynr1        NUMBER;
      vcxnr1         NUMBER;
      vcynr1         NUMBER;
      vcxynr1        NUMBER;
      vdxnr1         NUMBER;
      vdynr1         NUMBER;
      vdxynr1        NUMBER;
      vpaso          NUMBER := 0;
      vrx            NUMBER;
      vry            NUMBER;
      vrxy           NUMBER;
      vrx0           NUMBER;
      vry0           NUMBER;
      vrxn           NUMBER;
      vryn           NUMBER;
      vrxyn          NUMBER;
      vrxn1          NUMBER;
      vryn1          NUMBER;
      vrxyn1         NUMBER;
      vrxnr1         NUMBER;
      vrynr1         NUMBER;
      vrxynr1        NUMBER;
      vacummx        NUMBER := 0;
      vacummy        NUMBER := 0;
      vacummxy       NUMBER := 0;

      TYPE rt_progs IS RECORD(
         prog           NUMBER,
         progacum       NUMBER
      );

      TYPE t_progs IS TABLE OF rt_progs
         INDEX BY BINARY_INTEGER;

      TYPE rt_lx IS RECORD(
         vlxi           NUMBER,
         vlyi           NUMBER,
         vlxi1          NUMBER,
         vlyi1          NUMBER,
         vqx            NUMBER,
         vqy            NUMBER
      );

      TYPE trt_lx IS TABLE OF rt_lx
         INDEX BY BINARY_INTEGER;

      tabprogs       t_progs;
      tablx          trt_lx;
      vtconmut       t_conmutador;
      vconmut        ob_conmutador;
      vtconmut2      t_conmutador;
      vedadactx2     NUMBER;
      vedadacty2     NUMBER;
      vanyosmaxtab   NUMBER;
   BEGIN
      vmaxvalortabla := NULL;
      vmaxvalortabla1 := NULL;   --Importante

      -- BUG 9889 - 04/2009 - JRH  - Cuadre de los datos del cierre de ABRIL
      IF pedadx IS NULL THEN
         vpaso := 50;
         RAISE errorparam;
      END IF;

      IF psexo IS NULL THEN
         vpaso := 51;
         RAISE errorparam;
      END IF;

      IF pnacim IS NULL THEN
         vpaso := 52;
         RAISE errorparam;
      END IF;

      IF psexo2 IS NOT NULL THEN
         IF pedady IS NULL
            OR pnacim2 IS NULL THEN
            vpaso := 53;
            RAISE errorparam;
         END IF;
      END IF;

      IF ptabla IS NULL THEN
         vpaso := 54;
         RAISE errorparam;
      END IF;

      IF ptabla IS NULL THEN
         vpaso := 55;
         RAISE errorparam;
      END IF;

      IF pinter IS NULL THEN
         vpaso := 56;
         RAISE errorparam;
      END IF;

      IF pinter2 IS NOT NULL THEN
         IF periodo IS NULL THEN
            vpaso := 57;
            RAISE errorparam;
         END IF;
      END IF;

      IF pgg IS NULL
         OR pig IS NULL THEN
         vpaso := 58;
         RAISE errorparam;
      END IF;

      IF panyos IS NULL THEN
         vpaso := 59;
         RAISE errorparam;
      END IF;

      IF pmesini IS NULL THEN
         vpaso := 60;
         RAISE errorparam;
      END IF;

      IF ptabpagasextras IS NOT NULL THEN
         IF pmesefecto IS NULL THEN
            vpaso := 62;
            RAISE errorparam;
         END IF;
      END IF;

      IF var IS NULL THEN
         vpaso := 63;
         RAISE errorparam;
      END IF;

      IF p_es_mensual IS NULL THEN
         vpaso := 64;
         RAISE errorparam;
      END IF;

      IF pforpag IS NULL THEN
         vpaso := 65;
         RAISE errorparam;
      END IF;

      IF pmesini IS NULL THEN
         vpaso := 67;
         RAISE errorparam;
      END IF;

      IF preemb IS NULL THEN
         vpaso := 68;
         RAISE errorparam;
      END IF;

      IF psobremort IS NULL THEN
         vpaso := 69;
         RAISE errorparam;
      END IF;

      IF prevers IS NULL THEN
         vpaso := 69;
         RAISE errorparam;
      END IF;

      --DBMS_OUTPUT.put_line('_________________________panyostab:' || panyostab);

      -- BUG 13969- 04/2010 - JRH  - Valor tabla
      IF panyostab = 0 THEN
--         IF ptabla <> 6 THEN
--            BEGIN
--               SELECT MAX(nedad)
--                 INTO vanyosmaxtab
--                 FROM mortalidad
--                WHERE ctabla = ptabla;
--            EXCEPTION
--               WHEN NO_DATA_FOUND THEN
--                  vanyosmaxtab := 126;
--            END;
--         ELSE
--            BEGIN
--               SELECT MAX(nedad)
--                 INTO vanyosmaxtab
--                 FROM mortalidad
--                WHERE ctabla = ptabla;

         --               vanyosmaxtab := TRUNC(vanyosmaxtab / 12);
--            EXCEPTION
--               WHEN NO_DATA_FOUND THEN
--                  vanyosmaxtab := 126;
--            END;
--         END IF;
         vanyosmaxtab := f_anyos_maxtabla(ptabla);
         vanyosmaxtab := vanyosmaxtab + 1;
      ELSE
         vanyosmaxtab := panyostab;
      END IF;

-- Fi BUG 13969- 03/2010 - JRH  - Caso de revisión

      --JRH Acceso a cache
      vtconmut2 := f_buscarconm(pedadx, psexo, pnacim, pedady, psexo2, pnacim2, ptabla, pinter,
                                pinter2, periodo, pgg, pig, panyos, panyos_rent, var,
                                p_es_mensual, pforpag, pmesini, preemb, psobremort, pesahorr,
                                prevers, ptabprogresiones, ptabpagasextras, pmesefecto,
                                pesrevision, ptipoact, pincrementoriesg, panyostab,
                                ptipoextrap);

      IF vtconmut2 IS NOT NULL THEN
         --dbms_output.put_line('________________________tabla:'||ptabla||' cuenta:'||reg.count );
         RETURN vtconmut2;
      END IF;

      IF p_es_mensual <> 0 THEN   --Para convertir todo lo que nos viene en años a meses
         vfactor := 12;
      ELSE
         vfactor := 1;
      END IF;

      vpaso := 1;
      vsobremort := NVL(psobremort, 0);
      vduraci := ROUND((vanyosmaxtab - pedadx) * vfactor, 0);

      IF NVL(pedady, 1000) < pedadx THEN
         vduraci := ROUND((vanyosmaxtab - pedady) * vfactor, 0);
      END IF;

      vpaso := 2;
      i := vduraci;
      vanyos := ROUND(panyos * vfactor);
      vanyos_rent := ROUND(panyos_rent * vfactor);
      vpaso := 3;

      IF pesahorr = 1 THEN
         vedadini := 0;
      ELSE
         vedadini := pedadx;
      END IF;

      vpaso := 4;
      -- BUG 10228 - 05/2009 - JRH  - CRE - Adaptar el pac_conmutadors_2 per a que pugui treballar amb sobremortalitats

      --Buscamos valor maximo de la tabla
      accesotablas(psesion, ptabla, 0, psexo, pnacim, NULL, NULL, NULL, 0, p_es_mensual,
                   vmaxvalortabla, vmaxvalortabla1);

      DECLARE
         vedad          NUMBER;
         vlxi           NUMBER;
         vlyi           NUMBER;
         vlxi1          NUMBER;
         vlyi1          NUMBER;
         vlxi1_ant      NUMBER;
         vlyi1_ant      NUMBER;
         vqx            NUMBER;
         vqy            NUMBER;
         vlxin          NUMBER;
         vlyin          NUMBER;
         vqx_ant        NUMBER;
         vqy_ant        NUMBER;
         vedad1         NUMBER;
         vsomonolin     NUMBER;
      --JRH CALCULO DE LAS LX y QX iniciales , para aplicar sobremortalidad si fuera necesario.
      BEGIN
         vpaso := 5;

         FOR i IN 0 .. vanyosmaxtab * vfactor LOOP
            vedad :=(i / vfactor);
            vpaso := 6;
            vedad1 :=((i + 1) / vfactor);

            IF vlxi1_ant IS NULL THEN
               vpaso := 65;
               accesotablas(psesion, ptabla, vedad, psexo, pnacim, vedad, psexo2, pnacim2,
                            var, p_es_mensual, vlxi, vlyi);
            ELSE
               vlxi := vlxi1_ant;
               vlyi := vlyi1_ant;
            END IF;

            vpaso := 67;
            accesotablas(psesion, ptabla, vedad1, psexo, pnacim, vedad1, psexo2, pnacim2, var,
                         p_es_mensual, vlxi1, vlyi1);
            vlxi1_ant := vlxi1;
            vlyi1_ant := vlyi1;

            IF ptipoextrap = 1 THEN
               vqx := vqx + psobremort;
               vqy := vqy + psobremort;
            ELSIF ptipoextrap = 2 THEN
               vqx := 0 + psobremort;
               vqy := 0 + psobremort;
            ELSE
               --BUG 28033- INICIO - DCT - 02/09/2013 - LCOL_MILL - Ajustar la sobremortalitat
               vsomonolin :=
                  NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                    'SOMONOLIN'),
                      0);

               IF vsomonolin = 0 THEN
                  IF NVL(vlxi, 0) <> 0 THEN
                     vqx := (1 +(psobremort / 100)) *((vlxi - vlxi1) / vlxi);
                  ELSE
                     vqx := 0;
                  END IF;

                  IF NVL(vlyi, 0) <> 0 THEN
                     vqy := (1 +(psobremort / 100)) *((vlyi - vlyi1) / vlyi);
                  ELSE
                     vqy := 0;
                  END IF;
               ELSE
                  IF NVL(vlxi, 0) <> 0 THEN
                     vqx := 1 - POWER((1 -((vlxi - vlxi1) / vlxi)),(100 + psobremort) / 100);
                  ELSE
                     vqx := 0;
                  END IF;

                  IF NVL(vlyi, 0) <> 0 THEN
                     vqy := 1 - POWER((1 -((vlyi - vlyi1) / vlyi)),(100 + psobremort) / 100);
                  ELSE
                     vqy := 0;
                  END IF;
               END IF;
            END IF;

            /*IF NVL(vlxi, 0) <> 0 THEN
               -- Bug 26947/0144288 - APD - 27/05/2013
               --vqx := (1 +(psobremort / 100)) *((vlxi - vlxi1) / vlxi);
               vqx := 1 - POWER((1 -((vlxi - vlxi1) / vlxi)), psobremort / 100);
            -- fin Bug 26947/0144288 - APD - 27/05/2013
            ELSE
               vqx := 0;
            END IF;

            IF NVL(vlyi, 0) <> 0 THEN
               -- Bug 26947/0144288 - APD - 27/05/2013
               --vqy := (1 +(psobremort / 100)) *((vlyi - vlyi1) / vlyi);
               vqy := 1 - POWER((1 -((vlyi - vlyi1) / vlyi)), psobremort / 100);
            -- fin Bug 26947/0144288 - APD - 27/05/2013
            ELSE
               vqy := 0;
            END IF;*/
            --BUG 28033- FIN - DCT - 02/09/2013 - LCOL_MILL - Ajusatr la sobremortalitat
            vpaso := 7;

            --las nuevas lx a partir del aqx con la sobremortalidad son
            IF i = 0 THEN
               vlxin := 1;
               vlyin := 1;
            ELSE
               vlxin := vlxin *(1 - vqx_ant);
               vlyin := vlyin *(1 - vqy_ant);
            END IF;

--dbms_output.put_line('El primer i:'||i||'   vlxi:'||vlxin||'   vqx:'||vqx);
            tablx(i).vlxi := vlxin;
            tablx(i).vlyi := vlyin;
            tablx(i).vqx := vqx;
            tablx(i).vqy := vqy;
            vqx_ant := vqx;
            vqy_ant := vqy;
         --dbms_output.put_line('i:'||i||'   vlxi:'||vlxi||'   vlxi1:'||vlxi1||'   vlxin:'||vlxin||'   qx:'||vqx);
         END LOOP;
      END;

      --Fi bug 10228

      --JRH CALCULO DEL VECTOR DE PROGRESIONES
      DECLARE
         prog           NUMBER;
         valor          NUMBER := 0;
         vlxi0          NUMBER;
         vlyi0          NUMBER;
         vfacint1       NUMBER;
         vedadactx      NUMBER;
         vedadacty      NUMBER;
         vedadactx1     NUMBER;
         vedadacty1     NUMBER;
      BEGIN
         vedadactx := pedadx;
         vedadacty := pedady;
         vedadactx1 := pedadx +((0 + 1) / vfactor);
         vedadacty1 := pedady +((0 + 1) / vfactor);
         factreemb := POWER(1 +(preemb / 100), 1 / vfactor);   -- BUG 8782 - 02/2009 - JRH  - Factor de reembolso de primas
         vpaso := 8;

         FOR i IN 0 .. vduraci LOOP
            prog := ff_progresionnat(psesion, pgg, pig, i / vfactor, pforpag, pmesini,
                                     p_es_mensual, pesahorr, ptabprogresiones, pesrevision);

            IF ptabpagasextras IS NOT NULL THEN   --JRH Hay pagos irregulares
               IF INSTR('|' || ptabpagasextras || '|',
                        '|' || TO_CHAR(MOD(i + pmesefecto, vfactor)) || '|', 1) > 0 THEN
                  --IF INSTR('|'||ptabpagasextras||'|',  '|'||TO_CHAR(MOD(i + pmesefecto, vfactor)) || '|', 1) > 0 THEN
                     --IF NVL((obtenercadena(ptabprogresiones, i, p_es_mensual)), 0) <> 0 THEN
                  prog := prog + prog;   --Si hay paga extra se duplica la progresión.
               END IF;
            END IF;

            valor := (valor + prog) * factreemb;
            tabprogs(i).prog := prog;
            tabprogs(i).progacum := valor;
            vpaso := 9;

            IF i = 0 THEN   --Aprovechamos para calcular los dx0
               --accesotablas(psesion, ptabla, vedadactx, psexo, pnacim, vedadacty, psexo2,
               --             pnacim2, var, p_es_mensual, vlxi0, vlyi0);
               IF panyostab = 0 THEN
                  DECLARE
                     vedad          NUMBER;
                     residuox       NUMBER;
                     residuoy       NUMBER;
                  BEGIN
                     vedad := ROUND(vfactor * vedadactx);
                     residuox := (vfactor * vedadactx) - vedad;
                     vlxi0 := tablx(ROUND(vfactor * vedadactx)).vlxi *(1 - residuox)
                              + tablx(ROUND(vfactor * vedadactx1)).vlxi * residuox;

                     IF NVL(vedadacty, 0) <> 0 THEN
                        vedad := ROUND(vfactor * vedadacty);
                        residuoy := (vfactor * vedadacty) - vedad;
                        vlyi0 := tablx(ROUND(vfactor * vedadacty)).vlyi *(1 - residuoy)
                                 + tablx(ROUND(vfactor * vedadacty1)).vlxi * residuoy;
                     ELSE
                        vlyi0 := 0;
                     END IF;
                  END;
               ELSE   --Que lo haga tal como en Credit aunque no está bien (estos TRUNCS a veces Oracle no los realiza correctamente)
                  DECLARE
                     vedad          NUMBER;
                     residuox       NUMBER;
                     residuoy       NUMBER;
                  BEGIN
                     vedad := TRUNC(vfactor * vedadactx);
                     residuox := (vfactor * vedadactx) - vedad;
                     vlxi0 := tablx(TRUNC(vfactor * vedadactx)).vlxi *(1 - residuox)
                              + tablx(TRUNC(vfactor * vedadactx1)).vlxi * residuox;

                     IF NVL(vedadacty, 0) <> 0 THEN
                        vedad := TRUNC(vfactor * vedadacty);
                        residuoy := (vfactor * vedadacty) - vedad;
                        vlyi0 := tablx(TRUNC(vfactor * vedadacty)).vlyi *(1 - residuoy)
                                 + tablx(TRUNC(vfactor * vedadacty1)).vlxi * residuoy;
                     ELSE
                        vlyi0 := 0;
                     END IF;
                  END;
               END IF;

               vlxiini := vlxi0;
               vlyiini := vlyi0;
               vinter := pinter;
               vpaso := 10;
               vfacint1 := POWER(vinter, vedadactx - vedadini);
               vdx0 :=(vlxiini * vfacint1);
               vdy0 :=(vlyiini * vfacint1);
               vdxy0 :=(vlxiini * vlyiini * vfacint1);
            END IF;
         END LOOP;
      END;

      i := vduraci;
      vtconmut := t_conmutador();

      --JRH CALACULO DEL RESTO
      LOOP
         -- BUG 10228 - 05/2009 - JRH  - CRE - Adaptar el pac_conmutadors_2 per a que pugui treballar amb sobremortalitats
         vedadactx := pedadx +(i / vfactor);
         vedadacty := pedady +(i / vfactor);
         vedadactx1 := pedadx +((i + 1) / vfactor);
         vedadacty1 := pedady +((i + 1) / vfactor);
         vedadactx2 := pedadx +((i + 2) / vfactor);
         vedadacty2 := pedady +((i + 2) / vfactor);
         vpaso := 10;

         /*IF vlxi1_ant IS NULL THEN
            accesotablas(psesion, ptabla, vedadactx1, psexo, pnacim, vedadacty1, psexo2,
                         pnacim2, var, p_es_mensual, vlxi1, vlyi1);
         ELSE
            vlxi1 := vlxi1_ant;
            vlyi1 := vlyi1_ant;
         END IF;

         accesotablas(psesion, ptabla, vedadactx, psexo, pnacim, vedadacty, psexo2, pnacim2,
                      var, p_es_mensual, vlxi, vlyi);
         vlxi1_ant := vlxi;
         vlyi1_ant := vlyi;*/

         --   dbms_output.put_line('i:'||i||'   vlxi:'||vlxi||'   vlxi1:'||vlxi1);
         -- PRORRATEOS
         IF panyostab = 0 THEN
            DECLARE
               vedad          NUMBER;
               residuox       NUMBER;
               retorno        NUMBER;
               residuoy       NUMBER;
            BEGIN
               BEGIN
                  vedad := ROUND(vfactor * vedadactx);
                  residuox := vfactor * vedadactx - vedad;
                  retorno := tablx(ROUND(vfactor * vedadactx)).vlxi *(1 - residuox)
                             + tablx(ROUND(vfactor * vedadactx1)).vlxi * residuox;
                  vlxi := retorno;
                  retorno := tablx(ROUND(vfactor * vedadactx)).vqx *(1 - residuox)
                             + tablx(ROUND(vfactor * vedadactx1)).vqx * residuox;
                  vqx := retorno;
                  vedad := ROUND(vfactor * vedadactx1);
                  residuox := vfactor * vedadactx1 - vedad;
                  retorno := tablx(ROUND(vfactor * vedadactx1)).vlxi *(1 - residuox)
                             + tablx(ROUND(vfactor * vedadactx2)).vlxi * residuox;
                  vlxi1 := retorno;
               EXCEPTION
                  WHEN OTHERS THEN
                     -- dbms_output.put_line('Error:'||sqlerrm);
                     vlxi := 0;
                     --vlyi := 0;
                     vlxi1 := 0;
                     --vlyi1 := 0;
                     vqx := 0;
               -- vqy := 0;
               END;

               IF NVL(vedadacty, 0) <> 0 THEN
                  vedad := ROUND(vfactor * vedadacty);
                  residuoy := vfactor * vedadacty - vedad;
                  retorno := tablx(ROUND(vfactor * vedadacty)).vlyi *(1 - residuoy)
                             + tablx(ROUND(vfactor * vedadacty1)).vlyi * residuoy;
                  vlyi := retorno;
                  retorno := tablx(ROUND(vfactor * vedadacty)).vqy *(1 - residuoy)
                             + tablx(ROUND(vfactor * vedadacty1)).vqy * residuoy;
                  vqy := retorno;
                  vedad := ROUND(vfactor * vedadacty1);
                  residuoy := vfactor * vedadacty1 - vedad;
                  retorno := tablx(ROUND(vfactor * vedadacty1)).vlyi *(1 - residuoy)
                             + tablx(ROUND(vfactor * vedadacty2)).vlyi * residuoy;
                  vlyi1 := retorno;
               ELSE
                  vlyi := 0;
                  vqy := 0;
                  vlyi1 := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                   -- dbms_output.put_line('Error:'||sqlerrm);
                  -- vlxi := 0;
                  vlyi := 0;
                  -- vlxi1 := 0;
                  vlyi1 := 0;
                  -- vqx := 0;
                  vqy := 0;
            END;
         ELSE   --Que lo haga tal como en Credit aunque no está bien (estos TRUNCS a veces Oracle no los realiza correctamente)
            DECLARE
               vedad          NUMBER;
               residuox       NUMBER;
               retorno        NUMBER;
               residuoy       NUMBER;
            BEGIN
               BEGIN
                  vedad := TRUNC(vfactor * vedadactx);
                  residuox := vfactor * vedadactx - vedad;
                  retorno := tablx(TRUNC(vfactor * vedadactx)).vlxi *(1 - residuox)
                             + tablx(TRUNC(vfactor * vedadactx1)).vlxi * residuox;
                  vlxi := retorno;
                  retorno := tablx(TRUNC(vfactor * vedadactx)).vqx *(1 - residuox)
                             + tablx(TRUNC(vfactor * vedadactx1)).vqx * residuox;
                  vqx := retorno;
                  vedad := TRUNC(vfactor * vedadactx1);
                  residuox := vfactor * vedadactx1 - vedad;
                  retorno := tablx(TRUNC(vfactor * vedadactx1)).vlxi *(1 - residuox)
                             + tablx(TRUNC(vfactor * vedadactx2)).vlxi * residuox;
                  vlxi1 := retorno;
               EXCEPTION
                  WHEN OTHERS THEN
                     -- dbms_output.put_line('Error:'||sqlerrm);
                     vlxi := 0;
                     --vlyi := 0;
                     vlxi1 := 0;
                     --vlyi1 := 0;
                     vqx := 0;
               -- vqy := 0;
               END;

               IF NVL(vedadacty, 0) <> 0 THEN
                  vedad := TRUNC(vfactor * vedadacty);
                  residuoy := vfactor * vedadacty - vedad;
                  retorno := tablx(TRUNC(vfactor * vedadacty)).vlyi *(1 - residuoy)
                             + tablx(TRUNC(vfactor * vedadacty1)).vlyi * residuoy;
                  vlyi := retorno;
                  retorno := tablx(TRUNC(vfactor * vedadacty)).vqy *(1 - residuoy)
                             + tablx(TRUNC(vfactor * vedadacty1)).vqy * residuoy;
                  vqy := retorno;
                  vedad := TRUNC(vfactor * vedadacty1);
                  residuoy := vfactor * vedadacty1 - vedad;
                  retorno := tablx(TRUNC(vfactor * vedadacty1)).vlyi *(1 - residuoy)
                             + tablx(TRUNC(vfactor * vedadacty2)).vlyi * residuoy;
                  vlyi1 := retorno;
               ELSE
                  vlyi := 0;
                  vqy := 0;
                  vlyi1 := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                   -- dbms_output.put_line('Error:'||sqlerrm);
                  -- vlxi := 0;
                  vlyi := 0;
                  -- vlxi1 := 0;
                  vlyi1 := 0;
                  -- vqx := 0;
                  vqy := 0;
            END;
         END IF;

         --Fi bug 10228

         --  dbms_output.put_line('i2:'||i||'   vlxi:'||vlxi||'   vlxi1:'||vlxi1||'   tablx(TRUNC(vfactor*vedadactx)).vlxi:'||tablx(TRUNC(vfactor*vedadactx)).vlxi||' '||TRUNC(vfactor*vedadactx));
         vprog := tabprogs(i).prog;
         vprogacum := tabprogs(i).progacum;
         vpaso := 11;
         vinter := pinter;

         IF periodo IS NOT NULL THEN
            IF ptipoact = 0 THEN   --Tipo de actualización interés único
               IF i + 1 >(periodo * vfactor) THEN   --interes mínimo
                  vinter := pinter2;
               END IF;

               vfacint1 := POWER(vinter, vedadactx - vedadini);
               vfacint2 := POWER(vinter, vedadactx - vedadini -(pincrementoriesg / vfactor));
            ELSE
               -- BUG 11463-  01/2010 - JRH  - Corrección
               IF vinter = pinter2 THEN
                  vfacint1 := POWER(vinter, vedadactx - vedadini);
                  vfacint2 := POWER(vinter,
                                    vedadactx - vedadini -(pincrementoriesg / vfactor));
               ELSE
                  -- BUG 13969- 04/2010 - JRH  - Caso de revisión
                  IF i + 0 > ROUND(periodo * vfactor) THEN   --Tipo de actualización teniendo en cuenta todos los tramos de interés
                     -- Fi BUG 13969- 04/2010 - JRH
                     vfacint1 := POWER(vinter / pinter2, periodo * 1)
                                 * POWER(pinter2, vedadactx - vedadini);
                     vfacint2 := POWER(vinter / pinter2,
                                       (periodo * 1) -(pincrementoriesg / vfactor))
                                 * POWER(pinter2,
                                         vedadactx - vedadini -(pincrementoriesg / vfactor));
                  ELSE
                     vfacint1 := POWER(vinter / pinter2, vedadactx - vedadini)
                                 * POWER(pinter2, vedadactx - vedadini);
                     vfacint2 := POWER(vinter / pinter2,
                                       vedadactx - vedadini -(pincrementoriesg / vfactor))
                                 * POWER(pinter2,
                                         vedadactx - vedadini -(pincrementoriesg / vfactor));
                  END IF;
               END IF;
            -- Fi BUG 11463-  01/2010 - JRH
            END IF;
         ELSE
            vfacint1 := POWER(vinter, vedadactx - vedadini);
            vfacint2 := POWER(vinter, vedadactx - vedadini -(pincrementoriesg / vfactor));
         END IF;

         --dbms_output.put_line('i:'||i||'   vinter:'||vinter||'   vfacint1:'||vfacint1||'   vfacint2:'||vfacint2||'  (vedadactx - vedadini):'||TO_NUMBER(vedadactx - vedadini)||'    (periodo * vfactor):'||(periodo * vfactor)||'     POWER(vinter, periodo * vfactor):'||POWER(vinter, periodo * vfactor)||'            POWER(vinter, (vedadactx - vedadini)-(periodo * vfactor):'||POWER(vinter, (vedadactx - vedadini)-(periodo * vfactor)));
         vpaso := 12;
         vpaso := 14;
         vdx :=(vlxi * vfacint1);
         vdy :=(vlyi * vfacint1);
         vdxy :=(vlxi * vlyi * vfacint1);
         vcx := (vlxi - vlxi1) * vfacint2;
         vcy := (vlyi - vlyi1) * vfacint2;
         -- BUG 12136- 03/2010 - JRH  - No es asi
         --vcxy := (vlxi - vlxi1) *(vlyi - vlyi1) * vfacint2;
         vcxy := (vlxi * vlyi - vlxi1 * vlyi1) * vfacint2;
         -- Fi BUG 12136- 03/2010 - JRH
         vacumdx := vacumdx + vdx * vprog;
         vacumdy := vacumdy + vdy * vprog;
         vacumdxy := vacumdxy + vdxy * vprog;
         vnx := vacumdx;
         vny := vacumdy;
         vnxy := vacumdxy;
         vacumdx2 := vacumdx2 + vdx * 1;
         vacumdy2 := vacumdy2 + vdy * 1;
         vacumdxy2 := vacumdxy2 + vdxy * 1;
         vnnx := vacumdx2;
         vnny := vacumdy2;
         vnnxy := vacumdxy2;
         vacumcx := vacumcx + POWER(factreemb, i + 1) * vcx;
         vacumcy := vacumcy + POWER(factreemb, i + 1) * vcy;
         vacumcxy := vacumcxy + POWER(factreemb, i + 1) * vcxy;
         vmx := vacumcx;
         vmy := vacumcy;
         vmxy := vacumcxy;
         vacumcx2 := vacumcx2 + vcx * vprogacum;
         vacumcy2 := vacumcy2 + vcy * vprogacum;
         vacumcxy2 := vacumcxy2 + vcxy * vprogacum;
         vpaso := 15;
         vux := vacumcx2;
         vuy := vacumcy2;
         vuxy := vacumcxy2;
         vacumnx := vacumnx + vnx;   -- * vprog;
         vacumny := vacumny + vny;   -- * vprog;
         vacumnxy := vacumnxy + vnxy;   -- * vprog;
         vsx := vacumnx;
         vsy := vacumny;
         vsxy := vacumnxy;
         --JRH POS
         vacummx := vacummx + vmx;   -- * vprog;
         vacummy := vacummy + vmy;   -- * vprog;
         vacummxy := vacummxy + vmxy;   -- * vprog;
         vrx := vacummx;
         vry := vacummy;
         vrxy := vacummxy;

         -- dbms_output.put_line('vrx:'||vrx);

         --FI JRH POS
         IF vlxiini > 0 THEN
            vjx := vlxi / vlxiini;
         ELSE
            vjx := 0;
         END IF;

         IF vlyiini > 0 THEN
            vjy := vlyi / vlyiini;
         ELSE
            vjy := 0;
         END IF;

         IF vlyiini > 0
            AND vlxiini > 0 THEN
            vjxy := (vlxi * vlyi) /(vlxiini * vlyiini);
         ELSE
            vjxy := 0;
         END IF;

         vpaso := 16;

         IF vanyos - 1 = i THEN
            vnxn := vnx;
            vnyn := vny;
            vnxy := vnxy;
            vnnxn := vnnx;
            vnnyn := vnny;
            vnnxy := vnnxy;
            vuxn := vux;
            vuyn := vuy;
            vuxyn := vuxy;
            vmxn := vmx;
            vmyn := vmy;
            vmxyn := vmxy;
            vdxn := vdx;
            vdyn := vdy;
            vdxyn := vdxy;
            vcxn := vcx;
            vcyn := vcy;
            vcxyn := vcxy;
            vsxn := vsx;
            vsyn := vsy;
            vsxyn := vsxy;
            -- BUG 11462 - 11/2009 - JRH  - Faltaba este simbolo
            vnxyn := vnxy;   --JRH IMP
            -- fi BUG 11462 - 11/2009 - JRH
            vrxn := vrx;
            vryn := vry;
            vrxyn := vrxy;
         END IF;

         IF vanyos + 1 - 1 = i THEN
            vnxn1 := vnx;
            vnyn1 := vny;
            vnxyn1 := vnxy;
            vnnxn1 := vnnx;
            vnnyn1 := vnny;
            vnnxyn1 := vnnxy;
            vuxn1 := vux;
            vuyn1 := vuy;
            vuxyn1 := vuxy;
            vmxn1 := vmx;
            vmyn1 := vmy;
            vmxyn1 := vmxy;
            vdxn1 := vdx;
            vdyn1 := vdy;
            vdxyn1 := vdxy;
            vcxn1 := vcx;
            vcyn1 := vcy;
            vcxyn1 := vcxy;
            vsxn1 := vsx;
            vsyn1 := vsy;
            vsxyn1 := vsxy;
            vnxyn1 := vnxy;   --JRH IMP
            vrxn1 := vrx;
            vryn1 := vry;
            vrxyn1 := vrxy;
         END IF;

         IF vanyos_rent + 1 - 1 = i THEN
            vmxnr1 := vmx;
            vmynr1 := vmy;
            vmxynr1 := vmxy;
            vnxnr1 := vnx;
            vnynr1 := vny;
            vnxynr1 := vnxy;
            vuxnr1 := vux;
            vuynr1 := vuy;
            vuxynr1 := vuxy;
            vsxnr1 := vsx;
            vsynr1 := vsy;
            vsxynr1 := vsxy;
            vcxnr1 := vcx;
            vcynr1 := vcy;
            vcxynr1 := vcxy;
            vdxnr1 := vdx;
            vdynr1 := vdy;
            vdxynr1 := vdxy;
            vrxnr1 := vrx;
            vrynr1 := vry;
            vrxynr1 := vrxy;
         END IF;

         IF vanyos IS NULL THEN
            vnxn := 0;
            vnyn := 0;
            vnxy := 0;
            vnnxn := 0;
            vnnyn := 0;
            vnnxy := 0;
            vuxn := 0;
            vuyn := 0;
            vuxyn := 0;
            vmxn := 0;
            vmyn := 0;
            vmxyn := 0;
            vdxn := 0;
            vdyn := 0;
            vdxyn := 0;
            vnxn1 := 0;
            vnyn1 := 0;
            vnxyn1 := 0;
            vnnxn1 := 0;
            vnnyn1 := 0;
            vnnxyn1 := 0;
            vuxn1 := 0;
            vuyn1 := 0;
            vuxyn1 := 0;
            vmxn1 := 0;
            vmyn1 := 0;
            vmxyn1 := 0;
            vdxn1 := 0;
            vdyn1 := 0;
            vdxyn1 := 0;
            vmxnr1 := 0;
            vmynr1 := 0;
            vmxynr1 := 0;
            vcxn1 := 0;
            vcyn1 := 0;
            vcxyn1 := 0;
            vcxn := 0;
            vcyn := 0;
            vcxyn := 0;
            vnxyn := 0;   --JRH IMP
            vrxn := 0;
            vryn := 0;
            vrxy := 0;
            vsxn := 0;
            vsyn := 0;
            vsxy := 0;
            vrxnr1 := 0;
            vrynr1 := 0;
            vrxynr1 := 0;
            vsxnr1 := 0;
            vsynr1 := 0;
            vsxynr1 := 0;
            vrxn1 := 0;
            vryn1 := 0;
            vrxyn1 := 0;
         END IF;

         vpaso := 17;

         IF vdx > 0 THEN
            vexn1 := vdxn1 / vdx;
         ELSE
            vexn1 := 0;
         END IF;

         IF vdy > 0 THEN
            veyn1 := vdyn1 / vdy;
         ELSE
            veyn1 := 0;
         END IF;

         vpaso := 18;

         IF vdx0 <> 0 THEN
            vaxnpp := (vnx - vnxn) / vdx0;
            n_vaxpp := (vux - vuxn) / vdx0;
            l_nvaxpp := 0;
            axtkpp := (vmx - vmxn) / vdx0;
            axtnkpp := (vmxn - vmxnr1) / vdx0;
         ELSE
            vaxnpp := 0;
            n_vaxpp := 0;
            l_nvaxpp := 0;
            axtkpp := 0;
            axtnkpp := 0;
         END IF;

         vpaso := 19;
         vaxnpu := 1;

         IF vdx <> 0 THEN
            n_vaxpu := (vmx - vmxn) / POWER(factreemb, i + 1) / vdx;   --Cambiado  vMxn por vMxn1
            l_nvaxpu := vcxn / vdx;   --vcxn/vdx;
            l_nvaxpu := l_nvaxpu * POWER(factreemb, vanyos - i);
            axtkpu := (vmx0 - vmxn) / vdx;   --Cambiado  vMxn por vMxn1
            axtnkpu := (vmxn - vmxnr1) / vdx;   --Cambiado  vMxn por vMxn1
         ELSE
            n_vaxpu := 0;
            l_nvaxpu := 0;
            axtkpu := 0;
            axtnkpu := 0;
         END IF;

         vpaso := 20;
         vconmut := ob_conmutador();
         vconmut.vmesanyo := vedadactx * vfactor;
         vconmut.vedadactx := vedadactx;
         vconmut.vedadacty := vedadacty;
         vconmut.vedadactx1 := vedadactx1;
         vconmut.vedadacty1 := vedadacty1;
         vconmut.vlxi := vlxi;
         vconmut.vlxi1 := vlxi1;
         vconmut.vlyi := vlyi;
         vconmut.vlyi1 := vlyi1;
         vconmut.vlxiini := vlxiini;
         vconmut.vlyiini := vlyiini;
         vconmut.vprog := vprog;
         vconmut.vprogacum := vprogacum;
         vconmut.vduraci := vduraci;
         vconmut.vfactreemb := vfactreemb;
         vconmut.vsobremort := vsobremort;
         vconmut.n := i;
         vconmut.vqx := vqx;
         vconmut.vqy := vqy;
         vconmut.vdx := vdx;
         vconmut.vdy := vdy;
         vconmut.vdxy := vdxy;
         vconmut.vcx := vcx;
         vconmut.vcy := vcy;
         vconmut.vcxy := vcxy;
         vconmut.vnx := vnx;
         vconmut.vny := vny;
         vconmut.vnxy := vnxy;
         vconmut.vmx := vmx;
         vconmut.vmy := vmy;
         vconmut.vmxy := vmxy;
         vconmut.vux := vux;
         vconmut.vuy := vuy;
         vconmut.vuxy := vuxy;
         vconmut.vjx := vjx;
         vconmut.vjy := vjy;
         vconmut.vjxy := vjxy;
         vconmut.vnx0 := vnx0;
         vconmut.vny0 := vny0;
         vconmut.vnxy0 := vnxy0;
         vconmut.vnnx0 := vnnx0;
         vconmut.vnny0 := vnny0;
         vconmut.vnnxy0 := vnnxy0;
         vconmut.vux0 := vux0;
         vconmut.vuy0 := vuy0;
         vconmut.vuxy0 := vuxy0;
         vconmut.vmx0 := vmx0;
         vconmut.vmy0 := vmy0;
         vconmut.vmxy0 := vmxy0;
         vconmut.vdx0 := vdx0;
         vconmut.vdy0 := vdy0;
         vconmut.vdxy0 := vdxy0;
         vconmut.vnxn := vnxn;
         vconmut.vnyn := vnyn;
         vconmut.vnxyn := vnxyn;
         vconmut.vnnxn := vnnxn;
         vconmut.vnnyn := vnnyn;
         vconmut.vnnxyn := vnnxyn;
         vconmut.vuxn := vuxn;
         vconmut.vuyn := vuyn;
         vconmut.vuxyn := vuxyn;
         vconmut.vmxn := vmxn;
         vconmut.vmyn := vmyn;
         vconmut.vmxyn := vmxyn;
         vconmut.vdxn := vdxn;
         vconmut.vdyn := vdyn;
         vconmut.vdxyn := vdxyn;
         vconmut.vnxn1 := vnxn1;
         vconmut.vnyn1 := vnyn1;
         vconmut.vnxyn1 := vnxyn1;
         vconmut.vnnxn1 := vnnxn1;
         vconmut.vnnyn1 := vnnyn1;
         vconmut.vnnxyn1 := vnnxyn1;
         vconmut.vnnx := vnnx;
         vconmut.vnny := vnny;
         vconmut.vnnxy := vnnxy;
         vconmut.vuxn1 := vuxn1;
         vconmut.vuyn1 := vuyn1;
         vconmut.vuxyn1 := vuxyn1;
         vconmut.vmxn1 := vmxn1;
         vconmut.vmyn1 := vmyn1;
         vconmut.vmxyn1 := vmxyn1;
         vconmut.vdxn1 := vdxn1;
         vconmut.vdyn1 := vdyn1;
         vconmut.vdxyn1 := vdxyn1;
         vconmut.vexn1 := vexn1;
         vconmut.veyn1 := veyn1;
         vconmut.vfacint1 := vfacint1;
         vconmut.vfacint2 := vfacint2;
         vconmut.vinter := vinter;
         vconmut.vanyos := vanyos;
         vconmut.vaxnpp := vaxnpp;
         vconmut.n_vaxpp := n_vaxpp;
         vconmut.l_nvaxpp := l_nvaxpp;
         vconmut.axtkpp := axtkpp;
         vconmut.axtnkpp := axtnkpp;
         vconmut.vaxnpu := vaxnpu;
         vconmut.n_vaxpu := n_vaxpu;
         vconmut.l_nvaxpu := l_nvaxpu;
         vconmut.axtkpu := axtkpu;
         vconmut.axtnkpu := axtnkpu;
         vconmut.vmxnr1 := vmxnr1;
         vconmut.vmynr1 := vmynr1;
         vconmut.vmxynr1 := vmxynr1;
         vconmut.vcxn1 := vcxn1;
         vconmut.vcyn1 := vcyn1;
         vconmut.vcxyn1 := vcxyn1;
         vconmut.vcxn := vcxn;
         vconmut.vcyn := vcyn;
         vconmut.vcxyn := vcxyn;
         vconmut.vsx := vsx;
         vconmut.vsy := vsy;
         vconmut.vsxy := vsxy;
         vconmut.vsx0 := vsx0;
         vconmut.vsy0 := vsy0;
         vconmut.vsxn := vsxn;
         vconmut.vsyn := vsyn;
         vconmut.vsxyn := vsxyn;
         vconmut.vsxn1 := vsxn1;
         vconmut.vsyn1 := vsyn1;
         vconmut.vsxyn1 := vsxyn1;
         vconmut.vnxnr1 := vnxnr1;
         vconmut.vnynr1 := vnynr1;
         vconmut.vnxynr1 := vnxynr1;
         vconmut.vuxnr1 := vuxnr1;
         vconmut.vuynr1 := vuynr1;
         vconmut.vuxynr1 := vuxynr1;
         vconmut.vsxnr1 := vsxnr1;
         vconmut.vsynr1 := vsynr1;
         vconmut.vsxynr1 := vsxynr1;
         vconmut.vcxnr1 := vcxnr1;
         vconmut.vcynr1 := vcynr1;
         vconmut.vcxynr1 := vcxynr1;
         vconmut.vdxnr1 := vdxnr1;
         vconmut.vdynr1 := vdynr1;
         vconmut.vdxynr1 := vdxynr1;
         vconmut.vrx := vrx;
         vconmut.vry := vry;
         vconmut.vrxy := vrxy;
         vconmut.vrx0 := vrx0;
         vconmut.vry0 := vry0;
         vconmut.vrxn := vrxn;
         vconmut.vryn := vryn;
         vconmut.vrxyn := vrxyn;
         vconmut.vrxn1 := vrxn1;
         vconmut.vryn1 := vryn1;
         vconmut.vrxyn1 := vrxyn1;
         vconmut.vrxnr1 := vrxnr1;
         vconmut.vrynr1 := vrynr1;
         vconmut.vrxynr1 := vrxynr1;
         vpaso := 21;
         vtconmut.EXTEND;
         vtconmut(vtconmut.LAST) := vconmut;
         vpaso := 22;

         IF i <= 0 THEN
            EXIT;
         END IF;

         i := i - 1;
      END LOOP;

      IF vtconmut.COUNT > 0 THEN
         vpaso := 24;
         vtconmut2 := invertir(vtconmut);
         vpaso := 25;
      END IF;

      --Añadimos a cache
      p_anadirconm(pedadx, psexo, pnacim, pedady, psexo2, pnacim2, ptabla, pinter, pinter2,
                   periodo, pgg, pig, panyos, panyos_rent, var, p_es_mensual, pforpag, pmesini,
                   preemb, psobremort, pesahorr, prevers, ptabprogresiones, ptabpagasextras,
                   pmesefecto, pesrevision, ptipoact, pincrementoriesg, panyostab, ptipoextrap,
                   vtconmut2);
      --dbms_output.put_line('CUENTA:'||reg.count);
      RETURN vtconmut2;
   EXCEPTION
      WHEN erroracctab THEN
         p_tab_error(f_sysdate, f_user, 'pac_conmutadors_2', vpaso, 'ErrorAccTab', 'v');
         RETURN NULL;
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_conmutadors_2', vpaso, 'OTHERS',
                     SUBSTR(SQLERRM, 1, 2500));
         RETURN NULL;
   END calculaconmu;
END pac_conmutadors;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONMUTADORS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONMUTADORS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONMUTADORS" TO "PROGRAMADORESCSI";
