--------------------------------------------------------
--  DDL for Package Body PAC_MD_DATOSCTASEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DATOSCTASEGURO" AS
/*****************************************************************************
   NAME:       PAC_MD_DATOSCTASEGURO
   PURPOSE:    Funciones de obtención de datos de CTASEGURO e importes de las pólizas de productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/04/2008   JRH             1. Creación del package.
   2.0        17/09/2009   RSC             2. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   3.0        02/11/2009   APD             3. Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   4.0        21/12/2009   APD             4. Bug 12426 : se crea la funcion f_anula_linea_ctaseguro
   5.0        16/03/2010   JRH             5. 0013692: ERROR PROVISIÓ POLISSA AMB 2 RESCATS PARCIALS
   6.0        25/05/2010   JMF             6. 0014185 ENSA101 - Proceso de carga del fichero (beneficio definido)
   7.0        28/06/2010   RSC             7. 0014598: CEM800 - Información adicional en pantallas y documentos
   8.0        22/07/2010   JRH             8. 0015485: CEM805 - Ordenación de la llibreta en la consulta de pólizas
   9.0        14/10/2010   RSC             9. 0016217: Mostrar cuadro de capitales para la pólizas de rentas
  10.0        16/11/2011   JMC            10. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
  11.0        08/12/2011   JRH            11. 0020163: LCOL_T004-Completar parametrizaci�n de los productos de Vida Individual (2� parte)
  12.0        31/07/2012   FAL            12. 0022839: LCOL - Funcionalidad Certificado 0
  13.0        09/11/2012   DCT            13. 0024628: LCOL_T001- qtracker 5361 - En un seguro prorrogado y saldado debe traer el valor de las primas pendientes
  14.0        05/12/2012   DCT            14. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
  15.0        28/03/2013   ETM            15. 0026085: POSAN600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 178 - Creaci?n prod: Saldado, Prorrogado, Convertibilidad (Fase 2)
  16.0        29/05/2013   ETM            16. 0024715: (POSPG600)-Revisar anulaciones y Rehabilitaciones.Parametrizacion-Tecnico-Parametrizar corto plazo y rescates anualidad Cumplida
  18.0        10/06/2013   AMJ            16. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
  19.0        03/09/2013   MLR            19. 0028044: RSA003-Limitar en consulta de poliza el numero de registros de resumen colectivo
  20.0        20/11/2013   AGG            20. 0028906: CALI800-Parametrizar producto PIAS para poder gestionar traspasos
  21.0        27/01/2014   JSV            21. 0029582: LCOL_T010-Revision incidencias qtracker (2014/01)
  22.0        08/04/2014   JTT            22. 0029943: Sustitucion de la formula IPARTBEN por IPBENAC
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;

   ------- Funciones internes

   --JRH 04/2008
    /*************************************************************************
       Obtiene una serie de importes calculados propios de la póliza que se deben mostrar en varias parte de la aplicación
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fecha     : fecha del rescate
       param out          : El objeto del tipo OB_IAX_DATOSECONOMICOS con los valores de esos importes
       param out mensajes : mensajes de error
       return             : 0 si todo va bien o  1.
    *************************************************************************/
   FUNCTION f_obtdatecon(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      datecon IN OUT ob_iax_datoseconomicos,
      mensajes IN OUT t_iax_mensajes,
      ptablas IN VARCHAR2 DEFAULT NULL)
-- Bug 14598 - RSC - 28/06/2010 - CEM800 - Información adicional en pantallas y documentos
   RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
               := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fecha;
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSCTASEGURO.f_ObtDatEcon';
      v_sproduc      NUMBER;
      v_norden       NUMBER;
      num            NUMBER;
      v_sperson_tomador NUMBER;
      ip_recpen      NUMBER;
      ip_imprecpen   NUMBER;
      ip_primames    NUMBER;
      ip_primaejercicio NUMBER;
      ip_primaact    NUMBER;
      viprianu       NUMBER;
      ip_reapersona  NUMBER := NULL;
      ip_reapersonatot NUMBER := NULL;
      ip_maxipersona NUMBER := NULL;
      ip_maxipersonatot NUMBER := NULL;
      ip_penpersona  NUMBER := NULL;
      vsproduc       NUMBER;
      vpendanual     NUMBER;
      vpendtotal     NUMBER;
      ip_provision   NUMBER;
      ip_capfall     NUMBER;
      ip_capgaran    NUMBER;
      pninttec       NUMBER;
      vcactivi       NUMBER;
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
      -- Bug 10828 - RSC - 14/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      ip_capesperat  NUMBER;
      -- Fin Bug 10828

      -- Bug 14598 - RSC - 22/06/2010 - CEM800 - Información adicional en pantallas y documentos
      v_ip_iprovrev  NUMBER;
      v_ip_icaprev   NUMBER;
      v_ip_icesrev   NUMBER;
      v_ip_icapgaranrev NUMBER;
      v_frevisio     seguros_aho.frevisio%TYPE;
      v_fvencim      seguros.fvencim%TYPE;
      -- Bug 14598

      -- Bug 14598 - RSC - 29/06/2010 - CEM800 - Información adicional en pantallas y documentos
      v_clave        garanformula.clave%TYPE;
      v_sesion       NUMBER;
      v_iprovrev     NUMBER := 0;
      v_icesrev      NUMBER := 0;
      v_icapgaranrev NUMBER := 0;
      -- Bug 19412 - RSC - 05/11/2011
      v_ip_iprovres  NUMBER;
      -- Fin Bug 19412
      vnum           NUMBER;
      v_ivalres      NUMBER;
      v_ip_ivalres   NUMBER;
      v_ipartben     NUMBER;
      v_ip_ipartben  NUMBER;
      v_cempres      NUMBER;

      CURSOR cur_garanprovi(pfechaa IN DATE) IS
         SELECT DISTINCT cgarant
                    FROM estgaranseg g, estseguros s
                   WHERE g.sseguro = s.sseguro
                     AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 0,
                                         g.cgarant, 'CALCULA_PROVI') = 1
                     AND s.sseguro = psseguro
                     AND g.finiefe <= pfechaa
                     AND(g.ffinefe IS NULL
                         OR g.ffinefe > pfechaa);
   -- Fin bug 14598
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR fecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Bug 14598 - RSC - 28/06/2010 - CEM800 - Información adicional en pantallas y documentos
      IF ptablas = 'EST' THEN
         vpasexec := 1;

         SELECT iprianu, sproduc, cactivi, cramo, cmodali, ctipseg, ccolect, fvencim
           INTO viprianu, vsproduc, vcactivi, xcramo, xcmodali, xctipseg, xccolect, v_fvencim
           FROM estseguros
          WHERE sseguro = psseguro;

         vpasexec := 2;

         BEGIN
            SELECT frevisio
              INTO v_frevisio
              FROM estseguros_aho
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_frevisio := v_fvencim;
         END;

         -- Provisión a fecha de revisión
         vpasexec := 3;

         FOR regs IN cur_garanprovi(fecha) LOOP
            BEGIN
               SELECT clave
                 INTO v_clave
                 FROM garanformula g
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ctipseg = xctipseg
                  AND ccolect = xccolect
                  AND ccampo = 'IPROVAC'
                  AND cgarant = regs.cgarant;

               SELECT sgt_sesiones.NEXTVAL
                 INTO v_sesion
                 FROM DUAL;

               BEGIN
                  numerr := pac_calculo_formulas.calc_formul(TRUNC(v_frevisio), vsproduc,
                                                             vcactivi, regs.cgarant, pnriesgo,
                                                             psseguro, v_clave, v_ip_iprovrev,
                                                             NULL, v_sesion, 1, TRUNC(fecha),
                                                             'R');
               EXCEPTION
                  WHEN OTHERS THEN
                     v_ip_iprovrev := 0;
               END;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ip_iprovrev := 0;
            END;

            v_iprovrev := v_iprovrev + v_ip_iprovrev;
         END LOOP;

         -- Capital esperaedo a fecha de revisión
         vpasexec := 4;

         FOR regs IN cur_garanprovi(fecha) LOOP
            BEGIN
               SELECT clave
                 INTO v_clave
                 FROM garanformula g
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ctipseg = xctipseg
                  AND ccolect = xccolect
                  AND ccampo = 'ICESREV'
                  AND cgarant = regs.cgarant;

               SELECT sgt_sesiones.NEXTVAL
                 INTO v_sesion
                 FROM DUAL;

               BEGIN
                  numerr := pac_calculo_formulas.calc_formul(TRUNC(fecha), vsproduc, vcactivi,
                                                             regs.cgarant, pnriesgo, psseguro,
                                                             v_clave, v_ip_icesrev, NULL,
                                                             v_sesion, 1, TRUNC(fecha), 'R');
               EXCEPTION
                  WHEN OTHERS THEN
                     v_ip_icesrev := 0;
               END;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ip_icesrev := 0;
            END;

            v_icesrev := v_icesrev + v_ip_icesrev;
         END LOOP;

         -- Capital garantizado a fecha de revisión
         vpasexec := 5;

         FOR regs IN cur_garanprovi(fecha) LOOP
            BEGIN
               SELECT clave
                 INTO v_clave
                 FROM garanformula g
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ctipseg = xctipseg
                  AND ccolect = xccolect
                  AND ccampo = 'ICAPREV'
                  AND cgarant = regs.cgarant;

               SELECT sgt_sesiones.NEXTVAL
                 INTO v_sesion
                 FROM DUAL;

               BEGIN
                  numerr := pac_calculo_formulas.calc_formul(TRUNC(v_frevisio), vsproduc,
                                                             vcactivi, regs.cgarant, pnriesgo,
                                                             psseguro, v_clave,
                                                             v_ip_icapgaranrev, NULL,
                                                             v_sesion, 1, TRUNC(fecha), 'R');
               EXCEPTION
                  WHEN OTHERS THEN
                     v_ip_icapgaranrev := 0;
               END;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ip_icapgaranrev := 0;
            END;

            v_icapgaranrev := v_icapgaranrev + v_ip_icapgaranrev;
         END LOOP;

         -- Bug 25788 - XVM - 24/01/2013.Inico
         vpasexec := 6;

         FOR regs IN cur_garanprovi(fecha) LOOP
            BEGIN
               SELECT clave
                 INTO v_clave
                 FROM garanformula g
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ctipseg = xctipseg
                  AND ccolect = xccolect
                  AND ccampo = 'IVALRES'
                  AND cgarant = regs.cgarant;

               SELECT sgt_sesiones.NEXTVAL
                 INTO v_sesion
                 FROM DUAL;

               BEGIN
                  numerr := pac_calculo_formulas.calc_formul(TRUNC(v_frevisio), vsproduc,
                                                             vcactivi, regs.cgarant, pnriesgo,
                                                             psseguro, v_clave, v_ip_ivalres,
                                                             NULL, v_sesion, 1, TRUNC(fecha),
                                                             'R');
               EXCEPTION
                  WHEN OTHERS THEN
                     v_ip_ivalres := 0;
               END;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ip_ivalres := 0;
            END;

            v_ivalres := v_ivalres + v_ip_ivalres;
         END LOOP;

         vpasexec := 7;

         FOR regs IN cur_garanprovi(fecha) LOOP
            BEGIN
               SELECT clave
                 INTO v_clave
                 FROM garanformula g
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ctipseg = xctipseg
                  AND ccolect = xccolect
                  AND ccampo = 'IPBENAC'   -- 29943 - JTT
                  AND cgarant = regs.cgarant;

               SELECT sgt_sesiones.NEXTVAL
                 INTO v_sesion
                 FROM DUAL;

               BEGIN
                  numerr := pac_calculo_formulas.calc_formul(TRUNC(v_frevisio), vsproduc,
                                                             vcactivi, regs.cgarant, pnriesgo,
                                                             psseguro, v_clave, v_ip_ipartben,
                                                             NULL, v_sesion, 1, TRUNC(fecha),
                                                             'R');
               EXCEPTION
                  WHEN OTHERS THEN
                     v_ip_ipartben := 0;
               END;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ip_ipartben := 0;
            END;

            v_ipartben := v_ipartben + v_ip_ipartben;
         END LOOP;

         -- Bug 25788 - XVM - 24/01/2013.Fin
         vpasexec := 8;
         datecon := ob_iax_datoseconomicos();
         datecon.impprovrevi := NVL(v_iprovrev, 0);
         datecon.impcapestrevi := NVL(v_icesrev, 0);
         datecon.impcapgarrevi := NVL(v_icapgaranrev, 0);
         datecon.valresc := NVL(v_ivalres, 0);
         datecon.valpb := NVL(v_ipartben, 0);
      ELSE
         -- Fin Bug 14598
         vpasexec := 1;

         BEGIN
            SELECT sperson
              INTO v_sperson_tomador
              FROM tomadores
             WHERE sseguro = psseguro
               AND ROWNUM = 1;
         --JRH IMP De momento hasta ue no hagamos algo con el riesgo
         END;

         vpasexec := 2;

         SELECT iprianu, sproduc, cactivi, cramo, cmodali, ctipseg, ccolect, fvencim,
                cempres
           INTO viprianu, vsproduc, vcactivi, xcramo, xcmodali, xctipseg, xccolect, v_fvencim,
                v_cempres
           FROM seguros
          WHERE sseguro = psseguro;

         -- Bug 14598 - RSC - 22/06/2010 - CEM800 - Información adicional en pantallas y documentos
         BEGIN
            SELECT frevisio
              INTO v_frevisio
              FROM seguros_aho
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_frevisio := v_fvencim;
         END;

         -- Fin Bug 14598

         -- BUG 20163-  12/2011 - JRH  -  0020163: LCOL_T004-Completar parametrizaci�n de los productos de Vida Individual (2� parte)
         SELECT COUNT(*)   --Miramos si alguna garant�a calcula provisi�n
           INTO vnum
           FROM pargaranpro
          WHERE cramo = xcramo
            AND cmodali = xcmodali
            AND ctipseg = xctipseg
            AND ccolect = xccolect
            AND cactivi = vcactivi
            AND cpargar = 'CALCULA_PROVI'
            AND cvalpar = 1;

         -- Fi BUG 20163-  12/2011 - JRH

         -- Bug 0014185 - JMF - 25/05/2010
         IF vnum = 0
            AND f_prod_ahorro(vsproduc) = 0
            AND f_parproductos_v(vsproduc, 'DETALLE_GARANT') IS NULL THEN
            -- ini Bug 0025583 - JMF - 14/01/2013
            --datecon := NULL;
            datecon := ob_iax_datoseconomicos();
            -- fin Bug 0025583 - JMF - 14/01/2013
            RETURN 0;
         END IF;

         vpasexec := 3;
         ip_recpen := f_recpen_pp(psseguro, 1);
         vpasexec := 4;
         ip_imprecpen := f_recpen_pp(psseguro, 2);
         vpasexec := 5;
         -- Aportaciones / Prima Mes
         numerr := f_primas_pagadas(psseguro,
                                    TO_DATE('01/' || TO_CHAR(fecha, 'MM') || '/'
                                            || TO_CHAR(fecha, 'yyyy'),
                                            'dd/mm/yyyy'),
                                    LAST_DAY(TO_DATE(TO_CHAR(fecha, 'MM') || '/'
                                                     || TO_CHAR(fecha, 'yyyy'),
                                                     'MM/YYYY')),
                                    ip_primames);

         IF numerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
            -- error
            RETURN 1;
         END IF;

         vpasexec := 6;

         IF ip_primames IS NULL THEN
            ip_primames := 0;
         END IF;

         -- Aportaciones / Prima Ejercicio
         numerr := f_primas_pagadas(psseguro,
                                    TO_DATE('01/01' || TO_CHAR(fecha, 'yyyy'), 'dd/mm/yyyy'),
                                    TO_DATE('31/12' || TO_CHAR(fecha, 'yyyy'), 'dd/mm/yyyy'),
                                    ip_primaejercicio);

         IF numerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
            -- el producto no permite rescates
            RETURN 1;
         END IF;

         vpasexec := 7;

         IF ip_primaejercicio IS NULL THEN
            ip_primaejercicio := 0;
         END IF;

         -- Prima Actual a nivel de Poliza y sólo recargo por fraccionamiento
         ip_primaact := f_prima_forpag('SEG', 1, 1, psseguro, NULL, NULL, viprianu, NULL);
         vpasexec := 8;

         IF NVL(f_parproductos_v(vsproduc, 'APORTMAXIMAS'), 0) = 1 THEN
            ip_reapersona :=
               NVL(pac_ppa_planes.calcula_importe_anual_persona(TO_CHAR(fecha, 'YYYY'), 1,
                                                                psseguro, 1,
                                                                v_sperson_tomador),
                   0);
            vpasexec := 9;
            ip_maxipersona :=
               NVL(pac_ppa_planes.calcula_importe_maximo_persona(TO_CHAR(fecha, 'YYYY'),
                                                                 psseguro, 1,
                                                                 v_sperson_tomador),
                   0);
            vpasexec := 10;
            ip_penpersona := NVL(ip_maxipersona, 0) - NVL(ip_reapersona, 0);
         END IF;

         IF NVL(f_parproductos_v(vsproduc, 'TIPO_LIMITE'), 0) <> 0 THEN
            --AGG 20/11/2013 Bug: 0028906. Se a�ade el importe correspondiente a los traspasos
            ip_reapersona :=
               NVL(pac_limites_ahorro.ff_calcula_importe(f_parproductos_v(vsproduc,
                                                                          'TIPO_LIMITE'),
                                                         v_sperson_tomador,
                                                         TO_NUMBER(TO_CHAR(fecha, 'YYYY'))),
                   0)
               + NVL(pac_ppa_planes.calcula_importe_anual_persona(TO_CHAR(fecha, 'YYYY'), 1,
                                                                  psseguro, 1,
                                                                  v_sperson_tomador),
                     0);
            vpasexec := 11;
            ip_reapersonatot :=
               NVL(pac_limites_ahorro.ff_calcula_importe(f_parproductos_v(vsproduc,
                                                                          'TIPO_LIMITE'),
                                                         v_sperson_tomador),
                   0);
            vpasexec := 12;
            ip_maxipersona :=
               NVL(pac_limites_ahorro.ff_iaportanual(f_parproductos_v(vsproduc, 'TIPO_LIMITE'),
                                                     fecha),
                   0);   -- Valor Fijo 280
            vpasexec := 13;
            ip_maxipersonatot :=
               NVL(pac_limites_ahorro.ff_iaporttotal(f_parproductos_v(vsproduc, 'TIPO_LIMITE'),
                                                     fecha),
                   0);   -- Valor Fijo 280
            vpendanual := ip_maxipersona - ip_reapersona;
            vpendtotal := ip_maxipersonatot - ip_reapersonatot;
            vpasexec := 14;

            SELECT LEAST(vpendanual, vpendtotal)
              INTO ip_penpersona
              FROM DUAL;
         END IF;

         -- Provisión Actual
         BEGIN
            vpasexec := 15;
            ip_provision := pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(fecha),
                                                                       'IPROVAC');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Capital Fallecimiento Actual
         BEGIN
            vpasexec := 16;
            ip_capfall := pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(fecha),
                                                                     'ICFALLAC');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Capìtal Garantizado Actual
         BEGIN
            -- Bug 29578 - ELP - 14/01/2014 - CRE - Capital garantit per pantalla incorrecte
            IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'NEW_CAPGARAN'), 0) = 1 THEN
               ip_capgaran := pac_isqlfor.f_provisio_actual(psseguro, 'ICGARAC');
            ELSE
               ip_capgaran := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                         TRUNC(fecha),
                                                                         'ICGARAC');
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Bug 10828 - RSC - 14/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
         BEGIN
            ip_capesperat := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                        TRUNC(fecha),
                                                                        'ICAPESP');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Bug 14598 - RSC - 22/06/2010 - CEM800 - Información adicional en pantallas y documentos
         BEGIN
            v_ip_iprovrev := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                        TRUNC(v_frevisio),
                                                                        'IPROVAC');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            v_ip_icaprev := pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(fecha),
                                                                       'ICAPREV');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            v_ip_icesrev := pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(fecha),
                                                                       'ICESREV');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Bug 16217 - RSC - 14/10/2010
         --BEGIN
         --   v_ip_icapgaranrev :=
         --      pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(v_frevisio),
         --                                                 'ICGARAC');
         --EXCEPTION
         --   WHEN OTHERS THEN
         --      NULL;
         --END;
         -- Fin Bug 16217
         -- Fin Bug 14598

         -- Bug 19412 - RSC - 05/11/2011
         BEGIN
            v_ip_iprovres := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                        TRUNC(fecha),
                                                                        'IPROVRES');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Bug 25788 - XVM - 24/01/2013.Inicio
         BEGIN
            vpasexec := 17;
            v_ivalres := pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(fecha),
                                                                    'IVALRES');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            vpasexec := 18;
            v_ipartben := pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(fecha),
                                                                     'IPBENAC');   -- 29943 - JTT
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         -- Bug 25788 - XVM - 24/01/2013. Fin

         -- Fin Bug 19412

         -- Fin Bug 10828
         datecon := ob_iax_datoseconomicos();
         datecon.recpen := NVL(ip_recpen, 0);
         datecon.imprecpen := NVL(ip_imprecpen, 0);
         datecon.impprimainicial := NVL(ip_primaejercicio, 0);
         datecon.impprimaper := NVL(ip_primames, 0);
         datecon.impprimaactual := NVL(ip_primaact, 0);
         datecon.impaportacum := NVL(ip_reapersona, 0);
         datecon.impaportacumtot := NVL(ip_reapersonatot, 0);
         datecon.impaportmax := NVL(ip_maxipersona, 0);
         datecon.impaportmaxtot := NVL(ip_maxipersonatot, 0);
         datecon.impaportpend := NVL(ip_penpersona, 0);
         datecon.impprovision := NVL(ip_provision, 0);
         datecon.impcapfall := NVL(ip_capfall, 0);
         datecon.impcapgaran := NVL(ip_capgaran, 0);
         -- Bug 10828 - RSC - 14/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
         datecon.impcapestimat := NVL(ip_capesperat, 0);
         -- Fin Bug 10828

         -- Bug 14598 - RSC - 22/06/2010 - CEM800 - Información adicional en pantallas y documentos

         -- Bug 16217 - RSC - 14/10/2010
         --datecon.impcapgarrevi := NVL(v_ip_icapgaranrev, 0);
         --datecon.impcapfallrevi := NVL(v_ip_icaprev, 0);
         datecon.impcapgarrevi := NVL(v_ip_icaprev, 0);
         -- Fin Bug 16217
         datecon.impprovrevi := NVL(v_ip_iprovrev, 0);
         datecon.impcapestrevi := NVL(v_ip_icesrev, 0);
         -- Fin Bug 14598

         -- Bug 19412 - RSC - 05/11/2011: Valor de rescate (provisi�n de riesgo)
         datecon.impprovresc := NVL(v_ip_iprovres, 0);
         -- Fin Bug 19412
         vpasexec := 18;
         datecon.valresc := NVL(v_ivalres, 0);
         datecon.valpb := NVL(v_ipartben, 0);
         numerr := pac_inttec.f_int_seguro('SEG', psseguro, fecha, datecon.pctinttect,
                                           pninttec);

         IF numerr NOT IN(0, 120135) THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
            -- error
            RETURN 1;
         END IF;

         vpasexec := 20;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtdatecon;

   --JRH 03/2008

   --JRH 04/2008
   /*************************************************************************
       Obtiene los registros de movimientos en CTASEGURO
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fechaIni     : fecha Inicio movimientos
       param in fechaFin    : fecha Final movimientos
       DatCtaseg out T_IAX_DATOSCTASEGURO : Collection con datos CTASEGURO
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_obtenermovimientos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fechaini IN DATE,
      fechafin IN DATE,
      datctaseg IN OUT t_iax_datosctaseguro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fechaini
            || ' fechaFin= ' || fechafin || ' fechaFin= ' || fechafin;
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSCTASEGURO.f_obtenerMovimientos';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
      datctaseg2     t_iax_datosctaseguro := t_iax_datosctaseguro();
      vsproduc       NUMBER;
      empleo         NUMBER;
      ttexto         VARCHAR2(400);
-- JGM -12/06/09 - bug 10385
      v_tcesta_unidades NUMBER;
      v_tcesta_importe NUMBER;
      v_total_cestas NUMBER;
      v_cempres      NUMBER;
      -- Bug XXX - RSC - 23/11/2009 - Ajustes PPJ Dinámic / PLA Estudiant
      v_ccesta       NUMBER;

      -- Fin Bug XXX
      CURSOR datosctaseg IS
         SELECT   c.sseguro, c.fcontab, c.nnumlin, c.ffecmov, c.fvalmov, c.cmovimi, c.imovimi,
                  c.ccalint, c.imovim2, c.nrecibo, c.nsinies, c.cmovanu, c.smovrec, c.cesta,
                  c.nunidad, c.cestado, c.fasign, c.nparpla, c.cestpar, c.iexceso, c.spermin,
                  c.sidepag, c.ctipapor, c.srecren, s.sproduc, s.cagrpro, c.falta
             FROM ctaseguro c, seguros s
            WHERE c.sseguro = psseguro
              AND c.sseguro = s.sseguro
              AND c.fcontab BETWEEN NVL(fechaini, TO_DATE('01/01/1001', 'dd/mm/yyyy'))
                                AND NVL(fechafin, TO_DATE('01/01/8001', 'dd/mm/yyyy'))
              AND((NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                   AND c.cesta IS NOT NULL)
                  OR(NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                     AND c.cmovimi IN(0, 53))
                  OR(NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1))
         -- Bug 13692 - JRH - 16/03/2010 - Nuevo orden en la consulta de pantalla
         --ORDER BY TRUNC(c.fcontab) DESC, c.nnumlin DESC;
         --ORDER BY DECODE(c.cmovimi, 0, c.fvalmov, TRUNC(c.fcontab)) DESC, c.nnumlin DESC;
         -- Bug 15485 - JRH - 22/07/2010 - 0015485: CEM805 - Ordenación de la llibreta en la consulta de pólizas
         ORDER BY DECODE(c.cmovimi,
                         0, c.fvalmov,
                         2, c.fvalmov,
                         51, c.fvalmov,   -- jlb 17724 - Modifiaciones CRT
                         53, c.fvalmov,
                         TRUNC(c.fcontab)) DESC,
                  c.cesta, c.nnumlin DESC;
         -- Fi Bug 15485 - JRH - 22/07/2010
   -- Fi Bug 13692 - JRH - 16/03/2010
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT sproduc, cempres
        INTO vsproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      numerr := f_parproductos(vsproduc, 'PPEMPLEO', empleo);

      FOR reg IN datosctaseg LOOP
         datctaseg2.EXTEND;
         datctaseg2(datctaseg2.LAST) := ob_iax_datosctaseguro();
         datctaseg2(datctaseg2.LAST).fcontab := reg.fcontab;
         datctaseg2(datctaseg2.LAST).nnumlin := reg.nnumlin;
         datctaseg2(datctaseg2.LAST).ffecmov := reg.ffecmov;
         datctaseg2(datctaseg2.LAST).fvalmov := reg.fvalmov;
         datctaseg2(datctaseg2.LAST).cmovimi := reg.cmovimi;
         datctaseg2(datctaseg2.LAST).imovimi := reg.imovimi;
         datctaseg2(datctaseg2.LAST).ccalint := reg.ccalint;
         datctaseg2(datctaseg2.LAST).imovim2 := reg.imovim2;
         datctaseg2(datctaseg2.LAST).nrecibo := reg.nrecibo;
         datctaseg2(datctaseg2.LAST).nsinies := reg.nsinies;
         datctaseg2(datctaseg2.LAST).cmovanu := reg.cmovanu;
         datctaseg2(datctaseg2.LAST).smovrec := reg.smovrec;
         datctaseg2(datctaseg2.LAST).cesta := reg.cesta;
         datctaseg2(datctaseg2.LAST).nunidad := reg.nunidad;
         datctaseg2(datctaseg2.LAST).cestado := reg.cestado;
         datctaseg2(datctaseg2.LAST).fasign := reg.fasign;
         datctaseg2(datctaseg2.LAST).nparpla := reg.nparpla;
         datctaseg2(datctaseg2.LAST).cestpar := reg.cestpar;
         datctaseg2(datctaseg2.LAST).iexceso := reg.iexceso;
         datctaseg2(datctaseg2.LAST).spermin := reg.spermin;
         datctaseg2(datctaseg2.LAST).sidepag := reg.sidepag;
         datctaseg2(datctaseg2.LAST).ctipapor := reg.ctipapor;
         datctaseg2(datctaseg2.LAST).srecren := reg.srecren;
         datctaseg2(datctaseg2.LAST).tmovanu :=
                             pac_md_listvalores.f_getdescripvalores(86, reg.cmovanu, mensajes);
         datctaseg2(datctaseg2.LAST).falta := reg.falta;

         -------------- JGM -12/06/09 - bug 10385
         IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
            OR(reg.imovimi IS NOT NULL
               AND reg.nunidad IS NOT NULL) THEN
            --datctaseg2(datctaseg2.LAST).valorliq := ROUND((reg.imovimi / reg.nunidad), 6);
            BEGIN
               SELECT iuniact,
                      iuniactcmp,
                      iuniactvtashw,
                      iuniactcmpshw
                 INTO datctaseg2(datctaseg2.LAST).valorliq,
                      datctaseg2(datctaseg2.LAST).valorliqcmp,
                      datctaseg2(datctaseg2.LAST).valorliqvtashw,
                      datctaseg2(datctaseg2.LAST).valorliqcmpshw
                 FROM tabvalces
                WHERE ccesta = reg.cesta
                  AND fvalor = TRUNC(reg.fvalmov);
            -- Bug 20995 - RSC - 20/02/2012 (Ponemos TRUNC)
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            v_tcesta_unidades := 0;
            v_tcesta_importe := 0;
            v_total_cestas := 0;

            IF reg.cesta IS NOT NULL THEN
               numerr := pac_operativa_finv.f_cta_provision_cesta(psseguro, NULL, reg.fvalmov,
                                                                  reg.cesta,
                                                                  v_tcesta_unidades,
                                                                  v_tcesta_importe,
                                                                  v_total_cestas, reg.nnumlin);
            ELSE
               IF reg.cmovimi = 0 THEN
                  SELECT ccesta
                    INTO v_ccesta
                    FROM segdisin2
                   WHERE sseguro = psseguro
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM segdisin2 s2
                                     WHERE s2.sseguro = segdisin2.sseguro);

                  numerr := pac_operativa_finv.f_cta_provision_cesta(psseguro, NULL,
                                                                     reg.fvalmov, v_ccesta,
                                                                     v_tcesta_unidades,
                                                                     v_tcesta_importe,
                                                                     v_total_cestas,
                                                                     reg.nnumlin);
               END IF;
            END IF;

            datctaseg2(datctaseg2.LAST).saldoacum := v_tcesta_unidades;
         END IF;

-------------- fi JGM----------------------------
         DECLARE
            texto          VARCHAR2(400);
            cuantos        NUMBER;
            texto2         VARCHAR2(400);
            tipo           VARCHAR2(10);
            nif            VARCHAR2(30);
            v_cmovimi      NUMBER;
         BEGIN
            texto := pac_md_listvalores.f_getdescripvalores(83, reg.cmovimi, mensajes);

            IF reg.cmovimi = 53
               AND reg.sidepag IS NOT NULL THEN
               vpasexec := 4;

               BEGIN
                  SELECT COUNT(*)
                    INTO cuantos
                    FROM prestaextrapp
                   WHERE sidepag = reg.sidepag
                     AND sseguro = reg.sseguro;

                  vpasexec := 5;

                  -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
                     SELECT nnumide
                       INTO nif
                       FROM per_personas p, pagosini
                      WHERE p.sperson = pagosini.sperson
                        AND pagosini.sidepag = reg.sidepag;
                  ELSE
                     SELECT nnumide
                       INTO nif
                       FROM per_personas p, sin_tramita_pago
                      WHERE p.sperson = sin_tramita_pago.sperson
                        AND sin_tramita_pago.sidepag = reg.sidepag;
                  END IF;
               -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               vpasexec := 6;

               IF cuantos > 0 THEN
                  texto := '[*]-' || texto;
               END IF;

               datctaseg2(datctaseg2.LAST).tmovimi := texto || '( ' || nif || ' ) ';
            ELSE
               datctaseg2(datctaseg2.LAST).tmovimi := texto;
            END IF;

            vpasexec := 7;

            -- Bug  14058 - 14/05/2010 - RSC - ENSA: Parametrización básica de los productos de beneficio definido
            IF empleo = 1 THEN
               IF reg.ctipapor IN('RP', 'RE') THEN
                  datctaseg2(datctaseg2.LAST).imovimi := NULL;
               ELSE
                  datctaseg2(datctaseg2.LAST).nunidad := NULL;
               END IF;

               datctaseg2(datctaseg2.LAST).saldoacum := NULL;
            END IF;

            -- Fin Bug 14058
            IF empleo = 1 THEN
               vpasexec := 8;

               -- Bug 14058 - RSC - 13/05/2010
               IF reg.cmovimi = 45 THEN
                  SELECT cmovimi
                    INTO v_cmovimi
                    FROM ctaseguro c
                   WHERE c.sseguro = reg.sseguro
                     AND c.nnumlin = (SELECT MAX(nnumlin)
                                        FROM ctaseguro
                                       WHERE sseguro = reg.sseguro
                                         AND nnumlin < reg.nnumlin
                                         AND cmovimi IN(1, 2, 4));
               ELSE
                  v_cmovimi := reg.cmovimi;
               END IF;

               -- Bug 0014185 - JMF - 25/05/2010:
               IF v_cmovimi IN(1, 2)
                  AND reg.spermin IS NOT NULL THEN
                  IF reg.ctipapor = 'SP' THEN   --Servicios pasados
                     texto2 := '( S.P )';
                  ELSIF reg.ctipapor = 'PR' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(151522, gidioma);
                  -- Aportación promotor
                  ELSIF reg.ctipapor = 'P' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(152674, gidioma);
                  -- Aportación prima de riesgo
                  ELSIF reg.ctipapor = 'RP' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(9901200, gidioma);
                  -- Reasignación derechos consolidados promotor
                  ELSIF reg.ctipapor = 'B' THEN
                     -- Bug 0014185 - JMF - 25/05/2010
                     texto2 := f_axis_literales(9001911, gidioma);
                  -- Beneficiario
                  ELSE   -- Por defecto Promotor
                     texto2 := f_axis_literales(151522, gidioma);
                  END IF;

                  datctaseg2(datctaseg2.LAST).tmovimi := texto || ' ' || texto2;
               ELSIF v_cmovimi IN(1, 2)
                     AND reg.spermin IS NULL THEN
                  vpasexec := 9;
                  texto2 := f_axis_literales(120459, gidioma);
                  vpasexec := 10;
                  datctaseg2(datctaseg2.LAST).tmovimi := texto || ' ' || texto2;

                  -- Voluntaria o obligatoria
                  IF reg.ctipapor = 'O' THEN   -- Obligatorias
                     texto2 := f_axis_literales(151683, gidioma);
                  ELSIF reg.ctipapor = 'V' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(151682, gidioma);
                  -- Voluntarias
                  ELSIF reg.ctipapor = 'RE' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(9901199, gidioma);
                     -- Reasignación derechos consolidados empleaso
                     datctaseg2(datctaseg2.LAST).tmovimi := NULL;
                  ELSE   -- Por defecto Voluntarias
                     texto2 := f_axis_literales(151682, gidioma);
                  END IF;

                  datctaseg2(datctaseg2.LAST).tmovimi :=
                                           datctaseg2(datctaseg2.LAST).tmovimi || ' ' || texto2;
               ELSIF v_cmovimi = 0
                     AND reg.spermin IS NOT NULL THEN
                  IF reg.ctipapor = 'SP' THEN   --Servicios pasados
                     texto2 := '( S.P )';
                  ELSIF reg.ctipapor = 'PR' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(151522, gidioma);
                  -- Aportación promotor
                  ELSIF reg.ctipapor = 'P' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(152674, gidioma);
                  -- Aportación prima de riesgo
                  ELSIF reg.ctipapor = 'RP' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(9901200, gidioma);
                  -- Reasignación derechos consolidados promotor
                  ELSIF reg.ctipapor = 'B' THEN
                     -- Bug 0014185 - JMF - 25/05/2010
                     texto2 := f_axis_literales(9001911, gidioma);
                  -- Beneficiario
                  ELSE   -- Por defecto Promotor
                     texto2 := f_axis_literales(151522, gidioma);
                  END IF;

                  datctaseg2(datctaseg2.LAST).tmovimi := texto || ' ' || texto2;
               ELSIF v_cmovimi = 0
                     AND reg.spermin IS NULL
                     AND reg.ctipapor IS NOT NULL THEN
                  vpasexec := 9;
                  texto2 := f_axis_literales(120459, gidioma);
                  vpasexec := 10;
                  datctaseg2(datctaseg2.LAST).tmovimi := texto || ' ' || texto2;

                  -- Voluntaria o obligatoria
                  IF reg.ctipapor = 'O' THEN   -- Obligatorias
                     texto2 := f_axis_literales(151683, gidioma);
                  ELSIF reg.ctipapor = 'V' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(151682, gidioma);
                  -- Voluntarias
                  ELSIF reg.ctipapor = 'RE' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(9901199, gidioma);
                     -- Reasignación derechos consolidados empleaso
                     datctaseg2(datctaseg2.LAST).tmovimi := NULL;
                  ELSE   -- Por defecto Voluntarias
                     texto2 := f_axis_literales(151682, gidioma);
                  END IF;

                  datctaseg2(datctaseg2.LAST).tmovimi :=
                                           datctaseg2(datctaseg2.LAST).tmovimi || ' ' || texto2;
               END IF;
            END IF;

            -- Bug 14058 - RSC - 13/05/2010
            IF NVL(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
               AND reg.cagrpro = 21 THEN
               IF reg.cmovimi = 45 THEN
                  SELECT cmovimi
                    INTO v_cmovimi
                    FROM ctaseguro c
                   WHERE c.sseguro = reg.sseguro
                     AND c.nnumlin = (SELECT MAX(nnumlin)
                                        FROM ctaseguro
                                       WHERE sseguro = reg.sseguro
                                         AND nnumlin < reg.nnumlin
                                         AND cmovimi IN(1, 2, 4));
               ELSE
                  v_cmovimi := reg.cmovimi;
               END IF;

               texto := pac_md_listvalores.f_getdescripvalores(83, v_cmovimi, mensajes);

               IF datctaseg2(datctaseg2.LAST).cesta IS NOT NULL THEN
                  DECLARE
                     v_fondo        fondos.tfonabv%TYPE;
                  BEGIN
                     SELECT tfonabv
                       INTO v_fondo
                       FROM fondos
                      WHERE ccodfon = datctaseg2(datctaseg2.LAST).cesta;

                     datctaseg2(datctaseg2.LAST).tmovimi := texto || '(' || v_fondo || ')';
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;
               END IF;
            END IF;

            IF reg.iexceso > 0 THEN
               texto := pac_md_listvalores.f_getdescripvalores(86, 0, mensajes);
               texto2 := pac_md_listvalores.f_getdescripvalores(86, 1, mensajes);
               datctaseg2(datctaseg2.LAST).tmovanu := texto || '/' || texto2;
            END IF;

            IF reg.cmovimi = 53 THEN
               BEGIN
                  SELECT ctipcap
                    INTO tipo
                    FROM irpf_prestaciones
                   WHERE sidepag = reg.sidepag;

                  IF tipo = 4 THEN
                     texto2 := f_axis_literales(151878, gidioma);
                     datctaseg2(datctaseg2.LAST).tmovimi := texto2 || '( ' || nif || ' ) ';
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            BEGIN
               -- Se informa el Capital de Fallecimiento y Capital Garantizado
               SELECT ccapfal,
                      ccapgar
                 INTO datctaseg2(datctaseg2.LAST).capfall,
                      datctaseg2(datctaseg2.LAST).capgarant
                 FROM ctaseguro_libreta
                WHERE sseguro = reg.sseguro
                  AND nnumlin = reg.nnumlin
                  AND fcontab = reg.fcontab;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      vpasexec := 20;
      datctaseg := datctaseg2;
      --Realizar consulta

      --DatCtaseg:=PAC_MD_DATOSCTASEGURO.f_obtenerMovimientos(psseguro ,pnriesgo,fechaIni ,fechaFin ,mensajes );
       --if numerr <> 0 then
      --     PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr); -- el producto no permite rescates
       --      RETURN 1;
      -- end if;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtenermovimientos;

   /*************************************************************************
       Obtiene los registros de movimientos en CTASEGURO_shadow
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fechaIni     : fecha Inicio movimientos
       param in fechaFin    : fecha Final movimientos
       DatCtaseg out T_IAX_DATOSCTASEGURO : Collection con datos CTASEGURO_shadow
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_obtenermovimientos_shw(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fechaini IN DATE,
      fechafin IN DATE,
      datctaseg IN OUT t_iax_datosctaseguro_shw,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || fechaini
            || ' fechaFin= ' || fechafin || ' fechaFin= ' || fechafin;
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSCTASEGURO.f_obtenerMovimientos';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
      datctaseg2     t_iax_datosctaseguro_shw := t_iax_datosctaseguro_shw();
      vsproduc       NUMBER;
      empleo         NUMBER;
      ttexto         VARCHAR2(400);
-- JGM -12/06/09 - bug 10385
      v_tcesta_unidades NUMBER;
      v_tcesta_importe NUMBER;
      v_total_cestas NUMBER;
      v_cempres      NUMBER;
      -- Bug XXX - RSC - 23/11/2009 - Ajustes PPJ Dinámic / PLA Estudiant
      v_ccesta       NUMBER;

      -- Fin Bug XXX
      CURSOR datosctaseg IS
         SELECT   c.sseguro, c.fcontab, c.nnumlin, c.ffecmov, c.fvalmov, c.cmovimi, c.imovimi,
                  c.ccalint, c.imovim2, c.nrecibo, c.nsinies, c.cmovanu, c.smovrec, c.cesta,
                  c.nunidad, c.cestado, c.fasign, c.nparpla, c.cestpar, c.iexceso, c.spermin,
                  c.sidepag, c.ctipapor, c.srecren, s.sproduc, s.cagrpro, c.falta
             FROM ctaseguro_shadow c, seguros s
            WHERE c.sseguro = psseguro
              AND c.sseguro = s.sseguro
              AND c.fcontab BETWEEN NVL(fechaini, TO_DATE('01/01/1001', 'dd/mm/yyyy'))
                                AND NVL(fechafin, TO_DATE('01/01/8001', 'dd/mm/yyyy'))
              AND((NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                   AND c.cesta IS NOT NULL)
                  OR(NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                     AND c.cmovimi IN(0, 53))
                  OR(NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1))
         -- Bug 13692 - JRH - 16/03/2010 - Nuevo orden en la consulta de pantalla
         --ORDER BY TRUNC(c.fcontab) DESC, c.nnumlin DESC;
         --ORDER BY DECODE(c.cmovimi, 0, c.fvalmov, TRUNC(c.fcontab)) DESC, c.nnumlin DESC;
         -- Bug 15485 - JRH - 22/07/2010 - 0015485: CEM805 - Ordenación de la llibreta en la consulta de pólizas
         ORDER BY DECODE(c.cmovimi,
                         0, c.fvalmov,
                         2, c.fvalmov,
                         51, c.fvalmov,   -- jlb 17724 - Modifiaciones CRT
                         53, c.fvalmov,
                         TRUNC(c.fcontab)) DESC,
                  c.cesta, c.nnumlin DESC;
         -- Fi Bug 15485 - JRH - 22/07/2010
   -- Fi Bug 13692 - JRH - 16/03/2010
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT sproduc, cempres
        INTO vsproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      numerr := f_parproductos(vsproduc, 'PPEMPLEO', empleo);

      FOR reg IN datosctaseg LOOP
         datctaseg2.EXTEND;
         datctaseg2(datctaseg2.LAST) := ob_iax_datosctaseguro_shw();
         datctaseg2(datctaseg2.LAST).fcontab := reg.fcontab;
         datctaseg2(datctaseg2.LAST).nnumlin := reg.nnumlin;
         datctaseg2(datctaseg2.LAST).ffecmov := reg.ffecmov;
         datctaseg2(datctaseg2.LAST).fvalmov := reg.fvalmov;
         datctaseg2(datctaseg2.LAST).cmovimi := reg.cmovimi;
         datctaseg2(datctaseg2.LAST).imovimi := reg.imovimi;
         datctaseg2(datctaseg2.LAST).ccalint := reg.ccalint;
         datctaseg2(datctaseg2.LAST).imovim2 := reg.imovim2;
         datctaseg2(datctaseg2.LAST).nrecibo := reg.nrecibo;
         datctaseg2(datctaseg2.LAST).nsinies := reg.nsinies;
         datctaseg2(datctaseg2.LAST).cmovanu := reg.cmovanu;
         datctaseg2(datctaseg2.LAST).smovrec := reg.smovrec;
         datctaseg2(datctaseg2.LAST).cesta := reg.cesta;
         datctaseg2(datctaseg2.LAST).nunidad := reg.nunidad;
         datctaseg2(datctaseg2.LAST).cestado := reg.cestado;
         datctaseg2(datctaseg2.LAST).fasign := reg.fasign;
         datctaseg2(datctaseg2.LAST).nparpla := reg.nparpla;
         datctaseg2(datctaseg2.LAST).cestpar := reg.cestpar;
         datctaseg2(datctaseg2.LAST).iexceso := reg.iexceso;
         datctaseg2(datctaseg2.LAST).spermin := reg.spermin;
         datctaseg2(datctaseg2.LAST).sidepag := reg.sidepag;
         datctaseg2(datctaseg2.LAST).ctipapor := reg.ctipapor;
         datctaseg2(datctaseg2.LAST).srecren := reg.srecren;
         datctaseg2(datctaseg2.LAST).tmovanu :=
                             pac_md_listvalores.f_getdescripvalores(86, reg.cmovanu, mensajes);
         datctaseg2(datctaseg2.LAST).falta := reg.falta;

         -------------- JGM -12/06/09 - bug 10385
         IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
            OR(reg.imovimi IS NOT NULL
               AND reg.nunidad IS NOT NULL) THEN
            --datctaseg2(datctaseg2.LAST).valorliq := ROUND((reg.imovimi / reg.nunidad), 6);
            BEGIN
               SELECT iuniact,
                      iuniactcmp,
                      iuniactvtashw,
                      iuniactcmpshw
                 INTO datctaseg2(datctaseg2.LAST).valorliq,
                      datctaseg2(datctaseg2.LAST).valorliqcmp,
                      datctaseg2(datctaseg2.LAST).valorliqvtashw,
                      datctaseg2(datctaseg2.LAST).valorliqcmpshw
                 FROM tabvalces
                WHERE ccesta = reg.cesta
                  AND fvalor = TRUNC(reg.fvalmov);
            -- Bug 20995 - RSC - 20/02/2012 (Ponemos TRUNC)
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            v_tcesta_unidades := 0;
            v_tcesta_importe := 0;
            v_total_cestas := 0;

            IF reg.cesta IS NOT NULL THEN
               numerr := pac_operativa_finv.f_cta_provision_cesta_shw(psseguro, NULL,
                                                                      reg.fvalmov, reg.cesta,
                                                                      v_tcesta_unidades,
                                                                      v_tcesta_importe,
                                                                      v_total_cestas,
                                                                      reg.nnumlin);
            ELSE
               IF reg.cmovimi = 0 THEN
                  SELECT ccesta
                    INTO v_ccesta
                    FROM segdisin2
                   WHERE sseguro = psseguro
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM segdisin2 s2
                                     WHERE s2.sseguro = segdisin2.sseguro);

                  numerr := pac_operativa_finv.f_cta_provision_cesta_shw(psseguro, NULL,
                                                                         reg.fvalmov, v_ccesta,
                                                                         v_tcesta_unidades,
                                                                         v_tcesta_importe,
                                                                         v_total_cestas,
                                                                         reg.nnumlin);
               END IF;
            END IF;

            datctaseg2(datctaseg2.LAST).saldoacum := v_tcesta_unidades;
         END IF;

-------------- fi JGM----------------------------
         DECLARE
            texto          VARCHAR2(400);
            cuantos        NUMBER;
            texto2         VARCHAR2(400);
            tipo           VARCHAR2(10);
            nif            VARCHAR2(30);
            v_cmovimi      NUMBER;
         BEGIN
            texto := pac_md_listvalores.f_getdescripvalores(83, reg.cmovimi, mensajes);

            IF reg.cmovimi = 53
               AND reg.sidepag IS NOT NULL THEN
               vpasexec := 4;

               BEGIN
                  SELECT COUNT(*)
                    INTO cuantos
                    FROM prestaextrapp
                   WHERE sidepag = reg.sidepag
                     AND sseguro = reg.sseguro;

                  vpasexec := 5;

                  -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
                     SELECT nnumide
                       INTO nif
                       FROM per_personas p, pagosini
                      WHERE p.sperson = pagosini.sperson
                        AND pagosini.sidepag = reg.sidepag;
                  ELSE
                     SELECT nnumide
                       INTO nif
                       FROM per_personas p, sin_tramita_pago
                      WHERE p.sperson = sin_tramita_pago.sperson
                        AND sin_tramita_pago.sidepag = reg.sidepag;
                  END IF;
               -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               vpasexec := 6;

               IF cuantos > 0 THEN
                  texto := '[*]-' || texto;
               END IF;

               datctaseg2(datctaseg2.LAST).tmovimi := texto || '( ' || nif || ' ) ';
            ELSE
               datctaseg2(datctaseg2.LAST).tmovimi := texto;
            END IF;

            vpasexec := 7;

            -- Bug  14058 - 14/05/2010 - RSC - ENSA: Parametrización básica de los productos de beneficio definido
            IF empleo = 1 THEN
               IF reg.ctipapor IN('RP', 'RE') THEN
                  datctaseg2(datctaseg2.LAST).imovimi := NULL;
               ELSE
                  datctaseg2(datctaseg2.LAST).nunidad := NULL;
               END IF;

               datctaseg2(datctaseg2.LAST).saldoacum := NULL;
            END IF;

            -- Fin Bug 14058
            IF empleo = 1 THEN
               vpasexec := 8;

               -- Bug 14058 - RSC - 13/05/2010
               IF reg.cmovimi = 45 THEN
                  SELECT cmovimi
                    INTO v_cmovimi
                    FROM ctaseguro_shadow c
                   WHERE c.sseguro = reg.sseguro
                     AND c.nnumlin = (SELECT MAX(nnumlin)
                                        FROM ctaseguro_shadow
                                       WHERE sseguro = reg.sseguro
                                         AND nnumlin < reg.nnumlin
                                         AND cmovimi IN(1, 2, 4));
               ELSE
                  v_cmovimi := reg.cmovimi;
               END IF;

               -- Bug 0014185 - JMF - 25/05/2010:
               IF v_cmovimi IN(1, 2)
                  AND reg.spermin IS NOT NULL THEN
                  IF reg.ctipapor = 'SP' THEN   --Servicios pasados
                     texto2 := '( S.P )';
                  ELSIF reg.ctipapor = 'PR' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(151522, gidioma);
                  -- Aportación promotor
                  ELSIF reg.ctipapor = 'P' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(152674, gidioma);
                  -- Aportación prima de riesgo
                  ELSIF reg.ctipapor = 'RP' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(9901200, gidioma);
                  -- Reasignación derechos consolidados promotor
                  ELSIF reg.ctipapor = 'B' THEN
                     -- Bug 0014185 - JMF - 25/05/2010
                     texto2 := f_axis_literales(9001911, gidioma);
                  -- Beneficiario
                  ELSE   -- Por defecto Promotor
                     texto2 := f_axis_literales(151522, gidioma);
                  END IF;

                  datctaseg2(datctaseg2.LAST).tmovimi := texto || ' ' || texto2;
               ELSIF v_cmovimi IN(1, 2)
                     AND reg.spermin IS NULL THEN
                  vpasexec := 9;
                  texto2 := f_axis_literales(120459, gidioma);
                  vpasexec := 10;
                  datctaseg2(datctaseg2.LAST).tmovimi := texto || ' ' || texto2;

                  -- Voluntaria o obligatoria
                  IF reg.ctipapor = 'O' THEN   -- Obligatorias
                     texto2 := f_axis_literales(151683, gidioma);
                  ELSIF reg.ctipapor = 'V' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(151682, gidioma);
                  -- Voluntarias
                  ELSIF reg.ctipapor = 'RE' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(9901199, gidioma);
                     -- Reasignación derechos consolidados empleaso
                     datctaseg2(datctaseg2.LAST).tmovimi := NULL;
                  ELSE   -- Por defecto Voluntarias
                     texto2 := f_axis_literales(151682, gidioma);
                  END IF;

                  datctaseg2(datctaseg2.LAST).tmovimi :=
                                           datctaseg2(datctaseg2.LAST).tmovimi || ' ' || texto2;
               ELSIF v_cmovimi = 0
                     AND reg.spermin IS NOT NULL THEN
                  IF reg.ctipapor = 'SP' THEN   --Servicios pasados
                     texto2 := '( S.P )';
                  ELSIF reg.ctipapor = 'PR' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(151522, gidioma);
                  -- Aportación promotor
                  ELSIF reg.ctipapor = 'P' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(152674, gidioma);
                  -- Aportación prima de riesgo
                  ELSIF reg.ctipapor = 'RP' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(9901200, gidioma);
                  -- Reasignación derechos consolidados promotor
                  ELSIF reg.ctipapor = 'B' THEN
                     -- Bug 0014185 - JMF - 25/05/2010
                     texto2 := f_axis_literales(9001911, gidioma);
                  -- Beneficiario
                  ELSE   -- Por defecto Promotor
                     texto2 := f_axis_literales(151522, gidioma);
                  END IF;

                  datctaseg2(datctaseg2.LAST).tmovimi := texto || ' ' || texto2;
               ELSIF v_cmovimi = 0
                     AND reg.spermin IS NULL
                     AND reg.ctipapor IS NOT NULL THEN
                  vpasexec := 9;
                  texto2 := f_axis_literales(120459, gidioma);
                  vpasexec := 10;
                  datctaseg2(datctaseg2.LAST).tmovimi := texto || ' ' || texto2;

                  -- Voluntaria o obligatoria
                  IF reg.ctipapor = 'O' THEN   -- Obligatorias
                     texto2 := f_axis_literales(151683, gidioma);
                  ELSIF reg.ctipapor = 'V' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(151682, gidioma);
                  -- Voluntarias
                  ELSIF reg.ctipapor = 'RE' THEN
                     -- Bug 14058 - RSC - 13/05/2010
                     texto2 := f_axis_literales(9901199, gidioma);
                     -- Reasignación derechos consolidados empleaso
                     datctaseg2(datctaseg2.LAST).tmovimi := NULL;
                  ELSE   -- Por defecto Voluntarias
                     texto2 := f_axis_literales(151682, gidioma);
                  END IF;

                  datctaseg2(datctaseg2.LAST).tmovimi :=
                                           datctaseg2(datctaseg2.LAST).tmovimi || ' ' || texto2;
               END IF;
            END IF;

            -- Bug 14058 - RSC - 13/05/2010
            IF NVL(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
               AND reg.cagrpro = 21 THEN
               IF reg.cmovimi = 45 THEN
                  SELECT cmovimi
                    INTO v_cmovimi
                    FROM ctaseguro_shadow c
                   WHERE c.sseguro = reg.sseguro
                     AND c.nnumlin = (SELECT MAX(nnumlin)
                                        FROM ctaseguro_shadow
                                       WHERE sseguro = reg.sseguro
                                         AND nnumlin < reg.nnumlin
                                         AND cmovimi IN(1, 2, 4));
               ELSE
                  v_cmovimi := reg.cmovimi;
               END IF;

               texto := pac_md_listvalores.f_getdescripvalores(83, v_cmovimi, mensajes);

               IF datctaseg2(datctaseg2.LAST).cesta IS NOT NULL THEN
                  DECLARE
                     v_fondo        fondos.tfonabv%TYPE;
                  BEGIN
                     SELECT tfonabv
                       INTO v_fondo
                       FROM fondos
                      WHERE ccodfon = datctaseg2(datctaseg2.LAST).cesta;

                     datctaseg2(datctaseg2.LAST).tmovimi := texto || '(' || v_fondo || ')';
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;
               END IF;
            END IF;

            IF reg.iexceso > 0 THEN
               texto := pac_md_listvalores.f_getdescripvalores(86, 0, mensajes);
               texto2 := pac_md_listvalores.f_getdescripvalores(86, 1, mensajes);
               datctaseg2(datctaseg2.LAST).tmovanu := texto || '/' || texto2;
            END IF;

            IF reg.cmovimi = 53 THEN
               BEGIN
                  SELECT ctipcap
                    INTO tipo
                    FROM irpf_prestaciones
                   WHERE sidepag = reg.sidepag;

                  IF tipo = 4 THEN
                     texto2 := f_axis_literales(151878, gidioma);
                     datctaseg2(datctaseg2.LAST).tmovimi := texto2 || '( ' || nif || ' ) ';
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END IF;

            BEGIN
               -- Se informa el Capital de Fallecimiento y Capital Garantizado
               SELECT ccapfal,
                      ccapgar
                 INTO datctaseg2(datctaseg2.LAST).capfall,
                      datctaseg2(datctaseg2.LAST).capgarant
                 FROM ctaseguro_libreta_shw
                WHERE sseguro = reg.sseguro
                  AND nnumlin = reg.nnumlin
                  AND fcontab = reg.fcontab;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      vpasexec := 20;
      datctaseg := datctaseg2;
      --Realizar consulta

      --DatCtaseg:=PAC_MD_DATOSCTASEGURO.f_obtenerMovimientos(psseguro ,pnriesgo,fechaIni ,fechaFin ,mensajes );
       --if numerr <> 0 then
      --     PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr); -- el producto no permite rescates
       --      RETURN 1;
      -- end if;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtenermovimientos_shw;

--JRH 03/2008

   -- Bug 12426 - APD - 21/12/2009 - se crea la funcion f_anula_linea_ctaseguro
   /*************************************************************************
       Funcion que anulará una linea en ctasseguro
       param in psseguro  : póliza
       param in pfcontab  : fecha contable
       param in pnnumlin  : Número de línea de ctaseguro
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1 si ha habido algún error
    *************************************************************************/
   FUNCTION f_anula_linea_ctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro= ' || psseguro || ' pfcontab= ' || pfcontab || ' pnnumlin= ' || pnnumlin;
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSCTASEGURO.f_anula_linea_ctaseguro';
      vnrecibo       NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pfcontab IS NULL
         OR pnnumlin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_ctaseguro.f_anula_linea_ctaseguro(psseguro, pfcontab, pnnumlin, gidioma,
                                                      vnrecibo);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE e_object_error;
      END IF;

      -- Si todo correcto se devuelve el mensaje con el número de recibo de extorno creado
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 102469, vnrecibo);
      -- Se ha grabado el recibo nº =
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_anula_linea_ctaseguro;

-- fin Bug 12426 - APD - 21/12/2009 - se crea la funcion f_anula_linea_ctaseguro
-- Bug 19303 - JMC - 16/11/2011 - se crea la funcion f_obtsaldoprorroga
   /*************************************************************************
       Funcion que obtiene los datos necesarios para saldar o prorrogar una
       p�liza.
       param in psseguro  : p�liza
       param in pnriesgo  : N�mero del riesgo.
       param in pfecha  : Fecha.
       param in ptablas  : Tablas sobre las que actua.
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1 si ha habido alg�n error
    *************************************************************************/
   FUNCTION f_obtsaldoprorroga(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      ptablas IN VARCHAR2,
      pmode IN VARCHAR2,
      piprifinanpen IN NUMBER,   --  bug 26085 - ETM -0026085
      salpro IN OUT ob_iax_saldoprorroga,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' piprifinanpen= ' || piprifinanpen || ' ptablas= ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSCTASEGURO.f_obtsaldoprorroga';
      v_iprimafinan_pen NUMBER;
      vcmoneda       NUMBER(3);
      vsproduc       NUMBER(6);
      videmora       NUMBER;
      viotrospre     NUMBER := 0;
      vcappend       NUMBER;
      vinteres       NUMBER;
      v_imprecpen    NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := f_obtdatecon(psseguro, pnriesgo, pfecha, salpro.datosecon, mensajes);
      salpro.imprescate := salpro.datosecon.impprovresc;

      --BUG24628:DCT:09/11/2012 - Inicio: 0024628: LCOL_T001- qtracker 5361 - En un seguro prorrogado y saldado debe traer el valor de las primas pendientes
      BEGIN
         SELECT pac_monedas.f_moneda_producto(sproduc), sproduc
           INTO vcmoneda, vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            vcmoneda := f_parinstalacion_n('MONEDAINST');
      END;

      FOR x IN (SELECT   p.ctapres, p.falta, ps.finiprest
                    FROM prestamos p, prestamoseg ps
                   WHERE ps.ctapres = p.ctapres
                     AND ps.falta = p.falta
                     AND p.cestado = 1
                     AND ps.sseguro = psseguro
                ORDER BY p.ctapres) LOOP
         FOR reg IN (SELECT *
                       FROM prestcuadro
                      WHERE ctapres = x.ctapres
                        AND falta = x.falta
                        AND ffincua IS NULL
                        AND fpago IS NULL) LOOP
            numerr := pac_prestamos.f_calc_demora_cuota(vcmoneda, reg.icapital, x.finiprest,
                                                        reg.fvencim, psseguro, vsproduc,
                                                        f_sysdate, videmora);
            viotrospre := NVL(viotrospre, 0) + NVL(reg.icapital, 0) + NVL(videmora, 0);
         END LOOP;

         vcappend := pac_prestamos.f_get_cappend(x.ctapres, x.falta, x.finiprest);
         /* BUG: 24448  15/03/2013  AMJ
           numerr := pac_prestamos.f_calc_interes(vcmoneda, vcappend, x.finiprest, psseguro,
                                                  vsproduc, f_sysdate, vinteres);*/

         -- BUG: 24448  15/03/2013 AMJ
         vinteres := pac_prestamos.f_calc_interesco_total(x.ctapres, x.falta, TRUNC(f_sysdate),
                                                          x.finiprest, psseguro);
         viotrospre := viotrospre + NVL(vinteres, 0);
      END LOOP;

      salpro.isaldoprest := viotrospre;

      BEGIN
         -- Recibos pendientes
         SELECT SUM(DECODE(ctiprec, 9, -vdr.itotalr, 13, -vdr.itotalr, vdr.itotalr))   -- 9 = Extorno, 13=Retorno
           INTO v_imprecpen
           FROM movrecibo, vdetrecibos vdr, recibos
          WHERE recibos.sseguro = psseguro
            AND movrecibo.nrecibo = recibos.nrecibo
            AND movrecibo.nrecibo = vdr.nrecibo
            AND movrecibo.fmovfin IS NULL
            AND movrecibo.cestrec = 0;
      EXCEPTION
         WHEN OTHERS THEN
            v_imprecpen := 0;
      END;

      salpro.datosecon.imprecpen := NVL(v_imprecpen, 0);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- error
         RETURN 1;
      END IF;

      --BUG24628:DCT:09/11/2012 - Fin: 0024628: LCOL_T001- qtracker 5361 - En un seguro prorrogado y saldado debe traer el valor de las primas pendientes

      --salpro.iprimafinan_pen := 0;   --Pendiente de determinar.
      salpro.iprima_np := 0;   --Pendiente de determinar.
      salpro.icapfall_np := 0;   --Pendiente de determinar.
      salpro.fvencim_np := TRUNC(f_sysdate);   --Pendiente de determinar.
      salpro.cmode := pmode;

/*
BUG 25888/137463 - JLTS - Se elimina la condici�n por no ser consistente
      IF numerr <> 0 THEN
         RETURN 1;
      END IF;*/
      IF piprifinanpen IS NULL THEN
         numerr := pac_propio.f_obt_primas_financiadas(psseguro, ptablas, v_iprimafinan_pen);
         salpro.iprimafinan_pen := NVL(v_iprimafinan_pen, 0);
      ELSE   --  bug 26085 - ETM -0026085
         salpro.iprimafinan_pen := NVL(piprifinanpen, 0);
      END IF;

--BUG 24715/145039--ETM--29/05/2013
      numerr := pac_propio.f_get_param_salpro(psseguro, pnriesgo, salpro.cmode,
                                              salpro.datosecon.valresc,
                                              salpro.datosecon.impprovision,
                                              salpro.datosecon.imprecpen, salpro.isaldoprest,
                                              salpro.iprimafinan_pen, salpro.iprima_np,
                                              salpro.icapfall_np, salpro.fvencim_np);

      --BUG25888/137463:JLTS:07/02/2013 - Ini
      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);   -- error
         RETURN numerr;
      END IF;

      --BUG25888/137463:JLTS:07/02/2013 - Fin
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtsaldoprorroga;

-- fin Bug 19303 - JMC - 16/11/2011

   -- BUG 0022839 - FAL - 31/07/2012
   /*************************************************************************
      Obtiene una serie de campos informativos a nivel general del colectivo
      param in psseguro  : p�liza
      param out          : El objeto del tipo OB_IAX_DATOSCOLECTIVO con la info de los colectivos
      param out mensajes : mensajes de error
      return             : 0 si todo va bien o 1.
   *************************************************************************/
   FUNCTION f_obtdatcolect(
      psseguro IN NUMBER,
      datecolect IN OUT ob_iax_datoscolectivo,
      mensajes OUT t_iax_mensajes,
      ptablas IN VARCHAR2 DEFAULT NULL,
      pmaxrows IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_resp_4081    pregunpolseg.crespue%TYPE;
      v_total_valaseg FLOAT := 0;
      datcertif      t_iax_certificados := t_iax_certificados();
      dattomado      t_iax_tomadores := t_iax_tomadores();
      ndirec         NUMBER;
      num_err        NUMBER;
      w_sumaprima    garanseg.iprianu%TYPE;
      w_sumacapital  garanseg.icapital%TYPE;
      exist          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSCTASEGURO.f_obtdatcolect';
      v_sseguro      seguros.sseguro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      vmaxrows       NUMBER := 0;
      vcount         NUMBER := 0;
      vflag          BOOLEAN := TRUE;

      CURSOR cur_colectivos(psseguro IN NUMBER) IS
         SELECT s.*
           FROM seguros s
          WHERE s.sseguro IN(SELECT sseguro
                               FROM seguros
                              WHERE npoliza = (SELECT npoliza
                                                 FROM seguros
                                                WHERE sseguro = psseguro)
                                AND ncertif <> 0)
            -- Bug 29582/0164016 - 27/01/2014
            AND creteni NOT IN(3, 4);

      CURSOR cur_estcolectivos(psseguro IN NUMBER) IS
         SELECT s.*
           FROM estseguros s
          WHERE s.sseguro IN(SELECT sseguro
                               FROM seguros
                              WHERE npoliza = (SELECT npoliza
                                                 FROM seguros
                                                WHERE sseguro = psseguro)
                                AND ncertif <> 0);

      CURSOR c_person(psperson2 IN NUMBER, psseguro IN NUMBER) IS
         SELECT pd.tapelli1, pd.tapelli2, pd.tnombre
           FROM estper_detper pd, estper_personas p
          WHERE pd.sperson = psperson2
            AND pd.sperson = p.sperson
            AND pd.cagente = ff_agente_cpervisio((SELECT s.cagente FROM estseguros s WHERE s.sseguro = psseguro));

      CURSOR c_person2(psperson IN NUMBER, psseguro IN NUMBER) IS
         SELECT pd.tapelli1, pd.tapelli2, pd.tnombre
           FROM per_detper pd, per_personas p
          WHERE pd.sperson = psperson
            AND pd.sperson = p.sperson
            AND pd.cagente = ff_agente_cpervisio((SELECT s.cagente FROM seguros s WHERE s.sseguro = psseguro));
   BEGIN
      /*IF pmaxrows IS NOT NULL THEN
         vmaxrows := pmaxrows;
      ELSE
         vmaxrows := 999999999;
      END IF;*/
      vmaxrows := 999999999;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'EST' THEN
         BEGIN
            SELECT sseguro, sproduc
              INTO v_sseguro, v_sproduc
              FROM estseguros
             WHERE sseguro = psseguro
               AND ncertif = 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
         END;
      ELSE
         BEGIN
            SELECT sseguro, sproduc
              INTO v_sseguro, v_sproduc
              FROM seguros
             WHERE sseguro = psseguro
               AND ncertif = 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
         END;
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
         datecolect := ob_iax_datoscolectivo();

         IF ptablas = 'EST' THEN
            FOR reg IN cur_estcolectivos(psseguro) LOOP
               --v_resp_4081 := 0;
               --num_err := pac_preguntas.f_get_pregunpolseg(reg.sseguro, 4081, 'EST',v_resp_4081);
               --v_total_valaseg := v_total_valaseg + NVL(v_resp_4081, 0);
               SELECT NVL(SUM(NVL(icapital, 0)), 0)
                 INTO w_sumacapital
                 FROM estgaranseg
                WHERE sseguro = reg.sseguro;

               v_total_valaseg := v_total_valaseg + w_sumacapital;

               SELECT NVL(SUM(NVL(iprianu, 0)), 0)
                 INTO w_sumaprima
                 FROM estgaranseg
                WHERE sseguro = reg.sseguro;

               datecolect.iprianus := datecolect.iprianus + w_sumaprima;

               IF reg.csituac = 2 THEN
                  datecolect.ncertfanu := datecolect.ncertfanu + 1;
               ELSIF reg.csituac = 4
                     AND reg.creteni = 2 THEN
                  datecolect.ncertpropaut := datecolect.ncertpropaut + 1;
               ELSIF reg.csituac = 4
                     AND reg.creteni = 0 THEN
                  datecolect.ncertaut := datecolect.ncertaut + 1;
               ELSIF reg.csituac = 5
                     AND reg.creteni = 2 THEN
                  datecolect.ncertpropautsupl := datecolect.ncertpropautsupl + 1;
               ELSIF reg.csituac = 5
                     AND reg.creteni = 0 THEN
                  datecolect.ncertautsupl := datecolect.ncertautsupl + 1;
               END IF;

               IF vcount < vmaxrows THEN
                  vcount := vcount + 1;
                  datcertif.EXTEND;
                  datcertif(datcertif.LAST) := ob_iax_certificados();
                  datcertif(datcertif.LAST).sseguro := reg.sseguro;
                  datcertif(datcertif.LAST).npoliza := reg.npoliza;
                  datcertif(datcertif.LAST).ncertif := reg.ncertif;
                  datcertif(datcertif.LAST).fefecto := reg.fefecto;
                  datcertif(datcertif.LAST).csituac := reg.csituac;
                  datcertif(datcertif.LAST).tsituac :=
                     pac_seguros.ff_situacion_poliza(reg.sseguro,
                                                     pac_md_common.f_get_cxtidioma, 2);
                  --pac_iax_listvalores.f_get_situacionpoliza(reg.sseguro);
                  datcertif(datcertif.LAST).treteni :=
                                        pac_iax_listvalores.f_get_retencionpoliza(reg.creteni);
                  dattomado := t_iax_tomadores();

                  FOR tom IN (SELECT sperson, nordtom, cdomici
                                FROM esttomadores
                               WHERE sseguro = reg.sseguro) LOOP
                     --datcertif(datcertif.LAST).dattomado.EXTEND;
                     dattomado.EXTEND;
                     dattomado(dattomado.LAST) := ob_iax_tomadores();
                     dattomado(dattomado.LAST).sperson := tom.sperson;
                     dattomado(dattomado.LAST).nordtom := tom.nordtom;

                     --etm ini
                     FOR per IN c_person(tom.sperson, reg.sseguro) LOOP
                        dattomado(dattomado.LAST).tapelli1 := per.tapelli1;
                        dattomado(dattomado.LAST).tapelli2 := per.tapelli2;
                        dattomado(dattomado.LAST).tnombre := per.tnombre;
                     END LOOP;

                     --etm fin
                     SELECT COUNT(*)
                       INTO exist
                       FROM estassegurats
                      WHERE sseguro = reg.sseguro
                        AND sperson = tom.sperson
                        AND ffecfin IS NULL;

                     IF exist > 0 THEN
                        dattomado(dattomado.LAST).isaseg := 1;
                     ELSE
                        dattomado(dattomado.LAST).isaseg := 0;
                     END IF;

                     IF dattomado(dattomado.LAST).direcciones IS NULL THEN
                        dattomado(dattomado.LAST).direcciones := t_iax_direcciones();
                     END IF;

                     dattomado(dattomado.LAST).direcciones.EXTEND;
                     ndirec := dattomado(dattomado.LAST).direcciones.LAST;
                     dattomado(dattomado.LAST).direcciones(ndirec) := ob_iax_direcciones();
                     dattomado(dattomado.LAST).direcciones(ndirec).cdomici := tom.cdomici;

                     IF tom.cdomici IS NOT NULL THEN
                        pac_md_listvalores.p_ompledadesdireccions
                                               (tom.sperson, tom.cdomici, 'EST',
                                                dattomado(dattomado.LAST).direcciones(ndirec),
                                                mensajes);
                     END IF;
                  END LOOP;

                  datcertif(datcertif.LAST).tomadores := dattomado;
               ELSE
                  IF vflag THEN
                     vflag := FALSE;
                     pac_iobj_mensajes.crea_nuevo_mensaje_var
                                          (mensajes, 2, 9905950,
                                           pac_iobj_mensajes.crea_variables_mensaje(vmaxrows,
                                                                                    1));
                  END IF;
               END IF;
            END LOOP;
         ELSE
            FOR reg IN cur_colectivos(psseguro) LOOP
               --v_resp_4081 := 0;
               --num_err := pac_preguntas.f_get_pregunpolseg(reg.sseguro, 4081, 'SEG', v_resp_4081);
               --v_total_valaseg := v_total_valaseg + NVL(v_resp_4081, 0);
               SELECT NVL(SUM(NVL(icapital, 0)), 0)
                 INTO w_sumacapital
                 FROM garanseg
                WHERE sseguro = reg.sseguro
                  AND ffinefe IS NULL;

               v_total_valaseg := v_total_valaseg + w_sumacapital;

               SELECT NVL(SUM(NVL(iprianu, 0)), 0)
                 INTO w_sumaprima
                 FROM garanseg
                WHERE sseguro = reg.sseguro
                  AND ffinefe IS NULL;

               datecolect.iprianus := datecolect.iprianus + w_sumaprima;

               IF reg.csituac = 2 THEN
                  datecolect.ncertfanu := datecolect.ncertfanu + 1;
               ELSIF reg.csituac = 4
                     AND reg.creteni = 2 THEN
                  datecolect.ncertpropaut := datecolect.ncertpropaut + 1;
               ELSIF reg.csituac = 4
                     AND reg.creteni = 0 THEN
                  datecolect.ncertaut := datecolect.ncertaut + 1;
               ELSIF reg.csituac = 5
                     AND reg.creteni = 2 THEN
                  datecolect.ncertpropautsupl := datecolect.ncertpropautsupl + 1;
               ELSIF reg.csituac = 5
                     AND reg.creteni = 0 THEN
                  datecolect.ncertautsupl := datecolect.ncertautsupl + 1;
               END IF;

               IF vcount < vmaxrows THEN
                  vcount := vcount + 1;
                  datcertif.EXTEND;
                  datcertif(datcertif.LAST) := ob_iax_certificados();
                  datcertif(datcertif.LAST).sseguro := reg.sseguro;
                  datcertif(datcertif.LAST).npoliza := reg.npoliza;
                  datcertif(datcertif.LAST).ncertif := reg.ncertif;
                  datcertif(datcertif.LAST).fefecto := reg.fefecto;
                  datcertif(datcertif.LAST).csituac := reg.csituac;
                  datcertif(datcertif.LAST).tsituac :=
                     pac_seguros.ff_situacion_poliza(reg.sseguro,
                                                     pac_md_common.f_get_cxtidioma, 2);
                  --pac_iax_listvalores.f_get_situacionpoliza(reg.sseguro);
                  datcertif(datcertif.LAST).treteni :=
                                        pac_iax_listvalores.f_get_retencionpoliza(reg.creteni);
                  dattomado := t_iax_tomadores();

                  FOR tom IN (SELECT sperson, nordtom, cdomici
                                FROM tomadores
                               WHERE sseguro = reg.sseguro) LOOP
                     --datcertif(datcertif.LAST).dattomado.EXTEND;
                     dattomado.EXTEND;
                     dattomado(dattomado.LAST) := ob_iax_tomadores();
                     dattomado(dattomado.LAST).sperson := tom.sperson;
                     dattomado(dattomado.LAST).nordtom := tom.nordtom;

                     --INI ETM
                     FOR per IN c_person2(tom.sperson, reg.sseguro) LOOP
                        dattomado(dattomado.LAST).tapelli1 := per.tapelli1;
                        dattomado(dattomado.LAST).tapelli2 := per.tapelli2;
                        dattomado(dattomado.LAST).tnombre := per.tnombre;
                     END LOOP;

                     --FIN ETM
                     SELECT COUNT(*)
                       INTO exist
                       FROM asegurados
                      WHERE sseguro = reg.sseguro
                        AND sperson = tom.sperson
                        AND ffecfin IS NULL;

                     IF exist > 0 THEN
                        dattomado(dattomado.LAST).isaseg := 1;
                     ELSE
                        dattomado(dattomado.LAST).isaseg := 0;
                     END IF;

                     IF dattomado(dattomado.LAST).direcciones IS NULL THEN
                        dattomado(dattomado.LAST).direcciones := t_iax_direcciones();
                     END IF;

                     dattomado(dattomado.LAST).direcciones.EXTEND;
                     ndirec := dattomado(dattomado.LAST).direcciones.LAST;
                     dattomado(dattomado.LAST).direcciones(ndirec) := ob_iax_direcciones();
                     dattomado(dattomado.LAST).direcciones(ndirec).cdomici := tom.cdomici;

                     IF tom.cdomici IS NOT NULL THEN
                        pac_md_listvalores.p_ompledadesdireccions
                                               (tom.sperson, tom.cdomici, 'POL',
                                                dattomado(dattomado.LAST).direcciones(ndirec),
                                                mensajes);
                     END IF;
                  END LOOP;

                  datcertif(datcertif.LAST).tomadores := dattomado;
               ELSE
                  IF vflag THEN
                     vflag := FALSE;
                     pac_iobj_mensajes.crea_nuevo_mensaje_var
                                          (mensajes, 2, 9905950,
                                           pac_iobj_mensajes.crea_variables_mensaje(vmaxrows,
                                                                                    1));
                  END IF;
               END IF;
            END LOOP;
         END IF;

         datecolect.vasegurado := v_total_valaseg;
         datecolect.listacertifs := datcertif;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtdatcolect;

   FUNCTION f_suplem_obert(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'SEG',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro= ' || psseguro || ' ptablas= ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSCTASEGURO.f_suplem_obert';
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_seguros.f_suplem_obert(psseguro, ptablas);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_suplem_obert;
-- FI BUG 0022839
END pac_md_datosctaseguro;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DATOSCTASEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DATOSCTASEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DATOSCTASEGURO" TO "PROGRAMADORESCSI";
