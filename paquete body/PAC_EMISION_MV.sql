--------------------------------------------------------
--  DDL for Package Body PAC_EMISION_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_EMISION_MV" 
IS
  /****************************************************************************
  NOMBRE:       PAC_EMISION_MV
  PROPÓSITO:
  REVISIONES:
  Ver        Fecha        Autor             Descripción
  ---------  ----------  ---------------  ----------------------------------
  1.0        ********    **               1. Creación del package.
  2.0        25/02/2009  XCG              2. Modificació dels literals
  3.0        13/03/2009  DRA              3. 0009448: IAX - Retenció de pòlisses al realitzar un suplement d'augment de capital si preguntes afirmatives qüestionari
  4.0        30/03/2009  DRA              4. 0009620: CIV - TAR - Cambios parametrización producto
  5.0        30/03/2009  DRA              5. 0009640: IAX - Modificar missatge de retenció de pòlisses pendents de facultatiu
  6.0        17/09/2009  RSC              6. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
  7.0        30/09/2009  DRA              7. 0011183: CRE - Suplemento de alta de asegurado ya existente
  8.0        16/10/2009  NMM              8. 11457: CEM - Retención de pólizas según profesión
  9.0        01/01/2010  NMM              9. 12712: CEM - Retencion de pólizas, distinguir IMC de cuestionario.
  10.0       23/04/2010  JGR              10. 14268: CRE - Incorreccions en les retencions per IMC d'una pòlissa Credit Salut
  11.0       28/04/2010  DRA              11. 0014308: AGA008 - VIDA RISC GENERALS: Ajustar parametrització dels 2 productes.
  12.0       26/05/2010  DRA              12. 0011288: CRE - Modificación de propuestas retenidas
  13.0       26/08/2010  ICV              13. 0015811: CRE800 - Suplement de salut que no reté pòlissa per preguntes afirmatives
  14.0       26/11/2010  DRA              14. 0016804: CRT101 - Validación en producto Groupama Averia Maquinaria
  15.0       16/03/2011  DRA              15. 0018011: CRE998 - Canvi en sistema de retenció productes PIAM i CREDIT SALUT
  16.0       21/07/2011  APD              16. 0019114: CRE800 - Índex de masa corporal - pregunta 9
  17.0       20/11/2012  FAL              17. 0024058: LCOL_T010-LCOL - Parametrizaci?n de productos Vida Grupo
  18.0       24/12/2012  AMJ              18. 0024722: (POSDE600)-Desarrollo-GAPS Tecnico-Id 176 - Numero de Anexo en Impresion
  19.0       17/07/2013  DCT              19. 0027505: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Generales
  20.0       30/04/2014  FAL              20. 0027642: RSA102 - Producto Tradicional
  21.0       21/05/2014  AGG              21. 0028992: (POSPG400)-Parametrizacion
  22.0       04/07/2014  FAL              22. 0032059: Incidencias detectadas en iAXIS
  ****************************************************************************/
  FUNCTION f_retener_poliza(
      ptablas  IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pcreteni IN NUMBER,
      pfecha   IN DATE )
    RETURN NUMBER
  IS
    /*********************************************************************************************
    F_RETENER_POLIZA_MV:
    INSERTARÁ EN LA TABLA motretencion EL MOTIVO DE RETENCIÓN Y CAMBIARÁ EL ESTADO
    DE LA POLIZA.
    13/11/2003 YIL.
    *********************************************************************************************/
    n_nmotret     NUMBER;
    vpasexec      NUMBER(10);
    v_existe      NUMBER;
    vparampsu     NUMBER;
    vsproduc      NUMBER;
    vccontrol     NUMBER;
    vcempres      NUMBER;
    vcnivel       NUMBER;
    vnvalinf      NUMBER;
    vnvalsup      NUMBER;
    vcidioma      NUMBER;
    vautmanual    VARCHAR2(50);
    vestabloquea  VARCHAR2(50);
    vordenbloquea NUMBER;
    vautoriprev   VARCHAR2(50);
    vcnivelu      NUMBER;
    vnocurre      NUMBER;
    vcreteni      NUMBER;
    v_cestadocua  NUMBER:=0;
  BEGIN
    IF ptablas ='EST' THEN
      vpasexec:=1;
      SELECT sproduc,
        cempres,
        cidioma
      INTO vsproduc,
        vcempres,
        vcidioma
      FROM estseguros
      WHERE sseguro       =psseguro;
      vparampsu          :=pac_parametros.f_parproducto_n(vsproduc, 'PSU');
      IF NVL(vparampsu, 0)=0 THEN
        /* BUG18011:DRA:18/03/2011:Inici*/
        SELECT COUNT(1)
        INTO v_existe
        FROM estmotretencion
        WHERE sseguro=psseguro
        AND nmovimi  =pnmovimi
        AND nriesgo  =pnriesgo
        AND cmotret  =pcmotret;
        IF v_existe  =0 THEN
          vpasexec  :=2;
          BEGIN
            SELECT NVL(MAX(nmotret), 0)+1
            INTO n_nmotret
            FROM estmotretencion
            WHERE sseguro=psseguro
            AND nmovimi  =pnmovimi
            AND nriesgo  =pnriesgo;
          END;
          BEGIN
            vpasexec:=3;
            /* insertamos la retención*/
            INSERT
            INTO estmotretencion
              (
                nmotret,
                sseguro,
                nriesgo,
                nmovimi,
                cmotret,
                cusuret,
                freten
              )
              VALUES
              (
                n_nmotret,
                psseguro,
                pnriesgo,
                pnmovimi,
                pcmotret,
                f_user,
                pfecha
              );
            /* actualizamos seguros a retenido*/
            UPDATE estseguros
            SET creteni  =pcreteni
            WHERE sseguro=psseguro;
          EXCEPTION
          WHEN OTHERS THEN
            RETURN 107801;
            /* Error al calcular la retención*/
          END;
        END IF;
        /* BUG18011:DRA:18/03/2011:Fi*/
      ELSE
        /* Si es PSU grabamos un control para el CMOTRET, para cada empresa que*/
        /*tenga la psu activada deberemos ponerle un control por defecto para cuando*/
        /*la emisión de la póliza nos dé un error.*/
        vccontrol    :=pac_parametros.f_parempresa_n(vcempres, 'CONROLPSU_RETENCIO');
        IF vccontrol IS NOT NULL THEN
          /*Obtenim les dades d'aquest control que s'ha parametritzat a parempresas*/
          SELECT autmanual,
            establoquea,
            ordenbloquea,
            autoriprev,
            pnc.cnivel,
            pnc.nvalinf,
            pnc.nvalsup
          INTO vautmanual,
            vestabloquea,
            vordenbloquea,
            vautoriprev,
            vcnivel,
            vnvalinf,
            vnvalsup
          FROM psu_controlpro pp,
            estseguros e,
            psu_nivel_control pnc
          WHERE e.sseguro =psseguro
          AND e.sproduc   =pp.sproduc
          AND pnc.ccontrol=pp.ccontrol
          AND pnc.sproduc =pp.sproduc
          AND pp.ccontrol =vccontrol
          AND pnc.cnivel  =
            (SELECT MAX(cnivel)
            FROM psu_nivel_control pnc2
            WHERE pnc2.ccontrol=pp.ccontrol
            AND pnc2.sproduc   =pp.sproduc
            );
          p_tab_error(f_sysdate, f_user, 'pac_emision_mv', 11, 'pnc.cnivel: ' || vcnivel, NULL);
          p_tab_error(f_sysdate, f_user, 'pac_emision_mv', 11, 'vccontrol: ' || vccontrol, NULL);
          vcnivelu:=pac_psu.f_nivel_usuari_psu(f_user, vsproduc);
          SELECT NVL(MAX(nocurre), 1)
          INTO vnocurre
          FROM estpsucontrolseg
          WHERE sseguro=psseguro
          AND nmovimi  =pnmovimi;
          /*esborrem el control d'error per si ha saltat quan s'ha llençat el procés*/
          DELETE estpsucontrolseg
          WHERE ccontrol=vccontrol
          AND sseguro   =psseguro
          AND nmovimi   =NVL(pnmovimi, 1)
          AND nocurre   =NVL(vnocurre, 1);
          /*Deixem el control com pendent d'autoritzar i actualitzem el psu_retenidas,*/
          /*a la descripció ens mostrarà el que pertany al cmotret.*/
          BEGIN
            INSERT
            INTO estpsucontrolseg
              (
                sseguro,
                nmovimi,
                fmovpsu,
                ccontrol,
                nriesgo,
                cgarant,
                cnivelr,
                nvalor,
                cusumov,
                cnivelu,
                cautrec,
                establoquea,
                ordenbloquea,
                autoriprev,
                fautrec,
                cusuaur,
                observ,
                nocurre,
                nvalorinf,
                nvalorsuper,
                autmanual,
                nvalortope,
                isvisible
              )
              VALUES
              (
                psseguro,
                pnmovimi,
                f_sysdate,
                vccontrol,
                NVL(pnriesgo, 1),
                0,
                vcnivel,
                vnvalsup,
                f_user,
                vcnivelu,
                0,
                vestabloquea,
                vordenbloquea,
                vautoriprev,
                f_sysdate,
                f_user,
                ff_desvalorfijo(708, vcidioma, pcmotret),
                vnocurre,
                vnvalinf,
                vnvalsup,
                vautmanual,
                vnvalsup,
                1
              );
            vcreteni:=pac_psu.f_grabar_retenidas('EST', psseguro, NULL, NULL, NULL, NULL, NULL, vcidioma);
            /* actualizamos seguros a retenido*/
            UPDATE estseguros
            SET creteni=2
              /*retenim la pòlissa amb valor 2*/
            WHERE sseguro=psseguro;
          EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.f_retener_poliza EST', 1, 'insertando psucontrolseg', 'error vccontrol.:' || vccontrol || ':vcnivel.:' || vcnivel || ':vnvalsup.:' || vnvalsup || ':vcnivelu.:' || vcnivelu || ':vestabloquea.:' || vestabloquea || ':vordenbloquea.:' || vordenbloquea || ':vautoriprev.:' || vautoriprev || ':vnocurre.:' || vnocurre || ':vnvalinf.:' || vnvalinf || ':vnvalsup.:' || vnvalsup || ':vautmanual.:' || vautmanual || ':vnvalsup.:' || vnvalsup || ',psseguro:' || psseguro || ',pnmovimi:' || pnmovimi);
            p_tab_error(f_sysdate, f_user, 'PAC_EMISION.MV.f_retener_poliza EST psu', vpasexec, SQLERRM, SQLCODE);
            RETURN 107801;
            /* Error al calcular la retención*/
          END;
        ELSE
          RETURN 107801;
          /* Error al calcular la retención*/
        END IF;
      END IF;
    ELSE
      vpasexec:=11;
      vpasexec:=1;
      SELECT sproduc,
        cempres,
        cidioma
      INTO vsproduc,
        vcempres,
        vcidioma
      FROM seguros
      WHERE sseguro       =psseguro;
      vparampsu          :=pac_parametros.f_parproducto_n(vsproduc, 'PSU');
      IF NVL(vparampsu, 0)=0 THEN
        /* BUG18011:DRA:18/03/2011:Inici*/
        SELECT COUNT(1)
        INTO v_existe
        FROM motretencion
        WHERE sseguro=psseguro
        AND nmovimi  =pnmovimi
        AND nriesgo  =pnriesgo
        AND cmotret  =pcmotret;
        IF v_existe  =0 THEN
          vpasexec  :=12;
          BEGIN
            BEGIN
              SELECT NVL(MAX(nmotret), 0)+1
              INTO n_nmotret
              FROM motretencion
              WHERE sseguro=psseguro
              AND nmovimi  =pnmovimi
              AND nriesgo  =pnriesgo;
              /* AND cmotret = pcmotret;  -- BUG18011:DRA:18/03/2011*/
            END;
            vpasexec:=13;
            /* insertamos la retención*/
            INSERT
            INTO motretencion
              (
                sseguro,
                nriesgo,
                nmovimi,
                cmotret,
                cusuret,
                freten,
                nmotret
              )
              VALUES
              (
                psseguro,
                pnriesgo,
                pnmovimi,
                pcmotret,
                f_user,
                pfecha,
                n_nmotret
              );
            /* actualizamos seguros a retenido*/
            UPDATE seguros
            SET creteni  =pcreteni
            WHERE sseguro=psseguro;
          EXCEPTION
          WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_EMISION.MV.f_retener_poliza', vpasexec, SQLERRM, SQLCODE);
            p_tab_error(f_sysdate, f_user, 'PAC_EMISION.MV.f_retener_poliza', vpasexec, 'psseguro - pnriesgo - pnmovimi - pcmotret - F_USER', psseguro || ' - ' || pnmovimi || ' - ' || pcmotret || ' - ' || f_user);
            RETURN 107801;
            /* Error al calcular la retención*/
          END;
        END IF;
      ELSE
        /* Si es PSU grabamos un control para el CMOTRET, para cada empresa que*/
        /*tenga la psu activada deberemos ponerle un control por defecto para cuando*/
        /*la emisión de la póliza nos dé un error.*/
        vccontrol    :=pac_parametros.f_parempresa_n(vcempres, 'CONROLPSU_RETENCIO');
        IF vccontrol IS NOT NULL THEN
          BEGIN
            /* BUG 24058/0129453 - FAL - 20/11/2012            Controlar el NO_DATA_FOUND*/
            /*Obtenim les dades d'aquest control que s'ha parametritzat a parempresas*/
            SELECT autmanual,
              establoquea,
              ordenbloquea,
              autoriprev,
              pnc.cnivel,
              pnc.nvalinf,
              pnc.nvalsup
            INTO vautmanual,
              vestabloquea,
              vordenbloquea,
              vautoriprev,
              vcnivel,
              vnvalinf,
              vnvalsup
            FROM psu_controlpro pp,
              seguros e,
              psu_nivel_control pnc
            WHERE e.sseguro =psseguro
            AND e.sproduc   =pp.sproduc
            AND pnc.ccontrol=pp.ccontrol
            AND pnc.sproduc =pp.sproduc
            AND pp.ccontrol =vccontrol
            AND pnc.cnivel  =
              (SELECT MAX(cnivel)
              FROM psu_nivel_control pnc2
              WHERE pnc2.ccontrol=pp.ccontrol
              AND pnc2.sproduc   =pp.sproduc
              );
            /* BUG 24058/0129453 - FAL - 20/11/2012            Controlar el error*/
          EXCEPTION
          WHEN no_data_found THEN
            p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.f_retener_poliza POL', 1, 'recuperando psu_controlpro', 'error vccontrol.:' || vccontrol || ',psseguro:' || psseguro);
            RETURN 9904548;
          END;
          /* FI BUG 24058/0129453*/
          vcnivelu := pac_psu.f_nivel_usuari_psu(f_user, vsproduc);
          SELECT NVL(MAX(nocurre), 1)
          INTO vnocurre
          FROM psucontrolseg
          WHERE sseguro = psseguro
          AND nmovimi   = pnmovimi;
          DELETE psucontrolseg
          WHERE ccontrol = vccontrol
          AND sseguro    = psseguro
          AND nmovimi    = NVL(pnmovimi, 1)
          AND nocurre    = NVL(vnocurre, 1);
          /*AGG 21/05/2014 si el motret es  distinto de "Pendiente de cuadro facultativo"*/
          /*el procedimiento es el que había hasta ahora*/
          IF pcmotret <> 10
            /*Detvalores = 708*/
            THEN
            BEGIN
              INSERT
              INTO psucontrolseg
                (
                  sseguro,
                  nmovimi,
                  fmovpsu,
                  ccontrol,
                  nriesgo,
                  cgarant,
                  cnivelr,
                  nvalor,
                  cusumov,
                  cnivelu,
                  cautrec,
                  establoquea,
                  ordenbloquea,
                  autoriprev,
                  fautrec,
                  cusuaur,
                  observ,
                  nocurre,
                  nvalorinf,
                  nvalorsuper,
                  autmanual,
                  nvalortope,
                  isvisible
                )
                VALUES
                (
                  psseguro,
                  pnmovimi,
                  f_sysdate,
                  vccontrol,
                  NVL(pnriesgo, 1),
                  0,
                  vcnivel,
                  vnvalsup,
                  f_user,
                  vcnivelu,
                  0,
                  vestabloquea,
                  vordenbloquea,
                  vautoriprev,
                  f_sysdate,
                  f_user,
                  ff_desvalorfijo(708, vcidioma, pcmotret),
                  vnocurre,
                  vnvalinf,
                  vnvalsup,
                  vautmanual,
                  vnvalsup,
                  1
                );
              vcreteni := pac_psu.f_grabar_retenidas('POL', psseguro, NULL, NULL, NULL, NULL, NULL, vcidioma);
              /* actualizamos seguros a retenido*/
              UPDATE seguros
              SET creteni = 2
                /*retenim la pòlissa amb valor 2*/
              WHERE sseguro = psseguro;
            EXCEPTION
            WHEN OTHERS THEN
              p_tab_error(f_sysdate, f_user, 'PAC_EMISION.MV.f_retener_poliza POL psu', vpasexec, SQLERRM, SQLCODE);
              p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.f_retener_poliza POL', 1, 'insertando psucontrolseg', 'error vccontrol.:'|| vccontrol|| ':vcnivel.:'|| vcnivel|| ':vnvalsup.:'|| vnvalsup|| ':vcnivelu.:'|| vcnivelu|| ':vestabloquea.:'|| vestabloquea|| ':vordenbloquea.:'|| vordenbloquea|| ':vautoriprev.:'|| vautoriprev|| ':vnocurre.:'|| vnocurre|| ':vnvalinf.:'|| vnvalinf|| ':vnvalsup.:'|| vnvalsup|| ':vautmanual.:'|| vautmanual|| ':vnvalsup.:'|| vnvalsup|| ',psseguro:'|| psseguro|| ',pnmovimi:'|| pnmovimi);
              RETURN 107801;
              /* Error al calcular la retención*/
            END;
          ELSE
            /*AGG 21/05/2014 El motivo de retención es pendiente de cuadro facultativo*/
            /*Comprobamos si está completo el cuadro facultivo*/
            /* BUG 0032059/0179024 - FAL - 04/04/2014*/
            /*
            SELECT cestado
            INTO v_cestadocua
            FROM cuafacul
            WHERE sseguro = psseguro;
            */
            v_cestadocua := 0;
            SELECT COUNT(1)
            INTO v_cestadocua
            FROM cuafacul
            WHERE sseguro = psseguro
            AND cestado   = 1;
            /* evalua algun cuadro incompleto de la poliza (por si hay mas de uno por garantia)*/
            IF v_cestadocua = 0 THEN
              v_cestadocua := 2;
            END IF;
            /* FI BUG 0032059/0179024 - FAL - 04/04/2014*/
            IF v_cestadocua = 2 THEN
              /*Estado cuafacul = Completo; DetValores = 118*/
              BEGIN
                INSERT
                INTO psucontrolseg
                  (
                    sseguro,
                    nmovimi,
                    fmovpsu,
                    ccontrol,
                    nriesgo,
                    cgarant,
                    cnivelr,
                    nvalor,
                    cusumov,
                    cnivelu,
                    cautrec,
                    establoquea,
                    ordenbloquea,
                    autoriprev,
                    fautrec,
                    cusuaur,
                    observ,
                    nocurre,
                    nvalorinf,
                    nvalorsuper,
                    autmanual,
                    nvalortope,
                    isvisible
                  )
                  VALUES
                  (
                    psseguro,
                    pnmovimi,
                    f_sysdate,
                    vccontrol,
                    NVL(pnriesgo, 1),
                    0,
                    vcnivel,
                    vnvalsup,
                    f_user,
                    vcnivelu,
                    0,
                    vestabloquea,
                    vordenbloquea,
                    vautoriprev,
                    f_sysdate,
                    f_user,
                    ff_desvalorfijo(708, vcidioma, pcmotret),
                    vnocurre,
                    vnvalinf,
                    vnvalsup,
                    vautmanual,
                    vnvalsup,
                    1
                  );
                vcreteni := pac_psu.f_grabar_retenidas('POL', psseguro, NULL, NULL, NULL, NULL, NULL, vcidioma);
                /* actualizamos seguros a retenido*/
                UPDATE seguros
                SET creteni = 2
                  /*retenim la pòlissa amb valor 2*/
                WHERE sseguro = psseguro;
              EXCEPTION
              WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'PAC_EMISION.MV.f_retener_poliza POL psu', vpasexec, SQLERRM, SQLCODE);
                p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.f_retener_poliza POL', 1, 'insertando psucontrolseg', 'error vccontrol.:'|| vccontrol|| ':vcnivel.:'|| vcnivel|| ':vnvalsup.:'|| vnvalsup|| ':vcnivelu.:'|| vcnivelu|| ':vestabloquea.:'|| vestabloquea|| ':vordenbloquea.:'|| vordenbloquea|| ':vautoriprev.:'|| vautoriprev|| ':vnocurre.:'|| vnocurre|| ':vnvalinf.:'|| vnvalinf|| ':vnvalsup.:'|| vnvalsup|| ':vautmanual.:'|| vautmanual|| ':vnvalsup.:'|| vnvalsup|| ',psseguro:'|| psseguro|| ',pnmovimi:'|| pnmovimi);
                RETURN 107801;
                /* Error al calcular la retención*/
              END;
            ELSE
              /*agg 21/05/2014*/
              /* actualizamos seguros a retenido*/
              UPDATE seguros
              SET creteni = 2
                /*retenim la pòlissa amb valor 2*/
              WHERE sseguro = psseguro;
            END IF;
          END IF;
        ELSE
          RETURN 107801;
          /* Error al calcular la retención*/
        END IF;
      END IF;
      /* BUG18011:DRA:18/03/2011:Fi*/
    END IF;
    RETURN 0;
  END f_retener_poliza;
/*-----------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------*/
  PROCEDURE p_control_cumul(
      psseguro IN NUMBER,
      pfecha   IN DATE,
      papto OUT NUMBER,
      perror OUT NUMBER,
      terror OUT VARCHAR )
  IS
    /* Definimos variables*/
    num_err   NUMBER;
    mens      NUMBER;
    v_sproduc NUMBER;
    formul    VARCHAR2(60);
    pcont     NUMBER;
    xicapital NUMBER;
    xsperson  NUMBER;
    xsperson2 NUMBER;
    parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb;
    apto      CHAR;
    v_nmovimi NUMBER;
    document  VARCHAR2(1);
    xhayerr   NUMBER(1);
    sqle      VARCHAR2(200);
    pnnumlin  NUMBER;
    v_ssegpol NUMBER;
    terror1   VARCHAR2(100);
    terror2   VARCHAR2(100);
  BEGIN
    perror:=0;
    terror:=NULL;
    BEGIN
      SELECT sproduc,
        ssegpol
      INTO v_sproduc,
        v_ssegpol
      FROM estseguros
      WHERE sseguro=psseguro;
    EXCEPTION
    WHEN OTHERS THEN
      perror:=1;
      /*BUG 8914 - 02/02/2009 - XCG  - 'Error inesperado. No encuentra la póliza';*/
      terror1:=f_axis_literales(149921, f_usu_idioma);
      terror2:=f_axis_literales(108936, f_usu_idioma);
      terror :=terror1 || ' ' || terror2;
    END;
    xsperson :=0;
    xsperson2:=0;
    FOR per IN
    (SELECT sperson,
      norden
    FROM estassegurats
    WHERE sseguro=psseguro
    AND ffecfin IS NULL
    )
    /* BUG11183:DRA:01/10/2009*/
    LOOP
      BEGIN
        IF per.norden=1 THEN
          xsperson  :=per.sperson;
        ELSE
          xsperson2:=per.sperson;
        END IF;
      EXCEPTION
      WHEN no_data_found THEN
        perror:=1;
        /*BUG 8914 - 02/02/2009 - XCG  - 'No hay asegurados en la póliza ';*/
        terror:=f_axis_literales(103518, f_usu_idioma);
      WHEN OTHERS THEN
        perror:=1;
        /*BUG 8914 - 02/02/2009 -XCG - 'Error inesperat en assegurats per la polissa:';*/
        terror:=f_axis_literales(149921, f_usu_idioma);
      END;
    END LOOP;
    /**/
    IF perror                            =0 THEN
      xicapital                         :=0;
      pcont                             :=1;
      parms_transitorios(pcont).sperson :=xsperson;
      parms_transitorios(pcont).sperson2:=xsperson2;
      parms_transitorios(pcont).icapital:=xicapital;
      parms_transitorios(pcont).qcontr  :=1;
      parms_transitorios(pcont).sseguro :=psseguro;
      parms_transitorios(pcont).sproduc :=v_sproduc;
      mens                              :=pk_cumul_rie_vida.buscar_cumulo(v_sproduc, pfecha, pcont, parms_transitorios);
      IF mens                            >0 THEN
        FOR i IN 1 .. mens
        LOOP
          formul:=pk_cumul_rie_vida.ver_mensajes(i);
          apto  :=SUBSTR(formul, 1, 1);
          IF apto=0 THEN
            /* Se controla si es apto(0/1)*/
            papto  :=0;
          ELSIF apto=1 THEN
            /* NO ES APTO*/
            papto:=1;
            SELECT NVL(MAX(nmovimi), 0)+1
            INTO v_nmovimi
            FROM movseguro
            WHERE sseguro=v_ssegpol
            AND femisio IS NOT NULL;
            /* BUG11288:DRA:20/10/2009*/
            document  :=SUBSTR(formul, -1);
            IF document='1' THEN --
              /* Se retiene la póliza (PENDIENTE DE EVALUACIÓN) y se inserta en motretencion*/
              num_err      :=pac_emision_mv.f_retener_poliza('EST', psseguro, 1, v_nmovimi, 3, 2, pfecha);
              IF num_err    =0 THEN
                perror     :=0;
                terror1    :=f_axis_literales(9000802, f_usu_idioma);
                terror2    :=f_axis_literales(9000803, f_usu_idioma);
                terror     :=terror1 || ' ' || terror2;
              ELSIF num_err<>0 THEN
                perror     :=1;
                terror     :=f_axis_literales(num_err, f_usu_idioma);
              END IF;
            ELSIF document='2' THEN
              /* Se retiene la póliza (PENDIENTE DE EVALUACION) y se inserta en motretencion*/
              num_err      :=pac_emision_mv.f_retener_poliza('EST', psseguro, 1, v_nmovimi, 4, 2, pfecha);
              IF num_err    =0 THEN
                perror     :=0;
                terror1    :=f_axis_literales(9000802, f_usu_idioma);
                terror2    :=f_axis_literales(9000803, f_usu_idioma);
                terror     :=terror1 || ' ' || terror2;
              ELSIF num_err<>0 THEN
                perror     :=1;
                terror     :=f_axis_literales(num_err, f_usu_idioma);
              END IF;
            END IF;
          ELSIF apto=2 THEN
            perror :=1;
            /*BUG 8914 - 02/02/2009 -XCG - 'Error al calcular el cúmulo';*/
            terror :=f_axis_literales(151891, f_usu_idioma);
          ELSIF apto=3 THEN
            perror :=1;
            /*BUG 8914 - 02/02/2009 -XCG - 'Error al calcular el cúmulo';*/
            terror:=f_axis_literales(151891, f_usu_idioma);
          ELSE
            perror:=1;
            /*BUG 8914 - 02/02/2009 -XCG - 'Error al calcular el cúmulo';*/
            terror:=f_axis_literales(151891, f_usu_idioma);
          END IF;
        END LOOP;
        /* Fin loop mensajes*/
        pk_cumul_rie_vida.borra_mensajes;
      ELSE
        perror:=1;
        terror:=f_axis_literales(ABS(num_err), f_usu_idioma);
      END IF;
      /* Error*/
    END IF;
  END p_control_cumul;
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
  FUNCTION f_seleccion_riesgos(
      psseguro IN NUMBER,
      pfecha   IN DATE,
      papto OUT NUMBER,
      pnumerr OUT NUMBER,
      /* BUG9620:DRA:31-03-2009*/
      pterror OUT VARCHAR2 )
    /* BUG9620:DRA:31-03-2009*/
    RETURN NUMBER
  IS
    v_nmovimi NUMBER;
    v_crespue NUMBER;
    num_err   NUMBER;
    v_ssegpol NUMBER;
    v_mov     NUMBER;
    xsqlerrm  VARCHAR(2000);
    v_cmotmov NUMBER;
    v_sproduc NUMBER;
    v_cempres estseguros.cempres%TYPE;
    /* BUG9620:DRA:31-03-2009*/
    v_cobjase estseguros.cobjase%TYPE;
    v_fmatric DATE;
    v_imcmin  NUMBER;
    /* BUG9620:DRA:31-03-2009*/
    v_imcmax NUMBER;
    /* BUG9620:DRA:31-03-2009*/
    v_retener NUMBER;
    /* BUG16804:DRA:26/11/2010*/
    /* Bug 22843 - RSC - 12/09/2012*/
    visaltacol NUMBER:=0;
    v_npoliza estseguros.npoliza%TYPE;
    v_imcminp     NUMBER;
    v_imcmaxp     NUMBER;
    v_prof        NUMBER;
    v_aux         NUMBER;
    v_icapitalact NUMBER;
    v_iprianuact  NUMBER;
    v_icapitalant NUMBER;
    v_iprianuant  NUMBER;
    v_nriesgo     NUMBER;
    /* Fin Bug 22843*/
  BEGIN
    /* En realidad tendríamos que utilizar la funcionalidad de SELECCION DE RIESGOS  que hay en axis,*/
    /* (por ejemplo. f_autorizar_riesgo. Pero de momento lo haremos a 'pelo'*/
    BEGIN
      SELECT ssegpol,
        sproduc,
        cempres,
        cobjase,
        npoliza
      INTO v_ssegpol,
        v_sproduc,
        v_cempres,
        v_cobjase,
        v_npoliza
      FROM estseguros
      WHERE sseguro=psseguro;
    EXCEPTION
    WHEN OTHERS THEN
      RETURN(2222);
    END;
    SELECT NVL(MAX(nmovimi), 0)+1
    INTO v_nmovimi
    FROM movseguro
    WHERE sseguro=v_ssegpol
    AND femisio IS NOT NULL;
    /*Bug.: 0015811 - ICV - 26/08/2010 - Se modifica para retener por riesgo, no por un riesgo*/
    /* bug 12712.nmm.01/02/2010.f.*/
    BEGIN
      SELECT COUNT(cmotmov)
      INTO v_cmotmov
      FROM estdetmovseguro
      WHERE sseguro                                              =psseguro
      AND nmovimi                                                =v_nmovimi
      AND NVL(f_parmotmov(cmotmov, 'RETEN_CUMULO', v_sproduc), 0)=1;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      /* no ha habido suplemento de modificaicón de garantias*/
    END;
    FOR rc IN
    (SELECT crespue,
      nriesgo
    FROM estpregunseg
    WHERE cpregun=10
    AND sseguro  =psseguro
    AND nmovimi  =v_nmovimi
    )
    LOOP
      IF rc.crespue>=1 THEN
        /* Miramos si ya se ha aceptado alguna vez*/
        BEGIN
          SELECT MAX(m.nmovimi)
          INTO v_mov
          FROM motretencion m,
            motreten_rev x
          WHERE m.sseguro=v_ssegpol
          AND m.cmotret  =2
          AND x.sseguro  =m.sseguro
          AND x.nmovimi  =m.nmovimi
          AND x.nriesgo  =rc.nriesgo
          AND x.cmotret  =m.cmotret
          AND x.nmotret  =m.nmotret
          AND x.cresulta =1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
        EXCEPTION
        WHEN OTHERS THEN
          v_mov:=NULL;
        END;
        IF rc.crespue >= 1
          /* bug 14268.JGR.04/2010. -- v_crespue = 1*/
          AND(v_mov IS NULL OR v_cmotmov > 0) THEN
          /*han contestado que hay respuestas afirmativas*/
          papto   := 1;
          num_err := pac_emision_mv.f_retener_poliza('EST', psseguro, rc.nriesgo, -- bug 14268.JGR.04/2010 -- 1
          v_nmovimi, 2, 2, pfecha);
          IF num_err <> 0 THEN
            RETURN(num_err);
          END IF;
        ELSE
          papto := 0;
        END IF;
      END IF;
    END LOOP;
    FOR rc IN
    (SELECT crespue,
      nriesgo
    FROM estpregunseg
    WHERE cpregun=554
    AND sseguro  =psseguro
    AND nmovimi  =v_nmovimi
    )
    LOOP
      IF rc.crespue>=1 THEN
        /* Miramos si ya se ha aceptado alguna vez*/
        BEGIN
          SELECT MAX(m.nmovimi)
          INTO v_mov
          FROM motretencion m,
            motreten_rev x
          WHERE m.sseguro=v_ssegpol
          AND m.cmotret  =13
          AND x.sseguro  =m.sseguro
          AND x.nmovimi  =m.nmovimi
          AND x.nriesgo  =rc.nriesgo
          AND x.cmotret  =m.cmotret
          AND x.nmotret  =m.nmotret
          AND x.cresulta =1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
        EXCEPTION
        WHEN OTHERS THEN
          v_mov:=NULL;
        END;
        /* BUG14308:DRA:30/04/2010:Inici*/
        IF rc.crespue >= 1
          /* bug 14268.JGR.04/2010. -- v_crespue = 1*/
          AND(v_mov IS NULL OR v_cmotmov > 0) THEN
          /*han contestado que practica deportes de riesgo*/
          papto   := 1;
          num_err := pac_emision_mv.f_retener_poliza('EST', psseguro, rc.nriesgo, -- bug 14268.JGR.04/2010 -- 1
          v_nmovimi, 13, 2, pfecha);
          IF num_err <> 0 THEN
            RETURN(num_err);
          END IF;
        END IF;
      END IF;
    END LOOP;
    /* Bug 22843 - RSC - 12/09/2012*/
    IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0)=1 THEN
      IF pac_seguros.f_get_escertifcero(v_npoliza)               =0 THEN
        visaltacol                                              :=1;
      END IF;
    END IF;
    IF visaltacol=1 THEN
      NULL;
    ELSE
      /* Fin bug 22843*/
      /* bug 12712.NMM.01/02/2010.i.*/
      BEGIN
        /* Inici BUG9620:DRA:30-03-2009*/
        /*   Sustuimos por PAREMPRESA los valores del IMC*/
        /* Bug36216-XVM-17/03/2016.Miramos antes si existe el parametro por producto, sino miraremos por empresa. */
        /* Para que vaya por producto los dos parametros han de estar configurados, sino ira por empresa. */
        v_imcminp    :=pac_parametros.f_parproducto_n(v_sproduc, 'IMC_MINP');
        v_imcmaxp    :=pac_parametros.f_parproducto_n(v_sproduc, 'IMC_MAXP');
        v_imcmaxp    :=v_imcmaxp-0.1;
        IF v_imcminp IS NULL OR v_imcmaxp IS NULL THEN
          v_imcmin   :=pac_parametros.f_parempresa_n(v_cempres, 'IMC_MIN');
          v_imcmax   :=pac_parametros.f_parempresa_n(v_cempres, 'IMC_MAX');
        ELSE
          v_imcmin:=v_imcminp;
          v_imcmax:=v_imcmaxp;
        END IF;
        IF v_imcmin IS NULL OR v_imcmax IS NULL THEN
          NULL;
        ELSE
          FOR rc IN
          (SELECT crespue,
            nriesgo
          FROM estpregunseg
          WHERE cpregun=9
          AND sseguro  =psseguro
          AND (crespue <v_imcmin
            /* BUG9620:DRA:31-03-2009*/
          OR crespue>v_imcmax)
            /*> Fuera de los límites*/
          AND nmovimi=v_nmovimi
          )
          LOOP
            /* Bug 19114 - APD - 21/07/2011 - se sustituye rc.crespue = 1 por rc.crespue = 0*/
            /* Si el IMC es >= 0, tambien debe mirar si se debe retener la poliza*/
            IF rc.crespue>=0 THEN
              /* Miramos si ya se ha aceptado alguna vez*/
              BEGIN
                SELECT MAX(m.nmovimi)
                INTO v_mov
                FROM motretencion m,
                  motreten_rev x
                WHERE m.sseguro=v_ssegpol
                AND m.cmotret  =12
                AND x.sseguro  =m.sseguro
                AND x.nmovimi  =m.nmovimi
                AND x.nriesgo  =rc.nriesgo
                AND x.cmotret  =m.cmotret
                AND x.nmotret  =m.nmotret
                AND x.cresulta =1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
              EXCEPTION
              WHEN OTHERS THEN
                v_mov:=NULL;
              END;
              /* bug 12712.nmm.01/02/2010.i.*/
              /* Bug 19114 - APD - 21/07/2011 - se sustituye rc.crespue = 1 por rc.crespue = 0*/
              IF rc.crespue >= 0
                /* bug 14268.JGR.04/2010. -- v_crespue2 IS NOT NULL*/
                AND(v_mov IS NULL OR v_cmotmov > 0) THEN
                papto     := 1;
                num_err   := pac_emision_mv.f_retener_poliza ('EST', psseguro, rc.nriesgo, -- bug 14268.JGR.04/2010 -- 1
                v_nmovimi, 12, 2, pfecha);
                IF num_err <> 0 THEN
                  RETURN(num_err);
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;
        /* Fi BUG9620:DRA:30-03-2009*/
      EXCEPTION
      WHEN OTHERS THEN
        xsqlerrm:=SQLERRM;
      END;
      BEGIN
        FOR rc IN
        (SELECT crespue,
          nriesgo
        FROM estpregunseg
        WHERE cpregun = 260
        AND sseguro   = psseguro
        AND nmovimi   = v_nmovimi
        )
        LOOP
          IF rc.crespue > 0 THEN
            BEGIN
              SELECT MAX(m.nmovimi)
              INTO v_mov
              FROM motretencion m,
                motreten_rev x
              WHERE m.sseguro = v_ssegpol
              AND m.cmotret   = 21
              AND x.sseguro   = m.sseguro
              AND x.nmovimi   = m.nmovimi
              AND x.nriesgo   = rc.nriesgo
              AND x.cmotret   = m.cmotret
              AND x.nmotret   = m.nmotret
              AND x.cresulta  = 1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
            EXCEPTION
            WHEN OTHERS THEN
              v_mov := NULL;
            END;
            IF rc.crespue > 0
              /* bug 14268.JGR.04/2010. -- v_crespue2 IS NOT NULL*/
              AND(v_mov IS NULL OR v_cmotmov > 0) THEN
              papto     := 1;
              num_err   := pac_emision_mv.f_retener_poliza ('EST', psseguro, rc.nriesgo, -- bug 14268.JGR.04/2010 -- 1
              v_nmovimi, 21, 2, pfecha);
              IF num_err <> 0 THEN
                RETURN(num_err);
              END IF;
            END IF;
          END IF;
        END LOOP;
      EXCEPTION
      WHEN OTHERS THEN
        xsqlerrm := SQLERRM;
      END;
      BEGIN
        FOR rc IN
        (SELECT crespue,
          nriesgo
        FROM estpregunseg
        WHERE cpregun = 261
        AND sseguro   = psseguro
        AND nmovimi   = v_nmovimi
        )
        LOOP
          IF rc.crespue > 0 THEN
            BEGIN
              SELECT MAX(m.nmovimi)
              INTO v_mov
              FROM motretencion m,
                motreten_rev x
              WHERE m.sseguro = v_ssegpol
              AND m.cmotret   = 22
              AND x.sseguro   = m.sseguro
              AND x.nmovimi   = m.nmovimi
              AND x.nriesgo   = rc.nriesgo
              AND x.cmotret   = m.cmotret
              AND x.nmotret   = m.nmotret
              AND x.cresulta  = 1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
            EXCEPTION
            WHEN OTHERS THEN
              v_mov := NULL;
            END;
            IF rc.crespue > 0
              /* bug 14268.JGR.04/2010. -- v_crespue2 IS NOT NULL*/
              AND(v_mov IS NULL OR v_cmotmov > 0) THEN
              papto     := 1;
              num_err   := pac_emision_mv.f_retener_poliza ('EST', psseguro, rc.nriesgo, -- bug 14268.JGR.04/2010 -- 1
              v_nmovimi, 22, 2, pfecha);
              IF num_err <> 0 THEN
                RETURN(num_err);
              END IF;
            END IF;
          END IF;
        END LOOP;
      EXCEPTION
      WHEN OTHERS THEN
        xsqlerrm := SQLERRM;
      END;
      IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PROFESIONESILT'), 0) <> 0 THEN
        BEGIN
          FOR rc IN
          (SELECT crespue,
            nriesgo
          FROM estpregunseg
          WHERE cpregun = 60
          AND sseguro   = psseguro
          AND nmovimi   = v_nmovimi
          )
          LOOP
            BEGIN
              SELECT cgruppro
              INTO v_prof
              FROM profesionprod pp,
                productos pr,
                codiram co
              WHERE pr.sproduc = v_sproduc
              AND pp.cramo     = pr.cramo
              AND pp.cmodali   = pr.cmodali
              AND pp.ctipseg   = pr.ctipseg
              AND pp.ccolect   = pr.ccolect
              AND co.cramo     = pr.cramo
              AND pp.cempres   = co.cempres
              AND pp.cprofes   = rc.crespue;
            EXCEPTION
            WHEN OTHERS THEN
              v_prof := 0;
            END;
            IF v_prof = 3 THEN
              BEGIN
                SELECT MAX(m.nmovimi)
                INTO v_mov
                FROM motretencion m,
                  motreten_rev x
                WHERE m.sseguro = v_ssegpol
                AND m.cmotret   = 23
                AND x.sseguro   = m.sseguro
                AND x.nmovimi   = m.nmovimi
                AND x.nriesgo   = rc.nriesgo
                AND x.cmotret   = m.cmotret
                AND x.nmotret   = m.nmotret
                AND x.cresulta  = 1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
              EXCEPTION
              WHEN OTHERS THEN
                v_mov := NULL;
              END;
              IF v_prof = 3
                /* bug 14268.JGR.04/2010. -- v_crespue2 IS NOT NULL*/
                AND(v_mov IS NULL OR v_cmotmov > 0) THEN
                papto     := 1;
                num_err   := pac_emision_mv.f_retener_poliza ('EST', psseguro, rc.nriesgo, -- bug 14268.JGR.04/2010 -- 1
                v_nmovimi, 23, 2, pfecha);
                IF num_err <> 0 THEN
                  RETURN(num_err);
                END IF;
              END IF;
            END IF;
          END LOOP;
        EXCEPTION
        WHEN OTHERS THEN
          xsqlerrm := SQLERRM;
        END;
        END IF;

        IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PROFESIONESILT'), 0) <> 0 THEN
          BEGIN
            FOR rc IN
            (SELECT icapital,
              nriesgo
            FROM estgaranseg
            WHERE cgarant = 100
            AND sseguro   = psseguro
            AND nmovimi   = v_nmovimi
            )
            LOOP
              IF rc.icapital >= 90 THEN
                BEGIN
                  SELECT MAX(m.nmovimi)
                  INTO v_mov
                  FROM motretencion m,
                    motreten_rev x
                  WHERE m.sseguro = v_ssegpol
                  AND m.cmotret   = 24
                  AND x.sseguro   = m.sseguro
                  AND x.nmovimi   = m.nmovimi
                  AND x.nriesgo   = rc.nriesgo
                  AND x.cmotret   = m.cmotret
                  AND x.nmotret   = m.nmotret
                  AND x.cresulta  = 1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
                EXCEPTION
                WHEN OTHERS THEN
                  v_mov := NULL;
                END;
                IF rc.icapital >= 90
                  /* bug 14268.JGR.04/2010. -- v_crespue2 IS NOT NULL*/
                  AND(v_mov IS NULL OR v_cmotmov > 0) THEN
                  papto     := 1;
                  num_err   := pac_emision_mv.f_retener_poliza ('EST', psseguro, rc.nriesgo, -- bug 14268.JGR.04/2010 -- 1
                  v_nmovimi, 24, 2, pfecha);
                  IF num_err <> 0 THEN
                    RETURN(num_err);
                  END IF;
                END IF;
              END IF;
            END LOOP;
          EXCEPTION
          WHEN OTHERS THEN
            xsqlerrm := SQLERRM;
          END;
          v_aux := 0;
          BEGIN
            SELECT icapital,
              iprianu,
              nriesgo
            INTO v_icapitalact,
              v_iprianuact,
              v_nriesgo
            FROM garanseg
            WHERE ffinefe IS NULL
            AND sseguro    = v_ssegpol
            AND cgarant    =100;
          EXCEPTION
          WHEN no_data_found THEN
            v_aux :=1;
          END;
          IF v_aux = 0 THEN
            SELECT icapital,
              iprianu,
              nriesgo
            INTO v_icapitalant,
              v_iprianuant,
              v_nriesgo
            FROM estgaranseg
            WHERE NVL (cobliga, 1) = 1
            AND sseguro            = psseguro
            AND cgarant            =100;
            IF v_icapitalact      <> v_icapitalant OR v_iprianuact <> v_iprianuant THEN
              BEGIN
                SELECT MAX(m.nmovimi)
                INTO v_mov
                FROM motretencion m,
                  motreten_rev x
                WHERE m.sseguro = v_ssegpol
                AND m.cmotret   = 25
                AND x.sseguro   = m.sseguro
                AND x.nmovimi   = m.nmovimi
                AND x.nriesgo   = v_nriesgo
                AND x.cmotret   = m.cmotret
                AND x.nmotret   = m.nmotret
                AND x.cresulta  = 1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
              EXCEPTION
              WHEN OTHERS THEN
                v_mov := NULL;
              END;
              /* bug 14268.JGR.04/2010. -- v_crespue2 IS NOT NULL*/
              IF (v_mov IS NULL OR v_cmotmov > 0) THEN
                papto   := 1;
                num_err := pac_emision_mv.f_retener_poliza ('EST', psseguro, v_nriesgo, -- bug 14268.JGR.04/2010 -- 1
                v_nmovimi, 25, 2, pfecha);
                IF num_err <> 0 THEN
                  RETURN(num_err);
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
      /*Fin bug.: 0015811 -- ICV*/
      /* bug 12712.nmm.01/02/2010.f.*/
      /* JLB - I - Politica de subscripción*/
      IF v_cobjase=5 THEN
        /* si es autos then*/
        BEGIN
          SELECT fmatric
          INTO v_fmatric
          FROM estautriesgos
          WHERE sseguro=psseguro
          AND nmovimi  =nmovimi
          AND nriesgo  =1;
          /* FALTA PASAR EL RIESGO....NO FUNCIONARÁ PARA VARIOS RIESGOS*/
          SELECT 1
          INTO v_crespue
          FROM estgaranseg
          WHERE sseguro=psseguro
          AND nmovimi  =v_nmovimi
          AND ffinefe IS NULL
          AND nriesgo  =1
          AND cgarant  =5303
          AND cobliga  =1;
          /* garantias de daños propios*/
        EXCEPTION
        WHEN OTHERS THEN
          v_fmatric:=NULL;
          v_crespue:=NULL;
        END;
        IF (v_crespue = 1 AND months_between(pfecha, NVL(v_fmatric, pfecha)) >= 24) AND(v_mov IS NULL OR v_cmotmov > 0) THEN
          papto      := 1;
          num_err    := pac_emision_mv.f_retener_poliza('EST', psseguro, 1, v_nmovimi, 7, 2, pfecha);
          IF num_err <> 0 THEN
            RETURN num_err;
          END IF;
        ELSE
          papto := 0;
        END IF;
      END IF;
      /* JLB - F - Politica de subscripción*/
      /* BUG16804:DRA:25/11/2010:Inici*/
      BEGIN
        FOR rc IN
        (SELECT crespue,
          nriesgo
        FROM estpregunseg
        WHERE sseguro=psseguro
        AND nmovimi  =v_nmovimi
        AND cpregun  =7954
        )
        LOOP
          IF NVL(rc.crespue, 0)=0 THEN
            /* Si el equipo o maquinaria no es de leasing ni renting*/
            BEGIN
              SELECT crespue
              INTO v_crespue
              FROM estpregunseg
              WHERE sseguro=psseguro
              AND nriesgo  =rc.nriesgo
              AND nmovimi  =v_nmovimi
              AND cpregun  =7955;
            EXCEPTION
            WHEN no_data_found THEN
              v_crespue:=NULL;
            END;
            /* la antigüedad supere los 2 años si se trata de equipo electrónico o 4 años en el resto*/
            SELECT COUNT(1)
            INTO v_retener
            FROM estgaranseg g
            WHERE g.sseguro       = psseguro
            AND g.nriesgo         = rc.nriesgo
            AND g.nmovimi         = v_nmovimi
            AND g.cobliga         = 1
            AND((g.cgarant       IN(8401, 8402, 8403)
            AND NVL(v_crespue, 0) > 2)
            OR(g.cgarant         IN(8404, 8405, 8406)
            AND NVL(v_crespue, 0) > 4));
            /* Miramos si ya se ha aceptado alguna vez*/
            BEGIN
              SELECT MAX(m.nmovimi)
              INTO v_mov
              FROM motretencion m,
                motreten_rev x
              WHERE m.sseguro = v_ssegpol
              AND m.cmotret   = 15
              AND x.sseguro   = m.sseguro
              AND x.nmovimi   = m.nmovimi
              AND x.nriesgo   = rc.nriesgo
              AND x.cmotret   = m.cmotret
              AND x.nmotret   = m.nmotret
              AND x.cresulta  = 1; -- BUG9107:DRA:25-02-2009:No ha d'agafar les ja acceptades
            EXCEPTION
            WHEN OTHERS THEN
              v_mov := NULL;
            END;
            /* bug 12712.nmm.01/02/2010.i.*/
            IF v_retener >= 1 AND(v_mov IS NULL OR v_cmotmov > 0) THEN
              papto      := 1;
              num_err    := pac_emision_mv.f_retener_poliza('EST', psseguro, rc.nriesgo, -- bug 14268.JGR.04/2010 -- 1
              v_nmovimi, 15, 2, pfecha);
              IF num_err <> 0 THEN
                RETURN(num_err);
              END IF;
            END IF;
          END IF;
        END LOOP;
      EXCEPTION
      WHEN OTHERS THEN
        xsqlerrm:=SQLERRM;
      END;
      /* BUG16804:DRA:25/11/2010:Fi*/
      RETURN 0;
    END f_seleccion_riesgos;
    /*--------------------------------------------------------------------------------------------*/
    /*--------------------------------------------------------------------------------------------*/
    PROCEDURE p_control_antes_emision(
        psseguro IN NUMBER,
        pfecha   IN DATE,
        pnmovimi IN NUMBER,
        pcreteni OUT NUMBER,
        perror OUT NUMBER,
        terror OUT VARCHAR )
    IS
      /******************************************************************************************
      Antes de emitir la propuesta debe pasar por una serie de controles para saber
      si debe quedar retenida o no:
      1.- Control de cúmulos
      2.- Selección de riesgos
      a)  Cuestionario 'limpio'
      b)  Relación Peso-altura
      3.- Control de aumento de capital en garantías con cuestionario de salud afirmativo
      Se devuelve el estado de retención.
      ********************************************************************************************/
      CURSOR c_gar_cum
      IS
        SELECT cg.ccumulo,
          g.cgarant,
          s.ssegpol
        FROM cum_cumgaran cg,
          cum_cumulo cc,
          estgaranseg g,
          estseguros s
        WHERE cg.cramo = s.cramo
        AND cg.cmodali = s.cmodali
        AND cg.ctipseg = s.ctipseg
        AND cg.ccolect = s.ccolect
        AND cc.scumulo = cg.ccumulo
        AND cc.cnivel  = 1
        AND g.sseguro  = s.sseguro
        AND cg.cgarant = g.cgarant
        AND s.sseguro  = psseguro;
      papto         NUMBER;
      num_err       NUMBER;
      v_capital     NUMBER;
      v_capital_ant NUMBER;
      control_cumul NUMBER;
      /*------------------------------------------------------------------------*/
      /* bug 11457.NMM.16/10/2009.i.*/
      /*------------------------------------------------------------------------*/
      w_professio NUMBER;
      w_creteni   NUMBER;
      FUNCTION get_professio(
          p_sseguro IN seguros.sseguro%TYPE,
          p_data    IN DATE,
          p_nmovimi IN NUMBER,
          p_creteni OUT NUMBER )
        RETURN NUMBER
      IS
        w_cramo seguros.cramo%TYPE;
        w_cmodali seguros.cmodali%TYPE;
        w_ctipseg seguros.ctipseg%TYPE;
        w_ccolect seguros.ccolect%TYPE;
        w_cactivi seguros.cactivi%TYPE;
        w_cempres seguros.cempres%TYPE;
        w_profess estpregunseg.crespue%TYPE;
        /**/
        wo_sobreprima NUMBER;
        w_result      NUMBER := -1;
        w_cgarant     NUMBER;
        w_nriesgo     NUMBER;
        w_pas PLS_INTEGER := 0;
        /**/
        w_continua NUMBER := 0;
        /**/
      BEGIN
        p_creteni := 0;
        SELECT cramo,
          cmodali,
          ctipseg,
          ccolect,
          cactivi,
          cempres
        INTO w_cramo,
          w_cmodali,
          w_ctipseg,
          w_ccolect,
          w_cactivi,
          w_cempres
        FROM estseguros
        WHERE sseguro = p_sseguro;
        w_pas        := 1;
        /*------------------------- cursor de riscos --------------------------*/
        FOR cr IN
        ( SELECT nriesgo FROM estriesgos WHERE sseguro = p_sseguro
        )
        LOOP
          BEGIN
            SELECT crespue
            INTO w_profess
            FROM estpregunseg
            WHERE cpregun = 60
            AND sseguro   = p_sseguro
            AND nriesgo   = cr.nriesgo;
            w_continua   := 0;
          EXCEPTION
          WHEN OTHERS THEN
            /* La pregunta 60 no existeix a totes les instal·lacions. Si no existeix no fa el segon bucle.*/
            w_continua := 1;
          END;
          IF w_continua = 0 THEN
            /*------------- cursor de garanties per cada risc ------------------*/
            /* Bug 11457 - 04/11/2009 - AMC*/
            FOR cg IN
            ( SELECT DISTINCT cgarant
            FROM estgaranseg
            WHERE sseguro = p_sseguro
            AND nriesgo   = cr.nriesgo
            AND icapital IS NOT NULL
            AND icapital <> 0
            AND iprianu  IS NOT NULL
            AND iprianu  <> 0
            )
            LOOP
              /* Fi Bug 11457 - 04/11/2009 - AMC*/
              w_pas       := 2;
              w_result    := pac_calc_comu.ff_get_infoprofesion(p_data, w_cempres, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, cg.cgarant, 'R', w_profess, wo_sobreprima, 0);
              w_pas       := 3;
              IF w_result <> 0 THEN
                w_pas     := 4;
                /* controlem l'error*/
                p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.p_control_antes_emision.get_professio', 1, 'ff_get_infoprofesion', 'error 1.:' || w_result || ':2.:' || p_data || ':3.:' || w_cempres || ':4.:' || w_cramo || ':5.:' || w_cmodali || ':6.:' || w_ctipseg || ':7.:' || w_ccolect || ':8.:' || w_cactivi || ':9.:' || cg.cgarant || ':10.:' || w_profess || ':11.:' || wo_sobreprima);
                /*---------------- sortim de la funció -----------------------*/
                RETURN(w_result);
              END IF;
              /**/
              w_pas            := 5;
              IF wo_sobreprima <> 0 THEN
                w_pas          := 6;
                w_result       := pac_emision_mv.f_retener_poliza('EST', p_sseguro, 1, p_nmovimi, 11, 2, p_data);
                IF w_result    <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.p_control_antes_emision.get_professio', 1, 'f_retener_poliza', 'error 1.:' || w_result || ':2.:' || p_data || ':3.:' || w_cempres || ':4.:' || w_cramo || ':5.:' || w_cmodali || ':6.:' || w_ctipseg || ':7.:' || w_ccolect || ':8.:' || w_cactivi || ':9.:' || cg.cgarant || ':10.:' || w_profess || ':11.:' || wo_sobreprima);
                  /*---------------- sortim de la funció --------------------*/
                  RETURN(w_result);
                ELSE
                  p_creteni := 2;
                  /*---------------- sortim de la funció ---------------------*/
                  RETURN(0);
                END IF;
              END IF;
            END LOOP;
          END IF;
          /*------------- cursor de garanties per cada risc ------------------*/
          w_pas := 7;
        END LOOP;
        /*------------------------- cursor de riscos --------------------------*/
        RETURN(0);
        /**/
      EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.p_control_antes_emision.get_professio', w_pas, 'Others', w_result);
        RETURN(w_result);
      END get_professio;
    /*------------------------------------------------------------------------*/
    /* bug 11457.NMM.16/10/2009.f.*/
    /*------------------------------------------------------------------------*/
    /*---------------------------------------------------------------------------*/
    /*---------------------------------------------------------------------------*/
    BEGIN
      pcreteni := 0;
      /* Miramos si corresponde pasar el control de cúmulos*/
      /* Sólo debería pasar el control si se aumenta el capital*/
      /* Miramos si la póliza tiene garantías con cúmulo que hayan aumentado el capital*/
      FOR cur_gar IN c_gar_cum
      LOOP
        BEGIN
          SELECT icapital
          INTO v_capital
          FROM estgaranseg
          WHERE sseguro = psseguro
          AND cgarant   = cur_gar.cgarant
          AND nmovimi   = pnmovimi;
        EXCEPTION
        WHEN OTHERS THEN
          v_capital := 0;
        END;
        BEGIN
          SELECT icapital
          INTO v_capital_ant
          FROM garanseg
          WHERE sseguro = cur_gar.ssegpol
          AND cgarant   = cur_gar.cgarant
          AND nmovimi   =
            (SELECT MAX(nmovimi)
            FROM garanseg
            WHERE sseguro = cur_gar.ssegpol
            AND cgarant   = cur_gar.cgarant
            AND nmovimi   < pnmovimi
            );
        EXCEPTION
        WHEN OTHERS THEN
          v_capital_ant := 0;
        END;
        IF v_capital     > v_capital_ant THEN
          control_cumul := 1;
          EXIT;
        ELSE
          control_cumul := 0;
        END IF;
      END LOOP;
      IF control_cumul = 1 THEN
        /* PASO 1: CONTROL DE CÚMULOS*/
        pac_emision_mv.p_control_cumul(psseguro, pfecha, papto, perror, terror);
        IF perror = 0 THEN
          /*commit;*/
          IF papto = 1 THEN
            /* NO ha pasado el control de cumulos*/
            pcreteni := 2;
          ELSE
            pcreteni := 0;
          END IF;
        END IF;
      END IF;
      /* paso 2: seleccion de riesgos*/
      /* Bug 10828 - RSC - 09/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)*/
      IF pac_control_emision.f_control_risc(psseguro, pnmovimi, pfecha) = 1 THEN
        num_err                                                        := pac_emision_mv.f_seleccion_riesgos(psseguro, pfecha, papto, perror, terror);
        IF num_err                                                      = 0 AND pcreteni = 0 THEN
          /* BUG9107:DRA:25-02-2009:No entramos si ya se queda retenida*/
          IF papto = 1 THEN
            /* NO ha pasado el control de SELECCION DE RIESGOS*/
            pcreteni := 2;
          ELSE
            pcreteni := 0;
          END IF;
        END IF;
        /* BUG9448:13-03-2009:DRA*/
        /* paso 3: Si hay respuestas afirmativas al cuestionario también retenemos*/
        IF pcreteni  = 0 THEN
          num_err   := pac_emision_mv.f_control_capital_respuesta(psseguro, pnmovimi, pfecha, perror, terror, papto);
          IF num_err = 0 THEN
            IF papto = 1 THEN
              /* NO ha pasado el control de capital aumentado con resp.afirm.*/
              pcreteni := 2;
            ELSE
              pcreteni := 0;
            END IF;
          END IF;
        END IF;
      END IF;
      /*------------------------------------------------------------------------*/
      /* bug 11457.NMM.16/10/2009.i.*/
      /* Pas 4.- Control de professió.*/
      /*------------------------------------------------------------------------*/
      IF pcreteni       = 0 THEN
        w_professio    := get_professio(psseguro, pfecha, pnmovimi, w_creteni);
        IF w_professio <> 0 THEN
          /* si hi ha error quedarà constància.*/
          p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.p_control_antes_emision', 1, '-- get_professio --', w_professio);
        ELSE
          pcreteni := w_creteni;
        END IF;
      END IF;
      /* bug 11457.NMM.f.*/
      /*------------------------------------------------------------------------*/
    END p_control_antes_emision;
  /*-------------------------------------------------------------------------------------------*/
  /*-------------------------------------------------------------------------------------------*/
  FUNCTION p_cobro_recibo(
      pnrecibo   IN NUMBER,
      ptipocobro IN NUMBER,
      pcbancar   IN VARCHAR2,
      poficina   IN NUMBER,
      pusuario   IN VARCHAR2,
      paut       IN OUT NUMBER,
      phost OUT NUMBER,
      terror OUT VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL )
    RETURN NUMBER
  IS
    /********************************************************************************************
    Cobro de un recibo:
    ptipocobro: 1 = por caja. Se cobra el recibo y se hace adeudo a HOST
    2 = por cuenta.
    -- si la cuenta es de BM se hace adeudo a host
    -- si NO es de BM se deja el recibo pendiente de domiciliar y no se hace adeudo
    a HOST
    pbancar: cuenta a la cual se adeuda el recibo
    poficiona: oficina del terminal
    pusuario: usuario del terminal
    paut (IN):  0  -- se llama por primera vez al adeudo de recibo
    1  -- se llama por segunda vez con autorización
    paut (OUT) :  nos devuelve 0 .- se cobra el recibo correctamente
    1 .- hace falta pedir autorización para poder adudar
    2 .- el host deniega el cobro
    3 .- el host devuleve un error
    4 .- error en la respuesta del host
    5 .- ( valor ocupado por la cancelación del terminalista)
    6 .- error axis
    phost: devuelve 0.- si no llega a intentar cobrar el recibo por host
    1.- si intenta cobrar el recibo por host
    perror:  si ha habido error se devuelve en esta variable.
    *********************************************************************************************/
    v_cbancar       NUMBER;
    v_ccobban       NUMBER;
    v_cdelega       NUMBER;
    v_cagente       NUMBER;
    v_cramo         NUMBER;
    v_cmodali       NUMBER;
    v_ctipseg       NUMBER;
    v_ccolect       NUMBER;
    entidad_tf      VARCHAR2(4);
    v_ctipban       NUMBER;
    salir           EXCEPTION;
    entidad_cbancar VARCHAR2(4);
    v_formato       VARCHAR2(2);
    v_smovagr       NUMBER:=0;
    v_nliqmen       NUMBER;
    v_nliqlin       NUMBER;
    v_error         NUMBER;
    v_fefecto       DATE;
    xfmovini        DATE;
  BEGIN
    phost          :=0;
    v_error        :=0;
    entidad_tf     :=f_parinstalacion_t('ENTIDAD_TF');
    entidad_cbancar:=SUBSTR(lpad(pcbancar, 20, '0'), 1, 4);
    BEGIN
      SELECT r.cbancar,
        r.ccobban,
        r.cdelega,
        r.cagente,
        s.cramo,
        s.cmodali,
        s.ctipseg,
        s.ccolect,
        r.fefecto,
        r.ctipban
      INTO v_cbancar,
        v_ccobban,
        v_cdelega,
        v_cagente,
        v_cramo,
        v_cmodali,
        v_ctipseg,
        v_ccolect,
        v_fefecto,
        v_ctipban
      FROM recibos r,
        seguros s
      WHERE r.nrecibo=pnrecibo
      AND r.sseguro  =s.sseguro;
    EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'pac_emision_mv.p_cobro_recibo', 1, 'Error al buscar datos del recibo: ' || pnrecibo, SQLERRM);
      v_error:=101731;
      /* recibo no encontrado*/
      paut:=6;
      /* error axis*/
      RAISE salir;
    END;
    IF ptipocobro=0 THEN
      /*POR CAJA*/
      v_ccobban:=1;
      /* momento sólo hay un cobrador banario, cuando haya más será una*/
      /* variable*/
    ELSE
      v_ccobban    :=NVL(f_buscacobban(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cagente, pcbancar, v_ctipban, v_error), 1);
      IF v_ccobban IS NULL THEN
        p_tab_error(f_sysdate, f_user, 'pac_emision_mv.p_cobro_recibo', 2, 'Error al buscar cobrador bancario: ' || pnrecibo || ' cuenta: ' || pcbancar, SQLERRM);
        paut:=6;
        /* error axis;*/
        RAISE salir;
      END IF;
    END IF;
    /* Modificamos el recibo con la cuenta y el cobrador elegido*/
    BEGIN
      UPDATE recibos
      SET cbancar  =pcbancar,
        ccobban    =v_ccobban,
        ctipban    =pctipban
      WHERE nrecibo=pnrecibo;
    EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'pac_emision_mv.p_cobro_recibo', 3, 'Error al modificar la cuenta del recibo: ' || pnrecibo, SQLERRM);
      v_error:=102358;
      /* error al modificar recibos*/
      paut:=6;
      RAISE salir;
    END;
    /*- cobramos el recibo si:*/
    /* es cobro por caja*/
    /* la cuenta del cobro es de la ntidad TF (en este caso Banca March)*/
    /* si la fecha es igual o menor a hoy*/
    IF (ptipocobro=1 AND entidad_tf<>entidad_cbancar) OR v_fefecto>f_sysdate THEN
      /* Cobro por cuenta y entidad diferente a la propia de TF.*/
      /* No se cobra el recibo, sólo se deja pendiente de domiciliar*/
      BEGIN
        UPDATE recibos SET cestimp=4 WHERE nrecibo=pnrecibo;
      EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'pac_emision_mv.p_cobro_recibo', 4, 'Error al modificar es estado de impresion del recibo: ' || pnrecibo, SQLERRM);
        v_error:=102358;
        /* error al modificar recibos*/
        paut:=6;
        RAISE salir;
      END;
    ELSIF(ptipocobro=0 OR (ptipocobro=1 AND entidad_tf=entidad_cbancar)) THEN
      /* hacemos el adeudo a HOST y cobramos el recibo en axis si ha ido bien el adeudo*/
      phost:=1;
      /* obtenemos la secuencia de interfase*/
      pac_xml_mv.p_inicializar_sinterf;
      IF paut=0 THEN
        /* se llama la primera vez al adeudo del recibo*/
        v_formato:='E0';
        /* Primero cobramoe el recibo en AXIS porque si es una póliza con libreta necesitamos*/
        /* tener ya el registro de ctaseguro, el cual se inserta al cobrar el recibo.*/
        /* Si despúes el adeudo a HOST va mal, ya se hará un rollback.*/
        /*p_control_error(null, 'extr', 'llamamos a movrecibo');*/
        /*p_control_error(null, 'extr', 'v_ccobban ='||v_ccobban);*/
        /*p_control_error(null, 'extr', 'v_cdelega ='||v_cdelega);*/
        /*p_control_error(null, 'extr', 'v_caente ='||v_cagente);*/
        /* calculamos la fecha de cobro*/
        BEGIN
          SELECT fmovini
          INTO xfmovini
          FROM movrecibo
          WHERE nrecibo=pnrecibo
          AND fmovfin IS NULL;
        EXCEPTION
        WHEN OTHERS THEN
          RETURN 104043;
          /* Error al llegir de MOVRECIBO*/
        END;
        IF TRUNC(xfmovini)<=TRUNC(f_sysdate) THEN
          xfmovini        :=f_sysdate;
        END IF;
        v_error:=f_movrecibo(pnrecibo, 1, NULL, NULL, v_smovagr, v_nliqmen, v_nliqlin, xfmovini, v_ccobban, v_cdelega, NULL, v_cagente, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ptipocobro);
        /*p_control_error(null, 'extr', 'perror ='||perror);*/
        IF v_error<>0 THEN
          paut    :=6;
          RAISE salir;
        END IF;
      ELSE
        v_formato:='E1';
      END IF;
      v_error   :=pac_int_online_mv.adeudo_recibo_host(v_formato, pusuario, poficina, f_sysdate, pnrecibo, ptipocobro, paut, terror);
      IF v_error<>0 THEN
        /* se ha producido un error y no se cobrará el recibo*/
        RAISE salir;
      END IF;
    END IF;
    RETURN(0);
  EXCEPTION
  WHEN salir THEN
    RETURN(v_error);
  END p_cobro_recibo;
/* BUG9448:13/03/2009:DRA*/
/*************************************************************************
Analiza si queda retenida por aumento de capital con preguntas afirmativas
param in psseguro     : codigo del seguro
param in pnmovimi     : numero de movimiento
param in pfecha       : Fecha
param out pnerror     : indica si hay error
param out pterror     : devuelve el texto de error
param out papto       : indica si es apto o no
return NUMBER         : 0 todo ha ido bien;  1 han habido errores
*************************************************************************/
  FUNCTION f_control_capital_respuesta(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      pfecha   IN DATE,
      pnerror OUT NUMBER,
      pterror OUT VARCHAR2,
      papto OUT NUMBER )
    RETURN NUMBER
  IS
    /**/
    CURSOR c_garseg
    IS
      SELECT g.cgarant,
        s.ssegpol
      FROM estgaranseg g,
        estseguros s
      WHERE g.sseguro  =s.sseguro
      AND s.sseguro    =psseguro;
    vpasexec      NUMBER(2):=0;
    control_capit NUMBER(1):=0;
    v_crespue     NUMBER(1);
    num_err       NUMBER;
    v_capital estgaranseg.icapital%TYPE;
    v_capital_ant garanseg.icapital%TYPE;
  BEGIN
    vpasexec  :=1;
    IF pnmovimi>1 THEN
      /* BUG11288:DRA:20/10/2009:Només té sentit en suplements*/
      FOR r_gar IN c_garseg
      LOOP
        vpasexec:=11;
        BEGIN
          SELECT e.icapital
          INTO v_capital
          FROM estgaranseg e
          WHERE e.sseguro=psseguro
          AND e.cgarant  =r_gar.cgarant
          AND e.nmovimi  =pnmovimi;
        EXCEPTION
        WHEN OTHERS THEN
          v_capital:=0;
        END;
        vpasexec:=12;
        BEGIN
          /*Obtenició de l'últim capital autoritzat per aquesta garantia amb preguntes afirmatives.*/
          SELECT ga.icapital
          INTO v_capital_ant
          FROM garanseg ga
          WHERE ga.sseguro=r_gar.ssegpol
          AND ga.cgarant  =r_gar.cgarant
          AND ga.nmovimi  =
            (SELECT MAX(gn.nmovimi)
            FROM garanseg gn
            WHERE gn.sseguro=ga.sseguro
            AND gn.cgarant  =ga.cgarant
            AND gn.nmovimi <>pnmovimi
            AND gn.nmovimi <=
              (SELECT NVL(MAX(p.nmovimi), pnmovimi)
              FROM pregunseg p
              WHERE p.sseguro=ga.sseguro
              AND p.cpregun  =10
              AND p.crespue  =1
              )
            );
        EXCEPTION
        WHEN OTHERS THEN
          v_capital_ant:=0;
        END;
        vpasexec       :=13;
        IF v_capital    >v_capital_ant THEN
          control_capit:=1;
          EXIT;
        ELSE
          control_capit:=0;
        END IF;
      END LOOP;
      vpasexec       :=2;
      IF control_capit=1 THEN
        BEGIN
          SELECT 1
          INTO v_crespue
          FROM estpregunseg
          WHERE cpregun=10
            /*> Alguna respuesta afirmativa en el cuestionario de salud*/
          AND crespue=1
          AND sseguro=psseguro
          AND nmovimi=pnmovimi
          AND ROWNUM =1;
          /*> En cualquier riesgo*/
        EXCEPTION
        WHEN OTHERS THEN
          v_crespue:=0;
        END;
        vpasexec     := 3;
        IF v_crespue  = 1 THEN
          pterror    := f_axis_literales(9001251, f_usu_idioma);
          papto      := 1;
          pnerror    := 0;
          num_err    := pac_emision_mv.f_retener_poliza('EST', psseguro, 1, pnmovimi, 2, 2, pfecha);
          IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.f_control_capital_respuesta', vpasexec, 'Error al retener la póliza', num_err);
            pnerror := 1;
            RETURN num_err;
          END IF;
        END IF;
      ELSE
        /* BUG18011:DRA:17/03/2011:Inici*/
        IF pac_control_emision.f_control_capital_respuesta(psseguro, pnmovimi, pfecha)<>1 THEN
          pterror                                                                     :=f_axis_literales(9001251, f_usu_idioma);
          papto                                                                       :=1;
          pnerror                                                                     :=0;
        ELSE
          pnerror:=0;
          papto  :=0;
        END IF;
        /* BUG18011:DRA:17/03/2011:Fi*/
      END IF;
    END IF;
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'PAC_EMISION_MV.f_control_capital_respuesta', vpasexec, SQLERRM, SQLCODE);
    pnerror:=1;
    pterror:=SQLERRM;
    RETURN 1;
  END f_control_capital_respuesta;
/* BUG9640:30/03/2009:DRA*/
/*************************************************************************
Analitza els error al emitir i retorna el motiu de retenció i el literal a mostrar
param in  p_sseguro     : id. del seguro
param in  p_sproduc     : id. del producto
param in  p_indice      : indicador de la emision
param in  p_indice_e    : indicador de error en la emision
param in  p_cmotret     : codigo del motivo de retencion
param in  p_cidioma     : codigo del idioma
param out p_tmotret     : mensaje del error
return NUMBER           : 0 --> OK   1 --> KO
*************************************************************************/
  FUNCTION f_texto_emision(
      p_sseguro  IN NUMBER,
      p_indice   IN NUMBER,
      p_indice_e IN NUMBER,
      p_cmotret  IN NUMBER,
      p_cidioma  IN NUMBER,
      p_tmensaje OUT VARCHAR2 )
    RETURN NUMBER
  IS
    /**/
    v_sncertif VARCHAR2(9);
    /* Bug 8745 - 03/03/2008 - RSC - IAX - Adaptación iAxis a productos colectivos con certificados*/
    v_ncertif seguros.ncertif%TYPE;
    v_npoliza seguros.npoliza%TYPE;
    v_nsolici seguros.nsolici%TYPE;
    v_sproduc seguros.sproduc%TYPE;
    v_ttexto1 VARCHAR2(100);
    v_ttexto2 VARCHAR2(100);
    v_ttexto3 VARCHAR2(100);
    v_ttexto4 VARCHAR2(100);
    v_numerr  NUMBER;
    /* BUG:24722 24-12-2012 AMJ  Numero de Anexo en Impresion*/
    vnmovimi movseguro.nmovimi%TYPE;
    vcempres empresas.cempres%TYPE;
  BEGIN
    p_tmensaje:=NULL;
    SELECT npoliza,
      ncertif,
      sproduc
    INTO v_npoliza,
      v_ncertif,
      v_sproduc
    FROM seguros
    WHERE sseguro=p_sseguro;
    /*BUG:24722 24-12-2012 AMJ  Numero de Anexo en Impresion Ini.*/
    vcempres:=pac_contexto.f_contextovalorparametro('IAX_EMPRESA');
    vnmovimi:=pac_movseguro.f_nmovimi_ult(p_sseguro);
    /*BUG:24722 24-12-2012 AMJ  Numero de Anexo en Impresion Fin.*/
    IF p_indice_e=0 AND p_indice>=1 THEN
      /* Bug 8745 - 03/03/2009 - RSC - IAX - Adaptación iAxis a productos colectivos con certificados*/
      IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', v_sproduc)=1 THEN
        v_sncertif                                                             :=' - ' || v_ncertif;
      ELSE
        v_sncertif:=NULL;
      END IF;
      /*BUG:24722 24-12-2012 AMJ  Numero de Anexo en Impresion Ini.*/
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'SHOW_MOV'), 0)=1 THEN
        p_tmensaje                                                 :=f_axis_literales(151301, p_cidioma) || ' ' || v_npoliza || v_sncertif || '. ' || f_axis_literales(9001954, pac_md_common.f_get_cxtidioma) || ': ' || vnmovimi;
      ELSE
        p_tmensaje:=f_axis_literales(151301, p_cidioma) || ' ' || v_npoliza || v_sncertif;
      END IF;
      /*BUG:24722 24-12-2012 AMJ  Numero de Anexo en Impresion Fin.*/
    ELSE
      /* BUG5673:DRA:12-02-2009*/
      v_numerr   :=pac_seguros.f_get_nsolici_npoliza(p_sseguro, NULL, v_sproduc, NULL, v_nsolici, v_npoliza, v_ncertif);
      IF v_numerr<>0 THEN
        RETURN v_numerr;
      END IF;
      IF p_cmotret=10 THEN
        v_ttexto3:=ff_desvalorfijo(708, p_cidioma, p_cmotret);
        /* BUG 27642 - FAL - 30/04/2014*/
      ELSIF p_cmotret=53 THEN
        v_ttexto3   :=ff_desvalorfijo(708, p_cidioma, p_cmotret);
        /* FI BUG 27642 - FAL - 30/04/2014*/
      ELSE
        v_ttexto3:=f_axis_literales(151333, p_cidioma);
      END IF;
      IF v_npoliza IS NOT NULL THEN
        /* BUG5673:DRA:12-02-2009*/
        v_ttexto1:=f_axis_literales(151237, p_cidioma);
        v_ttexto2:=f_axis_literales(151332, p_cidioma);
        v_ttexto4:=v_npoliza;
      ELSE
        v_ttexto1:=f_axis_literales(9000855, p_cidioma);
        v_ttexto2:=f_axis_literales(9000854, p_cidioma);
        v_ttexto4:=v_nsolici;
      END IF;
      /* BUG9640:DRA:16/04/2009:Inici*/
      IF p_cmotret IS NULL THEN
        /*BUG:24722 24-12-2012 AMJ  Numero de Anexo en Impresion Ini.*/
        IF NVL(pac_parametros.f_parempresa_n(vcempres, 'SHOW_MOV'), 0)=1 THEN
          p_tmensaje                                                 :=v_ttexto1 || '. ' || v_ttexto2 || ': ' || v_ttexto4 || '. ' || f_axis_literales(9001954, pac_md_common.f_get_cxtidioma) || ': ' || vnmovimi || '. ' || v_ttexto3;
        ELSE
          p_tmensaje:=v_ttexto1 || '. ' || v_ttexto2 || ': ' || v_ttexto4 || '. ' || v_ttexto3;
        END IF;
        /*BUG:24722 24-12-2012 AMJ  Numero de Anexo en Impresion Fin.*/
      ELSE
        IF NVL(pac_parametros.f_parempresa_n(vcempres, 'SHOW_MOV'), 0)=1 THEN
          p_tmensaje                                                 :=v_ttexto3 || '. ' || v_ttexto2 || ': ' || v_ttexto4 || '. ' || f_axis_literales(9001954, pac_md_common.f_get_cxtidioma) || ': ' || vnmovimi || '.';
        ELSE
          p_tmensaje:=v_ttexto3 || '. ' || v_ttexto2 || ': ' || v_ttexto4 || '.';
        END IF;
      END IF;
      /* BUG9640:DRA:16/04/2009:Fi*/
    END IF;
    RETURN 0;
  END f_texto_emision;
END pac_emision_mv;

/

  GRANT EXECUTE ON "AXIS"."PAC_EMISION_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_EMISION_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_EMISION_MV" TO "PROGRAMADORESCSI";
