--------------------------------------------------------
--  DDL for Package Body PAC_MD_REDCOMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_REDCOMERCIAL" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_REDCOMERCIAL
      PROP¿SITO:    Funciones con todo lo referente a la Red Comercial de la capa MD

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        16/09/2008   AMC              1. Creaci¿n del package.
      2.0        01/06/2009   NMM              2.0010340: IAX - No se ven los datos del agente en otros idiomas
      3.0        19/10/2009   AMC              3. Bug 11444. Se quita el parametro pctipage a la funcion f_set_redcomarcial.
      5.0        23/03/2010   JMF              5. 0013392 - 23/03/2010 - JMF: APR - verificar el suplemento masivo de cambio de agente
      6.0        11/05/2010   ICV              6. 0014470: ERROR PUTTING IN NEW BROKERS
      7.0        29/12/2010   SRA              7. 0017004: APR - proceso de gesti¿n de impagos
      8.0        30/03/2011   DRA              8. 0018078: LCOL - Analisis Traspaso de Cartera
      9.0        20/10/2011   JMC              9. 0019586: AGM003-Comisiones Indirectas a distintos niveles.
      10.0       02/11/2011   DRA              10. 0019069: LCOL_C001 - Co-corretaje
      11.0       08/11/2011   APD              11. 0019169: LCOL_C001 - Campos nuevos a a¿adir para Agentes.
      12.0       21/11/2011   DRA              12. 0020208: LCOL_C001: Acceso a la vista PERSONAS
      13.0       05/12/2011   APD              13. 0020287: LCOL_C001 - Tener en cuenta campo Subvenci¿n
      14.0       23/01/2012   APD              14. 0021035: LCOL_C001: Bloque Gesti¿n de Cobro de Traspaso de Cartera
      15.0       24/01/2012   MDS              15. 0021044: LCOL_C001: Visualizaci¿n de importes en Traspaso de cartera
      16.0       26/01/2012   APD              16. 0020999: LCOL_C001: Comisiones Indirectas para ADN Bancaseguros
      17.0       01/03/2012   JMF              17. 0021425 MDP - COM - AGENTES Secci¿n datos generales
      18.0       29/05/2012   APD              18. 0021682: MDP - COM - Transiciones de estado de agente.
      19.0       29/11/2012   LECG             19.0024711: LCOL_C003-LCOL: Q-trackers de Fase 2
      20.0       30/11/2010   NMM              20. 24657: MDP_T001-Pruebas de Suplementos
      21.0       21/08/2013   MMM              21. 0027951: LCOL: Mejora de Red Comercial
      22.0       19/09/2013   MCA              22. 0027549: Traspaso de cartera
      23.0       21/05/2014   FAL              23. 0031489: TRQ003-TRQ: Gap de comercial. Liquidaci¿n a nivel de Banco
      24.0       11/03/2015   KJSC             24. BUG 35103-200056.KJSC Eliminar la l¿nea que calcula los d¿as de gesti¿n
	  25.0       16/01/2019   ACL              TCS_1: En la función f_set_agente y f_get_agente se agrega el campo claveinter para la tabla agentes.
	  26.0       01/02/2019   ACL              26. TCS_1569B: Se agrega parámetros de impuestos en la funcion f_set_agente. Se modifica la fucnión f_get_agente.
	  27.0       21/02/2019   AP               27. TCS-7: Se agrega parametro de domicilio en la funcion f_set_redcomercial.
	  28.0       27/02/2019   DFR              28. IAXIS-2415: FICHA RED COMERCIAL
   *******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
           Funci¿n que nos devolver¿ la red comercial seg¿n par¿metros informados en el filtro
           Return: Sys_Refcursor
       *************************************************************************/
   FUNCTION f_get_agentes(
      pempresa IN NUMBER,
      pfecha IN DATE,
      pcagente IN NUMBER,
      pnomagente IN VARCHAR2,
      ptipagente IN NUMBER,
      pactivo IN NUMBER,
      pctipmed IN NUMBER,
      pagrupador IN NUMBER,
      pnnumide IN VARCHAR2,
      pcpostal IN VARCHAR2,
      ptelefono IN NUMBER,
      ptnomcom IN VARCHAR2,
      pfax IN NUMBER,
      pmail IN VARCHAR2,
      pcage00 IN NUMBER,
      pcage01 IN NUMBER,
      pcage02 IN NUMBER,
      pcage03 IN NUMBER,
      pcage04 IN NUMBER,
      pcage05 IN NUMBER,
      pcage06 IN NUMBER,
      pcage07 IN NUMBER,
      pcage08 IN NUMBER,
      pcage09 IN NUMBER,
      pcage10 IN NUMBER,
      pcage11 IN NUMBER,
      pcage12 IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := ' pempresa:' || pempresa || ' pfecha:' || pfecha || ' pcagente:' || pcagente
            || ' pnomagente:' || pnomagente || ' ptipagente:' || ptipagente || 'pactivo:'
            || pactivo;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.F_get_agente';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      w_fecha        DATE;
   --
   BEGIN
      w_fecha := NVL(pac_parametros.f_parempresa_f(pempresa, 'AG_CONSUL_DATE'), pfecha);   -- Bug 24657.NMM.2012.11.30.

      --
      OPEN cur FOR
         SELECT   cagente, ctipage, ttipage, sperson, tnombre, cempres, tempres, territorio,
                  zona, delegacion, ejcomercial, mediador, tipmed, telf, cpostal
             FROM (SELECT DISTINCT a.cagente, a.ctipage,
                                   pac_redcomercial.f_get_desnivel
                                                      (a.ctipage,
                                                       pac_md_common.f_get_cxtempresa,
                                                       pac_md_common.f_get_cxtidioma) ttipage,
                                   a.sperson, f_nombre(a.sperson, 1, a.cagente) tnombre,
                                   r.cempres, (SELECT tempres
                                                 FROM empresas e
                                                WHERE e.cempres = r.cempres) tempres,
                                   DECODE(ar.c01,
                                          0, NULL,
                                          ar.c01 || '- ' || pac_isqlfor.f_agente(ar.c01))
                                                                                    territorio,
                                   DECODE(ar.c02,
                                          0, NULL,
                                          ar.c02 || '- ' || pac_isqlfor.f_agente(ar.c02)) zona,
                                   DECODE(ar.c03,
                                          0, NULL,
                                          ar.c03 || '- ' || pac_isqlfor.f_agente(ar.c03))
                                                                                    delegacion,
                                   DECODE(ar.c04,
                                          0, NULL,
                                          ar.c04 || '- ' || pac_isqlfor.f_agente(ar.c04))
                                                                                   ejcomercial,
                                   DECODE(ar.c05,
                                          0, NULL,
                                          ar.c05 || '- ' || pac_isqlfor.f_agente(ar.c05))
                                                                                      mediador,
                                   ff_desvalorfijo(1062, pac_md_common.f_get_cxtidioma,
                                                   a.ctipmed) tipmed,
                                   NVL((SELECT tvalcon
                                          FROM per_contactos c
                                         WHERE c.sperson = p.sperson
                                           AND ctipcon = 1
                                           AND ROWNUM = 1),
                                       (SELECT TO_CHAR(telefono)
                                          FROM age_contactos d
                                         WHERE d.cagente = a.cagente
                                           AND ctipo = 1
                                           AND ROWNUM = 1)) telf,
                                   (SELECT pd.cpostal
                                      FROM per_direcciones pd
                                     WHERE pd.sperson = p.sperson
                                       AND pd.cdomici = 1) cpostal
                              FROM agentes a, per_detper p, redcomercial r, ageredcom ar
                             WHERE a.ctipage = NVL(ptipagente, a.ctipage)
                               AND(UPPER(p.tbuscar) LIKE '%' || UPPER(pnomagente) || '%'
                                   OR pnomagente IS NULL)
                               AND p.sperson = a.sperson
                               AND(a.cactivo = pactivo
                                   OR pactivo IS NULL)
                               AND a.cagente = NVL(pcagente, a.cagente)
                               AND(TRUNC(r.fmovini) <= TRUNC(w_fecha)
                                   --AND r.fmovfin IS NULL --CELSO - 05/06/19 - IAXIS-4219 - Remove fmovfin IS NULL
                                   OR TRUNC(r.fmovfin) > TRUNC(w_fecha))
                               AND r.cagente = a.cagente
                               AND r.cempres = NVL(pempresa, r.cempres)
                               AND ar.cagente = r.cagente
                               AND ar.cempres = r.cempres
                              --AND r.fmovfin IS NULL   --CELSO - 05/06/19 - IAXIS-4219 - Remove fmovfin IS NULL
                              -- AND ar.fmovfin IS NULL   --CELSO - 05/06/19 - IAXIS-4219 - Remove fmovfin IS NULL
                               AND(ar.fmovini BETWEEN r.fmovini AND NVL(r.fmovfin, ar.fmovini))
                               AND(pctipmed IS NULL
                                   OR a.ctipmed = pctipmed)
                               AND(pnnumide IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_personas pp
                                              WHERE pp.sperson = p.sperson
                                                AND pp.nnumide = pnnumide))
                               AND(ptnomcom IS NULL
                                   OR UPPER(a.tnomcom) LIKE '%' || UPPER(ptnomcom) || '%')
                               AND(TO_CHAR(ptelefono) IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_contactos c
                                              WHERE c.sperson = p.sperson
                                                AND ctipcon IN(1, 5, 6, 8)
                                                AND tvalcon LIKE TO_CHAR(ptelefono)))
                               AND(TO_CHAR(pfax) IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_contactos c
                                              WHERE c.sperson = p.sperson
                                                AND ctipcon IN(2)
                                                AND tvalcon LIKE TO_CHAR(pfax))
                                   OR EXISTS(SELECT 1
                                               FROM age_contactos c
                                              WHERE c.cagente = a.cagente
                                                AND UPPER(fax) LIKE UPPER(pfax)))
                               AND(pmail IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_contactos c
                                              WHERE c.sperson = p.sperson
                                                AND ctipcon IN(3)
                                                AND UPPER(tvalcon) LIKE
                                                                      '%' || UPPER(pmail)
                                                                      || '%')
                                   OR EXISTS(SELECT 1
                                               FROM age_contactos c
                                              WHERE c.cagente = a.cagente
                                                AND UPPER(email) LIKE '%' || UPPER(pmail)
                                                                      || '%'))
                               AND(pcpostal IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_direcciones pd
                                              WHERE pd.sperson = p.sperson
                                                AND pd.cpostal = pcpostal))
                               AND(pagrupador IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM agentes_comp ac
                                              WHERE ac.cagente = a.cagente
                                                AND ac.agrupador = pagrupador))
                               AND(pcage00 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c00 = pcage00
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage01 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c01 = pcage01
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage02 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c02 = pcage02
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage03 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c03 = pcage03
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage04 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c04 = pcage04
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage05 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c05 = pcage05
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage06 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c06 = pcage06
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage07 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c07 = pcage07
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage08 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c08 = pcage08
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage09 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c09 = pcage09
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage10 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c10 = pcage10
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage11 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c11 = pcage11
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage12 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c12 = pcage12
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                   UNION
                   SELECT DISTINCT a.cagente, a.ctipage,
                                   pac_redcomercial.f_get_desnivel
                                                      (a.ctipage,
                                                       pac_md_common.f_get_cxtempresa,
                                                       pac_md_common.f_get_cxtidioma) ttipage,
                                   a.sperson, f_nombre(a.sperson, 1, NULL) tnombre,
                                   NULL cempres, NULL tempres, NULL territorio, NULL zona,
                                   NULL delegacion, NULL ejcomercial, NULL mediador,
                                   ff_desvalorfijo(1062, pac_md_common.f_get_cxtidioma,
                                                   a.ctipmed) tipmed,
                                   NVL((SELECT tvalcon
                                          FROM per_contactos c
                                         WHERE c.sperson = p.sperson
                                           AND ctipcon = 1
                                           AND ROWNUM = 1),
                                       (SELECT TO_CHAR(telefono)
                                          FROM age_contactos d
                                         WHERE d.cagente = a.cagente
                                           AND ctipo = 1
                                           AND ROWNUM = 1)) telf,
                                   (SELECT pd.cpostal
                                      FROM per_direcciones pd
                                     WHERE pd.sperson = p.sperson
                                       AND pd.cdomici = 1) cpostal
                              FROM agentes a, per_detper p
                             WHERE a.ctipage = NVL(ptipagente, a.ctipage)
                               AND(UPPER(p.tbuscar) LIKE '%' || UPPER(pnomagente) || '%'
                                   OR pnomagente IS NULL)
                               AND p.sperson = a.sperson
                               AND(a.cactivo = pactivo
                                   OR pactivo IS NULL)
                               AND a.cagente = NVL(pcagente, a.cagente)
                               AND a.cagente NOT IN(SELECT cagente
                                                      FROM redcomercial rr
                                                     WHERE rr.cagente = a.cagente)
                               AND(pctipmed IS NULL
                                   OR a.ctipmed = pctipmed)
                               AND(pnnumide IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_personas pp
                                              WHERE pp.sperson = p.sperson
                                                AND pp.nnumide = pnnumide))
                               AND(ptnomcom IS NULL
                                   OR UPPER(a.tnomcom) LIKE '%' || UPPER(ptnomcom) || '%')
                               AND(TO_CHAR(ptelefono) IS NULL
                                   OR EXISTS(
                                        SELECT 1
                                          FROM per_contactos c
                                         WHERE c.sperson = p.sperson
                                           AND ctipcon IN(1, 5, 6, 8)
                                           AND UPPER(tvalcon) LIKE UPPER(TO_CHAR(ptelefono)))
                                   OR EXISTS(SELECT 1
                                               FROM age_contactos c
                                              WHERE c.cagente = a.cagente
                                                AND UPPER(telefono) LIKE UPPER(ptelefono)))
                               AND(TO_CHAR(pfax) IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_contactos c
                                              WHERE c.sperson = p.sperson
                                                AND ctipcon IN(2)
                                                AND tvalcon LIKE TO_CHAR(pfax))
                                   OR EXISTS(SELECT 1
                                               FROM age_contactos c
                                              WHERE c.cagente = a.cagente
                                                AND UPPER(fax) LIKE UPPER(ptelefono)))
                               AND(pmail IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_contactos c
                                              WHERE c.sperson = p.sperson
                                                AND ctipcon IN(3)
                                                AND UPPER(tvalcon) LIKE
                                                                      '%' || UPPER(pmail)
                                                                      || '%')
                                   OR EXISTS(SELECT 1
                                               FROM age_contactos c
                                              WHERE c.cagente = a.cagente
                                                AND UPPER(email) LIKE '%' || UPPER(pmail)
                                                                      || '%'))
                               AND(pcpostal IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM per_direcciones pd
                                              WHERE pd.sperson = p.sperson
                                                AND pd.cpostal = pcpostal))
                               AND(pagrupador IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM agentes_comp ac
                                              WHERE ac.cagente = a.cagente
                                                AND ac.agrupador = pagrupador))
                               AND(pcage00 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c00 = pcage00
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage01 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c01 = pcage01
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage02 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c02 = pcage02
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage03 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c03 = pcage03
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage04 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c04 = pcage04
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage05 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c05 = pcage05
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage06 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c06 = pcage06
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage07 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c07 = pcage07
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage08 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c08 = pcage08
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage09 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c09 = pcage09
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage10 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c10 = pcage10
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage11 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c11 = pcage11
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha)))
                               AND(pcage12 IS NULL
                                   OR EXISTS(SELECT 1
                                               FROM ageredcom ar
                                              WHERE ar.cagente = a.cagente
                                                AND ar.c12 = pcage12
                                                AND w_fecha BETWEEN ar.fmovini
                                                                AND NVL(ar.fmovfin, w_fecha))))
         ORDER BY territorio, zona, delegacion, ejcomercial, mediador, cagente, ctipage,
                  tipmed, cpostal, telf;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agentes;

   /*************************************************************************
       Funci¿n que nos devolver¿ la red comercial seg¿n par¿metros informados en el filtro
       Return: Sys_Refcursor
   *************************************************************************/
   FUNCTION f_get_arbolredcomercial(
      pempresa IN NUMBER,
      pfecha IN DATE,
      pcagente IN NUMBER,
      pnomagente IN VARCHAR2,
      ptipagente IN NUMBER,
      pactivo IN NUMBER,
      pcbusqueda IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := ' pempresa:' || pempresa || ' pfecha:' || pfecha || ' pcagente:' || pcagente
            || ' pnomagente:' || pnomagente || ' ptipagente:' || ptipagente || 'pactivo:'
            || pactivo;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.F_get_arbolredcomercial';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
   BEGIN
      SELECT MIN(nivel)
        INTO nivelmin
        FROM (SELECT     LEVEL nivel, cagente
                    FROM redcomercial r
                   -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Inicio
                   --WHERE TRUNC(r.fmovini) <= TRUNC(pfecha) AND((TRUNC(r.fmovfin) > TRUNC(pfecha))OR r.fmovfin IS NULL)
              WHERE      (r.fmovfin IS NULL
                          OR(((SELECT COUNT(*)
                                 FROM redcomercial r1
                                WHERE r1.cagente = r.cagente
                                  AND r1.cempres = r.cempres
                                  AND r1.fmovfin IS NULL) = 0)
                             AND r.fmovini IN(SELECT   MAX(fmovini)
                                                  FROM redcomercial r2
                                                 WHERE r2.cagente = r.cagente
                                                   AND r2.cempres = r.cempres
                                              GROUP BY r2.cempres, r2.cagente)))
              -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Fin
              START WITH ((r.cagente = pcagente
                           AND pcagente IS NOT NULL)
                          OR(r.ctipage = NVL(ptipagente, 0)
                             AND pcagente IS NULL))
                     AND(r.cempres = pempresa
                         OR pempresa IS NULL)
                     -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Inicio
                     /*
                     AND TRUNC(r.fmovini) <= TRUNC(pfecha)
                     AND((TRUNC(r.fmovfin) > TRUNC(pfecha))
                         OR r.fmovfin IS NULL)
                     */
                     AND(r.fmovfin IS NULL
                         OR(((SELECT COUNT(*)
                                FROM redcomercial r1
                               WHERE r1.cagente = r.cagente
                                 AND r1.cempres = r.cempres
                                 AND r1.fmovfin IS NULL) = 0)
                            AND r.fmovini IN(SELECT   MAX(fmovini)
                                                 FROM redcomercial r2
                                                WHERE r2.cagente = r.cagente
                                                  AND r2.cempres = r.cempres
                                             GROUP BY r2.cempres, r2.cagente)))
              -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Fin
              CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
                     AND PRIOR r.cempres =(r.cempres + 0)
                     -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Inicio
                     /*
                     AND TRUNC(r.fmovini) <= TRUNC(pfecha)
                     AND((TRUNC(r.fmovfin) > TRUNC(pfecha))
                         OR r.fmovfin IS NULL)
                     */
                     AND(r.fmovfin IS NULL
                         OR(((SELECT COUNT(*)
                                FROM redcomercial r1
                               WHERE r1.cagente = r.cagente
                                 AND r1.cempres = r.cempres
                                 AND r1.fmovfin IS NULL) = 0)
                            AND r.fmovini IN(SELECT   MAX(fmovini)
                                                 FROM redcomercial r2
                                                WHERE r2.cagente = r.cagente
                                                  AND r2.cempres = r.cempres
                                             GROUP BY r2.cempres, r2.cagente)))
                     -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Fin
                     AND r.cagente >= 0) rr,
             agentes a,
             per_detper p   -- BUG20208:DRA:21/11/2011
       WHERE rr.cagente = a.cagente
         AND a.sperson = p.sperson
         AND(UPPER(p.tbuscar) LIKE '%' || UPPER(pnomagente) || '%'
             OR pnomagente IS NULL)
         AND(a.cactivo = pactivo
             OR pactivo IS NULL);

      IF pcbusqueda = 1 THEN
         OPEN cur FOR
            SELECT DISTINCT rr.codigo, rr.cempres, (SELECT e.tempres
                                                      FROM empresas e
                                                     WHERE e.cempres = rr.cempres) tempres,
                            rr.cagente, rr.ctipage,
                            pac_redcomercial.f_get_desnivel
                                                      (a.ctipage,
                                                       pac_md_common.f_get_cxtempresa,
                                                       pac_md_common.f_get_cxtidioma) ttipage,
                            rr.fmovini, a.sperson, f_nombre(a.sperson, 1, a.cagente) tnombre,
                            rr.cpadre, rr.cpadrefit
                       FROM (SELECT     cempres, r.cagente codigo, LEVEL, r.cagente, r.ctipage,
                                        r.fmovini, r.cpadre,
                                        DECODE(nivelmin, LEVEL, -999, r.cpadre) cpadrefit
                                   FROM redcomercial r
                                  -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Inicio
                                  --WHERE TRUNC(r.fmovini) <= TRUNC(pfecha) AND((TRUNC(r.fmovfin) > TRUNC(pfecha)) OR r.fmovfin IS NULL)
                             WHERE      (r.fmovfin IS NULL
                                         OR(((SELECT COUNT(*)
                                                FROM redcomercial r1
                                               WHERE r1.cagente = r.cagente
                                                 AND r1.cempres = r.cempres
                                                 AND r1.fmovfin IS NULL) = 0)
                                            AND r.fmovini IN(
                                                  SELECT   MAX(fmovini)
                                                      FROM redcomercial r2
                                                     WHERE r2.cagente = r.cagente
                                                       AND r2.cempres = r.cempres
                                                  GROUP BY r2.cempres, r2.cagente)))
                             -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Fin
                             START WITH ((r.cagente = pcagente
                                          AND pcagente IS NOT NULL)
                                         OR(r.ctipage = NVL(ptipagente, 0)
                                            AND pcagente IS NULL))
                                    AND(r.cempres = pempresa
                                        OR pempresa IS NULL)
                                    -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Inicio
                                    /*
                                    AND TRUNC(r.fmovini) <= TRUNC(pfecha)
                                    AND((TRUNC(r.fmovfin) > TRUNC(pfecha))
                                        OR r.fmovfin IS NULL)
                                    */
                                    AND(r.fmovfin IS NULL
                                        OR(((SELECT COUNT(*)
                                               FROM redcomercial r1
                                              WHERE r1.cagente = r.cagente
                                                AND r1.cempres = r.cempres
                                                AND r1.fmovfin IS NULL) = 0)
                                           AND r.fmovini IN(
                                                 SELECT   MAX(fmovini)
                                                     FROM redcomercial r2
                                                    WHERE r2.cagente = r.cagente
                                                      AND r2.cempres = r.cempres
                                                 GROUP BY r2.cempres, r2.cagente)))
                             -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Fin
                             CONNECT BY PRIOR r.cagente =(r.cpadre + 0)
                                    AND PRIOR r.cempres =(r.cempres + 0)
                                    -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Inicio
                                    /*
                                    AND TRUNC(r.fmovini) <= TRUNC(pfecha)
                                    AND((TRUNC(r.fmovfin) > TRUNC(pfecha))
                                        OR r.fmovfin IS NULL)
                                    */
                                    AND(r.fmovfin IS NULL
                                        OR(((SELECT COUNT(*)
                                               FROM redcomercial r1
                                              WHERE r1.cagente = r.cagente
                                                AND r1.cempres = r.cempres
                                                AND r1.fmovfin IS NULL) = 0)
                                           AND r.fmovini IN(
                                                 SELECT   MAX(fmovini)
                                                     FROM redcomercial r2
                                                    WHERE r2.cagente = r.cagente
                                                      AND r2.cempres = r.cempres
                                                 GROUP BY r2.cempres, r2.cagente)))
                                    -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Fin
                                    AND r.cagente >= 0) rr,
                            agentes a,
                            per_detper p   -- BUG20208:DRA:21/11/2011
                      WHERE rr.cagente = a.cagente
                        AND a.sperson = p.sperson
                        AND(UPPER(p.tbuscar) LIKE '%' || UPPER(pnomagente) || '%'
                            OR pnomagente IS NULL)
                        AND(a.cactivo = pactivo
                            OR pactivo IS NULL)
            UNION
            SELECT -999, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   f_axis_literales(103037, pac_md_common.f_get_cxtidioma), NULL, NULL
              FROM DUAL;
      ELSE
         OPEN cur FOR
            SELECT rr.cagente codigo, rr.cempres, rr.tempres, rr.cagente, rr.ctipage,
                   rr.ttipage, rr.fmovini, rr.sperson, rr.tnombrecomp tnombre, rr.cpadre,
                   rr.cpadrefit
              FROM (SELECT DISTINCT a.cagente, a.ctipage,

                                    -- BUG20208:DRA:21/11/2011
                                    pac_redcomercial.f_get_desnivel
                                                      (a.ctipage,
                                                       pac_md_common.f_get_cxtempresa,
                                                       pac_md_common.f_get_cxtidioma) ttipage,
                                    a.sperson, f_nombre(a.sperson, 1, a.cagente) tnombrecomp,
                                    r.cempres, (SELECT tempres
                                                  FROM empresas e
                                                 WHERE e.cempres = r.cempres) tempres,
                                    r.cpadre, -999 cpadrefit, r.fmovini
                               FROM agentes a, per_detper p,
                                                            -- BUG20208:DRA:21/11/2011
                                                            redcomercial r
                              WHERE a.ctipage = NVL(ptipagente, a.ctipage)
                                AND(UPPER(p.tbuscar) LIKE '%' || UPPER(pnomagente) || '%'
                                    OR pnomagente IS NULL)
                                AND p.sperson = a.sperson
                                AND(a.cactivo = pactivo
                                    OR pactivo IS NULL)
                                AND a.cagente = NVL(pcagente, a.cagente)
                                -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Inicio
                                --AND(TRUNC(r.fmovini) <= TRUNC(pfecha) AND r.fmovfin IS NULL OR TRUNC(r.fmovfin) > TRUNC(pfecha))
                                -- Devolvemos el que tenga fecha de fin a NULL y si no hay ninguno, el que tenga mayor fecha FMOVINI
                                AND(r.fmovfin IS NULL
                                    OR(((SELECT COUNT(*)
                                           FROM redcomercial r1
                                          WHERE r1.cagente = r.cagente
                                            AND r1.cempres = r.cempres
                                            AND r1.fmovfin IS NULL) = 0)
                                       AND r.fmovini IN(
                                             SELECT   MAX(fmovini)
                                                 FROM redcomercial r2
                                                WHERE r2.cagente = r.cagente
                                                  AND r2.cempres = r.cempres
                                             GROUP BY r2.cempres, r2.cagente)))
                                -- 21. MMM - 21/08/2013 - 0027951: LCOL: Mejora de Red Comercial - Fin
                                AND r.cagente = a.cagente
                                AND r.ctipage = a.ctipage
                                AND r.cempres = NVL(pempresa, r.cempres)
                    UNION
                    SELECT DISTINCT a.cagente, a.ctipage,
                                    pac_redcomercial.f_get_desnivel
                                                      (a.ctipage,
                                                       pac_md_common.f_get_cxtempresa,
                                                       pac_md_common.f_get_cxtidioma) ttipage,
                                    a.sperson, f_nombre(a.sperson, 1, NULL) tnombrecomp,
                                    NULL cempres, NULL tempres,
-- JGM - bug 11078 ponia null el cpadrefit pero esto hace petar la red comercial cuando el agente no est¿ incluido en la red
                                    NULL cpadre, -998 cpadrefit, NULL fmovini
                               FROM agentes a, per_detper p   -- BUG20208:DRA:21/11/2011
                              WHERE a.ctipage = NVL(ptipagente, a.ctipage)
                                AND(UPPER(p.tbuscar) LIKE '%' || UPPER(pnomagente) || '%'
                                    OR pnomagente IS NULL)
                                AND p.sperson = a.sperson
                                AND(a.cactivo = pactivo
                                    OR pactivo IS NULL)
                                AND a.cagente = NVL(pcagente, a.cagente)
                                AND a.cagente NOT IN(SELECT cagente
                                                       FROM redcomercial rr
                                                      WHERE rr.cagente = a.cagente)) rr
            UNION
            SELECT -999, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   f_axis_literales(103037, pac_md_common.f_get_cxtidioma), NULL, NULL
              FROM DUAL;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_arbolredcomercial;

   /*************************************************************************
   Funci¿n que recuperar¿ el agente seleccionado en el ¿rbol.
   Return: ob_iax_agentes
   *************************************************************************/
   FUNCTION f_get_agente(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_agentes IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_agente';
      agente         ob_iax_agentes;
      vnumerr        NUMBER := 0;
   BEGIN
      agente := ob_iax_agentes();

      -- Bug 19169 - APD - 16/09/2011 - Modificar la select de la tabla AGENTES,
      -- a¿adiendo en el from de la select la nueva tabla AGENTES_COMP, a¿adiendo los
      -- nuevos campos de la tabla AGENTES y AGENTES_COMP, guardando su valor en el
      -- objeto OB_IAX_AGENTES
      -- Bug 20999 - APD - 25/01/2012 - se a¿ade el campo ccomisi_indirect
      -- BUG 0021425 - 01/03/2012 - JMF
      SELECT a.cagente, cretenc, ctipiva, ccomisi, ctipage,
             cactivo, cbancar, ncolegi, fbajage, sperson,
             cdomici, a.csobrecomisi, a.talias, a.cliquido,
             ac.ctipadn, ac.cagedep, ac.ctipint, ac.cageclave,
             ac.cofermercan, ac.frecepcontra, ac.cidoneidad, ac.spercomp,
             ac.ccompani, ac.cofipropia, ac.cclasif, ac.nplanpago,
             ac.nnotaria, ac.cprovin, ac.cpoblac, ac.nescritura,
             ac.faltasoc, ac.tgerente, ac.tcamaracomercio,
             a.ccomisi_indirect, a.ctipmed, a.tnomcom, a.cdomcom,
             a.ctipretrib, a.cmotbaja, a.cbloqueo, a.nregdgs,
             a.finsdgs, a.crebcontdgs, ac.agrupador, ac.cactividad,
             ac.ctipoactiv, ac.pretencion, ac.cincidencia, ac.crating,
             ac.tvaloracion, ac.cresolucion, ac.ffincredito, ac.nlimcredito,
             ac.tcomentarios, a.coblccc, ac.fultrev, ac.fultckc,
             ac.ctipbang, ac.cbanges, ac.cclaneg, ac.ctipage_liquida,
             ac.iobjetivo, ac.ibonifica, ac.pcomextr, ac.ctipcal,
             ac.cforcal, ac.cmespag, ac.pcomextrov, ac.ppersisten,
             ac.pcompers, ac.ctipcalb, ac.cforcalb, ac.cmespagb,
             ac.pcombusi, ac.ilimiteb, a.ccodcon, a.claveinter,  -- TCS_1 - ACL - 16/01/2019
			 a.cdescriiva, a.descricretenc, a.descrifuente, a.cdescriica, -- -- TCS_1569B - ACL - 01/02/2019
             ac.cexpide
             --AAC_INI-CONF_379-20160927
             ,ac.corteprod
             --AAC_FI-CONF_379-20160927
        INTO agente.cagente, agente.cretenc, agente.ctipiva, agente.ccomisi, agente.ctipage,
             agente.cactivo, agente.cbancar, agente.ncolegi, agente.fbajage, agente.sperson,
             agente.cdomici, agente.csobrecomisi, agente.talias, agente.cliquido,
             agente.ctipadn, agente.cagedep, agente.ctipint, agente.cageclave,
             agente.cofermercan, agente.frecepcontra, agente.cidoneidad, agente.spercomp,
             agente.ccompani, agente.cofipropia, agente.cclasif, agente.nplanpago,
             agente.nnotaria, agente.cprovin, agente.cpoblac, agente.nescritura,
             agente.faltasoc, agente.tgerente, agente.tcamaracomercio,
             agente.ccomisi_indirect, agente.ctipmed, agente.tnomcom, agente.cdomcom,
             agente.ctipretrib, agente.cmotbaja, agente.cbloqueo, agente.nregdgs,
             agente.finsdgs, agente.crebcontdgs, agente.agrupador, agente.cactividad,
             agente.ctipoactiv, agente.pretencion, agente.cincidencia, agente.crating,
             agente.tvaloracion, agente.cresolucion, agente.ffincredito, agente.nlimcredito,
             agente.tcomentarios, agente.coblccc, agente.fultrev, agente.fultckc,
             agente.ctipbang, agente.cbanges, agente.cclaneg, agente.ctipage_liquida,
             agente.iobjetivo, agente.ibonifica, agente.pcomextr, agente.ctipcal,
             agente.cforcal, agente.cmespag, agente.pcomextrov, agente.ppersisten,
             agente.pcompers, agente.ctipcalb, agente.cforcalb, agente.cmespagb,
             agente.pcombusi, agente.ilimiteb, agente.ccodcon, agente.claveinter,   -- TCS_1 - ACL - 16/01/2019
			 agente.cdescriiva, agente.descricretenc, agente.descrifuente, agente.cdescriica, -- -- TCS_1569B - ACL - 01/02/2019
             agente.cexpide   -- BUG 31489 - FAL - 21/05/2014
             --AAC_INI-CONF_379-20160927
             ,agente.corteprod
             --AAC_FI-CONF_379-20160927
        FROM agentes a, agentes_comp ac
       WHERE a.cagente = pcagente
         AND a.cagente = ac.cagente(+);

      -- fin Bug 20999 - APD - 25/01/2012
      -- Fin Bug 19169 - APD - 16/09/2011
      -- fin BUG 0021425 - 01/03/2012 - JMF
      vpasexec := 2;
      -- Recuperamos descripcion del codigo del cactivo
      agente.tactivo := pac_md_listvalores.f_getdescripvalores(31, agente.cactivo, mensajes);
      vpasexec := 3;
      -- Recuperamos descripcion del codigo del ctipage
      agente.tctipage := pac_redcomercial.f_get_desnivel(agente.ctipage,
                                                         pac_md_common.f_get_cxtempresa,
                                                         pac_md_common.f_get_cxtidioma);
      vpasexec := 4;

      -- Recuperamos la descripcion de la comision
      IF agente.ccomisi IS NOT NULL THEN
         -- Mantis 10340.#6.ini.01/06/2009.NMM.0010340: IAX - No se ven los datos del agente en otros idiomas.
         -- Si no es troba la descripci¿ de la comissi¿ que no peti.
         BEGIN
            SELECT tcomisi
              INTO agente.tcomisi
              FROM descomision
             WHERE ccomisi = agente.ccomisi
               AND cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      -- Mantis 10340.#6.fi.
      END IF;

      vpasexec := 5;

      -- Recuperamos las descripcion del tipo de iva
      -- 29.0 INICIO RABQ
        IF agente.ctipiva IS NOT NULL THEN BEGIN
          SELECT 
            ttipiva 
          INTO
            agente.ttipiva
          FROM
             descripcioniva
          WHERE
            ctipiva = agente.ctipiva
            AND cidioma = pac_md_common.f_get_cxtidioma;
          EXCEPTION 
          WHEN OTHERS THEN 
            NULL;
          END;
        
        END IF;
        
      -- 29.0 FIN RABQ
      vpasexec := 6;

      -- Recuperamos la descripcion del tipo de retencion
      IF agente.cretenc IS NOT NULL THEN
         SELECT ttipret
           INTO agente.tretenc
           FROM descripcionret
          WHERE cretenc = agente.cretenc
            AND cidioma = pac_md_common.f_get_cxtidioma;
      END IF;

      vpasexec := 7;
      -- Recuperamos el nombre y el nif del agente
      agente.nnif := ff_buscanif(agente.sperson);
      agente.tnombre := f_nombre(agente.sperson, 1);
      vpasexec := 8;

      -- Bug 19169 - APD - 16/09/2011
      -- Recuperamos la descripcion de la comision
      IF agente.csobrecomisi IS NOT NULL THEN
         -- Mantis 10340.#6.ini.01/06/2009.NMM.0010340: IAX - No se ven los datos del agente en otros idiomas.
         -- Si no es troba la descripci¿ de la sobrecomissi¿ que no peti.
         BEGIN
            SELECT tcomisi
              INTO agente.tsobrecomisi
              FROM descomision
             WHERE ccomisi = agente.csobrecomisi
               AND cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      -- Mantis 10340.#6.fi.
      END IF;

      vpasexec := 9;

      -- Bug 19169 - APD - 16/09/2011
      -- Recuperamos descripcion del Tipo de ADN
      IF agente.ctipadn IS NOT NULL THEN
         agente.ttipadn := pac_md_listvalores.f_getdescripvalores(370, agente.ctipadn,
                                                                  mensajes);
      ELSE
         agente.ttipadn := NULL;
      END IF;

      vpasexec := 10;

      -- Bug 19169 - APD - 16/09/2011
      -- Recuperamos descripcion del Tipo de Intermediario
      IF agente.ctipint IS NOT NULL THEN
         agente.ttipint := pac_md_listvalores.f_getdescripvalores(371, agente.ctipint,
                                                                  mensajes);
      ELSE
         agente.ttipint := NULL;
      END IF;

      vpasexec := 11;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿n de si el Intermediario tiene autorizaci¿n para desconectarse, detener, directamente las comisiones
      IF agente.cliquido IS NOT NULL THEN
         agente.tliquido := pac_md_listvalores.f_getdescripvalores(372, agente.cliquido,
                                                                   mensajes);
      ELSE
         agente.tliquido := NULL;
      END IF;

      vpasexec := 12;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿n de si cumple o no con los requisitos de capacitaci¿n para ser Intermediario
      IF agente.cidoneidad IS NOT NULL THEN
         agente.tidoneidad := pac_md_listvalores.f_getdescripvalores(373, agente.cidoneidad,
                                                                     mensajes);
      ELSE
         agente.tidoneidad := NULL;
      END IF;

      vpasexec := 13;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿n de Clientes ¿nicos identificados como compa¿¿as
      IF agente.ccompani IS NOT NULL THEN
         BEGIN
            SELECT tcompani
              INTO agente.tcompani
              FROM companias
             WHERE ccompani = agente.ccompani;
         EXCEPTION
            WHEN OTHERS THEN
               agente.tcompani := NULL;
         END;
      ELSE
         agente.tcompani := NULL;
      END IF;

      vpasexec := 14;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿n de si el Intermediario tiene oficina propia
      IF agente.cofipropia IS NOT NULL THEN
         agente.tofipropia := pac_md_listvalores.f_getdescripvalores(374, agente.cofipropia,
                                                                     mensajes);
      ELSE
         agente.tofipropia := NULL;
      END IF;

      vpasexec := 15;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿n de la clasificaci¿n del Intermediario
      IF agente.cclasif IS NOT NULL THEN
         agente.tclasif := pac_md_listvalores.f_getdescripvalores(375, agente.cclasif,
                                                                  mensajes);
      ELSE
         agente.tclasif := NULL;
      END IF;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿n de la provincia de la ciudad de notaria
      IF agente.cprovin IS NOT NULL THEN
         agente.tprovin := f_desprovin2(agente.cprovin, NULL);
      ELSE
         agente.tprovin := NULL;
      END IF;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿n de la poblacion de la ciudad de notaria
      IF agente.cpoblac IS NOT NULL THEN
         agente.tpoblac := f_despoblac2(agente.cpoblac, agente.cprovin);
      ELSE
         agente.tpoblac := NULL;
      END IF;

      vpasexec := 16;

      -- Bug 19169 - APD - 16/09/2011
      -- Los campos FINIVIGCOM, FINIVIGSOBRECOM y FFINVIGSOBRECOM del objeto OB_IAX_AGENTES se obtienen de la select:
      BEGIN
         -- Bug 20999 - APD - 26/01/2012 - se a¿ade la condicion ccomind = 0.-Comision NO indirecta
         SELECT finivig, ffinvig
           INTO agente.finivigcom, agente.ffinvigcom
           FROM comisionvig_agente ca
          WHERE cagente = agente.cagente
            AND ccomisi = agente.ccomisi
            AND ffinvig IS NULL
            AND ccomind = 0;
      -- fin Bug 20999 - APD - 26/01/2012
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vpasexec := 17;

      BEGIN
         -- Bug 20999 - APD - 26/01/2012 - se a¿ade la condicion ccomind = 0.-Comision NO indirecta
         SELECT finivig, ffinvig
           INTO agente.finivigsobrecom, agente.ffinvigsobrecom
           FROM comisionvig_agente ca
          WHERE cagente = agente.cagente
            AND ccomisi = agente.csobrecomisi
            AND finivig = (SELECT MAX(finivig)
                             FROM comisionvig_agente ca1
                            WHERE ca1.cagente = ca.cagente
                              AND ca1.ccomisi = ca.ccomisi)
            AND ccomind = 0;
      -- fin Bug 20999 - APD - 26/01/2012
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vpasexec := 20;

      -- Bug 19169 - APD - 16/11/2011
      -- Nombre agente ADN de la cual depente. Obligatorio si CTIPADN es 'ADN dependiente de otra ADN'
      IF agente.cagedep IS NOT NULL THEN
         agente.tagedep := pac_redcomercial.ff_desagente(agente.cagedep,
                                                         pac_md_common.f_get_cxtidioma, 1);
      END IF;

      vpasexec := 25;

      -- Bug 19169 - APD - 16/11/2011
      -- Nombre del agente agrupador de otras claves de Intermediarios
      IF agente.cageclave IS NOT NULL THEN
         agente.tageclave := pac_redcomercial.ff_desagente(agente.cageclave,
                                                           pac_md_common.f_get_cxtidioma, 1);
      END IF;

      vpasexec := 30;

      -- Bug 20999 - APD - 25/01/2012
      -- Recuperamos la descripcion de la comision indirecta
      IF agente.ccomisi_indirect IS NOT NULL THEN
         BEGIN
            SELECT tcomisi
              INTO agente.tcomisi_indirect
              FROM descomision
             WHERE ccomisi = agente.ccomisi_indirect
               AND cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      vpasexec := 35;

      -- El campo FINIVIGCOM_INDIRECT del objeto OB_IAX_AGENTES se obtienen de la select:
      BEGIN
         -- Bug 20999 - APD - 26/01/2012 - se a¿ade la condicion ccomind = 1.-Comision SI indirecta
         SELECT finivig, ffinvig
           INTO agente.finivigcom_indirect, agente.ffinvigcom_indirect
           FROM comisionvig_agente
          WHERE cagente = agente.cagente
            AND ccomisi = agente.ccomisi_indirect
            AND ffinvig IS NULL
            AND ccomind = 1;
      -- fin Bug 20999 - APD - 26/01/2012
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- fin Bug 20999 - APD - 25/01/2012

      -- ini bug 0021425 - 01/03/2012 - JMF
      IF agente.ctipmed IS NOT NULL THEN
         vpasexec := 40;
         agente.ttipmed := pac_md_listvalores.f_getdescripvalores(1062, agente.ctipmed,
                                                                  mensajes);
      END IF;

      IF agente.cdomcom IS NOT NULL THEN
         vpasexec := 45;

         DECLARE
            retval         NUMBER;
            pctipo         NUMBER;
            ps1            NUMBER;
            ps2            NUMBER;
            pcformat       NUMBER;
            ptlin1         VARCHAR2(200);
            ptlin2         VARCHAR2(200);
            ptlin3         VARCHAR2(200);
         BEGIN
            pctipo := 1;
            ps1 := agente.sperson;
            ps2 := agente.cdomcom;
            pcformat := 2;
            ptlin1 := NULL;
            ptlin2 := NULL;
            ptlin3 := NULL;
            retval := f_direccion(pctipo, ps1, ps2, pcformat, ptlin1, ptlin2, ptlin3);

            IF retval = 0 THEN
               agente.tdomcom := ptlin1;
            ELSE
               agente.tdomcom := NULL;
            END IF;
         END;
      END IF;

      IF agente.ctipretrib IS NOT NULL THEN
         vpasexec := 50;
         agente.ttipretrib := pac_md_listvalores.f_getdescripvalores(1063, agente.ctipretrib,
                                                                     mensajes);
      END IF;

      IF agente.cmotbaja IS NOT NULL THEN
         vpasexec := 52;
         agente.tmotbaja := pac_md_listvalores.f_getdescripvalores(1066, agente.cmotbaja,
                                                                   mensajes);
      END IF;

      IF agente.cbloqueo IS NOT NULL THEN
         vpasexec := 54;
         agente.tbloqueo := pac_md_listvalores.f_getdescripvalores(1067, agente.cbloqueo,
                                                                   mensajes);
      END IF;

      IF agente.agrupador IS NOT NULL THEN
         vpasexec := 56;
         agente.tagrupador := pac_md_listvalores.f_getdescripvalores(1064, agente.agrupador,
                                                                     mensajes);
      END IF;

      IF agente.cactividad IS NOT NULL THEN
         vpasexec := 58;
         agente.tactividad := pac_md_listvalores.f_getdescripvalores(1065, agente.cactividad,
                                                                     mensajes);
      END IF;

      IF agente.ctipoactiv IS NOT NULL THEN
         vpasexec := 60;
         agente.ttipoactiv := pac_md_listvalores.f_getdescripvalores(1068, agente.ctipoactiv,
                                                                     mensajes);
      END IF;

      IF agente.cincidencia IS NOT NULL THEN
         vpasexec := 62;
         agente.tincidencia := pac_md_listvalores.f_getdescripvalores(1069,
                                                                      agente.cincidencia,
                                                                      mensajes);
      END IF;

      IF agente.crating IS NOT NULL THEN
         vpasexec := 64;
         agente.trating := pac_md_listvalores.f_getdescripvalores(1070, agente.crating,
                                                                  mensajes);
      END IF;

      IF agente.cresolucion IS NOT NULL THEN
         vpasexec := 66;
         agente.tresolucion := pac_md_listvalores.f_getdescripvalores(1071,
                                                                      agente.cresolucion,
                                                                      mensajes);
      END IF;

      IF agente.cagente IS NOT NULL THEN
         vpasexec := 69;
         vnumerr := pac_md_age_datos.f_get_bancos(agente.cagente, agente.bancos, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF agente.cagente IS NOT NULL THEN
         vpasexec := 72;
         vnumerr := pac_md_age_datos.f_get_entidadesaseg(agente.cagente, agente.entidadesaseg,
                                                         mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF agente.cagente IS NOT NULL THEN
         vpasexec := 74;
         vnumerr := pac_md_age_datos.f_get_asociaciones(agente.cagente, agente.asociaciones,
                                                        mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF agente.cagente IS NOT NULL THEN
         vpasexec := 76;
         vnumerr := pac_md_age_datos.f_get_referencias(agente.cagente, agente.referencias,
                                                       mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      -- fin bug 0021425 - 01/03/2012 - JMF
      RETURN agente;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_agente;

   /*************************************************************************
   Funci¿n que recuperar¿ la informaci¿n de los contratos asociados al agente
   Return: ob_iax_contratos
   *************************************************************************/
   FUNCTION f_get_contrato(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contratos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_contrato';
      contratos      t_iax_contratos;
   BEGIN
      contratos := t_iax_contratos();

      FOR cur IN (SELECT cempres, ncontrato, ffircon
                    FROM contratosage
                   WHERE cagente = pcagente) LOOP
         contratos.EXTEND;
         contratos(contratos.LAST) := ob_iax_contratos();

         SELECT tempres
           INTO contratos(contratos.LAST).tempres
           FROM empresas
          WHERE cempres = cur.cempres;

         contratos(contratos.LAST).cempres := cur.cempres;
         contratos(contratos.LAST).cagente := pcagente;
         contratos(contratos.LAST).ncontrato := cur.ncontrato;
         contratos(contratos.LAST).ffircon := cur.ffircon;
      END LOOP;

      RETURN contratos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_contrato;

   /*************************************************************************
    Funci¿n que cargar los objetos de agentes y contratos
    Return: number
   *************************************************************************/
   FUNCTION f_get_datosagente(
      pcagente IN NUMBER,
      contratos OUT t_iax_contratos,
      agente OUT ob_iax_agentes,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_datosagente';
   BEGIN
      agente := f_get_agente(pcagente, mensajes);

      IF agente IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000503);
         RAISE e_object_error;
      END IF;

      -- Bug 19169 - APD - 16/09/2011
      -- se obtienen los valores del t_iax_soportearp_agente
      agente.soportearp := pac_md_redcomercial.f_get_soportearp(pcagente, mensajes);
      -- se obtienen los valores del t_iax_prodparticipacion_agente
      agente.prodparticipacion := pac_md_redcomercial.f_get_prodparticipacion(pcagente,
                                                                              mensajes);
      -- se obtienen los valores del t_iax_subvencion_agente
      agente.subvencion := pac_md_redcomercial.f_get_subvencion(pcagente, mensajes);
      -- Fin Bug 19169 - APD - 16/09/2011
      vpasexec := 2;
      contratos := f_get_contrato(pcagente, mensajes);

      IF agente IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000503);
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
   END f_get_datosagente;

    /*************************************************************************
     Funci¿n que recuperar¿ la informaci¿n de la red comercial asociado al agente
     Return: t_iax_redcomercial
   *************************************************************************/
   FUNCTION f_get_redcomercial(
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_redcomercial IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ' pcempres:' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_redcomercial';
      redcomercial   t_iax_redcomercial;
   BEGIN
      redcomercial := t_iax_redcomercial();

      -- Bug 18946 - APD - 09/11/2011 - se a¿aden los campos de vision por poliza
      -- cpolvisio, tpolvisio, cpolnivel, tpolnivel
      FOR cur IN (SELECT   r.fmovini, r.fmovfin, r.ctipage, r.cpadre, a.sperson, r.cpervisio,
                           f_desagente_t(r.cpervisio) AS tpervisio, r.cpernivel,
                           ff_desvalorfijo(600, pac_md_common.f_get_cxtidioma,
                                           r.cpernivel) AS tpernivel,
                           r.cageind,   -- Bug : 19586 - 20/10/2011 - JMC
                                     f_desagente_t(r.cageind) AS tageind,
                                                                         -- Bug : 19586 - 20/10/2011 - JMC
                                                                         r.cpolvisio,
                           f_desagente_t(r.cpolvisio) AS tpolvisio, r.cpolnivel,
                           ff_desvalorfijo(600, pac_md_common.f_get_cxtidioma,
                                           r.cpolnivel) AS tpolnivel,
                           r.cenlace, f_desagente_t(r.cenlace) tenlace
                      FROM redcomercial r, agentes a
                     WHERE r.cagente = pcagente
                       AND(pcempres IS NULL
                           OR cempres = pcempres)
                       AND r.cpadre = a.cagente(+)
                  ORDER BY r.fmovini DESC) LOOP
         redcomercial.EXTEND;
         redcomercial(redcomercial.LAST) := ob_iax_redcomercial();
         redcomercial(redcomercial.LAST).cempres := pcempres;
         redcomercial(redcomercial.LAST).cagente := pcagente;
         redcomercial(redcomercial.LAST).fmovini := cur.fmovini;
         redcomercial(redcomercial.LAST).fmovfin := cur.fmovfin;
         redcomercial(redcomercial.LAST).ctipage := cur.ctipage;
         redcomercial(redcomercial.LAST).cpadre := cur.cpadre;
         redcomercial(redcomercial.LAST).cpervisio := cur.cpervisio;
         redcomercial(redcomercial.LAST).tpervisio := cur.tpervisio;
         redcomercial(redcomercial.LAST).cpernivel := cur.cpernivel;
         redcomercial(redcomercial.LAST).tpernivel := cur.tpernivel;
         redcomercial(redcomercial.LAST).cenlace := cur.cenlace;
         redcomercial(redcomercial.LAST).tenlace := cur.tenlace;
         vpasexec := 2;
         -- Recuperamos el nombre del padre
         redcomercial(redcomercial.LAST).tpadre := f_nombre(cur.sperson, 1);
         vpasexec := 3;
         -- Recuperamos descripcion del codigo del ctipage
         redcomercial(redcomercial.LAST).tctipage :=
            pac_redcomercial.f_get_desnivel(cur.ctipage, pcempres,
                                            pac_md_common.f_get_cxtidioma);
         -- Ini Bug : 19586 - 20/10/2011 - JMC
         vpasexec := 4;
         redcomercial(redcomercial.LAST).cageind := cur.cageind;
         redcomercial(redcomercial.LAST).tageind := cur.tageind;
         -- Fin Bug : 19586 - 20/10/2011 - JMC
            -- Bug 18946 - APD - 09/11/2011 - se a¿aden los campos de vision por poliza
         redcomercial(redcomercial.LAST).cpolvisio := cur.cpolvisio;
         redcomercial(redcomercial.LAST).tpolvisio := cur.tpolvisio;
         redcomercial(redcomercial.LAST).cpolnivel := cur.cpolnivel;
         redcomercial(redcomercial.LAST).tpolnivel := cur.tpolnivel;
      -- fin Bug 18946 - APD - 09/11/2011
      END LOOP;

      vpasexec := 4;
      RETURN redcomercial;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_redcomercial;

   /*************************************************************************
       f_set_agente_compe
         -- Bug 27949 Funci¿¿n modificada para crear f_set_agentes_comp
    *************************************************************************/
   FUNCTION f_set_agente(
      pcagente IN agentes.cagente%TYPE,
      pcretenc IN agentes.cretenc%TYPE,
      pctipiva IN agentes.ctipiva%TYPE,
      psperson IN agentes.sperson%TYPE,
      pccomisi IN agentes.ccomisi%TYPE,
      pcdesc IN NUMBER,
      pctipage IN agentes.ctipage%TYPE,
      pcactivo IN agentes.cactivo%TYPE,
      pcdomici IN agentes.cdomici%TYPE,
      pcbancar IN agentes.cbancar%TYPE,
      pncolegi IN agentes.ncolegi%TYPE,
      pfbajage IN agentes.fbajage%TYPE,
      pctipban IN agentes.ctipban%TYPE,
      pfinivigcom IN DATE,
      pffinvigcom IN DATE,
      pfinivigdesc IN DATE,
      pffinvigdesc IN DATE,
      pcsobrecomisi IN agentes.csobrecomisi%TYPE,
      pfinivigsobrecom IN DATE,
      pffinvigsobrecom IN DATE,
      ptalias IN agentes.talias%TYPE,
      pcliquido IN agentes.cliquido%TYPE,
      pccomisi_indirect IN agentes.ccomisi_indirect%TYPE,
      -- Bug 20999 - APD - 25/01/2012
      pfinivigcom_indirect IN DATE,   -- Bug 20999 - APD - 25/01/2012
      pffinvigcom_indirect IN DATE,
      -- bug 21425/109832 - 21/03/2012 - AMC
      pctipmed IN agentes.ctipmed%TYPE,
      ptnomcom IN agentes.tnomcom%TYPE,
      pcdomcom IN agentes.cdomcom%TYPE,
      pctipretrib IN agentes.ctipretrib%TYPE,
      pcmotbaja IN agentes.cmotbaja%TYPE,
      pcbloqueo IN agentes.cbloqueo%TYPE,
      pnregdgs IN agentes.nregdgs%TYPE,
      pfinsdgs IN agentes.finsdgs%TYPE,
      pcrebcontdgs IN agentes.crebcontdgs%TYPE,
      pcoblccc IN NUMBER,
      pccodcon IN agentes.ccodcon%TYPE,
	  pclaveinter IN  agentes.claveinter%TYPE,  -- TCS_1 - 15/01/2019 - ACL
	  pcdescriiva  IN  agentes.cdescriiva%TYPE,	-- TCS_1569B - ACL - 01/02/2019
      pdescricretenc IN  agentes.descricretenc%TYPE,	-- TCS_1569B - ACL - 01/02/2019
      pdescrifuente  IN  agentes.descrifuente%TYPE,	-- TCS_1569B - ACL - 01/02/2019
      pcdescriica IN  agentes.cdescriica%TYPE,	-- TCS_1569B - ACL - 01/02/2019
      pctipint IN agentes_comp.ctipint%TYPE,
      -- fin bug 21425/109832 - 21/03/2012 - AMC
      --BUG 41764-233736
      pmodifica IN NUMBER,
      pcagente_out IN OUT agentes.cagente%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_agente';
      verror         NUMBER;
      v_mensaje      VARCHAR2(2000);
      v_idioma       NUMBER;
      v_pcempres     NUMBER;
   BEGIN
       -- Bug 19169 - APD - 19/11/2011 - no se valida que el pcagente ya
       -- que en funcion del PARINSTALACION 'CODAGENTEAUT' se obtendr¿¿
       -- autom¿¿ticamente el valor del codigo del agente
/*
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
       -- Fin Bug 19169 - APD - 19/11/2011
      /*      if pac_redcomercial.f_valida_agente(pcagente) != 0 then

               verror := 153013;
            else
      */

      -- Bug 21682 - APD - 25/04/2012
      verror := pac_redcomercial.f_valida_estado(pac_md_common.f_get_cxtempresa, pcagente,
                                                 pctipage, pcactivo, pctipmed, pnregdgs);

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      -- fin Bug 21682 - APD - 25/04/2012


      -- Bug 27598 - ICG - 29/01/2013
      v_idioma := pac_md_common.f_get_cxtidioma();
      verror := pac_redcomercial.f_valida_regfiscal(pac_md_common.f_get_cxtempresa, v_idioma,
                                                    psperson, pctipage, pctipiva, pctipint,
                                                    v_mensaje);

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror, v_mensaje);
         RAISE e_object_error;
      END IF;

      --  Fin Bug 27598 - ICG - 29/01/2013

      -- Bug 19169 - APD - 16/09/2011 - se a¿aden los nuevos campos de la tabla agentes y agentes_comp
      verror := pac_redcomercial.f_set_agente(pcagente, pcretenc, pctipiva, psperson, pccomisi,
                                              pcdesc, pctipage, pcactivo, pcdomici, pcbancar,
                                              pncolegi, pfbajage, pctipban, pfinivigcom,
                                              pffinvigcom, pfinivigdesc, pffinvigdesc,
                                              pcsobrecomisi, pfinivigsobrecom,
                                              pffinvigsobrecom, ptalias, pcliquido,
                                              pccomisi_indirect, pfinivigcom_indirect,
                                              pffinvigcom_indirect,
                                              -- bug 21425/109832 - 21/03/2012 - AMC
                                              pctipmed, ptnomcom, pcdomcom, pctipretrib,
                                              pcmotbaja, pcbloqueo, pnregdgs, pfinsdgs,
                                              pcrebcontdgs, pcoblccc, pccodcon, pclaveinter,  -- TCS_1 - 15/01/2019 - ACL
											  pcdescriiva, pdescricretenc, pdescrifuente, pcdescriica,    -- TCS_1569B - ACL - 01/02/2019
											  pmodifica,
                                              -- Fi bug 21425/109832 - 21/03/2012 - AMC
                                              pcagente_out);
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      ELSE
         --Bug.: 14470 - ICV - 11/05/2010
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9906396);
      --Los datos del agente se han grabado correctamente
      END IF;

      --      end if;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_agente;

   /*************************************************************************
       f_set_agente_comp
         -- Bug 27949 Funci¿¿n creada a partir de f_set_agente
    *************************************************************************/
   FUNCTION f_set_agente_comp(
      pcagente IN agentes_comp.cagente%TYPE,
      pctipadn IN agentes_comp.ctipadn%TYPE,
      pcagedep IN agentes_comp.cagedep%TYPE,
      pctipint IN agentes_comp.ctipint%TYPE,
      pcageclave IN agentes_comp.cageclave%TYPE,
      pcofermercan IN agentes_comp.cofermercan%TYPE,
      pfrecepcontra IN agentes_comp.frecepcontra%TYPE,
      pcidoneidad IN agentes_comp.cidoneidad%TYPE,
      pccompani IN agentes_comp.ccompani%TYPE,
      pcofipropia IN agentes_comp.cofipropia%TYPE,
      pcclasif IN agentes_comp.cclasif%TYPE,
      pnplanpago IN agentes_comp.nplanpago%TYPE,
      pnnotaria IN agentes_comp.nnotaria%TYPE,
      pcprovin IN agentes_comp.cprovin%TYPE,
      pcpoblac IN agentes_comp.cpoblac%TYPE,
      pnescritura IN agentes_comp.nescritura%TYPE,
      pfaltasoc IN agentes_comp.faltasoc%TYPE,
      ptgerente IN agentes_comp.tgerente%TYPE,
      ptcamaracomercio IN agentes_comp.tcamaracomercio%TYPE,
      pagrupador IN agentes_comp.agrupador%TYPE,
      pcactividad IN agentes_comp.cactividad%TYPE,
      pctipoactiv IN agentes_comp.ctipoactiv%TYPE,
      ppretencion IN agentes_comp.pretencion%TYPE,
      pcincidencia IN agentes_comp.cincidencia%TYPE,
      pcrating IN agentes_comp.crating%TYPE,
      ptvaloracion IN agentes_comp.tvaloracion%TYPE,
      pcresolucion IN agentes_comp.cresolucion%TYPE,
      pffincredito IN agentes_comp.ffincredito%TYPE,
      pnlimcredito IN agentes_comp.nlimcredito%TYPE,
      ptcomentarios IN agentes_comp.tcomentarios%TYPE,
      --nuevos campos
      pfultrev IN agentes_comp.fultrev%TYPE,
      pfultckc IN agentes_comp.fultckc%TYPE,
      pctipbang IN agentes_comp.ctipbang%TYPE,
      pcbanges IN agentes_comp.cbanges%TYPE,
      pcclaneg IN agentes_comp.cclaneg%TYPE,
      pctipage_liquida IN agentes_comp.ctipage_liquida%TYPE,
                                               -- BUG 31489 - FAL - 21/05/2014
      --
      piobjetivo IN agentes_comp.iobjetivo%TYPE,
      pibonifica IN agentes_comp.ibonifica%TYPE,
      ppcomextr IN agentes_comp.pcomextr%TYPE,
      pctipcal IN agentes_comp.ctipcal%TYPE,
      pcforcal IN agentes_comp.cforcal%TYPE,
      pcmespag IN agentes_comp.cmespag%TYPE,
      ppcomextrov IN agentes_comp.pcomextrov%TYPE,
      pppersisten IN agentes_comp.ppersisten%TYPE,
      ppcompers IN agentes_comp.pcompers%TYPE,
      pctipcalb IN agentes_comp.ctipcalb%TYPE,
      pcforcalb IN agentes_comp.cforcalb%TYPE,
      pcmespagb IN agentes_comp.cmespagb%TYPE,
      ppcombusi IN agentes_comp.pcombusi%TYPE,
      pilimiteb IN agentes_comp.ilimiteb%TYPE,
      pccexpide IN agentes_comp.cexpide%TYPE,
      --AAC_INI-CONF_379-20160927
      pcorteprod in number,
      --AAC_FI-CONF_379-20160927
      pcagente_out OUT agentes_comp.cagente%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_agente_comp';
      verror         NUMBER;
   BEGIN
      verror := pac_redcomercial.f_set_agente_comp(pcagente, pctipadn, pcagedep, pctipint,
                                                   pcageclave, pcofermercan, pfrecepcontra,
                                                   pcidoneidad, pccompani, pcofipropia,
                                                   pcclasif, pnplanpago, pnnotaria, pcprovin,
                                                   pcpoblac, pnescritura, pfaltasoc,
                                                   ptgerente, ptcamaracomercio, pagrupador,
                                                   pcactividad, pctipoactiv, ppretencion,
                                                   pcincidencia, pcrating, ptvaloracion,
                                                   pcresolucion, pffincredito, pnlimcredito,
                                                   ptcomentarios, pfultrev, pfultckc,
                                                   pctipbang, pcbanges, pcclaneg,
                                                   pctipage_liquida, piobjetivo, pibonifica,
                                                   ppcomextr, pctipcal, pcforcal, pcmespag,
                                                   ppcomextrov, pppersisten, ppcompers,
                                                   pctipcalb, pcforcalb, pcmespagb, ppcombusi,
                                                   pilimiteb, pccexpide
                                                   --AAC_INI-CONF_379-20160927
                                                  ,pcorteprod
                                                  --AAC_FI-CONF_379-20160927
                                                   );   -- BUG 31489 - FAL - 21/05/2014
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      ELSE
         --Bug.: 14470 - ICV - 11/05/2010
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9906397);
      --Les dades complementaries del agent s''han grabat correctament
      END IF;

      --      end if;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_agente_comp;

   FUNCTION f_set_contrato(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pncontrato IN NUMBER,
      pffircon IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcempres:' || pcempres || ', pcagente:' || pcagente || ', pncontrato:'
            || pncontrato || ', pffircon:' || TO_CHAR(pffircon, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_contrato';
      verror         NUMBER;
   BEGIN
      verror := pac_redcomercial.f_set_contrato(pcempres, pcagente, pncontrato, pffircon);
      vpasexec := 2;

      IF verror != 0 THEN
         --PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_contrato;

      -- Bug 18946 - APD - 16/11/2011 - se a¿aden los campos de vision por poliza
      -- cpolvisio, cpolnivel
/*************************************************************************
      Inserta la redcomercial
      param in pcempres  : c¿digo de la empresa
      param in pcagente  : c¿digo del agente
      param in pfecha    : fecha
      param in pcpadre   : codigo del padre
      param in pccomindt :
      param in pcprevisio : C¿digo del agente que nos indica el nivel de visi¿n de personas
      param in pcprenivel : Nivel visi¿n personas
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_redcomercial(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecha IN DATE,
      pcpadre IN NUMBER,
      pccomindt IN NUMBER,
      pcprevisio IN NUMBER,
      pcprenivel IN NUMBER,
      pcageind IN NUMBER,   -- Bug : 19586 - 20/10/2011 - JMC
      pcpolvisio IN NUMBER,
      pcpolnivel IN NUMBER,
      pcenlace IN NUMBER,   --Bug 21672 - JTS - 29/05/2012
      pcdomiciage IN NUMBER, --TCS-7 21/02/2018 AP -- IAXIS-2415 27/02/2019
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcempres:' || pcempres || ', pcagente:' || pcagente || ', pfecha:'
            || TO_CHAR(pfecha, 'dd/mm/yyyy') || ', pcpadre:' || pcpadre || ', pccomindt:'
            || pccomindt || ', pcprevisio:' || pcprevisio || ', pcprenivel:' || pcprenivel
            || ', pcpolvisio:' || pcpolvisio || ', pcpolnivel:' || pcpolnivel|| ', pcdomiciage:' || pcdomiciage; -- IAXIS-2415 27/02/2019
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_redcomercial';
      verror         NUMBER;
      /*vcpoblac1      NUMBER; --TCS-7 21/02/2018 AP -- IAXIS-2415 27/02/2019
      vcprovin1      NUMBER; --TCS-7 21/02/2018 AP
      vcpoblac2      NUMBER; --TCS-7 21/02/2018 AP
      vcprovin2      NUMBER; --TCS-7 21/02/2018 AP*/ -- IAXIS-2415 27/02/2019
   BEGIN
      IF pcagente IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;
      -- Inicio IAXIS-2415 27/02/2019
	  -- Se comenta funcionalidad anterior por mejora
	  --INI TCS-7 21/02/2018 AP
      /*SELECT P.CPOBLAC, P.CPROVIN INTO VCPOBLAC1, VCPROVIN1 FROM AGENTES A, PER_DIRECCIONES P WHERE A.SPERSON = P.SPERSON AND A.CAGENTE = pcagente AND P.CDOMICI = pcdomici;
      SELECT P.CPOBLAC, P.CPROVIN INTO VCPOBLAC2, VCPROVIN2 FROM AGENTES A, PER_DIRECCIONES P WHERE A.SPERSON = P.SPERSON AND A.CAGENTE = pcpadre;

      IF VCPROVIN1 = VCPROVIN2 AND VCPOBLAC1 = VCPOBLAC2 THEN*/
      --FIN TCS-7 21/02/2018 AP
	  -- Fin IAXIS-2415 27/02/2019
      /*
      if pcpadre is not null and pac_redcomercial.f_valida_agente_redcom(pcpadre, pcempres) = 0 then
         verror :=104350;
      else
      */
      verror := pac_redcomercial.f_set_redcomercial(pcempres, pcagente, pfecha, pcpadre,
                                                    pccomindt, pcprevisio, pcprenivel,
                                                    pcageind, pcpolvisio, pcpolnivel, pcenlace, pcdomiciage); -- IAXIS-2415 27/02/2019
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;
      -- Inicio IAXIS-2415 27/02/2019
      /*ELSE  --INI TCS-7 21/02/2018 AP
                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89906227);
                RAISE e_object_error;
      END IF;*/ --FIN TCS-7 21/02/2018 AP
      -- Fin IAXIS-2415 27/02/2019
      --end if;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_redcomercial;

   /*************************************************************************
           Funci¿n que nos devolver¿ lista p¿liza de un agente Return: Sys_Refcursor

           Bug 22313/115161 - 23/05/2012 - AMC
       *************************************************************************/
   FUNCTION f_get_polagente(
      pempresa IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pcpolcia IN VARCHAR2,
      psseguro IN NUMBER,
      pnnumidetomador IN VARCHAR2,
      pspersontom IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0013392 - 23/03/2010 - JMF
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pempresa:' || pempresa || ' pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_polagente';
      cur            sys_refcursor;
      vwhere         VARCHAR2(2000);
      vquery         VARCHAR2(3000);
   BEGIN
      IF pempresa IS NULL
         OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pnpoliza IS NOT NULL THEN
         vwhere := vwhere || ' and s.npoliza =  ' || pnpoliza;
      END IF;

      IF pcpolcia IS NOT NULL THEN
         vwhere := vwhere || ' and s.cpolcia =  ' || CHR(39) || pcpolcia || CHR(39);
      END IF;

      IF psseguro IS NOT NULL THEN
         vwhere := vwhere || ' and s.sseguro =  ' || psseguro;
      END IF;

      IF pspersontom IS NOT NULL THEN
         vwhere := vwhere || ' and t.sperson =  ' || pspersontom;
      END IF;

      IF pnnumidetomador IS NOT NULL THEN
         --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'),
                0) = 1 THEN
            vwhere := vwhere || ' and UPPER(p.nnumide) = UPPER(''' || pnnumidetomador || ''')';
         ELSE
            vwhere := vwhere || ' and p.nnumide = ''' || pnnumidetomador || '''';
         END IF;
      END IF;

      --Bug 22313/115161 - 23/05/2012 - AMC
      IF pcramo IS NOT NULL THEN
         vwhere := vwhere || ' and s.cramo =  ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vwhere := vwhere || ' and s.sproduc =  ' || psproduc;
      END IF;

      --Fi Bug 22313/115161 - 23/05/2012 - AMC

      -- BUG19069:DRA:02/11/2011:Inici
      IF NVL(ff_es_correduria(pac_md_common.f_get_cxtempresa), 0) = 0 THEN
         --  OPEN cur FOR
              -- Ini bug 17126 - SRA - 29/12/2010: a¿adimos esta condici¿n para evitar duplicados en el resultado final si
              --                                   hay m¿s de un registro de detalle en PER_DETPER para diferentes agentes
         vquery :=
            ' SELECT DISTINCT s.npoliza||''-''||s.ncertif npoliza, f_nombre(pd.sperson, 2, pd.cagente) tnombre, '
            || ' pac_isqlfor.f_titulopro(s.sseguro) titpro, s.sseguro, '
            || ' pac_md_redcomercial.ff_formatoccc(s.cbancar) cuenta, s.cpolcia '
            || ' FROM seguros s, tomadores t, per_personas p, per_detper pd '
            || ' WHERE s.csituac = 0 AND s.cempres = ' || pempresa || ' AND s.cagente = '
            || pcagente || ' AND t.nordtom = (SELECT MIN(t1.nordtom) '
            || ' FROM tomadores t1 WHERE t1.sseguro = t.sseguro)'
            || ' AND t.sseguro = s.sseguro AND p.sperson = t.sperson'
            || ' AND(((s.ncertif = 0 AND 1 = NVL((SELECT cagente FROM prodherencia_colect WHERE sproduc = s.sproduc),1))) OR(0 = NVL((SELECT cagente FROM prodherencia_colect WHERE sproduc = s.sproduc),0)))'   -- BUG 0039419 - FAL - Recupera certificados si no hay herencia de agente
            --Bug 27549  19/09/2013  Para colectivos s¿lo mostrar Certificado 0
            || ' AND pd.sperson = p.sperson AND pd.cagente = ff_agente_cpervisio(s.cagente) '
            || ' AND pac_corretaje.f_tiene_corretaje (s.sseguro, NULL) = 0 ' || vwhere
            || ' UNION ALL '
            || ' SELECT DISTINCT s.npoliza||''-''||s.ncertif npoliza, f_nombre(pd.sperson, 2, pd.cagente) tnombre, '
            || ' pac_isqlfor.f_titulopro(s.sseguro) titpro, s.sseguro, '
            || ' pac_md_redcomercial.ff_formatoccc(s.cbancar) cuenta, s.cpolcia '
            || ' FROM seguros s, tomadores t, per_personas p, per_detper pd, age_corretaje c '
            || ' WHERE s.csituac = 0 AND s.cempres = ' || pempresa || ' AND c.cagente = '
            || pcagente || ' AND s.sseguro = c.sseguro '
            || ' AND t.nordtom = (SELECT MIN(t1.nordtom) '
            || ' FROM tomadores t1 WHERE t1.sseguro = t.sseguro) '
            || ' AND t.sseguro = s.sseguro AND p.sperson = t.sperson '
            || ' AND pd.sperson = p.sperson AND pd.cagente = ff_agente_cpervisio(s.cagente) '
            -- || ' AND s.ncertif = 0 '
            || ' AND(((s.ncertif = 0 AND 1 = NVL((SELECT cagente FROM prodherencia_colect WHERE sproduc = s.sproduc),1))) OR(0 = NVL((SELECT cagente FROM prodherencia_colect WHERE sproduc = s.sproduc),0)))'   -- BUG 0039419 - FAL - Recupera certificados si no hay herencia de agente
            --Bug 27549  19/09/2013  Para colectivos s¿lo mostrar Certificado 0
            || ' AND c.nmovimi = PAC_ISQLFOR_CONF.f_get_ultmov(s.sseguro,1) AND pac_corretaje.f_tiene_corretaje (s.sseguro, NULL) = 0 '
            || vwhere || ' ORDER BY 1';
         -- Fin bug 17126 - SRA - 29/12/2010
         p_tab_error(f_sysdate, f_user, 'f_get_polagente', 666, 'vquery:', vquery);
         cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      ELSE
            --para correduria no filtramos por nada XPL#0018834#17062011
         --   OPEN cur FOR
               -- Ini bug 17126 - SRA - 29/12/2010: a¿adimos esta condici¿n para evitar duplicados en el resultado final si
               --                                   hay m¿s de un registro de detalle en PER_DETPER para diferentes agentes
         vquery :=
            ' SELECT DISTINCT s.npoliza, f_nombre(pd.sperson, 2, pd.cagente) tnombre, '
            || ' pac_isqlfor.f_titulopro(s.sseguro) titpro, s.sseguro, '
            || ' pac_md_redcomercial.ff_formatoccc(s.cbancar) cuenta, s.cpolcia '
            || ' FROM seguros s, tomadores t, per_personas p, per_detper pd '
            || ' WHERE s.cempres = ' || pempresa || ' AND s.cagente = ' || pcagente
            || ' AND t.nordtom = (SELECT MIN(t1.nordtom) FROM tomadores t1 '
            || ' WHERE t1.sseguro = t.sseguro) AND t.sseguro = s.sseguro '
            || ' AND p.sperson = t.sperson AND pd.sperson = p.sperson '
            || ' AND pd.cagente = ff_agente_cpervisio(s.cagente) '
            || ' AND pac_corretaje.f_tiene_corretaje (s.sseguro, NULL) = 0 ' || vwhere
            || ' UNION ALL '
            || ' SELECT DISTINCT s.npoliza, f_nombre(pd.sperson, 2, pd.cagente) tnombre, '
            || ' pac_isqlfor.f_titulopro(s.sseguro) titpro, s.sseguro, '
            || ' pac_md_redcomercial.ff_formatoccc(s.cbancar) cuenta, s.cpolcia '
            || ' FROM seguros s, tomadores t, per_personas p, per_detper pd, age_corretaje c '
            || ' WHERE s.cempres = ' || pempresa || ' AND c.cagente = ' || pcagente
            || ' AND s.sseguro = c.sseguro AND t.nordtom = (SELECT MIN(t1.nordtom) '
            || ' FROM tomadores t1 WHERE t1.sseguro = t.sseguro)'
            || ' AND t.sseguro = s.sseguro AND p.sperson = t.sperson'
            || ' AND pd.sperson = p.sperson AND pd.cagente = ff_agente_cpervisio(s.cagente) '
            || ' AND c.nmovimi = PAC_ISQLFOR_CONF.f_get_ultmov(s.sseguro,1) AND pac_corretaje.f_tiene_corretaje (s.sseguro, NULL) = 0 '
            || vwhere || ' ORDER BY 1';
         cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      END IF;

      -- BUG19069:DRA:02/11/2011:Fi
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_polagente;

   FUNCTION ff_formatoccc(pcbancar IN VARCHAR2)
      RETURN VARCHAR2 IS
      ptsalida       VARCHAR2(200) := '';
      vnumerr        NUMBER;
   BEGIN
      IF pcbancar IS NOT NULL THEN
         vnumerr := f_formatoccc(pcbancar, ptsalida);
      END IF;

      RETURN ptsalida;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END;

   /*************************************************************************
           Funci¿n que nos devolver¿ lista recibos de un agente
           condicionada al estado del recibo (pendiente, gestion, etc).
           Return: Sys_Refcursor

            --Bug 22313/115161 - 23/05/2012 - AMC
       *************************************************************************/
   FUNCTION f_get_recagente(
      pempresa IN NUMBER,
      pcagente IN NUMBER,
      pcestrec IN NUMBER,
      pnpoliza IN NUMBER,
      pcpolcia IN VARCHAR2,
      pnrecibo IN NUMBER,
      pcreccia IN VARCHAR2,
      psseguro IN NUMBER,
      pnnumidetom IN VARCHAR2,
      pspersontom IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0013392 - 23/03/2010 - JMF
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
           := ' pempresa:' || pempresa || ' pcagente:' || pcagente || ' pcestrec:' || pcestrec;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_recagente';
      cur            sys_refcursor;
      d_fec          DATE;
      n_dia          NUMBER;
      vwhere         VARCHAR2(2000);
      vquery         VARCHAR2(3000);
      -- BUG 21044 - MDS - 24/01/2012
      v_tabla_detrecibos VARCHAR2(50);
      v_campo_icombru VARCHAR2(50);
   BEGIN
      IF pempresa IS NULL
         OR pcagente IS NULL
         OR pcestrec IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pnpoliza IS NOT NULL THEN
         vwhere := vwhere || ' and s.npoliza =  ' || pnpoliza;
      END IF;

      IF pcpolcia IS NOT NULL THEN
         vwhere := vwhere || ' and s.cpolcia =  ' || CHR(39) || pcpolcia || CHR(39);
      END IF;

      IF psseguro IS NOT NULL THEN
         vwhere := vwhere || ' and s.sseguro =  ' || psseguro;
      END IF;

      IF pspersontom IS NOT NULL THEN
         vwhere := vwhere || ' and t.sperson =  ' || pspersontom;
      END IF;

      IF pnnumidetom IS NOT NULL THEN
         --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'),
                0) = 1 THEN
            vwhere :=
               vwhere
               || ' AND t.sperson IN (SELECT p.sperson FROM per_personas p WHERE UPPER(p.nnumide) = UPPER('''
               || pnnumidetom || '''))';
         ELSE
            vwhere :=
               vwhere
               || ' AND t.sperson IN (SELECT p.sperson FROM per_personas p WHERE p.nnumide = '''
               || pnnumidetom || ''')';
         END IF;
      END IF;

      IF pnrecibo IS NOT NULL THEN
         vwhere := vwhere || ' AND r.nrecibo =  ' || pnrecibo;
      END IF;

      IF pcreccia IS NOT NULL THEN
         vwhere := vwhere || ' AND r.creccia =  ' || CHR(39) || pcreccia || CHR(39);
      END IF;

      --Bug 22313/115161 - 23/05/2012 - AMC
      IF pcramo IS NOT NULL THEN
         vwhere := vwhere || ' and s.cramo =  ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vwhere := vwhere || ' and s.sproduc =  ' || psproduc;
      END IF;

      --Fi Bug 22313/115161 - 23/05/2012 - AMC

      -- ini BUG 21044 - MDS - 24/01/2012
      -- el 'Importe' de la tabla 'vdetrecibos_monpol' o de 'vdetrecibos', para la tabla importes de recibos
      -- el 'Importe' del campo 'c.icombru_moncia' o de 'c.icombru', para el campo de comisiones
      IF NVL(pac_parametros.f_parempresa_n(pempresa, 'MONEDA_POL'), 0) = 1 THEN
         v_tabla_detrecibos := 'vdetrecibos_monpol vr';
         v_campo_icombru := 'c.icombru_moncia';
      ELSE
         v_tabla_detrecibos := 'vdetrecibos vr';
         v_campo_icombru := 'c.icombru';
      END IF;

      -- fin BUG 21044 - MDS - 24/01/2012

      -- BUG19069:DRA:02/11/2011:Inici
      IF pcestrec = 0 THEN
         --
         -- RECIBOS PENDIENTES
         --
         IF NVL(ff_es_correduria(pac_md_common.f_get_cxtempresa), 0) = 0 THEN
            vpasexec := 2;
            --  OPEN cur FOR
            vquery :=
               ' SELECT vr.nrecibo, s.npoliza||''-''||s.ncertif npoliza, s.cpolcia, '
               || ' pac_isqlfor.f_titulopro(r.sseguro) titpro,'
                                                               --|| ' (vr.itotalr * (nvl(ac.ppartici,100)/100)) totrebut,'   -- Bug 27549/151318 - 27/08/2013 - AMC
               || ' vr.itotalr totrebut,'
-- Bug 27549 - 21/10/2013 - MCA se muestra el total del recibo sin tener en cuenta co-corretaje
               || ' r.fefecto fefecto, f_nombre(t.sperson, 2) tnombre,'
               || ' pac_md_redcomercial.ff_formatoccc(r.cbancar) cuenta, r.creccia '
               || ' FROM ' || v_tabla_detrecibos || ', recibos r, tomadores t, seguros s, '
               || ' age_corretaje ac '   -- Bug 27549/151318 - 27/08/2013 - AMC
               || ' WHERE vr.nrecibo = r.nrecibo AND r.sseguro = s.sseguro '
               || ' AND r.sseguro = t.sseguro AND r.cempres = ' || pempresa
               || ' AND r.cagente = ' || pcagente || ' AND EXISTS (SELECT 1 FROM movrecibo m '
               || ' WHERE m.nrecibo = r.nrecibo AND m.cestrec = 0 '
               || ' AND m.fmovfin IS NULL) AND NVL(r.cestaux, 0) = 0 '
                                                    --Bug 27549 JLV 26/07/2013
               --|| ' AND r.ctiprec NOT IN (13, 15) '   --Bug 27549 MCA 19/09/2013  No ha de mostrar recibos de Retorno
               -- Bug 27549 JLV 12/07/2013
               || ' and ((not exists (select 1 from adm_recunif where nrecunif = r.nrecibo) )
                    or (exists (select 1 from adm_recunif where nrecunif = r.nrecibo) and s.cagente = '
               || pcagente || '))'
                                  -- Bug 27549/151318 - 27/08/2013 - AMC
               || ' and ac.sseguro(+) = r.sseguro' || ' and ac.cagente(+) = ' || pcagente
               || ' and ac.nmovimi(+) = r.nmovimi' || vwhere;
            cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
         ELSE
             --para correduria no filtramos por nada
            -- OPEN cur FOR
            vpasexec := 3;
            vquery :=
               '  SELECT vr.nrecibo, s.npoliza npoliza, s.cpolcia, '
               || ' pac_isqlfor.f_titulopro(r.sseguro) titpro, vr.itotalr totrebut, '
               || ' r.fefecto fefecto, f_nombre(t.sperson, 2) tnombre, '
               || ' pac_md_redcomercial.ff_formatoccc(r.cbancar) cuenta, r.creccia '
               || ' FROM ' || v_tabla_detrecibos || ', recibos r, tomadores t, seguros s '
               || ' WHERE vr.nrecibo = r.nrecibo AND r.sseguro = s.sseguro '
               || ' AND r.sseguro = t.sseguro AND r.cempres =  ' || pempresa
               || ' AND r.cagente = ' || pcagente || ' AND ' || pcagente
               || ' NOT IN (SELECT c.cagente FROM comrecibo c WHERE c.nrecibo = r.nrecibo) '
               || vwhere || ' UNION ALL '
               || ' SELECT c.nrecibo, s.npoliza npoliza, s.cpolcia, '
               || ' pac_isqlfor.f_titulopro(r.sseguro) titpro, SUM (' || v_campo_icombru
               || ') totrebut, ' || ' r.fefecto fefecto, f_nombre(t.sperson, 2) tnombre, '
               || ' pac_md_redcomercial.ff_formatoccc(r.cbancar) cuenta, r.creccia '
               || ' FROM recibos r, tomadores t, seguros s, comrecibo c '
               || ' WHERE r.sseguro = s.sseguro AND r.sseguro = t.sseguro '
               || ' AND c.nrecibo = r.nrecibo AND c.cagente = r.cagente AND r.cempres = '
               || pempresa || ' AND c.cagente = ' || pcagente || vwhere
               || ' GROUP BY c.nrecibo, s.npoliza, s.cpolcia, pac_isqlfor.f_titulopro(r.sseguro), r.fefecto, '
               || ' f_nombre(t.sperson, 2), pac_md_redcomercial.ff_formatoccc(r.cbancar), r.creccia '
               || ' HAVING SUM(' || v_campo_icombru || ') > 0' || ' ORDER BY 2,1';
            cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
         END IF;
      ELSIF pcestrec = 3 THEN
         --
         -- RECIBOS GESTION
         --
         vpasexec := 4;

         IF NVL(ff_es_correduria(pac_md_common.f_get_cxtempresa), 0) = 0 THEN
            d_fec := f_sysdate;
            --BUG 35103-200056.KJSC eliminar la l¿nea que calcula los d¿as de gesti¿n
            -- n_dia := pac_adm.f_get_diasgest(pempresa);

            --  OPEN cur FOR
            -- Bug 21035 - APD - 23/01/2012 - se a¿ade la condicion :
            -- OR m.cestrec = 3 AND m.fmovfin IS NULL
            vquery :=
               ' SELECT vr.nrecibo, s.npoliza||''-''||s.ncertif npoliza, s.cpolcia, '
               || ' pac_isqlfor.f_titulopro(r.sseguro) titpro,'
                                                               --|| ' (vr.itotalr * (nvl(ac.ppartici,100)/100)) totrebut,'   -- Bug 27549/151318 - 27/08/2013 - AMC
               || ' vr.itotalr totrebut,'
-- Bug 27549 - 21/10/2013 - MCA se muestra el total del recibo sin tener en cuenta co-corretaje
               || ' r.fefecto fefecto, f_nombre(t.sperson, 2) tnombre, r.creccia, '
               || ' pac_md_redcomercial.ff_formatoccc(r.cbancar) cuenta ' || ' FROM '
               || v_tabla_detrecibos || ', recibos r, tomadores t, seguros s, '
               || ' age_corretaje ac '   -- Bug 27549/151318 - 27/08/2013 - AMC
               || ' WHERE vr.nrecibo = r.nrecibo AND s.sseguro = r.sseguro '
               || ' AND r.cempres = ' || pempresa || ' AND r.sseguro = t.sseguro '
               || ' AND r.cagente = ' || pcagente || ' AND EXISTS (SELECT 1 FROM movrecibo m '
               || ' WHERE m.nrecibo = r.nrecibo AND ((m.fmovfin IS NULL '
               || ' AND m.ctipcob IS NULL ' || ' AND m.cestrec = 1 AND( ''' || d_fec
               -- 35103-200056 KJSC cambiar los d¿as de gesti¿n (n_dia) por la llamada a PAC_ADM.F_GET_DIASGEST pasando como par¿metro el recibo (r.nrecibo).
               --|| ''' <= m.fmovini + ' || n_dia || ' OR m.fmovini > ''' || d_fec
               || ''' <= m.fmovini + '
--               || NVL (pac_adm.f_get_diasgest ('r.nrecibo', NULL), 0)
               || 'NVL (pac_adm.f_get_diasgest (r.nrecibo, NULL), 0)' || ' OR m.fmovini > '''
               || d_fec || ''')) OR (m.cestrec = 3 AND m.fmovfin IS NULL))) '
               || ' AND NVL(r.cestaux, 0) = 0 '   --Bug 27549 JLV 26/07/2013
               --|| ' AND r.ctiprec NOT IN (13, 15) '   --Bug 27549 MCA 19/09/2013  No ha de mostrar recibos de Retorno
               -- Bug 27549 JLV 12/07/2013
               || ' and ((not exists (select 1 from adm_recunif where nrecunif = r.nrecibo) )
                    or (exists (select 1 from adm_recunif where nrecunif = r.nrecibo) and s.cagente = '
               || pcagente || '))'
                                  -- Bug 27549/151318 - 27/08/2013 - AMC
               || ' and ac.sseguro(+) = r.sseguro' || ' and ac.cagente(+) = ' || pcagente
               || ' and ac.nmovimi(+) = r.nmovimi' || vwhere;
            cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
         END IF;
      -- BUG19069:DRA:02/11/2011:Fi
      ELSE
         RAISE e_param_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_recagente;

   /*************************************************************************
      Devuelve el numero de agente dependiendo del tipo de agente
      param in pcempres  : c¿digo de la empresa
      param in pctipage  : c¿digo del tipo de agente
      param out pcontador : Numero de contador
      param out mensajes : Mensajes de error

      return             : 0 - Ok , 1 Ko

      bug 19049/89656 - 14/07/2011 - AMC
   *************************************************************************/
   FUNCTION f_get_contador_agente(
      pcempres IN NUMBER,
      pctipage IN NUMBER,
      pcontador OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_redcomercial.f_get_contador_agente';
      vparam         VARCHAR2(2000)
                           := 'par¿metros - pcempres:' || pcempres || ' pctipage:' || pctipage;
      vpasexec       NUMBER(5) := 1;
      verror         NUMBER;
      vcempres       NUMBER;
   BEGIN
      IF pctipage IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      END IF;

      verror := pac_redcomercial.f_get_contador_agente(vcempres, pctipage, pcontador);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_contador_agente;

   /*************************************************************************
    Funci¿n que recupera el objeto OB_IAX_PRODPARTICIPACION_AGENTE.
    Productos/actividad que contaran en la participacion de utilidades para el agente
      param in pcagente  : C¿digo del agente
      param in psproduc  : C¿digo del producto
      param in pcactivi : C¿digo de la actividad
      param out mensajes : Mensajes de error
    Return: OB_IAX_PRODPARTICIPACION_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_detprodparticipacion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodparticipacion_age IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
            := 'pcagente:' || pcagente || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_detprodparticipacion';
      vnumerr        NUMBER;
      prodparticipacion ob_iax_prodparticipacion_age;
   BEGIN
      prodparticipacion := ob_iax_prodparticipacion_age();

      FOR cur IN (SELECT cagente, sproduc, cactivi
                    FROM prodparticipacion_agente
                   WHERE cagente = pcagente
                     AND sproduc = psproduc
                     AND cactivi = pcactivi) LOOP
         prodparticipacion.cagente := cur.cagente;
         prodparticipacion.sproduc := cur.sproduc;
         -- Recuperamos la descripcion del producto
         vnumerr := f_dessproduc(cur.sproduc, 1, pac_md_common.f_get_cxtidioma,
                                 prodparticipacion.tproduc);
         prodparticipacion.cactivi := cur.cactivi;

         -- Recuperamos la descripcion de la actividad
         BEGIN
            SELECT s.ttitulo
              INTO prodparticipacion.tactivi
              FROM activisegu s, activiprod p, productos pp
             WHERE s.cactivi = p.cactivi
               AND s.cramo = p.cramo
               AND s.cidioma = pac_md_common.f_get_cxtidioma
               AND pp.sproduc = cur.sproduc
               AND p.cramo = pp.cramo
               AND p.cmodali = pp.cmodali
               AND p.ctipseg = pp.ctipseg
               AND p.ccolect = pp.ccolect
               AND s.cactivi = cur.cactivi;
         EXCEPTION
            WHEN OTHERS THEN
               prodparticipacion.tactivi := NULL;
         END;
      END LOOP;

      vpasexec := 4;
      RETURN prodparticipacion;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detprodparticipacion;

   /*************************************************************************
    Funci¿n que recupera el objeto OB_IAX_SOPORTEARP_AGENTE.
    Informacion del importe que se le asigna a algunas ADN's por dar soporte administrativo
      param in pcagente  : C¿digo del agente
      param in pfinivig  : Fecha de inicio vigencia
      param out mensajes : Mensajes de error
    Return: OB_IAX_SOPORTEARP_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_detsoportearp(
      pcagente IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_soportearp_agente IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ' pfinivig:' || pfinivig;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_detsoportearp';
      vnumerr        NUMBER;
      soportearp     ob_iax_soportearp_agente;
   BEGIN
      soportearp := ob_iax_soportearp_agente();

      FOR cur IN (SELECT cagente, iimporte, finivig, ffinvig
                    FROM soportearp_agente
                   WHERE cagente = pcagente
                     AND finivig = pfinivig) LOOP
         soportearp.cagente := cur.cagente;
         soportearp.iimporte := cur.iimporte;
         soportearp.finivig := cur.finivig;
         soportearp.ffinvig := cur.ffinvig;
      END LOOP;

      vpasexec := 4;
      RETURN soportearp;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detsoportearp;

   /*************************************************************************
    Funci¿n que recupera el objeto OB_IAX_SUBVENCION_AGENTE.
    Informacion de la cantidad de subvencion que se le asigna al Intermediario o ADN
      param in pcagente  : C¿digo del agente
      param in psproduc  : C¿digo del producto
      param in pcactivi : C¿digo de la actividad
      param out mensajes : Mensajes de error
    Return: OB_IAX_SUBVENCION_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_detsubvencion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_subvencion_agente IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
            := 'pcagente:' || pcagente || ' psproduc:' || psproduc || ' pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_detsubvencion';
      vnumerr        NUMBER;
      subvencion     ob_iax_subvencion_agente;
      vcramo         ramos.cramo%TYPE;
      vtramo         ramos.tramo%TYPE;
   BEGIN
      subvencion := ob_iax_subvencion_agente();

      FOR cur IN (SELECT cagente, sproduc, cactivi, iimporte, cestado, nplanpago
                    FROM subvencion_agente
                   WHERE cagente = pcagente
                     AND sproduc = psproduc
                     AND(cactivi = pcactivi
                         OR pcactivi IS NULL)) LOOP
         BEGIN
            SELECT DISTINCT r.cramo, r.tramo
                       INTO vcramo, vtramo
                       FROM ramos r, productos p
                      WHERE r.cidioma = pac_md_common.f_get_cxtidioma
                        AND r.cramo = p.cramo
                        AND p.sproduc = cur.sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               vcramo := NULL;
               vtramo := NULL;
         END;

         subvencion.cramo := vcramo;
         subvencion.tramo := vtramo;
         subvencion.cagente := cur.cagente;
         subvencion.sproduc := cur.sproduc;
         -- Recuperamos la descripcion del producto
         vnumerr := f_dessproduc(cur.sproduc, 1, pac_md_common.f_get_cxtidioma,
                                 subvencion.tproduc);
         subvencion.cactivi := cur.cactivi;

         -- Recuperamos la descripcion de la actividad
         BEGIN
            SELECT s.ttitulo
              INTO subvencion.tactivi
              FROM activisegu s, activiprod p, productos pp
             WHERE s.cactivi = p.cactivi
               AND s.cramo = p.cramo
               AND s.cidioma = pac_md_common.f_get_cxtidioma
               AND pp.sproduc = cur.sproduc
               AND p.cramo = pp.cramo
               AND p.cmodali = pp.cmodali
               AND p.ctipseg = pp.ctipseg
               AND p.ccolect = pp.ccolect
               AND s.cactivi = cur.cactivi;
         EXCEPTION
            WHEN OTHERS THEN
               subvencion.tactivi := NULL;
         END;

         subvencion.iimporte := cur.iimporte;
         -- Bug 20287 - APD - 05/12/2011 - se a¿aden los campos cestado, testado, nplanplago
         subvencion.cestado := cur.cestado;
         subvencion.testado := ff_desvalorfijo(800070, pac_md_common.f_get_cxtidioma,
                                               cur.cestado);
         subvencion.nplanpago := cur.nplanpago;
      -- Fin Bug 20287 - APD - 05/12/2011
      END LOOP;

      vpasexec := 4;
      RETURN subvencion;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detsubvencion;

   /*************************************************************************
    Funci¿n que recupera el objeto T_IAX_PRODPARTICIPACION_AGENTE.
    Productos/actividad que contaran en la participacion de utilidades para el agente
      param in pcagente  : C¿digo del agente
      param out mensajes : Mensajes de error
    Return: T_IAX_PRODPARTICIPACION_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_prodparticipacion(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodparticipacion_age IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_prodparticipacion';
      prodparticipacion t_iax_prodparticipacion_age;
      vnumerr        NUMBER;
   BEGIN
      prodparticipacion := t_iax_prodparticipacion_age();

      FOR cur IN (SELECT   cagente, sproduc, cactivi
                      FROM prodparticipacion_agente
                     WHERE cagente = pcagente
                  ORDER BY sproduc, cactivi) LOOP
         prodparticipacion.EXTEND;
         prodparticipacion(prodparticipacion.LAST) := ob_iax_prodparticipacion_age();
         prodparticipacion(prodparticipacion.LAST).cagente := cur.cagente;
         prodparticipacion(prodparticipacion.LAST).sproduc := cur.sproduc;
         prodparticipacion(prodparticipacion.LAST).cactivi := cur.cactivi;
         -- Recuperamos la descripcion del producto
         vnumerr := f_dessproduc(cur.sproduc, 1, pac_md_common.f_get_cxtidioma,
                                 prodparticipacion(prodparticipacion.LAST).tproduc);

         -- Recuperamos la descripcion de la actividad
         BEGIN
            SELECT s.ttitulo
              INTO prodparticipacion(prodparticipacion.LAST).tactivi
              FROM activisegu s, activiprod p, productos pp
             WHERE s.cactivi = p.cactivi
               AND s.cramo = p.cramo
               AND s.cidioma = pac_md_common.f_get_cxtidioma
               AND pp.sproduc = cur.sproduc
               AND p.cramo = pp.cramo
               AND p.cmodali = pp.cmodali
               AND p.ctipseg = pp.ctipseg
               AND p.ccolect = pp.ccolect
               AND s.cactivi = cur.cactivi;
         EXCEPTION
            WHEN OTHERS THEN
               prodparticipacion(prodparticipacion.LAST).tactivi := NULL;
         END;
      END LOOP;

      vpasexec := 4;
      RETURN prodparticipacion;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_prodparticipacion;

   /*************************************************************************
    Funci¿n que recupera el objeto T_IAX_SOPORTEARP_AGENTE.
    Informacion del importe que se le asigna a algunas ADN's por dar soporte administrativo
      param in pcagente  : C¿digo del agente
      param out mensajes : Mensajes de error
    Return: T_IAX_SOPORTEARP_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_soportearp(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_soportearp_agente IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_soportearp';
      vnumerr        NUMBER;
      soportearp     t_iax_soportearp_agente;
   BEGIN
      soportearp := t_iax_soportearp_agente();

      FOR cur IN (SELECT   cagente, iimporte, finivig, ffinvig
                      FROM soportearp_agente
                     WHERE cagente = pcagente
                  ORDER BY finivig DESC) LOOP
         soportearp.EXTEND;
         soportearp(soportearp.LAST) := ob_iax_soportearp_agente();
         soportearp(soportearp.LAST).cagente := cur.cagente;
         soportearp(soportearp.LAST).iimporte := cur.iimporte;
         soportearp(soportearp.LAST).finivig := cur.finivig;
         soportearp(soportearp.LAST).ffinvig := cur.ffinvig;
      END LOOP;

      vpasexec := 4;
      RETURN soportearp;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_soportearp;

   /*************************************************************************
    Funci¿n que recupera el objeto T_IAX_SUBVENCION_AGENTE.
    Informacion de la cantidad de subvencion que se le asigna al Intermediario o ADN
      param in pcagente  : C¿digo del agente
      param out mensajes : Mensajes de error
    Return: T_IAX_SUBVENCION_AGENTE
   *************************************************************************/
   -- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_subvencion(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_subvencion_agente IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_subvencion';
      subvencion     t_iax_subvencion_agente;
      vnumerr        NUMBER;
      vcramo         ramos.cramo%TYPE;
      vtramo         ramos.tramo%TYPE;
   BEGIN
      subvencion := t_iax_subvencion_agente();

      FOR cur IN (SELECT   cagente, sproduc, cactivi, iimporte, cestado, nplanpago
                      FROM subvencion_agente
                     WHERE cagente = pcagente
                  ORDER BY sproduc, cactivi) LOOP
         subvencion.EXTEND;
         subvencion(subvencion.LAST) := ob_iax_subvencion_agente();

         BEGIN
            SELECT DISTINCT r.cramo, r.tramo
                       INTO vcramo, vtramo
                       FROM ramos r, productos p
                      WHERE r.cidioma = pac_md_common.f_get_cxtidioma
                        AND r.cramo = p.cramo
                        AND p.sproduc = cur.sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               vcramo := NULL;
               vtramo := NULL;
         END;

         subvencion(subvencion.LAST).cramo := vcramo;
         subvencion(subvencion.LAST).tramo := vtramo;
         subvencion(subvencion.LAST).cagente := cur.cagente;
         subvencion(subvencion.LAST).sproduc := cur.sproduc;
         subvencion(subvencion.LAST).cactivi := cur.cactivi;
         subvencion(subvencion.LAST).iimporte := cur.iimporte;
         -- Recuperamos la descripcion del producto
         vnumerr := f_dessproduc(cur.sproduc, 1, pac_md_common.f_get_cxtidioma,
                                 subvencion(subvencion.LAST).tproduc);

         -- Recuperamos la descripcion de la actividad
         BEGIN
            SELECT s.ttitulo
              INTO subvencion(subvencion.LAST).tactivi
              FROM activisegu s, activiprod p, productos pp
             WHERE s.cactivi = p.cactivi
               AND s.cramo = p.cramo
               AND s.cidioma = pac_md_common.f_get_cxtidioma
               AND pp.sproduc = cur.sproduc
               AND p.cramo = pp.cramo
               AND p.cmodali = pp.cmodali
               AND p.ctipseg = pp.ctipseg
               AND p.ccolect = pp.ccolect
               AND s.cactivi = cur.cactivi;
         EXCEPTION
            WHEN OTHERS THEN
               subvencion(subvencion.LAST).tactivi := NULL;
         END;

         -- Bug 20287 - APD - 05/12/2011 - se a¿aden los campos cestado, testado, nplanpago
         subvencion(subvencion.LAST).cestado := cur.cestado;
         subvencion(subvencion.LAST).testado := ff_desvalorfijo(800070,
                                                                pac_md_common.f_get_cxtidioma,
                                                                cur.cestado);
         subvencion(subvencion.LAST).nplanpago := cur.nplanpago;
      -- Fin Bug 20287 - APD - 05/12/2011
      END LOOP;

      vpasexec := 4;
      RETURN subvencion;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_subvencion;

/*************************************************************************
      Inserta un valor del producto de participaci¿n de utilidades para el agente
      param in pcagente  : c¿digo del agente
      param in psproduc    : C¿digo del producto
      param in pcactivi   : C¿digo de la actividad
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_prodparticipacion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
          := 'pcagente:' || pcagente || ', psproduc:' || psproduc || ', pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_prodparticipacion';
      verror         NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR psproduc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_redcomercial.f_set_prodparticipacion(pcagente, psproduc, pcactivi);
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
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
   END f_set_prodparticipacion;

/*************************************************************************
      Inserta un valor del Soporte por ARP
      param in pcmodo ; 1.-Alta; 2.-Modif
      param in pcagente  : c¿digo del agente
      param in piimporte    : Importe que se le asigna a algunas ADN's por dar soporte administrativo
      param in pfinivig   : Fecha inicio vigencia
      param in pffinvig   : Fecha fin vigencia
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_soportearp(
      pcmodo IN NUMBER,
      pcagente IN NUMBER,
      piimporte IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcmodo:' || pcmodo || ', pcagente:' || pcagente || ', piimporte:' || piimporte
            || ', pfinivig:' || pfinivig || ', pffinvig:' || pffinvig;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_soportearp';
      verror         NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR piimporte IS NULL
         OR pfinivig IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_redcomercial.f_set_soportearp(pcmodo, pcagente, piimporte, pfinivig,
                                                  pffinvig);
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
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
   END f_set_soportearp;

/*************************************************************************
      Inserta una subvenci¿n
      param in pcmodo ; 1.-Alta; 2.-Modif
      param in pcagente  : c¿digo del agente
      param in psproduc    : C¿digo del producto
      param in pcactivi   : C¿digo de la actividad
      param in piimporte   : Importe de la subvenci¿n
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_set_subvencion(
      pcmodo IN NUMBER,
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      piimporte IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcmodo:' || pcmodo || ', pcagente:' || pcagente || ', psproduc:' || psproduc
            || ', pcactivi:' || pcactivi || ', piimporte:' || piimporte;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_subvencion';
      verror         NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR psproduc IS NULL
         OR piimporte IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_redcomercial.f_set_subvencion(pcmodo, pcagente, psproduc, pcactivi,
                                                  piimporte);
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
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
   END f_set_subvencion;

/*************************************************************************
      Elimina un registro del producto de participaci¿n de utilidades para el agente
      param in pcagente  : c¿digo del agente
      param in psproduc    : C¿digo del producto
      param in pcactivi   : C¿digo de la actividad
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_prodparticipacion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
          := 'pcagente:' || pcagente || ', psproduc:' || psproduc || ', pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_del_prodparticipacion';
      verror         NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR psproduc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_redcomercial.f_del_prodparticipacion(pcagente, psproduc, pcactivi);
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
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
   END f_del_prodparticipacion;

/*************************************************************************
      Elimina un registro del Soporte por ARP
      param in pcagente  : c¿digo del agente
      param in pfinivig    : Fecha inicio vigencia
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_soportearp(
      pcagente IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ', pfinivig:' || pfinivig;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_del_soportearp';
      verror         NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pfinivig IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_redcomercial.f_del_soportearp(pcagente, pfinivig);
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
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
   END f_del_soportearp;

/*************************************************************************
      Elimina un registro de una subvenci¿n
      param in pcagente  : c¿digo del agente
      param in psproduc    : C¿digo del producto
      param in pcactivi    : C¿digo de la actividad
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_del_subvencion(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
          := 'pcagente:' || pcagente || ', psproduc:' || psproduc || ', pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_del_subvencion';
      verror         NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_redcomercial.f_del_subvencion(pcagente, psproduc, pcactivi);
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
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
   END f_del_subvencion;

   /*************************************************************************
      Funci¿n que nos devolver¿ el hist¿rico de las vigencias de las comisiones/sobrecomisiones del agente
      param in pcagente  : c¿digo del agente
      param in pctipo    : Tipo de la comision
      param in pccomind  : Indica si la comision es indirecta (1) o no (0)
      Return: Sys_Refcursor
    *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_comisionvig_agente(
      pcagente IN NUMBER,
      pctipo IN NUMBER,
      pccomind IN NUMBER,   -- Bug 20999 - APD - 26/01/2012
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0013392 - 23/03/2010 - JMF
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
               := ' pcagente:' || pcagente || ' pctipo:' || pctipo || ' pccomind:' || pccomind;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_comisionvig_agente';
      cur            sys_refcursor;
      d_fec          DATE;
      n_dia          NUMBER;
      vwhere         VARCHAR2(1000);
      vquery         VARCHAR2(2000);
   BEGIN
      IF pcagente IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105308);
         RAISE e_param_error;
      END IF;

      vquery :=
         'SELECT ca.cagente, c.ccomisi, d.tcomisi, ca.finivig, ca.ffinvig
        FROM comisionvig_agente ca, codicomisio c, descomision d
        WHERE ca.ccomisi = c.ccomisi
        AND c.ccomisi = d.ccomisi
        AND d.cidioma = pac_md_common.f_get_cxtidioma
        AND ca.cagente = '
         || pcagente || ' AND c.ctipo = NVL (' || NVL(TO_CHAR(pctipo), 'null')
         || ',c.ctipo) AND ca.ccomind = NVL (' || NVL(TO_CHAR(pccomind), 'null')
         || ',ca.ccomind) ORDER BY finivig DESC';
      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_comisionvig_agente;

   /*************************************************************************
      Funci¿n que nos devolver¿ el hist¿rico de las vigencias de las comisiones/sobrecomisiones del agente
      param in pcagente  : c¿digo del agente
      param in pctipo    : Tipo de la comision
      param in pccomind  : Indica si la comision es indirecta (1) o no (0)
      Return: Sys_Refcursor
    *************************************************************************/
-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION f_get_descuentovig_agente(
      pcagente IN NUMBER,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0013392 - 23/03/2010 - JMF
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcagente:' || pcagente || ' pctipo:' || pctipo;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_descuentovig_agente';
      cur            sys_refcursor;
      d_fec          DATE;
      n_dia          NUMBER;
      vwhere         VARCHAR2(1000);
      vquery         VARCHAR2(2000);
   BEGIN
      IF pcagente IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105308);
         RAISE e_param_error;
      END IF;

      vquery :=
         'SELECT ca.cagente, c.cdesc, d.tdesc, ca.finivig , ca.ffinvig
       FROM descvig_agente ca, codidesc c, desdesc d
        WHERE ca.cdesc = c.cdesc
        AND c.cdesc = d.cdesc
        AND d.cidioma = pac_md_common.f_get_cxtidioma
        AND ca.cagente = '
         || pcagente || ' ORDER BY finivig DESC';
      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_descuentovig_agente;

-- Bug 19169 - APD - 16/09/2011 - se crea la funcion
   FUNCTION ff_desagente(
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pformato IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcagente:' || pcagente || ' pformato:' || pformato;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.ff_desagente';
      verror         NUMBER;
      vdesagente     VARCHAR2(200);
   BEGIN
      vdesagente := pac_redcomercial.ff_desagente(pcagente, pcidioma, pformato);
      vpasexec := 2;

      IF vdesagente IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000503);
         -- Error al recuperar los datos del agente
         RAISE e_object_error;
      END IF;

      RETURN vdesagente;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END ff_desagente;

-- Bug 20287 - APD - 05/12/2011 - se crea la funcion
   FUNCTION f_traspasar_subvencion(
      pcagente IN NUMBER,
      pnplanpago IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                   := 'pcagente:' || pcagente || ', pnplanpago:' || pnplanpago;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_traspasar_subvencion';
      verror         NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pnplanpago IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_redcomercial.f_traspasar_subvencion(pcagente, pnplanpago);
      vpasexec := 2;

      IF verror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 9902897);
      -- Registros traspasados correctamente.
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
   END f_traspasar_subvencion;

   /*************************************************************************
      Funci¿n que nos devolver¿ los contactos de un agente
      param in pcagente  : c¿digo del agente
      Return: Sys_Refcursor

      Bug 21450/108261 - 24/02/2012 - AMC
    *************************************************************************/
   FUNCTION f_get_contactosage(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_contactosage';
      verror         NUMBER;
      vquery         VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vquery := 'select a.*, d.tatribu ttipo' || ' from age_contactos a, detvalores d'
                || ' where a.cagente =' || pcagente || ' and d.cvalor = 800074'
                || ' and d.CIDIOMA =' || pac_md_common.f_get_cxtidioma()
                || ' and d.catribu = a.ctipo order by norden ';
      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_contactosage;

   /*************************************************************************
     Funci¿n que nos devolver¿ un contacto del agente
     param in pcagente : c¿digo del agente
     param in pnorden  : n¿ orden
     Return: ob_iax_age_contactos

     Bug 21450/108261 - 24/02/2012 - AMC
    *************************************************************************/
   FUNCTION f_get_contactoage(
      pcagente IN NUMBER,
      pnorden IN NUMBER,
      pcontacto IN OUT ob_iax_age_contactos,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ' pnorden:' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_contactoage';
   BEGIN
      IF pcagente IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcontacto IS NULL THEN
         pcontacto := ob_iax_age_contactos();
      END IF;

      vpasexec := 1;

      SELECT cagente, ctipo, norden, nombre,
             cargo, iddomici, telefono, telefono2,
             fax, web, email
        INTO pcontacto.cagente, pcontacto.ctipo, pcontacto.norden, pcontacto.nombre,
             pcontacto.cargo, pcontacto.iddomici, pcontacto.telefono, pcontacto.telefono2,
             pcontacto.fax, pcontacto.web, pcontacto.email
        FROM age_contactos
       WHERE cagente = pcagente
         AND norden = pnorden;

      vpasexec := 2;
      pcontacto.ttipo := pac_md_listvalores.f_getdescripvalores(800074, pcontacto.ctipo,
                                                                mensajes);
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
   END f_get_contactoage;

   /*************************************************************************
    FUNCTION f_set_age_contacto
    Funcion que guarda el contacto de un agente
    param in pcagente   : C¿digo agente
    param in pctipo     : C¿digo del tipo de contacto
    param in pnorden    : N¿ orden
    param in pnombre    : Nombre del contacto
    param in pcargo     : C¿digo del cargo
    param in piddomici  : C¿digo del domicilio
    param in ptelefono  : Telefono
    param in ptelefono2 : Telefono 2
    param in pfax       : Fax
    param in pemail     : Email
    return             : 0 - ok - Codi error

    Bug 21450/108261 - 27/02/2012 - AMC
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
      pemail IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcagente:' || pcagente || ' pnorden:' || pnorden || ' pctipo:' || pctipo
            || ' pnombre:' || pnombre || ' pcargo:' || pcargo || 'piddomici:' || piddomici
            || ' ptelefono:' || ptelefono || ' ptelefono2:' || ptelefono2 || ' pfax:' || pfax
            || ' pweb:' || pweb || ' pemail:' || pemail;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_age_contacto';
      vnumerr        NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_agentes.f_set_age_contacto(pcagente, pctipo, pnorden, pnombre, pcargo,
                                                piddomici, ptelefono, ptelefono2, pfax, pweb,
                                                pemail);

      IF vnumerr <> 0 THEN
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
   END f_set_age_contacto;

   /*************************************************************************
    FUNCTION f_del_age_contacto
    Funcion que borra el contacto de un agente
    param in pcagente   : C¿digo agente
    param in pnorden    : N¿ orden
    return             : 0 - ok - Codi error

    Bug 21450/108261 - 27/02/2012 - AMC
   *************************************************************************/
   FUNCTION f_del_age_contacto(
      pcagente IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente || ' pnorden:' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_del_age_contacto';
      vnumerr        NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_agentes.f_del_age_contacto(pcagente, pnorden);

      IF vnumerr <> 0 THEN
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
   END f_del_age_contacto;

     /*************************************************************************
     Funci¿n que inserta o actualiza los datos de un documento asociado a un agente
     param in pcagente   : C¿digo agente
     param in pfcaduca   : Fecha de caducidad
     param in ptobserva  : Observaciones
     param in piddocgedox : Identificador del documento
     param in ptamano : Tama¿o del documento

     Bug 21543/108711 - AMC - 02/03/2012
   *************************************************************************/
   FUNCTION f_set_docagente(
      pcagente IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptamano IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'par¿metros - pcagente: ' || pcagente || ' - ptamano:' || ptamano
            || ' - pfcaduca: ' || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - ptobserva: '
            || ptobserva || ' - piddocgedox: ' || piddocgedox;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_docagente';
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_agentes.f_set_docagente(pcagente, pfcaduca, ptobserva, piddocgedox,
                                             ptamano);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_docagente;

    /*************************************************************************
      FUNCTION funci¿n que recupera la informaci¿n de los datos de un documento asociado al agente
      param in pcagente    : Agente
      param in piddocgedox  : documento gedox
      pobdocpersona out ob_iax_docagente : Objeto de documentos de agentes
      return           : c¿digo de error

      Bug 21543/108711 - AMC - 02/03/2012
   *************************************************************************/
   FUNCTION f_get_docagente(
      pcagente IN NUMBER,
      piddocgedox IN NUMBER,
      pobdocagente OUT ob_iax_docagente,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                 := 'par¿metros - pcagente = ' || pcagente || ' piddocgedox = ' || piddocgedox;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_docagente';
   BEGIN
      vpasexec := 1;

      IF pcagente IS NULL
         OR piddocgedox IS NULL THEN
         RAISE e_param_error;
      END IF;

      pobdocagente := ob_iax_docagente();
      vpasexec := 2;

      SELECT cagente, iddocgedox, fcaduca,
             tobserva, tamano, cusualt,
             falta, cusuari, fmovimi
        INTO pobdocagente.cagente, pobdocagente.iddocgedox, pobdocagente.fcaduca,
             pobdocagente.tobserva, pobdocagente.tamano, pobdocagente.cusualt,
             pobdocagente.falta, pobdocagente.cusuari, pobdocagente.fmovimi
        FROM age_documentos
       WHERE cagente = pcagente
         AND iddocgedox = piddocgedox;

      vpasexec := 3;
      pobdocagente.iddcat := pac_axisgedox.f_get_catdoc(pobdocagente.iddocgedox);
      vpasexec := 4;
      pobdocagente.tdescrip := pac_axisgedox.f_get_descdoc(pobdocagente.iddocgedox);
      vpasexec := 5;
      pobdocagente.fichero :=
         SUBSTR(pac_axisgedox.f_get_filedoc(pobdocagente.iddocgedox),
                INSTR(pac_axisgedox.f_get_filedoc(pobdocagente.iddocgedox), '\', -1) + 1,
                LENGTH(pac_axisgedox.f_get_filedoc(pobdocagente.iddocgedox)));
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
   END f_get_docagente;

     /*************************************************************************
      FUNCTION funci¿n que recupera los documentos asociados al agente
      param in pcagente    : Agente
      pobdocagente out t_iax_docagente : Objeto de documentos de agentes
      return           : c¿digo de error

      Bug 21543/108711 - AMC - 02/03/2012
   *************************************************************************/
   FUNCTION f_get_documentacion(
      pcagente IN NUMBER,
      ptdocagente OUT t_iax_docagente,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'par¿metros - pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_documentacion';

      CURSOR cur_perrel IS
         SELECT cagente, iddocgedox
           FROM age_documentos
          WHERE cagente = pcagente;
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      ptdocagente := t_iax_docagente();

      FOR reg IN cur_perrel LOOP
         ptdocagente.EXTEND;
         ptdocagente(ptdocagente.LAST) := ob_iax_docagente();
         vnumerr := f_get_docagente(pcagente, reg.iddocgedox, ptdocagente(ptdocagente.LAST),
                                    mensajes);

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

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
   END f_get_documentacion;

   FUNCTION f_get_niveles(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcempres:' || pcempres || ', pcidioma:' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_niveles';
      cur            sys_refcursor;
   BEGIN
      cur := pac_redcomercial.f_get_niveles(pcempres, pcidioma);

      IF cur IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900958);
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_niveles;

   FUNCTION f_busca_padre(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pfbusca IN DATE,
      ptagente OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
          := 'pcempres:' || pcempres || ', pcagente:' || pcagente || ', pctipage:' || pctipage;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_busca_padre';
      vcagente       NUMBER;
   BEGIN
      vcagente := pac_redcomercial.f_busca_padre(NVL(pcempres, pac_md_common.f_get_cxtempresa),
                                                 pcagente, pctipage, pfbusca);

      IF vcagente IS NOT NULL THEN
         ptagente := pac_redcomercial.ff_desagente(vcagente, pac_md_common.f_get_cxtidioma, 0);
      END IF;

      RETURN vcagente;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_busca_padre;

   /******************************************************************************
    FUNCION: f_get_retencion
    Funcion que devielve el tipo de retenci¿n segun la letra del cif.
    Param in psperson
    Param out pcidioma
    Param out pcidioma
    Param in/out mensajes
    Retorno 0- ok 1-ko

    Bug 24514/128686 - 15/11/2012 - AMC
   ******************************************************************************/
   FUNCTION f_get_retencion(
      psperson IN NUMBER,
      pcretenc OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psperson:' || psperson;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_retencion';
      vnumerr        NUMBER;
      vmensaje       VARCHAR2(1000);
      vcidioma       NUMBER;
      vcempres       NUMBER;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcidioma := pac_md_common.f_get_cxtidioma();
      vcempres := pac_md_common.f_get_cxtempresa();
      vnumerr := pac_redcomercial.f_get_retencion(psperson, vcidioma, vcempres, pcretenc,
                                                  vmensaje);

      IF vmensaje IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, vmensaje);
      END IF;

      RETURN vnumerr;
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
   END f_get_retencion;

   --Copia f_get_agente
   FUNCTION f_get_agente_original(pcagente IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_agentes IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_agente';
      agente         ob_iax_agentes;
      vnumerr        NUMBER := 0;
   BEGIN
      agente := ob_iax_agentes();

      -- Bug 19169 - APD - 16/09/2011 - Modificar la select de la tabla AGENTES,
      -- a¿¿adiendo en el from de la select la nueva tabla AGENTES_COMP, a¿¿adiendo los
      -- nuevos campos de la tabla AGENTES y AGENTES_COMP, guardando su valor en el
      -- objeto OB_IAX_AGENTES
      -- Bug 20999 - APD - 25/01/2012 - se a¿¿ade el campo ccomisi_indirect
      -- BUG 0021425 - 01/03/2012 - JMF
      SELECT a.cagente, cretenc, ctipiva, ccomisi, ctipage,
             cactivo, cbancar, ncolegi, fbajage, sperson,
             cdomici, a.csobrecomisi, a.talias, a.cliquido,
             ac.ctipadn, ac.cagedep, ac.ctipint, ac.cageclave,
             ac.cofermercan, ac.frecepcontra, ac.cidoneidad, ac.spercomp,
             ac.ccompani, ac.cofipropia, ac.cclasif, ac.nplanpago,
             ac.nnotaria, ac.cprovin, ac.cpoblac, ac.nescritura,
             ac.faltasoc, ac.tgerente, ac.tcamaracomercio,
             a.ccomisi_indirect, a.ctipmed, a.tnomcom, a.cdomcom,
             a.ctipretrib, a.cmotbaja, a.cbloqueo, a.nregdgs,
             a.finsdgs, a.crebcontdgs, ac.agrupador, ac.cactividad,
             ac.ctipoactiv, ac.pretencion, ac.cincidencia, ac.crating,
             ac.tvaloracion, ac.cresolucion, ac.ffincredito, ac.nlimcredito,
             ac.tcomentarios, a.coblccc, ac.fultrev, ac.fultckc,
             ac.ctipbang, ac.cbanges, ac.cclaneg
             --AAC_INI-CONF_379-20160927
             ,ac.corteprod
             --AAC_FI-CONF_379-20160927
			 INTO agente.cagente, agente.cretenc, agente.ctipiva, agente.ccomisi, agente.ctipage,
             agente.cactivo, agente.cbancar, agente.ncolegi, agente.fbajage, agente.sperson,
             agente.cdomici, agente.csobrecomisi, agente.talias, agente.cliquido,
             agente.ctipadn, agente.cagedep, agente.ctipint, agente.cageclave,
             agente.cofermercan, agente.frecepcontra, agente.cidoneidad, agente.spercomp,
             agente.ccompani, agente.cofipropia, agente.cclasif, agente.nplanpago,
             agente.nnotaria, agente.cprovin, agente.cpoblac, agente.nescritura,
             agente.faltasoc, agente.tgerente, agente.tcamaracomercio,
             agente.ccomisi_indirect, agente.ctipmed, agente.tnomcom, agente.cdomcom,
             agente.ctipretrib, agente.cmotbaja, agente.cbloqueo, agente.nregdgs,
             agente.finsdgs, agente.crebcontdgs, agente.agrupador, agente.cactividad,
             agente.ctipoactiv, agente.pretencion, agente.cincidencia, agente.crating,
             agente.tvaloracion, agente.cresolucion, agente.ffincredito, agente.nlimcredito,
             agente.tcomentarios, agente.coblccc, agente.fultrev, agente.fultckc,
             agente.ctipbang, agente.cbanges, agente.cclaneg
             --AAC_INI-CONF_379-20160927
             ,agente.corteprod
             --AAC_FI-CONF_379-20160927
        FROM agentes a, agentes_comp ac
       WHERE a.cagente = pcagente
         AND a.cagente = ac.cagente(+);

      -- fin Bug 20999 - APD - 25/01/2012
      -- Fin Bug 19169 - APD - 16/09/2011
      -- fin BUG 0021425 - 01/03/2012 - JMF
      vpasexec := 2;
      -- Recuperamos descripcion del codigo del cactivo
      agente.tactivo := pac_md_listvalores.f_getdescripvalores(31, agente.cactivo, mensajes);
      vpasexec := 3;
      -- Recuperamos descripcion del codigo del ctipage
      agente.tctipage := pac_redcomercial.f_get_desnivel(agente.ctipage,
                                                         pac_md_common.f_get_cxtempresa,
                                                         pac_md_common.f_get_cxtidioma);
      vpasexec := 4;

      -- Recuperamos la descripcion de la comision
      IF agente.ccomisi IS NOT NULL THEN
         -- Mantis 10340.#6.ini.01/06/2009.NMM.0010340: IAX - No se ven los datos del agente en otros idiomas.
         -- Si no es troba la descripci¿¿ de la comissi¿¿ que no peti.
         BEGIN
            SELECT tcomisi
              INTO agente.tcomisi
              FROM descomision
             WHERE ccomisi = agente.ccomisi
               AND cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      -- Mantis 10340.#6.fi.
      END IF;

      vpasexec := 5;

      -- Recuperamos las descripcion del tipo de iva
      IF agente.ctipiva IS NOT NULL THEN
         SELECT ttipiva
           INTO agente.ttipiva
           FROM descripcioniva
          WHERE ctipiva = agente.ctipiva
            AND cidioma = pac_md_common.f_get_cxtidioma;
      END IF;

      vpasexec := 6;

      -- Recuperamos la descripcion del tipo de retencion
      IF agente.cretenc IS NOT NULL THEN
         SELECT ttipret
           INTO agente.tretenc
           FROM descripcionret
          WHERE cretenc = agente.cretenc
            AND cidioma = pac_md_common.f_get_cxtidioma;
      END IF;

      vpasexec := 7;
      -- Recuperamos el nombre y el nif del agente
      agente.nnif := ff_buscanif(agente.sperson);
      agente.tnombre := f_nombre(agente.sperson, 1);
      vpasexec := 8;

      -- Bug 19169 - APD - 16/09/2011
      -- Recuperamos la descripcion de la comision
      IF agente.csobrecomisi IS NOT NULL THEN
         -- Mantis 10340.#6.ini.01/06/2009.NMM.0010340: IAX - No se ven los datos del agente en otros idiomas.
         -- Si no es troba la descripci¿¿ de la sobrecomissi¿¿ que no peti.
         BEGIN
            SELECT tcomisi
              INTO agente.tsobrecomisi
              FROM descomision
             WHERE ccomisi = agente.csobrecomisi
               AND cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      -- Mantis 10340.#6.fi.
      END IF;

      vpasexec := 9;

      -- Bug 19169 - APD - 16/09/2011
      -- Recuperamos descripcion del Tipo de ADN
      IF agente.ctipadn IS NOT NULL THEN
         agente.ttipadn := pac_md_listvalores.f_getdescripvalores(370, agente.ctipadn,
                                                                  mensajes);
      ELSE
         agente.ttipadn := NULL;
      END IF;

      vpasexec := 10;

      -- Bug 19169 - APD - 16/09/2011
      -- Recuperamos descripcion del Tipo de Intermediario
      IF agente.ctipint IS NOT NULL THEN
         agente.ttipint := pac_md_listvalores.f_getdescripvalores(371, agente.ctipint,
                                                                  mensajes);
      ELSE
         agente.ttipint := NULL;
      END IF;

      vpasexec := 11;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿¿n de si el Intermediario tiene autorizaci¿¿n para desconectarse, detener, directamente las comisiones
      IF agente.cliquido IS NOT NULL THEN
         agente.tliquido := pac_md_listvalores.f_getdescripvalores(372, agente.cliquido,
                                                                   mensajes);
      ELSE
         agente.tliquido := NULL;
      END IF;

      vpasexec := 12;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿¿n de si cumple o no con los requisitos de capacitaci¿¿n para ser Intermediario
      IF agente.cidoneidad IS NOT NULL THEN
         agente.tidoneidad := pac_md_listvalores.f_getdescripvalores(373, agente.cidoneidad,
                                                                     mensajes);
      ELSE
         agente.tidoneidad := NULL;
      END IF;

      vpasexec := 13;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿¿n de Clientes ¿¿nicos identificados como compa¿¿¿¿as
      IF agente.ccompani IS NOT NULL THEN
         BEGIN
            SELECT tcompani
              INTO agente.tcompani
              FROM companias
             WHERE ccompani = agente.ccompani;
         EXCEPTION
            WHEN OTHERS THEN
               agente.tcompani := NULL;
         END;
      ELSE
         agente.tcompani := NULL;
      END IF;

      vpasexec := 14;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿¿n de si el Intermediario tiene oficina propia
      IF agente.cofipropia IS NOT NULL THEN
         agente.tofipropia := pac_md_listvalores.f_getdescripvalores(374, agente.cofipropia,
                                                                     mensajes);
      ELSE
         agente.tofipropia := NULL;
      END IF;

      vpasexec := 15;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿¿n de la clasificaci¿¿n del Intermediario
      IF agente.cclasif IS NOT NULL THEN
         agente.tclasif := pac_md_listvalores.f_getdescripvalores(375, agente.cclasif,
                                                                  mensajes);
      ELSE
         agente.tclasif := NULL;
      END IF;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿¿n de la provincia de la ciudad de notaria
      IF agente.cprovin IS NOT NULL THEN
         agente.tprovin := f_desprovin2(agente.cprovin, NULL);
      ELSE
         agente.tprovin := NULL;
      END IF;

      -- Bug 19169 - APD - 16/09/2011
      -- Descripci¿¿n de la poblacion de la ciudad de notaria
      IF agente.cpoblac IS NOT NULL THEN
         agente.tpoblac := f_despoblac2(agente.cpoblac, agente.cprovin);
      ELSE
         agente.tpoblac := NULL;
      END IF;

      vpasexec := 16;

      -- Bug 19169 - APD - 16/09/2011
      -- Los campos FINIVIGCOM, FINIVIGSOBRECOM y FFINVIGSOBRECOM del objeto OB_IAX_AGENTES se obtienen de la select:
      BEGIN
         -- Bug 20999 - APD - 26/01/2012 - se a¿¿ade la condicion ccomind = 0.-Comision NO indirecta
         SELECT finivig, ffinvig
           INTO agente.finivigcom, agente.ffinvigcom
           FROM comisionvig_agente ca
          WHERE cagente = agente.cagente
            AND ccomisi = agente.ccomisi
            AND ffinvig IS NULL
            AND ccomind = 0;
      -- fin Bug 20999 - APD - 26/01/2012
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vpasexec := 17;

      BEGIN
         -- Bug 20999 - APD - 26/01/2012 - se a¿¿ade la condicion ccomind = 0.-Comision NO indirecta
         SELECT finivig, ffinvig
           INTO agente.finivigsobrecom, agente.ffinvigsobrecom
           FROM comisionvig_agente ca
          WHERE cagente = agente.cagente
            AND ccomisi = agente.csobrecomisi
            AND finivig = (SELECT MAX(finivig)
                             FROM comisionvig_agente ca1
                            WHERE ca1.cagente = ca.cagente
                              AND ca1.ccomisi = ca.ccomisi)
            AND ccomind = 0;
      -- fin Bug 20999 - APD - 26/01/2012
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vpasexec := 20;

      -- Bug 19169 - APD - 16/11/2011
      -- Nombre agente ADN de la cual depente. Obligatorio si CTIPADN es 'ADN dependiente de otra ADN'
      IF agente.cagedep IS NOT NULL THEN
         agente.tagedep := pac_redcomercial.ff_desagente(agente.cagedep,
                                                         pac_md_common.f_get_cxtidioma, 1);
      END IF;

      vpasexec := 25;

      -- Bug 19169 - APD - 16/11/2011
      -- Nombre del agente agrupador de otras claves de Intermediarios
      IF agente.cageclave IS NOT NULL THEN
         agente.tageclave := pac_redcomercial.ff_desagente(agente.cageclave,
                                                           pac_md_common.f_get_cxtidioma, 1);
      END IF;

      vpasexec := 30;

      -- Bug 20999 - APD - 25/01/2012
      -- Recuperamos la descripcion de la comision indirecta
      IF agente.ccomisi_indirect IS NOT NULL THEN
         BEGIN
            SELECT tcomisi
              INTO agente.tcomisi_indirect
              FROM descomision
             WHERE ccomisi = agente.ccomisi_indirect
               AND cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      vpasexec := 35;

      -- El campo FINIVIGCOM_INDIRECT del objeto OB_IAX_AGENTES se obtienen de la select:
      BEGIN
         -- Bug 20999 - APD - 26/01/2012 - se a¿¿ade la condicion ccomind = 1.-Comision SI indirecta
         SELECT finivig, ffinvig
           INTO agente.finivigcom_indirect, agente.ffinvigcom_indirect
           FROM comisionvig_agente
          WHERE cagente = agente.cagente
            AND ccomisi = agente.ccomisi_indirect
            AND ffinvig IS NULL
            AND ccomind = 1;
      -- fin Bug 20999 - APD - 26/01/2012
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- fin Bug 20999 - APD - 25/01/2012

      -- ini bug 0021425 - 01/03/2012 - JMF
      IF agente.ctipmed IS NOT NULL THEN
         vpasexec := 40;
         agente.ttipmed := pac_md_listvalores.f_getdescripvalores(1062, agente.ctipmed,
                                                                  mensajes);
      END IF;

      IF agente.cdomcom IS NOT NULL THEN
         vpasexec := 45;

         DECLARE
            retval         NUMBER;
            pctipo         NUMBER;
            ps1            NUMBER;
            ps2            NUMBER;
            pcformat       NUMBER;
            ptlin1         VARCHAR2(200);
            ptlin2         VARCHAR2(200);
            ptlin3         VARCHAR2(200);
         BEGIN
            pctipo := 1;
            ps1 := agente.sperson;
            ps2 := agente.cdomcom;
            pcformat := 2;
            ptlin1 := NULL;
            ptlin2 := NULL;
            ptlin3 := NULL;
            retval := f_direccion(pctipo, ps1, ps2, pcformat, ptlin1, ptlin2, ptlin3);

            IF retval = 0 THEN
               agente.tdomcom := ptlin1;
            ELSE
               agente.tdomcom := NULL;
            END IF;
         END;
      END IF;

      IF agente.ctipretrib IS NOT NULL THEN
         vpasexec := 50;
         agente.ttipretrib := pac_md_listvalores.f_getdescripvalores(1063, agente.ctipretrib,
                                                                     mensajes);
      END IF;

      IF agente.cmotbaja IS NOT NULL THEN
         vpasexec := 52;
         agente.tmotbaja := pac_md_listvalores.f_getdescripvalores(1066, agente.cmotbaja,
                                                                   mensajes);
      END IF;

      IF agente.cbloqueo IS NOT NULL THEN
         vpasexec := 54;
         agente.tbloqueo := pac_md_listvalores.f_getdescripvalores(1067, agente.cbloqueo,
                                                                   mensajes);
      END IF;

      IF agente.agrupador IS NOT NULL THEN
         vpasexec := 56;
         agente.tagrupador := pac_md_listvalores.f_getdescripvalores(1064, agente.agrupador,
                                                                     mensajes);
      END IF;

      IF agente.cactividad IS NOT NULL THEN
         vpasexec := 58;
         agente.tactividad := pac_md_listvalores.f_getdescripvalores(1065, agente.cactividad,
                                                                     mensajes);
      END IF;

      IF agente.ctipoactiv IS NOT NULL THEN
         vpasexec := 60;
         agente.ttipoactiv := pac_md_listvalores.f_getdescripvalores(1068, agente.ctipoactiv,
                                                                     mensajes);
      END IF;

      IF agente.cincidencia IS NOT NULL THEN
         vpasexec := 62;
         agente.tincidencia := pac_md_listvalores.f_getdescripvalores(1069,
                                                                      agente.cincidencia,
                                                                      mensajes);
      END IF;

      IF agente.crating IS NOT NULL THEN
         vpasexec := 64;
         agente.trating := pac_md_listvalores.f_getdescripvalores(1070, agente.crating,
                                                                  mensajes);
      END IF;

      IF agente.cresolucion IS NOT NULL THEN
         vpasexec := 66;
         agente.tresolucion := pac_md_listvalores.f_getdescripvalores(1071,
                                                                      agente.cresolucion,
                                                                      mensajes);
      END IF;

      IF agente.cagente IS NOT NULL THEN
         vpasexec := 69;
         vnumerr := pac_md_age_datos.f_get_bancos(agente.cagente, agente.bancos, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF agente.cagente IS NOT NULL THEN
         vpasexec := 72;
         vnumerr := pac_md_age_datos.f_get_entidadesaseg(agente.cagente, agente.entidadesaseg,
                                                         mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF agente.cagente IS NOT NULL THEN
         vpasexec := 74;
         vnumerr := pac_md_age_datos.f_get_asociaciones(agente.cagente, agente.asociaciones,
                                                        mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      IF agente.cagente IS NOT NULL THEN
         vpasexec := 76;
         vnumerr := pac_md_age_datos.f_get_referencias(agente.cagente, agente.referencias,
                                                       mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      -- fin bug 0021425 - 01/03/2012 - JMF
      RETURN agente;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_agente_original;

   /******************************************************************************
    FUNCION: F_GET_CORREO
    recuperar¿n datos tambi¿n de MENSAJES_CORREO y DESMENSAJE_CORREO
    Param in pcagente
    Param out mensajes
    Retorno 0- ok 1-ko

   ******************************************************************************/
   FUNCTION f_get_correo(
      pcagente IN NUMBER,
      ptcorreo OUT agentes_comp.tcorreo%TYPE,
      pcenvcor OUT agentes_comp.cenvcorreo%TYPE,
      pmsjcorreo OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_REDCOMERCIAL.f_get_correo';
      cur            sys_refcursor;

      CURSOR c_agentes_comp IS
         SELECT tcorreo, cenvcorreo
           FROM agentes_comp
          WHERE cagente = pcagente;
   BEGIN
      OPEN pmsjcorreo FOR
         SELECT ROWNUM col, d.tatribu, a.tcorreo, a.cenviar, d.catribu
           FROM mensajes_correo m, agentes_correo a, detvalores d
          WHERE m.scorreo = a.scorreo(+)
            AND a.cagente(+) = pcagente
            AND d.cvalor = 714
            AND d.catribu = m.scorreo(+)
            AND m.ctipo(+) = 17
            AND d.cidioma = 2;

      OPEN c_agentes_comp;

      FETCH c_agentes_comp
       INTO ptcorreo, pcenvcor;

      IF ptcorreo IS NOT NULL
         OR pcenvcor IS NOT NULL THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;

   /******************************************************************************
    FUNCION: F_SET_CORREO
    recuperar¿n datos tambi¿n de MENSAJES_CORREO y DESMENSAJE_CORREO
    Param in pcagente
    Param out mensajes
    Retorno 0- ok 1-ko

   ******************************************************************************/
   FUNCTION f_set_correo(
      pcagente IN NUMBER,
      ptcorreo IN agentes_comp.tcorreo%TYPE,
      pcenvcor IN agentes_comp.cenvcorreo%TYPE,
      correo IN VARCHAR2,
      envio IN NUMBER,
      codigo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_set_correo';
      vcagente       NUMBER;
   BEGIN
      BEGIN
         INSERT INTO agentes_correo
                     (scorreo, cagente, cenviar, tcorreo)
              VALUES (codigo, pcagente, envio, correo);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE agentes_correo
               SET cenviar = envio,
                   tcorreo = correo
             WHERE scorreo = codigo
               AND cagente = pcagente;
      END;

      BEGIN
         INSERT INTO agentes_comp
                     (cagente, tcorreo, cenvcorreo)
              VALUES (pcagente, ptcorreo, pcenvcor);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE agentes_comp
               SET tcorreo = ptcorreo,
                   cenvcorreo = pcenvcor
             WHERE cagente = pcagente;
      END;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END;
   
   --Inicio tarefa 4077 - Borduchi
   FUNCTION f_get_users(
       psperson IN number,
       idioma IN NUMBER,
       mensajes IN OUT t_iax_mensajes)
       RETURN sys_refcursor
       IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(2000) := 'sperson:' || psperson || ' idioma:' || idioma;
        vobject        VARCHAR2(200) := 'PAC_MD_REDCOMERCIAL.f_get_users';
        list_users sys_refcursor;
    BEGIN
        OPEN list_users FOR
            SELECT u.cusuari,
            u.tusunom,
            CASE
                WHEN md.trolmen LIKE '%CONFIBROKER' THEN 'CONFIBROKER'
                    ELSE 'CONFIRED'
                END AS tipo,
            CASE
                WHEN u.fbaja IS NULL THEN 'ACTIVO'
                    ELSE 'INACTIVO'
                END AS estatus
            FROM usuarios u
            INNER JOIN menu_usercodirol mu
                ON u.cusuari = mu.cuser AND u.sperson = psperson
            INNER JOIN menu_desrolmen md
                ON mu.crolmen = md.crolmen
            WHERE u.cidioma = idioma and md.cidioma = idioma
                AND (md.trolmen like '%CONFIBROKER' OR md.trolmen like '%CONFIRED');         
        RETURN list_users;
    EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
    END;
    --Fin tarefa 4077 - Borduchi
END pac_md_redcomercial;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_REDCOMERCIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_REDCOMERCIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_REDCOMERCIAL" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_MD_REDCOMERCIAL" TO "AXIS00";
