--------------------------------------------------------
--  DDL for Package Body PAC_FE_VIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FE_VIDA" IS
/******************************************************************************
   NOMBRE:       PAC_MD_FE_DE_VIDA
   PROPÓSITO: Funcions per gestionar Cartes de Fe de Vida

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/09/2010   ETM               1. Creación del package.
   2.0        20/01/2011   APD               2. Bug 15289: Cartas Fe de Vida
   3.0        25/05/2011   APD               3. 0018636: ENSA101-Revisar maps sobre prestaciones
   4.0        28/01/2013   MDS               4. 0024743: (POSDE600)-Desarrollo-GAPS Tecnico-Id 146 - Modif listados para regional sucursal
   5.0        02/05/2013   JMF               5. 0025623 (POSDE200)-Desarrollo-GAPS - Comercial - Id 56
   6.0        08/01/2014   LPP               6. 0028409: ENSA998-ENSA - Implementación de historico de prestaciones
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   -- Bug 15289 - APD - 21/01/2011 - se crea la funcion
   FUNCTION f_valor_substr(pstr IN VARCHAR2, pttexto IN VARCHAR2, pseparador IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_valorsubstr  VARCHAR2(200);
      vpos           NUMBER;
      vlength        NUMBER;
      vposseparador  NUMBER;
   BEGIN
      SELECT INSTR(pstr, pttexto), LENGTH(pttexto),
             INSTR(pstr, pseparador, INSTR(pstr, pttexto))
        INTO vpos, vlength,
             vposseparador
        FROM DUAL;

      SELECT SUBSTR(pstr, vpos + vlength, vposseparador -(vpos + vlength))
        INTO v_valorsubstr
        FROM DUAL;

      RETURN v_valorsubstr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fe_vida.f_valor_substr', 1,
                     'pstr: ' || pstr || ';pttexto: ' || pttexto, SQLERRM);
         RETURN NULL;
   END f_valor_substr;

   -- Bug 15289 - APD - 20/01/2011 - se crea la funcion
   /*************************************************************************
   Función  F_PERCEPTORES_RENTA
   Devuelve las personas que reciben la renta.
   Solo se mostraran aquellas personas a las cuales se les ha enviado la carta de
   fe de vida previamente y que aun no han confirmado su fe de vida
      param in psseguro: identificador del seguro
         Retorno: v_squery:Devuelve la select de los perceptores de la renta
   *************************************************************************/
   FUNCTION f_perceptores_renta(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_squery       VARCHAR2(4000);
   BEGIN
      -- solo se muestran aquellos perceptores a los cuales se les ha enviado la carta de fe de vida
      -- por eso esta la condicion agensegu.ctipreg = 31
      -- solo se muestran aquellos perceptores pendientes de confirmar su fe de vida
      -- por eso esta la condicion agensegu.cestado = 0
      v_squery :=
         'SELECT a.sperson sperson, '
         || ' RPAD(pac_isqlfor.f_dades_persona(a.sperson, 5, s.cidioma) || '', '' '
         || ' || pac_isqlfor.f_dades_persona(a.sperson, 4, s.cidioma), 40, '' '') nombre, '
         || ' RPAD(pac_isqlfor.f_dades_persona(a.sperson, 8, s.cidioma), 40, '' '') tipodoc, '
         || ' RPAD(pac_isqlfor.f_dades_persona(a.sperson, 1, s.cidioma), 9, '' '') doc, '
         || ' ag.falta fecha_envio_carta '
         || ' FROM seguros s, seguros_ren sr, asegurados a, agensegu ag '
         || ' WHERE s.sseguro = sr.sseguro ' || ' AND s.sseguro = a.sseguro '
         || ' AND s.sseguro = ag.sseguro ' || ' AND s.sseguro = ' || psseguro
         || ' AND ag.ctipreg = 31 ' || ' AND ag.cestado = 0 ' || ' UNION '
         || ' SELECT pr.sperson sperson, '
         || ' RPAD(pac_isqlfor.f_dades_persona(pr.sperson, 5, s.cidioma) || '', '' '
         || ' || pac_isqlfor.f_dades_persona(pr.sperson, 4, s.cidioma), 40, '' '') nombre, '
         || ' RPAD(pac_isqlfor.f_dades_persona(pr.sperson, 8, s.cidioma), 40, '' '') tipodoc, '
         || ' RPAD(pac_isqlfor.f_dades_persona(pr.sperson, 1, s.cidioma), 9, '' '') doc, '
         || ' ag.falta fecha_envio_carta ' || ' FROM seguros s, prestaren pr, agensegu ag '
         || ' WHERE s.sseguro = pr.sseguro ' || ' AND pr.sseguro = ag.sseguro '
         || ' AND pr.npresta = (select max(npresta) from prestaren pt where pt.sseguro = pr.sseguro) '
         || ' AND s.sseguro = ' || psseguro || ' AND ag.ctipreg = 31 '
         || ' AND ag.cestado = 0'
         || ' AND pac_fe_vida.f_valor_substr(UPPER(ag.ttextos), ''SPERSON='', '';'') = pr.sperson';
      RETURN v_squery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fe_vida.f_perceptores_renta', 1,
                     'psseguro: ' || psseguro, SQLERRM);
         RETURN NULL;
   END f_perceptores_renta;

   -- fin Bug 15289 - APD - 20/01/2011

   /*************************************************************************
   Función  F_APUNTE_AGENDA
   FUNCION que inserta un apunte en la agenda de aquellas pólizas que deben enviar la carta de fe de vida .
     Se buscan las pólizas que deben enviar la carta de fe de vida y que cumplan con los requisitos (pólizas que devuelve el ref cursor de la función pac_propio.f_get_datos_apunte_fe_vida).
    Para cada una de éstas pólizas se realiza un apunte en la agenda (pac_agensegu.f_set_datos_apunte).

    1.   psproces IN. Identificador del proceso.
    2.   pcempres IN. Identificador de la empresa. Obligatorio.
    3.   pcramo IN. Identificador del ramo.
    4.   psproduc IN. Identificador del producto.
    5.   pcagente IN. Identificador del agente.
    6.   pnpoliza IN. Número de póliza.
    7.   pncertif IN. Número de certificado.
    8.   pfhasta IN. Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
    9.   pngenerar IN. Identificador de generación de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)
    10.  sproces OUT. Identificador del proceso.

   param in out mensajes   : mensajes de error
          return              : sys_Refcursor
   *************************************************************************/
   FUNCTION f_apunte_agenda(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pfhasta IN DATE,
      pngenerar IN NUMBER DEFAULT 0,
      sproces OUT NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      nprolin        NUMBER;
      v_sproces      NUMBER;
      num_err        NUMBER;
      v_psseguro     seguros.sseguro%TYPE;   -- Identificador del Seguros
      v_pcidioma     seguros.cidioma%TYPE;   -- Idioma del seguro
      v_psperson     per_personas.sperson%TYPE;   -- Identificador de la persona
      v_fecha_envio  DATE;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproces:' || psproces || ' ,pcempres:' || pcempres || ' ,pcramo:' || pcramo
            || ', psproduc:' || psproduc || ', pcagente:' || pcagente || ' ,pfhasta:'
            || pfhasta || ' ,pngenerar:' || pngenerar || ', sproces:' || sproces;
      vobject        VARCHAR2(200) := 'PAC_FE_DE_VIDA.F_APUNTE_AGENDA';
      v_cursor       sys_refcursor;
      v_nlinea       agensegu.nlinea%TYPE;
      v_ttextos      agensegu.ttextos%TYPE;
   BEGIN
      IF pngenerar = 0 THEN
         IF pcempres IS NULL
            OR pfhasta IS NULL THEN
            RAISE e_param_error;
         END IF;
      ELSIF pngenerar = 1 THEN
         IF psproces IS NULL THEN
            RAISE e_param_error;
         END IF;
      END IF;

      vpasexec := 2;

      -- Si el psproces no está informado, se creará la cabecera del proceso
      IF psproces IS NULL THEN
         num_err := f_procesini(f_user, f_parinstalacion_n('EMPRESADEF'), 'CARTAS_FE_VIDA',
                                'Generación Cartas Fe de Vida:' || TRUNC(f_sysdate),
                                v_sproces);
         vpasexec := 3;
      ELSE
         num_err := f_proceslin(psproces,
                                'Inicio Generación Cartas Fe de Vida'
                                || TO_CHAR(f_sysdate, 'DD-MM-YYYY  HH24:MI'),
                                0, nprolin, 4);
         vpasexec := 3;
         v_sproces := psproces;
         vpasexec := 4;
      END IF;

      vpasexec := 5;
      ---el nuevo paquete
      v_cursor := pac_propio.f_get_datos_apunte_fe_vida(psproces, pcempres, pcramo, psproduc,
                                                        pcagente, pnpoliza, pncertif, pfhasta,
                                                        pngenerar);
      vpasexec := 6;

       -- Todos los ref cursor que devuelva la función pac_propio.f_get_polizas_apunte_fe_vida deben
      -- devolver los mismos campos: sseguro, cidioma, sperson
      LOOP
         FETCH v_cursor
          INTO v_psseguro, v_pcidioma, v_psperson;

         EXIT WHEN v_cursor%NOTFOUND;
         -- Realizamos un apunte en la egenda
         vpasexec := 7;
         -- La variable v_ttextos debe ser fija, no se puede modificar ya que los valores
         -- del SPROCES y SPERSON se necesitan utilizar más tarde
         v_ttextos := 'SPROCES=' || v_sproces || ';SPERSON=' || v_psperson || ';';
         vnumerr :=
            pac_agensegu.f_set_datosapunte(NULL, v_psseguro, NULL,
                                           f_axis_literales(9901436, v_pcidioma), v_ttextos,
                                           31,   --tipo de registro automatic detvalores 21
                                           0, pfhasta, NULL, 0, 1);   --  apunte automático
         vpasexec := 8;

         -- el apunte debe ser automatico.
         -- La funcion pac_agensegu.f_set_datosapunte entiende que si el apunte es automatico debe
         -- quedar en estado finalizado
         -- Hasta que no se modifique la funcion pac_agensegu.f_set_datosapunte realizaremos el cambio
         -- de Manual a Automatico con un update fuera de la funcion.
         -- Una vez que se modifique la funcion se deberá eliminar el update y el parametro pcmanual de
         -- la funcion debe ser 0 (y no el 1 como está ahora)
         SELECT NVL(MAX(nlinea), 0)
           INTO v_nlinea
           FROM agensegu
          WHERE sseguro = v_psseguro;

         vpasexec := 9;

         BEGIN
            UPDATE agensegu
               SET cmanual = 0   -- automatico
             WHERE sseguro = v_psseguro
               AND nlinea = v_nlinea;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                           f_axis_literales(9001151, v_pcidioma), SQLERRM);
         END;

         vpasexec := 10;

         IF vnumerr = 0 THEN
            vpasexec := 11;
            COMMIT;
            num_err := f_proceslin(v_sproces, f_axis_literales(9901437) || ': ' || v_psseguro,
                                   v_psseguro, nprolin, 4);
         -- 180955 : Apunte Agenda
         ELSE
            vpasexec := 12;
            ROLLBACK;
            num_err := f_proceslin(v_sproces,
                                   f_axis_literales(9000464) || ' '
                                   || f_axis_literales(9901437) || ': '
                                   || f_axis_literales(vnumerr) || ': ' || v_psseguro,
                                   v_psseguro, nprolin, 1);
         END IF;
      END LOOP;

      vpasexec := 13;
      num_err := f_proceslin(v_sproces, 'Generación Cartas Fe de Vida finalizado.', 0, nprolin,
                             4);
      vpasexec := 14;

      IF psproces IS NULL THEN
         vpasexec := 15;
         num_err := f_procesfin(v_sproces, num_err);
      END IF;

      vpasexec := 16;
      sproces := v_sproces;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: ' || vparam, SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_apunte_agenda;

   /*************************************************************************
    Función F_GET_CONSULTA_FE_VIDA
    Devuelved un VARCHAR2 con la select de las pólizas que tienen un apunte en la Agenda de tipo 31.-Envío de Cartas de Fe de Vida
    Nota: Se puede realizar la consulta de aquellos contratos a los cuales se les ha enviado la Carta de Fe de Vida. Dichos contratos deben cumplir los requisitos siguientes:
    Contratos vigentes y no retenidos por siniestro o rescate (csituac = 0 y pac_motretenction.f_esta_retenica_sin_resc = 0)
     Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida; agensegu.ctipreg = 31).
    El apunte en la agenda se debe de haber realizado entre las fechas inicial y final seleccionadas (agensegu.falta >=pfinicial y agensegu.falta <= pffinal)

    Parametros
     1.   pcidioma. Identificador del idioma.
     2.   pcempres. Identificador de la empresa. Obligatorio.
     3.   psproduc. Identificador del producto.
     4.   pfinicial. Fecha inicio.
     5.   pffinal. Fecha final
     6.   pcramo. Identificador del ramo.
     7.   pcagente. Identificador del agente.
     8.   pcagrpro. Identificador de la agrupación de la póliza.
    param in out mensajes   : mensajes de error
          return             VARCHAR2
    *************************************************************************/
   FUNCTION f_get_consulta_fe_vida(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER)
      RETURN VARCHAR2 IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'pcidioma=' || pcidioma || ' pcempres=' || pcempres || ' psproduc=' || psproduc
            || ' pfinicial=' || pfinicial || ' pffinal=' || pffinal || ' pcramo=' || pcramo
            || ' pcagente=' || pcagente || ' pcagrpro=' || pcagrpro;
      vobject        VARCHAR2(200) := 'PAC_FE_DE_VIDA.F_GET_CONSULTA_FE_VIDA';
      vsquery        VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL
         OR pfinicial IS NULL
         OR pffinal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
         ' SELECT   s.sproduc sproduc,  ' || ' (SELECT ttitulo  ' || ' FROM titulopro t '
         || ' WHERE t.cramo = s.cramo ' || ' AND t.cmodali = s.cmodali '
         || ' AND t.ctipseg = s.ctipseg ' || ' AND t.ccolect = s.ccolect '
         || ' AND t.cidioma = s.cidioma) descproducto, '
         || ' f_formatopol(s.npoliza, s.ncertif, 1) contrato, ' || ' DECODE(a1.ffecfin, '
         || ' NULL, DECODE(a1.sperson, NULL, NULL, f_nombre(a1.sperson, 1)), '
         || ' NULL) nombretitular1, ' || ' DECODE(a1.ffecfin, '
         || ' NULL, DECODE(a1.sperson, NULL, NULL, '
         || ' fedadaseg(0, a1.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular1, ' || ' DECODE(a2.ffecfin, '
         || ' NULL, DECODE(a2.sperson, NULL, NULL, f_nombre(a2.sperson, 1)), '
         || ' NULL) nombretitular2, ' || ' DECODE(a2.ffecfin, '
         || ' NULL, DECODE(a2.sperson, NULL, NULL, '
         || ' fedadaseg(0, a2.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular2, ' || ' ag.falta fecha_envio, ' || ' (SELECT d.tatribu '
         || ' FROM detvalores d ' || ' WHERE d.cvalor = 22 ' || ' AND d.cidioma = s.cidioma '
         || ' AND d.catribu = ag.cestado) desc_estado '
         || ' FROM seguros s, seguros_ren sr, agensegu ag, asegurados a1, asegurados a2 '
         || ' WHERE s.sseguro = ag.sseguro ' || ' AND s.sseguro = sr.sseguro '
         || ' AND a1.sseguro = s.sseguro ' || ' AND a2.sseguro(+) = s.sseguro '
         || ' AND a1.norden = 1 ' || ' AND a2.norden(+) = 2 ' || ' AND ag.ctipreg = 31    '
         || ' AND ag.falta >= ''' || TRUNC(pfinicial) || ''' AND ag.falta <= '''
         || TRUNC(pffinal) || '''  AND s.csituac = 0  '
         || ' AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro) = ' || ' 0 '
         || ' AND(s.cempres = NVL(' || NVL(TO_CHAR(pcempres), 'NULL') || ',s.cempres))'
         || ' AND(s.cramo = NVL(' || NVL(TO_CHAR(pcramo), 'NULL') || ',s.cramo))'
         || ' AND(s.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'NULL') || ',s.sproduc))'
         || ' AND(s.cagente = NVL(' || NVL(TO_CHAR(pcagente), 'NULL') || ',s.cagente))'
         || ' AND(s.cagrpro = NVL(' || NVL(TO_CHAR(pcagrpro), 'NULL') || ',s.cagrpro))'
         || ' UNION ' || ' SELECT   s.sproduc sproduc,  ' || ' (SELECT ttitulo  '
         || ' FROM titulopro t ' || ' WHERE t.cramo = s.cramo '
         || ' AND t.cmodali = s.cmodali ' || ' AND t.ctipseg = s.ctipseg '
         || ' AND t.ccolect = s.ccolect ' || ' AND t.cidioma = s.cidioma) descproducto, '
         || ' f_formatopol(s.npoliza, s.ncertif, 1) contrato, ' || ' DECODE(pp.fdefunc, '
         || ' NULL, DECODE(pp.sperson, NULL, NULL, f_nombre(pp.sperson, 1)), '
         || ' NULL) nombretitular1, ' || ' DECODE(pp.fdefunc, '
         || ' NULL, DECODE(pp.sperson, NULL, NULL, '
         || ' fedadaseg(0, pp.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular1, ' || ' NULL nombretitular2, ' || ' NULL edadtitular2, '
         || ' ag.falta fecha_envio, ' || ' (SELECT d.tatribu ' || ' FROM detvalores d '
         || ' WHERE d.cvalor = 22 ' || ' AND d.cidioma = s.cidioma '
         || ' AND d.catribu = ag.cestado) desc_estado '
         || ' FROM seguros s, prestaren pr, agensegu ag, per_personas pp '
         || ' WHERE s.sseguro = ag.sseguro ' || ' AND s.sseguro = pr.sseguro '
         || ' AND pr.npresta = (select max(npresta) from prestaren pt where pt.sseguro=pr.sseguro) '
         || ' AND pr.sperson = pp.sperson(+) ' || ' AND ag.ctipreg = 31    '
         || ' AND ag.falta >= ''' || TRUNC(pfinicial) || ''' AND ag.falta <= '''
         || TRUNC(pffinal) || '''  AND s.csituac = 0  '
         || ' AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro) = ' || ' 0 '
         || ' AND(s.cempres = NVL(' || NVL(TO_CHAR(pcempres), 'NULL') || ',s.cempres))'
         || ' AND(s.cramo = NVL(' || NVL(TO_CHAR(pcramo), 'NULL') || ',s.cramo))'
         || ' AND(s.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'NULL') || ',s.sproduc))'
         || ' AND(s.cagente = NVL(' || NVL(TO_CHAR(pcagente), 'NULL') || ',s.cagente))'
         || ' AND(s.cagrpro = NVL(' || NVL(TO_CHAR(pcagrpro), 'NULL') || ',s.cagrpro))'
         || ' ORDER BY 1, 3 ';
      vpasexec := 3;
      RETURN vsquery;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'vsquery ' || vsquery, SQLERRM);
         RETURN NULL;
   END f_get_consulta_fe_vida;

   /*************************************************************************
     Función  F_GET_RENTAS_BLOQUEADAS
     función que devolverá un VARCHAR2 con la select de las pólizas con rentas bloqueadas debido a que no se ha certificado todavía la fe de vida de los titulares del contrato
     Nota: Se puede realizar la consulta de aquellos contratos a los cuales se les ha enviado la Carta de Fe de Vida. Dichos contratos deben cumplir los requisitos siguientes:
          Contratos vigentes y no retenidos por siniestro o rescate (csituac = 0 y pac_motretenction.f_esta_retenica_sin_resc = 0)
          Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida; agensegu.ctipreg = 31).
          El apunte en la agenda se debe de haber realizado entre las fechas inicial y final seleccionadas (agensegu.falta >=pfinicial y agensegu.falta <= pffinal)
          La póliza está bloqueada (pagosrenta.cblopag = 5.-Bloqueada)

      parametros
      1.   pcidioma. Identificador del idioma.
      2.   pcempres. Identificador de la empresa. Obligatorio.
      3.   psproduc. Identificador del producto.
      4.   pfinicial. Fecha inicio.
      5.   pffinal. Fecha final
      6.   pcramo. Identificador del ramo.
      7.   pcagente. Identificador del agente.
      8.   pcagrpro. Identificador de la agrupación de la póliza.
     param in out mensajes   : mensajes de error
           return             VARCHAR2
     *************************************************************************/
   FUNCTION f_get_rentas_bloqueadas(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER)
      RETURN VARCHAR2 IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'pcidioma=' || pcidioma || ' pcempres=' || pcempres || ' psproduc=' || psproduc
            || ' pfinicial=' || pfinicial || ' pffinal=' || pffinal || ' pcramo=' || pcramo
            || ' pcagente=' || pcagente || ' pcagrpro=' || pcagrpro;
      vobject        VARCHAR2(200) := 'PAC_FE_DE_VIDA.F_GET_RENTAS_BLOQUEADAS';
      vsquery        VARCHAR2(4000);
   BEGIN
      IF pcempres IS NULL
         OR pfinicial IS NULL
         OR pffinal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- Bug 18636 - APD - 05/05/2011 - union entre prestaren y pagosrenta tambien
      -- por nsinies, ntramit y ctipdes
      vsquery :=
         ' SELECT   s.sproduc sproduc, ' || ' (SELECT ttitulo ' || ' FROM titulopro t '
         || ' WHERE t.cramo = s.cramo ' || ' AND t.cmodali = s.cmodali '
         || ' AND t.ctipseg = s.ctipseg ' || ' AND t.ccolect = s.ccolect '
         || ' AND t.cidioma = s.cidioma) descproducto, '
         || ' f_formatopol(s.npoliza, s.ncertif, 1) contrato, ' || ' DECODE(a1.ffecfin, '
         || ' NULL, DECODE(a1.sperson, NULL, NULL, f_nombre(a1.sperson, 1)), '
         || ' NULL) nombretitular1, ' || ' DECODE(a1.ffecfin, '
         || ' NULL, DECODE(a1.sperson, NULL, NULL, '
         || ' fedadaseg(0, a1.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular1, ' || ' DECODE(a2.ffecfin, '
         || ' NULL, DECODE(a2.sperson, NULL, NULL, f_nombre(a2.sperson, 1)), '
         || ' NULL) nombretitular2, ' || ' DECODE(a2.ffecfin, '
         || ' NULL, DECODE(a2.sperson, NULL, NULL, '
         || ' fedadaseg(0, a2.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular2, '
         || ' ag.falta fecha_envio, p.iconret importe, p.ffecpag fecha_emision '
         || ' FROM seguros s, seguros_ren sr, agensegu ag, asegurados a1, asegurados a2, '
         || ' pagosrenta p, movpagren m ' || ' WHERE s.sseguro = sr.sseguro '
         || ' AND s.sseguro = ag.sseguro ' || ' AND a1.sseguro = s.sseguro '
         || ' AND a2.sseguro(+) = s.sseguro ' || ' AND a1.norden = 1 '
         || ' AND a2.norden(+) = 2 ' || ' AND p.sseguro = sr.sseguro '
         || ' AND p.srecren = m.srecren ' || 'AND m.fmovfin IS NULL '
         || ' AND ag.ctipreg = 31    ' || ' AND ag.cestado = 0    ' || ' AND ag.falta >= '''
         || TRUNC(pfinicial) || ''' AND ag.falta <= ''' || TRUNC(pffinal)
         || ''' AND sr.cblopag = 5 ' || ' AND m.cestrec = 5 ' || ' AND s.csituac = 0    '
         || ' AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro) = 0 '
         || ' AND(s.cempres = NVL(' || NVL(TO_CHAR(pcempres), 'NULL') || ',s.cempres))'
         || ' AND(s.cramo = NVL(' || NVL(TO_CHAR(pcramo), 'NULL') || ',s.cramo))'
         || ' AND(s.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'NULL') || ',s.sproduc))'
         || ' AND(s.cagente = NVL(' || NVL(TO_CHAR(pcagente), 'NULL') || ',s.cagente))'
         || ' AND(s.cagrpro = NVL(' || NVL(TO_CHAR(pcagrpro), 'NULL') || ',s.cagrpro))'
         || ' UNION ' || ' SELECT   s.sproduc sproduc, ' || ' (SELECT ttitulo '
         || ' FROM titulopro t ' || ' WHERE t.cramo = s.cramo '
         || ' AND t.cmodali = s.cmodali ' || ' AND t.ctipseg = s.ctipseg '
         || ' AND t.ccolect = s.ccolect ' || ' AND t.cidioma = s.cidioma) descproducto, '
         || ' f_formatopol(s.npoliza, s.ncertif, 1) contrato, ' || ' DECODE(pp.fdefunc, '
         || ' NULL, DECODE(pp.sperson, NULL, NULL, f_nombre(pp.sperson, 1)), '
         || ' NULL) nombretitular1, ' || ' DECODE(pp.fdefunc, '
         || ' NULL, DECODE(pp.sperson, NULL, NULL, '
         || ' fedadaseg(0, pp.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular1, ' || ' NULL nombretitular2, ' || ' NULL edadtitular2, '
         || ' ag.falta fecha_envio, p.iconret importe, p.ffecpag fecha_emision '
         || ' FROM seguros s, prestaren pr, agensegu ag, per_personas pp, '
         || ' pagosrenta p, movpagren m ' || ' WHERE s.sseguro = ag.sseguro '
         || ' AND s.sseguro = pr.sseguro ' || ' AND pr.sperson = pp.sperson(+) '
         || 'AND pr.sseguro = p.sseguro ' || 'AND pr.sperson = p.sperson '
         || 'AND pr.nsinies = p.nsinies ' || 'AND pr.ntramit = p.ntramit '
         || 'AND pr.ctipdes = p.ctipdes ' || ' AND p.srecren = m.srecren '
         || 'AND m.fmovfin IS NULL ' || ' AND ag.ctipreg = 31    ' || ' AND ag.cestado = 0    '
         || ' AND ag.falta >= ''' || TRUNC(pfinicial) || ''' AND ag.falta <= '''
         || TRUNC(pffinal) || ''' AND pr.cblopag = 5 ' || ' AND m.cestrec = 5 '
         || ' AND s.csituac = 0    '
         || ' AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro) = 0 '
         || ' AND(s.cempres = NVL(' || NVL(TO_CHAR(pcempres), 'NULL') || ',s.cempres))'
         || ' AND(s.cramo = NVL(' || NVL(TO_CHAR(pcramo), 'NULL') || ',s.cramo))'
         || ' AND(s.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'NULL') || ',s.sproduc))'
         || ' AND(s.cagente = NVL(' || NVL(TO_CHAR(pcagente), 'NULL') || ',s.cagente))'
         || ' AND(s.cagrpro = NVL(' || NVL(TO_CHAR(pcagrpro), 'NULL') || ',s.cagrpro))'
         || ' ORDER BY 1, 3 ';
      -- fin Bug 18636 - APD - 05/05/2011
      vpasexec := 3;
      RETURN vsquery;
      vpasexec := 4;
   EXCEPTION   --???
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'vsquery ' || vsquery, SQLERRM);
         RETURN NULL;
   END f_get_rentas_bloqueadas;

   /*************************************************************************
   Función  F_CONFIRMAR_FE_VIDA
   función que se encargará de validar y confirmar la certificación de fe de vida de los titulares de una póliza
     param in psseguro : nº de seguro
           in ptlista : sperson de los perceptores que han presentado su fe de vida
         Retorno: 0.-Todo Ok; código error.-si ha habido algún error
   *************************************************************************/
   FUNCTION f_confirmar_fe_vida(psseguro IN NUMBER, ptlista IN VARCHAR2)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := ' psseguro=' || psseguro || ';ptlista=' || ptlista;
      vobject        VARCHAR2(200) := 'PAC_FE_VIDA.F_CONFIRMAR_FE_VIDA';
      v_num_apunte   NUMBER;
      v_sum_titulares NUMBER;
      v_num_tit_pol  NUMBER;
      v_nlinea       NUMBER;
      v_tipo         VARCHAR2(1);
      v_ttextos      agensegu.ttextos%TYPE;
      vsperson       per_personas.sperson%TYPE;
      i              NUMBER;
      error          EXCEPTION;

      -- Se buscan los pagos de renta en situacion Bloqueados
      CURSOR cur_pagos(p_sseguro NUMBER, p_sperson NUMBER) IS
         SELECT p.srecren
           FROM pagosrenta p, movpagren m
          WHERE p.srecren = m.srecren
            AND p.sseguro = p_sseguro
            AND p.sperson = NVL(p_sperson, p.sperson)
            AND m.cestrec = 5   -- Pendiente Bloqueado
            AND m.fmovfin IS NULL;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      BEGIN
         -- P = el seguro esta en seguros_ren
         -- R = el seguro esta en pretaren
         SELECT DISTINCT DECODE(sr.sseguro, NULL, DECODE(pr.sseguro, NULL, ' ', 'P'), 'R')
                                                                                          tipo
                    INTO v_tipo
                    FROM seguros s, seguros_ren sr, prestaren pr
                   WHERE sr.sseguro(+) = s.sseguro
                     AND pr.sseguro(+) = s.sseguro
                     AND s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            numerr := 101919;   -- Error al leer datos de la tabla SEGUROS
            RAISE error;
      END;

      i := 1;
      vsperson := pac_fe_vida.f_valor_substr(UPPER(ptlista), 'SPERSON' || i || '=', ';');

      IF vsperson IS NULL THEN
         numerr := 9901815;   -- Debe seleccionar un perceptor
         RAISE error;
      END IF;

      WHILE vsperson IS NOT NULL LOOP
         IF v_tipo = 'R' THEN
            vsperson := NULL;
         END IF;

         -- Se valida si hay un apunte en la Agenda de tipo 31.-Envío de Carta de Fe de Vida en estado Pendiente
         SELECT COUNT(*)
           INTO v_num_apunte
           FROM agensegu
          WHERE sseguro = psseguro
            AND ctipreg = 31   -- Envio de Cartas de Fe de Vida (cvalor = 21)
            AND cestado =
                      0   -- 0.- Pendiente (ffinali is null), 1.- Finalizado (ffinali is not null)
            AND(pac_fe_vida.f_valor_substr(UPPER(ttextos), 'SPERSON=', ';') = vsperson
                OR vsperson IS NULL);

         vpasexec := 3;

         IF v_num_apunte = 0 THEN   -- No hay ningún apunte pendiente
            numerr := 9901438;   -- No hay Certificación de Fe de Vida pendiente
            RAISE error;
         END IF;

         vpasexec := 4;

         -- Se busca el apunte en la agenda de Envio de Carta de Fe de Vida
         FOR reg IN (SELECT nlinea, ttextos
                       FROM agensegu
                      WHERE sseguro = psseguro
                        AND ctipreg = 31   -- Envido de Cartas de Fe de Vida (cvalor = 21)
                        AND cestado = 0
                        AND(pac_fe_vida.f_valor_substr(UPPER(ttextos), 'SPERSON=', ';') =
                                                                                       vsperson
                            OR vsperson IS NULL)) LOOP
            vpasexec := 5;

            -- Se actualiza el apunte en la Agenda con estado finalizado
            BEGIN
               UPDATE agensegu
                  SET cestado = 1,   -- Finalizado
                      ffinali = TRUNC(f_sysdate)
                WHERE sseguro = psseguro
                  AND(pac_fe_vida.f_valor_substr(UPPER(ttextos), 'SPERSON=', ';') = vsperson
                      OR vsperson IS NULL)
                  AND nlinea = reg.nlinea;
            EXCEPTION
               WHEN OTHERS THEN
                  numerr := 103358;   -- Error al insertar en la tabla AGENSEGU
                  RAISE error;
            END;

            vpasexec := 6;

            -- Se desbloquea la póliza
            IF v_tipo = 'R' THEN
               BEGIN
                  UPDATE seguros_ren
                     SET cblopag = 0   -- No Bloqueada
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     numerr := 9901443;   -- Error al modificar la tabla SEGUROS_REN
                     RAISE error;
               END;
            ELSIF v_tipo = 'P' THEN
               BEGIN
                  UPDATE prestaren
                     SET cblopag = 0   -- No Bloqueada
                   WHERE sseguro = psseguro
                     AND sperson = vsperson;
               EXCEPTION
                  WHEN OTHERS THEN
                     numerr := 9901790;   -- Error al modificar la tabla PRESTAREN
                     RAISE error;
               END;
            END IF;

            vpasexec := 7;

            -- Se desbloquean los pagos
            FOR reg_pag IN cur_pagos(psseguro, vsperson) LOOP
               numerr :=
                  pk_rentas.cambia_estado_recibo
                                               (reg_pag.srecren,   -- Clave del Recibo
                                                TRUNC(f_sysdate),   -- Fecha del nuevo movimiento
                                                0);   -- Nuevo estado de movimiento 0.- Pendiente pago
               vpasexec := 8;

               IF numerr <> 0 THEN
                  EXIT;
               END IF;
            END LOOP;

            vpasexec := 9;

            IF numerr <> 0 THEN
               vpasexec := 10;
               ROLLBACK;
               RAISE error;
            ELSE
               vpasexec := 11;
               COMMIT;
            END IF;
         END LOOP;

         i := i + 1;
         vsperson := pac_fe_vida.f_valor_substr(UPPER(ptlista), 'SPERSON' || i || '=', ';');
      END LOOP;

      RETURN 0;   -- Todo Ok
   EXCEPTION
      WHEN error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'error ' || numerr, SQLERRM);
         ROLLBACK;
         RETURN numerr;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 140999, SQLERRM);
         ROLLBACK;
         RETURN 140999;   -- Error no controlado
   END f_confirmar_fe_vida;

   /************************************************************************************************************************************
   funcion P_PROCESO_CERTIFICA_FE_VIDA
    nota:
   Se crea un proceso de certificación de fe de vida, que se debe lanzar diariamente, para controlar
   si se bloquea una póliza en caso de que se haya enviado a los titulares del contrato la solicitud
   de Fe de Vida y pasados dos meses (según parametrización) desde su envío no se hayan aún personado o presentado su
   certificado médico que justifique su fe de vida en su oficina.

     param in psproces : nº de proceso
     param in psseguro : nº de seguro
      Retorno: numero de proceso
   ******************************************************************************************************************************************/
   PROCEDURE p_proceso_certifica_fe_vida(
      psseguro IN NUMBER DEFAULT NULL,
      psproces IN OUT NUMBER) IS
      num_err        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := ' psseguro=' || psseguro || ' psproces= ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_FE_DE_VIDA.P_PROCESO_CERTIFICA_FE_VIDA';
      verror         NUMBER := 0;
      v_sproces      NUMBER;
      nprolin        NUMBER;
      empresa        VARCHAR2(10);
      vsperson       NUMBER;

      -- Se busca si la póliza tiene un apunte en la Agenda con ctipreg = 31.-Envío de Cartas de Fe de Vida
      -- sin finalizar y que haya pasado más de 2 meses desde que se generó el apunte.
      -- La póliza debe estar vigente y no bloqueada
      -- Bug 18636 - APD - 05/05/2011 - union entre prestaren y pagosrenta tambien
      -- por nsinies, ntramit y ctipdes
      CURSOR cur_polizas IS
         SELECT s.sseguro, s.npoliza, s.ncertif,
                                                 --DECODE(sr.sseguro, NULL, DECODE(pr.sseguro, NULL, ' ', 'P'), 'R') tipo,
                'R' tipo, a.ttextos, NULL nsinies, NULL ntramit, NULL ctipdes
           FROM agensegu a, seguros s, seguros_ren sr
          WHERE a.sseguro = s.sseguro
            AND sr.sseguro = s.sseguro
            AND(s.sseguro = psseguro
                OR psseguro IS NULL)
            AND s.csituac = 0   -- poliza vigente
            AND(NVL(sr.cblopag, 0) <> 5)   -- póliza no bloqueada 5.-Bloqueada, 0.-No Bloqueada
            AND a.ctipreg = 31   -- Envio Carta Fe de Vida (cvalor = 21)
            AND TRUNC(f_sysdate) >=
                  ADD_MONTHS
                     (a.falta,
                      pac_parametros.f_parempresa_n(s.cempres, 'MESES_MARGEN_FE_VIDA'))   -- han pasado 2 meses desde que se genero el apunte (se envió la carta)--'MESES_MARGEN_FE_VIDA'????
            AND a.cestado = 0   -- apunte sin finalizar
         UNION
         SELECT s.sseguro, s.npoliza, s.ncertif,
                                                 --DECODE(sr.sseguro, NULL, DECODE(pr.sseguro, NULL, ' ', 'P'), 'R') tipo,
                'P' tipo, a.ttextos, pr.nsinies nsinies, pr.ntramit ntramit,
                pr.ctipdes ctipdes
           FROM agensegu a, seguros s, prestaren pr
          WHERE a.sseguro = s.sseguro
            AND pr.sseguro = s.sseguro
            AND pr.npresta = (SELECT MAX(npresta)
                                FROM prestaren pt
                               WHERE pt.sseguro = pr.sseguro)
            AND(s.sseguro = psseguro
                OR psseguro IS NULL)
            AND s.csituac = 0   -- poliza vigente
            AND(NVL(pr.cblopag, 0) <> 5)   -- póliza no bloqueada 5.-Bloqueada, 0.-No Bloqueada
            AND a.ctipreg = 31   -- Envio Carta Fe de Vida (cvalor = 21)
            AND TRUNC(f_sysdate) >=
                  ADD_MONTHS
                     (a.falta,
                      pac_parametros.f_parempresa_n(s.cempres, 'MESES_MARGEN_FE_VIDA'))   -- han pasado 2 meses desde que se genero el apunte (se envió la carta)--'MESES_MARGEN_FE_VIDA'????
            AND a.cestado = 0   -- apunte sin finalizar
            AND pac_fe_vida.f_valor_substr(UPPER(a.ttextos), 'SPERSON=', ';') = pr.sperson;

      -- fin Bug 18636 - APD - 05/05/2011

      -- Se buscan los pagos de renta en situacion Pendiente de pago
      -- Bug 18636 - APD - 05/05/2011 - union entre prestaren y pagosrenta tambien
      -- por nsinies, ntramit y ctipdes
      CURSOR cur_pagos(
         p_sseguro NUMBER,
         p_sperson NUMBER,
         p_nsinies NUMBER,
         p_ntramit NUMBER,
         p_ctipdes NUMBER) IS
         SELECT p.srecren
           FROM pagosrenta p, movpagren m
          WHERE p.srecren = m.srecren
            AND p.sseguro = p_sseguro
            AND p.sperson = NVL(p_sperson, p.sperson)
            AND p.nsinies = NVL(p_nsinies, p.nsinies)
            AND p.ntramit = NVL(p_ntramit, p.ntramit)
            AND p.ctipdes = NVL(p_ctipdes, p.ctipdes)
            AND m.cestrec = 0   -- Pendiente de pago
            AND m.fmovfin IS NULL;
   BEGIN
      empresa := f_parinstalacion_n('EMPRESADEF');
      pac_iax_login.p_iax_iniconnect(pac_parametros.f_parempresa_t(empresa, 'USER_BBDD'));

      -- Si el psproces no está informado, se creará la cabecera del proceso
      IF psproces IS NULL THEN
         verror := f_procesini(f_user, empresa, 'PROCESO_FE_VIDA',
                               'Proceso Certifica Fe Vida:' || TRUNC(f_sysdate), v_sproces);
         vpasexec := 2;
      ELSE
         verror := f_proceslin(v_sproces,
                               'Inicio proceso Certifica Fe Vida '
                               || TO_CHAR(f_sysdate, 'DD-MM-YYYY  HH24:MI'),
                               0, nprolin, 4);
         v_sproces := psproces;
         vpasexec := 3;
      END IF;

      FOR reg IN cur_polizas LOOP
         -- Si existe el apunte, se mira la póliza ya está bloqueada (ya se ha lanzado el proceso y
         -- ha bloqueado la póliza)

         -- Se bloquea la póliza
         IF reg.tipo = 'R' THEN
            vsperson := NULL;

            UPDATE seguros_ren
               SET cblopag = 5   -- Bloqueada
             WHERE sseguro = reg.sseguro;
         ELSIF reg.tipo = 'P' THEN
            vsperson := f_valor_substr(reg.ttextos, 'SPERSON=', ';');

            -- Bug 18636 - APD - 05/05/2011 - union entre prestaren y pagosrenta tambien
            -- por nsinies, ntramit y ctipdes
            UPDATE prestaren
               SET cblopag = 5   -- Bloqueada
             WHERE sseguro = reg.sseguro
               AND sperson = vsperson
               AND nsinies = reg.nsinies
               AND ntramit = reg.ntramit
               AND ctipdes = reg.ctipdes;
         END IF;

         vpasexec := 4;
         num_err := 0;

         -- Se bloquean los pagos de renta en situacion Pendiente de Pago
            -- Bug 18636 - APD - 05/05/2011 - union entre prestaren y pagosrenta tambien
            -- por nsinies, ntramit y ctipdes, por lo tanto se debe pasar al cur_pagos
            -- dichos campos
         FOR reg_pag IN cur_pagos(reg.sseguro, vsperson, reg.nsinies, reg.ntramit, reg.ctipdes) LOOP
            num_err :=
               pk_rentas.cambia_estado_recibo(reg_pag.srecren,   -- Clave del Recibo
                                              TRUNC(f_sysdate),   -- Fecha del nuevo movimiento
                                              5);   -- Nuevo estado de movimiento 5.-Pendiente Bloqueado
            vpasexec := 5;

            IF num_err <> 0 THEN
               EXIT;
            END IF;
         END LOOP;

         IF num_err <> 0 THEN
            ROLLBACK;
            verror := f_proceslin(v_sproces,
                                  f_axis_literales(9901450) || '.'
                                  || f_axis_literales(9000464) || ': '
                                  || f_axis_literales(num_err) || ': ' || reg.npoliza || '/'
                                  || reg.ncertif,
                                  reg.sseguro, nprolin, 1);
            vpasexec := 6;
         -- 141078: Bloqueos Pagos
         ELSE
            COMMIT;
            verror := f_proceslin(v_sproces,
                                  f_axis_literales(152212) || ': ' || reg.npoliza || '/'
                                  || reg.ncertif,
                                  reg.sseguro, nprolin, 4);
            -- 152212: Póliza bloqueada
            vpasexec := 7;
         END IF;
      END LOOP;

      verror := f_proceslin(v_sproces, 'Proceso Certifica Fe Vida finalizado.', 0, nprolin, 4);
      vpasexec := 8;

      IF psproces IS NULL THEN
         verror := f_procesfin(v_sproces, verror);
      END IF;

      vpasexec := 9;
      psproces := v_sproces;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: ' || vparam, SQLERRM);
   END p_proceso_certifica_fe_vida;

-- BUG 24743 - MDS - 28/01/2013
-- versión ampliada de F_GET_RENTAS_BLOQUEADAS, que incluye los campos Regional y Sucursal para los maps 641 y 642 de POS
-- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
   /*************************************************************************
     Función  F_GET_RENTAS_BLOQUEADAS2
     función que devolverá un VARCHAR2 con la select de las pólizas con rentas bloqueadas debido a que no se ha certificado todavía la fe de vida de los titulares del contrato
     Nota: Se puede realizar la consulta de aquellos contratos a los cuales se les ha enviado la Carta de Fe de Vida. Dichos contratos deben cumplir los requisitos siguientes:
          Contratos vigentes y no retenidos por siniestro o rescate (csituac = 0 y pac_motretenction.f_esta_retenica_sin_resc = 0)
          Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida; agensegu.ctipreg = 31).
          El apunte en la agenda se debe de haber realizado entre las fechas inicial y final seleccionadas (agensegu.falta >=pfinicial y agensegu.falta <= pffinal)
          La póliza está bloqueada (pagosrenta.cblopag = 5.-Bloqueada)

      parametros
      1.   pcidioma. Identificador del idioma.
      2.   pcempres. Identificador de la empresa. Obligatorio.
      3.   psproduc. Identificador del producto.
      4.   pfinicial. Fecha inicio.
      5.   pffinal. Fecha final
      6.   pcramo. Identificador del ramo.
      7.   pcagente. Identificador del agente.
      8.   pcagrpro. Identificador de la agrupación de la póliza.
      9.   pperage   sperson del agente
     param in out mensajes   : mensajes de error
           return             VARCHAR2
     *************************************************************************/
   FUNCTION f_get_rentas_bloqueadas2(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      pperage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'pcidioma=' || pcidioma || ' pcempres=' || pcempres || ' psproduc=' || psproduc
            || ' pfinicial=' || pfinicial || ' pffinal=' || pffinal || ' pcramo=' || pcramo
            || ' pcagente=' || pcagente || ' pcagrpro=' || pcagrpro || ' pperage=' || pperage;
      vobject        VARCHAR2(200) := 'PAC_FE_DE_VIDA.F_GET_RENTAS_BLOQUEADAS2';
      vsquery        VARCHAR2(4000);
      v_txtperage    VARCHAR2(200);
   BEGIN
      vpasexec := 2;

      IF pcempres IS NULL
         OR pfinicial IS NULL
         OR pffinal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      -- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
      -- Podemos tener varios agentes asignados a diferentes sucursales, que en realidad son la misma persona.
      IF pperage IS NULL THEN
         v_txtperage := NULL;
      ELSE
         v_txtperage := ' and s.cagente in (select cagente from agentes where sperson='
                        || pperage || ')';
      END IF;

      vpasexec := 4;
      -- Bug 18636 - APD - 05/05/2011 - union entre prestaren y pagosrenta tambien
      -- por nsinies, ntramit y ctipdes
      vsquery :=
         ' SELECT   s.sproduc sproduc, ' || ' (SELECT ttitulo ' || ' FROM titulopro t '
         || ' WHERE t.cramo = s.cramo ' || ' AND t.cmodali = s.cmodali '
         || ' AND t.ctipseg = s.ctipseg ' || ' AND t.ccolect = s.ccolect '
         || ' AND t.cidioma = s.cidioma) descproducto, '
         || ' f_formatopol(s.npoliza, s.ncertif, 1) contrato, ' || ' DECODE(a1.ffecfin, '
         || ' NULL, DECODE(a1.sperson, NULL, NULL, f_nombre(a1.sperson, 1)), '
         || ' NULL) nombretitular1, ' || ' DECODE(a1.ffecfin, '
         || ' NULL, DECODE(a1.sperson, NULL, NULL, '
         || ' fedadaseg(0, a1.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular1, ' || ' DECODE(a2.ffecfin, '
         || ' NULL, DECODE(a2.sperson, NULL, NULL, f_nombre(a2.sperson, 1)), '
         || ' NULL) nombretitular2, ' || ' DECODE(a2.ffecfin, '
         || ' NULL, DECODE(a2.sperson, NULL, NULL, '
         || ' fedadaseg(0, a2.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular2, '
         || ' ag.falta fecha_envio, p.iconret importe, p.ffecpag fecha_emision '
         -- Ini Bug 24743 - MDS - 28/01/2013
         || ', pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(s.cempres,s.cagente,1,f_sysdate)) '
         || ', pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(s.cempres,s.cagente,2,f_sysdate)) '
         -- Fin Bug 24743 - MDS - 28/01/2013
         || ' FROM seguros s, seguros_ren sr, agensegu ag, asegurados a1, asegurados a2, '
         || ' pagosrenta p, movpagren m ' || ' WHERE s.sseguro = sr.sseguro '
         || ' AND s.sseguro = ag.sseguro ' || ' AND a1.sseguro = s.sseguro '
         || ' AND a2.sseguro(+) = s.sseguro ' || ' AND a1.norden = 1 '
         || ' AND a2.norden(+) = 2 ' || ' AND p.sseguro = sr.sseguro '
         || ' AND p.srecren = m.srecren ' || 'AND m.fmovfin IS NULL '
         || ' AND ag.ctipreg = 31    ' || ' AND ag.cestado = 0    ' || ' AND ag.falta >= '''
         || TRUNC(pfinicial) || ''' AND ag.falta <= ''' || TRUNC(pffinal)
         || ''' AND sr.cblopag = 5 ' || ' AND m.cestrec = 5 ' || ' AND s.csituac = 0    '
         || ' AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro) = 0 '
         || ' AND(s.cempres = NVL(' || NVL(TO_CHAR(pcempres), 'NULL') || ',s.cempres))'
         || ' AND(s.cramo = NVL(' || NVL(TO_CHAR(pcramo), 'NULL') || ',s.cramo))'
         || ' AND(s.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'NULL') || ',s.sproduc))'
         || ' AND(s.cagente = NVL(' || NVL(TO_CHAR(pcagente), 'NULL') || ',s.cagente))'
         || ' AND(s.cagrpro = NVL(' || NVL(TO_CHAR(pcagrpro), 'NULL') || ',s.cagrpro))'
         || v_txtperage || ' UNION ' || ' SELECT   s.sproduc sproduc, ' || ' (SELECT ttitulo '
         || ' FROM titulopro t ' || ' WHERE t.cramo = s.cramo '
         || ' AND t.cmodali = s.cmodali ' || ' AND t.ctipseg = s.ctipseg '
         || ' AND t.ccolect = s.ccolect ' || ' AND t.cidioma = s.cidioma) descproducto, '
         || ' f_formatopol(s.npoliza, s.ncertif, 1) contrato, ' || ' DECODE(pp.fdefunc, '
         || ' NULL, DECODE(pp.sperson, NULL, NULL, f_nombre(pp.sperson, 1)), '
         || ' NULL) nombretitular1, ' || ' DECODE(pp.fdefunc, '
         || ' NULL, DECODE(pp.sperson, NULL, NULL, '
         || ' fedadaseg(0, pp.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular1, ' || ' NULL nombretitular2, ' || ' NULL edadtitular2, '
         || ' ag.falta fecha_envio, p.iconret importe, p.ffecpag fecha_emision '
         -- Ini Bug 24743 - MDS - 28/01/2013
         || ', pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(s.cempres,s.cagente,1,f_sysdate)) '
         || ', pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(s.cempres,s.cagente,2,f_sysdate)) '
         -- Fin Bug 24743 - MDS - 28/01/2013
         || ' FROM seguros s, prestaren pr, agensegu ag, per_personas pp, '
         || ' pagosrenta p, movpagren m ' || ' WHERE s.sseguro = ag.sseguro '
         || ' AND s.sseguro = pr.sseguro ' || ' AND pr.sperson = pp.sperson(+) '
         || 'AND pr.sseguro = p.sseguro ' || 'AND pr.sperson = p.sperson '
         || 'AND pr.nsinies = p.nsinies ' || 'AND pr.ntramit = p.ntramit '
         || 'AND pr.ctipdes = p.ctipdes ' || ' AND p.srecren = m.srecren '
         || 'AND m.fmovfin IS NULL ' || ' AND ag.ctipreg = 31    ' || ' AND ag.cestado = 0    '
         || ' AND ag.falta >= ''' || TRUNC(pfinicial) || ''' AND ag.falta <= '''
         || TRUNC(pffinal) || ''' AND pr.cblopag = 5 ' || ' AND m.cestrec = 5 '
         || ' AND s.csituac = 0    '
         || ' AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro) = 0 '
         || ' AND(s.cempres = NVL(' || NVL(TO_CHAR(pcempres), 'NULL') || ',s.cempres))'
         || ' AND(s.cramo = NVL(' || NVL(TO_CHAR(pcramo), 'NULL') || ',s.cramo))'
         || ' AND(s.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'NULL') || ',s.sproduc))'
         || ' AND(s.cagente = NVL(' || NVL(TO_CHAR(pcagente), 'NULL') || ',s.cagente))'
         || ' AND(s.cagrpro = NVL(' || NVL(TO_CHAR(pcagrpro), 'NULL') || ',s.cagrpro))'
         || v_txtperage || ' ORDER BY 1, 3 ';
      -- fin Bug 18636 - APD - 05/05/2011
      vpasexec := 4;
      RETURN vsquery;
   EXCEPTION   --???
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'vsquery ' || vsquery, SQLERRM);
         RETURN NULL;
   END f_get_rentas_bloqueadas2;

-- BUG 24743 - MDS - 28/01/2013
-- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
-- versión ampliada de F_GET_CONSULTA_FE_VIDA, que incluye los campos Regional y Sucursal para el map 642 de POS
   /*************************************************************************
    Función F_GET_CONSULTA_FE_VIDA
    Devuelved un VARCHAR2 con la select de las pólizas que tienen un apunte en la Agenda de tipo 31.-Envío de Cartas de Fe de Vida
    Nota: Se puede realizar la consulta de aquellos contratos a los cuales se les ha enviado la Carta de Fe de Vida. Dichos contratos deben cumplir los requisitos siguientes:
    Contratos vigentes y no retenidos por siniestro o rescate (csituac = 0 y pac_motretenction.f_esta_retenica_sin_resc = 0)
     Se debe de haber enviado anteriormente la carta de fe de vida (existe un apunte en la Agenda de tipo Envío Carta Fe de Vida; agensegu.ctipreg = 31).
    El apunte en la agenda se debe de haber realizado entre las fechas inicial y final seleccionadas (agensegu.falta >=pfinicial y agensegu.falta <= pffinal)

    Parametros
     1.   pcidioma. Identificador del idioma.
     2.   pcempres. Identificador de la empresa. Obligatorio.
     3.   psproduc. Identificador del producto.
     4.   pfinicial. Fecha inicio.
     5.   pffinal. Fecha final
     6.   pcramo. Identificador del ramo.
     7.   pcagente. Identificador del agente.
     8.   pcagrpro. Identificador de la agrupación de la póliza.
     9.   pperage   sperson del agente
    param in out mensajes   : mensajes de error
          return             VARCHAR2
    *************************************************************************/
   FUNCTION f_get_consulta_fe_vida2(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pcagrpro IN NUMBER,
      pperage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'pcidioma=' || pcidioma || ' pcempres=' || pcempres || ' psproduc=' || psproduc
            || ' pfinicial=' || pfinicial || ' pffinal=' || pffinal || ' pcramo=' || pcramo
            || ' pcagente=' || pcagente || ' pcagrpro=' || pcagrpro || ' pperage=' || pperage;
      vobject        VARCHAR2(200) := 'PAC_FE_DE_VIDA.F_GET_CONSULTA_FE_VIDA2';
      vsquery        VARCHAR2(4000);
      v_txtperage    VARCHAR2(200);
   BEGIN
      vpasexec := 2;

      IF pcempres IS NULL
         OR pfinicial IS NULL
         OR pffinal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      -- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
      -- Podemos tener varios agentes asignados a diferentes sucursales, que en realidad son la misma persona.
      IF pperage IS NULL THEN
         v_txtperage := NULL;
      ELSE
         v_txtperage := ' and s.cagente in (select cagente from agentes where sperson='
                        || pperage || ')';
      END IF;

      vpasexec := 4;
      vsquery :=
         ' SELECT   s.sproduc sproduc,  ' || ' (SELECT ttitulo  ' || ' FROM titulopro t '
         || ' WHERE t.cramo = s.cramo ' || ' AND t.cmodali = s.cmodali '
         || ' AND t.ctipseg = s.ctipseg ' || ' AND t.ccolect = s.ccolect '
         || ' AND t.cidioma = s.cidioma) descproducto, '
         || ' f_formatopol(s.npoliza, s.ncertif, 1) contrato, ' || ' DECODE(a1.ffecfin, '
         || ' NULL, DECODE(a1.sperson, NULL, NULL, f_nombre(a1.sperson, 1)), '
         || ' NULL) nombretitular1, ' || ' DECODE(a1.ffecfin, '
         || ' NULL, DECODE(a1.sperson, NULL, NULL, '
         || ' fedadaseg(0, a1.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular1, ' || ' DECODE(a2.ffecfin, '
         || ' NULL, DECODE(a2.sperson, NULL, NULL, f_nombre(a2.sperson, 1)), '
         || ' NULL) nombretitular2, ' || ' DECODE(a2.ffecfin, '
         || ' NULL, DECODE(a2.sperson, NULL, NULL, '
         || ' fedadaseg(0, a2.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular2, ' || ' ag.falta fecha_envio, ' || ' (SELECT d.tatribu '
         || ' FROM detvalores d ' || ' WHERE d.cvalor = 22 ' || ' AND d.cidioma = s.cidioma '
         || ' AND d.catribu = ag.cestado) desc_estado '
         -- Ini Bug 24743 - MDS - 28/01/2013
         || ', pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(s.cempres,s.cagente,1,f_sysdate)) '
         || ', pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(s.cempres,s.cagente,2,f_sysdate)) '
         -- Fin Bug 24743 - MDS - 28/01/2013
         || ' FROM seguros s, seguros_ren sr, agensegu ag, asegurados a1, asegurados a2 '
         || ' WHERE s.sseguro = ag.sseguro ' || ' AND s.sseguro = sr.sseguro '
         || ' AND a1.sseguro = s.sseguro ' || ' AND a2.sseguro(+) = s.sseguro '
         || ' AND a1.norden = 1 ' || ' AND a2.norden(+) = 2 ' || ' AND ag.ctipreg = 31    '
         || ' AND ag.falta >= ''' || TRUNC(pfinicial) || ''' AND ag.falta <= '''
         || TRUNC(pffinal) || '''  AND s.csituac = 0  '
         || ' AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro) = ' || ' 0 '
         || ' AND(s.cempres = NVL(' || NVL(TO_CHAR(pcempres), 'NULL') || ',s.cempres))'
         || ' AND(s.cramo = NVL(' || NVL(TO_CHAR(pcramo), 'NULL') || ',s.cramo))'
         || ' AND(s.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'NULL') || ',s.sproduc))'
         || ' AND(s.cagente = NVL(' || NVL(TO_CHAR(pcagente), 'NULL') || ',s.cagente))'
         || ' AND(s.cagrpro = NVL(' || NVL(TO_CHAR(pcagrpro), 'NULL') || ',s.cagrpro))'
         || v_txtperage || ' UNION ' || ' SELECT   s.sproduc sproduc,  '
         || ' (SELECT ttitulo  ' || ' FROM titulopro t ' || ' WHERE t.cramo = s.cramo '
         || ' AND t.cmodali = s.cmodali ' || ' AND t.ctipseg = s.ctipseg '
         || ' AND t.ccolect = s.ccolect ' || ' AND t.cidioma = s.cidioma) descproducto, '
         || ' f_formatopol(s.npoliza, s.ncertif, 1) contrato, ' || ' DECODE(pp.fdefunc, '
         || ' NULL, DECODE(pp.sperson, NULL, NULL, f_nombre(pp.sperson, 1)), '
         || ' NULL) nombretitular1, ' || ' DECODE(pp.fdefunc, '
         || ' NULL, DECODE(pp.sperson, NULL, NULL, '
         || ' fedadaseg(0, pp.sperson, TO_CHAR(ag.falta, ''yyyymmdd''), ' || ' 2)), '
         || ' NULL) edadtitular1, ' || ' NULL nombretitular2, ' || ' NULL edadtitular2, '
         || ' ag.falta fecha_envio, ' || ' (SELECT d.tatribu ' || ' FROM detvalores d '
         || ' WHERE d.cvalor = 22 ' || ' AND d.cidioma = s.cidioma '
         || ' AND d.catribu = ag.cestado) desc_estado '
         -- Ini Bug 24743 - MDS - 28/01/2013
         || ', pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(s.cempres,s.cagente,1,f_sysdate)) '
         || ', pac_isqlfor.f_agente(pac_redcomercial.f_busca_padre(s.cempres,s.cagente,2,f_sysdate)) '
         -- Fin Bug 24743 - MDS - 28/01/2013
         || ' FROM seguros s, prestaren pr, agensegu ag, per_personas pp '
         || ' WHERE s.sseguro = ag.sseguro ' || ' AND s.sseguro = pr.sseguro '
         || ' AND pr.sperson = pp.sperson(+) ' || ' AND ag.ctipreg = 31    '
         || ' AND ag.falta >= ''' || TRUNC(pfinicial) || ''' AND ag.falta <= '''
         || TRUNC(pffinal) || '''  AND s.csituac = 0  '
         || ' AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro) = ' || ' 0 '
         || ' AND(s.cempres = NVL(' || NVL(TO_CHAR(pcempres), 'NULL') || ',s.cempres))'
         || ' AND(s.cramo = NVL(' || NVL(TO_CHAR(pcramo), 'NULL') || ',s.cramo))'
         || ' AND(s.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'NULL') || ',s.sproduc))'
         || ' AND(s.cagente = NVL(' || NVL(TO_CHAR(pcagente), 'NULL') || ',s.cagente))'
         || ' AND(s.cagrpro = NVL(' || NVL(TO_CHAR(pcagrpro), 'NULL') || ',s.cagrpro))'
         || v_txtperage || ' ORDER BY 1, 3 ';
      vpasexec := 5;
      RETURN vsquery;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ' || vparam, SQLERRM);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'vsquery ' || vsquery, SQLERRM);
         RETURN NULL;
   END f_get_consulta_fe_vida2;
END pac_fe_vida;

/

  GRANT EXECUTE ON "AXIS"."PAC_FE_VIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FE_VIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FE_VIDA" TO "PROGRAMADORESCSI";
