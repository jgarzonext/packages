/* Formatted on 2020/05/28 09:10 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY pac_seguros
AS
   /******************************************************************************
      NOMBRE:       PAC_SEGUROS
      PROP¿SITO:    Funciones para realizar acciones sobre la tabla SEGUROS

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  -------------  ------------------------------------
      1.0        ??/??/2008   ???            1. Creaci¿n del package.
      2.0        16/03/2009   DRA            2. BUG0009423: IAX - Gesti¿ propostes retingudes: detecci¿ difer¿ncies al modificar capitals o afegir garanties
      3.0        27/02/2009   RSC            3. Adaptaci¿n iAxis a productos colectivos con certificados
      4.0        01-09-2009:  XPL            4. 11008, CRE - Afegir camps de cerca en la pantalla de selecci¿ de certificat 0.
      5.0        15/12/2009   JTS/NMM        5. 10831: CRE - Estado de p¿lizas vigentes con fecha de efecto futura
      6.0        20/01/2009   RSC            6. 7926: APR - Fecha de vencimiento a nivel de garant¿a
      7.0        22/02/2010   JMC            7. BUG 13038 Se a¿ade la funcion f_get_renovacion
      8.0        24/02/2010   DRA            8. 0010772: CRE - Desanul¿lar programacions al venciment/propera cartera
      9.0        18/03/2010   ASN            9. 0012915: CEM - Identificar p¿lizas con rentas bloqueadas
      10.0       24/03/2010   DRA            10.0013352: CEM003 - SUPLEMENTS: Parametritzar canvi de forma de pagament pels productes de risc
      11.0       22/12/2010   APD            11. Bug 16768: APR - Implementaci¿n y parametrizaci¿n del producto GROUPLIFE (II)
      12.0       12/09/2011   JMF            12. 0019444: LCOL_T04: Parametrizaci¿n Rehabilitaci¿n
      13.0       17/07/2012   MDS            13. 0022824: LCOL_T010-Duplicado de porpuestas
      14.0       01/10/2012   DRA            14. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
      15.0       19/10/2012   DRA            15. 0023911: LCOL: A¿adir Retorno para los productos Colectivos
      16.0       10/10/2012   APD            16. 0023817: LCOL - Anulaci¿n de colectivos
      17.0       13/11/2012   APD            17. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
      18.0       05/12/2012   APD            18. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
      19.0       12/12/2012   JMF            19. 0024832 LCOL - Cartera colectivos - Procesos
      20.0       08/01/2013   APD            20. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
      21.0       21/01/2013   APD            21. 0025542: LCOL_T031- LCOL - AUT - (id 431) Fecha de antig?edad en personas por agrupaci?n
      22.0       11/02/2013   NMM            22. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
      23.0       16/04/2013   FAL            23. 026100: RSAG101 - Producto RC Argentina. Incidencias
      23.0       02/05/2013   JDS            24. 0025221: LCOL_T031-LCOL - Fase 3 - Desarrollo Inspecci¿n de Riesgo
      24.0       18/06/2013   DCT            25. 0026488: LCOL_T010-LCOL - Revision incidencias qtracker (VI)
      25.0       05/08/2013   DCT            26. 0027048: LCOL_T010-Revision incidencias qtracker (V)
      26.0       27/01/2014   JTT            27. 0027429: Mostrar estado en la pantalla de simulaciones
      27.0       17/03/2014   APD            27. 0030448/0169858: LCOL_T010-Revision incidencias qtracker (2014/03)
      28.0       15/04/2014   JSV            28. 0030842: LCOL_T010-Revision incidencias qtracker (2014/04)
      29.0       30/4/2014    FAL            29. 0027642: RSA102 - Producto Tradicional
      30.0       16/06/2016   VCG            30. AMA-187-Realizar el desarrollo del GAP 114
      31.0       13/05/2019   ECP            31. IAXIS- 3631 Cambio de Estado cuando las pólizas están vencidas (proceso nocturno)
      32.0       15/05/2019   ECP            32. IAXIS-3592. Proceso de terminación por no pago
      33.0       27/12/2019   ECP            33. IAXIS-3504. PAtalla Gestión Suplementos
      34.0       25/02/2020   ECP            34. IAXIS-6224  Endosos con prima (0) no generan Recibo, aplica para Cumplimiento y RC
      35.0       26/05/2020   ECP            35. IAXIS-13888. Gestión Agenda
      36.0       28/05/2020   ECP            36. IAXIS-13945. Error Pagador de Pólizas
   ******************************************************************************/
   e_param_error   EXCEPTION;

   FUNCTION f_get_cagente (
      psseguro   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      pcagente   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200)
                  := 'param - psseguro: ' || psseguro || ' TABLA:' || ptablas;
      vobject    VARCHAR2 (200) := 'pac_seguros.f_get_cagente';
      vsproduc   NUMBER;
   BEGIN
      IF UPPER (ptablas) = 'EST'
      THEN
         BEGIN
            SELECT cagente
              INTO pcagente
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT cagente
                    INTO pcagente
                    FROM seguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     RETURN 103286;
               END;
         END;
      ELSE
         vpasexec := 2;

-- Ini IAXIS-3504 --ECP--30/12/2019
         BEGIN
            SELECT cagente
              INTO pcagente
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT cagente
                    INTO pcagente
                    FROM estseguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     RETURN 103286;
               END;
         END;
      -- Fin IAXIS-3504 -- ECP--30/12/2019
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - 3' || SQLERRM
                     );
         RETURN 103286;
   END f_get_cagente;

   FUNCTION f_get_sproduc (
      psseguro   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      psproduc   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200)
                  := 'param - psseguro: ' || psseguro || ' TABLA:' || ptablas;
      vobject    VARCHAR2 (200) := 'pac_seguros.f_get_sproduc';
      vsproduc   NUMBER;
   BEGIN
      IF UPPER (ptablas) = 'EST'
      THEN
         BEGIN
            SELECT sproduc
              INTO psproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- Ini IAXIS-6224 -- ECP -- 25/02/2020
               BEGIN
                  SELECT sproduc
                    INTO psproduc
                    FROM seguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     RETURN 103286;
               END;
         -- Fin IAXIS-6224 -- ECP 25/02/2020
         END;
      ELSE
         vpasexec := 2;

         -- INi IAXIS-3504 -- ECP -- 27/12/2019
         BEGIN
            SELECT sproduc
              INTO psproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT sproduc
                    INTO psproduc
                    FROM estseguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     RETURN 103286;
               END;
         END;
      -- INi IAXIS-3504 -- ECP -- 27/12/2019
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' -4 ' || SQLERRM
                     );
         RETURN 103286;
   END f_get_sproduc;

   FUNCTION f_ultsupl (
      pnpoliza    IN       NUMBER,
      pncertif    IN       NUMBER,
      psseguro    IN       NUMBER,
      pnsuplem    IN OUT   NUMBER,
      pfefepol    IN OUT   DATE,
      pfefesupl   IN OUT   DATE
   )
      RETURN NUMBER
   IS
      /***********************************************************************
        F_ULTSUPL: Retorna el n¿mero de suplemento y fecha de efecto
           del ¿ltimo suplemento.
        ALLIBCTR - Gesti¿n de datos referentes a los seguros
        No tenemos en cuenta las regularizaciones
        No tendremos en cuenta los movimientos anulados
           (nuevo tipo -> cmovseg = 52)
      ***********************************************************************/
      CURSOR c_suplemento
      IS
         SELECT   s.nsuplem, s.fefecto, m.fefecto
             FROM movseguro m, seguros s
            WHERE m.cmovseg NOT IN (6, 52)
              AND m.sseguro = s.sseguro
              AND s.ncertif = pncertif
              AND s.npoliza = pnpoliza
         ORDER BY m.fefecto DESC;

      CURSOR c_suplemento_seg
      IS
         SELECT   s.nsuplem, s.fefecto, m.fefecto
             FROM movseguro m, seguros s
            WHERE m.cmovseg NOT IN (6, 52)
              AND m.sseguro = s.sseguro
              AND s.sseguro = psseguro
         ORDER BY m.fefecto DESC;

      num_err   NUMBER;
   BEGIN
      IF pncertif IS NOT NULL AND pncertif IS NOT NULL
      THEN
         OPEN c_suplemento;

         FETCH c_suplemento
          INTO pnsuplem, pfefepol, pfefesupl;

         IF c_suplemento%FOUND
         THEN
            num_err := 0;
         ELSE
            num_err := 100525;                        -- Suplement inexistent
         END IF;

         CLOSE c_suplemento;
      ELSIF psseguro IS NOT NULL
      THEN
         OPEN c_suplemento_seg;

         -- BUG - 21546_108724- 04/02/2012 - JLTS - Se cambia c_suplemento por c_suplemento_seg
         FETCH c_suplemento_seg
          INTO pnsuplem, pfefepol, pfefesupl;

         IF c_suplemento_seg%FOUND
         THEN
            num_err := 0;
         ELSE
            num_err := 100525;                        -- Suplement inexistent
         END IF;

         CLOSE c_suplemento_seg;
      END IF;

      RETURN (num_err);
   /* BUG - 21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos incluyendo EXCEPTION
      y adem¿s se incluye el error 140999 de retorno */
   EXCEPTION
      WHEN OTHERS
      THEN
         IF c_suplemento%ISOPEN
         THEN
            CLOSE c_suplemento;
         END IF;

         IF c_suplemento_seg%ISOPEN
         THEN
            CLOSE c_suplemento_seg;
         END IF;

         RETURN 140999;
   END f_ultsupl;

   /*************************************************************************
    Funci¿n que valida que la fecha de efecto de una p¿liza
         return             : 0 la validaci¿n ha sido correcta
                           <> 0 la validaci¿n no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_fefecto (
      psproduc   IN   seguros.sproduc%TYPE,
      pfefecto   IN   seguros.fefecto%TYPE,
      pfvencim   IN   seguros.fvencim%TYPE,
      pcduraci   IN   seguros.cduraci%TYPE
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER;
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200)
         :=    'psproduc: '
            || psproduc
            || ' pfefecto: '
            || pfefecto
            || ' pfvencim: '
            || pfvencim
            || ' pcduraci: '
            || pcduraci;
      vobject    VARCHAR2 (200) := 'PAC_SEGUROS.F_Valida_Fefecto';
      vconta     NUMBER;
      vdias_a    NUMBER         := 0;
      vdias_d    NUMBER         := 0;
      vmeses_a   NUMBER         := 0;
      vmeses_d   NUMBER         := 0;
   BEGIN
      --Comprovaci¿ de par¿metres
      IF pfefecto IS NULL OR psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := 0;

      --Comprobamos si la fecha de efecto debe ser el d¿a 1 de mes.
      IF NVL (f_parproductos_v (psproduc, 'DIA_INICIO_01'), 0) IN (1, 2)
      THEN
         IF TO_CHAR (pfefecto, 'DD') <> '01'
         THEN
            vnumerr := 1000459;
         END IF;
      END IF;

      vpasexec := 3;
      vdias_a := f_parproductos_v (psproduc, 'DIASATRAS');
      vdias_d := f_parproductos_v (psproduc, 'DIASDESPU');
      -- 34866/206242
      vmeses_a := NVL (f_parproductos_v (psproduc, 'MESESATRAS'), 0);
      vmeses_d := NVL (f_parproductos_v (psproduc, 'MESESDESPU'), 0);

      -- Calcular v_dias:
      -- Si la fecha de efecto esta en diferente a¿o al actual de la emisi¿n de la
      -- la propuesta, solo se permitir¿ retroactividad hasta el principio del a¿o:
      --
      IF vmeses_a != 0
      THEN
         IF (ADD_MONTHS (pfefecto, vmeses_a) >= TRUNC (f_sysdate))
         THEN
            IF TO_NUMBER (TO_CHAR (pfefecto, 'YYYY')) <>
                                      TO_NUMBER (TO_CHAR (f_sysdate, 'YYYY'))
            THEN
               vmeses_a := NULL;
               vdias_a :=
                  TRUNC (  f_sysdate
                         - TO_DATE ('01/01/' || TO_CHAR (f_sysdate, 'YYYY'),
                                    'dd/mm/yyyy'
                                   )
                        );
            ELSE
               vmeses_a := NULL;
               vdias_a := TRUNC (f_sysdate - pfefecto);
            END IF;
         ELSE
            IF ADD_MONTHS (pfefecto, vmeses_a) < TRUNC (f_sysdate)
            THEN
               vmeses_a := NULL;
               vdias_a := f_sysdate - ADD_MONTHS (f_sysdate, -1 * vmeses_a);
            END IF;
         END IF;
      END IF;

      -- Calcular v_dias_d
      IF (vmeses_d != 0)
      THEN
         vdias_d := TRUNC (ADD_MONTHS (f_sysdate, vmeses_d) - f_sysdate);
      END IF;

      -- Validar retroactividad
      --
      IF vdias_d = -1
      THEN                                      --primer dia del mes siguiente
         vdias_d := LAST_DAY (f_sysdate) + 1 - f_sysdate;
      END IF;

      vpasexec := 4;

      -- Comprobamos que la f.efecto est¿ dentro de unos l¿mites m¿nimo y m¿ximo
      IF TRUNC (pfefecto) + NVL (vdias_a, 0) < TRUNC (f_sysdate)
      THEN
         vnumerr := 109909;
      ELSIF TRUNC (pfefecto) > TRUNC (f_sysdate) + NVL (vdias_d, 0)
      THEN
         vnumerr := 101490;
      END IF;

      -- Comprobamos que la f.vencim. sea posterior a la f.efecto, y si la f.vencim. no est¿ informada, miramos el cduraci
      IF pfvencim IS NOT NULL
      THEN
         vpasexec := 5;

         IF TRUNC (pfvencim) <= TRUNC (pfefecto)
         THEN
            vnumerr := 100022;
         END IF;
      ELSE
         vpasexec := 6;

         -- Bug 23117 - RSC - 30/07/2012 - LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A¿O (a¿adimos 6)
         IF pcduraci NOT IN (0, 4, 6)
         THEN
            vnumerr := 151288;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'Par¿metros incorrectos'
                     );
         RETURN 1000005;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;
   END f_valida_fefecto;

   /*************************************************************************
    Funci¿n que modifica la fecha de efecto de una p¿liza
         return             : 0 todo OK
                           <> 0 algo KO
   *************************************************************************/
   FUNCTION f_set_fefecto (
      psseguro   IN   seguros.sseguro%TYPE,
      pfefecto   IN   seguros.fefecto%TYPE,
      pnmovimi   IN   movseguro.nmovimi%TYPE
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200)
         :=    'psseguro: '
            || psseguro
            || ' pnmovimi: '
            || pnmovimi
            || ' pfefecto: '
            || pfefecto;
      vobject    VARCHAR2 (200) := 'PAC_SEGUROS.f_set_fefecto';
   BEGIN
      --Comprovaci¿ de par¿metres
      IF psseguro IS NULL OR pfefecto IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      pk_nueva_produccion.p_modificar_fefecto_seg (psseguro,
                                                   pfefecto,
                                                   pnmovimi,
                                                   'SEG'
                                                  );
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'Par¿metros incorrectos'
                     );
         RETURN 1000005;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;
   END f_set_fefecto;

   /*************************************************************************
    Funci¿n que devuelve el NSOLICI o el NPOLIZA en funci¿n de unos criterios
         return             : 0 todo OK
                           <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_nsolici_npoliza (
      psseguro   IN       seguros.sseguro%TYPE,
      ptablas    IN       VARCHAR2,
      psproduc   IN       seguros.sproduc%TYPE,
      pcsituac   IN       seguros.csituac%TYPE,
      pnsolici   OUT      seguros.nsolici%TYPE,
      pnpoliza   OUT      seguros.npoliza%TYPE,
      pncertif   OUT      seguros.ncertif%TYPE
   )
      RETURN NUMBER
   IS
      --
      CURSOR c_seg
      IS
         SELECT seg.sproduc, seg.csituac, seg.nsolici, seg.npoliza,
                seg.ncertif, seg.ncertif
           FROM seguros seg
          WHERE seg.sseguro = psseguro AND ptablas IS NULL
         UNION ALL
         SELECT seg.sproduc, seg.csituac, seg.nsolici, seg.npoliza,
                seg.ncertif, seg.ncertif
           FROM estseguros seg
          WHERE seg.sseguro = psseguro AND ptablas = 'EST';

      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200)
         :=    'psseguro: '
            || psseguro
            || ' ptablas: '
            || ptablas
            || ' psproduc: '
            || psproduc
            || ' pcsituac: '
            || pcsituac;
      vobject    VARCHAR2 (200) := 'PAC_SEGUROS.f_get_nsolici_npoliza';
      vnsolici   NUMBER;
      vnpoliza   NUMBER;
      vncertif   NUMBER;
      vcsituac   NUMBER;
      vcreteni   NUMBER;
      vsproduc   NUMBER;
   BEGIN
      --Comprovaci¿ de par¿metres
      IF psseguro IS NULL
      THEN                 -- OR psproduc IS NULL  -- BUG13352:DRA:24/03/2010
         RAISE e_param_error;
      END IF;

      OPEN c_seg;

      FETCH c_seg
       INTO vsproduc, vcsituac, vnsolici, vnpoliza, vncertif, vcreteni;

      CLOSE c_seg;

      IF NVL (pcsituac, vcsituac) = 5
      THEN
         pnsolici := NULL;
         pnpoliza := vnpoliza;
      ELSE
         IF     NVL (f_parproductos_v (NVL (psproduc, vsproduc),
                                       'NPOLIZA_EN_EMISION'
                                      ),
                     0
                    ) = 1
            AND NVL (pcsituac, vcsituac) = 4
         THEN
            -- BUG22839:DRA:26/09/2012:Inici
            IF     pac_seguros.f_es_col_admin (psseguro,
                                               NVL (ptablas, 'SEG')) = 1
               AND vcreteni = 1
            THEN
               pnsolici := NULL;
               pnpoliza := vnpoliza;
            ELSE
               IF vnsolici IS NOT NULL
               THEN
                  pnsolici := vnsolici;
                  pnpoliza := NULL;
               ELSE
                  pnsolici := NULL;
                  pnpoliza := vnpoliza;
               END IF;
            END IF;
         -- BUG22839:DRA:26/09/2012:Fi
         ELSE
            pnsolici := NULL;
            pnpoliza := vnpoliza;
         END IF;
      END IF;

      IF     NVL (pac_parametros.f_parproducto_n (vsproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                  0
                 ) = 1
         AND pnpoliza IS NOT NULL
      THEN
         pncertif := vncertif;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_seg%ISOPEN
         THEN
            CLOSE c_seg;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'Par¿metros incorrectos'
                     );
         RETURN 1000005;
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_seg%ISOPEN
         THEN
            CLOSE c_seg;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;
   END f_get_nsolici_npoliza;

   /*************************************************************************
    Funci¿n que devuelve el CDOMICI de un tomador
      param in     psseguro : Id. seguro
      param in     psperson : id. persona
      param in     ptablas  : 'EST', ...
      param    out pcdomici : Id. domicilio
         return             : 0 todo OK
                           <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_cdomici_tom (
      psseguro   IN       tomadores.sseguro%TYPE,
      psperson   IN       tomadores.sperson%TYPE,
      ptablas    IN       VARCHAR2,
      pcdomici   OUT      tomadores.cdomici%TYPE
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200)
         :=    'psseguro: '
            || psseguro
            || ' ptablas: '
            || ptablas
            || ' psperson: '
            || psperson;
      vobject    VARCHAR2 (200) := 'PAC_SEGUROS.f_get_cdomici_tom';
   BEGIN
      BEGIN
         IF ptablas = 'EST'
         THEN
            SELECT cdomici
              INTO pcdomici
              FROM esttomadores
             WHERE sseguro = psseguro AND sperson = psperson;
         ELSE
            SELECT cdomici
              INTO pcdomici
              FROM tomadores
             WHERE sseguro = psseguro AND sperson = psperson;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pcdomici := NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'Par¿metros incorrectos'
                     );
         RETURN 1000005;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;
   END f_get_cdomici_tom;

   /*************************************************************************
    Funci¿n que devuelve y modifica la fecha de cancelaci¿n de una p¿liza
      param in     psseguro : Id. seguro
      param in     ptablas  : 'EST', ...
      param    out pfcancel : Fecha cancelaci¿n
         return             : 0 todo OK
                           <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_set_fcancel (
      psseguro   IN       tomadores.sseguro%TYPE,
      ptablas    IN       VARCHAR2,
      pfcancel   OUT      seguros.fcancel%TYPE
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER         := 1;
      vparam       VARCHAR2 (200)
                       := 'psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vobject      VARCHAR2 (200) := 'PAC_SEGUROS.f_get_set_fcancel';
      vsproduc     NUMBER;
      nerr         NUMBER         := 0;
      v_fcancel    DATE           := NULL;
      meses_prop   NUMBER;
      vfefecto     DATE;
      vfmovimi     DATE;
   BEGIN
      nerr := pac_seguros.f_get_sproduc (psseguro, ptablas, vsproduc);

      IF ptablas = 'EST'
      THEN
         SELECT fefecto
           INTO vfefecto
           FROM estseguros
          WHERE sseguro = psseguro;

         vfmovimi := f_sysdate;              -- BUG 0038761 - FAL - 17/11/2015
      ELSE
         SELECT fefecto
           INTO vfefecto
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT fmovimi                      -- BUG 0038761 - FAL - 17/11/2015
           INTO vfmovimi
           FROM movseguro
          WHERE sseguro = psseguro AND nmovimi = (SELECT MAX (nmovimi)
                                                    FROM movseguro
                                                   WHERE sseguro = psseguro);
      END IF;

      IF nerr = 0
      THEN
         BEGIN
            IF v_fcancel IS NULL
            THEN
               --BUG 15304 - 09/07/2010 - JRB - Se inserta la fecha de cancelacion de la propuesta a partir de DIAS_PROPOST_VALIDA
               IF NVL (f_parproductos_v (vsproduc, 'DIAS_PROPOST_VALIDA'), 0) >
                                                                            0
               THEN
                  IF NVL
                        (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'CANCEL_POR_FEMISIO'
                                           ),
                         0
                        ) = 1
                  THEN                       -- BUG 0038761 - FAL - 17/11/2015
                     v_fcancel :=
                          GREATEST (vfefecto, vfmovimi)
                        + f_parproductos_v (vsproduc, 'DIAS_PROPOST_VALIDA');
                  ELSE
                     v_fcancel :=
                          vfefecto
                        + f_parproductos_v (vsproduc, 'DIAS_PROPOST_VALIDA');
                  END IF;
               ELSE
                  -- si no est¿ informada la fecha de cancelaci¿n de la propuesta
                  meses_prop :=
                     NVL (f_parproductos_v (vsproduc, 'MESES_PROPOST_VALIDA'),
                          0
                         );

                  IF meses_prop > 0
                  THEN
                     /*v_fcancel := TO_DATE('01'
                                          || TO_CHAR(ADD_MONTHS(f_sysdate, meses_prop + 1), 'mmyyyy'),
                                          'ddmmyyyy');*/
                     IF NVL
                           (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'CANCEL_POR_FEMISIO'
                                           ),
                            0
                           ) = 1
                     THEN                    -- BUG 0038761 - FAL - 17/11/2015
                        v_fcancel :=
                           ADD_MONTHS (GREATEST (vfefecto, vfmovimi),
                                       meses_prop
                                      );
                     ELSE
                        v_fcancel := ADD_MONTHS (vfefecto, meses_prop);
                     END IF;
                  ELSE
                     v_fcancel := NULL;
                  END IF;
               END IF;
            END IF;
         /*meses_prop := NVL(f_parproductos_v(vsproduc, 'MESES_PROPOST_VALIDA'), 0);

         IF meses_prop > 0 THEN
            v_fcancel := TO_DATE('01'
                                 || TO_CHAR(ADD_MONTHS(f_sysdate, meses_prop + 1),
                                            'mmyyyy'),
                                 'ddmmyyyy');
         ELSE
            v_fcancel := NULL;
         END IF;*/
         EXCEPTION
            WHEN OTHERS
            THEN
               v_fcancel := NULL;
         END;

         pfcancel := v_fcancel;

         IF ptablas = 'EST'
         THEN
            UPDATE estseguros
               SET fcancel = v_fcancel
             WHERE sseguro = psseguro;
         ELSE
            UPDATE seguros
               SET fcancel = v_fcancel
             WHERE sseguro = psseguro;
         END IF;
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'Par¿metros incorrectos'
                     );
         RETURN 1000005;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;
   END f_get_set_fcancel;

   /*************************************************************************
     Funci¿n que devuelve la situaci¿n en la que se encuentra una p¿liza
       param  in     psseguro : Id. seguro
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcsituac : CSITUAC de la taula
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_csituac (
      psseguro   IN       seguros.sseguro%TYPE,
      ptablas    IN       VARCHAR2,
      pcsituac   OUT      seguros.csituac%TYPE
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200)
                       := 'psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vobject    VARCHAR2 (200) := 'PAC_SEGUROS.f_get_csituac';
   BEGIN
      --Comprovaci¿ de par¿metres
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'EST'
      THEN
         SELECT csituac
           INTO pcsituac
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT csituac
           INTO pcsituac
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'Par¿metros incorrectos'
                     );
         RETURN 1000005;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 101919;
   END f_get_csituac;

   /*************************************************************************
    Funci¿n que devuelve los meses con paga extra de los seguros de rentas
      param  in     psseguro : Id. seguro
      param  out    pmesesextra : Meses con paga extra
      return        : 0 todo OK
                      <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_nmesextra (
      psseguro      IN       seguros.sseguro%TYPE,
      pmesesextra   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200) := 'psseguro: ' || psseguro;
      vobject    VARCHAR2 (200) := 'PAC_SEGUROS.f_get_nmesextra';
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         SELECT nmesextra
           INTO pmesesextra
           FROM seguros_ren
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT nmesextra
                 INTO pmesesextra
                 FROM estseguros_ren
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  pmesesextra := NULL;
            END;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'Par¿metros incorrectos'
                     );
         RETURN 1000005;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;
   END f_get_nmesextra;

   -- 24735.NMM.i.
   /*************************************************************************
    Funci¿ que retorna l'import dels mesos amb paga xtra de les assegurances de rendes.
      param  in     psseguro : Id. asseguran¿a
      param  out    pimesextra : Imports dels Mesos amb paga extra
      return        : 0 tot OK
                      <> 0 Error
   *************************************************************************/
   FUNCTION f_get_imesextra (
      psseguro       IN       seguros.sseguro%TYPE,
      pimesosextra   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200) := 'psseguro: ' || psseguro;
      vobject    VARCHAR2 (200) := 'PAC_SEGUROS.f_get_imesextra';
   BEGIN
      IF psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         SELECT imesextra
           INTO pimesosextra
           FROM seguros_ren
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT imesextra
                 INTO pimesosextra
                 FROM estseguros_ren
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  pimesosextra := NULL;
            END;
      END;

      RETURN (0);
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      'Par¿metres incorrectes'
                     );
         RETURN (1000005);
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN (1000455);
   END f_get_imesextra;

   -- 24735.NMM.f.

   /*************************************************************************
      Funci¿n que obtiene la lista de p¿lizas de un producto de colectivo con certificados
      param in psproduc  : c¿digo de producto
      param in pnpoliza  : n¿mero de p¿liza
      param out vselect  : select para obtener la lista de p¿lizas
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   -- Bug 8745 - 27/02/2009 - RSC - Adaptaci¿n iAxis a productos colectivos con certificados
   FUNCTION f_sel_certificadoscero (
      psproduc     IN   NUMBER,
      pnpoliza     IN   NUMBER,
      pbuscar      IN   VARCHAR2,                      --BUG11008-01092009-XPL
      pcintermed   IN   NUMBER,               --BUG22839/125740:DCT:21/10/2012
      pcsucursal   IN   NUMBER,               --BUG22839/125740:DCT:21/10/2012
      pcadm        IN   NUMBER,               --BUG22839/125740:DCT:21/10/2012
      pcidioma     IN   NUMBER DEFAULT 2,
      pmodo        IN   VARCHAR2 DEFAULT NULL,
      -- Bug 30360/174025 - 09/05/2014 - AMC
      pnsolici     IN   NUMBER
            DEFAULT NULL                -- Bug 34409/196980 - 16/04/2015 - POS
   )
      RETURN VARCHAR2
   IS
      squery     VARCHAR2 (2000);
      vobject    VARCHAR2 (100)  := 'PAC_SEGUROS.f_sel_certificadoscero';
      vpasexec   NUMBER          := 1;
      vparam     VARCHAR2 (1000)
         :=    'psproduc: '
            || psproduc
            || 'pnpoliza: '
            || pnpoliza
            || 'pbuscar: '
            || pbuscar
            || 'pcintermed: '
            || pcintermed
            || 'pcsucursal: '
            || pcsucursal
            || 'pcadm: '
            || pcadm
            || 'pcidioma: '
            || pcidioma
            || 'pmodo: '
            || pmodo
            || 'pnsolici: '
            || pnsolici;
   BEGIN
      -- BUG22839:DRA:26/09/2012:Inici
      -- Se genera la instrucci¿n select para obtener la lista de p¿lizas de un producto concreto, que est¿n
      -- vigentes y tienen certificado cero. El par¿metro p¿liza puede estar vac¿o.
      --BUG22839/125740:DCT:21/10/2012:Inicio A¿adir campos intermidiarios, sucursal y adn
      --BUG24058/130880:DCT:27/11/2012:Inicio A¿adir     || ' AND src.fmovfin IS NULL '
      squery :=
            'SELECT s.npoliza Numero, '
         || ' pac_seguros.f_get_nametomador(s.sseguro, 1,t.cidioma) Tomador, '
         || ' ff_desvalorfijo(61,t.cidioma,s.csituac) Situacion, '
         || ' t.ttitulo Producto, s.fefecto Efecto, '
         || ' s.cagente intermediario, '
         || ' PAC_REDCOMERCIAL.ff_desagente (s.cagente,'
         || pac_md_common.f_get_cxtidioma
         || ', 2) tintermediario,'
         || ' src.c02 sucursal, '
         || ' src.c03 adn '
         || ' FROM seguros s, titulopro t, seguredcom src WHERE s.cramo = t.cramo '
         || ' AND s.cmodali = t.cmodali AND s.ctipseg = t.ctipseg '
         || ' AND s.ccolect = t.ccolect '
         || ' AND s.sseguro = src.sseguro '
         || ' AND src.fmovfin IS NULL '
         --|| ' AND s.ncertif = 0  '
         || ' AND pac_seguros.f_soycertifcero (s.sproduc, s.npoliza, s.sseguro) = 0 '
         --JAVENDANO Bug 34409/196980 - 16/04/2015 - POS
         || ' AND s.sproduc = '
         || psproduc
         || ' AND t.cidioma = '
         || pcidioma
         || ' AND s.npoliza = NVL('''
         || pnpoliza
         || ''',s.npoliza) '
--         || ' AND s.nsolici = NVL(''' || pnsolici || ''',s.nsolici) '   --JAVENDANO Bug 34409/196980 - 16/04/2015 - POS
         || ' AND ((s.nsolici = NVL('''
         || pnsolici
         || ''',s.nsolici) and '''
         || pnsolici
         || ''' is not null ) or ( '''
         || pnsolici
         || ''' is null))'                 -- FAL - 34477/0210201 - 28/07/2015
         || ' AND((pac_corretaje.f_tiene_corretaje(s.sseguro) = 1 '
         || ' AND EXISTS(SELECT 1 FROM age_corretaje ctj, agentes_agente_pol bb
                         WHERE ctj.sseguro = s.sseguro AND bb.cempres = s.cempres AND bb.cagente = ctj.cagente)) '
         || ' OR((s.cagente, s.cempres) IN(SELECT aa.cagente, aa.cempres FROM agentes_agente_pol aa)))';

      -- Bug 30360/174025 - 09/05/2014 - AMC
      IF pmodo IS NULL OR pmodo <> 'SIMULACION'
      THEN
         squery :=
               squery
            || ' AND (((s.csituac = 4 OR s.csituac = 5) AND s.creteni = 0 AND pac_seguros.f_es_col_admin(s.sseguro)=1) '
            || ' OR (s.csituac = 0 AND pac_seguros.f_es_col_admin(s.sseguro)=0)) ';
      ELSIF pmodo = 'SIMULACION'
      THEN
         -- Inicio AMA-29 - 06/06/2016 - AMC
         squery :=
               squery
            || ' AND((f_vigente(s.sseguro, NULL, f_sysdate) = 0 OR csituac IN(';

         IF NVL (pac_parametros.f_parproducto_n (psproduc, 'PROALTA_SIMUL'),
                 0) = 1
         THEN
            squery := squery || ' 4,';
         END IF;

         squery := squery || ' 5))';
         squery := squery || ' AND NOT(';

         IF NVL (pac_parametros.f_parproducto_n (psproduc, 'PROALTA_SIMUL'),
                 0) = 1
         THEN
            squery := squery || ' s.csituac = 4 AND';
         END IF;

         squery := squery || ' s.creteni IN(3, 4)))';
      -- Fin AMA-29 - 06/06/2016 - AMC
      END IF;

      -- Fi Bug 30360/174025 - 09/05/2014 - AMC
      IF pcintermed IS NOT NULL
      THEN
         squery := squery || ' AND s.cagente = ' || pcintermed;
      END IF;

      IF pcsucursal IS NOT NULL
      THEN
         squery := squery || ' AND src.c02 = ' || pcsucursal;
      END IF;

      IF pcadm IS NOT NULL
      THEN
         squery := squery || ' AND src.c03 = ' || pcadm;
      END IF;

      -- BUG22839:DRA:26/09/2012:Fi
      --BUG22839/125740:DCT:21/10/2012:Fin
      --BUG24058/130880:DCT:27/11/2012: Fin
      IF pbuscar IS NOT NULL
      THEN
         squery :=
               squery
            || ' AND s.sseguro IN (SELECT a.sseguro '
            || ' FROM tomadores a, per_detper p '
            || ' WHERE a.sperson = p.sperson '
            || ' AND UPPER(p.tbuscar) LIKE UPPER(''%'
            || pbuscar
            || '%'
            || CHR (39)
            || '))';
      END IF;

      p_control_error ('AMC', 'f_sel_certificadoscero', squery);
      RETURN squery;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN NULL;
   END f_sel_certificadoscero;

   /*************************************************************************
      Obtiene la actividad de una poliza
       param in psseguro: codigo del seguro
       param in pnpoliza: Numero de p¿liza
       param in pncertif: Numero de certificado de la poliza
       param in ptablas: identificador de tablas EST, SOL, SEG
      param out pcactivi : codigo de la actividad de la poliza
      return             : number (0- Todo OK, num_err - Si ha habido algun error)
   *************************************************************************/
   -- Bug 8745 - 27/02/2009 - RSC - Adaptaci¿n iAxis a productos colectivos con certificados
   FUNCTION f_get_cactivi (
      psseguro   IN       NUMBER,
      pnpoliza   IN       NUMBER,
      pncertif   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      pcactivi   OUT      NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      IF UPPER (ptablas) = 'EST'
      THEN
         SELECT cactivi
           INTO pcactivi
           FROM estseguros
          WHERE (sseguro = psseguro OR psseguro IS NULL)
            AND (npoliza = pnpoliza OR pnpoliza IS NULL)
            AND (ncertif = pncertif OR pncertif IS NULL);
      ELSE
         SELECT cactivi
           INTO pcactivi
           FROM seguros
          WHERE (sseguro = psseguro OR psseguro IS NULL)
            AND (npoliza = pnpoliza OR pnpoliza IS NULL)
            AND (ncertif = pncertif OR pncertif IS NULL);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Pac_Seguros.f_get_cactivi',
                      1,
                         'pnpoliza = '
                      || pnpoliza
                      || '; pncertif = '
                      || pncertif
                      || '; psseguro = '
                      || psseguro
                      || '; ptablas = '
                      || ptablas,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 101919;             -- Error al leer datos de la tabla SEGUROS
   END f_get_cactivi;

   /******************************************************************
    Funci¿n que nos devuelve una garantia, o bien en polizas o bien en riesgos.
      param in PSSEGURO: Codi de segur
      param in PNRIESGO: N¿mero de risc
      param in PTABLAS : taula 'SOL','EST'...
      RETURN               : NUMBER; (Codi d'activitat)
    RETURN error: 0: correcto
   *******************************************************************/
   FUNCTION ff_get_actividad (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      s_sproduc   seguros.sproduc%TYPE;
      vcactivi    seguros.cactivi%TYPE;
      numerr      NUMBER;
      vvalor      NUMBER;
   BEGIN
      --BUSCAR PRODUCTO
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT sproduc, cactivi
              INTO s_sproduc, vcactivi
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- IAXIS -13888  -- 26/05/2020
               BEGIN
                  SELECT sproduc, cactivi
                    INTO s_sproduc, vcactivi
                    FROM seguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'FF_GET_ACTIVIDAD',
                                  1,
                                  'EXCEPTION NO_DATA_FOUND ESTSEGUROS',
                                  SQLERRM || ' ' || SQLCODE
                                 );
                     RETURN NULL;                    --No existeix el producte
               END;
-- IAXIS -13888  -- 26/05/2020
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'FF_GET_ACTIVIDAD',
                            1,
                            'EXCEPTION OTHERS ESTSEGUROS',
                            SQLERRM || ' ' || SQLCODE
                           );
               RETURN NULL;                          --Llegir taula estseguros
         END;
      ELSIF ptablas = 'SOL'
      THEN
         BEGIN
            SELECT sproduc, cactivi
              INTO s_sproduc, vcactivi
              FROM solseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'FF_GET_ACTIVIDAD',
                            1,
                            'EXCEPTION NO_DATA_FOUND SOLSEGUROS',
                            SQLERRM || ' ' || SQLCODE
                           );
               RETURN NULL;                          --No existeix el producte
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'FF_GET_ACTIVIDAD',
                            1,
                            'EXCEPTION SOLSEGUROS',
                            SQLERRM || ' ' || SQLCODE
                           );
               RETURN NULL;
         END;
      ELSE
         BEGIN
            SELECT sproduc, cactivi
              INTO s_sproduc, vcactivi
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'FF_GET_ACTIVIDAD',
                            1,
                            'EXCEPTION NO_DATA_FOUND SEGUROS',
                            SQLERRM || ' ' || SQLCODE
                           );
               RETURN NULL;                          --No existeix el producte
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'FF_GET_ACTIVIDAD',
                            1,
                            'EXCEPTION SEGUROS',
                            SQLERRM || ' ' || SQLCODE
                           );
               RETURN NULL;
         END;
      END IF;

      numerr := f_parproductos (s_sproduc, 'ACTIVIRIESGO', vvalor);

      IF numerr <> 0
      THEN
         RETURN NULL;
      ELSE
         --buscar en la taula riscos
         IF vvalor = 1
         THEN
            IF ptablas = 'EST'
            THEN
               BEGIN
                  SELECT cactivi
                    INTO vcactivi
                    FROM estriesgos
                   WHERE sseguro = psseguro AND nriesgo = pnriesgo;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'FF_GET_ACTIVIDAD',
                                  1,
                                  'EXCEPTION NO_DATA_FOUND ESTRIESGOS',
                                  SQLERRM || ' ' || SQLCODE
                                 );
                     RETURN NULL;
                  --No hi ha cap activitat ni garantia amb les dades introdu¿des.
                  WHEN OTHERS
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'FF_GET_ACTIVIDAD',
                                  1,
                                  'EXCEPTION OTHERS ESTRIESGOS',
                                  SQLERRM || ' ' || SQLCODE
                                 );
                     RETURN NULL;
               END;
            ELSE
               BEGIN
                  SELECT cactivi
                    INTO vcactivi
                    FROM riesgos
                   WHERE sseguro = psseguro AND nriesgo = pnriesgo;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'FF_GET_ACTIVIDAD',
                                  1,
                                  'EXCEPTION NO_DATA_FOUND RIESGOS',
                                  SQLERRM || ' ' || SQLCODE
                                 );
                     RETURN NULL;
                  --No hi ha cap activitat ni garantia amb les dades introdu¿des.
                  WHEN OTHERS
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'FF_GET_ACTIVIDAD',
                                  1,
                                  'EXCEPTION OTHERS RIESGOS',
                                  SQLERRM || ' ' || SQLCODE
                                 );
                     RETURN NULL;
               END;
            END IF;
         END IF;
      END IF;

      RETURN vcactivi;
   END ff_get_actividad;

   /******************************************************************
      Funci¿n que nos devuelve el sseguro pasandole el npoliza y ncertificado
        param in pnpoliza: num poliza
        param in pncertif: num certif
        param in PTABLAS : taula 'SOL','EST'...
        param out psseguro: sseguro
        RETURN               : 0-ok : 1-error
    /*****************************************************************/
   FUNCTION f_get_sseguro (
      pnpoliza   IN       NUMBER,
      pncertif   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      psseguro   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      s_sproduc   seguros.sproduc%TYPE;
      vcactivi    seguros.cactivi%TYPE;
      numerr      NUMBER;
      vvalor      NUMBER;
   BEGIN
      --BUSCAR SSEGURO
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT sseguro
              INTO psseguro
              FROM estseguros
             WHERE npoliza = pnpoliza
               AND (pncertif IS NULL OR ncertif = pncertif);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT sseguro
                    INTO psseguro
                    FROM seguros
                   WHERE npoliza = pnpoliza
                     AND (pncertif IS NULL OR ncertif = pncertif);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
         END;
      ELSE
         -- Ini IAXIS-13945 -- 28/05/2020
         BEGIN
            --ptablas : SOL, POL...
            SELECT sseguro
              INTO psseguro
              FROM seguros
             WHERE npoliza = pnpoliza
               AND (pncertif IS NULL OR ncertif = pncertif);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT sseguro
                    INTO psseguro
                    FROM estseguros
                   WHERE npoliza = pnpoliza
                     AND (pncertif IS NULL OR ncertif = pncertif);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
         END;
      --  IAXIS-13945 -- 28/05/2020
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN TOO_MANY_ROWS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_get_sseguro',
                      1,
                      'EXCEPTION TOO_MANY_ROWS',
                      SQLERRM || ' ' || SQLCODE
                     );
         RETURN 9001959;
      WHEN NO_DATA_FOUND
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_get_sseguro',
                      2,
                      'EXCEPTION NO_DATA_FOUND',
                      SQLERRM || ' ' || SQLCODE || 'ptablas' || ptablas||'psseguro '||psseguro||'pnpoliza '||pnpoliza
                     );
         RETURN 100500;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_get_sseguro',
                      3,
                      'EXCEPTION OTHERS',
                      SQLERRM || ' ' || SQLCODE
                     );
         RETURN 100500;
   END f_get_sseguro;

   /*************************************************************************
      Recupera el nombre del tomador de la p¿liza seg¿n el orden
      param in sseguro   : c¿digo seguro
      param in nordtom   : orden tomador
      param in idioma   : idioma
      return             : nombre tomador
   *************************************************************************/
   FUNCTION f_get_nametomador (
      sseguro    IN   NUMBER,
      nordtom    IN   NUMBER,
      pcidioma   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      vf         VARCHAR2 (200) := NULL;
      nerr       NUMBER;
      vcidioma   NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (100) := 'sseguro= ' || sseguro;
      vobject    VARCHAR2 (200) := 'PAC_MD_LISTVALORES.F_Get_NameTomador';
      mensajes   t_iax_mensajes := NULL;
   BEGIN
      vcidioma := pcidioma;
      nerr := f_tomador (sseguro, nordtom, vf, vcidioma);
      RETURN vf;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_get_nametomador',
                      3,
                      'EXCEPTION OTHERS',
                      SQLERRM || ' ' || SQLCODE
                     );
         RETURN 100500;
   END f_get_nametomador;

   /*************************************************************************
      Funci¿n devuelve el estado detallado de una poliza
      param in psseguro  : sseguro
      param in pcidioma  : idioma
      param in ptipo     : 1- solo situacion; 2- sit + estado; 3- sit + estado + incidencias
      return             : Literal con la situacion
      --BUG 10831.i.
   *************************************************************************/
   FUNCTION ff_situacion_poliza (
      p_sseguro   IN   NUMBER,
      p_cidioma   IN   NUMBER,
      p_tipo      IN   NUMBER,
      -- bug 10831.NMM.01/2009.i.
      p_csituac   IN   seguros.csituac%TYPE DEFAULT NULL,
      p_creteni   IN   seguros.creteni%TYPE DEFAULT NULL,
      p_fefecto   IN   seguros.fefecto%TYPE DEFAULT NULL,
      -- bug 10831.NMM.01/2009.f.
      p_tabla     IN   VARCHAR2 DEFAULT 'SEG'
   )                                            -- Bug27429 - 27/01/2014 - JTT
      RETURN VARCHAR2
   IS
      vf                    VARCHAR2 (200)         := NULL;
      vcsituac              seguros.csituac%TYPE;
      vcreteni              seguros.creteni%TYPE;
      vfefecto              seguros.fefecto%TYPE;
      vestado               NUMBER;
      vincidencias          VARCHAR2 (200);
      mensajes              t_iax_mensajes;
      vpasexec              NUMBER (8)             := 0;
      vparam                VARCHAR2 (100)
         :=    's='
            || p_sseguro
            || '.i='
            || p_cidioma
            || '.t='
            || p_tipo
            || '.c='
            || p_csituac
            || '.r='
            || p_creteni
            || '.f='
            || p_fefecto
            || ' .t='
            || p_tabla;
      vobject               VARCHAR2 (200)
                                          := 'PAC_SEGUROS.ff_Situacion_Poliza';
      ret_v_subestadoprop   NUMBER;                                   --ramiro
      v_subestadoprop       VARCHAR (500);                            --ramiro
   --
   BEGIN
      vpasexec := 1;
      vpasexec := 2;

      -- Bug27429 - 27/01/2014 - JTT: Buscamos en la tabla de SEGUROS o ESTSEGUROS
      IF p_tabla = 'EST'
      THEN
         SELECT NVL (p_csituac, csituac), NVL (p_creteni, creteni),
                NVL (p_fefecto, fefecto)
           INTO vcsituac, vcreteni,
                vfefecto
           FROM estseguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT NVL (p_csituac, csituac), NVL (p_creteni, creteni),
                NVL (p_fefecto, fefecto)
           INTO vcsituac, vcreteni,
                vfefecto
           FROM seguros
          WHERE sseguro = p_sseguro;
      END IF;

      -- Fi Bug27429

      -- BUG13352:DRA:06/04/2010:Fi
      vpasexec := 3;

      IF p_tipo = 1
      THEN                                                   -- solo situacion
         vpasexec := 4;

         -- bug 10831.NMM.01/2009.
         SELECT tatribu
           INTO vf
           FROM detvalores
          WHERE cvalor = 61 AND catribu = vcsituac AND cidioma = p_cidioma;

         vpasexec := 5;
         RETURN (vf);
      END IF;

      IF vcsituac = 0
      THEN
         vpasexec := 6;

         IF vcreteni = 0
         THEN
            vpasexec := 7;

            IF TRUNC (f_sysdate) < TRUNC (vfefecto)
            THEN                          -- -- bug 10831.NMM.01/2009. > => <
               vpasexec := 8;
               vestado := 13;                      -- futura entrada en vigor
            ELSE
               vpasexec := 9;
               vestado := 1;                                       -- vigente
            END IF;
         ELSIF vcreteni = 1
         THEN
            vpasexec := 10;
            vestado := 2;                                         -- retenida
         ELSIF vcreteni = 6
         THEN
            vpasexec := 101;
            vestado := 19;             -- retenida por env¿o fallido a la erp
         --BUG27048/150505 - DCT - 05/08/2013 - Inicio -
         ELSIF vcreteni = 21
         THEN
            vpasexec := 19;
            vestado := 34;       -- Pendiente de finalizar proceso de emisi¿n
         --BUG27048/150505 - DCT - 05/08/2013 - Fin -
         -- Bug 30448/0169858 - APD - 17/03/2014
         ELSIF vcreteni = 22
         THEN
            vpasexec := 20;
            vestado := 35;
         -- Pendiente de finalizar proceso de ejecucion suplementos diferidos
         -- fin Bug 30448/0169858 - APD - 17/03/2014
         END IF;
      ELSIF vcsituac = 2
      THEN
         vpasexec := 11;
         vestado := 8;                                             -- Anulada
      ELSIF vcsituac = 3
      THEN
         vpasexec := 12;
         vestado := 9;                                             -- Vencida
      ELSIF vcsituac = 4
      THEN
         vpasexec := 13;

         IF vcreteni = 0
         THEN
            vpasexec := 14;
            vestado := 3;                                       -- Prop. Alta
         ELSIF vcreteni = 2
         THEN
            vpasexec := 15;
            vestado := 4;                               -- Prop. Pdte. Autor.
         ELSIF vcreteni = 4
         THEN
            vpasexec := 16;
            vestado := 5;                                    -- Prop. Anulada
         ELSIF vcreteni = 3
         THEN
            vpasexec := 17;
            vestado := 6;                                -- Prop. No Aceptada
         ELSIF vcreteni = 1
         THEN
            vpasexec := 18;
            vestado := 7;                                   -- Prop. Retenida
         ELSIF vcreteni = 7
         THEN
            vpasexec := 19;
            vestado := 23;                         -- Pdte. Inspecci¿n riesgo
         ELSIF vcreteni = 8
         THEN
            vpasexec := 19;
            vestado := 24;                            -- Inspecci¿n rechazada
         ELSIF vcreteni = 9
         THEN
            vpasexec := 19;
            vestado := 25;                             -- Inspecci¿n aprobada
         ELSIF vcreteni = 10
         THEN
            vpasexec := 19;
            vestado := 26;   -- Pendiente autorizaci¿n e inspecci¿n de riesgo
         ELSIF vcreteni = 11
         THEN
            vpasexec := 19;
            vestado := 27;
         -- Pendiente autorizaci¿n e inspecci¿n de riesgo - inspecci¿n rechazada
         ELSIF vcreteni = 12
         THEN
            vpasexec := 19;
            vestado := 28;
         -- Pendiente autorizaci¿n e inspecci¿n de riesgo - inspecci¿n aprobada
         ELSIF vcreteni = 13
         THEN
            vpasexec := 19;
            vestado := 29;
         -- Pendiente autorizaci¿n (PSU critica) e inspecci¿n de riesgo
         ELSIF vcreteni = 14
         THEN
            vpasexec := 19;
            vestado := 30;            -- Autorizada - Pdte. Inspecci¿n riesgo
         ELSIF vcreteni = 15
         THEN
            vpasexec := 19;
            vestado := 31;                -- Autorizada - Inspecci¿n aprobada
         ELSIF vcreteni = 16
         THEN
            vpasexec := 19;
            vestado := 32;               -- Autorizada - Inspecci¿n rechazada
         --BUG27048/150505 - DCT - 05/08/2013 - Inicio -
         ELSIF vcreteni = 21
         THEN
            vpasexec := 19;
            vestado := 34;       -- Pendiente de finalizar proceso de emisi¿n
         --BUG27048/150505 - DCT - 05/08/2013 - Fin -
         -- Bug 30448/0169858 - APD - 17/03/2014
         ELSIF vcreteni = 22
         THEN
            vpasexec := 20;
            vestado := 35;
         -- Pendiente de finalizar proceso de ejecucion suplementos diferidos
         -- fin Bug 30448/0169858 - APD - 17/03/2014
         END IF;
      --edit detvalores where cvalor = 66 and catribu > 6 and cidioma = 2
      ELSIF vcsituac = 5
      THEN
         vpasexec := 19;

         IF vcreteni = 0
         THEN
            vpasexec := 20;
            vestado := 10;                                    --Prop. Suplem.
         ELSIF vcreteni = 1
         THEN
            vpasexec := 21;
            vestado := 11;                              -- Prop. Suplem. Ret.
         ELSIF vcreteni = 2
         THEN
            vpasexec := 22;
            vestado := 12;                      -- Prop. Suplem. Pdte. Autor.
         ELSIF vcreteni = 7
         THEN
            vpasexec := 19;
            vestado := 23;                         -- Pdte. Inspecci¿n riesgo
         ELSIF vcreteni = 8
         THEN
            vpasexec := 19;
            vestado := 24;                            -- Inspecci¿n rechazada
         ELSIF vcreteni = 9
         THEN
            vpasexec := 19;
            vestado := 25;                             -- Inspecci¿n aprobada
         ELSIF vcreteni = 10
         THEN
            vpasexec := 19;
            vestado := 26;   -- Pendiente autorizaci¿n e inspecci¿n de riesgo
         ELSIF vcreteni = 11
         THEN
            vpasexec := 19;
            vestado := 27;
         -- Pendiente autorizaci¿n e inspecci¿n de riesgo - inspecci¿n rechazada
         ELSIF vcreteni = 12
         THEN
            vpasexec := 19;
            vestado := 28;
         -- Pendiente autorizaci¿n e inspecci¿n de riesgo - inspecci¿n aprobada
         ELSIF vcreteni = 13
         THEN
            vpasexec := 19;
            vestado := 29;
         -- Pendiente autorizaci¿n (PSU critica) e inspecci¿n de riesgo
         ELSIF vcreteni = 14
         THEN
            vpasexec := 19;
            vestado := 30;            -- Autorizada - Pdte. Inspecci¿n riesgo
         ELSIF vcreteni = 15
         THEN
            vpasexec := 19;
            vestado := 31;                -- Autorizada - Inspecci¿n aprobada
         ELSIF vcreteni = 16
         THEN
            vpasexec := 19;
            vestado := 32;               -- Autorizada - Inspecci¿n rechazada
         --BUG26488/147026 - DCT - 16/06/2013 - Inicio -
         ELSIF vcreteni = 20
         THEN
            vpasexec := 19;
            vestado := 33;          -- Pendiente de finalizar proceso interno
         --BUG26488/147026 - DCT - 16/06/2013 - Fin -
         --BUG27048/150505 - DCT - 05/08/2013 - Inicio -
         ELSIF vcreteni = 21
         THEN
            vpasexec := 19;
            vestado := 34;       -- Pendiente de finalizar proceso de emisi¿n
         --BUG27048/150505 - DCT - 05/08/2013 - Fin -
         -- Bug 30448/0169858 - APD - 17/03/2014
         ELSIF vcreteni = 22
         THEN
            vpasexec := 20;
            vestado := 35;
         -- Pendiente de finalizar proceso de ejecucion suplementos diferidos
         -- fin Bug 30448/0169858 - APD - 17/03/2014
         END IF;
      ELSIF vcsituac = 7
      THEN                                             --Proposta Alta anulada
         vpasexec := 19;

         IF vcreteni = 4
         THEN
            vpasexec := 22;
            vestado := 5;                            -- Anul¿laci¿ Prop. Alta
         END IF;
      ELSIF vcsituac = 12
      THEN
         vestado := 14;                                   -- Projecte Gen¿ric
      ELSIF vcsituac = 13
      THEN
         vestado := 15;                          -- Anulaci¿ Projecte Gen¿ric
      ELSIF vcsituac = 14
      THEN
         vestado := 16;                                   -- Nota informativa
      ELSIF vcsituac = 15
      THEN
         vestado := 17;                          -- Anulaci¿ Nota informativa
      ELSIF vcsituac = 16
      THEN
         vestado := 18;                                         -- Traspasada
      -- Bug 23940 - APD - 06/11/2012 - se a¿ade el csituac = 17.-Prop. cartera
      ELSIF vcsituac = 17
      THEN
         vpasexec := 25;

         IF vcreteni = 0
         THEN
            vpasexec := 26;
            vestado := 20;                                    --Prop. Cartera
         ELSIF vcreteni = 1
         THEN
            vpasexec := 27;
            vestado := 21;                              -- Prop. Cartera Ret.
         ELSIF vcreteni = 2
         THEN
            vpasexec := 28;
            vestado := 22;                      -- Prop. Cartera Pdte. Autor.
         END IF;
      -- fin Bug 23940 - APD - 06/11/2012
      -- Ini IAXIS-3631  -- ECP -- 13/05/2019
      ELSIF vcsituac = 18
      THEN
         vestado := 9;                                             -- Vencida
      -- Ini IAXIS-3592  -- ECP -- 15/05/2019
      ELSIF vcsituac = 19
      THEN
         vestado := 36;                   -- Cancelación de póliza por Impago
      END IF;

      -- Fin IAXIS-3592  -- ECP -- 15/05/2019
      -- Ini IAXIS-3631  -- ECP -- 13/05/2019
      vpasexec := 23;

      SELECT tatribu
        INTO vf
        FROM detvalores
       WHERE cvalor = 251 AND catribu = vestado AND cidioma = p_cidioma;

      vpasexec := 24;

      IF p_tipo = 2
      THEN                                                           -- Estado
         vpasexec := 25;
         ret_v_subestadoprop :=
                     pac_psu.f_get_subestadoprop (p_sseguro, v_subestadoprop);
         --ramiro
         RETURN (vf || '/' || v_subestadoprop);                      --ramiro
      END IF;

      vpasexec := 26;
      vincidencias := ff_incidencias_poliza (p_sseguro, p_cidioma, vcsituac);

      IF vincidencias IS NOT NULL
      THEN
         vpasexec := 27;
         vf := vf || ' / ' || vincidencias;
      END IF;

      vpasexec := 28;
      RETURN (vf);
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN (101919);
   END ff_situacion_poliza;

   --BUG 10831.f.
   /*************************************************************************
      Funci¿n devuelve la lista de incidencias de una poliza
      param in psseguro  : sseguro
      param in pcidioma  : idioma
      param in pcsituac  : csituac de seguros (default NULL)
      return             : literal con las incidencias
      --BUG 10831
   *************************************************************************/
   FUNCTION ff_incidencias_poliza (
      p_sseguro   IN   NUMBER,
      p_cidioma   IN   NUMBER,
      p_csituac   IN   NUMBER DEFAULT NULL,
      p_incis     IN   NUMBER DEFAULT 0
   )
      RETURN VARCHAR2
   IS
      vcsituac     NUMBER;
      vtincide     VARCHAR2 (100);
      vretorno     VARCHAR2 (100);
      vpasexec     NUMBER                     := 0;
      vcblopag     seguros_ren.cblopag%TYPE;
      vtraspasos   NUMBER;
      v_conta      NUMBER;
      v_pregunta   NUMBER;
      vparam       VARCHAR2 (100)
             := 's=' || p_sseguro || '.i=' || p_cidioma || '.c=' || p_csituac;
      vobject      VARCHAR2 (200)      := 'PAC_SEGUROS.FF_Incidencias_Poliza';
   --
   BEGIN
      vpasexec := 1;

      IF p_csituac IS NULL
      THEN
         vpasexec := 2;

         BEGIN
            SELECT csituac
              INTO vcsituac
              FROM seguros
             WHERE sseguro = p_sseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT csituac
                    INTO vcsituac
                    FROM estseguros
                   WHERE sseguro = p_sseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     vcsituac := 0;
               END;
         END;
      ELSE
         vpasexec := 3;
         vcsituac := p_csituac;
      END IF;

      IF vcsituac IN (2, 3)
      THEN                                        -- Si esta anulada o vencida
         vpasexec := 4;
         RETURN NULL;
      END IF;

      vpasexec := 5;

      -- BUG10772:DRA:24/02/2010:Inici
      IF pac_anulacion.f_esta_prog_anulproxcar (p_sseguro) = 1
      THEN
         vpasexec := 51;
         vtincide := f_axis_literales (9001407, p_cidioma);

         --Anulaci¿n prog. a pr¿x. recibo
         IF vtincide IS NOT NULL
         THEN
            vpasexec := 52;
            vretorno := vtincide;
            vtincide := NULL;
         END IF;
      ELSE
         vpasexec := 6;

         IF pac_anulacion.f_esta_anulada_vto (p_sseguro) = 1
         THEN
            vpasexec := 61;
            vtincide := f_axis_literales (151882, p_cidioma);

            --Anulaci¿n programada al vto.
            IF vtincide IS NOT NULL
            THEN
               vpasexec := 62;
               vretorno := vtincide;
               vtincide := NULL;
            END IF;
         END IF;
      END IF;

      -- BUG10772:DRA:24/02/2010:Fi
      vpasexec := 8;

      IF pac_ctaseguro.f_esta_reducida (p_sseguro) = 1
      THEN
         IF    p_incis <> 1
            OR NVL
                  (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'VER_INCIS_POL'
                                           ),
                   0
                  ) = 0
         THEN
            vpasexec := 9;
            vtincide := f_axis_literales (9002051, p_cidioma);     --Reducida

            IF vretorno IS NULL
            THEN
               vpasexec := 10;
               vretorno := vtincide;
            ELSE
               vpasexec := 11;
               vretorno := vretorno || ' - ' || vtincide;
            END IF;
         END IF;
      END IF;

      vpasexec := 12;

      IF f_bloquea_pignorada (p_sseguro, f_sysdate) = 1
      THEN
         vpasexec := 13;
         vtincide := f_axis_literales (9002052, p_cidioma);       --Bloqueada

         IF vretorno IS NULL
         THEN
            vpasexec := 14;
            vretorno := vtincide;
         ELSE
            vpasexec := 15;
            vretorno := vretorno || ' - ' || vtincide;
         END IF;
      END IF;

      vpasexec := 16;

      IF f_bloquea_pignorada (p_sseguro, f_sysdate) = 2
      THEN
         vpasexec := 17;
         vtincide := f_axis_literales (9002053, p_cidioma);       --Pignorada

         IF vretorno IS NULL
         THEN
            vpasexec := 18;
            vretorno := vtincide;
         ELSE
            vpasexec := 19;
            vretorno := vretorno || ' - ' || vtincide;
         END IF;
      END IF;

      IF NVL
            (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                            'VAL_TEXTINCIDE_PIGNO'
                                           ),
             0
            ) = 1
      THEN
         BEGIN
            SELECT COUNT (*)
              INTO v_conta
              FROM benespseg
             WHERE sseguro = p_sseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_conta := 0;
         END;

         v_pregunta :=
                    pac_preguntas.ff_buscapregunpolseg (p_sseguro, 1942, NULL);

         IF v_pregunta = 2
         THEN
            BEGIN
               SELECT tclatit
                 INTO vtincide
                 FROM clausugen
                WHERE sclagen = 1900
                  AND cidioma = pac_md_common.f_get_cxtidioma;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vtincide := NULL;
            END;

            IF vtincide IS NOT NULL
            THEN
               vretorno := vretorno || ' - ' || vtincide;
            END IF;
         ELSIF v_conta > 0
         THEN
            IF vretorno IS NULL
            THEN
               vretorno :=
                    f_axis_literales (9001911, pac_md_common.f_get_cxtidioma);
            ELSE
               vretorno :=
                     vretorno
                  || ' - '
                  || f_axis_literales (9001911, pac_md_common.f_get_cxtidioma);
            END IF;
         END IF;
      END IF;

      vpasexec := 24;

      -- Bug. 12915 18/03/2010 ASN -- inicio
      BEGIN
         SELECT cblopag
           INTO vcblopag
           FROM seguros_ren
          WHERE sseguro = p_sseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      IF vcblopag = 5
      THEN
         vpasexec := 25;
         vtincide := f_axis_literales (9901077, p_cidioma);

         -- Rentas bloqueadas
         IF vretorno IS NULL
         THEN
            vpasexec := 26;
            vretorno := vtincide;
         ELSE
            vpasexec := 27;
            vretorno := vretorno || ' - ' || vtincide;
         END IF;
      END IF;

      BEGIN
         SELECT COUNT (*)
           INTO vtraspasos
           FROM trasplainout
          WHERE sseguro = p_sseguro AND cestado IN (1, 2);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      IF vtraspasos > 0
      THEN
         vpasexec := 28;
         vtincide := f_axis_literales (9901078, p_cidioma);

         -- traspasos pendientes
         IF vretorno IS NULL
         THEN
            vpasexec := 28;
            vretorno := vtincide;
         ELSE
            vpasexec := 29;
            vretorno := vretorno || ' - ' || vtincide;
         END IF;
      END IF;

      -- Bug. 12915 18/03/2010 ASN -- fin

      -- BUG 0024450/0129646 - FAL - 15/11/2012
      IF f_suspendida (p_sseguro, f_sysdate) = 1
      THEN
         vpasexec := 13;
         vtincide := f_axis_literales (9904528, p_cidioma);      --Suspendida

         IF vretorno IS NULL
         THEN
            vpasexec := 30;
            vretorno := vtincide;
         ELSE
            vpasexec := 31;
            vretorno := vretorno || ' - ' || vtincide;
         END IF;
      END IF;

      -- FI BUG 0024450/0129646
      RETURN (vretorno);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN (NULL);
   END ff_incidencias_poliza;

-- BUG 0024450/0129646 - FAL - 15/11/2012
   /*************************************************************************
      Funci¿n devuelve 1 si la polixa esta suspendida
      param in psseguro  : sseguro
      param in pfvalmov  : fecha a evaluar si esta suspendida
      return             : 0 si vigente, 1 si suspendida
   *************************************************************************/
   FUNCTION f_suspendida (psseguro IN NUMBER, pfvalmov IN DATE)
      RETURN NUMBER
   IS
      fecha_susp       DATE;
      fecha_fin_susp   DATE;
      mov_susp         NUMBER;
      fecha_reini      DATE;
   BEGIN
      --------Control que la p¿liza est¿ bloqueada
      BEGIN
         SELECT MAX (finicio), MAX (nmovimi), MAX (ffinal)
           INTO fecha_susp, mov_susp, fecha_fin_susp
           FROM suspensionseg
          WHERE sseguro = psseguro AND finicio <= pfvalmov AND cmotmov = 391;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      END;

      --
      IF fecha_susp IS NOT NULL
      THEN
         BEGIN
            SELECT MAX (finicio)
              INTO fecha_reini               -- buscamos si reinicio posterior
              FROM suspensionseg
             WHERE sseguro = psseguro
               AND cmotmov = pac_suspension.vcod_reinicio
               -- CONF-274-25/11/2016-JLTS- Se cambis 392 por vreinicio
               AND finicio >= fecha_susp
               AND nmovimi > mov_susp;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN 1;                  -- no hay reinicio, est¿ suspendida
         END;
      END IF;

      IF (fecha_susp IS NOT NULL AND fecha_reini IS NULL)
      THEN
         RETURN 1;                                              -- suspendida
      END IF;

      RETURN 0;
   END f_suspendida;

-- FI BUG 0024450/0129646

   /*************************************************************************
     Recupera la fecha de vencimiento de una garant¿a si tiene parametrizada
     la pregunta 1043 indicada en el par¿metro de producto 'CPREGUN_VTOGARAN'.
     En caso de no tener vencimiento la garant¿a retornar¿ NULL.

     param in psseguro  : codigo de seguro
     param in pnriesgo  : codigo de riesgo
     param in pcgarant  : codigo de garant¿a
     param in pnmovimi  : codigo de movimiento
     param in ptablas   : tablas a acceder ('EST' o NULL)
     return             : DATE
   *************************************************************************/
   -- Bug 7926 - 25/05/2009 - RSC - APR - Fecha de vencimiento a nivel de garant¿a
   FUNCTION f_vto_garantia (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT NULL
   )
      RETURN DATE
   IS
      v_vto       pregungaranseg.crespue%TYPE;
      v_sproduc   seguros.sproduc%TYPE;
   BEGIN
      -- Miraremos si tiene contratada o no la garant¿a 2116 (forfait)
      IF ptablas = 'EST' OR ptablas = 'SOL'
      THEN
         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT crespue
              INTO v_vto
              FROM estpregungaranseg e
             WHERE e.cpregun =
                              f_parproductos_v (v_sproduc, 'CPREGUN_VTOGARAN')
               -- AND   f_parproductos_v(v_sproduc, 'CPREGUN_VTOGARAN') IS NOT NULL
               AND e.sseguro = psseguro
               AND e.nriesgo = pnriesgo
               AND e.cgarant = pcgarant
               AND e.nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN NULL;
         END;
      ELSE
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         BEGIN
            SELECT crespue
              INTO v_vto
              FROM pregungaranseg p
             WHERE p.cpregun =
                              f_parproductos_v (v_sproduc, 'CPREGUN_VTOGARAN')
               --     AND   f_parproductos_v(v_sproduc, 'CPREGUN_VTOGARAN') IS NOT NULL
               AND p.sseguro = psseguro
               AND p.nriesgo = pnriesgo
               AND p.cgarant = pcgarant
               AND p.nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN NULL;
         END;
      END IF;

      RETURN TO_DATE (v_vto, 'YYYYMMDD');
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_PROPIO_ALBSGT_APR.F_vto_garantia',
                      1,
                         'psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pcgarant = '
                      || pcgarant
                      || ' pnmovimi = '
                      || pnmovimi
                      || ' ptablas = '
                      || ptablas,
                      SQLERRM
                     );
         RETURN NULL;
   END f_vto_garantia;

-- Fin Bug 7926
   -- BUG : 13038 - 22-02-2010 - JMC - Se a¿ade funcion.
   /***************************************************************************
      FUNCTION f_get_renovacion
      Dado un sseguro, obtenemos si ha renovado o no 0- NO 1- SI
         param in  psseguro:  sseguro de la p¿liza.
         return:              0- NO 1- SI.
   ***************************************************************************/
   FUNCTION f_get_renovacion (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      v_cont   NUMBER;
   BEGIN
      SELECT DECODE (COUNT (*), 0, 0, 1)
        INTO v_cont
        FROM movseguro
       WHERE sseguro = psseguro AND cmovseg = 2;

      RETURN v_cont;
   END f_get_renovacion;

-- FIN BUG : 13038 - 22-02-2010 - JMC

   -- Bug 16106 - 11-10-2010 - RSC
   /***************************************************************************
      FUNCTION f_get_escertifcero
      Dado un npoliza, nos indica si existe el ncertif = 0
      Dado un sseguro, nos indica si ese sseguro es el ncertif = 0
         param in  pnpoliza:  numero de la p¿liza.
         param in  psseguro:  sseguro de la p¿liza.
         return:              0- NO 1- SI.
   ***************************************************************************/
   -- Bug 23817 - APD - 27/09/2012 - se a¿ade el psseguro
   FUNCTION f_get_escertifcero (
      pnpoliza   IN   NUMBER,
      psseguro   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      v_cont   NUMBER;
   BEGIN
      IF pnpoliza IS NOT NULL
      THEN
         -- Indica que existe el certificado 0
         SELECT COUNT (*)
           INTO v_cont
           FROM seguros
          WHERE npoliza = pnpoliza AND ncertif = 0;
      ELSIF psseguro IS NOT NULL
      THEN
         -- Indica que es el certificado 0 (util siempre y cuando el producto
         -- admita certificados (parproducto 'ADMITE_CERTIFICADOS' = 1))
         SELECT COUNT (*)
           INTO v_cont
           FROM seguros
          WHERE sseguro = psseguro AND ncertif = 0;
      END IF;

      RETURN v_cont;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SEGUROS.f_get_escertifcero',
                      1,
                      'pnpoliza = ' || pnpoliza || ';psseguro = ' || psseguro,
                      SQLERRM
                     );
         RETURN NULL;
   END f_get_escertifcero;

-- Fin Bug 16106

   -- Bug 16768 - APD - 22-11-2010 - se crea la funcion f_get_agentecol
   /***************************************************************************
      FUNCTION f_get_agentecol
      Dado un numero de poliza, obtenemos el codigo del agente de su certificado 0
         param in  pnpoliza:  numero de la p¿liza.
         return:              NUMBER.
   ***************************************************************************/
   FUNCTION f_get_agentecol (pnpoliza IN NUMBER)
      RETURN NUMBER
   IS
      v_cagente   seguros.cagente%TYPE;
   BEGIN
      SELECT cagente
        INTO v_cagente
        FROM seguros
       WHERE npoliza = pnpoliza AND ncertif = 0;

      RETURN v_cagente;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SEGUROS.f_get_agentecol',
                      1,
                      'pnpoliza = ' || pnpoliza,
                      SQLERRM
                     );
         RETURN NULL;
   END f_get_agentecol;

-- Fin Bug 16768 - APD - 22-11-2010

   -- Bug 16768 - APD - 22-11-2010 - se crea la funcion f_get_cforpagcol
   /***************************************************************************
      FUNCTION f_get_cforpagcol
      Dado un numero de poliza, obtenemos la forma de pago de su certificado 0
         param in  pnpoliza:  numero de la p¿liza.
         return:              NUMBER.
   ***************************************************************************/
   FUNCTION f_get_cforpagcol (pnpoliza IN NUMBER)
      RETURN NUMBER
   IS
      v_cforpag   seguros.cforpag%TYPE;
   BEGIN
      SELECT cforpag
        INTO v_cforpag
        FROM seguros
       WHERE npoliza = pnpoliza AND ncertif = 0;

      RETURN v_cforpag;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SEGUROS.f_get_cforpagcol',
                      1,
                      'pnpoliza = ' || pnpoliza,
                      SQLERRM
                     );
         RETURN NULL;
   END f_get_cforpagcol;

-- Fin Bug 16768 - APD - 22-11-2010

   -- Bug 0019444 - 12/09/2011 - JMF
   /***************************************************************************
      FUNCTION f_tiene_garanahorro
      Comprueba si tiene una garantia de ahorro contratada
         param in  pnrecibo: numero de recibo.
         param in  psseguro: numero seguro
         paran in  pfecha: fecha a comprobar
         return:  0-No, 1-Si
   ***************************************************************************/
   FUNCTION f_tiene_garanahorro (
      pnrecibo   IN   NUMBER,
      psseguro   IN   NUMBER,
      pfecha     IN   DATE DEFAULT f_sysdate
   )
      RETURN NUMBER
   IS
      vobject    VARCHAR2 (200)         := 'PAC_SEGUROS.F_TIENE_GARANAHORRO';
      vpasexec   NUMBER                 := 0;
      vparam     VARCHAR2 (100)
                  := 'r=' || pnrecibo || ' s=' || psseguro || ' f=' || pfecha;
      n_numerr   NUMBER (1);
      n_seg      seguros.sseguro%TYPE;
   BEGIN
      vpasexec := 1;

      IF pnrecibo IS NULL AND psseguro IS NULL
      THEN
         RAISE NO_DATA_FOUND;
      ELSIF psseguro IS NOT NULL
      THEN
         n_seg := psseguro;
      ELSIF pnrecibo IS NOT NULL
      THEN
         vpasexec := 3;

         SELECT MAX (sseguro)
           INTO n_seg
           FROM recibos
          WHERE nrecibo = pnrecibo;
      END IF;

      SELECT NVL (MAX (1), 0)
        INTO n_numerr
        FROM seguros b, garanseg c
       WHERE b.sseguro = n_seg
         AND pfecha BETWEEN c.finiefe AND NVL (c.ffinefe, pfecha)
         AND c.sseguro = b.sseguro
         AND f_pargaranpro_v (b.cramo,
                              b.cmodali,
                              b.ctipseg,
                              b.ccolect,
                              b.cactivi,
                              c.cgarant,
                              'TIPO'
                             ) IN (3, 4);

      RETURN n_numerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN NULL;
   END f_tiene_garanahorro;

   -- BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
    /***********************************************************************
        Ens retorna si ¿s de migraci¿n
       el importe del concepto
       param in psseguro    : c¿digo del seguro
       param in tablas       : modo
       psalida              :0 No ¿s migraci¿n
                            1 ¿s migraci¿n
        return                    resto es un c¿digo de error
    ***********************************************************************/
   FUNCTION f_es_migracion (
      psseguro   IN       NUMBER,
      ptablas    IN       VARCHAR2 DEFAULT 'EST',
      psalida    OUT      NUMBER
   )
      RETURN NUMBER
   IS
      e_object_error   EXCEPTION;
      e_param_error    EXCEPTION;
      vobjectname      VARCHAR2 (100)  := 'pac_tarifas.f_es_migracion';
      vparam           VARCHAR2 (2000)
         := 'par¿metros - psseguro: ' || psseguro || ' - ptablas: '
            || ptablas;
      vcrespue         NUMBER;
      vnumerr          NUMBER;
      vpasexec         NUMBER          := 0;
   BEGIN
      --Comprovaci¿ dels par¿metres d'entrada
      IF psseguro IS NULL OR ptablas IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vnumerr :=
          pac_preguntas.f_get_pregunpolseg (psseguro, 4044, ptablas, vcrespue);
      vpasexec := 2;

      IF vnumerr = 120135
      THEN
         psalida := 0;
--Si no encuentra la pregunta , no estamos en migraci¿n y continuamos como si nada
      ELSIF vnumerr = 0
      THEN
         psalida := 1;
      --  Si encuentra la pregunta ,  estamos en migraci¿n y no debe generar derechos de registro
      ELSE
--Error, dif¿icil que suceda, pero por si acaso hacemos un raise para que savuelva a la funci¿n anterior
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'Objeto invocado con par¿metros erroneos'
                     );
         RETURN 101901;
      WHEN e_object_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                         'Error al llamar procedimiento o funci¿n - numerr: '
                      || vnumerr
                     );
         RETURN vnumerr;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 140999;
   END f_es_migracion;

-- Fi BUG 20671-  01/2012 - JRH
   --bfp bug 21808 ini
   FUNCTION ff_frenovacion (
      pnsesion   IN   NUMBER,
      psseguro   IN   NUMBER,
      porigen         NUMBER
   )
      RETURN VARCHAR2
   IS
      vestsproduc   NUMBER (6);
      vsproduc      NUMBER (6);
      v_frenova     DATE;
      vfparprod     NUMBER;
      num_error     NUMBER;
   BEGIN
      IF porigen = 1
      THEN                                             --som a les taules EST
         --obtenim sproduc de la taula estseguros
         SELECT sproduc
           INTO vestsproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         vfparprod :=
                   NVL (f_parproductos_v (vestsproduc, 'PER_REV_NO_ANUAL'), 1);

         IF vfparprod IN (1, 150)
         THEN
            RETURN frenovacion (pnsesion, psseguro, porigen);
         ELSE
            BEGIN
               SELECT TO_DATE (crespue, 'yyyymmdd')
                 INTO v_frenova
                 FROM estpregunpolseg
                WHERE sseguro = psseguro
                  AND nmovimi = (SELECT MAX (nmovimi)
                                   FROM estpregunpolseg
                                  WHERE sseguro = psseguro)
                  AND cpregun = 4778;                -- fecha de la renovaci¿n
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  SELECT fcaranu
                    INTO v_frenova
                    FROM estseguros
                   WHERE sseguro = psseguro;
            END;

            RETURN TO_CHAR (ADD_MONTHS (v_frenova, (-1 * 12 * vfparprod)),
                            'YYYYMMDD'
                           );
         END IF;
      ELSIF porigen = 2
      THEN                                          --som a les taules release
         --obtenim sproduc de la taula seguros
         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         vfparprod := NVL (f_parproductos_v (vsproduc, 'PER_REV_NO_ANUAL'), 1);

         IF vfparprod IN (1, 150)
         THEN
            RETURN frenovacion (pnsesion, psseguro, porigen);
         ELSE
            BEGIN
               SELECT TO_DATE (crespue, 'yyyymmdd')
                 INTO v_frenova
                 FROM pregunpolseg
                WHERE sseguro = psseguro
                  AND nmovimi = (SELECT MAX (nmovimi)
                                   FROM pregunpolseg
                                  WHERE sseguro = psseguro)
                  AND cpregun = 4778;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  SELECT fcaranu
                    INTO v_frenova
                    FROM seguros
                   WHERE sseguro = psseguro;
            END;

            RETURN TO_CHAR (ADD_MONTHS (v_frenova, (-1 * 12 * vfparprod)),
                            'YYYYMMDD'
                           );
         END IF;
      END IF;
   END ff_frenovacion;

--bfp bug 21808 fi

   -- 17/07/2012 - MDS - 0022824: LCOL_T010-Duplicado de propuestas
   FUNCTION f_calcula_npoliza (
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pcramo     IN       NUMBER,
      pcempres   IN       NUMBER,
      pnpoliza   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      v_npoliza_cnv       NUMBER;
      v_npoliza_ini       VARCHAR2 (15);
      v_npoliza_prefijo   NUMBER;
      vntraza             NUMBER;
   BEGIN
      vntraza := 1;
      v_npoliza_cnv :=
                   NVL (f_parproductos_v (psproduc, 'NPOLIZA_CNVPOLIZAS'), 0);
      vntraza := 2;

      IF v_npoliza_cnv IN (1, 2)
      THEN
         vntraza := 3;
         v_npoliza_ini := f_npoliza (NULL, psseguro);

         IF LENGTH (v_npoliza_ini) > 8
         THEN
            RETURN 9901434;
         -- El n¿mero de p¿lissa ha de ser num¿ric i de 8 d¿gits com a m¿xim
         END IF;

         vntraza := 4;

         BEGIN
            pnpoliza := TO_NUMBER (v_npoliza_ini);
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 9901434;
         -- El n¿mero de p¿lissa ha de ser num¿ric i de 8 d¿gits com a m¿xim
         END;

         vntraza := 5;

         IF pnpoliza IS NULL AND v_npoliza_cnv = 2
         THEN
            RETURN 120006;                      -- Error al llegir CNVPOLIZAS
         END IF;
      END IF;

      vntraza := 6;

      IF pnpoliza IS NULL
      THEN
         -- Antes de llamar a la funci¿n f_contador se deber¿ verificar el parproducto 'NPOLIZA_PREFIJO' que devuelva un valor.
         -- En caso de que no est¿ informado se llamar¿ a la f_contador con el cramo,
         -- en caso contrario se deber¿ llamar con el resultado del parproducto
         v_npoliza_prefijo := f_parproductos_v (psproduc, 'NPOLIZA_PREFIJO');
         pnpoliza :=
            pac_propio.f_contador2 (pcempres,
                                    '02',
                                    NVL (v_npoliza_prefijo, pcramo)
                                   );
         pnpoliza :=
              pnpoliza
            + NVL (pac_parametros.f_parempresa_n (pcempres, 'NUMADDPOLIZA'),
                   0);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_seguros.f_calcula_npoliza',
                      vntraza,
                         'psproduc = '
                      || psproduc
                      || ' psseguro = '
                      || psseguro
                      || ' pcramo = '
                      || pcramo
                      || ' pcempres = '
                      || pcempres,
                      SQLERRM
                     );
   END f_calcula_npoliza;

   FUNCTION f_abrir_suplemento (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (100)  := 'PAC_SEGUROS.f_abrir_suplemento';
      vparam        VARCHAR2 (2000) := 'parametros - psseguro: ' || psseguro;
      vnumerr       NUMBER;
      vpasexec      NUMBER          := 0;
      v_mov         NUMBER;
      v_mov_ant     NUMBER;

      CURSOR c_cert0
      IS
         SELECT sseguro, csituac, creteni, npoliza, ncertif, fefecto,
                cempres, sproduc, nsuplem, fcarpro
           FROM seguros
          WHERE sseguro = psseguro AND csituac = 0 AND creteni = 0;
   BEGIN
      IF psseguro IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      '1000005'
                     );
         RETURN 1000005;
      END IF;

      vpasexec := 1;

      IF pac_seguros.f_suspendida (psseguro, f_sysdate) = 1
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      '9904861'
                     );
         RETURN 9904861;
      ELSE
         FOR r0 IN c_cert0
         LOOP
            vpasexec := 2;
            vnumerr :=
               f_movseguro
                  (r0.sseguro,
                   NULL,
                   996,
                   1,
                   LEAST
                      (GREATEST
                          (pac_movseguro.f_get_fefecto
                                   (r0.sseguro,
                                    pac_movseguro.f_nmovimi_valido (r0.sseguro)
                                   ),
                           f_sysdate
                          ),
                       NVL (r0.fcarpro, f_sysdate)
                      ),
                   NULL,
                   r0.nsuplem + 1,
                   0,
                   NULL,
                   v_mov,
                   NULL,
                   NULL,
                   998
                  );

            IF vnumerr <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobjectname,
                            vpasexec,
                            vparam,
                            vnumerr
                           );
               RETURN vnumerr;
            END IF;

            vpasexec := 3;

            -- Bug 26151 - APD - 22/02/2013 - se guarda el historico del movimiento anterior
            SELECT MAX (nmovimi)
              INTO v_mov_ant
              FROM movseguro
             WHERE sseguro = r0.sseguro AND nmovimi < v_mov AND cmovseg <> 52;

            -- no anulado
            vnumerr := f_act_hisseg (r0.sseguro, v_mov_ant);

            IF vnumerr <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobjectname,
                            vpasexec,
                            vparam,
                            vnumerr
                           );
               RETURN vnumerr;
            END IF;

            vpasexec := 4;

            -- fin Bug 26151 - APD - 22/02/2013
            UPDATE seguros
               SET csituac = 5
             WHERE sseguro = r0.sseguro;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      '1000005'
                     );
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      SQLCODE || '-' || SQLERRM
                     );
         RETURN 1;
   END f_abrir_suplemento;

   PROCEDURE p_emitir_propuesta_col (
      pcempres    IN       NUMBER,
      pnpoliza    IN       NUMBER,
      pncertif    IN       NUMBER,
      pcramo      IN       NUMBER,
      pcmodali    IN       NUMBER,
      pctipseg    IN       NUMBER,
      pccolect    IN       NUMBER,
      pcactivi    IN       NUMBER,
      pmoneda     IN       NUMBER,
      pcidioma    IN       NUMBER,
      pindice     OUT      NUMBER,
      pindice_e   OUT      NUMBER,
      pcmotret    OUT      NUMBER,                   -- BUG9640:DRA:16/04/2009
      psproces    IN       NUMBER DEFAULT NULL,
      pnordapo    IN       NUMBER DEFAULT NULL,
      pcommit     IN       NUMBER DEFAULT NULL
   )
   IS
      TYPE t_cursor IS REF CURSOR;

      c_pol               t_cursor;
      v_sel               VARCHAR2 (4000);
      v_pol               seguros%ROWTYPE;
      lnmovimi            NUMBER;
      lcmotmov            NUMBER;
      lcmovseg            NUMBER;
      lcdomper            NUMBER;
      lctiprec            NUMBER;
      lctipmov            NUMBER;
      lcforpag            NUMBER;
      lfcanua             DATE;
      lcrevfpg            NUMBER;
      lndiaspro           NUMBER;
      lcprprod            NUMBER;
      --Indica si un producto es de rentas.
      lfaux               DATE;
      lfcapro             DATE;
      lmeses              NUMBER;
      lfvencim            DATE;
      lsproces            NUMBER;
      lgenrec             NUMBER;
      lnumrec             NUMBER;
      lmensaje            VARCHAR2 (500)           := NULL;
      ltexto              VARCHAR2 (400);
      ltexto2             VARCHAR2 (400);
      ltarjet_aln         VARCHAR2 (2);
      lgesdoc             VARCHAR2 (10);
      ddmm                VARCHAR2 (4);
      dd                  VARCHAR2 (2);
      lfefecto            DATE;
      nprolin             NUMBER;
      num_err             NUMBER                   := 0;
      num_err2            NUMBER                   := 0;
      xcimpres            NUMBER;
      lprimera            NUMBER;
      lnomesextra         NUMBER;
      lctipefe            NUMBER;
      fecha_aux           DATE;
      l_fefecto_1         DATE;
      lcsubpro            NUMBER;
      v_ncertif           NUMBER;
      v_npoliza           NUMBER                   := NULL;
      -- Bug 5467 - 10/02/2009 - RSC - CRE - Desarrollo de sistema de copago
      v_npoliza_prefijo   NUMBER;
      -- Bug 22839/0120953 - FAL - 27/08/2012
      err                 NUMBER;
      v_crespue_4084      NUMBER;
      v_crespue_4790      NUMBER;
      -- FI Bug 22839/0120953 - FAL - 27/08/2012
      vmensajes           t_iax_mensajes;
      --BUG 23854: DCT: 12-12-2012: INICIO
      v_funcion           VARCHAR2 (50);
      ss                  VARCHAR2 (3000);
      v_sproces           NUMBER;
      v_sseguro           seguros.sseguro%TYPE;
      v_fefecto           VARCHAR2 (10);
      v_nmovimi           movseguro.nmovimi%TYPE;
      --BUG 23854: DCT: 12-12-2012: FIN
      v_tmensaje          VARCHAR2 (500);     -- BUG 27642 - FAL - 30/04/2014
      v_poliza_ant        seguros.npoliza%TYPE;            --BUG 34409/203137
   BEGIN
      --lnordapo := pnordapo;  --eliminar
      pindice := 0;
      pindice_e := 0;
      pcmotret := NULL;                             -- BUG9640:DRA:16/04/2009
      -- Obtenci¿ de par¿metres per instal.laci¿
      ltarjet_aln := NVL (f_parinstalacion_t ('TARJET_ALN'), 'NO');
      lgesdoc := NVL (f_parinstalacion_t ('GESTDOC'), 'NO');
      -- Selecci¿ din¿mica de les p¿lisses a emetre
      v_sel :=
            'SELECT  * '
         || ' FROM seguros '
         || ' WHERE creteni = 0 '
         || '   AND (csituac = 4 OR csituac = 5)'
         || '   AND f_produsu(cramo, cmodali, ctipseg, ccolect, 2) = 1 ';

      IF pcempres IS NOT NULL
      THEN
         v_sel := v_sel || ' AND cempres = ' || pcempres;
      END IF;

      IF pnpoliza IS NOT NULL
      THEN
         v_sel := v_sel || ' AND npoliza = ' || pnpoliza;
      END IF;

      IF pncertif IS NOT NULL
      THEN
         v_sel := v_sel || ' AND ncertif = ' || pncertif;
      END IF;

      IF pcramo IS NOT NULL
      THEN
         v_sel := v_sel || ' AND cramo   = ' || pcramo;
      END IF;

      IF pcmodali IS NOT NULL
      THEN
         v_sel := v_sel || ' AND cmodali = ' || pcmodali;
      END IF;

      IF pctipseg IS NOT NULL
      THEN
         v_sel := v_sel || ' AND ctipseg = ' || pctipseg;
      END IF;

      IF pccolect IS NOT NULL
      THEN
         v_sel := v_sel || ' AND ccolect = ' || pccolect;
      END IF;

      -- Bug 9164 - 30/03/2009 - svj - Permitir en nueva producci¿n escoger la actividad.
      --IF pcactivi IS NOT NULL THEN
      --   v_sel := v_sel || ' AND cactivi = ' || pcactivi;
      --END IF;
      BEGIN
         lprimera := 1;

         OPEN c_pol FOR v_sel;

         LOOP
            FETCH c_pol
             INTO v_pol;

            EXIT WHEN c_pol%NOTFOUND;
            -- Parproducto = NOMESEXTRA
            -- El producte diu si a la nova producci¿ nom¿s tenim extra
            -- i grava el rebut amb ctiprec = 0 i no ctiprec = 4
            num_err :=
                    f_parproductos (v_pol.sproduc, 'NOMESEXTRA', lnomesextra);
            lnomesextra := NVL (lnomesextra, 0);

            -- la primera vegada cridem a procesini per l'empresa de la p¿lissa
            IF lprimera = 1
            THEN
               lprimera := 0;

               IF psproces IS NULL
               THEN
                  num_err :=
                     f_procesini (f_user,
                                  v_pol.cempres,
                                  'EMISION',
                                  'Emisi¿n de propuestas',
                                  lsproces
                                 );
               ELSE
                  lsproces := psproces;
               END IF;
            END IF;

            SELECT DECODE (v_pol.csituac, 4, 0, 5, 1, NULL)
              INTO v_pol.csituac
              FROM DUAL;

            pindice := pindice + 1;

            -- Miramos el movim. de seg. de ese seguro
            BEGIN
               SELECT nmovimi, fefecto, cmotmov
                 INTO lnmovimi, lfefecto, lcmotmov
                 FROM movseguro
                WHERE sseguro = v_pol.sseguro
                  AND femisio IS NULL
                  AND fanulac IS NULL;
            EXCEPTION
               WHEN TOO_MANY_ROWS
               THEN
                  ROLLBACK;
                  num_err := 1;
                  lmensaje := 103106;               --M¿s de 1 mov. de seguro
                  p_tab_error (f_sysdate,
                               f_user,
                               'p_emitir_propuesta',
                               1,
                                  'pcempres = '
                               || pcempres
                               || ' pnpoliza = '
                               || pnpoliza
                               || ' pncertif = '
                               || pncertif
                               || ' pcramo = '
                               || pcramo
                               || ' pcmodali = '
                               || pcmodali
                               || ' pctipseg = '
                               || pctipseg
                               || ' pccolect = '
                               || pccolect
                               || ' pcactivi = '
                               || pcactivi
                               || ' pmoneda = '
                               || pmoneda
                               || 'pcidioma = '
                               || pcidioma,
                               SQLERRM
                              );
               WHEN NO_DATA_FOUND
               THEN
                  ROLLBACK;
                  num_err := 1;
                  lmensaje := 103107;          --No hay movimientos de seguro
                  p_tab_error (f_sysdate,
                               f_user,
                               'p_emitir_propuesta',
                               2,
                                  'pcempres = '
                               || pcempres
                               || ' pnpoliza = '
                               || pnpoliza
                               || ' pncertif = '
                               || pncertif
                               || ' pcramo = '
                               || pcramo
                               || ' pcmodali = '
                               || pcmodali
                               || ' pctipseg = '
                               || pctipseg
                               || ' pccolect = '
                               || pccolect
                               || ' pcactivi = '
                               || pcactivi
                               || ' pmoneda = '
                               || pmoneda
                               || 'pcidioma = '
                               || pcidioma,
                               SQLERRM
                              );
               WHEN OTHERS
               THEN
                  lmensaje := SQLCODE;
                  ROLLBACK;
                  num_err := 1;                   --Error en la base de datos
                  p_tab_error (f_sysdate,
                               f_user,
                               'p_emitir_propuesta',
                               3,
                                  'pcempres = '
                               || pcempres
                               || ' pnpoliza = '
                               || pnpoliza
                               || ' pncertif = '
                               || pncertif
                               || ' pcramo = '
                               || pcramo
                               || ' pcmodali = '
                               || pcmodali
                               || ' pctipseg = '
                               || pctipseg
                               || ' pccolect = '
                               || pccolect
                               || ' pcactivi = '
                               || pcactivi
                               || ' pmoneda = '
                               || pmoneda
                               || 'pcidioma = '
                               || pcidioma,
                               SQLERRM
                              );
            END;

            -- Miramos si se ha de generar recibo (seg¿n el lmotivo de mov.)
            BEGIN
               SELECT cgenrec
                 INTO lgenrec
                 FROM codimotmov
                WHERE cmotmov = lcmotmov;
            EXCEPTION
               WHEN OTHERS
               THEN
                  num_err := 1;
                  lgenrec := 0;
                  p_tab_error (f_sysdate,
                               f_user,
                               'p_emitir_propuesta',
                               31,
                                  'pcempres = '
                               || pcempres
                               || ' pnpoliza = '
                               || pnpoliza
                               || ' pncertif = '
                               || pncertif
                               || ' pcramo = '
                               || pcramo
                               || ' pcmodali = '
                               || pcmodali
                               || ' pctipseg = '
                               || pctipseg
                               || ' pccolect = '
                               || pccolect
                               || ' pcactivi = '
                               || pcactivi
                               || ' pmoneda = '
                               || pmoneda
                               || 'pcidioma = '
                               || pcidioma,
                               SQLERRM
                              );
            END;

            IF num_err = 0
            THEN
               IF lnmovimi = 1
               THEN
                  lctiprec := 0;                                 --Producci¿n
                  lctipmov := 00;                                        -- "

                  IF     NVL (pac_parametros.f_parempresa_n (v_pol.cempres,
                                                             'MULTIMONEDA'
                                                            ),
                              0
                             ) = 1
                     AND v_pol.cmoneda IS NULL
                  THEN
                     UPDATE seguros
                        SET cmoneda =
                               pac_parametros.f_parempresa_n (v_pol.cempres,
                                                              'MONEDAEMP'
                                                             )
                      WHERE sseguro = v_pol.sseguro;
                  END IF;
               ELSIF lnmovimi > 1
               THEN
                  lctiprec := 1;                                 --Suplemento
                  lctipmov := 01;                                        -- "

                  IF lcmotmov = 298
                  THEN                                -- Suspensi¿ de p¿lissa
                     UPDATE seguros
                        SET csituac = 1,
                            ccartera = NULL
                      WHERE sseguro = v_pol.sseguro;
                  END IF;
               END IF;

               BEGIN
                  SELECT crevfpg, ndiaspro,
                                           --Se recupera ndiaspro para utilizarlo en el c¿lculo de fcarpro.
                                           cprprod,
                                                   -- Indica si un producto es de rentas.
                                                   ctipefe, csubpro
                    -- Para saber qu¿ tipo de renovaci¿n (calcular fcaranu)
                  INTO   lcrevfpg, lndiaspro,
                                             -- Para el c¿lculo de fcarpro.
                                             lcprprod,
                                                      -- Indica si un producto es de rentas.
                                                      lctipefe, lcsubpro
                    FROM productos
                   WHERE cramo = v_pol.cramo
                     AND cmodali = v_pol.cmodali
                     AND ctipseg = v_pol.ctipseg
                     AND ccolect = v_pol.ccolect;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     lmensaje := SQLCODE;
                     num_err := 1;
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'p_emitir_propuesta',
                                  4,
                                     'pcempres = '
                                  || pcempres
                                  || ' pnpoliza = '
                                  || pnpoliza
                                  || ' pncertif = '
                                  || pncertif
                                  || ' pcramo = '
                                  || pcramo
                                  || ' pcmodali = '
                                  || pcmodali
                                  || ' pctipseg = '
                                  || pctipseg
                                  || ' pccolect = '
                                  || pccolect
                                  || ' pcactivi = '
                                  || pcactivi
                                  || ' pmoneda = '
                                  || pmoneda
                                  || 'pcidioma = '
                                  || pcidioma,
                                  SQLERRM
                                 );
               END;

               IF num_err = 0
               THEN
                  --Forma de pago no ¿nica o forma de pago ¿nica con renovaci¿n,
                  --Nueva producci¿n
                  IF     (   v_pol.cforpag <> 0
                          OR (v_pol.cforpag = 0 AND lcrevfpg = 1)
                         )
                     AND v_pol.csituac = 0
                  THEN
                     IF v_pol.cforpag = 0 AND lcrevfpg = 1
                     THEN
                        lcforpag := 1;
                     -- que calcule las fechas como si fuera pago anual
                     ELSE
                        lcforpag := v_pol.cforpag;
                     END IF;

                     lmeses := 12 / lcforpag;

                     IF v_pol.frenova IS NOT NULL
                     THEN
                        dd := TO_CHAR (v_pol.frenova, 'dd');
                        -- SUBSTR(LPAD(v_pol.nrenova, 4, 0), 3, 2);
                        ddmm := TO_CHAR (v_pol.frenova, 'ddmm');
                     -- dd || SUBSTR(LPAD(v_pol.nrenova, 4, 0), 1, 2);
                     ELSE
                        dd := SUBSTR (LPAD (v_pol.nrenova, 4, 0), 3, 2);
                        ddmm :=
                              dd || SUBSTR (LPAD (v_pol.nrenova, 4, 0), 1, 2);
                     END IF;

                     IF v_pol.frenova IS NOT NULL
                     THEN
                        lfcanua := v_pol.frenova;
                     ELSE
                        IF    TO_CHAR (v_pol.fefecto, 'DDMM') = ddmm
                           OR LPAD (v_pol.nrenova, 4, 0) IS NULL
                        THEN
                           --lfcanua     := ADD_MONTHS(v_pol.fefecto, 12);
                           lfcanua := f_summeses (v_pol.fefecto, 12, dd);
                        ELSE
                           IF lctipefe = 2
                           THEN                     -- a d¿a 1/mes por exceso
                              fecha_aux := ADD_MONTHS (v_pol.fefecto, 13);
                              lfcanua :=
                                 TO_DATE (ddmm || TO_CHAR (fecha_aux, 'YYYY'),
                                          'DDMMYYYY'
                                         );
                           ELSE
                              BEGIN
                                 lfcanua :=
                                    TO_DATE (   ddmm
                                             || TO_CHAR (v_pol.fefecto,
                                                         'YYYY'),
                                             'DDMMYYYY'
                                            );
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    IF ddmm = 2902
                                    THEN
                                       ddmm := 2802;
                                       lfcanua :=
                                          TO_DATE (   ddmm
                                                   || TO_CHAR (v_pol.fefecto,
                                                               'YYYY'
                                                              ),
                                                   'DDMMYYYY'
                                                  );
                                    ELSE
                                       lmensaje := 104510;
                                       --Fecha de renovaci¿n (mmdd) incorrecta
                                       num_err := 1;
                                       p_tab_error (f_sysdate,
                                                    f_user,
                                                    'p_emitir_propuesta',
                                                    5,
                                                       'pcempres = '
                                                    || pcempres
                                                    || ' pnpoliza = '
                                                    || pnpoliza
                                                    || ' pncertif = '
                                                    || pncertif
                                                    || ' pcramo = '
                                                    || pcramo
                                                    || ' pcmodali = '
                                                    || pcmodali
                                                    || ' pctipseg = '
                                                    || pctipseg
                                                    || ' pccolect = '
                                                    || pccolect
                                                    || ' pcactivi = '
                                                    || pcactivi
                                                    || ' pmoneda = '
                                                    || pmoneda
                                                    || 'pcidioma = '
                                                    || pcidioma,
                                                    SQLERRM
                                                   );
                                    END IF;
                              END;
                           END IF;

                           IF lfcanua <= v_pol.fefecto
                           THEN
                              --lfcanua     := ADD_MONTHS(lfcanua, 12);
                              lfcanua := f_summeses (lfcanua, 12, dd);
                           END IF;
                        END IF;
                     END IF;

                     IF v_pol.frenova IS NOT NULL AND lcforpag IN (0, 1)
                     THEN
                        lfcapro := v_pol.frenova;
                     ELSE
                            -- Se calcula la pr¿x. cartera partiendo de la cartera de renovaci¿n (fcaranu)
                            -- y rest¿ndole periodos de pago
                        -- Calculem la data de propera cartera
                        IF     lctipefe = 2
                           AND TO_CHAR (v_pol.fefecto, 'dd') <> 1
                           AND lcforpag <> 12
                        THEN
                           l_fefecto_1 :=
                                 '01/'
                              || TO_CHAR (ADD_MONTHS (v_pol.fefecto, 1),
                                          'mm/yyyy'
                                         );
                        ELSE
                           l_fefecto_1 := v_pol.fefecto;
                        END IF;

                        lfaux := lfcanua;

                        WHILE TRUE
                        LOOP
                           --lfaux        := ADD_MONTHS(lfaux, -lmeses);
                           lfaux := f_summeses (lfaux, -lmeses, dd);

                           IF lfaux <= l_fefecto_1
                           THEN
                              lfcapro := f_summeses (lfaux, lmeses, dd);
                              --lfcapro      := ADD_MONTHS(lfaux, lmeses);
                              EXIT;
                           END IF;
                        END LOOP;
                     END IF;

                     IF (lndiaspro IS NOT NULL)
                     THEN
                        IF     TO_NUMBER (TO_CHAR (v_pol.fefecto, 'dd')) >=
                                                                    lndiaspro
                           AND TO_NUMBER (TO_CHAR (lfcapro, 'mm')) =
                                  TO_NUMBER
                                         (TO_CHAR (ADD_MONTHS (v_pol.fefecto,
                                                               1
                                                              ),
                                                   'mm'
                                                  )
                                         )
                        THEN
                           -- ¿s a dir , que el dia sigui > que el dia 15 de l'ultim m¿s del periode
                           lfcapro := ADD_MONTHS (lfcapro, lmeses);

                           IF lfcapro > lfcanua
                           THEN
                              lfcapro := lfcanua;
                           END IF;
                        END IF;
                     END IF;

                     IF v_pol.cforpag = 0 AND lcrevfpg = 1
                     THEN
                        IF v_pol.frenova IS NOT NULL AND lcforpag IN (0, 1)
                        THEN
                           lfvencim := NVL (v_pol.frenova, lfefecto + 1);
                        ELSE
                           lfvencim := NVL (v_pol.fvencim, lfefecto + 1);
                        END IF;
                     ELSE
                        lfvencim := lfcapro;
                     END IF;

                     BEGIN
                        IF lcmotmov <> 298
                        THEN                    -- No es suspensi¿ de p¿lissa
                           -- pot tenir data d'anulaci¿ si ¿s una regularitzaci¿
                           -- feta despr¿s d'anular la p¿lissa.
                           -- Bug 16768 - APD - 25/11/2010 - no se deben actualizar las fechas
                           -- fcaranu y fcarpro para las polizas colectivas, ya que se quiere que
                           -- no entren ni puedan entrar en ningun caso en el proceso de cartera

                           -- Bug 23117 - RSC - 13/08/2012  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A¿O
                           IF NVL
                                 (f_parproductos_v
                                               (f_sproduc_ret (v_pol.cramo,
                                                               v_pol.cmodali,
                                                               v_pol.ctipseg,
                                                               v_pol.ccolect
                                                              ),
                                                'FCARPRO_FCARANU_COL'
                                               ),
                                  0
                                 ) = 1
                           THEN
                              UPDATE seguros
                                 SET csituac = DECODE (fanulac, NULL, 0, 2),
                                     femisio = f_sysdate,
                                     fcaranu = lfcanua,
                                     fcarpro = lfcapro,
                                     ccartera = NULL
                               WHERE sseguro = v_pol.sseguro;
                           ELSE
                              -- Fin Bug 23117
                              UPDATE seguros
                                 SET csituac = DECODE (fanulac, NULL, 0, 2),
                                     femisio = f_sysdate,
                                     ccartera = NULL
                               WHERE sseguro = v_pol.sseguro;
                           -- Bug 23117 - RSC - 13/08/2012  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A¿O
                           END IF;

                           -- Fin Bug 23117

                           -- fin Bug 16768 - APD - 25/11/2010

                           -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011. Informar fcaranu,fcarpro para renovar poliza madre del colectivo transportes GIP
                           IF NVL
                                 (f_parproductos_v
                                               (f_sproduc_ret (v_pol.cramo,
                                                               v_pol.cmodali,
                                                               v_pol.ctipseg,
                                                               v_pol.ccolect
                                                              ),
                                                'RECUNIF'
                                               ),
                                  0
                                 ) = 3
                           THEN
                              UPDATE seguros
                                 SET csituac = DECODE (fanulac, NULL, 0, 2),
                                     femisio = f_sysdate,
                                     fcaranu = lfcanua,
                                     fcarpro = lfcapro,
                                     ccartera = NULL
                               WHERE sseguro = v_pol.sseguro;
                           END IF;
                        -- Fi BUG 0019627
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           lmensaje := SQLCODE;
                           num_err := 1;
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'p_emitir_propuesta',
                                        6,
                                           'pcempres = '
                                        || pcempres
                                        || ' pnpoliza = '
                                        || pnpoliza
                                        || ' pncertif = '
                                        || pncertif
                                        || ' pcramo = '
                                        || pcramo
                                        || ' pcmodali = '
                                        || pcmodali
                                        || ' pctipseg = '
                                        || pctipseg
                                        || ' pccolect = '
                                        || pccolect
                                        || ' pcactivi = '
                                        || pcactivi
                                        || ' pmoneda = '
                                        || pmoneda
                                        || 'pcidioma = '
                                        || pcidioma,
                                        SQLERRM
                                       );
                     END;
                  ELSIF v_pol.cforpag <> 0 AND v_pol.csituac = 1
                  THEN
                     -- Suplement i forma de pagament no ¿nica
                     lfcanua := v_pol.fcaranu;
                     lfcapro := v_pol.fcarpro;
                     lfvencim := lfcapro;

                     BEGIN
                        IF lcmotmov <> 298
                        THEN                    -- No es suspensi¿ de p¿lissa
                           -- pot tenir data d'anulaci¿ si ¿s una regularitzaci¿
                           -- feta despr¿s d'anular la p¿lissa.
                           UPDATE seguros
                              SET csituac = DECODE (fanulac, NULL, 0, 2),
                                  femisio = f_sysdate,
                                  ccartera = NULL
                            WHERE sseguro = v_pol.sseguro;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           lmensaje := SQLCODE;
                           num_err := 1;
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'p_emitir_propuesta',
                                        7,
                                           'pcempres = '
                                        || pcempres
                                        || ' pnpoliza = '
                                        || pnpoliza
                                        || ' pncertif = '
                                        || pncertif
                                        || ' pcramo = '
                                        || pcramo
                                        || ' pcmodali = '
                                        || pcmodali
                                        || ' pctipseg = '
                                        || pctipseg
                                        || ' pccolect = '
                                        || pccolect
                                        || ' pcactivi = '
                                        || pcactivi
                                        || ' pmoneda = '
                                        || pmoneda
                                        || 'pcidioma = '
                                        || pcidioma,
                                        SQLERRM
                                       );
                     END;

                     --BUG 23854: DCT: 12-12-2012: INICIO
                     IF num_err = 0
                     THEN
                        SELECT pac_parametros.f_parproducto_t (v_pol.sproduc,
                                                               'F_PRE_EMISION'
                                                              )
                          INTO v_funcion
                          FROM DUAL;

                        IF v_funcion IS NOT NULL
                        THEN
                           v_sproces := lsproces;
                           v_sseguro := v_pol.sseguro;
                           v_fefecto := TO_CHAR (lfefecto, 'dd/mm/yyyy');
                           v_nmovimi := lnmovimi;
                           ss :=
                                 'begin :num_err := '
                              || v_funcion
                              || '(:v_sproces, :v_sseguro, :v_fefecto, :v_nmovimi); end;';

                           EXECUTE IMMEDIATE ss
                                       USING OUT    num_err,
                                             IN     v_sproces,
                                             IN     v_sseguro,
                                             IN     v_fefecto,
                                             IN     v_nmovimi;

                           IF num_err <> 0
                           THEN
                              lmensaje := num_err;
                              num_err := 1;
                              ROLLBACK;
                              p_tab_error
                                         (f_sysdate,
                                          f_user,
                                          'p_emitir_propuesta.f_pre_emision',
                                          7,
                                             'pcempres = '
                                          || pcempres
                                          || ' pnpoliza = '
                                          || pnpoliza
                                          || ' pncertif = '
                                          || pncertif
                                          || ' pcramo = '
                                          || pcramo
                                          || ' pcmodali = '
                                          || pcmodali
                                          || ' pctipseg = '
                                          || pctipseg
                                          || ' pccolect = '
                                          || pccolect
                                          || ' pcactivi = '
                                          || pcactivi
                                          || ' pmoneda = '
                                          || pmoneda
                                          || 'pcidioma = '
                                          || pcidioma,
                                          lmensaje
                                         );
                           END IF;

                           SELECT nmovimi
                             --, fefecto, cmotmov, cmovseg, cdomper
                           INTO   lnmovimi
                             --, lfefecto, lcmotmov, lcmovseg, lcdomper
                           FROM   movseguro
                            WHERE sseguro = v_pol.sseguro
                              AND femisio IS NULL
                              AND fanulac IS NULL;
                        END IF;
                     END IF;
                  --BUG 23854: DCT: 12-12-2012: FIN
                  ELSIF v_pol.cforpag = 0 AND lcrevfpg = 0
                  THEN
                     IF v_pol.frenova IS NOT NULL
                     THEN
                        lfcanua := v_pol.frenova;
                        lfcapro := v_pol.frenova;
                        lfvencim := NVL (v_pol.frenova, lfefecto + 1);
                     ELSE
                        lfcanua := v_pol.fcaranu;
                        lfcapro := v_pol.fcarpro;
                        lfvencim := NVL (v_pol.fvencim, lfefecto + 1);
                     END IF;

                     --lfvencim := v_pol.fvencim;
                     BEGIN
                        IF lcmotmov <> 298
                        THEN                    -- No es suspensi¿ de p¿lissa
                           -- pot tenir data d'anulaci¿ si ¿s una regularitzaci¿
                           -- feta despr¿s d'anular la p¿lissa.
                           UPDATE seguros
                              SET csituac = DECODE (fanulac, NULL, 0, 2),
                                  femisio = f_sysdate,
                                  ccartera = NULL
                            WHERE sseguro = v_pol.sseguro;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           lmensaje := SQLCODE;
                           num_err := 1;
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'p_emitir_propuesta',
                                        8,
                                           'pcempres = '
                                        || pcempres
                                        || ' pnpoliza = '
                                        || pnpoliza
                                        || ' pncertif = '
                                        || pncertif
                                        || ' pcramo = '
                                        || pcramo
                                        || ' pcmodali = '
                                        || pcmodali
                                        || ' pctipseg = '
                                        || pctipseg
                                        || ' pccolect = '
                                        || pccolect
                                        || ' pcactivi = '
                                        || pcactivi
                                        || ' pmoneda = '
                                        || pmoneda
                                        || 'pcidioma = '
                                        || pcidioma,
                                        SQLERRM
                                       );
                     END;
                  ELSE                                  -- Si es un suplemento
                     lfcanua := v_pol.fcaranu;
                     lfcapro := v_pol.fcarpro;

                     IF v_pol.cforpag = 0 AND lcrevfpg = 1
                     THEN
                        lfvencim := NVL (v_pol.fvencim, lfefecto + 1);
                     ELSE
                        lfvencim := lfcapro;
                     END IF;

                     BEGIN
                        IF lcmotmov <> 298
                        THEN                    -- No es suspensi¿ de p¿lissa
                           -- pot tenir data d'anulaci¿ si ¿s una regularitzaci¿
                           -- feta despr¿s d'anular la p¿lissa.
                           UPDATE seguros
                              SET csituac = DECODE (fanulac, NULL, 0, 2),
                                  femisio = f_sysdate,
                                  ccartera = NULL
                            WHERE sseguro = v_pol.sseguro;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           lmensaje := SQLCODE;
                           num_err := 1;
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'p_emitir_propuesta',
                                        9,
                                           'pcempres = '
                                        || pcempres
                                        || ' pnpoliza = '
                                        || pnpoliza
                                        || ' pncertif = '
                                        || pncertif
                                        || ' pcramo = '
                                        || pcramo
                                        || ' pcmodali = '
                                        || pcmodali
                                        || ' pctipseg = '
                                        || pctipseg
                                        || ' pccolect = '
                                        || pccolect
                                        || ' pcactivi = '
                                        || pcactivi
                                        || ' pmoneda = '
                                        || pmoneda
                                        || 'pcidioma = '
                                        || pcidioma,
                                        SQLERRM
                                       );
                     END;
                  END IF;
               END IF;
            END IF;

            -- Para evitar problemas. Si frenova est¿ informado. Machacar el NRENOVA.
            IF v_pol.frenova IS NOT NULL
            THEN
               UPDATE seguros
                  SET nrenova = TO_CHAR (v_pol.frenova, 'mmdd')
                WHERE sseguro = v_pol.sseguro;
            END IF;

            IF num_err = 0
            THEN
               BEGIN
                  SELECT DECODE (cimpres,
                                 1, 0,                            --Se imprime
                                 0, 1,                         --No se imprime
                                 1
                                )                                    --Tampoco
                    INTO xcimpres
                    FROM codimotmov
                   WHERE cmotmov = lcmotmov;

                  UPDATE movseguro
                     SET cimpres = xcimpres,
                         femisio = f_sysdate
                   WHERE sseguro = v_pol.sseguro
                     AND femisio IS NULL
                     AND fanulac IS NULL;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     lmensaje := SQLCODE;
                     num_err := 1;
                     ROLLBACK;
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'p_emitir_propuesta_col',
                                  17,
                                     'pcempres = '
                                  || pcempres
                                  || ' pnpoliza = '
                                  || pnpoliza
                                  || ' pncertif = '
                                  || pncertif
                                  || ' pcramo = '
                                  || pcramo
                                  || ' pcmodali = '
                                  || pcmodali
                                  || ' pctipseg = '
                                  || pctipseg
                                  || ' pccolect = '
                                  || pccolect
                                  || ' pcactivi = '
                                  || pcactivi
                                  || ' pmoneda = '
                                  || pmoneda
                                  || 'pcidioma = '
                                  || pcidioma,
                                  SQLERRM
                                 );
               END;
            END IF;

            -- ini Bug 0026070 - 18/02/2013 - JMF
            IF lctiprec = 1
            THEN                                                  --Suplemento
               num_err := pk_suplementos.f_post_suplemento (v_pol.sseguro);

               IF num_err <> 0
               THEN
                  lmensaje := num_err;
                  num_err := 1;
                  ROLLBACK;
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_seguros.p_emitir_propuesta_col',
                               2465,
                                  'pcempres = '
                               || pcempres
                               || ' pnpoliza = '
                               || pnpoliza
                               || ' pncertif = '
                               || pncertif
                               || ' pcramo = '
                               || pcramo
                               || ' pcmodali = '
                               || pcmodali
                               || ' pctipseg = '
                               || pctipseg
                               || ' pccolect = '
                               || pccolect
                               || ' pcactivi = '
                               || pcactivi
                               || ' pmoneda = '
                               || pmoneda
                               || 'pcidioma = '
                               || pcidioma,
                               f_axis_literales (lmensaje)
                              );
               END IF;
            END IF;

            -- fin Bug 0026070 - 18/02/2013 - JMF

            -- Bug 24278 - APD - 20/11/2012 - Se propaga el suplemento del certificado 0
            -- a sus n certifs
            num_err :=
               pac_sup_diferidos.f_propaga_suplemento (v_pol.sseguro,
                                                       lcmotmov,
                                                       lnmovimi,
                                                       lfefecto
                                                      );

            IF num_err <> 0
            THEN
               lmensaje := num_err;
               num_err := 1;
               ROLLBACK;
               p_tab_error (f_sysdate,
                            f_user,
                            'p_emitir_propuesta',
                            18,
                               'pcempres = '
                            || pcempres
                            || ' pnpoliza = '
                            || pnpoliza
                            || ' pncertif = '
                            || pncertif
                            || ' pcramo = '
                            || pcramo
                            || ' pcmodali = '
                            || pcmodali
                            || ' pctipseg = '
                            || pctipseg
                            || ' pccolect = '
                            || pccolect
                            || ' pcactivi = '
                            || pcactivi
                            || ' pmoneda = '
                            || pmoneda
                            || 'pcidioma = '
                            || pcidioma,
                            f_axis_literales (lmensaje)
                           );
            END IF;

            --BUG 23854: DCT: 12-12-2012: INICIO
            IF num_err = 0
            THEN
               SELECT pac_parametros.f_parproducto_t (v_pol.sproduc,
                                                      'F_POST_EMISION'
                                                     )
                 INTO v_funcion
                 FROM DUAL;

               IF v_funcion IS NOT NULL
               THEN
                  v_sproces := lsproces;
                  v_sseguro := v_pol.sseguro;
                  v_fefecto := TO_CHAR (lfefecto, 'dd/mm/yyyy');
                  v_nmovimi := lnmovimi;
                  ss :=
                        'begin :num_err := '
                     || v_funcion
                     || '(:v_sproces, :v_sseguro, :v_fefecto, :v_nmovimi, :v_tmensaje); end;';

                  -- BUG 27642 - FAL - 30/04/2014
                  EXECUTE IMMEDIATE ss
                              USING OUT    num_err,
                                    IN     v_sproces,
                                    IN     v_sseguro,
                                    IN     v_fefecto,
                                    IN     v_nmovimi,
                                    OUT    v_tmensaje;

                  -- BUG 27642 - FAL - 30/04/2014
                  IF num_err <> 0
                  THEN
                     lmensaje := num_err;
                     num_err := 1;
                     ROLLBACK;
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'p_emitir_propuesta.f_post_emision',
                                  19,
                                     'pcempres = '
                                  || pcempres
                                  || ' pnpoliza = '
                                  || pnpoliza
                                  || ' pncertif = '
                                  || pncertif
                                  || ' pcramo = '
                                  || pcramo
                                  || ' pcmodali = '
                                  || pcmodali
                                  || ' pctipseg = '
                                  || pctipseg
                                  || ' pccolect = '
                                  || pccolect
                                  || ' pcactivi = '
                                  || pcactivi
                                  || ' pmoneda = '
                                  || pmoneda
                                  || 'pcidioma = '
                                  || pcidioma,
                                  lmensaje
                                 );
                  END IF;
               END IF;
            END IF;

            --BUG 23854: DCT: 12-12-2012: FIN

            -- fin Bug 24278 - APD - 20/11/2012
            IF num_err = 0
            THEN
               -- Si se asigna el numero de p¿liza en la emisi¿n
               IF
/*-- INI--BUG18631--ETM-----NVL(f_parproductos_v(v_pol.sproduc, 'NPOLIZA_EN_EMISION'), 0) = 1 AND   --FIN--*/
                  lctipmov = 0
               THEN                               -- solo en Nueva Producci¿n
                  -- Bug 7854 y 8745 - 12/02/2008 - RSC - Adaptaci¿n iAxis a productos colectivos con certificados
                  /*IF lcsubpro = 3
                     OR NVL(f_parproductos_v(v_pol.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN   -- colectivos*/
                  v_ncertif := 0;
                  v_npoliza_prefijo :=
                          f_parproductos_v (v_pol.sproduc, 'NPOLIZA_PREFIJO');

                  IF v_npoliza_prefijo IS NOT NULL
                  THEN
                     v_pol.cramo := v_npoliza_prefijo;
                  END IF;

                  -- Bug 16768 - APD - 22/11/2010 - se le pasa el valor 3 al parametro
                  -- pexp ya que se quiere que la poliza se a de 5 cifras
                  -- Ademas se sustituye la llamada f_contador por pac_propio.f_contador
                  --v_npoliza := f_contador('02', v_pol.cramo, 3);
                  --v_npoliza := pac_propio.f_contador2(v_pol.cempres, '02', v_pol.cramo, 3);

                  -- fin Bug 16768 - APD - 22/11/2010
                  --INI--bug 18631--ETM--31/05/2011
                  IF NVL (f_parproductos_v (v_pol.sproduc, 'DETALLE_GARANT'),
                          0
                         ) IN (1, 2)
                  THEN
                     v_npoliza :=
                        pac_propio.f_contador2 (v_pol.cempres,
                                                '02',
                                                v_pol.cramo,
                                                3
                                               );
                  ELSE
                     v_npoliza :=
                        pac_propio.f_contador2 (v_pol.cempres,
                                                '02',
                                                v_pol.cramo
                                               );
                  END IF;

                  --fin-bug 18631--ETM--31/05/2011
                  --END IF;
                  BEGIN
                     v_poliza_ant := v_pol.npoliza;

                     UPDATE seguros
                        SET npoliza = NVL (v_npoliza, npoliza),
                            ncertif = NVL (v_ncertif, ncertif)
                      WHERE sseguro = v_pol.sseguro;

                     -- Bug 23940 - APD - 19/11/2012 - bloquear la poliza en emision si por defecto
                     -- debe quedar bloqueada
                     num_err := pac_propio.f_act_cbloqueocol (v_pol.sseguro);

                     -- fin Bug 23940 - APD - 19/11/2012

                     --JAVENDANO BUG 34409 03/06/2015
                     BEGIN
                        UPDATE estseguros
                           SET npoliza = NVL (v_npoliza, npoliza)
                         WHERE npoliza = v_poliza_ant;

                        p_tab_error (f_sysdate,
                                     f_user,
                                     'funciona update',
                                     99,
                                        'poliza ant = '
                                     || v_poliza_ant
                                     || ' poliza nueva = '
                                     || v_npoliza
                                     || ' registros = '
                                     || SQL%ROWCOUNT,
                                     SQLERRM
                                    );
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           num_err := 1;
                           ROLLBACK;
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'p_emitir_propuesta',
                                        21,
                                           'pcempres = '
                                        || pcempres
                                        || ' pnpoliza = '
                                        || pnpoliza
                                        || ' pncertif = '
                                        || pncertif
                                        || ' pcramo = '
                                        || pcramo
                                        || ' pcmodali = '
                                        || pcmodali
                                        || ' pctipseg = '
                                        || pctipseg
                                        || ' pccolect = '
                                        || pccolect
                                        || ' pcactivi = '
                                        || pcactivi
                                        || ' pmoneda = '
                                        || pmoneda
                                        || 'pcidioma = '
                                        || pcidioma,
                                        SQLERRM
                                       );
                     END;
                  --FIN JAVENDANO BUG 34409 03/06/2015
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        num_err := 1;
                        ROLLBACK;
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'p_emitir_propuesta',
                                     22,
                                        'pcempres = '
                                     || pcempres
                                     || ' pnpoliza = '
                                     || pnpoliza
                                     || ' pncertif = '
                                     || pncertif
                                     || ' pcramo = '
                                     || pcramo
                                     || ' pcmodali = '
                                     || pcmodali
                                     || ' pctipseg = '
                                     || pctipseg
                                     || ' pccolect = '
                                     || pccolect
                                     || ' pcactivi = '
                                     || pcactivi
                                     || ' pmoneda = '
                                     || pmoneda
                                     || 'pcidioma = '
                                     || pcidioma,
                                     SQLERRM
                                    );
                  END;
               END IF;

               -- BUG23911:DRA:19/10/2012:Inici
               IF num_err = 0
               THEN
                  IF pac_retorno.f_tiene_retorno (NULL,
                                                  v_pol.sseguro,
                                                  lnmovimi
                                                 ) = 1
                  THEN
                     num_err :=
                        pac_retorno.f_generar_retorno (v_pol.sseguro,
                                                       lnmovimi,
                                                       NULL,
                                                       NULL
                                                      );
                  END IF;
               END IF;

               -- Bug 25542 - APD - 16/01/2013
               -- Se actualiza la antiguedad de las personas de la poliza
               IF num_err = 0
               THEN
                  num_err :=
                        pac_persona.f_antiguedad_personas_pol (v_pol.sseguro);

                  IF num_err <> 0
                  THEN
                     lmensaje := num_err;
                     num_err := 1;
                     ROLLBACK;
                     p_tab_error
                             (f_sysdate,
                              f_user,
                              'p_emitir_propuesta.f_antiguedad_personas_pol',
                              23,
                                 'pcempres = '
                              || pcempres
                              || ' pnpoliza = '
                              || pnpoliza
                              || ' pncertif = '
                              || pncertif
                              || ' pcramo = '
                              || pcramo
                              || ' pcmodali = '
                              || pcmodali
                              || ' pctipseg = '
                              || pctipseg
                              || ' pccolect = '
                              || pccolect
                              || ' pcactivi = '
                              || pcactivi
                              || ' pmoneda = '
                              || pmoneda
                              || 'pcidioma = '
                              || pcidioma,
                              lmensaje
                             );
                  END IF;
               END IF;

               -- Fin Bug 25542 - APD - 16/01/2013

               -- BUG23911:DRA:19/10/2012:Fi
               -- Bug 22839/0120953 - FAL - 27/08/2012
               IF     pac_seguros.f_es_col_admin (v_pol.sseguro, 'SEG') = 1
                  AND lctipmov = 0
               THEN
                  err :=
                     pac_preguntas.f_get_pregunpolseg (v_pol.sseguro,
                                                       4084,
                                                       'SEG',
                                                       v_crespue_4084
                                                      );

                  IF v_crespue_4084 = 2 AND err = 0
                  THEN
                     err :=
                        pac_preguntas.f_get_pregunpolseg (v_pol.sseguro,
                                                          4790,
                                                          'SEG',
                                                          v_crespue_4790
                                                         );

                     IF v_crespue_4790 = 1 AND err = 0
                     THEN
--                        UPDATE seguros
--                           SET csituac = 4
--                         WHERE sseguro = v_pol.sseguro;

                        --                        UPDATE movseguro m
--                           SET m.femisio = NULL
--                         WHERE m.sseguro = v_pol.sseguro
--                           AND m.nmovimi = (SELECT MAX(m1.nmovimi)
--                                              FROM movseguro m1
--                                             WHERE m1.sseguro = m.sseguro);
                        err := f_abrir_suplemento (v_pol.sseguro);

                        IF err <> 0
                        THEN
                           lmensaje := err;
                           num_err := 1;
                           ROLLBACK;
                           p_tab_error
                              (f_sysdate,
                               f_user,
                               'p_emitir_propuesta.f_antiguedad_personas_pol',
                               23,
                                  'pcempres = '
                               || pcempres
                               || ' pnpoliza = '
                               || pnpoliza
                               || ' pncertif = '
                               || pncertif
                               || ' pcramo = '
                               || pcramo
                               || ' pcmodali = '
                               || pcmodali
                               || ' pctipseg = '
                               || pctipseg
                               || ' pccolect = '
                               || pccolect
                               || ' pcactivi = '
                               || pcactivi
                               || ' pmoneda = '
                               || pmoneda
                               || 'pcidioma = '
                               || pcidioma,
                               lmensaje
                              );
                        END IF;
                     END IF;
                  END IF;
               END IF;
            -- FI Bug 22839/0120953 - FAL - 27/08/2012
            END IF;

            -- REEMPLAZOS
            FOR cur IN (SELECT r.sseguro, s.npoliza, s.csituac, s.cagente,
                               r.sreempl
                                        -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                               , s.sproduc
                          -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        FROM   reemplazos r, seguros s
                         WHERE r.sreempl = s.sseguro
                           AND r.sseguro = v_pol.sseguro)
            LOOP
               --JAVENDANO BUG 34409/203137 30/04/2015 POS
               IF     NVL
                         (pac_mdpar_productos.f_get_parproducto
                                                       ('ADMITE_CERTIFICADOS',
                                                        cur.sproduc
                                                       ),
                          0
                         ) = 1
                  AND pac_seguros.f_soycertifcero (cur.sproduc,
                                                   cur.npoliza,
                                                   cur.sseguro
                                                  ) = 0
               THEN
                  num_err :=
                            pac_seguros.f_ini_certifn (cur.sseguro, 'EMITIR');
               END IF;

               IF cur.csituac = 0
               THEN                                                 -- vigente
                  num_err :=
                     pac_iax_anulaciones.f_anulacion (cur.sreempl,
                                                      4,
                                                      v_pol.fefecto,
                                                      302,
                                                      NULL,
                                                      1,
                                                      1,
                                                      NULL,
                                                      NULL,
                                                      vmensajes
                                                     );
               END IF;
            END LOOP;

            IF num_err = 1
            THEN
               pindice_e := pindice_e + 1;
               ltexto := f_axis_literales (lmensaje, pcidioma);
               num_err :=
                       f_proceslin (lsproces, ltexto, v_pol.sseguro, nprolin);
               p_tab_error (f_sysdate,
                            f_user,
                            'p_emitir_propuesta',
                            23,
                               'pcempres = '
                            || pcempres
                            || ' pnpoliza = '
                            || pnpoliza
                            || ' pncertif = '
                            || pncertif
                            || ' pcramo = '
                            || pcramo
                            || ' pcmodali = '
                            || pcmodali
                            || ' pctipseg = '
                            || pctipseg
                            || ' pccolect = '
                            || pccolect
                            || ' pcactivi = '
                            || pcactivi
                            || ' pmoneda = '
                            || pmoneda
                            || 'pcidioma = '
                            || pcidioma,
                            f_axis_literales (lmensaje, pcidioma)
                           );
               COMMIT;

               --Posem el creteni = 1 si esta a 6
               UPDATE seguros
                  SET creteni = 1,
                      ccartera = NULL
                WHERE sseguro = v_pol.sseguro AND creteni = 99;
            ELSE            -- Si todo ha ido bien que calcule un nuevo numrec
               lnumrec := NULL;

               UPDATE estseguros
                  SET csituac = 2                                    --Emitido
                WHERE sseguro = v_pol.sseguro;
            END IF;
         END LOOP;                                            -- Cursor Poliza

         CLOSE c_pol;

         IF psproces IS NULL
         THEN
            IF f_procesfin (lsproces, num_err) = 0
            THEN
               NULL;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
            IF c_pol%ISOPEN
            THEN
               CLOSE c_pol;
            END IF;

            ROLLBACK;

            CLOSE c_pol;

            pindice_e := pindice_e + 1;
            p_tab_error (f_sysdate,
                         f_user,
                         'p_emitir_propuesta_col',
                         25,
                            'pcempres = '
                         || pcempres
                         || ' pnpoliza = '
                         || pnpoliza
                         || ' pncertif = '
                         || pncertif
                         || ' pcramo = '
                         || pcramo
                         || ' pcmodali = '
                         || pcmodali
                         || ' pctipseg = '
                         || pctipseg
                         || ' pccolect = '
                         || pccolect
                         || ' pcactivi = '
                         || pcactivi
                         || ' pmoneda = '
                         || pmoneda
                         || 'pcidioma = '
                         || pcidioma,
                         SQLERRM
                        );
      END;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'p_emitir_propuesta_col',
                      0,
                         'pcempres = '
                      || pcempres
                      || ' pnpoliza = '
                      || pnpoliza
                      || ' pncertif = '
                      || pncertif
                      || ' pcramo = '
                      || pcramo
                      || ' pcmodali = '
                      || pcmodali
                      || ' pctipseg = '
                      || pctipseg
                      || ' pccolect = '
                      || pccolect
                      || ' pcactivi = '
                      || pcactivi
                      || ' pmoneda = '
                      || pmoneda
                      || 'pcidioma = '
                      || pcidioma,
                      SQLERRM
                     );
   END p_emitir_propuesta_col;

   -- BUG 023117 -  01/2012 - RSC  - LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
   /***********************************************************************
       Retorna el tipo de vigencia de una p¿liza f_get_tipo_vigencia
       return                     es un c¿digo de error
    ***********************************************************************/
   FUNCTION f_get_tipo_vigencia (
      psseguro   IN       NUMBER,
      pnpoliza   IN       NUMBER,
      ptablas    IN       VARCHAR2 DEFAULT 'EST',
      psalida    OUT      NUMBER
   )
      RETURN NUMBER
   IS
      e_object_error   EXCEPTION;
      e_param_error    EXCEPTION;
      vobjectname      VARCHAR2 (100)    := 'PAC_SEGUROS.f_get_tipo_vigencia';
      vparam           VARCHAR2 (2000)
         := 'par¿metros - psseguro: ' || psseguro || ' - ptablas: '
            || ptablas;
      vcrespue         NUMBER;
      vnumerr          NUMBER;
      vpasexec         NUMBER                      := 0;
      v_sseguro        seguros.sseguro%TYPE;
      v_crespue4790    pregunpolseg.crespue%TYPE;
   BEGIN
      IF psseguro IS NULL AND pnpoliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF psseguro IS NOT NULL
      THEN
         v_sseguro := psseguro;
      ELSE
         SELECT sseguro
           INTO v_sseguro
           FROM seguros
          WHERE npoliza = pnpoliza AND ncertif = 0;
      END IF;

      vpasexec := 1;
      vnumerr :=
         pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                           4790,
                                           ptablas,
                                           v_crespue4790
                                          );
      vpasexec := 2;

      IF vnumerr = 120135
      THEN
         psalida := 2;  -- Si no encuentra nada, por defecto vigencia abierta
      ELSIF vnumerr = 0
      THEN
         psalida := v_crespue4790;
      ELSE
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'Objeto invocado con par¿metros erroneos'
                     );
         RETURN 101901;
      WHEN e_object_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                         'Error al llamar procedimiento o funci¿n - numerr: '
                      || vnumerr
                     );
         RETURN vnumerr;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 140999;
   END f_get_tipo_vigencia;

   -- BUG 023117 -  01/2012 - RSC  - LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
   /***********************************************************************
       Retorna el tipo de vigencia de una p¿liza f_get_tipo_vigencia
       return                     es un c¿digo de error
    ***********************************************************************/
   FUNCTION f_get_tipo_duracion_cero (
      psseguro   IN       NUMBER,
      pnpoliza   IN       NUMBER,
      ptablas    IN       VARCHAR2 DEFAULT 'EST',
      psalida    OUT      NUMBER
   )
      RETURN NUMBER
   IS
      e_object_error   EXCEPTION;
      e_param_error    EXCEPTION;
      vobjectname      VARCHAR2 (100)
                                    := 'PAC_SEGUROS.f_get_tipo_duracion_cero';
      vparam           VARCHAR2 (2000)
         := 'par¿metros - psseguro: ' || psseguro || ' - ptablas: '
            || ptablas;
      vcrespue         NUMBER;
      vnumerr          NUMBER;
      vpasexec         NUMBER                      := 0;
      v_sseguro        seguros.sseguro%TYPE;
      v_crespue4790    pregunpolseg.crespue%TYPE;
      v_cduraci        seguros.cduraci%TYPE;
   BEGIN
      IF psseguro IS NULL AND pnpoliza IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF psseguro IS NOT NULL
      THEN
         v_sseguro := psseguro;
      ELSE
         SELECT sseguro
           INTO v_sseguro
           FROM seguros
          WHERE npoliza = pnpoliza AND ncertif = 0;
      END IF;

      SELECT cduraci
        INTO v_cduraci
        FROM seguros
       WHERE sseguro = v_sseguro;

      vpasexec := 4;
      psalida := v_cduraci;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'Objeto invocado con par¿metros erroneos'
                     );
         RETURN 101901;
      WHEN e_object_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                         'Error al llamar procedimiento o funci¿n - numerr: '
                      || vnumerr
                     );
         RETURN vnumerr;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 140999;
   END f_get_tipo_duracion_cero;

   -- BUG22839:DRA:26/09/2012:Inici
   FUNCTION f_es_col_admin (
      psseguro   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'SEG'
   )
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (100)         := 'PAC_SEGUROS.f_es_col_admin';
      vparam           VARCHAR2 (2000)
         := 'par¿metros - psseguro: ' || psseguro || ' - ptablas: '
            || ptablas;
      v_crespue_4092   pregunpolseg.crespue%TYPE;
      v_sseguro        seguros.sseguro%TYPE;
      v_cempres        empresas.cempres%TYPE;
      v_sproduc        seguros.sproduc%TYPE;
      vnumerr          NUMBER;
      vpasexec         NUMBER                      := 0;
   BEGIN
      IF ptablas = 'EST'
      THEN
         BEGIN
            SELECT sseguro, cempres, sproduc
              INTO v_sseguro, v_cempres, v_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               SELECT sseguro, cempres, sproduc
                 INTO v_sseguro, v_cempres, v_sproduc
                 FROM estseguros
                WHERE ssegpol = psseguro;
         END;
      ELSE
         SELECT sseguro, cempres, sproduc
           INTO v_sseguro, v_cempres, v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF NVL (pac_parametros.f_parempresa_n (v_cempres, 'SET_PROP'), 0) = 1
      THEN
         IF NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                 'ADMITE_CERTIFICADOS'
                                                ),
                 0
                ) = 1
         THEN
            vnumerr :=
               pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                                 4092,
                                                 NVL (ptablas, 'SEG'),
                                                 v_crespue_4092
                                                );

            IF v_crespue_4092 = 1 AND vnumerr = 0
            THEN
               RETURN 1;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 140999;
   END f_es_col_admin;

   -- Bug 23940 - APD - 26/10/2012 - se crea la funcion
   FUNCTION f_es_col_agrup (
      psseguro   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'SEG'
   )
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (100)         := 'PAC_SEGUROS.f_es_col_agrup';
      vparam           VARCHAR2 (2000)
         := 'par¿metros - psseguro: ' || psseguro || ' - ptablas: '
            || ptablas;
      v_crespue_4092   pregunpolseg.crespue%TYPE;
      v_sseguro        seguros.sseguro%TYPE;
      v_cempres        empresas.cempres%TYPE;
      vnumerr          NUMBER;
      vpasexec         NUMBER                      := 0;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT sseguro, cempres
           INTO v_sseguro, v_cempres
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sseguro, cempres
           INTO v_sseguro, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF NVL (pac_parametros.f_parempresa_n (v_cempres, 'SET_PROP'), 0) = 1
      THEN
         vnumerr :=
            pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                              4092,
                                              NVL (ptablas, 'SEG'),
                                              v_crespue_4092
                                             );

         IF v_crespue_4092 = 2 AND vnumerr = 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 140999;
   END f_es_col_agrup;

   FUNCTION f_suplem_obert (
      psseguro   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'SEG'
   )
      RETURN NUMBER
   IS
      vobjectname      VARCHAR2 (100)         := 'PAC_SEGUROS.f_suplem_obert';
      vparam           VARCHAR2 (2000)
         := 'par¿metros - psseguro: ' || psseguro || ' - ptablas: '
            || ptablas;
      v_crespue_4092   pregunpolseg.crespue%TYPE;
      v_sseguro        seguros.sseguro%TYPE;
      v_cempres        empresas.cempres%TYPE;
      v_csituac        seguros.csituac%TYPE;
      v_npoliza        seguros.npoliza%TYPE;
      v_ncertif        seguros.ncertif%TYPE;
      v_sproduc        seguros.sproduc%TYPE;
      vnumerr          NUMBER;
      vpasexec         NUMBER                      := 0;
   BEGIN
      IF ptablas = 'EST'
      THEN
         SELECT sseguro, cempres, csituac, npoliza, ncertif,
                sproduc
           INTO v_sseguro, v_cempres, v_csituac, v_npoliza, v_ncertif,
                v_sproduc
           FROM estseguros
          WHERE ssegpol = psseguro;
      ELSE
         SELECT sseguro, cempres, csituac, npoliza, ncertif,
                sproduc
           INTO v_sseguro, v_cempres, v_csituac, v_npoliza, v_ncertif,
                v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF NVL (pac_parametros.f_parempresa_n (v_cempres, 'SET_PROP'), 0) = 1
      THEN
         IF NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                 'ADMITE_CERTIFICADOS'
                                                ),
                 0
                ) = 1
         THEN
            vnumerr :=
               pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                                 4092,
                                                 NVL (ptablas, 'SEG'),
                                                 v_crespue_4092
                                                );

            IF v_crespue_4092 = 1 AND vnumerr = 0
            THEN
               IF v_ncertif <> 0
               THEN
                  SELECT csituac
                    INTO v_csituac
                    FROM seguros
                   WHERE npoliza = v_npoliza AND ncertif = 0;

                  IF v_csituac <> 5
                  THEN
                     RETURN 9904265;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 140999;
   END f_suplem_obert;

-- BUG22839:DRA:26/09/2012:Fi

   -- BUG 0024832 - 12/12/2012 - JMF
   FUNCTION f_anul_obert (psseguro IN NUMBER, ptablas IN VARCHAR2
            DEFAULT 'SEG')
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (100)          := 'PAC_SEGUROS.f_anul_obert';
      vparam        VARCHAR2 (2000)
         := 'par¿metros - psseguro: ' || psseguro || ' - ptablas: '
            || ptablas;
      v_sseguro     seguros.sseguro%TYPE;
      v_cempres     empresas.cempres%TYPE;
      v_csituac     seguros.csituac%TYPE;
      v_npoliza     seguros.npoliza%TYPE;
      v_ncertif     seguros.ncertif%TYPE;
      v_sproduc     seguros.sproduc%TYPE;
      vnumerr       NUMBER;
      vpasexec      NUMBER                  := 0;
      v_sitcero     seguros.csituac%TYPE;
      n_admin       NUMBER;
      n_agrup       NUMBER;
   BEGIN
      n_admin := pac_seguros.f_es_col_admin (psseguro, ptablas);
      n_agrup := pac_seguros.f_es_col_agrup (psseguro, ptablas);

      IF ptablas = 'EST'
      THEN
         vpasexec := 10;

         SELECT sseguro, cempres, csituac, npoliza, ncertif,
                sproduc
           INTO v_sseguro, v_cempres, v_csituac, v_npoliza, v_ncertif,
                v_sproduc
           FROM estseguros
          WHERE ssegpol = psseguro;
      ELSE
         vpasexec := 20;

         SELECT sseguro, cempres, csituac, npoliza, ncertif,
                sproduc
           INTO v_sseguro, v_cempres, v_csituac, v_npoliza, v_ncertif,
                v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF n_admin = 1 OR n_agrup = 1
      THEN
         -- Que no permita anular la p¿liza ni sus hijas en caso de administradas si la p¿liza est¿ en propuesta de cartera.
         -- en el caso de agrupadas si la p¿liza misma esta en propuesta de cartera no dejar, pero si se quiere anular una
         -- hija que su situaci¿n es correcta que deje.
         IF v_csituac = 17
         THEN
            -- El certificado esta en propuesta de cartera
            RETURN 9904559;
         END IF;
      END IF;

      IF n_admin = 1
      THEN
         -- Que no permita anular la p¿liza ni sus hijas en caso de administradas si la p¿liza est¿ en propuesta de cartera.
         SELECT MAX (csituac)
           INTO v_sitcero
           FROM seguros
          WHERE npoliza = v_npoliza AND ncertif = 0;

         IF v_sitcero = 17
         THEN
            -- La p¿liza principal del colectivo esta en propuesta de cartera
            RETURN 9904560;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 140999;
   END f_anul_obert;

   -- Bug 23817 - APD - 03/10/2012 - se crea la funcion
   FUNCTION f_set_detmovsegurocol (
      psseguro_0      IN   NUMBER,
      pnmovimi_0      IN   NUMBER,
      psseguro_cert   IN   NUMBER,
      pnmovimi_cert   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vparam   VARCHAR2 (2000)
         :=    'psseguro_0: '
            || psseguro_0
            || '; pnmovimi_0: '
            || pnmovimi_0
            || '; psseguro_cert: '
            || psseguro_cert
            || '; pnmovimi_cert: '
            || pnmovimi_cert;
      salir    EXCEPTION;
   BEGIN
      BEGIN
         INSERT INTO detmovsegurocol
                     (sseguro_0, nmovimi_0, sseguro_cert, nmovimi_cert
                     )
              VALUES (psseguro_0, pnmovimi_0, psseguro_cert, pnmovimi_cert
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            RAISE salir;
      END;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_seguros.f_set_detmovsegurocol',
                      1,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9904288;      -- Error al insertar en la tabla DETMOVSEGUROCOL
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_seguros.f_set_detmovsegurocol',
                      1,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;                               -- Error no controlado.
   END f_set_detmovsegurocol;

   -- Bug 23940 - APD - 03/10/2012 - se crea la funcion
   FUNCTION f_set_detrecmovsegurocol (
      psseguro_0      IN   NUMBER,
      pnmovimi_0      IN   NUMBER,
      psseguro_cert   IN   NUMBER,
      pnmovimi_cert   IN   NUMBER,
      pnrecibo        IN   NUMBER,
      psproces        IN   NUMBER
   )
      RETURN NUMBER
   IS
      vparam   VARCHAR2 (2000)
         :=    'psseguro_0: '
            || psseguro_0
            || '; pnmovimi_0: '
            || pnmovimi_0
            || '; psseguro_cert: '
            || psseguro_cert
            || '; pnmovimi_cert: '
            || pnmovimi_cert
            || '; pnrecibo: '
            || pnrecibo
            || '; psproces: '
            || psproces;
   BEGIN
      BEGIN
         INSERT INTO detrecmovsegurocol
                     (sseguro_0, nmovimi_0, sseguro_cert, nmovimi_cert,
                      nrecibo, sproces
                     )
              VALUES (psseguro_0, pnmovimi_0, psseguro_cert, pnmovimi_cert,
                      pnrecibo, psproces
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_seguros.f_set_detrecmovsegurocol',
                      1,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;                               -- Error no controlado.
   END f_set_detrecmovsegurocol;

   --BUG 23860/0130231 - FAL - 01/12/2012
   FUNCTION f_valida_borra_plan (psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER
   IS
      vparam       VARCHAR2 (2000)
                     := 'psseguro: ' || psseguro || ';pfefecto: ' || pfefecto;
      v_resp4089   pregunpolseg.crespue%TYPE;
      nerr         NUMBER;

      CURSOR c_riesgos_baja
      IS
         SELECT nriesgo, fanulac, nmovimb, sseguro
           FROM estriesgos
          WHERE sseguro = (SELECT sseguro
                             FROM estseguros
                            WHERE ssegpol = psseguro)
            AND TO_CHAR (fanulac, 'DD/MM/YYYY') =
                                              TO_CHAR (pfefecto, 'DD/MM/YYYY')
            AND nmovimb = (SELECT MAX (nmovimi) + 1
                             FROM movseguro
                            WHERE sseguro = psseguro);
   BEGIN
      FOR ries IN c_riesgos_baja
      LOOP
         FOR reg IN (SELECT sseguro
                       FROM seguros
                      WHERE npoliza = (SELECT npoliza
                                         FROM seguros
                                        WHERE sseguro = psseguro)
                        AND ncertif > 0)
         LOOP
            nerr :=
               pac_preguntas.f_get_pregunpolseg (reg.sseguro,
                                                 4089,
                                                 'SEG',
                                                 v_resp4089
                                                );

-- no permite baja del plan si es plan del colectivo de alguno de los certificados
            IF v_resp4089 = ries.nriesgo
            THEN
               RETURN 1;
            END IF;
         END LOOP;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_seguros.f_valida_borra_plan',
                      1,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;                               -- Error no controlado.
   END f_valida_borra_plan;

--FI BUG 23860/0130231

   -- BUG 26100 - FAL - 12/04/2013
   FUNCTION f_get_cmoncap (
      psproduc   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcactivi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      wcmoncap   garanpro.cmoncap%TYPE;
      vparam     VARCHAR2 (2000)
         :=    'psproduc: '
            || psproduc
            || ';pcgarant: '
            || pcgarant
            || ';pcactivi: '
            || pcactivi;
   BEGIN
      BEGIN
         SELECT g.cmoncap
           INTO wcmoncap
           FROM garanpro g
          WHERE g.cgarant = pcgarant
            AND g.sproduc = psproduc
            AND g.cactivi = NVL (pcactivi, 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            wcmoncap := NULL;
      END;

      RETURN wcmoncap;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_seguros.f_get_cmoncap',
                      1,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1000455;                               -- Error no controlado.
   END f_get_cmoncap;

-- FI BUG 26100 - FAL - 12/04/2013

   --INICIO BUG 25944  -DCT - 06/05/2013
   /*************************************************************************
       Funci¿n devuelve impvalor1 de la p¿liza del BONUS 603151 (Resp.civil, Perdidas, Terremoto y Patrimonial
       y 603152 (Ajuste R.C, P¿rdidas, Terremoto y Patrimonial
       param in psseguro  : sseguro
       param in pnriesgo  : nriesgo
       param in pnmovimi  : nmovimi
       return             : Porcentaje del bonusmalus
    *************************************************************************/
   FUNCTION f_get_bonusmalus (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'EST'
   )
      RETURN NUMBER
   IS
      valor   NUMBER;
   BEGIN
      IF UPPER (ptablas) = 'EST'
      THEN
         SELECT SUM (impvalor1)
           INTO valor
           FROM (SELECT   cgrup, MAX (NVL (impvalor1, 0)) impvalor1
                     FROM estbf_bonfranseg b
                    WHERE b.sseguro = psseguro
                      AND b.nriesgo = pnriesgo
                      AND (   (b.nmovimi = pnmovimi AND pnmovimi IS NOT NULL
                              )
                           OR     (b.nmovimi =
                                      (SELECT MAX (b2.nmovimi)
                                         FROM estbf_bonfranseg b2
                                        WHERE b.sseguro = b2.sseguro
                                          AND b.nriesgo = b2.nriesgo)
                                  )
                              AND pnmovimi IS NULL
                          )
                      AND b.ctipgrup = 1
                 GROUP BY cgrup);
      ELSE
         SELECT SUM (impvalor1)
           INTO valor
           FROM (SELECT   cgrup, MAX (NVL (impvalor1, 0)) impvalor1
                     FROM bf_bonfranseg b
                    WHERE b.sseguro = psseguro
                      AND b.nriesgo = pnriesgo
                      AND (   (b.nmovimi = pnmovimi AND pnmovimi IS NOT NULL
                              )
                           OR     (b.nmovimi =
                                      (SELECT MAX (b2.nmovimi)
                                         FROM bf_bonfranseg b2
                                        WHERE b.sseguro = b2.sseguro
                                          AND b.nriesgo = b2.nriesgo)
                                  )
                              AND pnmovimi IS NULL
                          )
                      AND b.ctipgrup = 1
                 GROUP BY cgrup);
      END IF;

      RETURN valor;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SEGUROS.F_GET_BONUSMALUS',
                      1,
                         'psseguro = '
                      || psseguro
                      || ' pnriesgo = '
                      || pnriesgo
                      || ' pnmovimi = '
                      || pnmovimi,
                      SQLERRM
                     );
         RETURN NULL;
   END f_get_bonusmalus;

   -- Bug 26989 - APD - 09/05/2013 -  se crea la funcion
   FUNCTION f_valor_asegurado (
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'pac_seguros.f_valor_asegurado';
      vparam        VARCHAR2 (2000)
         :=    'par¿metros - psseguro : '
            || psseguro
            || ' - pnriesgo : '
            || pnriesgo
            || ' - pnmovimi : '
            || pnmovimi;
      vpasexec      NUMBER (5)      := 1;
      vvalor        NUMBER;
   BEGIN
      vvalor := pac_propio.f_valor_asegurado (psseguro, pnriesgo, pnmovimi);
      RETURN vvalor;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      SQLERRM
                     );
         RETURN 0;
   END f_valor_asegurado;

-- Fin Bug 23940

   --BUG27048/150505 - DCT - 05/08/2013 - Inicio -
   PROCEDURE p_modificar_seguro (psseguro IN NUMBER, pcreteni IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   --ptablas IN VARCHAR2 DEFAULT 'EST',
   --psalida OUT NUMBER);
   BEGIN
      UPDATE seguros
         SET creteni = pcreteni
       WHERE sseguro = psseguro;

      COMMIT;
   END;

--BUG27048/150505 - DCT - 05/08/2013 - Fin -

   --Comprovamos si esta en propuesta de suplemento por tratarse de un colectivo
   --adminsitrado que al emitirlo crea un nuevo movimiento de apertura de suplemento
   FUNCTION f_emicol_propsup (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      vret             NUMBER := 0;
      vnmovimi         NUMBER;
      err              NUMBER;
      v_crespue_4084   NUMBER;
      v_crespue_4790   NUMBER;
      vcsituac         NUMBER;
      v_imp_rei        NUMBER := 0;                               -- conf-786
   BEGIN
      SELECT MAX (nmovimi)
        INTO vnmovimi
        FROM movseguro
       WHERE sseguro = psseguro;

      SELECT csituac
        INTO vcsituac
        FROM seguros
       WHERE sseguro = psseguro;

      IF vnmovimi = 2 AND vcsituac = 5
      THEN
         IF pac_seguros.f_es_col_admin (psseguro, 'SEG') = 1
         THEN
            err :=
               pac_preguntas.f_get_pregunpolseg (psseguro,
                                                 4084,
                                                 'SEG',
                                                 v_crespue_4084
                                                );

            IF v_crespue_4084 = 2 AND err = 0
            THEN
               err :=
                  pac_preguntas.f_get_pregunpolseg (psseguro,
                                                    4790,
                                                    'SEG',
                                                    v_crespue_4790
                                                   );

               IF v_crespue_4790 = 1 AND err = 0
               THEN
                  vret := 1;
               END IF;
            END IF;
         END IF;
      END IF;

      ------------------------------------------------------------- conf-786 INICIO
      SELECT DISTINCT mov.cmotmov
                 INTO v_imp_rei
                 FROM movseguro mov,
                      (SELECT   MAX (nmovimi) max_nmovimi, sseguro
                           FROM movseguro mov
                          WHERE sseguro = psseguro
                       GROUP BY sseguro) m
                WHERE mov.sseguro = m.sseguro
                  AND mov.nmovimi = m.max_nmovimi
                  AND mov.cmotmov = 141;

      IF v_imp_rei = 141
      THEN
         vret := v_imp_rei;
      END IF;

------------------------------------------------------------------ conf-786 FIN
      RETURN vret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN vret;
   END f_emicol_propsup;

   -- Bug 30842/0172526 - 15/04/2014
   FUNCTION f_soycertifcero (
      psproduc   IN   NUMBER,
      pnpoliza   IN   NUMBER,
      psseguro   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobject         VARCHAR2 (200) := 'PAC_SEGUROS.f_soycertifcero';
      num_err         NUMBER;
      v_existe        NUMBER;
      v_escertif0     NUMBER;
      isaltacol       BOOLEAN;
      e_param_error   EXCEPTION;
      vret            NUMBER;                   -- 0 => soy 0 / 1 => no soy 0
   BEGIN
      IF pnpoliza IS NULL OR psseguro IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF NVL (f_parproductos_v (psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
      THEN
         v_existe := pac_seguros.f_get_escertifcero (pnpoliza);
         v_escertif0 := pac_seguros.f_get_escertifcero (NULL, psseguro);

         IF v_escertif0 > 0
         THEN
            isaltacol := TRUE;
         ELSE
            IF v_existe > 0
            THEN
               isaltacol := FALSE;
            ELSE
               isaltacol := TRUE;
            END IF;
         END IF;
      ELSE
         isaltacol := FALSE;
      END IF;

      IF isaltacol
      THEN
         vret := 0;
      ELSE
         vret := 1;
      END IF;

      RETURN vret;
   EXCEPTION
      WHEN e_param_error
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      1,
                         'psseguro o pnpoliza = null; psproduc= '
                      || psproduc
                      || ';pnpoliza = '
                      || pnpoliza
                      || ';psseguro = '
                      || psseguro,
                      SQLERRM
                     );
         RETURN 1;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      1,
                         'psproduc= '
                      || psproduc
                      || ';pnpoliza = '
                      || pnpoliza
                      || ';psseguro = '
                      || psseguro,
                      SQLERRM
                     );
         RETURN 1;
   END f_soycertifcero;

   --BUG 27924/151061 - RCL - 20/03/2014
   FUNCTION f_get_movimi_cero_fecha (psseguro_cero IN NUMBER, pfecha IN DATE)
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'pac_seguros.f_get_movimi_cero_fecha';
      vparam        VARCHAR2 (2000)
         :=    'par¿metros - psseguro_cero : '
            || psseguro_cero
            || ' - pfecha : '
            || pfecha;
      vpasexec      NUMBER (5)      := 1;
      vnmovimi      NUMBER;
   BEGIN
      BEGIN
         SELECT MAX (nmovimi)
           INTO vnmovimi
           FROM movseguro gs
          WHERE sseguro = psseguro_cero
            AND fefecto <= pfecha
            AND EXISTS (SELECT 1
                          FROM garanseg
                         WHERE sseguro = gs.sseguro AND nmovimi = gs.nmovimi);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vnmovimi := NULL;
      END;

      RETURN vnmovimi;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      vparam,
                      SQLERRM
                     );
         RETURN NULL;
   END f_get_movimi_cero_fecha;

   -- Actualizado para 34989/209958
   FUNCTION f_fatca_indicios (
      psseguro   IN   NUMBER,
      pctipo     IN   NUMBER,
      pnorden    IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'SEG',
      psperson   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      v_traza             NUMBER := 1;
      v_sperson           NUMBER;
      v_indicio1          NUMBER;
      v_indicio2          NUMBER;
      v_indicio3          NUMBER;
      v_indicio4          NUMBER;
      v_indicio5          NUMBER;
      v_indicio6          NUMBER;
      v_indicio7          NUMBER;
      v_indicio8          NUMBER;
      v_indicio9          NUMBER;
      v_indicio10         NUMBER;
      v_indicio11         NUMBER;
      v_indicio12         NUMBER;
      v_indicio13         NUMBER;
      v_indicio14         NUMBER;
      v_indicio15         NUMBER;
      v_indicio16         NUMBER;
      v_indicio17         NUMBER;
      v_indicio18         NUMBER;
      v_indicio19         NUMBER;
      v_indicio20         NUMBER;
      v_indicio21         NUMBER;
      v_indicio22         NUMBER;
      v_indicio23         NUMBER;
      v_indicio24         NUMBER;
      v_indicio25         NUMBER;
      v_aux1              NUMBER;
      v_aux_10            NUMBER;
      v_aux_13            NUMBER;
      v_obligationes      NUMBER;
      v_abogado_fuera     NUMBER;
      v_fisica_juridica   NUMBER;
   BEGIN
      v_traza := 2;

      IF ptablas = 'EST'
      THEN
         IF pctipo = 1
         THEN
            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM esttomadores t, estseguros s
                WHERE s.sseguro = psseguro
                  AND t.sseguro = s.sseguro
                  AND t.nordtom = pnorden;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN NULL;
            END;
         ELSIF pctipo = 2
         THEN
            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM estassegurats e, estseguros s
                WHERE e.sseguro = psseguro
                  AND e.sseguro = s.sseguro
                  AND e.norden = pnorden;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN NULL;
            END;
         END IF;
      ELSE
         IF pctipo = 1
         THEN
            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM tomadores t, seguros s
                WHERE s.sseguro = psseguro
                  AND t.sseguro = s.sseguro
                  AND t.nordtom = pnorden;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN NULL;
            END;
         ELSIF pctipo = 2
         THEN
            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM asegurados e, seguros s
                WHERE e.sseguro = psseguro
                  AND e.sseguro = s.sseguro
                  AND e.norden = pnorden;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN NULL;
            END;
         END IF;
      END IF;

      IF psperson IS NOT NULL
      THEN
         v_sperson := psperson;
      END IF;

      v_traza := 3;

      IF ptablas = 'EST'
      THEN
         SELECT ctipper
           INTO v_fisica_juridica
           FROM estper_personas
          WHERE sperson = v_sperson;
      ELSE
         SELECT ctipper
           INTO v_fisica_juridica
           FROM per_personas
          WHERE sperson = v_sperson;
      END IF;

      -- Indicios persona f¿sica
      --
      IF v_fisica_juridica = 1
      THEN
         -- Pais de nacimiento:
         -- Si no se encuentra ning¿n dato para 'PAIS_NACIMIENTO', entonces clasificar v_indicio1 como 1.
         --
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio1
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_NACIMIENTO'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio1 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM estper_parpersonas p, paises pp
                   WHERE cparam = 'PAIS_NACIMIENTO'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio1 := 1;
               END;
            END IF;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio1
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_NACIMIENTO'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio1 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM per_parpersonas p, paises pp
                   WHERE cparam = 'PAIS_NACIMIENTO'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio1 := 1;
               END;
            END IF;
         END IF;

         v_traza := 4;

         -- Nacionalidad
         --
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio2
              FROM estper_nacionalidades p, paises pp
             WHERE sperson = v_sperson AND p.cpais = pp.cpais
                   AND pp.cpais = 840;

            IF v_indicio2 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM estper_nacionalidades p, paises pp
                   WHERE sperson = v_sperson AND p.cpais = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio2 := 1;
               END;
            END IF;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio2
              FROM per_nacionalidades p, paises pp
             WHERE sperson = v_sperson AND p.cpais = pp.cpais
                   AND pp.cpais = 840;

            IF v_indicio2 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM per_nacionalidades p, paises pp
                   WHERE sperson = v_sperson AND p.cpais = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio2 := 1;
               END;
            END IF;
         END IF;

         -- Pais de trabajo
         --
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio3
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_TRABAJO'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio3 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM estper_parpersonas p, paises pp
                   WHERE cparam = 'PAIS_TRABAJO'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio3 := 1;
               END;
            END IF;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio3
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_TRABAJO'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio3 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM per_parpersonas p, paises pp
                   WHERE cparam = 'PAIS_TRABAJO'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio3 := 1;
               END;
            END IF;
         END IF;

-- Tiene alg¿n prefijo norteamericano
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (*)
              INTO v_indicio4
              FROM estper_contactos p, paises pp
             WHERE ctipcon IN (1, 2, 5, 6, 12)
               AND pp.codisotel = p.cprefix
               AND p.cprefix = 1
               AND p.sperson = v_sperson;
         ELSE
            SELECT COUNT (*)
              INTO v_indicio4
              FROM per_contactos p, paises pp
             WHERE ctipcon IN (1, 2, 5, 6, 12)
               AND pp.codisotel = p.cprefix
               AND p.cprefix = 1
               AND p.sperson = v_sperson;
         END IF;

-- Tiene alguna direcci¿n con pais de estados unidos
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio5
              FROM estper_direcciones p, provincias pp
             WHERE sperson = v_sperson
               AND p.cprovin = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio5
              FROM per_direcciones p, provincias pp
             WHERE sperson = v_sperson
               AND p.cprovin = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- Pais de residencia
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio6
              FROM estper_detper p, paises pp
             WHERE sperson = v_sperson AND p.cpais = pp.cpais
                   AND pp.cpais = 840;

            IF v_indicio6 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM estper_detper p, paises pp
                   WHERE sperson = v_sperson AND p.cpais = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio6 := 1;
               END;
            END IF;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio6
              FROM per_detper p, paises pp
             WHERE sperson = v_sperson AND p.cpais = pp.cpais
                   AND pp.cpais = 840;

            IF v_indicio6 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM per_detper p, paises pp
                   WHERE sperson = v_sperson AND p.cpais = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio6 := 1;
               END;
            END IF;
         END IF;

         v_traza := 5;

-- Pais de residencia fiscal
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio7
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio7 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM estper_parpersonas p, paises pp
                   WHERE cparam = 'PAIS_FISCAL'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio7 := 1;
               END;
            END IF;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio7
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio7 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux1
                    FROM per_parpersonas p, paises pp
                   WHERE cparam = 'PAIS_FISCAL'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
-- Solo cuando no hay datos entonces clasificar este indicio como tal (v_indicio1 = 1)
                  WHEN NO_DATA_FOUND
                  THEN
                     v_indicio7 := 1;
               END;
            END IF;
         END IF;

-- Pais de residencia fiscal_2
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio8
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio8
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- Pais de residencia fiscal_3
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio9
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio9
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- Pais extranjero con obligaciones fiscales
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio10
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio10 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux_10
                    FROM estper_parpersonas p, paises pp
                   WHERE cparam = 'FOREIGN_COUNTRY_TAX'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT nvalpar
                          INTO v_obligationes
                          FROM estper_parpersonas p
                         WHERE cparam = 'PAIS_OBLIGATIONES'
                           AND sperson = v_sperson;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_obligationes := 2;
                     END;

                     IF v_obligationes = 1
                     THEN
                        v_indicio10 := 1;
                     END IF;
               END;
            END IF;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio10
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio10 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux_10
                    FROM per_parpersonas p, paises pp
                   WHERE cparam = 'FOREIGN_COUNTRY_TAX'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT nvalpar
                          INTO v_obligationes
                          FROM per_parpersonas p
                         WHERE cparam = 'PAIS_OBLIGATIONES'
                           AND sperson = v_sperson;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_obligationes := 2;
                     END;

                     IF v_obligationes = 1
                     THEN
                        v_indicio10 := 1;
                     END IF;
               END;
            END IF;
         END IF;

         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio11
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio11
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio12
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio12
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- Pais extranjero del abogado
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio13
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_ATTORNEY'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio13 = 0
            THEN
               BEGIN
                  SELECT 1
                    INTO v_aux_13
                    FROM estper_parpersonas p, paises pp
                   WHERE cparam = 'FOREIGN_ATTORNEY'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT nvalpar
                          INTO v_abogado_fuera
                          FROM estper_parpersonas p
                         WHERE cparam = 'ABOGADO_FUERA'
                               AND sperson = v_sperson;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_abogado_fuera := 2;
                     END;

                     IF v_abogado_fuera = 1
                     THEN
                        v_indicio13 := 1;
                     END IF;
               END;
            END IF;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio13
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_ATTORNEY'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;

            IF v_indicio13 = 0
            THEN
               BEGIN
                  SELECT pp.cpais
                    INTO v_aux_13
                    FROM per_parpersonas p, paises pp
                   WHERE cparam = 'FOREIGN_ATTORNEY'
                     AND sperson = v_sperson
                     AND p.nvalpar = pp.cpais;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT nvalpar
                          INTO v_abogado_fuera
                          FROM per_parpersonas p
                         WHERE cparam = 'ABOGADO_FUERA'
                               AND sperson = v_sperson;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_abogado_fuera := 2;
                     END;

                     IF v_abogado_fuera = 1
                     THEN
                        v_indicio13 := 1;
                     END IF;
               END;
            END IF;
         END IF;

         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio14
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_ATTORNEY_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio14
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_ATTORNEY_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio15
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_ATTORNEY_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio15
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_ATTORNEY_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

         IF    v_indicio1 > 0
            OR v_indicio2 > 0
            OR v_indicio3 > 0
            OR v_indicio4 > 0
            OR v_indicio5 > 0
            OR v_indicio6 > 0
            OR v_indicio7 > 0
            OR v_indicio8 > 0
            OR v_indicio9 > 0
            OR v_indicio10 > 0
            OR v_indicio11 > 0
            OR v_indicio12 > 0
            OR v_indicio13 > 0
            OR v_indicio14 > 0
            OR v_indicio15 > 0
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'PAC_SEGUROS,F_FACTA_CLAISIFCA',
                         2,
                         'RETORNA 1 FISICA',
                            ' v_indicio1 '
                         || v_indicio1
                         || ' v_indicio2 '
                         || v_indicio2
                         || ' v_indicio3 '
                         || v_indicio3
                         || ' v_indicio4 '
                         || v_indicio4
                         || ' v_indicio5 '
                         || v_indicio5
                         || ' v_indicio6 '
                         || v_indicio6
                         || ' v_indicio7 '
                         || v_indicio7
                         || ' v_indicio8 '
                         || v_indicio8
                         || ' v_indicio9 '
                         || v_indicio9
                         || ' v_indicio10 '
                         || v_indicio10
                         || ' v_indicio11 '
                         || v_indicio11
                         || ' v_indicio12 '
                         || v_indicio12
                         || ' v_indicio13 '
                         || v_indicio13
                         || ' v_indicio14 '
                         || v_indicio14
                         || ' v_indicio15 '
                         || v_indicio15
                        );
            RETURN 1;
         END IF;
      ELSE
         v_traza := 6;

--indicios perosna juridica
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio16
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_INCORPORACION'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio16
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_INCORPORACION'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- Tiene alguna direcci¿n con pais de estados unidos
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio17
              FROM estper_direcciones p, provincias pp
             WHERE sperson = v_sperson
               AND p.cprovin = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio17
              FROM per_direcciones p, provincias pp
             WHERE sperson = v_sperson
               AND p.cprovin = pp.cpais
               AND pp.cpais = 840;
         END IF;

--Algun prefijo telefonico indicador de norteamerica.
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (*)
              INTO v_indicio18
              FROM estper_contactos p, paises pp
             WHERE ctipcon IN (1, 2, 5, 6, 12)
                                              --AND pp.codisotel = p.cprefix
                                              --AND p.cprefix = 1
                   AND p.sperson = v_sperson;
         ELSE
            SELECT COUNT (*)
              INTO v_indicio18
              FROM per_contactos p, paises pp
             WHERE ctipcon IN (1, 2, 5, 6, 12)
                                              --AND pp.codisotel = p.cprefix
                                              --AND p.cprefix = 1
                   AND p.sperson = v_sperson;
         END IF;

         -- Pais de residencia fiscal
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio19
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio19
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- Pais de residencia fiscal_2
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio20
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio20
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- Pais de residencia fiscal_3
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio21
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio21
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'PAIS_FISCAL_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

         -- Propiedad:FOREIGN_COUNTRY_TAX
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio22
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio23
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- -- Propiedad:FOREIGN_COUNTRY_TAX
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio24
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio24
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX_2'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

-- -- Propiedad:FOREIGN_COUNTRY_TAX
         IF ptablas = 'EST'
         THEN
            SELECT COUNT (1)
              INTO v_indicio25
              FROM estper_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         ELSE
            SELECT COUNT (1)
              INTO v_indicio25
              FROM per_parpersonas p, paises pp
             WHERE cparam = 'FOREIGN_COUNTRY_TAX_3'
               AND sperson = v_sperson
               AND p.nvalpar = pp.cpais
               AND pp.cpais = 840;
         END IF;

         IF    v_indicio16 > 0
            OR v_indicio17 > 0
            OR v_indicio18 > 0
            OR v_indicio19 > 0
            OR v_indicio20 > 0
            OR v_indicio21 > 0
            OR v_indicio22 > 0
            OR v_indicio23 > 0
            OR v_indicio24 > 0
            OR v_indicio25 > 0
         THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SEGUROS,f_fatca_indicios',
                      v_traza,
                      ' ',
                      'error: ' || SQLERRM
                     );
         RETURN NULL;
   END f_fatca_indicios;

   FUNCTION f_fatca_clasifica (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      v_cagente           NUMBER;
      v_sperson           NUMBER;
      v_traza             NUMBER;
      v_param             VARCHAR2 (200) := 'psseguro: ' || psseguro;
      v_fisica_juridica   NUMBER;
      v_resultado         NUMBER;
      vcagente_visio      NUMBER;
      vcagente_per        NUMBER;

      CURSOR c_tom
      IS
         (SELECT t.sperson, t.nordtom, s.cagente
            FROM tomadores t, seguros s
           WHERE s.sseguro = psseguro AND t.sseguro = s.sseguro);

      CURSOR c_aseg
      IS
         (SELECT e.sperson, e.norden, s.cagente
            FROM asegurados e, seguros s
           WHERE e.sseguro = psseguro AND e.sseguro = s.sseguro);
   BEGIN
-------------------------------
--claisifca tomadores---------
      v_traza := 1;

      FOR r_tom IN c_tom
      LOOP
         IF r_tom.nordtom = 1
         THEN
            SELECT ctipper
              INTO v_fisica_juridica
              FROM per_personas
             WHERE sperson = r_tom.sperson;

            pac_persona.p_busca_agentes (r_tom.sperson,
                                         NULL,
                                         vcagente_visio,
                                         vcagente_per,
                                         'SEG'
                                        );

            IF v_fisica_juridica = 1
            THEN
               v_resultado := pac_seguros.f_fatca_indicios (psseguro, 1, 1);

               IF v_resultado = 0
               THEN
                  BEGIN
                     INSERT INTO per_parpersonas
                                 (cparam, sperson,
                                  cagente, nvalpar, cusuari, fmovimi
                                 )
                          VALUES ('FATCA_FISICA', r_tom.sperson,
                                  vcagente_per, 3, f_user, f_sysdate
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE per_parpersonas
                           SET nvalpar = 3
                         WHERE cparam = 'FATCA_FISICA'
                           AND sperson = r_tom.sperson
                           AND cagente = vcagente_per;
                  END;
               END IF;
            END IF;
         ELSIF r_tom.nordtom = 2
         THEN
            SELECT ctipper
              INTO v_fisica_juridica
              FROM per_personas
             WHERE sperson = r_tom.sperson;

            pac_persona.p_busca_agentes (r_tom.sperson,
                                         NULL,
                                         vcagente_visio,
                                         vcagente_per,
                                         'SEG'
                                        );

            IF v_fisica_juridica = 1
            THEN
               v_resultado := pac_seguros.f_fatca_indicios (psseguro, 1, 2);

               IF v_resultado = 0
               THEN
                  BEGIN
                     INSERT INTO per_parpersonas
                                 (cparam, sperson,
                                  cagente, nvalpar, cusuari, fmovimi
                                 )
                          VALUES ('FATCA_FISICA', r_tom.sperson,
                                  vcagente_per, 3, f_user, f_sysdate
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE per_parpersonas
                           SET nvalpar = 3
                         WHERE cparam = 'FATCA_FISICA'
                           AND sperson = r_tom.sperson
                           AND cagente = vcagente_per;
                  END;
               END IF;
            END IF;
         END IF;
      END LOOP;

      v_traza := 2;

-------------------------------
--claisifca asegurados---------
      FOR r_aseg IN c_aseg
      LOOP
         IF r_aseg.norden = 1
         THEN
            SELECT ctipper
              INTO v_fisica_juridica
              FROM per_personas
             WHERE sperson = r_aseg.sperson;

            pac_persona.p_busca_agentes (r_aseg.sperson,
                                         NULL,
                                         vcagente_visio,
                                         vcagente_per,
                                         'SEG'
                                        );

            IF v_fisica_juridica = 1
            THEN
               v_resultado := pac_seguros.f_fatca_indicios (psseguro, 2, 1);

               IF v_resultado = 0
               THEN
                  BEGIN
                     INSERT INTO per_parpersonas
                                 (cparam, sperson,
                                  cagente, nvalpar, cusuari, fmovimi
                                 )
                          VALUES ('FATCA_FISICA', r_aseg.sperson,
                                  vcagente_per, 3, f_user, f_sysdate
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE per_parpersonas
                           SET nvalpar = 3
                         WHERE cparam = 'FATCA_FISICA'
                           AND sperson = r_aseg.sperson
                           AND cagente = vcagente_per;
                  END;
               END IF;
            END IF;
         ELSIF r_aseg.norden = 2
         THEN
            SELECT ctipper
              INTO v_fisica_juridica
              FROM per_personas
             WHERE sperson = r_aseg.sperson;

            pac_persona.p_busca_agentes (r_aseg.sperson,
                                         NULL,
                                         vcagente_visio,
                                         vcagente_per,
                                         'SEG'
                                        );

            IF v_fisica_juridica = 1
            THEN
               v_resultado := pac_seguros.f_fatca_indicios (psseguro, 2, 2);

               IF v_resultado = 0
               THEN
                  BEGIN
                     INSERT INTO per_parpersonas
                                 (cparam, sperson,
                                  cagente, nvalpar, cusuari, fmovimi
                                 )
                          VALUES ('FATCA_FISICA', r_aseg.sperson,
                                  vcagente_per, 3, f_user, f_sysdate
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        UPDATE per_parpersonas
                           SET nvalpar = 3
                         WHERE cparam = 'FATCA_FISICA'
                           AND sperson = r_aseg.sperson
                           AND cagente = vcagente_per;
                  END;
               END IF;
            END IF;
         END IF;
      END LOOP;

      v_traza := 3;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SEGUROS,F_FACTA_CLAISIFCA',
                      v_traza,
                      v_param,
                      'error: ' || SQLERRM
                     );
         RETURN 1;
   END f_fatca_clasifica;

   --BUG 34409/  javendano - 22/04/2015
   FUNCTION f_ini_certifn (psseguro IN NUMBER, paccion IN VARCHAR2)
      RETURN NUMBER
   AS
      vobjectname      VARCHAR2 (60)           := 'PAC_SEGUROS.F_INI_CERTIFN';
      vpasexec         NUMBER                         := 0;
      vparam           VARCHAR2 (255)
                        := ' psseguro ' || psseguro || ' paccion ' || paccion;
      num_err          NUMBER;
      v_hereda         NUMBER;
      v_npoliza        seguros.npoliza%TYPE;
      v_ccompani       seguros.ccompani%TYPE;
      v_sproduc        seguros.sproduc%TYPE;
      v_cagente        seguros.cagente%TYPE;
      v_cforpag        seguros.cforpag%TYPE;
      v_crecfra        seguros.crecfra%TYPE;
      v_nmovimi_cero   NUMBER;
      v_nmovimi_est    NUMBER;
      v_fefecto        seguros.fefecto%TYPE;
      v_plan           garanseg.nriesgo%TYPE;
      v_crevali        garanseg.crevali%TYPE;
      v_prevali        garanseg.prevali%TYPE;
      v_irevali        garanseg.irevali%TYPE;
      v_frenova        seguros.frenova%TYPE;
      v_cduraci        seguros.cduraci%TYPE;
      v_ctipcom        NUMBER;
      v_cbancar        NUMBER;
      v_ccobban        seguros.ccobban%TYPE;
      v_ctipban        seguros.ctipban%TYPE;
      vt_asegurado     t_iax_asegurados;
      v_existe_per     NUMBER;
      v_sperficti      estper_personas.sperson%TYPE;
   BEGIN
      vparam := 'Psseguro: ' || psseguro || ' Paccion: ' || paccion;
      vpasexec := 1;
      p_tab_error (f_sysdate, f_user, 'f_ini_certifn', 1, vparam, NULL);

      BEGIN
         SELECT npoliza, sproduc, ccompani, fefecto, crecfra,
                cbancar, ctipban, ccobban
           INTO v_npoliza, v_sproduc, v_ccompani, v_fefecto, v_crecfra,
                v_cbancar, v_ctipban, v_ccobban
           FROM seguros
          WHERE sseguro = psseguro AND ncertif = 0;

         v_nmovimi_cero :=
                     pac_seguros.f_get_movimi_cero_fecha (psseguro, v_fefecto);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         vobjectname,
                         vpasexec,
                         vparam,
                         'No se encontro el sseguro: ' || psseguro
                        );
            RETURN NULL;
      END;

      FOR ch IN (SELECT s.sseguro, s.ncertif, s.ccompani, s.cagente
                   FROM estseguros s
                  WHERE s.npoliza = v_npoliza AND s.ncertif <> 0)
      LOOP
         --ELIMINO RESPUESTAS A PREGUNTAS SEMIAUTOMATICAS
         DELETE      estpregungaranseg
               WHERE cpregun IN (SELECT cpregun
                                   FROM pregunpro
                                  WHERE cpretip = 3 AND sproduc = v_sproduc)
                 AND sseguro = ch.sseguro;

         --ELIMINO PREGUNTAS SEMIAUTOMATICAS
         DELETE      estpregunseg
               WHERE cpregun IN (SELECT cpregun
                                   FROM pregunpro
                                  WHERE cpretip = 3 AND sproduc = v_sproduc)
                 AND sseguro = ch.sseguro;

         DELETE      estpregunpolseg
               WHERE cpregun IN (SELECT cpregun
                                   FROM pregunpro
                                  WHERE cpretip = 3 AND sproduc = v_sproduc)
                 AND sseguro = ch.sseguro;

         --ELIMINO LAS PREGUNTAS DE LAS GARANTIAS QUE NO EST¿N EN EL PADRE
         DELETE      estpregungaranseg r
               WHERE NOT EXISTS (
                        SELECT cgarant
                          FROM garanseg g
                         WHERE g.sseguro = psseguro
                           AND g.cgarant = r.cgarant
                           AND g.nmovimi = (SELECT MAX (g1.nmovimi)
                                              FROM garanseg g1
                                             WHERE g1.sseguro = g.sseguro))
                 AND r.sseguro = ch.sseguro;

         --buscar el max(nmovimi) para ch.sseguro
         SELECT MAX (nmovimi)
           INTO v_nmovimi_est
           FROM estgaranseg
          WHERE sseguro = ch.sseguro;

         --ELIMINO GARANTIAS QUE NO CORRESPONDEN CON LAS DEL PADRE.
         DELETE      estgaranseg eg
               WHERE eg.sseguro = ch.sseguro
                 AND NOT EXISTS (
                         SELECT cgarant
                           FROM garanseg g
                          WHERE g.sseguro = psseguro
                                AND g.cgarant = eg.cgarant);

         INSERT INTO estgaranseg
                     (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden,
                      crevali, ctarifa, icapital, precarg, iextrap, iprianu,
                      ffinefe, cformul, ctipfra, ifranqu, irecarg, ipritar,
                      pdtocom, idtocom, prevali, irevali, itarifa, itarrea,
                      ipritot, icaptot, ftarifa, crevalcar, pdtoint, idtoint,
                      feprev, fpprev, percre, cmatch, tdesmat, pintfin, cref,
                      cintref, pdif, pinttec, nparben, nbns, tmgaran, cderreg,
                      ccampanya, nversio, nmovima, cageven, nfactor, nlinea,
                      cfranq, nfraver, ngrpfra, ngrpgara, nordfra, pdtofra,
                      cmotmov, finider, falta, ctarman, itotanu, pdtotec,
                      preccom, idtotec, ireccom, icaprecomend, ipricom)
            SELECT cgarant, nriesgo, nmovimi, ch.sseguro, finiefe, norden,
                   crevali, ctarifa, icapital, precarg, iextrap, iprianu,
                   ffinefe, cformul, ctipfra, ifranqu, irecarg, ipritar,
                   pdtocom, idtocom, prevali, irevali, itarifa, itarrea,
                   ipritot, icaptot, ftarifa, crevalcar, pdtoint, idtoint,
                   feprev, fpprev, percre, cmatch, tdesmat, pintfin, cref,
                   cintref, pdif, pinttec, nparben, nbns, tmgaran, cderreg,
                   ccampanya, nversio, nmovima, cageven, nfactor, nlinea,
                   cfranq, nfraver, ngrpfra, ngrpgara, nordfra, pdtofra,
                   cmotmov, finider, falta, ctarman, itotanu, pdtotec,
                   preccom, idtotec, ireccom, icaprecomend, ipricom
              FROM garanseg g
             WHERE g.sseguro = psseguro
               AND g.nmovimi = v_nmovimi_cero
               AND NOT EXISTS (
                      SELECT cgarant
                        FROM estgaranseg gs
                       WHERE gs.sseguro = ch.sseguro
                             AND gs.cgarant = g.cgarant);

         --EVALUO LA HERENCIA
         IF NVL
               (pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                       v_sproduc
                                                      ),
                0
               ) = 1
         THEN
            --AGENTE
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 1, v_hereda);

            IF NVL (v_hereda, 0) = 1 AND num_err = 0
            THEN
               v_cagente := pac_seguros.f_get_agentecol (v_npoliza);
            END IF;

            --FORMA DE PAGO
            num_err :=
                     pac_productos.f_get_herencia_col (v_sproduc, 2, v_hereda);

            IF NVL (v_hereda, 0) = 2 AND num_err = 0
            THEN
               v_cforpag := pac_seguros.f_get_cforpagcol (v_npoliza);
            END IF;

            --Recargo fraccionamiento
            num_err :=
                     pac_productos.f_get_herencia_col (v_sproduc, 3, v_hereda);

            IF NVL (v_hereda, 0) = 0 OR num_err != 0
            THEN
               --Si no se hereda o se produce un error evalu¿ndo esa herencia se deja NULL para no acatualizar
               v_crecfra := NULL;
            END IF;

            --Cl¿usulas
            num_err :=
                     pac_productos.f_get_herencia_col (v_sproduc, 4, v_hereda);

            IF NVL (v_hereda, 0) IN (2, 3) AND num_err = 0
            THEN
               --ELIMINO CLAUSULAS DEL HIJO
               DELETE      estclausuesp
                     WHERE sseguro = ch.sseguro;

               --INSERTO LA CLAUSULAS DEL PADRE
               INSERT INTO estclausuesp
                           (nmovimi, sseguro, cclaesp, nordcla, nriesgo,
                            finiclau, sclagen, tclaesp, ffinclau)
                  SELECT v_nmovimi_est, ch.sseguro, cclaesp, nordcla,
                         nriesgo, finiclau, sclagen, tclaesp, ffinclau
                    FROM clausuesp
                   WHERE nmovimi = v_nmovimi_cero AND sseguro = psseguro;
            END IF;

            --Fecha renovaci¿n
            num_err :=
                     pac_productos.f_get_herencia_col (v_sproduc, 6, v_hereda);

            IF NVL (v_hereda, 0) = 1 AND num_err = 0
            THEN
               num_err :=
                       pac_productos.f_get_frenova_col (v_npoliza, v_frenova);
            END IF;

            --Duraci¿n de la p¿liza
            num_err :=
                     pac_productos.f_get_herencia_col (v_sproduc, 7, v_hereda);

            IF NVL (v_hereda, 0) IN (1, 2) AND num_err = 0
            THEN
               num_err :=
                  pac_seguros.f_get_tipo_duracion_cero (NULL,
                                                        v_npoliza,
                                                        'SEG',
                                                        v_cduraci
                                                       );
            END IF;

            --Co-corretaje
            num_err :=
                     pac_productos.f_get_herencia_col (v_sproduc, 8, v_hereda);

            IF NVL (v_hereda, 0) = 1 AND num_err = 0
            THEN
               --vt_corretaje := pac_mdpar_productos.f_get_corretaje(v_sproduc, mensajes);
               DELETE      estage_corretaje
                     WHERE sseguro = ch.sseguro;

               INSERT INTO estage_corretaje
                           (sseguro, cagente, nmovimi, nordage, pcomisi,
                            ppartici, islider)
                  SELECT ch.sseguro, cagente, v_nmovimi_est, nordage,
                         pcomisi, ppartici, islider
                    FROM age_corretaje
                   WHERE nmovimi = v_nmovimi_cero AND sseguro = psseguro;
            END IF;

            --Retorno
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 10, v_hereda);

            IF NVL (v_hereda, 0) = 1 AND num_err = 0
            THEN
               -- vt_retorno := pac_mdpar_productos.f_get_retorno(v_sproduc, mensajes);
               DELETE      estrtn_convenio
                     WHERE sseguro = ch.sseguro;

               FOR ar IN (SELECT sperson
                            FROM rtn_convenio
                           WHERE sseguro = psseguro)
               LOOP
                  BEGIN
                     SELECT COUNT (1)
                       INTO v_existe_per
                       FROM estpersonas
                      WHERE spereal = ar.sperson;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_existe_per := 0;
                  END;

                  IF NVL (v_existe_per, 0) = 0
                  THEN
                     --CREAR PERSONA EN EST
                     pac_persona.traspaso_tablas_per (ar.sperson,
                                                      v_sperficti,
                                                      ch.sseguro,
                                                      ch.cagente
                                                     );
                  ELSE
                     v_sperficti := ar.sperson;
                  END IF;

                  INSERT INTO estrtn_convenio
                              (sseguro, sperson, nmovimi, pretorno,
                               idconvenio)
                     SELECT ch.sseguro, v_sperficti, v_nmovimi_est, pretorno,
                            idconvenio
                       FROM rtn_convenio
                      WHERE sseguro = psseguro AND nmovimi = v_nmovimi_cero;
               END LOOP;
            END IF;

            BEGIN
               SELECT crespue
                 INTO v_plan
                 FROM pregunpolseg
                WHERE sseguro = psseguro
                  AND cpregun = 4089
                  AND nmovimi = v_nmovimi_cero;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_plan := NULL;
            END;

            --Revalorizaci¿n
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 11, v_hereda);
            vpasexec := 2;

            IF NVL (v_hereda, 0) = 1 AND num_err = 0
            THEN
               BEGIN
                  SELECT g.crevali
                    INTO v_crevali
                    FROM garanseg g, seguros s, garanpro gg
                   WHERE g.sseguro = s.sseguro
                     AND g.nriesgo = v_plan
                     AND g.ffinefe IS NULL
                     AND gg.sproduc = s.sproduc
                     AND gg.cgarant = g.cgarant
                     AND gg.cbasica = 1
                     AND ROWNUM = 1
                     AND s.npoliza = v_npoliza
                     AND s.ncertif = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT g.crevali
                          INTO v_crevali
                          FROM garanseg g, seguros s, garanpro gg
                         WHERE g.sseguro = s.sseguro
                           AND g.nriesgo = v_plan
                           AND g.ffinefe IS NULL
                           AND gg.sproduc = s.sproduc
                           AND gg.cgarant = g.cgarant
                           AND ROWNUM = 1
                           AND s.npoliza = v_npoliza
                           AND s.ncertif = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_crevali := 0;
                           p_tab_error
                              (f_sysdate,
                               f_user,
                               vobjectname,
                               vpasexec,
                                  'No se ha encontrado revalorizaci¿n de la garant¿a. - vplan='
                               || v_plan
                               || ' - npoliza='
                               || v_npoliza,
                               SQLERRM
                              );
                     END;
               END;
            END IF;

            --Importe revalorizaci¿n
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 12, v_hereda);

            IF NVL (v_hereda, 0) = 1 AND num_err = 0
            THEN
               BEGIN
                  SELECT NVL (g.prevali, 0), NVL (g.irevali, 0)
                    INTO v_prevali, v_irevali
                    FROM garanseg g, seguros s, garanpro gg
                   WHERE g.sseguro = s.sseguro
                     AND g.nriesgo = v_plan
                     AND g.ffinefe IS NULL
                     AND gg.sproduc = s.sproduc
                     AND gg.cgarant = g.cgarant
                     AND gg.cbasica = 1
                     AND ROWNUM = 1
                     AND s.npoliza = v_npoliza
                     AND s.ncertif = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT NVL (g.prevali, 0), NVL (g.irevali, 0)
                          INTO v_prevali, v_irevali
                          FROM garanseg g, seguros s, garanpro gg
                         WHERE g.sseguro = s.sseguro
                           AND g.nriesgo = v_plan
                           AND g.ffinefe IS NULL
                           AND gg.sproduc = s.sproduc
                           AND gg.cgarant = g.cgarant
                           AND ROWNUM = 1
                           AND s.npoliza = v_npoliza
                           AND s.ncertif = 0;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           v_prevali := 0;
                           v_irevali := 0;
                           p_tab_error
                              (f_sysdate,
                               f_user,
                               vpasexec,
                               vpasexec,
                                  'No se ha encontrado revalorizaci¿n de la garant¿a. - vplan='
                               || v_plan
                               || ' - npoliza='
                               || v_npoliza,
                               SQLERRM
                              );
                     END;
               END;
            END IF;

            --Comisi¿n
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 13, v_hereda);

            IF NVL (v_hereda, 0) = 1 AND num_err = 0 AND v_ctipcom IN
                                                                     (90, 92)
            THEN
               DELETE      estcomisionsegu
                     WHERE sseguro = ch.sseguro;

               INSERT INTO estcomisionsegu
                           (sseguro, cmodcom, pcomisi, ninialt, nfinalt,
                            nmovimi)
                  SELECT ch.sseguro, cmodcom, pcomisi, ninialt, nfinalt,
                         v_nmovimi_est
                    FROM comisionsegu
                   WHERE sseguro = psseguro AND nmovimi = v_nmovimi_cero;
            END IF;

            --Coaseguro
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 14, v_hereda);

            IF NVL (v_hereda, 0) = 1
            THEN
               -- vt_coacuadro := pac_md_obtenerdatos.f_leercoacuadro(ch.sseguro, mensajes, 1);
               DELETE      estcoacedido
                     WHERE sseguro = ch.sseguro;

               DELETE      estcoacuadro
                     WHERE sseguro = ch.sseguro;

               INSERT INTO estcoacuadro
                           (sseguro, ncuacoa, ploccoa, finicoa, ffincoa,
                            fcuacoa, ccompan, npoliza)
                  SELECT ch.sseguro, ncuacoa, ploccoa, finicoa, ffincoa,
                         fcuacoa, ccompan, npoliza
                    FROM coacuadro
                   WHERE sseguro = psseguro;

               INSERT INTO estcoacedido
                           (sseguro, ncuacoa, ccompan, pcomcoa, pcomgas,
                            pcomcon, pcescoa, pcesion)
                  SELECT ch.sseguro, ncuacoa, ccompan, pcomcoa, pcomgas,
                         pcomcon, pcescoa, pcesion
                    FROM coacedido
                   WHERE sseguro = psseguro;
            END IF;

            --Cuenta bancaria
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 16, v_hereda);

            IF NVL (v_hereda, 0) = 0 AND num_err != 0
            THEN
               v_cbancar := NULL;
               v_ctipban := NULL;
            END IF;

            --Cobrador bancario
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 17, v_hereda);

            IF NVL (v_hereda, 0) = 0 AND num_err != 0
            THEN
               v_ccobban := NULL;
            END IF;

            --Documentaci¿n requerida
            --num_err := pac_productos.f_get_herencia_col(v_sproduc, 18, v_hereda);
            --????? validar con David

            --Asegurado
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 19, v_hereda);

            IF NVL (v_hereda, 0) = 1 AND num_err = 0
            THEN
               --vt_asegurado := pac_md_obtenerdatos.f_leeasegurados(1, mensajes);
               DELETE      estassegurats
                     WHERE sseguro = ch.sseguro;

               FOR ap IN (SELECT sperson
                            FROM asegurados
                           WHERE sseguro = psseguro)
               LOOP
                  BEGIN
                     SELECT COUNT (1)
                       INTO v_existe_per
                       FROM estpersonas
                      WHERE spereal = ap.sperson;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_existe_per := 0;
                  END;

                  IF NVL (v_existe_per, 0) = 0
                  THEN
                     --CREAR PERSONA EN EST
                     pac_persona.traspaso_tablas_per (ap.sperson,
                                                      v_sperficti,
                                                      ch.sseguro,
                                                      ch.cagente
                                                     );
                  ELSE
                     v_sperficti := ap.sperson;
                  END IF;

                  INSERT INTO estassegurats
                              (sseguro, sperson, norden, cdomici, ffecini,
                               ffecfin, ffecmue, nriesgo, fecretroact)
                     SELECT ch.sseguro, v_sperficti, norden, cdomici, ffecini,
                            ffecfin, ffecmue, nriesgo, fecretroact
                       FROM asegurados
                      WHERE sseguro = psseguro AND sperson = ap.sperson;
               END LOOP;
            END IF;

            --Beneficiarios
            num_err :=
                    pac_productos.f_get_herencia_col (v_sproduc, 20, v_hereda);

            IF NVL (v_hereda, 0) = 1 AND num_err = 0
            THEN
               DELETE      estbenespseg
                     WHERE sseguro = ch.sseguro;

               FOR bp IN (SELECT sperson
                            FROM benespseg
                           WHERE sseguro = psseguro)
               LOOP
                  BEGIN
                     SELECT COUNT (1)
                       INTO v_existe_per
                       FROM estper_personas
                      WHERE spereal = bp.sperson;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_existe_per := 0;
                  END;

                  IF NVL (v_existe_per, 0) = 0
                  THEN
                     --CREAR PERSONA EN EST
                     pac_persona.traspaso_tablas_per (bp.sperson,
                                                      v_sperficti,
                                                      ch.sseguro,
                                                      ch.cagente
                                                     );
                  ELSE
                     v_sperficti := bp.sperson;
                  END IF;

                  INSERT INTO estbenespseg
                              (sseguro, nriesgo, cgarant, nmovimi, sperson,
                               sperson_tit, finiben, ffinben, ctipben, cparen,
                               pparticip, cusuari, fmovimi, cestado)
                     SELECT ch.sseguro, nriesgo, cgarant, nmovimi,
                            v_sperficti, sperson_tit, finiben, ffinben,
                            ctipben, cparen, pparticip, cusuari, fmovimi,
                            cestado
                       FROM benespseg
                      WHERE sseguro = psseguro AND sperson = bp.sperson;
               END LOOP;
            END IF;

            --ACTUALIZO LOS DATOS QUE CREO POSIBLES EN LA TABLA SEGUROS PARA EL CERTIFICADO QUE SE ESTA EVALUANDO.
            UPDATE estseguros
               SET cagente = NVL (v_cagente, cagente),
                   crecfra = NVL (v_crecfra, crecfra),
                   cforpag = NVL (v_cforpag, cforpag),
                   frenova = NVL (v_frenova, frenova),
                   ccompani = NVL (v_ccompani, ccompani),
                   cduraci = NVL (v_cduraci, cduraci),
                   cbancar = NVL (v_cbancar, cbancar),
                   ctipban = NVL (v_ctipban, ctipban),
                   ccobban = NVL (v_ccobban, ccobban),
                   npoliza = DECODE (paccion, 'EMITIR', v_npoliza, npoliza)
             WHERE sseguro = ch.sseguro;
         END IF;
      END LOOP;

      RETURN 0;
   END f_ini_certifn;

   FUNCTION f_get_tomador_poliza (
      psseguro   IN   NUMBER,
      nordtom    IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   AS
      vsperson   NUMBER;
   BEGIN
      SELECT sperson
        INTO vsperson
        FROM tomadores t
       WHERE t.sseguro = psseguro
         AND t.nordtom =
                (SELECT MIN (t1.nordtom)
                   FROM tomadores t1
                  WHERE t1.sseguro = t.sseguro
                    AND t1.nordtom = NVL (nordtom, t1.nordtom));

      RETURN vsperson;
   EXCEPTION
      WHEN OTHERS
      THEN
         vsperson := 0;
   END f_get_tomador_poliza;

   PROCEDURE p_notifica (
      psseguro   IN       NUMBER,
      pctipeve   IN       NUMBER,
      pnumerr    OUT      NUMBER,
      precibo    IN       NUMBER DEFAULT NULL
   )
   IS
/*
Esta funci¿n ser¿ la encargada de disparar o iniciar el proceso de notificaci¿n a las personas relacionadas
con el seguro sobre el que se est¿ realizando la acci¿n.
Deber¿ preparar los par¿metros para iniciar el proceso de env¿o, registrar en la tabla INT_NOTIFICACION_SOA
el inicio del proceso con estado ¿XXXX¿ e iniciar el proceso de env¿o de informaci¿n a AxisConnectNT.

PARAMETRO    TIPO    E/S    DEFINICION
PSSEGURO    NUMBER    E    N¿mero de persona
CTIPEVE        NUMBER    E    Tipo de evento que genera la notificaci¿n
NUMERR        NUMBER    S    N¿mero de error
*/
      psinterf   NUMBER;
      vnumerr    NUMBER;
      pcidioma   NUMBER;
      vcestnot   NUMBER;
      vcresul    int_resultado.cresultado%TYPE;
      vnerror    int_resultado.nerror%TYPE;
      mensajes   t_iax_mensajes;
   BEGIN
      pnumerr := 0;
      pcidioma := f_idiomauser;

      FOR c IN (SELECT cvalemp, cvaldef
                  FROM int_codigos_emp
                 WHERE ccodigo = 'DOCUMENTO_MAILING' AND cvalaxis = pctipeve)
      LOOP
         IF c.cvaldef IN ('RECIBO', 'DOCPOL')
         THEN
            pac_md_impresion.f_imprimir_recibo_ensa_mail (precibo,
                                                          NULL,
                                                          psseguro,
                                                          c.cvalemp,
                                                          c.cvaldef,
                                                          mensajes
                                                         );
         ELSE
            pac_seguros.p_imprime_doc (psseguro, c.cvalemp);
         END IF;
      END LOOP;

      IF psseguro IS NULL OR pctipeve IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'p_notifica',
                      1,
                      'Faltan parametros',
                      'psseguro: ' || psseguro || ' pctipeve: ' || pctipeve
                     );
         pnumerr := -1;
      ELSE
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;

         --verror := pac_int_online.f_int(6, '', 'IN01', '1575');
         BEGIN
            INSERT INTO int_notificacion_soa
                        (sinterf, ctipnot, cestnot, sseguro, ctipeve,
                         nintento, falta, fmodif,
                         cusua,
                         cusum
                        )
                 VALUES (psinterf, 3,                           -- SMS y email
                                     0,                  -- Pendiente de envio
                                       psseguro, pctipeve,
-- tipo evento Ej.- : EmisionPoliza , o Emision Recibo, Emision Siniestro -- etc,
                         0, f_sysdate, f_sysdate,
                         NVL (f_user, 'USER SIN INFO'),
                         NVL (f_user, 'USER SIN INFO')
                        );

            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'p_notifica',
                            1,
                            'Error al Insertar tabla int_notificacion_soa',
                               ' psseguro: '
                            || psseguro
                            || ' pctipeve: '
                            || pctipeve
                            || ' '
                            || SQLCODE
                            || ' - '
                            || SQLERRM
                           );
               pnumerr := -1;
         END;

         IF pnumerr = 0
         THEN
            DBMS_OUTPUT.put_line ('entrando a p_procesa_notif');
            p_tab_error (f_sysdate,
                         f_user,
                         'p_notifica',
                         1,
                         'entrando a p_procesa_notif',
                         ''
                        );
            pac_seguros.p_procesa_notif (psinterf,
                                         pctipeve,
                                         0,
                                         vnumerr,
                                         precibo
                                        );
            DBMS_OUTPUT.put_line ('saliendo de p_procesa_notif');

            IF vnumerr <> 0
            THEN
               vcestnot := 3;                                        -- Error
            ELSE
               BEGIN
                  SELECT cresultado, nerror
                    INTO vcresul, vnerror
                    FROM int_resultado
                   WHERE sinterf = psinterf;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     vcresul := NULL;
                     vnerror := NULL;
               END;

               IF vcresul = '0' AND vnerror = '0'
               THEN
                  vcestnot := 2;                                 -- Entregado
               ELSE
                  vcestnot := 3;                                     -- Error
               END IF;
            END IF;

            BEGIN
/*                    UPDATE int_notificacion_soa
                                SET cestnot  = vcestnot, -- Entregado (2) o Error (3)
                                    nintento = nintento + 1
                              WHERE sinterf = psinterf;*/
               COMMIT;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error
                           (f_sysdate,
                            f_user,
                            'p_notifica',
                            1,
                            'Error al Actualizar tabla int_notificacion_soa',
                               ' psseguro: '
                            || psseguro
                            || ' pctipeve: '
                            || pctipeve
                            || ' '
                            || SQLCODE
                            || ' - '
                            || SQLERRM
                           );
                  pnumerr := -1;
                  RETURN;
            END;
         END IF;

         pnumerr := vnumerr;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         pnumerr := -1;
         p_tab_error (f_sysdate, f_user, 'p_notifica', 1, SQLCODE, SQLERRM);
   END p_notifica;

   PROCEDURE p_procesa_notif (
      psinterf   IN       NUMBER,
      pctipeve   IN       NUMBER,
      pitippro   IN       NUMBER,
      pnumerr    OUT      NUMBER,
      precibo    IN       NUMBER DEFAULT NULL
   )
   IS
/*
Esta funci¿n ser¿ la encargada de procesar los mensajes que se encuentren en la tabla  INT_NOTIFICACION_SOA
en un estado que permita el env¿o a SOA.

PARAMETRO    TIPO        E/S    DEFINICION
PSINTERF    NUMBER        E    N¿mero de interficie (int_notificacion_soa)
ITIPPRO        NUMBER(1)    E    Indicador tipo proceso (0-Online,1-batch)
NUMERR        NUMBER        S    N¿mero de error

La funci¿n recibir¿ por par¿metros el c¿digo identificativo del registro de la tabla INT_NOTIFICACION_SOA que se procesar¿.
Si este valor est¿ informado, deber¿ enviarse el par¿metro ITIPPRO informado a ¿0¿,
indicando que el proceso es online, es decir, deber¿ tratarse solo el registro indicado por el par¿metro SINTERF.

Si por el contrario ITIPPRO viene informado a 1, indicar¿ que se deber¿n reprocesar todos aquellos mensajes que est¿n en un
estado que permita el reenv¿o. En este caso SINTERF no deber¿ informarse.

*/
      verror     NUMBER;
      vcestnot   NUMBER;
      vcresul    int_resultado.cresultado%TYPE;
      vnerror    int_resultado.nerror%TYPE;

      CURSOR c_procesa_elenvio (
         pint_sinterf   IN   int_notificacion_soa.sinterf%TYPE
      )
      IS
         SELECT p.*
           FROM int_notificacion_soa p
          WHERE p.sinterf = pint_sinterf;

      CURSOR c_procesa_envios
      IS
         SELECT p.*
           FROM int_notificacion_soa p
          WHERE p.cestnot IN (0, 1, 3);
   -- 0 Pendiente de envio
   -- 1 Enviado
   -- 2 Entregado
   -- 3 Error
   BEGIN
      -- 1 = batch
      IF pitippro = 1
      THEN
         IF psinterf > 0 AND psinterf IS NOT NULL
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'p_procesa_notif',
                         1,
                         'Inconsistencia de parametros batch',
                         'psinterf: ' || psinterf || ' pitippro: ' || pitippro
                        );
            RETURN;
         END IF;
      ELSIF pitippro = 0
      THEN                                                       -- 0 = online
         IF psinterf = 0 OR psinterf IS NULL
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'p_procesa_notif',
                         1,
                         'Inconsistencia de parametros online',
                         'psinterf: ' || psinterf || ' pitippro: ' || pitippro
                        );
            RETURN;
         END IF;
      ELSE
         p_tab_error (f_sysdate,
                      f_user,
                      'p_procesa_notif',
                      1,
                      'Parametro pitippro con valor distinto de [0/1]',
                      ' pitippro: ' || pitippro
                     );
         RETURN;
      END IF;

      SELECT pac_contexto.f_inicializarctx
                                   (pac_parametros.f_parempresa_t (6,
                                                                   'USER_BBDD'
                                                                  )
                                   )
        INTO verror
        FROM DUAL;

      IF pitippro = 0
      THEN                                                       -- 0 = online
         -- solo proceso informado en psinterf
         FOR reg_elenvio IN c_procesa_elenvio (psinterf)
         LOOP
            verror :=
               pac_int_online.f_int (6,
                                     psinterf,
                                     'IN01',
                                        TO_CHAR (pctipeve)
                                     || '|'
                                     || reg_elenvio.sseguro
                                     || '|'
                                     || TO_CHAR (precibo)
                                    );
            pnumerr := verror;
         END LOOP;

         --verror := pac_int_online.f_int(6, psinterf, 'IN01', '1575');
         pnumerr := verror;
         RETURN;
      END IF;

      IF pitippro = 1
      THEN                                                        -- 1 = batch
         --  proceso con cursor sobre tabla INT_NOTIFICACION_SOA
         pnumerr := 0;                                                      --

         FOR reg_envio IN c_procesa_envios
         LOOP
            verror :=
                  pac_int_online.f_int (6, reg_envio.sinterf, 'IN01', '1575');

            IF verror <> 0
            THEN
               vcestnot := 3;                                        -- Error
               pnumerr := pnumerr + 1;
            ELSE
               BEGIN
                  SELECT cresultado, nerror
                    INTO vcresul, vnerror
                    FROM int_resultado
                   WHERE sinterf = psinterf;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     vcresul := NULL;
                     vnerror := NULL;
               END;

               IF vcresul = '0' AND vnerror = '0'
               THEN
                  vcestnot := 2;                                 -- Entregado
               ELSE
                  vcestnot := 3;                                     -- Error
               END IF;
            END IF;

            BEGIN
               UPDATE int_notificacion_soa
                  SET cestnot = vcestnot,         -- Entregado (2) o Error (3)
--                                    nintento = nintento + 1,
                      fmodif = f_sysdate,
                      cusum = NVL (f_user, 'USER SIN INFO')
                WHERE sinterf = reg_envio.sinterf;

               COMMIT;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error
                           (f_sysdate,
                            f_user,
                            'p_notifica',
                            1,
                            'Error al Actualizar tabla int_notificacion_soa',
                               ' sinterf: '
                            || reg_envio.sinterf
                            || ' ctipeve: '
                            || reg_envio.ctipeve
                           );
                  pnumerr := -1;
            END;
         END LOOP;
      END IF;
   END p_procesa_notif;

/*
Funci¿n que se encarga de realizar la llamada a la impresi¿n de los documentos de p¿liza para el env¿o de email de ENSA.
*/
   PROCEDURE p_imprime_doc (psseguro IN NUMBER, pnombreplant IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vnumerr      NUMBER;
      vtfilename   VARCHAR2 (200);
      vparamimp    pac_isql.vparam;
      mensajes     t_iax_mensajes;
      vt_obj       t_iax_impresion              := t_iax_impresion ();
      vobj         ob_iax_impresion             := ob_iax_impresion ();
      vpolinf      pac_md_impresion.ob_info_imp;
      vcidioma     NUMBER;
      v_poliza     VARCHAR2 (20);
   BEGIN
      vcidioma := 4;

      SELECT npoliza || '-' || ncertif
        INTO v_poliza
        FROM seguros
       WHERE sseguro = psseguro;

      vparamimp (1).par := 'PMT_IDIOMA';
      vparamimp (1).val := vcidioma;
      vparamimp (2).par := 'PMT_SSEGURO';
      vparamimp (2).val := psseguro;
      --Fin par¿metros
      vpolinf.cidioma := vcidioma;
      vtfilename := pnombreplant || '_' || v_poliza || '.rtf';
      --Nombre que tendr¿ el fichero de prueba que generemos
      vnumerr := pac_contexto.f_inicializarctx ('AXIS_ENSA');
--Usuario que ejecuta la plantilla (AXIS_XXX) donde XXX es el d¿digo de cliente
      pac_contexto.p_contextoasignaparametro ('IAX_IDIOMA', vcidioma);
                                                      --Idioma de la plantilla
      --Impresi¿n de la plantilla.
      vobj :=
         pac_md_impresion.f_detimprimir (vpolinf,
                                         pnombreplant,
                                         vparamimp,
                                         vtfilename,
                                         mensajes
                                        );

      IF vobj IS NULL
      THEN
         IF mensajes IS NOT NULL
         THEN
            FOR i IN 1 .. mensajes.LAST ()
            LOOP
               DBMS_OUTPUT.put_line (   mensajes (i).cerror
                                     || ' - '
                                     || mensajes (i).terror
                                    );
            END LOOP;
         ELSE
            DBMS_OUTPUT.put_line ('No hay documentaci¿n');
         END IF;
      ELSE
         DBMS_OUTPUT.put_line (vobj.descripcion || ' - ' || vobj.fichero);
      END IF;

      COMMIT;
   END p_imprime_doc;

   FUNCTION f_borrar_simulaciones (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200) := 'param - psseguro: ' || psseguro;
      vobject    VARCHAR2 (200) := 'pac_seguros.f_borrar_simulaciones';
      vsproduc   NUMBER;
      vsseguro   NUMBER;
      vscertif   NUMBER;
      vnpoliza   NUMBER;
      v_count    NUMBER;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      p_tab_error (f_sysdate,
                   f_user,
                   vobject,
                   vpasexec,
                   'traza',
                   ' psseguro-->' || psseguro || ' vsproduc-->' || vsproduc
                  );
      vpasexec := 2;

      --Comprobamos si para el producto del parametro de entrada tiene parametrizado que debe borrar las simulaciones creadas
      IF NVL (f_parproductos_v (vsproduc, 'BORRAR_SIMUL'), 0) IN (1)
      THEN
         SELECT ncertif
           INTO vscertif
           FROM seguros
          WHERE sseguro = psseguro;

         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'traza',
                         ' psseguro-->'
                      || psseguro
                      || ' vsproduc-->'
                      || vsproduc
                      || ' vscertif-->'
                      || vscertif
                     );
         vpasexec := 3;

         IF vscertif = 0
         THEN
            SELECT npoliza
              INTO vnpoliza
              FROM seguros
             WHERE sseguro = psseguro;

            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                         'traza',
                            ' psseguro-->'
                         || psseguro
                         || ' vsproduc-->'
                         || vsproduc
                         || '  vnpoliza-->'
                         || vnpoliza
                        );
            vpasexec := 4;

            --Se valida si existen simulaciones para borrar
            SELECT COUNT (1)
              INTO v_count
              FROM estseguros
             WHERE npoliza = vnpoliza AND csituac = 7 AND ncertif <> 0;

            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                         'traza',
                            ' psseguro-->'
                         || psseguro
                         || ' vsproduc-->'
                         || vsproduc
                         || '  vnpoliza-->'
                         || vnpoliza
                         || ' v_count'
                         || v_count
                        );
            vpasexec := 5;

            ---Se borran  todas las simulaciones para la car¿tula
            IF v_count > 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                            'traza',
                               ' psseguro-->'
                            || psseguro
                            || ' vsproduc-->'
                            || vsproduc
                            || '  vnpoliza-->'
                            || vnpoliza
                            || ' v_count'
                            || v_count
                           );

               FOR c IN (SELECT sseguro
                           FROM estseguros
                          WHERE npoliza = vnpoliza
                            AND csituac = 7
                            AND ncertif <> 0)
               LOOP
                  vsseguro := c.sseguro;
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               'traza',
                                  ' psseguro-->'
                               || psseguro
                               || ' vsproduc-->'
                               || vsproduc
                               || '  vnpoliza-->'
                               || vnpoliza
                               || ' v_count'
                               || v_count
                               || ' vsseguro'
                               || vsseguro
                              );
                  ---Borra las simulaciones
                  pac_alctr126.borrar_tablas_est (vsseguro);
               END LOOP;
            END IF;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' -  r' || SQLERRM
                     );
         RETURN 103286;
   END f_borrar_simulaciones;
END pac_seguros;
/