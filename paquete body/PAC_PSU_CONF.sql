create or replace PACKAGE BODY PAC_PSU_CONF IS
   /******************************************************************************
      NOMBRE:    pac_psu_conf
      PROPSITO:
      REVISIONES:
      Ver        Fecha        Autor       Descripcin
      ---------  ----------  ---------  ------------------------------------
      1.0        07/03/2016  JAE        1. Creacin del objeto.
      2.0        06/09/2016  NMM        2. Funcin f_reaseguro_back.
      3.0        02/11/2016  HRE        3. Funcin f_facultativo
      4.0                    KJSC       4. CONF-241 AT_TEC_CONF_10_ANULACIONV_V1.0_GAP_GTEC49
      5.0    PAC_PSU_CONF Body
    29/10/2016  NMM        5. CONF-434. Desarrollo PSU.
      5.1        27/12/2016  NMM        5. CONF-434. Desarrollo PSU.
      5.2        12/06/2017  HRE        5. CONF-695. Tipologias de Reaseguro.  Se agrega
                                           funcion f_riesgo_restringido.
      6.0        17/04/2018  JLTS       6. CONF-1357_QT_2026. PSU Vigencia Superior a la permitida - Disposicin Legal
      7.0        24/04/2018  VCG        7. 	0002068: PSU Vigencia superior a la delegada - Subsidio Familiar de Vivienda
	  8.0        18/02/2019  CJMR       8. TCS-344 Marcas: Se agrega funcionalidad a PSU de marcas
	  9.0        04/03/2019	 HB         9. IAXIS-2421: Al superar tope anual de rgimen simplificado, permitir cambiar categora tributaria
      10.0       08/03/2019  CES       10. IAXIS-2420 Se agrega llamado al P_CAMBIO_REGIMEN para envio de corrreo en cambio de regimen simplificado a comn IAXIS-2421.
      11.0        31/05/2019 HARSHITA   11. IAXIS-3992: Políticas de Suscripción (Reglas de Negocio) - Nuevo Modelo de Delegaciones
      12.0       14/06/2019  ECP        12. IAXIS-3981. Marcas Integrantes Consorcios y Uniones Tempo
   ******************************************************************************/
   /*************************************************************************
      FUNCTION F_TOMADOR_RESTRINGIDO
      PSU 125 (801125)Tomador aparece en lista interna
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   /*************************************************************************
      FUNCTION F_ASEGURADO_RESTRINGIDO
      PSU 130 (801130)Asegurado aparece en lista interna
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   -- Esta funcin agrupa las 2 anteriores.
   FUNCTION f_persona_lre(
      p_nsesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_tipo IN NUMBER,--1 TOMADOR, 2 ASEGURADO
      p_ctiplis  IN   NUMBER DEFAULT NULL)    -- detvalores 800048
      RETURN NUMBER IS
      w_sperson      per_personas.sperson%TYPE;
      w_conta        NUMBER(6) := 0;

      BEGIN

        IF p_tipo = 1 THEN
          SELECT p.spereal
            INTO w_sperson
            FROM estper_personas p
           WHERE sperson = (SELECT e.sperson
                               FROM esttomadores e
                              WHERE sseguro = p_sseguro);
        ELSE
          SELECT p.spereal
            INTO w_sperson
            FROM estper_personas p
           WHERE sperson = (SELECT e.sperson
                               FROM estassegurats e
                              WHERE sseguro = p_sseguro);
        END IF;

        SELECT COUNT(0)
          INTO w_conta
          FROM lre_personas
         WHERE ctiplis = NVL(p_ctiplis,ctiplis)
           AND sperson = w_sperson
           AND fexclus IS NULL;

        IF w_conta > 0 THEN
          RETURN 1;
        ELSE
          RETURN 0;
        END IF;

   END f_persona_lre;
   ---------------------------------------------------------------------
   -- Obtiene si el contrato previamente se anulo
   -- CONF-241 KJSC AT_TEC_CONF_10_ANULACIONV_V1.0_GAP_GTEC49
   ---------------------------------------------------------------------
   FUNCTION f_contrato_prev_a(
      p_nsesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_origenpsu IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      w_error        NUMBER(2) := 0;
      w_sperson      per_personas.sperson%TYPE;
      w_ctipide      per_personas.ctipide%TYPE;
      w_nnumide      per_personas.nnumide%TYPE;
      w_anurec       NUMBER(6) := 0;
      w_ssegpol      NUMBER := 0;
      w_cambio       NUMBER := 0;
      w_valor        NUMBER;
      v_trespue      pregunpolseg.trespue%TYPE;
      v_trespue2     estpregunpolseg.trespue%TYPE;

      BEGIN
      SELECT trespue
        INTO v_trespue
        FROM estpregunpolseg
       WHERE cpregun = 4097
         AND sseguro = p_sseguro;

     FOR i IN(/*SELECT trespue
                FROM estpregunpolseg e,
                     estseguros s
               WHERE s.sseguro = e.sseguro
                 AND cpregun   = 4097
                 AND s.csituac = 10*/
                SELECT trespue
                FROM estpregunpolseg e,
                     estseguros s
               WHERE s.sseguro = e.sseguro
                 AND cpregun   = 4097
                 AND s.csituac = 10

                UNION ALL
                SELECT trespue
                FROM pregunpolseg e,
                     seguros s
               WHERE s.sseguro = e.sseguro
                 AND cpregun   = 4097
                 AND s.csituac = 4 AND s.creteni = 4

                 )
     LOOP
         IF v_trespue = i.trespue THEN
           w_anurec := 1;
         ELSE
           w_anurec := 2;
         END IF;
     END LOOP;

     RETURN w_anurec;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN 0;
      WHEN OTHERS THEN
        PSU_TRACE('PAC_PSU_CONF','f_contrato_prev_a','; p_sseguro:'||p_sseguro||'; SQLERRM:'||SQLERRM);
        RETURN -1;
   END f_contrato_prev_a;
   /*************************************************************************
      FUNCTION f_valida_cumul_max_ctgar

      param in pscontgar : Identificador contragaranta
      param in psperson  : Identificador persona
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_valida_cumul_max_ctgar(psseguro IN NUMBER,
                                     psperson IN NUMBER)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_psu_conf.f_valida_cumul_max_ctgar';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro || ' psperson: ' ||psperson;
      --
      vpexcento     NUMBER;
      v_capital     NUMBER;
      v_capital_sum NUMBER;
      wsperson      NUMBER;
      wspereal      NUMBER;
      vapuntereturn NUMBER;
      vidapunte_out NUMBER;
      vcusuari      VARCHAR2(50) := f_user;
      vcgrupo       VARCHAR2(50) := '0';
      vcontragar    NUMBER;
      vsseguro      NUMBER;
      v_hayapunte   NUMBER;
      --
   BEGIN
      --
      v_capital_sum := f_cumulo_aseg(psseguro);
      --
      SELECT sperson
        INTO wsperson
        FROM esttomadores
       WHERE sseguro = psseguro
         AND nordtom = 1;

      SELECT spereal
        INTO wspereal
        FROM estper_personas
       WHERE sperson = wsperson;
      --
      BEGIN
        SELECT nvalpar
          INTO vpexcento
          FROM per_parpersonas
         WHERE sperson = wspereal --(SELECT sperson FROM esttomadores WHERE sseguro = psseguro)
           AND cparam  = 'PER_EXCENTO_CONTGAR';
      EXCEPTION WHEN NO_DATA_FOUND THEN
        vpexcento := 0;
      END;
      --
      IF v_capital_sum > 100000000 AND
         NVL(vpexcento, 0) != 1
      THEN
         --
         --Se busca si tiene Contragarantia de clase pagar y en estado abierta
         --
         SELECT COUNT(*)
           INTO vcontragar
           FROM (SELECT c.*
                   FROM ctgar_contragarantia c,
                        per_contragarantia   p
                  WHERE c.scontgar = p.scontgar
                    AND p.sperson  = wspereal
                    AND c.ctipo    = 1 --Personal
                    AND c.cclase   = 1 --Pagar
                    AND c.cestado  = 1 --Vigente abierta
                    AND c.nmovimi  = (SELECT MAX(nmovimi)
                                        FROM ctgar_contragarantia
                                       WHERE scontgar = c.scontgar))
          WHERE cestado = 1;
         --
         IF vcontragar = 0 THEN
           --
           SELECT COUNT(*)
           INTO vcontragar
           FROM (SELECT c.*
                   FROM ctgar_contragarantia c,
                        estper_contragarantia   p
                  WHERE c.scontgar = p.scontgar
                    AND p.sperson  = wspereal
                    AND c.ctipo    = 1 --Personal
                    AND c.cclase   = 1 --Pagar
                    AND c.cestado  = 1 --Vigente abierta
                    AND c.nmovimi  = (SELECT MAX(nmovimi)
                                        FROM ctgar_contragarantia
                                       WHERE scontgar = c.scontgar))
          WHERE cestado = 1;
           --
         END IF;
         --
         IF vcontragar = 0 THEN
           --
           BEGIN
             SELECT ssegpol
               INTO vsseguro
               FROM estseguros
              WHERE sseguro = psseguro;
           EXCEPTION WHEN OTHERS THEN
             vsseguro := 0;
           END;
           --
           vapuntereturn := pac_agenda.f_set_apunte(NULL,
                                                    NULL,
                                                    3,
                                                    NULL,
                                                    1, --Tarea
                                                    0,
                                                    NULL,
                                                    NULL,
                                                    f_axis_literales(9910284),
                                                    f_axis_literales(9910846),
                                                    0,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    vidapunte_out);
           --
           SELECT COUNT(*)
             INTO v_hayapunte
             FROM agd_apunte a, agd_agenda b
            WHERE a.idapunte = b.idapunte
              AND a.ttitapu  = 'Cumulos/Cupos'
              AND a.ctipapu  = 0
              AND b.tclagd   = TO_CHAR(vsseguro);
           --
           IF v_hayapunte = 0 THEN
             --
             IF vapuntereturn = 0 THEN
               vapuntereturn := pac_agenda.f_set_agenda(vidapunte_out,
                                                        NULL,
                                                        vcusuari,
                                                        vcgrupo,
                                                        '',
                                                        1,
                                                        vsseguro,
                                                        0,
                                                        vcusuari,
                                                        vcgrupo,
                                                        '');
             END IF;
             --
           END IF;
           --
           RETURN 1;
           --
         END IF;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                  'SQLERRM: ' || SQLERRM);
      RETURN 0;
   END f_valida_cumul_max_ctgar;
   --
   /*************************************************************************
      FUNCTION f_reaseguro_back

      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_reaseguro_back(psseguro IN NUMBER) RETURN NUMBER IS
      vpasexec  NUMBER := 0;
      vobject   VARCHAR2(200) := 'pac_psu_conf.f_reaseguro_back';
      vparam    VARCHAR2(500) := 'psseguro: '||psseguro;
      PCTIPREA  seguros.ctiprea%type;
   BEGIN
      SELECT CTIPREA INTO PCTIPREA FROM SEGUROS WHERE SSEGURO = PSSEGURO;
      p_control_error('pac_psu_conf', 'f_reaseguro_back','2.-' || pctiprea || ';vparam:' || vparam);
      RETURN( PCTIPREA);
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
            SELECT ctiprea
              INTO pctiprea
              FROM estseguros
             WHERE sseguro = psseguro;
            p_control_error('pac_psu_conf', 'f_reaseguro_back','3.-' || pctiprea || ';vparam:' || vparam);
        RETURN( PCTIPREA);
      EXCEPTION
         WHEN OTHERS THEN
            p_control_error('pac_psu_conf', 'f_reaseguro_back','4.-others'||pctiprea||';vparam:'||vparam||' ;sqlerrm'||SQLERRM);
        RETURN( 0);
      END;
    WHEN OTHERS THEN
      p_control_error('pac_psu_conf', 'f_reaseguro_back','5.-others'||pctiprea||';vparam:'||vparam||' ;sqlerrm'||SQLERRM);
      RETURN( 0);
   END f_reaseguro_back;
   --
   /*************************************************************************
      FUNCTION f_duplicidad_riesgo: Valida duplicidad de riesgo
      PSU 155 (801155) Duplicidad Riesgos
      param IN psproduc   : Cdigo del producto
      param IN psseguro   : Nmero identificativo interno de SEGUROS
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo(psproduc IN NUMBER,
                                psseguro IN NUMBER) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_AVISOS_CONF.f_duplicidad_riesgo';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro;
      --
      vnumerr    NUMBER := 0;
      vcount_err NUMBER := 0;
      ptmensaje  VARCHAR2(2000);
      pcidioma   NUMBER := f_idiomauser;
      --
   BEGIN
      --
      ptmensaje := NULL;
      --
      vnumerr    := pac_validaciones_conf.f_duplicidad_riesgo_4(psproduc => psproduc,
                                                                psseguro => psseguro,
                                                                pcidioma => pcidioma,
                                                                ptmensaje => ptmensaje);
      vcount_err := vcount_err + vnumerr;
      --
      vnumerr    := pac_validaciones_conf.f_duplicidad_riesgo_5(psproduc => psproduc,
                                                                psseguro => psseguro,
                                                                pcidioma => pcidioma,
                                                                ptmensaje => ptmensaje);
      vcount_err := vcount_err + vnumerr;
      --
      vnumerr    := pac_validaciones_conf.f_duplicidad_riesgo_6(psproduc => psproduc,
                                                                psseguro => psseguro,
                                                                pcidioma => pcidioma,
                                                                ptmensaje => ptmensaje);
      vcount_err := vcount_err + vnumerr;
      --
      vnumerr    := pac_validaciones_conf.f_duplicidad_riesgo_7(psproduc => psproduc,
                                                                psseguro => psseguro,
                                                                pcidioma => pcidioma,
                                                                ptmensaje => ptmensaje);
      vcount_err := vcount_err + vnumerr;
      --
      vnumerr    := pac_validaciones_conf.f_duplicidad_riesgo_8(psproduc => psproduc,
                                                                psseguro => psseguro,
                                                                pcidioma => pcidioma,
                                                                ptmensaje => ptmensaje);
      vcount_err := vcount_err + vnumerr;
      --
      vnumerr    := pac_validaciones_conf.f_duplicidad_riesgo_9(psproduc => psproduc,
                                                                psseguro => psseguro,
                                                                pcidioma => pcidioma,
                                                                ptmensaje => ptmensaje);
      vcount_err := vcount_err + vnumerr;
      --
      IF vcount_err != 0
      THEN
         --
         ptmensaje := f_axis_literales(9908858, pcidioma) || chr(13) ||
                      ptmensaje;
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo;

   /*************************************************************************
      FUNCTION f_facultativo: Controla si necesita Reaseguro Facultativo
      param IN p_nsesion   : Cdigo de la sesion
      param IN psseguro    : Nmero identificativo interno de SEGUROS
      param IN p_fefecto   : Fecha de efecto
      param IN p_nmovimi   : Numero de Movimiento
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
    FUNCTION f_facultativo(
    p_nsesion IN NUMBER,
    p_sseguro IN NUMBER,
    p_fefecto IN NUMBER,
    p_nmovimi IN NUMBER)
    RETURN NUMBER IS
    w_error        NUMBER := 0;
    w_facul        NUMBER := 0;
    w_sproduc      seguros.sproduc%TYPE;
    w_ctiprea      seguros.ctiprea%TYPE;
    w_motiu        NUMBER;
    w_nsolici      seguros.nsolici%TYPE;
    vcmoneda       monedas.cmoneda%TYPE;
    w_sproces      procesoscab.sproces%TYPE;
    w_cempres      seguros.cempres%TYPE;
    v_cgenrec      codimotmov.cgenrec%TYPE := 1;
    vcapitalini    NUMBER := 0;
    vcapitalfin    NUMBER := 0;
    vprimaini      NUMBER := 0;
    vprimafin      NUMBER := 0;
    vnriesgo       NUMBER;
    vtabla         VARCHAR(4) := 'EST';
    v_traza        NUMBER := 0;
   BEGIN
      v_traza := 101;

      BEGIN
         SELECT sproduc, NVL(ctiprea, 0), NVL(nsolici, 0), NVL(cempres, 17)
           INTO w_sproduc, w_ctiprea, w_nsolici, w_cempres
           FROM estseguros
          WHERE sseguro = p_sseguro;
      EXCEPTION
         -- AVT 04/02/2014 control sobre les taules definitives
         WHEN NO_DATA_FOUND THEN
            v_traza := 102;

            SELECT sproduc, NVL(ctiprea, 0), NVL(nsolici, 0), NVL(cempres, 17)
              INTO w_sproduc, w_ctiprea, w_nsolici, w_cempres
              FROM seguros
             WHERE sseguro = p_sseguro;

            vtabla := 'REA';
         WHEN OTHERS THEN
            v_traza := 103;
            w_error := 1;
      END;

      v_traza := 104;

      IF w_error = 0
         AND w_ctiprea = 0 THEN
         BEGIN
            SELECT pac_monedas.f_moneda_producto(sproduc)
              INTO vcmoneda
              FROM productos
             WHERE sproduc = w_sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               v_traza := 105;
               w_error := 1;
         END;
      END IF;

      vnriesgo := NVL(pac_gfi.f_sgt_parms('NRIESGO', p_nsesion), 1);

      IF vnriesgo = 0 THEN
         vnriesgo := 1;
      END IF;

      IF vtabla IN('REA', 'CAR') THEN
         BEGIN
            --CAR
            SELECT NVL(SUM(e.icapital), 0), NVL(SUM(e.iprianu), 0)
              INTO vcapitalfin, vprimafin
              FROM seguros s, garancar e, garanpro g
             WHERE s.sseguro = p_sseguro
               AND e.sseguro = s.sseguro
               AND e.nriesgo = vnriesgo
               AND g.sproduc = s.sproduc
               AND g.cgarant = e.cgarant
               AND g.cactivi = s.cactivi
               AND NVL(g.creaseg, 1) = 1;

            vtabla := 'CAR';

            IF vcapitalfin = 0
               AND vprimafin = 0 THEN
               --REA
               SELECT NVL(SUM(e.icapital), 0), NVL(SUM(e.iprianu), 0)
                 INTO vcapitalfin, vprimafin
                 FROM seguros s, garanseg e, garanpro g
                WHERE s.sseguro = p_sseguro
                  AND e.sseguro = s.sseguro
                  AND e.nmovimi = p_nmovimi
                  AND e.nriesgo = vnriesgo
                  AND g.sproduc = s.sproduc
                  AND g.cgarant = e.cgarant
                  AND g.cactivi = s.cactivi
                  AND NVL(g.creaseg, 1) = 1;

               vtabla := 'REA';
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalfin := 0;
               vprimafin := 0;
         END;
      ELSIF vtabla = 'EST' THEN
         BEGIN
            SELECT NVL(SUM(e.icapital), 0), NVL(SUM(e.iprianu), 0)
              INTO vcapitalfin, vprimafin
              FROM estseguros s, estgaranseg e, garanpro g
             WHERE s.sseguro = p_sseguro
               AND e.sseguro = s.sseguro
               AND e.nmovimi = p_nmovimi
               AND e.nriesgo = vnriesgo
               AND g.sproduc = s.sproduc
               AND g.cgarant = e.cgarant
               AND g.cactivi = s.cactivi
               AND NVL(e.cobliga, 1) = 1
               AND NVL(g.creaseg, 1) = 1;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalfin := 0;
               vprimafin := 0;
         END;
      END IF;

      v_traza := 105;

      IF vtabla IN('REA', 'CAR') THEN
         BEGIN
            SELECT NVL(SUM(e.icapital), 0), NVL(SUM(e.iprianu), 0)
              INTO vcapitalini, vprimaini
              FROM seguros s, garanseg e, garanpro g
             WHERE s.sseguro = p_sseguro
               AND e.sseguro = s.sseguro
               AND e.nmovimi = (SELECT MAX(nmovimi)
                                  FROM garanseg e2
                                 WHERE e2.sseguro = e.sseguro
                                   AND e2.cgarant = e.cgarant
                                   AND e2.nriesgo = e.nriesgo
                                   AND e2.nmovimi < p_nmovimi)
               AND e.nriesgo = vnriesgo
               AND g.sproduc = s.sproduc
               AND g.cactivi = s.cactivi
               AND g.cgarant = e.cgarant
               AND NVL(g.creaseg, 1) = 1;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalini := 0;
               vprimaini := 0;
         END;
      ELSIF vtabla = 'EST' THEN
         BEGIN
            SELECT NVL(SUM(e.icapital), 0), NVL(SUM(e.iprianu), 0)
              INTO vcapitalini, vprimaini
              FROM estseguros s, garanseg e, garanpro g
             WHERE s.sseguro = p_sseguro
               AND e.sseguro = s.ssegpol
               AND e.nmovimi = (SELECT MAX(nmovimi)
                                  FROM garanseg e2
                                 WHERE e2.sseguro = e.sseguro
                                   AND e2.cgarant = e.cgarant
                                   AND e2.nriesgo = e.nriesgo
                                   AND e2.nmovimi <= p_nmovimi)
               AND e.nriesgo = vnriesgo
               AND g.sproduc = s.sproduc
               AND g.cactivi = s.cactivi
               AND g.cgarant = e.cgarant
               AND NVL(g.creaseg, 1) = 1;
         EXCEPTION
            WHEN OTHERS THEN
               vcapitalini := 0;
               vprimaini := 0;
         END;
      END IF;

      IF p_nmovimi > 1 THEN
         IF NVL(vcapitalini, 0) = NVL(vcapitalfin, 0) THEN   --Si no hay cambio de capital no pedimos  mirar facultativo
            v_cgenrec := 0;
         END IF;
      ELSE
         v_cgenrec := 1;
      END IF;

      v_traza := 106;

      IF v_cgenrec = 1   -- 28777 AVT 13/11/2013
         AND w_error = 0
         AND w_ctiprea IN (0, 2)--= 0
         AND pac_cesionesrea.producte_reassegurable(w_sproduc) = 1 THEN   -- 26663 AVT 07/10/2013 s'afegeix el control de producte reassegurable
         w_error := f_procesini(f_user, w_cempres, 'REASEGURO_EST','Retencin por facultativo', w_sproces);
         IF w_error != 0 THEN
            v_traza := 107;
            w_error := 1;
         END IF;

         IF w_error = 0 THEN
            IF p_nmovimi = 1 THEN
               w_motiu := 3;
            ELSE
               IF vtabla = 'CAR' THEN
                  w_motiu := 5;
               ELSE
                  w_motiu := 4;
               END IF;
            END IF;
         END IF;

         w_facul := pac_cesionesrea.f_buscactrrea_est(p_sseguro, p_nmovimi, w_sproces, w_motiu,
                                                      vcmoneda, 1, NULL, NULL, vtabla);

         IF w_facul = 0 THEN
            v_traza := 117;
            w_facul := pac_cesionesrea.f_cessio_est(w_sproces, w_motiu, vcmoneda, f_sysdate,
                                                    -1, vtabla);

         END IF;
      END IF;

      IF w_facul = 99 OR w_ctiprea = 2 THEN
         RETURN 1;
      ELSIF w_facul != 0 THEN
         RETURN 99999;
      ELSE
         RETURN 0;   -- No s Facultatiu
      END IF;
   END f_facultativo;
   --
   -- NMM.CONF-434.i
   --
   /*************************************************************************
      FUNCTION F_ES_CONTRACTUAL_SALARIO
      param in pcgarant  : Identificador garanta
      return             : number
   *************************************************************************/
   FUNCTION F_ES_CONTRACTUAL_SALARIO ( PSPRODUC IN NUMBER, PCGARANT IN NUMBER)
      RETURN NUMBER IS
    WRESULT NUMBER;
   BEGIN
     PSU_TRACE('PAC_PSU_CONF','F_ES_CONTRACTUAL_SALARIO','WRESULT:'||WRESULT||'; PSPRODUC:'||PSPRODUC||'; PCGARANT:'||PCGARANT);
     -- 0: PRE-CONTRACTUAL; 1: CONTRACTUAL; 2: POST-CONTRACTUAL; 3: SALARIO
    BEGIN
      SELECT CVALPAR
        INTO WRESULT
        FROM PARGARANPRO
       WHERE CPARGAR = 'AMPARO_TIPO_SALARIO'
         AND SPRODUC = PSPRODUC
         AND CGARANT = PCGARANT
         AND ROWNUM = 1;

      RETURN 3;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT CVALPAR
          INTO WRESULT
          FROM PARGARANPRO
         WHERE CPARGAR = 'EXCONTRACTUAL'
           AND SPRODUC = PSPRODUC
           AND CGARANT = PCGARANT
           AND ROWNUM = 1;

        RETURN( WRESULT);

    END;
   EXCEPTION
      WHEN OTHERS THEN
        RETURN( -1);
   END F_ES_CONTRACTUAL_SALARIO;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_prec
      Vigencia supera nivel delegacin: Modalidad Derivado de Contrato - Precontractual
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIG_SUP_NIV_DELEGA_PREC( PSSEGURO  IN      NUMBER)
      RETURN NUMBER IS
      WDIF  NUMBER;
      WRET  NUMBER;
   BEGIN
      SELECT months_between(FVENCIM, FEFECTO)
      INTO     WDIF
      FROM     ESTSEGUROS
       WHERE   SSEGURO = PSSEGURO;
      -- VIGENCIA SUPERIOR A 5 AOS (60 MESES O 1825 DAS)
      IF WDIF > 60 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_PREC','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_PREC','PSSEGURO:'||PSSEGURO||' SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIG_SUP_NIV_DELEGA_PREC;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_contrac
      Vigencia supera nivel delegacin: Modalidad Derivado de Contrato - Contractual
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIG_SUP_NIV_DELEGA_CONTRAC( PSSEGURO IN NUMBER, PCGARANT IN NUMBER)
      RETURN NUMBER IS
      WDIF   NUMBER;
      WDIF2  NUMBER;
      WRET   NUMBER;
   BEGIN
      SELECT months_between(FVENCPLAZO, FEFEPLAZO) INTO WDIF
        FROM ESTSEGUROS
       WHERE SSEGURO = PSSEGURO;
      --
      SELECT months_between(FFINVIG, FINIVIG) INTO WDIF2 FROM ESTGARANSEG
      WHERE  SSEGURO = PSSEGURO AND CGARANT = PCGARANT;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_CONTRAC','PSSEGURO:'||PSSEGURO||'; PCGARANT:'||PCGARANT);
      -- PLAZO DE EJECUCIN SUPERIOR A 5 AOS (60 MESES O 1825 DAS) O
      -- VIGENCIA POR AMPARO SUPERA LOS 5 AOS Y 6 MESES (2007 DAS)
      IF WDIF > 60 OR WDIF2 > 66 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_CONTRAC','Wdif:'||Wdif||'; Wdif2:'||Wdif2||'; wret:'||wret);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_CONTRAC','PSSEGURO:'||PSSEGURO||' SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIG_SUP_NIV_DELEGA_CONTRAC;
   --
   /*************************************************************************
      FUNCTION F_VIG_SUP_NIV_DELEGA_PAGOSAL
      Vigencia supera nivel delegacin: Modalidad Derivado de - Contrato Pago Salarios
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIG_SUP_NIV_DELEGA_PAGOSAL( PSSEGURO  IN      NUMBER, PCGARANT IN NUMBER)
      RETURN NUMBER IS
      WDIF   NUMBER;
      WDIF2  NUMBER;
      WRET   NUMBER;
   BEGIN
      SELECT months_between(FVENCPLAZO, FEFEPLAZO)
        INTO WDIF
        FROM ESTSEGUROS
       WHERE SSEGURO = PSSEGURO;

      SELECT months_between(FFINVIG, FINIVIG) INTO WDIF2 FROM ESTGARANSEG
      WHERE  SSEGURO = PSSEGURO AND CGARANT = PCGARANT;
      -- PLAZO DE EJECUCIN SUPERIOR A 5 AOS (60 MESES O 1825 DAS) O
      -- VIGENCIA POR AMPARO SUPERA LOS 5 AOS Y 3 AOS (2920 DAS)
      IF WDIF > 60 OR WDIF2 > 96 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_PAGOSAL','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_PAGOSAL','PSSEGURO:'||PSSEGURO||' SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIG_SUP_NIV_DELEGA_PAGOSAL;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_postcont
      Vigencia supera nivel delegacin: Modalidad Derivado de - Contrato Post Contractual
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIG_SUP_NIV_DELEGA_POSTCONT( PSSEGURO IN NUMBER, PCGARANT IN NUMBER)
      RETURN NUMBER IS
      WDIF  NUMBER;
      WRET  NUMBER;
   BEGIN
      SELECT months_between(FFINVIG, FINIVIG) INTO WDIF FROM ESTGARANSEG
       WHERE SSEGURO = PSSEGURO
         AND cgarant = PCGARANT;
      -- VIGENCIA X AMPARO SUPERIOR A 5 AOS (60 MESES O 1825 DAS)
      IF WDIF > 60 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_POSTCONT','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_POSTCONT','PSSEGURO:'||PSSEGURO||' SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIG_SUP_NIV_DELEGA_POSTCONT;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_subfam
      Vigencia supera nivel delegacin: Subsidio Familiar Vivienda
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIG_SUP_NIV_DELEGA_SUBFAM( PSSEGURO IN NUMBER)
      RETURN NUMBER IS
      WDIF  NUMBER;
      WRET  NUMBER;
   BEGIN
      --SELECT FRENOVA - FEFECTO
      SELECT months_between(FVENCIM, FEFECTO)
      INTO     WDIF
      FROM     ESTSEGUROS
      WHERE    SSEGURO = PSSEGURO;
      -- VIGENCIA SUPERIOR A 5 AOS (60 MESES O 1825 DAS)
      IF WDIF > 60 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_SUBFAM','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_SUBFAM','PSSEGURO:'||PSSEGURO||' SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIG_SUP_NIV_DELEGA_SUBFAM;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_displeg
      Vigencia supera nivel delegacin: Para Disposiciones Legales
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIG_SUP_NIV_DELEGA_DISPLEG( PSSEGURO IN NUMBER)
      RETURN NUMBER IS
      WDIF  NUMBER;
      WRET  NUMBER;
   BEGIN
      --SELECT FRENOVA - FEFECTO
      SELECT months_between(FVENCIM, FEFECTO)
      INTO     WDIF
      FROM     ESTSEGUROS
      WHERE    SSEGURO = PSSEGURO;
      -- VIGENCIA SUPERIOR A 5 AOS (60 MESES O 1825 DAS)
      IF WDIF > 60 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_DISPLEG','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_DISPLEG','PSSEGURO:'||PSSEGURO||' SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIG_SUP_NIV_DELEGA_DISPLEG;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega_caucileg
      Vigencia supera nivel delegacin: Para Cauciones judiciales
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIG_SUP_NIV_DELEGA_CAUCILEG( PSSEGURO IN NUMBER)
      RETURN NUMBER IS
      WDIF  NUMBER;
      WRET  NUMBER;
   BEGIN
      SELECT months_between(FVENCIM, FEFECTO)
        INTO WDIF
        FROM ESTSEGUROS
       WHERE SSEGURO = PSSEGURO;
      -- VIGENCIA SUPERIOR A 5 AOS (60 MESES O 1825 DAS)
      IF WDIF > 60 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_CAUCILEG','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA_CAUCILEG','PSSEGURO:'||PSSEGURO||' SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIG_SUP_NIV_DELEGA_CAUCILEG;
   --
   /*************************************************************************
      FUNCTION f_vig_sup_niv_delega
      Vigencia supera nivel delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIG_SUP_NIV_DELEGA( PSSEGURO IN NUMBER, PCGARANT IN NUMBER) RETURN NUMBER IS
      WRET      NUMBER;
      WRET2     NUMBER;
      WSPRODUC  NUMBER;
      WCRAMO    NUMBER;
   BEGIN
      SELECT SPRODUC, CRAMO INTO WSPRODUC, WCRAMO FROM ESTSEGUROS WHERE SSEGURO = PSSEGURO;
      -- CONF-1357_QT_2026 - JLTS - 17/04/2018 - Se adicional los productos 80009 y 80010.
      -- QT-2068-VCG-24/04/2018- Se actualizan los codigos de los productos Subsidio Familiar de Vivienda y Caucion Judicial
      IF WSPRODUC IN (80001, 80002, 80003, 80004, 80005, 80006,80009,80010, 80007, 80008, 80011) THEN
        WRET := F_ES_CONTRACTUAL_SALARIO( WSPRODUC , PCGARANT);

        IF WRET = 0 THEN
          WRET2 := F_VIG_SUP_NIV_DELEGA_PREC( PSSEGURO);
        ELSIF WRET = 1 THEN
          WRET2 := F_VIG_SUP_NIV_DELEGA_CONTRAC( PSSEGURO, PCGARANT);
        ELSIF WRET = 2 THEN
          WRET2 := F_VIG_SUP_NIV_DELEGA_POSTCONT( PSSEGURO, PCGARANT);
        ELSIF WRET = 3 THEN
          WRET2 := F_VIG_SUP_NIV_DELEGA_PAGOSAL( PSSEGURO, PCGARANT);
        END IF;
      ELSIF WSPRODUC=8033 THEN
        WRET2 := F_VIG_SUP_NIV_DELEGA_CAUCILEG( PSSEGURO);
      ELSIF WSPRODUC=8035 THEN
        WRET2 := F_VIG_SUP_NIV_DELEGA_DISPLEG( PSSEGURO);
      ELSIF WSPRODUC=8037 THEN
        WRET2 := F_VIG_SUP_NIV_DELEGA_SUBFAM( PSSEGURO);
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA','WRET:'||WRET||'; WRET2:'||WRET2||'; PSSEGURO:'||PSSEGURO||'; PCGARANT:'||PCGARANT);
      RETURN( WRET2);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIG_SUP_NIV_DELEGA','PSSEGURO:'||PSSEGURO||'; PCGARANT:'||PCGARANT||' SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIG_SUP_NIV_DELEGA;
   --
   /*************************************************************************
      FUNCTION f_ries_abs_rel
      Riesgo Relativo o Absoluto aplicado supera Nivel de Delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_RIES_ABS_REL( PSSEGURO IN NUMBER, P_ABS_REL IN CHAR) RETURN NUMBER IS
      WRET      NUMBER;
      WSPRODUC  NUMBER;
      WCRAMO    NUMBER;
      WCMODALI  NUMBER;
      WCTIPSEG  NUMBER;
      WCCOLECT  NUMBER;
      WSTEP     NUMBER := 0;
      WCOUNT    NUMBER;
   BEGIN
      WSTEP := 10;
      SELECT CRAMO, CMODALI, CTIPSEG, CCOLECT, SPRODUC
      INTO   WCRAMO, WCMODALI, WCTIPSEG, WCCOLECT, WSPRODUC
      FROM ESTSEGUROS  WHERE SSEGURO = PSSEGURO;
      --
      IF WCRAMO IN (801,805,806) THEN
        WSTEP := 20;
        /*SELECT DECODE(CRETEN,'N',0, 'R', 1, 2) INTO WRET
        FROM ESTPREGUNSEG P, SECTORESPROD SP
        WHERE SP.CCODCONTRATO = P.CRESPUE
        AND   P.SSEGURO       = PSSEGURO
        AND   P.CPREGUN       = 2880
        AND   SP.CRAMO        = WCRAMO
        AND   SP.CMODALI      = WCMODALI
        AND   SP.CTIPSEG      = WCTIPSEG
        AND   SP.CCOLECT      = WCCOLECT;*/
        SELECT DECODE(CRETEN,'P',1, 0) INTO WRET
        FROM ESTPREGUNSEG P, SECTORESPROD SP
        WHERE SP.CCODCONTRATO = P.CRESPUE
        AND   P.SSEGURO       = PSSEGURO
        AND   P.CPREGUN       = 2880
        AND   SP.CRAMO        = WCRAMO
        AND   SP.CMODALI      = WCMODALI
        AND   SP.CTIPSEG      = WCTIPSEG
        AND   SP.CCOLECT      = WCCOLECT
        AND   SP.creten = 'P'
        AND ROWNUM = 1;
      ELSIF WCRAMO = 802 THEN
        SELECT DECODE(CRETEN,'N',0, 'I', 1, 'R', 2, 'A', 3) INTO WRET
        FROM ESTPREGUNSEG P, SECTORESPROD SP
        WHERE SP.CCODCONTRATO = P.CRESPUE
        AND   P.SSEGURO       = PSSEGURO
        AND   P.CPREGUN       = 2880
        AND   SP.CRAMO        = WCRAMO
        AND   SP.CMODALI      = WCMODALI
        AND   SP.CTIPSEG      = WCTIPSEG
        AND   SP.CCOLECT      = WCCOLECT;
      END IF;

      WSTEP := 30;
      PSU_TRACE('PAC_PSU_CONF','F_RIES_ABS_REL','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO||'; P_ABS_REL:'||P_ABS_REL);
      RETURN( WRET);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_RIES_ABS_REL','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; P_ABS_REL:'||P_ABS_REL||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_RIES_ABS_REL;
   --
   /*************************************************************************
      FUNCTION f_valor_max_aseg
      PSU 30 (80130) Valor Asegurado supera Nivel de Delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VALOR_MAX_ASEG( PSSEGURO IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
   BEGIN
      WSTEP := 10;
      SELECT  SUM(ICAPITAL) INTO WRET
      FROM    ESTGARANSEG
      WHERE   SSEGURO = PSSEGURO
      AND     COBLIGA = 1;
      PSU_TRACE('PAC_PSU_CONF','F_VALOR_MAX_ASEG','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO );
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VALOR_MAX_ASEG','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VALOR_MAX_ASEG;
   --
   /*************************************************************************
      FUNCTION f_cambio_tomador
      PSU 7006 (801706) Cambio tomador supera Nivel de Delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_CAMBIO_TOMADOR( PSSEGURO IN NUMBER, PSSEGPOL IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
   BEGIN
      -- SUPL. CAMBIO TOMADOR CMOTMOV 696, SELECT PDS_SUPL_VALIDACIO
      WSTEP := 10;
      SELECT DECODE( COUNT(*), 0, 0, 1) INTO WRET FROM (
        SELECT SPERSON
        FROM   TOMADORES T
        WHERE  SSEGURO = PSSEGPOL
        MINUS
        SELECT SPEREAL
        FROM   ESTTOMADORES T, ESTPER_PERSONAS E
        WHERE  T.SSEGURO = PSSEGURO
        AND    T.SPERSON=E.SPERSON);
      --
      PSU_TRACE('PAC_PSU_CONF','F_CAMBIO_TOMADOR','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO||'; PSSEGPOL:'||PSSEGPOL);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_CAMBIO_TOMADOR','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; PSSEGPOL:'||PSSEGPOL||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_CAMBIO_TOMADOR;

   /*************************************************************************
      FUNCTION F_RETROACTIVIDAD
      PSU 45 (80145)Retroactividad superior al Nivel de Delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_RETROACTIVIDAD( PSSEGURO IN NUMBER, PFEFECTO IN NUMBER, PNMOVIMI IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
   BEGIN
      WSTEP := 10;
      WRET := TRUNC(SYSDATE) - TO_DATE(PFEFECTO,'YYYYMMDD');

      PSU_TRACE('PAC_PSU_CONF','F_RETROACTIVIDAD','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO||'; PFEFECTO:'||PFEFECTO||'; PNMOVIMI:'||PNMOVIMI);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_RETROACTIVIDAD','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_RETROACTIVIDAD;
   --
   /*************************************************************************
      FUNCTION F_TASA_APLICADA
      PSU 10 (80110) Tasa aplicada supera Nivel de delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_TASA_APLICADA( PSSEGURO IN NUMBER, PCGARANT   IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WRAMO         NUMBER;
   BEGIN
      WSTEP := 10;
         PSU_TRACE('PAC_PSU_CONF','F_TASA_APLICADA','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
      SELECT CRAMO INTO WRAMO FROM ESTSEGUROS WHERE SSEGURO = PSSEGURO;
         PSU_TRACE('PAC_PSU_CONF','F_TASA_APLICADA','STEP:'||WSTEP||'; WRAMO:'||WRAMO||'; SQLERRM:'||SQLERRM);

      IF WRAMO IN (801, 805, 806) THEN
        BEGIN
          SELECT NVL(CRESPUE, 0)
            INTO WRET
            FROM ESTPREGUNGARANSEG
           WHERE SSEGURO = PSSEGURO
             AND CGARANT = PCGARANT
             AND CPREGUN = 6624;
        EXCEPTION
          WHEN OTHERS THEN
            WRET := 0;
        END;
      ELSIF WRAMO = 802 THEN
        BEGIN
          SELECT NVL(CRESPUE, 0)
            INTO WRET
            FROM ESTPREGUNGARANSEG
           WHERE SSEGURO = PSSEGURO
             AND CGARANT = PCGARANT
             AND CPREGUN = 8001
             AND CRESPUE < 0.18;
        EXCEPTION
          WHEN OTHERS THEN
            WRET := 0;
        END;
      ELSIF WRAMO = 804 THEN
        BEGIN
          SELECT NVL(CRESPUE, 0)
            INTO WRET
            FROM estpregunseg
           WHERE SSEGURO = PSSEGURO
             AND CPREGUN = 6510;
        EXCEPTION
          WHEN OTHERS THEN
            WRET := 0;
        END;
      END IF;
         PSU_TRACE('PAC_PSU_CONF','F_TASA_APLICADA','STEP:'||WSTEP||'; WRET:'||WRET);

      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_TASA_APLICADA','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_TASA_APLICADA;
   --
   /*************************************************************************
      FUNCTION F_COMISION_APLICADA
      PSU 40 (80140) Comision aplicada supera Nivel de Delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_COMISION_APLICADA( PSSEGURO IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WMODE         NUMBER;
    WPCTCOMIS     NUMBER;
    v_cagente     seguros.cagente%TYPE;
    v_sproduc     seguros.sproduc%TYPE;

   BEGIN
      WSTEP := 10;
      IF F_ES_RENOVACION(PSSEGURO) = 0 THEN    -- es cartera
         WMODE := 2;
      ELSE                                     -- si es 1 es nueva produccion
         WMODE := 1;
      END IF;
      --
      SELECT cagente, sproduc
        INTO v_cagente, v_sproduc
        FROM estseguros
       WHERE sseguro = PSSEGURO;

      BEGIN
         SELECT nvl(pcomisi,0)
           INTO WRET
           FROM estcomisionsegu
          WHERE sseguro =psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT MIN(pcomisi)
                 INTO WRET
                 FROM comisionprod c, agentes a
                WHERE c.ccomisi = a.ccomisi
                  AND a.cagente= v_cagente
                  AND c.sproduc =v_sproduc
                  AND c.finivig = (SELECT MAX(finivig)
                                     FROM comisionvig v
                                    WHERE v.ccomisi = a.ccomisi
                                      AND v.finivig <= f_sysdate);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  WRET:=0;
               END;
      END;
      /*FOR R IN ( SELECT S.FEFECTO,S.CAGENTE,S.CRAMO,S.CMODALI,S.CTIPSEG,S.CCOLECT,S.CACTIVI
                 FROM   ESTSEGUROS S
                 WHERE  S.SSEGURO = PSSEGURO) LOOP
        WSTEP := 20;
        WRET := FF_PCOMISI(NULL,NULL,WMODE,R.FEFECTO,R.CAGENTE,R.CRAMO,R.CMODALI,R.CTIPSEG,R.CCOLECT,R.CACTIVI,NULL,'EST','CAR');
         p_control_error('PAC_PSU_CONF', 'F_COMISION_APLICADA','WRET:'||WRET);
      END LOOP;*/
      PSU_TRACE('PAC_PSU_CONF','F_COMISION_APLICADA','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_COMISION_APLICADA','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_COMISION_APLICADA;
   --
   /*************************************************************************
      FUNCTION F_NUEVA_CLAUSULA
      PSU 100 (801100) Nueva clusula para revisin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_NUEVA_CLAUSULA( PSSEGURO IN NUMBER, PSSEGPOL IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WCLAUSUESP    CLAUSUESP.TCLAESP%TYPE;
   BEGIN
      WSTEP := 10;
      SELECT DECODE( COUNT(*), 0, 0, 1)  INTO WRET
      FROM   ESTCLAUSUESP E
      WHERE  E.SSEGURO = PSSEGURO
      AND    NMOVIMI = (SELECT  MAX(NMOVIMI)
                        FROM    ESTCLAUSUESP EE
                        WHERE   EE.SSEGURO = E.SSEGURO)
      AND  CCLAESP=2;
      PSU_TRACE('PAC_PSU_CONF','F_NUEVA_CLAUSULA','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO||'; PSSEGPOL:'||PSSEGPOL);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_NUEVA_CLAUSULA','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_NUEVA_CLAUSULA;
   --
   /*************************************************************************
      FUNCTION f_coaseguro
      PSU 105 (801105) Coaseguro
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_COASEGURO( PSSEGURO IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
   BEGIN
      WSTEP := 10;
      --SELECT CTIPCOA INTO WRET FROM ESTSEGUROS WHERE SSEGURO = PSSEGURO;
      SELECT DECODE(COUNT(*),0,0,1) INTO WRET FROM ESTSEGUROS WHERE SSEGURO = PSSEGURO AND CTIPCOA IN (1,8);
      PSU_TRACE('PAC_PSU_CONF','F_COASEGURO','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_COASEGURO','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_COASEGURO;
   --
   /*************************************************************************
      FUNCTION F_SUBSIDIO_FAMI
      PSU 10 (80110)Tasa aplicada supera Nivel de delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   /*************************************************************************
      FUNCTION F_DISP_LEGALES
      PSU 115 (801115) Disposiciones Legales
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   --
   /*************************************************************************
      FUNCTION F_PERSONA_NATURAL
      PSU 135 (801135) Asegurado persona natural
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_PERSONA_NATURAL( PSSEGURO IN NUMBER) RETURN NUMBER IS
      WRET          NUMBER := 0;
      WSTEP         NUMBER := 0;
   BEGIN

      SELECT ctipper
        INTO WRET
        FROM estper_personas p
       WHERE sperson = (SELECT e.sperson
                          FROM estassegurats e
                         WHERE sseguro = PSSEGURO);
      --Inicio IAXIS-3992 31/05/2019
      IF WRET = 1 THEN
        RETURN 1;
      END IF;

      SELECT ctipper
        INTO WRET
        FROM estper_personas p
       WHERE sperson = (SELECT e.sperson
                          FROM esttomadores e
                         WHERE sseguro = PSSEGURO);                       
      --Fin IAXIS-3992 31/05/2019
      -- Se activa cuando el asegurado es persona natural y el valor
      -- asegurado y/o cmulo superan los 500.000.000 millones de  de pesos col.
      IF WRET = 1 /*AND F_VALOR_MAX_ASEG(PSSEGURO) > 500000000*/ THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;

      PSU_TRACE('PAC_PSU_CONF','F_PERSONA_NATURAL','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_PERSONA_NATURAL','STEP:'||WSTEP||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_PERSONA_NATURAL;
   --
   /*************************************************************************
      FUNCTION F_DESC_COMERCIAL
      PSU 140 (801140) Descuento Comercial aplicado supera el mximo delegado
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_DESC_COMERCIAL( PSSEGURO IN NUMBER, PCGARANT IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
   BEGIN
      WSTEP := 10;
      SELECT crespue
        INTO WRET
        FROM estpregungaranseg
       WHERE sseguro = PSSEGURO
         AND cpregun = 6549
         AND cgarant = PCGARANT;

      PSU_TRACE('PAC_PSU_CONF','F_DESC_COMERCIAL','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_DESC_COMERCIAL','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_DESC_COMERCIAL;
   --
   /*************************************************************************
      FUNCTION F_MARCA_AUTORIZ
      PSU 145 (801145)Marcas Autorizacin
      param in p_sseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_MARCA_AUTORIZ( P_SSEGURO IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
	-- INI TCS-344 CJMR 18/02/2019
	w_nmarcas     NUMBER := 0;
-- IAXIS-3981.-- ECP --14/06/2019
	CURSOR c_personas IS
		SELECT p.spereal
		FROM estper_personas p
		WHERE sperson = (SELECT e.sperson
						 FROM esttomadores e
						 WHERE sseguro = P_SSEGURO)
		UNION
		SELECT p.spereal
		FROM estper_personas p
		WHERE sperson = (SELECT e.sperson
						 FROM estassegurats e
						 WHERE sseguro = P_SSEGURO)
        union
        SELECT p.spereal
		FROM estper_personas p
		WHERE sperson = (SELECT e.sperson
						 FROM esttomadores e
						 WHERE sseguro = P_SSEGURO)
		UNION
		select sperson from per_personas_rel 
        where sperson_rel = (SELECT p.spereal
		FROM estper_personas p
		WHERE sperson = (SELECT e.sperson
						 FROM estassegurats e
						 WHERE sseguro = P_SSEGURO)) 
        union
        select sperson from per_personas_rel 
        where sperson_rel = (SELECT p.spereal
		FROM estper_personas p
		WHERE sperson = (SELECT e.sperson
						 FROM esttomadores e
						 WHERE sseguro = P_SSEGURO)) ;

   BEGIN
      WSTEP := 10;

	  FOR r IN c_personas LOOP

		SELECT count(*)
		INTO w_nmarcas
		FROM agr_marcas am,
			 per_agr_marcas pam,
			 (SELECT cmarca, MAX(nmovimi) nmov
			  FROM per_agr_marcas
			  WHERE sperson = r.spereal
			  GROUP BY cmarca) max_mov
		WHERE pam.cmarca = am.cmarca
		AND pam.sperson = r.spereal
		AND max_mov.nmov = pam.nmovimi
		and max_mov.cmarca = pam.cmarca
		AND am.caacion = 0 ---PSU
		AND (pam.ctomador = 1 OR pam.cconsorcio = 1 OR pam.casegurado = 1 OR pam.ccodeudor = 1 OR pam.caccionista = 1
			 OR pam.cintermed = 1 OR pam.crepresen = 1 OR pam.capoderado = 1 OR pam.cpagador = 1 OR pam.cproveedor = 1);

		IF w_nmarcas > 0 THEN
			WRET := 1;
		END IF;

	  END LOOP;
	-- FIN TCS-344 CJMR 18/02/2019
-- IAXIS-3981.-- ECP --14/06/2019
      PSU_TRACE('PAC_PSU_CONF','F_MARCA_AUTORIZ','WRET:'||WRET||'; P_SSEGURO:'||P_SSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_MARCA_AUTORIZ','STEP:'||WSTEP||'; P_SSEGURO:'||P_SSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_MARCA_AUTORIZ;
   --
   /*************************************************************************
      FUNCTION F_REASEG_ESPECIAL
      PSU 150 (801150)Reaseguro Especial
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_REASEG_ESPECIAL( PSSEGURO IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
   BEGIN
      -- DETVALORES CVALOR = 74
      -- 0	Reaseguro habitual
      -- 1	No se reasegura (Back to back)
      -- 2	Facultativo Exclusivo
      WSTEP := 10;
      SELECT DECODE(CTIPREA, 0, 0, 1) INTO WRET FROM ESTSEGUROS WHERE SSEGURO = PSSEGURO;
      PSU_TRACE('PAC_PSU_CONF','F_REASEG_ESPECIAL','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_REASEG_ESPECIAL','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_REASEG_ESPECIAL;
   --
  /*************************************************************************
      FUNCTION PSU_TRACE
      return             : number
  *************************************************************************/
  PROCEDURE PSU_TRACE ( P1 IN VARCHAR2, P2 IN VARCHAR2, P3  IN VARCHAR2)IS
    WTRACE NUMBER := 0;
  BEGIN
    WTRACE := NVL( F_PARINSTALACION_N('PSU_TRACE'), 0);
    IF WTRACE != 0 THEN
      P_CONTROL_ERROR( P1, P2, P3);
    END IF;
  END PSU_TRACE ;
   --
   /*************************************************************************
      FUNCTION F_CAMBIO_ASEG_BENEF
      PSU 165 (801165) Cambio Asegurado y/o Beneficiario supera Nivel de Delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_CAMBIO_ASEG_BENEF( PSSEGURO IN NUMBER, PSSEGPOL IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
      FUNCTION F_CAMB_ASEG RETURN NUMBER IS
        WRET2          NUMBER := 0;
      BEGIN
        SELECT DECODE( COUNT(*), 0, 0, 1) INTO WRET2 FROM (
          SELECT E.SPEREAL
          FROM   ESTASSEGURATS T, ESTPER_PERSONAS E
          WHERE  T.SSEGURO = PSSEGURO
          AND    T.SPERSON=E.SPERSON
          minus
          SELECT SPERSON
          FROM   ASEGURADOS T
          WHERE  SSEGURO = PSSEGPOL
        );
        RETURN(WRET2);
      EXCEPTION
        WHEN OTHERS THEN
          PSU_TRACE('PAC_PSU_CONF','F_CAMB_ASEG','SQLERRM:'||SQLERRM);
          RETURN(1);
      END F_CAMB_ASEG;
      --
      FUNCTION F_CAMB_BENEF RETURN NUMBER IS
        WRET3          NUMBER := 0;
      BEGIN
         SELECT DECODE( COUNT(*), 0, 0, 1) INTO WRET3
         FROM (SELECT CGARANT, NVL(pac_persona.f_sperson_spereal(sperson), sperson), NVL(NVL(pac_persona.f_sperson_spereal(SPERSON_TIT), SPERSON_TIT), 0), CTIPBEN, CPAREN, PPARTICIP
                 FROM estbenespseg e
                WHERE sseguro = psseguro
               MINUS
               SELECT CGARANT, SPERSON, SPERSON_TIT, CTIPBEN, CPAREN, PPARTICIP
                 FROM benespseg
                WHERE  sseguro = pssegpol);
        RETURN(WRET3);
      EXCEPTION
        WHEN OTHERS THEN
          PSU_TRACE('PAC_PSU_CONF','F_CAMB_BENEF','SQLERRM:'||SQLERRM);
          RETURN(1);
      END F_CAMB_BENEF;

   BEGIN
      WSTEP := 10;
      --
      IF F_CAMB_ASEG > 0 OR F_CAMB_BENEF > 0 THEN
        WRET := 1;
      ELSE
        WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_CAMBIO_ASEG_BENEF','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO||'; PSSEGPOL:'||PSSEGPOL);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_CAMBIO_ASEG_BENEF','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; PSSEGPOL:'||PSSEGPOL||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_CAMBIO_ASEG_BENEF;
   --
   /*************************************************************************
      FUNCTION F_COBERTURA_RESTRINGA
      PSU 170 (801170) Cobertura/ Amparo Restringido o Prohibido aplicada supera Nivel de Delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_COBERTURA_RESTRINGA( PSSEGURO IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
   BEGIN
      WSTEP := 10;
      PSU_TRACE('PAC_PSU_CONF','F_COBERTURA_RESTRINGA','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_COBERTURA_RESTRINGA','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_COBERTURA_RESTRINGA;
   --
   /*************************************************************************
      FUNCTION F_VALIDA_DEDUCIBLE
      PSU 175 (801175) Deducibles aplicados deben ser validados
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VALIDA_DEDUCIBLE( --p_nsesion   IN NUMBER
                                 p_sseguro   IN NUMBER
                               , p_fecefe    IN NUMBER
                               , p_nmovimi   IN NUMBER
                               , p_nriesgo   IN NUMBER
                               , p_cgarant   IN NUMBER) RETURN NUMBER IS
      vpasexec NUMBER := 1;
      w_sproduc estseguros.sproduc%TYPE;
      w_cempres estseguros.cempres%TYPE;
      w_cactivi estseguros.cactivi%TYPE;
      w_ssegpol estseguros.ssegpol%TYPE;
      p_resultat NUMBER;
      xxsesion   NUMBER;
      v_error    NUMBER;
      w_conta    NUMBER;
      WSTEP      NUMBER := 0;
      WRETURN    NUMBER := 0;
      --
      CURSOR c_prod IS
            SELECT a.*
            FROM bf_progarangrup a
            WHERE a.sproduc = w_sproduc AND a.cgarant = p_cgarant AND a.codgrup IN
              (SELECT cgrup
              FROM bf_codgrup
              WHERE cempres = w_cempres AND cgrup = a.codgrup AND ctipgrup = 2
              );
      CURSOR C_EST (C_CODGRUP IN NUMBER)IS
            SELECT *
            FROM  estbf_bonfranseg
            WHERE sseguro = p_sseguro AND nriesgo = p_nriesgo AND nmovimi = p_nmovimi
            AND cgrup = C_CODGRUP
            AND   cnivel != ( SELECT max(cnivel) from BF_DETNIVEL
                              where cempres = w_cempres and cgrup = C_CODGRUP
                              and   cdefecto = 'S' )
            ;
      --
    BEGIN

      WSTEP := 10;
      SELECT sproduc, cempres, cactivi, ssegpol
      INTO w_sproduc, w_cempres, w_cactivi, w_ssegpol
      FROM estseguros
      WHERE sseguro = p_sseguro;
      --
      FOR R IN C_PROD LOOP
        -- se buscan todas las franquicias donde su cnivel es diferente al cnivel por defecto
        FOR I IN C_EST(R.CODGRUP) LOOP
          -- En Nueva Produccion solo con que su cnivel sea diferente al cnivel por defecto ya debe saltar la PSU
          IF p_nmovimi = 1 THEN  -- Nueva Produccion
            WRETURN := 1;
          ELSE                   -- suplemento
            SELECT COUNT (0)
            INTO w_conta
            FROM bf_bonfranseg a
            WHERE a.sseguro = w_ssegpol AND a.nriesgo = p_nriesgo AND a.nmovimi =
              (SELECT MAX (b.nmovimi)
              FROM bf_bonfranseg b
              WHERE b.sseguro         = a.sseguro AND b.nriesgo = a.nriesgo AND b.cgrup =
                a.cgrup AND b.nmovimi < p_nmovimi
              ) AND a.cgrup           = I.cgrup;
            --
            IF w_conta = 0 THEN
              -- Aix indica que el grup, en el moviment anterior no hi era i que per tant
              -- es nou i es te que comportar com si es tracts de Nova Prodcucci, i noms
              -- que en el cursor el trovi diferent el nivell de defecte amb el triat, ha de disparar-se la PSU.
              WRETURN := 1;
            END IF;
            SELECT COUNT (0)
            INTO w_conta
            FROM bf_bonfranseg a
            WHERE a.sseguro = w_ssegpol AND a.nriesgo = p_nriesgo
            AND a.nmovimi = ( SELECT MAX (b.nmovimi)
                              FROM bf_bonfranseg b
                              WHERE b.sseguro = a.sseguro AND b.nriesgo = a.nriesgo
                              AND b.cgrup = a.cgrup AND b.nmovimi < p_nmovimi
                            )
            AND a.cgrup = I.cgrup AND a.cnivel != I.cnivel;
            --
            -- Si hi ha registres vol dir que el nivell de franqucia no s el de defecte i que no s el que
            -- hi havia al movimnet d'abans. Aix implica que ha de saltar la PSU i per tant tornarem un 1
            --
            IF w_conta > 0 THEN
              WRETURN := 1;
            END IF;
          END IF;
        END LOOP;
        --
      END LOOP;
      PSU_TRACE('PAC_PSU_CONF','F_VALIDA_DEDUCIBLE','WRETURN:'||WRETURN||'; SSEGURO:'||P_SSEGURO||'; fecefe:'||p_fecefe||'; nmovimi:'||p_nmovimi||'; nriesgo:'||p_nriesgo||'; cgarant:'||p_cgarant);
      RETURN( WRETURN);
      --
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VALIDA_DEDUCIBLE','STEP:'||WSTEP||'; PSSEGURO:'||P_SSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VALIDA_DEDUCIBLE;
   --
   /*************************************************************************
      FUNCTION f_autoriz_gar
      PSU 170 (801170) Cobertura/Amparo Restringido o Prohibido supera Nivel de Delegacin
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_autoriz_gar(
      p_nsesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_sproduc      seguros.sproduc%TYPE;
      v_valor        NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER := 1;
      wnivelusu      NUMBER;
      FUNCTION haycambio(
         p_sseguro IN NUMBER,
         p_nriesgo IN NUMBER,
         p_cgarant IN NUMBER,
         p_nmovimi IN NUMBER)
         RETURN NUMBER IS
         w_cambio       NUMBER;
         w_ssegpol      estseguros.ssegpol%TYPE;
      BEGIN
         SELECT ssegpol
           INTO w_ssegpol
           FROM estseguros
          WHERE sseguro = p_sseguro;

         SELECT COUNT(1)
           INTO w_cambio
           FROM (SELECT 1
                   FROM estgaranseg
                  WHERE sseguro = p_sseguro
                    AND nmovimi = p_nmovimi
                    AND cobliga = 1
                    AND nriesgo = p_nriesgo
                    AND cgarant = p_cgarant
                 MINUS
                 SELECT 1
                   FROM garanseg
                  WHERE sseguro = w_ssegpol
                    AND nmovimi = (SELECT MAX(g2.nmovimi)
                                     FROM garanseg g2
                                    WHERE g2.nmovimi < p_nmovimi
                                      AND sseguro = w_ssegpol)
                    AND ffinefe IS NULL
                    AND nriesgo = p_nriesgo
                    AND cgarant = p_cgarant);

         RETURN w_cambio;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_psu_conf.f_autoriz_gar.haycambio', 1,
                        'p_sseguro = ' || p_sseguro || ', p_nriesgo = ' || p_nriesgo
                        || 'p_cgarant = ' || p_cgarant || 'p_nmovimi = ' || p_nmovimi,
                        SQLCODE || ' - ' || SQLERRM);
            RETURN 1;
      END haycambio;
   BEGIN
      PSU_TRACE('PAC_PSU_CONF','f_autoriz_gar','sseguro:'||p_sseguro||';nriesgo:'||p_nriesgo||';nriesgo:'||p_nriesgo||';cgarant:'||p_cgarant||';nmovimi:'||p_nmovimi);
      vpasexec := 10;
      num_err := pac_seguros.f_get_sproduc(p_sseguro, 'EST', v_sproduc);
      PSU_TRACE('PAC_PSU_CONF','f_autoriz_gar','v_sproduc:'||v_sproduc);
      vpasexec := 20;
      wnivelusu := pac_psu.f_nivel_usuari_psu(f_user, v_sproduc);
      PSU_TRACE('PAC_PSU_CONF','f_autoriz_gar','f_user:'||f_user||'; wnivelusu:'||wnivelusu);
      vpasexec := 30;
      IF p_cgarant IS NULL THEN
         FOR gar IN (SELECT cgarant
                       FROM estgaranseg
                      WHERE sseguro = p_sseguro
                        AND nriesgo = p_nriesgo
                        AND cobliga = 1) LOOP
            -- f_vsubtabla(NULL, 8000050, 333, 1, 8038, 7030,2540)
            v_valor := pac_subtablas.f_vsubtabla(p_nsesion, 8000050, 333, 1, v_sproduc, gar.cgarant, wnivelusu);

            IF v_valor > 0 THEN
               RETURN 1;
            END IF;
         END LOOP;
      ELSE
         IF haycambio(p_sseguro, p_nriesgo, p_cgarant, p_nmovimi) > 0 THEN
            v_valor := pac_subtablas.f_vsubtabla(p_nsesion, 8000050, 333, 1, v_sproduc,p_cgarant, wnivelusu);
            IF v_valor > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_psu_conf.f_autoriz_gar', vpasexec, 'p_sseguro = '
          ||p_sseguro||'; p_nriesgo = '||p_nriesgo||'; p_cgarant = ' || p_cgarant
          || '; p_nmovimi = ' || p_nmovimi,SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_autoriz_gar;
   -----------------------------------------------------------------------------
   --
   /*************************************************************************
      FUNCTION F_VIGENCIA_RC
      PSU 46 () Vigencia Productos Responsabilidad Civil
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIGENCIA_RC(psseguro IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WDIF          NUMBER := 0;
	VFVENCIM      DATE;--BARTOLO
    VFEFECTOSUMA      DATE;--BARTOLO
	
   BEGIN
      WSTEP := 10;
      --SELECT   FVENCIM - FEFECTO
      --INTO     WDIF
      --FROM     ESTSEGUROS
      --WHERE    SSEGURO = PSSEGURO;
      -- VIGENCIA GENERAL SUPERA LOS 1980 DIAS
      --IF WDIF > 1980 THEN
	  
	  SELECT   FVENCIM,ADD_MONTHS(FEFECTO, 60)--BARTOLO
      INTO     VFVENCIM, VFEFECTOSUMA
      FROM     ESTSEGUROS
      WHERE    SSEGURO = PSSEGURO;
      
      IF VFVENCIM > VFEFECTOSUMA THEN --BARTOLO
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIGENCIA_RC','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIGENCIA_RC','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIGENCIA_RC;
   --
   /*************************************************************************
      FUNCTION F_VIGENCIA_TRC
      PSU 46 () Vigencia Productos TODO RIESGO CONSTRUCCION
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIGENCIA_TRC(psseguro IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WDIF          NUMBER := 0;
   BEGIN
      WSTEP := 10;
      SELECT   FVENCIM - FEFECTO
      INTO     WDIF
      FROM     ESTSEGUROS
      WHERE    SSEGURO = PSSEGURO;
      -- VIGENCIA GENERAL SUPERA LOS 4 AOS ( 1460 DAS )
      IF WDIF > 1460 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIGENCIA_TRC','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIGENCIA_TRC','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIGENCIA_TRC;
   --
   /*************************************************************************
      FUNCTION F_VIGENCIA_TRDM
      PSU 46 () Vigencia Productos TODO RIESGO DAOS MATERIALES
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VIGENCIA_TRDM(psseguro IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WDIF          NUMBER := 0;
   BEGIN
      WSTEP := 10;
      SELECT   FVENCIM - FEFECTO
      INTO     WDIF
      FROM     ESTSEGUROS
      WHERE    SSEGURO = PSSEGURO;
      -- VIGENCIA GENERAL SUPERA LOS 720 DAS
      IF WDIF > 720 THEN
         WRET := 1;
      ELSE
         WRET := 0;
      END IF;
      PSU_TRACE('PAC_PSU_CONF','F_VIGENCIA_TRDM','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VIGENCIA_TRDM','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VIGENCIA_TRDM;
  --
  -- NMM.CONF-434.f
  --
   /*************************************************************************
      FUNCTION F_CUMULO_ASEG
      PSU 46 () Cmulo+valor asegurado supera nivel del perfil
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_CUMULO_ASEG(psseguro IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WSPERSON      NUMBER;
    WSPEREAL      NUMBER;
    v_monprod     monedas.cmonint%TYPE;
    v_producto   NUMBER;

   BEGIN
      WSTEP := 10;
      SELECT   SPERSON
      INTO     WSPERSON
      FROM     ESTTOMADORES
      WHERE    SSEGURO = PSSEGURO
      AND      NORDTOM=1;

      SELECT  SUM(ICAPITAL) INTO WRET
      FROM    ESTGARANSEG
      WHERE   SSEGURO = PSSEGURO
      AND     COBLIGA = 1;

      SELECT sproduc
        INTO v_producto
        FROM estseguros
       WHERE sseguro = PSSEGURO;
      --
      SELECT cmonint
        INTO v_monprod
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_monedas.f_moneda_producto(v_producto);

      SELECT SPEREAL
      INTO WSPEREAL
      FROM ESTPER_PERSONAS
      WHERE SPERSON = WSPERSON;

      WRET:= pac_eco_tipocambio.f_importe_cambio(v_monprod,'COP', f_sysdate, WRET);

      WRET := NVL(pac_isqlfor_conf.F_cumulo_persona(WSPEREAL), 0) + WRET;

      PSU_TRACE('PAC_PSU_CONF','F_CUMULO_ASEG','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_CUMULO_ASEG','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_CUMULO_ASEG;

   /*************************************************************************
      FUNCTION F_CUMULO_SUPERA_CLI
      PSU 46 () Cmulo+valor asegurado supera el cupo asignado al tomador
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_CUMULO_SUPERA_CLI(psseguro IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WCUMULO       NUMBER := 0;
    WCUPO         NUMBER := 0;
    WCTIPPER      NUMBER;
    WSPERSON      NUMBER;
    WSPEREAL      NUMBER;
    WSFINANCI     NUMBER;
   BEGIN
      WSTEP := 10;
      WCUMULO := NVL(F_CUMULO_ASEG(PSSEGURO),0);

      SELECT   SPERSON
      INTO     WSPERSON
      FROM     ESTTOMADORES
      WHERE    SSEGURO = PSSEGURO
      AND      NORDTOM=1;

      SELECT  CTIPPER, SPEREAL INTO WCTIPPER, WSPEREAL
      FROM    ESTPER_PERSONAS
      WHERE   SPERSON = WSPERSON;

      BEGIN
        SELECT SFINANCI
          INTO WSFINANCI
          FROM FIN_GENERAL
         WHERE SPERSON = WSPEREAL;

        IF WCTIPPER = 1 THEN --NATURAL
          SELECT ICUPOG
          INTO WCUPO
          FROM FIN_ENDEUDAMIENTO
          WHERE SFINANCI = WSFINANCI;
        ELSE  --2 JURIDICA
          SELECT ICUPOG
          INTO WCUPO
          FROM FIN_INDICADORES
          WHERE SFINANCI = WSFINANCI;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          RETURN 0;
      END;

      IF WCUMULO > WCUPO THEN
        WRET := 1;
      ELSE
        WRET := 0;
      END IF;

      PSU_TRACE('PAC_PSU_CONF','F_CUMULO_SUPERA_CLI','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_CUMULO_SUPERA_CLI','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_CUMULO_SUPERA_CLI;

   /*************************************************************************
      FUNCTION F_VALIDA_CESION
      PSU () Devuelve la cesin si el coaseguro es cedido
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_VALIDA_CESION(psseguro IN NUMBER) RETURN NUMBER IS
    WRET          NUMBER := 0;
    WSTEP         NUMBER := 0;
    WCTIPCOA      NUMBER := 0;

   BEGIN
      WSTEP := 10;

      SELECT   CTIPCOA
      INTO     WCTIPCOA
      FROM     ESTSEGUROS
      WHERE    SSEGURO = PSSEGURO;

      IF WCTIPCOA = 1 THEN
        SELECT PLOCCOA
          INTO WRET
          FROM ESTCOACUADRO
         WHERE SSEGURO = PSSEGURO
           AND NCUACOA = (SELECT MAX(NCUACOA) FROM ESTCOACUADRO WHERE SSEGURO = PSSEGURO);
      ELSE
        WRET := 0;
      END IF;

      PSU_TRACE('PAC_PSU_CONF','F_VALIDA_CESION','WRET:'||WRET||'; PSSEGURO:'||PSSEGURO);
      RETURN( WRET);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_VALIDA_CESION','STEP:'||WSTEP||'; PSSEGURO:'||PSSEGURO||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_VALIDA_CESION;

   --CONF-747 Inicio
   --
   /*************************************************************************
      FUNCTION f_max_coasegurador
      PSU 804340 Mximo nmero permitido de Coaseguradores
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_MAX_COASEGURADOR( psseguro IN NUMBER) RETURN NUMBER IS
    wret          NUMBER := 0;
    wstep         NUMBER := 0;
    wmaxcoa       NUMBER := 0;
    wcont         NUMBER := 0;
    wsproduc      seguros.sproduc%TYPE;
    wctipcoa      seguros.ctipcoa%TYPE;
   BEGIN
      wstep := 10;

      BEGIN
         SELECT sproduc, ctipcoa
           INTO wsproduc, wctipcoa
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            SELECT sproduc, ctipcoa
              INTO wsproduc, wctipcoa
              FROM seguros
             WHERE sseguro = psseguro;

         WHEN OTHERS THEN
            wret := -1;
      END;

      --Se valida si es Coaseguro cedido
      IF wctipcoa = 1 THEN

        wmaxcoa := pac_parametros.f_parproducto_n(wsproduc, 'NUMMAXCOASEG');
        --Inicio IAXIS-3992 31/05/2019
        BEGIN
                SELECT COUNT(DISTINCT ccompan)
                  INTO wcont
                  FROM estcoacedido
                 WHERE sseguro = psseguro;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                SELECT COUNT(DISTINCT ccompan)
                  INTO wcont
                  FROM coacedido
                 WHERE sseguro = psseguro;
                
            WHEN OTHERS THEN
                wret := -1;
        END;
        --Fin IAXIS-3992 31/05/2019
        IF wcont > NVL(wmaxcoa,0) THEN

           wret := 1;

        END IF;

        PSU_TRACE('PAC_PSU_CONF','F_MAX_COASEGURADOR','WRET:'||wret||'; PSSEGURO:'||psseguro);

      END IF;

      RETURN( wret);
   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_MAX_COASEGURADOR','STEP:'||wstep||'; PSSEGURO:'||psseguro||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_MAX_COASEGURADOR;
   --
   --CONF-747 Fin
   /*************************************************************************
      FUNCTION f_riesgo_restringido

      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_riesgo_restringido(psseguro IN NUMBER) RETURN NUMBER IS
      vpasexec  NUMBER := 0;
      vobject   VARCHAR2(200) := 'pac_psu_conf.f_riesgo_restringido';
      vparam    VARCHAR2(500) := 'psseguro: '||psseguro;
      v_sproduc seguros.sproduc%TYPE;
      v_clascont detclasecontrato.ccodcontrato%TYPE;
      v_nval1 sgt_subtabs_det.nval1%TYPE;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM estseguros
       WHERE sseguro = psseguro;

      SELECT crespue
        INTO v_clascont
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND cpregun = 2880;

      SELECT nval1
        INTO v_nval1
        FROM sgt_subtabs_det
       WHERE csubtabla = 8000045
         AND ccla1 = v_sproduc
         AND ccla2 = v_clascont;

      RETURN( NVL(v_nval1, 0));
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
       BEGIN
          SELECT sproduc
            INTO v_sproduc
            FROM seguros
           WHERE sseguro = psseguro;

          SELECT crespue
            INTO v_clascont
            FROM pregunseg
           WHERE sseguro = psseguro
             AND cpregun = 2880;

          SELECT nval1
            INTO v_nval1
            FROM sgt_subtabs_det
           WHERE csubtabla = 8000045
             AND ccla1 = v_sproduc
             AND ccla2 = v_clascont;

          RETURN( NVL(v_nval1, 0));

      EXCEPTION
         WHEN OTHERS THEN
            p_control_error('pac_psu_conf', 'f_riesgo_restringido','4.-others'||v_nval1||';vparam:'||vparam||' ;sqlerrm'||SQLERRM);
        RETURN( 0);
      END;
    WHEN OTHERS THEN
      p_control_error('pac_psu_conf', 'f_riesgo_restringido','5.-others'||v_nval1||';vparam:'||vparam||' ;sqlerrm'||SQLERRM);
      RETURN( 0);
   END f_riesgo_restringido;

   --CONF-910 Inicio
   --
   /*************************************************************************
      FUNCTION f_fecha_fin_rea
      PSU 804345 Negocio con fecha mayor a fecha fin del contrato de reaseguro
      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION F_FECHA_FIN_REA(psseguro  IN NUMBER) RETURN NUMBER IS
    wret          NUMBER := 0;
    wstep         NUMBER := 0;
    wmaxcoa       NUMBER := 0;
    wcont         NUMBER := 0;
    wscontra      cesionesrea.scontra%TYPE;
    wnversio      cesionesrea.nversio%TYPE;
    wfefecto      seguros.fefecto%TYPE;
    wfconfin      contratos.fconfin%TYPE;
    wctiprea      seguros.ctiprea%TYPE;
    wcempres      seguros.cempres%TYPE;
    wcramo        seguros.cramo%TYPE;
    wcmodali      seguros.cmodali%TYPE;
    wctipseg      seguros.ctipseg%TYPE;
    wccolect      seguros.ccolect%TYPE;
    wcactivi      seguros.cactivi%TYPE;
    v_ipleno      NUMBER;
    v_icapaci     NUMBER;
    v_cdetces     NUMBER;
   BEGIN
      wstep := 11;

      --p_busca_val_tab(psseguro);

      BEGIN
         SELECT ctiprea, fefecto, cramo, cmodali, ctipseg, ccolect, cactivi, cempres
           INTO wctiprea, wfefecto, wcramo, wcmodali, wctipseg, wccolect, wcactivi, wcempres
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            SELECT ctiprea, fefecto, cramo, cmodali, ctipseg, ccolect, cactivi, cempres
              INTO wctiprea, wfefecto, wcramo, wcmodali, wctipseg, wccolect, wcactivi, wcempres
              FROM seguros
             WHERE sseguro = psseguro;

         WHEN OTHERS THEN
            wret := -1;
      END;

      BEGIN
         SELECT DISTINCT r.scontra, r.nversio
           INTO wscontra, wnversio
           FROM reariesgos r
          WHERE r.sseguro = psseguro;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            wret:= f_buscacontrato(psseguro,
                                   wfefecto,
                                   wcempres,
                                   NULL,
                                   wcramo,
                                   wcmodali,
                                   wctipseg,
                                   wccolect,
                                   wcactivi,
                                   2,
                                   wscontra,
                                   wnversio,
                                   v_ipleno,
                                   v_icapaci,
                                   v_cdetces);

         WHEN OTHERS THEN
            wret := -1;
      END;

      --Se valida la fecha fin del contrato
      IF wscontra IS NOT NULL
        AND wnversio IS NOT NULL THEN

        SELECT c.fconfinaux
          INTO wfconfin
          FROM contratos c
         WHERE scontra = wscontra
           AND nversio = wnversio;

        IF wfconfin IS NOT NULL
          AND wfefecto > wfconfin THEN

           wret := 1;

        END IF;

        PSU_TRACE('PAC_PSU_CONF','F_FECHA_FIN_REA','WRET:'||wret||'; PSSEGURO:'||psseguro);

      END IF;

      RETURN( wret);

   EXCEPTION
      WHEN OTHERS THEN
         PSU_TRACE('PAC_PSU_CONF','F_FECHA_FIN_REA','STEP:'||wstep||'; PSSEGURO:'||psseguro||'; SQLERRM:'||SQLERRM);
         RETURN( -1);
   END F_FECHA_FIN_REA;
   --
   --CONF-910 Fin
-- Inicio IAXIS-2421 04/03/2019
   FUNCTION f_valida_regimen (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      vcagente      NUMBER := 0;
      vsperson      NUMBER := 0;
      vcregfiscal   NUMBER := 0;
      vitasa        NUMBER := 0;
      vicombru      NUMBER := 0;
      vprima        NUMBER;
      vfusumod      DATE;
      vfecha        NUMBER := 0;
      vdias         NUMBER := 15;
   BEGIN

      BEGIN
         SELECT s.cagente
           INTO vcagente
           FROM estseguros s
          WHERE s.sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN

           return 1;
      END;


      BEGIN
         SELECT sperson, fusumod, round(f_sysdate - nvl(fusumod,falta))
           INTO vsperson, vfusumod, vfecha
           FROM agentes
          WHERE cagente = vcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 1;
      END;

      BEGIN
         SELECT cregfiscal
           INTO vcregfiscal
           FROM per_regimenfiscal a
          WHERE a.sperson = vsperson
            AND a.fefecto =
                     (SELECT MAX (b.fefecto)
                        FROM per_regimenfiscal b
                       WHERE b.sperson = a.sperson AND b.fefecto <= f_sysdate);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
           vcregfiscal:= 0;
      END;


      IF (vcregfiscal = 2)
      THEN
         BEGIN
            SELECT itasa
              INTO vitasa
              FROM eco_tipocambio a
             WHERE UPPER (LTRIM (RTRIM (a.cmonori))) = 'TPS'
               AND a.fcambio =
                      (SELECT MAX (b.fcambio)
                         FROM eco_tipocambio b
                        WHERE b.cmonori = a.cmonori AND b.fcambio <= f_sysdate);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              vitasa := 0;
         END;

         BEGIN
            SELECT nvl(SUM (c.icombru),0)
              INTO vicombru
              FROM recibos a, movrecibo b, vdetrecibos c
             WHERE a.sseguro IN (SELECT d.sseguro
                                   FROM seguros d
                                  WHERE d.cagente = vcagente)
               AND a.nrecibo = b.nrecibo
               AND b.nrecibo = c.nrecibo
               AND b.cestrec = 1
               AND b.fmovfin IS NULL
               AND b.fmovini >= to_date('01/01'||to_char(f_sysdate, 'yyyy'),'dd/mm/yyyy')
               AND b.fmovini <= f_sysdate;

         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              vicombru:= 0;

         END;





           if vfecha = 0 then
           vfecha := 1;
           end if;




         IF (vicombru > vitasa)
         THEN

            IF (vfecha >= vdias)
            THEN
               UPDATE agentes
                  SET cactivo = 7
                WHERE cagente = vcagente;


            ELSE
               UPDATE agentes
                  SET cactivo = 6
                WHERE cagente = vcagente;


            END IF;


            commit;

            PAC_CORREO.P_CAMBIO_REGIMEN(vcagente);



            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      ELSE
         RETURN 0;
      END IF;

   EXCEPTION
      WHEN OTHERS 

      THEN
         p_control_error ('pac_psu_conf',
                          'f_valida_regimen',
                           ' ;sqlerrm'
                          || SQLERRM
                         );
         RETURN (0);
   END f_valida_regimen;
   -- Fin IAXIS-2421 04/03/2019

----
-- INICIO IAXIS-3186 03/04/2019

   FUNCTION f_valida_convenio (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      vcagente      NUMBER         := 0;
      vsperson      NUMBER         := 0;
      vspersonr     NUMBER         := 0;
      vcregfiscal   NUMBER         := 0;
      vitasa        NUMBER         := 0;
      vicombru      NUMBER         := 0;
      vprima        NUMBER;
      vfusumod      DATE;
      vfecha        NUMBER         := 0;
      vtbuscar      VARCHAR2 (250);
      vexiste       NUMBER (1);
   BEGIN
      BEGIN
         SELECT s.cagente
           INTO vcagente
           FROM estseguros s
          WHERE s.sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 1;
      END;

      BEGIN
         SELECT a.sperson, b.tbuscar
           INTO vsperson, vtbuscar
           FROM estassegurats a, estper_detper b
          WHERE sseguro = psseguro
          and a.sperson = b.sperson;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      END;

      BEGIN
         SELECT sperson
           INTO vspersonr
           FROM per_detper
          WHERE tbuscar = vtbuscar;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      END;

      BEGIN
         SELECT count(1)
           INTO vexiste
           FROM convcomesptom a
          WHERE a.sperson = vspersonr;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
             vexiste :=0;
      END;

      if vexiste > 0 then
        RETURN 1;
      else
       RETURN 0;
      end if;
      
   EXCEPTION
      WHEN OTHERS
      THEN
         p_control_error ('pac_psu_conf',
                          'f_valida_convenio',
                          ' ;sqlerrm' || SQLERRM
                         );
         RETURN (0);
   END f_valida_convenio;

-- FIN IAXIS-3186 03/04/2019

END pac_psu_conf;