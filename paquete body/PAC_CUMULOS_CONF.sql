/* Formatted on 2020/02/27 12:45 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY pac_cumulos_conf
AS
    /******************************************************************************
         NOMBRE:       PAC_CUMULOS_CONF
         PROPSITO:  Funciones para gestionar los cumulos del tomador

         REVISIONES:
         Ver        Fecha        Autor   Descripcin
        ---------  ----------  ------   ------------------------------------
         1.0        16/02/2017   HRE     1. Creacin del package.
         2.0        06/07/2019   ECP     2.IAXIS-4209. Cmulo en Riesgo
         3.0        06/09/2019   FEPP    3.IAXIS-4773. CUMULOS
         4.0        21/10/2019   ECP     4.IAXIS-5353 Cesi[on Cumulos Depurados
         5.0        25/10/2019   ECP     5.IAXIS-4785. Cumulo Depurado y ajustes a pantalla axisrea052
         6.0        20/11/2019   ECP     6.IAXIS-5353.CESION CUMULOS depurados
         7.0        12/12/2019   ECP     5.IAXIS-4785. Cumulo Depurado y ajustes a pantalla axisrea052
         8.0        13/01/2020   DFR     6.IAXIS-5353: CESION CUMULOS depurados
         9.0        05/02/2020   DFR     9.IAXIS-11903: Anulacin de pliza
        10.0        13/02/2020   DFR    10.IAXIS-11903: Anulacin de pliza
        11.0        27/02/2020   ECP    11. IAXIS-4785. Ajustes Cúmulos
        12.0        27/04/2020   DFR    12.IAXIS-12992: Cesión en contratos con más de un tramo
   ******************************************************************************//*************************************************************************
     FUNCTION f_set_depuracion_manual
     Permite generar el registro de depuracion manual
     param in pfcorte        : Fecha de corte
     param in ptcumulo       : Tipo de cumulo
     param in pnnumide       : Documento del tomador
     param out mensajes      : mesajes de error
     return                  : number
    *************************************************************************/
   FUNCTION f_set_depuracion_manual (
      psseguro   IN   NUMBER,
      pcgenera   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pindicad   IN   VARCHAR2,
      pvalor     IN   NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec       NUMBER (8)      := 1;
      vparam         VARCHAR2 (2000)
         :=    'psseguro='
            || psseguro
            || ' pcgenera='
            || pcgenera
            || ' pcgarant='
            || pcgarant
            || ' pindicad='
            || pindicad
            || ' pvalor='
            || pvalor;
      vobject        VARCHAR2 (200)
                                 := 'pac_cumulos_conf.f_set_depuracion_manual';
      v_pordepu      NUMBER;
      v_tot_depu     NUMBER;                        --valor  total por depurar
      w_sdetcesrea   NUMBER;
      salir          EXCEPTION;
      v_movidep      NUMBER          := 0;

      CURSOR cur_tot_por_depurar
      IS
         SELECT SUM (DECODE (NVL (cdepura, 'N'), 'N', icapces, -icapces))
           FROM det_cesionesrea dces
          WHERE sseguro = psseguro
            AND cgarant = pcgarant
            AND dces.nmovimi = (SELECT MAX (nmovimi)
                                  FROM det_cesionesrea dces2
                                 WHERE dces.sseguro = dces2.sseguro)
            AND (   dces.nmovidep =
                       (SELECT MAX (nmovidep)
                          FROM det_cesionesrea dces3
                         WHERE dces.sseguro = dces3.sseguro
                           AND dces.cgarant = dces3.cgarant)
                 OR dces.nmovidep = 1
                )
            AND EXISTS (
                   SELECT 'x'
                     FROM cesionesrea ces
                    WHERE ces.sseguro = dces.sseguro
                      AND cgenera = pcgenera
                      AND dces.scesrea = ces.scesrea);

      CURSOR cur_det_cesiones
      IS
         SELECT scesrea, nmovimi, ptramo, cgarant, icesion, icapces,
                psobreprima, iextrap, iextrea, ipritarrea, itarifrea, icomext,
                ccompani, sperson
           FROM det_cesionesrea dces
          WHERE sseguro = psseguro
            AND cgarant = pcgarant
            AND NVL (cdepura, 'N') = 'N'
            AND dces.nmovimi = (SELECT MAX (nmovimi)
                                  FROM det_cesionesrea dces2
                                 WHERE dces.sseguro = dces2.sseguro)
            AND EXISTS (
                   SELECT 'x'
                     FROM cesionesrea ces
                    WHERE ces.sseguro = dces.sseguro
                      AND cgenera = pcgenera
                      AND dces.scesrea = ces.scesrea);

      CURSOR cur_total_garantia
      IS
         SELECT NVL (SUM (icapces), 0)
           FROM det_cesionesrea dces, tomadores tom
          WHERE dces.sseguro = psseguro
            AND dces.cgarant = pcgarant
            AND tom.sseguro = dces.sseguro
            AND tom.sperson = dces.sperson
            AND tom.sperson = 1
            AND dces.nmovidep = 1
            AND dces.nmovimi = (SELECT MAX (nmovimi)
                                  FROM det_cesionesrea dces2
                                 WHERE dces.sseguro = dces2.sseguro)
            AND EXISTS (
                   SELECT 'x'
                     FROM cesionesrea ces
                    WHERE ces.sseguro = dces.sseguro
                      AND cgenera = pcgenera
                      AND dces.scesrea = ces.scesrea);
   BEGIN
      OPEN cur_tot_por_depurar;

      FETCH cur_tot_por_depurar
       INTO v_tot_depu;

      CLOSE cur_tot_por_depurar;

      IF (v_tot_depu <= 0)
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RAISE salir;
      END IF;

      vpasexec := 2;

      OPEN cur_total_garantia;

      FETCH cur_total_garantia
       INTO v_tot_depu;

      CLOSE cur_total_garantia;

      -- Ini IAXIS-4785 -- ECP -- 27/02/2020
      IF v_tot_depu = 0
      THEN
         v_tot_depu := 100;
      END IF;

      -- Fin IAXIS-4785 -- ECP -- 27/02/2020
      IF (pindicad = 'P')
      THEN
         v_pordepu := pvalor / 100;
      ELSE
         v_pordepu := pvalor / v_tot_depu;
      END IF;

      SELECT NVL (MAX (nmovidep), 0) + 1
        INTO v_movidep
        FROM det_cesionesrea
       WHERE sseguro = psseguro;

      FOR rg_det_cesiones IN cur_det_cesiones
      LOOP
         SELECT sdetcesrea.NEXTVAL
           INTO w_sdetcesrea
           FROM DUAL;

         INSERT INTO det_cesionesrea
                     (scesrea, sdetcesrea, sseguro,
                      nmovimi, ptramo,
                      cgarant, icesion,
                      icapces,
                      pcesion,
                      psobreprima,
                      iextrap,
                      iextrea,
                      ipritarrea,
                      itarifrea,
                      icomext,
                      ccompani, falta, cusualt, fmodifi,
                      cusumod, cdepura, fefecdema, nmovidep, sperson
                     )
              VALUES (rg_det_cesiones.scesrea, w_sdetcesrea, psseguro,
                      rg_det_cesiones.nmovimi, rg_det_cesiones.ptramo,
                      pcgarant, rg_det_cesiones.icesion * v_pordepu,
                      rg_det_cesiones.icapces * v_pordepu,
                      (rg_det_cesiones.icapces * v_pordepu / v_tot_depu
                      ) * 100,
                      rg_det_cesiones.psobreprima * v_pordepu,
                      rg_det_cesiones.iextrap * v_pordepu,
                      rg_det_cesiones.iextrea * v_pordepu,
                      rg_det_cesiones.ipritarrea * v_pordepu,
                      rg_det_cesiones.itarifrea * v_pordepu,
                      rg_det_cesiones.icomext * v_pordepu,
                      rg_det_cesiones.ccompani, f_sysdate, f_user, NULL,
                      NULL, 'S', f_sysdate, v_movidep, rg_det_cesiones.sperson
                     );
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             vobject,
             vpasexec,
             'No se puede depurar la garntia, ya ha sido depurada completamente',
             SQLERRM
            );
         RETURN 9910739;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_cumulos_conf.f_set_depuracion_manual',
                      1,
                      'error al insertar, no controlado',
                      SQLERRM
                     );
         RETURN 1;
   END f_set_depuracion_manual;

-- Ini AXIS-5353  -- 30/10/2019
-- Ini IAXIS-4785 -- 25/10/2019
-- Ini IAXIS-4785 -- 24/07/2019
   /*************************************************************************
    FUNCTION f_calcula_depura_auto
    Permite obtener por poliza y garantia el valor de la depuracion automatica
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param in pmodo          : modo (Alta, consulta)
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_depura_auto (
      pfcorte    IN   DATE,
      psseguro   IN   NUMBER,
      pcgarant   IN   NUMBER,
      psperson   IN   NUMBER,
      ptablas    IN   VARCHAR2 DEFAULT 'POL',
      pmodo      IN   VARCHAR2 DEFAULT 'ALTA' -- IAXIS-11903 05/02/2020
   )
      RETURN NUMBER
   IS
      vpasexec        NUMBER (8)               := 1;
      vparam          VARCHAR2 (2000)
         :=    'pfcorte='
            || pfcorte
            || '-psseguro='
            || psseguro
            || '-pcgarant='
            || pcgarant
            || '-psperson='
            || psperson
            || '-ptablas='
            || ptablas
            || '-pmodo=' 
            || pmodo;
      vobject         VARCHAR2 (200)
                                := 'pac_md_cumulos_conf.f_calcula_depura_auto';
      terror          VARCHAR2 (200)           := 'Error obtener cumulos';
      rg_gar_cump     garanseg%ROWTYPE;
      rg_garantia     garanseg%ROWTYPE;
      v_consorcio     VARCHAR2 (1);
      v_tomador       tomadores.sperson%TYPE;
      v_participa     NUMBER;
      v_depuaut       NUMBER;
      vcoaseguro      NUMBER                   := 0;
      v_sseguro       NUMBER;
      v_contract      NUMBER                   := 0;
      v_nocontra      NUMBER                   := 0;
      v_npoliza       NUMBER;
      v_depu_tot      NUMBER                   := 0;
      v_depuaut_mon   NUMBER                   := 0;
      v_monprod       VARCHAR2 (3);
      v_moninst       VARCHAR2 (3);
      v_sproduc       NUMBER;
      v_cactivi       NUMBER;
      v_scesrea       NUMBER;
      v_salario       NUMBER                   := 0;      
    

      CURSOR cur_participa (
         ppercons     per_personas.sperson%TYPE,
         pconsorcio   VARCHAR2
      )
      IS
      SELECT pparticipacion
           FROM per_personas_rel
          WHERE sperson = ppercons
            AND sperson_rel = psperson
            AND ctipper_rel = 0
            --AND pconsorcio = 'S'
            ;

        
      CURSOR cur_pol_tom
      IS
         SELECT a.sseguro,
               b.sperson,
               b.sperson sperson_rel,
               100 participacion,
               a.npoliza,
               a.sproduc,
               a.cactivi,
               ces.scesrea,
               'N' consorcio
          FROM seguros a, tomadores b, cesionesrea ces
         WHERE b.sperson = psperson
           AND a.sseguro = nvl(psseguro, a.sseguro)
           AND a.sseguro = b.sseguro
           AND a.sseguro = ces.sseguro
           AND (ces.fregula > pfcorte OR ces.fregula IS NULL)
           AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
           AND ces.ctramo IN (0, 5)
           AND ces.scesrea =
               (SELECT MAX(ces1.scesrea)
                  FROM cesionesrea ces1
                 WHERE ces1.sseguro = ces.sseguro
                   AND trunc(ces1.fgenera) <= pfcorte
                   AND ces1.cgenera <> 2)
                   union
           SELECT a.sseguro,
               p.sperson_rel,
               p.sperson,
               p.PPARTICIPACION participacion,
               a.npoliza,
               a.sproduc,
               a.cactivi,
               ces.scesrea,
               'S' consorcio
          FROM seguros a, tomadores b, cesionesrea ces, per_personas_rel p
         WHERE p.sperson = b.sperson
           and p.sperson_rel = psperson
           and p.ctipper_rel in (0,3)
           and p.cagrupa = b.cagrupa
           AND a.sseguro = nvl(psseguro, a.sseguro)
           AND a.sseguro = b.sseguro
           AND a.sseguro = ces.sseguro
           AND (ces.fregula > pfcorte OR ces.fregula IS NULL)
           AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
           AND ces.ctramo IN (0, 5)
           AND ces.scesrea =
               (SELECT MAX(ces1.scesrea)
                  FROM cesionesrea ces1
                 WHERE ces1.sseguro = ces.sseguro
                   AND trunc(ces1.fgenera) <= pfcorte
                   AND ces1.cgenera <> 2)
             ;

      CURSOR c_garan
      IS
         SELECT gar.cgarant, gar.icapital
           FROM garanseg gar, det_cesionesrea dce
          WHERE gar.sseguro = v_sseguro
            AND gar.sseguro = dce.sseguro
            AND gar.cgarant = dce.cgarant
            AND TRUNC (dce.falta) <= pfcorte
            AND dce.scesrea = v_scesrea
            AND gar.cgarant = NVL (pcgarant, gar.cgarant)
            AND gar.icapital IS NOT NULL
            AND ffinefe IS NULL
                               --and dce.scesrea = (select max(dce1.scesrea) from det_cesionesrea dce1 where dce1.sseguro = dce.sseguro)
      ;          
      -- 
      -- Inicio IAXIS-11903 05/02/2020
      --
      -- Cursores para el modo consulta.
      --
      CURSOR cur_pol_tom_con
      IS
              SELECT a.sseguro,
               b.sperson,
               b.sperson sperson_rel,
               100 participacion,
               a.npoliza,
               a.sproduc,
               a.cactivi,
               ces.scesrea,
               'N' consorcio
          FROM seguros a, tomadores b, cesionesrea ces
         WHERE b.sperson = psperson
           AND a.sseguro = nvl(psseguro, a.sseguro)
           AND a.sseguro = b.sseguro
           AND a.sseguro = ces.sseguro
           AND (ces.fregula > pfcorte OR ces.fregula IS NULL)
           AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
           AND ces.ctramo IN (0, 5)
           AND ces.scesrea =
               (SELECT MAX(ces1.scesrea)
                  FROM cesionesrea ces1
                 WHERE ces1.sseguro = ces.sseguro
                   AND trunc(ces1.fgenera) <= pfcorte
                   AND ces1.cgenera <> 2)
                   union
           SELECT a.sseguro,
               p.sperson_rel,
               p.sperson,
               p.PPARTICIPACION participacion,
               a.npoliza,
               a.sproduc,
               a.cactivi,
               ces.scesrea,
               'S' consorcio
          FROM seguros a, tomadores b, cesionesrea ces, per_personas_rel p
         WHERE p.sperson = b.sperson
           and p.sperson_rel = psperson
           and p.ctipper_rel in (0,3)
           and p.cagrupa = b.cagrupa
           AND a.sseguro = nvl(psseguro, a.sseguro)
           AND a.sseguro = b.sseguro
           AND a.sseguro = ces.sseguro
           AND (ces.fregula > pfcorte OR ces.fregula IS NULL)
           AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
           AND ces.ctramo IN (0, 5)
           AND ces.scesrea =
               (SELECT MAX(ces1.scesrea)
                  FROM cesionesrea ces1
                 WHERE ces1.sseguro = ces.sseguro
                   AND trunc(ces1.fgenera) <= pfcorte
                   AND ces1.cgenera <> 2)
             ;

      CURSOR c_garan_con
      IS
        SELECT gar.cgarant, gar.icapital, gar.nmovimi, ces.cgenera
          FROM garanseg gar, det_cesionesrea dce, cesionesrea ces
         WHERE gar.sseguro = v_sseguro
           AND gar.sseguro = dce.sseguro
           AND gar.cgarant = dce.cgarant
           AND dce.scesrea = v_scesrea
           AND ces.scesrea = dce.scesrea
           AND ces.cgenera <> 6
           AND gar.nmovimi = dce.nmovimi
           AND trunc(ces.fgenera) <= pfcorte
           AND gar.cgarant = nvl(pcgarant, gar.cgarant)
           AND gar.icapital IS NOT NULL;
      -- 
      -- Fin IAXIS-11903 05/02/2020
      --         
   BEGIN 
   p_tab_error(f_sysdate, f_user, 'PAC_CUMULOS_CONF', NULL,'AABG PAC_CUMULOS_CONF 408',
                         'Inicio cumulos,
                     vparam:' || vparam);
      BEGIN
         SELECT cmonint
           INTO v_moninst
           FROM monedas
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_moninst := 'COP';
      END;

      IF ptablas = 'POL'
      THEN
        --
        -- Inicio IAXIS-11903 03/02/2020
        --
        -- Si el modo es 'ALTA', dejamos que calcule tal y como se ha venido haciendo hasta el momento.
        --
        IF pmodo = 'ALTA' THEN
          FOR i IN cur_pol_tom
             LOOP
                v_tomador := i.sperson;
                v_sseguro := i.sseguro;
                v_sproduc := i.sproduc;
                v_cactivi := i.cactivi;
                v_scesrea := i.scesrea;			
    --            p_traza_proceso
    --                        (24,
    --                         'TRAZA_CESIONES_REA',
    --                         777,
    --                         'PAC_CUMULOS_CONF',
    --                         'f_calcula_depura_auto',
    --                         NULL,
    --                         3,
    --                            'Error: paso 1,
    --                     psperson:  '
    --                         || psperson
    --                         || ' v_tomador'
    --                         || v_tomador
    --                         || ' v_sseguro:'
    --                         || v_sseguro
    --                         || '  v_sproduc:'
    --                         || v_sproduc
    --                         || 'v_sproduc:'
    --                         || v_sproduc
    --                         || 'v_cactivi:'
    --                         || v_cactivi
    --                         ||'v_scesrea:'
    --                         ||v_scesrea
    --                        );

                BEGIN
                   SELECT NVL (c.ploccoa / 100, 0)
                     INTO vcoaseguro
                     FROM seguros s, coacuadro c
                    WHERE s.sseguro = c.sseguro
                      AND s.ctipcoa = 1
                      AND c.ncuacoa = (SELECT MAX (ncuacoa)
                                         FROM coacuadro
                                        WHERE sseguro = s.sseguro)
                      AND s.sseguro = v_sseguro;
                EXCEPTION
                   WHEN OTHERS
                   THEN
                      vcoaseguro := 0;
                END;				

                IF vcoaseguro <> 0
                THEN
                   vcoaseguro := vcoaseguro;
                ELSE
                   vcoaseguro := 1;
                END IF;

                v_contract := 0;
                v_nocontra := 0;
                v_salario := 0;
			

                FOR j IN c_garan
                LOOP
                   IF j.cgarant <> 7005
                   THEN
                      IF NVL
                            (pac_iaxpar_productos.f_get_pargarantia
                                                                 ('EXCONTRACTUAL',
                                                                  v_sproduc,
                                                                  j.cgarant,
                                                                  v_cactivi
                                                                 ),
                             0
                            ) <> 2
                      THEN
                         v_contract :=
                                   v_contract
                                   + (NVL (j.icapital, 0) * vcoaseguro);									   
                      ELSE
                         v_nocontra :=
                                   v_nocontra
                                   + (NVL (j.icapital, 0) * vcoaseguro);									   
                      END IF;
                   ELSE
                      v_salario := (NVL (j.icapital, 0) * vcoaseguro);						  
                   END IF;
                END LOOP;

                IF v_contract >= v_nocontra
                THEN
                   v_depuaut := v_nocontra;				   
                ELSE
                   v_depuaut := v_contract;				   
                END IF;
                -- Ini IAXIS-4785 -- 12/12/2019
                v_depuaut := v_depuaut; --+ v_salario;

                 -- Fin IAXIS-4785 -- 12/12/2019


                BEGIN
                   SELECT mon.cmonint
                     INTO v_monprod
                     FROM monedas mon
                    WHERE mon.cidioma = pac_md_common.f_get_cxtidioma
                      AND mon.cmoneda = pac_monedas.f_moneda_producto (i.sproduc);
                EXCEPTION
                   WHEN NO_DATA_FOUND
                   THEN
                      v_monprod := 'COP';
                END;

                IF v_monprod <> v_moninst
                THEN
                   v_depuaut_mon :=
                      NVL
                         (pac_eco_tipocambio.f_importe_cambio
                                                   (v_monprod,
                                                    v_moninst,
                                                    TO_DATE (TO_CHAR (pfcorte,
                                                                      'ddmmyyyy'
                                                                     ),
                                                             'ddmmyyyy'
                                                            ),
                                                    v_depuaut
                                                   ),
                          0
                         );							 
                ELSE
                   v_depuaut_mon := v_depuaut;					   
                END IF;


               -- v_depu_tot := v_depu_tot + v_depuaut_mon;
                                v_participa := i.participacion;
                v_depu_tot := v_depu_tot + (v_depuaut_mon*v_participa/100);

                			
    --             p_traza_proceso
    --                   (24,
    --                    'TRAZA_CESIONES_REA',
    --                    777,
    --                    'PAC_CUMULOS_CONF',
    --                    'f_calcula_depura_auto',
    --                    NULL,
    --                    3,
    --                       'Error: paso 1,
    --                     psperson:  333 '
    --                    || psperson
    --                    || ' vcoaseguro:'
    --                    || vcoaseguro
    --                    || ' v_tomador:'
    --                    || v_tomador
    --                    || '  v_sseguro:'
    --                    || v_sseguro
    --                    || 'v_sproduc:'
    --                    || v_sproduc
    --                    || 'v_depuaut_mon'
    --                    || v_depuaut_mon
    --                   );
             END LOOP;
       
         
         -- 
         -- Inicio IAXIS-11903 05/02/2020
         --
         -- Para el modo consulta, modificamos los cursores usados.
         --
         ELSE
           FOR i IN cur_pol_tom_con
             LOOP
                v_tomador := i.sperson;
                v_sseguro := i.sseguro;
                v_sproduc := i.sproduc;
                v_cactivi := i.cactivi;
                v_scesrea := i.scesrea;	

                BEGIN
                   SELECT NVL (c.ploccoa / 100, 0)
                     INTO vcoaseguro
                     FROM seguros s, coacuadro c
                    WHERE s.sseguro = c.sseguro
                      AND s.ctipcoa = 1
                      AND c.ncuacoa = (SELECT MAX (ncuacoa)
                                         FROM coacuadro
                                        WHERE sseguro = s.sseguro)
                      AND s.sseguro = v_sseguro;
				  
                EXCEPTION
                   WHEN OTHERS
                   THEN
                      vcoaseguro := 0;
                END;					

                IF vcoaseguro <> 0
                THEN
                   vcoaseguro := vcoaseguro;
                ELSE
                   vcoaseguro := 1;
                END IF;

                v_contract := 0;
                v_nocontra := 0;
                v_salario := 0;

                FOR j IN c_garan_con
                LOOP
                   IF j.cgarant <> 7005
                   THEN
                      IF NVL
                            (pac_iaxpar_productos.f_get_pargarantia
                                                                 ('EXCONTRACTUAL',
                                                                  v_sproduc,
                                                                  j.cgarant,
                                                                  v_cactivi
                                                                 ),
                             0
                            ) <> 2
                      THEN
                         v_contract :=
                                   v_contract
                                   + (NVL (j.icapital, 0) * vcoaseguro);									   
                      ELSE
                         v_nocontra :=
                                   v_nocontra
                                   + (NVL (j.icapital, 0) * vcoaseguro);								   
                      END IF;
                   ELSE
                      v_salario := (NVL (j.icapital, 0) * vcoaseguro);					  
                   END IF;
                END LOOP;

                IF v_contract >= v_nocontra
                THEN
                   v_depuaut := v_nocontra;
                ELSE
                   v_depuaut := v_contract;
                END IF;

                v_depuaut := v_depuaut;

                BEGIN
                   SELECT mon.cmonint
                     INTO v_monprod
                     FROM monedas mon
                    WHERE mon.cidioma = pac_md_common.f_get_cxtidioma
                      AND mon.cmoneda = pac_monedas.f_moneda_producto (i.sproduc);
                EXCEPTION
                   WHEN NO_DATA_FOUND
                   THEN
                      v_monprod := 'COP';
                END;

                IF v_monprod <> v_moninst
                THEN
                   v_depuaut_mon :=
                      NVL
                         (pac_eco_tipocambio.f_importe_cambio
                                                   (v_monprod,
                                                    v_moninst,
                                                    TO_DATE (TO_CHAR (pfcorte,
                                                                      'ddmmyyyy'
                                                                     ),
                                                             'ddmmyyyy'
                                                            ),
                                                    v_depuaut
                                                   ),
                          0
                         );					 
                ELSE
                   v_depuaut_mon := v_depuaut;						 				   
                END IF;


                v_participa := i.participacion;
                v_depu_tot := v_depu_tot + (v_depuaut_mon*v_participa/100);
                
                				
    --             p_traza_proceso
    --                   (24,
    --                    'TRAZA_CESIONES_REA',
    --                    777,
    --                    'PAC_CUMULOS_CONF',
    --                    'f_calcula_depura_auto',
    --                    NULL,
    --                    3,
    --                       'Error: paso 1,
    --                     psperson:  333 '
    --                    || psperson
    --                    || ' vcoaseguro:'
    --                    || vcoaseguro
    --                    || ' v_tomador:'
    --                    || v_tomador
    --                    || '  v_sseguro:'
    --                    || v_sseguro
    --                    || 'v_sproduc:'
    --                    || v_sproduc
    --                    || 'v_depuaut_mon'
    --                    || v_depuaut_mon
    --                   );
             END LOOP;

         END IF;
         --
         -- Fin IAXIS-11903 05/02/2020
         --			 
         /*IF (psperson = v_tomador)
         THEN
            v_participa := 100;
         ELSE
            v_consorcio := 'N';

            OPEN cur_participa (v_tomador, v_consorcio);

            FETCH cur_participa
             INTO v_participa;

            CLOSE cur_participa;
         END IF;*/
        -- v_depu_tot := v_depu_tot * v_participa / 100;					 		 
--          p_traza_proceso
--                   (24,
--                    'TRAZA_CESIONES_REA',
--                    777,
--                    'PAC_CUMULOS_CONF',
--                    'f_calcula_depura_auto',
--                    NULL,
--                    3,
--                       'Error: paso 1,
--                     psperson: 234 '
--                    || psperson
--                    || ' vcoaseguro:'
--                    || vcoaseguro
--                    || ' v_tomador:'
--                    || v_tomador
--                    || '  v_sseguro:'
--                    || v_sseguro
--                    || 'v_sproduc:'
--                    || v_sproduc
--                    || 'v_depu_tot'
--                    || v_depu_tot
--                    ||'v_monprod'
--                    ||v_monprod
--                    ||'v_moninst'
--                    ||v_moninst
--                   );
         RETURN (v_depu_tot);
      ELSE	  
--         p_traza_proceso
--                   (24,
--                    'TRAZA_CESIONES_REA',
--                    777,
--                    'PAC_CUMULOS_CONF',
--                    'f_calcula_depura_auto',
--                    NULL,
--                    3,
--                       'Error: paso 1,
--                     psperson:  EST 2'
--                    || psperson
--                    || ' vcoaseguro:'
--                    || vcoaseguro
--                    || ' v_tomador:'
--                    || v_tomador
--                    || '  v_sseguro:'
--                    || v_sseguro
--                    || 'v_sproduc:'
--                    || v_sproduc
--                    || 'v_cactivi:'
--                    || v_cactivi
--                   );

         FOR i IN cur_pol_tom
         LOOP
            v_tomador := i.sperson;
            v_sseguro := i.sseguro;
            v_sproduc := i.sproduc;
            v_cactivi := i.cactivi;				

            BEGIN
               SELECT NVL (c.ploccoa / 100, 0)
                 INTO vcoaseguro
                 FROM seguros s, coacuadro c
                WHERE s.sseguro = c.sseguro
                  AND s.ctipcoa = 1
                  AND c.ncuacoa = (SELECT MAX (ncuacoa)
                                     FROM coacuadro
                                    WHERE sseguro = s.sseguro)
                  AND s.sseguro = v_sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  vcoaseguro := 0;
            END;			

            IF vcoaseguro <> 0
            THEN
               vcoaseguro := vcoaseguro;
            ELSE
               vcoaseguro := 1;
            END IF;

            v_contract := 0;
            v_nocontra := 0;


            FOR j IN c_garan
            LOOP

               IF j.cgarant <> 7005
               THEN
                  IF NVL
                        (pac_iaxpar_productos.f_get_pargarantia
                                                             ('EXCONTRACTUAL',
                                                              v_sproduc,
                                                              j.cgarant,
                                                              v_cactivi
                                                             ),
                         0
                        ) <> 2
                  THEN
                     v_contract :=
                               v_contract
                               + (NVL (j.icapital, 0) * vcoaseguro);							   
                  ELSE
                     v_nocontra :=
                               v_nocontra
                               + (NVL (j.icapital, 0) * vcoaseguro);								   
                  END IF;
               ELSE
                  v_salario := (NVL (j.icapital, 0) * vcoaseguro);					  
               END IF;
            END LOOP;
            IF v_contract >= v_nocontra
            THEN
               v_depuaut := v_nocontra;			   
            ELSE
               v_depuaut := v_contract;			   
            END IF;

            v_depuaut := v_depuaut + v_salario;
            p_traza_proceso
                      (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CUMULOS_CONF',
                       'f_calcula_depura_auto',
                       NULL,
                       3,
                          'Error: est paso 1,
                     psperson:'
                       || psperson
                       || ' vcoaseguro:'
                       || vcoaseguro
                       || ' v_contract:'
                       || v_contract
                       || ' v_nocontra:'
                       || v_nocontra
                       || 'v_depu_tot:'
                       || v_depu_tot
                       || ' v_depuaut--> '
                       || v_depuaut
                       || 'v_salario '
                       || v_salario
                      );

            BEGIN
               SELECT mon.cmonint
                 INTO v_monprod
                 FROM monedas mon
                WHERE mon.cidioma = pac_md_common.f_get_cxtidioma
                  AND mon.cmoneda = pac_monedas.f_moneda_producto (i.sproduc);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_monprod := 'COP';
            END;

            v_depuaut_mon :=
               NVL
                  (pac_eco_tipocambio.f_importe_cambio
                                               (v_monprod,
                                                v_moninst,
                                                TO_DATE (TO_CHAR (pfcorte,
                                                                  'ddmmyyyy'
                                                                 ),
                                                         'ddmmyyyy'
                                                        ),
                                                v_depuaut
                                               ),
                   0
                  );					  
            v_depu_tot := v_depu_tot + v_depuaut_mon;
            
         END LOOP;	
 
  

         /*IF (psperson = v_tomador)
         THEN
            v_participa := 100;
			
         ELSE
            v_consorcio := 'N';

            OPEN cur_participa (v_tomador, v_consorcio);

            FETCH cur_participa
             INTO v_participa;

            CLOSE cur_participa;
         END IF;
         v_depu_tot := v_depu_tot * v_participa / 100;*/		 
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CUMULOS_CONF',
                       'f_calcula_depura_auto',
                       NULL,
                       313,
                          'Error: paso 1,
                     psperson:'
                       || psperson
                       || ' vcoaseguro:'
                       || vcoaseguro
                       || ' v_contract:'
                       || v_contract
                       || ' v_nocontra:'
                       || v_nocontra
                       || 'v_depu_tot:'
                       || v_depu_tot
                       ||'v_participa--> '||v_participa
                      );                    
         RETURN v_depu_tot;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error en la depuracion automatica',
                      SQLERRM
                     );                     
         RETURN 0;
   END f_calcula_depura_auto;

-- Ini IAXIS-4785 -- 24/07/2019
-- Fin IAXIS-4785 -- 25/10/2019
-- Fin AXIS-5353  -- 30/10/2019
   /*************************************************************************
    FUNCTION f_calcula_depura_manual
    Permite obtener por poliza y garantia el valor de la depuracion manual
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_depura_manual (
      pfcorte    IN   DATE,
      psseguro   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pcgenera   IN   NUMBER,
      psperson   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)      := 1;
      vparam     VARCHAR2 (2000)
         :=    'pfcorte='
            || pfcorte
            || '-psseguro='
            || psseguro
            || '-pcgarant='
            || pcgarant
            || '-pcgenera='
            || pcgenera;
      vobject    VARCHAR2 (200)
                              := 'pac_md_cumulos_conf.f_calcula_depura_manual';
      terror     VARCHAR2 (200)  := 'Error obtener cumulos';
      v_depura   NUMBER;

      CURSOR cur_depura
      IS
         SELECT NVL (SUM (icapces), 0)
           FROM det_cesionesrea dces
          WHERE sseguro = NVL (psseguro, sseguro)
            AND cgarant = NVL (pcgarant, cgarant)
            AND sperson = NVL (psperson, sperson)
            AND TRUNC (dces.fefecdema) <= pfcorte
            AND dces.nmovimi = (SELECT MAX (nmovimi)
                                  FROM det_cesionesrea dces2
                                 WHERE dces.sseguro = dces2.sseguro)
            AND (dces.nmovidep =
                    (SELECT MAX (nmovidep)
                       FROM det_cesionesrea dces3
                      WHERE dces.sseguro = dces3.sseguro
                        AND dces.cgarant = dces3.cgarant)
                )
            AND dces.nmovidep != 1
            AND EXISTS (
                   SELECT 'x'
                     FROM cesionesrea ces
                    WHERE ces.sseguro = dces.sseguro
                      AND cgenera = pcgenera
                      AND dces.scesrea = ces.scesrea);
   BEGIN
      --
      OPEN cur_depura;              --obtiene garantia de estabilidad/calidad

      FETCH cur_depura
       INTO v_depura;

      CLOSE cur_depura;

      --
      RETURN v_depura;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error en la depuracion manual',
                      SQLERRM
                     );
         RETURN 0;
   END f_calcula_depura_manual;

   /*************************************************************************
    FUNCTION f_calcula_comfu_cont
    Permite obtener por poliza los compromisos futuros contractuales
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_comfu_cont (psseguro IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec       NUMBER (8)               := 1;
      vparam         VARCHAR2 (2000)          := 'psseguro=' || psseguro;
      vobject        VARCHAR2 (200)
                                := 'pac_md_cumulos_conf.f_calcula_comfu_cont';
      terror         VARCHAR2 (200)           := 'Error obtener cumulos';
      v_compromiso   NUMBER;
      v_consorcio    VARCHAR2 (1);
      v_tomador      tomadores.sperson%TYPE;
      v_participa    NUMBER;
      vcoaseguro     NUMBER;

      CURSOR cur_participa (
         ppercons     per_personas.sperson%TYPE,
         pconsorcio   VARCHAR2
      )
      IS
         SELECT pparticipacion
           FROM per_personas_rel
          WHERE sperson = ppercons
            AND sperson_rel = psperson
            AND ctipper_rel = 0
            AND pconsorcio = 'S';

      CURSOR cur_compromiso
      IS
         SELECT SUM (valor) valor
           FROM (SELECT cgaran,
                        pac_eco_tipocambio.f_importe_cambio
                           ((SELECT cmonint
                               FROM monedas
                              WHERE cidioma = pac_md_common.f_get_cxtidioma
                                AND cmoneda = mon),
                            (SELECT cmonint
                               FROM monedas
                              WHERE cidioma = pac_md_common.f_get_cxtidioma
                                AND cmoneda =
                                       pac_parametros.f_parinstalacion_n
                                                                 ('MONEDAINST')),
                            TO_DATE (TO_CHAR (f_sysdate, 'ddmmyyyy'),
                                     'ddmmyyyy'
                                    ),
                            valor
                           ) valor
                   FROM (SELECT   nlinea, SUM (garan) cgaran, SUM (mon) mon,
                                  SUM (valor) valor
                             FROM (SELECT pt1.nlinea,
                                          DECODE (ccolumna,
                                                  1, nvalor,
                                                  0
                                                 ) garan,
                                          DECODE (ccolumna,
                                                  2, nvalor,
                                                  0
                                                 ) mon,
                                          DECODE (ccolumna,
                                                  4, nvalor,
                                                  0
                                                 ) valor
                                     FROM pregungaransegtab pt1
                                    WHERE pt1.sseguro = psseguro
                                      AND pt1.cpregun = 9551
                                      AND pt1.ccolumna IN (1, 2, 4)
                                      AND pt1.nmovimi =
                                             (SELECT MAX (nmovimi)
                                                FROM pregungaransegtab pt2
                                               WHERE pt2.sseguro = pt1.sseguro
                                                 AND pt2.cpregun = 9551)
                                      AND pt1.nlinea IN (
                                             SELECT nlinea
                                               FROM pregungaransegtab pt,
                                                    pargaranpro pgp
                                              WHERE pt.nvalor = pgp.cgarant
                                                AND pt.sseguro = pt1.sseguro
                                                AND pt.ccolumna = 1
                                                AND pt.cpregun = 9551
                                                AND pgp.cpargar =
                                                               'EXCONTRACTUAL'
                                                AND pgp.cvalpar = 1)) gar
                         GROUP BY nlinea));
   BEGIN
      --
      OPEN cur_compromiso;

      FETCH cur_compromiso
       INTO v_compromiso;

      CLOSE cur_compromiso;

      --
      SELECT sperson
        INTO v_tomador
        FROM tomadores
       WHERE sseguro = psseguro;

      --
      IF (psperson = v_tomador)
      THEN
         v_participa := 100;
      ELSE
         SELECT DECODE (f_consorcio (v_tomador), 0, 'N', 'S')
           INTO v_consorcio
           FROM DUAL;

         OPEN cur_participa (v_tomador, v_consorcio);

         FETCH cur_participa
          INTO v_participa;

         CLOSE cur_participa;
      END IF;

      BEGIN
         SELECT NVL (c.ploccoa, 0)
           INTO vcoaseguro
           FROM seguros s, coacuadro c
          WHERE s.sseguro = c.sseguro
            AND s.ctipcoa = 1
            AND c.ncuacoa = (SELECT MAX (ncuacoa)
                               FROM coacuadro
                              WHERE sseguro = psseguro)
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            vcoaseguro := 0;
      END;

      IF vcoaseguro <> 0
      THEN
         v_compromiso := v_compromiso * vcoaseguro / 100;
      END IF;

      v_compromiso := v_compromiso * v_participa / 100;
      RETURN v_compromiso;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error en obtener compromisos futuros contractuales',
                      SQLERRM
                     );
         RETURN 0;
   END f_calcula_comfu_cont;

   /*************************************************************************
    FUNCTION f_calcula_comfu_pos
    Permite obtener por poliza los compromisos futuros poscontractuales
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_comfu_pos (psseguro IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec       NUMBER (8)               := 1;
      vparam         VARCHAR2 (2000)          := 'psseguro=' || psseguro;
      vobject        VARCHAR2 (200)
                                 := 'pac_md_cumulos_conf.f_calcula_comfu_pos';
      terror         VARCHAR2 (200)           := 'Error obtener cumulos';
      v_compromiso   NUMBER;
      v_consorcio    VARCHAR2 (1);
      v_tomador      tomadores.sperson%TYPE;
      v_participa    NUMBER;
      vcoaseguro     NUMBER;

      CURSOR cur_participa (
         ppercons     per_personas.sperson%TYPE,
         pconsorcio   VARCHAR2
      )
      IS
         SELECT pparticipacion
           FROM per_personas_rel
          WHERE sperson = ppercons
            AND sperson_rel = psperson
            AND ctipper_rel = 0
            AND pconsorcio = 'S';

      CURSOR cur_compromiso
      IS
         SELECT SUM (valor) valor
           FROM (SELECT cgaran,
                        pac_eco_tipocambio.f_importe_cambio
                           ((SELECT cmonint
                               FROM monedas
                              WHERE cidioma = pac_md_common.f_get_cxtidioma
                                AND cmoneda = mon),
                            (SELECT cmonint
                               FROM monedas
                              WHERE cidioma = pac_md_common.f_get_cxtidioma
                                AND cmoneda =
                                       pac_parametros.f_parinstalacion_n
                                                                 ('MONEDAINST')),
                            TO_DATE (TO_CHAR (f_sysdate, 'ddmmyyyy'),
                                     'ddmmyyyy'
                                    ),
                            valor
                           ) valor
                   FROM (SELECT   nlinea, SUM (garan) cgaran, SUM (mon) mon,
                                  SUM (valor) valor
                             FROM (SELECT pt1.nlinea,
                                          DECODE (ccolumna,
                                                  1, nvalor,
                                                  0
                                                 ) garan,
                                          DECODE (ccolumna,
                                                  2, nvalor,
                                                  0
                                                 ) mon,
                                          DECODE (ccolumna,
                                                  4, nvalor,
                                                  0
                                                 ) valor
                                     FROM pregungaransegtab pt1
                                    WHERE pt1.sseguro = psseguro
                                      AND pt1.cpregun = 9551
                                      AND pt1.ccolumna IN (1, 2, 4)
                                      AND pt1.nmovimi =
                                             (SELECT MAX (nmovimi)
                                                FROM pregungaransegtab pt2
                                               WHERE pt2.sseguro = pt1.sseguro
                                                 AND pt2.cpregun = 9551)
                                      AND pt1.nlinea IN (
                                             SELECT nlinea
                                               FROM pregungaransegtab pt,
                                                    pargaranpro pgp
                                              WHERE pt.nvalor = pgp.cgarant
                                                AND pt.sseguro = pt1.sseguro
                                                AND pt.ccolumna = 1
                                                AND pt.cpregun = 9551
                                                AND pgp.cpargar =
                                                               'EXCONTRACTUAL'
                                                AND pgp.cvalpar = 2)) gar
                         GROUP BY nlinea));
   BEGIN
      --
      OPEN cur_compromiso;

      FETCH cur_compromiso
       INTO v_compromiso;

      CLOSE cur_compromiso;

      --
      SELECT sperson
        INTO v_tomador
        FROM tomadores
       WHERE sseguro = psseguro;

      --
      IF (psperson = v_tomador)
      THEN
         v_participa := 100;
      ELSE
         SELECT DECODE (f_consorcio (v_tomador), 0, 'N', 'S')
           INTO v_consorcio
           FROM DUAL;

         OPEN cur_participa (v_tomador, v_consorcio);

         FETCH cur_participa
          INTO v_participa;

         CLOSE cur_participa;
      END IF;

      BEGIN
         SELECT NVL (c.ploccoa, 0)
           INTO vcoaseguro
           FROM seguros s, coacuadro c
          WHERE s.sseguro = c.sseguro
            AND s.ctipcoa = 1
            AND c.ncuacoa = (SELECT MAX (ncuacoa)
                               FROM coacuadro
                              WHERE sseguro = psseguro)
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            vcoaseguro := 0;
      END;

      IF vcoaseguro <> 0
      THEN
         v_compromiso := v_compromiso * vcoaseguro / 100;
      END IF;

      v_compromiso := v_compromiso * v_participa / 100;
      RETURN v_compromiso;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error
                    (f_sysdate,
                     f_user,
                     vobject,
                     vpasexec,
                     'Error en obtener compromisos futuros poscontractuales',
                     SQLERRM
                    );
         RETURN 0;
   END f_calcula_comfu_pos;

   /*************************************************************************
     FUNCTION f_calcula_cupo_autorizado
     Permite obtener el cupo autorizado de una persona a una fecha
     param in pfcorte        : fecha de corte
     param in psperson       : codigo de persona
     return                  : number
    *************************************************************************/
   FUNCTION f_calcula_cupo_autorizado (pfcorte IN DATE, psperson IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)      := 1;
      vparam        VARCHAR2 (2000)
                         := 'pfcorte=' || pfcorte || '-psperson=' || psperson;
      vobject       VARCHAR2 (200)
                              := 'pac_cumulos_conf.f_calcula_cupo_autorizado';
      terror        VARCHAR2 (200)  := 'Error obtener cumulos';
      vnumerr       NUMBER;
      vsfinanci     NUMBER;
      pcuposug      NUMBER;
      pcupogar      NUMBER;
      pcapafin      NUMBER;
      pcuposugv1    NUMBER;
      pcupogarv1    NUMBER;
      pcapafinv1    NUMBER;
      pncontpol     NUMBER;
      pnaniosvinc   NUMBER;
      mensajes      t_iax_mensajes;
      v_contexto    NUMBER          := 0;
   BEGIN
      --
      BEGIN
         SELECT sfinanci
           INTO vsfinanci
           FROM fin_general
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vsfinanci := NULL;
      END;

      --
      IF vsfinanci IS NOT NULL
      THEN
         v_contexto :=
            pac_contexto.f_inicializarctx
                                  (pac_parametros.f_parempresa_t (24,
                                                                  'USER_BBDD'
                                                                 )
                                  );
         vnumerr :=
            pac_md_financiera.f_calcula_modelo (vsfinanci,
                                                NULL,
                                                1,
                                                pcuposug,
                                                pcupogar,
                                                pcapafin,
                                                pcuposugv1,
                                                pcupogarv1,
                                                pcapafinv1,
                                                pncontpol,
                                                pnaniosvinc,
                                                NULL,
                                                NULL,
                                                mensajes
                                               );

         IF vnumerr <> 0
         THEN
            pcupogar := 0;
         END IF;
      ELSE
         pcupogar := 0;
      END IF;

      --
      RETURN pcupogar;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error en obtener cupo autorizado',
                      SQLERRM
                     );
         RETURN 0;
   END f_calcula_cupo_autorizado;

   /*************************************************************************
     FUNCTION f_calcula_cupo_modelo
     Permite obtener el cupo modelo de una persona a una fecha
     param in pfcorte        : fecha de corte
     param in psperson       : codigo de persona
     return                  : number
    *************************************************************************/
   FUNCTION f_calcula_cupo_modelo (pfcorte IN DATE, psperson IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec      NUMBER (8)      := 1;
      vparam        VARCHAR2 (2000)
                         := 'pfcorte=' || pfcorte || '-psperson=' || psperson;
      vobject       VARCHAR2 (200)
                               := 'pac_md_cumulos_conf.f_calcula_cupo_modelo';
      terror        VARCHAR2 (200)  := 'Error obtener cumulos';
      vnumerr       NUMBER;
      vsfinanci     NUMBER;
      pcuposug      NUMBER;
      pcupogar      NUMBER;
      pcapafin      NUMBER;
      pcuposugv1    NUMBER;
      pcupogarv1    NUMBER;
      pcapafinv1    NUMBER;
      pncontpol     NUMBER;
      pnaniosvinc   NUMBER;
      mensajes      t_iax_mensajes;
      v_contexto    NUMBER          := 0;
   BEGIN
      --
      BEGIN
         SELECT sfinanci
           INTO vsfinanci
           FROM fin_general
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            vsfinanci := NULL;
      END;

      --
      IF vsfinanci IS NOT NULL
      THEN
         v_contexto :=
            pac_contexto.f_inicializarctx
                                  (pac_parametros.f_parempresa_t (24,
                                                                  'USER_BBDD'
                                                                 )
                                  );
         vnumerr :=
            pac_md_financiera.f_calcula_modelo (vsfinanci,
                                                NULL,
                                                1,
                                                pcuposug,
                                                pcupogar,
                                                pcapafin,
                                                pcuposugv1,
                                                pcupogarv1,
                                                pcapafinv1,
                                                pncontpol,
                                                pnaniosvinc,
                                                NULL,
                                                NULL,
                                                mensajes
                                               );
      ELSE
         pcuposug := 0;
      END IF;

      --
      RETURN pcuposug;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error en obtener cupo modelo',
                      SQLERRM
                     );
         RETURN 0;
   END f_calcula_cupo_modelo;

   /*************************************************************************
     FUNCTION f_get_fechadepu
     Permite obtener la fecha de depuracion del maximo movimiento de depuracion
     para el seguro y amparo
     param in psseguro       : seguro
     param in pcgarant       : garantia
     return                  : date
    *************************************************************************/
   FUNCTION f_get_fechadepu (psseguro IN NUMBER, pcgarant IN NUMBER)
      RETURN DATE
   IS
      vpasexec     NUMBER (8)      := 1;
      vparam       VARCHAR2 (2000)
                       := 'psseguro=' || psseguro || '-pcgarant=' || pcgarant;
      vobject      VARCHAR2 (200)  := 'pac_cumulos_conf.f_get_fechadepu';
      terror       VARCHAR2 (200)  := 'Error obtener cumulos';
      v_fechdepu   DATE;

      CURSOR cur_fechdepu
      IS
         SELECT TRUNC (MAX (fefecdema))
           FROM det_cesionesrea dces
          WHERE sseguro = psseguro
            AND cgarant = pcgarant
            AND cdepura = 'S'
            AND nmovidep =
                   (SELECT MAX (nmovidep)
                      FROM det_cesionesrea dces2
                     WHERE dces2.sseguro = dces.sseguro
                       AND dces2.cgarant = dces.cgarant
                       AND cdepura = 'S');
   BEGIN
      --
      OPEN cur_fechdepu;

      FETCH cur_fechdepu
       INTO v_fechdepu;

      CLOSE cur_fechdepu;

      --
      RETURN v_fechdepu;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error en obtener fecha de depuracion manual',
                      SQLERRM
                     );
         RETURN NULL;
   END f_get_fechadepu;

  /*************************************************************************
   FUNCTION f_get_porc_garantia
   Permite obtener el porcentaje que representan los diferentes tramos en cada
   garantia de depuracion automatica
   param in pfcorte        : fecha de corte
   param in psperson       : codigo de persona
   param in pscontra       : contrato de reaseguro
   param in psseguro       : seguro
   param in pcgarant       : garantia
   return                  : number
  *************************************************************************/
  FUNCTION f_get_porc_garantia(pfcorte  IN DATE,
                               psperson IN NUMBER,
                               pscontra IN NUMBER,
                               psseguro IN NUMBER,
                               pcgarant IN NUMBER) RETURN NUMBER IS
    vpasexec   NUMBER(8) := 0;
    vparam     VARCHAR2(2000) := 'pfcorte=' || pfcorte || '-psperson=' ||
                                 psperson || '-pscontra=' || pscontra ||
                                 '-psseguro=' || psseguro || '-pcgarant=' ||
                                 pcgarant;
    vobject    VARCHAR2(200) := 'pac_cumulos_conf.f_get_porc_garantia';
    terror     VARCHAR2(200) := 'Error obtener porcentaje por garantía';
    v_porcgara NUMBER;
    --
    -- Inicio IAXIS-12992 27/04/2020
    --
    CURSOR cur_porc IS
      SELECT SUM(pcesion) pcesion
        FROM (SELECT dce.sseguro seguro,
                     dce.cgarant garan,
                     decode(ces.ctramo,
                            0,
                            decode(nvl(ces.ctrampa, 0),
                                   0,
                                   ces.ctramo,
                                   ces.ctrampa),
                            dce.ptramo) tramo,
                     SUM(dce.pcesion) pcesion
                FROM det_cesionesrea dce,
                     cesionesrea     ces,
                     garanseg        gar,
                     seguros         seg,
                     tomadores       tom
               WHERE dce.sseguro = gar.sseguro
                 AND dce.cgarant = gar.cgarant
                 AND dce.scesrea = ces.scesrea
                 AND ces.scontra = pscontra
                 AND dce.sseguro = psseguro
                 AND dce.cgarant = pcgarant
                 AND ces.fefecto <= pfcorte
                 AND ces.fvencim > pfcorte
                 AND (ces.fregula > pfcorte OR ces.fregula IS NULL)
                 AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                 AND (ces.fanulac > pfcorte OR ces.fanulac IS NULL)
                 AND nvl(cdepura, 'N') != 'S'
                 AND seg.sseguro = gar.sseguro
                 AND seg.sseguro = tom.sseguro
                 AND tom.sperson = psperson
                 AND gar.nmovimi =
                     (SELECT MAX(nmovimi)
                        FROM garanseg gar2
                       WHERE gar.sseguro = gar2.sseguro)
               GROUP BY dce.sseguro,
                        dce.cgarant,
                        decode(ces.ctramo,
                               0,
                               decode(nvl(ces.ctrampa, 0),
                                      0,
                                      ces.ctramo,
                                      ces.ctrampa),
                               dce.ptramo));
    --
    -- Fin IAXIS-12992 27/04/2020
    --                       
  BEGIN
    --
    vpasexec := 1;
    --
    OPEN cur_porc;
    --
    vpasexec := 2;
    --
    FETCH cur_porc
      INTO v_porcgara;
    --
    vpasexec := 3;  
    --
    CLOSE cur_porc;
    --
    RETURN nvl(v_porcgara, 0);
  
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  terror||' '||vparam,
                  SQLERRM);
      RETURN NULL;
  END f_get_porc_garantia;

   /*************************************************************************
     FUNCTION f_calcula_cumries_tramo
     Permite obtener el cumulo en riesgo por tramo
     param in pfcorte        : fecha de corte
     param in psperson       : codigo de persona
     param in pscontra       : contrato de reaseguro
     param in pctramo        : tramo de contrato de reaseguro
     return                  : number
    *************************************************************************/
   FUNCTION f_calcula_cumries_tramo (
      pfcorte    IN   DATE,
      psperson   IN   NUMBER,
      pscontra   IN   NUMBER,
      pctramo    IN   NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec        NUMBER (8)             := 1;
      vparam          VARCHAR2 (2000)
         :=    'pfcorte='
            || pfcorte
            || '-psperson='
            || psperson
            || '-pscontra='
            || pscontra
            || '-pctramo='
            || pctramo;
      vobject         VARCHAR2 (200)
                              := 'pac_md_cumulos_conf.f_calcula_cumries_tramo';
      terror          VARCHAR2 (200)
                                   := 'Error calculo cumulo riesgo por tramos';
      v_cumries       NUMBER;
      v_cumries_tot   NUMBER;
      v_depman        NUMBER;
      v_depauto       NUMBER;
      v_moninst       monedas.cmonint%TYPE;                     --moneda local

--Ini IAXIS-5353 -- ECP -- 21/10/2019
      CURSOR cur_cumries (pmoninst monedas.cmonint%TYPE)
      IS
         --FEPP INI 06/09/2019 IAXIS-4773 SE VALIDA QUE LA CONSUTA LLAME LAS CESIONES PARA RESTAR CUMULO POR TRAMOS AGREGANDO OR ces.cgarant is null
         SELECT NVL
                   (SUM
                       (pac_eco_tipocambio.f_importe_cambio
                           (pac_monedas.f_cmoneda_t
                                   (pac_monedas.f_moneda_producto (seg.sproduc)
                                   ),
                            pmoninst,
                            pfcorte,
                            NVL (dce.icapces, 0)
                           )
                       ),
                    0
                   )
           --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
         FROM   det_cesionesrea dce,
                cesionesrea ces,
                garanseg gar,
                seguros seg,
                tomadores tom,
                contratos con
          WHERE tom.sperson = psperson
            AND gar.sseguro = dce.sseguro
            AND gar.cgarant = dce.cgarant
            AND ces.scontra = con.scontra
            AND ces.nversio = con.nversio
            AND pfcorte <= gar.ffinvig
            AND gar.nmovimi = (SELECT MAX (nmovimi)
                                 FROM garanseg gar3
                                WHERE gar3.sseguro = gar.sseguro)
            AND tom.sseguro = ces.sseguro
            --AND (ces.fanulac > pfcorte OR ces.fanulac IS NULL)
            AND (ces.fregula > pfcorte OR ces.fregula IS NULL)
            AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
            AND dce.sseguro = seg.sseguro
            AND seg.csituac = 0
            AND dce.scesrea = ces.scesrea
            AND NVL (dce.cdepura, 'N') = 'N';

                           --FEPP FIN 06/09/2019 IAXIS-4773
      --Fin IAXIS-5353 -- ECP -- 21/10/2019
         --depuracion manual por tramo
      CURSOR cur_depmanual (pmoninst monedas.cmonint%TYPE)
      IS
         --SELECT NVL(SUM(dces.icapces),0)
         SELECT NVL
                   (SUM
                       (pac_eco_tipocambio.f_importe_cambio
                           (pac_monedas.f_cmoneda_t
                                   (pac_monedas.f_moneda_producto (seg.sproduc)
                                   ),
                            pmoninst,
                            pfcorte,
                            NVL (dces.icapces, 0)
                           )
                       ),
                    0
                   )
           --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
         FROM   det_cesionesrea dces, /*tomadores tom, */ cesionesrea ces,
                seguros seg
          WHERE                                   --tom.sseguro = dces.sseguro
                --AND
                dces.scesrea = ces.scesrea
            AND ces.sseguro = seg.sseguro
            --AND tom.sperson  = psperson
            AND dces.sperson = psperson
            AND ces.scontra = pscontra
            AND (ces.ctramo = pctramo OR ces.ctrampa = pctramo)
            AND TRUNC (dces.fefecdema) <= pfcorte
            AND dces.nmovimi = (SELECT MAX (nmovimi)
                                  FROM det_cesionesrea dces2
                                 WHERE dces.sseguro = dces2.sseguro)
            AND (dces.nmovidep =
                    (SELECT MAX (nmovidep)
                       FROM det_cesionesrea dces3
                      WHERE dces.sseguro = dces3.sseguro
                        AND dces.cgarant = dces3.cgarant)
                )
            AND dces.nmovidep != 1;

      ----depuracion automatica por tramo
      CURSOR cur_depauto (pmoninst monedas.cmonint%TYPE)
      IS
         --SELECT SUM(depuaut) depuaut
         SELECT NVL
                   (SUM
                       (pac_eco_tipocambio.f_importe_cambio
                           (pac_monedas.f_cmoneda_t
                                       (pac_monedas.f_moneda_producto (sproduc)
                                       ),
                            pmoninst,
                            pfcorte,
                            NVL (depuaut, 0)
                           )
                       ),
                    0
                   ) depuaut
           --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
         FROM   (SELECT   seguro, garan, tramo, SUM (pcesion) pcesion,
                          sproduc,
                            NVL
                               (pac_cumulos_conf.f_calcula_depura_auto
                                                                     (pfcorte,
                                                                      seguro,
                                                                      garan,
                                                                      psperson
                                                                     ),
                                0
                               )
                          +   NVL
                                 (pac_cumulos_conf.f_calcula_depura_auto
                                                                    (pfcorte,
                                                                     NULL,
                                                                     NULL,
                                                                     psperson,
                                                                     'EST'
                                                                    ),
                                  0
                                 )
                            * (  SUM (pcesion)
                               / pac_cumulos_conf.f_get_porc_garantia
                                                                    (pfcorte,
                                                                     psperson,
                                                                     pscontra,
                                                                     seguro,
                                                                     garan
                                                                    )
                              ) depuaut
                     FROM (SELECT   dce.sseguro seguro, dce.cgarant garan,
                                    seg.sproduc,
                                    DECODE (ces.ctramo,
                                            0, DECODE (NVL (ces.ctrampa, 0),
                                                       0, ces.ctramo,
                                                       ces.ctrampa
                                                      ),
                                            dce.ptramo
                                           ) tramo,
                                    SUM (dce.pcesion) pcesion
                               FROM det_cesionesrea dce,
                                    cesionesrea ces,
                                    garanseg gar,
                                    seguros seg,
                                    tomadores tom
                              WHERE dce.sseguro = gar.sseguro
                                AND dce.cgarant = gar.cgarant
                                AND gar.sseguro = dce.sseguro
                                AND gar.cgarant = dce.cgarant
                                AND gar.cgarant = ces.cgarant
                                AND gar.nriesgo = ces.nriesgo
                                AND gar.nmovimi = ces.nmovimi
                                AND gar.sseguro = ces.sseguro
                                AND dce.scesrea = ces.scesrea
                                AND ces.scontra = pscontra
                                AND dce.cgarant IN (7008, 7009)
                                AND (   ces.ctramo = pctramo
                                     OR ces.ctrampa = pctramo
                                    )
                                AND ces.fefecto <= pfcorte
                                --AND ces.fvencim > pfcorte
                                AND (   ces.fregula > pfcorte
                                     OR ces.fregula IS NULL
                                    )
                                AND ces.cgenera IN
                                           (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
                                --  AND (   ces.fanulac > pfcorte
                                 --      OR ces.fanulac IS NULL
                                 --     )
                                AND NVL (cdepura, 'N') != 'S'
                                AND seg.sseguro = gar.sseguro
                                AND seg.sseguro = tom.sseguro
                                AND tom.sperson = psperson
                                AND tom.cdomici = 1
                                AND gar.nmovimi =
                                           (SELECT MAX (nmovimi)
                                              FROM garanseg gar2
                                             WHERE gar.sseguro = gar2.sseguro)
                           GROUP BY dce.sseguro,
                                    dce.cgarant,
                                    seg.sproduc,
                                    DECODE (ces.ctramo,
                                            0, DECODE (NVL (ces.ctrampa, 0),
                                                       0, ces.ctramo,
                                                       ces.ctrampa
                                                      ),
                                            dce.ptramo
                                           ))
                 GROUP BY seguro, garan, tramo, sproduc);
   BEGIN
      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');

      --
      OPEN cur_cumries (v_moninst);

      FETCH cur_cumries
       INTO v_cumries;

      CLOSE cur_cumries;

      --
      OPEN cur_depmanual (v_moninst);

      FETCH cur_depmanual
       INTO v_depman;

      CLOSE cur_depmanual;

      --
      OPEN cur_depauto (v_moninst);

      FETCH cur_depauto
       INTO v_depauto;

      CLOSE cur_depauto;

      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CUMULOS_CONF',
                       'F_CALCULA_CUMRIES_TRAMO',
                       NULL,
                       2,
                          'Error: paso 1,
                     psperson:'
                       || psperson
                       || ' pctramo:'
                       || pctramo
                       || ' v_cumries:'
                       || v_cumries
                       || ' v_depman:'
                       || v_depman
                       || ' v_depauto:'
                       || v_depauto
                      );
      --
      v_depauto :=
         pac_cumulos_conf.f_calcula_depura_auto (pfcorte,
                                                 NULL,
                                                 NULL,
                                                 psperson,
                                                 'EST'
                                                );
      v_cumries_tot :=
                     NVL (v_cumries, 0) - NVL (v_depman, 0)
                     - NVL (v_depauto, 0);
      p_traza_proceso (24,
                       'TRAZA_CESIONES_REA',
                       777,
                       'PAC_CUMULOS_CONF',
                       'F_CALCULA_CUMRIES_TRAMO',
                       NULL,
                       23,
                          'Error: paso 1,
                     psperson:'
                       || psperson
                       || ' pctramo:'
                       || pctramo
                       || ' v_cumries:'
                       || v_cumries
                       || ' v_depman:'
                       || v_depman
                       || ' v_depauto:'
                       || v_depauto
                       || 'v_cumries_tot '
                       || v_cumries_tot
                      );
      RETURN v_cumries_tot;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error en obtener cumulo en riesgo por tramo',
                      SQLERRM
                     );
         RETURN 0;
   END f_calcula_cumries_tramo;

   /*************************************************************************
    FUNCTION f_calcula_disponible_tramo
    Calcula el minimo porcentaje disponible en el tramo por persona
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona del consorcio/tomador
    param in pscontra       : contrato de reaseguro
    param in pnversio       : version del contrato
    param in pctramo        : tramo de contrato de reaseguro
    param in pivalaseg      : valor asegurado de la poliza
    param in pconsorcio     : indica si es o no un consorcio
    param in pctipcoa       : tipo de coaseguro
    param in sseguro        : seguro
    param in pmotiu         : tipo de cesión
    param ptablas           : tablas (reales, estudio)
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_disponible_tramo(pfcorte    IN DATE,
                                       psperson   IN NUMBER,
                                       pscontra   IN NUMBER,
                                       pnversio   IN NUMBER,
                                       pctramo    IN NUMBER,
                                       pivalaseg  IN NUMBER,
                                       pconsorcio IN VARCHAR2,
                                       pctipcoa   IN NUMBER, 
                                       -- Inicio IAXIS-12992 26/04/2020
                                       psseguro   IN NUMBER,
                                       pmotiu     IN NUMBER,
                                       ptablas    IN VARCHAR2
                                       -- Fin IAXIS-12992 26/04/2020
                                       ) RETURN NUMBER IS
     vpasexec      NUMBER(8) := 1;
     vparam        VARCHAR2(2000) := 'pfcorte=' || pfcorte || '-psperson=' ||
                                     psperson || '-pscontra=' || pscontra ||
                                     '-pctramo=' || pctramo;
     vobject       VARCHAR2(200) := 'pac_md_cumulos_conf.f_calcula_cumries_tramo';
     terror        VARCHAR2(200) := 'Error calculo cumulo riesgo por tramos';
     v_capacont    NUMBER; --capacidad del tramo/contrato
     v_pordisp     NUMBER; --porcentaje disponible en el tramo
     v_pordisp_min NUMBER; --minimo porcentaje disponible en el tramo
     v_nnumide     NUMBER;
     --
     -- Inicio IAXIS-12992 27/04/2020
     --
     v_sseguro           NUMBER; 
     v_capatotcont       NUMBER := 0;
     v_cum_total_otros   NUMBER := 0;
     v_calcula_dep_otros NUMBER := 0;
     v_ocupa_tramo       NUMBER := 0;
     --
     -- Fin IAXIS-12992 27/04/2020
     --
     CURSOR cur_tomador IS --determinar si debe incluir tambien el consorcio padre
       SELECT sperson_rel sperson, pparticipacion, 'P' tip_per --participante
         FROM per_personas_rel
        WHERE sperson = psperson
          AND ctipper_rel = 0
          AND pconsorcio = 'S'
       UNION ALL
       SELECT psperson, 100, 'C' --consorcio
         FROM dual
        WHERE pconsorcio = 'S'
       UNION ALL
       SELECT psperson, 100, 'I' --cliente individual
         FROM dual
        WHERE pconsorcio = 'N'
        ORDER BY 3, 2 DESC;
   BEGIN
     --
     -- Inicio IAXIS-12992 27/04/2020
     --
     -- Controlamos que para los suplementos se seleccione el seguro correspondiente al negocio que se está emitiendo.
     -- Este se enviará como parámetro para que el cálculo de la acumulación sea realizado teniendo en cuenta únicamente
     -- los seguros diferentes a él mismo.
     --
     IF ptablas = 'EST' THEN
       IF pmotiu = 4 THEN
         BEGIN
           SELECT ssegpol
             INTO v_sseguro
             FROM estseguros
            WHERE sseguro = psseguro;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             v_sseguro := psseguro;
         END;    
        ELSE
          v_sseguro := psseguro;  
       END IF;   
     ELSE 
       v_sseguro := psseguro;
     END IF;       
     --
     -- Fin IAXIS-12992 27/04/2020
     --
     IF (pctramo = 0) THEN
       v_capacont := 500000000;
     ELSE
       SELECT nvl(itottra, 0)
         INTO v_capacont
         FROM tramos
        WHERE scontra = pscontra
          AND nversio = pnversio
          AND ctramo = pctramo;
       -- INI - ML - BUG 4775
       --COAS ACEPTADO
       --IF (pctipcoa = 8)
       --THEN
       -- v_capacont := v_capacont / 2;
       -- END IF;
       -- FIN - ML - BUG 4775
       --
       -- Acá se ha de obtener la capacidad total de los tramos siguientes al que está siendo tratado a fin de poder 
       -- coparla (virtualmente) con el cúmulo del afianzado generado por pólizas en otras versiones del mismo contrato.
       --
       SELECT SUM(NVL(t.itottra,0))  
         INTO v_capatotcont
         FROM tramos t
        WHERE t.scontra = pscontra
          AND t.nversio = pnversio
          AND t.ctramo > pctramo;
       
       v_capatotcont := NVL(v_capatotcont,0);  
       --
       --
       -- Se obtiene el cúmulo vigente del afianzado generado por pólizas en otras versiones del mismo contrato
       --
       v_cum_total_otros := f_cum_total_tom_otros(psperson,
                                                  pfcorte,
                                                  v_sseguro,
                                                  pscontra,
                                                  pnversio,
                                                  NULL);
       --
       --
       -- Así mismo se calcula la depuración generada por pólizas en otras versiones del mismo contrato.
       --
       v_calcula_dep_otros := f_calcula_depuracion_otros(pfcorte,
                                                         psperson,
                                                         v_sseguro,
                                                         pscontra,
                                                         pnversio,
                                                         NULL);
       --
       -- La ocupación del tramo tratado (v_ocupa_tramo) vienen determinada por la diferencia entre la capacidad total en los siguientes 
       -- tramos diferentes y mayores al tratado (v_capatotcont) y el cúmulo depurado calculado a la fecha para el afianzado en dicho
       -- contrato (v_cum_total_otros - v_calcula_dep_otros) sin tener en cuenta la versión en la que se encuentra.
       --
       v_ocupa_tramo := v_capatotcont - (v_cum_total_otros - v_calcula_dep_otros);
       --
       --
       -- Si el resultado es 0 o mayor a éste, se entenderá que la capacidad configurada del tramo tratado no deberá verse afectada por el 
       -- cúmulo del afianzado generado por pólizas en otras versiones del mismo contrato.
       --
       IF v_ocupa_tramo >= 0 THEN
         v_ocupa_tramo := 0;
       ELSE 
         v_ocupa_tramo := ABS(v_ocupa_tramo);  
       END IF;  
       --
       -- Capacidades variables de tramo (v_capacont):
       -- Aunque por configuración en la tabla de tramos se especifique que cada tramo para un contrato y versión tiene una capacidad fija, 
       -- se considerará de ahora en adelante variable debido a que dicha capacidad dependerá de la acumulación depurada de valores 
       -- asegurados que puede tener el afianzado de versiones anteriores del mismo contrato.   
       --
       v_capacont := v_capacont - v_ocupa_tramo;
       --
     END IF;
     
     v_pordisp_min := 100;
   
     FOR rg_tomador IN cur_tomador LOOP
       BEGIN
         SELECT nnumide
           INTO v_nnumide
           FROM per_identificador
          WHERE sperson = rg_tomador.sperson;
       END;
     
       -- INi  IAXIS-5353 -- ECP -- 20/11/2019
       v_pordisp := ((v_capacont -
                    (pac_cumulos_conf.f_cum_total_tom_tramo(psperson,
                                                            pfcorte,
                                                            v_sseguro,
                                                            pscontra,
                                                            pnversio,
                                                            pctramo) -
                    f_calcula_depuracion_tramo(pfcorte,
                                                  psperson,
                                                  v_sseguro,
                                                  pscontra,
                                                  pnversio,
                                                  pctramo))) /
                    (pivalaseg * rg_tomador.pparticipacion / 100));


         -- Fin IAXIS-5353 -- ECP -- 20/11/2019
--         p_traza_proceso
--            (24,
--             'TRAZA_CESIONES_REA',
--             777,
--             'PAC_CUMULOS_CONF',
--             'F_CALCULA_DISPONIBLE_TRAMO',
--             NULL,
--             2,
--                'Error: paso 1,
--                     rg_tomador.sperson:'
--             || rg_tomador.sperson
--             || ' pctramo:'
--             || pctramo
--             || ' v_capacont:'
--             || v_capacont
--             || ' pivalaseg:'
--             || pivalaseg
--             || ' rg_tomador.pparticipacion:'
--             || rg_tomador.pparticipacion
--             || '  f_cum_total_tom (p_nnumide, p_fcorte):'
--             || pac_cumulos_conf.f_cum_total_tom (v_nnumide, pfcorte)
--             || ' pac_cumulos_conf.f_calcula_depura_auto(pfcorte, null,null,psperson,''EST''); '
--             || pac_cumulos_conf.f_calcula_depura_auto (pfcorte,
--                                                        NULL,
--                                                        NULL,
--                                                        psperson,
--                                                        'EST'
--                                                       )
--             || 'pac_cumulos_conf.f_calcula_depura_auto (pfcorte,
--                                                          NULL,
--                                                          NULL,
--                                                          psperson,
--
--                                                         )'
--             || pac_cumulos_conf.f_calcula_depura_auto (pfcorte,
--                                                        NULL,
--                                                        NULL,
--                                                        psperson
--                                                       )
--             || 'v_pordisp--> '
--             || v_pordisp
--            );
       IF (v_pordisp < v_pordisp_min) THEN
         v_pordisp_min := v_pordisp;
       END IF;
       
       IF (v_pordisp_min < 0)
       THEN
         v_pordisp_min := 0;
       END IF;
     --  
     END LOOP;
   
     --
      RETURN v_pordisp_min;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error en obtener minimo disponible por tramo',
                      SQLERRM
                     );
         RETURN 0;
   END f_calcula_disponible_tramo;

   /*************************************************************************
     FUNCTION f_get_cons_cesionesrea
     Obtiene el consecutivo de cesionesrea para un participante de consorcio
     param in psseguro       : seguro
     param in pscontra       : contrato de reaseguro
     param in pnversio       : version del contrato
     param in pctramo        : tramo de contrato de reaseguro
     param in pnriesgo       : riesgo
     param in pctrampa       : tramo padre
     param in pcgenera       : tipo de movimiento
     param in pnmovimi       : numero movimiento
     return                  : number
    *************************************************************************/
   FUNCTION f_get_cons_cesionesrea (
      psseguro   IN   NUMBER,
      pscontra   IN   NUMBER,
      pnversio   IN   NUMBER,
      pctramo    IN   NUMBER,
      pnriesgo   IN   NUMBER,
      pctrampa   IN   NUMBER,
      pcgenera   IN   NUMBER,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)                 := 1;
      vparam      VARCHAR2 (2000)
         :=    'psseguro='
            || psseguro
            || '-pscontra='
            || pscontra
            || '-pnversio='
            || pnversio
            || '-pctramo='
            || pctramo
            || '-pnriesgo='
            || pnriesgo
            || '-pctrampa='
            || pctrampa
            || '-pcgenera='
            || pcgenera
            || '-pnmovimi='
            || pnmovimi;
      vobject     VARCHAR2 (200)
                               := 'pac_md_cumulos_conf.f_get_cons_cesionesrea';
      terror      VARCHAR2 (200)    := 'Error calculo consecutivo cesionesrea';
      v_scesrea   cesionesrea.scesrea%TYPE;
   BEGIN
      SELECT scesrea
        INTO v_scesrea
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND scontra = pscontra
         AND nversio = pnversio
         AND ctramo = pctramo
         AND nriesgo = pnriesgo
         AND NVL (ctrampa, 0) = NVL (pctrampa, 0)
         AND cgenera = pcgenera
         AND nmovimi = pnmovimi
         AND ROWNUM = 1;

      --
      RETURN v_scesrea;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Error calculo consecutivo cesionesrea',
                      SQLERRM
                     );
         RETURN 0;
   END f_get_cons_cesionesrea;

/*************************************************************************
    FUNCTION fun_cum_nories_tom
    Obtiene el cumulo en no riesgo total por tomador
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_nories_tom (p_nnumide IN VARCHAR2, p_fcorte IN DATE)
      RETURN NUMBER
   IS
      CURSOR cur_nories
      IS
         SELECT SUM (cum_ries)
           FROM (SELECT (SELECT NVL
                                   ((pac_eco_tipocambio.f_importe_cambio
                                        (mon.cmonint,
                                         (SELECT cmonint
                                            FROM monedas
                                           WHERE cidioma =
                                                    pac_md_common.f_get_cxtidioma
                                             AND cmoneda =
                                                    pac_parametros.f_parinstalacion_n
                                                                 ('MONEDAINST')),
                                         TO_DATE (TO_CHAR (p_fcorte,
                                                           'ddmmyyyy'
                                                          ),
                                                  'ddmmyyyy'
                                                 ),
                                         dcr.icapces
                                        )
                                    ),
                                    0
                                   )
                           FROM garanseg gar2, det_cesionesrea dcr
                          WHERE gar2.sseguro = dcr.sseguro
                            AND gar2.cgarant = dcr.cgarant
                            AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                         'ddmmyyyy'
                                        ) < gar2.finivig
                            AND dcr.sdetcesrea = dce.sdetcesrea
                            AND gar2.nmovimi =
                                          (SELECT MAX (nmovimi)
                                             FROM garanseg gar3
                                            WHERE gar2.sseguro = gar3.sseguro))
                                                                     cum_ries
                   FROM det_cesionesrea dce,
                        cesionesrea ces,
                        seguros seg,
                        monedas mon,
                        per_personas pe,
                        tomadores tom,
                        garanseg gar2
                  WHERE pe.nnumide = p_nnumide
                    AND tom.sperson = pe.sperson
                    AND tom.cdomici = 1
                    AND gar2.sseguro = dce.sseguro
                    AND gar2.cgarant = dce.cgarant
                    AND gar2.sseguro = dce.sseguro
                    AND gar2.cgarant = dce.cgarant
                    AND gar2.nriesgo = ces.nriesgo
                    AND gar2.nmovimi = ces.nmovimi
                    AND gar2.sseguro = ces.sseguro
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <
                                                                  gar2.finivig
                    AND gar2.nmovimi = (SELECT MAX (nmovimi)
                                          FROM garanseg gar3
                                         WHERE gar2.sseguro = gar3.sseguro)
                    AND tom.sseguro = ces.sseguro
                    --AND (   ces.fanulac >
                    --           TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                     --                   'ddmmyyyy'
                     --                  )
                      --   OR ces.fanulac IS NULL
                     --   )
                    AND (   ces.fregula >
                               TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                        'ddmmyyyy'
                                       )
                         OR ces.fregula IS NULL
                        )
                    AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
                    AND dce.sseguro = seg.sseguro
                    AND dce.scesrea = ces.scesrea
                    AND NVL (dce.cdepura, 'N') = 'N'
                    AND mon.cidioma = pac_md_common.f_get_cxtidioma
                    AND mon.cmoneda =
                                   pac_monedas.f_moneda_producto (seg.sproduc)
                 UNION ALL
                 SELECT (  (SELECT NVL
                                      ((pac_eco_tipocambio.f_importe_cambio
                                           (mon.cmonint,
                                            (SELECT cmonint
                                               FROM monedas
                                              WHERE cidioma =
                                                       pac_md_common.f_get_cxtidioma
                                                AND cmoneda =
                                                       pac_parametros.f_parinstalacion_n
                                                                 ('MONEDAINST')),
                                            TO_DATE (TO_CHAR (p_fcorte,
                                                              'ddmmyyyy'
                                                             ),
                                                     'ddmmyyyy'
                                                    ),
                                            dcr.icapces
                                           )
                                       ),
                                       0
                                      )
                              FROM garanseg gar2, det_cesionesrea dcr
                             WHERE gar2.sseguro = dcr.sseguro
                               AND gar2.cgarant = dcr.cgarant
                               AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                            'ddmmyyyy'
                                           ) < gar2.finivig
                               AND dcr.sdetcesrea = dce.sdetcesrea
                               AND gar2.nmovimi =
                                          (SELECT MAX (nmovimi)
                                             FROM garanseg gar3
                                            WHERE gar2.sseguro = gar3.sseguro))
                         * ppr.pparticipacion
                         / 100
                        ) cum_ries
                   FROM det_cesionesrea dce,
                        cesionesrea ces,
                        seguros seg,
                        monedas mon,
                        per_personas pe,
                        tomadores tom,
                        garanseg gar2,
                        per_personas_rel ppr
                  WHERE pe.nnumide = p_nnumide
                    AND pe.sperson = ppr.sperson_rel
                    AND ppr.sperson = tom.sperson
                    AND tom.sseguro = seg.sseguro
                    AND tom.cdomici = 1
                    AND seg.sseguro = ces.sseguro
                    AND ces.sseguro = dce.sseguro
                    AND ces.scesrea = dce.scesrea
                    AND gar2.sseguro = dce.sseguro
                    AND gar2.cgarant = dce.cgarant
                    AND gar2.nriesgo = ces.nriesgo
                    AND gar2.nmovimi = ces.nmovimi
                    AND gar2.sseguro = ces.sseguro
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <
                                                                  gar2.finivig
                    AND gar2.nmovimi = (SELECT MAX (nmovimi)
                                          FROM garanseg gar3
                                         WHERE gar2.sseguro = gar3.sseguro)
                    --AND (   ces.fanulac >
                     --          TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                     --                   'ddmmyyyy'
                     --                  )
                      --   OR ces.fanulac IS NULL
                      --  )
                    AND (   ces.fregula >
                               TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                        'ddmmyyyy'
                                       )
                         OR ces.fregula IS NULL
                        )
                    AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
                    AND NVL (dce.cdepura, 'N') = 'N'
                    AND mon.cidioma = pac_md_common.f_get_cxtidioma
                    AND mon.cmoneda =
                                   pac_monedas.f_moneda_producto (seg.sproduc));

      --
      v_nories   NUMBER;
   BEGIN
      OPEN cur_nories;

      FETCH cur_nories
       INTO v_nories;

      CLOSE cur_nories;

      --
      IF (v_nories IS NULL)
      THEN
         v_nories := 0;
      END IF;

      RETURN v_nories;
   END f_cum_nories_tom;

/*************************************************************************
    FUNCTION fun_cum_nories_serie
    Obtiene el cumulo en no riesgo total por tomador y anio/serie
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    param in p_serie       : anio/ serie
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_nories_serie (
      p_nnumide   IN   VARCHAR2,
      p_fcorte    IN   DATE,
      p_serie     IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      CURSOR cur_nories
      IS
         SELECT SUM
                   (NVL
                       ((pac_eco_tipocambio.f_importe_cambio
                                  (mon.cmonint,
                                   'COP',
                                   p_fcorte /*to_date('27022018','ddmmyyyy')*/,
                                   dce.icapces
                                  )
                        ),
                        0
                       )
                   )
           FROM det_cesionesrea dce,
                cesionesrea ces,
                seguros seg,
                monedas mon,
                per_personas pe,
                tomadores tom,
                garanseg gar2
          WHERE pe.nnumide = p_nnumide                            --'79950618'
            AND gar2.sseguro = dce.sseguro
            AND gar2.cgarant = dce.cgarant
            AND gar2.nriesgo = ces.nriesgo
            AND gar2.nmovimi = ces.nmovimi
            AND gar2.sseguro = ces.sseguro
            AND TO_CHAR (seg.fefecto, 'YYYY') = p_serie
            AND p_fcorte /*to_date('27022024','ddmmyyyy') */ > gar2.ffinvig
            AND gar2.nmovimi = (SELECT MAX (nmovimi)
                                  FROM garanseg gar3
                                 WHERE gar2.sseguro = gar3.sseguro)
            AND tom.sseguro = ces.sseguro
            AND tom.cdomici = 1
            AND pe.sperson = dce.sperson
            -- AND ces.fanulac IS NULL
            AND (   ces.fregula > p_fcorte    --to_date('27022024','ddmmyyyy')
                 OR ces.fregula IS NULL
                )
            AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
            AND dce.sseguro = seg.sseguro
            AND dce.scesrea = ces.scesrea
            AND NVL (dce.cdepura, 'N') = 'N'
            AND mon.cidioma = 8
            AND mon.cmoneda = pac_monedas.f_moneda_producto (seg.sproduc);

      --
      v_nories   NUMBER;
   BEGIN
      OPEN cur_nories;

      FETCH cur_nories
       INTO v_nories;

      CLOSE cur_nories;

      --
      IF (v_nories IS NULL)
      THEN
         v_nories := 0;
      END IF;

      RETURN v_nories;
   END f_cum_nories_serie;

   /*************************************************************************
    FUNCTION f_cum_total_tom
    Obtiene el cumulo total por tomador por tramo
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    param in p_ctramo       : tramo
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_total_tom(p_nnumide IN VARCHAR2,
                            p_fcorte  IN DATE,
                            p_ctramo  IN NUMBER DEFAULT NULL) -- IAXIS-12992 27/04/2020
    RETURN NUMBER IS
     -- 
     -- Inicio IAXIS-11903 05/02/2020
     --
     -- Notas de la versin:
     -- 1. Se vuelven a activar los filtros de la fecha de anulacin y regularizacin para no tener en cuenta las cesiones de las plizas anuladas
     --    en el clculo del cmulo durante la emisin.
     -- 2. Se excluyen los tipos de movimiento 6 (cesin por anulacin) para no sumar errneamente dichos valores de capital durante la emisin
     --    de una pliza o suplemento.
     -- 3. Se identa el cursor cur_total para ms fcil entendimiento y mantenimiento.
     --
     CURSOR cur_total IS
       SELECT SUM(cum_tot)
         FROM (SELECT nvl((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,
                                                               (SELECT cmonint
                                                                  FROM monedas
                                                                 WHERE cidioma =
                                                                       pac_md_common.f_get_cxtidioma
                                                                   AND cmoneda =
                                                                       pac_parametros.f_parinstalacion_n('MONEDAINST')),
                                                               to_date(to_char(p_fcorte,
                                                                               'ddmmyyyy'),
                                                                       'ddmmyyyy'),
                                                               dce.icapces)),
                          0) cum_tot
                 FROM det_cesionesrea dce,
                      cesionesrea     ces,
                      seguros         seg,
                      monedas         mon,
                      per_personas    pe,
                      tomadores       tom,
                      garanseg        gar2
                WHERE pe.nnumide = p_nnumide
                  AND tom.sperson = pe.sperson
                  AND tom.cdomici = 1
                  AND gar2.sseguro = dce.sseguro
                  AND gar2.cgarant = dce.cgarant
                  AND gar2.nriesgo = ces.nriesgo
                  AND gar2.nmovimi = ces.nmovimi
                  AND gar2.sseguro = ces.sseguro
                  AND to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                      gar2.ffinvig
                  AND gar2.nmovimi =
                      (SELECT MAX(nmovimi)
                         FROM garanseg gar3
                        WHERE gar2.sseguro = gar3.sseguro)
                  AND tom.sseguro = ces.sseguro
                  AND ces.fvencim >
                      to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') --IAXIS - 4773 FEPP
                  AND (ces.fanulac >
                      to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                      ces.fanulac IS NULL)
                  AND (ces.fregula >
                      to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                      ces.fregula IS NULL)
                  AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND dce.sseguro = seg.sseguro
                  AND seg.sseguro = ces.sseguro
                  AND dce.scesrea = ces.scesrea
                  AND nvl(dce.cdepura, 'N') = 'N'
                  AND mon.cidioma = pac_md_common.f_get_cxtidioma
                  AND mon.cmoneda =
                      pac_monedas.f_moneda_producto(seg.sproduc)
                  --    
                  -- Inicio IAXIS-12992 
                  --
                  AND (ces.ctramo = nvl(p_ctramo, ces.ctramo) OR
                      (ces.ctramo = 0 AND
                      ces.ctrampa = nvl(p_ctramo, ces.ctrampa)))
                  --    
                  -- Fin IAXIS-12992
                  --    
               /*UNION ALL
               SELECT (nvl((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,
                                                                (SELECT cmonint
                                                                   FROM monedas
                                                                  WHERE cidioma =
                                                                        pac_md_common.f_get_cxtidioma
                                                                    AND cmoneda =
                                                                        pac_parametros.f_parinstalacion_n('MONEDAINST')),
                                                                to_date(to_char(p_fcorte,
                                                                                'ddmmyyyy'),
                                                                        'ddmmyyyy'),
                                                                dce.icapces)),
                           0) * ppr.pparticipacion / 100) cum_tot
                 FROM det_cesionesrea  dce,
                      cesionesrea      ces,
                      seguros          seg,
                      monedas          mon,
                      per_personas     pe,
                      tomadores        tom,
                      garanseg         gar2,
                      per_personas_rel ppr
                WHERE pe.nnumide = p_nnumide
                  AND pe.sperson = ppr.sperson_rel
                  AND ppr.sperson = tom.sperson
                  AND tom.sseguro = seg.sseguro
                  AND tom.cdomici = 1
                  AND seg.sseguro = ces.sseguro
                  AND ces.sseguro = dce.sseguro
                  AND ces.scesrea = dce.scesrea
                  AND gar2.sseguro = dce.sseguro
                  AND gar2.cgarant = dce.cgarant
                  AND gar2.nriesgo = ces.nriesgo
                  AND gar2.nmovimi = ces.nmovimi
                  AND gar2.sseguro = ces.sseguro
                  AND to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                      gar2.ffinvig
                  AND gar2.nmovimi =
                      (SELECT MAX(nmovimi)
                         FROM garanseg gar3
                        WHERE gar2.sseguro = gar3.sseguro)
                  AND ces.fvencim >
                      to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') ---IAXIS - 4773 FEPP
                  AND (ces.fanulac >
                      to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                      ces.fanulac IS NULL)
                  AND (ces.fregula >
                      to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                      ces.fregula IS NULL)
                  AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND nvl(dce.cdepura, 'N') = 'N'
                  AND mon.cidioma = pac_md_common.f_get_cxtidioma
                  AND mon.cmoneda =
                      pac_monedas.f_moneda_producto(seg.sproduc)
                  --    
                  -- Inicio IAXIS-12992 
                  --
                  AND (ces.ctramo = nvl(p_ctramo, ces.ctramo) OR
                      (ces.ctramo = 0 AND
                      ces.ctrampa = nvl(p_ctramo, ces.ctrampa)))*/);
                  --    
                  -- Fin IAXIS-12992 
                  --     
     --
     -- Fin IAXIS-11903 05/02/2020
     -- 
     v_total NUMBER;
   BEGIN
     OPEN cur_total;
   
     FETCH cur_total
       INTO v_total;
   
     CLOSE cur_total;
     --
     IF (v_total IS NULL) THEN
       v_total := 0;
     END IF;
     
      RETURN v_total;
   END f_cum_total_tom;

/*************************************************************************
    FUNCTION f_cum_ries_tom
    Obtiene el cumulo en riesgo total por tomador
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_ries_tom (p_nnumide IN VARCHAR2, p_fcorte IN DATE)
      RETURN NUMBER
   IS
      CURSOR cur_ries
      IS
         SELECT SUM (cum_ries)
           FROM (SELECT (SELECT NVL
                                   ((pac_eco_tipocambio.f_importe_cambio
                                        (mon.cmonint,
                                         (SELECT cmonint
                                            FROM monedas
                                           WHERE cidioma =
                                                    pac_md_common.f_get_cxtidioma
                                             AND cmoneda =
                                                    pac_parametros.f_parinstalacion_n
                                                                 ('MONEDAINST')),
                                         TO_DATE (TO_CHAR (p_fcorte,
                                                           'ddmmyyyy'
                                                          ),
                                                  'ddmmyyyy'
                                                 ),
                                         dcr.icapces
                                        )
                                    ),
                                    0
                                   )
                           FROM garanseg gar2, det_cesionesrea dcr
                          WHERE gar2.sseguro = dcr.sseguro
                            AND gar2.cgarant = dcr.cgarant
                            AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                         'ddmmyyyy'
                                        ) >= gar2.finivig
                            AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                         'ddmmyyyy'
                                        ) <= gar2.ffinvig
                            AND dcr.sdetcesrea = dce.sdetcesrea
                            AND gar2.nmovimi =
                                          (SELECT MAX (nmovimi)
                                             FROM garanseg gar3
                                            WHERE gar2.sseguro = gar3.sseguro))
                                                                     cum_ries
                   FROM det_cesionesrea dce,
                        cesionesrea ces,
                        seguros seg,
                        monedas mon,
                        per_personas pe,
                        tomadores tom,
                        garanseg gar2
                  WHERE pe.nnumide = p_nnumide
                    AND tom.sperson = pe.sperson
                    AND tom.cdomici = 1
                    AND gar2.sseguro = dce.sseguro
                    AND gar2.cgarant = dce.cgarant
                    AND gar2.nriesgo = ces.nriesgo
                    AND gar2.nmovimi = ces.nmovimi
                    AND gar2.sseguro = ces.sseguro
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') >=
                                                                  gar2.finivig
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                                                                  gar2.ffinvig
                    AND gar2.nmovimi = (SELECT MAX (nmovimi)
                                          FROM garanseg gar3
                                         WHERE gar2.sseguro = gar3.sseguro)
                    AND tom.sseguro = ces.sseguro
                    --AND ces.fvencim > to_date(to_char(p_fcorte,'ddmmyyyy'),'ddmmyyyy')
                    --AND (   ces.fanulac >
                    --           TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                     --                   'ddmmyyyy'
                     --                  )
                     --    OR ces.fanulac IS NULL
                     --   )
                    AND (   ces.fregula >
                               TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                        'ddmmyyyy'
                                       )
                         OR ces.fregula IS NULL
                        )
                    AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
                    AND dce.sseguro = seg.sseguro
                    AND dce.scesrea = ces.scesrea
                    AND NVL (dce.cdepura, 'N') = 'N'
                    AND mon.cidioma = pac_md_common.f_get_cxtidioma
                    AND mon.cmoneda =
                                   pac_monedas.f_moneda_producto (seg.sproduc)
                 UNION ALL
                 SELECT (  (SELECT NVL
                                      ((pac_eco_tipocambio.f_importe_cambio
                                           (mon.cmonint,
                                            (SELECT cmonint
                                               FROM monedas
                                              WHERE cidioma =
                                                       pac_md_common.f_get_cxtidioma
                                                AND cmoneda =
                                                       pac_parametros.f_parinstalacion_n
                                                                 ('MONEDAINST')),
                                            TO_DATE (TO_CHAR (p_fcorte,
                                                              'ddmmyyyy'
                                                             ),
                                                     'ddmmyyyy'
                                                    ),
                                            dcr.icapces
                                           )
                                       ),
                                       0
                                      )
                              FROM garanseg gar2, det_cesionesrea dcr
                             WHERE gar2.sseguro = dcr.sseguro
                               AND gar2.cgarant = dcr.cgarant
                               AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                            'ddmmyyyy'
                                           ) >= gar2.finivig
                               AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                            'ddmmyyyy'
                                           ) <= gar2.ffinvig
                               AND dcr.sdetcesrea = dce.sdetcesrea
                               AND gar2.nmovimi =
                                          (SELECT MAX (nmovimi)
                                             FROM garanseg gar3
                                            WHERE gar2.sseguro = gar3.sseguro))
                         * ppr.pparticipacion
                         / 100
                        ) cum_ries
                   FROM det_cesionesrea dce,
                        cesionesrea ces,
                        seguros seg,
                        monedas mon,
                        per_personas pe,
                        tomadores tom,
                        garanseg gar2,
                        per_personas_rel ppr
                  WHERE pe.nnumide = p_nnumide
                    AND pe.sperson = ppr.sperson_rel
                    AND tom.sperson = ppr.sperson
                    AND tom.sseguro = seg.sseguro
                    AND tom.cdomici = 1
                    AND seg.sseguro = ces.sseguro
                    AND ces.sseguro = dce.sseguro
                    AND ces.scesrea = dce.scesrea
                    AND gar2.sseguro = dce.sseguro
                    AND gar2.cgarant = dce.cgarant
                    AND gar2.nriesgo = ces.nriesgo
                    AND gar2.nmovimi = ces.nmovimi
                    AND gar2.sseguro = ces.sseguro
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') >=
                                                                  gar2.finivig
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                                                                  gar2.ffinvig
                    AND gar2.nmovimi = (SELECT MAX (nmovimi)
                                          FROM garanseg gar3
                                         WHERE gar2.sseguro = gar3.sseguro)
                    AND ces.fvencim >
                           TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                    'ddmmyyyy')            --IAXIS - 4773 FEPP
                    --AND (   ces.fanulac >
                     --          TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                     --                   'ddmmyyyy'
                      --                 )
                      --   OR ces.fanulac IS NULL
                     --   )
                    AND (   ces.fregula >
                               TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                        'ddmmyyyy'
                                       )
                         OR ces.fregula IS NULL
                        )
                    AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
                    AND NVL (dce.cdepura, 'N') = 'N'
                    AND mon.cidioma = pac_md_common.f_get_cxtidioma
                    AND mon.cmoneda =
                                   pac_monedas.f_moneda_producto (seg.sproduc));

                      -- Fin IAXIS-4209 -- ECP-- 06/07/2019
      --
      v_ries   NUMBER;
   BEGIN
      OPEN cur_ries;

      FETCH cur_ries
       INTO v_ries;

      CLOSE cur_ries;

      --
      IF (v_ries IS NULL)
      THEN
         v_ries := 0;
      END IF;

      RETURN v_ries;
   END f_cum_ries_tom;

/*************************************************************************
    FUNCTION f_cum_ries_tom
    Obtiene el cumulo en riesgo total por tomador
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_riesgo (p_nnumide IN VARCHAR2, p_fcorte IN DATE)
      RETURN NUMBER
   IS
      CURSOR cur_ries
      IS
         SELECT SUM (cum_ries)
           FROM (SELECT (SELECT NVL
                                   ((pac_eco_tipocambio.f_importe_cambio
                                        (mon.cmonint,
                                         (SELECT cmonint
                                            FROM monedas
                                           WHERE cidioma =
                                                    pac_md_common.f_get_cxtidioma
                                             AND cmoneda =
                                                    pac_parametros.f_parinstalacion_n
                                                                 ('MONEDAINST')),
                                         TO_DATE (TO_CHAR (p_fcorte,
                                                           'ddmmyyyy'
                                                          ),
                                                  'ddmmyyyy'
                                                 ),
                                         dcr.icapces
                                        )
                                    ),
                                    0
                                   )
                           FROM garanseg gar2, det_cesionesrea dcr
                          WHERE gar2.sseguro = dcr.sseguro
                            AND gar2.cgarant = dcr.cgarant
                            AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                         'ddmmyyyy'
                                        ) >= gar2.finivig
                            AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                         'ddmmyyyy'
                                        ) <= gar2.ffinvig
                            AND dcr.sdetcesrea = dce.sdetcesrea
                            AND gar2.nmovimi =
                                          (SELECT MAX (nmovimi)
                                             FROM garanseg gar3
                                            WHERE gar2.sseguro = gar3.sseguro))
                                                                     cum_ries
                   FROM det_cesionesrea dce,
                        cesionesrea ces,
                        seguros seg,
                        monedas mon,
                        per_personas pe,
                        tomadores tom,
                        garanseg gar2
                  WHERE pe.nnumide = p_nnumide
                    AND tom.sperson = pe.sperson
                    AND tom.cdomici = 1
                    AND gar2.sseguro = dce.sseguro
                    AND gar2.cgarant = dce.cgarant
                    AND gar2.nriesgo = ces.nriesgo
                    AND gar2.nmovimi = ces.nmovimi
                    AND gar2.sseguro = ces.sseguro
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') >=
                                                                  gar2.finivig
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                                                                  gar2.ffinvig
                    AND gar2.nmovimi = (SELECT MAX (nmovimi)
                                          FROM garanseg gar3
                                         WHERE gar2.sseguro = gar3.sseguro)
                    AND tom.sseguro = ces.sseguro
                      --AND ces.fvencim > to_date(to_char(p_fcorte,'ddmmyyyy'),'ddmmyyyy')
                    --  AND (   ces.fanulac >
                     --            TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                     --                     'ddmmyyyy'
                     --                    )
                     --      OR ces.fanulac IS NULL
                     --     )
                    AND (   ces.fregula >
                               TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                        'ddmmyyyy'
                                       )
                         OR ces.fregula IS NULL
                        )
                    AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
                    AND dce.sseguro = seg.sseguro
                    --AND seg.csituac = 0
                    --AND seg.creteni = 0
                    AND seg.femisio >=
                           TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                    'ddmmyyyy')
                    AND seg.fvencim <=
                           TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                    'ddmmyyyy')
                    AND dce.scesrea = ces.scesrea
                    AND NVL (dce.cdepura, 'N') = 'N'
                    AND mon.cidioma = pac_md_common.f_get_cxtidioma
                    AND mon.cmoneda =
                                   pac_monedas.f_moneda_producto (seg.sproduc)
                 UNION ALL
                 SELECT (  (SELECT NVL
                                      ((pac_eco_tipocambio.f_importe_cambio
                                           (mon.cmonint,
                                            (SELECT cmonint
                                               FROM monedas
                                              WHERE cidioma =
                                                       pac_md_common.f_get_cxtidioma
                                                AND cmoneda =
                                                       pac_parametros.f_parinstalacion_n
                                                                 ('MONEDAINST')),
                                            TO_DATE (TO_CHAR (p_fcorte,
                                                              'ddmmyyyy'
                                                             ),
                                                     'ddmmyyyy'
                                                    ),
                                            dcr.icapces
                                           )
                                       ),
                                       0
                                      )
                              FROM garanseg gar2, det_cesionesrea dcr
                             WHERE gar2.sseguro = dcr.sseguro
                               AND gar2.cgarant = dcr.cgarant
                               AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                            'ddmmyyyy'
                                           ) >= gar2.finivig
                               AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                            'ddmmyyyy'
                                           ) <= gar2.ffinvig
                               AND dcr.sdetcesrea = dce.sdetcesrea
                               AND gar2.nmovimi =
                                          (SELECT MAX (nmovimi)
                                             FROM garanseg gar3
                                            WHERE gar2.sseguro = gar3.sseguro))
                         * ppr.pparticipacion
                         / 100
                        ) cum_ries
                   FROM det_cesionesrea dce,
                        cesionesrea ces,
                        seguros seg,
                        monedas mon,
                        per_personas pe,
                        tomadores tom,
                        garanseg gar2,
                        per_personas_rel ppr
                  WHERE pe.nnumide = p_nnumide
                    AND pe.sperson = ppr.sperson_rel
                    AND tom.sperson = ppr.sperson
                    AND tom.sseguro = seg.sseguro
                    AND tom.cdomici = 1
                    AND seg.sseguro = ces.sseguro
                    -- AND seg.csituac = 0
                    -- AND seg.creteni = 0
                    AND seg.femisio >=
                           TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                    'ddmmyyyy')
                    AND seg.fvencim <=
                           TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                    'ddmmyyyy')
                    AND ces.sseguro = dce.sseguro
                    AND ces.scesrea = dce.scesrea
                    AND gar2.sseguro = dce.sseguro
                    AND gar2.cgarant = dce.cgarant
                    AND gar2.nriesgo = ces.nriesgo
                    AND gar2.nmovimi = ces.nmovimi
                    AND gar2.sseguro = ces.sseguro
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') >=
                                                                  gar2.finivig
                    AND TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                                                                  gar2.ffinvig
                    AND gar2.nmovimi = (SELECT MAX (nmovimi)
                                          FROM garanseg gar3
                                         WHERE gar2.sseguro = gar3.sseguro)
                    --AND ces.fvencim > to_date(to_char(p_fcorte,'ddmmyyyy'),'ddmmyyyy')
                    --AND (   ces.fanulac >
                     --          TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                     --                   'ddmmyyyy'
                     --                  )
                     --    OR ces.fanulac IS NULL
                     --   )
                    AND (   ces.fregula >
                               TO_DATE (TO_CHAR (p_fcorte, 'ddmmyyyy'),
                                        'ddmmyyyy'
                                       )
                         OR ces.fregula IS NULL
                        )
                    AND ces.cgenera IN (1, 3, 4, 5, 6, 9, 10, 20, 40, 41)
                    AND NVL (dce.cdepura, 'N') = 'N'
                    AND mon.cidioma = pac_md_common.f_get_cxtidioma
                    AND mon.cmoneda =
                                   pac_monedas.f_moneda_producto (seg.sproduc));

                      -- Fin IAXIS-4209 -- ECP-- 06/07/2019
      --
      v_ries   NUMBER;
   BEGIN
      OPEN cur_ries;

      FETCH cur_ries
       INTO v_ries;

      CLOSE cur_ries;

      --
      IF (v_ries IS NULL)
      THEN
         v_ries := 0;
      END IF;

      RETURN v_ries;
   END f_cum_riesgo;
   --
   -- Inicio IAXIS-12992 27/04/2020
   --
   /*************************************************************************
    FUNCTION f_calcula_depuracion_pol
    Permite obtener por poliza el valor depurado automáticamente de la garantía
    de entrada. Se devuelve un valor diferente de 0 con el valor del capital de 
    la garantía si debe depurarse.
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param in psperson       : Tomador/Afianzado
    return                  : number
   *************************************************************************/
  FUNCTION f_calcula_depuracion_pol(pfcorte  IN DATE,
                                    psseguro IN NUMBER,
                                    pcgarant IN NUMBER,
                                    psperson IN NUMBER) RETURN NUMBER IS
    vpasexec      NUMBER(8) := 0;
    vparam        VARCHAR2(2000) := 'pfcorte=' || pfcorte || '-psseguro=' ||
                                    psseguro || '-pcgarant=' || pcgarant|| '-psperson=' || psperson;
    vobject       VARCHAR2(200) := 'pac_cumulos_conf.f_calcula_depuracion_pol';
    terror        VARCHAR2(200) := 'Error obtener depuración por póliza';
    v_consorcio   VARCHAR2(1);
    v_tomador     tomadores.sperson%TYPE;
    v_participa   NUMBER;
    v_depuaut     NUMBER := 0;
    vcoaseguro    NUMBER := 0;
    v_contract    NUMBER := 0;
    v_nocontra    NUMBER := 0;
    v_depu_tot    NUMBER := 0;
    v_sproduc     NUMBER;
    v_cactivi     NUMBER;
    v_salario     NUMBER := 0;
    v_nerror      NUMBER;
    v_n           NUMBER := 0;
    v_ctipgarant  NUMBER := 0;
    v_cagrupa     NUMBER := 0;
    --
    CURSOR c_garan IS
      SELECT gar.cgarant, gar.icapital
        FROM garanseg gar
       WHERE gar.sseguro = psseguro
         AND gar.icapital IS NOT NULL
         AND ffinefe IS NULL;
    --
    TYPE rgarant IS RECORD (
      cgarant    NUMBER   := 0,
      icapital   NUMBER   := 0,
      ctipvalpar NUMBER   := 0
    );
    --
    TYPE tgarant IS TABLE OF rgarant INDEX BY BINARY_INTEGER;
    --
    v_tgarant tgarant;
    --
  BEGIN
    --
    vpasexec := 2;
    --
    v_nerror  := pac_seguros.f_get_sproduc(psseguro, 'REA', v_sproduc);
    --
    vpasexec := 3;
    --
    v_nerror  := pac_seguros.f_get_cactivi(psseguro, NULL, NULL, 'REA', v_cactivi);
    --
    vpasexec := 4;
    --
    BEGIN
      SELECT nvl(c.ploccoa / 100, 0)
        INTO vcoaseguro
        FROM seguros s, coacuadro c
       WHERE s.sseguro = c.sseguro
         AND s.ctipcoa = 1
         AND c.ncuacoa =
             (SELECT MAX(ncuacoa) FROM coacuadro WHERE sseguro = s.sseguro)
         AND s.sseguro = psseguro;
    EXCEPTION
      WHEN OTHERS THEN
        vcoaseguro := 0;
    END;
    --
    vpasexec := 5;
    --
    IF vcoaseguro <> 0 THEN
      vcoaseguro := vcoaseguro;
    ELSE
      vcoaseguro := 1;
    END IF;
    
    v_contract := 0;
    v_nocontra := 0;

    FOR i IN c_garan LOOP
      --
      v_n := v_n + 1;
      --
      vpasexec := 6;
    
      v_ctipgarant := NVL(pac_iaxpar_productos.f_get_pargarantia('EXCONTRACTUAL',
                                                                   v_sproduc,
                                                                   i.cgarant,
                                                                   v_cactivi), 0);
      IF i.cgarant <> 7005 THEN -- Amparo de Pago de Salarios no se depura.
        IF v_ctipgarant <> 2 THEN
          v_contract := v_contract + (nvl(i.icapital, 0) * vcoaseguro);
        ELSE
          v_nocontra := v_nocontra + (nvl(i.icapital, 0) * vcoaseguro);
        END IF;
      END IF;
      --
      vpasexec := 7;
      --
      v_tgarant(v_n).cgarant    := i.cgarant;
      v_tgarant(v_n).icapital   := nvl(i.icapital, 0) * vcoaseguro;
      v_tgarant(v_n).ctipvalpar := v_ctipgarant;
      
    END LOOP;
    --
    vpasexec := 8;
    --
    IF v_contract >= v_nocontra THEN     
      --
      vpasexec := 10;
      --
      FOR i IN v_tgarant.FIRST .. v_tgarant.LAST LOOP
        IF v_tgarant(i).cgarant = pcgarant AND v_tgarant(i).ctipvalpar = 2 THEN 
          v_depuaut := v_tgarant(i).icapital;
        END IF;
      END LOOP;   
    ELSE
      --
      vpasexec := 11;
      --
      FOR i IN v_tgarant.FIRST .. v_tgarant.LAST LOOP
        IF v_tgarant(i).cgarant = pcgarant AND v_tgarant(i).ctipvalpar <> 2 THEN 
          v_depuaut := v_tgarant(i).icapital;
        END IF;
      END LOOP;
    END IF;
    
    v_depu_tot := v_depuaut;

    RETURN(v_depu_tot);
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  terror||' '||vparam,
                  SQLERRM);
      RETURN 0;
  END f_calcula_depuracion_pol;
  --
  /*************************************************************************
    FUNCTION f_calcula_depuracion_tramo
    Permite obtener la depuración por tramo para un contrato y versión en específico
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona
    param in psseugro       : seguro
    param in pscontra       : contrato de reaseguro
    param in pnversio       : versión del contrato
    param in pctramo        : tramo de contrato de reaseguro
    return                  : number
   *************************************************************************/
  FUNCTION f_calcula_depuracion_tramo(pfcorte  IN DATE,
                                      psperson IN NUMBER,
                                      psseguro IN NUMBER,
                                      pscontra IN NUMBER,
                                      pnversio IN NUMBER,
                                      pctramo  IN NUMBER)
  
   RETURN NUMBER IS
    vpasexec      NUMBER(8) := 0;
    vparam        VARCHAR2(2000) := 'pfcorte=' || pfcorte || '-psperson=' ||
                                    psperson || '-pscontra=' || pscontra || '-pnversio=' || pnversio ||
                                    '-pctramo=' || pctramo||'-psseguro=' || psseguro;
    vobject       VARCHAR2(200) := 'pac_cumulos_conf.f_calcula_depuracion_tramo';
    terror        VARCHAR2(200) := 'Error calculo depuración riesgo por tramos';
    v_cumries     NUMBER;
    v_cumries_tot NUMBER;
    v_depman      NUMBER;
    v_depauto     NUMBER;
    v_moninst     monedas.cmonint%TYPE; --moneda local
  
    CURSOR cur_depauto(pmoninst monedas.cmonint%TYPE) IS
      SELECT nvl(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(sproduc)),
                                                         pmoninst,
                                                         pfcorte,
                                                         nvl(depuaut, 0))),
                 0) depuaut
      
        FROM (SELECT seguro,
                     garan,
                     tramo,
                     SUM(pcesion) pcesion,
                     sproduc,
                     
                     pac_cumulos_conf.f_calcula_depuracion_pol(pfcorte,
                                                           seguro,
                                                           garan,
                                                           psperson) *
                     (SUM(pcesion) /
                      pac_cumulos_conf.f_get_porc_garantia(pfcorte,
                                                           psperson,
                                                           pscontra,
                                                           seguro,
                                                           garan)) depuaut
                FROM (SELECT dce.sseguro seguro,
                             dce.cgarant garan,
                             seg.sproduc,
                             decode(ces.ctramo,
                                    0,
                                    decode(nvl(ces.ctrampa, 0),
                                           0,
                                           ces.ctramo,
                                           ces.ctrampa),
                                    dce.ptramo) tramo,
                             SUM(dce.pcesion) pcesion
                        FROM det_cesionesrea dce,
                             cesionesrea     ces,
                             garanseg        gar,
                             seguros         seg,
                             tomadores       tom
                       WHERE dce.sseguro = gar.sseguro
                         AND dce.cgarant = gar.cgarant
                         AND dce.scesrea = ces.scesrea
                         AND ces.scontra = pscontra
                         AND ces.nversio = pnversio
                         AND (ces.ctramo = nvl(pctramo, ces.ctramo) OR
                             (ces.ctramo = 0 AND
                             ces.ctrampa = nvl(pctramo, ces.ctrampa)))
                         AND ces.fefecto <= pfcorte
                         AND ces.fvencim > pfcorte
                         AND pfcorte <= gar.ffinvig
                         AND (ces.fregula > pfcorte OR ces.fregula IS NULL)
                         AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                         AND (ces.fanulac > pfcorte OR ces.fanulac IS NULL)
                         AND nvl(cdepura, 'N') != 'S'
                         AND seg.sseguro = gar.sseguro
                         AND seg.sseguro = tom.sseguro
                         AND tom.sperson = psperson
                         AND seg.sseguro <> psseguro
                         AND gar.sseguro = ces.sseguro
                         AND gar.nmovimi = ces.nmovimi
                         AND gar.nriesgo = ces.nriesgo
                         AND gar.nmovimi =
                             (SELECT MAX(nmovimi)
                                FROM garanseg gar2
                               WHERE gar.sseguro = gar2.sseguro)
                       GROUP BY dce.sseguro,
                                dce.cgarant,
                                seg.sproduc,
                                decode(ces.ctramo,
                                       0,
                                       decode(nvl(ces.ctrampa, 0),
                                              0,
                                              ces.ctramo,
                                              ces.ctrampa),
                                       dce.ptramo))
               GROUP BY seguro, garan, tramo, sproduc);
  BEGIN
    --
    vpasexec := 1;
    --
    SELECT cmonint
      INTO v_moninst
      FROM monedas
     WHERE cidioma = pac_md_common.f_get_cxtidioma
       AND cmoneda = pac_parametros.f_parinstalacion_n('MONEDAINST');
    --
    vpasexec := 2;
    --
    OPEN cur_depauto(v_moninst);
    FETCH cur_depauto
      INTO v_depauto;
    CLOSE cur_depauto;
    --
    RETURN nvl(v_depauto, 0);
    --
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  terror||' '||vparam,
                  SQLERRM);
      RETURN 0;
  END f_calcula_depuracion_tramo;
  --
  /*************************************************************************
    FUNCTION f_cum_total_tom_tramo
    Obtiene el cumulo total del tomador/afianzado por tramo.
    param in p_sperson      : secuencia de persona (tomador/afianzado)
    param in p_fcorte       : fecha de corte
    param in p_sseguro      : seguro
    param in p_scontra      : contrato de reaseguro
    param in p_nversio      : versión del contrato
    param in p_ctramo       : tramo del contrato
    return                  : number
   *************************************************************************/
  FUNCTION f_cum_total_tom_tramo(p_sperson IN NUMBER,
                                 p_fcorte  IN DATE,
                                 p_sseguro IN NUMBER,
                                 p_scontra IN NUMBER,
                                 p_nversio IN NUMBER,
                                 p_ctramo  IN NUMBER) 
   RETURN NUMBER IS
   --
   vpasexec    NUMBER(8) := 0;
   vparam      VARCHAR2(2000) := 'p_sperson=' || p_sperson || '-p_fcorte=' ||
                                  p_fcorte || '-p_sseguro=' || p_sseguro || '-p_scontra=' || p_scontra ||
                                  '-p_nversio=' || p_nversio||'-p_ctramo=' || p_ctramo;
   vobject     VARCHAR2(200) := 'pac_cumulos_conf.f_cum_total_tom_tramo';
   terror      VARCHAR2(200) := 'Error calculo del cúmulo tomador por tramo';
    --
    CURSOR cur_total IS
      SELECT SUM(cum_tot)
        FROM (SELECT nvl((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,
                                                              (SELECT cmonint
                                                                 FROM monedas
                                                                WHERE cidioma =
                                                                      pac_md_common.f_get_cxtidioma
                                                                  AND cmoneda =
                                                                      pac_parametros.f_parinstalacion_n('MONEDAINST')),
                                                              to_date(to_char(p_fcorte,
                                                                              'ddmmyyyy'),
                                                                      'ddmmyyyy'),
                                                              dce.icapces)),
                         0) cum_tot
                FROM det_cesionesrea dce,
                     cesionesrea     ces,
                     seguros         seg,
                     monedas         mon,
                     per_personas    pe,
                     tomadores       tom,
                     garanseg        gar2
               WHERE pe.sperson = p_sperson
                 AND tom.sperson = pe.sperson
                 AND tom.cdomici = 1
                 AND gar2.sseguro = dce.sseguro
                 AND gar2.cgarant = dce.cgarant
                 AND gar2.nriesgo = ces.nriesgo
                 AND gar2.nmovimi = ces.nmovimi
                 AND gar2.sseguro = ces.sseguro
                 AND to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                     gar2.ffinvig
                 AND gar2.nmovimi =
                     (SELECT MAX(nmovimi)
                        FROM garanseg gar3
                       WHERE gar2.sseguro = gar3.sseguro)
                 AND tom.sseguro = ces.sseguro
                 AND ces.fvencim >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy')
                 AND (ces.fanulac >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                     ces.fanulac IS NULL)
                 AND (ces.fregula >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                     ces.fregula IS NULL)
                 AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                 AND dce.sseguro = seg.sseguro
                 AND seg.sseguro = ces.sseguro
                 AND seg.sseguro <> p_sseguro
                 AND dce.scesrea = ces.scesrea
                 AND nvl(dce.cdepura, 'N') = 'N'
                 AND mon.cidioma = pac_md_common.f_get_cxtidioma
                 AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                 AND ces.scontra = p_scontra
                 AND ces.nversio = p_nversio
                 AND (ces.ctramo = nvl(p_ctramo, ces.ctramo) OR
                     (ces.ctramo = 0 AND
                     ces.ctrampa = nvl(p_ctramo, ces.ctrampa)))
              /*
              Hasta que no se defina propiamente la funcionalidad para el cálculo de las acumulaciones de consorcios, uniones temporales 
              y grupos económicos el siguiente bloque de código se comentará para no afectar el rendimiento de la aplicación.
              UNION ALL
              SELECT (nvl((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,
                                                               (SELECT cmonint
                                                                  FROM monedas
                                                                 WHERE cidioma =
                                                                       pac_md_common.f_get_cxtidioma
                                                                   AND cmoneda =
                                                                       pac_parametros.f_parinstalacion_n('MONEDAINST')),
                                                               to_date(to_char(p_fcorte,
                                                                               'ddmmyyyy'),
                                                                       'ddmmyyyy'),
                                                               dce.icapces)),
                          0) * ppr.pparticipacion / 100) cum_tot
                FROM det_cesionesrea  dce,
                     cesionesrea      ces,
                     seguros          seg,
                     monedas          mon,
                     per_personas     pe,
                     tomadores        tom,
                     garanseg         gar2,
                     per_personas_rel ppr
               WHERE pe.sperson = p_sperson
                 AND pe.sperson = ppr.sperson_rel
                 AND ppr.sperson = tom.sperson
                 AND tom.sseguro = seg.sseguro
                 AND tom.cdomici = 1
                 AND seg.sseguro = ces.sseguro
                 AND seg.sseguro <> p_sseguro
                 AND ces.sseguro = dce.sseguro
                 AND ces.scesrea = dce.scesrea
                 AND gar2.sseguro = dce.sseguro
                 AND gar2.cgarant = dce.cgarant
                 AND gar2.nriesgo = ces.nriesgo
                 AND gar2.nmovimi = ces.nmovimi
                 AND gar2.sseguro = ces.sseguro
                 AND to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                     gar2.ffinvig
                 AND gar2.nmovimi =
                     (SELECT MAX(nmovimi)
                        FROM garanseg gar3
                       WHERE gar2.sseguro = gar3.sseguro)
                 AND ces.fvencim >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') ---IAXIS - 4773 FEPP
                 AND (ces.fanulac >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                     ces.fanulac IS NULL)
                 AND (ces.fregula >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                     ces.fregula IS NULL)
                 AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                 AND nvl(dce.cdepura, 'N') = 'N'
                 AND mon.cidioma = pac_md_common.f_get_cxtidioma
                 AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                 AND ces.scontra = p_scontra
                 AND ces.nversio = p_nversio
                 AND (ces.ctramo = nvl(p_ctramo, ces.ctramo) OR
                     (ces.ctramo = 0 AND
                     ces.ctrampa = nvl(p_ctramo, ces.ctrampa)))*/);
    --                  
    v_total NUMBER;
    --
  BEGIN
    --
    vpasexec := 1;
    --
    OPEN cur_total;
    --
    vpasexec := 2;
    --
    FETCH cur_total
      INTO v_total;
    --  
    vpasexec := 3;  
    --
    CLOSE cur_total;
    --
    IF (v_total IS NULL) THEN
      v_total := 0;
    END IF;
    --
    RETURN v_total;
  --  
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  terror||' '||vparam,
                  SQLERRM);
      RETURN 0;  
    
  END f_cum_total_tom_tramo;
  --
  /*************************************************************************
    FUNCTION f_cum_total_tom_otros
    Obtiene el cumulo total del tomador/afianzado proveniente de otras versiones del contrato de reaseguros 
    param in p_sperson      : secuencia de persona (tomador/afianzado)
    param in p_fcorte       : fecha de corte
    param in p_sseguro      : seguro
    param in p_scontra      : contrato de reaseguro
    param in p_nversio      : versión del contrato
    param in p_ctramo       : tramo del contrato
    return                  : number
   *************************************************************************/
  FUNCTION f_cum_total_tom_otros(p_sperson IN NUMBER,
                                 p_fcorte  IN DATE,
                                 p_sseguro IN NUMBER,
                                 p_scontra IN NUMBER,
                                 p_nversio IN NUMBER,
                                 p_ctramo  IN NUMBER) 
   RETURN NUMBER IS
    --
   vpasexec    NUMBER(8) := 0;
   vparam      VARCHAR2(2000) := 'p_sperson=' || p_sperson || '-p_fcorte=' ||
                                  p_fcorte || '-p_sseguro=' || p_sseguro || '-p_scontra=' || p_scontra ||
                                  '-p_nversio=' || p_nversio||'-p_ctramo=' || p_ctramo;
   vobject     VARCHAR2(200) := 'pac_cumulos_conf.f_cum_total_tom_otros';
   terror      VARCHAR2(200) := 'Error calculo del cúmulo tomador otras versiones';
    CURSOR cur_total IS
      SELECT SUM(cum_tot)
        FROM (SELECT nvl((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,
                                                              (SELECT cmonint
                                                                 FROM monedas
                                                                WHERE cidioma =
                                                                      pac_md_common.f_get_cxtidioma
                                                                  AND cmoneda =
                                                                      pac_parametros.f_parinstalacion_n('MONEDAINST')),
                                                              to_date(to_char(p_fcorte,
                                                                              'ddmmyyyy'),
                                                                      'ddmmyyyy'),
                                                              dce.icapces)),
                         0) cum_tot
                FROM det_cesionesrea dce,
                     cesionesrea     ces,
                     seguros         seg,
                     monedas         mon,
                     per_personas    pe,
                     tomadores       tom,
                     garanseg        gar2
               WHERE pe.sperson = p_sperson
                 AND tom.sperson = pe.sperson
                 AND tom.cdomici = 1
                 AND gar2.sseguro = dce.sseguro
                 AND gar2.cgarant = dce.cgarant
                 AND gar2.nriesgo = ces.nriesgo
                 AND gar2.nmovimi = ces.nmovimi
                 AND gar2.sseguro = ces.sseguro
                 AND to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                     gar2.ffinvig
                 AND gar2.nmovimi =
                     (SELECT MAX(nmovimi)
                        FROM garanseg gar3
                       WHERE gar2.sseguro = gar3.sseguro)
                 AND tom.sseguro = ces.sseguro
                 AND ces.fvencim >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy')
                 AND (ces.fanulac >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                     ces.fanulac IS NULL)
                 AND (ces.fregula >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                     ces.fregula IS NULL)
                 AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                 AND dce.sseguro = seg.sseguro
                 AND seg.sseguro = ces.sseguro
                 AND seg.sseguro <> p_sseguro
                 AND dce.scesrea = ces.scesrea
                 AND nvl(dce.cdepura, 'N') = 'N'
                 AND mon.cidioma = pac_md_common.f_get_cxtidioma
                 AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                 AND ces.scontra = p_scontra
                 AND ces.nversio <> p_nversio
                 AND (ces.ctramo = nvl(p_ctramo, ces.ctramo) OR
                     (ces.ctramo = 0 AND
                     ces.ctrampa = nvl(p_ctramo, ces.ctrampa)))
              /*
              Hasta que no se defina propiamente la funcionalidad para el cálculo de las acumulaciones de consorcios, uniones temporales 
              y grupos económicos el siguiente bloque de código se comentará para no afectar el rendimiento de la aplicación.
              UNION ALL
              SELECT (nvl((pac_eco_tipocambio.f_importe_cambio(mon.cmonint,
                                                               (SELECT cmonint
                                                                  FROM monedas
                                                                 WHERE cidioma =
                                                                       pac_md_common.f_get_cxtidioma
                                                                   AND cmoneda =
                                                                       pac_parametros.f_parinstalacion_n('MONEDAINST')),
                                                               to_date(to_char(p_fcorte,
                                                                               'ddmmyyyy'),
                                                                       'ddmmyyyy'),
                                                               dce.icapces)),
                          0) * ppr.pparticipacion / 100) cum_tot
                FROM det_cesionesrea  dce,
                     cesionesrea      ces,
                     seguros          seg,
                     monedas          mon,
                     per_personas     pe,
                     tomadores        tom,
                     garanseg         gar2,
                     per_personas_rel ppr
               WHERE pe.sperson = p_sperson
                 AND pe.sperson = ppr.sperson_rel
                 AND ppr.sperson = tom.sperson
                 AND tom.sseguro = seg.sseguro
                 AND tom.cdomici = 1
                 AND seg.sseguro = ces.sseguro
                 AND seg.sseguro <> p_sseguro
                 AND ces.sseguro = dce.sseguro
                 AND ces.scesrea = dce.scesrea
                 AND gar2.sseguro = dce.sseguro
                 AND gar2.cgarant = dce.cgarant
                 AND gar2.nriesgo = ces.nriesgo
                 AND gar2.nmovimi = ces.nmovimi
                 AND gar2.sseguro = ces.sseguro
                 AND to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') <=
                     gar2.ffinvig
                 AND gar2.nmovimi =
                     (SELECT MAX(nmovimi)
                        FROM garanseg gar3
                       WHERE gar2.sseguro = gar3.sseguro)
                 AND ces.fvencim >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') ---IAXIS - 4773 FEPP
                 AND (ces.fanulac >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                     ces.fanulac IS NULL)
                 AND (ces.fregula >
                     to_date(to_char(p_fcorte, 'ddmmyyyy'), 'ddmmyyyy') OR
                     ces.fregula IS NULL)
                 AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                 AND nvl(dce.cdepura, 'N') = 'N'
                 AND mon.cidioma = pac_md_common.f_get_cxtidioma
                 AND mon.cmoneda = pac_monedas.f_moneda_producto(seg.sproduc)
                 AND ces.scontra = p_scontra
                 AND ces.nversio <> p_nversio
                 AND (ces.ctramo = nvl(p_ctramo, ces.ctramo) OR
                     (ces.ctramo = 0 AND
                     ces.ctrampa = nvl(p_ctramo, ces.ctrampa)))*/);
    --                  
    v_total NUMBER;
    --
  BEGIN
    --
    vpasexec := 1;
    --
    OPEN cur_total;
    --
    vpasexec := 2;
    --
    FETCH cur_total
      INTO v_total;
    --
    vpasexec := 3;
    --
    CLOSE cur_total;
    --
    IF (v_total IS NULL) THEN
      v_total := 0;
    END IF;

    RETURN v_total;
  --  
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  terror||' '||vparam,
                  SQLERRM);
      RETURN 0;  
  END f_cum_total_tom_otros;
  --
  /*************************************************************************
    FUNCTION f_calcula_depuracion_otros
    Obtiene la depuración proveniente de otras versiones del contrato de reaseguros 
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona
    param in psseguro       : seguro
    param in pscontra       : contrato de reaseguro
    param in pnversio       : versión del contrato
    param in pctramo        : tramo de contrato de reaseguro
    return                  : number
   *************************************************************************/
  FUNCTION f_calcula_depuracion_otros(pfcorte  IN DATE,
                                      psperson IN NUMBER,
                                      psseguro IN NUMBER,
                                      pscontra IN NUMBER,
                                      pnversio IN NUMBER,
                                      pctramo  IN NUMBER)
  
   RETURN NUMBER IS
    vpasexec      NUMBER(8) := 0;
    vparam        VARCHAR2(2000) := 'pfcorte=' || pfcorte || '-psperson=' ||
                                    psperson || '-pscontra=' || pscontra ||'-pnversio=' || pnversio ||
                                    '-pctramo=' || pctramo||'-psseguro=' || psseguro;
    vobject       VARCHAR2(200) := 'pac_cumulos_conf.f_calcula_depuracion_otros';
    terror        VARCHAR2(200) := 'Error calculo depuración riesgo otras versioens';
    v_cumries     NUMBER;
    v_cumries_tot NUMBER;
    v_depman      NUMBER;
    v_depauto     NUMBER;
    v_moninst     monedas.cmonint%TYPE; --moneda local
  
    CURSOR cur_depauto(pmoninst monedas.cmonint%TYPE) IS
      SELECT nvl(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(sproduc)),
                                                         pmoninst,
                                                         pfcorte,
                                                         nvl(depuaut, 0))),
                 0) depuaut
      
        FROM (SELECT seguro,
                     garan,
                     tramo,
                     SUM(pcesion) pcesion,
                     sproduc,
                     
                     pac_cumulos_conf.f_calcula_depuracion_pol(pfcorte,
                                                           seguro,
                                                           garan,
                                                           psperson) *
                     (SUM(pcesion) /
                      pac_cumulos_conf.f_get_porc_garantia(pfcorte,
                                                           psperson,
                                                           pscontra,
                                                           seguro,
                                                           garan)) depuaut
                FROM (SELECT dce.sseguro seguro,
                             dce.cgarant garan,
                             seg.sproduc,
                             decode(ces.ctramo,
                                    0,
                                    decode(nvl(ces.ctrampa, 0),
                                           0,
                                           ces.ctramo,
                                           ces.ctrampa),
                                    dce.ptramo) tramo,
                             SUM(dce.pcesion) pcesion
                        FROM det_cesionesrea dce,
                             cesionesrea     ces,
                             garanseg        gar,
                             seguros         seg,
                             tomadores       tom
                       WHERE dce.sseguro = gar.sseguro
                         AND dce.cgarant = gar.cgarant
                         AND dce.scesrea = ces.scesrea
                         AND ces.scontra = pscontra
                         AND ces.nversio <> pnversio
                         AND (ces.ctramo = nvl(pctramo, ces.ctramo) OR
                             (ces.ctramo = 0 AND
                             ces.ctrampa = nvl(pctramo, ces.ctrampa)))
                         AND ces.fefecto <= pfcorte
                         AND ces.fvencim > pfcorte
                         AND pfcorte <= gar.ffinvig
                         AND (ces.fregula > pfcorte OR ces.fregula IS NULL)
                         AND ces.cgenera IN (1, 3, 4, 5, 9, 10, 20, 40, 41)
                         AND (ces.fanulac > pfcorte OR ces.fanulac IS NULL)
                         AND nvl(cdepura, 'N') != 'S'
                         AND seg.sseguro = gar.sseguro
                         AND seg.sseguro = tom.sseguro
                         AND tom.sperson = psperson
                         AND seg.sseguro <> psseguro
                         AND gar.sseguro = ces.sseguro
                         AND gar.nmovimi = ces.nmovimi
                         AND gar.nriesgo = ces.nriesgo
                         AND gar.nmovimi =
                             (SELECT MAX(nmovimi)
                                FROM garanseg gar2
                               WHERE gar.sseguro = gar2.sseguro)
                       GROUP BY dce.sseguro,
                                dce.cgarant,
                                seg.sproduc,
                                decode(ces.ctramo,
                                       0,
                                       decode(nvl(ces.ctrampa, 0),
                                              0,
                                              ces.ctramo,
                                              ces.ctrampa),
                                       dce.ptramo))
               GROUP BY seguro, garan, tramo, sproduc);
  BEGIN
    --
    vpasexec    := 1;
    --
    SELECT cmonint
      INTO v_moninst
      FROM monedas
     WHERE cidioma = pac_md_common.f_get_cxtidioma
       AND cmoneda = pac_parametros.f_parinstalacion_n('MONEDAINST');
    --
    vpasexec    := 2;
    --
    OPEN cur_depauto(v_moninst);
    FETCH cur_depauto
      INTO v_depauto;
    CLOSE cur_depauto;
    --
    RETURN nvl(v_depauto, 0);
    --
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  terror||' '||vparam,
                  SQLERRM);
      RETURN 0;
  END f_calcula_depuracion_otros;  
--
-- Fin IAXIS-12992 27/04/2020
--
END pac_cumulos_conf;
/