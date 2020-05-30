CREATE OR REPLACE PACKAGE BODY pac_impuestos_conf
IS
   /******************************************************************************
      NOMBRE:     PAC_IMPUESTOS_CONF
      PROPÓSITO:  Package que contiene las funciones propias de calculo de impuestos para CONF
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        14/06/2012   JLB              1.0 22516: CONF898-Nuevas poblaciones con RETEICA
      2.0        18/06/2012   MCA              2.0 22443: Unificación de los impuestos en la pac_impuestos_CONF
      3.0        13/06/2012   JGR              3.0 23674: CONF999-Nueva opcion del regimen fiscal - 0122846
      4.0        04/03/2013   APD              4.0 0025826: CONF_T031-CONF - Fase 3 - (176-10) - Parametrización Gastos de Expedición e Impuestos
      5.0        20/11/2013   MCA              5.0 CONF: Revisión de la parametrización de impuestos
      6.0        18/04/2018   VCG              6.0 0001941: Cobro de IVA para personas exentas de IVA
      7.0        27/05/2019   ROHIT            7.0 IAXIS-3978: Gastos de expedicion en polizas
      8.0        18/06/2019   ECP              8.0 IAXIS-3628   Nota Tècnica
      9.0        26/05/2020   ECP              9.0 IAXIS-13888. Gestión Agenda
      10.0       28/05/2020   ECP              10.0 IAXIS-13945. Pagador Póliza
   ******************************************************************************/
   /*************************************************************************
   FUNCTION f_reteica_indicador:  Encontrar el valor reteica de indicadores
   param in pcagente : Codigo agente
   param out pvalor  : Porcentaje de ICA
   *************************************************************************/
   FUNCTION f_reteica_indicador (pcagente IN NUMBER)
      RETURN NUMBER
   IS
      --
      vcprovin   NUMBER;
      vcpoblac   NUMBER;
      vvalor     NUMBER;
   --
   BEGIN
      SELECT a.cprovin cprovin, a.cpoblac cpoblac
        INTO vcprovin, vcpoblac
        FROM agentes_comp a,
             agentes ag,
             per_personas p,
             (SELECT sperson, cregfiscal
                FROM per_regimenfiscal
               WHERE (sperson, fefecto) IN (SELECT   sperson, MAX (fefecto)
                                                FROM per_regimenfiscal
                                            GROUP BY sperson)) r
       WHERE ag.cagente = pcagente
         AND a.cagente = ag.cagente
         AND p.sperson = ag.sperson
         AND p.sperson = r.sperson(+);

      --
      SELECT d.porcent
        INTO vvalor
        FROM tipos_indicadores t, tipos_indicadores_det d, codpostal c
       WHERE t.carea = 2
         AND t.ctipreg = 2
         AND t.cimpret = 4
         AND t.ctipind = d.ctipind
         AND d.cpostal = c.cpostal
         AND c.cprovin = vcprovin
         AND c.cpoblac = vcpoblac;

      --
      RETURN vvalor;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         RETURN 0;
   --
   END f_reteica_indicador;

   /*************************************************************************
               FUNCTION f_reteica_provin
      Encontrar el valor reteica
      param in pcagente    : codigo agente
      param out pvalor  : devuelve el valor de la provincia para aplicar el reteica
   *************************************************************************/
   FUNCTION f_reteica_provin (pcagente IN NUMBER)
      RETURN NUMBER
   IS
      vvalor   NUMBER;
   BEGIN
      /* SELECT   DECODE(r.cregfiscal, 5, 0, 11, 0, a.cprovin) -- 3.0 23674 - 0122846 (-)*/
      /*SELECT DECODE(r.cregfiscal, 5, 0, 11, 0, 12, 0, a.cprovin)   -- 3.0 23674 - 0122846 (+)*/
      SELECT DECODE (r.cregfiscal,
                     4, 0,
                     5, 0,
                     7, 0,
                     8, 0,
                     12, 0,
                     a.cprovin
                    )                               /* Bug 28971  20/11/2013*/
        INTO vvalor
        FROM agentes_comp a,
             agentes ag,
             per_personas p,
             (SELECT sperson, cregfiscal
                FROM per_regimenfiscal
               WHERE (sperson, fefecto) IN (SELECT   sperson, MAX (fefecto)
                                                FROM per_regimenfiscal
                                            GROUP BY sperson)) r
       WHERE ag.cagente = pcagente
         AND a.cagente = ag.cagente
         AND p.sperson = ag.sperson
         AND p.sperson = r.sperson(+);

      RETURN vvalor;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_impuestos_CONF.f_reteica_provin',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 0;
   END f_reteica_provin;

   /*************************************************************************
              FUNCTION f_reteica_poblac
     Encontrar el valor reteica
     param in pcagente    : codigo agente
     param out pvalor  : devuelve el valor de la provincia para aplicar el reteica
   *************************************************************************/
   FUNCTION f_reteica_poblac (pcagente IN NUMBER)
      RETURN NUMBER
   IS
      vvalor   NUMBER;
   BEGIN
      /* SELECT   DECODE(r.cregfiscal, 5, 0, 11, 0, a.cpoblac)  -- 3.0 23674 - 0122846 (-)*/
      /*SELECT DECODE(r.cregfiscal, 5, 0, 11, 0, 12, 0, a.cpoblac)   -- 3.0 23674 - 0122846 (+)*/
      SELECT DECODE (r.cregfiscal,
                     4, 0,
                     5, 0,
                     7, 0,
                     8, 0,
                     12, 0,
                     a.cpoblac
                    )                               /* Bug 28971  20/11/2013*/
        INTO vvalor
        FROM agentes_comp a,
             agentes ag,
             per_personas p,
             (SELECT sperson, cregfiscal
                FROM per_regimenfiscal
               WHERE (sperson, fefecto) IN (SELECT   sperson, MAX (fefecto)
                                                FROM per_regimenfiscal
                                            GROUP BY sperson)) r
       WHERE a.cagente = pcagente
         AND a.cagente = ag.cagente
         AND p.sperson = ag.sperson
         AND p.sperson = r.sperson(+);

      RETURN vvalor;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_impuestos_CONF.f_reteica_poblac',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 0;
   END f_reteica_poblac;

   /*Ini Bug: 22443  MCA Unificación de los impuestos*/
   /*************************************************************************
            FUNCTION f_retefuente
      Encontrar el valor retefuente
      param in pcagente    : codigo agente
      param out pretefuente  : devuelve el valor del retefuente a buscar dentro de las vigencias
   *************************************************************************/
   FUNCTION f_retefuente (pcagente IN NUMBER)
      RETURN NUMBER
   IS
      vvalor   NUMBER;
   BEGIN
      IF pcagente IS NOT NULL
      THEN
         --
         BEGIN
            --
            SELECT DECODE
                      (r.cregfiscal,
                       6, 0,
                       8, 0,
                       DECODE (p.ctipper, 1, 1, 2)
                      ) -- Regimen Comun Y  Gran contribuyente, Auto-retenedor
              INTO vvalor
              FROM agentes a,
                   per_personas p,
                   (SELECT sperson, cregfiscal
                      FROM per_regimenfiscal
                     WHERE (sperson, fefecto) IN (
                                                 SELECT   sperson,
                                                          MAX (fefecto)
                                                     FROM per_regimenfiscal
                                                 GROUP BY sperson)) r
             WHERE a.cagente = pcagente
               AND p.sperson = a.sperson
               AND p.sperson = r.sperson(+);
         END;
      END IF;

      RETURN vvalor;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IMPUESTOS_CONF.f_retefuente',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 0;
   END f_retefuente;

   /* INI - JLB - BUG 22578*/
   /*************************************************************************
           FUNCTION f_iva_provinciariesgo
     Encontrar el valor de la provincia de localización del riesgo para saber que tipo de iva se aplica
     param in ptabla      : tablas de origen
     param in psseguro    : seguro
     param out pvalor  : devuelve el valor de la provincia para aplicar el el iva
   *************************************************************************/
   FUNCTION f_iva_provinciariesgo (
      ptabla     IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vcobjase     seguros.cobjase%TYPE;
      vprovincia   NUMBER;
      vsproduc     NUMBER;                                          --bartolo
   BEGIN
      --IAXIS -13888 -- 26/05/2020
      IF ptabla = 'EST'
      THEN
         BEGIN
            SELECT cobjase, sproduc
              INTO vcobjase, vsproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT cobjase, sproduc
                    INTO vcobjase, vsproduc
                    FROM seguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
         END;

         /* De momento solo consideramos riesgos personas*/
         IF vcobjase = 1
         THEN
            /*persona*/
            SELECT dir.cprovin
              INTO vprovincia
              FROM estper_direcciones dir, esttomadores tom
             WHERE sseguro = psseguro
               AND dir.sperson = tom.sperson
               AND dir.cdomici = tom.cdomici;

            IF vsproduc = 8062
            THEN                                                     --bartolo
               SELECT SUBSTR (p.crespue, 1, LENGTH (p.crespue) - 3)
                 INTO vprovincia
                 FROM estpregunpolseg p
                WHERE p.sseguro = psseguro AND p.cpregun = 6561;
            END IF;                                                  --bartolo
         ELSIF vcobjase = 2
         THEN
            /* sitriesgo*/
            SELECT cprovin
              INTO vprovincia
              FROM estsitriesgo
             WHERE sseguro = psseguro AND nriesgo = pnriesgo;
         /* Bug 25826 - APD - 04/03/2013*/
         ELSIF vcobjase = 3
         THEN
             /* domicilio*/
            -- Ini  IAXIS-3628  -- ECP -- 18/06/2019
            begin
            SELECT SUBSTR (p.crespue, 1, LENGTH (p.crespue) - 3)
              INTO vprovincia
              FROM estpregunseg p
             WHERE p.sseguro = psseguro
               AND p.nriesgo = pnriesgo
               AND p.cpregun = 2886
               AND p.nmovimi =
                      (SELECT MAX (a.nmovimi)
                         FROM estpregunseg a
                        WHERE a.sseguro = p.sseguro
                          AND a.nriesgo = p.nriesgo
                          AND a.cpregun = p.cpregun);
             exception when no_data_found then
                begin
            SELECT SUBSTR (p.crespue, 1, LENGTH (p.crespue) - 3)
              INTO vprovincia
              FROM pregunseg p
             WHERE p.sseguro = psseguro
               AND p.nriesgo = pnriesgo
               AND p.cpregun = 2886
               AND p.nmovimi =
                      (SELECT MAX (a.nmovimi)
                         FROM pregunseg a
                        WHERE a.sseguro = p.sseguro
                          AND a.nriesgo = p.nriesgo
                          AND a.cpregun = p.cpregun);
             exception when no_data_found then
              null;
             end;
             end;
         /* CONF-190 AP */
         ELSIF vcobjase = 5
         THEN
            /* autos*/
            SELECT cprovin
              INTO vprovincia
              FROM estper_direcciones dir, estautconductores aut
             WHERE aut.sseguro = psseguro
               AND aut.nriesgo = pnriesgo
               AND aut.cprincipal = 1
               AND dir.sperson = aut.sperson
               AND dir.cdomici = aut.cdomici;
         /* fin Bug 25826 - APD - 04/03/2013*/
         ELSIF vcobjase = 4
         THEN
            IF vsproduc = 8063
            THEN
               SELECT SUBSTR (p.crespue, 1, LENGTH (p.crespue) - 3)
                 INTO vprovincia
                 FROM estpregunpolseg p
                WHERE p.sseguro = psseguro AND p.cpregun = 6561;
            END IF;
         ELSE
            NULL;
         END IF;
      ELSE
         /* tablas reales*/
         SELECT cobjase, sproduc
           INTO vcobjase, vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         /* De momento solo consideramos riesgos personas*/
         IF vcobjase = 1
         THEN
            SELECT dir.cprovin
              INTO vprovincia
              FROM per_direcciones dir, tomadores tom
             WHERE sseguro = psseguro
               AND dir.sperson = tom.sperson
               AND dir.cdomici = tom.cdomici;
         ELSIF vcobjase = 2
         THEN
            /* sitriesgo*/
            SELECT cprovin
              INTO vprovincia
              FROM sitriesgo
             WHERE sseguro = psseguro AND nriesgo = pnriesgo;
         /* Bug 25826 - APD - 04/03/2013*/
         ELSIF vcobjase = 3
         THEN
            /* domicilio*/
            SELECT SUBSTR (p.crespue, 1, LENGTH (p.crespue) - 3)
              INTO vprovincia
              FROM pregunseg p
             WHERE p.sseguro = psseguro
               AND p.nriesgo = pnriesgo
               AND p.cpregun = 2886
               AND p.nmovimi =
                      (SELECT MAX (a.nmovimi)
                         FROM pregunseg a
                        WHERE a.sseguro = p.sseguro
                          AND a.nriesgo = p.nriesgo
                          AND a.cpregun = p.cpregun);
         -- IAXIS - 3628 -- ECP -- 18/06/2019
         ELSIF vcobjase = 5
         THEN
            /* autos*/
            SELECT cprovin
              INTO vprovincia
              FROM per_direcciones dir, autconductores aut
             WHERE dir.sperson = aut.sperson
               AND dir.cdomici = aut.cdomici
               AND aut.sseguro = psseguro
               AND aut.nriesgo = pnriesgo
               AND aut.cprincipal = 1
               AND aut.nmovimi =
                      (SELECT MAX (aut2.nmovimi)
                         FROM autconductores aut2
                        WHERE aut.sseguro = aut2.sseguro
                          AND aut.nriesgo = aut2.nriesgo
                          AND aut.norden = aut2.norden);
         /* fin Bug 25826 - APD - 04/03/2013*/
         ELSIF vcobjase = 4
         THEN
            IF vsproduc = 8063
            THEN
               SELECT SUBSTR (p.crespue, 1, LENGTH (p.crespue) - 3)
                 INTO vprovincia
                 FROM pregunpolseg p
                WHERE p.sseguro = psseguro
                  AND p.cpregun = 6561
                  AND p.nmovimi =
                         (SELECT MAX (a.nmovimi)
                            FROM pregunpolseg a
                           WHERE a.sseguro = p.sseguro
                             AND a.cpregun = p.cpregun);
            END IF;
         ELSE
            NULL;
         END IF;
      END IF;

      --IAXIS -13888 -- 26/05/2020
      RETURN vprovincia;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IMPUESTOS_CONF.f_iva_provinciariesgo',
                      1,
                      SQLCODE,
                         SQLERRM
                      || 'vcobjase '
                      || vcobjase
                      || 'ptablas'
                      || ptabla
                      || 'passeguro'
                      || psseguro
                     );
         RETURN 0;
   END;

   /*************************************************************************
                                                                     FUNCTION f_iva_poblacionriesgo
     Encontrar el valor de la poblacion de localización del riesgo para saber que tipo de iva se aplica
     param in ptabla      : tablas de origen
     param in psseguro    : sseguro
     param out pvalor     :devuelve el valor de la poblacion para aplicar el reteica
   *************************************************************************/
   FUNCTION f_iva_poblacionriesgo (
      ptabla     IN   VARCHAR2,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vcpoblac   NUMBER;
      vcobjase   seguros.cobjase%TYPE;
   BEGIN
      IF ptabla = 'EST'
      THEN
         SELECT cobjase
           INTO vcobjase
           FROM estseguros
          WHERE sseguro = psseguro;

         /* De momento solo consideramos riesgos personas*/
         IF vcobjase = 1
         THEN
            /*persona*/
            SELECT dir.cpoblac
              INTO vcpoblac
              FROM estper_direcciones dir, esttomadores tom
             WHERE sseguro = psseguro
               AND dir.sperson = tom.sperson
               AND dir.cdomici = tom.cdomici;
         ELSIF vcobjase = 2
         THEN
            /* sitriesgo*/
            SELECT cpoblac
              INTO vcpoblac
              FROM estsitriesgo
             WHERE sseguro = psseguro AND nriesgo = pnriesgo;
         /* Bug 25826 - APD - 04/03/2013*/
         ELSIF vcobjase = 5
         THEN
            /* autos*/
            SELECT cpoblac
              INTO vcpoblac
              FROM estper_direcciones dir, estautconductores aut
             WHERE aut.sseguro = psseguro
               AND aut.nriesgo = pnriesgo
               AND aut.cprincipal = 1
               AND dir.sperson = aut.sperson
               AND dir.cdomici = aut.cdomici;
         /* fin Bug 25826 - APD - 04/03/2013*/
         ELSE
            NULL;
         END IF;
      ELSE
         /* tablas reales*/
         SELECT cobjase
           INTO vcobjase
           FROM seguros
          WHERE sseguro = psseguro;

         /* De momento solo consideramos riesgos personas*/
         IF vcobjase = 1
         THEN
            SELECT dir.cpoblac
              INTO vcpoblac
              FROM per_direcciones dir, tomadores tom
             WHERE sseguro = psseguro
               AND dir.sperson = tom.sperson
               AND dir.cdomici = tom.cdomici;
         ELSIF vcobjase = 2
         THEN
            /* sitriesgo*/
            SELECT cpoblac
              INTO vcpoblac
              FROM sitriesgo
             WHERE sseguro = psseguro AND nriesgo = pnriesgo;
         /* Bug 25826 - APD - 04/03/2013*/
         ELSIF vcobjase = 5
         THEN
            /* autos*/
            SELECT cpoblac
              INTO vcpoblac
              FROM per_direcciones dir, autconductores aut
             WHERE dir.sperson = aut.sperson
               AND dir.cdomici = aut.cdomici
               AND aut.sseguro = psseguro
               AND aut.nriesgo = pnriesgo
               AND aut.cprincipal = 1
               AND aut.nmovimi =
                      (SELECT MAX (aut2.nmovimi)
                         FROM autconductores aut2
                        WHERE aut.sseguro = aut2.sseguro
                          AND aut.nriesgo = aut2.nriesgo
                          AND aut.norden = aut2.norden);
         /* fin Bug 25826 - APD - 04/03/2013*/
         ELSE
            NULL;
         END IF;
      END IF;

      RETURN vcpoblac;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IMPUESTOS_CONF.f_iva_poblacionriesgo',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 0;
   END;

   -- INI - CONF-190 -- AP
   /*************************************************************************
   FUNCTION F_ENTIDAD_EXC_IVA
   Encontrar si el tomador es una persona (entidad) sin ánimo de lucro exenta de IVA
   param in ptabla      : tablas de origen
   param in psseguro    : seguro
   param out pvalor     : devuelve 1 si la entidad es sin ánimo de lucro exenta de iva y 0 si no
   *************************************************************************/
   /*QT-1941-VC-18/04/2018 - Se modifica la consulta*/
   FUNCTION f_entidad_exc_iva (ptabla IN VARCHAR2, psseguro IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_entidad_exc_iva
      IS
         SELECT reg.cregfiscal, reg.ctipiva
           FROM per_regimenfiscal reg, tomadores tom
          WHERE tom.sseguro = psseguro
            AND reg.sperson = tom.sperson
            AND reg.fefecto =
                   (SELECT MAX (reg.fefecto)
                      FROM per_regimenfiscal reg
                     WHERE reg.sperson = tom.sperson
                       AND TRUNC (reg.fefecto) < = TRUNC (f_sysdate));

      CURSOR c_est_entidad_exc_iva
      IS
         SELECT reg.cregfiscal, reg.ctipiva
           FROM estper_regimenfiscal reg, esttomadores tom
          WHERE tom.sseguro = psseguro
            AND reg.sperson = tom.sperson
            AND reg.fefecto =
                   (SELECT MAX (reg.fefecto)
                      FROM estper_regimenfiscal reg
                     WHERE reg.sperson = tom.sperson
                       AND TRUNC (reg.fefecto) < = TRUNC (f_sysdate));

      c_entidad_exc_iva_r       c_entidad_exc_iva%ROWTYPE;
      c_est_entidad_exc_iva_r   c_est_entidad_exc_iva%ROWTYPE;
      v_retorno                 NUMBER                          := 0;
      v_real                    NUMBER                          := 0;
                                                                     --QT-1941
      v_est                     NUMBER                          := 0;
                                                                     --QT-1941
   BEGIN
      --QT-1941
      SELECT COUNT (0)
        INTO v_real
        FROM per_regimenfiscal reg, tomadores tom
       WHERE tom.sseguro = psseguro
         AND reg.sperson = tom.sperson
         AND reg.fefecto =
                (SELECT MAX (reg.fefecto)
                   FROM per_regimenfiscal reg
                  WHERE reg.sperson = tom.sperson
                    AND TRUNC (reg.fefecto) < = TRUNC (f_sysdate));

      --QT-1941
      SELECT COUNT (0)
        INTO v_est
        FROM estper_regimenfiscal reg, esttomadores tom
       WHERE tom.sseguro = psseguro
         AND reg.sperson = tom.sperson
         AND reg.fefecto =
                (SELECT MAX (reg.fefecto)
                   FROM estper_regimenfiscal reg
                  WHERE reg.sperson = tom.sperson
                    AND TRUNC (reg.fefecto) < = TRUNC (f_sysdate));

      IF v_est > 0                                                   --QT-1941
      THEN
         OPEN c_est_entidad_exc_iva;

         FETCH c_est_entidad_exc_iva
          INTO c_est_entidad_exc_iva_r;

         IF     c_est_entidad_exc_iva_r.cregfiscal = 2
            AND c_est_entidad_exc_iva_r.ctipiva = 3
         THEN
            v_retorno := 1;
         ELSE
            v_retorno := 0;
         END IF;

         IF c_est_entidad_exc_iva%ISOPEN
         THEN
            CLOSE c_est_entidad_exc_iva;
         END IF;
      ELSIF v_real > 0
      THEN                                                           --QT-1941
         OPEN c_entidad_exc_iva;

         FETCH c_entidad_exc_iva
          INTO c_entidad_exc_iva_r;

         IF     c_entidad_exc_iva_r.cregfiscal = 2
            AND c_entidad_exc_iva_r.ctipiva = 3
         THEN
            v_retorno := 1;
         ELSE
            v_retorno := 0;
         END IF;

         IF c_entidad_exc_iva%ISOPEN
         THEN
            CLOSE c_entidad_exc_iva;
         END IF;
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IMPUESTOS_CONF.f_entidad_exc_iva',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 0;
   END f_entidad_exc_iva;

   -- FIN -- CONF-190 -- AP

   /*************************************************************************
   FUNCTION f_gastos_expedicion
   Encontrar el valor los gastos de expedicion según producto y moneda
   param in ptabla      : tablas de origen
   param in psseguro    : sseguro
   param out pvalor     :devuelve el valor de los gastos en la moneda produto
   *************************************************************************/
   -- Inicio IAXIS-3978 27/05/2019
   /*****************************************************************************
   Insert/update required records to configure  the expedition expenses for policies.
   ADDED n_cagente to fect agente, n_cempres for cempress and
   PAC_SUBTABLAS.F_VSUBTABLA to calculate the expedition expenses for policies
   for NUEVA PRODUCCION AND ENDORSEMENTS
   ************************************************************************ */
   FUNCTION f_gastos_expedicion (
      porigen    IN   NUMBER,
      psseguro   IN   NUMBER,
      pnriesgo   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_retorno    NUMBER                           := 0;
      n_producto   NUMBER;
      n_cagente    NUMBER;
      n_cempres    sgt_subtabs_det.cempres%TYPE     := 24;
      v_ctipage    NUMBER;
      v_subtabla   sgt_subtabs_det.csubtabla%TYPE;
   BEGIN
      --IAXIS-13888 -- 26/05/2020
      IF porigen = 1
      THEN
         BEGIN
            SELECT p.sproduc, s.cagente
              INTO n_producto, n_cagente
              FROM productos p, estseguros s
             WHERE s.sproduc = p.sproduc AND sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT p.sproduc, s.cagente
                    INTO n_producto, n_cagente
                    FROM productos p, seguros s
                   WHERE s.sproduc = p.sproduc AND sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
         END;
      ELSE
         SELECT p.sproduc, cagente
           INTO n_producto, n_cagente
           FROM productos p, seguros s
          WHERE s.sproduc = p.sproduc AND sseguro = psseguro;
      END IF;

      SELECT ctipage
        INTO v_ctipage
        FROM redcomercial
       WHERE cagente = n_cagente
         AND cempres = n_cempres
         AND fmovini <= SYSDATE
         AND (fmovfin > SYSDATE OR fmovfin IS NULL);

      -- Tarifas de gastos de expedición para endosos
      IF pac_iax_produccion.issuplem
      THEN
         v_subtabla := 9000015;
      -- Tarifas de gastos de expedición para nuevos negocios
      ELSE
         v_subtabla := 9000014;
      END IF;

      IF v_ctipage IN (0, 1, 2, 3)
      THEN
         v_retorno :=
            pac_subtablas.f_vsubtabla (-1,
                                       v_subtabla,
                                       '33',
                                       1,
                                       n_producto,
                                       n_cagente
                                      );
      ELSE
         v_retorno :=
            pac_subtablas.f_vsubtabla
                                  (-1,
                                   v_subtabla,
                                   '33',
                                   1,
                                   n_producto,
                                   pac_redcomercial.f_busca_padre (n_cempres,
                                                                   n_cagente,
                                                                   NULL,
                                                                   SYSDATE
                                                                  )
                                  );
      END IF;

--IAXIS-13888 -- 26/05/2020
      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IMPUESTOS_CONF.f_gastos_expedicion',
                      1,
                      SQLCODE,
                      SQLERRM || 'pnorigen' || porigen || 'passeguro'
                      || psseguro
                     );
         RETURN 0;
   END f_gastos_expedicion;

   -- Fin IAXIS-3978 27/05/2019
   /*************************************************************************
   FUNCTION f_indicador_agente:  Encontrar indicadores
   param in pcagente : Codigo agente
   param in pcimpret : Impuesto (1-IVA 2-Retefuente 3-ReteIVA 4-ReteICA 5-Ipoconsumo)
   return            : indicador
   *************************************************************************/
   FUNCTION f_indicador_agente (
      pcagente   IN   NUMBER,
      pcimpret   IN   NUMBER,
      pfecha     IN   DATE
   )
      RETURN VARCHAR2
   IS
      --
      vcprovin    NUMBER;
      vcpoblac    NUMBER;
      v_valor     NUMBER;
      v_porcent   NUMBER;
      v_ctipind   NUMBER;
      v_fecha     DATE          := NVL (pfecha, f_sysdate);
      v_indic     VARCHAR2 (10);
   --
   BEGIN
      --
      IF pcimpret = 1
      THEN
         v_porcent := NVL (pac_agentes.f_get_tipiva (pcagente, pfecha), 0);
      ELSIF pcimpret = 2
      THEN
         v_porcent :=
            vtramo (nsesion      => -1,
                    ntramo       => 800064,
                    vbuscar      => f_retefuente (pcagente => pcagente)
                   );
      ELSIF pcimpret = 3
      THEN
         --
         v_porcent := NVL (pac_agentes.f_get_reteniva (pcagente, v_fecha), 0);

         --
         BEGIN
            --
            SELECT ctipind
              INTO v_ctipind
              FROM retenciones ret, agentes ag
             WHERE ag.cagente = pcagente
               AND ret.cretenc = ag.cretenc
               AND TRUNC (v_fecha) >= TRUNC (finivig)
               AND TRUNC (v_fecha) < TRUNC (NVL (ffinvig, v_fecha + 1));
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               --
               v_ctipind := NULL;
         --
         END;
      --
      ELSIF pcimpret = 4
      THEN
         --
         SELECT a.cprovin cprovin, a.cpoblac cpoblac
           INTO vcprovin, vcpoblac
           FROM agentes_comp a, agentes ag
          WHERE a.cagente = pcagente AND a.cagente = ag.cagente;

         --
         SELECT t.ccindid || t.cindsap
           INTO v_indic
           FROM tipos_indicadores t, tipos_indicadores_det d, codpostal c
          WHERE t.carea = 2
            AND t.ctipreg = 2
            AND t.cimpret = 4
            AND t.ctipind = d.ctipind
            AND d.cpostal = c.cpostal
            AND c.cprovin = vcprovin
            AND c.cpoblac = vcpoblac;

         --
         --Retorna indicadores
         RETURN v_indic;
      --
      END IF;

      --
      --Retorna indicadores
      SELECT t.ccindid || t.cindsap
        INTO v_indic
        FROM tipos_indicadores t, tipos_indicadores_det d
       WHERE t.carea = 2
         AND t.cimpret = pcimpret
         AND t.ctipind = d.ctipind
         AND d.porcent = v_porcent
         AND d.fvigor <= v_fecha
         AND t.ctipind = NVL (v_ctipind, t.ctipind)
         AND ROWNUM = 1;

      --
      RETURN v_indic;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         RETURN v_indic;
   --
   END f_indicador_agente;

   --
   /*************************************************************************
      FUNCTION f_busca_padre
      Retorna el agente padre con CTIPAGE  IN (2,3) del agente que se especifica
      param in pcagente      : cagente
   *************************************************************************/
   -- CONF 403 - JVG - 20/10/2017 - se crea la funcion
   FUNCTION f_busca_padre (pcagente IN NUMBER)
      RETURN NUMBER
   IS
      v_padre     NUMBER;
      v_ctipage   NUMBER;
      v_fbusca    DATE   := f_sysdate;
   BEGIN
      SELECT DISTINCT ctipage
                 INTO v_ctipage
                 FROM agentes
                WHERE ctipage NOT IN (0, 1, 7) AND cagente = pcagente;

      --
      IF v_ctipage = 2
      THEN
         SELECT cagente
           INTO v_padre
           FROM agentes
          WHERE ctipage IN (2) AND cagente = pcagente;

         --
         RETURN v_padre;
      END IF;

      --
      IF v_ctipage = 3
      THEN
         SELECT cagente
           INTO v_padre
           FROM agentes
          WHERE ctipage IN (3) AND cagente = pcagente;

         --
         RETURN v_padre;
      END IF;

      --
      IF v_ctipage IN (4, 5, 6)
      THEN
         SELECT cpadre
           INTO v_padre
           FROM redcomercial
          WHERE cagente = pcagente
            AND cpadre IN (SELECT cagente
                             FROM agentes
                            WHERE ctipage IN (2, 3))
            AND fmovini <= v_fbusca
            AND (fmovfin > v_fbusca OR fmovfin IS NULL);

         --
         RETURN v_padre;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_impuestos_conf.f_busca_padre',
                      2,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN NULL;
   END f_busca_padre;

   /*************************************************************************
       FUNCTION f_indicador_primas_emitidas
       Retorna el indicador de los impuestos de la emisi?n de primas (iva solamente)
       param in psperson : sperson
       param in pfbusca       : f_sysdate
    *************************************************************************/-- CONF 403 - JVG - 23/10/2017 - se crea la funcion
   FUNCTION f_indicador_primas_emitidas (psperson IN NUMBER, pfecha IN DATE)
      RETURN VARCHAR2
   IS
      --
      pcimpret    NUMBER        := 1;
      v_porcent   NUMBER;
      v_ctipind   NUMBER;
      v_fecha     DATE          := NVL (pfecha, f_sysdate);
      v_indic     VARCHAR2 (10);
   --
   BEGIN
      --
      IF pcimpret = 1
      THEN
         --
         v_porcent := NVL (pac_persona.f_get_tipiva (psperson, pfecha), 0);

         --
         BEGIN
            --
            SELECT ctipind
              INTO v_ctipind
              FROM tipoiva tiv, per_regimenfiscal p
             WHERE p.sperson = psperson
               AND tiv.ctipiva = p.ctipiva
               AND p.fefecto = (SELECT MAX (fefecto)
                                  FROM per_regimenfiscal
                                 WHERE sperson = psperson)
               AND TRUNC (v_fecha) >= TRUNC (tiv.finivig)
               AND TRUNC (v_fecha) < TRUNC (NVL (tiv.ffinvig, v_fecha + 1));
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               --
               v_ctipind := NULL;
         --
         END;
      END IF;

      --
      --Retorna indicadores
      SELECT t.ccindid || t.cindsap
        INTO v_indic
        FROM tipos_indicadores t, tipos_indicadores_det d
       WHERE t.carea = 4
         AND t.cimpret = pcimpret
         AND t.ctipind = d.ctipind
         AND d.porcent = v_porcent
         AND d.fvigor <= v_fecha
         AND t.ctipind = NVL (v_ctipind, t.ctipind)
         AND ROWNUM = 1;

      --
      RETURN v_indic;
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         RETURN v_indic;
   --
   END f_indicador_primas_emitidas;

   --
   /*************************************************************************
      FUNCTION f_indicador_Coa_Rea
      Retorna el indicador de los impuestos de la compañia coaseguradora y reaseguradora
      param in pccompani  : ccompani
      param in pctipcoa   : ctipcoa
      param in pfbusca    : f_sysdate
      param out pvalor    : Indicador impuesto SAP
   *************************************************************************/
   -- CONF 403 - JVG - 27/10/2017 - se crea la funcion
   FUNCTION f_indicador_coa_rea (
      pccompani   IN   NUMBER,
      pcimpret    IN   NUMBER,
      pctipcoa    IN   NUMBER,
      pfecha      IN   DATE
   )
      RETURN VARCHAR2
   IS
      v_ctipind   NUMBER;
      v_porcent   NUMBER;
      v_fecha     DATE          := NVL (pfecha, f_sysdate);
      v_indic     VARCHAR2 (10);
      v_indic1    VARCHAR2 (10);
   BEGIN
      IF pcimpret = 1
      THEN
         v_porcent := NVL (pac_companias.f_get_tipiva (pccompani, pfecha), 0);

         BEGIN
            --
            SELECT ctipind
              INTO v_ctipind
              FROM tipoiva tiv, companias c
             WHERE c.ccompani = pccompani
               AND tiv.ctipiva = c.ctipiva
               AND TRUNC (pfecha) >= TRUNC (finivig)
               AND TRUNC (pfecha) < TRUNC (NVL (ffinvig, pfecha + 1));
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               v_ctipind := NULL;
         END;
      END IF;

      IF pcimpret = 2
      THEN
         v_porcent :=
            vtramo
               (nsesion      => -1,
                ntramo       => 800064,
                vbuscar      => pac_companias.f_retefuente
                                                       (pccompani      => pccompani)
               );
      END IF;

      IF v_porcent IN (0, 1)
      THEN
         --Retorna indicadores
         SELECT t.ccindid || t.cindsap
           INTO v_indic
           FROM tipos_indicadores t, tipos_indicadores_det d
          WHERE t.carea IN (1, 4)
            AND t.cimpret = pcimpret
            AND t.ctipind = d.ctipind
            AND d.porcent = v_porcent
            AND d.fvigor <= v_fecha
            AND t.ctipind = NVL (v_ctipind, t.ctipind)
            AND ROWNUM = 1;
      END IF;

      IF v_porcent NOT IN (0, 1)
      THEN
         -- --Retorna indicadores COA (1,8)  REA (0)
         SELECT t.ccindid || t.cindsap
           INTO v_indic1
           FROM tipos_indicadores t, tipos_indicadores_det d
          WHERE t.carea IN (1, 4)
            AND t.cimpret = pcimpret
            AND t.ctipind = d.ctipind
            AND d.porcent = v_porcent
            AND d.fvigor <= v_fecha
            AND t.ctipcoarea = pctipcoa
            AND ROWNUM = 1;
      END IF;

      RETURN NVL (v_indic, v_indic1);
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_impuestos_conf.f_indicador_Coa_Rea',
                      1,
                         'pccompani = '
                      || pccompani
                      || '; pfecha = '
                      || TO_CHAR (pfecha, 'dd/mm/yyyy'),
                      SQLERRM
                     );
         RETURN NULL;
   END f_indicador_coa_rea;

   /*************************************************************************
   FUNCTION f_reteica_indicador_coa:  Encontrar el valor reteica de indicadores
   param in pccompania : Codigo Compañía
   param out pvalor  : Porcentaje de ICA
   *************************************************************************/
   FUNCTION f_reteica_indicador_coa (pccompania IN NUMBER)
      RETURN NUMBER
   IS
      --
      vcpostal   NUMBER;
      vvalor     NUMBER;
      varea      NUMBER;
--
   BEGIN
      varea :=
         pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa (),
                                        'AREA_RETEICA_COA'
                                       );

      SELECT cpostal
        INTO vcpostal
        FROM codpostal
       WHERE (cprovin, cpoblac) IN (
                SELECT cprovin, cpoblac
                  FROM per_direcciones pd
                 WHERE sperson = (SELECT sperson
                                    FROM companias
                                   WHERE ccompani = pccompania)
                   AND cdomici = (SELECT MIN (cdomici)
                                    FROM per_direcciones
                                   WHERE sperson = pd.sperson));

      --
      SELECT d.porcent
        INTO vvalor
        FROM tipos_indicadores t, tipos_indicadores_det d
       WHERE t.carea = varea
         AND t.ctipreg = 2
         AND t.cimpret = 4
         AND t.ctipind = d.ctipind
         AND d.cpostal = vcpostal;

      --
      RETURN vvalor;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_IMPUESTOS_CONF.F_RETEICA_INDICADOR_COA',
                      0,
                      SQLERRM,
                      SQLCODE,
                      0
                     );
         RETURN 0;
--
   END f_reteica_indicador_coa;
END pac_impuestos_conf;
/
