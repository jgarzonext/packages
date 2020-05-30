/* Formatted on 2019/05/10 15:47 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package Body PAC_MD_VALIDACIONES
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_md_validaciones
AS
   /******************************************************************************
      NAME:       PAC_MD_VALIDACIONES
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        09/10/2007                    1. Created this package body.
      2.0        04/03/2009    AMC             2. Se añaden nuevas funciones
      3.0        11/03/2009    DRA             3. 0009216: IAX - Revisió de la gestió de garanties en la contractació
      4.0        27/02/2009    RSC             4. Adaptación iAxis a productos colectivos con certificados
      5.0        22/04/2009    AMC             5. Se corrigen literales erroneos.
      5.1        27/03/2009    APD             6. Bug 9446 (precisiones var numericas)
      6.0        27/05/2009    ETM             7. 0010231: APR - Límite de aportaciones en productos fiscales
      7.0        19/06/2009    JRB             8. errores en la validación de preguntas
      8.0        30/06/2009    ETM             9. 0010515: CRE069 - Validación de asegurado en ramos de salud y bajas
      9.0        21/09/2009    DRA            10  0011091: APR - error en la pantalla de simulacion
     10.0        15/10/2009    FAL            11. 0011330: CRE - Bajas a al próximo recibo
     11.0        20/10/2009    FAL            12. 0011518: CEM - Garantía de regularización de prima mínima en los TAR
     12.0        17/11/2009    NMM            13. 11998: CRE201 - Suplemento de alta de asegurados recien nacidos.
     13.0        17/11/2009    NMM            14. 12252: we can't put in insured person in simulation
     14.0        15/12/2009    ICV            15. 0012307: CRE - Modificaciones en el producto Saldo Deutors
     15.0        30/12/2009    APD            16. 0012499: CEM - ESCUT CONSTANT 95 - Desdoblar en dos productos: préstamos personales e hipotecarios
     16.0        03/01/2010    JRH            16. 0012499: CEM - ESCUT CONSTANT 95 - Desdoblar en dos productos: préstamos personales e hipotecarios
     17.0        26/01/2010    JMF            17. 0011733: APR - suplemento de cambio forma de pago
     18.0        27/01/2010    DRA            18. 0012421: CRE 80- Saldo deutors II
     19.0        10/03/2010    DRA            19. 0013360: MODIFICACIONS RENDES VITALICIES
     20.0        22/03/2010    ICV            20. 0013640: CRE202 - Nuevo control en fecha vencimiento producto PPJ Garantit
     21.0        29/03/2010    DRA            21. 0013945: CRE 80- Saldo deutors III
     22.0        12/04/2010    FAL            22. 0013945: CRE 80- Saldo deutors III
     23.0        30/04/2010    DRA            23. 0014279: CRE 80- Saldo deutors IV
     24.0        08/09/2010    DRA            24. 0015617: AGA103 - migración de pólizas - Numeración de polizas
     25.0        23/09/2010    XPL            25. 16105: CRT101- Informar cuando una pregunta es obligatoria a nivel de garantia de la garantia + pregunta
     26.0        11/01/2011    APD            26. 17221: APRA - Ajustes GROUPLIFE
     27.0        17/05/2011    APD            27. 0018362: LCOL003 - Parámetros en cláusulas y visualización cláusulas automáticas
     28.0        16/06/2011    RSC            28. 0018631: ENSA102- Alta del certificado 0 en Contribucion definida
     29.0        27/06/2011    APD            29. 0018848: LCOL003 - Vigencia fecha de tarifa
     30.0        19/10/2011    RSC            30. 0019412: LCOL_T004: Completar parametrización de los productos de Vida Individual
     31.0        27/09/2011    DRA            31. 0019069: LCOL_C001 - Co-corretaje
     32.0        14/11/2011    DRA            32. 0020146: AGM - Control asegurado ya tiene pólizas pendientes de evaluación. (para asegurado)
     33.0        16/11/2011    JMC            33. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
     34.0        15/11/2011    APD            34. 0019169: LCOL_C001 - Campos nuevos a aÃ±adir para Agentes.
     35.0        10/12/2011    RSC            35. 0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
     36.0        16/12/2011    APD            36. 0020576: LCOL_C001: Validació co-corretatge
     37.0        04/01/2012    RSC            37. 0020671: LCOL_T001-LCOL - UAT - TEC: Contratación
     38.0        23/01/2012    APD            38. 0020995: LCOL - UAT - TEC - Incidencias de Contratacion
     39.0        30/01/2012    APD            39. 0020995: LCOL - UAT - TEC - Incidencias de Contratacion
     40.0        21/03/2012    APD            40. 0021785: CRE800: PPJ Garantit Control edat màxima contractació
     41.0        17/04/2012    RSC            41. 0022016: LCOL - Ajustes de parametrización LCOL
     42.0        23/01/2013    MMS            42. 0025584: f_controledad agregamos el parametro pnedamar
     43.0        04/03/2013    AEG            43. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
     44.0        05/06/2013    MMS            44. 0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)
     45.0        28/08/2013    RCL            45. 0028479: LCOL895-Incidencias Fase 2 Post-Producci?n UAT
     46.0        06/11/2013    JSV            46. 0027768: LCOL_F3B-Fase 3B - Parametrizaci?n B?sica AWS
     47.0        25/11/2013    JSV            47. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
     48.0        11/12/2013    JDS            48. 0029315: LCOL_T031-Revisi?n Q-Trackers Fase 3A III
     49.0        16/01/2014    MMS            49. 0027305: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Conmutacion Pensional
     50.0        06/05/2014    ECP            50. 0031204: LCOL896-Soporte a cliente en Liberty (Mayo 2014) /0012459: Error en beneficiarios al duplicar Solicitudes
     51.0        23-06-2014    SSM            51  (30145/175326) LCOL999-Nueva Estructura de Tarifas AUTOS  - Modificación, se añade parametro pcodgrup a function pac_bonfran.f_resuelve_formula
     52.0        30/01/2018    VCG            52. 0001451: Error mensaje por Asegurado en varias solicitudes pendientes de emitir (Productos ramo Cumplimiento)
     53.0        10/05/2019     ECP           53. IAXIS-3631 Cambio de Estado cuando las pólizas están vencidas (proceso nocturno)
   ******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;
   mensajes         t_iax_mensajes := NULL;
   gidioma          NUMBER         := pac_md_common.f_get_cxtidioma;

   ------- Funciones internes

   /*************************************************************************
      Recupera la poliza como objeto persistente
      param out mensajes : mensajes de error
      return             : objeto detalle póliza
   *************************************************************************/
   FUNCTION f_getpoliza (mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_detpoliza
   IS
      tmpdpoliza   ob_iax_detpoliza := NULL;
      vpasexec     NUMBER           := 1;
      vparam       VARCHAR2 (1)     := NULL;
      vobject      VARCHAR2 (200)   := 'PAC_MD_VALIDACIONES.F_GetPoliza';
   BEGIN
      tmpdpoliza := pac_iobj_prod.f_getpoliza (mensajes);
      RETURN tmpdpoliza;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN NULL;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN NULL;
   END f_getpoliza;

   /*************************************************************************
      Valida si la duración está permitida en la parametrización del producto
      param in psproduc  : código de producto
      param in pndurper  : duración periodo
      param in pfecha    : fecha efecto
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_durper (
      psproduc   IN       NUMBER,
      pndurper   IN       NUMBER,
      pfecha     IN       DATE,
      mensajes   IN OUT   t_iax_mensajes
   )                                                -- BUG13360:DRA:11/03/2010
      RETURN NUMBER
   IS
      vndurper   NUMBER;
      vpasexec   NUMBER          := 1;
      vparam     VARCHAR2 (1000)
         :=    'psproduc= '
            || psproduc
            || ' pndurper= '
            || pndurper
            || ' pfecha= '
            || pfecha;
      vobject    VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.F_DURPER';
   BEGIN
      IF psproduc IS NULL OR pndurper IS NULL OR pfecha IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      SELECT ndurper
        INTO vndurper
        FROM durperiodoprod
       WHERE sproduc = psproduc
         AND ndurper = pndurper
         AND finicio <= pfecha
         AND (ffin > pfecha OR ffin IS NULL);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180198);
                                      -- Duración no permitida en el producto
         RETURN 1;
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_durper;

----------------

   /*************************************************************************
      Valida que la edad mínima y máxima de contratación según la fecha de nacimiento
      param in pfnacimi  : fecha nacimiento
      param in pfecha    : fecha efecto
      param in psproduc  : código de producto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_controledad (
      pfnacimi   IN       DATE,
      pfecha     IN       DATE,
      psproduc   IN       NUMBER,
      pnedamac   IN       NUMBER,            -- Bug 0025584 - MMS - 23/01/2013
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      n_ciedamic    NUMBER;
      n_ciedamac    NUMBER;
      n_ciedamac2   NUMBER;
      numerr        NUMBER         := 0;
      vnedamac      NUMBER;           -- edad max. permitida primer asegurado
      vnedamic      NUMBER;           -- edad min. permitida primer asegurado
      vciedmac      NUMBER;
        -- indicador edad real o actuarial en max. permitida primer asegurado
      vciedmic      NUMBER;
        -- indicador edad real o actuarial en min. permitida primer asegurado
      vnedma2c      NUMBER;          -- edad max. permitida segundo asegurado
      vnedmi2c      NUMBER;          -- edad min. permitida segundo asegurado
      vciema2c      NUMBER;
       -- indicador edad real o actuarial en max. permitida segundo asegurado
      vciemi2c      NUMBER;
       -- indicador edad real o actuarial en min. permitida segundo asegurado
      vnsedmac      NUMBER;
         -- máximo de contratación de la suma de edades (productos 2 cabezas)
      vcisemac      NUMBER;
                    -- indicar edad real o actuarial máximo de suma de edades
      vpasexec      NUMBER         := 1;
      vparam        VARCHAR2 (500)
         :=    'pfnacimi= '
            || pfnacimi
            || ' pfecha= '
            || pfecha
            || ' psproduc= '
            || psproduc
            || ' pnedamac= '
            || pnedamac;
      vobject       VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.F_ControlEdad';
   BEGIN
      --mirem l'edat segons CIEDMIC,CIEMAC (1 Real ,0 Actuarial)
      IF pfnacimi IS NULL OR pfecha IS NULL OR psproduc IS NULL
      THEN
         RAISE e_param_error;
      ELSE
         SELECT p.nedamac, p.nedamic, p.ciedmac, p.ciedmic, p.nedma2c,
                p.ciema2c, p.nedmi2c, p.ciemi2c, p.nsedmac, p.cisemac
           INTO vnedamac, vnedamic, vciedmac, vciedmic, vnedma2c,
                vciema2c, vnedmi2c, vciemi2c, vnsedmac, vcisemac
           FROM productos p
          WHERE p.sproduc = psproduc;

         vnedamic := vnedamic;                    -- bug 11998.NMM.17/11/2009.
         vciedmic := NVL (vciedmic, 0);
         vnedamac := NVL (pnedamac, vnedamac);
-- bug 11998.NMM.17/11/2009. -- Bug 0025584 - MMS - 23/01/2013 (nvl->pnedamar)
         vciedmac := NVL (vciedmac, 0);

         -- bug 11998.NMM.17/11/2009.i.
         IF vnedamac IS NOT NULL
         THEN
            IF vciedmac = 0
            THEN                        -- edad actuarial maxima contractació
               numerr := f_difdata (pfnacimi, pfecha, 2, 1, n_ciedamac);
            ELSIF vciedmac = 1
            THEN                              -- edad real minima contractació
               numerr := f_difdata (pfnacimi, pfecha, 1, 1, n_ciedamac);
            END IF;

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, numerr);
               RETURN 1;
            END IF;
         END IF;

         IF vnedamic IS NOT NULL
         THEN
            IF vciedmic = 0
            THEN                        -- edad actuarial maxima contractació
               numerr := f_difdata (pfnacimi, pfecha, 2, 1, n_ciedamic);
            ELSIF vciedmic = 1
            THEN                               --edad real minima contractació
               numerr := f_difdata (pfnacimi, pfecha, 1, 1, n_ciedamic);
            END IF;

            IF numerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, numerr);
               RETURN 1;
            END IF;
         END IF;

         -- bug 11998.NMM.17/11/2009.f.
         -- Bug 21785 - APD - 21/03/2012 - se modifica el IF ya que puede ser que
         -- n_ciedamac sea NULO y n_ciedamic sea NO NULO, o viceversa, y sino no
         -- mostraría el mensaje de error
/*
         IF (n_ciedamic < vnedamic
             OR n_ciedamac > vnedamac)
            AND(n_ciedamac IS NOT NULL
                AND n_ciedamic IS NOT NULL) THEN
*/
         IF    (n_ciedamic < vnedamic AND n_ciedamic IS NOT NULL)
            OR (n_ciedamac > vnedamac AND n_ciedamac IS NOT NULL)
         THEN
            -- fin Bug 21785 - APD - 21/03/2012
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 103366);
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_controledad;

   /*************************************************************************
      Valida si una periodicidad de pago está permitida en un producto
      param in gestion   : fecha nacimiento
      param in psproduc  : código de producto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_periodpag (
      gestion    IN       ob_iax_gestion,
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      poliza     ob_iax_detpoliza;
      vcforpag   NUMBER;
      vpasexec   NUMBER           := 1;
      vparam     VARCHAR2 (100)   := 'psproduc= ' || psproduc;
      vobject    VARCHAR2 (200)   := 'PAC_MD_VALIDACIONES.F_FormPag';
   BEGIN
      IF gestion IS NULL OR psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- ini Bug 0011733 - 26/01/2010 - JMF: En suplementos no permitir pago único.
      IF     pac_iax_produccion.issuplem
         AND NVL (f_parproductos_v (psproduc, 'PAGUNI_NOSUPLE'), 0) = 1
      THEN
         DECLARE
            v_cforpag   seguros.cforpag%TYPE;
            n_conta     NUMBER;
         BEGIN
            SELECT MAX (cforpag)
              INTO v_cforpag
              FROM seguros
             WHERE sseguro = pac_iax_produccion.vsseguro;

            IF v_cforpag IS NOT NULL AND v_cforpag <> gestion.cforpag
            THEN
               -- En caso de suplemento forma pago, no deben existir otros suplementos.
               SELECT COUNT (1)
                 INTO n_conta
                 FROM estdetmovseguro
                WHERE sseguro IN (SELECT sseguro
                                    FROM estseguros
                                   WHERE ssegpol = pac_iax_produccion.vsseguro)
                  AND cmotmov <> 269;

               IF n_conta > 0
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151391);
                  RETURN 1;
               END IF;
            END IF;

            IF     gestion.cforpag = 0
               AND v_cforpag IS NOT NULL
               AND v_cforpag <> gestion.cforpag
            THEN
               -- No se permite suplemento a forma pago única.
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151375);
               RETURN 1;
            END IF;
         END;
      END IF;

      -- fin Bug 0011733 - 26/01/2010 - JMF
      BEGIN
         SELECT cforpag
           INTO vcforpag
           FROM forpagpro
          WHERE (cramo, cmodali, ctipseg, ccolect) =
                                    (SELECT cramo, cmodali, ctipseg, ccolect
                                       FROM productos
                                      WHERE sproduc = psproduc)
            AND cforpag = gestion.cforpag;

         RETURN 0;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 140704);
            RETURN 1;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_periodpag;

   /*************************************************************************
      Valida la duración y fecha de vencimiento de la póliza según la parametrización del producto
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_duracion (
      pdetpoliza   IN       ob_iax_detpoliza,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr          NUMBER           := 0;
      vcduraci         NUMBER;
      vnduraci         NUMBER;
      vfvencim         DATE;
      sproduc          NUMBER;
      vfefecto         DATE;
      vriesgos         t_iax_riesgos;
      vaseg            t_iax_asegurados;
      vpasexec         NUMBER           := 0;
      vparam           VARCHAR2 (100)   := NULL;
      vobject          VARCHAR2 (200)
                                   := 'PAC_MD_VALIDACIONES.F_Valida_Duracion';
      vdurpoliza       NUMBER;
      vdurprestamo     NUMBER;
      -- Bug 19412 - RSC - 25/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
      v_meses          NUMBER;
      v_meses_nrenov   NUMBER;
      -- Fin Bug 19412

      -- Bug 0024090 - RSC - 17/10/2012 - LCOL - qtracker 5193 - Error en la validació de duració de cobrament
      v_mig_fefecto    DATE;
      v_durextra       NUMBER;
   -- Fin bug 0024090
   BEGIN
      vriesgos := pdetpoliza.riesgos;
      vpasexec := 1;

      IF pdetpoliza.gestion IS NULL OR pdetpoliza.sproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vfefecto := pdetpoliza.gestion.fefecto;
      vfvencim := pdetpoliza.gestion.fvencim;
      vnduraci := pdetpoliza.gestion.duracion;
      vpasexec := 2;

      SELECT p.cduraci
        INTO vcduraci
        FROM productos p
       WHERE p.sproduc = pdetpoliza.sproduc;

      -- Ini IAXIS-3631 -- ECP -- 10/05/2019
      IF pdetpoliza.csituac <> 3
      THEN
         IF vfvencim IS NOT NULL
         THEN
            vpasexec := 3;

            IF vfvencim <= vfefecto
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 100022);
               RETURN 1;
    -- La fecha de vencimiento no puede ser más grande que la fecha de efecto
            END IF;
         ELSE
            vpasexec := 4;

            -- Bug 23117 - RSC - 30/07/2012 - LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN AÑO (añadimos 6)
            IF vcduraci NOT IN (0, 4, 6)
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151288);
               RETURN 1;                        -- La duración es obligatoria
            END IF;
         END IF;
      END IF;

      -- Fin IAXIS-3631 -- ECP -- 10/05/2019
      vpasexec := 5;

      -- Validamos la duración de cada riesgo
      IF pdetpoliza.cobjase = 1
      THEN
         vpasexec := 6;

         FOR i IN vriesgos.FIRST .. vriesgos.LAST
         LOOP
            IF vriesgos.EXISTS (i)
            THEN
               vpasexec := 7;
               vaseg := vriesgos (i).riesgoase;

               FOR j IN vaseg.FIRST .. vaseg.LAST
               LOOP
                  IF vaseg.EXISTS (j)
                  THEN
                     vpasexec := 8;
                     vnumerr :=
                        f_validar_duracion (pdetpoliza.sproduc,
                                            0,
                                            vaseg (j).fnacimi,
                                            pdetpoliza.gestion.fefecto,
                                            pdetpoliza.gestion.fvencim
                                           );

                     IF vnumerr <> 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              vnumerr
                                                             );
                        RETURN 1;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      END IF;

      -- Mantis 7919.#6.i.12/2008
      vpasexec := 9;
      -- Bug 0024090 - RSC - 17/10/2012 - LCOL - qtracker 5193 - Error en la validació de duració de cobrament
      v_mig_fefecto := pdetpoliza.gestion.fefecto;

      IF pdetpoliza.preguntas IS NOT NULL
      THEN
         IF pdetpoliza.preguntas.COUNT > 0
         THEN
            FOR i IN pdetpoliza.preguntas.FIRST .. pdetpoliza.preguntas.LAST
            LOOP
               IF pdetpoliza.preguntas (i).cpregun = 4044
               THEN                             -- Es una póliza de migración
                  v_mig_fefecto :=
                     TO_DATE (pdetpoliza.preguntas (i).trespue, 'dd/mm/yyyy');
               END IF;
            END LOOP;
         END IF;
      END IF;

      SELECT MONTHS_BETWEEN (pdetpoliza.gestion.fefecto, v_mig_fefecto) / 12
        INTO v_durextra
        FROM DUAL;

      -- Fin Bug 0024090
      IF (pdetpoliza.gestion.duracion + NVL (v_durextra, 0)) <
                                                    pdetpoliza.gestion.ndurcob
      THEN
         -- La durada no pot ser inferior a la durada del cobrament del producte.
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9000654);
         RETURN (1);
      --
      END IF;

-- Bug 12499 - JRH - 30/12/2009 - No hace en simulaciones
      IF NOT (pac_iax_produccion.issimul)
      THEN
         -- Bug 12499 - APD - 30/12/2009 - se controla que para el producto 571.-ESCUT CONSTANT 95 PERSONAL
         -- la duración de la póliza debe ser siempre la misma que la duración del préstamo. Esta duración se informará en meses.
         IF NVL (f_parproductos_v (pdetpoliza.sproduc, 'MISMA_DUR_PRESTAMO'),
                 0
                ) = 1
         THEN
            vdurpoliza :=
               MONTHS_BETWEEN (pdetpoliza.gestion.fvencim,
                               pdetpoliza.gestion.fefecto
                              );
            vdurprestamo :=
               MONTHS_BETWEEN (pdetpoliza.riesgos (1).prestamo (1).ffinprest,
                               pdetpoliza.riesgos (1).prestamo (1).finiprest
                              );

            IF vdurpoliza <> NVL (TRUNC (vdurprestamo), -1)
            THEN
               -- La duración de la póliza debe ser la misma que la duración del préstamo.
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9900909);
               RETURN (1);
            END IF;
         END IF;
      END IF;

      -- Fi Bug 12499 - JRH - 30/12/2009 -

      -- Bug 0019412 - RSC - 25/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
      /*IF vfvencim IS NOT NULL THEN
         IF pdetpoliza.nrenova IS NOT NULL THEN
            SELECT MONTHS_BETWEEN(vfvencim, vfefecto)
              INTO v_meses
              FROM DUAL;   --- Duración de la póliza

            SELECT MONTHS_BETWEEN(TO_DATE(TO_NUMBER(TO_CHAR(vfefecto, 'YYYY')) + 1
                                          || LPAD(pdetpoliza.nrenova, 4, '0'),
                                          'YYYYMMDD'),
                                  vfefecto)
              INTO v_meses_nrenov
              FROM DUAL;

            IF v_meses < v_meses_nrenov THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902563);
               RETURN 1;
            END IF;
         END IF;
      END IF;*/
      -- Fin Bug 0019412

      -- Mantis 7919.#6.f.12/2008
      RETURN (0);
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_duracion;

   /*************************************************************************
         Función que valida que la fecha de efecto de una póliza
         param in gestion   : datos gestión
         param in psproduc  : código de producto
         param out mensajes : mensajes de error
         return             : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_fefecto (
      pgestion   IN       ob_iax_gestion,
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER;
      vpasexec   NUMBER         := 1;
      vparam     VARCHAR2 (200) := 'psproduc: ' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.F_Valida_Fefecto';
      vconta     NUMBER;
      vdias_a    NUMBER;
      vdias_d    NUMBER;
   BEGIN
      --Comprovació de paràmetres
      IF pgestion IS NULL OR pgestion.fefecto IS NULL OR psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr :=
         pac_seguros.f_valida_fefecto (psproduc,
                                       pgestion.fefecto,
                                       pgestion.fvencim,
                                       pgestion.cduraci
                                      );

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_fefecto;

   /*************************************************************************
         Función que valida que el conjunto polissa_ini - sproduc no esté repetido.
         param in gestion   : datos gestión
         param in psproduc  : código de producto
         param out mensajes : mensajes de error
         return             : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_polissaini (
      pgestion   IN       ob_iax_gestion,
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr          NUMBER                      := 1;
      vpasexec         NUMBER                      := 1;
      vparam           VARCHAR2 (200)             := 'psproduc: ' || psproduc;
      vobject          VARCHAR2 (200)
                                 := 'PAC_MD_VALIDACIONES.F_Valida_PolissaIni';
      vconta           NUMBER;
      -- Bug 22016 - RSC - 17/04/2012 - LCOL - Ajustes de parametrización LCOL
      v_num_err        NUMBER;
      v_cpregun_4051   pregunpolseg.cpregun%TYPE   := 4051;
      v_crespue_4051   pregunpolseg.crespue%TYPE;
      v_trespue_4051   pregunpolseg.trespue%TYPE;
      v_existep_4051   NUMBER;
      -- Fin bug 22016

      -- Bug 26267/152089 - 06/09/2013 - AMC
      v_cpregun_4962   pregunpolseg.cpregun%TYPE   := 4962;
      v_crespue_4962   pregunpolseg.crespue%TYPE;
      v_trespue_4962   pregunpolseg.trespue%TYPE;
      v_existep_4962   NUMBER;
   -- Fi Bug 26267/152089 - 06/09/2013 - AMC
   BEGIN
      --Comprovació de paràmetres
      IF pgestion IS NULL OR psproduc IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- BUG15617:DRA:09/09/2010:Inici
      IF pgestion.polissa_ini IS NOT NULL
      THEN
         -- Si se debe grabar en el campo SEGUROS.NPOLIZA el valor de POLISSA_INI
         --  debemos verificar que sea un NUMBER (8) o petará la emisión
         IF NVL (pac_parametros.f_parproducto_n (psproduc,
                                                 'NPOLIZA_CNVPOLIZAS'
                                                ),
                 0
                ) <> 0
         THEN
            BEGIN
               IF LENGTH (pgestion.polissa_ini) > 8
               THEN
                  RETURN 9901434;
          -- El número de pòlissa ha de ser numèric i de 8 dígits com a màxim
               END IF;

               vconta := TO_NUMBER (pgestion.polissa_ini);
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN 9901434;
          -- El número de pòlissa ha de ser numèric i de 8 dígits com a màxim
            END;
         END IF;
      END IF;

      -- BUG15617:DRA:09/09/2010:Fi
      vpasexec := 3;

      IF pgestion.polissa_ini IS NOT NULL
      THEN
         IF NVL (pac_parametros.f_parproducto_n (psproduc, 'CSIT_NOTAINFOR'),
                 0
                ) <> 14
         THEN
            -- Validamos que el conjunto polissa_ini - sproduc no esté repetido
            -- LPS (02/07/2008), se añade la tabla seguros para que si existe en una póliza
            -- anulada, no retorne 1.

            -- Bug 22016 - RSC - 17/04/2012 - LCOL - Ajustes de parametrización LCOL
            v_num_err :=
               pac_call.f_get_preguntas (NULL,
                                         v_cpregun_4051,
                                         v_crespue_4051,
                                         v_trespue_4051,
                                         v_existep_4051
                                        );

            IF v_num_err = 0 AND v_existep_4051 = 1
            THEN
               SELECT COUNT (1)
                 INTO vconta
                 FROM cnvpolizas cp, seguros s
                WHERE cp.sseguro = s.sseguro
                  AND cp.polissa_ini = pgestion.polissa_ini
                  AND cp.sseguro <>
                         pac_iax_produccion.vssegpol
                                               -- Bug 22745 - RSC - 04/07/2012
                  AND cp.producte = psproduc
                  AND cp.sistema = 0
                  AND cp.aplica = 0
                  AND f_situacion_poliza (s.sseguro) <> 2
                  AND (SELECT p.crespue
                         FROM pregunpolseg p
                        WHERE p.sseguro = s.sseguro
                          AND p.cpregun = 4051
                          AND p.nmovimi =
                                 (SELECT MAX (p2.nmovimi)
                                    FROM pregunpolseg p2
                                   WHERE p2.sseguro = s.sseguro
                                     AND p2.cpregun = p.cpregun)) =
                                                                v_crespue_4051;
            ELSE
               -- Fin Bug 22016
               SELECT COUNT (1)
                 INTO vconta
                 FROM cnvpolizas cp, seguros s
                WHERE cp.sseguro = s.sseguro
                  AND cp.polissa_ini = pgestion.polissa_ini
                  AND cp.sseguro <>
                         pac_iax_produccion.vssegpol
                                               -- Bug 22745 - RSC - 04/07/2012
                  AND cp.producte = psproduc
                  AND cp.sistema = 0
                  AND cp.aplica = 0
                  AND f_situacion_poliza (s.sseguro) <> 2;
            -- Bug 22016 - RSC - 17/04/2012 - LCOL - Ajustes de parametrización LCOL
            END IF;

            -- Fin bug 22016
            IF vconta > 0
            THEN
               RETURN 1000457;
        -- Ja existeix una pòlissa entrada amb aquest núm. de pòlissa antiga.
            END IF;

            -- Bug 26267/152089 - 06/09/2013 - AMC
            v_num_err :=
               pac_call.f_get_preguntas (NULL,
                                         v_cpregun_4962,
                                         v_crespue_4962,
                                         v_trespue_4962,
                                         v_existep_4962
                                        );

            IF v_num_err = 0 AND v_existep_4962 = 1
            THEN
               SELECT COUNT (1)
                 INTO vconta
                 FROM cnvpolizas cp, seguros s
                WHERE cp.sseguro = s.sseguro
                  AND cp.polissa_ini = pgestion.polissa_ini
                  AND cp.sseguro <> pac_iax_produccion.vssegpol
                  AND cp.producte = psproduc
                  AND cp.sistema = 0
                  AND cp.aplica = 0
                  AND f_situacion_poliza (s.sseguro) <> 2
                  AND (SELECT p.crespue
                         FROM pregunpolseg p
                        WHERE p.sseguro = s.sseguro
                          AND p.cpregun = 4962
                          AND p.nmovimi =
                                 (SELECT MAX (p2.nmovimi)
                                    FROM pregunpolseg p2
                                   WHERE p2.sseguro = s.sseguro
                                     AND p2.cpregun = p.cpregun)) =
                                                                v_crespue_4962;
            ELSE
               SELECT COUNT (1)
                 INTO vconta
                 FROM cnvpolizas cp, seguros s
                WHERE cp.sseguro = s.sseguro
                  AND cp.polissa_ini = pgestion.polissa_ini
                  AND cp.sseguro <> pac_iax_produccion.vssegpol
                  AND cp.producte = psproduc
                  AND cp.sistema = 0
                  AND cp.aplica = 0
                  AND f_situacion_poliza (s.sseguro) <> 2;
            END IF;

            IF vconta > 0
            THEN
               RETURN 1000457;
        -- Ja existeix una pòlissa entrada amb aquest núm. de pòlissa antiga.
            END IF;
         -- Fi Bug 26267/152089 - 06/09/2013 - AMC
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 9900866;           -- Error a l'extreure el número de pòlissa.
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 9900866;           -- Error a l'extreure el número de pòlissa.
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 9900866;           -- Error a l'extreure el número de pòlissa.
   END f_valida_polissaini;

   /*************************************************************************
      Validación de garantias seleccionadas
      param in psseguro  : código seguro
      param in pnriesgo  : número de riesgo
      param in pnmovimi  : movimiento seguro
      param in pcgarant  : código garantia
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pnmovima  : movimiento alta
      param in paccion   : SEL selecciona garantia
                           DESEL garantia deseleccionada
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_cobliga (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcgarant   IN       NUMBER,
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pnmovima   IN       NUMBER,
      paccion    IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr       NUMBER;
      vmensa     VARCHAR2 (1000);
      vpasexec   NUMBER          := 1;
      vparam     VARCHAR2 (2000)
         :=    'psseguro= '
            || psseguro
            || ' pnriesgo= '
            || pnriesgo
            || ' pnmovimi='
            || pnmovimi
            || ' pcgarant='
            || pcgarant
            || ' psproduc='
            || psproduc
            || ' pcactivi='
            || pcactivi
            || ' pnmovima='
            || pnmovima
            || ' paccion='
            || paccion;
      vobject    VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.F_Validacion_Cobliga';
   BEGIN
      nerr :=
         pk_nueva_produccion.f_validacion_cobliga (psseguro,
                                                   pnriesgo,
                                                   pnmovimi,
                                                   pcgarant,
                                                   paccion,
                                                   psproduc,
                                                   pcactivi,
                                                   vmensa,
                                                   pnmovima
                                                  );
      vpasexec := 2;

      IF nerr > 0
      THEN
         vpasexec := 3;
         pac_iobj_mensajes.crea_nuevo_mensaje
            (mensajes,
             2,
             nerr,
                pac_iobj_mensajes.f_get_descmensaje
                                                (nerr,
                                                 pac_md_common.f_get_cxtidioma
                                                )
             || ' '
             || vmensa
            );
         RETURN 1;
      END IF;

      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validacion_cobliga;

   /*************************************************************************
      Validación de garantias seleccionadas el capital
      param in psseguro  : código seguro
      param in pnriesgo  : número de riesgo
      param in pnmovimi  : movimiento seguro
      param in pcgarant  : código garantia
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pnmovima  : movimiento alta
      param in paccion   : SEL selecciona garantia
                           DESEL garantia deseleccionada
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_capital (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcgarant   IN       NUMBER,
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pnmovima   IN       NUMBER,
      paccion    IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerr       NUMBER;
      vmensa     VARCHAR2 (1000);
      vpasexec   NUMBER          := 1;
      vparam     VARCHAR2 (100)
         :=    'psseguro:'
            || psseguro
            || 'pnriesgo:'
            || pnriesgo
            || 'pnmovimi:'
            || pnmovimi
            || 'pcgarant:'
            || pcgarant
            || 'psproduc:'
            || psproduc
            || 'pcactivi:'
            || pcactivi
            || 'pnmovima:'
            || pnmovima
            || 'paccion:'
            || paccion;
      vobject    VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.F_Validacion_Capital';
   BEGIN
      nerr :=
         pk_nueva_produccion.f_valida_capital (paccion,
                                               psseguro,
                                               pnriesgo,
                                               pnmovimi,
                                               pcgarant,
                                               psproduc,
                                               pcactivi,
                                               vmensa,
                                               pnmovima
                                              );

      IF nerr > 0
      THEN
         vpasexec := 3;
         pac_iobj_mensajes.crea_nuevo_mensaje
            (mensajes,
             2,
             nerr,
                pac_iobj_mensajes.f_get_descmensaje
                                                (nerr,
                                                 pac_md_common.f_get_cxtidioma
                                                )
             || ' '
             || vmensa
            );
         RETURN 1;
      END IF;

      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validacion_capital;

   /*************************************************************************
      Valida la edad mínima y máxima de contratación según la parametrización del producto
      param in asegurs   : objeto asegurados
      param in psproduc  : código producto
      param in pfefecto  : fecha efecto
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_edad_prod (
      asegurs             ob_iax_asegurados,
      psproduc   IN       NUMBER,
      pfefecto   IN       DATE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vedad_aseg   NUMBER;
      vmenor       NUMBER;
                     -- indica el numero de error si es menor alguno es nemor
      num_err      NUMBER                   := -1;
      poliza       ob_iax_detpoliza;
      numerr       NUMBER                   := 0;
      vfefecto     DATE;
      vfnacimi     DATE;
      sproduc      NUMBER;
      vpasexec     NUMBER                   := 1;
      vparam       VARCHAR2 (200)
                       := 'psproduc=' || psproduc || ' pfefecto=' || pfefecto;
      vobject      VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.F_Valida_Edad_Prod';
      v_mens       VARCHAR2 (200);
      vtexto       VARCHAR2 (400);
      --
      w_cagrpro    productos.cagrpro%TYPE;
   --
   BEGIN
      sproduc := psproduc;
      vfefecto := pfefecto;
      --FOR n IN asegurs.first..asegurs.last LOOP
      vfnacimi := asegurs.fnacimi;

      -- bug 11998/12252.i.
      SELECT cagrpro
        INTO w_cagrpro
        FROM productos
       WHERE sproduc = psproduc;

      IF (w_cagrpro = 5) AND (vfnacimi > vfefecto)
      THEN                                   -- si la agrupació és la de salut
         IF vfefecto < f_sysdate ()
         THEN
            vfefecto := f_sysdate ();
         END IF;
      END IF;

      -- bug 11998.f.
      -- Bug 18631 - 16/06/2011 - RSC - ENSA102- Alta del certificado 0 en Contribucion definida
      IF NOT pac_iax_produccion.isaltacol
      THEN
         -- Fin Bug 18631
         IF NVL (asegurs.ctipper, 0) = 2
         THEN                   -- El asegurado no puede ser persona jurídica
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 152093);
            RETURN 1;
         END IF;
      END IF;

      -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
      IF NVL (f_parproductos_v (sproduc, 'VALIDA_EDAD_ASEG_PRO'), 1) = 1
      THEN
         -- Fin bug 19715
         numerr :=
                 f_controledad (vfnacimi, vfefecto, psproduc, NULL, mensajes);
                                            -- Bug 0025584 - MMS - 23/01/2013
      -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
      END IF;

      -- Fin bug 19715

      -- Bug 8670-27/04/2009-AMC
      IF numerr <> 0
      THEN
         vtexto := pac_iobj_mensajes.f_get_descmensaje (9001498);
                                       -- Error validar edad en riesgo número
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               1,
                                               NULL,
                                                  vtexto
                                               || ' '
                                               || TO_CHAR (asegurs.nriesgo)
                                              );
         RETURN 1;
      END IF;

      -- Fi Bug 8670-27/04/2009-AMC

      -- El producto tiene parametrizada la edad minima de alguno de los asegurados
      IF NVL (f_parproductos_v (sproduc, 'EDADMINASEG'), 0) <> 0
      THEN
         numerr := f_difdata (vfnacimi, vfefecto, 1, 1, vedad_aseg);

         --  entonces debe ser mayor de edad
         IF vedad_aseg < NVL (f_parproductos_v (sproduc, 'EDADMINASEG'), 0)
         THEN
            vmenor := 109631;                      -- Asegurado menor de edad
         ELSE
            vmenor := -1;
         END IF;
      END IF;

      --END LOOP;
      IF vmenor > 0
      THEN
         -- Bug 8670-27/04/2009-AMC
         v_mens :=
               pac_iobj_mensajes.f_get_descmensaje (vmenor, gidioma)
            || CHR (13)
            || pac_iobj_mensajes.f_get_descmensaje (9001498, gidioma)
            || TO_CHAR (asegurs.nriesgo);
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vmenor, v_mens);
         --Fi Bug 8670-27/04/2009-AMC
         RETURN 1;
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_edad_prod;

   /*************************************************************************
      Valida porcentajes descuento y recargos
      param in pmode     : modo de tarificaciÃ³n
      param in psolicit  : cÃ³digo de solicitud
      param in pnriesgo  : cÃ³digo de riesgo
      param in out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error o codigo error
      -- ini BUG 0025087 - 17/12/2012 - JMF
   *************************************************************************/
   FUNCTION f_valida_dtorec (
      psolicit   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerror     NUMBER;
      vtotal     NUMBER;
      vgar       estgaranseg.cgarant%TYPE;
      vsproduc   NUMBER;
      vvalor     NUMBER;
   BEGIN
      SELECT MAX (sproduc)
        INTO vsproduc
        FROM estseguros
       WHERE sseguro = psolicit;

      vvalor :=
           NVL (pac_parametros.f_parproducto_n (vsproduc, 'VALPOR_DTOREC'), 0);

      IF vvalor <> 0
      THEN
         --SELECT ABS((NVL(pdtotec, 0) + NVL(pdtocom, 0)) -(NVL(precarg, 0) + NVL(preccom, 0)))
         SELECT ABS (NVL (pdtotec, 0) + NVL (pdtocom, 0))
           INTO vtotal
           FROM estriesgos
          WHERE sseguro = psolicit AND nriesgo = pnriesgo;

         IF vtotal >= vvalor
         THEN
            nerror := 9904650;
            pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            nerror,
                               f_axis_literales (nerror,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ' '
                            || pnriesgo
                           );
            RETURN 1;
         END IF;

         vgar := NULL;

         SELECT MIN (cgarant)
           INTO vgar
           FROM estgaranseg a
          WHERE sseguro = psolicit
            AND nriesgo = pnriesgo
            --AND(ABS((NVL(a.pdtotec, 0) + NVL(a.pdtocom, 0))
            --NVL(a.precarg, 0) + NVL(a.preccom, 0))) > vvalor
            --      or
            --       abs( (nvl(a.PDTOTEC,0) + nvl(a.PDTOCOM,0)) - (nvl(a.PRECARG,0) + nvl(a.PRECCOM,0)) ) > 100
            AND (ABS (NVL (a.pdtotec, 0) + NVL (a.pdtocom, 0))) >= vvalor
            AND cobliga = 1;

         IF vgar IS NOT NULL
         THEN
            nerror := 9904652;
            pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            nerror,
                               f_axis_literales (nerror,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ' '
                            || vgar
                           );
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   END f_valida_dtorec;

   /*************************************************************************
      Validación de garantias para tarificar
      param in psolicit  : código de seguro
      param in pnriesgo  : número de riesgo
      param in pnmovimi  : número de novimiento
      param in psproduc  : código de producto
      param in pcactivi  : código de actividad
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validar_garantias_al_tarifar (
      psolicit   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER                 := 1;
      vparam       VARCHAR2 (1)           := NULL;
      vobject      VARCHAR2 (200)
                      := 'PAC_MD_VALIDACIONES.F_Validar_Garantias_Al_Tarifar';
      nerror       NUMBER;
      vmensaje     VARCHAR2 (2000);
                    -- BUG9216:DRA:11/03/2009:Amplio el tamany de la variable
      desmsj       VARCHAR2 (500);
                    -- BUG9216:DRA:11/03/2009:Amplio el tamany de la variable
      tgarant      VARCHAR2 (2000);
                    -- BUG9216:DRA:11/03/2009:Amplio el tamany de la variable
      -- Bug 19412/95066 - RSC - 19/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
      v_prevali    seguros.prevali%TYPE;
      v_pplimrev   NUMBER;
      -- Fin Bug 19412/95066

      -- Bug 20163 - RSC - 10/12/2011 - LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
      v_crevali    seguros.crevali%TYPE;

      -- Fin Bug 20163
      CURSOR garantias
      IS
         SELECT cgarant, nmovima, icapital, finiefe
           FROM estgaranseg
          WHERE sseguro = psolicit AND nriesgo = pnriesgo AND cobliga = 1;
   BEGIN
      -- Bug 10113 - 18/05/2009 - RSC - Ajustes Flexilife Nueva Emisión
      nerror :=
         pac_md_validaciones.f_valida_dependencia_basica (psproduc,
                                                          psolicit,
                                                          pnriesgo,
                                                          mensajes
                                                         );

      IF nerror <> 0
      THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- Fin Bug 10113

      -- BUG 0025087 - JRH - 18/12/2012. Inicio
      nerror := f_valida_dtorec (psolicit, pnriesgo, mensajes);

      IF nerror <> 0
      THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- BUG 0025087 - JRH - 18/12/2012. Fin
      nerror :=
         pk_nueva_produccion.f_validar_garantias_al_tarifar (psolicit,
                                                             pnriesgo,
                                                             pnmovimi,
                                                             psproduc,
                                                             pcactivi,
                                                             vmensaje
                                                            );

      IF nerror <> 0
      THEN
         vpasexec := 4;
         desmsj :=
            pac_iobj_mensajes.f_get_descmensaje
                                               (nerror,
                                                pac_md_common.f_get_cxtidioma
                                               );
         tgarant := vmensaje;
         --//ACC ho he comentat perque no tingin molt clar que retorni sempre una garantia
         --            BEGIN
         --                tgarant:= PAC_IAXPAR_PRODUCTOS.F_GET_DESCGARANT(vmensaje,mensajes);
         --            EXCEPTION WHEN OTHERS THEN
         --                NULL;
         --            END;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               1,
                                               nerror,
                                               desmsj || '<br>' || tgarant
                                              );
         RAISE e_object_error;
      END IF;

      -- Bug 19412/95066 - RSC - 19/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
      -- Bug 20163 - RSC - 10/12/2011 - LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
      SELECT prevali, crevali
        INTO v_prevali, v_crevali
        FROM estseguros
       WHERE sseguro = psolicit;

      nerror :=
         pk_nueva_produccion.f_valida_limrevalgeom (psproduc,
                                                    v_prevali,
                                                    v_pplimrev,
                                                    v_crevali
                                                   );

      IF nerror <> 0
      THEN
         vpasexec := 4;
         desmsj :=
            pac_iobj_mensajes.f_get_descmensaje
                                               (nerror,
                                                pac_md_common.f_get_cxtidioma
                                               );
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror, desmsj);
         RAISE e_object_error;
      END IF;

      -- Fin Bug 19412/95066

      -- Bug 17221 - APD - 11/01/11 - se crea la funcion f_valida_baja_gar_col
      -- para validar si una garantia de un certificado colectivo (certificado 0)
      -- se puede dar de baja o no
      IF     pac_iax_produccion.issuplem
         AND NVL (f_parproductos_v (psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         AND NVL (f_parproductos_v (psproduc, 'DETALLE_GARANT'), 0) IN (1, 2)
      THEN
         nerror :=
            pk_nueva_produccion.f_validar_baja_gar_col (psolicit,
                                                        pnriesgo,
                                                        pnmovimi,
                                                        psproduc,
                                                        pcactivi,
                                                        vmensaje
                                                       );

         IF nerror <> 0
         THEN
            vpasexec := 4;
            --desmsj := pac_iobj_mensajes.f_get_descmensaje(nerror,
            --                                              pac_md_common.f_get_cxtidioma);
            tgarant := vmensaje;
            --//ACC ho he comentat perque no tingin molt clar que retorni sempre una garantia
            --            BEGIN
            --                tgarant:= PAC_IAXPAR_PRODUCTOS.F_GET_DESCGARANT(vmensaje,mensajes);
            --            EXCEPTION WHEN OTHERS THEN
            --                NULL;
            --            END;
            --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror,
            --                                     desmsj || '<br>' || tgarant);
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                  1,
                                                  nerror,
                                                  tgarant
                                                 );
            RAISE e_object_error;
         END IF;
      END IF;

      -- fin bub 17221
      FOR gar IN garantias
      LOOP
         --Bug.: 15145 - 30/06/2010 - ICV  --Validaciones de capitales de garantia generales
         nerror :=
            pac_md_validaciones.f_valida_capitales_gar (psproduc,
                                                        gar.cgarant,
                                                        gar.icapital,
                                                        1,
                                                        gar.finiefe,
                                                        1,
                                                        mensajes
                                                       );

         IF nerror <> 0
         THEN
            vpasexec := 5;
            desmsj :=
               pac_iobj_mensajes.f_get_descmensaje
                                               (nerror,
                                                pac_md_common.f_get_cxtidioma
                                               );
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror, desmsj);
            RAISE e_object_error;
         END IF;

         --Fin Bug.
         nerror :=
            pac_md_validaciones_aho.f_valida_capitales_gar (psproduc,
                                                            gar.cgarant,
                                                            gar.icapital,
                                                            1,
                                                            gar.finiefe,
                                                            1,
                                                            mensajes
                                                           );

         IF nerror <> 0
         THEN
            vpasexec := 6;
            desmsj :=
               pac_iobj_mensajes.f_get_descmensaje
                                               (nerror,
                                                pac_md_common.f_get_cxtidioma
                                               );
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror, desmsj);
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validar_garantias_al_tarifar;

   /*************************************************************************
      Validación de una póliza del mismo producto, por persona.
      param in psproduc  : código de producto
      param in psperson  : código de persona
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : cantidad de seguros de la persona sperson
   *************************************************************************/
   FUNCTION f_valida_producto_unico (
      psproduc   IN       NUMBER,
      psperson   IN       NUMBER,
      psseguro   IN       NUMBER,
      -- BUG 11330 - 15/10/2009 - FAL - Añadir pfefecto para filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
      pfefecto   IN       DATE,
      -- FI BUG 11330  - 15/10/2009 – FAL
-- JLB - 26301 - I - RSA - Validación póliza partner
      pcagente   IN       NUMBER,
      pcpolcia   IN       VARCHAR2,
-- JLB - 26301 - F - RSA - Validación póliza partner
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerror      NUMBER;
      vparam      VARCHAR2 (1)   := NULL;
      vpasexec    NUMBER         := 1;
      v_cvalpar   NUMBER;
      vobject     VARCHAR2 (200)
                             := 'PAC_MD_VALIDACIONES.F_Valida_Producto_Unico';
      vfefecto    DATE;
   BEGIN
      nerror := f_parproductos (psproduc, 'POLIZA_UNICA', v_cvalpar);

      IF NVL (v_cvalpar, 0) = 1
      THEN                                                         --producto
         -- BUG 11330 - 15/10/2009 - FAL - Diferenciar si pfefecto informada
         IF pfefecto IS NOT NULL
         THEN
            -- FI BUG 11330  - 15/10/2009 – FAL
            SELECT COUNT (1)
              INTO nerror
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = psperson
               AND r.sseguro <> psseguro
               AND s.sproduc = psproduc
               AND r.fanulac IS NULL           --que el riesgo no este anulado
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                           -- AND s.csituac <> 2   -- que no estén anuladas
               AND s.csituac NOT IN
                                   (2, 3) -- que no estén anuladas ni vencidas
               -- FI BUG 11330  - 15/10/2009 – FAL
               AND NOT (s.csituac = 4 AND creteni IN (3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND (   (s.fvencim IS NULL)
                    OR (    s.fvencim IS NOT NULL
                        AND s.fvencim > pfefecto
                        AND (   pac_anulacion.f_esta_prog_anulproxcar
                                                                    (s.sseguro) =
                                                                             1
                             OR pac_anulacion.f_esta_anulada_vto (s.sseguro) =
                                                                             1
                            )
                       )
                   );
         -- FI BUG 11330  - 15/10/2009 – FAL

         -- BUG 11330 - 15/10/2009 - FAL - Diferenciar si pfefecto informada
         ELSE
            SELECT COUNT (1)
              INTO nerror
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = psperson
               AND r.sseguro <> psseguro
               AND s.sproduc = psproduc
               AND r.fanulac IS NULL           --que el riesgo no este anulado
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                           -- AND s.csituac <> 2   -- que no estén anuladas
               AND s.csituac NOT IN
                                   (2, 3) -- que no estén anuladas ni vencidas
               -- FI BUG 11330  - 15/10/2009 – FAL
               AND NOT (s.csituac = 4 AND creteni IN (3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado
               AND (    (s.fvencim IS NULL)
                    AND (    pac_anulacion.f_esta_prog_anulproxcar (s.sseguro) =
                                                                             0
                         AND pac_anulacion.f_esta_anulada_vto (s.sseguro) = 0
                        )
                   );
         -- FI BUG 11330  - 15/10/2009 – FAL
         END IF;

         -- FI BUG 11330  - 15/10/2009 – FAL

         -- bug 10515: 08/07/2009:ETM: 2parte--ini
         IF nerror > 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 151240);
            RETURN nerror;
         END IF;
      -- fin bug 10515: 08/07/2009:ETM:

      /* BUG 10515 : 30/06/09 : ETM : CRE069 - Validación de asegurado en ramos de salud y bajas--INI  */
      ELSIF NVL (v_cvalpar, 0) = 2
      THEN                                                              --RAMO
         -- BUG 11330 - 15/10/2009 - FAL - Diferenciar si pfefecto informada
         IF pfefecto IS NOT NULL
         THEN
            -- FI BUG 11330  - 15/10/2009 – FAL
            SELECT COUNT (1)
              INTO nerror
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = psperson
               AND r.sseguro <> psseguro
               AND s.cramo IN (SELECT cramo
                                 FROM productos
                                WHERE sproduc = psproduc)
               AND r.fanulac IS NULL           --que el riesgo no este anulado
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                           -- AND s.csituac <> 2   -- que no estén anuladas
               AND s.csituac NOT IN
                                   (2, 3) -- que no estén anuladas ni vencidas
               -- FI BUG 11330  - 15/10/2009 – FAL
               AND NOT (s.csituac = 4 AND creteni IN (3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND (   (s.fvencim IS NULL)
                    OR (    s.fvencim IS NOT NULL
                        AND s.fvencim > pfefecto
                        AND (   pac_anulacion.f_esta_prog_anulproxcar
                                                                    (s.sseguro) =
                                                                             1
                             OR pac_anulacion.f_esta_anulada_vto (s.sseguro) =
                                                                             1
                            )
                       )
                   );
             -- FI BUG 11330  - 15/10/2009 – FAL
         -- BUG 11330 - 15/10/2009 - FAL - Diferenciar si pfefecto informada
         ELSE
            SELECT COUNT (1)
              INTO nerror
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = psperson
               AND r.sseguro <> psseguro
               AND s.cramo IN (SELECT cramo
                                 FROM productos
                                WHERE sproduc = psproduc)
               AND r.fanulac IS NULL           --que el riesgo no este anulado
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                           -- AND s.csituac <> 2   -- que no estén anuladas
               AND s.csituac NOT IN
                                   (2, 3) -- que no estén anuladas ni vencidas
               -- FI BUG 11330  - 15/10/2009 – FAL
               AND NOT (s.csituac = 4 AND creteni IN (3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND (    (s.fvencim IS NULL)
                    AND (    pac_anulacion.f_esta_prog_anulproxcar (s.sseguro) =
                                                                             0
                         AND pac_anulacion.f_esta_anulada_vto (s.sseguro) = 0
                        )
                   );
         -- FI BUG 11330  - 15/10/2009 – FAL
         END IF;

         -- FI BUG 11330  - 15/10/2009 – FAL

         -- bug 10515: 08/07/2009:ETM: 2parte--ini
         IF nerror > 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001931);
            RETURN nerror;
         END IF;
      -- fin bug 10515: 08/07/2009:ETM:
      ELSIF NVL (v_cvalpar, 0) = 3
      THEN                                                        --AGRUPACION
         -- BUG 11330 - 15/10/2009 - FAL - Diferenciar si pfefecto informada
         IF pfefecto IS NOT NULL
         THEN
            -- FI BUG 11330  - 15/10/2009 – FAL
            SELECT COUNT (1)
              INTO nerror
              FROM riesgos r, seguros s, productos p
             WHERE r.sseguro = s.sseguro
               AND r.sperson = psperson
               AND r.sseguro <> psseguro
               AND s.cagrpro IN (SELECT cagrpro
                                   FROM productos
                                  WHERE sproduc = psproduc)
               AND r.fanulac IS NULL           --que el riesgo no este anulado
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                           -- AND s.csituac <> 2   -- que no estén anuladas
               AND s.csituac NOT IN
                                   (2, 3) -- que no estén anuladas ni vencidas
               -- FI BUG 11330  - 15/10/2009 – FAL
               AND NOT (s.csituac = 4 AND s.creteni IN (3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND (   (s.fvencim IS NULL)
                    OR (    s.fvencim IS NOT NULL
                        AND s.fvencim > pfefecto
                        AND (   pac_anulacion.f_esta_prog_anulproxcar
                                                                    (s.sseguro) =
                                                                             1
                             OR pac_anulacion.f_esta_anulada_vto (s.sseguro) =
                                                                             1
                            )
                       )
                   );
             -- FI BUG 11330  - 15/10/2009 – FAL
         -- BUG 11330 - 15/10/2009 - FAL - Diferenciar si pfefecto informada
         ELSE
            SELECT COUNT (1)
              INTO nerror
              FROM riesgos r, seguros s, productos p
             WHERE r.sseguro = s.sseguro
               AND r.sperson = psperson
               AND r.sseguro <> psseguro
               AND s.cagrpro IN (SELECT cagrpro
                                   FROM productos
                                  WHERE sproduc = psproduc)
               AND r.fanulac IS NULL           --que el riesgo no este anulado
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                           -- AND s.csituac <> 2   -- que no estén anuladas
               AND s.csituac NOT IN
                                   (2, 3) -- que no estén anuladas ni vencidas
               -- FI BUG 11330  - 15/10/2009 – FAL
               AND NOT (s.csituac = 4 AND s.creteni IN (3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND (    (s.fvencim IS NULL)
                    AND (    pac_anulacion.f_esta_prog_anulproxcar (s.sseguro) =
                                                                             0
                         AND pac_anulacion.f_esta_anulada_vto (s.sseguro) = 0
                        )
                   );
         -- FI BUG 11330  - 15/10/2009 – FAL
         END IF;

         -- bug 10515: 08/07/2009:ETM: 2parte--ini
         IF nerror > 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001932);
            RETURN nerror;
         END IF;
      -- fin bug 10515: 08/07/2009:ETM:
      /*FIN bUG 10515 : 30/06/09 : ETM   */

      -- BUG 26070/0138253 - FAL - 16/02/2013
      ELSIF NVL (v_cvalpar, 0) = 4
      THEN                                                         --COLECTIVO
         IF pfefecto IS NOT NULL
         THEN
            SELECT COUNT (1)
              INTO nerror
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = psperson
               AND r.sseguro <> psseguro
               AND s.npoliza =
                      NVL (pac_iax_produccion.poliza.det_poliza.npoliza,
                           (SELECT npoliza
                              FROM seguros
                             WHERE sseguro = psseguro)
                          )
               -- AND s.sproduc = psproduc
               AND r.fanulac IS NULL
               AND s.csituac NOT IN (2, 3)
               AND NOT (s.csituac = 4 AND creteni IN (3, 4))
               AND (   (s.fvencim IS NULL)
                    OR (    s.fvencim IS NOT NULL
                        AND s.fvencim > pfefecto
                        AND (   pac_anulacion.f_esta_prog_anulproxcar
                                                                    (s.sseguro) =
                                                                             1
                             OR pac_anulacion.f_esta_anulada_vto (s.sseguro) =
                                                                             1
                            )
                       )
                   );
         ELSE
            SELECT COUNT (1)
              INTO nerror
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = psperson
               AND r.sseguro <> psseguro
               AND s.npoliza =
                      NVL (pac_iax_produccion.poliza.det_poliza.npoliza,
                           (SELECT npoliza
                              FROM seguros
                             WHERE sseguro = psseguro)
                          )
               -- AND s.sproduc = psproduc
               AND r.fanulac IS NULL
               AND s.csituac NOT IN (2, 3)
               AND NOT (s.csituac = 4 AND creteni IN (3, 4))
               AND (    (s.fvencim IS NULL)
                    AND (    pac_anulacion.f_esta_prog_anulproxcar (s.sseguro) =
                                                                             0
                         AND pac_anulacion.f_esta_anulada_vto (s.sseguro) = 0
                        )
                   );
         END IF;

         IF nerror > 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9904994);
            RETURN nerror;
         END IF;
      -- FI BUG 26070/0138253
      END IF;

      -- JLB - 26301 -- RSA - Validación póliza partner
      v_cvalpar :=
         NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'POLIZA_UNICA_PARTNER'
                                            ),
              0
             );

      IF v_cvalpar = 1
      THEN
         SELECT COUNT (1)
           INTO nerror
           FROM seguros s
          WHERE s.cagente = pcagente
            AND s.cpolcia = pcpolcia
            AND s.sseguro <> psseguro
            AND s.csituac <> 2                         --que no estén anuladas
            AND NOT (s.csituac = 4 AND creteni IN (3, 4))
            -- BUG 26070/0138253 - FAL - 16/02/2013
            --AND((s.fvencim IS NULL)  AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 0  AND pac_anulacion.f_esta_anulada_vto(s.sseguro) = 0))
            AND (   (s.fvencim IS NULL)
                 OR (    s.fvencim IS NOT NULL
                     AND pfefecto BETWEEN s.fefecto AND s.fvencim
                    )
                );
      END IF;

      IF nerror > 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9905553);
         RETURN nerror;
      END IF;

      -- JLB - 26301 - F - RSA - Validación póliza partner
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_producto_unico;

   /*************************************************************************
      Validación de NO pólizas pendientes.
      param in psproduc  : código de producto
      param in psperson  : código de persona
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : cantidad de seguros de la persona sperson
   *************************************************************************/
   FUNCTION f_valida_no_pol_pendientes (
      psproduc   IN       NUMBER,
      psperson   IN       NUMBER,
      psseguro   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerror     NUMBER;
      vparam     VARCHAR2 (200)
         :=    'psproduc: '
            || psproduc
            || ' - psperson: '
            || psperson
            || ' - psseguro: '
            || psseguro;
      vpasexec   NUMBER         := 1;
      vobject    VARCHAR2 (200)
                           := 'PAC_MD_VALIDACIONES.F_Valida_No_Pol_Pendientes';
   BEGIN
        -- BUG20146:DRA:14/11/2011:Inici: El parametro nos indica si se permite dar el alta o no con polizas del asegurado pendientes
        --Ini-QT-1836-VCG-30/01/2018-Se elimina validación ya que hay asegurados con los que se tienen convenios o entidades a las que se les expide con una alta frecuencia
      /*  IF NVL(f_parproductos_v(psproduc, 'ALTA_POL_PDTE_ASEG'), 1) = 0 THEN
           SELECT DECODE(COUNT(1), 0, 0, 9902683)
             INTO nerror
             FROM asegurados a, seguros s
            WHERE a.sseguro = s.sseguro
              AND a.sperson = psperson
              AND a.sseguro <> psseguro
              AND s.sproduc = psproduc
              AND s.creteni <> 0
              AND s.csituac <> 2   -- que no estén anuladas
              AND NOT(s.csituac = 4
                      AND s.creteni IN(3, 4));

           IF nerror <> 0 THEN
              RETURN nerror;
           END IF;
        -- Bug 20671 - RSC - 04/01/2012 - LCOL_T001-LCOL - UAT - TEC: Contrataci?n
        ELSIF NVL(f_parproductos_v(psproduc, 'ALTA_POL_PDTE_ASEG'), 1) = 2 THEN
           SELECT DECODE(COUNT(1), 0, 0, 9902683)
             INTO nerror
             FROM asegurados a, seguros s
            WHERE a.sseguro = s.sseguro
              AND a.sperson = psperson
              AND a.sseguro <> psseguro
              AND s.sproduc = psproduc
              AND s.creteni NOT IN(0, 3, 4)
              AND s.csituac IN(4, 5);

           IF nerror <> 0 THEN
              RETURN nerror;
           END IF;
        END IF;*/
      --Fin-QT-1836-VCG-30/01/2018
        -- Fin Bug 20671

      -- BUG20146:DRA:14/11/2011:Fi
      IF NVL (f_parproductos_v (psproduc, 'ALTA_CON_POL_PDTE'), 0) = 0
      THEN
         SELECT DECODE (COUNT (1), 0, 0, 151241)
           INTO nerror
           FROM riesgos r, seguros s
          WHERE r.sseguro = s.sseguro
            AND r.sperson = psperson
            AND r.sseguro <> psseguro
            AND s.sproduc = psproduc
            AND s.creteni <> 0
            AND s.csituac <> 2                        -- que no estén anuladas
            AND NOT (s.csituac = 4 AND s.creteni IN (3, 4));

         IF nerror <> 0
         THEN
            RETURN nerror;
         END IF;
      -- Bug 20671 - RSC - 04/01/2012 - LCOL_T001-LCOL - UAT - TEC: Contrataci?n
      ELSIF NVL (f_parproductos_v (psproduc, 'ALTA_CON_POL_PDTE'), 0) = 2
      THEN
         SELECT DECODE (COUNT (1), 0, 0, 151241)
           INTO nerror
           FROM riesgos r, seguros s
          WHERE r.sseguro = s.sseguro
            AND r.sperson = psperson
            AND r.sseguro <> psseguro
            AND s.sproduc = psproduc
            AND s.creteni NOT IN (0, 3, 4)
            AND s.csituac IN (4, 5);

         IF nerror <> 0
         THEN
            RETURN nerror;
         END IF;
      END IF;

      -- Fin Bug 20671
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 140999;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 140999;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 140999;
   END f_valida_no_pol_pendientes;

   /*************************************************************************
      Valida que exista el agente
      param in  pcagente : código de agente
      param in  pid_prod : identificador del producto (ramo,mod.,tip.,col.)
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_agente (
      pcagente   IN       NUMBER,
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr     NUMBER;
      vparam      VARCHAR2 (50)
                       := 'pcagente=' || pcagente || ' psproduc=' || psproduc;
      vpasexec    NUMBER                 := 1;
      vobject     VARCHAR2 (200)     := 'PAC_MD_VALIDACIONES.F_Valida_Agente';
      vcorrecto   NUMBER (8);
      vpcomisi    NUMBER;
      vpretenc    NUMBER;
      vcramo      NUMBER;
      vcmodali    NUMBER;
      vctipseg    NUMBER;
      vccolect    NUMBER;
      vcempres    NUMBER;
      vcactivo    agentes.cactivo%TYPE;
   BEGIN
      --Comprovació dels paràmetres d'entrada
      IF pcagente IS NULL
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180252);
                                      -- Es obligatorio introducir la oficina
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      --Bug 7018
      IF psproduc IS NOT NULL
      THEN
         vnumerr :=
              f_def_producto (psproduc, vcramo, vcmodali, vctipseg, vccolect);

         IF vnumerr = 0
         THEN
            vnumerr := f_empresa (NULL, NULL, vcramo, vcempres, NULL);

            IF vnumerr = 0
            THEN
               vnumerr :=
                  pac_redcomercial.agente_valido (pcagente,
                                                  vcempres,
                                                  f_sysdate,
                                                  NULL,
                                                  vcorrecto
                                                 );
            END IF;

            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         IF vnumerr <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         --Fin Bug 7018
         vnumerr :=
            pac_redcomercial.agente_valido (pcagente,
                                            pac_md_common.f_get_cxtempresa,
                                            f_sysdate,
                                            NULL,
                                            vcorrecto
                                           );
      END IF;

      IF vcorrecto <> 0
      THEN                                                -- 0 = Agente valido
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 108010);
                                                      -- Agente ya no vigente
         RAISE e_object_error;
      ELSIF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
                                                -- Error al validar el agente
         RAISE e_object_error;
      END IF;

      vpasexec := 3;

      -- Bug 19169 - APD - 14/11/2011 -
      -- los agentes solo pueden hacer Nueva Produccion en estado (detvalores 31):
      -- 1.-Activo
      BEGIN
         SELECT cactivo
           INTO vcactivo
           FROM agentes
          WHERE cagente = pcagente;
      EXCEPTION
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 104473);
                                         -- Error al leer de la tabla AGENTES
            RAISE e_object_error;
      END;

      IF vcactivo <> 1
      THEN                                                    -- detvalores 31
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 101411);
                                                -- Este agente no está activo
         RAISE e_object_error;
      END IF;

      -- Fin Bug 19169 - APD - 14/11/2011

      -- Si ens passen el sproduc, comprovem que l'agent en qüestió tingui definit un quadre de comissions.
      IF psproduc IS NOT NULL
      THEN
         vpasexec := 4;
         vnumerr :=
              f_def_producto (psproduc, vcramo, vcmodali, vctipseg, vccolect);

         IF vnumerr = 0
         THEN
            vpasexec := 5;
            vnumerr :=
               f_pcomisi (NULL,
                          1,
                          f_sysdate,
                          vpcomisi,
                          vpretenc,
                          pcagente,
                          vcramo,
                          vcmodali,
                          vctipseg,
                          vccolect
                         );
         END IF;

         IF vnumerr <> 0
         THEN
            -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
             --RAISE e_object_error;
            NULL;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_agente;

   /*************************************************************************
      Valida los códigos de las direcciones
      param in  pcpostal : código postal
      param in  pcpoblac : código de población
      param in  pcprovin : código de la provincia
      param in pcpais    : código del pais
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_codigosdireccion (
      pcpostal   IN       VARCHAR2,
      pcpoblac   IN       NUMBER,
      pcprovin   IN       NUMBER,
      pcpais     IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr     NUMBER;
      vparam      tab_error.tdescrip%TYPE
                             -- BUG 0026532 - FAL - 3/4/2013. Ampliar tamanyo
         :=    'pcpostal='
            || pcpostal
            || ' pcpoblac='
            || pcpoblac
            || ' pcprovin='
            || pcprovin
            || ' pcpais='
            || pcpais;
      vpasexec    NUMBER                                                  := 1;
      vobject     VARCHAR2 (200)
                            := 'PAC_MD_VALIDACIONES.F_Valida_Codigosdireccion';
      vcorrecto   NUMBER;
      vpcomisi    NUMBER;
      vpretenc    NUMBER;
      vcramo      NUMBER;
      vcmodali    NUMBER;
      vctipseg    NUMBER;
      vccolect    NUMBER;
   BEGIN
      vnumerr :=
         pac_persona.f_valida_codigosdireccion (pcpais,
                                                pcpoblac,
                                                pcprovin,
                                                pcpostal
                                               );

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_codigosdireccion;

   --bug 7643
   /*************************************************************************
          Valida las preguntas a nivel de póliza, riesgo y garantías
          param in  Psseguro  : Código de Seguro       Vendrá informado siempre
          param in  Pcactivi  : Código de Actividad    Vendrá informado siempre
          param in  Pfefecto  : Fecha de Efecto        Vendrá informado siempre
          param in  Pnriesgo  : Código de Riesgo       Vendrá informado si son preguntas a nivel de riesgo o garantía
          param in  Pcgarant  : Código de Garantía     Vendrá informado si son preguntas a nivel de garantía
          param in  Pnmovimi  : Número de Movimiento   Vendrá informado si son preguntas a nivel de garantía
          param in  Pnmovima  :  Movimiento de alta    Vendrá informado si son preguntas a nivel de garantía
          param in  Picapital : Capital                Vendrá informado si son preguntas a nivel de garantía
          param in  ptablas   : Tablas
          param in  preguntas : Objeto preguntas
          param in  prgPar    : Parámetro preguntas
          param out mensajes  : mensajes de error
          return              : 0 la validación ha sido correcta
                                1 la validación no ha sido correcta
       *************************************************************************/
   FUNCTION f_validapreguntas (
      psseguro    IN       NUMBER,
      pcactivi    IN       NUMBER,
      pfefecto    IN       DATE,
      pnriesgo    IN       NUMBER,
      pcgarant    IN       NUMBER,
      pnmovimi    IN       NUMBER,
      pnmovima    IN       NUMBER,
      picapital   IN       NUMBER,
      ptablas     IN       VARCHAR2,                -- BUG11091:DRA:21/09/2009
      preguntas   IN       t_iax_preguntas,
      prgpar      IN       t_iaxpar_preguntas,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER          := 1;
      vparam      VARCHAR2 (2000)
         :=    'psseguro= '
            || psseguro
            || ' - pcactivi= '
            || pcactivi
            || ' - Pfefecto= '
            || pfefecto
            || ' - pnriesgo= '
            || pnriesgo
            || ' - pcgarant= '
            || pcgarant
            || ' - Pnmovimi= '
            || pnmovimi
            || ' - Pnmovima= '
            || pnmovima
            || ' - Picapital= '
            || picapital
            || ' - ptablas= '
            || ptablas;
      vresultat   NUMBER;
      errnum      NUMBER          := 0;
      gidioma     NUMBER          := pac_md_common.f_get_cxtidioma;
      vobject     VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.F_ValidaPreguntas';
      vgarantia   VARCHAR2 (2000);
-- Inicio IAXIS-3398 31/07/2019 Marcelo Ozawa      
      v_editmotmov NUMBER;
-- Fin IAXIS-3398 31/07/2019 Marcelo Ozawa      
   BEGIN
      --Bug 11474: CRE - Error en la simulació de rendes - XPL 20102009
-- Inicio IAXIS-3398 31/07/2019 Marcelo Ozawa      
      v_editmotmov := NVL(pac_iax_produccion.veditmotmov, 0);
-- Fin IAXIS-3398 31/07/2019 Marcelo Ozawa      
      IF prgpar IS NOT NULL AND preguntas IS NOT NULL
      THEN
         IF prgpar.COUNT > 0 AND preguntas.COUNT > 0
         THEN
            FOR vprp IN preguntas.FIRST .. preguntas.LAST
            LOOP
               vpasexec := 5;

               IF preguntas.EXISTS (vprp)
               THEN
                  vpasexec := 6;

                  FOR vprg IN prgpar.FIRST .. prgpar.LAST
                  LOOP
                     vpasexec := 7;

                     IF prgpar.EXISTS (vprg)
                     THEN
                        vpasexec := 8;

                        -- 19504 SI son automàtiques no es validen
                        IF prgpar (vprg).cpretip <> 2
                        THEN
                           IF prgpar (vprg).cpregun =
                                                     preguntas (vprp).cpregun
                           THEN
                              vpasexec := 9;

                              IF prgpar (vprg).cpreobl = 1
                              THEN
                                 vpasexec := 10;

                                 IF     preguntas (vprp).crespue IS NULL
                                    AND preguntas (vprp).trespue IS NULL
                                 THEN
                                    vpasexec := 11;

                                    -- Bug 27768/157578 - JSV - 06/11/2013
                                    IF (   preguntas (vprp).tpreguntastab IS NULL
                                        OR preguntas (vprp).tpreguntastab.COUNT =
                                                                             0
                                       )
                                    THEN
-- Inicio IAXIS-3398 31/07/2019 Marcelo Ozawa                                    
                                       IF v_editmotmov <> 971
                                       THEN
-- Fin IAXIS-3398 31/07/2019 Marcelo Ozawa                                       
                                       --XPL#23/09/2010#16105: CRT101- Informar cuando una pregunta es obligatoria a nivel de garantia de la garantia + pregunta
                                       IF pcgarant IS NULL
                                       THEN
                                          pac_iobj_mensajes.crea_nuevo_mensaje
                                                (mensajes,
                                                 1,
                                                 3245,
                                                    f_axis_literales (9000686,
                                                                      gidioma
                                                                     )
                                                 || ' '
                                                 || prgpar (vprg).tpregun
                                                );
                                       ELSE
                                          vgarantia :=
                                                ' ( '
                                             || f_axis_literales (100561,
                                                                  gidioma
                                                                 )
                                             || ' - '
                                             || ff_desgarantia (pcgarant,
                                                                gidioma
                                                               )
                                             || ' )';
                                          pac_iobj_mensajes.crea_nuevo_mensaje
                                                 (mensajes,
                                                  1,
                                                  3245,
                                                     f_axis_literales
                                                                     (9000686,
                                                                      gidioma
                                                                     )
                                                  || ' '
                                                  || prgpar (vprg).tpregun
                                                  || vgarantia
                                                 );
-- Inicio IAXIS-3398 31/07/2019 Marcelo Ozawa                                                 
                                       END IF;
-- Fin IAXIS-3398 31/07/2019 Marcelo Ozawa                                       
                                       END IF;
                                    END IF;
                                 END IF;
                              END IF;

                              IF     prgpar (vprg).tvalfor IS NOT NULL
                                 AND (   preguntas (vprp).trespue IS NOT NULL
                                      OR preguntas (vprp).crespue IS NOT NULL
                                     )
                              THEN
                                 --BUG 5388 - 25/05/2009 - JRB - No se ha de tener en cuenta el tipo de pregunta sino si realmente está informada la respuesta
                                 --AND prgpar(vprg).cpretip IN(1, 3) THEN
                                 errnum :=
                                    pac_albsgt.f_tvalfor
                                          (preguntas (vprp).crespue,
                                           preguntas (vprp).trespue,
                                           prgpar (vprg).tvalfor,
                                           ptablas, -- BUG11091:DRA:21/09/2009
                                           psseguro,
                                           pcactivi,
                                           pnriesgo,
                                           pfefecto,
                                           pnmovimi,
                                           pcgarant,
                                           vresultat,
                                           NULL,
                                           pnmovima,
                                           picapital
                                          );

                                 IF errnum <> 0
                                 THEN
                                    pac_iobj_mensajes.crea_nuevo_mensaje
                                                                   (mensajes,
                                                                    1,
                                                                    errnum
                                                                   );     --**
                                    RAISE e_object_error;
                                 END IF;

                                 IF vresultat <> 0
                                 THEN
                                    pac_iobj_mensajes.crea_nuevo_mensaje
                                                                   (mensajes,
                                                                    1,
                                                                    vresultat
                                                                   );     --**
                                    RAISE e_object_error;
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validapreguntas;

   --Fin bug 7643

   /*************************************************************************
      Valida si el agente tiene acceso al producto
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_acces_prod (
      psproduc   IN       productos.sproduc%TYPE,
      pcagente   IN       agentes.cagente%TYPE,
      pctipo     IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr    NUMBER;
      vparam     VARCHAR2 (50)
         :=    'psproduc='
            || psproduc
            || ' pcagente='
            || pcagente
            || ' pctipo='
            || pctipo;
      vpasexec   NUMBER         := 1;
      vobject    VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.F_Valida_Acces_Prod';
   BEGIN
      vnumerr := pac_productos.f_prodagente (psproduc, pcagente, pctipo);

      IF vnumerr <> 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 109905);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_acces_prod;

   /*************************************************************************
      Valida de que se ha impreso el cuestionario de salud
      param in ppulsado : 0 No pulsado, 1 pulsado
      param in pmodo : 'SIM', 'ALT' o 'SUP'
      param in psseguro : Código de Seguro
      param in pnriesgo : Código del riesgo
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_cuest_salud (
      ppulsado   IN       NUMBER,
      pmodo      IN       VARCHAR2,
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER         := 1;
      vobject    VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.F_Valida_Cuest_Salud';
      vparam     VARCHAR2 (1)   := NULL;
      num_err    NUMBER;
   BEGIN
      -- Bug 9051 - 18/02/2009 - AMC - Validacion de los parametros obligatorios”
      IF    ppulsado IS NULL
         OR pmodo IS NULL
         OR psseguro IS NULL
         OR pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      num_err :=
         pac_val_comu.f_valida_cuest_salud (ppulsado,
                                            pmodo,
                                            psseguro,
                                            pnriesgo
                                           );

      IF num_err = 1
      THEN
         RETURN num_err;
      ELSIF num_err > 1
      THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_cuest_salud;

   --Bug 9099
   /*************************************************************************
      Valida las preguntas de la garantia
      param in    psproduc  : código del producto
      param in    pcactivi  : código de la actividad
      param in    pcgarant  : código de la garantía
      param in    pnmovimi  : Número de movimiento
      param in    pcpregun  : Código de la pregunta
      param in    pcrespue  : Código de la respuesta
      param in    ptrespue  : Respuesta de la pregunta
      param in    psseguro  : Código seguro
      param in    Pnriesgo  : Riesgo
      param in    Pfefecto  : Fecha de efecto
      param in    Pnmovima  : Número de movimiento de alta
      param in    Ptablas   : Tipo de las tablas
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_validapregungaran (
      psproduc   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pcgarant   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pcpregun   IN       NUMBER,
      pcrespue   IN       FLOAT,
      ptrespue   IN       VARCHAR2,
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,                            -- Más parámetros
      pfefecto   IN       DATE,
      pnmovima   IN       NUMBER,
      ptablas    IN       VARCHAR2,                          -- Más parámetros
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      prgpar      t_iaxpar_preguntas;
      vpasexec    NUMBER             := 1;
      vparam      VARCHAR2 (1)       := NULL;
      vobject     VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.f_validapregungaran';
      errnum      NUMBER;
      vresultat   NUMBER;
      picapital   NUMBER             := 0;
      gartabla    t_iax_preguntastab;
   BEGIN
      prgpar :=
         pac_mdpar_productos.f_get_preggarant (psproduc,
                                               pcactivi,
                                               pcgarant,
                                               mensajes
                                              );

      FOR vprg IN prgpar.FIRST .. prgpar.LAST
      LOOP
         vpasexec := 7;

         IF prgpar.EXISTS (vprg)
         THEN
            vpasexec := 8;

            IF prgpar (vprg).cpregun = pcpregun
            THEN
               vpasexec := 9;

               IF prgpar (vprg).cpreobl = 1
               THEN
                  vpasexec := 10;

                  IF prgpar (vprg).crestip != 3
                  THEN
                     IF pcrespue IS NULL AND ptrespue IS NULL
                     THEN
                        vpasexec := 11;
                        pac_iobj_mensajes.crea_nuevo_mensaje
                                                (mensajes,
                                                 1,
                                                 3245,
                                                    f_axis_literales (9000686,
                                                                      gidioma
                                                                     )
                                                 || ' '
                                                 || prgpar (vprg).tpregun
                                                );
                     END IF;
                  ELSE
                     gartabla :=
                        pac_iax_produccion.f_get_preguntab ('G',
                                                            pnriesgo,
                                                            pcgarant,
                                                            pcpregun,
                                                            mensajes
                                                           );

                     IF gartabla IS NULL OR gartabla.COUNT = 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje
                                                (mensajes,
                                                 1,
                                                 3245,
                                                    f_axis_literales (9000686,
                                                                      gidioma
                                                                     )
                                                 || ' '
                                                 || prgpar (vprg).tpregun
                                                );
                     END IF;
                  END IF;
               END IF;

               IF     prgpar (vprg).tvalfor IS NOT NULL
                  AND (ptrespue IS NOT NULL OR pcrespue IS NOT NULL)
               THEN
                  --BUG 5388 - 25/05/2009 - JRB - No se ha de tener en cuenta el tipo de pregunta sino si realmente está informada la respuesta
                  --AND prgpar(vprg).cpretip IN(1, 3) THEN   BUG 5388 05/2009
                  errnum :=
                     pac_albsgt.f_tvalfor (pcrespue,
                                           ptrespue,
                                           prgpar (vprg).tvalfor,
                                           ptablas,
                                           psseguro,
                                           pcactivi,
                                           pnriesgo,
                                           pfefecto,
                                           pnmovimi,
                                           pcgarant,
                                           vresultat,
                                           NULL,
                                           pnmovima,
                                           picapital
                                          );

                  IF errnum <> 0
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           errnum
                                                          );
                     RAISE e_object_error;
                  END IF;

                  IF vresultat <> 0
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                           1,
                                                           vresultat
                                                          );
                     RAISE e_object_error;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validapregungaran;

   --Fin Bug 9099

   /*************************************************************************
       --BUG 9007 - 10/02/2009 - JTS
       Valida la prima mínima de un seguro por riesgo
       param in  P_sproduc  : Código de Producto
       param in  P_sseguro  : Código de Seguro
       param in  P_nriesgo  : Código de Riesgo
       param out mensajes   : mensajes de error
       return               : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_primaminfrac (
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      --pprima IN NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_numerr       NUMBER;
      v_param        VARCHAR2 (50)
         :=    'psproduc='
            || psproduc
            || ' psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo;
      v_pasexec      NUMBER          := 1;
      v_object       VARCHAR2 (200)
                            := 'PAC_MD_VALIDACIONES.f_validacion_primaminfrac';
      v_pprima       NUMBER;
      v_text         VARCHAR2 (4000);
      v_descmoneda   VARCHAR2 (200);
   BEGIN
      v_numerr :=
         pk_nueva_produccion.f_validacion_primaminfrac (psproduc,
                                                        psseguro,
                                                        pnriesgo,
                                                        v_pprima
                                                       );
                                                -- BUG 9513 - 01/04/2009 - LPS

      IF v_numerr <> 0
      THEN
         v_pasexec := 2;
         v_text :=
            pac_iobj_mensajes.f_get_descmensaje
                                               (v_numerr,
                                                pac_md_common.f_get_cxtidioma
                                               );
         -- Bug 11676 - 30/10/2009 - AMC
         v_numerr :=
            f_desmoneda (f_parinstalacion_n ('MONEDAINST'),
                         pac_md_common.f_get_cxtidioma,
                         v_descmoneda
                        );
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               1,
                                               v_numerr,
                                                  v_text
                                               || ' '
                                               || v_pprima
                                               || ' '
                                               || v_descmoneda
                                              );
         -- Fi Bug 11676 - 30/10/2009 - AMC
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validacion_primaminfrac;

      /*************************************************************************
       --BUG 9513 - 01/04/2009 - LPS
       Valida la prima mínima de un seguro por riesgo
       param in  P_sproduc  : Código de Producto
       param in  P_sseguro  : Código de Seguro
       param in  P_nriesgo  : Código de Riesgo
       param in  P_prima    : importe de la prima
       param out mensajes   : mensajes de error
       return               : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_validacion_primamin (
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      --pprima IN NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_numerr    NUMBER;
      v_param     VARCHAR2 (50)
         :=    'psproduc='
            || psproduc
            || ' psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo;
      v_pasexec   NUMBER          := 1;
      v_object    VARCHAR2 (200)
                                := 'PAC_MD_VALIDACIONES.f_validacion_primamin';
      v_pprima    NUMBER;
      v_text      VARCHAR2 (4000);
      v_cprimin   NUMBER;
   BEGIN
      -- BUG 11518 - 20/10/2009 - FAL - Recuperar productos.cprimin. Si es tipo prima minima = Validación (fija) -> validar prima mínima
      BEGIN
         SELECT cprimin
           INTO v_cprimin
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cprimin := NULL;
      END;

      IF v_cprimin = 2
      THEN
         v_numerr :=
            pk_nueva_produccion.f_validacion_primamin (psproduc,
                                                       psseguro,
                                                       pnriesgo,
                                                       v_pprima
                                                      );
                                                -- BUG 9513 - 01/04/2009 - LPS
      END IF;

      -- FI BUG 11518  - 20/10/2009 – FAL
      IF v_numerr <> 0
      THEN
         v_pasexec := 2;
         v_text :=
            pac_iobj_mensajes.f_get_descmensaje
                                               (v_numerr,
                                                pac_md_common.f_get_cxtidioma
                                               );
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               1,
                                               v_numerr,
                                               v_text || ' ' || v_pprima
                                              );
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validacion_primamin;

   --BUG 8613 - 160309 - ACC - Suplement Canvi d'agent
      /*************************************************************************
         Valida que el canvi d'agent estigui permés
         param in    pcagentini : código agent inicial pòlissa
         param in    pcagentfin : código agent a canviar pòlissa
         param in    pfecha     : data comprovació agent
         param in out mensajes  : mensajes de error
         return :  0 todo correcto
                   1 ha habido un error
      *************************************************************************/
   FUNCTION f_validacanviagent (
      pcagentini   IN       NUMBER,
      pcagentfin   IN       NUMBER,
      pfecha       IN       DATE,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER                        := 1;
      vparam      VARCHAR2 (1)                  := NULL;
      vobject     VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.F_VALIDACANVIAGENT';
      errnum      NUMBER                        := 0;
      vpervi1     redcomercial.cpervisio%TYPE;
      vpervi2     redcomercial.cpervisio%TYPE;
      vtext       VARCHAR2 (450);
      vempresa    NUMBER;
      vmismoage   NUMBER;
   BEGIN
      IF pcagentini IS NULL OR pcagentfin IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 11468 - 23/10/2009 - AMC
      vempresa := pac_md_common.f_get_cxtempresa ();
      vmismoage :=
               pac_parametros.f_parempresa_n (vempresa, 'SUPCANVIAGENTDIFVIS');

      IF vmismoage = 1
      THEN
         RETURN 0;
      ELSE
         BEGIN
            vpervi1 := ff_agente_cpervisio (pcagentini, pfecha);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vtext := pac_iobj_mensajes.f_get_descmensaje (9000730);
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     9000730,
                                                        vtext
                                                     || ' ('
                                                     || pcagentini
                                                     || ')'
                                                    );
               RETURN 1;
            WHEN OTHERS
            THEN
               RETURN 1;
         END;

         BEGIN
            vpervi2 := ff_agente_cpervisio (pcagentfin, pfecha);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vtext := pac_iobj_mensajes.f_get_descmensaje (9000730);
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     9000730,
                                                        vtext
                                                     || ' ('
                                                     || pcagentfin
                                                     || ')'
                                                    );
               RETURN 1;
            WHEN OTHERS
            THEN
               RETURN 1;
         END;

         IF (vpervi1 = vpervi2)
         THEN
            RETURN 0;
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9001268);
         END IF;

         RETURN 1;
      END IF;
   --Fi Bug 11468 - 23/10/2009 - AMC
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validacanviagent;

   --Fi BUG 8613 - 160309 - ACC - Suplement Canvi d'agent

   /*************************************************************************
      Valida los datos de gestión en cuanto a certificado 0.
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 8286 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
   FUNCTION f_valida_gestioncertifs (
      pgestion   IN       ob_iax_gestion,
      ppoliza             ob_iax_detpoliza,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      poliza      ob_iax_detpoliza;
      riesgos     t_iax_riesgos;
      riesgo      ob_iax_riesgos;
      vpasexec    NUMBER           := 1;
      vobject     VARCHAR2 (200)
                             := 'PAC_MD_VALIDACIONES.F_Valida_GestionCertifs';
      vparam      VARCHAR2 (1)     := NULL;
      vnumerr     NUMBER;
      vselect     VARCHAR2 (2000);         -- Bug 31686/180881-28/07/2014-AMC
      vcertif     sys_refcursor;
      vnpoliza    NUMBER;
      vtomador    VARCHAR2 (250);
      vsituaci    VARCHAR2 (150);
      vproduct    VARCHAR2 (40);
      vfefecto    DATE;
      vagente     NUMBER;
      vtagente    VARCHAR2 (500);
      vsucursal   NUMBER;
      vadn        NUMBER;
   BEGIN
      IF pac_mdpar_productos.f_get_parproducto ('ADMITE_CERTIFICADOS',
                                                ppoliza.sproduc
                                               ) = 1
      THEN
         vselect :=
            pac_seguros.f_sel_certificadoscero
                                       (ppoliza.sproduc,
                                        ppoliza.npoliza,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL, --BUG22839/125740:DCT:21/10/2012
                                        ppoliza.gestion.cidioma
                                       );
         vcertif := pac_md_listvalores.f_opencursor (vselect, mensajes);

         LOOP
            FETCH vcertif
             INTO vnpoliza, vtomador, vsituaci, vproduct, vfefecto, vagente,
                  vtagente, vsucursal, vadn;

            EXIT WHEN vcertif%NOTFOUND;

            IF pgestion.fefecto < vfefecto
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 180916);
               RETURN 1;
            END IF;
         END LOOP;

         CLOSE vcertif;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_gestioncertifs;

   --BUG 9709 - 06/04/2009 - LPS - Validación del limite del % de crecimiento geométrico
      /*************************************************************************
         Valida el límite del porcentaje de crecimiento geométrico
         param in    psproduc  : código agent inicial pòlissa
         param in    prevali   : código agent a canviar pòlissa
         param out   mensajes  : mensajes de error
         return :  0 todo correcto
                   1 ha habido un error
      *************************************************************************/
   FUNCTION f_valida_limrevalgeom (
      psproduc   IN       NUMBER,
      pprevali   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes,
      pcrevali   IN       NUMBER DEFAULT 2
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER          := 1;
      vparam      VARCHAR2 (200)
                       := 'psproduc:' || psproduc || ' pprevali:' || pprevali;
      vobject     VARCHAR2 (200)
                               := 'PAC_MD_VALIDACIONES.f_valida_limrevalgeom';
      v_text      VARCHAR2 (4000);
      v_numerr    NUMBER          := 0;
      v_plimrev   NUMBER;
   BEGIN
      v_numerr :=
         pk_nueva_produccion.f_valida_limrevalgeom (psproduc,
                                                    pprevali,
                                                    v_plimrev,
                                                    pcrevali
                                                   );

      IF v_numerr <> 0
      THEN
         v_text := pac_iobj_mensajes.f_get_descmensaje (v_numerr);
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                               1,
                                               v_numerr,
                                               v_text || ' ' || v_plimrev
                                              );
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_limrevalgeom;

      /*************************************************************************
      Valida los datos de gestión en cuanto a certificado 0.
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   -- Bug 8286 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
   FUNCTION f_valida_finversion (
      ppoliza          ob_iax_detpoliza,
      mensajes   OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER          := 1;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_VALIDACIONES.F_Valida_GestionCertifs';
      vparam     VARCHAR2 (1)    := NULL;
      v_text     VARCHAR2 (4000);
      v_numerr   NUMBER;
   BEGIN
      -- Bug XXX - RSC - 24/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      --v_numerr := pac_val_finv.f_valida_ulk_abierto(NULL, ppoliza.sproduc, f_sysdate);

      --IF v_numerr <> 0 THEN
      --   v_text := pac_iobj_mensajes.f_get_descmensaje(v_numerr);
      --   pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr, v_text);
      --   RAISE e_object_error;
      --END IF;
      -- Fin Bug XXX
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_finversion;

   -- Fin Bug 10040

   /*************************************************************************
       Comprobación de al menos haya una garantía dependiente seleccionada
       si existe una garantía padre seleccionada.

       param in  P_sproduc  : Código de Producto
       param in  P_sseguro  : Código de Seguro
       param in  P_nriesgo  : Código de Riesgo
       param out mensajes   : mensajes de error
       return               : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   -- Bug 10113 - 18/05/2009 - RSC - Ajustes FlexiLife nueva emisión
   FUNCTION f_valida_dependencia_basica (
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_numerr    NUMBER;
      v_param     VARCHAR2 (50)
         :=    'psproduc='
            || psproduc
            || ' psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo;
      v_pasexec   NUMBER          := 1;
      v_object    VARCHAR2 (200)
                          := 'PAC_MD_VALIDACIONES.f_valida_dependencia_basica';
      v_pprima    NUMBER;
      v_text      VARCHAR2 (4000);
   BEGIN
      v_numerr :=
         pk_nueva_produccion.f_valida_dependencia_basica (psseguro,
                                                          pnriesgo,
                                                          psproduc
                                                         );

      IF v_numerr <> 0
      THEN
         v_pasexec := 2;
         v_text :=
            pac_iobj_mensajes.f_get_descmensaje
                                               (v_numerr,
                                                pac_md_common.f_get_cxtidioma
                                               );
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_numerr, v_text);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_dependencia_basica;

   /*************************************************************************
      FUNCTION f_validaposttarif
      Validaciones despues de tarifar
      Param IN psproduc: producto
      Param IN psseguro: sseguro
      Param IN pnriesgo: nriesgo
      Param IN pfefecto: Fecha
      return : 0 Si todo ha ido bien, si no el código de error

   *************************************************************************/
   --BUG 10231 - 27/05/2009 - ETM -Límite de aportaciones en productos fiscales --INI
   FUNCTION f_validaposttarif (
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pfefecto   IN       DATE,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerror      NUMBER;
      v_pasexec   NUMBER                    := 1;
      v_param     VARCHAR2 (50)
         :=    'psproduc='
            || psproduc
            || ' psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo;
      v_object    VARCHAR2 (200)    := 'PAC_MD_VALIDACIONES.f_validaposttarif';
      v_pprima    NUMBER;
      v_text      VARCHAR2 (4000);
      --det_poliza     ob_iax_detpoliza;
      -- Bug 19412/95066 - RSC - 19/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
      w_cgarant   garangen.cgarant%TYPE;
      vnsesion    NUMBER;
      vfefecto    DATE;
      vnpoliza    NUMBER;
      v_existe    NUMBER;
      vmensa      VARCHAR2 (4000);
      -- Fin Bug 19412/95066
      vcapmax     NUMBER;
      vcapmin     NUMBER;                    -- Bug 0026501 - MMS - 05/06/2013
      -- JLB - I
      vprevali    estseguros.prevali%TYPE;
      vcrevali    estseguros.crevali%TYPE;
   BEGIN
      -- BUG 9513 - 01/04/2009 - LPS - Validacion prima minima
      nerror :=
         pac_md_validaciones.f_validacion_primamin (psproduc,
                                                    psseguro,
                                                    pnriesgo,
                                                    mensajes
                                                   );

      IF nerror <> 0
      THEN
         v_pasexec := 2;
         RAISE e_object_error;
      END IF;

      -- FI BUG 9513 - 01/04/2009 - LPS - Validacion prima minima
      nerror :=
         pac_md_validaciones.f_validacion_primaminfrac (psproduc,
                                                        psseguro,
                                                        pnriesgo,
                                                        mensajes
                                                       );
                                                -- BUG 9513 - 01/04/2009 - LPS

      IF nerror <> 0
      THEN
         v_pasexec := 3;
         RAISE e_object_error;
      END IF;

      -- BUG 9709 - 06/04/2009 - LPS - Validacion del limite del porcentaje de crecimiento geométrico
      --
      -- I - JLB - No recupero la póliza sino que solo los campos que necesito
      --det_poliza := pac_iobj_prod.f_getpoliza(mensajes);
      BEGIN
         SELECT prevali, crevali
           INTO vprevali, vcrevali
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      --IF det_poliza.crevali = 2 THEN
      --nerror := pac_md_validaciones.f_valida_limrevalgeom(psproduc, det_poliza.prevali,
       --                                                   mensajes, det_poliza.crevali);
      nerror :=
         pac_md_validaciones.f_valida_limrevalgeom (psproduc,
                                                    vprevali,
                                                    mensajes,
                                                    vcrevali
                                                   );

      -- F - JLB - No recupero la póliza sino que solo los campos que necesito
      IF nerror <> 0
      THEN
         v_pasexec := 2;
         RAISE e_object_error;
      END IF;

      --END IF;

      -- FI BUG 9709 - 06/04/2009 - LPS - Validacion del limite del porcentaje de crecimiento geométrico
      nerror :=
         pac_propio.f_validaposttarif (psproduc, psseguro, pnriesgo, pfefecto);

      IF nerror <> 0
      THEN
         v_pasexec := 3;
         v_text :=
            pac_iobj_mensajes.f_get_descmensaje
                                               (nerror,
                                                pac_md_common.f_get_cxtidioma
                                               );
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror, v_text);
         RAISE e_object_error;
      END IF;

      -- Bug 19412/95066 - RSC - 19/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
      -- Bug 21706 - APD - 24/04/2012 - se añade el campo icapital
      FOR c IN (SELECT   e.cgarant, e.nmovima, s.cactivi, e.nmovimi,
                         e.icapital
                    FROM estgaranseg e, estseguros s
                   WHERE e.sseguro = psseguro
                     AND e.nriesgo = pnriesgo
                     AND e.sseguro = s.sseguro
                     AND e.cobliga = 1
                ORDER BY NVL (pac_parametros.f_pargaranpro_n (s.sproduc,
                                                              s.cactivi,
                                                              e.cgarant,
                                                              'ORDEN_TARIF'
                                                             ),
                              e.cgarant
                             ))
      LOOP
         w_cgarant := c.cgarant;
         nerror :=
            pk_nueva_produccion.f_valida_garanproval (c.cgarant,
                                                      psseguro,
                                                      pnriesgo,
                                                      c.nmovimi,
                                                      psproduc,
                                                      c.cactivi,
                                                      vmensa,
                                                      'POST'
                                                     );

         IF nerror <> 0
         THEN
            vmensa :=
                  f_axis_literales (nerror, f_usu_idioma)
               || '<br>'
               || ff_desgarantia (w_cgarant, f_usu_idioma);
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror, vmensa);
            RETURN 1;
         END IF;

         -- Bug 21706 - APD - 24/04/2012 - se llama a la funcion f_capital_maximo_garantia_post
         -- para validar el capital máximo calculado en la post-tarificacion
         nerror :=
            pk_nueva_produccion.f_capital_maximo_garantia_post (psproduc,
                                                                c.cactivi,
                                                                c.cgarant,
                                                                psseguro,
                                                                pnriesgo,
                                                                c.nmovimi,
                                                                vcapmax
                                                               );

         IF nerror <> 0
         THEN
            vmensa :=
                  f_axis_literales (nerror, f_usu_idioma)
               || '<br>'
               || ff_desgarantia (w_cgarant, f_usu_idioma);
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror, vmensa);
            RETURN 1;
         END IF;

         IF vcapmax IS NOT NULL AND c.icapital IS NOT NULL
         THEN
            IF c.icapital > vcapmax
            THEN
               vmensa :=
                     f_axis_literales (110199, f_usu_idioma)
                  || ' ('
                  || f_axis_literales (105815, f_usu_idioma)
                  || ' '
                  || vcapmax
                  || ')'
                  || '<br>'
                  || ff_desgarantia (w_cgarant, f_usu_idioma);
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     nerror,
                                                     vmensa
                                                    );
               RETURN 1;
            END IF;
         END IF;

         -- Bug 0026501 - MMS - 16/04/2013
         nerror :=
            pk_nueva_produccion.f_capital_minimo_garantia_post (psproduc,
                                                                c.cactivi,
                                                                c.cgarant,
                                                                psseguro,
                                                                pnriesgo,
                                                                c.nmovimi,
                                                                vcapmin
                                                               );

         IF nerror <> 0
         THEN
            vmensa :=
                  f_axis_literales (nerror, f_usu_idioma)
               || '<br>'
               || ff_desgarantia (w_cgarant, f_usu_idioma);
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror, vmensa);
            RETURN 1;
         END IF;

         IF vcapmin IS NOT NULL AND c.icapital IS NOT NULL
         THEN
            IF c.icapital < vcapmin
            THEN
               vmensa :=
                     f_axis_literales (9905720, f_usu_idioma)
                  || ' ('
                  || f_axis_literales (1000493, f_usu_idioma)
                  || ' '
                  || vcapmin
                  || ')'
                  || '<br>'
                  || ff_desgarantia (w_cgarant, f_usu_idioma);
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                     1,
                                                     nerror,
                                                     vmensa
                                                    );
               RETURN 1;
            END IF;
         END IF;
      -- Fin Bug 0026501 - MMS - 16/04/2013

      -- fin Bug 21706 - APD - 24/04/2012
      END LOOP;

      -- Fin Bug 19412/95066
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validaposttarif;

   --BUG 10231 - 27/05/2009 - ETM -Límite de aportaciones en productos fiscales --FIN
    /*************************************************************************
         Valida el saldo deutor
         param out mensajes : mesajes de error
         return             : 0 todo ha sido correcto
                              1 ha habido un error
      *************************************************************************/
      -- Bug 10702 - 22/07/2009 - XPL - Nueva pantalla para contratación y suplementos que permita seleccionar cuentas aseguradas.
      -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_valida_prestamoseg (
      pnriesgo   IN       NUMBER,
      psaldo     OUT      t_iax_prestamoseg,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vcapitaltotal_queda   NUMBER             := 0;
      vtotal_aseg           NUMBER             := 0;
      verrnum               NUMBER             := 0;
      poliza                ob_iax_detpoliza;
      riesgo                ob_iax_riesgos;
      vprestamo             ob_iax_prestamoseg;
      vtprestamo            t_iax_prestamoseg  := t_iax_prestamoseg ();
      vpasexec              NUMBER (8)         := 1;
      vparam                VARCHAR2 (2000)    := 'pnriesgo = ' || pnriesgo;
      vobject               VARCHAR2 (2000)
                                := 'PAC_MD_VALIDACIONES.f_valida_prestamoseg';
      v_cont                NUMBER             := 0;
      v_porc_parcial        NUMBER;
      vsaldo_parcial        NUMBER;
      v_saldo_total         NUMBER;
      v_alguno_sel          NUMBER             := 0;
      -- BUG13945:DRA:29/03/2010:Inici
      v_sperson             NUMBER;
      v_dummy               VARCHAR2 (2000);
      vtasseg               t_iax_asegurados;
      -- BUG13945:DRA:29/03/2010:Fi
      -- JLB -
      v_count               NUMBER (3);
      v_icapmax             NUMBER;                -- BUG14279:DRA:26/04/2010
      v_icapmaxpol          NUMBER;                -- BUG14279:DRA:26/04/2010
   BEGIN
      vpasexec := 1;
      poliza := f_getpoliza (mensajes);

      IF poliza IS NULL
      THEN
         vpasexec := 2;
         RETURN 0;
      END IF;

      -- Miramos si el riesgo nos viene informado
      IF pnriesgo IS NULL
      THEN
         vpasexec := 3;
         RAISE e_param_error;
      END IF;

      riesgo := pac_iobj_prod.f_partpolriesgo (poliza, pnriesgo, mensajes);

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.COUNT > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      -- BUG13945:DRA:29/03/2010:Inici
      vpasexec := 41;
      vtasseg := riesgo.riesgoase;
      -- BUG13945:DRA:29/03/2010:Fi
      vpasexec := 42;
      -- tenemos la parte de saldodeutors
      vtprestamo := riesgo.prestamo;
      vpasexec := 5;

      IF vtprestamo IS NULL
      THEN
         vpasexec := 51;
      END IF;

      -- Miramos el capital total
      FOR i IN vtprestamo.FIRST .. vtprestamo.LAST
      LOOP
         -- calculamo el capital asegurado por si antes se ha modificado
         verrnum :=
            pac_iax_produccion.f_calcula_capase (vtprestamo (i).ctipimp,
                                                 vtprestamo (i).isaldo,
                                                 vtprestamo (i).porcen,
                                                 vtprestamo (i).ilimite,
                                                 vtprestamo (i).icapmax,
                                                 vtprestamo (i).icapaseg,
                                                 mensajes
                                                );

         IF vtprestamo (i).selsaldo = 1
         THEN
            -- BUG12421:DRA:02/03/2010:Inici
            IF vtprestamo (i).porcen < 0 OR vtprestamo (i).porcen > 100
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9901044);
               RAISE e_object_error;
            END IF;

            IF vtprestamo (i).icapmax < 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9901045);
               RAISE e_object_error;
            END IF;

            -- BUG12421:DRA:02/03/2010:Fi
            vtotal_aseg := NVL (vtotal_aseg, 0) + vtprestamo (i).icapaseg;
         END IF;
      END LOOP;

      vpasexec := 52;

      IF poliza.icapmaxpol IS NOT NULL
      THEN
         v_icapmaxpol := poliza.icapmaxpol;
      ELSE
         v_icapmaxpol := 0;
      END IF;

      --BUG14279:DRA:26/04/2010:Inici
      IF vtasseg IS NOT NULL
      THEN
         IF vtasseg.COUNT > 0
         THEN
            v_sperson :=
               pac_persona.f_sperson_spereal (vtasseg (vtasseg.FIRST).sperson);
            verrnum :=
               pk_nueva_produccion.f_capmax_poliza_prestamo (v_sperson,
                                                             poliza.ssegpol,
                                                             poliza.sproduc,
                                                             v_icapmax
                                                            );

            IF verrnum <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verrnum);
               RAISE e_object_error;
            END IF;

            IF v_icapmax <= 0
            THEN
               vpasexec := 521;
               verrnum := 9901154;
               poliza.icapmaxpol := 0;
               pac_iax_produccion.poliza.det_poliza.icapmaxpol :=
                                                            poliza.icapmaxpol;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, verrnum);
               RAISE e_object_error;
            ELSIF v_icapmax < v_icapmaxpol
            THEN
               vpasexec := 522;
               verrnum := 9901137;
               poliza.icapmaxpol := v_icapmax;
               pac_iax_produccion.poliza.det_poliza.icapmaxpol :=
                                                            poliza.icapmaxpol;
               pac_iobj_mensajes.crea_nuevo_mensaje
                  (mensajes,
                   2,
                   verrnum,
                      pac_iobj_mensajes.f_get_descmensaje
                                                (verrnum,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                   || ' '
                   || TO_CHAR (v_icapmax)
                  );
               RAISE e_object_error;
            ELSE
               vpasexec := 523;

               IF NVL (poliza.icapmaxpol, 0) = 0
               THEN
                  -- Esto solo lo hará si no han puesto ningun valor
                  poliza.icapmaxpol := v_icapmax;
                  pac_iax_produccion.poliza.det_poliza.icapmaxpol :=
                                                            poliza.icapmaxpol;
               END IF;
            END IF;
         END IF;
      END IF;

      v_icapmaxpol :=
          NVL (poliza.icapmaxpol, f_parproductos_v (poliza.sproduc, 'CAPMAX'));
      vpasexec := 53;

      --Ini Bug.: 13945 - FAL - 12/04/2010
      IF poliza.icapmaxpol IS NULL
      THEN
         poliza.icapmaxpol := v_icapmaxpol;
         pac_iax_produccion.poliza.det_poliza.icapmaxpol := poliza.icapmaxpol;
      ELSE
         IF poliza.icapmaxpol > v_icapmaxpol
         THEN
            verrnum := 9901137;
         END IF;

         IF verrnum <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
               (mensajes,
                2,
                verrnum,
                   pac_iobj_mensajes.f_get_descmensaje
                                                (verrnum,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                || ' '
                || TO_CHAR (v_icapmaxpol)
               );
            RAISE e_object_error;
         END IF;
      END IF;

      --Fin Bug.: 13945
      vpasexec := 6;
      --BUG14279:DRA:26/04/2010:Fi
      vcapitaltotal_queda := NVL (poliza.icapmaxpol, 999999999999);
      vpasexec := 7;

      FOR reg IN (SELECT   ctipcuenta, nprior
                      FROM ctacategoria_orden
                  ORDER BY nprior ASC)
      LOOP
         v_saldo_total := 0;

         --Bug.: 12307 - 15/12/2009 - ICV - 0012307: CRE - Modificaciones en el producto Saldo Deutors
         --Buscamos cuantos de este nivel tenemos en el objeto
         FOR j IN vtprestamo.FIRST .. vtprestamo.LAST
         LOOP
            IF     reg.ctipcuenta = vtprestamo (j).ctipcuenta
               AND vtprestamo (j).selsaldo = 1
            THEN
               v_alguno_sel := 1;
               v_cont := j;
               v_saldo_total :=
                             vtprestamo (j).icapaseg + NVL (v_saldo_total, 0);
            END IF;
         END LOOP;

         IF v_saldo_total > vcapitaltotal_queda
         THEN
            v_porc_parcial := vcapitaltotal_queda / v_saldo_total;
         ELSE
            v_porc_parcial := NULL;
         END IF;

         FOR i IN vtprestamo.FIRST .. vtprestamo.LAST
         LOOP
            -- si esta marcado y  el tipo de cuenta es igual al de la prioridad.
            IF     reg.ctipcuenta = vtprestamo (i).ctipcuenta
               AND vtprestamo (i).selsaldo = 1
            THEN
               IF NVL (v_porc_parcial, 0) <> 0
               THEN
                  vsaldo_parcial :=
                       ROUND ((vtprestamo (i).icapaseg * v_porc_parcial), 2);

                  IF v_cont = i
                  THEN                                --Ajuste para el último
                     -- JLB - añado el round
                     IF ROUND (vsaldo_parcial - vcapitaltotal_queda, 2) <> 0
                     THEN
                        vsaldo_parcial := vcapitaltotal_queda;
                     END IF;
                  END IF;
               ELSE
                  vsaldo_parcial := ROUND (vtprestamo (i).icapaseg, 2);
                                -- BUG12421:DRA:27/01/2010: Añadimos el ROUND
               END IF;

               IF vsaldo_parcial <= vcapitaltotal_queda
               THEN
                  vcapitaltotal_queda := vcapitaltotal_queda - vsaldo_parcial;
                  vtprestamo (i).icapaseg := vsaldo_parcial;
               ELSIF     vsaldo_parcial > vcapitaltotal_queda
                     AND vcapitaltotal_queda > 0
               THEN
                  vtprestamo (i).icapaseg := vcapitaltotal_queda;
                  vcapitaltotal_queda := 0;
               -- Si no queda capital desmarcamos.
               ELSIF vcapitaltotal_queda <= 0
               THEN
                  -- BUG12421:DRA:16/02/2010
                  -- vtprestamo(i).selsaldo := 0;
                  vtprestamo (i).icapaseg := 0;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      vpasexec := 8;

      -- JLB - Queda capital pendiente todavia o existe alguno seleccionado
      FOR j IN vtprestamo.FIRST .. vtprestamo.LAST
      LOOP
         IF vtprestamo (j).selsaldo = 1
         THEN
            v_alguno_sel := 1;

            -- De momento introduzco el saldo en el primero que encuentre
            BEGIN
               SELECT COUNT ('x')
                 INTO v_count
                 FROM ctacategoria_orden
                WHERE ctipcuenta = vtprestamo (j).ctipcuenta;

               IF v_count = 0
               THEN
                  IF NVL (vcapitaltotal_queda, 0) > 0
                  THEN
                     -- esto igual se tiene que repartir
                     vtprestamo (j).icapaseg :=
                         LEAST (vtprestamo (j).icapaseg, vcapitaltotal_queda);
                     vcapitaltotal_queda :=
                                vcapitaltotal_queda - vtprestamo (j).icapaseg;
                  ELSE
                     -- BUG12421:DRA:16/02/2010
                     -- vtprestamo(j).selsaldo := 0;
                     vtprestamo (j).icapaseg := 0;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  -- no deberia pasar nunca
                  -- BUG12421:DRA:16/02/2010
                  -- vtprestamo(j).selsaldo := 0;
                  vtprestamo (j).icapaseg := 0;
            END;

            vpasexec := 9;

            -- BUG13945:DRA:29/03/2010:Inici
            IF vtasseg IS NOT NULL
            THEN
               IF vtasseg.COUNT > 0
               THEN
                  v_sperson :=
                     pac_persona.f_sperson_spereal
                                              (vtasseg (vtasseg.FIRST).sperson
                                              );
                  vpasexec := 10;

                  IF v_sperson IS NOT NULL
                  THEN
                     verrnum :=
                        pk_nueva_produccion.f_valida_poliza_prestamo
                                                     (vtprestamo (j).idcuenta,
                                                      v_sperson,
                                                      poliza.ssegpol
                                                     );

                     IF verrnum <> 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              verrnum
                                                             );
                        RAISE e_object_error;
                     END IF;
                  END IF;
               END IF;
            END IF;
         -- BUG13945:DRA:29/03/2010:Fi
         ELSE
            vtprestamo (j).icapaseg := 0;
         END IF;
      END LOOP;

      vpasexec := 11;

      -- JLB - F
      IF v_alguno_sel = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9900849);
         RAISE e_object_error;
      END IF;

      --Fin Bug:12307
      vpasexec := 12;
      --  END IF;
      psaldo := vtprestamo;
      --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_prestamoseg;

     --Ini Bug.: 13640 - ICV - 17/03/2010
   /*************************************************************************
         Valida la data de venciment pels productes d'estalvi.
         param out mensajes : mesajes de error
         return             : 0 todo ha sido correcto
                              1 ha habido un error
    *************************************************************************/
   FUNCTION f_valida_fvencim_aho (
      pfnacimi   IN       DATE,
      pffecini   IN       DATE,
      pfvencim   IN       DATE,
      ptramo     IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)      := 1;
      vparam       VARCHAR2 (2000)
         :=    'pfnacimi = '
            || pfnacimi
            || ' pffecini = '
            || pffecini
            || ' pfvencim = '
            || pfvencim;
      vobject      VARCHAR2 (2000)
                                 := 'PAC_MD_VALIDACIONES.f_valida_fvencim_ppj';
      v_edad       NUMBER;
      v_dura       NUMBER;
      num_err      NUMBER          := 0;
      v_dura_min   NUMBER          := 0;
      v_lit        VARCHAR2 (4000);
   BEGIN
      num_err := f_difdata (pfnacimi, pffecini, 1, 1, v_edad);
      num_err := f_difdata (pffecini, pfvencim, 1, 1, v_dura);
      v_dura_min := f_gettramo1 (pffecini, ptramo, v_edad);
      v_lit := f_axis_literales (9901060, gidioma);

      IF v_dura < v_dura_min
      THEN
         v_lit := REPLACE (v_lit, '#1#', v_dura_min);
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, NULL, v_lit);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_fvencim_aho;

--Fin Bug.: 13640

   --Bug.: 15145 - 30/06/2010 - ICV
   /*************************************************************************
         Valida varios parámetros de capitales de garantías
         param in psproduc  : código de producto
         param in pcgarant  : garantía
         param in picapital  : capital
         param in ptipo  : 1 para Nueva Producción.
         param out mensajes : mensajes de error
         return             : 0 todo correcto
                              1 ha habido un error
      *************************************************************************/
   FUNCTION f_valida_capitales_gar (
      psproduc    IN       seguros.sproduc%TYPE,
      pcgarant    IN       NUMBER,
      picapital   IN       NUMBER,
      ptipo       IN       NUMBER,
      pfecha      IN       DATE,
      porigen     IN       NUMBER DEFAULT 2,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      numerr       NUMBER           := 0;
      vpasexec     NUMBER (8)       := 1;
      vparam       VARCHAR2 (100)   := 'psproduc= ' || psproduc;
      vobject      VARCHAR2 (200)
                              := 'PAC_MD_VALIDACIONES.f_valida_capitales_gar';
      n            NUMBER;
      poliza       ob_iax_detpoliza := pac_iobj_prod.f_getpoliza (mensajes);
                                                              --Objeto póliza
      toma         t_iax_tomadores;
      tablariesg   t_iax_riesgos;
      tablaaseg    t_iax_asegurados;
      v_csujeto    NUMBER;
      v_anyo       NUMBER;
      v_ctipgar    NUMBER;
      pcpais       NUMBER;
      psperson     NUMBER;
      tipogar      NUMBER;
      n_capimult   NUMBER;                  -- Bug 0012549 - 05/01/2010 - JMF
   BEGIN
      IF psproduc IS NULL OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*BEGIN
         SELECT DISTINCT NVL(f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi,
                                             cgarant, 'TIPO'),
                             0)
                    INTO tipogar
                    FROM garanpro
                   WHERE sproduc = psproduc
                     AND cgarant = pcgarant
                     AND NVL(f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi,
                                             cgarant, 'TIPO'),
                             0) IN(3, 4);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;   --Sólo validamos las coberturas tipo 3 o 4
         WHEN TOO_MANY_ROWS THEN
            NULL;
      END;*/
      n_capimult := NVL (f_parproductos_v (psproduc, 'CAPMULT1000'), 0);

      IF n_capimult = 1
      THEN
         n := MOD (picapital, 1000);

         IF n <> 0
         THEN
            RETURN 153044;
         END IF;
      ELSIF n_capimult = 2
      THEN
         n := MOD (picapital, 100);

         IF n <> 0
         THEN
            RETURN 9900912;
         END IF;
      ELSIF n_capimult = 3
      THEN
         n := MOD (picapital, 10000);

         IF n <> 0
         THEN
            RETURN 9900913;
         END IF;
      ELSIF n_capimult = 4
      THEN
         n := MOD (picapital, 15000);

         IF n <> 0
         THEN
            RETURN 9901263;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_capitales_gar;

--Fin Bug.: 15145 - 30/06/2010

   /*************************************************************************
      FUNCTION f_validagarantia
      Validaciones garantias
      Param IN psseguro: sseguro
      Param IN pnriesgo: nriesgo
      Param IN pcgarant: cgarant
      return : 0 Si todo ha ido bien, si no el c?digo de error
   *************************************************************************/
   --BUG 16106 - 05/11/2010 - JTS
   FUNCTION f_validagarantia (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pcgarant   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      nerror      NUMBER;
      v_pasexec   NUMBER         := 1;
      v_param     VARCHAR2 (50)
         :=    'pcgarant='
            || pcgarant
            || ' psseguro='
            || psseguro
            || ' pnriesgo='
            || pnriesgo;
      v_object    VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.f_validagarantia';
   BEGIN
      v_pasexec := 2;
      nerror :=
         pac_propio.f_validagarantia (psseguro, pnmovimi, pnriesgo, pcgarant);

      IF nerror <> 0
      THEN
         v_pasexec := 3;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000005,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000006,
                                            v_pasexec,
                                            v_param
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            v_object,
                                            1000001,
                                            v_pasexec,
                                            v_param,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validagarantia;

   --Inicio Bug:17041 --JBN
/*************************************************************************
      Valida la edad mínima de contratación según la parametrización del producto
      param in tomadores   : objeto tomadores
      param in psproduc  : código producto
      param in pfefecto  : fecha efecto
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_edad_tomador (
      tomadores            t_iax_tomadores,
      psproduc    IN       NUMBER,
      pfefecto    IN       DATE,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vedad_aseg   NUMBER;
      vmenor       NUMBER;
                     -- indica el numero de error si es menor alguno es nemor
      num_err      NUMBER         := -1;
      numerr       NUMBER         := 0;
      vfefecto     DATE;
      vfnacimi     DATE;
      vdatetmp     DATE;
      sproduc      NUMBER;
      vpasexec     NUMBER         := 1;
      vparam       VARCHAR2 (200)
                       := 'psproduc=' || psproduc || ' pfefecto=' || pfefecto;
      vobject      VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.F_Valida_Edad_Prod';
      vedadmin     NUMBER;
   --
   BEGIN
      sproduc := psproduc;
      vfefecto := pfefecto;
      vedadmin := NVL (f_parproductos_v (sproduc, 'EDADMINTOM'), 0);

      -- El producto tiene parametrizada la edad minima del tomador
      IF vedadmin <> 0
      THEN
         FOR ind IN tomadores.FIRST .. tomadores.LAST
         LOOP
            IF NVL (tomadores (ind).ctipper, 0) <> 2
            THEN   -- Validamos la fecha si el tomador no es persona jurídica
               vfnacimi := tomadores (ind).fnacimi;
               vdatetmp := ADD_MONTHS (vfnacimi, 12 * vedadmin);

               IF vdatetmp > TRUNC (vfefecto)
               THEN
                  numerr := 9901762;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_edad_tomador;

-- Fin Bug:17041 --JBN

   -- Bug 18362 - APD - 17/05/2011 - se crea la funcion para validar los parametros de clausulas
   FUNCTION f_valida_claupar (
      psseguro   IN       NUMBER,
      pcactivi   IN       NUMBER,
      pfefecto   IN       DATE,
      pnriesgo   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pnmovima   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      psclagen   IN       NUMBER,
      pnparame   IN       NUMBER,
      pclaupar   IN       t_iax_clausupara,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER          := 1;
      vparam      VARCHAR2 (2000)
         :=    'psseguro= '
            || psseguro
            || ' - pcactivi= '
            || pcactivi
            || ' - Pfefecto= '
            || pfefecto
            || ' - pnriesgo= '
            || pnriesgo
            || ' - Pnmovimi= '
            || pnmovimi
            || ' - Pnmovima= '
            || pnmovima
            || ' - ptablas= '
            || ptablas;
      vresultat   NUMBER;
      errnum      NUMBER          := 0;
      gidioma     NUMBER          := pac_md_common.f_get_cxtidioma;
      vobject     VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.f_valida_claupar';
      vclausula   VARCHAR2 (2000);
   BEGIN
      IF pclaupar IS NULL
      THEN
         RETURN 0;                             -- no hay parametros a validar
      END IF;

      -- Verifiquem els parametres
      IF pclaupar.COUNT > 0
      THEN
         FOR vclau IN pclaupar.FIRST .. pclaupar.LAST
         LOOP
            IF pclaupar.EXISTS (vclau)
            THEN
               IF pclaupar (vclau).sclagen = psclagen
               THEN
                  -- Si pnparame is not null --> valida solo ese parametro
                  -- Si pnparame is null --> valida todos los parametros de la clausula
                  IF pclaupar (vclau).nparame = pnparame OR pnparame IS NULL
                  THEN
                     IF pclaupar (vclau).ttexto IS NULL
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              9902015
                                                             );
                        --Es obligatorio informar la descripción del parámetro
                        RAISE e_object_error;
                     END IF;

                     --validamos los parametros
                     errnum :=
                        pac_albsgt.f_tvalclau (pclaupar (vclau).tvalclau,
                                               pclaupar (vclau).sclagen,
                                               pclaupar (vclau).nparame,
                                               pclaupar (vclau).ttexto,
                                               ptablas,
                                               psseguro,
                                               pcactivi,
                                               pnriesgo,
                                               pfefecto,
                                               pnmovimi,
                                               vresultat
                                              );

                     IF errnum <> 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              errnum
                                                             );
                        RAISE e_object_error;
                     END IF;

                     IF vresultat <> 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              9902019
                                                             );
                                      -- El valor del parámetro no es correcto
                        RAISE e_object_error;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_claupar;

-- Fin Bug 18362 - APD - 17/05/2011

   -- Bug 18848 - APD - 27/06/2011 - se crea la funcion para validar una simulacion
   FUNCTION f_valida_simulacion (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      ptablas    IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER          := 1;
      vparam     VARCHAR2 (2000)
         :=    'psseguro= '
            || psseguro
            || ' - pnmovimi= '
            || pnmovimi
            || ' - ptablas= '
            || ptablas;
      errnum     NUMBER          := 0;
      gidioma    NUMBER          := pac_md_common.f_get_cxtidioma;
      vobject    VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.f_valida_simulacion';
   BEGIN
      errnum := pac_validaciones.f_vigencia_simul (psseguro, pnmovimi);

      IF errnum <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_simulacion;

-- Fin Bug 18848 - APD - 27/06/2011

   -- INICIO BUG 19276, JBN, REEMPLAZOS
   /*************************************************************************
      Función nueva que valida si una póliza puede ser reemplazada
      param in PSSEGURO    : Identificador del seguro a reemplazaar
      param in PSPRODUC    : Identificador del producto de la póliza nueva
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_reemplazo (
      psseguro   IN       NUMBER,
      psproduc   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER          := 1;
      vparam     VARCHAR2 (2000)
                   := 'psseguro= ' || psseguro || ' - PSPRODUC= ' || psproduc;
      errnum     NUMBER          := 0;
      gidioma    NUMBER          := pac_md_common.f_get_cxtidioma;
      vobject    VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.f_valida_reemplazo';
   BEGIN
      errnum := pac_validaciones.f_valida_reemplazo (psseguro, psproduc);

      IF errnum <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_reemplazo;

   /*************************************************************************
      Valida los datos de gestión  para lel reemplazo
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_gestion_reemplazo (
      reemplazos   IN       t_iax_reemplazos,
      pgestion     IN       ob_iax_gestion,
      mensajes     IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER          := 1;
      vparam     VARCHAR2 (2000) := '';
      errnum     NUMBER          := 0;
      gidioma    NUMBER          := pac_md_common.f_get_cxtidioma;
      vobject    VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.f_valida_reemplazo';
   BEGIN
      FOR reemplazo IN reemplazos.FIRST .. reemplazos.LAST
      LOOP
         errnum :=
            pac_validaciones.f_valida_gestion_reemplazo
                                              (reemplazos (reemplazo).sreempl,
                                               pgestion.fefecto
                                              );

         IF errnum <> 0
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
            RAISE e_object_error;
         END IF;
      END LOOP;

      RETURN errnum;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_gestion_reemplazo;

-- FIN BUG 19276, JBN, REEMPLAZOS

   /*************************************************************************
      Valida los datos del corretaje
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_corretaje (
      poliza     IN       ob_iax_detpoliza,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      errnum          NUMBER         := 0;
      vparam          VARCHAR2 (1)   := NULL;
      vobject         VARCHAR2 (200)
                                  := 'PAC_MD_VALIDACIONES.F_Valida_corretaje';
      vpasexec        NUMBER (8)     := 1;
      vnumlider       NUMBER         := 0;
      vporcent        NUMBER         := 0;
      vporcomisi      NUMBER         := 0;
      vporretenc      NUMBER         := 0;
      -- Bug 20576 - APD - 16/12/2011
      vagepol         NUMBER         := 0;
      vagepol_lider   NUMBER         := 0;
      -- Fin Bug 20576 - APD - 16/12/2011
      vcont           NUMBER         := 0;
      vneg            NUMBER         := 0;
   BEGIN
      IF poliza.corretaje IS NOT NULL
      THEN
         IF poliza.corretaje.COUNT > 0
         THEN
            FOR ncor IN poliza.corretaje.FIRST .. poliza.corretaje.LAST
            LOOP
               IF poliza.corretaje.EXISTS (ncor)
               THEN
                  vporcent :=
                       NVL (vporcent, 0)
                     + NVL (poliza.corretaje (ncor).ppartici, 0);

                  IF NVL (poliza.corretaje (ncor).islider, 0) = 1
                  THEN
                     vnumlider := vnumlider + 1;

                     -- Bug 20576 - APD - 16/12/2011 - se mira si el agente lider es el agente
                     -- de la poliza
                     IF poliza.corretaje (ncor).cagente = poliza.cagente
                     THEN
                        vagepol_lider := 1;
                     END IF;
                  -- Fin Bug 20576 - APD - 16/12/2011
                  END IF;

                  -- Bug 20576 - APD - 16/12/2011 - se mira si el agente de la poliza
                  -- es uno de los agentes del corretaje
                  IF poliza.corretaje (ncor).cagente = poliza.cagente
                  THEN
                     vagepol := 1;
                  END IF;

                  IF NVL (poliza.corretaje (ncor).ppartici, 0) < 0
                  THEN
                     vneg := 1;
                  END IF;

                  -- fin Bug 20576 - APD - 16/12/2011
                  vcont := vcont + 1;
               END IF;
            END LOOP;

            IF vporcent <> 100
            THEN
               errnum := 9902398;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
               RAISE e_object_error;
            END IF;

            IF vnumlider = 0
            THEN
               errnum := 9902399;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
               RAISE e_object_error;
            END IF;

            IF vnumlider > 1
            THEN
               errnum := 9902400;
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
               RAISE e_object_error;
            END IF;

            -- Bug 20576 - APD - 16/12/2011 - el agente lider debe ser el agente
            -- de la poliza
            IF vagepol_lider = 0
            THEN
               errnum := 9902978;
                   -- El intermediario líder debe ser el agente de la póliza.
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
               RAISE e_object_error;
            END IF;

            -- fin Bug 20576 - APD - 16/12/2011

            -- Bug 20576 - APD - 16/12/2011 - el agente de la poliza debe
            -- ser uno de los agentes del corretaje
            IF vagepol = 0
            THEN
               errnum := 9902978;
                   -- El intermediario líder debe ser el agente de la póliza.
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
               RAISE e_object_error;
            END IF;

            -- fin Bug 20576 - APD - 16/12/2011
            IF vcont < 2
            THEN
               errnum := 9903936; -- Deben haber como mínimo 2 intermediarios
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
               RAISE e_object_error;
            END IF;

            IF vneg = 1
            THEN
               errnum := 9902884;           -- El valor no puede ser negativo
               pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      RETURN errnum;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_corretaje;

--ini Bug: 19303 - JMC - 16/11/2011 - Automatización del seguro saldado y prorrogado
   /*************************************************************************
      Valida que una póliza pueda ser saldada o prorrogada.
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_sp (psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER
   IS
      errnum     NUMBER         := 0;
      vparam     VARCHAR2 (1)   := NULL;
      vobject    VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.F_Valida_sp';
      vpasexec   NUMBER (8)     := 1;
   BEGIN
      errnum := pac_validaciones.f_valida_sp (psseguro);

      IF errnum <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, errnum);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_sp;

--fin Bug: 19303 - JMC - 16/11/2011

   --Bug.: 20995 - 23/01/2012 - APD
    /*************************************************************************
      Función que valida que no existan repetidos en benefeiciarios especiales
      param in ctipo : 1.- Beneficiarios de riesgo, 2.- Beneficiarios de garantia
      param in sperson : Identificador del beneficiario que no debe estar repetido
      param in norden : Orden del beneficiario que no debe estar repetido
      param in sperson_tit : Identificador del beneficiario de contingencia
      param in ob_iax_benespeciales  : Objeto de beneficiario
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_benef_repetido (
      pctipo         IN       NUMBER,
      --Ini 31204/12459 --ECP--06/05/2014
      pcgarant       IN       NUMBER,
      --Fin 31204/12459 --ECP--06/05/2014
      psperson       IN       NUMBER,
      pnorden        IN       NUMBER,
      psperson_tit   IN       NUMBER,
      benefesp       IN       ob_iax_benespeciales,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      errnum      NUMBER         := 0;
      vparam      VARCHAR2 (1)   := NULL;
      vobject     VARCHAR2 (200) := 'PAC_MD_VALIDACIONES.f_benef_repetido';
      vpasexec    NUMBER (8)     := 1;
      v_sperson   NUMBER         := NULL;
      vcobjase    NUMBER;              -- Bug 26419/140572 - 13/03/2013 - AMC
   BEGIN
      IF pctipo IS NULL OR psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pctipo = 1
      THEN                                                           -- riesgo
         IF benefesp.benef_riesgo IS NOT NULL
         THEN
            --Validamos beneficiarios a nivel de riesgo
            IF benefesp.benef_riesgo.COUNT <> 0
            THEN
               FOR i IN
                  benefesp.benef_riesgo.FIRST .. benefesp.benef_riesgo.LAST
               LOOP
                  IF benefesp.benef_riesgo.EXISTS (i)
                  THEN
                     -- Un mismo beneficiario no puede estar repetido como beneficiario de riesgo
                     IF psperson_tit =
                               NVL (benefesp.benef_riesgo (i).sperson_tit, 0)
                     THEN
                        IF     psperson = benefesp.benef_riesgo (i).sperson
                           AND pnorden <> benefesp.benef_riesgo (i).norden
                        THEN
                           -- Ya existe el beneficiario
                           pac_iobj_mensajes.crea_nuevo_mensaje
                              (mensajes,
                               1,
                               109374,
                                  f_axis_literales
                                                (109374,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                               || ' '
                               || benefesp.benef_riesgo (i).nombre_ben
                              );
                           RETURN 1;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      IF pctipo = 2
      THEN                                                        -- garantias
         IF benefesp.benefesp_gar IS NOT NULL
         THEN
            --Validamos beneficiarios a nivel de garantía
            IF benefesp.benefesp_gar.COUNT <> 0
            THEN
               FOR i IN
                  benefesp.benefesp_gar.FIRST .. benefesp.benefesp_gar.LAST
               LOOP
                  IF benefesp.benefesp_gar.EXISTS (i)
                  THEN
                     IF benefesp.benefesp_gar (i).benef_ident.COUNT <> 0
                     THEN
                        FOR j IN
                           benefesp.benefesp_gar (i).benef_ident.FIRST .. benefesp.benefesp_gar
                                                                            (i
                                                                            ).benef_ident.LAST
                        LOOP
                           IF benefesp.benefesp_gar (i).benef_ident.EXISTS
                                                                          (j)
                           THEN
                              -- Un mismo beneficiario no puede estar repetido como beneficiario de garantia
                              IF psperson_tit =
                                    NVL
                                       (benefesp.benefesp_gar (i).benef_ident
                                                                           (j).sperson_tit,
                                        0
                                       )
                              THEN
                                 IF     psperson =
                                           benefesp.benefesp_gar (i).benef_ident
                                                                          (j).sperson
                                    AND pnorden <>
                                           benefesp.benefesp_gar (i).benef_ident
                                                                           (j).norden
                                    --Ini 31204/12459 --ECP--06/05/2014
                                    AND pcgarant <>
                                           benefesp.benefesp_gar (i).benef_ident
                                                                           (j).cgarant
                                 --Fin 31204/12459 --ECP--06/05/2014
                                 THEN
                                    -- Ya existe el beneficiario
                                    pac_iobj_mensajes.crea_nuevo_mensaje
                                       (mensajes,
                                        1,
                                        109374,
                                           f_axis_literales
                                                (109374,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                                        || ' '
                                        || benefesp.benefesp_gar (i).benef_ident
                                                                           (j).nombre_ben
                                       );
                                    RETURN 1;
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      -- El asegurado no puede ser el beneficiario
      IF     pac_iax_produccion.poliza.det_poliza.riesgos IS NOT NULL
         AND pac_iax_produccion.poliza.det_poliza.riesgos.COUNT > 0
      THEN
         SELECT cobjase
           INTO vcobjase
           FROM productos
          WHERE sproduc = pac_iax_produccion.poliza.det_poliza.sproduc;

         -- Bug 26419/140572 - 13/03/2013 - AMC
         -- Bug 28479/156416 - RCL - 28/10/2013 - QT-0008984: VG DEUDORES INNOMINADO ERROR NEBEFICIARIO ASEGURADO Y ES EL MISMO TOMADOR
         IF vcobjase NOT IN (3, 4, 5)
         THEN
            FOR j IN
               pac_iax_produccion.poliza.det_poliza.riesgos.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos.LAST
            LOOP
               IF     pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase IS NOT NULL
                  AND pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase.COUNT >
                                                                             0
               THEN
                  FOR i IN
                     pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase.FIRST .. pac_iax_produccion.poliza.det_poliza.riesgos
                                                                                           (j
                                                                                           ).riesgoase.LAST
                  LOOP
                     IF psperson =
                           pac_iax_produccion.poliza.det_poliza.riesgos (j).riesgoase
                                                                          (i).sperson
                     THEN
                        --El asegurado no puede ser beneficiario
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              180392
                                                             );
                        RETURN 1;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      -- Fi Bug 26419/140572 - 13/03/2013 - AMC
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_benef_repetido;

   --Bug.: 20995 - 30/01/2012 - APD
    /*************************************************************************
      Función que suma los porcentajes de participacion de los beneficiarios especiales contingentes
      param in ctipo : 1.- Beneficiarios de riesgo, 2.- Beneficiarios de garantia
      param in sperson : Identificador del beneficiario contingente
      param in ob_iax_benespeciales  : Objeto de beneficiario
      param out particip : suma del porcentaje de participacion
                mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_suma_particip_benef_conting (
      pctipo      IN       NUMBER,
      psperson    IN       NUMBER,
      benefesp    IN       ob_iax_benespeciales,
      pparticip   OUT      NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      errnum        NUMBER         := 0;
      vparam        VARCHAR2 (1)   := NULL;
      vobject       VARCHAR2 (200)
                       := 'PAC_MD_VALIDACIONES.F_SUMA_PARTICIP_BENEF_CONTING';
      vpasexec      NUMBER (8)     := 1;
      v_pparticip   NUMBER;
   BEGIN
      IF pctipo IS NULL OR psperson IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pctipo = 1
      THEN                                                           -- riesgo
         IF benefesp.benef_riesgo IS NOT NULL
         THEN
            --Validamos beneficiarios a nivel de riesgo
            IF benefesp.benef_riesgo.COUNT <> 0
            THEN
               FOR i IN
                  benefesp.benef_riesgo.FIRST .. benefesp.benef_riesgo.LAST
               LOOP
                  IF benefesp.benef_riesgo.EXISTS (i)
                  THEN
                     IF psperson = benefesp.benef_riesgo (i).sperson_tit
                     THEN
                        -- suma los porcentajes de participacion para un mismo beneficiario titular
                        v_pparticip :=
                             NVL (v_pparticip, 0)
                           + benefesp.benef_riesgo (i).pparticip;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      IF pctipo = 2
      THEN                                                        -- garantias
         IF benefesp.benefesp_gar IS NOT NULL
         THEN
            --Validamos beneficiarios a nivel de garantía
            IF benefesp.benefesp_gar.COUNT <> 0
            THEN
               FOR i IN
                  benefesp.benefesp_gar.FIRST .. benefesp.benefesp_gar.LAST
               LOOP
                  IF benefesp.benefesp_gar.EXISTS (i)
                  THEN
                     IF benefesp.benefesp_gar (i).benef_ident.COUNT <> 0
                     THEN
                        FOR j IN
                           benefesp.benefesp_gar (i).benef_ident.FIRST .. benefesp.benefesp_gar
                                                                            (i
                                                                            ).benef_ident.LAST
                        LOOP
                           IF benefesp.benefesp_gar (i).benef_ident.EXISTS
                                                                          (j)
                           THEN
                              IF psperson =
                                    benefesp.benefesp_gar (i).benef_ident (j).sperson_tit
                              THEN
                                 -- suma los porcentajes de participacion para un mismo beneficiario titular
                                 v_pparticip :=
                                      NVL (v_pparticip, 0)
                                    + benefesp.benefesp_gar (i).benef_ident
                                                                           (j).pparticip;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      pparticip := v_pparticip;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_suma_particip_benef_conting;

   /*************************************************************************
        Funci?n que valida importes fijos de las franquicias
        mensajes : mensajes de error
        return             : 0 la validación ha sido correcta
                             1 la validación no ha sido correcta
     *************************************************************************/
   FUNCTION f_valida_importefijo_franq (
      pnriesgo            IN       NUMBER,
      pcgarant            IN       NUMBER,
      franq               IN       t_iax_bf_proactgrup,
      pbonfranseg         IN       t_iax_bonfranseg,
      pifranqu            IN       NUMBER,
      pvalorfranquicias   OUT      NUMBER,
      mensajes            IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr          NUMBER         := 0;
      vparam           VARCHAR2 (1)   := NULL;
      vobject          VARCHAR2 (200)
                          := 'PAC_MD_VALIDACIONES.F_VALIDA_IMPORTEFIJO_FRANQ';
      vpasexec         NUMBER (8)     := 1;
      vformulavalida   NUMBER;
      vformula         NUMBER;
   BEGIN
      IF pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF franq IS NOT NULL AND franq.COUNT > 0
      THEN
         FOR vfranq IN franq.FIRST .. franq.LAST
         LOOP
            IF pbonfranseg IS NOT NULL AND pbonfranseg.COUNT > 0
            THEN
               FOR vbonfranq IN pbonfranseg.FIRST .. pbonfranseg.LAST
               LOOP
                  IF pbonfranseg (vbonfranq).cgrup =
                                                   franq (vfranq).grupo.cgrup
                  THEN
                     IF pbonfranseg (vbonfranq).ctipgrupsubgrup NOT IN
                                                                      (3, 4)
                     THEN                                --franquicias libres
                        IF pbonfranseg (vbonfranq).cvalor1 = 2
                        THEN                                   --importe fijo
                           pvalorfranquicias :=
                                pvalorfranquicias
                              + pbonfranseg (vbonfranq).impvalor1;
                        END IF;

                        SELECT formulavalida
                          INTO vformulavalida
                          FROM bf_desnivel bd, bf_detnivel bfd
                         WHERE bd.cempres = bfd.cempres
                           AND bfd.cgrup = bd.cgrup
                           AND bfd.csubgrup = bd.csubgrup
                           AND bd.cversion = bfd.cversion
                           AND bd.cnivel = bfd.cnivel
                           AND bd.cgrup = pbonfranseg (vbonfranq).cgrup
                           AND bd.csubgrup = pbonfranseg (vbonfranq).csubgrup
                           AND bd.cversion = pbonfranseg (vbonfranq).cversion
                           AND bd.cempres = pac_md_common.f_get_cxtempresa
                           AND bd.cidioma = pac_md_common.f_get_cxtidioma
                           AND bd.cnivel = pbonfranseg (vbonfranq).cnivel;

                        IF vformulavalida IS NOT NULL
                        THEN
                           vnumerr :=
                              pac_bonfran.f_resuelve_formula
                                 (1,
                                  pac_iax_produccion.poliza.det_poliza.sseguro,
                                  pac_iax_produccion.poliza.det_poliza.gestion.cactivi,
                                  pac_iax_produccion.poliza.det_poliza.sproduc,
                                  pbonfranseg (vbonfranq).cgrup,
                                  pac_iax_produccion.poliza.det_poliza.gestion.fefecto,
                                  pnriesgo,
                                  vformulavalida,
                                  pac_iax_produccion.poliza.det_poliza.nmovimi,
                                  vformula
                                 );

                           IF vnumerr <> 0
                           THEN
                              RAISE e_object_error;
                           END IF;

                           IF vformula <> 0
                           THEN
                              pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                                    1,
                                                                    vformula
                                                                   );
                              RAISE e_object_error;
                           END IF;
                        --Mirem vformula i actualitzem la franqu?cia del qual depengui...
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      END IF;

      IF pvalorfranquicias + (pifranqu) < 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            45532,
                               f_axis_literales (9904365,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ', '
                            || f_axis_literales (100561,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ': '
                            || ff_desgarantia (pcgarant,
                                               pac_md_common.f_get_cxtidioma
                                              )
                           );
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_importefijo_franq;

   /*************************************************************************
         Funci?n que valida franquicias libres
         mensajes : mensajes de error
         return             : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
      *************************************************************************/
   FUNCTION f_valida_franquicias_libres (
      pnriesgo      IN       NUMBER,
      pbonfranseg   IN       t_iax_bonfranseg,
      mensajes      IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vnumerr          NUMBER         := 0;
      vparam           VARCHAR2 (1)   := NULL;
      vobject          VARCHAR2 (200)
                         := 'PAC_MD_VALIDACIONES.f_valida_franquicias_libres';
      vpasexec         NUMBER (8)     := 1;
      vformulavalida   NUMBER;
      vformula         NUMBER;
      vcvalor1         NUMBER;
      vidlistalibre    NUMBER;
      lvalor2          NUMBER;
      limpmin          NUMBER;
      limpmax          NUMBER;
      vvalor           NUMBER;
      vcgarant         NUMBER;
      vcobliga         VARCHAR2 (1);
   BEGIN
      IF pnriesgo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pbonfranseg IS NOT NULL AND pbonfranseg.COUNT > 0
      THEN
         FOR vbonfranq IN pbonfranseg.FIRST .. pbonfranseg.LAST
         LOOP
            IF pbonfranseg (vbonfranq).ctipgrupsubgrup IN (3, 4)
            THEN                                         --franquicias libres
               IF     pbonfranseg (vbonfranq).cvalor1 IS NOT NULL
                  AND pbonfranseg (vbonfranq).impvalor1 IS NOT NULL
               THEN
                  SELECT id_listlibre
                    INTO vidlistalibre
                    FROM bf_detnivel b, bf_desnivel bdl
                   WHERE b.cempres = pac_md_common.f_get_cxtempresa
                     AND b.cempres = bdl.cempres
                     AND b.csubgrup = pbonfranseg (vbonfranq).csubgrup
                     AND b.cgrup = pbonfranseg (vbonfranq).cgrup
                     AND b.cgrup = bdl.cgrup
                     AND b.csubgrup = bdl.csubgrup
                     AND b.cversion = bdl.cversion
                     AND b.cversion = pbonfranseg (vbonfranq).cversion
                     AND bdl.cversion = b.cversion
                     AND b.cnivel = bdl.cnivel
                     AND b.cnivel = b.cnivel
                     AND b.cversion = pbonfranseg (vbonfranq).cversion
                     AND cidioma = pac_md_common.f_get_cxtidioma;

                  vpasexec := 2;

                  SELECT id_listlibre_2, id_listlibre_min, id_listlibre_max,
                         cvalor
                    INTO lvalor2, limpmin, limpmax,
                         vvalor
                    FROM bf_listlibre
                   WHERE cempres = pac_md_common.f_get_cxtempresa
                     AND id_listlibre = vidlistalibre
                     AND catribu = pbonfranseg (vbonfranq).cvalor1;

                  vpasexec := 3;

                  BEGIN
                     SELECT bfpa.cgarant
                       INTO vcgarant
                       FROM bf_proactgrup bfp, bf_progarangrup bfpa
                      WHERE bfp.cempres = bfpa.cempres
                        AND bfp.cactivi = bfpa.cactivi
                        AND bfp.sproduc = bfpa.sproduc
                        AND bfp.cgrup = bfpa.codgrup
                        AND bfp.ffecini = bfpa.ffecini
                        AND bfp.sproduc =
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                        AND bfp.cactivi =
                               pac_iax_produccion.poliza.det_poliza.gestion.cactivi
                        AND bfp.cgrup = pbonfranseg (vbonfranq).cgrup
                        AND bfp.cempres = pac_md_common.f_get_cxtempresa
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;

                  vpasexec := 4;

                  IF     lvalor2 IS NOT NULL
                     AND (   pbonfranseg (vbonfranq).cvalor2 IS NULL
                          OR pbonfranseg (vbonfranq).impvalor2 IS NULL
                         )
                  THEN
                     vnumerr := 1;
                  END IF;

                  IF     limpmin IS NOT NULL
                     AND (   pbonfranseg (vbonfranq).cimpmin IS NULL
                          OR pbonfranseg (vbonfranq).impmin IS NULL
                         )
                  THEN
                     vnumerr := 1;
                  END IF;

                  IF     limpmax IS NOT NULL
                     AND (   pbonfranseg (vbonfranq).cimpmax IS NULL
                          OR pbonfranseg (vbonfranq).impmax IS NULL
                         )
                  THEN
                     vnumerr := 1;
                  END IF;

                  IF vnumerr = 1
                  THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            45532,
                               f_axis_literales (9904540,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ' - '
                            || pbonfranseg (vbonfranq).tgrup
                            || ', '
                            || f_axis_literales (100561,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ': '
                            || ff_desgarantia (vcgarant,
                                               pac_md_common.f_get_cxtidioma
                                              )
                           );
                     RAISE e_object_error;
                  END IF;
               ELSE
                  vpasexec := 5;

                  BEGIN
                     SELECT bfpa.cgarant, bfp.cobliga
                       INTO vcgarant, vcobliga
                       FROM bf_proactgrup bfp, bf_progarangrup bfpa
                      WHERE bfp.cempres = bfpa.cempres
                        AND bfp.cactivi = bfpa.cactivi
                        AND bfp.sproduc = bfpa.sproduc
                        AND bfp.cgrup = bfpa.codgrup
                        AND bfp.ffecini = bfpa.ffecini
                        AND bfp.sproduc =
                                  pac_iax_produccion.poliza.det_poliza.sproduc
                        AND bfp.cactivi =
                               pac_iax_produccion.poliza.det_poliza.gestion.cactivi
                        AND bfp.cgrup = pbonfranseg (vbonfranq).cgrup
                        AND bfp.cempres = pac_md_common.f_get_cxtempresa
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                        vcobliga := 'N';
                  END;

                  IF vcobliga = 'S'
                  THEN
                     vpasexec := 6;
                     pac_iobj_mensajes.crea_nuevo_mensaje
                           (mensajes,
                            1,
                            45532,
                               f_axis_literales (9904540,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ', '
                            || pbonfranseg (vbonfranq).tgrup
                            || ': '
                            || ff_desgarantia (vcgarant,
                                               pac_md_common.f_get_cxtidioma
                                              )
                           );
                     RAISE e_object_error;
                  END IF;
               END IF;

               IF pbonfranseg (vbonfranq).cnivel IS NOT NULL
               THEN
                  SELECT formulavalida, cvalor1, id_listlibre
                    INTO vformulavalida, vcvalor1, vidlistalibre
                    FROM bf_desnivel bd, bf_detnivel bfd
                   WHERE bd.cempres = bfd.cempres
                     AND bfd.cgrup = bd.cgrup
                     AND bfd.csubgrup = bd.csubgrup
                     AND bd.cversion = bfd.cversion
                     AND bd.cnivel = bfd.cnivel
                     AND bd.cgrup = pbonfranseg (vbonfranq).cgrup
                     AND bd.csubgrup = pbonfranseg (vbonfranq).csubgrup
                     AND bd.cversion = pbonfranseg (vbonfranq).cversion
                     AND bd.cempres = pac_md_common.f_get_cxtempresa
                     AND bd.cidioma = pac_md_common.f_get_cxtidioma
                     AND bd.cnivel = pbonfranseg (vbonfranq).cnivel;

                  IF vformulavalida IS NOT NULL
                  THEN
                     vnumerr :=
                        pac_bonfran.f_resuelve_formula
                           (1,
                            pac_iax_produccion.poliza.det_poliza.sseguro,
                            pac_iax_produccion.poliza.det_poliza.gestion.cactivi,
                            pac_iax_produccion.poliza.det_poliza.sproduc,
                            pbonfranseg (vbonfranq).cgrup,
                            pac_iax_produccion.poliza.det_poliza.gestion.fefecto,
                            pnriesgo,
                            vformulavalida,
                            pac_iax_produccion.poliza.det_poliza.nmovimi,
                            vformula
                           );

                     IF vnumerr <> 0
                     THEN
                        RAISE e_object_error;
                     END IF;

                     IF vformula <> 0
                     THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                              1,
                                                              vformula
                                                             );
                        RAISE e_object_error;
                     END IF;
                  --Mirem vformula i actualitzem la franqu?cia del qual depengui...
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

         /*
            IF pvalorfranquicias +(pifranqu) < 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                                  (mensajes, 1, 45532,
                                                   f_axis_literales(9904365,
                                                                    pac_md_common.f_get_cxtidioma)
                                                   || ', '
                                                   || f_axis_literales
                                                                      (100561,
                                                                       pac_md_common.f_get_cxtidioma)
                                                   || ': '
                                                   || ff_desgarantia(pcgarant,
                                                                     pac_md_common.f_get_cxtidioma));
               RAISE e_object_error;
            END IF;
      */
      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_franquicias_libres;

   /*************************************************************************
        Bug: 24685 2013-02-06 AEG
        Función que valida numeracion de poliza manual. Preimpresos.
        mensajes : mensajes de error
        return             : 0 la validaciÃ³n ha sido correcta
                             1 la validaciÃ³n no ha sido correcta
     *************************************************************************/
   FUNCTION f_valida_polizamanual (
      ptipasignum               NUMBER,
      pnpolizamanual            NUMBER,
      psseguro                  NUMBER,
      psproduc                  NUMBER,
      pcempres                  NUMBER,
      pcagente                  NUMBER,
      ptablas                   VARCHAR2,
      mensajes         IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      c_poliza   CONSTANT NUMBER (1)       := 1;
      v_nerr              NUMBER (20);
      vparam              VARCHAR2 (32000)
         :=    'ptipasignum= '
            || ptipasignum
            || ' ,pnpolizamanual = '
            || pnpolizamanual
            || ',psseguro= '
            || psseguro
            || ' ,psproduc = '
            || psproduc
            || ' ,pcempres = '
            || pcempres
            || ',pcagente = '
            || pcagente
            || ',ptablas = '
            || ptablas;
      vpasexec            NUMBER (8)       := 1;
      vobject             VARCHAR2 (200)
                                := 'PAC_MD_VALIDACIONES.F_VALIDA_POLIZAMANUAL';
   BEGIN
      v_nerr :=
         pac_validaciones.f_valida_polizamanual (ptipasignum,
                                                 pnpolizamanual,
                                                 psseguro,
                                                 psproduc,
                                                 pcempres,
                                                 pcagente,
                                                 ptablas
                                                );

      IF v_nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_nerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_polizamanual;

   /*************************************************************************
        Bug: 24685 2013-02-06 AEG
        Función que valida numeracion de poliza manual. Preimpresos.
        mensajes : mensajes de error
        return             : 0 la validaciÃ³n ha sido correcta
                             1 la validaciÃ³n no ha sido correcta
     *************************************************************************/
   FUNCTION f_valida_npreimpreso (
      ptipasignum             NUMBER,
      pnpreimpreso            NUMBER,
      psseguro                NUMBER,
      psproduc                NUMBER,
      pcempres                NUMBER,
      pcagente                NUMBER,
      ptablas                 VARCHAR2,
      mensajes       IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      c_poliza   CONSTANT NUMBER (1)       := 1;
      v_nerr              NUMBER (10);
      vparam              VARCHAR2 (32000)
         :=    'ptipasignum= '
            || ptipasignum
            || ' ,pnpreimpreso = '
            || pnpreimpreso
            || ',psseguro= '
            || psseguro
            || ' ,psproduc = '
            || psproduc
            || ' ,pcempres = '
            || pcempres
            || ',pcagente = '
            || pcagente
            || ',ptablas = '
            || ptablas;
      vpasexec            NUMBER (8)       := 1;
      vobject             VARCHAR2 (200)
                                 := 'PAC_MD_VALIDACIONES.F_VALIDA_NPREIMPRESO';
   BEGIN
      v_nerr :=
         pac_validaciones.f_valida_npreimpreso (pnpreimpreso,
                                                psseguro,
                                                psproduc,
                                                pcempres,
                                                pcagente,
                                                ptablas
                                               );

      IF v_nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_nerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_valida_npreimpreso;

-- Bug 28455/0159543 - JSV - 25/11/2013
--   FUNCTION f_validaasegurados_nomodifcar(psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
   FUNCTION f_validaasegurados_nomodifcar (
      psperson   IN       NUMBER,
      psseguro   IN       NUMBER,
      pssegpol   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      c_poliza   CONSTANT NUMBER (1)       := 1;
      v_nerr              NUMBER (10);
      vparam              VARCHAR2 (32000) := 'psperson= ' || psperson;
      vpasexec            NUMBER (8)       := 1;
      vobject             VARCHAR2 (200)
                       := 'PAC_MD_VALIDACIONES.f_validaasegurados_nomodifcar';
   BEGIN
      v_nerr :=
         pac_validaciones.f_validaasegurados_nomodifcar (psperson,
                                                         psseguro,
                                                         pssegpol
                                                        );

      IF v_nerr > 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_nerr);
         RAISE e_object_error;
      END IF;

      RETURN v_nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validaasegurados_nomodifcar;

   /*************************************************************************
      f_valida_campo: valida si el valor de un campo en concreto contiene algún carácter no permitido
      param in pcempres    : Código empresa
      param in pcidcampo    : Campo a validar
      param in pcampo    : Texto introducido a validar
      return             : 0 validación correcta
                           <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_valida_campo (
      pcempres    IN       NUMBER,
      pcidcampo   IN       VARCHAR2,
      pcampo      IN       VARCHAR2,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobject    VARCHAR2 (500) := 'pac_md_validaciones.f_valida_campo';
      vparam     VARCHAR2 (500)
         :=    'parámetros - pcempres: '
            || pcempres
            || ' pcidcampo: '
            || pcidcampo
            || ' pcampo: '
            || pcampo;
      vpasexec   NUMBER (5)     := 1;
      v_error    NUMBER         := 1;
   BEGIN
      v_error :=
                pac_validaciones.f_valida_campo (pcempres, pcidcampo, pcampo);
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1000455;                                --Error no controlado.
   END f_valida_campo;

   -- Inicio Bug 27305 20140121 MMS
    /*************************************************************************
       f_valida_esclausulacertif0: Valida si una clausula pertenece al certificado 0 en un hijo y,
          por lo tanto, no se puede ni borrar ni modificar.
       param in pcempres    : Código empresa
       param in pcidcampo    : Campo a validar
       param in pcampo    : Texto introducido a validar
       return             : 0 validación correcta
                            <>0 validación incorrecta
    *************************************************************************/
   FUNCTION f_valida_esclausulacertif0 (
      psseguro   IN       NUMBER,
      pmode      IN       VARCHAR2,
      pnordcla   IN       NUMBER,
      ptclaesp   IN       VARCHAR2,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      vobject    VARCHAR2 (500)
                          := 'PAC_MD_VALIDACIONES.F_VALIDA_ESCLAUSULACERTIF0';
      vparam     VARCHAR2 (500)
         :=    'parámetros - psseguro: '
            || psseguro
            || ' pmode: '
            || pmode
            || ' pnordcla: '
            || pnordcla
            || ' ptclaesp: '
            || SUBSTR (ptclaesp, 1, 200);
      vpasexec   NUMBER (5)     := 1;
      v_error    NUMBER         := 0;
   BEGIN
      v_error :=
         pac_validaciones.f_esclausulacertif0 (psseguro,
                                               pmode,
                                               pnordcla,
                                               ptclaesp
                                              );

      IF v_error <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1000455;                                --Error no controlado.
   END f_valida_esclausulacertif0;

-- Fin Bug 27305

   -- Bug 31208/176812 - AMC - 06/06/2014
   FUNCTION f_validamodi_plan (
      psseguro   IN       NUMBER,
      pnriesgo   IN       NUMBER,
      pnmovimi   IN       NUMBER,       -- Bug 31686/179633 - 16/07/2014 - AMC
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_nerr     NUMBER (10);
      vparam     VARCHAR2 (1000)
         :=    'psseguro= '
            || psseguro
            || ' pnriesgo:'
            || pnriesgo
            || ' pnmovimi:'
            || pnmovimi;
      vpasexec   NUMBER (8)      := 1;
      vobject    VARCHAR2 (200)  := 'PAC_MD_VALIDACIONES.f_validamodi_plan';
   BEGIN
      v_nerr :=
            pac_validaciones.f_validamodi_plan (psseguro, pnriesgo, pnmovimi);
                                       -- Bug 31686/179633 - 16/07/2014 - AMC

      IF v_nerr > 1
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_nerr);
         RAISE e_object_error;
      END IF;

      RETURN v_nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validamodi_plan;

-- BUG 0033510 - FAL - 19/11/2014
   /*************************************************************************
      Valida exista al menos un titular y éste tenga todas las garantías contratadas por los dependientes
      param IN psseguro: sseguro
      param IN pnmovimi: nmovimi
      param out mensajes : mensajes de error
      return :  0 todo correcto
                <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_validar_titular_salud (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_nerr     NUMBER (10);
      vparam     VARCHAR2 (1000)
                      := 'psseguro= ' || psseguro || ' pnmovimi:' || pnmovimi;
      vpasexec   NUMBER (8)      := 1;
      vobject    VARCHAR2 (200)
                             := 'PAC_MD_VALIDACIONES.f_validar_titular_salud';
   BEGIN
      v_nerr := pac_validaciones.f_validar_titular_salud (psseguro, pnmovimi);

      IF v_nerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, v_nerr);
         RAISE e_object_error;
      END IF;

      RETURN v_nerr;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_validar_titular_salud;
-- FI BUG 0033510 - FAL - 19/11/2014
END pac_md_validaciones;
/