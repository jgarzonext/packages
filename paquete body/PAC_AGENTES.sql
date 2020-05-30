--------------------------------------------------------
--  DDL for Package Body PAC_AGENTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AGENTES" AS
/****************************************************************************
   NOM:       PAC_AGENTES
   PROPÒSIT:  Funciones relacionades amb agents

   REVISIONS:
   Ver        Data         Autor             Descripció
   ---------  ----------  ---------------  ----------------------------------
   1.0        28/05/2009   MSR               1. Creació del package.
   1.1        15/06/2009   MSR               Límitació per empreses
   2.0        28/09/2011   JMC               Comisiones Indirectas (bug:19586)
   3.0        27/01/2012   APD               0020999: LCOL_C001: Comisiones Indirectas para ADN Bancaseguros
   4.0        11/04/2012   APD               0021230: LCOL: Comisiones indirectas en el proceso de liquidaciones
   5.0        21/05/2014   FAL              5.0031489: TRQ003-TRQ: Gap de comercial. Liquidación a nivel de Banco
****************************************************************************/

   /*************************************************************************
    FUNCTION f_agents_visibes
    Torna una taula amb l'empresa i els codis d'aqents de 'redcomercial'
    que l'agent loginat pot veure.

    return             : table

    La format d'utilitzar-la és TABLE(PAC_GENTES.F_AGENTS_VISIBLES).
    Per exemple, SELECT cempres,cagente FROM TABLE(PAC_AGENTES.F_AGENTS_VISIBLES)

    Notes:
       1.- En cas que algun agent estigui donat de baixa tornarà els agents fills
       però no el propi agent donat de baixa.
       2.- En cas que el contexte empresa estigui inicialitzat torna només aquella empresa
           Si el contexte és a NULL tornarà les dades per totes les empreses
   *************************************************************************/
--   FUNCTION f_agents_visibles
--      RETURN tt_redcomercial PIPELINED IS
--      k_cagente CONSTANT redcomercial.cagente%TYPE := pac_user.ff_get_cagente(f_user);
--      k_sysdate CONSTANT DATE := f_sysdate;
--      k_cempres CONSTANT empresas.cempres%TYPE := pac_md_common.f_get_cxtempresa;
--      v_dades        rt_redcomercial;
--   BEGIN
--      -- Obtenim les dades de l'agent per totes les empreses on hi és
--      FOR rage IN (SELECT cempres, cpernivel, cpervisio
--                     FROM redcomercial a
--                    WHERE a.cagente = k_cagente
--                      AND a.fmovini <= k_sysdate
--                      AND(a.fmovfin >= k_sysdate
--                          OR a.fmovfin IS NULL)
--                      AND(cempres = k_cempres
--                          OR k_cempres IS NULL)) LOOP
--         CASE rage.cpernivel
--            WHEN 2 THEN
--               -- L'agent només veu els seus
--               v_dades.cagente := k_cagente;
--               v_dades.cempres := rage.cempres;
--               PIPE ROW(v_dades);
--            WHEN 1 THEN
--               -- L'agent veus els seus i els dels descendents
--               FOR rred IN (SELECT r.cagente, r.cempres
--                              FROM (SELECT     r.cagente, r.cempres, r.fmovini, r.fmovfin
--                                          FROM redcomercial r
--                                         WHERE r.fmovfin IS NULL
--                                    START WITH r.cagente = rage.cpervisio
--                                           AND r.cempres = rage.cempres
--                                    CONNECT BY PRIOR r.cagente = r.cpadre
--                                           AND PRIOR r.cempres = r.cempres) r
--                             WHERE fmovini <= f_sysdate
--                               AND(fmovfin >= f_sysdate
--                                   OR fmovfin IS NULL)) LOOP
--                  v_dades.cagente := rred.cagente;
--                  v_dades.cempres := rred.cempres;
--                  PIPE ROW(v_dades);
--               END LOOP;
--            ELSE
--               NULL;
--         END CASE;
--      END LOOP;

   --      RETURN;
--   END;

   /*************************************************************************
    FUNCTION f_get_agecomp
    Funcion que dado un agente y una compañia retorna un agente compañia
    return             : number
   *************************************************************************/
   FUNCTION f_get_agecomp(pcagente IN NUMBER, pccompani IN NUMBER)
      RETURN VARCHAR2 IS
      vcagecomp      agentescia.cagecomp%TYPE;
   BEGIN
      SELECT cagecomp
        INTO vcagecomp
        FROM agentescia
       WHERE ccompani = pccompani
         AND cagente = pcagente;

      RETURN vcagecomp;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_get_agecomp', 1,
                     'pcagente = ' || pcagente || '; pccompani = ' || pccompani, SQLERRM);
         RETURN NULL;
   END f_get_agecomp;

   /*************************************************************************
    FUNCTION f_get_agente
    Funcion que dado un agente compañia y una compañia retorna un agente
    return             : number
   *************************************************************************/
   FUNCTION f_get_agente(pcagecomp IN VARCHAR2, pccompani IN NUMBER)
      RETURN NUMBER IS
      vcagente       agentescia.cagente%TYPE;
   BEGIN
      SELECT cagente
        INTO vcagente
        FROM agentescia
       WHERE ccompani = pccompani
         AND cagecomp = pcagecomp;

      RETURN vcagente;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_get_agente', 1,
                     'pcagecomp = ' || pcagecomp || '; pccompani = ' || pccompani, SQLERRM);
         RETURN NULL;
   END f_get_agente;

   /*************************************************************************
     FUNCTION f_get_cageind
     Funcion que dado un agente y una fecha retorna el agente activo a la fecha
     que cobrara las comisiones indirectas.
     param in pcagente   : Código agente
     param in pfecha     : Fecha en activo
     return             : Código agente indirectas
    *************************************************************************/
   FUNCTION f_get_cageind(pcagente IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      vcageind       NUMBER;
   BEGIN
      SELECT cageind
        INTO vcageind
        FROM redcomercial
       WHERE cagente = pcagente
         AND(TRUNC(fmovini) <= TRUNC(pfecha)
             AND fmovfin IS NULL
             OR TRUNC(fmovfin) > TRUNC(pfecha));

      RETURN vcageind;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_get_cageind', 1,
                     'pcagente = ' || pcagente || '; pfecha = '
                     || TO_CHAR(pfecha, 'dd/mm/yyyy'),
                     SQLERRM);
         RETURN NULL;
   END f_get_cageind;

   /*************************************************************************
    FUNCTION f_get_cageliq
    Funcion que dado un agente, una empresa y un tipo agente retorna el agente
    que este por encima del agente pasado por parametro, en el nivel especificado.
    Se utiliza para obtener el agente que cobra las comisiones en el caso de estar
    informado el parámetro por empresa LIQUIDA_CTIPAGE.
    param in pcagente   : Código agente
    param in pcempres     : Código de empresa
    param in pctipage  : Tipo de agente
    return             : Código agente liquidación
   *************************************************************************/
   FUNCTION f_get_cageliq(pcempres IN NUMBER, pctipage IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      vctipage       NUMBER;
      vcagente       NUMBER;
      vctipage2      NUMBER;
      vcagente2      NUMBER;
      vtrobat        BOOLEAN := FALSE;
   BEGIN
      IF pctipage IS NULL THEN
         vctipage := pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_CTIPAGE');
      ELSE
         vctipage := pctipage;
      END IF;

      vcagente := pcagente;

      WHILE NOT vtrobat LOOP
         SELECT ctipage, cpadre
           INTO vctipage2, vcagente2
           FROM redcomercial
          WHERE cempres = pcempres
            AND cagente = vcagente
            AND fmovfin IS NULL;

         IF vctipage2 = vctipage THEN
            vtrobat := TRUE;
            EXIT;
         END IF;

         vcagente := vcagente2;
      END LOOP;

      RETURN vcagente;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN pcagente;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_get_ageliq', 0,
                     'Error al obtener el agente', SQLERRM);
         RETURN pcagente;
   END f_get_cageliq;

   /*************************************************************************
     FUNCTION f_get_tipiva
     Funcion que dado un agente y una fecha retorna el % tipo de iva a la fecha
     que cobrara las comisiones.
     param in pcagente   : Código agente
     param in pfecha     : Fecha en activo
     return             :  % Tipo de iva a aplicar
    *************************************************************************/
   FUNCTION f_get_tipiva(pcagente IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      pptipiva       NUMBER;
   BEGIN
      SELECT ptipiva
        INTO pptipiva
        FROM tipoiva t, agentes ag
       WHERE ag.cagente = pcagente
         AND t.ctipiva = ag.ctipiva
         AND TRUNC(pfecha) >= TRUNC(finivig)
         AND TRUNC(pfecha) < TRUNC(NVL(ffinvig, pfecha + 1));

      RETURN pptipiva;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_get_tipiva', 1,
                     'pcagente = ' || pcagente || '; pfecha = '
                     || TO_CHAR(pfecha, 'dd/mm/yyyy'),
                     SQLERRM);
         RETURN NULL;
   END f_get_tipiva;

   /*************************************************************************
      FUNCTION f_get_reteniva
      Funcion que dado un agente y una fecha retorna el la retencion a aplicar en la fecha
      que cobrara las comisiones.
      param in pcagente   : Código agente
      param in pfecha     : Fecha en activo
      return              :  % Tipo de retención a aplicar
     *************************************************************************/
   FUNCTION f_get_reteniva(pcagente IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      ppretenc       NUMBER;
   BEGIN
      SELECT pretenc
        INTO ppretenc
        FROM retenciones ret, agentes ag
       WHERE ag.cagente = pcagente
         AND ret.cretenc = ag.cretenc
         AND TRUNC(pfecha) >= TRUNC(finivig)
         AND TRUNC(pfecha) < TRUNC(NVL(ffinvig, pfecha + 1));

      RETURN ppretenc;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_get_reteniva', 1,
                     'pcagente = ' || pcagente || '; pfecha = '
                     || TO_CHAR(pfecha, 'dd/mm/yyyy'),
                     SQLERRM);
         RETURN NULL;
   END f_get_reteniva;

   /*************************************************************************
      FUNCTION f_es_descendiente
      Funcion que dado un agente 1 y un agente 2 determina
      si el agente 2 es descendiente del agente 1.
      param in pcagepadre   : Código agente padre
      param in pcagedesc    : Código agente descendiente
      return              :  0- NO es descendiente, 1-SI es descendiente
     *************************************************************************/
   FUNCTION f_es_descendiente(pcempres IN NUMBER, pcagepadre IN NUMBER, pcagedesc IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      FOR x IN (SELECT     cagente
                      FROM redcomercial
                     WHERE cempres = pcempres
                       AND fmovfin IS NULL
                START WITH cempres = pcempres
                       AND cagente = pcagepadre
                CONNECT BY cpadre = PRIOR cagente
                       AND cempres = PRIOR cempres) LOOP
         IF x.cagente = pcagedesc THEN
            RETURN 1;
         END IF;
      END LOOP;

      RETURN 0;
   END f_es_descendiente;

   /*************************************************************************
    FUNCTION f_get_ccomind
    Funcion que dado un agente y una fecha retorna el cuadro de comision indirecta
    de su agente padre y el agente padre
    param in pcempres   : Código de empresa
    param in pcagente   : Código agente
    param in pfecha     : Fecha en activo
    param out pccomind     : cuadro de comision indirecta del agente padre
    param out pcpadre     : agente padre
    return             : number
   *************************************************************************/
   FUNCTION f_get_ccomind(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecha IN DATE,
      pccomind OUT NUMBER,
      pcpadre OUT NUMBER)
      RETURN NUMBER IS
      vccomind       comisionvig_agente.ccomisi%TYPE := NULL;
      vcage_padre    redcomercial.cpadre%TYPE;
   --vctipage       agentes.ctipage%TYPE := 3;   -- ADN
   BEGIN
      -- Bug 21230 - APD - 11/04/2012 - se le debe pasar NULL al parametro ctipage
      vcage_padre := pac_redcomercial.f_busca_padre(pcempres, pcagente, NULL /*vctipage*/,
                                                    pfecha);

      -- fin Bug 21230 - APD - 11/04/2012
      SELECT ca.ccomisi
        INTO vccomind
        FROM comisionvig_agente ca, codicomisio c
       WHERE ca.ccomisi = c.ccomisi
         AND c.ctipo = 1   --comision
         AND ca.cagente = vcage_padre
         AND TRUNC(pfecha) BETWEEN finivig AND NVL(ffinvig, TRUNC(pfecha))
         AND ca.ccomind = 1;   -- comision indirecta

      pccomind := vccomind;
      pcpadre := vcage_padre;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pccomind := NULL;
         pcpadre := vcage_padre;
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_get_ccomind', 1,
                     'pcagente = ' || pcagente || '; pfecha = '
                     || TO_CHAR(pfecha, 'dd/mm/yyyy'),
                     SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_get_ccomind;

   /*************************************************************************
    FUNCTION f_set_age_contacto
    Funcion que guarda el contacto de un agente
    param in pcagente   : Código agente
    param in pctipo     : Código del tipo de contacto
    param in pnorden    : Nº orden
    param in pnombre    : Nombre del contacto
    param in pcargo     : Código del cargo
    param in piddomici  : Código del domicilio
    param in ptelefono  : Telefono
    param in ptelefono2 : Telefono 2
    param in pfax       : Fax
    param in pweb       : web
    param in pemail     : Email
    return             : 0 - ok - Codi error

    Bug 21450/108261 - 24/02/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_age_contacto(
      pcagente IN NUMBER,
      pctipo IN NUMBER,
      pnorden IN NUMBER,
      pnombre IN VARCHAR2,
      pcargo IN VARCHAR2,
      piddomici IN NUMBER,
      ptelefono IN NUMBER,
      ptelefono2 IN NUMBER,
      pfax IN NUMBER,
      pweb IN VARCHAR2,
      pemail IN VARCHAR2)
      RETURN NUMBER IS
      vnorden        NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipo IS NULL THEN
         RETURN 140974;
      END IF;

      IF pnorden IS NULL THEN
         SELECT NVL(MAX(norden), 0) + 1
           INTO vnorden
           FROM age_contactos
          WHERE cagente = pcagente;

         INSERT INTO age_contactos
                     (cagente, ctipo, norden, nombre, cargo, iddomici, telefono,
                      telefono2, fax, web, email)
              VALUES (pcagente, pctipo, vnorden, pnombre, pcargo, piddomici, ptelefono,
                      ptelefono2, pfax, pweb, pemail);
      ELSE
         UPDATE age_contactos
            SET ctipo = pctipo,
                nombre = pnombre,
                cargo = pcargo,
                iddomici = piddomici,
                telefono = ptelefono,
                telefono2 = ptelefono2,
                fax = pfax,
                web = pweb,
                email = pemail
          WHERE cagente = pcagente
            AND norden = pnorden;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_set_age_contacto', 1,
                     'pcagente = ' || pcagente || ' pctipo:' || pctipo || ' pnorden:'
                     || pnorden || ' pnombre:' || pnombre || ' pcargo:' || pcargo
                     || ' piddomici:' || piddomici || ' ptelefono:' || ptelefono
                     || ' ptelefono2:' || ptelefono2 || ' pfax:' || pfax || ' pweb:' || pweb
                     || ' pemail:' || pemail,
                     SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_age_contacto;

   /*************************************************************************
    FUNCTION f_del_age_contacto
    Funcion que borra el contacto de un agente
    param in pcagente   : Código agente
    param in pnorden    : Nº orden
    return             : 0 - ok - Codi error

    Bug 21450/108261 - 27/02/2012 - AMC
   *************************************************************************/
   FUNCTION f_del_age_contacto(pcagente IN NUMBER, pnorden IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pcagente IS NULL
         OR pnorden IS NULL THEN
         RETURN 140974;
      END IF;

      DELETE      age_contactos
            WHERE cagente = pcagente
              AND norden = pnorden;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_del_age_contacto', 1,
                     'pcagente = ' || pcagente || ' pnorden:' || pnorden, SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_del_age_contacto;

   /*************************************************************************
     Función que inserta o actualiza los datos de un documento asociado a un agente
     param in pcagente   : Código agente
     param in pfcaduca   : Fecha de caducidad
     param in ptobserva  : Observaciones
     param in piddocgedox : Identificador del documento
     param in ptamano : Tamaño del documento

     Bug 21543/108711 - AMC - 02/03/2012
   *************************************************************************/
   FUNCTION f_set_docagente(
      pcagente IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptamano IN VARCHAR2)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' - ptamano:' || ptamano
            || ' - pfcaduca: ' || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - ptobserva: '
            || ptobserva || ' - piddocgedox: ' || piddocgedox;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_set_docpersona';
      salir          EXCEPTION;
   BEGIN
      IF pcagente IS NULL
         OR piddocgedox IS NULL THEN
         vnumerr := 103135;   --Faltan parámetros
         RAISE salir;
      END IF;

      vpasexec := 2;

      BEGIN
         INSERT INTO age_documentos
                     (cagente, iddocgedox, fcaduca, tobserva, tamano)
              VALUES (pcagente, piddocgedox, pfcaduca, ptobserva, ptamano);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE age_documentos
               SET fcaduca = pfcaduca,
                   tobserva = ptobserva,
                   tamano = ptamano
             WHERE cagente = pcagente
               AND iddocgedox = piddocgedox;
      END;

      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES', vpasexec, 'f_set_docagente',
                     f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTEA', vpasexec, 'f_set_docagente', SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_set_docagente;

-- BUG 31489 - FAL - 21/05/2014
   /*************************************************************************
     Función que recupera el agente al que debe liquidar
     param in pcempres   : Código empresa
     param in pcagente   : Código agente
   *************************************************************************/
   FUNCTION f_agente_liquida(pcempres IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      vctipage_liquida agentes_comp.ctipage_liquida%TYPE;
      v_ctipage      agentes.ctipage%TYPE;
      -- Bug 35979/206802: KJSC añadir campo max(CAGECLAVE) y guardar valor
      v_cageclave    agentes_comp.cageclave%TYPE;
   BEGIN
      vctipage_liquida := 0;

      SELECT COUNT(1), MAX(cageclave)
        INTO vctipage_liquida, v_cageclave
        FROM agentes_comp
       WHERE cagente = pcagente;

      -- Bug 35979/206802: KJSC Si cumple con las condiciones retorne v_cageclave
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_AGECLAVE'), 0) = 1
         AND vctipage_liquida > 0
         AND v_cageclave IS NOT NULL THEN
         RETURN v_cageclave;
      ELSIF vctipage_liquida > 0 THEN
         SELECT ctipage_liquida
           INTO vctipage_liquida
           FROM agentes_comp
          WHERE cagente = pcagente;

         -- 0031510 Si buscamos el mismo tipo del que tenemos, devolvemos el agente
         SELECT MAX(ctipage)
           INTO v_ctipage
           FROM agentes
          WHERE cagente = pcagente;

         IF vctipage_liquida IS NULL
            OR vctipage_liquida = v_ctipage THEN
            RETURN pcagente;
         ELSE
            RETURN pac_redcomercial.f_busca_padre(pcempres, pcagente, vctipage_liquida,
                                                  f_sysdate);
         END IF;
      ELSE
         RETURN pcagente;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_AGENTES.f_agente_liquida', 1,
                     'pcagente = ' || pcagente, SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_agente_liquida;
-- FI BUG 31489 - FAL - 21/05/2014
END pac_agentes;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGENTES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGENTES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGENTES" TO "PROGRAMADORESCSI";
