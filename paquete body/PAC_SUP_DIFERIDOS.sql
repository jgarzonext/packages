--------------------------------------------------------
--  DDL for Package Body PAC_SUP_DIFERIDOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SUP_DIFERIDOS" 
AS
   /******************************************************************************
      NOMBRE:      PAC_SUP_DIFERIDOS  (Entorno AXIS)
      PROPÓSITO:   Package con proposito de negocio para el lanzamiento programado
                   de suplementos, ya sean automáticos o diferidos. Este tipo de
                   suplementos en principio se lanzarán desde cartera.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        07/04/2008     RSC              1. -- Bug 9153 - Suplementos automáticos - Creación del package.
      2.0        27/04/2009     RSC              2. Suplemento de cambio de forma de pago diferido
      3.0        28/08/2009     JMF              3. BUG 10908: CRE - ULK - Parametrització del suplement automàtic d'actualització de patrimoni
      4.0        13/10/2009     XVM              4. 11376 - CEM - Suplementos y param. DIASATRAS
      5.0        05/11/2010     APD              5. 16095 - Implementacion y parametrizacion producto GROUPLIFE
      6.0        27/10/2010     DRA              6. 0015823: CRE803 - Activar suplement automàtic fi nòmina domiciliada per al producte CV Previsió (293)
      7.0        11/05/2012     DRA              7. 0022137: CRE800: Pòlissa CS que no passa cartera
      8.0        03/12/2012     APD              8. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
      9.0        16/04/2013     MMS              9. 0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)
      10.0       30/08/2013     JMC              10. 0027048: LCOL_T010-Revision incidencias qtracker (V)
      11.0       20/12/2013     HRE              11. Bug 0027417: HRE - Modificacion a updates
      12.0       08/01/2014     JDS              12. 0029582: LCOL_T010-Revision incidencias qtracker (2014/01)
      13.0       30/04/2014     FAL              13. 0027642: RSA102 - Producto Tradicional
      14.0       01/10/2014     FAL              14. 0032488: LCOL_PROD-Qtrackers Fase 2 - iAXIS Produccion (08/2014)
      15.0       18/01/2016     MRB              6. 0039258: ENTORNO AXIS QT_22561 LCOL
                                                             (22561 + 39258)/: MRB - 18/01/2016
                                                             Al realizar un suplemento en el certificado cero de un colectivo,
                                                             se generan los suplementos diferidos para el resto de certificados
                                                             de dicho colectivo.
                                                             Cálculo de FCARANU en los casos de CSITUAC = 4 y CRETENI 0 y 2.
                                                             Propuestas retenidas o pendientes de EMITIR, que por este motivo
                                                             no tienen el campo FCARANU informado. Esto provoca el error :
                                                             Se ha producido un error en la emisión de la póliza 'nnnnnnn
                                                             póngase en contacto con el departamento de Vida.
                                                             Se crea nueva función f_calcula_fcaranu
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;
   mensajes         t_iax_mensajes := NULL;
   gidioma          NUMBER         := pac_md_common.f_get_cxtidioma;
   v_nmovimi        NUMBER;
   v_est_sseguro    NUMBER;

   -- Bug:. 0039258: LCOL-QT_22561 Cálculo de FCARANU --
   FUNCTION f_calcula_fcaranu (psseguro IN NUMBER)
      RETURN DATE
   IS
--------------------------------------------------------------------------------
-- F_CALCULA_FCARANU                                               12/01/2016 --
--------------------------------------------------------------------------------
-- Se crea partiendo del P_EMITIR_PROPUESTA en las líneas que calcula la FCARANU
-- Sustituye en PAC_SUP_DIFERIDOS.F_PROPAGA_SUPLEMENTO, al campo S.FCARANU en
-- for reg_certifs is ...
-- Sólo calcula el FCARANU, en aquellos casos en que NO está informado y además
-- SI tenga informado el FRENOVA para las pólizas con CSITUAC = 4 y CRETENI = 0,
-- que son PÓLIZAS que se quedaron retenidas, y que liego se autorizaron. De
-- esta forma el suplemento QUEDARRÁ PROGRAMADO para cuando se emita dicho
-- certificado del colectivo.
--------------------------------------------------------------------------------
      w_cramo       seguros.cramo%TYPE       := NULL;
      w_cmodali     seguros.cmodali%TYPE     := NULL;
      w_ctipseg     seguros.ctipseg%TYPE     := NULL;
      w_ccolect     seguros.ccolect%TYPE     := NULL;
      w_npoliza     seguros.npoliza%TYPE     := NULL;
      w_ncertif     seguros.ncertif%TYPE     := NULL;
      w_frenova     seguros.frenova%TYPE     := NULL;
      w_fcaranu     seguros.fcaranu%TYPE     := NULL;
      w_csituac     seguros.csituac%TYPE     := NULL;
      w_creteni     seguros.creteni%TYPE     := NULL;
      w_nrenova     seguros.nrenova%TYPE     := NULL;
      w_fefecto     seguros.fefecto%TYPE     := NULL;
      w_ctipefe     productos.ctipefe%TYPE   := NULL;
      w_dd          VARCHAR2 (2)             := NULL;
      w_ddmm        VARCHAR2 (4)             := NULL;
      w_fecha_aux   DATE                     := NULL;
--
   BEGIN
--
      SELECT cramo, cmodali, ctipseg, ccolect, npoliza, ncertif,
             frenova, fcaranu, csituac, creteni, nrenova, fefecto
        INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_npoliza, w_ncertif,
             w_frenova, w_fcaranu, w_csituac, w_creteni, w_nrenova, w_fefecto
        FROM seguros
       WHERE sseguro = psseguro;

--
      BEGIN
--
         SELECT ctipefe
           INTO w_ctipefe
           FROM productos
          WHERE cramo = w_cramo
            AND cmodali = w_cmodali
            AND ctipseg = w_ctipseg
            AND ccolect = w_ccolect;
      EXCEPTION
         WHEN OTHERS
         THEN
            w_ctipefe := NULL;
      END;

--
      IF w_fcaranu IS NULL AND w_csituac = 4 AND w_creteni IN (0, 2)
      THEN
--
   -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
         IF w_frenova IS NOT NULL
         THEN
            w_dd := TO_CHAR (w_frenova, 'dd');
            w_ddmm := TO_CHAR (w_frenova, 'ddmm');
         ELSE
            w_dd := SUBSTR (LPAD (w_nrenova, 4, 0), 3, 2);
            w_ddmm := w_dd || SUBSTR (LPAD (w_nrenova, 4, 0), 1, 2);
         -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
         END IF;

         --
         IF w_frenova IS NOT NULL
         THEN
            w_fcaranu := w_frenova;
         ELSE
            IF    TO_CHAR (w_fefecto, 'DDMM') = w_ddmm
               OR LPAD (w_nrenova, 4, 0) IS NULL
            THEN
               -- lfcanua     := ADD_MONTHS(v_pol.fefecto, 12);
               w_fcaranu := f_summeses (w_fefecto, 12, w_dd);
            ELSE
               IF w_ctipefe = 2
               THEN                                 -- a día 1/mes por exceso
                  w_fecha_aux := ADD_MONTHS (w_fefecto, 13);
                  w_fcaranu :=
                     TO_DATE (w_ddmm || TO_CHAR (w_fecha_aux, 'YYYY'),
                              'DDMMYYYY'
                             );
               ELSE
                  --
                  BEGIN
                     w_fcaranu :=
                        TO_DATE (w_ddmm || TO_CHAR (w_fefecto, 'YYYY'),
                                 'DDMMYYYY'
                                );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        IF w_ddmm = 2902
                        THEN
                           w_ddmm := 2802;
                           w_fcaranu :=
                              TO_DATE (w_ddmm || TO_CHAR (w_fefecto, 'YYYY'),
                                       'DDMMYYYY'
                                      );
                        ELSE
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'f_calcula_fcaranu CALCULO',
                                        2,
                                           ' sseguro:'
                                        || psseguro
                                        || ' cramo:  '
                                        || w_cramo
                                        || ' npoliza:'
                                        || w_npoliza
                                        || ' ncertif:'
                                        || w_ncertif,
                                        SQLERRM
                                       );
                        END IF;
                  END;
               END IF;

               IF w_fcaranu <= w_fefecto
               THEN
                  --lfcanua     := ADD_MONTHS(lfcanua, 12);
                  w_fcaranu := f_summeses (w_fcaranu, 12, w_dd);
               END IF;
            END IF;
         -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
         END IF;
--
      END IF;

--
      RETURN w_fcaranu;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_calcula_fcaranu PRINCIPAL',
                      1,
                         ' sseguro:'
                      || psseguro
                      || ' cramo:  '
                      || w_cramo
                      || ' npoliza:'
                      || w_npoliza
                      || ' ncertif:'
                      || w_ncertif,
                      SQLERRM
                     );
         RETURN w_fcaranu;
--
   END;

   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   FUNCTION iniciarsuple
      RETURN NUMBER
   IS
   BEGIN
      v_nmovimi := NULL;
      v_est_sseguro := NULL;
      RETURN 0;
   END;

   -- Fin Bug 9153

   /***********************************************************************
      Función que nos indicará si para un determinado contrado se debe evaluar
      si se ha de lanzar o no un suplemento automático.

      param in psseguro  : Código de seguro
      return             : Number (1--> SI, 0 --> No).
   ***********************************************************************/
   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   FUNCTION f_eval_automaticos (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      v_sproduc   seguros.sproduc%TYPE;
      v_count     NUMBER;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT COUNT (*)
        INTO v_count
        FROM pds_supl_automatic
       WHERE sproduc = v_sproduc;

      IF v_count > 0
      THEN
         RETURN 1;                 -- Hay suplementos automaticos que evaluar
      END IF;

      RETURN 0;
   END f_eval_automaticos;

   -- Fin Bug 9153

   /***********************************************************************
      Función que inicia el proceso de evaluación de suplementos automáticos
      para un deteminado contrato a una fecha.

      param in psseguro  : Código de seguro
      param in pfecha    : Fecha de suplemento (fecha de carte del producto)
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   FUNCTION f_eval_autodif_cartera (
      psseguro    IN   NUMBER,
      pfcarpro    IN   DATE,
      pfcartera   IN   DATE,
      pcidioma    IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      v_sproduc          seguros.sproduc%TYPE;
      v_cursor           NUMBER;
      ss                 VARCHAR2 (3000);
      v_funcion          VARCHAR2 (40);
      v_valida           NUMBER;
      v_filas            NUMBER;
      v_carpro           DATE;
      v_pfcarant         DATE;
      v_pfcarpro         DATE;
      v_pfcaranu         DATE;
      v_pfrenova         DATE;
      v_pnanuali         NUMBER;
      v_pnfracci         NUMBER;
      v_out              NUMBER;
      v_pinfo            VARCHAR2 (1000)          := '';
      v_tmotmov          motmovseg.tmotmov%TYPE;
      v_numerr           NUMBER;
      v_entra            NUMBER                   := 0;

      --Hash de motivos
      TYPE assoc_array_motivos IS TABLE OF NUMBER
         INDEX BY VARCHAR2 (100);

      vhashmotivos       assoc_array_motivos;
      vhashmotivos_dif   assoc_array_motivos;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

---------------------------------
-- Tratamiento de automáticos
---------------------------------
      v_carpro := pfcarpro;

      WHILE v_carpro <= pfcartera
      LOOP
         FOR regs IN (SELECT   *
                          FROM pds_supl_automatic
                         WHERE sproduc = v_sproduc
                      ORDER BY cmotmov, nordensup, norden)
         LOOP
            ss := 'begin :v_valida := ' || regs.fvalfun || '; end;';

            IF DBMS_SQL.is_open (v_cursor)
            THEN
               DBMS_SQL.close_cursor (v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse (v_cursor, ss, DBMS_SQL.native);

            IF INSTR (ss, ':SSEGURO') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':SSEGURO', psseguro);
            END IF;

            IF INSTR (ss, ':FECHA') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':FECHA', v_carpro);
            END IF;

            IF INSTR (ss, ':v_valida') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':v_valida', v_valida);
            END IF;

            v_filas := DBMS_SQL.EXECUTE (v_cursor);
            DBMS_SQL.variable_value (v_cursor, 'v_valida', v_valida);

            IF DBMS_SQL.is_open (v_cursor)
            THEN
               DBMS_SQL.close_cursor (v_cursor);
            END IF;

            v_numerr := f_desmotmov (regs.cmotmov, pcidioma, v_tmotmov);

            -- Funcion de validación evaluada a cierto --> Ejecutamos suplemento automático
            IF v_valida = 1
            THEN
               v_entra := 1;

               IF vhashmotivos.EXISTS (   regs.cmotmov
                                       || regs.sproduc
                                       || regs.norden
                                      )
               THEN
                  vhashmotivos (regs.cmotmov || regs.sproduc || regs.norden) :=
                       vhashmotivos (regs.cmotmov || regs.sproduc
                                     || regs.norden
                                    )
                     + 1;
               ELSE
                  vhashmotivos (regs.cmotmov || regs.sproduc || regs.norden) :=
                                                                            1;
                  v_pinfo :=
                        v_pinfo
                     || regs.cmotmov
                     || ';'
                     || v_tmotmov
                     || ';'
                     || TO_CHAR (v_carpro, 'dd/mm/yyyy')
                     || ';'
                     || f_axis_literales (regs.sdescrip, pcidioma)
                     || '#';
               END IF;
            END IF;
         END LOOP;

         v_out :=
            f_acproxcar (psseguro,
                         v_pfcarant,
                         v_carpro,
                         v_pfcaranu,
                         v_pnanuali,
                         v_pnfracci,
                         v_pfrenova
                        );

         IF v_out <> 0
         THEN
            RETURN NULL;
         END IF;
      END LOOP;

      v_pinfo := v_pinfo || '%';
---------------------------------
-- Tratamiento de diferidos
---------------------------------
      v_carpro := pfcarpro;

      WHILE v_carpro <= pfcartera
      LOOP
         FOR regs IN (SELECT *
                        FROM sup_diferidosseg
                       WHERE sseguro = psseguro
                         AND fecsupl = v_carpro
                         AND estado = 0)
         LOOP
            ss := 'begin :v_valida := ' || regs.fvalfun || '; end;';

            IF DBMS_SQL.is_open (v_cursor)
            THEN
               DBMS_SQL.close_cursor (v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse (v_cursor, ss, DBMS_SQL.native);

            IF INSTR (ss, ':SSEGURO') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':SSEGURO', psseguro);
            END IF;

            IF INSTR (ss, ':FECHA') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':FECHA', v_carpro);
            END IF;

            IF INSTR (ss, ':CMOTMOV') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':CMOTMOV', regs.cmotmov);
            END IF;

            IF INSTR (ss, ':v_valida') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':v_valida', v_valida);
            END IF;

            v_filas := DBMS_SQL.EXECUTE (v_cursor);
            DBMS_SQL.variable_value (v_cursor, 'v_valida', v_valida);

            IF DBMS_SQL.is_open (v_cursor)
            THEN
               DBMS_SQL.close_cursor (v_cursor);
            END IF;

            v_numerr := f_desmotmov (regs.cmotmov, pcidioma, v_tmotmov);

            -- Funcion de validación evaluada a cierto --> Ejecutamos suplemento automático
            IF v_valida = 1
            THEN
               v_entra := 1;

               IF vhashmotivos_dif.EXISTS (regs.cmotmov || regs.sseguro)
               THEN
                  vhashmotivos_dif (regs.cmotmov || regs.sseguro) :=
                           vhashmotivos_dif (regs.cmotmov || regs.sseguro)
                           + 1;
               ELSE
                  vhashmotivos_dif (regs.cmotmov || regs.sseguro) := 1;
                  v_pinfo :=
                        v_pinfo
                     || regs.cmotmov
                     || ';'
                     || v_tmotmov
                     || ';'
                     || TO_CHAR (regs.fecsupl, 'dd/mm/yyyy')
                     || ';'
                     || regs.tvalord
                     || ';'
                     || regs.cusuari
                     || ';'
                     || regs.falta
                     || '#';
               END IF;
            END IF;
         END LOOP;

         v_out :=
            f_acproxcar (psseguro,
                         v_pfcarant,
                         v_carpro,
                         v_pfcaranu,
                         v_pnanuali,
                         v_pnfracci,
                         v_pfrenova
                        );

         IF v_out <> 0
         THEN
            RETURN NULL;
         END IF;
      END LOOP;

      IF v_entra <> 0
      THEN
         RETURN v_pinfo;
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_eval_autodif_cartera;

   -- Fin Bug 9153

   /***********************************************************************
      Función que inicia el proceso de evaluación de suplementos automáticos
      para un deteminado contrato a una fecha.

      param in psseguro  : Código de seguro
      param in pfecha    : Fecha de suplemento (fecha de carte del producto)
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      param in pcmotmov  : Motivo suplemento opcional
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   -- Bug 0011348: Afegir parametre opcional motiu.
   FUNCTION f_gen_supl_automaticos (
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      psproces   IN   NUMBER,
      pcmotmov   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)             := 0;
      vparam        VARCHAR2 (500)
         :=    'psseguro = '
            || psseguro
            || '; pfecha = '
            || TO_CHAR (pfecha, 'dd/mm/yyyy')
            || '; psproces = '
            || psproces
            || '; pcmotmov = '
            || pcmotmov;
      vobject       VARCHAR2 (200)
                                 := 'pac_sup_diferidos.f_gen_supl_automaticos';
      v_sproduc     seguros.sproduc%TYPE;
      v_cursor      NUMBER;
      ss            VARCHAR2 (3000);
      v_funcion     VARCHAR2 (40);
      v_valida      NUMBER;
      v_filas       NUMBER;
      -- Pruebas
      v_out         NUMBER;
      d_calcsupl    DATE;                                       -- Bug 0011349
      d_segcarpro   DATE;                                       -- Bug 0011349
      d_segcaranu   DATE;                                       -- Bug 0011349
      -- Bug - 12/11/2009 - RSC - Ajustes Suplementos automáticos
      v_fecha_sup   DATE;
      -- Fin Bug
      v_cbloquea    NUMBER                 := 0;
   -- Bug 16095 - 29/09/2010 - Se controla si algun suplemento
   BEGIN
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vpasexec);

      -- Bug 0011349: Afegir carpro i caranu
      SELECT sproduc, fcarpro, fcaranu
        INTO v_sproduc, d_segcarpro, d_segcaranu
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 1;

      -- Bug 0011348: Afegir parametre opcional motiu.
      FOR regs IN (SELECT   *
                       FROM pds_supl_automatic
                      WHERE sproduc = v_sproduc
                        AND (   pcmotmov IS NULL
                             OR (pcmotmov IS NOT NULL AND cmotmov = pcmotmov
                                )
                            )
                   ORDER BY nordensup, norden)
      LOOP
         vpasexec := 2;
         ss := 'begin :v_valida := ' || regs.fvalfun || '; end;';
         pac_log.p_log_sup_diferidos (psseguro, 0, ss, vobject, vpasexec);

         -- INI 0011349: CRE - Suplemento de cartera de PPJ Dinámico
         DECLARE
            CURSOR c1
            IS
               SELECT   a.tfecrec
                   FROM pds_supl_config a
                  WHERE a.sproduc = regs.sproduc AND a.cmotmov = regs.cmotmov
               ORDER BY DECODE (a.cmodo, 'SUPLEMENTO', 1, 2), a.cconfig;

            v_tfecrec   pds_supl_config.tfecrec%TYPE;
         BEGIN
            vpasexec := 3;
            d_calcsupl := NULL;

            OPEN c1;

            FETCH c1
             INTO v_tfecrec;

            IF c1%FOUND
            THEN
               IF v_tfecrec = 'F_FCARPRO'
               THEN
                  d_calcsupl := d_segcarpro;
               ELSIF v_tfecrec = 'F_FCARANU'
               THEN
                  d_calcsupl := d_segcaranu;
               ELSIF v_tfecrec = 'F_SYSDATE'
               THEN
                -- ini 15/07/2016 rllf MSV-113 Error en cancelación de extraprimas
                IF (NVL (pac_parametros.f_parmotmov_n (regs.cmotmov,'USA_FCARPRO_DIFERID',v_sproduc),0)=1) THEN
                 d_calcsupl := d_segcarpro;
                ELSE
                 d_calcsupl := TRUNC (f_sysdate);
                END IF;
               -- fin 15/07/2016 rllf MSV-113 Error en cancelación de extraprimas
               ELSE
                  d_calcsupl := pfecha;
               END IF;
            ELSE
               d_calcsupl := pfecha;
            END IF;

            CLOSE c1;

            vpasexec := 4;
            d_calcsupl := NVL (d_calcsupl, pfecha);
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos se adiciona EXCEPTION
         EXCEPTION
            WHEN OTHERS
            THEN
               vpasexec := 5;

               IF c1%ISOPEN
               THEN
                  CLOSE c1;
               END IF;
         END;

         vpasexec := 6;

         -- FIN 0011349: CRE - Suplemento de cartera de PPJ Dinámico
         IF DBMS_SQL.is_open (v_cursor)
         THEN
            DBMS_SQL.close_cursor (v_cursor);
         END IF;

         v_cursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (v_cursor, ss, DBMS_SQL.native);

         IF INSTR (ss, ':SSEGURO') > 0
         THEN
            DBMS_SQL.bind_variable (v_cursor, ':SSEGURO', psseguro);
         END IF;

         IF INSTR (ss, ':FECHA') > 0
         THEN
            -- 0011349: canvi data suplement calculada enlloc del parametre.
            -- Bug 11771 - 06/11/2009 - RSC - CRE - Ajustes en simulación y contratación PPJ Dinámico/Pla Estudiant
            --DBMS_SQL.bind_variable(v_cursor, ':FECHA', d_calcsupl);
            -- La validación siempre debe ser a FCARPRO del contrato
            DBMS_SQL.bind_variable (v_cursor, ':FECHA', pfecha);
         -- Fin Bug 11771
         END IF;

         IF INSTR (ss, ':v_valida') > 0
         THEN
            DBMS_SQL.bind_variable (v_cursor, ':v_valida', v_valida);
         END IF;

         v_filas := DBMS_SQL.EXECUTE (v_cursor);
         DBMS_SQL.variable_value (v_cursor, 'v_valida', v_valida);

         IF DBMS_SQL.is_open (v_cursor)
         THEN
            DBMS_SQL.close_cursor (v_cursor);
         END IF;

         vpasexec := 7;
         pac_log.p_log_sup_diferidos (psseguro,
                                      0,
                                      'v_valida = ' || v_valida,
                                      vobject,
                                      vpasexec
                                     );

         -- Funcion de validación evaluada a cierto --> Ejecutamos suplemento automático
         IF v_valida = 1
         THEN
            vpasexec := 8;

            -- Bug - 12/11/2009 - RSC - Ajustes Suplementos automáticos
            SELECT LEAST (d_calcsupl, pfecha)
              INTO v_fecha_sup
              FROM DUAL;

            -- Fin Bug
            vpasexec := 9;
            -- Ejecutamos el suplemento
            -- 0011349: canvi data suplement calculada enlloc del parametre.
            -- Bug 16095 - APD - 05/11/2010 - Se añade el valor del parametro PCEMITE
            -- donde 1 indica que se debe emitir la póliza después de ejecutar el
            -- suplemento y 0 indica que NO se debe emitir la póliza después de
            -- ejecutar el suplemento.
            v_out :=
               pac_sup_diferidos.f_supl_automatic (psseguro,
                                                   regs.sproduc,
                                                   regs.norden,
                                                   v_fecha_sup,
                                                   regs.cmotmov,
                                                   NULL,
                                                   NULL,
                                                   psproces,
                                                   regs.cemite
                                                  );

            -- Fin Bug 16095 - 05/11/2010 - Control de bloqueo de cartera
            IF v_out <> 0
            THEN
               pac_log.p_log_sup_diferidos
                           (psseguro,
                            1,
                               'pac_sup_diferidos.f_supl_automatic v_out = '
                            || v_out,
                            vobject,
                            vpasexec
                           );
               RETURN v_out;
            END IF;

            vpasexec := 10;

            -- Bug 16095 - 05/11/2010 - Control de bloqueo de cartera
            -- Si el campo pds_supl_automatic.cbloquea = 1, entonces se debe bloquear la cartera
            IF regs.cbloquea = 1
            THEN
               v_cbloquea := v_cbloquea + 1;
            -- contador de suplementos que bloquean la cartera
            END IF;
         -- Fin Bug 16095 - 05/11/2010 - Control de bloqueo de cartera
         END IF;
      END LOOP;

      vpasexec := 11;
      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                   'v_cbloquea = ' || v_cbloquea,
                                   vobject,
                                   vpasexec
                                  );

      -- Bug 16095 - 05/11/2010 - Control de bloqueo de cartera
      IF v_cbloquea <> 0
      THEN                -- al menos hay un suplemento que bloquea la cartera
         RETURN 9901538;                 -- Retencion por revision de salario
      ELSE
         -- Fin Bug 16095 - 05/11/2010 - Control de bloqueo de cartera
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_gen_supl_automaticos',
                      NULL,
                      f_axis_literales (108953, f_idiomauser),
                      SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (108953)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 108953;
   END f_gen_supl_automaticos;

   -- Fin Bug 9153

   /***********************************************************************
      Función específica para el lanzamiento de un suplemento automático a
      nivel de negocio.

      param in psseguro  : Código de seguro
      param in psproduc  : Código de producto.
      param in pnorden   : Código de orden.
      param in pfecha    : Fecha de suplemento.
      param in pcmotmov  : Código de motivo de movimiento.
      param in pnriesgo  : Importe de operación.
      param in pcgarant  : Código de garantía.
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9153 - 07/04/2009 - RSC - Suplementos automáticos
   FUNCTION f_supl_automatic (
      psseguro   IN   NUMBER,
      psproduc   IN   NUMBER,
      pnorden    IN   NUMBER,
      pfecha     IN   DATE,
      pcmotmov   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcgarant   IN   NUMBER,
      psproces   IN   NUMBER,
      pcemite    IN   NUMBER DEFAULT 1
   )                                           -- Bug 16095 - APD - 05/11/2010
      RETURN NUMBER
   IS
      numerr           NUMBER                    := 0;
      vpasexec         NUMBER                    := 1;
      vparam           VARCHAR2 (400)
         :=    'psproduc= '
            || psseguro
            || ' pnriesgo= '
            || pnriesgo
            || ' pcgarant= '
            || pcgarant
            || ' fecha= '
            || TO_CHAR (pfecha, 'dd/mm/yyyy')
            || ' psproces= '
            || psproces
            || ' pcemite= '
            || pcemite;
      vobject          VARCHAR2 (200)
                                    := 'PAC_MD_SUP_DIFERIDOS.f_supl_automatic';
      salida           EXCEPTION;
      error_fin_supl   EXCEPTION;
      warn_fin_supl    EXCEPTION;
      v_sperson        asegurados.sperson%TYPE;
      vcont            NUMBER;
      v_sproduc        seguros.sproduc%TYPE;
      v_cactivi        seguros.cactivi%TYPE;
      v_cforpag        seguros.cforpag%TYPE;
      vcempres         seguros.cempres%TYPE;
      vnpoliza         seguros.npoliza%TYPE;
      vncertif         seguros.ncertif%TYPE;
      vcramo           seguros.cramo%TYPE;
      vcmodali         seguros.cmodali%TYPE;
      vctipseg         seguros.ctipseg%TYPE;
      vccolect         seguros.ccolect%TYPE;
      vcidioma         seguros.cidioma%TYPE;
      ss               VARCHAR2 (3000);
      vwhere           VARCHAR2 (500);
      v_tcampo         VARCHAR2 (500);
      v_riesgos        VARCHAR (50);
      indice           NUMBER;
      indice_e         NUMBER;
      indice_t         NUMBER;
      v_cursor         NUMBER;
      v_funcion        VARCHAR2 (40);
      v_valida         NUMBER;
      v_filas          NUMBER;
      retorno          NUMBER;
      vcrespue1        NUMBER;
      vcrespue2        NUMBER;
      -- 22/04/2009
      v_sproces        NUMBER;
      v_nnumlin        NUMBER                    := NULL;
      v_texto          VARCHAR2 (500);
      v_err            NUMBER;
      v_column_name    VARCHAR2 (100)            := NULL;
      -- Bug 16095 - APD - 05/11/2010
      pmensaje         VARCHAR2 (500);         -- BUG 27642 - FAL - 30/04/2014
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL OR pfecha IS NULL OR pcmotmov IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL
      THEN
         numerr :=
            f_procesini (getuser,
                         1,
                         'SUPL_AUT:' || TO_CHAR (f_sysdate, 'yyyymmdd'),
                         f_axis_literales (805824, f_idiomauser),
                         v_sproces
                        );
      ELSE
         v_sproces := psproces;
      END IF;

--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg,
             ccolect, sproduc, cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg,
             vccolect, v_sproduc, v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 3;

      IF pnriesgo IS NOT NULL
      THEN
         BEGIN
            SELECT sperson
              INTO v_sperson
              FROM asegurados
             WHERE sseguro = psseguro AND norden = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN 0;       -- Si no hay riesgo no hay nada que modificar.
         END;
      END IF;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      IF v_est_sseguro IS NULL
      THEN     --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         --BUG11376-XVM-13102009
         numerr :=
            pk_suplementos.f_permite_suplementos (psseguro, pfecha, pcmotmov);

         IF numerr <> 0
         THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL
         THEN
            numerr :=
               pk_suplementos.f_permite_este_suplemento (psseguro,
                                                         pfecha,
                                                         pcmotmov
                                                        );

            IF numerr <> 0
            THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr :=
            pk_suplementos.f_inicializar_suplemento (psseguro,
                                                     'SUPLEMENTO',
                                                     pfecha,
                                                     'BBDD',
                                                     '*',
                                                     pcmotmov,
                                                     v_est_sseguro,
                                                     v_nmovimi,
                                                     'NOPRAGMA'
                                                    );

         -- BUG15823:DRA:04/11/2010
         IF numerr <> 0
         THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                   'v_est_sseguro = ' || v_est_sseguro,
                                   vobject,
                                   vpasexec
                                  );

      -- UPDATE DINÁMICO ----------------------------------------------------
      FOR regs2 IN (SELECT   *
                        FROM pds_supl_acciones
                       WHERE cmotmov = pcmotmov
                         AND sproduc = psproduc
                         AND norden = pnorden
                    ORDER BY ordenacc)
      LOOP
         IF regs2.dinaccion = 'U'
         THEN
            vwhere := regs2.twhere;
            vwhere := REPLACE (vwhere, ':SSEGURO', v_est_sseguro);
            vwhere :=
               REPLACE (vwhere,
                        ':FECHA',
                           'TO_DATE('''
                        || TO_CHAR (pfecha, 'YYYYMMDD')
                        || ''',''YYYYMMDD'')'
                       );

            IF pnriesgo IS NULL
            THEN
               vwhere := REPLACE (vwhere, ':NRIESGO', 'NRIESGO');
            ELSE
               vwhere := REPLACE (vwhere, ':NRIESGO', pnriesgo);
            END IF;

            IF pcgarant IS NULL
            THEN
               vwhere := REPLACE (vwhere, ':CGARANT', 'CGARANT');
            ELSE
               vwhere := REPLACE (vwhere, ':CGARANT', pcgarant);
            END IF;

            ----------
            -- Update
            ----------
            -- Bug 16095 - APD - 05/11/2010
            BEGIN
               SELECT column_name
                 INTO v_column_name
                 FROM all_tab_columns
                WHERE table_name = UPPER (regs2.ttable)
                  AND owner = NVL (f_parinstalacion_t ('USER_OWNER'), f_user)
                  AND column_name = 'NMOVIMI';
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_column_name := NULL;
            END;

            ss :=
                  'UPDATE '
               || regs2.ttable
               || ' SET '
               || regs2.tcampo
               || ' = '
               || regs2.naccion
               || ' WHERE '
               || vwhere;

            IF v_column_name IS NOT NULL
            THEN
               ss := ss || '   and nmovimi = ' || v_nmovimi;
            END IF;

            -- Fin Bug 16095 - APD - 05/11/2010
            EXECUTE IMMEDIATE ss;
         ELSIF regs2.dinaccion = 'I'
         THEN
            ----------
            -- Insert
            ----------
            NULL;
         ELSIF regs2.dinaccion = 'F'
         THEN
------------
-- Function
------------
            ss :=
               'BEGIN ' || ' :RETORNO := ' || regs2.tcampo || ' ; ' || 'END;';

            IF DBMS_SQL.is_open (v_cursor)
            THEN
               DBMS_SQL.close_cursor (v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse (v_cursor, ss, DBMS_SQL.native);
            DBMS_SQL.bind_variable (v_cursor, ':RETORNO', retorno);

            IF INSTR (ss, ':FECHA') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':FECHA', pfecha);
            END IF;

            IF INSTR (ss, ':SSEGURO') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':SSEGURO', v_est_sseguro);
            END IF;

            IF pcgarant IS NOT NULL
            THEN
               IF INSTR (ss, ':CGARANT') > 0
               THEN
                  DBMS_SQL.bind_variable (v_cursor, ':CGARANT', pcgarant);
               END IF;
            END IF;

            IF pnriesgo IS NOT NULL
            THEN
               IF INSTR (ss, ':NRIESGO') > 0
               THEN
                  DBMS_SQL.bind_variable (v_cursor, ':NRIESGO', pnriesgo);
               END IF;
            ELSE           -- Bug 16095 - APD - 05/11/2010 -- se añade el ELSE
               IF INSTR (ss, ':NRIESGO') > 0
               THEN
                  DBMS_SQL.bind_variable (v_cursor, ':NRIESGO', 1);
               END IF;
            END IF;

            IF INSTR (ss, ':NMOVIMI') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':NMOVIMI', v_nmovimi);
            END IF;

            -- Ini Bug 10908 - 28/08/2009 - JMF
            IF INSTR (ss, ':SPROCES') > 0
            THEN
               DBMS_SQL.bind_variable (v_cursor, ':SPROCES', psproces);
            END IF;

            -- Fi  Bug 10908 - 28/08/2009 - JMF
            v_filas := DBMS_SQL.EXECUTE (v_cursor);
            DBMS_SQL.variable_value (v_cursor, 'RETORNO', retorno);

            IF DBMS_SQL.is_open (v_cursor)
            THEN
               DBMS_SQL.close_cursor (v_cursor);
            END IF;

            -- Bug 10908 - 28/08/2009 - JMF
            IF NVL (retorno, 0) > 0
            THEN
               v_texto := f_axis_literales (retorno, f_idiomauser);
               v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         -- Bug 10908 - 28/08/2009 - JMF
         END IF;

         IF regs2.ttarifa = 1
         THEN                               -- Se debe tarifar tras suplemento
            vpasexec := 8;

            IF pnriesgo IS NULL
            THEN
               -- bug 0011645 El riesgo no debe estar anulado
               FOR regs3 IN (SELECT r.nriesgo
                               FROM estriesgos r, estseguros s
                              WHERE r.sseguro = s.sseguro
                                AND NVL (r.fanulac, pfecha + 1) > pfecha
                                AND s.sseguro = v_est_sseguro)
               LOOP
                  -- BUG22137:DRA:11/05/2012:Inici
                  v_err :=
                     pk_nueva_produccion.f_validar_garantias_al_tarifar
                                                              (v_est_sseguro,
                                                               regs3.nriesgo,
                                                               v_nmovimi,
                                                               v_sproduc,
                                                               v_cactivi,
                                                               v_texto
                                                              );
                  -- BUG22137:DRA:11/05/2012:Fi
                  numerr :=
                     pac_tarifas.f_tarifar_riesgo_tot
                                    ('EST',
                                     v_est_sseguro,
                                     regs3.nriesgo,
                                     v_nmovimi,
                                     -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                   --              f_parinstalacion_n('MONEDAINST'),
                                     pac_monedas.f_moneda_producto (v_sproduc),
                                     -- JLB - f - BUG 18423 COjo la moneda del producto
                                     pfecha
                                    );

                  IF numerr <> 0
                  THEN
                     v_texto := f_axis_literales (numerr, f_idiomauser);
                     v_err :=
                        f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
                     RAISE error_fin_supl;
                  END IF;
               END LOOP;
            ELSE
               numerr :=
                  pac_tarifas.f_tarifar_riesgo_tot
                                   ('EST',
                                    v_est_sseguro,
                                    pnriesgo,
                                    v_nmovimi,
                                    -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                   --              f_parinstalacion_n('MONEDAINST'),
                                    pac_monedas.f_moneda_producto (v_sproduc),
                                    -- JLB - f - BUG 18423 COjo la moneda del producto
                                    pfecha
                                   );

               IF numerr <> 0
               THEN
                  v_texto := f_axis_literales (numerr, f_idiomauser);
                  v_err :=
                        f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
                  RAISE error_fin_supl;
               END IF;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 9;
      numerr :=
         pk_suplementos.f_validar_cambios (f_user,
                                           v_est_sseguro,
                                           v_nmovimi,
                                           v_sproduc,
                                           'BBDD',
                                           'SUPLEMENTO',
                                           vcidioma
                                          );

      IF numerr <> 0
      THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT (*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0
      THEN                                               -- No hi hagut canvis
         RAISE warn_fin_supl;
      END IF;

      -- Es grava el suplement a las taules reals
      vpasexec := 11;
      numerr :=
          pk_suplementos.f_grabar_suplemento_poliza (v_est_sseguro, v_nmovimi);

      IF numerr <> 0
      THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 12;

      -- Bug 16095 - APD - 05/11/2010 - Si pcemite = 1 queremos que todo continue igual,
      -- es decir, se debe emitir la poliza
      -- Si pcemite <> 1, no se debe emitir la poliza
      IF pcemite = 1
      THEN
         p_emitir_propuesta (vcempres,
                             vnpoliza,
                             vncertif,
                             vcramo,
                             vcmodali,
                             vctipseg,
                             vccolect,
                             v_cactivi,
                             1,
                             vcidioma,
                             indice,
                             indice_e,
                             indice_t,
                             pmensaje,         -- BUG 27642 - FAL - 30/04/2014
                             NULL,
                             NULL,
                             1
                            );

         IF indice_e <> 0 OR indice < 1
         THEN
            v_texto := f_axis_literales (151237, f_idiomauser);
            v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      -- Fin Bug 16095 - APD - 05/11/2010
      v_est_sseguro := NULL;
      COMMIT;

      -- Finalizamos proces
      IF psproces IS NULL
      THEN
         numerr := f_procesfin (v_sproces, 0);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         'e_param_error: '
                                      || f_axis_literales (numerr)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN warn_fin_supl
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_supl_automatic',
                      vpasexec,
                      'Warning: ' || f_axis_literales (numerr, f_idiomauser),
                      numerr
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         'Warning: '
                                      || f_axis_literales (numerr)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_supl_automatic',
                      vpasexec,
                      f_axis_literales (numerr, f_idiomauser),
                      numerr
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         'error_fin_supl: '
                                      || f_axis_literales (numerr)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         -- Bug 10908 - 28/08/2009 - JMF
         --RETURN 1;
         RETURN 9001777;
      -- Bug 10908 - 28/08/2009 - JMF
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_supl_automatic',
                      vpasexec,
                      f_axis_literales (numerr, f_idiomauser),
                      SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (numerr)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
   END f_supl_automatic;

   -- Fin Bug 9153

   /***********************************************************************
      Función que nos indicará si para un determinado contrato se debe evaluar
      un suplemento diferido a una fecha.

      param in psseguro  : Código de seguro
      return             : Number (1--> SI, 0 --> No).
   ***********************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_diferidos (psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER
   IS
      v_sproduc   NUMBER;
      v_count     NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_count
        FROM sup_diferidosseg
       WHERE sseguro = psseguro AND fecsupl = pfecha;

      IF v_count > 0
      THEN
         RETURN 1;                 -- Hay suplementos automaticos que evaluar
      END IF;

      RETURN 0;
   END f_eval_diferidos;

   /***********************************************************************
      Función que nos indicará si para un determinado contrato se debe evaluar
      un suplemento diferido a futuro respecto una fecha.

      param in psseguro  : Código de seguro
      return             : Number (1--> SI, 0 --> No).
   ***********************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_diferidos_futuro (psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER
   IS
      v_sproduc   NUMBER;
      v_count     NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_count
        FROM sup_diferidosseg
       WHERE sseguro = psseguro AND fecsupl >= pfecha;

      IF v_count > 0
      THEN
         RETURN 1;                 -- Hay suplementos automaticos que evaluar
      END IF;

      RETURN 0;
   END f_eval_diferidos_futuro;

   /***********************************************************************
      Función que inicia el proceso de evaluación de suplementos diferidos
      para un deteminado contrato a una fecha.

      param in psseguro  : Código de seguro
      param in pfecha    : Fecha de suplemento (fecha de carte del producto)
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_gen_supl_diferidos (
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      psproces   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec            NUMBER (8)      := 0;
      vparam              VARCHAR2 (500)
         :=    'psseguro = '
            || psseguro
            || '; pfecha = '
            || TO_CHAR (pfecha, 'dd/mm/yyyy')
            || '; psproces = '
            || psproces;
      vobject             VARCHAR2 (200)
                                   := 'pac_sup_diferidos.f_gen_supl_diferidos';
      v_sproduc           NUMBER;
      v_cursor            NUMBER;
      ss                  VARCHAR2 (3000);
      v_funcion           VARCHAR2 (40);
      v_valida            NUMBER;
      v_filas             NUMBER;
      -- Pruebas
      v_out               NUMBER;
      --
      v_final             DATE;
      vvalida_supl        NUMBER          := 1;
      -- Bug 26070 - APD - 11/03/2013
      v_admite_certif     NUMBER          := 0;
      -- Bug 26070 - APD - 11/03/2013
      v_es_administrado   NUMBER          := 0;
      -- Bug 26070 - APD - 11/03/2013
      v_es_certif_0       NUMBER          := 0;
   -- Bug 26070 - APD - 11/03/2013
   BEGIN
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vpasexec);
      -- Lo sacamos de la tabla de diferidos y lo ponemos al historico
      v_final := f_sysdate;

      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      v_admite_certif :=
                  NVL (f_parproductos_v (v_sproduc, 'ADMITE_CERTIFICADOS'), 0);
      v_es_administrado := pac_seguros.f_es_col_admin (psseguro, 'SEG');
      v_es_certif_0 := pac_seguros.f_get_escertifcero (NULL, psseguro);

      FOR regs IN (SELECT *
                     FROM sup_diferidosseg
                    WHERE sseguro = psseguro AND fecsupl = pfecha
                          AND estado = 0)
      LOOP
         vpasexec := 2;
         ss := 'begin :v_valida := ' || regs.fvalfun || '; end;';
         pac_log.p_log_sup_diferidos (psseguro, 0, ss, vobject, vpasexec);

         IF DBMS_SQL.is_open (v_cursor)
         THEN
            DBMS_SQL.close_cursor (v_cursor);
         END IF;

         v_cursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (v_cursor, ss, DBMS_SQL.native);

         IF INSTR (ss, ':SSEGURO') > 0
         THEN
            DBMS_SQL.bind_variable (v_cursor, ':SSEGURO', psseguro);
         END IF;

         IF INSTR (ss, ':FECHA') > 0
         THEN
            DBMS_SQL.bind_variable (v_cursor, ':FECHA', pfecha);
         END IF;

         IF INSTR (ss, ':CMOTMOV') > 0
         THEN
            DBMS_SQL.bind_variable (v_cursor, ':CMOTMOV', regs.cmotmov);
         END IF;

         IF INSTR (ss, ':v_valida') > 0
         THEN
            DBMS_SQL.bind_variable (v_cursor, ':v_valida', v_valida);
         END IF;

         v_filas := DBMS_SQL.EXECUTE (v_cursor);
         DBMS_SQL.variable_value (v_cursor, 'v_valida', v_valida);

         IF DBMS_SQL.is_open (v_cursor)
         THEN
            DBMS_SQL.close_cursor (v_cursor);
         END IF;

         pac_log.p_log_sup_diferidos (psseguro,
                                      0,
                                         'v_valida = '
                                      || v_valida
                                      || '; cmotmot = '
                                      || regs.cmotmov,
                                      vobject,
                                      vpasexec
                                     );
         vpasexec := 3;

         -- Funcion de validación evaluada a cierto --> Ejecutamos suplemento automático
         IF v_valida = 1
         THEN
            vpasexec := 4;
            -- Ejecutamos el suplemento
            v_out :=
               pac_sup_diferidos.f_supl_diferidos (psseguro,
                                                   pfecha,
                                                   regs.cmotmov,
                                                   NULL,
                                                   NULL,
                                                   psproces,
                                                   vvalida_supl
                                                  );

            IF v_out <> 0
            THEN
               pac_log.p_log_sup_diferidos
                           (psseguro,
                            1,
                               'pac_sup_diferidos.f_supl_diferidos v_out = '
                            || v_out,
                            vobject,
                            vpasexec
                           );
               RETURN v_out;
            ELSE
               vpasexec := 5;

               INSERT INTO his_sup_diferidosseg
                           (cmotmov, sseguro, ffinal, fecsupl, fvalfun,
                            estado, cusuari, falta, tvalord, fanula, nmovimi)
                  SELECT cmotmov, sseguro, v_final, fecsupl, fvalfun, 1,
                         cusuari, falta, tvalord, fanula, nmovimi
                    FROM sup_diferidosseg
                   WHERE cmotmov = regs.cmotmov AND sseguro = psseguro;

               vpasexec := 6;

               INSERT INTO his_sup_acciones_dif
                  SELECT cmotmov, sseguro, norden, v_final, 1, dinaccion,
                         ttable, tcampo, twhere, taccion, naccion, vaccion,
                         ttarifa
                    FROM sup_acciones_dif
                   WHERE cmotmov = regs.cmotmov AND sseguro = psseguro;

               vpasexec := 7;

               DELETE      sup_acciones_dif
                     WHERE cmotmov = regs.cmotmov AND sseguro = psseguro;

               vpasexec := 8;

               DELETE      sup_diferidosseg
                     WHERE cmotmov = regs.cmotmov AND sseguro = psseguro;
            END IF;
         ELSE
            vpasexec := 9;

            -- Lo sacamos de la tabla de diferidos y lo ponemos al historico
            -- Si a una fecha de ejecución de suplemento diferido éste no se ejecuta
            -- ya no se podrá ejecutar posterirmente. Perderá vigencia y se inserta
            -- en las tablas de historico.
            --v_final := f_sysdate;
            INSERT INTO his_sup_diferidosseg
                        (cmotmov, sseguro, ffinal, fecsupl, fvalfun, estado,
                         cusuari, falta, tvalord, fanula, nmovimi)
               SELECT cmotmov, sseguro, v_final, fecsupl, fvalfun, 1,
                      cusuari, falta, tvalord, fanula, nmovimi
                 FROM sup_diferidosseg
                WHERE cmotmov = regs.cmotmov AND sseguro = psseguro;

            vpasexec := 10;

            INSERT INTO his_sup_acciones_dif
               SELECT cmotmov, sseguro, norden, v_final, 1, dinaccion,
                      ttable, tcampo, twhere, taccion, naccion, vaccion,
                      ttarifa
                 FROM sup_acciones_dif
                WHERE cmotmov = regs.cmotmov AND sseguro = psseguro;

            vpasexec := 11;

            DELETE      sup_acciones_dif
                  WHERE cmotmov = regs.cmotmov AND sseguro = psseguro;

            vpasexec := 12;

            DELETE      sup_diferidosseg
                  WHERE cmotmov = regs.cmotmov AND sseguro = psseguro;
         END IF;

         v_valida := NULL;

         -- Bug 26070 - APD - 11/03/2013 - si el producto admite certificados,
         -- es un producto administrado y no es el certificado 0, entonces
         -- vvalida_supl = 0 para que no realice otra vez la validacion
         -- del suplemento
         IF v_admite_certif = 1 AND v_es_administrado = 1
            AND v_es_certif_0 = 0
         THEN
            vvalida_supl := 0;
         END IF;
      -- fin Bug 26070 - APD - 11/03/2013
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_gen_supl_diferidos',
                      NULL,
                      f_axis_literales (108953, f_idiomauser),
                      SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (108953)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 108953;
   END f_gen_supl_diferidos;

   /***********************************************************************
      Función específica para el lanzamiento de un suplemento automático a
      nivel de negocio.

      param in psseguro  : Código de seguro
      param in psproduc  : Código de producto.
      param in pnorden   : Código de orden.
      param in pfecha    : Fecha de suplemento.
      param in pcmotmov  : Código de motivo de movimiento.
      param in pnriesgo  : Importe de operación.
      param in pcgarant  : Código de garantía.
      param in psproces  : Identificador de proceso para dejar trazas informativas.
      return             : Number (0--> OK, 1 --> Error).
   ***********************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_supl_diferidos (
      psseguro       IN   NUMBER,
      pfecha         IN   DATE,
      pcmotmov       IN   NUMBER,
      pnriesgo       IN   NUMBER,
      pcgarant       IN   NUMBER,
      psproces       IN   NUMBER,
      pvalida_supl   IN   NUMBER DEFAULT 1
   )                                           -- Bug 26070 - APD - 11/03/2013
      RETURN NUMBER
   IS
      numerr              NUMBER                    := 0;
      vpasexec            NUMBER                    := 1;
      vparam              VARCHAR2 (400)
         :=    'psseguro= '
            || psseguro
            || ' fecha= '
            || TO_CHAR (pfecha, 'dd/mm/yyyy')
            || ' pcmotmov= '
            || pcmotmov
            || ' pnriesgo= '
            || pnriesgo
            || ' pcgarant= '
            || pcgarant
            || ' psproces= '
            || psproces
            || ' pvalida_supl= '
            || pvalida_supl;
      vobject             VARCHAR2 (200)
                                       := 'PAC_SUP_DIFERIDOS.f_supl_diferidos';
      v_sproduc           NUMBER;
      v_cactivi           NUMBER;
      salida              EXCEPTION;
      error_fin_supl      EXCEPTION;
      warn_fin_supl       EXCEPTION;
      v_cforpag           seguros.cforpag%TYPE;
      v_sperson           asegurados.sperson%TYPE;
      vcont               NUMBER;
      vcempres            seguros.cempres%TYPE;
      vnpoliza            seguros.npoliza%TYPE;
      vncertif            seguros.ncertif%TYPE;
      vcramo              seguros.cramo%TYPE;
      vcmodali            seguros.cmodali%TYPE;
      vctipseg            seguros.ctipseg%TYPE;
      vccolect            seguros.ccolect%TYPE;
      vcidioma            seguros.cidioma%TYPE;
      ss                  VARCHAR2 (32000);
      vwhere              VARCHAR2 (500);
      v_tcampo            VARCHAR2 (500);
      v_riesgos           VARCHAR (50);
      indice              NUMBER;
      indice_e            NUMBER;
      indice_t            NUMBER;
      v_cursor            NUMBER;
      v_funcion           VARCHAR2 (40);
      v_valida            NUMBER;
      v_filas             NUMBER;
      retorno             NUMBER;
      -- 22/04/2009
      v_sproces           NUMBER;
      v_nnumlin           NUMBER                    := NULL;
      v_texto             VARCHAR2 (200);
      v_err               NUMBER;
      vcapital            NUMBER;
      v_admite_certif     NUMBER;
      v_es_administrado   NUMBER;
      v_es_certif_0       NUMBER;
      pmensaje            VARCHAR2 (500);      -- BUG 27642 - FAL - 30/04/2014
   BEGIN
      vpasexec := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vpasexec);

      IF psseguro IS NULL OR pfecha IS NULL OR pcmotmov IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL
      THEN
         numerr :=
            f_procesini (getuser,
                         1,
                         'SUPL_DIF:' || TO_CHAR (f_sysdate, 'yyyymmdd'),
                         f_axis_literales (805824, f_idiomauser),
                         v_sproces
                        );
         pac_log.p_log_sup_diferidos (psseguro,
                                      0,
                                      'sproces = ' || v_sproces,
                                      vobject,
                                      vpasexec
                                     );
      ELSE
         v_sproces := psproces;
      END IF;

--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg,
             ccolect, sproduc, cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg,
             vccolect, v_sproduc, v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 3;

      IF pnriesgo IS NOT NULL
      THEN
         BEGIN
            SELECT sperson
              INTO v_sperson
              FROM asegurados
             WHERE sseguro = psseguro AND norden = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN 0;       -- Si no hay riesgo no hay nada que modificar.
         END;
      END IF;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------

      -- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      IF v_est_sseguro IS NULL
      THEN     --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;

         -- Bug 26070 - APD - 11/03/2013
         IF pvalida_supl = 1
         THEN
            numerr :=
               pk_suplementos.f_permite_suplementos (psseguro,
                                                     pfecha,
                                                     pcmotmov
                                                    );

            IF numerr <> 0
            THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         -- fin Bug 26070 - APD - 11/03/2013
         vpasexec := 6;

         IF pcmotmov IS NOT NULL
         THEN
            numerr :=
               pk_suplementos.f_permite_este_suplemento (psseguro,
                                                         pfecha,
                                                         pcmotmov
                                                        );

            IF numerr <> 0
            THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         -- Bug 26070 - APD - 11/03/2013 - se añade el parametro pvalida_supl
         numerr :=
            pk_suplementos.f_inicializar_suplemento (psseguro,
                                                     'SUPLEMENTO',
                                                     pfecha,
                                                     'BBDD',
                                                     '*',
                                                     pcmotmov,
                                                     v_est_sseguro,
                                                     v_nmovimi,
                                                     'NOPRAGMA',
                                                     pvalida_supl
                                                    );

         -- BUG15823:DRA:04/11/2010

         -- fin Bug 26070 - APD - 11/03/2013
         IF numerr <> 0
         THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                   'v_est_sseguro = ' || v_est_sseguro,
                                   vobject,
                                   vpasexec
                                  );

      -- ACCIÓN DINÁMICO ----------------------------------------------------
      FOR regs2 IN (SELECT   *
                        FROM sup_acciones_dif
                       WHERE cmotmov = pcmotmov AND sseguro = psseguro
                    ORDER BY norden)
      LOOP
         ss := regs2.taccion;
         ss := REPLACE (ss, ':SSEGURO', v_est_sseguro);
         ss :=
            REPLACE (ss,
                     ':FECHA',
                        'TO_DATE('''
                     || TO_CHAR (pfecha, 'YYYYMMDD')
                     || ''',''YYYYMMDD'')'
                    );
         ss := REPLACE (ss, ':NMOVIMI', v_nmovimi);
         pac_log.p_log_sup_diferidos (psseguro,
                                      0,
                                      SUBSTR ('ss = ' || ss, 1, 3500),
                                      vobject,
                                      vpasexec
                                     );

         -- Execute Inmediate
         EXECUTE IMMEDIATE ss;

         pac_log.p_log_sup_diferidos (psseguro,
                                      0,
                                      'regs2.ttarifa = ' || regs2.ttarifa,
                                      vobject,
                                      vpasexec
                                     );

         IF regs2.ttarifa = 1
         THEN                               -- Se debe tarifar tras suplemento
            vpasexec := 8;

            IF pcmotmov = 281
            THEN
               FOR x IN (SELECT   gp.ctipcap, s.sproduc, s.cactivi, g.*
                             FROM estgaranseg g, estseguros s, garanpro gp
                            WHERE s.sseguro = g.sseguro
                              AND gp.cmodali = s.cmodali
                              AND gp.ccolect = s.ccolect
                              AND gp.ctipseg = s.ctipseg
                              AND gp.cgarant = g.cgarant
                              AND gp.cactivi = s.cactivi
                              AND gp.cramo = s.cramo
                              AND g.sseguro = v_est_sseguro
                              AND g.cobliga = 1
                         ORDER BY g.norden)
               LOOP
                  IF x.ctipcap NOT IN (1, 2)
                  THEN
                     vcapital :=
                        f_sup_dif_valida_dependencias (x.sseguro,
                                                       x.nriesgo,
                                                       x.nmovimi,
                                                       x.cgarant,
                                                       x.sproduc,
                                                       x.cactivi,
                                                       x.nmovima
                                                      );
                     pac_log.p_log_sup_diferidos (psseguro,
                                                  0,
                                                     'sseguro='
                                                  || x.sseguro
                                                  || ',nriesgo='
                                                  || x.nriesgo
                                                  || ',nmovimi='
                                                  || x.nmovimi
                                                  || ',cgarant='
                                                  || x.cgarant
                                                  || ',capital='
                                                  || vcapital,
                                                  vobject,
                                                  vpasexec
                                                 );
                  END IF;

                  UPDATE estgaranseg
                     SET icapital = vcapital
                   WHERE sseguro = x.sseguro
                     AND nriesgo = x.nriesgo
                     AND cgarant = x.cgarant
                     AND nmovimi = x.nmovimi
                     AND finiefe = x.finiefe;
               END LOOP;
            END IF;

            IF pnriesgo IS NULL
            THEN
               -- bug 0011645 El riesgo no debe estar anulado
               FOR regs3 IN (SELECT r.nriesgo
                               FROM estriesgos r, estseguros s
                              WHERE r.sseguro = s.sseguro
                                AND NVL (r.fanulac, pfecha + 1) > pfecha
                                AND s.sseguro = v_est_sseguro)
               LOOP
                  numerr :=
                     pac_tarifas.f_tarifar_riesgo_tot
                                   ('EST',
                                    v_est_sseguro,
                                    regs3.nriesgo,
                                    v_nmovimi,
-- JLB - I - BUG 18423 COjo la moneda del producto
                                                 --f_parinstalacion_n('MONEDAINST'),
                                    pac_monedas.f_moneda_producto (v_sproduc),
                                    -- JLB - f - BUG 18423 COjo la moneda del producto
                                    pfecha
                                   );

                  IF numerr <> 0
                  THEN
                     v_texto := f_axis_literales (numerr, f_idiomauser);
                     v_err :=
                        f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
                     RAISE error_fin_supl;
                  END IF;
               END LOOP;
            ELSE
               numerr :=
                  pac_tarifas.f_tarifar_riesgo_tot
                                   ('EST',
                                    v_est_sseguro,
                                    pnriesgo,
                                    v_nmovimi,
-- JLB - I - BUG 18423 COjo la moneda del producto
                                                 --f_parinstalacion_n('MONEDAINST'),
                                    pac_monedas.f_moneda_producto (v_sproduc),
                                    -- JLB - f - BUG 18423 COjo la moneda del producto
                                    pfecha
                                   );

               IF numerr <> 0
               THEN
                  v_texto := f_axis_literales (numerr, f_idiomauser);
                  v_err :=
                        f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
                  RAISE error_fin_supl;
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- Suplementos identicos pero se deben excluir. Es temporal, pero de momento lo dejamos asi!
      IF pcmotmov = 900
      THEN
         UPDATE pds_estsegurosupl
            SET cestado = '0'
          WHERE sseguro = v_est_sseguro AND cmotmov = 905;

         DELETE      estdetmovseguro
               WHERE sseguro = v_est_sseguro AND cmotmov = 905;
      END IF;

      -- Suplementos identicos pero se deben excluir. Es temporal, pero de momento lo dejamos asi!
      IF pcmotmov = 905
      THEN
         UPDATE pds_estsegurosupl
            SET cestado = '0'
          WHERE sseguro = v_est_sseguro AND cmotmov = 900;

         DELETE      estdetmovseguro
               WHERE sseguro = v_est_sseguro AND cmotmov = 900;
      END IF;

      vpasexec := 9;
      numerr :=
         pk_suplementos.f_validar_cambios (f_user,
                                           v_est_sseguro,
                                           v_nmovimi,
                                           v_sproduc,
                                           'BBDD',
                                           'SUPLEMENTO',
                                           vcidioma
                                          );

      IF numerr <> 0
      THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      -- Suplementos identicos pero se deben excluir. Es temporal, pero de momento lo dejamos asi!
      IF pcmotmov = 900
      THEN
         UPDATE pds_estsegurosupl
            SET cestado = '0'
          WHERE sseguro = v_est_sseguro AND cmotmov = 905;

         DELETE      estdetmovseguro
               WHERE sseguro = v_est_sseguro AND cmotmov = 905;
      END IF;

      -- Suplementos identicos pero se deben excluir. Es temporal, pero de momento lo dejamos asi!
      IF pcmotmov = 905
      THEN
         UPDATE pds_estsegurosupl
            SET cestado = '0'
          WHERE sseguro = v_est_sseguro AND cmotmov = 900;

         DELETE      estdetmovseguro
               WHERE sseguro = v_est_sseguro AND cmotmov = 900;
      END IF;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT (*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE error_fin_supl;
      END;

      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                   'vcont = ' || vcont,
                                   vobject,
                                   vpasexec
                                  );

      IF vcont = 0
      THEN                                               -- No hi hagut canvis
         RAISE warn_fin_supl;
      END IF;

      -- Es grava el suplement a las taules reals
      vpasexec := 11;
      numerr :=
          pk_suplementos.f_grabar_suplemento_poliza (v_est_sseguro, v_nmovimi);

      IF numerr <> 0
      THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento siempre que no sea colectivo administrado y se trate de un certificado
-------------------------------------------------------------------------------------------
      v_es_administrado := 0;
      v_es_certif_0 := 1;
      v_admite_certif :=
                  NVL (f_parproductos_v (v_sproduc, 'ADMITE_CERTIFICADOS'), 0);

      IF v_admite_certif = 1
      THEN
         v_es_administrado := pac_seguros.f_es_col_admin (psseguro, 'SEG');
         v_es_certif_0 := pac_seguros.f_get_escertifcero (NULL, psseguro);
      END IF;

      vpasexec := 12;

      IF    v_admite_certif = 0
         OR (v_admite_certif = 1 AND v_es_administrado = 0)
      THEN
         p_emitir_propuesta (vcempres,
                             vnpoliza,
                             vncertif,
                             vcramo,
                             vcmodali,
                             vctipseg,
                             vccolect,
                             v_cactivi,
                             1,
                             vcidioma,
                             indice,
                             indice_e,
                             indice_t,
                             pmensaje,         -- BUG 27642 - FAL - 30/04/2014
                             NULL,
                             NULL,
                             1
                            );
         pac_log.p_log_sup_diferidos (psseguro,
                                      0,
                                         'p_emitir_propuesta indice = '
                                      || indice
                                      || '; indice_e = '
                                      || indice_e,
                                      vobject,
                                      vpasexec
                                     );

         IF indice_e <> 0 OR indice < 1
         THEN
            v_texto := f_axis_literales (151237, f_idiomauser);
            v_err := f_proceslin (v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      v_est_sseguro := NULL;
      COMMIT;

      -- Finalizamos proces
      IF psproces IS NULL
      THEN
         numerr := f_procesfin (v_sproces, 0);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         'e_param_error: '
                                      || f_axis_literales (numerr)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN warn_fin_supl
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_supl_diferidos',
                      vpasexec,
                      'Warning: ' || f_axis_literales (numerr, f_idiomauser),
                      numerr
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         'Warning: '
                                      || f_axis_literales (numerr)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_supl_diferidos',
                      vpasexec,
                      f_axis_literales (numerr, f_idiomauser),
                      numerr
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         'error_fin_supl: '
                                      || f_axis_literales (numerr)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_supl_diferidos',
                      vpasexec,
                      f_axis_literales (numerr, f_idiomauser),
                      SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (numerr)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
   END f_supl_diferidos;

   -- Fin Bug 9905

   -- Bug 9153 - 20/05/2009 - RSC - Suplementos automáticos
   FUNCTION f_eval_genera_map (
      pempres      IN       NUMBER,
      psproces     IN       NUMBER,
      pfcartera    IN       DATE,
      pgeneramap   IN OUT   NUMBER
   )
      RETURN NUMBER
   IS
      v_diferir   NUMBER;
      v_counta    NUMBER;
   BEGIN
      SELECT pac_parametros.f_parempresa_n (pempres, 'SPL_DIFERIR')
        INTO v_diferir
        FROM DUAL;

      SELECT COUNT (*)
        INTO v_counta
        FROM seguros s, carteraaux c
       WHERE
--PAC_SUP_DIFERIDOS.f_eval_automaticos_cartera(s.sseguro,s.fcarpro,pfcartera, 2) IS NOT NULL
             pac_sup_diferidos.f_eval_automaticos (s.sseguro) = 1
         AND s.fcarpro <= pfcartera
         AND s.cramo = c.cramo
         AND s.cmodali = c.cmodali
         AND s.ctipseg = c.ctipseg
         AND s.ccolect = c.ccolect
         AND c.sproces = psproces;

      -- Bug 10115 - 09/07/2009 - RSC - Listado de previo de cartera con los
      -- suplementos diferidos pendientes
      /* IF v_counta > 0
         OR v_diferir = 1 THEN
         pgeneramap := 1;
      ELSE
         pgeneramap := 0;
      END IF; */

      -- Generamos siempre el listado
      pgeneramap := 1;
      -- Fin bug 10115
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pgeneramap := 0;
         RETURN 1;
   END f_eval_genera_map;

-- Fin Bug 9153

   -- Ini Bug 24278 - MDS - 06/11/2012
   /*************************************************************************
      Realiza el diferimiento del suplemento 673 (modificación domicilio tomador)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifdomictom (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
--      ppoliza IN ob_iax_detpoliza,
--      pfdifer IN VARCHAR2,
--                                                           mensajes OUT t_iax_mensajes)
   RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                          := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_modifdomictom';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 673;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
   BEGIN
      /* De ppoliza sólo se necesita:
            .sproduc
            .npoliza
            .ssegpol
            .nmovimi
      */
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov
            AND (sproduc = vsproduc                          --ppoliza.sproduc
                 OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 9001505;
      END;

      vpasexec := 3;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;  --ppoliza.ssegpol;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND estado = 0;

      vpasexec := 5;

      -- obtener el sseguro (de REAL) del certificado 0
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;            --ppoliza.npoliza;

      vpasexec := 51;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      vpasexec := 52;

      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 5;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl,
                      fvalfun, cusuari, falta, tvalord, fanula,
                      nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, 0, pfecsupl,
                      vfvalfun, f_user, f_sysdate, NULL, NULL,
                      vnmovimi_0 /*ppoliza.nmovimi*/, vnejecu
                     );
      END IF;

      vpasexec := 6;

      -- para cada uno de los tomadores del seguro del certificado 0,
      -- obtener el domicilio y modificarlo en todos los seguros (de las EST) para la misma persona
      FOR reg IN (SELECT sperson, cdomici
                    FROM tomadores
                   WHERE sseguro = vsseguro_0)
      LOOP
         vpasexec := 7;
         -- crear la función de modificación del seguro en la tabla EST
         vnorden := vnorden + 1;
         vdinaccion := 'U';
         vttable := 'ESTTOMADORES';
         vtcampo := 'CDOMICI';
         vtwhere := 'SSEGURO = :SSEGURO AND SPERSON = ' || reg.sperson;
         vtaccion :=
               'UPDATE ESTTOMADORES SET CDOMICI = '
            || NVL (TO_CHAR (reg.cdomici), 'null')
            || ' WHERE SSEGURO = :SSEGURO AND SPERSON = pac_persona.f_spereal_sperson('
            || reg.sperson
            || ',:SSEGURO)';
         vpasexec := 8;

         --
         -- ejecución del suplemento
         --
         BEGIN
            INSERT INTO sup_acciones_dif
                        (cmotmov, sseguro, norden, estado,
                         nejecu, dinaccion, ttable, tcampo, twhere,
                         taccion, naccion, vaccion, ttarifa
                        )
                 VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                         vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                         vtaccion, reg.cdomici, NULL, 0
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               -- Existe una programación pendiente para este tipo de suplemento diferido
               RETURN 9001506;
            WHEN OTHERS
            THEN
               RAISE e_object_error;
         END;
      END LOOP;

      -- actualizar para tarifar=NO tras la última acción
      UPDATE sup_acciones_dif
         SET ttarifa = 0
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND norden = vnorden;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
--                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_diferir_spl_modifdomictom;

   /*************************************************************************
      Realiza el diferimiento del suplemento 729 (cambio de revalorización)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_cambioreval (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
--      ppoliza IN ob_iax_detpoliza,
--      pfdifer IN VARCHAR2,
--      mensajes OUT t_iax_mensajes)
   RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                            := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_cambioreval';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 729;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vcrevali     seguros.crevali%TYPE;
      virevali     seguros.irevali%TYPE;
      vprevali     seguros.prevali%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
   BEGIN
      /* De ppoliza sólo se necesita:
            .sproduc
            .npoliza
            .ssegpol
            .nmovimi
      */
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 9001505;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;  --ppoliza.ssegpol;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro, crevali, irevali, prevali
        INTO vsseguro_0, vcrevali, virevali, vprevali
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;            --ppoliza.npoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl,
                      fvalfun, cusuari, falta, tvalord, fanula,
                      nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, 0, pfecsupl,
                      vfvalfun, f_user, f_sysdate, NULL, NULL,
                      vnmovimi_0 /*ppoliza.nmovimi*/, vnejecu
                     );
      END IF;

      vpasexec := 5;
      --
      -- modificar CREVALI
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := 'CREVALI';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET CREVALI = '
         || NVL (TO_CHAR (vcrevali), 'null')
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 7;

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado,
                      nejecu, dinaccion, ttable, tcampo, twhere,
                      taccion, naccion, vaccion, ttarifa
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                      vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                      vtaccion, vcrevali, NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      vpasexec := 8;
      --
      -- modificar IREVALI
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := 'IREVALI';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET IREVALI = '
         || NVL (TRANSLATE (TO_CHAR (virevali), ',', '.'), 'null')
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 9;

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado,
                      nejecu, dinaccion, ttable, tcampo, twhere,
                      taccion, naccion, vaccion, ttarifa
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                      vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                      vtaccion, virevali, NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      vpasexec := 10;
      --
      -- modificar PREVALI
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := 'PREVALI';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET PREVALI = '
         || NVL (TRANSLATE (TO_CHAR (vprevali), ',', '.'), 'null')
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 11;

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado,
                      nejecu, dinaccion, ttable, tcampo, twhere,
                      taccion, naccion, vaccion, ttarifa
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                      vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                      vtaccion, vprevali, NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      -- para cada una de las garantías del seguro del certificado 0,
      -- obtener la revalorización y modificarla en todos los seguros (de las EST) para el mismo riesgo-garantía activo
      FOR reg IN (SELECT nriesgo, cgarant, nmovimi, crevali, irevali, prevali
                    FROM garanseg
                   WHERE sseguro = vsseguro_0 AND ffinefe IS NULL)
      LOOP
         vpasexec := 20;
         -- modificar CREVALI
         -- crear la función de modificación del seguro en la tabla EST
         vnorden := vnorden + 1;
         vdinaccion := 'U';
         vttable := 'ESTGARANSEG';
         vtcampo := 'CREVALI';
         vtwhere :=
               'SSEGURO = :SSEGURO AND NRIESGO = '
            || reg.nriesgo
            || ' AND CGARANT = '
            || reg.cgarant
            || ' AND NMOVIMI = '
            || reg.nmovimi;
         vtaccion :=
               'UPDATE ESTGARANSEG SET CREVALI = '
            || NVL (TO_CHAR (reg.crevali), 'null')
            || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
            || reg.nriesgo
            || ' AND CGARANT = '
            || reg.cgarant
            || ' AND NMOVIMI = '
            || reg.nmovimi;
         vpasexec := 21;

         --
         -- ejecución del suplemento
         --
         BEGIN
            INSERT INTO sup_acciones_dif
                        (cmotmov, sseguro, norden, estado,
                         nejecu, dinaccion, ttable, tcampo, twhere,
                         taccion, naccion, vaccion, ttarifa
                        )
                 VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                         vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                         vtaccion, reg.crevali, NULL, 0
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               -- Existe una programación pendiente para este tipo de suplemento diferido
               RETURN 9001506;
            WHEN OTHERS
            THEN
               RAISE e_object_error;
         END;

         vpasexec := 22;
         -- modificar IREVALI
         -- crear la función de modificación del seguro en la tabla EST
         vnorden := vnorden + 1;
         vdinaccion := 'U';
         vttable := 'ESTGARANSEG';
         vtcampo := 'IREVALI';
         vtwhere :=
               'SSEGURO = :SSEGURO AND NRIESGO = '
            || reg.nriesgo
            || ' AND CGARANT = '
            || reg.cgarant
            || ' AND NMOVIMI = '
            || reg.nmovimi;
         vtaccion :=
               'UPDATE ESTGARANSEG SET IREVALI = '
            || NVL (TRANSLATE (TO_CHAR (reg.irevali), ',', '.'), 'null')
            || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
            || reg.nriesgo
            || ' AND CGARANT = '
            || reg.cgarant
            || ' AND NMOVIMI = '
            || reg.nmovimi;
         vpasexec := 23;

         --
         -- ejecución del suplemento
         --
         BEGIN
            INSERT INTO sup_acciones_dif
                        (cmotmov, sseguro, norden, estado,
                         nejecu, dinaccion, ttable, tcampo, twhere,
                         taccion, naccion, vaccion, ttarifa
                        )
                 VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                         vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                         vtaccion, reg.irevali, NULL, 0
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               -- Existe una programación pendiente para este tipo de suplemento diferido
               RETURN 9001506;
            WHEN OTHERS
            THEN
               RAISE e_object_error;
         END;

         vpasexec := 24;
         -- modificar PREVALI
         -- crear la función de modificación del seguro en la tabla EST
         vnorden := vnorden + 1;
         vdinaccion := 'U';
         vttable := 'ESTGARANSEG';
         vtcampo := 'PREVALI';
         vtwhere :=
               'SSEGURO = :SSEGURO AND NRIESGO = '
            || reg.nriesgo
            || ' AND CGARANT = '
            || reg.cgarant
            || ' AND NMOVIMI = '
            || reg.nmovimi;
         vtaccion :=
               'UPDATE ESTGARANSEG SET PREVALI = '
            || NVL (TRANSLATE (TO_CHAR (reg.prevali), ',', '.'), 'null')
            || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
            || reg.nriesgo
            || ' AND CGARANT = '
            || reg.cgarant
            || ' AND NMOVIMI = '
            || reg.nmovimi;
         vpasexec := 25;

         --
         -- ejecución del suplemento
         --
         BEGIN
            INSERT INTO sup_acciones_dif
                        (cmotmov, sseguro, norden, estado,
                         nejecu, dinaccion, ttable, tcampo, twhere,
                         taccion, naccion, vaccion, ttarifa
                        )
                 VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                         vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                         vtaccion, reg.prevali, NULL, 0
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               -- Existe una programación pendiente para este tipo de suplemento diferido
               RETURN 9001506;
            WHEN OTHERS
            THEN
               RAISE e_object_error;
         END;
      END LOOP;

      -- actualizar para tarifar=SI tras la última acción
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND norden = vnorden;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
--                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_diferir_spl_cambioreval;

   /*************************************************************************
      Realiza el diferimiento del suplemento 825 (modificación del co-corretaje)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifcocorretaje (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
--      ppoliza IN ob_iax_detpoliza,
--      pfdifer IN VARCHAR2,
--      mensajes OUT t_iax_mensajes)
   RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                       := 'PAC_MD_SUPLEMENTOS.f_diferir_spl_modifcocorretaje';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 825;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      vexiste      NUMBER;
   BEGIN
      /* De ppoliza sólo se necesita:
            .sproduc
            .npoliza
            .ssegpol
            .nmovimi
      */
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 9001505;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;  --ppoliza.ssegpol;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- obtener el sseguro (de REAL) del certificado 0
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;            --ppoliza.npoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND estado = 0;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl,
                      fvalfun, cusuari, falta, tvalord, fanula,
                      nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, 0, pfecsupl,
                      vfvalfun, f_user, f_sysdate, NULL, NULL,
                      vnmovimi_0 /*ppoliza.nmovimi*/, vnejecu
                     );
      END IF;

      vpasexec := 5;
      -- Borrar lo que hay en las tablas EST.
      vnorden := vnorden + 1;
      vdinaccion := 'D';
      vttable := 'ESTAGE_CORRETAJE';
      vtcampo := 'PPARTICI';
      vtwhere := 'SSEGURO = :SSEGURO ' || ' AND NMOVIMI = :NMOVIMI';
      vtaccion :=
            'DELETE ESTAGE_CORRETAJE WHERE SSEGURO = :SSEGURO '
         || ' AND NMOVIMI = :NMOVIMI';

      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado,
                      nejecu, dinaccion, ttable, tcampo, twhere,
                      taccion, naccion, vaccion, ttarifa
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                      vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                      vtaccion, NULL, NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            RETURN 9001506;
         WHEN OTHERS
         THEN
            RAISE e_object_error;
      END;

      -- para cada uno de los co-corretajes del seguro del certificado 0,
      -- obtener el porcentaje de participación y modificarlo en todos los seguros (de las EST) para el mismo agente
      FOR reg IN (SELECT sseguro, cagente, nmovimi, ppartici, nordage,
                         pcomisi, islider
                    FROM age_corretaje
                   WHERE sseguro = vsseguro_0 AND nmovimi = vnmovimi_0)
      LOOP
         vpasexec := 7;
         --Función de
         -- crear la función de modificación del seguro en la tabla EST
--         vnorden := vnorden + 1;
         vdinaccion := 'I';
         vttable := 'ESTAGE_CORRETAJE';
         vtcampo := 'PPARTICI';
         vtwhere :=
               'SSEGURO = :SSEGURO AND CAGENTE = '
            || reg.cagente
            || ' AND NMOVIMI = :NMOVIMI ';
         vtaccion :=
               'INSERT INTO ESTAGE_CORRETAJE (SSEGURO, CAGENTE, NMOVIMI, NORDAGE, PCOMISI, PPARTICI, ISLIDER)
                         SELECT :SSEGURO, '
            || reg.cagente
            || ', :NMOVIMI, '
            || reg.nordage
            || ','
            || NVL (TRANSLATE (TO_CHAR (reg.pcomisi), ',', '.'), 'null')
            || ','
            || reg.ppartici
            || ','
            || reg.islider
            || ' FROM AGE_CORRETAJE WHERE SSEGURO = '
            || reg.sseguro
            || ' AND cagente = '
            || reg.cagente
            || ' AND nmovimi = '
            || reg.nmovimi;
         vpasexec := 8;

         SELECT DECODE (COUNT (*), 0, 0, 1)
           INTO vexiste
           FROM sup_acciones_dif
          WHERE cmotmov = vcmotmov
            AND sseguro = psseguro
            AND estado = 0
            AND nejecu = vnejecu
            AND DBMS_LOB.compare (taccion, vtaccion) = 0;

         --
         -- ejecución del suplemento
         --
         IF vexiste = 0
         THEN
            BEGIN
               vnorden := vnorden + 1;

               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden,
                            estado, nejecu, dinaccion, ttable, tcampo,
                            twhere, taccion, naccion, vaccion, ttarifa
                           )
                    VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden,
                            0, vnejecu, vdinaccion, vttable, vtcampo,
                            vtwhere, vtaccion, NULL, NULL, 0
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  RETURN 9001506;
               WHEN OTHERS
               THEN
                  RAISE e_object_error;
            END;
         END IF;
      END LOOP;

      -- actualizar para tarifar=NO tras la última acción
      UPDATE sup_acciones_dif
         SET ttarifa = 0
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND norden = vnorden;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN -1;
      WHEN e_object_error
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN -1;
      WHEN OTHERS
      THEN
         ROLLBACK;
--         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
--                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_diferir_spl_modifcocorretaje;

   FUNCTION f_tiene_preg_4089 (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      vrespue   NUMBER;
   BEGIN
      SELECT crespue
        INTO vrespue
        FROM pregunpolseg
       WHERE sseguro = psseguro
         AND cpregun = 4089
         AND nmovimi = (SELECT MAX (nmovimi)
                          FROM pregunpolseg
                         WHERE sseguro = psseguro AND cpregun = 4089);

      RETURN vrespue;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_tiene_preg_4089;

   /*************************************************************************
      Realiza el diferimiento del suplemento 281 (modificación garantías)

      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifgarantias (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec        NUMBER (8)                         := 0;
      vparam          VARCHAR2 (500)
         :=    'psseguro = '
            || psseguro
            || '; pfecsupl = '
            || TO_CHAR (pfecsupl, 'dd/mm/yyyy')
            || '; pnmovimi = '
            || pnmovimi;
      vobject         VARCHAR2 (200)
                           := 'PAC_SUP_DIFERIDOS.f_diferir_spl_modifgarantias';
      vcmotmov        pds_supl_dif_config.cmotmov%TYPE   := 281;
      vfvalfun        pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl        DATE;
      vsseguro_0      seguros.sseguro%TYPE;
      vnmovimi_0      movseguro.nmovimi%TYPE;
      vnorden         sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion      sup_acciones_dif.dinaccion%TYPE;
      vttable         sup_acciones_dif.ttable%TYPE;
      vtcampo         sup_acciones_dif.tcampo%TYPE;
      vtwhere         sup_acciones_dif.twhere%TYPE;
      vtaccion        sup_acciones_dif.taccion%TYPE;
      vnejecu         sup_acciones_dif.nejecu%TYPE;
      vcount          NUMBER;
      vcountgarant    NUMBER;
      vnpoliza        seguros.npoliza%TYPE;
      vsproduc        seguros.sproduc%TYPE;
      vcactivi        seguros.cactivi%TYPE;
      vcrespue        VARCHAR2 (2000);
      vtrespue        VARCHAR2 (2000);
      vresp           NUMBER;
      numerr          NUMBER;
      vplan           NUMBER;
      num_err         NUMBER;
      vcrespue2       pregungaranseg.crespue%TYPE;
      vtrespue2       pregungaranseg.trespue%TYPE;
      vexiste         NUMBER;
      salir           EXCEPTION;
      vnmovimi_ant    movseguro.nmovimi%TYPE;
      vcrespue0_ant   pregungaranseg.crespue%TYPE;
      vtrespue0_ant   pregungaranseg.trespue%TYPE;
   BEGIN
      vpasexec := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vpasexec);

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         num_err := 101901;
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc, cactivi
        INTO vnpoliza, vsproduc, vcactivi
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- obtener el sseguro (de REAL) del certificado 0
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;

      SELECT MAX (nmovimi)
        INTO vnmovimi_ant     -- movimiento anterior al que estamos propagando
        FROM garanseg
       WHERE sseguro = vsseguro_0 AND ffinefe IS NOT NULL;

      vpasexec := 5;

      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 51;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      -- BUG 32488/0188508 - FAL - 30/09/2014 -- Si encuentra algun diferido pdte. registralo en tablas de diferidos erroneos.
      IF vcount <> 0
      THEN
         INSERT INTO sup_diferidosseg_err
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu, cusumod,
                      fmodifi)
            SELECT cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                   falta, tvalord, fanula, nmovimi, nejecu, NULL, NULL
              FROM sup_diferidosseg
             WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

         INSERT INTO sup_acciones_dif_err
                     (cmotmov, sseguro, norden, estado, dinaccion, ttable,
                      tcampo, twhere, taccion, naccion, vaccion, ttarifa,
                      nejecu, cusualt, falta, cusumod, fmodifi)
            SELECT cmotmov, sseguro, norden, estado, dinaccion, ttable,
                   tcampo, twhere, taccion, naccion, vaccion, ttarifa,
                   nejecu, f_user, f_sysdate, NULL, NULL
              FROM sup_acciones_dif
             WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

         DELETE      sup_acciones_dif
               WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

         DELETE      sup_diferidosseg
               WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;
      END IF;

      -- FI BUG 32488/0188508 - FAL - 30/09/2014

      -- IF vcount = 0 THEN -- BUG 32488/0188508 - FAL - 30/09/2014, Se comenta ya que no es necesario pq si vcount <> 0 ya lo borra antes.
      vnejecu := vnejecu + 1;

      INSERT INTO sup_diferidosseg
                  (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                   falta, tvalord, fanula, nmovimi,
                   nejecu
                  )
           VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                   f_sysdate, NULL, NULL, vnmovimi_0 /*ppoliza.nmovimi*/,
                   vnejecu
                  );

      --END IF;
      vpasexec := 6;
      -- para cada una de las garantías del seguro del certificado 0,
      -- INSERT : crear un registro en estgaranseg, en el caso de que no exista en el certificado >0
      -- UPDATE : obtener los capitales y modificarlos en todos los seguros (de las EST) para el mismo riesgo-garantía activo, en el caso de que exista en el certificado >0
      vplan := f_tiene_preg_4089 (psseguro);
      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                   NVL (vplan, 999),
                                   vobject,
                                   vpasexec
                                  );

      -- solo insertamos las garantías que se haya dado de alta nuevas en el suplemento del certificado 0.
      -- las que ya existen, aunque no existan en los certificados no las insertamos porque puede ser que no estén porque
      -- de forma manual las han desseleccionado.
      FOR reg IN (SELECT nriesgo, cgarant, icapital, icaptot
                    FROM garanseg
                   WHERE sseguro = vsseguro_0
                     AND (nriesgo = vplan OR vplan IS NULL)
                     AND ffinefe IS NULL
                  MINUS
                  SELECT nriesgo, cgarant, icapital, icaptot
                    FROM garanseg
                   WHERE sseguro = vsseguro_0
                     AND (nriesgo = vplan OR vplan IS NULL)
                     AND nmovimi = vnmovimi_ant)
      LOOP
         FOR rie IN (SELECT   nriesgo
                         FROM riesgos
                        WHERE sseguro = psseguro AND fanulac IS NULL
                     ORDER BY nriesgo)
         LOOP
            -- mirar si el mismo riesgo-garantía activo se encuentra en el seguro a diferir
            SELECT COUNT (1)
              INTO vcountgarant
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = rie.nriesgo
               AND cgarant = reg.cgarant
               AND ffinefe IS NULL;

            -- crear la función de modificación del seguro en la tabla EST
            IF vcountgarant = 0
            THEN
               -- no se encuentra en el seguro a diferir --> INSERT
               --
               -- crear un registro nuevo
               vnorden := vnorden + 1;
               vdinaccion := 'I';
               vttable := 'ESTGARANSEG';
               vtcampo := '*';
               vtwhere :=
                     'SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant
                  || ' AND FFINEFE IS NULL';
               vtaccion :=
                     'UPDATE ESTGARANSEG SET ICAPITAL = '
                  || NVL (TRANSLATE (TO_CHAR (reg.icapital), ',', '.'),
                          'null')
                  || ', cobliga = 1 '
                  || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant;
               vpasexec := 7;

               --
               -- ejecución del suplemento
               --
               BEGIN
                  pac_log.p_log_sup_diferidos (psseguro,
                                               0,
                                               vtaccion,
                                               vobject,
                                               vpasexec
                                              );

                  INSERT INTO sup_acciones_dif
                              (cmotmov, sseguro, norden, estado, nejecu,
                               dinaccion, ttable, tcampo, twhere,
                               taccion, naccion, vaccion, ttarifa
                              )
                       VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                               vdinaccion, vttable, vtcampo, vtwhere,
                               vtaccion, NULL, NULL, 0
                              );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     -- Existe una programación pendiente para este tipo de suplemento diferido
                     num_err := 9001506;
                     RAISE salir;
               END;

               --Como es un alta de garantia, hay que insertar las posibles preguntas a nivel de garantias
               --que tenga en el certificado 0
               -- crear un registro nuevo
--               vnorden := vnorden + 1;
               vdinaccion := 'I';
               vttable := 'ESTPREGUNGARANSEG';
               vtcampo := '*';
               vtwhere :=
                     'SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant
                  || ' AND FFINEFE IS NULL';
               vtaccion :=
                     'BEGIN INSERT INTO ESTPREGUNGARANSEG (SSEGURO, NRIESGO, CGARANT, NMOVIMI, CPREGUN, CRESPUE, NMOVIMA, FINIEFE, TRESPUE) '
                  || ' SELECT :SSEGURO, '
                  || rie.nriesgo
                  || ', PG.CGARANT, :NMOVIMI, PG.CPREGUN, PG.CRESPUE, :NMOVIMI, :FECHA, PG.TRESPUE '
                  || 'FROM PREGUNGARANSEG PG,  PREGUNPROGARAN PP, SEGUROS S WHERE '
                  || ' PG.SSEGURO = S.SSEGURO '
                  || ' AND PP.CPREGUN = PG.CPREGUN '
                  || ' AND PP.CGARANT = PG.CGARANT '
                  || ' AND PP.SPRODUC = S.SPRODUC '
                  || ' AND VISIBLECOL = 1 '
                  || ' AND VISIBLECERT = 1 '
                  || ' AND PG.SSEGURO='
                  || vsseguro_0
                  || ' AND PG.NMOVIMI='
                  || vnmovimi_0
                  || ' AND PG.NRIESGO = '
                  || reg.nriesgo
                  || ' AND PG.CGARANT = '
                  || reg.cgarant
                  || ' UNION '
                  || ' SELECT :SSEGURO, '
                  || rie.nriesgo
                  || ', PP.CGARANT, :NMOVIMI, PP.CPREGUN, NULL, :NMOVIMI, :FECHA, NULL '
                  || 'FROM PREGUNPROGARAN PP, SEGUROS S WHERE '
                  || 'PP.SPRODUC = S.SPRODUC '
                  || ' AND VISIBLECOL = 0 '
                  || ' AND VISIBLECERT = 1 '
                  || ' AND S.SSEGURO='
                  || vsseguro_0
                  || ' AND PP.CGARANT = '
                  || reg.cgarant
                  || '; EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL; END;';
               vpasexec := 71;

               SELECT DECODE (COUNT (*), 0, 0, 1)
                 INTO vexiste
                 FROM sup_acciones_dif
                WHERE cmotmov = vcmotmov
                  AND sseguro = psseguro
                  AND estado = 0
                  AND nejecu = vnejecu
                  AND DBMS_LOB.compare (taccion, vtaccion) = 0;

               --
               -- ejecución del suplemento
               --
               IF vexiste = 0
               THEN
                  BEGIN
                     vnorden := vnorden + 1;
                     pac_log.p_log_sup_diferidos (psseguro,
                                                  0,
                                                  vtaccion,
                                                  vobject,
                                                  vpasexec
                                                 );

                     INSERT INTO sup_acciones_dif
                                 (cmotmov, sseguro,
                                  norden, estado, nejecu, dinaccion, ttable,
                                  tcampo, twhere, taccion, naccion, vaccion,
                                  ttarifa
                                 )
                          VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/,
                                  vnorden, 0, vnejecu, vdinaccion, vttable,
                                  vtcampo, vtwhere, vtaccion, NULL, NULL,
                                  0
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        -- Existe una programación pendiente para este tipo de suplemento diferido
                        num_err := 9001506;
                        RAISE salir;
                  END;
               END IF;

               --Una vez insertadas las preguntas, como habra preguntas sin respuesta, se
               --mira si  dependiendo del tipo de pregunta hay que calcular la respuesta.
               IF pac_parametros.f_parproducto_n (vsproduc,
                                                  'GRABAR_PREGGARAN_DEF'
                                                 ) = 1
               THEN
                  FOR preg IN (SELECT   ppg.*, cp.ctippre
                                   FROM pregunprogaran ppg,
                                        codipregun cp,
                                        seguros s
                                  WHERE cp.cpregun = ppg.cpregun
                                    AND ppg.sproduc = s.sproduc
                                    AND ppg.sproduc = vsproduc
                                    AND cgarant = reg.cgarant
                                    AND ppg.visiblecol = 0
                                    AND ppg.visiblecert = 1
                                    AND s.sseguro = vsseguro_0
                               ORDER BY npreord)
                  LOOP
                     vtrespue := 'NULL';
                     vcrespue := 'NULL';

                     IF preg.cpretip = 1
                     THEN
                        vpasexec := 72;

                        --Manual
                        IF preg.ctippre NOT IN (4, 5, 7)
                        THEN
                           IF preg.cresdef IS NOT NULL
                           THEN
                              vcrespue := TO_CHAR (preg.cresdef);
                           ELSE
                              vcrespue := 'NULL';
                           END IF;
                        ELSE
                           SELECT DECODE (preg.cresdef,
                                          NULL, 'NULL',
                                          CHR (39) || preg.cresdef || CHR (39)
                                         )
                             INTO vtrespue
                             FROM DUAL;
                        END IF;
                     ELSIF (   preg.cpretip = 3
                            OR (preg.cpretip = 2 AND preg.esccero = 1)
                           )
                     THEN
                        vpasexec := 73;

                        --Semi-Automática
                        IF preg.ctippre NOT IN (4, 5, 7)
                        THEN
                           vcrespue :=
                                 'NVL(pac_sup_diferidos.f_sup_dif_cal_pregar_semi('
                              || CHR (39)
                              || preg.tprefor
                              || CHR (39)
                              || ','
                              || CHR (39)
                              || 'EST'
                              || CHR (39)
                              || ', :SSEGURO,'
                              || rie.nriesgo
                              || ', :FECHA , :NMOVIMI ,'
                              || reg.cgarant
                              || '),'
                              || NVL (TO_CHAR (preg.cresdef), 'NULL')
                              || ')';
                        ELSE
                           vtrespue :=
                                 'NVL(pac_sup_diferidos.f_sup_dif_cal_pregar_semi('
                              || CHR (39)
                              || preg.tprefor
                              || CHR (39)
                              || ','
                              || CHR (39)
                              || 'EST'
                              || CHR (39)
                              || ', :SSEGURO,'
                              || rie.nriesgo
                              || ', :FECHA , :NMOVIMI ,'
                              || reg.cgarant
                              || '),'
                              || CHR (39)
                              || TO_CHAR (preg.cresdef)
                              || CHR (39)
                              || ')';
                        END IF;
                     END IF;

                     vpasexec := 74;
                     vnorden := vnorden + 1;
                     vdinaccion := 'U';
                     vttable := 'ESTPREGUNGARANSEG';
                     vtcampo := '*';
                     vtwhere :=
                           'SSEGURO = :SSEGURO AND NRIESGO = '
                        || rie.nriesgo
                        || ' AND CGARANT = '
                        || reg.cgarant
                        || ' AND FFINEFE IS NULL';
                     vtaccion :=
                           'UPDATE ESTPREGUNGARANSEG SET CRESPUE='
                        || vcrespue
                        || ', TRESPUE='
                        || vtrespue
                        || ' WHERE SSEGURO = :SSEGURO AND NRIESGO='
                        || rie.nriesgo
                        || ' AND CGARANT = '
                        || reg.cgarant
                        || ' AND CPREGUN='
                        || preg.cpregun;

                     --
                     -- ejecución del suplemento
                     --
                     BEGIN
                        pac_log.p_log_sup_diferidos (psseguro,
                                                     0,
                                                     vtaccion,
                                                     vobject,
                                                     vpasexec
                                                    );

                        INSERT INTO sup_acciones_dif
                                    (cmotmov, sseguro,
                                     norden, estado, nejecu, dinaccion,
                                     ttable, tcampo, twhere, taccion,
                                     naccion, vaccion, ttarifa
                                    )
                             VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/,
                                     vnorden, 0, vnejecu, vdinaccion,
                                     vttable, vtcampo, vtwhere, vtaccion,
                                     reg.icaptot, NULL, 0
                                    );
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           -- Existe una programación pendiente para este tipo de suplemento diferido
                           num_err := 9001506;
                           RAISE salir;
                     END;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      -- para cada una de las garantías del seguro del certificado >0,
           -- DELETE : borrar el registro de estgaranseg, en el caso de que no exista en el certificado 0
       -- solo borramos las garantías que realmente se han borrado en el certificado 0
      FOR reg IN (SELECT cgarant
                    FROM garanseg
                   WHERE sseguro = vsseguro_0
                     AND (nriesgo = vplan OR vplan IS NULL)
                     AND nmovimi = vnmovimi_ant
                  MINUS
                  SELECT cgarant
                    FROM garanseg
                   WHERE sseguro = vsseguro_0
                     AND (nriesgo = vplan OR vplan IS NULL)
                     AND ffinefe IS NULL)
      LOOP
         FOR rie IN (SELECT   nriesgo
                         FROM riesgos
                        WHERE sseguro = psseguro AND fanulac IS NULL
                     ORDER BY nriesgo)
         LOOP
            -- mirar si el mismo riesgo-garantía activo se encuentra en el seguro del certificado
            SELECT COUNT (1)
              INTO vcountgarant
              FROM garanseg
             WHERE sseguro = psseguro
               AND cgarant = reg.cgarant
               AND nriesgo = rie.nriesgo
               AND ffinefe IS NULL;

            -- crear la función de modificación del seguro en la tabla EST
            IF vcountgarant = 1
            THEN
               -- no se encuentra en el seguro del certificado 0 --> DELETE
               --
               -- crear un registro nuevo
--               vnorden := vnorden + 1;
               vdinaccion := 'D';
               vttable := 'ESTGARANSEG';
               vtcampo := '*';
               vtwhere :=
                     'SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant
                  || ' AND FFINEFE IS NULL';
               vtaccion :=
                     'DELETE FROM ESTGARANSEG '
                  || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant;
               vpasexec := 12;

               SELECT DECODE (COUNT (*), 0, 0, 1)
                 INTO vexiste
                 FROM sup_acciones_dif
                WHERE cmotmov = vcmotmov
                  AND sseguro = psseguro
                  AND estado = 0
                  AND nejecu = vnejecu
                  AND DBMS_LOB.compare (taccion, vtaccion) = 0;

               --
               -- ejecución del suplemento
               --
               IF vexiste = 0
               THEN
                  BEGIN
                     vnorden := vnorden + 1;
                     pac_log.p_log_sup_diferidos (psseguro,
                                                  0,
                                                  vtaccion,
                                                  vobject,
                                                  vpasexec
                                                 );

                     INSERT INTO sup_acciones_dif
                                 (cmotmov, sseguro, norden, estado, nejecu,
                                  dinaccion, ttable, tcampo, twhere,
                                  taccion, naccion, vaccion, ttarifa
                                 )
                          VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                                  vdinaccion, vttable, vtcampo, vtwhere,
                                  vtaccion, NULL, NULL, 0
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        -- Existe una programación pendiente para este tipo de suplemento diferido
                        num_err := 9001506;
                        RAISE salir;
                  END;
               END IF;

--               vnorden := vnorden + 1;
               vdinaccion := 'D';
               vttable := 'ESTPREGUNGARANSEG';
               vtcampo := '*';
               vtwhere :=
                     'SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant
                  || ' AND FFINEFE IS NULL';
               vtaccion :=
                     'DELETE FROM ESTPREGUNGARANSEG '
                  || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant;
               vpasexec := 12;
               pac_log.p_log_sup_diferidos (psseguro,
                                            0,
                                            vtaccion,
                                            vobject,
                                            vpasexec
                                           );

               SELECT DECODE (COUNT (*), 0, 0, 1)
                 INTO vexiste
                 FROM sup_acciones_dif
                WHERE cmotmov = vcmotmov
                  AND sseguro = psseguro
                  AND estado = 0
                  AND nejecu = vnejecu
                  AND DBMS_LOB.compare (taccion, vtaccion) = 0;

               -- ejecución del suplemento
               --
               IF vexiste = 0
               THEN
                  BEGIN
                     vnorden := vnorden + 1;
                     pac_log.p_log_sup_diferidos (psseguro,
                                                  0,
                                                  vtaccion,
                                                  vobject,
                                                  vpasexec
                                                 );

                     INSERT INTO sup_acciones_dif
                                 (cmotmov, sseguro,
                                  norden, estado, nejecu, dinaccion, ttable,
                                  tcampo, twhere, taccion, naccion, vaccion,
                                  ttarifa
                                 )
                          VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/,
                                  vnorden, 0, vnejecu, vdinaccion, vttable,
                                  vtcampo, vtwhere, vtaccion, NULL, NULL,
                                  0
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        -- Existe una programación pendiente para este tipo de suplemento diferido
                        num_err := 9001506;
                        RAISE salir;
                  END;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      --Si no han añadido ni quitado garantias, hay que revisar si han modificado alguna de las preguntas
      --de las garantias
      FOR reg IN (SELECT nriesgo, cgarant, nmovimi, icapital, icaptot
                    FROM garanseg g
                   WHERE g.sseguro = vsseguro_0
                     AND (g.nriesgo = vplan OR vplan IS NULL)
                     AND g.ffinefe IS NULL
                     AND EXISTS (
                            SELECT cgarant
                              FROM garanseg gg
                             WHERE gg.sseguro = vsseguro_0
                               AND nriesgo = g.nriesgo
                               AND cgarant = g.cgarant
                               AND nmovimi = vnmovimi_ant))
      LOOP
         FOR rie IN (SELECT   nriesgo
                         FROM riesgos
                        WHERE sseguro = psseguro AND fanulac IS NULL
                     ORDER BY nriesgo)
         LOOP
            -- mirar si las respuestas de las preguntas de garantias coinciden, sino modificar con el valor
            --de la respuesta del certificado 0
            FOR garanpre IN (SELECT p.sseguro, p.nriesgo, p.cgarant,
                                    p.cpregun, p.crespue, p.trespue
                               FROM pregungaranseg p, pregunprogaran pg
                              WHERE pg.cgarant = p.cgarant
                                AND pg.cpregun = p.cpregun
                                AND p.sseguro = vsseguro_0
                                AND (p.nriesgo = vplan OR vplan IS NULL)
                                AND p.cgarant = reg.cgarant
                                AND p.nmovimi = reg.nmovimi
                                AND pg.sproduc = vsproduc
                                AND pg.cactivi = vcactivi
                                AND pg.visiblecol = 1
                                AND pg.visiblecert = 1
                             MINUS
                             SELECT p.sseguro, p.nriesgo, p.cgarant,
                                    p.cpregun, p.crespue, p.trespue
                               FROM pregungaranseg p, pregunprogaran pg
                              WHERE pg.cgarant = p.cgarant
                                AND pg.cpregun = p.cpregun
                                AND p.sseguro = vsseguro_0
                                AND (p.nriesgo = vplan OR vplan IS NULL)
                                AND p.cgarant = reg.cgarant
                                AND p.nmovimi = vnmovimi_ant
                                AND pg.sproduc = vsproduc
                                AND pg.cactivi = vcactivi
                                AND pg.visiblecol = 1
                                AND pg.visiblecert = 1)
            LOOP
--P_CONTROL_ERROR('YIL', 'PREG', 'cgarant = '||reg.cgarant||'cpregun ='|| garanpre.cpregun||' crespue ='||garanpre.crespue);
               BEGIN
                  SELECT crespue, trespue
                    INTO vcrespue2, vtrespue2
                    FROM pregungaranseg pg2
                   WHERE sseguro = psseguro
                     AND nriesgo = rie.nriesgo
                     AND cgarant = garanpre.cgarant
                     AND nmovimi =
                            (SELECT nmovimi
                               FROM garanseg
                              WHERE cgarant = pg2.cgarant
                                AND nriesgo = pg2.nriesgo
                                AND sseguro = pg2.sseguro
                                AND ffinefe IS NULL)
                     AND cpregun = garanpre.cpregun;

--P_CONTROL_ERROR('YIL', 'PREG', ' crespue2 ='||vcrespue2);
                  SELECT crespue, trespue
                    INTO vcrespue0_ant, vtrespue0_ant
                    FROM pregungaranseg p
                   WHERE p.sseguro = vsseguro_0
                     AND (p.nriesgo = vplan OR vplan IS NULL)
                     AND p.cgarant = reg.cgarant
                     AND p.nmovimi = vnmovimi_ant
                     AND cpregun = garanpre.cpregun;

-- P_CONTROL_ERROR('YIL', 'PREG', 'crespue0_ant ='||vcrespue0_ant);
                  IF     (   NVL (vcrespue2, 0) <> NVL (garanpre.crespue, 0)
                          OR NVL (vtrespue2, '0') <>
                                                   NVL (garanpre.trespue, '0')
                         )
                     AND (   NVL (vcrespue2, 0) = NVL (vcrespue0_ant, 0)
                          OR NVL (vtrespue2, '0') = NVL (vtrespue0_ant, '1')
                         )
                  THEN
--P_CONTROL_ERROR('YIL', 'PREG', 'entra en el if para modificar');
                     vnorden := vnorden + 1;
                     vdinaccion := 'U';
                     vttable := 'ESTPREGUNGARANSEG';
                     vtcampo := '*';
                     vtwhere :=
                           'SSEGURO = :SSEGURO AND NRIESGO = '
                        || reg.nriesgo
                        || ' AND CGARANT = '
                        || reg.cgarant
                        || ' AND NMOVIMI = '
                        || reg.nmovimi;
                     vtaccion := 'UPDATE ESTPREGUNGARANSEG set crespue=';

                     IF garanpre.crespue IS NULL
                     THEN
                        vtaccion := vtaccion || ' NULL, ';
                     ELSE
                        vtaccion :=
                              vtaccion
                           || TRANSLATE (TO_CHAR (garanpre.crespue), ',', '.')
                           || ',';
                     END IF;

                     vtaccion := vtaccion || ' trespue= ';

                     IF garanpre.trespue IS NULL
                     THEN
                        vtaccion := vtaccion || ' NULL ';
                     ELSE
                        vtaccion :=
                           vtaccion || CHR (39) || garanpre.trespue
                           || CHR (39);
                     END IF;

                     vtaccion :=
                           vtaccion
                        || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                        || rie.nriesgo
                        || ' AND CGARANT = '
                        || reg.cgarant
                        || ' AND NMOVIMI = :NMOVIMI AND CPREGUN='
                        || garanpre.cpregun;
                     vpasexec := 14;
                     pac_log.p_log_sup_diferidos (psseguro,
                                                  0,
                                                  vtaccion,
                                                  vobject,
                                                  vpasexec
                                                 );

                     --
                     -- ejecución del suplemento
                     --
                     BEGIN
                        pac_log.p_log_sup_diferidos (psseguro,
                                                     0,
                                                     vtaccion,
                                                     vobject,
                                                     vpasexec
                                                    );

                        INSERT INTO sup_acciones_dif
                                    (cmotmov, sseguro,
                                     norden, estado, nejecu, dinaccion,
                                     ttable, tcampo, twhere, taccion,
                                     naccion, vaccion, ttarifa
                                    )
                             VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/,
                                     vnorden, 0, vnejecu, vdinaccion,
                                     vttable, vtcampo, vtwhere, vtaccion,
                                     NULL, NULL, 0
                                    );
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           -- Existe una programación pendiente para este tipo de suplemento diferido
                           num_err := 9001506;
                           RAISE salir;
                     END;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     --Si no encuentra la pregunta no hacemos nada,
                     -- ya que se tratara de una nueva garantia y
                     -- ya se habra tratado en el bucle anterior
                     NULL;
               END;
            END LOOP;

--P_CONTROL_ERROR('YIL', 'PREG', 'pasa del sitio');
            --Caso especial para la tasa de pregunta de tabla
            FOR garanpre IN (SELECT   p.*, pg.tprefor, pg.cresdef
                                 FROM pregungaranseg p, pregunprogaran pg
                                WHERE pg.cgarant = p.cgarant
                                  AND pg.cpregun = p.cpregun
                                  AND p.sseguro = psseguro
                                  AND p.nriesgo = rie.nriesgo
                                  AND p.cgarant = reg.cgarant
                                  AND p.nmovimi =
                                         (SELECT nmovimi
                                            FROM garanseg
                                           WHERE cgarant = p.cgarant
                                             AND nriesgo = p.nriesgo
                                             AND sseguro = p.sseguro
                                             AND ffinefe IS NULL)
                                  AND pg.sproduc = vsproduc
                                  AND pg.cactivi = vcactivi
                                  AND p.cpregun = 4815
                                  AND pg.visiblecert = 1
                                  AND EXISTS (
                                         SELECT '1'
                                           FROM pregunprogaran
                                          WHERE sproduc = pg.sproduc
                                            AND cactivi = pg.cactivi
                                            AND cgarant = pg.cgarant
                                            AND cpregun = 4091)
                             ORDER BY p.cgarant, p.cpregun)
            LOOP
               vnorden := vnorden + 1;
               vdinaccion := 'U';
               vttable := 'ESTPREGUNGARANSEG';
               vtcampo := '*';
               vtwhere :=
                     'SSEGURO = :SSEGURO AND NRIESGO = '
                  || reg.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant
                  || ' AND NMOVIMI = '
                  || reg.nmovimi;
               vtaccion :=
                     'UPDATE ESTPREGUNGARANSEG set crespue = NVL(pac_sup_diferidos.f_sup_dif_cal_pregar_semi('
                  || CHR (39)
                  || garanpre.tprefor
                  || CHR (39)
                  || ','
                  || CHR (39)
                  || 'EST'
                  || CHR (39)
                  || ', :SSEGURO,'
                  || rie.nriesgo
                  || ', :FECHA , :NMOVIMI ,'
                  || reg.cgarant
                  || '),'
                  || NVL (TO_CHAR (garanpre.cresdef), 'NULL')
                  || ')';
               vtaccion :=
                     vtaccion
                  || ' WHERE SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant
                  || ' AND NMOVIMI = :NMOVIMI AND CPREGUN='
                  || garanpre.cpregun;
               vpasexec := 12;
               pac_log.p_log_sup_diferidos (psseguro,
                                            0,
                                            vtaccion,
                                            vobject,
                                            vpasexec
                                           );

               -- ejecución del suplemento
               --
               BEGIN
                  pac_log.p_log_sup_diferidos (psseguro,
                                               0,
                                               vtaccion,
                                               vobject,
                                               vpasexec
                                              );

                  INSERT INTO sup_acciones_dif
                              (cmotmov, sseguro,
                               norden, estado, nejecu, dinaccion, ttable,
                               tcampo, twhere, taccion, naccion, vaccion,
                               ttarifa
                              )
                       VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/,
                               vnorden, 0, vnejecu, vdinaccion, vttable,
                               vtcampo, vtwhere, vtaccion, NULL, NULL,
                               0
                              );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     -- Existe una programación pendiente para este tipo de suplemento diferido
                     num_err := 9001506;
                     RAISE salir;
               END;
            END LOOP;

            -- Bug 27048 - 30/07/2013 - JMC - Preguntas que no estan en la caratula
            --Recalculamos las preguntas calculadas que estan en los certificados y no en la caratula.
            FOR garanpre IN
               (SELECT   p.*, pg.tprefor, cp.ctippre, pg.cresdef
                    FROM pregungaranseg p, pregunprogaran pg, codipregun cp
                   WHERE pg.cgarant = p.cgarant
                     AND pg.cpregun = p.cpregun
                     AND cp.cpregun = p.cpregun
                     AND p.sseguro = psseguro
                     AND (   p.nriesgo = rie.nriesgo          --AGG 04/09/2014
                          OR rie.nriesgo IS NULL
                         )                                    --AGG 04/09/2014
                     -- AND(p.nriesgo = vplan
                        --  OR vplan IS NULL)
                     AND p.cgarant = reg.cgarant
                     AND p.nmovimi = (SELECT MAX (nmovimi)
                                        FROM movseguro
                                       WHERE sseguro = p.sseguro)
                     AND pg.sproduc = vsproduc
                     AND pg.cactivi = vcactivi
                     AND pg.visiblecol = 0
                     AND pg.visiblecert = 1
                     AND pg.cpretip = 3                          --Automaticas
                ORDER BY p.cgarant, p.cpregun)
            LOOP
               vtrespue := 'NULL';
               vcrespue := 'NULL';

               IF garanpre.ctippre NOT IN (4, 5, 7)
               THEN
                  vcrespue :=
                        'NVL(pac_sup_diferidos.f_sup_dif_cal_pregar_semi('
                     || CHR (39)
                     || garanpre.tprefor
                     || CHR (39)
                     || ','
                     || CHR (39)
                     || 'EST'
                     || CHR (39)
                     || ', :SSEGURO,'
                     || rie.nriesgo
                     || ', :FECHA , :NMOVIMI ,'
                     || reg.cgarant
                     || '),'
                     || NVL (TO_CHAR (garanpre.cresdef), 'NULL')
                     || ')';
               ELSE
                  vtrespue :=
                        'NVL(pac_sup_diferidos.f_sup_dif_cal_pregar_semi('
                     || CHR (39)
                     || garanpre.tprefor
                     || CHR (39)
                     || ','
                     || CHR (39)
                     || 'EST'
                     || CHR (39)
                     || ', :SSEGURO,'
                     || rie.nriesgo
                     || ', :FECHA , :NMOVIMI ,'
                     || reg.cgarant
                     || '),'
                     || NVL (TO_CHAR (garanpre.cresdef), 'NULL')
                     || ')';
               END IF;

               vpasexec := 94;
               vnorden := vnorden + 1;
               vdinaccion := 'U';
               vttable := 'ESTPREGUNGARANSEG';
               vtcampo := '*';
               vtwhere :=
                     'SSEGURO = :SSEGURO AND NRIESGO = '
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant
                  || ' AND FFINEFE IS NULL';
               vtaccion :=
                     'UPDATE ESTPREGUNGARANSEG SET CRESPUE='
                  || vcrespue
                  || ', TRESPUE='
                  || vtrespue
                  || ' WHERE SSEGURO = :SSEGURO AND NRIESGO='
                  || rie.nriesgo
                  || ' AND CGARANT = '
                  || reg.cgarant
                  || ' AND CPREGUN='
                  || garanpre.cpregun;
               vpasexec := 95;
               pac_log.p_log_sup_diferidos (psseguro,
                                            0,
                                            vtaccion,
                                            vobject,
                                            vpasexec
                                           );

               --
               -- ejecución del suplemento
               --
               BEGIN
                  pac_log.p_log_sup_diferidos (psseguro,
                                               0,
                                               vtaccion,
                                               vobject,
                                               vpasexec
                                              );

                  INSERT INTO sup_acciones_dif
                              (cmotmov, sseguro,
                               norden, estado, nejecu, dinaccion, ttable,
                               tcampo, twhere, taccion, naccion, vaccion,
                               ttarifa
                              )
                       VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/,
                               vnorden, 0, vnejecu, vdinaccion, vttable,
                               vtcampo, vtwhere, vtaccion, reg.icaptot, NULL,
                               0
                              );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     -- Existe una programación pendiente para este tipo de suplemento diferido
                     num_err := 9001506;
                     RAISE salir;
               END;
            END LOOP;
         -- Fin Bug 27048 - 30/07/2013 - JMC
         END LOOP;
      END LOOP;

      -- actualizar para tarifar=SI tras la última acción
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND norden = vnorden;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifgarantias;

   /*************************************************************************
      Realiza el diferimiento del suplemento 288 (Inclusión/Exclusión de clausulas)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifclausulas (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi        NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)                         := 0;
      vparam        VARCHAR2 (500)
         :=    'psseguro = '
            || psseguro
            || '; pfecsupl = '
            || TO_CHAR (pfecsupl, 'dd/mm/yyyy')
            || '; pnmovimi = '
            || pnmovimi;
      vobject       VARCHAR2 (200)
                           := 'pac_sup_diferidos.f_diferir_spl_modifclausulas';
      vcmotmov      pds_supl_dif_config.cmotmov%TYPE   := 288;
      vfvalfun      pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl      DATE;
      vsseguro_0    seguros.sseguro%TYPE;
      vnmovimi_0    movseguro.nmovimi%TYPE;
      vnorden       sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion    sup_acciones_dif.dinaccion%TYPE;
      vttable       sup_acciones_dif.ttable%TYPE;
      vtcampo       sup_acciones_dif.tcampo%TYPE;
      vtwhere       sup_acciones_dif.twhere%TYPE;
      vtaccion      sup_acciones_dif.taccion%TYPE;
      vnejecu       sup_acciones_dif.nejecu%TYPE;
      vcount        NUMBER;
      vcountclaus   NUMBER;
      vnpoliza      seguros.npoliza%TYPE;
      vsproduc      seguros.sproduc%TYPE;
      num_err       NUMBER;
      vexiste       NUMBER;
      salir         EXCEPTION;
   BEGIN
      vpasexec := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vpasexec);

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         num_err := 101901;
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);

         pac_log.p_log_sup_diferidos (psseguro, 0, vfvalfun, vobject,
                                      vpasexec);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- obtener el sseguro (de REAL) del certificado 0
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;

      --Si existe una clausula de seguro (CLAUSUSEG) en la póliza madre (certificado 0) y no existe en el certificado, la añadimos.
      FOR reg IN (SELECT sclagen
                    FROM claususeg c
                   WHERE sseguro = vsseguro_0
                     AND nmovimi =
                            (SELECT MAX (nmovimi)
                               FROM claususeg
                              WHERE nmovimi <= vnmovimi_0
                                AND sseguro = c.sseguro
                                AND sclagen = c.sclagen
                                AND nordcla = c.nordcla)
                  MINUS
                  SELECT sclagen
                    FROM claususeg
                   WHERE sseguro = psseguro AND ffinclau IS NULL)
      LOOP
         -- crear un registro nuevo
--         vnorden := vnorden + 1;
         vdinaccion := 'I';
         vttable := 'ESTCLAUSUSEG';
         vtcampo := '*';
         vtwhere := 'SSEGURO = ';
         vtaccion :=
               'INSERT INTO ESTCLAUSUSEG'
            || '(sseguro, sclagen, nmovimi, finiclau, ffinclau, nordcla)'
            || ' SELECT '
            || ' :SSEGURO, sclagen, :NMOVIMI, finiclau, ffinclau, nordcla'
            || ' FROM CLAUSUSEG WHERE '
            || 'SSEGURO = '
            || vsseguro_0
            || ' AND NMOVIMI = '
            || vnmovimi_0
            || ' AND SCLAGEN = '
            || reg.sclagen;
         vpasexec := 7;

         SELECT DECODE (COUNT (*), 0, 0, 1)
           INTO vexiste
           FROM sup_acciones_dif
          WHERE cmotmov = vcmotmov
            AND sseguro = psseguro
            AND estado = 0
            AND nejecu = vnejecu
            AND DBMS_LOB.compare (taccion, vtaccion) = 0;

         --
         -- ejecución del suplemento
         --
         IF vexiste = 0
         THEN
            BEGIN
               vnorden := vnorden + 1;

               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa
                           )
                    VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                            vdinaccion, vttable, vtcampo, vtwhere, vtaccion,
                            NULL, NULL, 0
                           );

               pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; norden = '
                          || vnorden
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
            END;
         END IF;
      END LOOP;

      --Si existe una clausula de seguro (CLAUSUSEG) en lel certificado y no existe en a póliza madre (certificado 0) , la borramos.
      FOR reg IN (SELECT sclagen
                    FROM claususeg
                   WHERE sseguro = psseguro AND ffinclau IS NULL
                  MINUS
                  SELECT sclagen
                    FROM claususeg c
                   WHERE sseguro = vsseguro_0
                     AND nmovimi =
                            (SELECT MAX (nmovimi)
                               FROM claususeg
                              WHERE nmovimi <= vnmovimi_0
                                AND sseguro = c.sseguro
                                AND sclagen = c.sclagen
                                AND nordcla = c.nordcla))
      LOOP
         -- crear un registro nuevo
         vnorden := vnorden + 1;
         vdinaccion := 'D';
         vttable := 'ESTCLAUSUSEG';
         vtcampo := '*';
         vtwhere := 'SSEGURO = ';
         vtaccion :=
               'DELETE FROM ESTCLAUSUSEG '
            || ' WHERE SSEGURO = :SSEGURO '
            || ' AND NMOVIMI = :NMOVIMI AND SCLAGEN = '
            || reg.sclagen;
         vpasexec := 7;

         --
         -- ejecución del suplemento
         --
         BEGIN
            INSERT INTO sup_acciones_dif
                        (cmotmov, sseguro, norden, estado, nejecu,
                         dinaccion, ttable, tcampo, twhere, taccion,
                         naccion, vaccion, ttarifa
                        )
                 VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                         vdinaccion, vttable, vtcampo, vtwhere, vtaccion,
                         NULL, NULL, 0
                        );

            pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; norden = '
                          || vnorden
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               -- Existe una programación pendiente para este tipo de suplemento diferido
               num_err := 9001506;
               RAISE salir;
         END;
      END LOOP;

      -- para cada una de las cláusulas del seguro en CLAUSUESP del certificado 0,
      -- INSERT : crear un registro en estclausuesp, en el caso de que no exista en el certificado >0
      FOR reg IN (SELECT cclaesp, nriesgo, tclaesp
                    FROM clausuesp c
                   WHERE sseguro = vsseguro_0
                     AND nmovimi =
                            (SELECT MAX (nmovimi)
                               FROM clausuesp
                              WHERE nmovimi <= vnmovimi_0
                                AND sseguro = c.sseguro
                                AND cclaesp = c.cclaesp
                                AND nriesgo = c.nriesgo
                                AND nordcla = c.nordcla)
                  MINUS
                  SELECT cclaesp, nriesgo, tclaesp
                    FROM clausuesp
                   WHERE sseguro = psseguro AND ffinclau IS NULL)
      LOOP
         -- crear la función de modificación del seguro en la tabla EST
            -- no se encuentra en el seguro a diferir --> INSERT
            --
            -- crear un registro nuevo
--         vnorden := vnorden + 1;
         vdinaccion := 'I';
         vttable := 'ESTCLAUSUESP';
         vtcampo := '*';
         vtwhere := 'SSEGURO ';
         vtaccion :=
               'INSERT INTO ESTCLAUSUESP'
            || '(nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen, tclaesp, ffinclau)'
            || ' SELECT '
            || ' :NMOVIMI, :SSEGURO, cclaesp, '
            || '(select NVL(MAX(nordcla), 0) + 1 from estclausuesp where sseguro= :SSEGURO and nmovimi = :NMOVIMI and cclaesp='
            || reg.cclaesp
            || ' and nriesgo = '
            || reg.nriesgo
            || ') nordcla, '
            || 'nriesgo, finiclau, sclagen, tclaesp, ffinclau'
            || ' FROM CLAUSUESP WHERE '
            || 'SSEGURO = '
            || vsseguro_0
            || ' AND NRIESGO = '
            || reg.nriesgo
            || ' AND CCLAESP = '
            || reg.cclaesp
            || ' AND NMOVIMI = '
            || vnmovimi_0
            || ' AND TCLAESP = '
            || CHR (39)
            || reg.tclaesp
            || CHR (39);
         vpasexec := 7;

         SELECT DECODE (COUNT (*), 0, 0, 1)
           INTO vexiste
           FROM sup_acciones_dif
          WHERE cmotmov = vcmotmov
            AND sseguro = psseguro
            AND estado = 0
            AND nejecu = vnejecu
            AND DBMS_LOB.compare (taccion, vtaccion) = 0;

         --
         -- ejecución del suplemento
         --
         IF vexiste = 0
         THEN
            BEGIN
               vnorden := vnorden + 1;

               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa
                           )
                    VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                            vdinaccion, vttable, vtcampo, vtwhere, vtaccion,
                            NULL, NULL, 0
                           );

               pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; norden = '
                          || vnorden
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
            END;
         END IF;
      END LOOP;

      -- actualizar para tarifar=SI tras la última acción
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND norden = vnorden;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifclausulas;

   /*************************************************************************
      Realiza el diferimiento del suplemento 684 (Modificación de preguntas de póliza)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifpregunpol (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500)
         :=    'psseguro = '
            || psseguro
            || '; pfecsupl = '
            || TO_CHAR (pfecsupl, 'dd/mm/yyyy')
            || '; pnmovimi = '
            || pnmovimi;
      vobject      VARCHAR2 (200)
                           := 'pac_sup_diferidos.f_diferir_spl_modifpregunpol';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 684;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vcountpreg   NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      num_err      NUMBER;
      vexiste      NUMBER;
      salir        EXCEPTION;
   BEGIN
      vpasexec := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vpasexec);

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         num_err := 101901;
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);

         pac_log.p_log_sup_diferidos (psseguro, 0, vfvalfun, vobject,
                                      vpasexec);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- obtener el sseguro (de REAL) del certificado 0
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;

      -- para cada una de las preguntas de póliza del seguro del certificado 0,
      -- INSERT : crear un registro en estpregunpolseg, en el caso de que no exista en el certificado >0
      -- UPDATE : obtener las respuestas y modificarlas en todos los seguros (de las EST) para las misma pregunta de póliza, en el caso de que exista en el certificado >0
      FOR reg IN (SELECT   ps.cpregun, ps.nmovimi, ps.crespue, ps.trespue
                      FROM pregunpolseg ps, pregunpro pp
                     WHERE pp.cpregun = ps.cpregun
                       AND ps.sseguro = vsseguro_0
                       AND ps.nmovimi = vnmovimi_0
                       AND pp.sproduc = vsproduc
                       AND pp.visiblecert = 1
                       AND pp.visiblecol = 1
                  ORDER BY ps.cpregun)
      LOOP
         -- mirar si la misma pregunta de póliza se encuentra en el seguro a diferir
         SELECT COUNT (1)
           INTO vcountpreg
           FROM pregunpolseg ps, pregunpro pp
          WHERE ps.cpregun = pp.cpregun
            AND pp.sproduc = vsproduc
            AND pp.visiblecert = 1
            AND pp.visiblecol = 1
            AND ps.sseguro = psseguro
            AND ps.cpregun = reg.cpregun
            AND ps.nmovimi =
                        (SELECT MAX (nmovimi)
                           FROM pregunpolseg
                          WHERE sseguro = ps.sseguro AND cpregun = ps.cpregun);

         -- crear la función de modificación del seguro en la tabla EST
         IF vcountpreg = 0
         THEN
            -- no se encuentra en el seguro a diferir --> INSERT
            --
            -- crear un registro nuevo
--            vnorden := vnorden + 1;
            vdinaccion := 'I';
            vttable := 'PREGUNPOLSEG';
            vtcampo := '*';
            --Bug 27876/0159903 - JSV - 27/11/2013
            vtwhere :=
                  'SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               || ' AND NMOVIMI = :NMOVIMI';
            vtaccion :=
                  'INSERT INTO ESTPREGUNPOLSEG'
               || '(cpregun, sseguro, nmovimi, crespue, trespue) '
               || ' SELECT '
               --Bug 27876/0159903 - JSV - 27/11/2013
               || 'cpregun, :SSEGURO, :NMOVIMI, crespue, trespue'
               || ' FROM PREGUNPOLSEG WHERE '
               || 'SSEGURO = '
               || vsseguro_0
               || ' AND CPREGUN = '
               || reg.cpregun
               || ' AND NMOVIMI = '
               || reg.nmovimi;
            vpasexec := 7;

            SELECT DECODE (COUNT (*), 0, 0, 1)
              INTO vexiste
              FROM sup_acciones_dif
             WHERE cmotmov = vcmotmov
               AND sseguro = psseguro
               AND estado = 0
               AND nejecu = vnejecu
               AND DBMS_LOB.compare (taccion, vtaccion) = 0;

            --
            -- ejecución del suplemento
            --
            IF vexiste = 0
            THEN
               BEGIN
                  vnorden := vnorden + 1;

                  INSERT INTO sup_acciones_dif
                              (cmotmov, sseguro, norden, estado, nejecu,
                               dinaccion, ttable, tcampo, twhere,
                               taccion, naccion, vaccion, ttarifa
                              )
                       VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                               vdinaccion, vttable, vtcampo, vtwhere,
                               vtaccion, NULL, NULL, 0
                              );

                  pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; norden = '
                          || vnorden
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     -- Existe una programación pendiente para este tipo de suplemento diferido
                     num_err := 9001506;
                     RAISE salir;
               END;
            END IF;
         ELSE
            vpasexec := 8;
            -- se encuentra en el seguro a diferir --> UPDATE
            --
            -- modificar CRESPUE
            vnorden := vnorden + 1;
            vdinaccion := 'U';
            vttable := 'PREGUNPOLSEG';

            IF reg.trespue IS NOT NULL
            THEN
               vtcampo := 'TRESPUE';
            ELSE
               vtcampo := 'CRESPUE';
            END IF;

            vtwhere :=
                  'SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               || ' AND NMOVIMI = (select max(nmovimi) from pregunpolseg where sseguro= :SSEGURO and cpregun= '
               || reg.cpregun
               || ')';
            vtaccion :=
                  'UPDATE ESTPREGUNPOLSEG SET CRESPUE = '
               || NVL (TRANSLATE (TO_CHAR (reg.crespue), ',', '.'), 'null')
               || ', TRESPUE = '
               || CHR (39)
               || reg.trespue
               || CHR (39)              -- Bug 27417/161505 - 20/12/2013 - HRE
               || ' WHERE SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               --Bug 27876/0159903 - JSV - 27/11/2013
               || ' AND NMOVIMI = :NMOVIMI';
            vpasexec := 9;

            --
            -- ejecución del suplemento
            --
            BEGIN
               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa)
                  SELECT vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                         vttable, vtcampo, vtwhere, vtaccion,
                         DECODE (reg.trespue, NULL, reg.crespue, NULL),
                         DECODE (reg.trespue, NULL, NULL, reg.trespue), 0
                    FROM DUAL;

               pac_log.p_log_sup_diferidos
                        (psseguro,
                         0,
                            'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                         || vcmotmov
                         || '; sseguro = '
                         || psseguro
                         || '; norden = '
                         || vnorden
                         || '; estado = 0; nejecu = '
                         || vnejecu,
                         vobject,
                         vpasexec
                        );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
            END;
         END IF;
      END LOOP;

      -- para cada una de las preguntas de póliza del seguro del certificado >0,
      -- DELETE : borrar el registro de estpregunpolseg, en el caso de que no exista en el certificado 0
      FOR reg IN (SELECT ps.cpregun, ps.nmovimi
                    FROM pregunpolseg ps, pregunpro pp
                   WHERE ps.cpregun = pp.cpregun
                     AND pp.sproduc = vsproduc
                     AND pp.visiblecol = 1
                     AND pp.visiblecert = 1
                     AND ps.sseguro = psseguro
                     AND ps.nmovimi =
                            (SELECT MAX (p2.nmovimi)
                               FROM pregunpolseg p2
                              WHERE p2.sseguro = ps.sseguro
                                AND p2.cpregun = ps.cpregun))
      LOOP
         -- mirar si la misma pregunta de póliza se encuentra en el seguro del certificado 0
         SELECT COUNT (1)
           INTO vcountpreg
           FROM pregunpolseg ps, pregunpro pp
          WHERE pp.cpregun = ps.cpregun
            AND ps.cpregun = reg.cpregun
            AND ps.sseguro = vsseguro_0
            AND ps.nmovimi = vnmovimi_0
            AND pp.sproduc = vsproduc
            AND pp.visiblecol = 1
            AND pp.visiblecert = 1;

         -- crear la función de modificación del seguro en la tabla EST
         IF vcountpreg = 0
         THEN
            -- no se encuentra en el seguro del certificado 0 --> DELETE
            --
            -- crear un registro nuevo
            vnorden := vnorden + 1;
            vdinaccion := 'D';
            vttable := 'PREGUNPOLSEG';
            vtcampo := '*';
            vtwhere :=
                  'SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               || ' AND NMOVIMI = '
               || vnmovimi_0;
            vtaccion :=
                  'DELETE FROM ESTPREGUNPOLSEG '
               || ' WHERE SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               --Bug 27876/0159903 - JSV - 27/11/2013
               || ' AND NMOVIMI = :NMOVIMI';
            vpasexec := 12;

            --
            -- ejecución del suplemento
            --
            BEGIN
               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa
                           )
                    VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                            vdinaccion, vttable, vtcampo, vtwhere, vtaccion,
                            NULL, NULL, 0
                           );

               pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; norden = '
                          || vnorden
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
            END;
         END IF;
      END LOOP;

      -- actualizar para tarifar=SI tras la última acción
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND norden = vnorden;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifpregunpol;

   /*************************************************************************
      Realiza el diferimiento del suplemento 685 (Modificación de preguntas de riesgo)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifpregunries (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500)
         :=    'psseguro = '
            || psseguro
            || '; pfecsupl = '
            || TO_CHAR (pfecsupl, 'dd/mm/yyyy')
            || '; pnmovimi = '
            || pnmovimi;
      vobject      VARCHAR2 (200)
                          := 'pac_sup_diferidos.f_diferir_spl_modifpregunries';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 685;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vcountpreg   NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      num_err      NUMBER;
      vexiste      NUMBER;
      salir        EXCEPTION;
   BEGIN
      vpasexec := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vpasexec);

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         num_err := 101901;
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);

         pac_log.p_log_sup_diferidos (psseguro, 0, vfvalfun, vobject,
                                      vpasexec);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;  --ppoliza.ssegpol;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- obtener el sseguro (de REAL) del certificado 0
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;            --ppoliza.npoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;

      -- para cada una de las preguntas de póliza del seguro del certificado 0,
      -- INSERT : crear un registro en estpregunseg, en el caso de que no exista en el certificado >0
      -- UPDATE : obtener las respuestas y modificarlas en todos los seguros (de las EST) para las misma pregunta de póliza, en el caso de que exista en el certificado >0
      FOR reg IN (SELECT   ps.cpregun, ps.nmovimi, ps.crespue, ps.trespue,
                           ps.nriesgo
                      FROM pregunseg ps, pregunpro pp
                     WHERE pp.cpregun = ps.cpregun
                       AND ps.sseguro = vsseguro_0
                       AND ps.nmovimi = vnmovimi_0
                       AND pp.sproduc = vsproduc
                       AND pp.visiblecert = 1
                       AND pp.visiblecol = 1
                  ORDER BY ps.cpregun)
      LOOP
         -- mirar si la misma pregunta de póliza se encuentra en el seguro a diferir
         SELECT COUNT (1)
           INTO vcountpreg
           FROM pregunseg ps, pregunpro pp
          WHERE ps.cpregun = pp.cpregun
            AND pp.sproduc = vsproduc
            AND ps.nriesgo = reg.nriesgo
            AND pp.visiblecert = 1
            AND pp.visiblecol = 1
            AND ps.sseguro = psseguro
            AND ps.cpregun = reg.cpregun
            AND ps.nriesgo = reg.nriesgo
            AND ps.nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM pregunseg
                     WHERE sseguro = ps.sseguro
                       AND cpregun = ps.cpregun
                       AND nriesgo = ps.nriesgo);

         -- crear la función de modificación del seguro en la tabla EST
         IF vcountpreg = 0
         THEN
            -- no se encuentra en el seguro a diferir --> INSERT
            --
            -- crear un registro nuevo
--            vnorden := vnorden + 1;
            vdinaccion := 'I';
            vttable := 'PREGUNSEG';
            vtcampo := '*';
            --Bug 27876/0159903 - JSV - 27/11/2013
            vtwhere :=
                  'SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               || ' AND NMOVIMI = :NMOVIMI';
            vtaccion :=
                  'INSERT INTO ESTPREGUNSEG'
               || '(cpregun, sseguro, nmovimi, crespue, trespue) '
               || ' SELECT '
               --Bug 27876/0159903 - JSV - 27/11/2013
               || 'cpregun, :SSEGURO, :NMOVIMI, crespue, trespue'
               || ' FROM PREGUNSEG WHERE '
               || 'SSEGURO = '
               || vsseguro_0
               || ' AND CPREGUN = '
               || reg.cpregun
               || ' AND NMOVIMI = '
               || reg.nmovimi;
            vpasexec := 7;

            SELECT DECODE (COUNT (*), 0, 0, 1)
              INTO vexiste
              FROM sup_acciones_dif
             WHERE cmotmov = vcmotmov
               AND sseguro = psseguro
               AND estado = 0
               AND nejecu = vnejecu
               AND DBMS_LOB.compare (taccion, vtaccion) = 0;

            --
            -- ejecución del suplemento
            --
            IF vexiste = 0
            THEN
               BEGIN
                  vnorden := vnorden + 1;

                  INSERT INTO sup_acciones_dif
                              (cmotmov, sseguro, norden, estado, nejecu,
                               dinaccion, ttable, tcampo, twhere,
                               taccion, naccion, vaccion, ttarifa
                              )
                       VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                               vdinaccion, vttable, vtcampo, vtwhere,
                               vtaccion, NULL, NULL, 0
                              );

                  pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; norden = '
                          || vnorden
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     -- Existe una programación pendiente para este tipo de suplemento diferido
                     num_err := 9001506;
                     RAISE salir;
               END;
            END IF;
         ELSE
            vpasexec := 8;
            -- se encuentra en el seguro a diferir --> UPDATE
            --
            -- modificar CRESPUE
            vnorden := vnorden + 1;
            vdinaccion := 'U';
            vttable := 'PREGUNSEG';

            IF reg.trespue IS NOT NULL
            THEN
               vtcampo := 'TRESPUE';
            ELSE
               vtcampo := 'CRESPUE';
            END IF;

            --Bug 27876/0159903 - JSV - 27/11/2013
            vtwhere :=
                  'SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               || ' AND NMOVIMI = :NMOVIMI';                 --|| reg.nmovimi;
            vtaccion :=
                  'UPDATE ESTPREGUNSEG SET CRESPUE = '
               || NVL (TRANSLATE (TO_CHAR (reg.crespue), ',', '.'), 'null')
               || ', TRESPUE = '
               || CHR (39)
               || reg.trespue
               || CHR (39)              -- Bug 27417/161505 - 20/12/2013 - HRE
               || ' WHERE SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               --Bug 27876/0159903 - JSV - 27/11/2013
               || ' AND NMOVIMI = :NMOVIMI';                -- || reg.nmovimi;
            vpasexec := 9;

            --
            -- ejecución del suplemento
            --
            BEGIN
               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa)
                  SELECT vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                         vttable, vtcampo, vtwhere, vtaccion,
                         DECODE (reg.trespue, NULL, reg.crespue, NULL),
                         DECODE (reg.trespue, NULL, NULL, reg.trespue), 0
                    FROM DUAL;

               pac_log.p_log_sup_diferidos
                        (psseguro,
                         0,
                            'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                         || vcmotmov
                         || '; sseguro = '
                         || psseguro
                         || '; norden = '
                         || vnorden
                         || '; estado = 0; nejecu = '
                         || vnejecu,
                         vobject,
                         vpasexec
                        );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
            END;
         END IF;
      END LOOP;

      -- para cada una de las preguntas de póliza del seguro del certificado >0,
      -- DELETE : borrar el registro de estpregunpolseg, en el caso de que no exista en el certificado 0
      FOR reg IN (SELECT ps.cpregun, ps.nmovimi
                    FROM pregunseg ps, pregunpro pp
                   WHERE ps.cpregun = pp.cpregun
                     AND pp.sproduc = vsproduc
                     AND pp.visiblecol = 1
                     AND pp.visiblecert = 1
                     AND ps.sseguro = psseguro
                     AND ps.nmovimi = (SELECT MAX (p2.nmovimi)
                                         FROM pregunseg p2
                                        WHERE p2.sseguro = ps.sseguro))
      LOOP
         -- mirar si la misma pregunta de póliza se encuentra en el seguro del certificado 0
         SELECT COUNT (1)
           INTO vcountpreg
           FROM pregunseg ps, pregunpro pp
          WHERE pp.cpregun = ps.cpregun
            AND ps.cpregun = reg.cpregun
            AND ps.sseguro = vsseguro_0
            AND ps.nmovimi = vnmovimi_0
            AND pp.sproduc = vsproduc
            AND pp.visiblecol = 1
            AND pp.visiblecert = 1;

         -- crear la función de modificación del seguro en la tabla EST
         IF vcountpreg = 0
         THEN
            -- no se encuentra en el seguro del certificado 0 --> DELETE
            --
            -- crear un registro nuevo
            vnorden := vnorden + 1;
            vdinaccion := 'D';
            vttable := 'PREGUNSEG';
            vtcampo := '*';
            --Bug 27876/0159903 - JSV - 27/11/2013
            vtwhere :=
                  'SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               || ' AND NMOVIMI = :NMOVIMI';                 -- || vnmovimi_0;
            vtaccion :=
                  'DELETE FROM ESTPREGUNSEG '
               || ' WHERE SSEGURO = :SSEGURO AND CPREGUN = '
               || reg.cpregun
               --Bug 27876/0159903 - JSV - 27/11/2013
               || ' AND NMOVIMI = :NMOVIMI';                 -- || vnmovimi_0;
            vpasexec := 12;

            --
            -- ejecución del suplemento
            --
            BEGIN
               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa
                           )
                    VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                            vdinaccion, vttable, vtcampo, vtwhere, vtaccion,
                            NULL, NULL, 0
                           );

               pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_acciones_dif VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; norden = '
                          || vnorden
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
            END;
         END IF;
      END LOOP;

      -- actualizar para tarifar=SI tras la última acción
      UPDATE sup_acciones_dif
         SET ttarifa = 1
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND norden = vnorden;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifpregunries;

   /*************************************************************************
      Realiza el diferimiento del suplemento 225 (cambio de intermediario)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifoficina (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                            := 'PAC_SUP_DIFERIDOS.f_diferir_spl_modifoficina';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 225;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vcagente     seguros.cagente%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      salir        EXCEPTION;
      num_err      NUMBER;
   BEGIN
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro, cagente
        INTO vsseguro_0, vcagente
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;            --ppoliza.npoliza;

      vpasexec := 5;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 6;
      --
      -- modificar CAGENTE
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := 'CAGENTE';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET CAGENTE = '
         || NVL (TO_CHAR (vcagente), 'null')
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 7;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado,
                      nejecu, dinaccion, ttable, tcampo, twhere,
                      taccion, naccion, vaccion, ttarifa
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                      vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                      vtaccion, vcagente, NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      --BUG 27048/148456 - INICIO - DCT - LCOL_T010-Revisió incidencias qtracker (V)
      vpasexec := 8;
      --
      -- modificar CAGENTE
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTAGE_CORRETAJE';
      vtcampo := 'CAGENTE';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTAGE_CORRETAJE SET CAGENTE = '
         || NVL (TO_CHAR (vcagente), 'null')
         || ' WHERE SSEGURO = :SSEGURO AND NMOVIMI = :NMOVIMI AND ISLIDER = 1';
      vpasexec := 9;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado,
                      nejecu, dinaccion, ttable, tcampo, twhere,
                      taccion, naccion, vaccion, ttarifa
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                      vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                      vtaccion, vcagente, NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      --BUG 27048/148456 - FIN - DCT - LCOL_T010-Revisió incidencias qtracker (V)
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifoficina;

-- Fin Bug 24278 - MDS - 06/11/2012
   /*************************************************************************
      Realiza el diferimiento del suplemento 269 (cambio de forma de pago)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifcforpag (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                            := 'PAC_SUP_DIFERIDOS.f_diferir_spl_modifcforpag';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 269;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vcforpag     seguros.cforpag%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      salir        EXCEPTION;
      num_err      NUMBER;
      vcrespue     pregunpolseg.crespue%TYPE;
      vtrespue     pregunpolseg.trespue%TYPE;
      vpregun      pregunpolseg.cpregun%TYPE;
   BEGIN
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro, cforpag
        INTO vsseguro_0, vcforpag
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;            --ppoliza.npoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;
      --
      -- modificar CAGENTE
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := 'CAGENTE';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET CFORPAG = '
         || NVL (TO_CHAR (vcforpag), 'null')
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 7;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado,
                      nejecu, dinaccion, ttable, tcampo, twhere,
                      taccion, naccion, vaccion, ttarifa
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                      vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                      vtaccion, vcforpag, NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      vpasexec := 8;
      --ini bug 29582#c162722 :JDS: 08/01/2014 --> propagar el suplemento de forma de pago al resto de certificados.
--      vnorden := vnorden + 1;
--      vdinaccion := 'U';
--      vttable := 'PREGUNPOLSEG';
--      vpregun := 4084;

      --      SELECT crespue, trespue
--        INTO vcrespue, vtrespue
--        FROM pregunpolseg
--       WHERE sseguro = vsseguro_0
--         AND nmovimi = vnmovimi_0
--         AND cpregun = vpregun;

      --      vtwhere :=
--         'SSEGURO = :SSEGURO AND CPREGUN = ' || vpregun
--         || ' AND NMOVIMI = (select max(nmovimi) from pregunpolseg where sseguro= :SSEGURO and cpregun= '
--         || vpregun || ')';
--      vtaccion := 'UPDATE ESTPREGUNPOLSEG SET CRESPUE = '
--                  || NVL(TRANSLATE(TO_CHAR(vcrespue), ',', '.'), 'null') || ', TRESPUE = '
--                  || CHR(39) || vtrespue || CHR(39)
--                  || ' WHERE SSEGURO = :SSEGURO AND CPREGUN = ' || vpregun
--                  || ' AND NMOVIMI = :NMOVIMI';
--      vpasexec := 9;
--      pac_log.p_log_sup_diferidos(psseguro, 0, vtaccion, vobject, vpasexec);

      --      --
--      -- ejecución del suplemento
--      --
--      BEGIN
--         INSERT INTO sup_acciones_dif
--                     (cmotmov, sseguro, norden, estado, nejecu, dinaccion,
--                      ttable, tcampo, twhere, taccion, naccion, vaccion, ttarifa)
--              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0, vnejecu, vdinaccion,
--                      vttable, vtcampo, vtwhere, vtaccion, vcforpag, NULL, 0);
--      EXCEPTION
--         WHEN DUP_VAL_ON_INDEX THEN
--            -- Existe una programación pendiente para este tipo de suplemento diferido
--            num_err := 9001506;
--            RAISE salir;
--         WHEN OTHERS THEN
--            RAISE salir;
--      END;

      --fin bug 29582#c162722 :JDS: 08/01/2014
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifcforpag;

   /*************************************************************************
      Realiza el diferimiento del suplemento 674 (cambio de vigencia)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modiffefecto (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                            := 'PAC_SUP_DIFERIDOS.f_diferir_spl_modiffefecto';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 674;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vfefecto     seguros.fefecto%TYPE;
      vfrenova     seguros.frenova%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      salir        EXCEPTION;
      num_err      NUMBER;
   BEGIN
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov
         AND sseguro = psseguro                              --ppoliza.ssegpol
         AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro, fefecto, frenova
        INTO vsseguro_0, vfefecto, vfrenova
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;            --ppoliza.npoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      IF vcount = 0
      THEN
         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;
      --
      -- modificar CAGENTE
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := 'CAGENTE';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion := 'UPDATE ESTSEGUROS SET FEFECTO = ';

      IF vfefecto IS NOT NULL
      THEN
         vtaccion :=
               vtaccion
            || 'to_date('
            || CHR (39)
            || TO_CHAR (vfefecto, 'yyyymmdd')
            || CHR (39)
            || ','
            || CHR (39)
            || 'yyyymmdd'
            || CHR (39)
            || ')';
      ELSE
         vtaccion := vtaccion || ' NULL ';
      END IF;

      vtaccion := vtaccion || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 7;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado,
                      nejecu, dinaccion, ttable, tcampo, twhere,
                      taccion, naccion, vaccion, ttarifa
                     )
              VALUES (vcmotmov, psseguro /*ppoliza.ssegpol*/, vnorden, 0,
                      vnejecu, vdinaccion, vttable, vtcampo, vtwhere,
                      vtaccion, TO_CHAR (vfefecto, 'yyyymmdd'), NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modiffefecto;

   /*************************************************************************
      Realiza el diferimiento del suplemento 828 (cambio de comision)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifcomisi (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                             := 'PAC_SUP_DIFERIDOS.f_diferir_spl_modifcomisi';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 828;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vctipcom     seguros.ctipcom%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      salir        EXCEPTION;
      num_err      NUMBER;
      vplan        NUMBER;
      vexiste      NUMBER;
   BEGIN
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro, ctipcom
        INTO vsseguro_0, vctipcom
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;
      --
      -- modificar CTIPCOM
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := 'CTIPCOM';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET CTIPCOM = '
         || NVL (TO_CHAR (vctipcom), 'null')
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 7;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, nejecu, dinaccion,
                      ttable, tcampo, twhere, taccion, naccion, vaccion,
                      ttarifa
                     )
              VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                      vttable, vtcampo, vtwhere, vtaccion, vctipcom, NULL,
                      0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      vpasexec := 51;
      --
      -- borrar ESTCOMISIONSEGU
      vnorden := vnorden + 1;
      vdinaccion := 'D';
      vttable := 'ESTSEGUROS';
      vtcampo := 'CTIPCOM';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
         'DELETE ESTCOMISIONSEGU WHERE SSEGURO = :SSEGURO  AND NMOVIMI= :NMOVIMI';
      -- Bug 30642/169851 - 20/03/2014 - AMC
      vpasexec := 71;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, nejecu, dinaccion,
                      ttable, tcampo, twhere, taccion, naccion, vaccion,
                      ttarifa
                     )
              VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                      vttable, vtcampo, vtwhere, vtaccion, vctipcom, NULL,
                      0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      vpasexec := 52;
      -- borrar ESTGARANSEGCOM
      vnorden := vnorden + 1;
      vdinaccion := 'D';
      vttable := 'ESTSEGUROS';
      vtcampo := 'CTIPCOM';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion := 'DELETE ESTGARANSEGCOM WHERE SSEGURO = :SSEGURO';
      vpasexec := 72;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, nejecu, dinaccion,
                      ttable, tcampo, twhere, taccion, naccion, vaccion,
                      ttarifa
                     )
              VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                      vttable, vtcampo, vtwhere, vtaccion, vctipcom, NULL,
                      0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      IF vctipcom = 90
      THEN
         vpasexec := 53;
         -- insertar ESTCOMISIONSEGU
--         vnorden := vnorden + 1;
         vdinaccion := 'I';
         vttable := 'ESTSEGUROS';
         vtcampo := 'CTIPCOM';
         vtwhere := 'SSEGURO = :SSEGURO';
         -- Bug 30642/169851 - 20/03/2014 - AMC
         vtaccion :=
               'INSERT INTO ESTCOMISIONSEGU  SELECT :SSEGURO, CMODCOM, PCOMISI, NINIALT, NFINALT, :NMOVIMI FROM COMISIONSEGU WHERE SSEGURO='
            || vsseguro_0
            || ' AND NMOVIMI= '
            || vnmovimi_0;
         -- Fi Bug 30642/169851 - 20/03/2014 - AMC
         vpasexec := 73;
         pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject,
                                      vpasexec);

         SELECT DECODE (COUNT (*), 0, 0, 1)
           INTO vexiste
           FROM sup_acciones_dif
          WHERE cmotmov = vcmotmov
            AND sseguro = psseguro
            AND estado = 0
            AND nejecu = vnejecu
            AND DBMS_LOB.compare (taccion, vtaccion) = 0;

         --
         -- ejecución del suplemento
         --
         IF vexiste = 0
         THEN
            BEGIN
               vnorden := vnorden + 1;

               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa
                           )
                    VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                            vdinaccion, vttable, vtcampo, vtwhere, vtaccion,
                            vctipcom, NULL, 0
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
               WHEN OTHERS
               THEN
                  RAISE salir;
            END;
         END IF;
      END IF;

      IF vctipcom = 91
      THEN
         vplan := f_tiene_preg_4089 (psseguro);
         pac_log.p_log_sup_diferidos (psseguro,
                                      0,
                                      NVL (vplan, 999),
                                      vobject,
                                      vpasexec
                                     );

         FOR reg IN (SELECT *
                       FROM garansegcom
                      WHERE sseguro = vsseguro_0
                        AND (nriesgo = vplan OR vplan IS NULL)
                        AND nmovimi = pnmovimi)
         LOOP
            FOR rie IN (SELECT   nriesgo
                            FROM riesgos
                           WHERE sseguro = psseguro AND fanulac IS NULL
                        ORDER BY nriesgo)
            LOOP
               vpasexec := 54;
               -- insertar ESTGARANSEGCOM
--               vnorden := vnorden + 1;
               vdinaccion := 'U';
               vttable := 'ESTSEGUROS';
               vtcampo := 'CTIPCOM';
               vtwhere := 'SSEGURO = :SSEGURO';
               vtaccion :=
                     'INSERT INTO ESTGARANSEGCOM (SSEGURO, NRIESGO, CGARANT,NMOVIMI, '
                  || 'FINIEFE, CMODCOM, PCOMISI, CMATCH, TDESMAT, '
                  || 'PINTFIN, NINIALT, NFINALT, PCOMISICUA) VALUES ('
                  || ':SSEGURO,'
                  || rie.nriesgo
                  || ', '
                  || reg.cgarant
                  || ',:NMOVIMI, to_date('
                  || CHR (39)
                  || TO_CHAR (pfecsupl, 'yyymmdd')
                  || CHR (39)
                  || ','
                  || CHR (39)
                  || 'yyyymmdd'
                  || CHR (39)
                  || '), '
                  || reg.cmodcom
                  || ', '
                  || reg.pcomisi
                  || ', '
                  || CHR (39)
                  || 'NULL'
                  || CHR (39)
                  || ','
                  || CHR (39)
                  || 'NULL'
                  || CHR (39)
                  || ','
                  || CHR (39)
                  || 'NULL'
                  || CHR (39)
                  || ',';
               vtaccion :=
                        vtaccion || reg.ninialt || ', ' || reg.nfinalt || ', ';

               IF reg.pcomisicua IS NOT NULL
               THEN
                  vtaccion :=
                     vtaccion || CHR (39) || reg.pcomisicua || CHR (39)
                     || ') ';
               ELSE
                  vtaccion :=
                             vtaccion || CHR (39) || 'NULL' || CHR (39)
                             || ') ';
               END IF;

               vpasexec := 74;
               pac_log.p_log_sup_diferidos (psseguro,
                                            0,
                                            vtaccion,
                                            vobject,
                                            vpasexec
                                           );

               SELECT DECODE (COUNT (*), 0, 0, 1)
                 INTO vexiste
                 FROM sup_acciones_dif
                WHERE cmotmov = vcmotmov
                  AND sseguro = psseguro
                  AND estado = 0
                  AND nejecu = vnejecu
                  AND DBMS_LOB.compare (taccion, vtaccion) = 0;

               --
               -- ejecución del suplemento
               --
               IF vexiste = 0
               THEN
                  BEGIN
                     vnorden := vnorden + 1;

                     INSERT INTO sup_acciones_dif
                                 (cmotmov, sseguro, norden, estado, nejecu,
                                  dinaccion, ttable, tcampo, twhere,
                                  taccion, naccion, vaccion, ttarifa
                                 )
                          VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                                  vdinaccion, vttable, vtcampo, vtwhere,
                                  vtaccion, vctipcom, NULL, 0
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        -- Existe una programación pendiente para este tipo de suplemento diferido
                        num_err := 9001506;
                        RAISE salir;
                     WHEN OTHERS
                     THEN
                        RAISE salir;
                  END;
               END IF;
            END LOOP;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifcomisi;

   /*************************************************************************
      Realiza el diferimiento del suplemento 827 (cambio de retorno)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifretorno (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                            := 'PAC_SUP_DIFERIDOS.f_diferir_spl_modifretorno';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 827;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vsperson     estrtn_convenio.sperson%TYPE;
      vpretorno    estrtn_convenio.pretorno%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      salir        EXCEPTION;
      num_err      NUMBER;
      vplan        NUMBER;
      vexiste      NUMBER;
   BEGIN
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      --Obtenemos la persona beneficiario de retorno del certificado 0.
      BEGIN
         SELECT sperson, pretorno
           INTO vsperson, vpretorno
           FROM rtn_convenio
          WHERE sseguro = vsseguro_0 AND nmovimi = vnmovimi_0;
      EXCEPTION
         WHEN OTHERS
         THEN
            vsperson := NULL;
      END;

      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                   'Certificado 0 persona retorno:'
                                   || vsperson,
                                   vobject,
                                   vpasexec
                                  );

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;
      --
      -- borrar ESTRTN_CONVENIO
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'D';
      vttable := 'ESTRTN_CONVENIO';
      vtcampo := 'SPERSON';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
         'DELETE ESTRTN_CONVENIO WHERE SSEGURO = :SSEGURO AND NMOVIMI = :NMOVIMI';
      vpasexec := 7;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, nejecu, dinaccion,
                      ttable, tcampo, twhere, taccion, naccion, vaccion,
                      ttarifa
                     )
              VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                      vttable, vtcampo, vtwhere, vtaccion, vsperson, NULL,
                      0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      IF vsperson IS NOT NULL
      THEN
         vpasexec := 51;
         --
         -- insertar en  ESTRTN_CONVENIO
--         vnorden := vnorden + 1;
         vdinaccion := 'I';
         vttable := 'ESTRTN_CONVENIO';
         vtcampo := 'SPERSON';
         vtwhere := 'SSEGURO = :SSEGURO';
         vtaccion :=
               'INSERT INTO ESTRTN_CONVENIO (SSEGURO,SPERSON, NMOVIMI,PRETORNO) VALUES (:SSEGURO, '
            || vsperson
            || ', :NMOVIMI,'
            || vpretorno
            || ')';
         vpasexec := 71;
         pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject,
                                      vpasexec);

         SELECT DECODE (COUNT (*), 0, 0, 1)
           INTO vexiste
           FROM sup_acciones_dif
          WHERE cmotmov = vcmotmov
            AND sseguro = psseguro
            AND estado = 0
            AND nejecu = vnejecu
            AND DBMS_LOB.compare (taccion, vtaccion) = 0;

         --
         -- ejecución del suplemento
         --
         IF vexiste = 0
         THEN
            BEGIN
               vnorden := vnorden + 1;

               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa
                           )
                    VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                            vdinaccion, vttable, vtcampo, vtwhere, vtaccion,
                            vsperson, NULL, 0
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
               WHEN OTHERS
               THEN
                  RAISE salir;
            END;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifretorno;

   /*************************************************************************
      Realiza el diferimiento del suplemento 827 (cambio de retorno)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA
      param out mensajes   : Mensajes
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_modifcoacua (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                             := 'PAC_SUP_DIFERIDOS.f_diferir_spl_modifcoacua';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 938;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vsperson     estrtn_convenio.sperson%TYPE;
      vpretorno    estrtn_convenio.pretorno%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      salir        EXCEPTION;
      num_err      NUMBER;
      vplan        NUMBER;
      vctipcoa     seguros.ctipcoa%TYPE;
      vexiste      NUMBER;
   BEGIN
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      --Obtenemos el tipo de coaseguro del certificado 0.
      BEGIN
         SELECT ctipcoa
           INTO vctipcoa
           FROM seguros
          WHERE sseguro = vsseguro_0;
      EXCEPTION
         WHEN OTHERS
         THEN
            vsperson := NULL;
      END;

      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                   'Certificado 0 persona retorno:'
                                   || vctipcoa,
                                   vobject,
                                   vpasexec
                                  );

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;
      --
      -- borrar ESTRTN_CONVENIO
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := 'CTIPCOA';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET CTIPCOA='
         || vctipcoa
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 7;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, nejecu, dinaccion,
                      ttable, tcampo, twhere, taccion, naccion, vaccion,
                      ttarifa
                     )
              VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                      vttable, vtcampo, vtwhere, vtaccion, vctipcoa, NULL,
                      0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      IF vctipcoa = 1
      THEN
         vpasexec := 51;
         --
         -- cerrar el cuadro anterior
--         vnorden := vnorden + 1;
         vdinaccion := 'U';
         vttable := 'ESTCOACUADRO';
         vtcampo := 'SSEGURO';
         vtwhere := 'SSEGURO = :SSEGURO';
         vtaccion :=
               'INSERT INTO ESTCOACUADRO (SSEGURO,SPERSON, NMOVIMI,PRETORNO) VALUES (:SSEGURO, '
            || vsperson
            || ', :NMOVIMI,'
            || vpretorno
            || ')';
         vpasexec := 71;
         pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject,
                                      vpasexec);

         SELECT DECODE (COUNT (*), 0, 0, 1)
           INTO vexiste
           FROM sup_acciones_dif
          WHERE cmotmov = vcmotmov
            AND sseguro = psseguro
            AND estado = 0
            AND nejecu = vnejecu
            AND DBMS_LOB.compare (taccion, vtaccion) = 0;

         --
         -- ejecución del suplemento
         --
         IF vexiste = 0
         THEN
            BEGIN
               vnorden := vnorden + 1;

               INSERT INTO sup_acciones_dif
                           (cmotmov, sseguro, norden, estado, nejecu,
                            dinaccion, ttable, tcampo, twhere, taccion,
                            naccion, vaccion, ttarifa
                           )
                    VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu,
                            vdinaccion, vttable, vtcampo, vtwhere, vtaccion,
                            vsperson, NULL, 0
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  -- Existe una programación pendiente para este tipo de suplemento diferido
                  num_err := 9001506;
                  RAISE salir;
               WHEN OTHERS
               THEN
                  RAISE salir;
            END;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_modifcoacua;

   /*************************************************************************
      Realiza el diferimiento del suplemento 900 (prorroga vigencia)
      return               : 0 --> OK, <> 0 --> Error

      BUG 0026070 - 20/02/2013 - JMF
   *************************************************************************/
   FUNCTION f_diferir_spl_prorrogavigen (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                           := 'PAC_SUP_DIFERIDOS.f_diferir_spl_prorrogavigen';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 900;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vsperson     estrtn_convenio.sperson%TYPE;
      vpretorno    estrtn_convenio.pretorno%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      salir        EXCEPTION;
      num_err      NUMBER;
      vplan        NUMBER;
      d_fcaranu    seguros.fcaranu%TYPE;
      d_frenova    seguros.frenova%TYPE;
   BEGIN
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;

      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      SELECT NVL (MAX (norden), 0)
        INTO vnorden
        FROM sup_acciones_dif
       WHERE cmotmov = vcmotmov AND sseguro = psseguro;

      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

--      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      --Obtenemos fechas del certificado 0.
      BEGIN
         SELECT fcaranu, frenova
           INTO d_fcaranu, d_frenova
           FROM seguros
          WHERE sseguro = vsseguro_0;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_fcaranu := NULL;
            d_frenova := NULL;
      END;

      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                      'Certificado 0 fcaranu:'
                                   || TO_CHAR (d_fcaranu, 'dd-mm-yyyy')
                                   || ' frenova: '
                                   || TO_CHAR (d_frenova, 'dd-mm-yyyy'),
                                   vobject,
                                   vpasexec
                                  );

      IF vcount = 0
      THEN
         vnejecu := vnejecu + 1;

         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      END IF;

      vpasexec := 5;
      --
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := '*';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET FCARANU='
         || 'to_date('
         || CHR (39)
         || TO_CHAR (d_fcaranu, 'dd-mm-yyyy')
         || CHR (39)
         || ','
         || CHR (39)
         || 'dd-mm-yyyy'
         || CHR (39)
         || ')'
         || ', FRENOVA='
         || 'to_date('
         || CHR (39)
         || TO_CHAR (d_frenova, 'dd-mm-yyyy')
         || CHR (39)
         || ','
         || CHR (39)
         || 'dd-mm-yyyy'
         || CHR (39)
         || ')'
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 7;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, nejecu, dinaccion,
                      ttable, tcampo, twhere, taccion, naccion, vaccion,
                      ttarifa
                     )
              VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                      vttable, vtcampo, vtwhere, vtaccion, NULL, NULL,
                      0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_prorrogavigen;

   /*************************************************************************
      FUNCTION f_propaga_suplemento
      Funcion que, dado un suplemento en una poliza Colectiva (ncertif = 0),
      propaga ese suplemento (como suplemento diferido) a sus certificados
      (ncertif <> 0).
      param in psseguro  : Identificador de la poliza colectiva (ncertif = 0)
      param in pcmotmov  : codigo de movimiento del suplemento
      param in pnmovimi  : numero de movimiento del suplemento
      param in pfefecto  : fecha de efecto del suplemento
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   -- Bug 24278 - APD - 19/11/2012 - se crea la funcion
   FUNCTION f_propaga_suplemento (
      psseguro   IN   NUMBER,
      pcmotmov   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfefecto   IN   DATE
   )
      RETURN NUMBER
   IS
      vpasexec        NUMBER (8)                       := 1;
      vparam          VARCHAR2 (200)
         :=    'psseguro: '
            || psseguro
            || ',pcmotmov:'
            || pcmotmov
            || ',pnmovimi:'
            || pnmovimi
            || ',pfefecto:'
            || TO_CHAR (pfefecto, 'dd/mm/yyyy');
      vobject         VARCHAR2 (200)
                                   := 'pac_sup_diferidos.f_propaga_suplemento';
      salir           EXCEPTION;
      num_err         NUMBER;
      vsproduc        seguros.sproduc%TYPE;
      vcont           NUMBER;
      vcpropagasupl   detmovseguro.cpropagasupl%TYPE;

      CURSOR cur_motivos
      IS
         (SELECT DISTINCT a.cmotmov, a.fefecto, a.nmovimi
                     FROM (SELECT DISTINCT d.cmotmov, m.fefecto, m.nmovimi
                                      FROM detmovseguro d, movseguro m
                                     WHERE d.sseguro = m.sseguro
                                       AND d.nmovimi = m.nmovimi
                                       AND m.sseguro = psseguro
                                       AND m.nmovimi =
                                              NVL (pnmovimi,
                                                   (SELECT MAX (nmovimi)
                                                      FROM movseguro m2
                                                     WHERE m2.sseguro =
                                                                     m.sseguro
                                                       AND m2.cmovseg = 1
                                                       -- suplemento
                                                       AND m.cmotmov =
                                                              NVL (pcmotmov,
                                                                   m.cmotmov
                                                                  )
                                                       AND m.fefecto =
                                                              NVL (pfefecto,
                                                                   m.fefecto
                                                                  ))
                                                  )
                           UNION
                           SELECT DISTINCT m.cmotmov, m.fefecto, m.nmovimi
                                      FROM movseguro m
                                     WHERE m.sseguro = psseguro
                                       AND m.nmovimi =
                                              NVL (pnmovimi,
                                                   (SELECT MAX (nmovimi)
                                                      FROM movseguro m2
                                                     WHERE m2.sseguro =
                                                                     m.sseguro
                                                       AND m2.cmovseg = 1
                                                       -- suplemento
                                                       AND m.cmotmov =
                                                              NVL (pcmotmov,
                                                                   m.cmotmov
                                                                  )
                                                       AND m.fefecto =
                                                              NVL (pfefecto,
                                                                   m.fefecto
                                                                  ))
                                                  )) a);
   BEGIN
      vpasexec := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vpasexec);

      IF psseguro IS NULL
      THEN
         num_err := 103135;
         RAISE salir;
      END IF;

      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      FOR reg_mot IN cur_motivos
      LOOP
         vpasexec := 3;

         BEGIN
            SELECT DISTINCT NVL (cpropagasupl, 2)
                       INTO vcpropagasupl
                       FROM detmovseguro
                      WHERE sseguro = psseguro
                        AND nmovimi = reg_mot.nmovimi
                        AND cmotmov = reg_mot.cmotmov;
         EXCEPTION
            WHEN OTHERS
            THEN
               vcpropagasupl := 0;
         END;

         vpasexec := 4;
         pac_log.p_log_sup_diferidos
                (psseguro,
                 1,
                    'cmotmov = '
                 || reg_mot.cmotmov
                 || '; parmotmov ''PROPAGA_SUPLEMENTOS'' '
                 || NVL (pac_parametros.f_parmotmov_n (reg_mot.cmotmov,
                                                       'PROPAGA_SUPLEMENTOS',
                                                       vsproduc
                                                      ),
                         0
                        )
                 || '; vcpropagasupl = '
                 || vcpropagasupl,
                 vobject,
                 vpasexec
                );

         IF (   NVL (pac_parametros.f_parmotmov_n (reg_mot.cmotmov,
                                                   'PROPAGA_SUPLEMENTOS',
                                                   vsproduc
                                                  ),
                     0
                    ) = 1
             OR (    NVL
                        (pac_parametros.f_parmotmov_n (reg_mot.cmotmov,
                                                       'PROPAGA_SUPLEMENTOS',
                                                       vsproduc
                                                      ),
                         0
                        ) = 2
                 AND vcpropagasupl = 3
                )
            )
         THEN
            vpasexec := 5;

            FOR reg_certifs IN
               (SELECT s.sseguro, s.npoliza, s.ncertif,
                       DECODE
                          (pac_seguros.f_es_col_admin (s.sseguro, 'SEG'),
                           1, GREATEST (reg_mot.fefecto,
                                        pac_movseguro.f_get_fefecto (s.sseguro)
                                       ),
                           -- INICIO (22561 + 39258)/: MRB - 18/01/2016
                           -- s.fcaranu) fecsupl
                           -- Se subtituye por el cálculo de esta fecha para los casos que fcaranu sea nulo 18/01/2016
                           NVL (fcaranu, f_calcula_fcaranu (psseguro))
                          ) fecsupl
                  --f_calcula_fcaranu(s.sseguro)) fecsupl
                  -- FIN (22561 + 39258)/: MRB - 18/01/2016
                FROM   seguros s
                 WHERE s.npoliza IN (SELECT s2.npoliza
                                       FROM seguros s2
                                      WHERE s2.sseguro = psseguro)
                   AND s.ncertif <> 0
                   -- INICIO (22561 + 39258)/: MRB - 18/01/2016
                   -- s.creteni = 0) LOOP
                   -- Se substituye para que trate también las propuestas que están pendientes de autorización
                   -- para que en las cartera, dicho suplemento actualice las pólizas.
                   AND (   s.creteni = 0
                        OR (s.csituac = 4 AND s.creteni IN (0, 2))
                       ))
            -- FIN (22561 + 39258)/: MRB - 18/01/2016
            LOOP
               vpasexec := 6;
               pac_log.p_log_sup_diferidos (psseguro,
                                            0,
                                               'npoliza = '
                                            || reg_certifs.npoliza
                                            || '; .ncertif = '
                                            || reg_certifs.ncertif
                                            || '; fecsupl = '
                                            || TO_CHAR (reg_certifs.fecsupl,
                                                        'dd/mm/yyyy'
                                                       )
                                            || '; nmovimi = '
                                            || reg_mot.nmovimi,
                                            vobject,
                                            vpasexec
                                           );

               IF reg_mot.cmotmov = 673
               THEN
                  num_err :=
                     f_diferir_spl_modifdomictom (reg_certifs.sseguro,
                                                  reg_certifs.fecsupl,
                                                  reg_mot.nmovimi
                                                 );
               ELSIF reg_mot.cmotmov = 729
               THEN
                  num_err :=
                     f_diferir_spl_cambioreval (reg_certifs.sseguro,
                                                reg_certifs.fecsupl,
                                                reg_mot.nmovimi
                                               );
               ELSIF reg_mot.cmotmov = 825
               THEN
                  num_err :=
                     f_diferir_spl_modifcocorretaje (reg_certifs.sseguro,
                                                     reg_certifs.fecsupl,
                                                     reg_mot.nmovimi
                                                    );
               ELSIF reg_mot.cmotmov = 281
               THEN
                  num_err :=
                     f_diferir_spl_modifgarantias (reg_certifs.sseguro,
                                                   reg_certifs.fecsupl,
                                                   reg_mot.nmovimi
                                                  );
               ELSIF reg_mot.cmotmov = 288
               THEN
                  num_err :=
                     f_diferir_spl_modifclausulas (reg_certifs.sseguro,
                                                   reg_certifs.fecsupl,
                                                   reg_mot.nmovimi
                                                  );
               ELSIF reg_mot.cmotmov = 684
               THEN
                  num_err :=
                     f_diferir_spl_modifpregunpol (reg_certifs.sseguro,
                                                   reg_certifs.fecsupl,
                                                   reg_mot.nmovimi
                                                  );
               ELSIF reg_mot.cmotmov = 685
               THEN
                  num_err :=
                     f_diferir_spl_modifpregunries (reg_certifs.sseguro,
                                                    reg_certifs.fecsupl,
                                                    reg_mot.nmovimi
                                                   );
               ELSIF reg_mot.cmotmov = 225
               THEN
                  num_err :=
                     f_diferir_spl_modifoficina (reg_certifs.sseguro,
                                                 reg_certifs.fecsupl,
                                                 reg_mot.nmovimi
                                                );
               ELSIF reg_mot.cmotmov = 269
               THEN
                  num_err :=
                     f_diferir_spl_modifcforpag (reg_certifs.sseguro,
                                                 reg_certifs.fecsupl,
                                                 reg_mot.nmovimi
                                                );
               ELSIF reg_mot.cmotmov = 674
               THEN
                  num_err :=
                     f_diferir_spl_modiffefecto (reg_certifs.sseguro,
                                                 reg_certifs.fecsupl,
                                                 reg_mot.nmovimi
                                                );
               ELSIF reg_mot.cmotmov = 828
               THEN
                  num_err :=
                     f_diferir_spl_modifcomisi (reg_certifs.sseguro,
                                                reg_certifs.fecsupl,
                                                reg_mot.nmovimi
                                               );
               ELSIF reg_mot.cmotmov = 827
               THEN
                  num_err :=
                     f_diferir_spl_modifretorno (reg_certifs.sseguro,
                                                 reg_certifs.fecsupl,
                                                 reg_mot.nmovimi
                                                );
               ELSIF reg_mot.cmotmov = 938
               THEN
                  num_err :=
                     f_diferir_spl_modifcoacua (reg_certifs.sseguro,
                                                reg_certifs.fecsupl,
                                                reg_mot.nmovimi
                                               );
               ELSIF reg_mot.cmotmov = 900
               THEN                                 -- Incompatible con el 905
                  -- BUG 0026070 - 20/02/2013 - JMF
                  num_err :=
                     f_diferir_spl_prorrogavigen (reg_certifs.sseguro,
                                                  reg_certifs.fecsupl,
                                                  reg_mot.nmovimi
                                                 );
               ELSIF reg_mot.cmotmov = 905
               THEN                                 -- Incompatible con el 900
                  num_err :=
                     f_diferir_spl_renovavigen (reg_certifs.sseguro,
                                                reg_certifs.fecsupl,
                                                reg_mot.nmovimi
                                               );
               END IF;

               vpasexec := 7;

               IF num_err = 0
               THEN
                  pac_log.p_log_sup_diferidos (psseguro,
                                               0,
                                                  'f_diferir_spl cmotmov = '
                                               || reg_mot.cmotmov
                                               || ' OK',
                                               vobject,
                                               vpasexec
                                              );

                  -- si la poliza es administrada
                  IF pac_seguros.f_es_col_admin (psseguro, 'SEG') = 1
                  THEN
                     vpasexec := 8;
                     -- se actualiza el campo cestadocol = 0.-Pendiente Emitir/Pendiente generar Recibo
                     num_err :=
                        pac_movseguro.f_set_cestadocol (psseguro,
                                                        0,
                                                        reg_mot.nmovimi
                                                       );

                     IF num_err <> 0
                     THEN
                        EXIT;
                     END IF;

                     vpasexec := 9;

                     -- Si ha ido todo bien, se han podido programar todos los suplementos a los certificados,
                     -- se inserta en el historico de suplementos diferidos el certificado 0
                     BEGIN
                        SELECT COUNT (1)
                          INTO vcont
                          FROM his_sup_diferidosseg
                         WHERE cmotmov = reg_mot.cmotmov
                           AND sseguro = psseguro
                           AND nmovimi = reg_mot.nmovimi;

                        -- si no se ha insertado en el historico el certificado 0 lo insertamos
                        IF vcont = 0
                        THEN
                           INSERT INTO his_sup_diferidosseg
                                       (cmotmov, sseguro,
                                        ffinal, fecsupl, estado,
                                        nmovimi, cusuari, falta
                                       )
                                VALUES (reg_mot.cmotmov, psseguro,
                                        f_sysdate, reg_mot.fefecto, 1,
                                        reg_mot.nmovimi, f_user, f_sysdate
                                       );
                        END IF;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           NULL;
                        WHEN OTHERS
                        THEN
                           num_err := 9904632;
                           -- Error al insertar en la tabla HIS_SUP_DIFERIDOSSEG
                           p_tab_error (f_sysdate,
                                        f_user,
                                        vobject,
                                        vpasexec,
                                        vparam,
                                           f_axis_literales (num_err)
                                        || ': '
                                        || SQLCODE
                                        || '-'
                                        || SQLERRM
                                       );
                           pac_log.p_log_sup_diferidos
                                                 (psseguro,
                                                  1,
                                                     f_axis_literales (num_err)
                                                  || ': '
                                                  || SQLCODE
                                                  || '-'
                                                  || SQLERRM,
                                                  vobject,
                                                  vpasexec
                                                 );
                           EXIT;
                     END;
                  END IF;
               ELSE                                       -- num_err <> 0 THEN
                  -- si algún suplemento diferido no se ha podido programar, se para el proceso
                  EXIT;
               END IF;
            END LOOP;

            vpasexec := 10;

            IF num_err <> 0
            THEN
               -- si algún suplemento diferido no se ha podido programar, se para el proceso
               EXIT;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 11;

      IF num_err <> 0
      THEN
         RAISE salir;
      END IF;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         num_err := 9904566;
         -- Error al programar el suplemento a los certificados.
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_propaga_suplemento;

-- Bug 24278 - APD - 20/11/2012 - se crea el proceso
/*******************************************************************************
   Proceso que ejecuta los suplementos diferidos/automaticos
   pcempres PARAM IN: Empresa
   psproduc  PARAM IN : Producto
   psseguro PARAM IN : Seguro
   pfecha PARAM IN : Fecha referencia para ejecutar el suplemento
   pcommit PARAM IN: Indica si se debe realizar el commit o no (0.-No, 1.-si)
   psproces PARAM OUT : Proceso generado.
********************************************************************************/
   PROCEDURE p_ejecuta_suplemento (
      pcempres   IN       NUMBER,
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pfecha     IN       DATE,
      pnmovimi   IN       NUMBER,
      psproces   IN OUT   NUMBER
   )
   IS
      vtraza         NUMBER;
      vparam         VARCHAR2 (10000)
         :=    'pcempres = '
            || pcempres
            || '; psproduc = '
            || psproduc
            || '; psseguro = '
            || psseguro
            || '; pfecha = '
            || TO_CHAR (pfecha, 'dd/mm/yyyy')
            || '; pnmovimi = '
            || pnmovimi
            || '; psproces = '
            || psproces;
      vobject        VARCHAR2 (200)
                                   := 'pac_sup_diferidos.p_ejecuta_suplemento';
      num_err        NUMBER                     := 0;
      num_err2       NUMBER                     := 0;
      indice         NUMBER                     := 0;
      indice_error   NUMBER                     := 0;
      nprolin        NUMBER                     := NULL;
      texto          VARCHAR (4000)             := NULL;
      vsproces       procesoslin.sproces%TYPE;
      vcempres       empresas.cempres%TYPE;
      vsproduc       productos.sproduc%TYPE;
      vsseguro       seguros.sseguro%TYPE;
      vsseguro_0     seguros.sseguro%TYPE;
      vfecha         DATE;
      vnmovimi       movseguro.nmovimi%TYPE;
      vcont          NUMBER;
   BEGIN
      vtraza := 1;
      vcempres :=
         NVL (pcempres,
              NVL (pac_contexto.f_contextovalorparametro ('IAX_EMPRESA'),
                   pac_parametros.f_parinstalacion_n ('EMPRESADEF')
                  )
             );
      vtraza := 2;
      vfecha := NVL (TO_CHAR (pfecha, 'dd/mm/yyyy'), TRUNC (f_sysdate));
      vtraza := 3;

      IF pnmovimi IS NOT NULL
      THEN
         -- la fecha será la que esté programada en el suplemento diferido
         -- ya que se quiere ejecutar los suplementos a un nmovimi determinado
         vfecha := NULL;
      END IF;

      -- Si no viene informado SPROCES creamos uno
      IF psproces IS NULL
      THEN
         num_err2 :=
            f_procesini (f_user,
                         vcempres,
                            UPPER (f_axis_literales (9001641))
                         || ' '
                         || TO_CHAR (vfecha, 'yyyymmdd'),
                         f_axis_literales (9904568),
                         vsproces
                        );
      ELSE
         vsproces := psproces;
      END IF;

      vtraza := 4;

      FOR reg IN (SELECT   sup.sseguro, sup.fecsupl, sup.nmovimi, s.npoliza,
                           s.ncertif
                      FROM sup_diferidosseg sup, seguros s
                     WHERE sup.sseguro = s.sseguro
                       AND sup.nmovimi = NVL (pnmovimi, sup.nmovimi)
                       AND s.sseguro = NVL (psseguro, s.sseguro)
                       AND s.sproduc = NVL (psproduc, s.sproduc)
                       AND s.csituac = 0
                       AND s.creteni = 0                   -- polizas vigentes
                       AND sup.fecsupl <= NVL (vfecha, sup.fecsupl)
                       AND sup.estado = 0
                  GROUP BY sup.sseguro,
                           sup.fecsupl,
                           sup.nmovimi,
                           s.npoliza,
                           s.ncertif)
      LOOP
         indice := indice + 1;
         vtraza := 5;

         -- Se ejecutan los suplementos diferidos
         IF pac_sup_diferidos.f_eval_diferidos (reg.sseguro, reg.fecsupl) = 1
         THEN
            vtraza := 6;
            num_err :=
               pac_sup_diferidos.f_gen_supl_diferidos (reg.sseguro,
                                                       reg.fecsupl,
                                                       vsproces
                                                      );
            vtraza := 7;

            IF num_err <> 0
            THEN
               indice_error := indice_error + 1;
               ROLLBACK;
               texto := f_axis_literales (9904569);
               --Error al ejecutar el suplemento.
               num_err2 :=
                  f_proceslin (vsproces,
                                  texto
                               || ' ('
                               || f_axis_literales (102829)
                               || ' '
                               || TO_CHAR (reg.npoliza)
                               || '-'
                               || TO_CHAR (reg.ncertif)
                               || ')',
                               reg.sseguro,
                               nprolin,
                               1
                              );                                      -- Error
            END IF;

            vtraza := 8;
/*
            IF num_err = 0 THEN
               vtraza := 9;
               num_err := pac_dincartera.f_set_recibos_col(vsproces, reg.sseguro, reg.fecsupl,
                                                           reg.nmovimi);
               vtraza := 10;

               IF num_err <> 0 THEN
                  indice_error := indice_error + 1;
                  ROLLBACK;
                  texto := f_axis_literales(9904570);   --Error al insertar los recibos de las pólizas colectivas.
                  num_err2 := f_proceslin(vsproces,
                                          texto || ' (' || f_axis_literales(102829) || ' '
                                          || TO_CHAR(reg.npoliza) || '-'
                                          || TO_CHAR(reg.ncertif) || ')',
                                          reg.sseguro, nprolin, 1);   -- Error
               END IF;
            END IF;
*/
         END IF;

         vtraza := 11;

         IF num_err = 0
         THEN
            vtraza := 12;

            -- Se ejecutan los suplementos automaticos
            IF pac_sup_diferidos.f_eval_automaticos (reg.sseguro) = 1
            THEN
               vtraza := 13;
               num_err :=
                  pac_sup_diferidos.f_gen_supl_automaticos (reg.sseguro,
                                                            reg.fecsupl,
                                                            vsproces
                                                           );
               vtraza := 14;

               IF num_err <> 0 AND num_err <> 9901538
               THEN
                  indice_error := indice_error + 1;
                  ROLLBACK;
                  texto := f_axis_literales (9904569);
                  --Error al ejecutar el suplemento.
                  num_err2 :=
                     f_proceslin (vsproces,
                                     texto
                                  || ' ('
                                  || f_axis_literales (102829)
                                  || ' '
                                  || TO_CHAR (reg.npoliza)
                                  || '-'
                                  || TO_CHAR (reg.ncertif)
                                  || ')',
                                  reg.sseguro,
                                  nprolin,
                                  1
                                 );                                   -- Error
               END IF;

               vtraza := 15;
/*
               IF num_err = 0 THEN
                  vtraza := 16;
                  num_err := pac_dincartera.f_set_recibos_col(vsproces, reg.sseguro,
                                                              reg.fecsupl, reg.nmovimi);
                  vtraza := 17;

                  IF num_err <> 0 THEN
                     indice_error := indice_error + 1;
                     ROLLBACK;
                     texto := f_axis_literales(9904570);   --Error al insertar los recibos de las pólizas colectivas.
                     num_err2 := f_proceslin(vsproces,
                                             texto || ' (' || f_axis_literales(102829) || ' '
                                             || TO_CHAR(reg.npoliza) || '-'
                                             || TO_CHAR(reg.ncertif) || ')',
                                             reg.sseguro, nprolin, 1);   -- Error
                  END IF;
               END IF;
*/
            END IF;
         END IF;

         vtraza := 18;

         -- Todo Ok
         IF num_err = 0
         THEN
            vtraza := 19;
            texto := f_axis_literales (9904571);
            -- Suplemento ejecutado correctamente.
            num_err2 :=
               f_proceslin (vsproces,
                               texto
                            || ' ('
                            || f_axis_literales (102829)
                            || ' '
                            || TO_CHAR (reg.npoliza)
                            || '-'
                            || TO_CHAR (reg.ncertif)
                            || ')',
                            reg.sseguro,
                            nprolin,
                            4
                           );                                      -- Correcto
            COMMIT;
         ELSE                                         -- Ha habido algún error
            vtraza := 20;

            IF pac_seguros.f_es_col_admin (reg.sseguro, 'SEG') = 1
            THEN
               vtraza := 21;

               SELECT sseguro
                 INTO vsseguro_0
                 FROM seguros
                WHERE npoliza = (SELECT s2.npoliza
                                   FROM seguros s2
                                  WHERE s2.sseguro = reg.sseguro)
                  AND ncertif = 0;

               vtraza := 22;

               UPDATE movseguro
                  SET cestadocol = 2                            -- con errores
                WHERE sseguro = vsseguro_0 AND nmovimi = reg.nmovimi;

               vtraza := 23;
               COMMIT;
            END IF;
         END IF;
      END LOOP;

      vtraza := 24;

      FOR reg_col IN (SELECT m.sseguro, m.nmovimi, s.npoliza, s.ncertif
                        FROM movseguro m, seguros s
                       WHERE s.sseguro = m.sseguro
                         AND m.cestadocol IN (0, 2)
                         AND s.npoliza IN (
                                  SELECT s2.npoliza
                                    FROM seguros s2
                                   WHERE s2.sseguro =
                                                     NVL (psseguro, s.sseguro))
                         AND s.ncertif = 0
                         AND s.sproduc = NVL (psproduc, s.sproduc)
                         AND pac_seguros.f_es_col_admin (s.sseguro, 'SEG') = 1
                         AND m.nmovimi = NVL (pnmovimi, m.nmovimi)
                         AND m.fefecto <= NVL (vfecha, m.fefecto))
      LOOP
         vtraza := 25;

         -- Para las polizas administradas, mirar si todos los suplementos de
         -- los ncertifs de un colectivo se han ejecutado correctamete (no
         --  hay ninguno en estado pendiente)
         -- NO tener en cuenta las polizas en estado anuladas o vencidas que tienen
         -- suplementos diferidos programados
         -- ¡Ojo! Misma select que en f_ejecuta_supl_certifs
         SELECT COUNT (*)
           INTO vcont
           FROM sup_diferidosseg sup, seguros s
          WHERE sup.sseguro = s.sseguro
            AND s.npoliza IN (SELECT s2.npoliza
                                FROM seguros s2
                               WHERE s2.sseguro = reg_col.sseguro)
            AND s.ncertif <> 0
            AND s.csituac NOT IN (2, 3)                    -- anulado, vencido
            AND sup.nmovimi = reg_col.nmovimi
            AND sup.estado = 0;

         vtraza := 26;

         -- si vcont <> 0 --> todavía quedan suplementos por ejecutar --> NO CONTINUAR
         -- si vcont = 0 --> se han ejecutado correctamente todos los suplemetos
         IF vcont = 0
         THEN
            vtraza := 27;
/*
            -- Se agrupan los recibos generados en los suplementos
            num_err := pac_dincartera.f_agruparecibos(vsproces, reg_col.sseguro);
            vtraza := 28;

            IF num_err <> 0 THEN
               indice_error := indice_error + 1;
               ROLLBACK;
               texto := f_axis_literales(9904572);   -- Error al agrupar recibos.
               num_err2 := f_proceslin(vsproces,
                                       texto || ' (' || f_axis_literales(102829) || ' '
                                       || TO_CHAR(reg_col.npoliza) || '-'
                                       || TO_CHAR(reg_col.ncertif) || ')',
                                       reg_col.sseguro, nprolin, 1);   -- Error
            END IF;
*/
            vtraza := 29;

            IF num_err = 0
            THEN
               vtraza := 30;

               UPDATE movseguro
                  SET cestadocol = 1                                -- todo ok
                WHERE sseguro = reg_col.sseguro AND nmovimi = reg_col.nmovimi;
/*
            ELSE
               vtraza := 31;

               UPDATE movseguro
                  SET cestadocol = 2   -- con errores
                WHERE sseguro = reg_col.sseguro
                  AND nmovimi = reg_col.nmovimi;
*/
            END IF;

            COMMIT;
         ELSE
            vtraza := 32;
            indice_error := indice_error + 1;
            ROLLBACK;
            texto := f_axis_literales (9904573);
            --No todos los suplementos se han ejecutado. Existen suplementos pendientes.
            num_err2 :=
               f_proceslin (vsproces,
                               texto
                            || ' ('
                            || f_axis_literales (102829)
                            || ' '
                            || TO_CHAR (reg_col.npoliza)
                            || '-'
                            || TO_CHAR (reg_col.ncertif)
                            || ')',
                            reg_col.sseguro,
                            nprolin,
                            2
                           );                                         -- Aviso
         END IF;
      END LOOP;

      vtraza := 33;

      IF psproces IS NULL
      THEN
         IF indice_error = 0
         THEN
            texto := f_axis_literales (9904574);
         -- Proceso terminado correctamente.
         ELSE
            texto := f_axis_literales (9904575);
         -- Proceso terminado con errores.
         END IF;

         num_err2 := f_proceslin (vsproces, texto, 0, nprolin, 4); -- Correcto
         num_err2 := f_procesfin (vsproces, indice_error);
      ELSE
         psproces := vsproces;
      END IF;

      vtraza := 34;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vtraza, vparam, SQLERRM);
   END p_ejecuta_suplemento;

-- Bug 24278 - APD - 03/11/2012 - se crea la funcion
/*******************************************************************************
   Funcion que ejecuta los suplementos diferidos/automaticos programados para
   un colectivo para un movimiento determinado
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   psproces PARAM OUT : Proceso generado.
********************************************************************************/
   FUNCTION f_ejecuta_supl_certifs (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      psproces   IN OUT   NUMBER
   )
      RETURN NUMBER
   IS
      vtraza           NUMBER;
      vparam           VARCHAR2 (10000)
         :=    'psseguro = '
            || psseguro
            || '; pnmovimi = '
            || pnmovimi
            || '; psproces = '
            || psproces;
      vobject          VARCHAR2 (200)
                                 := 'pac_sup_diferidos.f_ejecuta_supl_certifs';
      num_err          NUMBER;
      num_err2         NUMBER;
      indice           NUMBER                      := 0;
      indice_error     NUMBER                      := 0;
      nprolin          NUMBER                      := NULL;
      texto            VARCHAR (4000)              := NULL;
      v_es_col_admin   NUMBER;
      vsproces         procesoslin.sproces%TYPE;
      vsproduc         productos.sproduc%TYPE;
      vcempres         empresas.cempres%TYPE;
      vnmovimi         movseguro.nmovimi%TYPE;
      vnmovimi_ant     movseguro.nmovimi%TYPE;
      vnpoliza         seguros.npoliza%TYPE;
      vncertif         seguros.ncertif%TYPE;
      vcestadocol      movseguro.cestadocol%TYPE;
      salir            EXCEPTION;
   BEGIN
      vtraza := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vtraza);

      -- Si es el certificado 0
      IF pac_seguros.f_get_escertifcero (NULL, psseguro) = 1
      THEN
         -- poliza administrada si f_es_col_admin = 1
         v_es_col_admin := pac_seguros.f_es_col_admin (psseguro, 'SEG');

         -- De momento sólo se deja ejecutar la funcion para administrados
         IF v_es_col_admin = 1
         THEN
            vtraza := 2;

            SELECT sproduc, cempres, npoliza, ncertif
              INTO vsproduc, vcempres, vnpoliza, vncertif
              FROM seguros
             WHERE sseguro = psseguro;

            vtraza := 3;

            -- Si no viene informado SPROCES creamos uno
            IF psproces IS NULL
            THEN
               num_err2 :=
                  f_procesini (f_user,
                               vcempres,
                                  UPPER (f_axis_literales (9001641))
                               || ' '
                               || TO_CHAR (f_sysdate, 'yyyymmdd'),
                               f_axis_literales (9904568),
                               vsproces
                              );
            ELSE
               vsproces := psproces;
            END IF;

            vtraza := 4;

            IF pnmovimi IS NULL
            THEN
               -- Si pnmovimi es NULL es el caso que se está emitiendo el suplemento del 0 desde
               -- pantalla.
               -- Una vez emitido el suplemento del 0, se crea el suplemento 670
               -- (pac_md_produccion.f_abrir_suplemento) y después es cuando se ejecutan los
               -- suplementos de los certificados (se debe crear el suplemento 670 ya que
               -- sino no dejaba ejecutar los suplementos, debido a que el certificado 0 debe
               -- estar a csitauc = 5).
               -- Una vez ejecutados los suplementos diferidos se debe llamar a la funcion
               -- pac_iax_produccion.f_emitir_col_admin
               vtraza := 5;

               -- Movimiento actual (será el del suplemento que se ha abierto automaticamente al 0
               -- para poder ejecutar los suplementos diferidos programados a los ncertifs)
               SELECT MAX (nmovimi)
                 INTO vnmovimi
                 FROM movseguro
                WHERE sseguro = psseguro;

               vtraza := 6;

               IF v_es_col_admin = 1
               THEN
                  -- Movimiento anterior (será el que tiene el suplemento que se acaba de hacer al 0)
                  -- se busca el ultimo movimiento del certificado 0
                  SELECT MAX (nmovimi)
                    INTO vnmovimi_ant
                    FROM movseguro
                   WHERE sseguro = psseguro
                     AND nmovimi < vnmovimi
                     AND cmovseg NOT IN (6, 52);

                  vtraza := 7;

                  -- Se le cambia el nmovimi a los suplementos diferidos programados por
                  -- el ultimo movimiento que tiene el ncertif 0
                  UPDATE sup_diferidosseg
                     SET nmovimi = vnmovimi
                   WHERE sseguro IN (
                                 SELECT s.sseguro
                                   FROM seguros s
                                  WHERE s.npoliza = vnpoliza
                                        AND s.ncertif <> 0)
                     AND nmovimi = vnmovimi_ant;

                  vtraza := 8;

                  SELECT cestadocol
                    INTO vcestadocol
                    FROM movseguro
                   WHERE sseguro = psseguro AND nmovimi = vnmovimi_ant;

                  num_err :=
                     pac_movseguro.f_set_cestadocol (psseguro,
                                                     vcestadocol,
                                                     vnmovimi
                                                    );

                  IF num_err <> 0
                  THEN
                     RAISE salir;
                  END IF;

                  vtraza := 9;
                  num_err :=
                     pac_movseguro.f_set_cestadocol (psseguro, 1,
                                                     vnmovimi_ant);

                  IF num_err <> 0
                  THEN
                     RAISE salir;
                  END IF;
               END IF;
            ELSE
               -- Si pnmovimi es NOT NULL es el caso que se quiere ejecutar los suplementos
               -- de los certificados para un determinado nmovimi
               vtraza := 10;
               vnmovimi := pnmovimi;
            END IF;

            -- ejecutar todos los suplementos propagados a los certificados del colectivo
            -- para un movimiento determinado del 0
            FOR reg IN (SELECT sup.sseguro, sup.fecsupl, sup.nmovimi,
                               s.npoliza, s.ncertif
                          FROM sup_diferidosseg sup, seguros s
                         WHERE sup.sseguro = s.sseguro
                           AND sup.nmovimi = vnmovimi
                           AND s.npoliza IN (SELECT s2.npoliza
                                               FROM seguros s2
                                              WHERE s2.sseguro = psseguro)
                           AND s.ncertif <> 0
                           AND s.csituac = 0
                           AND s.creteni = 0               -- polizas vigentes
                           AND sup.estado = 0)
            LOOP
               vtraza := 11;
               indice := indice + 1;
               vtraza := 12;

               -- Se ejecutan los suplementos diferidos
               IF pac_sup_diferidos.f_eval_diferidos (reg.sseguro,
                                                      reg.fecsupl
                                                     ) = 1
               THEN
                  vtraza := 13;
                  num_err :=
                     pac_sup_diferidos.f_gen_supl_diferidos (reg.sseguro,
                                                             reg.fecsupl,
                                                             vsproces
                                                            );
                  vtraza := 14;

                  IF num_err <> 0
                  THEN
                     indice_error := indice_error + 1;
                  END IF;

                  vtraza := 15;
               END IF;

               vtraza := 16;

               IF num_err = 0
               THEN
                  vtraza := 17;

                  -- Se ejecutan los suplementos automaticos
                  IF pac_sup_diferidos.f_eval_automaticos (reg.sseguro) = 1
                  THEN
                     vtraza := 18;
                     num_err :=
                        pac_sup_diferidos.f_gen_supl_automaticos
                                                                (reg.sseguro,
                                                                 reg.fecsupl,
                                                                 vsproces
                                                                );
                     vtraza := 19;

                     IF num_err <> 0 AND num_err <> 9901538
                     THEN
                        indice_error := indice_error + 1;
                     END IF;

                     vtraza := 20;
                  END IF;
               END IF;

               vtraza := 21;

               -- Todo Ok
               -- BUG 32488/0188508 - FAL - 30/09/2014 -- Evita que si da error al diferir a un certificado, no ponga como erroneos en procesoslin los siguientes certificados que se difieren correctamente
               -- IF indice_error = 0 THEN
               IF num_err = 0
               THEN
                  -- FI BUG 32488/0188508 - FAL - 30/09/2014
                  COMMIT;
                  vtraza := 22;
                  texto := f_axis_literales (9904571);
                  -- Suplemento ejecutado correctamente.
                  num_err2 :=
                     f_proceslin (vsproces,
                                     texto
                                  || ' ('
                                  || f_axis_literales (102829)
                                  || ' '
                                  || TO_CHAR (reg.npoliza)
                                  || '-'
                                  || TO_CHAR (reg.ncertif)
                                  || ')',
                                  reg.sseguro,
                                  nprolin,
                                  4
                                 );                                -- Correcto
               ELSE                                   -- Ha habido algún error
                  vtraza := 23;
                  ROLLBACK;
                  texto := f_axis_literales (9904569);
                  --Error al ejecutar el suplemento.
                  num_err2 :=
                     f_proceslin (vsproces,
                                     texto
                                  || ' ('
                                  || f_axis_literales (102829)
                                  || ' '
                                  || TO_CHAR (reg.npoliza)
                                  || '-'
                                  || TO_CHAR (reg.ncertif)
                                  || ')',
                                  reg.sseguro,
                                  nprolin,
                                  1
                                 );                                   -- Error
               END IF;
            END LOOP;

            vtraza := 8;

            IF indice_error = 0
            THEN
               IF v_es_col_admin = 1
               THEN
                  -- si todo ha ido bien, lo dejamos en estado pendiente por si previamente
                  -- había dado error y que se pueda continuar ahora con la emisión del
                  -- suplemento del 0
                  num_err :=
                       pac_movseguro.f_set_cestadocol (psseguro, 0, vnmovimi);

                  IF num_err <> 0
                  THEN
                     RAISE salir;
                  END IF;
               END IF;

               vtraza := 25;
               COMMIT;
            ELSE
               IF v_es_col_admin = 1
               THEN
                  -- con errores
                  num_err :=
                       pac_movseguro.f_set_cestadocol (psseguro, 2, vnmovimi);

                  IF num_err <> 0
                  THEN
                     RAISE salir;
                  END IF;
               END IF;

               vtraza := 25;
               COMMIT;
               texto := f_axis_literales (9904573);
               --No todos los suplementos se han ejecutado. Existen suplementos pendientes.
               num_err2 :=
                  f_proceslin (vsproces,
                                  texto
                               || ' ('
                               || f_axis_literales (102829)
                               || ' '
                               || TO_CHAR (vnpoliza)
                               || '-'
                               || TO_CHAR (vncertif)
                               || ')',
                               psseguro,
                               nprolin,
                               2
                              );                                      -- Aviso
            END IF;

            IF psproces IS NULL
            THEN
               vtraza := 26;

               IF indice_error = 0
               THEN
                  texto := f_axis_literales (9904574);
               -- Proceso terminado correctamente.
               ELSE
                  texto := f_axis_literales (9904575);
               -- Proceso terminado con errores.
               END IF;

               vtraza := 27;
               num_err2 := f_proceslin (vsproces, texto, 0, nprolin, 4);
               -- Correcto
               num_err2 := f_procesfin (vsproces, indice_error);
            ELSE
               vtraza := 28;
               psproces := vsproces;
            END IF;

            vtraza := 29;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vtraza,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vtraza
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate, f_user, vobject, vtraza, vparam, SQLERRM);
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vtraza
                                     );
         RETURN 1000455;
   END f_ejecuta_supl_certifs;

   -- Bug 24278 - APD - 10/12/2012 - se crea la funcion
/*******************************************************************************
   Funcion que pregunta si se existe algun suplemento que se debe propagar
   ptablas PARAM IN : EST o REA
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   pcvalpar PARAM IN : Valor del parmotmov
   pcmotmov PARAM IN : Motivo
   pcidioma PARAM IN : Idioma
   opropaga PARAM OUT: 0.-No se propaga ningún suplemento
                       1.-Si se propaga algún suplemento
   otexto PARAM OUT : Texto de la pregunta que se le realiza al usuario
                      (solo para el caso cvalpar = 2)
********************************************************************************/
   FUNCTION f_pregunta_propaga_suplemento (
      ptablas    IN       VARCHAR2,
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pcidioma   IN       NUMBER,
      opropaga   OUT      NUMBER,
      otexto     OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vtraza     NUMBER;
      vparam     VARCHAR2 (10000)
         :=    'ptablas = '
            || ptablas
            || 'psseguro = '
            || psseguro
            || '; pnmovimi = '
            || pnmovimi
            || '; pcmotmov = '
            || pcmotmov;
      vobject    VARCHAR2 (200)
                          := 'pac_sup_diferidos.f_pregunta_propaga_suplemento';
      num_err    NUMBER;
      salir      EXCEPTION;
      vmotivos   VARCHAR2 (10000);
      vpropaga   NUMBER                 := 0;
      vtexto     VARCHAR2 (10000)       := NULL;
      vcont      NUMBER                 := 0;
      vsproduc   seguros.sproduc%TYPE;
   BEGIN
      vtraza := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vtraza);

      IF psseguro IS NULL
      THEN
         num_err := 103135;
         RAISE salir;
      END IF;

      IF NVL (ptablas, 'EST') = 'EST'
      THEN
         vtraza := 2;

         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         IF NVL (f_parproductos_v (vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         THEN
            SELECT COUNT (*)
              INTO vcont
              FROM estseguros
             WHERE sseguro = psseguro AND ncertif = 0;
         END IF;
      ELSE
         vtraza := 3;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         IF NVL (f_parproductos_v (vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         THEN
            SELECT COUNT (*)
              INTO vcont
              FROM seguros
             WHERE sseguro = psseguro AND ncertif = 0;
         END IF;
      END IF;

      vtraza := 4;

      -- Si el producto Admite certifiados y es el ncertif = 0
      IF vcont <> 0
      THEN
         vtraza := 5;

         FOR reg IN
            (SELECT DISTINCT d.cmotmov, mm.tmotmov,
                             NVL
                                (pac_parametros.f_parmotmov_n
                                                       (d.cmotmov,
                                                        'PROPAGA_SUPLEMENTOS',
                                                        s.sproduc
                                                       ),
                                 0
                                ) cvalpar
                        FROM estseguros s, estdetmovseguro d, motmovseg mm
                       WHERE s.sseguro = d.sseguro
                         AND d.cmotmov = mm.cmotmov
                         AND mm.cidioma = pcidioma
                         AND s.sseguro = psseguro
                         AND d.nmovimi =
                                NVL (pnmovimi,
                                     (SELECT MAX (d2.nmovimi)
                                        FROM estdetmovseguro d2
                                       WHERE d.sseguro = d2.sseguro))
                         AND d.cmotmov = NVL (pcmotmov, d.cmotmov)
                         AND NVL (ptablas, 'EST') = 'EST'
             UNION
             SELECT DISTINCT d.cmotmov, mm.tmotmov,
                             NVL
                                (pac_parametros.f_parmotmov_n
                                                       (d.cmotmov,
                                                        'PROPAGA_SUPLEMENTOS',
                                                        s.sproduc
                                                       ),
                                 0
                                ) cvalpar
                        FROM seguros s,
                             movseguro m,
                             detmovseguro d,
                             motmovseg mm
                       WHERE s.sseguro = m.sseguro
                         AND m.sseguro = d.sseguro
                         AND m.nmovimi = d.nmovimi
                         AND d.cmotmov = mm.cmotmov
                         AND mm.cidioma = pcidioma
                         AND s.sseguro = psseguro
                         AND m.nmovimi =
                                NVL (pnmovimi,
                                     (SELECT MAX (m2.nmovimi)
                                        FROM movseguro m2
                                       WHERE m.sseguro = m2.sseguro))
                         AND d.cmotmov = NVL (pcmotmov, d.cmotmov)
                         AND NVL (ptablas, 'EST') = 'POL')
         LOOP
            vtraza := 6;

            IF reg.cvalpar = 0
            THEN
               NULL;
            -- no se actualiza el vpropaga ya que por defecto ya es 0
            ELSIF reg.cvalpar = 1
            THEN
               vpropaga := 1;
            ELSIF reg.cvalpar = 2
            THEN
               vpropaga := 1;

               IF vmotivos IS NULL
               THEN
                  vmotivos := CHR (13) || '- ' || reg.tmotmov || CHR (13);
               ELSE
                  vmotivos := vmotivos || '- ' || reg.tmotmov || CHR (13);
               END IF;
            END IF;
         END LOOP;

         vtraza := 7;

         IF vmotivos IS NOT NULL
         THEN
            vtexto := f_axis_literales (9904613, pcidioma);
            vtexto := vtexto || vmotivos;
         END IF;
      END IF;

      vtraza := 8;
      opropaga := vpropaga;
      otexto := vtexto;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vtraza,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vtraza
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vtraza, vparam, SQLERRM);
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vtraza
                                     );
         RETURN 1000455;
   END f_pregunta_propaga_suplemento;

-- Bug 24278 - APD - 11/12/2012 - se crea la funcion
/*******************************************************************************
   Funcion que actualiza el valor del campo detmovseguro.cpropagasupl
   ptablas PARAM IN : EST o REA
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   pcmotmov PARAM IN : Motivo
   pcpropagasupl PARAM IN : Valor que indica si se propaga el suplemento a sus certificado
                            en funcion de la decision del usuario
********************************************************************************/
   FUNCTION f_set_propaga_suplemento (
      ptablas         IN   VARCHAR2,
      psseguro        IN   NUMBER,
      pnmovimi        IN   NUMBER,
      pcmotmov        IN   NUMBER,
      pcpropagasupl   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vtraza          NUMBER;
      vparam          VARCHAR2 (10000)
         :=    'ptablas = '
            || ptablas
            || 'psseguro = '
            || psseguro
            || '; pnmovimi = '
            || pnmovimi
            || '; pcmotmov = '
            || pcmotmov
            || '; pcpropagasupl = '
            || pcpropagasupl;
      vobject         VARCHAR2 (200)
                               := 'pac_sup_diferidos.f_set_propaga_suplemento';
      num_err         NUMBER;
      salir           EXCEPTION;
      vcpropagasupl   detmovseguro.cpropagasupl%TYPE;
      vcont           NUMBER                           := 0;
      vsproduc        seguros.sproduc%TYPE;
   BEGIN
      vtraza := 1;
      pac_log.p_log_sup_diferidos (psseguro, 0, vparam, vobject, vtraza);

      IF psseguro IS NULL
      THEN
         num_err := 103135;
         RAISE salir;
      END IF;

      vtraza := 2;

      IF NVL (ptablas, 'EST') = 'EST'
      THEN
         vtraza := 3;

         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         IF NVL (f_parproductos_v (vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         THEN
            SELECT COUNT (*)
              INTO vcont
              FROM estseguros
             WHERE sseguro = psseguro AND ncertif = 0;
         END IF;
      ELSE
         vtraza := 4;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         IF NVL (f_parproductos_v (vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         THEN
            SELECT COUNT (*)
              INTO vcont
              FROM seguros
             WHERE sseguro = psseguro AND ncertif = 0;
         END IF;
      END IF;

      vtraza := 5;

      -- Si el producto Admite certifiados y es el ncertif = 0
      IF vcont <> 0
      THEN
         vtraza := 6;

         IF NVL (ptablas, 'EST') = 'EST'
         THEN
            vtraza := 7;

            FOR reg IN
               (SELECT d.sseguro, d.nmovimi, d.cmotmov, d.nriesgo, d.cgarant,
                       d.cpregun,
                       NVL
                          (pac_parametros.f_parmotmov_n
                                                       (d.cmotmov,
                                                        'PROPAGA_SUPLEMENTOS',
                                                        s.sproduc
                                                       ),
                           -1
                          ) cvalpar
                  FROM estseguros s, estdetmovseguro d
                 WHERE s.sseguro = d.sseguro
                   AND s.sseguro = psseguro
                   AND d.nmovimi =
                                NVL (pnmovimi,
                                     (SELECT MAX (d2.nmovimi)
                                        FROM estdetmovseguro d2
                                       WHERE d.sseguro = d2.sseguro))
                   AND d.cmotmov = NVL (pcmotmov, d.cmotmov))
            LOOP
               vtraza := 8;

               IF reg.cvalpar = -1
               THEN
                  vcpropagasupl := NULL;
               ELSIF reg.cvalpar = 0
               THEN
                  -- No (automatico)
                  vcpropagasupl := 0;                            -- v.f. 1115
               ELSIF reg.cvalpar = 1
               THEN
                  -- Si (automatico)
                  vcpropagasupl := 1;                            -- v.f. 1115
               ELSIF reg.cvalpar = 2
               THEN
                  -- Si, con aceptacion pregunta
                  IF NVL (pcpropagasupl, 0) = 0
                  THEN                                                  -- No
                     vcpropagasupl := 2;                         -- v.f. 1115
                  ELSIF NVL (pcpropagasupl, 0) = 1
                  THEN                                                   -- Si
                     vcpropagasupl := 3;                         -- v.f. 1115
                  END IF;
               END IF;

               vtraza := 9;

               UPDATE estdetmovseguro
                  SET cpropagasupl = vcpropagasupl
                WHERE sseguro = reg.sseguro
                  AND nmovimi = reg.nmovimi
                  AND cmotmov = reg.cmotmov
                  AND nriesgo = reg.nriesgo
                  AND cgarant = reg.cgarant
                  AND cpregun = reg.cpregun;
            END LOOP;
         ELSE
            vtraza := 10;

            FOR reg IN
               (SELECT d.sseguro, d.nmovimi, d.cmotmov, d.nriesgo, d.cgarant,
                       d.cpregun,
                       NVL
                          (pac_parametros.f_parmotmov_n
                                                       (d.cmotmov,
                                                        'PROPAGA_SUPLEMENTOS',
                                                        s.sproduc
                                                       ),
                           -1
                          ) cvalpar
                  FROM seguros s, movseguro m, detmovseguro d
                 WHERE s.sseguro = m.sseguro
                   AND m.sseguro = d.sseguro
                   AND m.nmovimi = d.nmovimi
                   AND s.sseguro = psseguro
                   AND m.nmovimi =
                                NVL (pnmovimi,
                                     (SELECT MAX (m2.nmovimi)
                                        FROM movseguro m2
                                       WHERE m.sseguro = m2.sseguro))
                   AND d.cmotmov = NVL (pcmotmov, d.cmotmov))
            LOOP
               vtraza := 11;

               IF reg.cvalpar = -1
               THEN
                  vcpropagasupl := NULL;
               ELSIF reg.cvalpar = 0
               THEN
                  -- No (automatico)
                  vcpropagasupl := 0;                            -- v.f. 1115
               ELSIF reg.cvalpar = 1
               THEN
                  -- Si (automatico)
                  vcpropagasupl := 1;                            -- v.f. 1115
               ELSIF reg.cvalpar = 2
               THEN
                  -- Si, con aceptacion pregunta
                  IF NVL (pcpropagasupl, 0) = 0
                  THEN                                                  -- No
                     -- No (manual)
                     vcpropagasupl := 2;                         -- v.f. 1115
                  ELSIF NVL (pcpropagasupl, 0) = 1
                  THEN                                                   -- Si
                     -- Si (manual)
                     vcpropagasupl := 3;                         -- v.f. 1115
                  END IF;
               END IF;

               vtraza := 12;

               UPDATE detmovseguro
                  SET cpropagasupl = vcpropagasupl
                WHERE sseguro = reg.sseguro
                  AND nmovimi = reg.nmovimi
                  AND cmotmov = reg.cmotmov
                  AND nriesgo = reg.nriesgo
                  AND cgarant = reg.cgarant
                  AND cpregun = reg.cpregun;
            END LOOP;
         END IF;
      END IF;

      vtraza := 13;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vtraza,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vtraza
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vtraza, vparam, SQLERRM);
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vtraza
                                     );
         RETURN 1000455;
   END f_set_propaga_suplemento;

-- Bug 24278 - JMC - 04/01/2013 - se crea las funciones
/*******************************************************************************
   Funcion que es una adaptación de PK_NUEVA_PRODUCCION.f_valida_dependencias_k,
   se utiliza en el suplemento diferido de cambio de garantias, para calcular los
   capitales dependientes.
   psseguro PARAM IN : Seguro
   pnriesgo PARAM IN : Nº de riesgo
   pnmovimi PARAM IN : Movimiento del suplemento
   pcgarant PARAM IN : Código de garantia
   psproduc PARAM IN : Código producto
   pcactivi PARAM IN : Código actividad
   pnmovima PARAM IN : Número de movimiento del alta
********************************************************************************/
   FUNCTION f_sup_dif_valida_dependencias (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER,
      psproduc   IN   NUMBER,
      pcactivi   IN   NUMBER,
      pnmovima   IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      garpro                garanpro%ROWTYPE;
      estgar                estgaranseg%ROWTYPE;
      capital_principal     estgaranseg.icapital%TYPE;
      capital_dependiente   estgaranseg.icapital%TYPE;
      capital               estgaranseg.icapital%TYPE;
      capmax                NUMBER;
      vcapmin               NUMBER;     -- Fin Bug 0026501 - MMS - 16/04/2013
   BEGIN
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc AND cactivi = pcactivi
                AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc AND cactivi = 0 AND cgarant = pcgarant;
      END;

      SELECT *
        INTO estgar
        FROM estgaranseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND nmovima = pnmovima
         AND cgarant = pcgarant;

      capital := estgar.icapital;

      IF garpro.ctipcap = 3 AND garpro.cgardep IS NOT NULL
      THEN
         SELECT NVL (icapital, 0)
           INTO capital_principal
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = garpro.cgardep;

         capital_dependiente :=
                            capital_principal
                            * (NVL (garpro.pcapdep, 0) / 100);
         capmax :=
            pk_nueva_produccion.f_capital_maximo_garantia (psproduc,
                                                           pcactivi,
                                                           pcgarant,
                                                           psseguro,
                                                           pnriesgo,
                                                           pnmovimi,
                                                           pnmovima
                                                          );
         -- Bug.14322:ASN:28/04/2010
         vcapmin :=
            pk_nueva_produccion.f_capital_minimo_garantia (psproduc,
                                                           pcactivi,
                                                           pcgarant,
                                                           psseguro,
                                                           pnriesgo,
                                                           pnmovimi
                                                          );
         -- Fin Bug 0026501 - MMS - 16/04/2013
         capital :=
            LEAST (GREATEST (capital_dependiente, NVL (vcapmin, 0)),
                   -- Fin Bug 0025584 - MMS - 16/04/2013
                   NVL (capmax,
                        GREATEST (capital_dependiente, NVL (vcapmin, 0))
                       )
                  );
      ELSIF garpro.ctipcap = 6 AND garpro.cgardep IS NOT NULL
      THEN
         SELECT NVL (icapital, 0)
           INTO capital_principal
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = garpro.cgardep;

         capital_dependiente :=
                      NVL (capital_principal, 0)
                    * (NVL (garpro.pcapdep, 0) / 100);
         capmax :=
            pk_nueva_produccion.f_capital_maximo_garantia (psproduc,
                                                           pcactivi,
                                                           pcgarant,
                                                           psseguro,
                                                           pnriesgo,
                                                           pnmovimi,
                                                           pnmovima
                                                          );

         -- Bug.14322:ASN:28/04/2010

         -- BUG9216:DRA:23-02-2009:Analizamos el capital máximo i minimo
         IF NVL (estgar.icapital, 0) = 0
         THEN
            capital_dependiente :=
                     NVL (capital_principal, 0)
                   * (NVL (garpro.pcapdep, 0) / 100);

            IF (capital_dependiente > capmax) AND (capmax IS NOT NULL)
            THEN
               capital := capmax;
            ELSIF     (capital_dependiente < vcapmin
                      )                      -- Bug 0026501 - MMS - 16/04/2013
                  AND (vcapmin IS NOT NULL)
            THEN                             -- Bug 0026501 - MMS - 16/04/2013
               capital := vcapmin;          -- Bug 0026501 - MMS - 16/04/2013
            ELSE
               capital := capital_dependiente;
            END IF;
         ELSE
            IF (estgar.icapital > capmax) AND (capmax IS NOT NULL)
            THEN
               capital := capmax;
            ELSIF     (estgar.icapital < vcapmin
                      )                      -- Bug 0026501 - MMS - 16/04/2013
                  AND (vcapmin IS NOT NULL)
            THEN                             -- Bug 0026501 - MMS - 16/04/2013
               capital := vcapmin;          -- Bug 0026501 - MMS - 16/04/2013
            ELSE
               capital := estgar.icapital;
            --si está informado el capital, se queda igual
            END IF;
         END IF;
      END IF;

      RETURN capital;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUP_DIFERIDOS.f_valida_dependencias',
                      0,
                      'When Others',
                      SQLERRM
                     );
         RETURN NULL;
   END f_sup_dif_valida_dependencias;

/*******************************************************************************
   Funcion puente para poder llamar a la función pac_albsgt.f_tprefor, desde los
   suplementos diferidos, cuando se trata de evaluar las preguntas semi-automáticas
   ptprefor PARAM IN : Formula
   ptablas PARAM IN :  Tablas
   psseguro PARAM IN : Seguro
   pnriesgo PARAM IN : Nº de riesgo
   pfiniefe PARAM IN : fecha inicial efecto
   pnmovimi PARAM IN : Número movimiento
   pcgarant PARAM IN : Código de garantia
********************************************************************************/
   FUNCTION f_sup_dif_cal_pregar_semi (
      ptprefor   IN   VARCHAR2,
      ptablas    IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pfiniefe   IN   DATE,
      pnmovimi   IN   NUMBER,
      pcgarant   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vretorno   NUMBER;
      numerr     NUMBER;
   BEGIN
      numerr :=
         pac_albsgt.f_tprefor (ptprefor,
                               ptablas,
                               psseguro,
                               pnriesgo,
                               pfiniefe,
                               pnmovimi,
                               pcgarant,
                               vretorno,
                               1
                              );

      IF numerr <> 0
      THEN
         RETURN NULL;
      ELSE
         RETURN vretorno;
      END IF;
   END f_sup_dif_cal_pregar_semi;

   /*************************************************************************
      Realiza el diferimiento del suplemento 905 (renova vigencia)
      return               : 0 --> OK, <> 0 --> Error

      BUG 0026070 - 20/02/2013 - JMF
   *************************************************************************/
   FUNCTION f_diferir_spl_renovavigen (
      psseguro   IN   NUMBER,
      pfecsupl   IN   DATE DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                         := 0;
      vparam       VARCHAR2 (500);
      vobject      VARCHAR2 (200)
                             := 'PAC_SUP_DIFERIDOS.f_diferir_spl_renovavigen';
      vcmotmov     pds_supl_dif_config.cmotmov%TYPE   := 905;
      vfvalfun     pds_supl_dif_config.fvalfun%TYPE;
      vfecsupl     DATE;
      vsseguro_0   seguros.sseguro%TYPE;
      vnmovimi_0   movseguro.nmovimi%TYPE;
      vnorden      sup_acciones_dif.norden%TYPE       := 0;
      vdinaccion   sup_acciones_dif.dinaccion%TYPE;
      vttable      sup_acciones_dif.ttable%TYPE;
      vtcampo      sup_acciones_dif.tcampo%TYPE;
      vtwhere      sup_acciones_dif.twhere%TYPE;
      vtaccion     sup_acciones_dif.taccion%TYPE;
      vnejecu      sup_acciones_dif.nejecu%TYPE;
      vsperson     estrtn_convenio.sperson%TYPE;
      vpretorno    estrtn_convenio.pretorno%TYPE;
      vcount       NUMBER;
      vnpoliza     seguros.npoliza%TYPE;
      vsproduc     seguros.sproduc%TYPE;
      salir        EXCEPTION;
      num_err      NUMBER;
      vplan        NUMBER;
      d_fcaranu    seguros.fcaranu%TYPE;
      d_frenova    seguros.frenova%TYPE;
   BEGIN
      vpasexec := 1;

      -- control de parámetros informados
      IF psseguro IS NULL OR pfecsupl IS NULL
      THEN
         RAISE salir;
      END IF;

      SELECT npoliza, sproduc
        INTO vnpoliza, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      -- obtener la función de validación del suplemento
      BEGIN
         SELECT fvalfun
           INTO vfvalfun
           FROM pds_supl_dif_config
          WHERE cmotmov = vcmotmov AND (sproduc = vsproduc OR sproduc = 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 9001505;
            RAISE salir;
      END;

      vpasexec := 3;
      -- obtener la fecha en que se difiere el suplemento
      --vfecsupl := pac_md_suplementos.f_fecha_diferido(pfdifer, ppoliza.ssegpol);
      vpasexec := 4;

      --
      -- control del suplemento
      --
      -- obtener el número de ejecución del diferido para el mismo suplemento-seguro
      BEGIN
         SELECT NVL (MAX (nejecu), 0)
           INTO vnejecu
           FROM sup_diferidosseg
          WHERE cmotmov = vcmotmov AND sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnejecu := 0;
      END;

      vnejecu := vnejecu + 1;

      -- y verificar que no se programa un mismo suplemento diferido para el mismo suplemento-seguro
      SELECT COUNT (1)
        INTO vcount
        FROM sup_diferidosseg
       WHERE cmotmov = vcmotmov AND sseguro = psseguro AND estado = 0;

      -- obtener el sseguro (de REAL) del certificado 0
      -- y la información de revalorización
      SELECT sseguro
        INTO vsseguro_0
        FROM seguros
       WHERE ncertif = 0 AND npoliza = vnpoliza;

      vpasexec := 6;

      -- obtener el sseguro (de REAL) del certificado 0
      IF pnmovimi IS NULL
      THEN
         SELECT MAX (nmovimi)
           INTO vnmovimi_0
           FROM movseguro
          WHERE sseguro = vsseguro_0;
      ELSE
         vnmovimi_0 := pnmovimi;
      END IF;

      --Obtenemos fechas del certificado 0.
      BEGIN
         SELECT fcaranu, frenova
           INTO d_fcaranu, d_frenova
           FROM seguros
          WHERE sseguro = vsseguro_0;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_fcaranu := NULL;
            d_frenova := NULL;
      END;

      pac_log.p_log_sup_diferidos (psseguro,
                                   0,
                                      'Certificado 0 fcaranu:'
                                   || TO_CHAR (d_fcaranu, 'dd-mm-yyyy')
                                   || ' frenova: '
                                   || TO_CHAR (d_frenova, 'dd-mm-yyyy'),
                                   vobject,
                                   vpasexec
                                  );

      IF vcount = 0
      THEN
         INSERT INTO sup_diferidosseg
                     (cmotmov, sseguro, estado, fecsupl, fvalfun, cusuari,
                      falta, tvalord, fanula, nmovimi, nejecu
                     )
              VALUES (vcmotmov, psseguro, 0, pfecsupl, vfvalfun, f_user,
                      f_sysdate, NULL, NULL, vnmovimi_0, vnejecu
                     );

         pac_log.p_log_sup_diferidos
                         (psseguro,
                          0,
                             'INSERT INTO sup_diferidosseg VALUES cmotmov = '
                          || vcmotmov
                          || '; sseguro = '
                          || psseguro
                          || '; estado = 0; nejecu = '
                          || vnejecu,
                          vobject,
                          vpasexec
                         );
      ELSE
         -- Existe una programación pendiente para este tipo de suplemento diferido
         num_err := 9001506;
         RAISE salir;
      END IF;

      vpasexec := 5;
      --
      -- crear la función de modificación del seguro en la tabla EST
      vnorden := vnorden + 1;
      vdinaccion := 'U';
      vttable := 'ESTSEGUROS';
      vtcampo := '*';
      vtwhere := 'SSEGURO = :SSEGURO';
      vtaccion :=
            'UPDATE ESTSEGUROS SET FRENOVA='
         || 'to_date('
         || CHR (39)
         || TO_CHAR (d_frenova, 'dd-mm-yyyy')
         || CHR (39)
         || ','
         || CHR (39)
         || 'dd-mm-yyyy'
         || CHR (39)
         || ')'
         || ' WHERE SSEGURO = :SSEGURO';
      vpasexec := 7;
      pac_log.p_log_sup_diferidos (psseguro, 0, vtaccion, vobject, vpasexec);

      --
      -- ejecución del suplemento
      --
      BEGIN
         INSERT INTO sup_acciones_dif
                     (cmotmov, sseguro, norden, estado, nejecu, dinaccion,
                      ttable, tcampo, twhere, taccion, naccion, vaccion,
                      ttarifa
                     )
              VALUES (vcmotmov, psseguro, vnorden, 0, vnejecu, vdinaccion,
                      vttable, vtcampo, vtwhere, vtaccion, NULL, NULL,
                      0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            -- Existe una programación pendiente para este tipo de suplemento diferido
            num_err := 9001506;
            RAISE salir;
         WHEN OTHERS
         THEN
            RAISE salir;
      END;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                      f_axis_literales (num_err),
                                      vobject,
                                      vpasexec
                                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         pac_log.p_log_sup_diferidos (psseguro,
                                      1,
                                         f_axis_literales (1000455)
                                      || ': '
                                      || SQLCODE
                                      || '-'
                                      || SQLERRM,
                                      vobject,
                                      vpasexec
                                     );
         RETURN 1000455;
   END f_diferir_spl_renovavigen;
END pac_sup_diferidos;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUP_DIFERIDOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUP_DIFERIDOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUP_DIFERIDOS" TO "PROGRAMADORESCSI";
