--------------------------------------------------------
--  DDL for Package Body PAC_IRPF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IRPF" AS
   PROCEDURE p_hoja_irpf(
      parretanual OUT NUMBER,
      parreduccion OUT NUMBER,
      parsitfam OUT NUMBER,
      partiporet OUT NUMBER,
      parretanu OUT NUMBER,
      parhijos OUT NUMBER,
      pardescen1625 OUT NUMBER,
      parretdescen316 OUT NUMBER,
      parretdescen3 OUT NUMBER,
      parretdesdis33 OUT NUMBER,
      parretdesdis65 OUT NUMBER,
      parretabuelos OUT NUMBER,
      parredneto OUT NUMBER,
      parredminper OUT NUMBER,
      parredminfam OUT NUMBER,
      parretpension OUT NUMBER,
      parretmasdos OUT NUMBER,
      raretprolon OUT VARCHAR2,
      parretmovgeo OUT VARCHAR2,
      pargradodisca OUT NUMBER,
      parlog OUT VARCHAR2) IS
   BEGIN
      parretanual := pac_irpf.pretanual;
      parreduccion := pac_irpf.preduccion;
      parsitfam := pac_irpf.psitfam;
      partiporet := pac_irpf.ptiporet;
      parretanu := pac_irpf.pretanu;
      parhijos := pac_irpf.phijos;
      pardescen1625 := pac_irpf.pdescen1625;
      parretdescen316 := pac_irpf.pretdescen316;
      parretdescen3 := pac_irpf.pretdescen3;
      parretdesdis33 := pac_irpf.pretdesdis33;
      parretdesdis65 := pac_irpf.pretdesdis65;
      parretabuelos := pac_irpf.pretabuelos;
      parredneto := pac_irpf.predneto;
      parredminper := pac_irpf.predminper;
      parredminfam := pac_irpf.predminfam;
      parretpension := pac_irpf.pretpension;
      parretmasdos := pac_irpf.pretmasdos;
      raretprolon := pac_irpf.pretprolon;
      parretmovgeo := pac_irpf.pretmovgeo;
      parlog := pac_irpf.plog;
   END p_hoja_irpf;

   FUNCTION f_calret_irpf(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pplan IN NUMBER,
      pfecha IN DATE,
      psaldo IN NUMBER,
      pimppago IN NUMBER,
      pretensn IN VARCHAR2,
      pporreten IN NUMBER,
      pretencion OUT NUMBER)
      RETURN NUMBER IS
--******************************************************************
--******************************************************************
--******************************************************************
--******* CALCULO DE LAS REDUCCIÓNES Y RETENCIONES DEL IRPF ********
--******************************************************************
--******************************************************************
--******************************************************************
      fecha_accion   DATE;
      moneda         NUMBER(1);

      CURSOR c_prespen IS
         SELECT importe, npartot, ctipcap, cperiod, finicio, ireducsn, nparant2007
           FROM planbenefpresta, prestaplan
          WHERE prestaplan.sseguro = psseguro
            AND prestaplan.sprestaplan = pplan
            AND prestaplan.sprestaplan = planbenefpresta.sprestaplan
            AND planbenefpresta.sperson = psperson
            AND TO_CHAR(finicio, 'YYYY') = TO_CHAR(pfecha, 'YYYY')
            AND NVL(planbenefpresta.cestado, 0) = 1;

      CURSOR c_prespenagrup(agrupacion IN NUMBER) IS
         SELECT importe, npartot, ctipcap, cperiod, finicio, ireducsn, nparant2007
           FROM prestaplan, seguros, parproductos, planbenefpresta
          WHERE prestaplan.sprestaplan = planbenefpresta.sprestaplan
            AND seguros.sseguro = prestaplan.sseguro
            AND seguros.sproduc = parproductos.sproduc
            AND parproductos.cparpro = 'AGRUPRODIRPF'
            AND parproductos.cvalpar = agrupacion
            AND planbenefpresta.sperson = psperson
            AND TO_CHAR(finicio, 'YYYY') = TO_CHAR(pfecha, 'YYYY')
            AND NVL(planbenefpresta.cestado, 0) = 1;

      prespen        c_prespen%ROWTYPE;

      CURSOR c_familia IS
         SELECT   sperson, fnacimi, cgrado, center
             FROM irpfdescendientes
            WHERE sperson = psperson
              AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) <=
                                                                                             25
                  OR cgrado IN(1, 2))
         ORDER BY fnacimi DESC;

      familia        c_familia%ROWTYPE;

      CURSOR c_abuelos IS
         SELECT sperson, fnacimi, cgrado, crenta, nviven
           FROM irpfmayores
          WHERE sperson = psperson
            AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) >=
                                                                                             65
                OR cgrado IN(1, 2));

      abuelos        c_abuelos%ROWTYPE;

      CURSOR c_cuadro IS
         SELECT   DECODE(moneda, 2, ROUND(ibase * 166.386), ibase) "IBASE",
                  DECODE(moneda, 2, ROUND(icuota * 166.386), icuota) "ICUOTA",
                  DECODE(moneda, 2, ROUND(iresto * 166.386), itipo) "IRESTO", itipo
             FROM irpfcuadro
         ORDER BY ibase DESC;

      cuadro         c_cuadro%ROWTYPE;
      expresion      VARCHAR2(100);
      prolongacion   NUMBER(1);
      movilidad      NUMBER(1);
      sechijos       NUMBER(2);
      retorno        NUMBER;
      mulhijo        NUMBER(1);
      err            NUMBER;
      pension        NUMBER(25, 10);
      imp_prolongacion NUMBER(25, 10);
      imp_movilidad  NUMBER(25, 10);
      mayor_edad     NUMBER(25, 10);
      masdos         NUMBER(25, 10);
      filas          INTEGER;
      cuantos        NUMBER(6);
      prestaciones_pagadas NUMBER(25, 2);
      anualidades    NUMBER(25, 2);
      retenciones_pagadas NUMBER(25, 2);
      reduccion_anterior NUMBER(25, 2);
      importe_invalidez_hijos NUMBER(25, 2);
      importe_invalidez_abuelos NUMBER(25, 2);
      importe_invalidez_benef NUMBER(25, 2);
      prestaciones_pendientes NUMBER(25, 2);
      porcentaje_retencion NUMBER(25, 2);
      tipo_hasta_final_anio NUMBER(25, 2);
      rendimiento_anual NUMBER(25, 2);
      rendimiento_anual_porcen NUMBER(25, 2);
      importe_minimo_excluido NUMBER(25, 2);
      importe_reduccion NUMBER(25, 2);
      retencion_pendiente NUMBER(25, 2);
      importe_saldo  NUMBER(25, 2);
      importe_personal NUMBER(25, 2);
      importe_familiar NUMBER(25, 2);
      pase_anualidades NUMBER(1);
      pase_base      NUMBER(1);
      importe_pago   NUMBER(25, 2);
      base_imponible NUMBER(25, 2);
      importe_hijos  NUMBER(25, 2);
      importe_abuelos NUMBER(25, 2);
      importe_total_hijos NUMBER(25, 2);
      importe_total_abuelos NUMBER(25, 2);
      cuota          NUMBER(25, 2);
      cuota_integra  NUMBER(25, 2);
      hijos          NUMBER(4);
      bruto          NUMBER(25, 2);
      valor_participacion NUMBER(25, 6);
      nulo           NUMBER(25, 6);
      periodos       NUMBER(2);
      contingencia   NUMBER(1);
      antiguedad     DATE;
      antiguedad_tras DATE;
      tabla_importe  NUMBER(25, 10);
      tabla_formula  VARCHAR2(100);
      grado          NUMBER(1);
      ayuda          NUMBER(1);
      situacion      NUMBER(1);
      edad           NUMBER(3);
      edad_hijo      NUMBER(3);
      edad_abuelo    NUMBER(3);
      ncursor        INTEGER;
      fecha_nacimiento DATE;
      error          NUMBER(8);
      error_fecha    NUMBER(8);
      fecha_valoracion DATE := f_sysdate;
      excepcion_salir EXCEPTION;
      excepcion_nosepuede EXCEPTION;
      excepcion_irpf_2007 EXCEPTION;
      importe_sin_retencion NUMBER;
      impret_total   NUMBER;
      impret_pendiente NUMBER;
      agruprod       NUMBER;
      retval         NUMBER;
      pnparant2007   NUMBER;
      pnparpos2006   NUMBER;
      pnparret       NUMBER;
      cerror         NUMBER;
      lerror         VARCHAR2(100);
      xparti         NUMBER;
   BEGIN
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

      -- Buscamos la Fecha de Acción del Parte de Prestacion
      SELECT faccion
        INTO fecha_accion
        FROM prestaplan
       WHERE sprestaplan = pplan;

      -- bUSCAMOS SI TIENE AGRUPACIÓN
      BEGIN
         SELECT cvalpar
           INTO agruprod
           FROM parproductos, seguros
          WHERE parproductos.sproduc = seguros.sproduc
            AND parproductos.cparpro = 'AGRUPRODIRPF'
            AND seguros.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            agruprod := NULL;
      END;

      error := 0;
      prestaciones_pendientes := 0;

      -- *** Sumamos las prestaciones(A) y retenciones(B) pagadas del beneficiario
      -- Cambiamos la Select para que no sume las prestaciones
      -- anuladas.
      IF agruprod IS NULL THEN
         SELECT NVL(SUM(iimporte), 0), NVL(SUM(irpf_prestaciones.iretenc), 0),
                SUM(NVL(iretenc, 0))
           INTO prestaciones_pagadas, retenciones_pagadas,
                importe_sin_retencion
           FROM prestaplan, irpf_prestaciones, ctaseguro
          WHERE ctaseguro.sidepag = irpf_prestaciones.sidepag
            AND irpf_prestaciones.sprestaplan = prestaplan.sprestaplan
            AND prestaplan.sseguro = ctaseguro.sseguro
            AND irpf_prestaciones.sprestaplan = pplan
            AND irpf_prestaciones.sperson = psperson
            AND ctaseguro.cmovanu = 0
            AND TO_CHAR(fpago, 'YYYY') = TO_CHAR(f_sysdate, 'YYYY');
      ELSE
         SELECT /*+ RULE */
                NVL(SUM(iimporte), 0), NVL(SUM(irpf_prestaciones.iretenc), 0),
                SUM(NVL(iretenc, 0))
           INTO prestaciones_pagadas, retenciones_pagadas,
                importe_sin_retencion
           FROM prestaplan, irpf_prestaciones, ctaseguro, seguros, parproductos
          WHERE ctaseguro.sidepag = irpf_prestaciones.sidepag
            AND irpf_prestaciones.sprestaplan = prestaplan.sprestaplan
            AND prestaplan.sseguro = ctaseguro.sseguro
            AND irpf_prestaciones.sperson = psperson
            AND seguros.sseguro = ctaseguro.sseguro
            AND seguros.sproduc = parproductos.sproduc
            AND parproductos.cparpro = 'AGRUPRODIRPF'
            AND parproductos.cvalpar = agruprod
            AND ctaseguro.cmovanu = 0
            AND TO_CHAR(fpago, 'YYYY') = TO_CHAR(f_sysdate, 'YYYY');
      END IF;

      -- *** Sumamos las prestaciones pendientes de pagar (A')
      IF agruprod IS NULL THEN
         OPEN c_prespen;
      ELSE
         OPEN c_prespenagrup(agruprod);
      END IF;

      LOOP
         IF agruprod IS NULL THEN
            FETCH c_prespen
             INTO prespen;

            EXIT WHEN c_prespen%NOTFOUND;
         ELSE
            FETCH c_prespenagrup
             INTO prespen;

            EXIT WHEN c_prespenagrup%NOTFOUND;
         END IF;

         -- *** Si la forma de pago es de capital el valor de la participació
         -- *** es el día de hoy
         IF prespen.ctipcap = 1
            AND NVL(prespen.importe, 0) = 0 THEN
            valor_participacion := f_valor_participlan(pfecha, psseguro, moneda);

            IF valor_participacion = -1 THEN
               RAISE excepcion_salir;
            END IF;

            fecha_valoracion := prespen.finicio;
         ELSIF prespen.ctipcap = 2
               AND NVL(prespen.importe, 0) = 0 THEN
            valor_participacion := f_valor_participlan(pfecha, psseguro, moneda);

            IF valor_participacion = -1 THEN
               RAISE excepcion_salir;
            END IF;

            fecha_valoracion := f_sysdate;
         ELSIF prespen.ctipcap = 2
               AND NVL(prespen.importe, 0) > 0 THEN
            fecha_valoracion := prespen.finicio;
         ELSIF prespen.ctipcap = 1
               AND NVL(prespen.importe, 0) > 0 THEN
            fecha_valoracion := prespen.finicio;
            valor_participacion := f_valor_participlan(pfecha, psseguro, moneda);

            IF pac_fisc_pp_2007.f_part_pres(psseguro, fecha_accion, pnparant2007,
                                            pnparpos2006, pnparret, cerror, lerror) = 0 THEN
               xparti := ROUND(pimppago / valor_participacion, 6);

               IF xparti > pnparant2007 THEN
                  prespen.nparant2007 := pnparant2007;
               ELSE
                  prespen.nparant2007 := xparti;
               END IF;
            ELSE
               RAISE excepcion_irpf_2007;
            END IF;
         END IF;

         SELECT cdivisa
           INTO moneda
           FROM seguros, productos
          WHERE seguros.sseguro = psseguro
            AND seguros.cramo = productos.cramo
            AND seguros.cmodali = productos.cmodali
            AND seguros.ctipseg = productos.ctipseg
            AND seguros.ccolect = productos.ccolect;

         IF NVL(prespen.importe, 0) = 0 THEN
            importe_pago := ROUND(prespen.npartot * valor_participacion, 2);
         ELSE
            importe_pago := prespen.importe;
         END IF;

         --*** Calculamos los períodos que nos quedan
         SELECT DECODE(prespen.cperiod,
                       1, 1,
                       2, TRUNC((12 - TO_NUMBER(TO_CHAR(prespen.finicio, 'MM')) + 1) / 6),
                       4, TRUNC((12 - TO_NUMBER(TO_CHAR(prespen.finicio, 'MM')) + 1) / 3),
                       6, TRUNC((12 - TO_NUMBER(TO_CHAR(prespen.finicio, 'MM')) + 1) / 2),
                       12, TRUNC((12 - TO_NUMBER(TO_CHAR(prespen.finicio, 'MM')) + 1) / 1),
                       NULL, 1)
           INTO periodos
           FROM DUAL;

         periodos := NVL(periodos, 0);

         -- *** Prestación por capital único, en participaciones
         IF prespen.ctipcap = 1
            AND prespen.cperiod IS NULL THEN
            IF NVL(prespen.importe, 0) > 0 THEN
               prestaciones_pendientes := prestaciones_pendientes
                                          +(prespen.importe * periodos);
            ELSIF NVL(prespen.npartot, 0) > 0 THEN
               prestaciones_pendientes := prestaciones_pendientes
                                          + ROUND(prespen.npartot * valor_participacion, 2);
            END IF;
         -- *** Prestación por capital períodico en participaciones o importe
         ELSIF prespen.ctipcap = 1
               AND prespen.cperiod IS NOT NULL THEN
            IF NVL(prespen.importe, 0) > 0 THEN
               prestaciones_pendientes := prestaciones_pendientes
                                          +(prespen.importe * periodos);
            ELSIF NVL(prespen.npartot, 0) > 0 THEN
               prestaciones_pendientes := prestaciones_pendientes
                                          +(ROUND(prespen.npartot * valor_participacion, 2)
                                            * periodos);
            END IF;
         -- *** Prestación por renta en participaciones o importe
         ELSIF prespen.ctipcap = 2
               AND prespen.cperiod IS NOT NULL THEN
            IF NVL(prespen.importe, 0) > 0 THEN
               prestaciones_pendientes := prestaciones_pendientes
                                          +(prespen.importe * periodos);
            ELSIF NVL(prespen.npartot, 0) > 0 THEN
               prestaciones_pendientes := prestaciones_pendientes
                                          +(ROUND(prespen.npartot * valor_participacion, 2)
                                            * periodos);
            END IF;
         END IF;

         SELECT ctipren
           INTO contingencia
           FROM prestaplan
          WHERE prestaplan.sprestaplan = pplan;

         SELECT fefecto
           INTO antiguedad
           FROM seguros
          WHERE seguros.sseguro = psseguro;

         SELECT MIN(fantigi)
           INTO antiguedad_tras
           FROM trasplainout
          WHERE cinout = 1
            AND sseguro = psseguro
            AND cestado IN(3, 4)
            AND fantigi IS NOT NULL;

         IF antiguedad > antiguedad_tras THEN
            antiguedad := antiguedad_tras;
         END IF;

--*************************************************************************
--*************************************************************************
--               IIIIIIIIII RRRRRRRRRR PPPPPPPPPP FFFFFFFFFF
--                   II     RR      RR PP      PP FF
--                   II     RR      RR PP      PP FF
--                   II     RRRRRRRRRR PPPPPPPPPP FFFFFFF
--                   II     RRRR       PP         FF
--                   II     RR RR      PP         FF
--                   II     RR  RR     PP         FF
--               IIIIIIIIII RR   RR    PP         FF
--*************************************************************************
--*************************************************************************
--*** Nuevo Calculo de la retención
--*************************************************************************

         --*************************************************************************
--   I. DETERMINACIÓN DE LA BASE DE RETENCIÓN
--*************************************************************************
--   MINORACIONES.
--   Reducciones por irregularidad ( Apartado 1 )
--*************************************************************************
      --***************************************************************
      --*** Si la contingencia no es invalidez y es en forma de capital
      --*** y la antiguedad del plan es superior a 2 años.
      --*** se aplica una reducción del 40% sobre el bruto.
      --*** NUEVO JAMR - 2003
      --*** En el caso de contingencia por invalidez, será el 50% --NO
      --*** Quan el partícep és invàlid la reducció serà del 50%
      --***************************************************************
         IF prespen.ctipcap = 1
            AND((contingencia <> 2
                 AND ADD_MONTHS(antiguedad, 24) < fecha_accion)
                OR contingencia = 2) THEN
            IF agruprod IS NULL THEN
               SELECT COUNT(*)
                 INTO cuantos
                 FROM irpf_prestaciones
                WHERE sprestaplan = pplan
                  AND sperson = psperson
                  AND ireduc > 0;
            ELSE
               SELECT /*+ RULE */
                      COUNT(*)
                 INTO cuantos
                 FROM parproductos, irpf_prestaciones, ctaseguro, seguros
                WHERE irpf_prestaciones.sperson = psperson
                  AND irpf_prestaciones.sidepag = ctaseguro.sidepag
                  AND ctaseguro.sseguro = seguros.sseguro
                  AND seguros.sproduc = parproductos.sproduc
                  AND parproductos.cparpro = 'AGRUPRODIRPF'
                  AND parproductos.cvalpar = agruprod
                  AND ireduc > 0;
            END IF;

            IF agruprod IS NULL THEN
               SELECT SUM(NVL(ireduc, 0))
                 INTO reduccion_anterior
                 FROM irpf_prestaciones
                WHERE sprestaplan = pplan
                  AND sperson = psperson
                  AND TO_CHAR(fpago, 'YYYY') = TO_CHAR(fecha_valoracion, 'YYYY')
                  AND ireduc > 0;
            ELSE
               SELECT /*+ RULE */
                      SUM(NVL(ireduc, 0))
                 INTO reduccion_anterior
                 FROM parproductos, irpf_prestaciones, ctaseguro, seguros
                WHERE irpf_prestaciones.sperson = psperson
                  AND irpf_prestaciones.sidepag = ctaseguro.sidepag
                  AND ctaseguro.sseguro = seguros.sseguro
                  AND seguros.sproduc = parproductos.sproduc
                  AND parproductos.cparpro = 'AGRUPRODIRPF'
                  AND parproductos.cvalpar = agruprod
                  AND TO_CHAR(fpago, 'YYYY') = TO_CHAR(fecha_valoracion, 'YYYY')
                  AND ireduc > 0;
            END IF;

            --*** Si no tiene ya una reducción se la aplicamos.
            IF (cuantos = 0
                OR reduccion_anterior = 0)
               AND prespen.ireducsn = 'S' THEN
               ----Mirem si el partícep/beneficiari és invàlid
               DECLARE
                  vestado        personas.cestado%TYPE;
               BEGIN
                  SELECT a.cestado
                    INTO vestado
                    FROM personas a, riesgos b
                   WHERE b.sseguro = psseguro
                     AND a.sperson = b.sperson
                     AND b.nriesgo = 1;

/*                  IF vestado = 1 THEN
                     importe_reduccion  :=
                                      ROUND (((importe_pago * 50) / 100), 2);
                  ELSE
                     importe_reduccion  :=
                                      ROUND (((importe_pago * 40) / 100), 2);
                  END IF;*/
                  IF vestado = 1 THEN
                     importe_reduccion := ROUND(((ROUND(prespen.nparant2007
                                                        * valor_participacion,
                                                        2)
                                                  * 50)
                                                 / 100),
                                                2);
                  ELSE
                     importe_reduccion := ROUND(((ROUND(prespen.nparant2007
                                                        * valor_participacion,
                                                        2)
                                                  * 40)
                                                 / 100),
                                                2);
                  END IF;
               END;
            END IF;
         END IF;
      END LOOP;

      IF agruprod IS NULL THEN
         CLOSE c_prespen;
      ELSE
         CLOSE c_prespenagrup;
      END IF;

      --***Sempre calculem la reducció anterior per a tenir-la en compte en el
      --***càlcul de la base imponible
      IF agruprod IS NULL THEN
         SELECT SUM(NVL(ireduc, 0))
           INTO reduccion_anterior
           FROM irpf_prestaciones
          WHERE sprestaplan = pplan
            AND sperson = psperson
            AND TO_CHAR(fpago, 'YYYY') = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ireduc > 0;
      ELSE
         SELECT /*+ RULE */
                SUM(NVL(ireduc, 0))
           INTO reduccion_anterior
           FROM seguros, ctaseguro, irpf_prestaciones, parproductos
          WHERE irpf_prestaciones.sperson = psperson
            AND irpf_prestaciones.sidepag = ctaseguro.sidepag
            AND ctaseguro.sseguro = seguros.sseguro
            AND seguros.sproduc = parproductos.sproduc
            AND parproductos.cparpro = 'AGRUPRODIRPF'
            AND parproductos.cvalpar = agruprod
            AND TO_CHAR(fpago, 'YYYY') = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ireduc > 0;
      END IF;

      --*** Si el saldo es 0 es que esta es la última prestacion
      --*** con lo cual el importe pendiente es el de esta prestación
      IF NVL(psaldo, 0) = 0 THEN
         prestaciones_pendientes := pimppago;
      END IF;

      rendimiento_anual := prestaciones_pagadas + prestaciones_pendientes;
      pretanual := NVL(rendimiento_anual, 0);
      bruto := NVL(rendimiento_anual, 0) - NVL(importe_reduccion, 0)
               - NVL(reduccion_anterior, 0);
      preduccion := NVL(importe_reduccion, 0);
--***************************************************************************
--*** MINORACIONES.
--*** Reducción por rendimiento de trabajo ( Apartado 5 ).
--***************************************************************************
--*** Asignamos la reducción del rendimiento neto del trabajo segun la tabla
      error := 1;

      SELECT iimporte, iformula
        INTO tabla_importe, tabla_formula
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 1
         AND bruto BETWEEN idesde AND ihasta;

      IF tabla_formula IS NOT NULL THEN
         error := 2;

         SELECT REPLACE(tabla_formula, 'RNT',
                        DECODE(moneda, 2, ROUND(bruto / 166.386, 2), bruto))
           INTO tabla_formula
           FROM DUAL;

         tabla_formula := REPLACE(tabla_formula, ',', '.');

         SELECT ROUND(evalselect(tabla_formula), 2)
           INTO tabla_importe
           FROM DUAL;
      ELSE
         SELECT DECODE(moneda, 2, ROUND(tabla_importe * 166.386), tabla_importe)
           INTO tabla_importe
           FROM DUAL;
      END IF;

      plog := plog || '
Apartado 5 AEAT :' || tabla_importe;

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por prolongación de la actividad laboral
--*** (Apartado 6 que depende del Apartado 5 ).
--***************************************************************************
      SELECT cgrado, csitfam, cayuda, ipension, ianuhijos, rmovgeo, prolon
        INTO grado, situacion, ayuda, pension, anualidades, movilidad, prolongacion
        FROM irpfpersonas
       WHERE sperson = psperson;

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

      plog := plog || '
Apartado 6+5 AEAT :' || imp_prolongacion;

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por movilidad geográfica ( Apartado 7 Depende del Apartado 5).
--***************************************************************************
      IF movilidad = 1 THEN
         imp_movilidad := tabla_importe;
      END IF;

      plog := plog || ' Apartado 7+5 AEAT :' || imp_movilidad;

   --***************************************************************************
   --*** MINORACIONES.
   --*** Reducción por discapacidad de trabajadores activos ( Apartado 8 )
   --***************************************************************************
/*
   ERROR := 3;

   :RET_SITFAM := SITUACION;

   IF AYUDA = 1 THEN
      TABLA_IMPORTE := TABLA_IMPORTE * 2.25;
   ELSIF GRADO = 1 THEN
      TABLA_IMPORTE := TABLA_IMPORTE * (1.75);
   ELSIF GRADO = 2 THEN
      TABLA_IMPORTE := TABLA_IMPORTE * 2.75;
   END IF;
*/

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

--***************************************************************************
--*** MINORACIONES.
--*** Mínimo personal ( Apartado 3 )
--***************************************************************************
      error := 4;

      SELECT fnacimi
        INTO fecha_nacimiento
        FROM personas
       WHERE sperson = psperson;

      error_fecha := f_difdata(fecha_nacimiento, f_sysdate, 2, 1, edad);
      error := 5;

      SELECT DECODE(moneda,
                    2, ROUND(DECODE(grado, 1, iinv1, 2, iinv2, iimporte) * 166.386),
                    DECODE(grado, 1, iinv1, 2, iinv2, iimporte))
        INTO importe_personal
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 2
         AND edad BETWEEN idesde AND ihasta;

      plog := plog || '
Mínimo personal Art.3 AEAT:' || importe_personal;
--***************************************************************************
--*** MINORACIONES.
--*** Mínimo por descendientes ( Apartado 4 )
--***************************************************************************
      error := 6;

      SELECT NVL(COUNT(*), 0)
        INTO hijos
        FROM irpfdescendientes
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

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por cuidado de hijos ( Apartado 9 )
--***************************************************************************
         BEGIN
            error_fecha := f_difdata(familia.fnacimi, f_sysdate, 2, 1, edad_hijo);

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
--*** MINORACIONES.
--*** Reducciones por edad ( Apartado 10 )
--*** Reducciones por asistencia ( Apartado 11 )
--***************************************************************************
--*********************************
--**** Opcion A - Del contribuyente
--*********************************
      BEGIN
         SELECT iimporte
           INTO mayor_edad
           FROM irpftablas
          WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ntipo = 7
            AND edad BETWEEN idesde AND ihasta;

         plog := plog || '
   Reducción ART.10/11-A. AEAT:' || mayor_edad;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            mayor_edad := 0;
      END;

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

      pretabuelos := NVL(importe_total_abuelos, 0);
      error := 9;

      --*** Si los hijos son mas de 2 resta 600 euros
      IF hijos > 2 THEN
         SELECT DECODE(moneda, 2, 100000, 600)
           INTO masdos
           FROM DUAL;
      END IF;

      plog := plog || '
Mas de 2 hijos ART.14 AEAT:' || masdos;

      -- Reducción invalidez para el contribuyente
      BEGIN
         SELECT iimporte
           INTO importe_invalidez_benef
           FROM irpftablas
          WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ntipo = 8
            AND grado BETWEEN idesde AND ihasta;
      EXCEPTION
         WHEN OTHERS THEN
            importe_invalidez_benef := 0;
      END;

      plog := plog || 'Reducción invalidez Contribuyente art. 12 AEAT: '
              || importe_invalidez_benef;
--*************************************************************************
--   II. DETERMINACIÓN DE LA CUOTA DE RETENCIÓN
--*************************************************************************
      base_imponible := bruto - NVL(tabla_importe, 0) - NVL(imp_prolongacion, 0)
                        - NVL(imp_movilidad, 0) - NVL(mayor_edad, 0) - NVL(importe_personal, 0)
                        - NVL(importe_familiar, 0) - NVL(importe_total_hijos, 0)
                        - NVL(importe_invalidez_hijos, 0) - NVL(pension, 0)
                        - NVL(anualidades, 0) - NVL(masdos, 0) - NVL(importe_total_abuelos, 0)
                        - NVL(importe_invalidez_abuelos, 0) - NVL(importe_invalidez_benef, 0);
      predneto := NVL(tabla_importe, 0);
      predminper := NVL(importe_personal, 0);
      predminfam := NVL(importe_total_hijos, 0) + NVL(importe_familiar, 0);
      pretpension := NVL(pension, 0);
      pretmasdos := NVL(masdos, 0);

      IF base_imponible < 0 THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

      error := 10;
      --*** Miramos la cuota integra;
      pase_anualidades := 0;
      pase_base := 0;

      OPEN c_cuadro;

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

      -- *** Rendimiento anual
      SELECT DECODE(moneda, 2, ROUND(iimporte * 166.386), iimporte)
        INTO importe_saldo
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 5;

      IF rendimiento_anual < importe_saldo THEN
         SELECT DECODE(moneda, 2, ROUND(iimporte * 166.386), iimporte)
           INTO importe_minimo_excluido
           FROM irpfcuadrohijos
          WHERE csituac = situacion
            AND NVL(hijos, 0) BETWEEN nhijdes AND nhijhas;

         rendimiento_anual_porcen := ROUND((rendimiento_anual - importe_minimo_excluido)
                                           *(43 / 100),
                                           2);

         IF cuota_integra > rendimiento_anual_porcen THEN
            cuota_integra := rendimiento_anual_porcen;
         END IF;
      END IF;

      error := 12;
--*************************************************************************
--   III. DETERMINACIÓN DEL TIPO DE RETENCION
--    IV. DETERMINACIÓN DEL IMPORTE DE LA RETENCION
--*************************************************************************
-- *** Obtenemos el porcentaje de la retención
      porcentaje_retencion := ROUND((cuota_integra / rendimiento_anual) * 100, 0);
      retencion_pendiente := cuota_integra - retenciones_pagadas;

      IF NVL(prestaciones_pendientes, 0) = 0 THEN
         tipo_hasta_final_anio := 0;
      ELSE
         tipo_hasta_final_anio := ROUND((retencion_pendiente / prestaciones_pendientes) * 100,
                                        0);
      END IF;

      -- Si el importe deja el saldo a 0
      tipo_hasta_final_anio := porcentaje_retencion;
      --IF PRetenSN = 'S' AND NVL(PORCENTAJE_RETENCION,0) < PPorReten THEN
      --  IF TO_NUMBER(TO_CHAR(PFecha,'YYYY')) < 2002 THEN
      --     tipo_hasta_final_anio :=  PPorReten;
      -- ELSE
       --    tipo_hasta_final_anio :=  ROUND(PPorReten,0);
      --  END IF;
      --END IF;
      ptiporet := NVL(tipo_hasta_final_anio, 0);

      IF NVL(ptiporet, 0) < 0 THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

      IF NVL(ptiporet, 0) > 0 THEN
         impret_total := ROUND((ptiporet / 100)
                               *(NVL(prestaciones_pagadas, 0) + NVL(prestaciones_pendientes, 0)),
                               2);
         --IMPRET_PENDIENTE := ROUND(( PTIPORET / 100 ) * PRESTACIONES_PAGADAS,2);
         impret_pendiente := NVL(retenciones_pagadas, 0);

         INSERT INTO errores
              VALUES (1,
                      'PTIPORET ' || ptiporet || ' TOTAL ' || impret_total || 'PENDIENTE '
                      || impret_pendiente || ' PRESPEN ' || prestaciones_pendientes);

         COMMIT;
         pretencion := ROUND(((impret_total - impret_pendiente) / prestaciones_pendientes)
                             * 100, 0);
      --IF PRetenSN = 'S' AND NVL(PRETENCION,0) < PPorReten THEN
       --  IF TO_NUMBER(TO_CHAR(PFecha,'YYYY')) < 2002 THEN
       --   PRETENCION :=  PPorReten;
        -- ELSE
       --   PRETENCION :=  ROUND(PPorReten,0);
       --  END IF;
       --END IF;
      ELSE
         pretencion := NVL(ptiporet, 0);
      END IF;

      --pretencion := 3;
      error := 13;
      pretanu := rendimiento_anual *(tipo_hasta_final_anio / 100);
      RETURN 0;
   EXCEPTION
      WHEN excepcion_salir THEN
         pretencion := 0;
         RETURN 0;
      WHEN excepcion_nosepuede THEN
         pretencion := 0;
         RETURN -99;
      WHEN excepcion_irpf_2007 THEN
         pretencion := 0;
         RETURN 500140;
      WHEN OTHERS THEN
         RETURN(-error);
   END f_calret_irpf;

-- ********************************************************************************
-- simulacion simulacion simulacion simulacion simulacion simulacion
-- simulacion simulacion simulacion simulacion simulacion simulacion
-- ********************************************************************************
   FUNCTION f_simula_irpf_renta(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      psesion IN NUMBER,
      pretencion OUT NUMBER)
      RETURN NUMBER IS
--******************************************************************
--******************************************************************
--******************************************************************
--******* CALCULO DE LAS REDUCCIÓNES Y RETENCIONES DEL IRPF ********
--******************************************************************
--******************************************************************
--******************************************************************
      fecha_accion   DATE;
      moneda         NUMBER(1);

      CURSOR c_prespen IS
         SELECT periodica, extra
           FROM simulapp
          WHERE sesion = psesion;

      prespen        c_prespen%ROWTYPE;

      CURSOR c_familia IS
         SELECT   sperson, fnacimi, cgrado, center
             FROM irpfdescendientes
            WHERE sperson = psperson
              AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) <=
                                                                                             25
                  OR cgrado IN(1, 2))
         ORDER BY fnacimi DESC;

      familia        c_familia%ROWTYPE;

      CURSOR c_abuelos IS
         SELECT sperson, fnacimi, cgrado, crenta, nviven
           FROM irpfmayores
          WHERE sperson = psperson
            AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) >=
                                                                                             65
                OR cgrado IN(1, 2));

      abuelos        c_abuelos%ROWTYPE;

      CURSOR c_cuadro IS
         SELECT   DECODE(moneda, 2, ROUND(ibase * 166.386), ibase) "IBASE",
                  DECODE(moneda, 2, ROUND(icuota * 166.386), icuota) "ICUOTA",
                  DECODE(moneda, 2, ROUND(iresto * 166.386), itipo) "IRESTO", itipo
             FROM irpfcuadro
         ORDER BY ibase DESC;

      cuadro         c_cuadro%ROWTYPE;
      expresion      VARCHAR2(100);
      prolongacion   NUMBER(1);
      movilidad      NUMBER(1);
      sechijos       NUMBER(2);
      retorno        NUMBER;
      mulhijo        NUMBER(1);
      err            NUMBER;
      pension        NUMBER(25, 10);
      imp_prolongacion NUMBER(25, 10);
      imp_movilidad  NUMBER(25, 10);
      mayor_edad     NUMBER(25, 10);
      masdos         NUMBER(25, 10);
      filas          INTEGER;
      cuantos        NUMBER(6);
      prestaciones_pagadas NUMBER(25, 2);
      anualidades    NUMBER(25, 2);
      retenciones_pagadas NUMBER(25, 2);
      reduccion_anterior NUMBER(25, 2);
      importe_invalidez_hijos NUMBER(25, 2);
      importe_invalidez_abuelos NUMBER(25, 2);
      importe_invalidez_benef NUMBER(25, 2);
      prestaciones_pendientes NUMBER(25, 2);
      porcentaje_retencion NUMBER(25, 2);
      tipo_hasta_final_anio NUMBER(25, 2);
      rendimiento_anual NUMBER(25, 2);
      rendimiento_anual_porcen NUMBER(25, 2);
      importe_minimo_excluido NUMBER(25, 2);
      importe_reduccion NUMBER(25, 2);
      retencion_pendiente NUMBER(25, 2);
      importe_saldo  NUMBER(25, 2);
      importe_personal NUMBER(25, 2);
      importe_familiar NUMBER(25, 2);
      pase_anualidades NUMBER(1);
      pase_base      NUMBER(1);
      importe_pago   NUMBER(25, 2);
      base_imponible NUMBER(25, 2);
      importe_hijos  NUMBER(25, 2);
      importe_abuelos NUMBER(25, 2);
      importe_total_hijos NUMBER(25, 2);
      importe_total_abuelos NUMBER(25, 2);
      cuota          NUMBER(25, 2);
      cuota_integra  NUMBER(25, 2);
      hijos          NUMBER(4);
      bruto          NUMBER(25, 2);
      valor_participacion NUMBER(25, 6);
      nulo           NUMBER(25, 6);
      periodos       NUMBER(2);
      contingencia   NUMBER(1);
      antiguedad     DATE;
      antiguedad_tras DATE;
      tabla_importe  NUMBER(25, 10);
      tabla_formula  VARCHAR2(100);
      grado          NUMBER(1);
      ayuda          NUMBER(1);
      situacion      NUMBER(1);
      edad           NUMBER(3);
      edad_hijo      NUMBER(3);
      edad_abuelo    NUMBER(3);
      ncursor        INTEGER;
      fecha_nacimiento DATE;
      error          NUMBER(8);
      error_fecha    NUMBER(8);
      fecha_valoracion DATE := f_sysdate;
      excepcion_salir EXCEPTION;
      excepcion_nosepuede EXCEPTION;
   BEGIN
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

      -- Buscamos la Fecha de Acción de la simulación
      SELECT fcontin
        INTO fecha_accion
        FROM simulapp
       WHERE sesion = psesion;

      error := 0;
      prestaciones_pendientes := 0;

      -- *** Sumamos las prestaciones pendientes de pagar (A')
      OPEN c_prespen;

      LOOP
         FETCH c_prespen
          INTO prespen;

         EXIT WHEN c_prespen%NOTFOUND;
         prestaciones_pendientes := NVL(prespen.periodica * 12, 0);
--*************************************************************************
--*************************************************************************
--               IIIIIIIIII RRRRRRRRRR PPPPPPPPPP FFFFFFFFFF
--                   II     RR      RR PP      PP FF
--                   II     RR      RR PP      PP FF
--                   II     RRRRRRRRRR PPPPPPPPPP FFFFFFF
--                   II     RRRR       PP         FF
--                   II     RR RR      PP         FF
--                   II     RR  RR     PP         FF
--               IIIIIIIIII RR   RR    PP         FF
--*************************************************************************

      --*************************************************************************
--   I. DETERMINACIÓN DE LA BASE DE RETENCIÓN
--*************************************************************************
--   MINORACIONES.
--   Reducciones por irregularidad ( Apartado 1 )
--*************************************************************************
      --***************************************************************
      --*** Si la contingencia no es invalidez y es en forma de capital
      --*** y la antiguedad del plan es superior a 2 años.
      --*** se aplica una reducción del 40% sobre el bruto.
      --*** En el caso de contingencia por invalidez, será el 50% --NO
      --*** Quan el partícep és invàlid la reducció serà del 50%
      --***************************************************************
      END LOOP;

      CLOSE c_prespen;

      rendimiento_anual := NVL(prestaciones_pagadas, 0) + NVL(prestaciones_pendientes, 0);
      pretanual := NVL(rendimiento_anual, 0);
      bruto := NVL(rendimiento_anual, 0) - NVL(importe_reduccion, 0)
               - NVL(reduccion_anterior, 0);
      preduccion := NVL(importe_reduccion, 0);
--***************************************************************************
--*** MINORACIONES.
--*** Reducción por rendimiento de trabajo ( Apartado 5 ).
--***************************************************************************
--*** Asignamos la reducción del rendimiento neto del trabajo segun la tabla
      error := 1;

      SELECT iimporte, iformula
        INTO tabla_importe, tabla_formula
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 1
         AND bruto BETWEEN idesde AND ihasta;

      IF tabla_formula IS NOT NULL THEN
         error := 2;

         SELECT REPLACE(tabla_formula, 'RNT',
                        DECODE(moneda, 2, ROUND(bruto / 166.386, 2), bruto))
           INTO tabla_formula
           FROM DUAL;

         tabla_formula := REPLACE(tabla_formula, ',', '.');

         SELECT ROUND(evalselect(tabla_formula), 2)
           INTO tabla_importe
           FROM DUAL;
      ELSE
         SELECT DECODE(moneda, 2, ROUND(tabla_importe * 166.386), tabla_importe)
           INTO tabla_importe
           FROM DUAL;
      END IF;

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por prolongación de la actividad laboral
--*** (Apartado 6 que depende del Apartado 5 ).
--***************************************************************************
      BEGIN
         SELECT cgrado, csitfam, cayuda, ipension, ianuhijos, rmovgeo, prolon
           INTO grado, situacion, ayuda, pension, anualidades, movilidad, prolongacion
           FROM irpfpersonas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
/* - INICI -
ATS5656 - 25/5/2006
Si no encuentra registro poner situacion = 3 para que pueda calcular la retencion.
Con situacion = 3 se calcula el máximo de retencion
*/
--            NULL;
            situacion := 3;
-- FI
      END;

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

      plog := plog || '
Apartado 6+5 AEAT :' || imp_prolongacion;

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por movilidad geográfica ( Apartado 7 Depende del Apartado 5).
--***************************************************************************
      IF movilidad = 1 THEN
         imp_movilidad := tabla_importe;
      END IF;

      plog := plog || ' Apartado 7+5 AEAT :' || imp_movilidad;

   --***************************************************************************
   --*** MINORACIONES.
   --*** Reducción por discapacidad de trabajadores activos ( Apartado 8 )
   --***************************************************************************
/*
   ERROR := 3;

   :RET_SITFAM := SITUACION;

   --               - En el caso de que se active se ha de modificar los
   --                    porcentajes segun el nuevo IRPF por importes.

   IF AYUDA = 1 THEN
      TABLA_IMPORTE := TABLA_IMPORTE * 2.25;
   ELSIF GRADO = 1 THEN
      TABLA_IMPORTE := TABLA_IMPORTE * (1.75);
   ELSIF GRADO = 2 THEN
      TABLA_IMPORTE := TABLA_IMPORTE * 2.75;
   END IF;
*/

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

--***************************************************************************
--*** MINORACIONES.
--*** Mínimo personal ( Apartado 3 )
--***************************************************************************
      error := 4;

      SELECT fnacimi
        INTO fecha_nacimiento
        FROM personas
       WHERE sperson = psperson;

      error_fecha := f_difdata(fecha_nacimiento, f_sysdate, 2, 1, edad);
      error := 5;

      SELECT DECODE(moneda,
                    2, ROUND(DECODE(grado, 1, iinv1, 2, iinv2, iimporte) * 166.386),
                    DECODE(grado, 1, iinv1, 2, iinv2, iimporte))
        INTO importe_personal
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 2
         AND edad BETWEEN idesde AND ihasta;

      plog := plog || '
Mínimo personal Art.3 AEAT:' || importe_personal;
--***************************************************************************
--*** MINORACIONES.
--*** Mínimo por descendientes ( Apartado 4 )
   --***************************************************************************
      error := 6;

      SELECT NVL(COUNT(*), 0)
        INTO hijos
        FROM irpfdescendientes
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

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por cuidado de hijos ( Apartado 9 )
--***************************************************************************
         BEGIN
            error_fecha := f_difdata(familia.fnacimi, f_sysdate, 2, 1, edad_hijo);

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
--*** MINORACIONES.
--*** Reducciones por edad ( Apartado 10 )
--*** Reducciones por asistencia ( Apartado 11 )
--***************************************************************************
--*********************************
--**** Opcion A - Del contribuyente
--*********************************
      BEGIN
         SELECT iimporte
           INTO mayor_edad
           FROM irpftablas
          WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ntipo = 7
            AND edad BETWEEN idesde AND ihasta;

         plog := plog || '
   Reducción ART.10/11-A. AEAT:' || mayor_edad;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            mayor_edad := 0;
      END;

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

      pretabuelos := NVL(importe_total_abuelos, 0);
      error := 9;

      --*** Si los hijos son mas de 2 resta 600 euros
      IF hijos > 2 THEN
         SELECT DECODE(moneda, 2, 100000, 600)
           INTO masdos
           FROM DUAL;
      END IF;

      plog := plog || '
Mas de 2 hijos ART.14 AEAT:' || masdos;

      -- Reducción invalidez para el contribuyente
      BEGIN
         SELECT iimporte
           INTO importe_invalidez_benef
           FROM irpftablas
          WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ntipo = 8
            AND grado BETWEEN idesde AND ihasta;
      EXCEPTION
         WHEN OTHERS THEN
            importe_invalidez_benef := 0;
      END;

      plog := plog || 'Reducción invalidez Contribuyente art. 12 AEAT: '
              || importe_invalidez_benef;
--*************************************************************************
--   II. DETERMINACIÓN DE LA CUOTA DE RETENCIÓN
--*************************************************************************
      base_imponible := bruto - NVL(tabla_importe, 0) - NVL(imp_prolongacion, 0)
                        - NVL(imp_movilidad, 0) - NVL(mayor_edad, 0) - NVL(importe_personal, 0)
                        - NVL(importe_familiar, 0) - NVL(importe_total_hijos, 0)
                        - NVL(importe_invalidez_hijos, 0) - NVL(pension, 0)
                        - NVL(anualidades, 0) - NVL(masdos, 0) - NVL(importe_total_abuelos, 0)
                        - NVL(importe_invalidez_abuelos, 0) - NVL(importe_invalidez_benef, 0);
      predneto := NVL(tabla_importe, 0);
      predminper := NVL(importe_personal, 0);
      predminfam := NVL(importe_total_hijos, 0) + NVL(importe_familiar, 0);
      pretpension := NVL(pension, 0);
      pretmasdos := NVL(masdos, 0);

      IF base_imponible < 0 THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

      error := 10;
      --*** Miramos la cuota integra;
      pase_anualidades := 0;
      pase_base := 0;

      OPEN c_cuadro;

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

      -- *** Rendimiento anual
      SELECT DECODE(moneda, 2, ROUND(iimporte * 166.386), iimporte)
        INTO importe_saldo
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 5;

      IF rendimiento_anual < importe_saldo THEN
         SELECT DECODE(moneda, 2, ROUND(iimporte * 166.386), iimporte)
           INTO importe_minimo_excluido
           FROM irpfcuadrohijos
          WHERE csituac = situacion
            AND NVL(hijos, 0) BETWEEN nhijdes AND nhijhas;

         rendimiento_anual_porcen := ROUND((rendimiento_anual - importe_minimo_excluido)
                                           *(43 / 100),
                                           2);

         IF cuota_integra > rendimiento_anual_porcen THEN
            cuota_integra := rendimiento_anual_porcen;
         END IF;
      END IF;

      error := 12;
--*************************************************************************
--   III. DETERMINACIÓN DEL TIPO DE RETENCION
--    IV. DETERMINACIÓN DEL IMPORTE DE LA RETENCION
--*************************************************************************
-- *** Obtenemos el porcentaje de la retención
      porcentaje_retencion := ROUND((cuota_integra / rendimiento_anual) * 100, 0);
      retencion_pendiente := cuota_integra - retenciones_pagadas;

      IF NVL(prestaciones_pendientes, 0) = 0 THEN
         tipo_hasta_final_anio := 0;
      ELSE
         tipo_hasta_final_anio := ROUND((retencion_pendiente / prestaciones_pendientes) * 100,
                                        0);
      END IF;

      -- Si el importe deja el saldo a 0
      tipo_hasta_final_anio := porcentaje_retencion;
      ptiporet := NVL(tipo_hasta_final_anio, 0);

      IF NVL(ptiporet, 0) < 0 THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

      pretencion := NVL(ptiporet, 0);
      error := 13;
      pretanu := rendimiento_anual *(tipo_hasta_final_anio / 100);
      RETURN 0;
   EXCEPTION
      WHEN excepcion_salir THEN
         pretencion := 0;
         RETURN 0;
      WHEN excepcion_nosepuede THEN
         pretencion := 0;
         RETURN -99;
      WHEN OTHERS THEN
         RETURN(-error);
   END f_simula_irpf_renta;

/*
   ATS5656
   24/09/2007
   Funció que retorna les participacions que tenen dret a reducció.
*/
   FUNCTION f_part_pres(psseguro IN NUMBER)
      RETURN NUMBER IS
      nparant2007    NUMBER;
      aux_ant2007    NUMBER;
      aux_pos2006    NUMBER;
      fecha_ini_fisc DATE := TO_DATE('20070101', 'YYYYMMDD');
      err_calc       EXCEPTION;
   BEGIN
      nparant2007 := 0;

      -- albert - añado la columna del importe del recibo
      FOR reg IN (SELECT c.cmovimi, c.fvalmov, nnumlin, ctipapor, ( select itotalr from vdetrecibos where nrecibo = c.nrecibo ) itotalr,
                         DECODE(GREATEST(c.cmovimi, 10), 10, c.nparpla, -c.nparpla) "NPARPLA"
                    FROM ctaseguro c
                   WHERE c.sseguro = psseguro
                     AND c.cmovimi NOT IN(0, 54)) LOOP
         IF reg.fvalmov < fecha_ini_fisc
            OR reg.ctipapor = 'SP' THEN
            nparant2007 := nparant2007 + reg.nparpla;
         ELSIF reg.cmovimi IN(8, 47)
               AND reg.fvalmov >= fecha_ini_fisc THEN   -- Traspasos
            SELECT t.nparant2007, t.nparpos2006
              INTO aux_ant2007, aux_pos2006
              FROM trasplainout t
             WHERE t.sseguro = psseguro
               AND t.nnumlin = reg.nnumlin
               AND t.cestado IN(3, 4);

            -- albert, cambiamos el nparpla por el vdetrecibos para el cmovimi = 8 traspaso de entrada
            IF reg.cmovimi = 8 and (aux_ant2007 + aux_pos2006) != ABS(nvl(reg.itotalr,0)) THEN   -- Comprovan que n. parti estigui correcta
               RAISE err_calc;
            elsIF reg.cmovimi <> 8 and (aux_ant2007 + aux_pos2006) != ABS(reg.nparpla) THEN   -- Comprovan que n. parti estigui correcta
               RAISE err_calc;
            ELSE
               IF reg.cmovimi = 8 THEN
                  -- Taspas d'entrada. Recogim les participacions corresponents.
                  nparant2007 := nparant2007 + aux_ant2007;
               ELSE
                  nparant2007 := nparant2007 - aux_ant2007;
               END IF;
            END IF;
         ELSIF reg.cmovimi = 53
               AND reg.fvalmov >= fecha_ini_fisc THEN
            SELECT i.nparant2007, i.nparpos2006
              INTO aux_ant2007, aux_pos2006
              FROM irpf_prestaciones i, ctaseguro c
             WHERE i.sidepag = c.sidepag
               AND c.sseguro = psseguro
               AND c.nnumlin = reg.nnumlin;

            IF aux_ant2007 IS NULL
               AND aux_pos2006 IS NULL THEN
               nparant2007 := nparant2007 + reg.nparpla;
            ELSE
               nparant2007 := nparant2007 - aux_ant2007;
            END IF;
         END IF;
      END LOOP;

      RETURN nparant2007;
   EXCEPTION
      WHEN err_calc THEN
         RETURN -99;
      WHEN OTHERS THEN
         RETURN -SQLCODE;
   END f_part_pres;

   FUNCTION f_simula_irpf_cap(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      psesion IN NUMBER,
      pretencion OUT NUMBER,
      preduccion OUT NUMBER,
      pbase OUT NUMBER)
      RETURN NUMBER IS
--******************************************************************
--******************************************************************
--******************************************************************
--******* CALCULO DE LAS REDUCCIÓNES Y RETENCIONES DEL IRPF ********
--******************************************************************
--******************************************************************
--******************************************************************
      fecha_accion   DATE;
      moneda         NUMBER(1);

      CURSOR c_familia IS
         SELECT   sperson, fnacimi, cgrado, center
             FROM irpfdescendientes
            WHERE sperson = psperson
              AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) <=
                                                                                             25
                  OR cgrado IN(1, 2))
         ORDER BY fnacimi DESC;

      familia        c_familia%ROWTYPE;

      CURSOR c_abuelos IS
         SELECT sperson, fnacimi, cgrado, crenta, nviven
           FROM irpfmayores
          WHERE sperson = psperson
            AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) >=
                                                                                             65
                OR cgrado IN(1, 2));

      abuelos        c_abuelos%ROWTYPE;

      CURSOR c_cuadro IS
         SELECT   DECODE(moneda, 2, ROUND(ibase * 166.386), ibase) "IBASE",
                  DECODE(moneda, 2, ROUND(icuota * 166.386), icuota) "ICUOTA",
                  DECODE(moneda, 2, ROUND(iresto * 166.386), itipo) "IRESTO", itipo
             FROM irpfcuadro
         ORDER BY ibase DESC;

      cuadro         c_cuadro%ROWTYPE;
      expresion      VARCHAR2(100);
      prolongacion   NUMBER(1);
      movilidad      NUMBER(1);
      sechijos       NUMBER(2);
      retorno        NUMBER;
      mulhijo        NUMBER(1);
      err            NUMBER;
      pension        NUMBER(25, 10);
      imp_prolongacion NUMBER(25, 10);
      imp_movilidad  NUMBER(25, 10);
      mayor_edad     NUMBER(25, 10);
      masdos         NUMBER(25, 10);
      filas          INTEGER;
      cuantos        NUMBER(6);
      prestaciones_pagadas NUMBER(25, 2);
      anualidades    NUMBER(25, 2);
      retenciones_pagadas NUMBER(25, 2);
      reduccion_anterior NUMBER(25, 2);
      importe_invalidez_hijos NUMBER(25, 2);
      importe_invalidez_abuelos NUMBER(25, 2);
      importe_invalidez_benef NUMBER(25, 2);
      prestaciones_pendientes NUMBER(25, 2);
      porcentaje_retencion NUMBER(25, 2);
      tipo_hasta_final_anio NUMBER(25, 2);
      rendimiento_anual NUMBER(25, 2);
      rendimiento_anual_porcen NUMBER(25, 2);
      importe_minimo_excluido NUMBER(25, 2);
      importe_reduccion NUMBER(25, 2);
      retencion_pendiente NUMBER(25, 2);
      importe_saldo  NUMBER(25, 2);
      importe_personal NUMBER(25, 2);
      importe_familiar NUMBER(25, 2);
      pase_anualidades NUMBER(1);
      pase_base      NUMBER(1);
      importe_pago   NUMBER(25, 2);
      base_imponible NUMBER(25, 2);
      importe_hijos  NUMBER(25, 2);
      importe_abuelos NUMBER(25, 2);
      importe_total_hijos NUMBER(25, 2);
      importe_total_abuelos NUMBER(25, 2);
      cuota          NUMBER(25, 2);
      cuota_integra  NUMBER(25, 2);
      hijos          NUMBER(4);
      bruto          NUMBER(25, 2);
      valor_participacion NUMBER(25, 6);
      nulo           NUMBER(25, 6);
      periodos       NUMBER(2);
      contingencia   NUMBER(1);
      antiguedad     DATE;
      antiguedad_tras DATE;
      tabla_importe  NUMBER(25, 10);
      tabla_formula  VARCHAR2(100);
      grado          NUMBER(1);
      ayuda          NUMBER(1);
      situacion      NUMBER(1);
      edad           NUMBER(3);
      edad_hijo      NUMBER(3);
      edad_abuelo    NUMBER(3);
      ncursor        INTEGER;
      fecha_nacimiento DATE;
      error          NUMBER(8);
      error_fecha    NUMBER(8);
      fecha_valoracion DATE := f_sysdate;
      excepcion_salir EXCEPTION;
      excepcion_nosepuede EXCEPTION;
      fantigi        DATE;
      anos           NUMBER;
      aux_fecha_valor DATE;
      aux_valor_parti NUMBER;
      aux_divisa     NUMBER;
      aux_par_calc_red NUMBER;
      aux_imp_calc_red NUMBER;
   BEGIN
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

      -- Buscamos la Fecha de Acción de la simulación
      SELECT fcontin, finiciofis
        INTO fecha_accion, fantigi
        FROM simulapp
       WHERE sesion = psesion;

      error := 0;
      prestaciones_pendientes := 0;

      -- Buscamos el capital
      BEGIN
         SELECT capital
           INTO prestaciones_pendientes
           FROM detsimulapp
          WHERE sesion = psesion
            AND ejercicio = 0;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- Si el contrato tiene más de 2 años no calculamos la reducción
      error := f_difdata(fantigi, f_sysdate, 1, 1, anos);

      IF anos > 2 THEN
         DECLARE
            vestado        personas.cestado%TYPE;
         BEGIN
            SELECT b.spermin
              INTO vestado
              FROM personas a, riesgos b
             WHERE b.sseguro = psseguro
               AND a.sperson = b.sperson
               AND b.nriesgo = 1;

            aux_fecha_valor := pac_tfv.f_ultima_fval(psseguro);
            aux_valor_parti := f_valor_participlan(aux_fecha_valor, psseguro, aux_divisa);
            aux_par_calc_red := f_part_pres(psseguro);

            IF aux_par_calc_red > 0 THEN
               aux_imp_calc_red := ROUND(aux_par_calc_red * aux_valor_parti, 2);

               IF aux_imp_calc_red > prestaciones_pendientes THEN
                  aux_imp_calc_red := prestaciones_pendientes;
               END IF;

               IF vestado IS NOT NULL THEN
                  importe_reduccion := ROUND(((aux_imp_calc_red * 50) / 100), 2);
               ELSE
                  importe_reduccion := ROUND(((aux_imp_calc_red * 40) / 100), 2);
               END IF;
            END IF;
         END;
      ELSE
         importe_reduccion := 0;
      END IF;

      preduccion := importe_reduccion;
      rendimiento_anual := NVL(prestaciones_pagadas, 0) + NVL(prestaciones_pendientes, 0);
      pretanual := NVL(rendimiento_anual, 0);
      bruto := NVL(rendimiento_anual, 0) - NVL(importe_reduccion, 0)
               - NVL(reduccion_anterior, 0);
      preduccion := NVL(importe_reduccion, 0);
--***************************************************************************
--*** MINORACIONES.
--*** Reducción por rendimiento de trabajo ( Apartado 5 ).
--***************************************************************************
--*** Asignamos la reducción del rendimiento neto del trabajo segun la tabla
      error := 1;

      SELECT iimporte, iformula
        INTO tabla_importe, tabla_formula
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 1
         AND bruto BETWEEN idesde AND ihasta;

      IF tabla_formula IS NOT NULL THEN
         error := 2;

         SELECT REPLACE(tabla_formula, 'RNT',
                        DECODE(moneda, 2, ROUND(bruto / 166.386, 2), bruto))
           INTO tabla_formula
           FROM DUAL;

         tabla_formula := REPLACE(tabla_formula, ',', '.');

         SELECT ROUND(evalselect(tabla_formula), 2)
           INTO tabla_importe
           FROM DUAL;
      ELSE
         SELECT DECODE(moneda, 2, ROUND(tabla_importe * 166.386), tabla_importe)
           INTO tabla_importe
           FROM DUAL;
      END IF;

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por prolongación de la actividad laboral
--*** (Apartado 6 que depende del Apartado 5 ).
--***************************************************************************
      BEGIN
         SELECT cgrado, csitfam, cayuda, ipension, ianuhijos, rmovgeo, prolon
           INTO grado, situacion, ayuda, pension, anualidades, movilidad, prolongacion
           FROM irpfpersonas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
/* - INICI -
ATS5656 - 25/5/2006
Si no encuentra registro poner situacion = 3 para que pueda calcular la retencion.
Con situacion = 3 se calcula el máximo de retencion
*/
--            NULL;
            situacion := 3;
-- FI
      END;

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

      plog := plog || '
Apartado 6+5 AEAT :' || imp_prolongacion;

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por movilidad geográfica ( Apartado 7 Depende del Apartado 5).
--***************************************************************************
      IF movilidad = 1 THEN
         imp_movilidad := tabla_importe;
      END IF;

      plog := plog || ' Apartado 7+5 AEAT :' || imp_movilidad;

--*************************************************************************
--*** Límite máximo de las reducciones previstas en los apartados 5,6,7,8
--*************************************************************************
--TABLA_IMPORTE := TABLA_IMPORTE + NVL(IMP_MOVILIDAD,0) + NVL(IMP_PROLONGACION,0)
      IF (tabla_importe + NVL(imp_movilidad, 0) + NVL(imp_prolongacion, 0)) > bruto THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

--***************************************************************************
--*** MINORACIONES.
--*** Mínimo personal ( Apartado 3 )
--***************************************************************************
      error := 4;

      SELECT fnacimi
        INTO fecha_nacimiento
        FROM personas
       WHERE sperson = psperson;

      error_fecha := f_difdata(fecha_nacimiento, f_sysdate, 2, 1, edad);
      error := 5;

      SELECT DECODE(moneda,
                    2, ROUND(DECODE(grado, 1, iinv1, 2, iinv2, iimporte) * 166.386),
                    DECODE(grado, 1, iinv1, 2, iinv2, iimporte))
        INTO importe_personal
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 2
         AND edad BETWEEN idesde AND ihasta;

      plog := plog || '
Mínimo personal Art.3 AEAT:' || importe_personal;
--***************************************************************************
--*** MINORACIONES.
--*** Mínimo por descendientes ( Apartado 4 )
   --***************************************************************************
      error := 6;

      SELECT NVL(COUNT(*), 0)
        INTO hijos
        FROM irpfdescendientes
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

--***************************************************************************
--*** MINORACIONES.
--*** Reducción por cuidado de hijos ( Apartado 9 )
--***************************************************************************
         BEGIN
            error_fecha := f_difdata(familia.fnacimi, f_sysdate, 2, 1, edad_hijo);

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
--*** MINORACIONES.
--*** Reducciones por edad ( Apartado 10 )
--*** Reducciones por asistencia ( Apartado 11 )
--***************************************************************************
--*********************************
--**** Opcion A - Del contribuyente
--*********************************
      BEGIN
         SELECT iimporte
           INTO mayor_edad
           FROM irpftablas
          WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ntipo = 7
            AND edad BETWEEN idesde AND ihasta;

         plog := plog || '
   Reducción ART.10/11-A. AEAT:' || mayor_edad;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            mayor_edad := 0;
      END;

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

      pretabuelos := NVL(importe_total_abuelos, 0);
      error := 9;

      --*** Si los hijos son mas de 2 resta 600 euros
      IF hijos > 2 THEN
         SELECT DECODE(moneda, 2, 100000, 600)
           INTO masdos
           FROM DUAL;
      END IF;

      plog := plog || '
Mas de 2 hijos ART.14 AEAT:' || masdos;

      -- Reducción invalidez para el contribuyente
      BEGIN
         SELECT iimporte
           INTO importe_invalidez_benef
           FROM irpftablas
          WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
            AND ntipo = 8
            AND grado BETWEEN idesde AND ihasta;
      EXCEPTION
         WHEN OTHERS THEN
            importe_invalidez_benef := 0;
      END;

      plog := plog || 'Reducción invalidez Contribuyente art. 12 AEAT: '
              || importe_invalidez_benef;
--*************************************************************************
--   II. DETERMINACIÓN DE LA CUOTA DE RETENCIÓN
--*************************************************************************
      base_imponible := bruto - NVL(tabla_importe, 0) - NVL(imp_prolongacion, 0)
                        - NVL(imp_movilidad, 0) - NVL(mayor_edad, 0) - NVL(importe_personal, 0)
                        - NVL(importe_familiar, 0) - NVL(importe_total_hijos, 0)
                        - NVL(importe_invalidez_hijos, 0) - NVL(pension, 0)
                        - NVL(anualidades, 0) - NVL(masdos, 0) - NVL(importe_total_abuelos, 0)
                        - NVL(importe_invalidez_abuelos, 0) - NVL(importe_invalidez_benef, 0);
      pbase := base_imponible;
      predneto := NVL(tabla_importe, 0);
      predminper := NVL(importe_personal, 0);
      predminfam := NVL(importe_total_hijos, 0) + NVL(importe_familiar, 0);
      pretpension := NVL(pension, 0);
      pretmasdos := NVL(masdos, 0);

      IF base_imponible < 0 THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

      error := 10;
      --*** Miramos la cuota integra;
      pase_anualidades := 0;
      pase_base := 0;

      OPEN c_cuadro;

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

      -- *** Rendimiento anual
      SELECT DECODE(moneda, 2, ROUND(iimporte * 166.386), iimporte)
        INTO importe_saldo
        FROM irpftablas
       WHERE TO_CHAR(nano) = TO_CHAR(fecha_valoracion, 'YYYY')
         AND ntipo = 5;

      IF rendimiento_anual < importe_saldo THEN
         SELECT DECODE(moneda, 2, ROUND(iimporte * 166.386), iimporte)
           INTO importe_minimo_excluido
           FROM irpfcuadrohijos
          WHERE csituac = situacion
            AND NVL(hijos, 0) BETWEEN nhijdes AND nhijhas;

         rendimiento_anual_porcen := ROUND((rendimiento_anual - importe_minimo_excluido)
                                           *(43 / 100),
                                           2);

         IF cuota_integra > rendimiento_anual_porcen THEN
            cuota_integra := rendimiento_anual_porcen;
         END IF;
      END IF;

      error := 12;
--*************************************************************************
--   III. DETERMINACIÓN DEL TIPO DE RETENCION
--    IV. DETERMINACIÓN DEL IMPORTE DE LA RETENCION
--*************************************************************************
-- *** Obtenemos el porcentaje de la retención
      porcentaje_retencion := ROUND((cuota_integra / rendimiento_anual) * 100, 0);
      retencion_pendiente := cuota_integra - retenciones_pagadas;

      IF NVL(prestaciones_pendientes, 0) = 0 THEN
         tipo_hasta_final_anio := 0;
      ELSE
         tipo_hasta_final_anio := ROUND((retencion_pendiente / prestaciones_pendientes) * 100,
                                        0);
      END IF;

      -- Si el importe deja el saldo a 0
      tipo_hasta_final_anio := porcentaje_retencion;
      ptiporet := NVL(tipo_hasta_final_anio, 0);

      IF NVL(ptiporet, 0) < 0 THEN
         ptiporet := 0;
         pretanu := 0;
         RAISE excepcion_salir;
      END IF;

      pretencion := NVL(ptiporet, 0);
      error := 13;
      pretanu := rendimiento_anual *(tipo_hasta_final_anio / 100);
      RETURN 0;
   EXCEPTION
      WHEN excepcion_salir THEN
         pretencion := 0;
         RETURN 0;
      WHEN excepcion_nosepuede THEN
         pretencion := 0;
         RETURN -99;
      WHEN OTHERS THEN
         RETURN(-error);
   END;

   --Bug 33748-206175 01/06/2015 KJSC INGRESAR LAS FUNCIONES f_busca_rt y f_calc_rt
      /*************************************************************
      F_CALC_RT: Obtiene el % de IRPF de una persona
      Devuelve:  0 - ok
              nnnn - Error
              campo PRETENCION -- La retención aplicar

      FECHA CREACION: 01/05/2015
   **************************************************************/
   FUNCTION f_calc_rt(
      psperson IN NUMBER,
      pcapital IN NUMBER,
      pireduccion IN NUMBER,
      pretencion OUT NUMBER)
      RETURN NUMBER IS
--******************************************************************
--******************************************************************
--******************************************************************
--******* CALCULO DE LAS REDUCCIÓNES Y RETENCIONES DEL IRPF ********
--******************************************************************
--******************************************************************
--******************************************************************
      CURSOR c_familia IS
         SELECT   sperson, fnacimi, cgrado, center, fadopcion
             FROM per_irpfdescen
            WHERE sperson = psperson
              AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) <=
                                                                                             25
                  OR cgrado IN(1, 2, 3, 4))
         ORDER BY fnacimi DESC;

      familia        c_familia%ROWTYPE;

      --
      CURSOR c_abuelos IS
         SELECT sperson, fnacimi, cgrado, crenta, nviven
           FROM per_irpfmayores
          WHERE sperson = psperson
            AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) >=
                                                                                             65
                OR cgrado IN(1, 2, 3, 4));

      abuelos        c_abuelos%ROWTYPE;

      --
      CURSOR c_cuadro(pano IN NUMBER) IS
         SELECT   ibase "IBASE", icuota "ICUOTA", iresto "IRESTO", itipo
             FROM irpfcuadro
            WHERE nano = NVL(pano, nano)
         ORDER BY ibase DESC;

      --
      lirend_anual   NUMBER(25, 2);
      libruto        NUMBER(25, 2);
      lcgrado        per_irpf.cgrado%TYPE;
      lcayuda        per_irpf.cayuda%TYPE;
      lcsitfam       per_irpf.csitfam%TYPE;
      lipension      per_irpf.ipension%TYPE;
      lianuhijos     per_irpf.ianuhijos%TYPE;
      lrmovgeo       per_irpf.rmovgeo%TYPE;
      lfmovgeo       per_irpf.fmovgeo%TYPE;
      limp_movilidad irpftablas.iimporte%TYPE;
      lprolon        per_irpf.prolon%TYPE;
      limp_prolon    irpftablas.iimporte%TYPE;
      --
      tabla_importe  irpftablas.iimporte%TYPE;
      tabla_formula  irpftablas.iformula%TYPE;
      tabla_formula1 irpftablas.iformula%TYPE;
      --
      lfnacimi       per_personas.fnacimi%TYPE;
      lcestper       per_personas.cestper%TYPE;
      lnedad         irpftablas.idesde%TYPE;
      lipensionista  irpftablas.iimporte%TYPE;
      lidesempleado  irpftablas.iimporte%TYPE;
      lnhijos        NUMBER(4);
      limasdos       irpftablas.iimporte%TYPE;
      limpactivo_dis irpftablas.iimporte%TYPE;
      limp_fija      irpftablas.iimporte%TYPE;
      lanyo          NUMBER(4);
      --
      cuadro         c_cuadro%ROWTYPE;
      sechijos       irpftablas.idesde%TYPE;
      limayor_edad   irpftablas.iimporte%TYPE;
      retenciones_pagadas NUMBER(25, 2);
      limporte_invalidez_hijos irpftablas.iimporte%TYPE;
      limporte_invalidez_abuelos irpftablas.iimporte%TYPE;
      limporte_invalidez_benef irpftablas.iimporte%TYPE;
      porcentaje_retencion NUMBER(25, 2);
      tipo_hasta_final_ano NUMBER(25, 2);
      rendimiento_anual_porcen NUMBER(25, 2);
      limp_minimo_excluido irpfcuadrohijos.iimporte%TYPE;
      retencion_pendiente NUMBER(25, 2);
      limporte_saldo irpftablas.iimporte%TYPE;
      limporte_personal irpftablas.iimporte%TYPE;
      limporte_familiar irpftablas.iimporte%TYPE;
      limporte_hijos irpftablas.iimporte%TYPE;
      limporte_abuelos irpftablas.iimporte%TYPE;
      limporte_total_hijos NUMBER;
      limporte_total_abuelos NUMBER;
      lcuota_integra_uno NUMBER(25, 2);
      lcuota_integra_dos NUMBER(25, 2);
      lcuota_integra NUMBER(25, 2);
      --
      pase_anualidades NUMBER(1);
      pase_base      NUMBER(1);
      base_imponible NUMBER(25, 2);
      base_imponible_reduc NUMBER(25, 2);
      ledad_hijo     NUMBER(3);
      ledad_abuelo   NUMBER(3);
      error_fecha    NUMBER(8);
      fecha_valoracion DATE := f_sysdate;
      excepcion_salir EXCEPTION;
      excepcion_nosepuede EXCEPTION;
      vtraza         NUMBER;
   BEGIN
      vtraza := 0;
      -- Cuantia total de retribuciones
      lirend_anual := NVL(pcapital, 0);
      libruto := NVL(lirend_anual, 0) - NVL(pireduccion, 0);
      lanyo := TO_NUMBER(TO_CHAR(fecha_valoracion, 'YYYY'));
      vtraza := 1;

--***************************************************************************
--  GASTOS DEDUCIBLES.
--***************************************************************************
      BEGIN
         SELECT cgrado, csitfam, cayuda, ipension, ianuhijos, rmovgeo, fmovgeo, prolon
           INTO lcgrado, lcsitfam, lcayuda, lipension, lianuhijos, lrmovgeo, lfmovgeo, lprolon
           FROM per_irpf
          WHERE sperson = psperson
            AND nano = lanyo;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                        'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                        'Falta informar la tabla PER_IRPF del año' || lanyo || ' . Error:'
                        || SQLERRM);
            RETURN 9907689;
      END;

      --
      vtraza := 2;

      -- Reducción por obtención de rendimientos del trabajo:
      BEGIN
         SELECT iimporte, iformula
           INTO tabla_importe, tabla_formula
           FROM irpftablas
          WHERE TO_CHAR(nano) = lanyo
            AND ntipo = 1
            AND libruto BETWEEN idesde AND ihasta;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                        'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                        'Falta informar la tabla IRPFTABLAS, ntipo = 1, del año' || lanyo
                        || ' Bruto:' || libruto);
            RETURN 9907689;
      END;

      vtraza := 3;

      IF tabla_formula IS NOT NULL THEN
         SELECT REPLACE(tabla_formula, 'RNT', libruto)
           INTO tabla_formula
           FROM DUAL;

         tabla_formula := REPLACE(tabla_formula, ',', '.');

         SELECT ROUND(evalselect(tabla_formula), 2)
           INTO tabla_importe
           FROM DUAL;
      END IF;

      vtraza := 4;

--***************************************************************************
--*** MINORACIONES. ( NUEVO 2003 - JAMR )
--*** Mínimo personal ( Apartado 3 )
--***************************************************************************
      BEGIN
         SELECT fnacimi, NVL(cestper, 0)
           INTO lfnacimi, lcestper
           FROM per_personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                        'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                        'Persona no existe en PER_PERSONAS. Error:' || SQLERRM);
            RETURN 105113;   -- Persona no encontrada en la tabla PERSONAS
      END;

      vtraza := 5;
      error_fecha := f_difdata(lfnacimi, f_sysdate, 2, 1, lnedad);
      --
      lidesempleado := 0;
      lipensionista := 0;
      limp_movilidad := 0;
      limpactivo_dis := 0;
      vtraza := 6;

      IF lcestper <> 0 THEN
         -- Reduccion por pensionista
         IF lcestper = 3 THEN
            BEGIN
               SELECT iimporte
                 INTO lipensionista
                 FROM irpftablas
                WHERE TO_CHAR(nano) = lanyo
                  AND ntipo = 14;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                              'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                              'Falta informar la tabla IRPFTABLAS, ntipo = 14, del año '
                              || lanyo || ' .Error:' || SQLERRM);
                  lipensionista := 0;
                  RETURN 9907689;
            END;

            vtraza := 7;
         -- Reduccion por desempleado
         ELSIF lcestper = 4 THEN
            BEGIN
               SELECT iimporte
                 INTO lidesempleado
                 FROM irpftablas
                WHERE TO_CHAR(nano) = lanyo
                  AND ntipo = 15;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                              'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                              'Falta informar la tabla IRPFTABLAS, ntipo = 15, del año '
                              || lanyo || ' .Error:' || SQLERRM);
                  lidesempleado := 0;
                  RETURN 9907689;
            END;

            vtraza := 8;
         END IF;
      ELSE
         -- Reduccion de Gastos Trabajadores activos con discapacidad
         BEGIN
            SELECT iimporte
              INTO limpactivo_dis
              FROM irpftablas
             WHERE TO_CHAR(nano) = lanyo
               AND ntipo = 11
               AND lcgrado BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN OTHERS THEN
               limpactivo_dis := 0;
         END;

         vtraza := 9;

--***************************************************************************
--*** Gastos Deducibles
--*** Reducción por movilidad geográfica.
--*** Si la movilidad geografica a tenido lugar en el 2014. Importe a reducir
--*** según baremo de ingresos.
--*** Si la movilidad geografica a tenido lugar en el 2015. Importe fijo a
--*** reducir.
--***
--*** Solo aplica si el contribuyente es trabajador activo.
--***************************************************************************
         IF lfmovgeo IS NOT NULL THEN
            --
            IF TO_CHAR(lfmovgeo, 'yyyy') <= 2014 THEN
               BEGIN
                  SELECT iimporte, iformula
                    INTO limp_movilidad, tabla_formula1
                    FROM irpftablas
                   WHERE TO_CHAR(nano) = lanyo
                     AND ntipo = 12
                     AND libruto BETWEEN idesde AND ihasta;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                                 'parametros: PSPERSON=' || psperson || ' PCAPITAL='
                                 || pcapital,
                                 'Falta informar la tabla IRPFTABLAS, ntipo = 12, del año'
                                 || lanyo || ' Bruto:' || libruto);
                     RETURN 9907689;
               END;

               vtraza := 10;

               IF tabla_formula1 IS NOT NULL THEN
                  SELECT REPLACE(tabla_formula1, 'RNT', libruto)
                    INTO tabla_formula1
                    FROM DUAL;

                  tabla_formula1 := REPLACE(tabla_formula1, ',', '.');

                  SELECT ROUND(evalselect(tabla_formula1), 2)
                    INTO limp_movilidad
                    FROM DUAL;
               END IF;

               vtraza := 11;
            ELSE
               BEGIN
                  SELECT iimporte
                    INTO limp_movilidad
                    FROM irpftablas
                   WHERE TO_CHAR(nano) = lanyo
                     AND ntipo = 13
                     AND idesde = 0;
               EXCEPTION
                  WHEN OTHERS THEN
                     limp_movilidad := 0;
                     p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                                 'parametros: PSPERSON=' || psperson || ' PCAPITAL='
                                 || pcapital,
                                 'Falta informar la tabla IRPFTABLAS, ntipo = 13, del año'
                                 || lanyo);
                     RETURN 9907689;
               END;

               vtraza := 12;
            END IF;
         END IF;
      END IF;

      vtraza := 13;

      -- Importe cuantia fija
      BEGIN
         SELECT iimporte
           INTO limp_fija
           FROM irpftablas
          WHERE TO_CHAR(nano) = lanyo
            AND ntipo = 10
            AND idesde = 0;
      EXCEPTION
         WHEN OTHERS THEN
            limp_fija := 0;
            p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                        'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                        'Falta informar la tabla IRPFTABLAS, ntipo = 10, del año' || lanyo);
            RETURN 9907689;
      END;

      vtraza := 14;

      SELECT NVL(COUNT(*), 0)
        INTO lnhijos
        FROM per_irpfdescen
       WHERE sperson = psperson
         AND((TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) - TO_NUMBER(TO_CHAR(fnacimi, 'YYYY'))) <=
                                                                                             25
             OR cgrado IN(1, 2));

      vtraza := 15;

      --*** Si los hijos son mas de 2 resta 600 euros
      IF NVL(lnhijos, 0) > 2 THEN
         BEGIN
            SELECT iimporte
              INTO limasdos
              FROM irpftablas
             WHERE TO_CHAR(nano) = lanyo
               AND ntipo = 16;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               limasdos := 0;
               p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                           'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                           'Falta informar la tabla IRPFTABLAS, ntipo = 16, del año' || lanyo);
               RETURN 9907689;
         END;
      END IF;

      vtraza := 16;
--*************************************************************************
--  DETERMINACIÓN DE LA 1era CUOTA DE RETENCIÓN
--  Base para calcular el tipo de retención = Retribuciones -  minoraciones
--*************************************************************************
      base_imponible := libruto - NVL(limpactivo_dis, 0) - NVL(limp_fija, 0)
                        - NVL(limp_movilidad, 0) - NVL(lipensionista, 0)
                        - NVL(lidesempleado, 0) - NVL(tabla_importe, 0) - NVL(limasdos, 0)
                        - NVL(lipension, 0);
      --
      vtraza := 17;

      IF base_imponible < 0 THEN
         pretencion := 0;
         RAISE excepcion_salir;
      END IF;

      --
      pase_anualidades := 0;
      pase_base := 0;

      --
      -- Buscamos en el cuadro
      --
      OPEN c_cuadro(lanyo);

      LOOP
         FETCH c_cuadro
          INTO cuadro;

         EXIT WHEN c_cuadro%NOTFOUND;

         IF NVL(lianuhijos, 0) > 0
            AND NVL(lianuhijos, 0) < base_imponible
            AND lianuhijos >= cuadro.ibase
            AND pase_anualidades = 0 THEN
            lcuota_integra_uno := NVL(lcuota_integra_uno, 0)
                                  +((NVL(lianuhijos, 0)) *(NVL(cuadro.itipo, 0) / 100));
            pase_anualidades := 1;
            EXIT WHEN pase_anualidades = 1
                 AND pase_base = 1;
         END IF;

         IF NVL(lianuhijos, 0) > 0
            AND NVL(lianuhijos, 0) < base_imponible
            AND(base_imponible - lianuhijos) >= cuadro.ibase
            AND pase_base = 0 THEN
            lcuota_integra_uno := NVL(lcuota_integra_uno, 0) + NVL(cuadro.icuota, 0)
                                  +(((NVL(base_imponible, 0) - NVL(lianuhijos, 0))
                                     - NVL(cuadro.ibase, 0))
                                    *(NVL(cuadro.itipo, 0) / 100));
            pase_base := 1;
            EXIT WHEN pase_anualidades = 1
                 AND pase_base = 1;
         END IF;

         IF base_imponible >= cuadro.ibase
            AND(NVL(lianuhijos, 0) = 0
                OR NVL(lianuhijos, 0) > base_imponible) THEN
            lcuota_integra_uno := NVL(cuadro.icuota, 0)
                                  +((NVL(base_imponible, 0) - NVL(cuadro.ibase, 0))
                                    *(NVL(cuadro.itipo, 0) / 100));
            EXIT WHEN 0 = 0;
         END IF;
      END LOOP;

      vtraza := 18;
      base_imponible_reduc := NVL(base_imponible, 0);

    --(JMC) importe_personal, corresponde al apartado Mínimo del contribuyente, con carácter general
--***************************************************************************
--*** MINORACIONES.
--*** Mínimo por descendientes ( Apartado 4 )
   --***************************************************************************
      BEGIN
         SELECT DECODE(lcgrado, 1, iinv1, 2, iinv2, iimporte)
           INTO limporte_personal
           FROM irpftablas
          WHERE TO_CHAR(nano) = lanyo
            AND ntipo = 2
            AND NVL(lnedad, 0) BETWEEN idesde AND ihasta;
      EXCEPTION
         WHEN OTHERS THEN
            limporte_personal := 0;
            p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                        'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                        'Falta informar la tabla IRPFTABLAS, ntipo = 2, del año' || lanyo
                        || ' Edad:' || NVL(lnedad, 0));
            RETURN 9907689;
      END;

      vtraza := 19;
      -- *** Control suplemento hijos menores o invalidos
      sechijos := 0;

      OPEN c_familia;

      LOOP
         FETCH c_familia
          INTO familia;

         EXIT WHEN c_familia%NOTFOUND;
         sechijos := sechijos + 1;

         SELECT NVL(limporte_familiar, 0) + DECODE(familia.center, 1, iimporte, iimporte / 2)
           INTO limporte_familiar
           FROM irpftablas
          WHERE TO_CHAR(nano) = lanyo
            AND ntipo = 3
            AND sechijos BETWEEN idesde AND ihasta;

         --(JMC) importe_familiar, corresponde al apartado Mínimo por descendientes <25 anos o discapacitados
         --                                                con carácter general
--***************************************************************************
--*** MINORACIONES.
--*** Reducción por cuidado de hijos ( Apartado 9 )
--***************************************************************************
         BEGIN
            error_fecha := f_difdata(familia.fnacimi, f_sysdate, 2, 1, ledad_hijo);

            -- Ini Bug 12716 - 14-09-2010 - JMC - Tenemos en cuenta la fecha de adopción
            IF ledad_hijo > 2
               AND familia.fadopcion IS NOT NULL THEN
               error_fecha := f_difdata(familia.fnacimi, familia.fadopcion, 2, 1, ledad_hijo);

               IF ledad_hijo < 19 THEN
                  error_fecha := f_difdata(familia.fadopcion, f_sysdate, 2, 1, ledad_hijo);
               END IF;
            END IF;

            -- Fin Bug 12716 - 14-09-2010 - JMC
            SELECT DECODE(familia.center, 1, iimporte, iimporte / 2)
              INTO limporte_hijos
              FROM irpftablas
             WHERE TO_CHAR(nano) = lanyo
               AND ntipo = 4
               AND ledad_hijo BETWEEN idesde AND ihasta;

            limporte_total_hijos := NVL(limporte_total_hijos, 0) + NVL(limporte_hijos, 0);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                           'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                           'error: ' || SQLERRM);
         END;

         --importe_total_hijos, corresponde al apartado Mínimo por descendientes <25 anos o discapacitados
         --                                                   descendientes <3 anos

         -- Miramos las invalidezas de los hijos
         BEGIN
            SELECT NVL(limporte_invalidez_hijos, 0)
                   + DECODE(familia.center, 1, iimporte, iimporte / 2)
              INTO limporte_invalidez_hijos
              FROM irpftablas
             WHERE TO_CHAR(nano) = lanyo
               AND ntipo = 8
               AND familia.cgrado BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      vtraza := 20;

--***************************************************************************
--*** MINORACIONES.
--***************************************************************************
--*********************************
--**** Opcion A - Del contribuyente
--*********************************
      BEGIN
         SELECT iimporte
           INTO limayor_edad
           FROM irpftablas
          WHERE TO_CHAR(nano) = lanyo
            AND ntipo = 7
            AND NVL(lnedad, 0) BETWEEN idesde AND ihasta;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            limayor_edad := 0;
      END;

      vtraza := 21;

--*********************************
--**** Opcion B - De Ascendiente
--*********************************
      OPEN c_abuelos;

      LOOP
         FETCH c_abuelos
          INTO abuelos;

         EXIT WHEN c_abuelos%NOTFOUND;
         error_fecha := f_difdata(abuelos.fnacimi, f_sysdate, 2, 1, ledad_abuelo);
         limporte_abuelos := 0;

         BEGIN
            SELECT DECODE(abuelos.nviven,
                          1, iimporte,
                          NULL, iimporte,
                          0, iimporte,
                          iimporte / abuelos.nviven)
              INTO limporte_abuelos
              FROM irpftablas
             WHERE TO_CHAR(nano) = lanyo
               AND ntipo = 6
               AND ledad_abuelo BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;

         limporte_total_abuelos := NVL(limporte_total_abuelos, 0) + NVL(limporte_abuelos, 0);

         -- Importe_total_abuelos, corresponde al apartado Mínimo por ascendientes >65 anos o discapacitados
         --                                                     ascendientes >75 anos
         -- Miramos las invalidezas de los abuelos
         BEGIN
            SELECT NVL(limporte_invalidez_abuelos, 0)
                   + DECODE(abuelos.nviven,
                            1, iimporte,
                            0, iimporte,
                            NULL, iimporte,
                            iimporte / abuelos.nviven)
              INTO limporte_invalidez_abuelos
              FROM irpftablas
             WHERE TO_CHAR(nano) = lanyo
               AND ntipo = 8
               AND abuelos.cgrado BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      CLOSE c_abuelos;

      vtraza := 22;

      -- Reduccion por discapacidad del contribuyente
      IF lcestper <> 0 THEN
         limporte_invalidez_benef := 0;
      ELSE
         BEGIN
            SELECT iimporte
              INTO limporte_invalidez_benef
              FROM irpftablas
             WHERE TO_CHAR(nano) = lanyo
               AND ntipo = 9
               AND lcgrado BETWEEN idesde AND ihasta;
         EXCEPTION
            WHEN OTHERS THEN
               limporte_invalidez_benef := 0;
         END;
      END IF;

      vtraza := 23;
--*************************************************************************
--  DETERMINACIÓN DE LA 2 CUOTA DE RETENCIÓN
--  Base para calcular tipo de retención = Sumatorio Mínimo personal y familiar
--*************************************************************************
   --INI BUG 33748-211952 11/08/2015 KJSC INCORPORAR AL CODIGO
      base_imponible := NVL(limayor_edad, 0) + NVL(limporte_personal, 0)
                        + NVL(limporte_familiar, 0) + NVL(limporte_total_hijos, 0)
                        + NVL(limporte_invalidez_hijos, 0) + NVL(limporte_total_abuelos, 0)
                        + NVL(limporte_invalidez_abuelos, 0) + NVL(limporte_invalidez_benef, 0)
                        + NVL(lianuhijos, 0);
      --FIN BUG 33748-211952 11/08/2015 KJSC INCORPORAR AL CODIGO
      --*** Miramos la cuota integra;
      pase_anualidades := 0;
      pase_base := 0;
      lcuota_integra_dos := 0;
      vtraza := 24;

      --
      IF c_cuadro%ISOPEN THEN
         CLOSE c_cuadro;
      END IF;

      OPEN c_cuadro(lanyo);

      LOOP
         FETCH c_cuadro
          INTO cuadro;

         EXIT WHEN c_cuadro%NOTFOUND;

         IF NVL(lianuhijos, 0) > 0
            AND NVL(lianuhijos, 0) < base_imponible
            AND lianuhijos >= cuadro.ibase
            AND pase_anualidades = 0 THEN
            lcuota_integra_dos := NVL(lcuota_integra_dos, 0) + NVL(cuadro.icuota, 0)
                                  +((NVL(lianuhijos, 0) - NVL(cuadro.ibase, 0))
                                    *(NVL(cuadro.itipo, 0) / 100));
            pase_anualidades := 1;
            EXIT WHEN pase_anualidades = 1
                 AND pase_base = 1;
         END IF;

         --
         IF NVL(lianuhijos, 0) > 0
            AND NVL(lianuhijos, 0) < base_imponible
            AND(base_imponible - lianuhijos) >= cuadro.ibase
            AND pase_base = 0 THEN
            lcuota_integra_dos := NVL(lcuota_integra_dos, 0) + NVL(cuadro.icuota, 0)
                                  +(((NVL(base_imponible, 0) - NVL(lianuhijos, 0))
                                     - NVL(cuadro.ibase, 0))
                                    *(NVL(cuadro.itipo, 0) / 100));
            pase_base := 1;
            EXIT WHEN pase_anualidades = 1
                 AND pase_base = 1;
         END IF;

         --
         IF base_imponible >= cuadro.ibase
            AND(NVL(lianuhijos, 0) = 0
                OR NVL(lianuhijos, 0) > base_imponible) THEN
            lcuota_integra_dos := NVL(cuadro.icuota, 0)
                                  +((NVL(base_imponible, 0) - NVL(cuadro.ibase, 0))
                                    *(NVL(cuadro.itipo, 0) / 100));
            EXIT WHEN 0 = 0;
         END IF;
      END LOOP;

      vtraza := 25;
--*************************************************************************
--  CUOTA DE RETENCIÓN = CUOTA 1 - CUOTA 2
--*************************************************************************
      lcuota_integra := NVL(lcuota_integra_uno, 0) - NVL(lcuota_integra_dos, 0);

--*************************************************************************
--  CUOTA MÁXIMA PARA RETRIBUCIONES NO SUPERIORES A 22.000 EUROS ANUALES:
--  43% x (Retribuciones totales anuales [1] - Cuantía que corresponda
--*************************************************************************
-- Buscamos cuantía.
      BEGIN
         SELECT iimporte
           INTO limporte_saldo
           FROM irpftablas
          WHERE TO_CHAR(nano) = lanyo
            AND ntipo = 5;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            limporte_saldo := 0;
         WHEN OTHERS THEN
            limporte_saldo := 0;
      END;

      vtraza := 26;

      --
      IF lirend_anual < limporte_saldo THEN
         BEGIN
            SELECT iimporte
              INTO limp_minimo_excluido
              FROM irpfcuadrohijos
             WHERE csituac = lcsitfam
               AND NVL(lnhijos, 0) BETWEEN nhijdes AND nhijhas;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               limp_minimo_excluido := 0;
            WHEN OTHERS THEN
               limp_minimo_excluido := 0;
         END;

         --
         rendimiento_anual_porcen := ROUND((lirend_anual - limp_minimo_excluido) *(43 / 100),
                                           2);

         IF NVL(base_imponible_reduc, 0) <= 8000 THEN
            rendimiento_anual_porcen := NVL(rendimiento_anual_porcen, 0) + 400;
         ELSIF NVL(base_imponible_reduc, 0) > 8000
               AND NVL(base_imponible_reduc, 0) <= 12000 THEN
            rendimiento_anual_porcen := NVL(rendimiento_anual_porcen, 0)
                                        +(400 - 0.1 *(base_imponible_reduc - 8000));
         ELSE
            rendimiento_anual_porcen := NVL(rendimiento_anual_porcen, 0);
         END IF;

         --
         IF lcuota_integra > rendimiento_anual_porcen THEN
            lcuota_integra := rendimiento_anual_porcen;
         END IF;
      END IF;

      vtraza := 27;
--*************************************************************************
--  TIPO DE RETENCION APLICABLE
--*************************************************************************
      porcentaje_retencion := (lcuota_integra / lirend_anual) * 100;
      retencion_pendiente := lcuota_integra;

      IF NVL(porcentaje_retencion, 0) < 0 THEN
         pretencion := 0;
         RAISE excepcion_salir;
      END IF;

      pretencion := NVL(porcentaje_retencion, 0);
      RETURN 0;
   EXCEPTION
      WHEN excepcion_salir THEN
         pretencion := 0;
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_calc_rt', vtraza,
                     'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                     'Error:' || SQLERRM);
         RETURN(108190);
   END f_calc_rt;

   /*************************************************************
      F_BUSCA_RT: Obtiene el % de IRPF de una persona
      Funcion llamada por SGT.

      Devuelve: nnnn - Porcentaje
               -nnnn - Error

      FECHA CREACION: 01/05/2015

   **************************************************************/
   FUNCTION f_busca_rt(
      psesion IN NUMBER,
      psperson IN NUMBER,
      pcapital IN NUMBER,
      pireduccion IN NUMBER)
      RETURN NUMBER IS
      retorno        NUMBER;
      lretencion     NUMBER;
   BEGIN
      retorno := pac_irpf.f_calc_rt(psperson, pcapital, pireduccion, lretencion);

      IF retorno = 0 THEN
         RETURN lretencion;
      ELSE
         p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_busca_rt', 0,
                     'parametros: SPERSON= ' || psperson || ' Capital= ' || pcapital
                     || ' Reduccion= ' || pireduccion,
                     'Error:' || SQLERRM);
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, getuser, 'PAC_IRPF.f_busca_rt', 0,
                     'parametros: PSPERSON=' || psperson || ' PCAPITAL=' || pcapital,
                     'Error:' || SQLERRM);
         RETURN NULL;
   END;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_IRPF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IRPF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IRPF" TO "PROGRAMADORESCSI";
