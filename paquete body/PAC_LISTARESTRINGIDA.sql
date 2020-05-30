--------------------------------------------------------
--  DDL for Package Body PAC_LISTARESTRINGIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LISTARESTRINGIDA" AS
   /******************************************************************************
    NAME:       pac_propio_lri
    PURPOSE:
    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        15/10/2012  JLB             1. Created this package body.
    2.0        5/02/2013   DCT             2. Modificar parámetros  orden pfexclus y pfinclus en f_valida_listarestringida
    3.0        14/02/2013  FAC             3. Listas restringidas para placas
    3.1        21/03/2013  FPG             3. Cambiar columna CMOTOR por CODMOTOR en LRE_AUTOS
    4.0        05/07/2013  RCL             4. 0027545: LCOL_F2-LCOL - Diversos QT de tipus GUI
    5.0        25/11/2013  JDS             5. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
    6.0        10/09/2014  AGG             6. 0027314: POSS5520 (POSSF200)- Resolucion de Incidencias FASE 1-2: Personas
    7.0        04/12/2015  YDA             7. 0038745: Creación del procedimiento proc_accion_lre y de la función f_valida_accion_lre
    8.0        27/08/2019  JMJRR           8. IAXIS-4854: Se cambia el usuario de base de datos por el usuario Logueado al consultar el historico de personas
	9.0		   20/03/2020  SP 			   9. Cambios de web compliance para point-2
	********************************************************************************/

   /*************************************************************************
          FUNCTION f_mail
        Función que envia un correo
        pscorreo  in number  : Identificador del número de correo.
        pcidioma  in number  : Idioma
        ptxtaux   in varchar2: Texto auxiliar
        RETURN 0(ok),1(error)
        -- BUG 0018967 - 07/09/2011 - JMF
   *************************************************************************/
   FUNCTION f_mail(pscorreo IN NUMBER, pcidioma IN NUMBER, ptxtaux IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_listarestringida.f_mail';
      vparam         VARCHAR2(500)
                 := SUBSTR(' c=' || pscorreo || ' i=' || pcidioma || ' t=' || ptxtaux, 1, 500);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_subject      desmensaje_correo.asunto%TYPE;
      v_from         mensajes_correo.remitente%TYPE;
      v_to           VARCHAR2(300);
      v_to2          VARCHAR2(300);
      v_texto        desmensaje_correo.cuerpo%TYPE;
      v_errcor       log_correo.error%TYPE;
   BEGIN
      vpasexec := 100;
      --Obtenemos el origen
      vpasexec := 110;

      BEGIN
         SELECT remitente
           INTO v_from
           FROM mensajes_correo
          WHERE scorreo = pscorreo;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151425;   --No existe ningún correo de este tipo .
      END;

      --Obtenemos los detinatarios
      vpasexec := 120;

      DECLARE
         CURSOR c1 IS
            SELECT destinatario, descripcion, direccion
              FROM destinatarios_correo
             WHERE scorreo = pscorreo;
      BEGIN
         vpasexec := 121;
         v_to := NULL;
         v_to2 := NULL;
         vpasexec := 122;

         FOR f1 IN c1 LOOP
            vpasexec := 123;
            v_to := RTRIM(f1.direccion || ';' || v_to, ';');
            vpasexec := 124;
            v_to2 := RTRIM(f1.descripcion || ';' || v_to2, ';');
         END LOOP;

         vpasexec := 125;

         IF v_to IS NULL THEN
            RETURN 151423;   -- No se han encontrado destinatarios de correo
         END IF;
      END;

      -- Obtenemos el cuerpo del correo
      vpasexec := 130;

      BEGIN
         SELECT cuerpo, asunto
           INTO v_texto, v_subject
           FROM desmensaje_correo
          WHERE scorreo = pscorreo
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151422;
      END;

      -- CASOS PARTICULARES
      vpasexec := 140;

      IF ptxtaux IS NOT NULL THEN
         v_texto := v_texto || CHR(10) || ptxtaux;
      END IF;

      BEGIN
         -- Enviar el correo
         vpasexec := 150;
         p_enviar_correo(v_from, v_to, v_from, v_to2, v_subject, v_texto);
         v_errcor := '0';
      EXCEPTION
         WHEN OTHERS THEN
            v_errcor := SQLCODE || ' ' || SQLERRM || CHR(10) || 'pscorreo=' || pscorreo
                        || ' to=' || v_to || ' ' || v_subject;
      END;

      vpasexec := 160;
      pac_correo.p_log_correo(f_sysdate, v_to, f_user, v_subject, v_errcor, NULL, NULL);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'ERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_mail;

   FUNCTION f_gen_texto1(
      p_idi IN NUMBER,
      p_noms IN VARCHAR2,
      p_apes IN VARCHAR2,
      p_tipide IN NUMBER,
      p_numide IN VARCHAR2,
      p_motivo IN VARCHAR2)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_listarestringida.f_gen_texto1';
      vparam         VARCHAR2(500)
         := SUBSTR(' i=' || p_idi || ' n=' || p_noms || ' a=' || p_apes || ' t=' || p_tipide
                   || ' i=' || p_numide,
                   1, 500);
      vpasexec       NUMBER(5) := 1;
      v_usu          usuarios.cusuari%TYPE;
      v_aux2         VARCHAR2(1000);
      v_retorno      VARCHAR2(1000);
   BEGIN
      vpasexec := 100;
      v_retorno := NULL;
      -- “Nombres: “
      vpasexec := 110;
      v_retorno := v_retorno || f_axis_literales(105940, p_idi) || ': ' || p_noms || CHR(10);

      IF p_apes IS NOT NULL THEN
         -- “Apellidos: “
         vpasexec := 120;
         v_retorno := v_retorno || f_axis_literales(1000560, p_idi) || ': ' || p_apes
                      || CHR(10);
      END IF;

      -- “Tipo doc: “
      vpasexec := 130;
      v_retorno := v_retorno || f_axis_literales(109774, p_idi) || ': '
                   || ff_desvalorfijo(672, p_idi, p_tipide) || CHR(10);
      -- “Num doc: “
      vpasexec := 140;
      v_retorno := v_retorno || f_axis_literales(105330, p_idi) || ': ' || p_numide || CHR(10);
      vpasexec := 150;
      v_usu := f_user;
      vpasexec := 160;

      SELECT ff_desagente(NVL(a.cdelega, f_zona_ofi(a.cempres, a.cdelega)))
        INTO v_aux2
        FROM usuarios a
       WHERE cusuari = v_usu;

      -- “Oficina: “
      vpasexec := 170;
      v_retorno := v_retorno || f_axis_literales(102591, p_idi) || ' ' || v_aux2 || CHR(10);
      -- “Usuario creador: “
      vpasexec := 180;
      v_retorno := v_retorno || f_axis_literales(9901861, p_idi) || ': ' || v_usu || CHR(10);
      vpasexec := 190;

      IF p_motivo IS NOT NULL THEN
         v_retorno := v_retorno || f_axis_literales(9902641, p_idi) || ': ' || p_motivo
                      || CHR(10);
      END IF;

      vpasexec := 200;
      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'ERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN vparam;
   END f_gen_texto1;

   --BUG 25965 - inicio FAC - 14/02/2013
   FUNCTION f_gen_texto2(p_idi IN NUMBER, p_cmatricula IN VARCHAR2, p_motivo IN VARCHAR2)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_listarestringida.f_gen_texto2';
      vparam         VARCHAR2(500)
                         := SUBSTR(' i=' || p_idi || ' p_cmatricula=' || p_cmatricula, 1, 500);
      vpasexec       NUMBER(5) := 1;
      v_usu          usuarios.cusuari%TYPE;
      v_aux2         VARCHAR2(1000);
      v_retorno      VARCHAR2(1000);
   BEGIN
      vpasexec := 100;
      v_retorno := NULL;
      --MATRICULA
      v_retorno := p_cmatricula || CHR(10);
      vpasexec := 110;
      v_usu := f_user;
      vpasexec := 120;

      SELECT ff_desagente(NVL(a.cdelega, f_zona_ofi(a.cempres, a.cdelega)))
        INTO v_aux2
        FROM usuarios a
       WHERE cusuari = v_usu;

      -- “Oficina: “
      vpasexec := 130;
      v_retorno := v_retorno || f_axis_literales(102591, p_idi) || ' ' || v_aux2 || CHR(10);
      -- “Usuario creador: “
      vpasexec := 140;
      v_retorno := v_retorno || f_axis_literales(9901861, p_idi) || ': ' || v_usu || CHR(10);
      vpasexec := 150;

      IF p_motivo IS NOT NULL THEN
         v_retorno := v_retorno || f_axis_literales(9902641, p_idi) || ': ' || p_motivo
                      || CHR(10);
      END IF;

      vpasexec := 160;
      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'ERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN vparam;
   END f_gen_texto2;

   --BUG 25965 - FIN FAC - 14/02/2013

   -- BUG 22463/116304 - 07/06/2012 - JLTS
   /*************************************************************************
      FUNCTION f_aviso_altapersona
        Función que desde la alta de persona, genera aviso si se cumplen unas condiciones
        pCTIPPER  in number  : Tipo de persona (V.F. 85) Física o Jurídica'
        pCTIPIDE  in number  : Tipo identificación persona ( V.F. 672, NIF, pasaporte, etc.)
        pNNUMIDE  in varchar2: Número identificación
        pTNOMBRE1 in varchar2: Nombre1 de la persona
        pTNOMBRE2 in varchar2: Nombre2 de la persona
        pTAPELLI1 in varchar2: Primer apellido
        pTAPELLI2 in varchar2: Segundo apellido
        pcidioma  in number: codigo idioma
        RETURN 0(ok),1(error),2(warning)
        -- BUG 0018967 - 07/09/2011 - JMF
        -- BUG 0018967 - 30/12/2011 - JMF: añadir sperson
   *************************************************************************/
   FUNCTION f_aviso_altapersona(
      pctipper IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pcidioma IN NUMBER,
      pcinclus IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_listarestringida.f_aviso_altapersona';
      vparam         VARCHAR2(500)
         := SUBSTR(' tp=' || pctipper || ' ti=' || pctipide || ' id=' || pnnumide || ' n1='
                   || ' id=' || pcidioma,
                   1, 500);
      vpasexec       NUMBER(5) := 1;
      v_txtaux       VARCHAR2(1000);
      v_numerr       NUMBER;
   --
   BEGIN
      vpasexec := 100;
      v_txtaux := NULL;
-------------------
-- lista externa --
-------------------
      vpasexec := 110;
      -- Preparar texto para mensaje.
      v_txtaux := f_gen_texto1(pcidioma, ptnombre, ptapelli1 || ' ' || ptapelli2, pctipide,
                               pnnumide, ff_desvalorfijo(800122, pcidioma, pcinclus));
      vpasexec := 130;
-------------------
-- lista interna --
-------------------
      vpasexec := 160;
      -- Persona entcontrada en lista interna.
      v_numerr := f_mail(51, pcidioma, v_txtaux);
      -- Si da error al enviar el mail no devuelvo error
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'ERROR: ' || SQLERRM);
         RETURN 1;
   END f_aviso_altapersona;

   /*************************************************************************
    BUG 25965 - inicio FAC - 14/02/2013
    FUNCTION f_aviso_altaautos
    Función que desde la alta de la poliza, genera aviso si se cumplen unas condiciones
    pccmatric in varchar2; numero de matricula o placa
    pcidioma  in number: codigo idioma
    RETURN 0(ok),1(error),2(warning)
   *************************************************************************/
   FUNCTION f_aviso_altaautos(pccmatric IN VARCHAR2, pcidioma IN NUMBER, pcinclus IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_listarestringida.f_aviso_altaautos';
      vparam         VARCHAR2(500)
                                  := SUBSTR(' tp=' || pccmatric || ' id=' || pcidioma, 1, 500);
      vpasexec       NUMBER(5) := 1;
      v_txtaux       VARCHAR2(1000);
      v_numerr       NUMBER;
   --
   BEGIN
      vpasexec := 100;
      v_txtaux := NULL;
-------------------
-- lista externa --
-------------------
      vpasexec := 110;
      -- Preparar texto para mensaje.
      v_txtaux := f_gen_texto2(pcidioma, pccmatric,
                               ff_desvalorfijo(800122, pcidioma, pcinclus));
      vpasexec := 130;
-------------------
-- lista interna --
-------------------
      vpasexec := 160;
      -- Persona entcontrada en lista interna.
      v_numerr := f_mail(58, pcidioma, v_txtaux);
      -- Si da error al enviar el mail no devuelvo error
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'ERROR: ' || SQLERRM);
         RETURN 1;
   END f_aviso_altaautos;

   /*************************************************************************
      FUNCTION f_set_listarestringida
       Función que inserta en la tabla lre_personas
       pspersonas in varchar2: Lista de personas
       pcclalis in number: Clase de lista
       pctiplis in number: Tipo de lista
       pcnotifi in number: Indicador de si hay que notificar o no la inserción en la lista.
       psperlre in number: Identificador de persona restringida
       pfexclus in date: Fecha de exclusión
       pfinclus in date: Fecha de inclusión
       pcinclus in number: Código motivo de inclusión
       return number: 0 -ok , otro valor ERROR
    *************************************************************************/
   FUNCTION f_set_listarestringida(
      psperson IN NUMBER,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pcnotifi IN NUMBER,
      psperlre_out OUT NUMBER,
      psperlre IN NUMBER,
      pfexclus IN DATE,
      pfinclus IN DATE,
      pcinclus IN NUMBER,
      psseguro IN NUMBER,   -- Bug 31411/175020 - 16/05/2014 - AMC
      pnmovimi IN NUMBER,
      pnsinies IN NUMBER,
      pcaccion IN NUMBER,
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      psdevolu IN NUMBER,
      pfnacimi IN DATE,
      ptdescrip IN VARCHAR2, --Se incluye campo tdescrip, AMA-232
      ptobserv IN VARCHAR2,
      ptmotexc IN VARCHAR2
      )
      RETURN NUMBER IS
      v_sperlre      lre_personas.sperlre%TYPE;
      v_persona      per_personas%ROWTYPE;
      vtparam        tab_error.tdescrip%TYPE;
      vobject        tab_error.tobjeto%TYPE
                                       := 'pac_listarestringida.f_set_seguro_listarestringida';
      vpasexec       NUMBER(1) := 0;
      vexiste        NUMBER;
      nerror         NUMBER;
      ptmensaje      VARCHAR2(500);
      v_tnombre      per_detper.tnombre%TYPE;
      v_tapelli1     per_detper.tapelli1%TYPE;
      v_tapelli2     per_detper.tapelli2%TYPE;
      per_fexclus    NUMBER(1);
      vnombre1       per_detper.tnombre1%TYPE;
      vnombre2       per_detper.tnombre2%TYPE;
      vapelli1       per_detper.tapelli1%TYPE;
      vapelli2       per_detper.tapelli2%TYPE;
      vnomape        lre_personas.tnomape%TYPE;
   BEGIN
      vtparam := 'psperson: ' || psperson || ' pcclalis: ' || pcclalis || ' pctiplis: '
                 || pctiplis || ' pcnotifi: ' || pcnotifi || ' psperlre:' || psperlre
                 || ' pfexclus:' || pfexclus || ' pfinclus:' || pfinclus || ' pcinclus:'
                 || pcinclus || ' psseguro:' || psseguro || ' pnmovimi:' || pnmovimi
                 || ' pnsinies:' || pnsinies || ' pcaccion:' || pcaccion || ' pnrecibo:'
                 || pnrecibo || ' psmovrec:' || psmovrec || ' psdevolu:' || psdevolu
                 || ' pfnacimi:' || pfnacimi|| ' ptdescrip:' || ptdescrip|| ' ptobserv:'
                 || ptobserv|| ' ptmotexc:' || ptmotexc;
      vpasexec := 1;
      -- BUG: 27314  Nota: 1623816 22/01/2014
      per_fexclus := 0;   -- Por defecto no esta activado
      -- Recoge el codigo de activacion para la empresa que estamos conectados
      per_fexclus := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                   'PER_FEXCLUS');

      -- Si el parametro de control sobre la fecha de exclusión esta activado
      -- y la fecha de exclusion es menor a la de hoy devuelve error.
      IF per_fexclus = 1
         AND pfexclus IS NOT NULL
         AND TRUNC(pfexclus) < TRUNC(f_sysdate) THEN
         RETURN 9906410;
      -- Error => 'La fecha de exclusión no puede ser menor a la hoy'
      END IF;

      -- FINAL BUG: 27314  Nota: 162569 13/01/2014
      IF psperlre IS NOT NULL THEN
         UPDATE lre_personas
            SET sperson = psperson,
                fexclus = pfexclus,
                cusumod = f_user,
                ctiplis = pctiplis,
                fmodifi = TRUNC(f_sysdate),
                tdescrip = ptdescrip,
                tobserv = ptobserv,
                tmotexc = ptmotexc
          WHERE sperlre = psperlre;

         psperlre_out := psperlre;
      ELSE
         -- BUG 26362/140183 - JLTS - 08/03/2013 -Se adiciona NVL(cinclus,999) = NVL(pcinclus,999)
         SELECT NVL(MAX(1), 0)
           INTO vexiste
           FROM lre_personas
          WHERE sperson = psperson
            AND cclalis = pcclalis
            AND ctiplis = pctiplis
            AND NVL(cinclus, 999) = NVL(pcinclus, 999)
            AND fexclus IS NULL;

         IF vexiste = 0 THEN
            SELECT *
              INTO v_persona
              FROM per_personas
             WHERE sperson = psperson;

            SELECT sperlre.NEXTVAL
              INTO v_sperlre
              FROM DUAL;

            psperlre_out := v_sperlre;

            BEGIN
               --AGG cambio tnomape para listas restringidas internas 10/09/2014
               SELECT DISTINCT pd.tnombre1, pd.tnombre2, pd.tapelli1, pd.tapelli2
                          INTO vnombre1, vnombre2, vapelli1, vapelli2
                          FROM per_personas p, per_detper pd
                         WHERE p.sperson = pd.sperson
                           AND p.nnumide = v_persona.nnumide
                           AND p.sperson = (SELECT MAX(p2.sperson)
                                              FROM per_personas p2
                                             WHERE p2.nnumide = v_persona.nnumide);

               vnomape := vnombre1 || vnombre2 || vapelli1 || vapelli2;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                              'nnumide: ' || v_persona.nnumide, SQLERRM);
                  NULL;
            END;

            BEGIN
               INSERT INTO lre_personas
                           (sperlre, nnumide, nordide,
                            ctipide, ctipper, tnomape, tnombre1, tnombre2, tapelli1,
                            tapelli2, sperson, cnovedad, cnotifi, cclalis, ctiplis,
                            finclus, fexclus, cinclus, cexclus, cusumod,
                            fmodifi, sseguro, nmovimi, caccion, nsinies,
                            nrecibo, smovrec, sdevolu,
                                                      -- Bug 31411/175020 - 16/05/2014 - AMC
                                                      fnacimi, tdescrip,
                                                      -- INI JAAB CONF-239
                                                      tobserv,
                                                      tmotexc,
                                                      cmarca
                                                      -- FIN JAAB CONF-239
                                                      )

                    VALUES (v_sperlre, v_persona.nnumide, v_persona.nordide,
                            v_persona.ctipide, v_persona.ctipper, NULL, NULL, NULL, NULL,
                            NULL, psperson, 1, pcnotifi, pcclalis, pctiplis,
                            NVL(pfinclus, f_sysdate), pfexclus, pcinclus, NULL, f_user,
                            TRUNC(f_sysdate), psseguro, pnmovimi, pcaccion, pnsinies,
                            pnrecibo, psmovrec, psdevolu,
                                                         -- Bug 31411/175020 - 16/05/2014 - AMC
                                                         pfnacimi, ptdescrip,
                                                         -- INI JAAB CONF-239
                                                         ptobserv,
                                                         ptmotexc,
                                                         1
                                                         -- FIN JAAB CONF-239
                                                         );

            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN   -- si ya esta creada no la vuelvo a crear
                  NULL;
            END;
         END IF;

         IF NVL(pcnotifi, 0) = 1 THEN
            SELECT LTRIM(RTRIM(pd.tapelli1)), LTRIM(RTRIM(pd.tapelli2)),
                   LTRIM(RTRIM(pd.tnombre))
              INTO v_tapelli1, v_tapelli2,
                   v_tnombre
              FROM personas pd
             WHERE sperson = psperson
               AND ROWNUM = 1;

            nerror :=
               f_aviso_altapersona
                          (v_persona.ctipper, v_persona.ctipide, v_persona.nnumide, v_tnombre,
                           v_tapelli1, v_tapelli2,
                           NVL(f_usu_idioma,
                               pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                             'IDIOMA_DEF')),
                           pcinclus);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9902875;
   END f_set_listarestringida;

   /*************************************************************************
      BUG 25965 - inicio FAC - 14/02/2013
      FUNCTION f_set_listarestringida_aut
       Función que inserta en la tabla lre_autos
       psmatric in varchar2: Lista de Placas
       pcodmotor IN VARCHAR2: codigo de motor
       pcchasis IN VARCHAR2,: codigo de chasis
       pnbastid IN VARCHAR2: codigo VIN o Nbastidor
       pcclalis in number: Clase de lista
       pctiplis in number: Tipo de lista
       pcnotifi in number: Indicador de si hay que notificar o no la inserción en la lista.
       psmatrilre in number: Identificador de matricula restringida
       pfexclus in date: Fecha de exclusión
       pfinclus in date: Fecha de inclusión
       pcinclus in number: Código motivo de inclusión
       return number: 0 -ok , otro valor ERROR
    *************************************************************************/
   FUNCTION f_set_listarestringida_aut(
      psmatric IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pcnotifi IN NUMBER,
      psmatriclre_out OUT NUMBER,
      psmatriclre IN NUMBER,
      pfexclus IN DATE,
      pfinclus IN DATE,
      pcinclus IN NUMBER,
      psseguro IN NUMBER,
      -- Bug 31411/175020 - 16/05/2014 - AMC
      pnmovimi IN NUMBER,
      pnsinies IN NUMBER,
      pcaccion IN NUMBER,
      pnrecibo IN NUMBER,
      psmovrec IN NUMBER,
      psdevolu IN NUMBER)
      RETURN NUMBER IS
      v_smatriclre   lre_autos.smatriclre%TYPE;
      v_autos        autriesgos%ROWTYPE;
      vtparam        tab_error.tdescrip%TYPE;
      vobject        tab_error.tobjeto%TYPE
                                          := 'pac_listarestringida.f_set_listarestringida_aut';
      vpasexec       NUMBER(1) := 0;
      vexiste        NUMBER;
      nerror         NUMBER;
      ptmensaje      VARCHAR2(500);
      v_cmatric      autriesgos.cmatric%TYPE;
      v_codmotor     autriesgos.codmotor%TYPE;
      v_cchasis      autriesgos.cchasis%TYPE;
      v_nbastid      autriesgos.nbastid%TYPE;
      vcontador      NUMBER(1) := 0;
   BEGIN
      vtparam := 'psmatric: ' || psmatric || ' pcclalis: ' || pcclalis || ' pctiplis: '
                 || pctiplis || ' pcnotifi: ' || pcnotifi || ' pfexclus:' || pfexclus
                 || ' pfinclus:' || pfinclus || ' pcinclus:' || pcinclus || ' psseguro:'
                 || psseguro || ' pnmovimi:' || pnmovimi || ' pnsinies:' || pnsinies
                 || ' pcaccion:' || pcaccion || ' pnrecibo:' || pnrecibo || ' psmovrec:'
                 || psmovrec || ' psdevolu:' || psdevolu;
      vpasexec := 1;

      IF psmatriclre IS NOT NULL THEN
         UPDATE lre_autos
            SET cmatric = psmatric,
                codmotor = pcodmotor,
                cchasis = pcchasis,
                nbastid = pnbastid,
                fexclus = pfexclus,
                cusumod = f_user,
                fmodifi = TRUNC(f_sysdate)
          WHERE smatriclre = psmatriclre;

         psmatriclre_out := psmatriclre;
      ELSE
         SELECT NVL(MAX(1), 0)
           INTO vexiste
           FROM lre_autos
          WHERE (cmatric = psmatric
                 OR codmotor = pcodmotor
                 OR cchasis = pcchasis
                 OR nbastid = pnbastid)
            AND cclalis = pcclalis
            AND ctiplis = pctiplis
            AND cinclus = pcinclus
            AND fexclus IS NULL;

         IF vexiste = 0 THEN
            SELECT smatriclre.NEXTVAL
              INTO v_smatriclre
              FROM DUAL;

            vpasexec := 2;
            psmatriclre_out := v_smatriclre;

            BEGIN
               INSERT INTO lre_autos
                           (smatriclre, cmatric, codmotor, cchasis, nbastid, cnovedad,
                            cnotifi, cclalis, ctiplis, finclus, fexclus,
                            cinclus, cexclus, cusumod, fmodifi, sseguro, nmovimi,
                            caccion, nsinies, nrecibo, smovrec,
                            sdevolu   -- Bug 31411/175020 - 16/05/2014 - AMC
                                   )
                    VALUES (v_smatriclre, psmatric, pcodmotor, pcchasis, pnbastid, 1,
                            pcnotifi, pcclalis, pctiplis, NVL(pfinclus, f_sysdate), pfexclus,
                            pcinclus, NULL, f_user, TRUNC(f_sysdate), psseguro, pnmovimi,
                            pcaccion, pnsinies, pnrecibo, psmovrec,
                            psdevolu   -- Bug 31411/175020 - 16/05/2014 - AMC
                                    );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN   -- si ya esta creada no la vuelvo a crear
                  NULL;
            END;
         END IF;

         IF NVL(pcnotifi, 0) = 1 THEN
            nerror :=
               f_aviso_altaautos
                         ('Matricula: ' || psmatric || CHR(10) || ' Motor: ' || pcodmotor
                          || CHR(10) || ' Chasis: ' || pcchasis || CHR(10) || ' Vin: '
                          || pnbastid,
                          NVL(f_usu_idioma,
                              pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                            'IDIOMA_DEF')),
                          pcinclus);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9902875;
   END f_set_listarestringida_aut;

   /*************************************************************************
        FUNCTION f_valida_LISTARESTRINGIDA
      Función que recorrerá Glre_validacion y recuperará las funciones que de validación que se han definido
      para los productos/actividades y acciones seleccionadas
      psseguro in number: identificador del seguro
      pnmovimi in number: número de movimiento
      paccion  in number: accion que se esta realizando (anulacion, emision,etc)
      pmensa  out number: parámetro de entrada/salida
      return number: retorno de la función F_VALIDA_LRI
   *************************************************************************/
   FUNCTION f_valida_listarestringida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnsinies IN NUMBER,
      pcaccion IN NUMBER,
      pnrecibo IN NUMBER,   -- Bug 31411/175020 - 16/05/2014 - AMC
      psmovrec IN NUMBER,
      psdevolu IN NUMBER)
      RETURN NUMBER IS
      vnerror        NUMBER;
      v_resultado    NUMBER;
      vtparam        tab_error.tdescrip%TYPE;
      vobject        tab_error.tobjeto%TYPE
                                          := 'pac_listarestringida. F_VALIDA_LISTARESTRINGIDA';
      vpasexec       NUMBER := 0;
      vnordval       NUMBER;
      vsperlre_out   NUMBER;
      vcmaticlre_out NUMBER;

      CURSOR c_validaciones IS
         SELECT   lre.tlreval tlreval, lre.cclalis cclalis, lre.ctiplis ctiplis, crol crol,
                  cnotifi cnotifi, nordval
             FROM lre_validacion lre, seguros seg
            WHERE lre.sproduc = seg.sproduc
              AND lre.cactivi = seg.cactivi
              AND seg.sseguro = psseguro
              AND caccion = pcaccion
         UNION
         SELECT   lre.tlreval tlreval, lre.cclalis cclalis, lre.ctiplis ctiplis, crol crol,
                  cnotifi cnotifi, nordval
             FROM lre_validacion lre
            WHERE lre.sproduc = 0
              AND lre.cactivi = 0
              AND caccion = pcaccion
         ORDER BY nordval;

      CURSOR c_personas_candidatas(pcrolper IN NUMBER) IS
         SELECT sperson, NULL nriesgo
           FROM tomadores
          WHERE sseguro = psseguro
            AND pcrolper IN(1, 3)   -- Tomadores y tomadores/asegurados
         UNION
         SELECT sperson, nriesgo nriesgo
           FROM asegurados
          WHERE sseguro = psseguro
            AND(ffecfin IS NULL
                OR ffecfin > f_sysdate)
            AND pcrolper IN(2, 3)   -- Asegurados y tomadores/asegurados
         --BUG 25965 - inicio FAC - 14/02/2013 se aanade al cursor el rol de conductores
         UNION
         SELECT sperson, nriesgo nriesgo
           FROM autconductores
          WHERE sseguro = psseguro
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM autconductores
                            WHERE sseguro = psseguro)
            AND pcrolper = 4;   -- Conductores

      --BUG 25965 - FIN FAC - 14/02/2013 se aanade al cursor el rol de conductores

      --BUG 25965 - inicio FAC - 14/02/2013 se adiciona el cursor  c_personas_candidatas_aut  para el trataimento de matriculas
      CURSOR c_personas_candidatas_aut(pcrolper IN NUMBER) IS
         SELECT cmatric, codmotor, cchasis, nbastid, NULL nriesgo
           FROM autriesgos
          WHERE sseguro = psseguro
            AND pcrolper = 5;   --Auto(Matricula  )
   --BUG 25965 - inicio FAC - 14/02/2013 se adiciona el cursor  c_personas_candidatas_aut  para el trataimento de matriculas
   BEGIN
      vtparam := 'psseguro: ' || psseguro || ' pnmovimi: ' || pnmovimi || ' paccion: '
                 || pcaccion || ' pnsinies: ' || pcaccion;
      vpasexec := 1;

      FOR i IN c_validaciones LOOP
         vpasexec := 2;
         vnordval := i.nordval;

         FOR candidatos IN c_personas_candidatas(i.crol) LOOP
            vnerror := pac_albsgt.f_tvallre(i.tlreval, 'SEG', psseguro, pnmovimi,
                                            candidatos.nriesgo, candidatos.sperson, pnsinies,
                                            v_resultado);
            vpasexec := 3;

            -- Si ha ocurrido un error retornamos
            IF vnerror <> 0 THEN
               RETURN vnerror;
            END IF;

            vpasexec := 4;

            -- Si la garantía no ha superado la validación retornamos
            IF v_resultado = 1 THEN
               --BUG 25583 - 137165 - INICIO- DCT - 5/02/2013 - La fecha excusión no se debe informar la f_sysdate y si en cambio la fecha de inclusión
               vnerror :=
                  f_set_listarestringida(candidatos.sperson, i.cclalis, i.ctiplis, i.cnotifi,
                                         vsperlre_out, NULL, NULL, f_sysdate, NULL, psseguro,
                                         pnmovimi, pnsinies, pcaccion, pnrecibo, psmovrec,
                                         psdevolu,   -- Bug 31411/175020 - 16/05/2014 - AMC
                                         NULL,NULL,NULL,NULL);

               --BUG 25583 - 137165 - FIN- DCT - 5/02/2013 - La fecha excusión no se debe informar la f_sysdate y si en cambio la fecha de inclusión

               -- Si ha ocurrido un error retornamos
               IF vnerror <> 0 THEN
                  RETURN vnerror;
               END IF;
            END IF;
         END LOOP;   --fin candidatos

         --BUG 25965 - inicio FAC - 14/02/2013 Cursor encarcado de taratar los tipos crol= 5 automoviles
         FOR candidatos_aut IN c_personas_candidatas_aut(i.crol) LOOP
            vnerror := pac_albsgt.f_tvallre(i.tlreval, 'SEG', psseguro, pnmovimi,
                                            candidatos_aut.nriesgo, psseguro, pnsinies,
                                            v_resultado);
            vpasexec := 3;

            -- Si ha ocurrido un error retornamos
            IF vnerror <> 0 THEN
               RETURN vnerror;
            END IF;

            vpasexec := 4;

            IF v_resultado = 1 THEN
               vnerror :=
                  f_set_listarestringida_aut(candidatos_aut.cmatric, candidatos_aut.codmotor,
                                             candidatos_aut.cchasis, candidatos_aut.nbastid,
                                             i.cclalis, i.ctiplis, i.cnotifi, vcmaticlre_out,
                                             NULL, NULL, f_sysdate, NULL, psseguro, pnmovimi,
                                             pnsinies, pcaccion, pnrecibo, psmovrec,
                                             psdevolu   -- Bug 31411/175020 - 16/05/2014 - AMC
                                                     );

               IF vnerror <> 0 THEN
                  RETURN vnerror;
               END IF;
            END IF;
         END LOOP;   --fin candidatos -aut
      --BUG 25965 - FIN FAC - 14/02/2013 Cursor encarcado de taratar los tipos crol= 5 automoviles
      END LOOP;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         vtparam := vtparam || ' - vnordval: ' || vnordval;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9901995;
   END f_valida_listarestringida;

   /*************************************************************************
      FUNCTION f_get_listarestringida
       Función que recupera las listas restringidas
       return lista de personas restringidas
       Bug 23824/124452 - 31/10/2012 - AMC
    *************************************************************************/
   FUNCTION f_get_listarestringida(
      pctipper IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnomape IN VARCHAR2,
      pcclais IN NUMBER,
      pctiplis IN NUMBER,
      pfinclusdesde IN DATE,
      pfinclushasta IN DATE,
      pfexclusdesde IN DATE,
      pfexclushasta IN DATE,
      psperlre IN NUMBER,
      pcidioma IN NUMBER,
      pfnacimi IN DATE,
      ptdescrip IN VARCHAR2 --Se incluye campo tdescrip, AMA-232
      )
      RETURN VARCHAR2 IS
      vtparam        VARCHAR2(500)
         := 'pctipper: ' || pctipper || ' pctipide: ' || pctipide || ' pnnumide: ' || pnnumide
            || ' ptnomape: ' || ptnomape || ' pcclais: ' || pcclais || ' pctiplis: '
            || pctiplis || ' pfinclusdesde: ' || pfinclusdesde || ' pfinclushasta: '
            || pfinclushasta || ' pfexclusdesde: ' || pfexclusdesde || ' pfexclushasta: '
            || pfexclushasta || ' psperlre:' || psperlre ||' ptdescrip: '||ptdescrip;
      vobject        tab_error.tobjeto%TYPE := 'pac_listarestringida.f_get_listarestringida';
      vpasexec       NUMBER(1) := 0;
      vrownum        VARCHAR2(3000);
      vsquery        VARCHAR2(3000);
      vsquery2       VARCHAR2(1000);
      vwhere         VARCHAR2(1000);
      vwhere2        VARCHAR2(1000);
      vrownum2       VARCHAR2(3000);
   BEGIN
      vpasexec := 1;
      --05/07/2013 - RCL - Inici BUG 27545/18006
      --se agregan los campos , tobserv, tmotexc CONF-239 JAVENDANO
      vrownum :=
         'select SPERLRE, NNUMIDE, NORDIDE, CTIPIDE, TTIPIDE, CTIPPER, TTIPPER,
                 nvl(TNOMAPE, TNOMBRE1 ||'' ''|| TNOMBRE2||'', ''||TAPELLI1||'' ''||TAPELLI2) TNOMAPE, TNOMBRE1, TNOMBRE2, TAPELLI1, TAPELLI2, SPERSON,
                  CNOVEDAD, CNOTIFI, CCLALIS, TCLALIS, CTIPLIS, TTIPLIS,
                 FINCLUS, FEXCLUS, CINCLUS, CEXCLUS, CUSUMOD, FMODIFI,
                 npoliza, nmovimi, ttipocaccion, nsinies, nrecibo,smovrec,sdevolu,
                 FNACIMI, tdescrip, tobserv, tmotexc
                 FROM (';
      vrownum2 :=
                 ') where ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      --05/07/2013 - RCL - Fi BUG 27545/18006
      vsquery :=
         'select SPERLRE, NNUMIDE, NORDIDE,
                         CTIPIDE, ff_desvalorfijo(672,'
         || pcidioma
         || ',CTIPIDE) TTIPIDE,
                         CTIPPER, ff_desvalorfijo(85,' || pcidioma
         || ',CTIPPER) TTIPPER,
                         TNOMAPE, TNOMBRE1, TNOMBRE2, TAPELLI1, TAPELLI2,
                         SPERSON, CNOVEDAD, CNOTIFI,
                         CCLALIS,ff_desvalorfijo(800040,'
         || pcidioma
         || ',CCLALIS) TCLALIS,
                         CTIPLIS, ff_desvalorfijo(800048,' || pcidioma
         || ',CTIPLIS) TTIPLIS,
                         FINCLUS, FEXCLUS, CINCLUS, CEXCLUS, CUSUMOD, FMODIFI, FNACIMI'
         -- Bug 31411/175020 - 16/05/2014 - AMC
         || ' ,F_FORMATOPOLSEG(sseguro) npoliza, nmovimi,' || ' ff_desvalorfijo(800121,'
         || pcidioma || ',caccion) ttipocaccion, nsinies, nrecibo,smovrec,sdevolu'
         -- Fi Bug 31411/175020 - 16/05/2014 - AMC
         || ', tdescrip' --Se incluye campo tdescrip, AMA-232
		 || ', tobserv, tmotexc' --Se incluyen campos , tobserv, tmotexc CONF-239 JAVENDANO
         || '  from lre_personas where sperson is null';
      vsquery2 :=
         ' union
                   select SPERLRE, per.NNUMIDE, per.NORDIDE,
                          per.CTIPIDE, ff_desvalorfijo(672,'
         || pcidioma
         || ',per.CTIPIDE) TTIPIDE,
                          per.CTIPPER, ff_desvalorfijo(85,' || pcidioma
         || ',per.CTIPPER) TTIPPER,
                          F_NOMBRE(lre.sperson,3) tnomape, per.tnombre TNOMBRE1, null TNOMBRE2, per.TAPELLI1, per.TAPELLI2,
                          per.SPERSON, lre.CNOVEDAD, lre.CNOTIFI,
                          lre.CCLALIS,ff_desvalorfijo(800040,'
         || pcidioma
         || ',lre.CCLALIS) TCLALIS,
                          lre.CTIPLIS, ff_desvalorfijo(800048,'
         || pcidioma
         || ',lre.CTIPLIS) TTIPLIS,
                          lre.FINCLUS, lre.FEXCLUS, lre.CINCLUS, lre.CEXCLUS, lre.CUSUMOD, lre.FMODIFI, per.FNACIMI'
         -- Bug 31411/175020 - 16/05/2014 - AMC
         || ' ,F_FORMATOPOLSEG(lre.sseguro) npoliza, lre.nmovimi,'
         || ' ff_desvalorfijo(800121,' || pcidioma
         || ',lre.caccion) ttipocaccion, lre.nsinies,lre.nrecibo,'
         || ' lre.smovrec,lre.sdevolu'
         -- Fi Bug 31411/175020 - 16/05/2014 - AMC
         || ', tdescrip' --Se incluye campo tdescrip, AMA-232
		 || ', tobserv, tmotexc' --Se incluyen campos , tobserv, tmotexc CONF-239 JAVENDANO
         || '         from lre_personas lre, personas per
                   where lre.SPERSON = per.sperson ';

      IF psperlre IS NOT NULL THEN
         vwhere := vwhere || ' and sperlre = ' || psperlre;
         vwhere2 := vwhere2 || ' and lre.sperlre = ' || psperlre;
      END IF;

      IF pctipper IS NOT NULL THEN
         vwhere := vwhere || ' and ctipper = ' || pctipper;
         vwhere2 := vwhere2 || ' and per.ctipper = ' || pctipper;
      END IF;

      IF pctipide IS NOT NULL THEN
         vwhere := vwhere || ' and ctipide = ' || pctipide;
         vwhere2 := vwhere2 || ' and per.ctipide = ' || pctipide;
      END IF;

      --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
      IF pnnumide IS NOT NULL THEN
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'),
                0) = 1 THEN
            vwhere := vwhere || ' and UPPER(nnumide) LIKE UPPER(''' || '%' || pnnumide || '%'
                      || ''')';
            vwhere2 := vwhere2 || ' and UPPER(per.nnumide) LIKE UPPER(''' || '%' || pnnumide
                       || '%' || ''')';
         ELSE
            vwhere := vwhere || ' and nnumide = ' || CHR(39) || pnnumide || CHR(39);
            vwhere2 := vwhere2 || ' and per.nnumide = ' || CHR(39) || pnnumide || CHR(39);
         END IF;
      END IF;

      IF ptnomape IS NOT NULL THEN
         vwhere := vwhere || ' and upper(tnomape) like ' || CHR(39) || CHR(37)
                   || UPPER(ptnomape) || CHR(37) || CHR(39);
         vwhere2 := vwhere2 || ' and upper(per.tbuscar) like ' || CHR(39) || CHR(37)
                    || UPPER(ptnomape) || CHR(37) || CHR(39);
      END IF;

      IF pcclais IS NOT NULL THEN
         vwhere := vwhere || ' and cclalis = ' || pcclais;
         vwhere2 := vwhere2 || ' and lre.cclalis = ' || pcclais;
      END IF;

      IF pctiplis IS NOT NULL THEN
         vwhere := vwhere || ' and ctiplis = ' || pctiplis;
         vwhere2 := vwhere2 || ' and lre.ctiplis = ' || pctiplis;
      END IF;

      IF pfinclusdesde IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(finclus) >= ' || CHR(39) || pfinclusdesde || CHR(39);
         vwhere2 := vwhere2 || ' and trunc(lre.finclus) >= ' || CHR(39) || pfinclusdesde
                    || CHR(39);
      END IF;

      IF pfinclushasta IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(finclus) <= ' || CHR(39) || pfinclushasta || CHR(39);
         vwhere2 := vwhere2 || ' and trunc(lre.finclus) <= ' || CHR(39) || pfinclushasta
                    || CHR(39);
      END IF;

      IF pfexclusdesde IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(fexclus) >= ' || CHR(39) || pfexclusdesde || CHR(39);
         vwhere2 := vwhere2 || ' and trunc(lre.fexclus) >= ' || CHR(39) || pfexclusdesde
                    || CHR(39);
      END IF;

      IF pfexclushasta IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(fexclus) <= ' || CHR(39) || pfexclushasta || CHR(39);
         vwhere2 := vwhere2 || ' and trunc(lre.fexclus) <= ' || CHR(39) || pfexclushasta
                    || CHR(39);
      END IF;

      --modificacion msv
      IF pfnacimi IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(fnacimi) = ' || CHR(39) || pfnacimi || CHR(39);
         vwhere2 := vwhere2 || ' and trunc(lre.fnacimi) = ' || CHR(39) || pfnacimi || CHR(39);
      END IF;

      --05/07/2013 - RCL - Inici BUG 27545/18006
      vsquery := vrownum || vsquery || vwhere || vsquery2 || vwhere2 || vrownum2;
      --05/07/2013 - RCL - Fi BUG 27545/18006
      RETURN vsquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN NULL;
   END f_get_listarestringida;

   /*************************************************************************
         FUNCTION f_get_existepersona
      Función que recupera si existe una persona en la lista restringida
       return number: 0 -ok , otro valor ERROR
      Bug 23824/124452 - 06/11/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_existepersona(
      psperson IN NUMBER,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pcinclus IN NUMBER)
      RETURN NUMBER IS
      vtparam        tab_error.tdescrip%TYPE := 'psperson:' || psperson;
      vobject        tab_error.tobjeto%TYPE := 'pac_listarestringida.f_get_existepersona';
      vpasexec       NUMBER(1) := 0;
      vexiste        NUMBER;
   BEGIN
      SELECT NVL(MAX(1), 0)
        INTO vexiste
        FROM lre_personas
       WHERE sperson = psperson
         AND cclalis = pcclalis
         AND ctiplis = pctiplis
         AND cinclus = pcinclus
         AND fexclus IS NULL;

      IF vexiste = 1 THEN
         RETURN 9904450;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN SQLERRM;
   END f_get_existepersona;

   /*************************************************************************
     FUNCTION f_get_listarestringida_aut
      Funcion que recupera las listas restringidas de autos
      return lista de autos restringidos
      Bug 26923/152307 - 10/09/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_listarestringida_aut(
      pcmatric IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pfinclusdesde IN DATE,
      pfinclushasta IN DATE,
      pfexclusdesde IN DATE,
      pfexclushasta IN DATE,
      pcidioma IN NUMBER,
      psmatriclre IN NUMBER)
      RETURN VARCHAR2 IS
      vtparam        VARCHAR2(500)
         := 'pcmatric: ' || pcmatric || ' pcodmotor: ' || pcodmotor || ' pcchasis: '
            || pcchasis || ' pnbastid: ' || pnbastid || ' pcclalis: ' || pcclalis
            || ' pctiplis: ' || pctiplis || ' pfinclusdesde: ' || pfinclusdesde
            || ' pfinclushasta: ' || pfinclushasta || ' pfexclusdesde: ' || pfexclusdesde
            || ' pfexclushasta: ' || pfexclushasta;
      vobject        tab_error.tobjeto%TYPE
                                          := 'pac_listarestringida.f_get_listarestringida_aut';
      vpasexec       NUMBER := 0;
      vrownum        VARCHAR2(3000);
      vsquery        VARCHAR2(8000);
      vwhere         VARCHAR2(2000);
      vrownum2       VARCHAR2(3000);
   BEGIN
      vpasexec := 1;
      vrownum :=
         'select SMATRICLRE, CMATRIC, CODMOTOR, CCHASIS, NBASTID, CNOVEDAD, CNOTIFI, CCLALIS,
                 TCLALIS, CTIPLIS, TTIPLIS, FINCLUS, FEXCLUS, CINCLUS, CEXCLUS, CUSUMOD, FMODIFI
                 ,npoliza,nmovimi,ttipocaccion,nsinies,nrecibo,smovrec,sdevolu
                 FROM (';
      vpasexec := 2;
      vrownum2 :=
                 ') where ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REG''),100)';
      vpasexec := 3;
      vsquery :=
         'select SMATRICLRE, CMATRIC, CODMOTOR, CCHASIS, NBASTID, CNOVEDAD, CNOTIFI, CCLALIS,'
         || ' ff_desvalorfijo(800040,' || pcidioma || ',CCLALIS) TCLALIS,'
         || ' CTIPLIS, ff_desvalorfijo(800048,' || pcidioma || ',CTIPLIS) TTIPLIS,'
         || ' FINCLUS, FEXCLUS, CINCLUS, CEXCLUS, CUSUMOD, FMODIFI'
         -- Bug 31411/175020 - 16/05/2014 - AMC
         || ' ,F_FORMATOPOLSEG(sseguro) npoliza, nmovimi,' || ' ff_desvalorfijo(800121,'
         || pcidioma || ',caccion) ttipocaccion, nsinies, nrecibo,smovrec,sdevolu'
         -- Fi Bug 31411/175020 - 16/05/2014 - AMC
         || ' from lre_autos ' || ' where 1 = 1 ';
      vpasexec := 4;

      IF psmatriclre IS NOT NULL THEN
         vwhere := vwhere || ' and smatriclre = ' || psmatriclre;
      END IF;

      IF pcmatric IS NOT NULL THEN
         vwhere := vwhere || ' and cmatric = ' || CHR(39) || pcmatric || CHR(39);
      END IF;

      vpasexec := 5;

      IF pcodmotor IS NOT NULL THEN
         vwhere := vwhere || ' and codmotor = ' || CHR(39) || pcodmotor || CHR(39);
      END IF;

      vpasexec := 6;

      IF pcchasis IS NOT NULL THEN
         vwhere := vwhere || ' and cchasis = ' || CHR(39) || pcchasis || CHR(39);
      END IF;

      vpasexec := 7;

      IF pnbastid IS NOT NULL THEN
         vwhere := vwhere || ' and nbastid = ' || CHR(39) || pnbastid || CHR(39);
      END IF;

      vpasexec := 8;

      IF pcclalis IS NOT NULL THEN
         vwhere := vwhere || ' and cclalis = ' || pcclalis;
      END IF;

      vpasexec := 9;

      IF pctiplis IS NOT NULL THEN
         vwhere := vwhere || ' and ctiplis = ' || pctiplis;
      END IF;

      vpasexec := 10;

      IF pfinclusdesde IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(finclus) >= ' || CHR(39) || pfinclusdesde || CHR(39);
      END IF;

      vpasexec := 11;

      IF pfinclushasta IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(finclus) <= ' || CHR(39) || pfinclushasta || CHR(39);
      END IF;

      vpasexec := 12;

      IF pfexclusdesde IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(fexclus) >= ' || CHR(39) || pfexclusdesde || CHR(39);
      END IF;

      vpasexec := 13;

      IF pfinclushasta IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(fexclus) <= ' || CHR(39) || pfexclushasta || CHR(39);
      END IF;

      vpasexec := 14;
      vsquery := vrownum || vsquery || vwhere || vrownum2;
      vpasexec := 15;
      RETURN vsquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN NULL;
   END f_get_listarestringida_aut;

   /*************************************************************************
      FUNCTION f_get_existeauto
      Funcion que recupera si existe un auto en la lista restringida
      return number: 0 -ok , otro valor ERROR
      Bug 26923/152307 - 10/09/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_existeauto(
      pcmatric IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pcinclus IN NUMBER)
      RETURN NUMBER IS
      vtparam        tab_error.tdescrip%TYPE
         := 'pcmatric:' || pcmatric || ' pcclalis:' || pcclalis || ' pctiplis:' || pctiplis
            || ' pcinclus:' || pcinclus;
      vobject        tab_error.tobjeto%TYPE := 'pac_listarestringida.f_get_existeauto';
      vpasexec       NUMBER(1) := 0;
      vexiste        NUMBER;
   BEGIN
      SELECT NVL(MAX(1), 0)
        INTO vexiste
        FROM lre_autos
       WHERE cmatric = pcmatric
         AND cclalis = pcclalis
         AND ctiplis = pctiplis
         AND cinclus = pcinclus
         AND fexclus IS NULL;

      IF vexiste = 1 THEN
         RETURN 9905974;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN SQLERRM;
   END f_get_existeauto;

   /*************************************************************************
      FUNCTION proc_accion_lre
      Procedimiento que recupera la acción activa
      return number: 0 -ok , otro valor ERROR
      Bug 38745/219383 - 04/12/2015 - YDA
   *************************************************************************/
   PROCEDURE proc_accion_lre(
      p_cempres IN NUMBER,
      p_cmotmov IN NUMBER,
      p_ctiplis IN NUMBER,
      p_email OUT BOOLEAN,
      p_underwriter OUT BOOLEAN,
      p_mlro OUT BOOLEAN,
      p_agenda OUT BOOLEAN,
      p_block OUT BOOLEAN) IS
      vtaccion       cfg_lre.taccion%TYPE;
      vtparam        tab_error.tdescrip%TYPE
         := 'p_cempres:' || p_cempres || ' p_cmotmov:' || p_cmotmov || ' p_ctiplis:'
            || p_ctiplis;
      vobject        tab_error.tobjeto%TYPE := 'pac_listarestringida.proc_accion_lre';
      vpasexec       NUMBER(1) := 0;
   BEGIN
      vpasexec := 1;

      BEGIN
         SELECT taccion
           INTO vtaccion
           FROM cfg_lre
          WHERE cempres = p_cempres
            AND cmodo = 'GENERAL'
            AND sproduc = 0
            AND cmotmov = p_cmotmov
            AND ctiplis = p_ctiplis
            AND cactivo = 1;
      EXCEPTION
         WHEN OTHERS THEN
            vtaccion := NULL;
      END;

      --  actions are: email ==> E,
      --               underwriter ==> U,
      --               mlro ==> M,
      --               agenda ==> A,
      --               block ==> B,
      --               no action ==> null
      vpasexec := 2;

      IF NVL(INSTR(vtaccion, 'E', 1), 0) = 0 THEN
         p_email := FALSE;
      ELSE
         p_email := TRUE;
      END IF;

      vpasexec := 3;

      IF NVL(INSTR(vtaccion, 'U', 1), 0) = 0 THEN
         p_underwriter := FALSE;
      ELSE
         p_underwriter := TRUE;
      END IF;

      vpasexec := 4;

      IF NVL(INSTR(vtaccion, 'M', 1), 0) = 0 THEN
         p_mlro := FALSE;
      ELSE
         p_mlro := TRUE;
      END IF;

      vpasexec := 5;

      IF NVL(INSTR(vtaccion, 'A', 1), 0) = 0 THEN
         p_agenda := FALSE;
      ELSE
         p_agenda := TRUE;
      END IF;

      vpasexec := 6;

      IF NVL(INSTR(vtaccion, 'B', 1), 0) = 0 THEN
         p_block := FALSE;
      ELSE
         p_block := TRUE;
      END IF;

      vpasexec := 7;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
   END proc_accion_lre;

   /*************************************************************************
      FUNCTION f_valida_accion_lre
      Procedimiento que recupera las listas activas de una persona
      return number: 0 -ok , otro valor ERROR
      Bug 38745/219383 - 04/12/2015 - YDA
   *************************************************************************/
   FUNCTION f_valida_accion_lre(
      p_cempres IN NUMBER,
      p_cidioma IN NUMBER,
      p_sseguro IN NUMBER,
      p_sperson IN NUMBER,
      p_cmotmov IN NUMBER,
      p_fecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER IS
      vpasexec       NUMBER(5) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_LISTARESTRINGIDA.f_valida_accion_lre';
      vparam         VARCHAR2(1000)
         := 'p_cempres: ' || p_cempres || ' - p_cidioma: ' || p_cidioma || ' - p_sseguro: '
            || p_sseguro || ' - p_sperson: ' || p_sperson || ' - p_cmotmov: ' || p_cmotmov
            || ' - p_fecha: ' || TO_CHAR(p_fecha, 'dd/mm/yyyy');
      v_count_block  NUMBER;
      v_aux_block    BOOLEAN := FALSE;
      v_aux_mail     BOOLEAN := FALSE;
      v_aux_mail_under BOOLEAN := FALSE;
      v_aux_mailmlro BOOLEAN := FALSE;
      v_aux_agenda   BOOLEAN := FALSE;
      vasunto        VARCHAR2(1000);
      vmail          VARCHAR(1000);
      vfrom          VARCHAR(200);
      vto            VARCHAR(200);
      vto2           VARCHAR(200);
      verror         VARCHAR(100);
      vtevento       VARCHAR(200);
      vscorreo       NUMBER;
      apuntereturn   NUMBER;
      vcconapu       NUMBER := 2;
      -- concepto observation
      vestadoapunte  NUMBER := 1;
      -- estado a ended
      vidapunte_out  NUMBER;
      vcusuari       VARCHAR2(50) := f_user;
      -- codigo de usuario
      vcgrupo        VARCHAR2(50) := '0';
      -- codigo grupo
      vtgrupo        VARCHAR2(50);
      -- valor grupo (obtenir el cagente de la taula de sinistres o de seguros, segons convingui)
      vcclagd        NUMBER := 1;
      -- codigo clave agenda (0: sinitre / 1: polissa / 2: rebut (veure detvalores 800029))
      vtclagd        VARCHAR2(50) := p_sseguro;
      -- valor clave agenda (Si vcclagd a 0: nsinistre / 1: sseguro / 2: nrecibo)
      vcperagd       NUMBER := 0;
      vmailreturn    NUMBER := 0;
      error_envio_correo EXCEPTION;
      error_generar_apunte EXCEPTION;
      --
      vnnumide       per_personas.nnumide%TYPE;
   BEGIN
      vpasexec := 10;
      v_count_block := 0;

      FOR curtiplis IN (SELECT ctiplis
                          FROM lre_personas
                         WHERE sperson = p_sperson
                           AND(fexclus IS NULL
                               OR TRUNC(fexclus) > TRUNC(p_fecha))) LOOP
         vtevento := NULL;
         vpasexec := 20;
         pac_listarestringida.proc_accion_lre(p_cempres, p_cmotmov, curtiplis.ctiplis,
                                              v_aux_mail, v_aux_mail_under, v_aux_mailmlro,
                                              v_aux_agenda, v_aux_block);
         vpasexec := 30;

         IF NVL(v_aux_mail, FALSE) THEN
            vtevento := 'LREMAIL';
         END IF;

         vpasexec := 35;

         IF NVL(v_aux_agenda, FALSE) THEN
            vpasexec := 40;

            SELECT nnumide
              INTO vnnumide
              FROM per_personas
             WHERE sperson = p_sperson;

            apuntereturn := pac_agenda.f_set_apunte(NULL, NULL, NULL, NULL, vcconapu,
                                                    vestadoapunte, NULL, NULL,
                                                    f_axis_literales(9906963, p_cidioma),
                                                    f_axis_literales(9908639, p_cidioma)
                                                    || '. '
                                                    || f_axis_literales(9900992, p_cidioma)
                                                    || ': ' || vnnumide,
                                                    0, NULL, NULL, NULL, NULL, NULL, NULL,
                                                    NULL, NULL, vidapunte_out);

            IF apuntereturn <> 0 THEN
               RAISE error_generar_apunte;
            END IF;

            vpasexec := 45;
            apuntereturn := pac_agenda.f_set_agenda(vidapunte_out, NULL, vcusuari, vcgrupo,
                                                    vtgrupo, vcclagd, vtclagd, vcperagd,
                                                    vcusuari, vcgrupo, vtgrupo);

            IF apuntereturn <> 0 THEN
               RAISE error_generar_apunte;
            END IF;
         END IF;

         vpasexec := 50;

         IF NVL(v_aux_mailmlro, FALSE) THEN
            vtevento := 'LREMAILMLRO';
         END IF;

         vpasexec := 55;

         IF NVL(v_aux_mail_under, FALSE) THEN
            vtevento := 'LREMAILUNDERWRITER';
         END IF;

         vpasexec := 60;

         IF vtevento IS NOT NULL THEN
            BEGIN
               vpasexec := 65;

               SELECT scorreo
                 INTO vscorreo
                 FROM cfg_notificacion
                WHERE cempres = p_cempres
                  AND cmodo = 'GENERAL'
                  AND sproduc = 0
                  AND tevento = vtevento;

               vpasexec := 70;
               vmailreturn := pac_correo.f_mail(vscorreo, p_sseguro, NULL, p_cidioma, NULL,
                                                vmail, vasunto, vfrom, vto, vto2, verror, NULL,
                                                NULL, NULL,
                                                ff_desvalorfijo(800048, p_cidioma,
                                                                curtiplis.ctiplis));

               IF vmailreturn <> 0 THEN
                  RAISE error_envio_correo;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                              f_axis_literales(9904235, p_cidioma));
                  RAISE error_envio_correo;
            END;
         END IF;

         IF v_aux_block THEN
            v_count_block := v_count_block + 1;
         END IF;
      END LOOP;   -- curtiplis

      vpasexec := 80;

      IF v_count_block <> 0 THEN
         RETURN 9908640;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error_generar_apunte THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     f_axis_literales(apuntereturn, p_cidioma));
         RETURN 9903168;
      WHEN error_envio_correo THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     f_axis_literales(vmailreturn, p_cidioma));
         RETURN 9904380;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLERRM);
         RETURN 9902888;
   END f_valida_accion_lre;

   /*************************************************************************
   FUNCTION f_get_historico_persona
      Función que recupera los datos históricos de una persona en lista restringida
      return cursor
      Bug CONF-239 JAVENDANO 01/09/2016
   *************************************************************************/
    FUNCTION f_get_historico_persona(
      pnnumide    IN       VARCHAR2
    )
    RETURN SYS_REFCURSOR IS
        cur     SYS_REFCURSOR;
        vobject varchar2(60) := 'pac_listarestringida.f_get_historico_persona';
        vparam  varchar2(60) := 'pnnumide: ' || pnnumide;
        NUM_ERR NUMBER;
        empresa number;
        vidioma number;
		/* cambios de web compliance - start */
        VSPERSONA PER_PERSONAS.SPERSON%TYPE;
        /* cambios de web compliance - end */		
    BEGIN
        empresa := f_parinstalacion_n('EMPRESADEF');
        num_err := pac_contexto.f_inicializarctx(pac_md_common.f_get_cxtusuario);--IAXIS-4854
        vidioma := pac_md_common.F_GET_CXTIDIOMA;
		
        /* cambios de web compliance - start */
        BEGIN
          SELECT MAX(PP.SPERSON) INTO VSPERSONA
            FROM PER_PERSONAS PP
           WHERE PP.NNUMIDE = PNNUMIDE;
        END;
        /* cambios de web compliance - end */		

        OPEN cur FOR
            SELECT nnumide,
                   (SELECT tatribu
                      FROM detvalores
                     WHERE cvalor = 800048 AND catribu = hl.ctiplis AND cidioma = vidioma) tiplis,
                   finclus, cinclus, fexclus,
                   (SELECT tatribu
                      FROM detvalores
                     WHERE cvalor = 800121 AND catribu = hl.caccion AND cidioma = vidioma) accion,
                   (SELECT npoliza
                      FROM seguros
                     WHERE sseguro = hl.sseguro) npoliza,
                   nsinies,
                   nrecibo
              FROM his_lre_personas hl
             WHERE hl.NNUMIDE = pnnumide
			 -- Cambios de Swapnil Para Q1897 :Start
             and accion is not null
             -- Cambios de Swapnil Para Q1897 :End
		     /* cambios de web compliance - start */
		     and hl.sperson = nvl(VSPERSONA,null)       
		     /* cambios de web compliance - end */			 
			 ;
        RETURN cur;
    EXCEPTION WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, vobject, 1, vparam, SQLCODE || '- ' || SQLERRM);
    END f_get_historico_persona;
-- IGIL CONFCC-7 INI
  FUNCTION f_consultar_compliance(
    p_sperson IN NUMBER,
    p_nnumide IN VARCHAR2,--NUMBER,Inc 1887 CONF KJSC
    p_nombre IN VARCHAR2,
    p_ctipide IN NUMBER,
    p_ctipper IN NUMBER
  ) RETURN NUMBER IS

    vobject     VARCHAR2(60) := 'pac_listarestringida.f_consultar_compliance';
    vparam      VARCHAR2(60) := 'p_nnumide: ' || p_nnumide;
    vsinterf    NUMBER;
    vpasexec    NUMBER;
    v_msgout    VARCHAR2(2000);
    v_msg       VARCHAR2(2000);
    vparser     xmlparser.parser;
    v_domdoc    xmldom.domdocument;
    verror      int_resultado.terror%TYPE;
    vnerror     int_resultado.nerror%TYPE;
    vnombre     VARCHAR2(2000);
  BEGIN


        vpasexec := 1;
        pac_int_online.p_inicializar_sinterf;
        vpasexec := 2;
        vsinterf := pac_int_online.f_obtener_sinterf;
        vpasexec := 3;

	-- Cambios de Swapnil Para Q1897 :Start
		IF P_NOMBRE IS NOT NULL THEN
          -- VNOMBRE := P_NOMBRE;
          SELECT TRIM(REGEXP_REPLACE(TRANSLATE(TRIM(P_NOMBRE),
                                     'ÁÉÍÓÚÑáéíóúñ',
                                     'AEIOUNaeioun'),
                           '[^0-9A-Za-z]',
                           ' '))
            INTO VNOMBRE
            FROM DUAL;
        ELSE
           VNOMBRE := '';
        END IF;
        /*

        SELECT nombre INTO vnombre FROM (
           SELECT unique pd.tapelli1||
                  Decode(pd.tapelli1, NULL, NULL,' ') || pd.tapelli2 ||
                  Decode(pd.tapelli1|| pd.tapelli2, NULL, NULL,
                         Decode(tnombre,NULL, NULL,' '||TNOMBRE)) nombre
             FROM per_detper pd
            WHERE pd.sperson =p_sperson
            UNION ALL
           SELECT pd.tapelli1||
                  Decode(pd.tapelli1, NULL, NULL,' ') || pd.tapelli2 ||
                  Decode(pd.tapelli1|| pd.tapelli2, NULL, NULL,
                         Decode(tnombre,NULL, NULL,' '||TNOMBRE)) nombre
             FROM estper_detper pd
            WHERE pd.sperson =p_sperson) WHERE ROWNUM=1;
		*/
    -- Cambios de Swapnil Para Q1897 :Start

        v_msg := '<?xml version="1.0"?>
                  <persona_lre>
                    <sinterf>'||vsinterf||'</sinterf>
                    <idPersona>'||p_sperson||'</idPersona>
                    <numeroIdentificacion>'||p_nnumide||'</numeroIdentificacion>
                    <tipoIdentificacion>'||p_ctipide||'</tipoIdentificacion>
                    <tipoPersona>'||p_ctipper||'</tipoPersona>
                    <nombrePersona>'||vnombre||'</nombrePersona>
                    <usuario>'||f_user||'</usuario>
                  </persona_lre> ';
      vpasexec := 4;
      INSERT INTO int_mensajes (sinterf,cinterf,finterf,tmenout,tmenin )
            VALUES(vsinterf,'I072',f_sysdate,v_msg,NULL);
      COMMIT;
      pac_int_online.peticion_host (pac_md_common.f_get_cxtempresa,
                                    'I072',
                                    v_msg,
                                    v_msgout
                                   );
      parsear (v_msgout, vparser);
      v_domdoc := xmlparser.getdocument (vparser);
      verror := NVL(pac_xml.buscarnodotexto (v_domdoc, 'error'),0);

      IF verror <> 0
      THEN
        NULL;
      END IF;

      vpasexec := 5;
      RETURN 0;
    EXCEPTION WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || '- ' || SQLERRM);
	RETURN 1;
  END f_consultar_compliance;
   PROCEDURE parsear (p_clob IN CLOB, p_parser IN OUT xmlparser.parser)
   IS
   BEGIN
      p_parser := xmlparser.newparser;
      xmlparser.setvalidationmode (p_parser, FALSE);

      IF DBMS_LOB.getlength (p_clob) > 32767
      THEN
         xmlparser.parseclob (p_parser, p_clob);
      ELSE
         xmlparser.parsebuffer (p_parser,
                                DBMS_LOB.SUBSTR (p_clob,
                                                 DBMS_LOB.getlength (p_clob),
                                                 1
                                                )
                               );
      END IF;
   END;
 -- IGIL CONFCC-7 FIN
END pac_listarestringida;

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTARESTRINGIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTARESTRINGIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTARESTRINGIDA" TO "PROGRAMADORESCSI";
