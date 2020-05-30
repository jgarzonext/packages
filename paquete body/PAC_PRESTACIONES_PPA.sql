--------------------------------------------------------
--  DDL for Package Body PAC_PRESTACIONES_PPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PRESTACIONES_PPA" IS
/******************************************************************************
   NAME:       PAC_PRESTACIONES_PPA
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????  ???              1. Created this package body.
   2.0        23/09/2009  DRA              2. 0011183: CRE - Suplemento de alta de asegurado ya existente
   3.0        27/05/2010  JMC              3. 0012716: CEM - PPA. Función f_rt, revisión cálculo IRPF
                                              Se anaden comentarios para relacionar las variables del
                                              proceso con las del documento (ver bug), estos comentarios
                                              tienen el prefijo (JMC)
   4.0        04/01/2011  RSC              4. 0017187: TRASPASSOS SORTIDA DONA ERROR AL CONFIRMAR I DESPAREIX BOTÓ TRASPASSAR
   5.0        28/10/2011  RSC              5. 0019425/94998: CIV998-Activar la nova gestio de traspassos
******************************************************************************/
/*************************************************************
bug 12716 JMC Descripción del valor del campo IRPFTABLAS.NTIPO
**************************************************************
   NTIPO  Descripción
   -----  -------------------------------------------------------
     0    Reducciones varias dependera del valor del campo IDESDE
          IDESDE    Descripción
          ------    ---------------------------------------------
             1      Reducción mas de dos descendientes
             2      Reducción pensionista de la S. Social
             3      Reducción por ser desempleado

     1    Reducción rendimiento neto.
     2    Minimo personal
     3    Mínimo por descendientes < 25 anos o discapacitados
     4    Descendientes < 3 anos
     5    Rendimiento Anual
     6    Edad Ascendentes
     7    Edad del contribuyente
     8    Discapacidad descendientes y ascendientes
     9    Discapacidad contribuyente

**************************************************************/
   FUNCTION frtprest(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pprestacion IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER IS
      /******************************************************************************************
           Retorna el valora de RT en una prestacion
           ptipo: 1 --> Retornará el Tipo de retención (Rendimiento del trabajo)
                  2 --> Retornará el importe de reducción.
       ***********************************************************************************/
      xerror         NUMBER;
      xmoneda        NUMBER := 1;
      xireten        NUMBER;
      xireduc        NUMBER;
      xircm          NUMBER;
      xfefecto       seguros.fefecto%TYPE;
      xretencion     NUMBER;
      xreduccion     NUMBER;
      xbase          NUMBER;
      xsperson       asegurados.sperson%TYPE;
      xcramo         seguros.cramo%TYPE;
      xcmotsin       prodcaumotsin.cmotsin%TYPE;
      vaportant2007  NUMBER;
      vaportdes2006  NUMBER;
   BEGIN
      SELECT fefecto, cramo
        INTO xfefecto, xcramo
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT a.sperson
        INTO xsperson
        FROM per_personas p, asegurados a
       WHERE p.sperson = a.sperson
         AND a.sseguro = psseguro
         AND a.norden = pnriesgo;

      /*
      select cmotsin into xcmotsin
      from prodcaumotsin
      where cramo = xcramo
        and cgarant = pcgarant;
      */
      xerror := pac_prestaciones_ppa.f_pres_ppa(psseguro, vaportant2007, vaportdes2006);

      IF xerror <> 0 THEN
         p_tab_error(f_sysdate, getuser, 'Pac_Prestaciones_PPA.Frtprest', 1,
                     'parametros: PSSEGURO=' || psseguro || ' PNRIESGO =' || pnriesgo
                     || ' PPRESTACION =' || pprestacion || ' PTIPO=' || ptipo,
                     f_axis_literales(xerror, f_idiomauser));
         RETURN NULL;
      END IF;

      -- De esta linea no estoy seguro --> Comentar con Yolanda!!!!
      vaportant2007 := vaportant2007
                       / pac_prestaciones_ppa.f_vivo_o_muerto(psseguro, 1, f_sysdate);
      xerror := pac_prestaciones_ppa.f_rt(psseguro, xfefecto, xsperson, pcgarant, pccausin,
                                          pcmotsin, pprestacion, vaportant2007, xretencion,
                                          xreduccion, xbase);

      IF xerror <> 0 THEN
         p_tab_error(f_sysdate, getuser, 'Pac_Prestaciones_PPA.Frtprest', 2,
                     'parametros: PSSEGURO=' || psseguro || ' PNRIESGO =' || pnriesgo
                     || ' PPRESTACION =' || pprestacion || ' PTIPO=' || ptipo,
                     f_axis_literales(xerror, f_idiomauser));
         RETURN NULL;
      ELSE
         IF ptipo = 1 THEN
            RETURN xretencion;   -- Porcentaje de retención
         ELSIF ptipo = 2 THEN
            RETURN xreduccion;   -- Valor de reducción
         END IF;
      END IF;

      RETURN xircm;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'Pac_Prestaciones_PPA.Frtprest', 3,
                     'parametros: PSSEGURO=' || psseguro || ' PNRIESGO =' || pnriesgo
                     || ' PPRESTACION =' || pprestacion || ' PTIPO=' || ptipo,
                     SQLERRM);
         RETURN NULL;
   END frtprest;

     /*
     RSC 01/04/2008
     Función desarrollada para el cálculo del Rendimiento de Trabajo para prestaciones PPA.
     Para PPA el tipo de retención no será RCM sinó RT. Esta función lo cálcula de forma
     generica.
   */
   FUNCTION f_rt(
      psseguro IN NUMBER,
      pfecha IN DATE,   --Fecha efecto póliza
      psperson IN NUMBER,
      pcgarant IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcapital IN NUMBER,   -- prestaciones pendientes de cobro
      paportsant2007 IN NUMBER,
      pretencion OUT NUMBER,
      preduccion OUT NUMBER,
      pbase OUT NUMBER)
      RETURN NUMBER IS
      pretanual      NUMBER;
      --  PReduccion    NUMBER;
      psitfam        per_irpf.csitfam%TYPE;
      ptiporet       NUMBER;
      pretanu        NUMBER;
      phijos         NUMBER;
      pdescen1625    NUMBER;
      pretdescen316  NUMBER;
      pretdescen3    NUMBER;
      pretdesdis33   NUMBER;
      pretdesdis65   NUMBER;
      pretabuelos    NUMBER;
      predneto       irpftablas.iimporte%TYPE;
      predminper     irpftablas.iimporte%TYPE;
      predminfam     NUMBER;
      pretpension    per_irpf.ipension%TYPE;
      pretmasdos     irpftablas.iimporte%TYPE;
      pgradodisca    per_irpf.cgrado%TYPE;
      gastos_convenio NUMBER;
      pretprolon     VARCHAR2(2);
      pretmovgeo     VARCHAR2(2);
      plog           VARCHAR2(3000);
--******************************************************************
--******************************************************************
--******************************************************************
--******* CALCULO DE LAS REDUCCIÓNES Y RETENCIONES DEL IRPF ********
--******************************************************************
--******************************************************************
--******************************************************************
      moneda         NUMBER(1);

      CURSOR c_familia IS
         SELECT   sperson, fnacimi, cgrado, center,
                  fadopcion   -- Bug 12716 - 14-09-2010 - JMC - Se anaden fadopcion
             FROM per_irpfdescen   --irpfdescendientes -- antes: per_irpfdescen
            WHERE sperson = psperson
              AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) <=
                                                                                             25
                  OR cgrado IN(1, 2, 3, 4))   -- Bug 12716 - 28-05-2010 - JMC - Se anaden grados 3 y 4
         ORDER BY fnacimi DESC;

      familia        c_familia%ROWTYPE;

      CURSOR c_abuelos IS
         SELECT sperson, fnacimi, cgrado, crenta, nviven
           FROM per_irpfmayores   --irpfmayores -- antes per_irpdmayores
          WHERE sperson = psperson
            AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) >=
                                                                                             65
                OR cgrado IN(1, 2, 3, 4));   -- Bug 12716 - 28-05-2010 - JMC - Se anaden grados 3 y 4

      abuelos        c_abuelos%ROWTYPE;

      -- Bug 17187 - RSC - 04/01/2011 - TRASPASSOS SORTIDA DONA ERROR AL CONFIRMAR I DESPAREIX BOTÓ TRASPASSAR
      -- Anadimos pano
      CURSOR c_cuadro(pano IN NUMBER) IS
         SELECT   ibase "IBASE", icuota "ICUOTA", iresto "IRESTO", itipo
             FROM irpfcuadro
            WHERE nano = NVL(pano, nano)
         ORDER BY ibase DESC;

      -- Fin Bug 17187
      cuadro         c_cuadro%ROWTYPE;
      expresion      VARCHAR2(100);
      prolongacion   per_irpf.prolon%TYPE;
      movilidad      per_irpf.rmovgeo%TYPE;
      sechijos       irpftablas.idesde%TYPE;
      retorno        NUMBER;
      mulhijo        NUMBER(1);
      err            NUMBER;
      pension        per_irpf.ipension%TYPE;
      imp_prolongacion irpftablas.iimporte%TYPE;
      imp_movilidad  irpftablas.iimporte%TYPE;
      mayor_edad     irpftablas.iimporte%TYPE;
      masdos         irpftablas.iimporte%TYPE;
      filas          INTEGER;
      cuantos        NUMBER(6);
      prestaciones_pagadas NUMBER(25, 2);
      anualidades    per_irpf.ianuhijos%TYPE;
      retenciones_pagadas NUMBER(25, 2);
      reduccion_anterior NUMBER(25, 2);
      importe_invalidez_hijos irpftablas.iimporte%TYPE;
      importe_invalidez_abuelos irpftablas.iimporte%TYPE;
      importe_invalidez_benef irpftablas.iimporte%TYPE;
      --prestaciones_pendientes     NUMBER (25, 2);
      porcentaje_retencion NUMBER(25, 2);
      tipo_hasta_final_ano NUMBER(25, 2);
      rendimiento_anual NUMBER(25, 2);
      rendimiento_anual_porcen NUMBER(25, 2);
      importe_minimo_excluido irpfcuadrohijos.iimporte%TYPE;
      importe_reduccion NUMBER(25, 2);
      retencion_pendiente NUMBER(25, 2);
      importe_saldo  irpftablas.iimporte%TYPE;
      importe_personal irpftablas.iimporte%TYPE;
      importe_familiar irpftablas.iimporte%TYPE;
      pase_anualidades NUMBER(1);
      pase_base      NUMBER(1);
--      importe_pago   NUMBER(25, 2);
      base_imponible NUMBER(25, 2);
      importe_hijos  irpftablas.iimporte%TYPE;
      importe_abuelos irpftablas.iimporte%TYPE;
      importe_total_hijos NUMBER;
      importe_total_abuelos NUMBER;
      cuota          NUMBER(25, 2);
      cuota_integra  NUMBER(25, 2);
      hijos          NUMBER(4);
      bruto          NUMBER(25, 2);
      -- valor_participacion NUMBER(25, 6);
      -- nulo           NUMBER(25, 6);
      -- periodos       NUMBER(2);
      -- contingencia   NUMBER(1);
      -- antiguedad     DATE;
      -- antiguedad_tras DATE;
      tabla_importe  irpftablas.iimporte%TYPE;
      tabla_formula  irpftablas.iformula%TYPE;
      grado          per_irpf.cgrado%TYPE;
      ayuda          per_irpf.cayuda%TYPE;
      situacion      per_irpf.csitfam%TYPE;
      edad           irpftablas.idesde%TYPE;
      edad_hijo      NUMBER(3);
      edad_abuelo    NUMBER(3);
      -- ncursor        INTEGER;
      fecha_nacimiento per_personas.fnacimi%TYPE;
      error          NUMBER(8);
      error_fecha    NUMBER(8);
      fecha_valoracion DATE := f_sysdate;   --:= to_date('15/04/2007','dd/mm/yyyy');
      excepcion_salir EXCEPTION;
      excepcion_nosepuede EXCEPTION;
      anos           NUMBER;
      vtraza         NUMBER;
      -- RSC 02/04/2008
      xsproduc       seguros.sproduc%TYPE;
      xcramo         seguros.cramo%TYPE;
      xcactivi       seguros.cactivi%TYPE;
      pred           NUMBER;
      xpcapital      NUMBER;
      xcestper       per_personas.cestper%TYPE;   -- Bug 12716 - 14-09-2010 - JMC - Se anade variable
      xpensionista   irpftablas.iimporte%TYPE;   -- Bug 12716 - 14-09-2010 - JMC - Se anade variable
      xdesempleado   irpftablas.iimporte%TYPE;   -- Bug 12716 - 14-09-2010 - JMC - Se anade variable
   BEGIN
      xpcapital := pcapital;

      SELECT sproduc, cramo, cactivi
        INTO xsproduc, xcramo, xcactivi
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 0;
      -- Inicializamos las variables para el nuevo cálculo de la Retención
      -- y de los valores correpondientes para la hoja del irpf
      pretanual := 0;
      preduccion := 0;
      psitfam := 0;
      ptiporet := 0;
      pretanu := 0;
      phijos := 0;
      pdescen1625 := 0;
      pretdescen316 := 0;
      pretdescen3 := 0;
      pretdesdis33 := 0;
      pretdesdis65 := 0;
      pretabuelos := 0;
      predneto := 0;
      predminper := 0;
      predminfam := 0;
      pretpension := 0;
      pretmasdos := 0;
      plog := NULL;
      pretprolon := NULL;
      pretmovgeo := NULL;
      error := 0;
      vtraza := 1;
      -- Si el contrato tiene más de 2 anos no calculamos la reducción
      error := f_difdata(pfecha, f_sysdate, 1, 1, anos);
      vtraza := 2;

       /*
       BEGIN
         select cmotsin into xcmotsin
         from prodcaumotsin
         where cramo = xcramo
           and cgarant = pcgarant;
      EXCEPTION
        WHEN OTHERS THEN

      END;
      */

      /*
         a.Reducción: 40% sólo sobre las aportaciones anteriores al 31/12/2006
                      siempre y cuando el PPA tenga más de 2 anos de antigüedad.
                      En caso de traspaso se mantiene la antigüedad inicial del
                      PPA. En el caso de prestación por Invalidez no se mira la
                      antigüedad del PPA.

         b.Retención: cálculo igual que en Planes de Pensiones. (ya es igual
                      que en planes)
      */
      IF pccausin = 1
         AND pcmotsin = 1 THEN   -- Siniestro (pccausin = 1) por Invalidez (pcmotsin = 1)
         IF pfecha <= TO_DATE('31/12/2006', 'dd/mm/yyyy') THEN
            pred := fbuscapreduc(1, xsproduc, xcactivi, pcgarant,
                                 TO_NUMBER(TO_CHAR(pfecha, 'yyyymmdd')), 0);
            importe_reduccion := ROUND(((paportsant2007 * pred) / 100), 2);
         ELSE
            importe_reduccion := 0;
         END IF;
      ELSE
         IF anos > 2 THEN
            IF pfecha <= TO_DATE('31/12/2006', 'dd/mm/yyyy') THEN
               pred := fbuscapreduc(1, xsproduc, xcactivi, pcgarant,
                                    TO_NUMBER(TO_CHAR(f_sysdate, 'yyyymmdd')), 0);
               importe_reduccion := ROUND(((paportsant2007 * pred) / 100), 2);
            ELSE
               importe_reduccion := 0;
            END IF;
         ELSE
            importe_reduccion := 0;
         END IF;
      END IF;

      -- Modificamos el capital de provisión quitandole la reducción
      --IF importe_reduccion <> 0 THEN
      -- xpcapital := pcapital - importe_reduccion;
      --END IF;
      -- Ya se hace a continuación esto!!!
      vtraza := 3;
      rendimiento_anual := NVL(prestaciones_pagadas, 0) + NVL(xpcapital, 0);
      pretanual := NVL(rendimiento_anual, 0);
      bruto := NVL(rendimiento_anual, 0) - NVL(importe_reduccion, 0)
               - NVL(reduccion_anterior, 0);
      vtraza := 4;
      preduccion := NVL(importe_reduccion, 0);
--***************************************************************************
--*** MINORACIONES.
--*** Reducción por rendimiento de trabajo ( Apartado 5 ).
--***************************************************************************
--*** Asignamos la reducción del rendimiento neto del trabajo segun la tabla
      vtraza := 5;
      error := 1;

      SELECT iimporte, iformula
        INTO tabla_importe, tabla_formula
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 1
         AND bruto BETWEEN idesde AND ihasta;

      vtraza := 6;

      IF tabla_formula IS NOT NULL THEN
         error := 2;

         SELECT REPLACE(tabla_formula, 'RNT', bruto)
           INTO tabla_formula
           FROM DUAL;

         tabla_formula := REPLACE(tabla_formula, ',', '.');

         SELECT ROUND(evalselect(tabla_formula), 2)
           INTO tabla_importe
           FROM DUAL;
      END IF;

      vtraza := 7;
      plog := plog || '
     Apartado 5 AEAT :' || tabla_importe;

     --(JMC) tabla_importe corresponde al aparatado Reducción de carácter general.
     -- Bug:12716 28
      --***************************************************************************
--*** MINORACIONES. ( NUEVO 2003 - JAMR )
--*** Reducción por prolongación de la actividad laboral
--*** (Apartado 6 que depende del Apartado 5 ).
--***************************************************************************
  /*
    RSC: 31/03/2008
    Nota: Tras esta query la variable "gastos_convenio" valdrá NULL. Estudiar el tema
      de los gastos deducibles. De momento lo dejamos asi y lo tratará como NULL y por tanto 0.
  */
      BEGIN
         SELECT cgrado, csitfam, cayuda, ipension, ianuhijos, rmovgeo,
                prolon   --, igastoconv
           INTO grado, situacion, ayuda, pension, anualidades, movilidad,
                prolongacion   --, gastos_convenio
           FROM per_irpf   --irpfpersonas -- antes: per_irpf
          WHERE sperson = psperson
            AND nano = TO_NUMBER(TO_CHAR(fecha_valoracion, 'YYYY')) - 1;   -- Bug 12716 - 28-05-2010 - JMC - Se anade el ano
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vtraza := 8;
      psitfam := situacion;
      pgradodisca := grado;

      --ERR := F_Desvalorfijo ( 688,:GLOBAL.USU_IDIOMA,GRADO,:RET_DISCAPACITADO);
      SELECT DECODE(NVL(prolongacion, 0), 1, 'Si', 'No')
        INTO pretprolon
        FROM DUAL;

      SELECT DECODE(NVL(movilidad, 0), 1, 'Si', 'No')
        INTO pretmovgeo
        FROM DUAL;

      IF prolongacion = 1 THEN
         imp_prolongacion := tabla_importe;
      END IF;

      vtraza := 9;
      plog := plog || '
    Apartado 6+5 AEAT :' || imp_prolongacion;

    --(JMC) imp_prolongacion, corresponde al apartado Reducción por prolongación de la actividad laboral.
--***************************************************************************
--*** MINORACIONES. ( NUEVO 2003 - JAMR )
--*** Reducción por movilidad geográfica ( Apartado 7 Depende del Apartado 5).
--***************************************************************************
      IF movilidad = 1 THEN
         imp_movilidad := tabla_importe;
      END IF;

      vtraza := 10;
      plog := plog || ' Apartado 7+5 AEAT :' || imp_movilidad;

      --(JMC) imp_movilidad, corresponde al apatado Reducción por movilidad geográfica.
--*************************************************************************
--*** Límite máximo de las reducciones previstas en los apartados 5,6,7,8
--*************************************************************************
--TABLA_IMPORTE := TABLA_IMPORTE + NVL(IMP_MOVILIDAD,0) + NVL(IMP_PROLONGACION,0)
      IF (tabla_importe + NVL(imp_movilidad, 0) + NVL(imp_prolongacion, 0)) > bruto THEN
         ptiporet := 0;
         pretanu := 0;
         plog := plog || '
    Límite máximo 5-6-7-8.Retención 0.' || imp_movilidad;
         RAISE excepcion_salir;
      END IF;

      vtraza := 11;
--***************************************************************************
--*** MINORACIONES. ( NUEVO 2003 - JAMR )
--*** Mínimo personal ( Apartado 3 )
--***************************************************************************
      error := 4;
      vtraza := 12;

      SELECT fnacimi
        INTO fecha_nacimiento
        FROM per_personas
       WHERE sperson = psperson;

      vtraza := 13;
      error_fecha := f_difdata(fecha_nacimiento, f_sysdate, 2, 1, edad);
      error := 5;
      vtraza := 133;

      SELECT DECODE(grado, 1, iinv1, 2, iinv2, iimporte)
        INTO importe_personal
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 2
         AND edad BETWEEN idesde AND ihasta;

      vtraza := 13333;
      plog := plog || '
    Mínimo personal Art.3 AEAT:' || importe_personal;
    --(JMC) importe_personal, corresponde al apartado Mínimo del contribuyente, con carácter general
--***************************************************************************
--*** MINORACIONES. ( NUEVO 2003 - JAMR )
--*** Mínimo por descendientes ( Apartado 4 )
   --***************************************************************************
      error := 6;
      vtraza := 14;

      SELECT NVL(COUNT(*), 0)
        INTO hijos
        FROM per_irpfdescen   --irpfdescendientes
       WHERE sperson = psperson
         AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) <=
                                                                                             25
             OR cgrado IN(1, 2));

      phijos := NVL(hijos, 0);
      -- *** Control suplemento hijos menores o invalidos
      error := 7;
      pdescen1625 := 0;
      pretdescen316 := 0;
      pretdescen3 := 0;
      pretdesdis33 := 0;
      pretdesdis65 := 0;
      sechijos := 0;
      vtraza := 15;

      OPEN c_familia;

      LOOP
         FETCH c_familia
          INTO familia;

         EXIT WHEN c_familia%NOTFOUND;
         sechijos := sechijos + 1;

         SELECT NVL(importe_familiar, 0) + DECODE(familia.center, 1, iimporte, iimporte / 2)
           INTO importe_familiar
           FROM irpftablas
          WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ntipo = 3
            AND sechijos BETWEEN idesde AND ihasta;

         plog := plog || '
    Mínimo por descendientes Punto. 4 AEAT. Secuencia hijo:' || sechijos || ' Importe acum: '
                 || importe_familiar;

         --(JMC) importe_familiar, corresponde al apartado Mínimo por descendientes <25 anos o discapacitados
         --                                                con carácter general
--***************************************************************************
--*** MINORACIONES. ( NUEVO 2003 - JAMR )
--*** Reducción por cuidado de hijos ( Apartado 9 )
--***************************************************************************
         BEGIN
            error_fecha := f_difdata(familia.fnacimi, f_sysdate, 2, 1, edad_hijo);

            -- Ini Bug 12716 - 14-09-2010 - JMC - Tenemos en cuenta la fecha de adopción
            IF edad_hijo > 2
               AND familia.fadopcion IS NOT NULL THEN
               error_fecha := f_difdata(familia.fnacimi, familia.fadopcion, 2, 1, edad_hijo);

               IF edad_hijo < 19 THEN
                  error_fecha := f_difdata(familia.fadopcion, f_sysdate, 2, 1, edad_hijo);
               END IF;
            END IF;

            -- Fin Bug 12716 - 14-09-2010 - JMC
            SELECT DECODE(familia.center, 1, iimporte, iimporte / 2)
              INTO importe_hijos
              FROM irpftablas
             WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
               AND ntipo = 4
               AND edad_hijo BETWEEN idesde AND ihasta;

            importe_total_hijos := NVL(importe_total_hijos, 0) + NVL(importe_hijos, 0);
            plog := plog || '
    Reducción por cuidado de hijos. art. 9 AEAT: ' || importe_total_hijos;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         --(JMC) importe_total_hijos, corresponde al apartado Mínimo por descendientes <25 anos o discapacitados
         --                                                   descendientes <3 anos

         -- Miramos las invalidezas de los hijos
         BEGIN
            SELECT NVL(importe_invalidez_hijos, 0)
                   + DECODE(familia.center, 1, iimporte, iimporte / 2)
              INTO importe_invalidez_hijos
              FROM irpftablas
             WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
               AND ntipo = 8
               AND familia.cgrado BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         plog := plog || '
    Reducción invalidez descendientes art. 12 AEAT: ' || importe_invalidez_hijos;
      END LOOP;

--***************************************************************************
--*** MINORACIONES. ( NUEVO 2003 - JAMR )
--*** Reducciones por edad ( Apartado 10 )
--*** Reducciones por asistencia ( Apartado 11 )
--***************************************************************************
--*********************************
--**** Opcion A - Del contribuyente
--*********************************
      vtraza := 16;

      BEGIN
         SELECT iimporte
           INTO mayor_edad
           FROM irpftablas
          WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ntipo = 7
            AND edad BETWEEN idesde AND ihasta;

         plog := plog || 'Reducción ART.10/11-A. AEAT:' || mayor_edad;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            mayor_edad := 0;
      END;

      vtraza := 17;
--*********************************
--**** Opcion B - De Ascendiente
--*********************************
      error := 8;

      OPEN c_abuelos;

      LOOP
         FETCH c_abuelos
          INTO abuelos;

         EXIT WHEN c_abuelos%NOTFOUND;
         error_fecha := f_difdata(abuelos.fnacimi, f_sysdate, 2, 1, edad_abuelo);
         importe_abuelos := 0;

         BEGIN
            SELECT DECODE(abuelos.nviven,
                          1, iimporte,
                          NULL, iimporte,
                          0, iimporte,
                          iimporte / abuelos.nviven)
              INTO importe_abuelos
              FROM irpftablas
             WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
               AND ntipo = 6
               AND edad BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         importe_total_abuelos := NVL(importe_total_abuelos, 0) + NVL(importe_abuelos, 0);
         plog := plog || '
    Reducción ART.10/11-B. AEAT:' || importe_total_abuelos;

         --(JMC) importe_total_abuelos, corresponde al apartado Mínimo por ascendientes >65 anos o discapacitados
         --                                                     ascendientes >75 anos

         -- Miramos las invalidezas de los abuelos
         BEGIN
            SELECT NVL(importe_invalidez_abuelos, 0)
                   + DECODE(abuelos.nviven,
                            1, iimporte,
                            0, iimporte,
                            NULL, iimporte,
                            iimporte / abuelos.nviven)
              INTO importe_invalidez_abuelos
              FROM irpftablas
             WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
               AND ntipo = 8
               AND abuelos.cgrado BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         plog := plog || 'Reducción invalidez Ascendientes art. 12 AEAT: '
                 || importe_invalidez_abuelos;
      END LOOP;

      CLOSE c_abuelos;

      vtraza := 18;
      pretabuelos := NVL(importe_total_abuelos, 0);
      error := 9;

      --*** Si los hijos son mas de 2 resta 600 euros
      --*** JAMR - IRPF 2003 - Opción comentada.
      IF hijos > 2 THEN
         -- Ini Bug 12716 - 14-09-2010 - JMC - Se parametriza con ntipo=0
         BEGIN
            SELECT iimporte
              INTO masdos
              FROM irpftablas
             WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
               AND ntipo = 0
               AND idesde = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
--         SELECT DECODE(moneda, 2, 100000, 600)   -- parametrizar ... svj.
--           INTO masdos
--           FROM DUAL;
         -- Fin Bug 12716 - 14-09-2010 - JMC
      END IF;

      plog := plog || 'Mas de 2 hijos ART.14 AEAT:' || masdos;
      vtraza := 19;

      --(JMC) masdos, corresponde al apartado Reducción mas de dos descendientes.

      -- Reducción invalidez para el contribuyente
      -- Ini Bug 12716 - 14-09-2010 - JMC -
      -- Se anade tipo 9 Invalidez contribuyente, hasta ahora se utilizaba el tipo 8
      -- porque coincidian los importes, ahora no.
      SELECT NVL(cestper, 0)
        INTO xcestper
        FROM per_personas
       WHERE sperson = psperson;

      xdesempleado := 0;
      xpensionista := 0;

      IF xcestper <> 0 THEN
         importe_invalidez_benef := 0;

         IF xcestper = 3 THEN
            BEGIN
               SELECT iimporte
                 INTO xpensionista
                 FROM irpftablas
                WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
                  AND ntipo = 0
                  AND idesde = 2;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         ELSIF xcestper = 4 THEN
            BEGIN
               SELECT iimporte
                 INTO xdesempleado
                 FROM irpftablas
                WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
                  AND ntipo = 0
                  AND idesde = 3;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END IF;
      ELSE
         BEGIN
            SELECT iimporte
              INTO importe_invalidez_benef
              FROM irpftablas
             WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
               AND ntipo = 9
               AND grado BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN OTHERS THEN
               importe_invalidez_benef := 0;
         END;
      END IF;

      -- Fin Bug 12716 - 14-09-2010 - JMC
      vtraza := 20;
      plog := plog || 'Reducción invalidez Contribuyente art. 12 AEAT: '
              || importe_invalidez_benef;
--*************************************************************************
--   II. DETERMINACIÓN DE LA CUOTA DE RETENCIÓN
--*************************************************************************
      base_imponible :=
         bruto
         - NVL
             (gastos_convenio, 0)   --svj. tener en cuenta el gasto de la segurirdad social ( Gastos deducibles )
         - NVL(tabla_importe, 0) - NVL(imp_prolongacion, 0) - NVL(imp_movilidad, 0)
         - NVL(mayor_edad, 0) - NVL(importe_personal, 0) - NVL(importe_familiar, 0)
         - NVL(importe_total_hijos, 0) - NVL(importe_invalidez_hijos, 0) - NVL(pension, 0)
         - NVL(anualidades, 0) - NVL(masdos, 0) - NVL(importe_total_abuelos, 0)
         - NVL(importe_invalidez_abuelos, 0) - NVL(importe_invalidez_benef, 0)
         -- Ini Bug 12716 - 14-09-2010 - JMC - Se anaden reducciones por desempleado y pensionista
         - NVL(xpensionista, 0) - NVL(xdesempleado, 0);
      -- Fin Bug 12716 - 14-09-2010 - JMC
      pbase := base_imponible;
      predneto := NVL(tabla_importe, 0);
      predminper := NVL(importe_personal, 0);
      predminfam := NVL(importe_total_hijos, 0) + NVL(importe_familiar, 0);
      pretpension := NVL(pension, 0);
      pretmasdos := NVL(masdos, 0);
      vtraza := 21;

      IF base_imponible < 0 THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

      error := 10;
      --*** Miramos la cuota integra;
      pase_anualidades := 0;
      pase_base := 0;

      -- Bug 17187 - RSC - 04/01/2011 - TRASPASSOS SORTIDA DONA ERROR AL CONFIRMAR I DESPAREIX BOTÓ TRASPASSAR
      -- Le pasamos el ano.
      OPEN c_cuadro(TO_NUMBER(TO_CHAR(fecha_valoracion, 'YYYY')));

      -- Fin Bug 17187
      LOOP
         FETCH c_cuadro
          INTO cuadro;

         EXIT WHEN c_cuadro%NOTFOUND;

         IF NVL(anualidades, 0) > 0
            AND NVL(anualidades, 0) < base_imponible
            AND anualidades >= cuadro.ibase
            AND pase_anualidades = 0 THEN
            cuota_integra := NVL(cuota_integra, 0) + NVL(cuadro.icuota, 0)
                             +((NVL(anualidades, 0) - NVL(cuadro.ibase, 0))
                               *(NVL(cuadro.itipo, 0) / 100));
            pase_anualidades := 1;
            EXIT WHEN pase_anualidades = 1
                 AND pase_base = 1;
         END IF;

         IF NVL(anualidades, 0) > 0
            AND NVL(anualidades, 0) < base_imponible
            AND(base_imponible - anualidades) >= cuadro.ibase
            AND pase_base = 0 THEN
            cuota_integra := NVL(cuota_integra, 0) + NVL(cuadro.icuota, 0)
                             +(((NVL(base_imponible, 0) - NVL(anualidades, 0))
                                - NVL(cuadro.ibase, 0))
                               *(NVL(cuadro.itipo, 0) / 100));
            pase_base := 1;
            EXIT WHEN pase_anualidades = 1
                 AND pase_base = 1;
         END IF;

         IF base_imponible >= cuadro.ibase
            AND(NVL(anualidades, 0) = 0
                OR NVL(anualidades, 0) > base_imponible) THEN
            cuota_integra := NVL(cuadro.icuota, 0)
                             +((NVL(base_imponible, 0) - NVL(cuadro.ibase, 0))
                               *(NVL(cuadro.itipo, 0) / 100));
            EXIT WHEN 0 = 0;
         END IF;
      END LOOP;

      error := 11;
      vtraza := 22;
      vtraza := 224;

      -- *** Rendimiento anual
      SELECT iimporte
        INTO importe_saldo
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 5;

      vtraza := 221;

      IF rendimiento_anual < importe_saldo THEN
         vtraza := 222;

         -- RSC 03/04/2008 (por defecto si no hay información fiscal de la personas,
         --                 pondremos situación 1 --> Soltero)
         SELECT iimporte
           INTO importe_minimo_excluido
           FROM irpfcuadrohijos
          WHERE csituac = NVL(situacion, 1)
            AND NVL(hijos, 0) BETWEEN nhijdes AND nhijhas;

         vtraza := 223;
         rendimiento_anual_porcen := ROUND((rendimiento_anual - importe_minimo_excluido)
                                           *(35 / 100),
                                           2);

         IF cuota_integra > rendimiento_anual_porcen THEN
            cuota_integra := rendimiento_anual_porcen;
         END IF;
      END IF;

      vtraza := 224;
      error := 12;
--*************************************************************************
--   III. DETERMINACIÓN DEL TIPO DE RETENCION
--    IV. DETERMINACIÓN DEL IMPORTE DE LA RETENCION
--*************************************************************************
-- *** Obtenemos el porcentaje de la retención
      porcentaje_retencion := ROUND((cuota_integra / rendimiento_anual) * 100, 0);
      retencion_pendiente := cuota_integra - retenciones_pagadas;

      IF NVL(xpcapital, 0) = 0 THEN
         tipo_hasta_final_ano := 0;
      ELSE
         tipo_hasta_final_ano := ROUND((retencion_pendiente / xpcapital) * 100, 0);
      END IF;

      -- Si el importe deja el saldo a 0
      tipo_hasta_final_ano := porcentaje_retencion;
      ptiporet := NVL(tipo_hasta_final_ano, 0);

      IF NVL(ptiporet, 0) < 0 THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

      pretencion := NVL(ptiporet, 0);
      error := 13;
      pretanu := rendimiento_anual *(tipo_hasta_final_ano / 100);
      RETURN 0;
   EXCEPTION
      WHEN excepcion_salir THEN
         pretencion := 0;
         RETURN 0;
      WHEN excepcion_nosepuede THEN
         pretencion := 0;
         RETURN -99;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'Pac_Prestaciones_PPA.f_rt', error,
                     'parametros: PSSEGURO=' || psseguro || ' PFECHA=' || pfecha
                     || ' PSPERSON=' || psperson || ' PCGARANT=' || pcgarant || ' PCCAUSIN='
                     || pccausin || ' PCMOTSIN=' || pcmotsin || ' PCAPITAL=' || pcapital
                     || ' PAPORTSANT2007=' || paportsant2007,
                     'Error:' || SQLERRM);
         RETURN(-error);
   END f_rt;

   FUNCTION f_pres_ppa(psseguro IN NUMBER, pnparant2007 OUT NUMBER, pnparpos2006 OUT NUMBER)
      RETURN NUMBER IS
      aux_ant2007    trasplainout.nparant2007%TYPE;
      aux_pos2006    trasplainout.nparpos2006%TYPE;
      err_calc       EXCEPTION;
   BEGIN
      pnparant2007 := 0;
      pnparpos2006 := 0;

      -- albert - añado la columna del importe del recibo
      FOR reg IN (SELECT c.cmovimi, c.fvalmov, nnumlin, ctipapor, ( select itotalr from vdetrecibos where nrecibo = c.nrecibo ) itotalr,
                         DECODE(GREATEST(c.cmovimi, 10), 10, c.imovimi, -c.imovimi) imovimi
                    FROM ctaseguro c
                   WHERE c.sseguro = psseguro
                     AND c.cmovimi NOT IN(0, 54)) LOOP
         IF reg.fvalmov < fecha_ini_fisc
            OR reg.ctipapor = 'SP' THEN
            pnparant2007 := pnparant2007 + reg.imovimi;
         ELSIF reg.cmovimi IN(8, 47)
               AND reg.fvalmov >= fecha_ini_fisc THEN   -- Traspasos
            /*
              RSC 03/04/2008
              Nota: Dado que en PPA no tendremos participaciones (no es un Plan de Pensión),
              en los campos nparant2007 y nparpos2006 vendrá el importe, no las participaciones.

              Tener en cuenta que esta afirmacion anterior no esta certificada completamente.
              Se tendrá que ver que realmente sea así, pero en principio parece que así será.
            */
            BEGIN
               SELECT t.nparant2007, t.nparpos2006
                 INTO aux_ant2007, aux_pos2006
                 FROM trasplainout t
                WHERE t.sseguro = psseguro
                  AND t.nnumlin = reg.nnumlin
                  AND t.cestado IN(3, 4);
            EXCEPTION
               WHEN OTHERS THEN
                  aux_ant2007 := NULL;
                  aux_pos2006 := NULL;
            END;

            IF aux_ant2007 IS NOT NULL
               AND aux_pos2006 IS NOT NULL THEN

               -- Albert - Para traspasos miramos por vdetrecibos
               if reg.cmovimi = 8 and (aux_ant2007 + aux_pos2006) != ABS(nvl(reg.itotalr,0)) THEN
                  RAISE err_calc;

               ELSIF reg.cmovimi <> 8 and (aux_ant2007 + aux_pos2006) != ABS(reg.imovimi) THEN   -- Comprovant que n. parti estigui correcta
                  RAISE err_calc;
               ELSE
                  IF reg.cmovimi = 8 THEN
                     -- Taspas d'entrada. Recogim les participacions corresponents.
                     pnparant2007 := pnparant2007 + aux_ant2007;
                     pnparpos2006 := pnparpos2006 + aux_pos2006;
                  ELSE
                     pnparant2007 := pnparant2007 - aux_ant2007;
                     pnparpos2006 := pnparpos2006 - aux_pos2006;
                  END IF;
               END IF;
            END IF;
         ELSIF reg.cmovimi = 53
               AND reg.fvalmov >= fecha_ini_fisc THEN
            BEGIN
               SELECT i.nparant2007, i.nparpos2006
                 INTO aux_ant2007, aux_pos2006
                 FROM irpf_prestaciones i, ctaseguro c
                WHERE i.sidepag = c.sidepag
                  AND c.sseguro = psseguro
                  AND c.nnumlin = reg.nnumlin;

               IF aux_ant2007 IS NULL
                  AND aux_pos2006 IS NULL THEN
                  pnparant2007 := pnparant2007 + reg.imovimi;
               ELSE
                  pnparant2007 := pnparant2007 - aux_ant2007;
                  pnparpos2006 := pnparpos2006 - aux_pos2006;
               END IF;
            -- Bug 19425 - 28/10/2011 - RSC
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         -- Fin Bug 19425
         ELSE
            pnparpos2006 := pnparpos2006 + reg.imovimi;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN err_calc THEN
         pnparpos2006 := NULL;
         pnparant2007 := NULL;
         p_tab_error(f_sysdate, getuser, 'Pac_Prestaciones_PPA.f_pres_ppa', 1,
                     'parametros: PSSEGURO=' || psseguro,
                     'Error calculo aux_ant2007=' || aux_ant2007 || ' aux_pos2006='
                     || aux_pos2006);
         RETURN 500141;
      WHEN OTHERS THEN
         pnparpos2006 := NULL;
         pnparant2007 := NULL;
         p_tab_error(f_sysdate, getuser, 'Pac_Prestaciones_PPA.f_pres_ppa', 2,
                     'parametros: PSSEGURO=' || psseguro, 'Error:' || SQLERRM);
         RETURN SQLCODE;
   END f_pres_ppa;

   FUNCTION f_vivo_o_muerto(psseguro IN NUMBER, pcestado IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      xcuantos       NUMBER;
      xvivos         NUMBER;
      xmuertos       NUMBER;
      xtodos         NUMBER;
   --********* Parámetros
   --**** ESTADO
   --****
   --**** 1- Devuelve los asegurados vivos
   --**** 2- Devuelve los asegurados muertos
   --**** 3- Devuelve el numero de asegurados tanto vivos como muertos
   BEGIN
      IF pcestado = 1 THEN
         SELECT COUNT(1)
           INTO xvivos
           FROM asegurados
          WHERE sseguro = psseguro
            AND(ffecmue > pfecha
                OR ffecmue IS NULL)
            AND(ffecfin > pfecha
                OR ffecfin IS NULL);   -- BUG11183:DRA:23/09/2009

         RETURN(xvivos);
      ELSIF pcestado = 2 THEN
         SELECT COUNT(1)
           INTO xmuertos
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecmue <= pfecha;

         RETURN(xmuertos);
      ELSIF pcestado = 3 THEN
         SELECT COUNT(1)
           INTO xtodos
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecfin IS NULL;   -- BUG11183:DRA:23/09/2009

         RETURN(xtodos);
      END IF;
   END f_vivo_o_muerto;

   FUNCTION frtsialp(
      psesion IN NUMBER,
      psperdes IN NUMBER,
      psproduc IN NUMBER,
      pfsinies IN NUMBER,
      pnsinies IN NUMBER,
      psseguro IN NUMBER)
      RETURN NUMBER IS
      vfantigi       trasplainout.fantigi%TYPE;
      vdiferencia    NUMBER;
      verror         NUMBER;
   BEGIN
      BEGIN
         SELECT fantigi
           INTO vfantigi
           FROM trasplainout
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vfantigi := NULL;
      END;

      IF vfantigi IS NULL THEN
         SELECT fefecto
           INTO vfantigi
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      verror := f_difdata(vfantigi, f_sysdate, 1, 1, vdiferencia);

      IF verror = 0 THEN
         IF vdiferencia >= 5 THEN
            RETURN 0;
         ELSE
            RETURN NVL(fbuscapreten(0, psperdes, psproduc, pfsinies, pnsinies), 0);
         END IF;
      END IF;
   END frtsialp;
END pac_prestaciones_ppa;

/

  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES_PPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES_PPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES_PPA" TO "PROGRAMADORESCSI";
