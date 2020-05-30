--------------------------------------------------------
--  DDL for Package Body PAC_CALC_COMU
--------------------------------------------------------
  CREATE OR REPLACE PACKAGE BODY PAC_CALC_COMU AS
   /******************************************************************************
      NAME:       PAC_CALC_COMU
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        ??/??/????  ???              1. Created this package body.
      2.0        18/03/2009  DRA              0009523: IAX - Gestió de propostes: Error en la data de cartera anual a l'emetre una pòlissa prèviament retinguda
      3.0        17/04/2009  APD              Bug 9685 - primero se ha de buscar para la actividad en concreto
                                              y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
                                              Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      4.0        01/07/2009  NMM              0010470: CEM - ESCUT - Profesiones sobreprimas y extraprimas
      5.0        20/07/2009  JRH              Bug 10876: CEM - PPA - Ajustar formulación a histórico de intereses y gastos
      6.0        14/12/2009  APD              Bug 12279: Poner fecha de vencimiento por defecto para el producto PU de CEM
      7.0        14/12/2009  APD              Bug 12277: Hay que adaptar el calculo de la fecha de revisión para las rentas vitacilicias de CEM
      8.0        23/06/2010  DRA              0015135: CEM998 - Creació d'un nou producte PPA
      9.0        22/12/2010  APD              Bug 16768: APR - Implementación y parametrización del producto GROUPLIFE (II)
      10.0       27/12/2010  APD              Bug 17105: Ajustes producto GROUPLIFE (III)
      11.0       25/05/2011  SRA              Bug 18624: CIV996 - MODIFICACIÓN PERIODO INICIAL DE TIPO DE INTERES EN PRODUCTO RENTA VITALICIA
      12.0       02/03/2012  DRA              12. 0021517: CIV998-CIV - EMISIÓN DE UN NUEVO ESTRUCTURADO
      13.0       23/04/2011  MDS              13. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
      14.0       19/06/2012  JRH              14. 0022504: MDP_T001- TEC - Capital Recomendado
      15.0       23/01/2013  MMS              15. 0025584: (f_calcula_fvencim_nduraci) Agregamos el cálculo de la fecha de vencimiento para CDURACI=7. Agregamos el parámetro de pnedamar
      16.0       03/05/2013  FAL              16. 0026835: GIP800 - Incidencias reportadas 23/4
      17.0       05/06/2013  MMS              17. 0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)
      18.0       18/05/2020  ECP              18. IAXIS-13888. Eror Gestión Agenda
   ******************************************************************************/
   FUNCTION f_calcula_nrenova(psproduc IN NUMBER, pfefecto IN DATE, pnrenova OUT NUMBER)
      RETURN NUMBER IS
      /**********************************************************************************************
      Función que calcula el campo nrenova en función de la parametrización del producto y de la
      fecha de efecto de la póliza
      ***********************************************************************************************/
      v_ctipefe      NUMBER(1);
      v_nrenova      NUMBER(4);
      v_fecha        DATE;
   BEGIN
      -- BUG9523:18/03/2009:DRA:S'amplia el càlcul de la NRENOVA
      SELECT ctipefe, nrenova
        INTO v_ctipefe, v_nrenova
        FROM productos
       WHERE sproduc = psproduc;

      IF v_ctipefe = 1 THEN
         IF v_nrenova IS NULL THEN
            RETURN 101826;
         ELSE
            pnrenova := v_nrenova;
         END IF;
      ELSIF v_ctipefe = 2 THEN
         IF TO_CHAR(pfefecto, 'dd') = 1 THEN
            v_fecha := pfefecto;
         ELSE
            v_fecha := ADD_MONTHS(pfefecto, 1);
         END IF;

         pnrenova := TO_CHAR(v_fecha, 'mm') || '01';
      ELSIF v_ctipefe = 3 THEN
         pnrenova := TO_CHAR(pfefecto, 'mm') || '01';
      ELSE
         pnrenova := TO_CHAR(pfefecto, 'mmdd');
      END IF;

      IF pnrenova = '229' THEN
         pnrenova := '228';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.f_calcula_nrenova', 1,
                     'parametros: sproduc =' || psproduc || ' pfefecto =' || pfefecto,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_calcula_nrenova;

   FUNCTION f_calcula_fvencim_nduraci(
      psproduc IN NUMBER,
      pfnacimi IN DATE,
      pfefecto IN DATE,
      pcduraci IN NUMBER,
      pnduraci IN OUT NUMBER,
      pfvencim IN OUT DATE,
      pnpoliza IN NUMBER DEFAULT NULL,   -- Bug 16768 - APD - 22/11/2010 - se añade el parametro pnpoliza
      pnrenova IN NUMBER DEFAULT NULL,   -- Bug 19412 - RSC - 26/10/2011
      pnedamar IN NUMBER DEFAULT NULL,   -- Bug 0025584 - MMS - 23/01/2013
      pncertif IN NUMBER DEFAULT NULL)	 /*PRBMANT-24 - AAC - 28/06/2016*/
	  RETURN NUMBER IS
         /*********************************************************************************************************************************
            Función que calcula la fecha de vencimiento y la duración según la parametrización del producto y los valores
            iniciales.
               Si sólo llega duración: calcula la fecha de vencimiento
              Si sólo llega fecha de vencimiento: calcula la duración
              Si no llega ni duración ni fecha de vencimiento calcula la duración mínima y máxima y la correspondiente fecha de
              vencimiento
      ***********************************************************************************************************************************/
      v_nduraci      NUMBER;
      v_fvencim      DATE;
      v_cdurmin      NUMBER;
      v_nvtomin      NUMBER;
      v_fnacimi      DATE;
      v_sproduc      NUMBER;
      v_cduraci      productos.cduraci%TYPE;
      v_existe       NUMBER;   -- Bug 16768 - APD - 22/11/2010
      -- Bug 19412 - RSC - 26/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
      verror         NUMBER;
      vnrenova       NUMBER;
      -- Fin Bug 19412

      -- Bug 20163/98005 - RSC - 15/11/2011
      v_edad_efecto  NUMBER;
      v_temporadas   NUMBER;
      v_fecha_renovacion DATE;
      v_edad_ftemporada NUMBER;
      v_nedamar      productos.nedamar%TYPE;
      -- Fin Bug 20163/98005
      v_aplica_vtomin BOOLEAN := TRUE;   -- BUG 26835 - FAL - 03/05/2013

	  /*PRBMANT-24 - AAC - 28/06/2016*/
	  v_mov221 number := 0;
      v_mov228 number := 0;
   BEGIN
	  /*INI-PRBMANT-24 - AAC - 28/06/2016*/
      select count(1) into v_mov221 from movseguro mv where mv.sseguro = (select sseguro from seguros s where pncertif = s.ncertif and s.npoliza = pnpoliza)and mv.cmotmov = 221;
      select count(1) into v_mov228 from movseguro mv where mv.sseguro = (select sseguro from seguros s where pncertif = s.ncertif and s.npoliza = pnpoliza)and mv.cmotmov = 228;
      /*FI-PRBMANT-24 AAC*/

      -- MSR Ref 1991
      IF pcduraci IS NULL THEN
         FOR rproductos IN (SELECT cduraci
                              FROM productos
                             WHERE sproduc = psproduc) LOOP
            v_cduraci := rproductos.cduraci;
            EXIT;
         END LOOP;
      ELSE
         v_cduraci := pcduraci;
      END IF;

      v_nduraci := pnduraci;

      -- Bug 12279 - APD - 11/12/2009 - si el parproducto tiene por defecto
      -- una fecha de vencimiento, v_fvencim será dicha fecha.
      -- En caso contrario, v_fvencim = pfvencim (tal y como estaba hasta ahora)
      IF pac_parametros.f_parproducto_f(psproduc, 'DIA_VENCIMIENTO') IS NOT NULL THEN
         v_fvencim := pac_parametros.f_parproducto_f(psproduc, 'DIA_VENCIMIENTO');
      ELSE
         v_fvencim := pfvencim;
      END IF;

      IF v_cduraci = 0 THEN   --anual renovable
         if v_mov221 <= v_mov228 then /*PRBMANT-24 - AAC - 28/06/2016*/
			v_fvencim := NULL;
         End if;
      ELSIF v_cduraci = 1 THEN   -- años
         IF v_nduraci IS NULL
            AND v_fvencim IS NOT NULL THEN
            v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);

            IF TRUNC(v_nduraci) <> v_nduraci THEN   -- no es un entero
               RETURN 104506;
            END IF;
         ELSE
            v_fvencim := ADD_MONTHS(pfefecto, v_nduraci * 12);
         END IF;
      ELSIF v_cduraci = 2 THEN   --meses
         IF v_nduraci IS NULL
            AND v_fvencim IS NOT NULL THEN
            v_nduraci := ROUND(MONTHS_BETWEEN(v_fvencim, pfefecto), 2);

            IF TRUNC(v_nduraci) <> v_nduraci THEN   -- no es un entero
               RETURN 104506;
            END IF;
         ELSE
            v_fvencim := ADD_MONTHS(pfefecto, v_nduraci);
         END IF;
      ELSIF v_cduraci = 3 THEN   --hasta vencimiento
         IF v_fvencim IS NOT NULL THEN
            v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
         END IF;
      ELSIF v_cduraci = 5 THEN   -- años más un día
         v_fvencim := ADD_MONTHS(pfefecto, v_nduraci * 12) + 1;
      -- Bug 0025584 - MMS - 23/01/2013
      ELSIF v_cduraci = 7 THEN   -- Hasta edad
         -- v_fvencim := ADD_MONTHS(pfnacimi, pnedamar * 12);
         -- v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
         -- Hay que hacer el cálculo en funcion de la fecha de efecto y no la de nacimiento
         v_fvencim := ADD_MONTHS(pfnacimi, 12 * pnedamar);

         IF pnrenova IS NULL THEN
            verror := pac_calc_comu.f_calcula_nrenova(psproduc, pfefecto, vnrenova);
         ELSE
            vnrenova := pnrenova;
         END IF;

         IF vnrenova IS NOT NULL THEN
            IF v_fvencim IS NOT NULL THEN
               IF v_fvencim <= TO_DATE(TO_CHAR(v_fvencim, 'YYYY') || LPAD(vnrenova, 4, '0'),
                                       'YYYYMMDD') THEN
                  v_fvencim := TO_DATE(TO_CHAR(v_fvencim, 'YYYY') || LPAD(vnrenova, 4, '0'),
                                       'YYYYMMDD');
               ELSE
                  v_fvencim := TO_DATE((TO_NUMBER(TO_CHAR(v_fvencim, 'YYYY')) + 1)
                                       || LPAD(vnrenova, 4, '0'),
                                       'YYYYMMDD');
               END IF;
            END IF;
         END IF;

         v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
      -- Fin Bug 0025584 - MMS - 23/01/2013
      END IF;

      IF v_fvencim IS NULL
         AND v_cduraci <> 0 THEN
         -- no ha sido calculada hasta ahora calculamos la duración mínima
         -- Añadimos control para que no se calcule la duración
         --mínima, si el producto es anual renovable.
         BEGIN
            SELECT cdurmin, nvtomin, nedamar
              INTO v_cdurmin, v_nvtomin, v_nedamar
              FROM productos p
             WHERE sproduc = psproduc;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101919;   -- eror al leer datos de la tabla seguros
         END;

         -- BUG 26835 - FAL - 03/05/2013
         v_aplica_vtomin := TRUE;

         IF NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
            AND NVL(f_parproductos_v(psproduc, 'APLICA_VTOMIN'), 0) = 1 THEN
            v_existe := pac_seguros.f_get_escertifcero(pnpoliza);

            IF v_existe = 0 THEN
               v_aplica_vtomin := FALSE;
            END IF;
         END IF;

         -- FI BUG 26835 - FAL - 03/05/2013
         IF v_aplica_vtomin THEN   -- BUG 26835 - FAL - 03/05/2013
            IF v_cdurmin = 0 THEN   -- años
               v_fvencim := ADD_MONTHS(pfefecto, v_nvtomin * 12);
               v_nduraci := v_nvtomin;
            ELSIF v_cdurmin = 1 THEN   --meses
               v_fvencim := ADD_MONTHS(pfefecto, v_nvtomin);
               v_nduraci := v_nvtomin;
            ELSIF v_cdurmin = 2 THEN   --dias
               v_fvencim := pfefecto + v_nvtomin;
               v_nduraci := v_nvtomin;
            ELSIF v_cdurmin = 3 THEN   -- meses más 1 día
               v_fvencim := ADD_MONTHS(pfefecto, v_nvtomin) + 1;
               v_nduraci := v_nvtomin;
            ELSIF v_cdurmin = 4 THEN   -- fecha primer período
               --- caso concreto de caixa, de momento devolvemos null
               v_fvencim := NULL;
            ELSIF v_cdurmin = 5 THEN   -- desde/hasta edad
               -- Bug 16768 - APD - 22/11/2010 - se busca la duracion minina
               -- del certificado 0
               IF NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                  AND NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 1
                  AND pnpoliza IS NOT NULL THEN
                  v_existe := pac_seguros.f_get_escertifcero(pnpoliza);

                  IF v_existe > 0 THEN
                     SELECT p.crespue
                       INTO v_nvtomin
                       FROM pregunpolseg p, seguros s
                      WHERE p.sseguro = s.sseguro
                        AND s.npoliza = pnpoliza
                        AND s.ncertif = 0
                        AND p.cpregun = 126;
                  END IF;
               END IF;

               -- Fin Bug 16768 - APD - 22/11/2010
               -- Bug 17105 - APD - 28/12/2010 - se añadel el NVL en la variable pfnacimi
               -- ya que si estamos en SIMULACION el parametro es nulo hasta que se selecciona
               -- un riesgo

               -- Bug 17694 - AMC - 24/02/2011 - Se elimina la modificación del bug anterior
               v_fvencim := ADD_MONTHS(pfnacimi, 12 * v_nvtomin);
               --Fi Bug 17694 - AMC - 24/02/2011

               -- fin Bug 17105 - APD - 28/12/2010
               v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);

               --JRH 08/2008 Esto no tiene que hacerlo
               IF NVL(f_parproductos_v(psproduc, 'DIA_FIN_01'), 0) = 1 THEN
                  -- la fecha de vencimiento será el 1 del mes siguiente
                  v_fvencim := TO_DATE('01' || TO_CHAR((LAST_DAY(v_fvencim) + 1), 'mmyyyy'),
                                       'ddmmyyyy');
                  v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
               END IF;
            -- Bug 12279 - JRH - 11/12/2009 - si el parproducto tiene por defecto
            ELSIF v_cdurmin = 6 THEN   -- "Años inicio mes siguiente"
               v_fvencim := LAST_DAY(ADD_MONTHS(pfefecto, 12 * v_nvtomin)) + 1;
               v_nduraci := v_nvtomin;
            -- Fi Bug 12279 - JRH - 11/12/2009
            -- Bug 13570 - RSC - 26/07/2010 - CRE998 - Nuevo Producto Pla Estudiant Garantit
            ELSIF v_cdurmin = 7 THEN   -- "Años inicio"
               v_fvencim := ADD_MONTHS(pfefecto, 12 * v_nvtomin);
               v_nduraci := v_nvtomin;
            -- Fi Bug 13570
            -- Bug 13570 - RSC - 26/07/2010 - CRE998 - Nuevo Producto Pla Estudiant Garantit

            -- Bug 19412 - RSC - 26/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
            ELSIF v_cdurmin = 8 THEN   -- "fecha de renovación en la que el asegurado cumple la edad mínima"
               v_fvencim := ADD_MONTHS(pfnacimi, 12 * v_nvtomin);

               IF pnrenova IS NULL THEN
                  verror := pac_calc_comu.f_calcula_nrenova(psproduc, pfefecto, vnrenova);
               ELSE
                  vnrenova := pnrenova;
               END IF;

               IF vnrenova IS NOT NULL THEN
                  IF v_fvencim IS NOT NULL THEN
                     IF v_fvencim <= TO_DATE(TO_CHAR(v_fvencim, 'YYYY')
                                             || LPAD(vnrenova, 4, '0'),
                                             'YYYYMMDD') THEN
                        v_fvencim := TO_DATE(TO_CHAR(v_fvencim, 'YYYY')
                                             || LPAD(vnrenova, 4, '0'),
                                             'YYYYMMDD');
                     ELSE
                        v_fvencim := TO_DATE((TO_NUMBER(TO_CHAR(v_fvencim, 'YYYY')) + 1)
                                             || LPAD(vnrenova, 4, '0'),
                                             'YYYYMMDD');
                     END IF;
                  END IF;
               END IF;

               v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
            -- Fin Bug 19412

            -- Bug 20163 - RSC - 15/11/2011 - LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
            ELSIF v_cdurmin = 9 THEN
               /*
                   La edad máxima de ingreso al amparo básico es 70 años y la edad de permanencia es hasta los 80 años.
                   Esto significa que ninguna póliza puede ser renovada después de que el asegurado haya cumplido la edad
                   máxima de ingreso de 70 años, ni podrá permanecer asegurado mas allá de los 80 años.

                   Por todo esto, se debe calcular la fecha de vencimiento forma que sea la (fecha de efecto * n * duración
                   periodo renovación) más próxima a los 80 años de edad.
               */
               v_edad_efecto := fedad(NULL, TO_NUMBER(TO_CHAR(pfnacimi, 'YYYYMMDD')),
                                      TO_NUMBER(TO_CHAR(pfefecto, 'YYYYMMDD')), 1);
               v_temporadas := TRUNC((v_nedamar - v_edad_efecto)
                                     / NVL(f_parproductos_v(psproduc, 'PER_REV_NO_ANUAL'), 10));

               IF v_temporadas > 0 THEN
                  v_fecha_renovacion :=
                     ADD_MONTHS(pfnacimi,
                                12
                                *(v_edad_efecto
                                  +(v_temporadas
                                    * NVL(f_parproductos_v(psproduc, 'PER_REV_NO_ANUAL'), 10))));
               ELSE
                  v_fecha_renovacion :=
                     ADD_MONTHS(pfnacimi,
                                12
                                *(v_edad_efecto
                                  + NVL(f_parproductos_v(psproduc, 'PER_REV_NO_ANUAL'), 10)));
               END IF;

               v_edad_ftemporada := fedad(NULL, TO_NUMBER(TO_CHAR(pfnacimi, 'YYYYMMDD')),
                                          TO_NUMBER(TO_CHAR(v_fecha_renovacion, 'YYYYMMDD')),
                                          1);

               IF v_edad_ftemporada <= v_nedamar THEN
                  v_fvencim := ADD_MONTHS(v_fecha_renovacion,
                                          12
                                          * NVL(f_parproductos_v(psproduc, 'PER_REV_NO_ANUAL'),
                                                10));
               ELSE
                  v_fvencim := v_fecha_renovacion;
               END IF;

               IF pnrenova IS NULL THEN
                  verror := pac_calc_comu.f_calcula_nrenova(psproduc, pfefecto, vnrenova);
               ELSE
                  vnrenova := pnrenova;
               END IF;

               IF vnrenova IS NOT NULL THEN
                  IF v_fvencim IS NOT NULL THEN
                     IF v_fvencim <= TO_DATE(TO_CHAR(v_fvencim, 'YYYY')
                                             || LPAD(vnrenova, 4, '0'),
                                             'YYYYMMDD') THEN
                        v_fvencim := TO_DATE(TO_CHAR(v_fvencim, 'YYYY')
                                             || LPAD(vnrenova, 4, '0'),
                                             'YYYYMMDD');
                     ELSE
                        v_fvencim := TO_DATE((TO_NUMBER(TO_CHAR(v_fvencim, 'YYYY')) + 1)
                                             || LPAD(vnrenova, 4, '0'),
                                             'YYYYMMDD');
                     END IF;
                  END IF;
               END IF;

               v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
            END IF;
         -- Fin Bug 20163
         END IF;   -- BUG 26835 - FAL - 03/05/2013
      END IF;

      pfvencim := v_fvencim;
      pnduraci := v_nduraci;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.f_calcula_fvencim_nduraci', 1,
                     'parametros: sproduc =' || psproduc || ' pfefecto =' || pfefecto
                     || ' pfnacimi =' || pfnacimi || ' v_cduraci =' || v_cduraci,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_calcula_fvencim_nduraci;

   FUNCTION ff_capital_min_garantia(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
         /*****************************************************************************************************************************
            Función que retorna el capital mínimo de una garantía parametrizado en el producto
           Si hay error devuelve NULL
      ********************************************************************************************************************************/
      vccapmin       NUMBER;
      vicapmin       NUMBER;
   BEGIN
      -- miramos que tipo de capital mínimo tiene
      -- 0 .- fijo, 1.- segun forma de pago
      -- Bug 9685 - APD - 17/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT ccapmin, icapmin
           INTO vccapmin, vicapmin
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT ccapmin, icapmin
              INTO vccapmin, vicapmin
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      ------    vicapmin := pk_nueva_produccion.f_capital_minimo_garantia(psproduc, pcactivi, pcgarant,
      ------                                                              psseguro, pnriesgo, pnmovimi); -- Bug 26501 - MMS - 05/06/2013

      -- Bug 9685 - APD - 17/04/2009 - Fin
      IF NVL(vccapmin, 0) = 1 THEN
         BEGIN
            SELECT icapmin
              INTO vicapmin
              FROM capitalmin
             WHERE sproduc = psproduc
               AND cactivi = pcactivi
               AND cforpag = pcforpag
               AND cgarant = pcgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN NULL;   -- si no está es que no hay límite mínimo
         END;
      END IF;

      RETURN vicapmin;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.ff_capital_min_garantia', NULL,
                     'parametros: sproduc =' || psproduc || ' pcactivi =' || pcactivi
                     || ' pcforpag =' || pcforpag || ' pcgarant =' || pcgarant,
                     SQLERRM);
         RETURN NULL;
   END ff_capital_min_garantia;

   FUNCTION ff_capital_max_garantia(psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER IS
      garpro         garanpro%ROWTYPE;
      vicapmax       NUMBER;
   BEGIN
      -- Bug 9685 - APD - 17/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = pcgarant
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cactivi = 0;
      END;

      -- Bug 9685 - APD - 17/04/2009 - Fin

      -- Utilizamos los campos garanpro.ip_icapmax, y garanpro.ip_icapmin porque el capital máximo
      -- puede ir cambiando ON-LINE (depende del tipo de capital, etc...)
      IF garpro.ccapmax = 1 THEN   -- Fijo
         RETURN garpro.icapmax;
      ELSIF garpro.ccapmax = 2 THEN   -- Depende de otro
         -- Bug 9685 - APD - 17/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         BEGIN
            SELECT icapmax
              INTO vicapmax
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = garpro.cgardep
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT icapmax
                 INTO vicapmax
                 FROM garanpro
                WHERE sproduc = psproduc
                  AND cgarant = garpro.cgardep
                  AND cactivi = 0;
         END;

         -- Bug 9685 - APD - 17/04/2009 - Fin
         RETURN vicapmax;
      ELSE   -- Ilimitado
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.ff_capital_max_garantia', NULL,
                     'parametros: sproduc =' || psproduc || ' pcactivi =' || pcactivi
                     || ' pcgarant =' || pcgarant,
                     SQLERRM);
         RETURN NULL;
   END ff_capital_max_garantia;

   FUNCTION f_cod_garantia(
      psproduc IN NUMBER,
      ptipo IN NUMBER,
      ppropietario IN NUMBER,
      pctipgar OUT NUMBER)
      RETURN NUMBER IS
      /********************************************************************************************
           Nos devolverá la garantía del producto parametrizada con el tipo  y propietario parametrizado en
          el producto.
          ptipo:      3- Prima periodo
                      4- Prima extraordinaria/inicial
                   5- Capital Garantizado
                   6- Fallecimietno
                   7- Accidentes

            ppropietario: 1 - asegurado 1
                        2 - asegruado 2.
       *******************************************************************************************/
      v_cgarant      NUMBER;
   BEGIN
      SELECT cgarant, ctipgar
        INTO v_cgarant, pctipgar
        FROM garanpro
       WHERE sproduc = psproduc
         AND NVL(f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, 'TIPO'),
                 0) = ptipo
         AND(NVL(f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi, cgarant,
                                 'PROPIETARIO'),
                 0) = ppropietario
             OR ppropietario IS NULL);

      RETURN v_cgarant;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.f_cod_garantia', NULL,
                     'parametros: psproduc =' || psproduc || ' ptipo=' || ptipo
                     || ' ppropietario=' || ppropietario,
                     SQLERRM);
         RETURN NULL;
   END f_cod_garantia;

   FUNCTION ff_capital_gar_tipo(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptipo IN NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL,
      propietario IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /**************************************************************************************************
       2007-02-28
       ff_Capital_Gar_Tipo --> Función que devuelve el capital de la garantía:
                               . tipo 5 = Capital Garantizado al Vencimiento
                               . tipo 3 = Capital Prima Período
                               . tipo 4 = Capital Prima Inicial
      **************************************************************************************************/
      wicapital      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT g.icapital
           INTO wicapital
           FROM estseguros s, estgaranseg g
          WHERE s.sseguro = psseguro
            AND g.sseguro = psseguro
            AND g.nmovimi = (SELECT MAX(nmovimi)
                               FROM estgaranseg g1
                              WHERE g1.sseguro = psseguro
                                AND g1.nriesgo = pnriesgo
                                AND g1.cgarant = g.cgarant)
            --                        AND g1.nmovimi <= pnmovimi)
            AND g.nriesgo = pnriesgo
            AND ptipo = f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                        pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'EST'),
                                        g.cgarant, 'TIPO')
            AND(propietario = f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                              pac_seguros.ff_get_actividad(psseguro, pnriesgo,
                                                                           'EST'),
                                              g.cgarant, 'PROPIETARIO')
                OR propietario IS NULL);
      -- Bug 9685 - APD - 17/04/2009 - Fin
      ELSIF ptablas = 'SOL' THEN
         -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT g.icapital
           INTO wicapital
           FROM solseguros s, solgaranseg g
          WHERE s.ssolicit = psseguro
            AND g.ssolicit = psseguro
            --       AND g.nmovimi = (SELECT MAX(nmovimi)
            --                         FROM garanseg g1
            --                        WHERE g1.sseguro = psseguro
            --                         AND g1.nriesgo = pnriesgo
            --                          AND g1.cgarant = g.cgarant
            --                    AND g1.nmovimi <= pnmovimi)
            AND g.nriesgo = pnriesgo
            AND ptipo = f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                        pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'SOL'),
                                        g.cgarant, 'TIPO')
            AND(propietario = f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                              pac_seguros.ff_get_actividad(psseguro, pnriesgo,
                                                                           'SOL'),
                                              g.cgarant, 'PROPIETARIO')
                OR propietario IS NULL);
      -- Bug 9685 - APD - 17/04/2009 - Fin
      ELSE
         -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT g.icapital
           INTO wicapital
           FROM seguros s, garanseg g
          WHERE s.sseguro = psseguro
            AND g.sseguro = psseguro
            AND g.nmovimi = (SELECT MAX(nmovimi)
                               FROM garanseg g1
                              WHERE g1.sseguro = psseguro
                                AND g1.nriesgo = pnriesgo
                                AND g1.cgarant = g.cgarant
                                AND g1.nmovimi <= NVL(pnmovimi, g1.nmovimi))
            AND g.nriesgo = pnriesgo
            AND ptipo = f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                        pac_seguros.ff_get_actividad(psseguro, pnriesgo),
                                        g.cgarant, 'TIPO')
            AND(propietario = f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                              pac_seguros.ff_get_actividad(psseguro, pnriesgo),
                                              g.cgarant, 'PROPIETARIO')
                OR propietario IS NULL);
      -- Bug 9685 - APD - 17/04/2009 - Fin
      END IF;

      RETURN wicapital;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.ff_Capital_Gar_Tipo', NULL,
                     f_axis_literales(153052, 2), SQLERRM);
         RETURN NULL;
   END ff_capital_gar_tipo;

   FUNCTION ff_get_fvencim_producto(psproduc IN NUMBER, pfnacimi IN DATE, pfefecto IN DATE)
      RETURN DATE IS
      /******************************************************************************************************************************************
         Función que devuelve la fecha de vencimiento por defecto parametrizada en el producto.

          La función retorna:
             -- fvencim: si todo es correcto
             -- NULL: Si no cumple alguna validación o hay un error.
      *************************************************************************************************************************************/
      num_err        NUMBER;
      v_cduraci      NUMBER;
      v_nduraci      NUMBER;
      v_fvencim      DATE;
      error          EXCEPTION;
   BEGIN
      SELECT cduraci
        INTO v_cduraci
        FROM productos
       WHERE sproduc = psproduc;

      num_err := f_calcula_fvencim_nduraci(psproduc, pfnacimi, pfefecto, v_cduraci, v_nduraci,
                                           v_fvencim);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      RETURN v_fvencim;
   EXCEPTION
      WHEN error THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.f_get_fvencim_producto', NULL,
                     'parametros: psproduc = ' || psproduc || '  pfnacimi = ' || pfnacimi
                     || '  pfefecto = ' || pfefecto,
                     SQLERRM);
         RETURN NULL;
   END ff_get_fvencim_producto;

   FUNCTION ff_get_cap_garanpro(
      psproduc IN NUMBER,
      ptipo IN NUMBER,
      ppropietario IN NUMBER,
      pcforpag IN NUMBER)
      RETURN NUMBER IS
      /******************************************************************************************************************************************
         Función que devuelve el capital de la garantia parametrizado en el producto según el tipo de garantía y el
         asegurado (asegurado 1 o asegurado2).

          La función retorna:
             -- capital: si todo es correcto
             -- NULL: Si no cumple alguna validación o hay un error.
      *************************************************************************************************************************************/
      v_cgarant      NUMBER;
      v_ctipgar      NUMBER;
      v_capital      NUMBER;
      num_err        NUMBER;
      v_ctipcap      NUMBER;
      v_icapmax      NUMBER;
      v_cactivi      NUMBER;
      error          EXCEPTION;
   BEGIN
      v_cgarant := f_cod_garantia(psproduc, ptipo, ppropietario, v_ctipgar);

      IF v_cgarant IS NOT NULL THEN
         SELECT ctipcap, icapmax, cactivi
           INTO v_ctipcap, v_icapmax, v_cactivi
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = v_cgarant;

         IF v_ctipcap = 1 THEN   -- Capital Fijo
            v_capital := v_icapmax;
         ELSIF v_ctipcap = 2 THEN   -- Capital Variable
            v_capital := ff_capital_min_garantia(psproduc, v_cactivi, pcforpag, v_cgarant);
         ELSIF v_ctipcap = 4 THEN   -- No hay capital
            v_capital := 0;
         END IF;

         RETURN v_capital;
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.f_get_cap_garanpro', NULL,
                     'parametros: psproduc= ' || psproduc || '  ptipo= ' || ptipo
                     || '  ppropietario= ' || ppropietario || ' pcforpag=' || pcforpag,
                     SQLERRM);
         RETURN NULL;
   END ff_get_cap_garanpro;

   FUNCTION f_get_reval_producto(psproduc IN NUMBER, pcrevali OUT NUMBER)
      RETURN NUMBER IS
      /******************************************************************************************************************************************
         Función que devuelve el valor de la revalorización por defecto parametrizada en el producto.

          La función retorna:
             -- nrevali: si todo es correcto
             -- NULL: Si no cumple alguna validación o hay un error.
      *************************************************************************************************************************************/
      v_nrevali      NUMBER;
      v_crevali      NUMBER;
      v_irevali      NUMBER;
      v_prevali      NUMBER;
   BEGIN
      SELECT crevali, NVL(irevali, 0), NVL(prevali, 0)
        INTO v_crevali, v_irevali, v_prevali
        FROM productos
       WHERE sproduc = psproduc;

      IF v_crevali = 1 THEN   -- Lineal
         v_nrevali := v_irevali;
      ELSIF v_crevali = 2 THEN   -- Geométrica
         v_nrevali := v_prevali;
      ELSE
         v_nrevali := v_prevali;   --JRH Tarea 6966
      END IF;

      pcrevali := v_crevali;
      RETURN v_nrevali;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.f_get_reval_producto', NULL,
                     'parametros: psproduc= ' || psproduc, SQLERRM);
         RETURN NULL;
   END f_get_reval_producto;

   FUNCTION ff_get_duracion(ptablas IN VARCHAR2, psseguro IN NUMBER)
      RETURN NUMBER IS
      v_duracion     NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSIF ptablas = 'SOL' THEN
         SELECT sproduc
           INTO v_sproduc
           FROM solseguros
          --          WHERE sseguro = psseguro;
         WHERE  ssolicit = psseguro;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'DURPER'), 0) = 1 THEN
         -- Buscamos la duración periodo
         IF ptablas = 'EST' THEN
            SELECT ndurper
              INTO v_duracion
              FROM estseguros_aho
             WHERE sseguro = psseguro;
         ELSIF ptablas = 'SOL' THEN
            SELECT ndurper
              INTO v_duracion
              FROM solseguros_aho
             WHERE ssolicit = psseguro;
         ELSE
            SELECT ndurper
              INTO v_duracion
              FROM seguros_aho
             WHERE sseguro = psseguro;
         END IF;
      ELSE
         -- Buscamos la duración de la póliza
         IF ptablas = 'EST' THEN
            SELECT nduraci
              INTO v_duracion
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSIF ptablas = 'SOL' THEN
            SELECT nduraci
              INTO v_duracion
              FROM solseguros
             WHERE ssolicit = psseguro;
         ELSE
            SELECT nduraci
              INTO v_duracion
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;
      END IF;

      RETURN v_duracion;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.ff_get_duracion', NULL,
                     'parametros: ptablas= ' || ptablas || ' ; psseguro = ' || psseguro,
                     SQLERRM);
         RETURN NULL;
   END ff_get_duracion;

   FUNCTION f_get_reval_poliza(
      ptablas IN VARCHAR2 DEFAULT 'SEG',
      psseguro IN NUMBER,
      pcrevali OUT NUMBER)
      RETURN NUMBER IS
      /********************************************************************************************************************************
         Función que devuelve el valor de la revalorización de una póliza.
         Parámetros de entrada: . ptablas = Tablas ('EST' - temporales, 'SEG' - reales, 'SOL' - solicitudes)

         Parámetros de salida: . pcrevali = Tipo de revalorización
      *****************************************************************************************************************************/
      v_nrevali      NUMBER;
      v_crevali      NUMBER;
      v_irevali      NUMBER;
      v_prevali      NUMBER;
      num_err        NUMBER;
   BEGIN
      -- Se busca el código de la forma de pago de la prestación de la póliza según el parámetro ptablas
      -- Ini 13888 -- 18/05/2020
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT crevali, NVL(prevali, 0), NVL(irevali, 0)
              INTO v_crevali, v_prevali, v_irevali
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- BUG8925:DRA:26-02-2009:Si estamos en suplementos es el SSEGURO real
               SELECT a.crevali, NVL(a.prevali, 0), NVL(a.irevali, 0)
                 INTO v_crevali, v_prevali, v_irevali
                 FROM estseguros a
                WHERE a.ssegpol = psseguro
                and a.sseguro = (select max(b.sseguro) from estseguros b where b.ssegpol = a.ssegpol);
         END;
         -- Ini 13888 -- 18/05/2020
      ELSIF ptablas = 'SOL' THEN
         SELECT crevali, NVL(prevali, 0), NVL(irevali, 0)
           INTO v_crevali, v_prevali, v_irevali
           FROM solseguros
          WHERE ssolicit = psseguro;
      ELSE
         SELECT crevali, NVL(prevali, 0), NVL(irevali, 0)
           INTO v_crevali, v_prevali, v_irevali
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF v_crevali = 1 THEN   -- Lineal
         v_nrevali := v_irevali;
      ELSIF v_crevali = 2 THEN   -- Geométrica
         v_nrevali := v_prevali;
      ELSE
         v_nrevali := v_prevali;   --JRH Tarea 6966
      END IF;

      pcrevali := v_crevali;
      RETURN v_nrevali;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.F_get_reval_poliza', NULL,
                     'parametros: ptablas = ' || ptablas || ' psseguro =' || psseguro,
                     SQLERRM);
         RETURN NULL;
   END f_get_reval_poliza;

   --
   --
   --
   FUNCTION ff_prima_inicial(
      psseguro IN seguros.sseguro%TYPE,
      pcforpag IN seguros.cforpag%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE)
      RETURN NUMBER IS
   BEGIN
      CASE pcforpag
         WHEN 0 THEN
            RETURN ff_capital_gar_tipo('SEG', psseguro, pnriesgo, 3, 1);
         ELSE
            RETURN ff_capital_gar_tipo('SEG', psseguro, pnriesgo, 4, 1);
      END CASE;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.ff_prima_inicial', 1,
                     'psSeguro = ' || psseguro || ' pcForPag = ' || pcforpag, SQLERRM);
         RETURN NULL;
   END;

   --
   -- Funció FF_PRIMA_SATISFECHA
   -- Donat un sseguro torna la prima satisfeta
   --
   FUNCTION ff_prima_satisfecha(psseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER IS
      v              NUMBER;
   BEGIN
      SELECT SUM(imovimi)
        INTO v
        FROM ctaseguro cs
       WHERE cs.cmovimi IN(1, 2, 8)
         AND cs.sseguro = psseguro
         AND cmovanu <> 1;   -- líneas no anuladas

      RETURN v;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.ff_prima_satisfecha', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END;

   --
   -- Funció FF_PRIMA_SATISFECHA_FECHA
   -- Donat un sseguro torna la prima satisfeta fins a un data
   --
   FUNCTION ff_prima_satisfecha_fecha(psseguro IN seguros.sseguro%TYPE, pfecha IN DATE)
      RETURN NUMBER IS
      v              NUMBER;
   BEGIN
      SELECT SUM(imovimi)
        INTO v
        FROM ctaseguro cs
       WHERE cs.cmovimi IN(1, 2, 8)
         AND cs.sseguro = psseguro
         AND cmovanu <> 1   -- líneas no anuladas
         AND TRUNC(fvalmov) <= TRUNC(pfecha);

      RETURN v;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.ff_prima_satisfecha', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END;

   --
   --
   --
   FUNCTION ff_falta_nie(
      psseguro IN seguros.sseguro%TYPE,
      psperson IN NUMBER,
      pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      -- Nota : posar aquest if és per optimitzar, en realitat el SELECT ja tornaria el valor correcte
      IF psperson IS NOT NULL THEN
         RETURN pac_personas.ff_falta_nie(psperson, pfecha);
      ELSE
         FOR r IN (SELECT SUM(CASE pac_personas.ff_falta_nie(a.sperson, pfecha)
                                 WHEN 1 THEN a.norden
                                 ELSE 0
                              END) valor
                     FROM asegurados a
                    WHERE a.sseguro = psseguro
                      AND(a.sperson = psperson
                          OR psperson IS NULL)) LOOP
            RETURN r.valor;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.FF_FALTA_NIE', 1,
                     'psSeguro=' || psseguro || ' psPerson=' || psperson || ' pFecha='
                     || pfecha,
                     SQLERRM);
         RETURN(NULL);
   END;

   --
   --
   --
   FUNCTION ff_baixa_titular(
      psseguro IN seguros.sseguro%TYPE,
      psperson IN NUMBER,
      pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      FOR r IN
         (SELECT SUM(CASE
                        WHEN a.ffecfin < NVL(pfecha, a.ffecfin)
                         OR a.ffecmue < NVL(pfecha, a.ffecmue) THEN CASE
                                                                      WHEN psperson IS NULL THEN a.norden
                                                                      ELSE 1
                                                                   END
                        ELSE 0
                     END) valor
            FROM asegurados a
           WHERE a.sseguro = psseguro
             AND(a.sperson = psperson
                 OR psperson IS NULL)) LOOP
         RETURN r.valor;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.FF_BAIXA_TITULAR', 1,
                     'psSeguro=' || psseguro || ' psPerson=' || psperson || ' pFecha='
                     || pfecha,
                     SQLERRM);
         RETURN(NULL);
   END;

   FUNCTION ff_desquadrament(psseguro IN seguros.sseguro%TYPE, ptipus IN NUMBER)
      RETURN NUMBER IS
      v_descuadre    NUMBER;
   BEGIN
      SELECT cdescuadre
        INTO v_descuadre
        FROM cnvpolizas
       WHERE sseguro = psseguro;

      RETURN v_descuadre;
   -- RETURN CASE pTipus WHEN 1 THEN 0 ELSE 0 END;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;   -- si no ha llegado migrada no hay descuadre
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.FF_DESQUADRAMENT', 1,
                     'psSeguro=' || psseguro || ' pTipus=' || ptipus, SQLERRM);
         RETURN(1);
   END;

   FUNCTION f_calcula_fcaranu(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pfefecto IN DATE,
      pnrenova IN NUMBER,
      ofcaranu OUT DATE)
      RETURN NUMBER IS
      lmeses         NUMBER;
      dd             VARCHAR2(2);
      ddmm           VARCHAR2(4);
      fecha_aux      DATE;
      lctipefe       NUMBER;
      lfcanua        DATE;
      lmensaje       NUMBER;
      num_err        NUMBER := 0;
   BEGIN
      SELECT ctipefe
        INTO lctipefe
        FROM productos
       WHERE sproduc = psproduc;

      lmeses := 12 / pcforpag;
      ---->P_CONTROL_error(null, 'emision', 'lmeses   ='||lmeses);
      dd := SUBSTR(LPAD(pnrenova, 4, 0), 3, 2);
      ddmm := dd || SUBSTR(LPAD(pnrenova, 4, 0), 1, 2);

      IF TO_CHAR(pfefecto, 'DDMM') = ddmm
         OR LPAD(pnrenova, 4, 0) IS NULL THEN
         --lfcanua     := ADD_MONTHS(v_pol.fefecto, 12);
         lfcanua := f_summeses(pfefecto, 12, dd);
      ELSE
         IF lctipefe = 2 THEN   -- a día 1/mes por exceso
            fecha_aux := ADD_MONTHS(pfefecto, 13);
            lfcanua := TO_DATE(ddmm || TO_CHAR(fecha_aux, 'YYYY'), 'DDMMYYYY');
         ELSE
            BEGIN
               lfcanua := TO_DATE(ddmm || TO_CHAR(pfefecto, 'YYYY'), 'DDMMYYYY');
            EXCEPTION
               WHEN OTHERS THEN
                  IF ddmm = 2902 THEN
                     ddmm := 2802;
                     lfcanua := TO_DATE(ddmm || TO_CHAR(pfefecto, 'YYYY'), 'DDMMYYYY');
                  ELSE
                     lmensaje := 104510;
                     --Fecha de renovación (mmdd) incorrecta
                     num_err := 1;
                  END IF;
            END;
         END IF;

         IF lfcanua <= pfefecto THEN
            --lfcanua     := ADD_MONTHS(lfcanua, 12);
            lfcanua := f_summeses(lfcanua, 12, dd);
         END IF;
      END IF;

      ofcaranu := lfcanua;

      IF num_err <> 0 THEN
         RETURN(lmensaje);
      ELSE
         RETURN(0);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.f_calcula_fcaranu', 1,
                     'parametros: psproduc:' || psproduc || ', cforpag =' || pcforpag
                     || ', pfefecto =' || pfefecto,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_calcula_fcaranu;

   /************************************************************************
        f_calcula_frevisio
           Calcula data revisió

        Paràmetres d'entrada:
         psproduc : Producto
         pnduraci = Duración
         pndurper  : Duración del periodo
         pfefecto : fecha inicial
         pmodo : 1 = Nueva Producción; 2 = Revision

        Paràmetres de sortida
         pfrevisio : data revisió

         retorna 0 si todo correcto o código de error
     *************************************************************************/
   -- Bug 12277 - APD - 15/12/2009 - se añade a la función el parametro pmodo
   -- que indicará si venimos de Nueva Produccion (1) o una Revision (2)
   FUNCTION f_calcula_frevisio(
      psproduc IN NUMBER,
      pnduraci IN NUMBER,
      pndurper IN NUMBER,
      pfefecto IN DATE,
      pfrevisio OUT DATE,
      pmodo IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      par_fecharev   NUMBER;
      diarev         VARCHAR2(100);
      diarev_2       VARCHAR2(100);
      diarev_3       VARCHAR2(100);
      diarev_4       VARCHAR2(100);
      fecha1         DATE;
      fecha2         DATE;
      fecha3         DATE;
      fecha4         DATE;
      fecha5         DATE;
      fechaini       DATE;
      par_fecharev_np NUMBER;   -- BUG15135:DRA:23/06/2010
   BEGIN
      par_fecharev := NVL(f_parproductos_v(psproduc, 'FECHAREV'), 0);

      -- BUG15135:DRA:23/06/2010:Inici
      IF pmodo = 1 THEN   -- Estamos en NP
         par_fecharev_np := NVL(f_parproductos_v(psproduc, 'FECHAREV_NP'), 0);

         IF par_fecharev_np <> 0 THEN   -- existe FECHAREV_NP
            par_fecharev := par_fecharev_np;   -- Cambiamos para NP el par_fecharev origen
         END IF;
      END IF;

      -- BUG15135:DRA:23/06/2010:Fi
      IF NVL(f_parproductos_v(psproduc, 'RENOVA_REVISA'), 0) <> 0 THEN   -- Si revisamos
         IF par_fecharev = 0 THEN
            pfrevisio := NULL;
         ELSIF par_fecharev = 1 THEN
            pfrevisio := ADD_MONTHS(pfefecto, NVL(pnduraci, 0) * 12);
         ELSIF par_fecharev = 2 THEN
            pfrevisio := ADD_MONTHS(pfefecto, NVL(pndurper, 0) * 12);
         ELSIF par_fecharev = 3 THEN
            pfrevisio := ADD_MONTHS(pfefecto, 12);
         ELSIF par_fecharev = 4 THEN
            pfrevisio := ADD_MONTHS(pfefecto, 6);
         ELSIF par_fecharev = 5 THEN
            pfrevisio := pfefecto;
            diarev := LPAD(NVL(f_parproductos_v(psproduc, 'DIAREV'), '0101'), 4, '0');
            fechaini := TO_DATE(TO_CHAR('0101' || TO_CHAR(pfefecto, 'yyyy')), 'DDMMYYYY');
            fecha1 := TO_DATE(TO_CHAR(diarev || TO_CHAR(pfefecto, 'yyyy')), 'DDMMYYYY');
            fecha2 := ADD_MONTHS(fecha1, 6);
            fecha3 := ADD_MONTHS(fecha1, 12);

            IF pfrevisio BETWEEN fechaini AND fecha1 - 1 THEN
               pfrevisio := fecha1;
            ELSIF pfrevisio BETWEEN fecha1 AND fecha2 - 1 THEN
               pfrevisio := fecha2;
            ELSE
               pfrevisio := fecha3;
            END IF;
         ELSIF par_fecharev = 6 THEN
            pfrevisio := ADD_MONTHS(pfefecto, 3);
         ELSIF par_fecharev = 7 THEN
            pfrevisio := pfefecto;   --add_months(pfefecto, 6);
            diarev := LPAD(NVL(f_parproductos_v(psproduc, 'DIAREV'), '0101'), 4, '0');
            fechaini := TO_DATE(TO_CHAR('0101' || TO_CHAR(pfefecto, 'yyyy')), 'DDMMYYYY');
            fecha1 := TO_DATE(TO_CHAR(diarev || TO_CHAR(pfefecto, 'yyyy')), 'DDMMYYYY');
            fecha2 := ADD_MONTHS(fecha1, 3);
            fecha3 := ADD_MONTHS(fecha1, 6);
            fecha4 := ADD_MONTHS(fecha1, 9);
            fecha5 := ADD_MONTHS(fecha1, 12);

            IF pfrevisio BETWEEN fechaini AND fecha1 - 1 THEN
               pfrevisio := fecha1;
            ELSIF pfrevisio BETWEEN fecha1 AND fecha2 - 1 THEN
               pfrevisio := fecha2;
            ELSIF pfrevisio BETWEEN fecha2 AND fecha3 - 1 THEN
               pfrevisio := fecha3;
            ELSIF pfrevisio BETWEEN fecha3 AND fecha4 - 1 THEN
               pfrevisio := fecha4;
            ELSE
               pfrevisio := fecha5;
            END IF;
         -- Bug 10876 - JRH  - 10/08/2009 - Anual natural
         ELSIF par_fecharev = 8 THEN
            pfrevisio := pfefecto;
            diarev := LPAD(NVL(f_parproductos_v(psproduc, 'DIAREV'), '0101'), 4, '0');
            fechaini := TO_DATE(TO_CHAR('0101' || TO_CHAR(pfefecto, 'yyyy')), 'DDMMYYYY');
            fecha1 := TO_DATE(TO_CHAR(diarev || TO_CHAR(pfefecto, 'yyyy')), 'DDMMYYYY');
            fecha2 := ADD_MONTHS(fecha1, 12);

            IF pfrevisio BETWEEN fechaini AND fecha1 - 1 THEN
               pfrevisio := fecha1;
            ELSIF pfrevisio BETWEEN fecha1 AND fecha2 - 1 THEN
               pfrevisio := fecha2;
            END IF;
         -- Bug 12277 - APD  - 15/12/2009 - Revisión incial con fecha fija por producto y siguientes segun durper
         -- si estamos en NP la fecha de revisión será el valor del parámetro de producto FECHARENOVINI
         -- si estamos en Revision (Renovacion) realizar lo mismo que en el caso en que FECHAREV = 2 (renovación por DURPER).
         ELSIF par_fecharev = 9 THEN
            IF pmodo = 1 THEN   -- Nueva Produccion
               pfrevisio := pac_parametros.f_parproducto_f(psproduc, 'FECHARENOVINI');

               IF pfrevisio IS NULL THEN
                  RETURN 1000458;   -- No se ha podido calcular la fecha de renovación
               END IF;
            ELSE   -- pmodo = 2 (Revision)
               pfrevisio := ADD_MONTHS(pfefecto, NVL(pndurper, 0) * 12);
            END IF;
         -- Bug 12277 - APD  - 15/12/2009 - Revisión basada en fecha según producto
         -- la fecha de revisión será el valor del parámetro de producto FECHARENOVPROD
         -- Se dará un aviso de error si FECHARENOVPROD <= que la última fecha de revisión.
         ELSIF par_fecharev = 10 THEN
            pfrevisio := pac_parametros.f_parproducto_f(psproduc, 'FECHARENOVPROD');

            IF pfrevisio IS NULL
               OR pfrevisio <= pfefecto THEN
               RETURN 1000458;   -- No se ha podido calcular la fecha de renovación
            END IF;
         -- Ini bug 18624 - SRA - 25/05/2011
         ELSIF par_fecharev = 11 THEN   --Si el tipo es 11 añadir el DURPER_NP
            DECLARE
               pndurper_np    NUMBER;
            BEGIN
               pndurper_np := pac_parametros.f_parproducto_n(psproduc, 'DURPER_NP');
               pfrevisio := ADD_MONTHS(pfefecto, NVL(pndurper_np, 0) * 12);
            END;
         -- Fin bug 18624 - SRA - 25/05/2011
         END IF;
      -- fi Bug 10876 - JRH  - 10/08/2009
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CALC_COMU.F_CALCULA_FREVISIO', 1,
                     'psproduc=' || psproduc || ' pnduraci=' || pnduraci || ' pndurper='
                     || pndurper || ' pfefecto=' || pfefecto || ' pmodo=' || pmodo,
                     SQLERRM);
         RETURN 180888;   -- Error al calcular la fecha de revisión
   END f_calcula_frevisio;

------------------------------------------------------------------------------
-- Mantis 7919.#6.i.12/2008.
------------------------------------------------------------------------------
   FUNCTION f_calcula_ndurcob(psproduc IN NUMBER, pnduraci IN NUMBER, pndurcob OUT NUMBER)
      RETURN NUMBER IS
      w_ndurcob      productos.ndurcob%TYPE;
   --
   BEGIN
      SELECT ndurcob
        INTO w_ndurcob
        FROM productos
       WHERE sproduc = psproduc;

      -- Si ndurcob de la taula PRODUCTOS es null, ndurcob de SEGUROS tb serà null
      IF w_ndurcob IS NULL THEN
         pndurcob := NULL;
      ELSE
         pndurcob := pnduraci - w_ndurcob;

         IF pndurcob < 0 THEN
            pndurcob := 0;
         END IF;
      END IF;

      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CALC_COMU.F_CALCULA_NDURCOB', 1,
                     'psproduc=' || psproduc || ' pnduraci=' || pnduraci || ' pndurcob='
                     || pndurcob,
                     SQLERRM);
         RETURN(9000652);   -- Error càlcul ndurcob
   END f_calcula_ndurcob;

------------------------------------------------------------------------------
-- Mantis 7919.#6.f.12/2008.
------------------------------------------------------------------------------

   ------------------------------------------------------------------------------
-- Mantis 10470.#6.i.07/2009.JJG/NMM.CEM - ESCUT - Profesiones sobreprimas y extraprimas
------------------------------------------------------------------------------
   FUNCTION ff_get_infoprofesion(
      p_fecha IN DATE,
      p_cempres IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_cactivi IN NUMBER,
      p_cgarant IN NUMBER,
      p_tipo IN VARCHAR2,
      p_cprofes IN NUMBER,
      po_sobreprima OUT NUMBER,   -- Bug 10876 - JRH  - 10/08/2009 - Anual natural
      p_cgruppro IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      /***********************************************************************
       FF_GET_INFOPROFESION: Recupera sobreprima, extraprima o estado de
       rechazo o Retención para un producto y garantía según la profesión.
          ptipo = 'S' return = Sobreprima
                  'E'          Extraprima
                  'R'          0 -  Nada, 1 - Retenido, 2 - Rechazado

       param in psproduc  : Producto, Garantía y tpo de consulta
       param out mensajes : mensajes de error
       return             : Extraprima, Sobreprima, Retención, Rechazo.
        ***********************************************************************/
      v_cgruppro     NUMBER(4);
      v_precarg      NUMBER(6, 2);
      v_iextrap      NUMBER(19, 12);
      v_retrech      NUMBER(1);
      w_pas          PLS_INTEGER := 0;
   --
   BEGIN
      /*
         IF p_cgruppro = 0 THEN
            w_pas := 1;

            SELECT cgruppro
              INTO v_cgruppro
              FROM profesionprod
             WHERE cprofes = p_cprofes
               AND cgarant = p_cgarant
               AND ctipseg = p_ctipseg
               AND ffecini <= p_fecha
               AND(p_fecha <= ffecfin
                   OR ffecfin IS NULL);

            w_pas := 2;
         ELSE
            w_pas := 3;
            v_cgruppro := p_cgruppro;
         END IF;
        */
      w_pas := 4;

      BEGIN
         SELECT precarg, iextrap, DECODE(creten, 'S', 1, 'R', 2, 0)
           INTO v_precarg, v_iextrap, v_retrech
           FROM profesionprod
          WHERE cempres = p_cempres
            AND cramo = p_cramo
            AND cmodali = p_cmodali
            AND ctipseg = p_ctipseg
            AND ccolect = p_ccolect
            AND cactivi = p_cactivi
            AND cgarant = p_cgarant
            AND cprofes = p_cprofes
            AND(cgruppro = NVL(p_cgruppro, 0)
                OR NVL(p_cgruppro, 0) = 0)
            AND ffecini <= p_fecha
            AND(p_fecha <= ffecfin
                OR ffecfin IS NULL);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            po_sobreprima := 0;
            RETURN(0);
      END;

      w_pas := 5;

      CASE
         WHEN p_tipo = 'S' THEN
            w_pas := 6;
            po_sobreprima := v_precarg;
         WHEN p_tipo = 'E' THEN
            w_pas := 7;
            po_sobreprima := v_iextrap;
         WHEN p_tipo = 'R' THEN
            w_pas := 8;
            po_sobreprima := v_retrech;
         ELSE
            w_pas := 9;
            p_tab_error(f_sysdate, f_user, 'PAC_CALC_COMU.FF_GET_INFOPROFESION', w_pas,
                        'p_cempres=' || p_cempres || ' pcramo=' || p_cramo || ' pcmodali='
                        || p_cmodali || ' pctipseg=' || p_ctipseg || ' pccolect=' || p_ccolect
                        || ' pcactivi=' || p_cactivi || ' pcgarant=' || p_cgarant || ' ptipo='
                        || p_tipo || ' pcprofes=' || p_cprofes || ' pcgruppro=' || p_cgruppro,
                        SUBSTR(SQLERRM, 1, 255));
            -- Pas incorrecte de paràmetres a la funció.
            RETURN(101901);
      END CASE;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CALC_COMU.FF_GET_INFOPROFESION', w_pas,
                     'p_cempres=' || p_cempres || ' pcramo=' || p_cramo || ' pcmodali='
                     || p_cmodali || ' pctipseg=' || p_ctipseg || ' pccolect=' || p_ccolect
                     || ' pcactivi=' || p_cactivi || ' pcgarant=' || p_cgarant || ' ptipo='
                     || p_tipo || ' pcprofes=' || p_cprofes || ' pcgruppro=' || p_cgruppro,
                     SUBSTR(SQLERRM, 1, 255));
         -- Error al obtenir dades de sobreprimes i extraprimes segons professió.
         RETURN(9001855);
   END ff_get_infoprofesion;

------------------------------------------------------------------------------
-- Mantis 10470.#6.f.07/2009.JJG/NMM.CEM - ESCUT - Profesiones sobreprimas y extraprimas
------------------------------------------------------------------------------

   --  Ini Bug 21907 - MDS - 23/04/2012
   /***********************************************************************
      Devuelve los valores de descuentos y recargos de un riesgo
      param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales)
      param in psseguro  : Numero interno de seguro
      param in pnriesgo  : Numero interno de riesgo
      param out pdtocom  : Porcentaje descuento comercial
      param out precarg  : Porcentaje recargo técnico
      param out pdtotec  : Porcentaje descuento técnico
      param out preccom  : Porcentaje recargo comercial
      return             : number
   ***********************************************************************/
   FUNCTION f_get_dtorec_riesgo(
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ppdtocom OUT NUMBER,
      pprecarg OUT NUMBER,
      ppdtotec OUT NUMBER,
      ppreccom OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF ptablas = 'EST' THEN
         BEGIN
            SELECT NVL(pdtocom, 0), NVL(precarg, 0), NVL(pdtotec, 0), NVL(preccom, 0)
              INTO ppdtocom, pprecarg, ppdtotec, ppreccom
              FROM estriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT NVL(e.pdtocom, 0), NVL(e.precarg, 0), NVL(e.pdtotec, 0),
                      NVL(e.preccom, 0)
                 INTO ppdtocom, pprecarg, ppdtotec,
                      ppreccom
                 FROM estriesgos e, estseguros s
                WHERE s.ssegpol = psseguro
                  AND e.nriesgo = pnriesgo
                  AND e.sseguro = s.sseguro;
         END;
      ELSIF ptablas = 'SEG' THEN
         SELECT NVL(pdtocom, 0), NVL(precarg, 0), NVL(pdtotec, 0), NVL(preccom, 0)
           INTO ppdtocom, pprecarg, ppdtotec, ppreccom
           FROM riesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.F_get_dtorec_riesgo', NULL,
                     'parametros: ptablas = ' || ptablas || ' psseguro =' || psseguro
                     || ' pnriesgo =' || pnriesgo,
                     SQLERRM);
         RETURN NULL;
   END f_get_dtorec_riesgo;

--  Fin Bug 21907 - MDS - 23/04/2012

   -- Bug 20504 - JRH - 19/06/2012 - Cálculo capital orientativo
    /***********************************************************************
       Devuelve el capital recomendado
       param in ptablas   : Tablas ('EST' - temporales, 'SEG' - reales)
       param in psseguro  : Numero interno de seguro
       param in pcactivi  : Numero interno de actividad
       param in pnriesgo  : Numero interno de riesgo
       param in pcgarant  : Numero interno de garatía
       param in pfefecto  : Fecha Movimiento
       param in pnmovmi  : Número movmiento
       param out pcaprec  : Importe
       return             : number
    ***********************************************************************/
   FUNCTION f_act_cap_recomend(
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcaprec OUT NUMBER)
      RETURN NUMBER IS
      vsproduc       seguros.sproduc%TYPE;
      vclave         garanformula.clave%TYPE;
      vtraza         NUMBER := 0;
      v_origen       NUMBER;
      vnum_err       NUMBER := 0;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      vtraza := 1;

      BEGIN
         SELECT clave
           INTO vclave
           FROM garanformula
          WHERE cgarant = pcgarant
            AND ccampo = 'CAPRECOM'
            AND cactivi = pcactivi
            AND sproduc = vsproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT clave
              INTO vclave
              FROM garanformula
             WHERE cgarant = pcgarant
               AND ccampo = 'CAPRECOM'
               AND cactivi = 0
               AND sproduc = vsproduc;
      END;

      vtraza := 2;

      IF ptablas = 'EST' THEN
         v_origen := 1;
      ELSE
         v_origen := 2;
      END IF;

      vtraza := 3;
      vnum_err := pac_calculo_formulas.calc_formul(pfefecto, vsproduc,   --p_sproduc,
                                                   pcactivi,   --p_cactivi,
                                                   pcgarant, pnriesgo, psseguro, vclave,   --pclave,
                                                   pcaprec, pnmovimi,   --pnmovimi
                                                   NULL,   --psesion
                                                   v_origen, pfefecto);
      vtraza := 4;
      RETURN vnum_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Calc_Comu.f_act_cap_recomend', vtraza,
                     'parametros: ptablas = ' || ptablas || ' psseguro =' || psseguro
                     || ' pnriesgo =' || pnriesgo,
                     SQLERRM);
         RETURN 1;
   END f_act_cap_recomend;
-- Fin Bug 20504 - JRH - 19/06/2012
END pac_calc_comu;

/