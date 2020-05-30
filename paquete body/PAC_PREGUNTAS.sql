--------------------------------------------------------
--  DDL for Package Body PAC_PREGUNTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PREGUNTAS" AS
   /******************************************************************************
      NOMBRE:       PAC_PREGUNTAS
      PROPÓSITO:    Funciones para realizar acciones sobre las tablas de PREGUNTAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        29/07/2009   RSC                1. Creación del package.
      2.0        08/09/2009   RSC                2. 0011075: APR - detalle de garantias
      3.0        20/11/2009   JMF                3. 0011914 CRE201 - Incidencia-ajuste en map PIAM Comú
      4.0        27/12/2010   APD                4. 0017105: Ajustes producto GROUPLIFE (III)
      5.0        09/12/2011   RSC                5. 0019312: LCOL_T004 - Parametrización Anulaciones
      6.0        13/01/2012   RSC                6. 0019715: LCOL: Migración de productos de Vida Individual
      7.0         01/02/2012  JRH                70020666: LCOL_T004-LCOL - UAT - TEC - Indicencias de Tarificaci?n
   ******************************************************************************/
   e_param_error  EXCEPTION;

   /*************************************************************************
     Función que devuelve el valor respuesta de una pregunta de garantía
     asociada a un contrato.

       param  in     psseguro : Id. seguro
       param  in     pcgarant : Id. garantía
       param  in     pnriesgo : Id. riesgo
       param  in     pcpregun : Id. de pregunta
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcrespue : Valor de la respuesta a la pregunta
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   -- Bug 10757 - RSC - 20/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emisión
   FUNCTION f_get_pregungaranseg(
      psseguro IN seguros.sseguro%TYPE,
      pcgarant IN garanseg.cgarant%TYPE,
      pnriesgo IN garanseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      pcrespue OUT pregungaranseg.crespue%TYPE,
      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      psproces IN NUMBER DEFAULT NULL
                                     --  FiBUG 20666-  01/2012 - JRH
   )
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_get_pregungaranseg';
      v_crespue      pregungaranseg.crespue%TYPE;
   BEGIN
      --Comprovació de paràmetres
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT p.crespue
           INTO pcrespue
           FROM estpregungaranseg p, estgaranseg g
          WHERE p.sseguro = psseguro
            AND p.cgarant = pcgarant
            AND p.cpregun = pcpregun
            AND p.nriesgo = pnriesgo
            AND p.sseguro = g.sseguro
            AND p.nriesgo = g.nriesgo
            AND p.cgarant = g.cgarant
            AND p.nmovimi = g.nmovimi
            AND g.ffinefe IS NULL;
      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      ELSIF ptablas = 'CAR' THEN
         SELECT p.crespue
           INTO pcrespue
           FROM pregungarancar p, garancar g
          WHERE p.sseguro = psseguro   --JRH De momento nos olvidamos del nmovimi / nmovii1
            AND p.cgarant = pcgarant
            AND p.cpregun = pcpregun
            AND p.nriesgo = pnriesgo
            AND p.sproces = psproces
            AND p.sseguro = g.sseguro
            AND p.nriesgo = g.nriesgo
            AND p.cgarant = g.cgarant
            --    AND p.finiefe = g.finiefe
            AND NVL(g.ndetgar, 0) = 0
            AND p.sproces = g.sproces;
      ELSIF ptablas = 'TMP' THEN
         SELECT p.crespue
           INTO pcrespue
           FROM pregungarancar p, tmp_garancar g
          WHERE p.sseguro = psseguro   --JRH De momento nos olvidamos del nmovimi / nmovii1
            AND p.cgarant = pcgarant
            AND p.cpregun = pcpregun
            AND p.nriesgo = pnriesgo
            AND p.sproces = psproces
            AND p.sseguro = g.sseguro
            AND p.nriesgo = g.nriesgo
            AND p.cgarant = g.cgarant
            AND NVL(g.ndetgar, 0) = 0
            -- AND p.finiefe = g.finiefe
            AND p.sproces = g.sproces;
      -- Fi BUG 20666-  01/2012 - JRH
      ELSE
         SELECT p.crespue
           INTO pcrespue
           FROM pregungaranseg p, garanseg g
          WHERE p.sseguro = psseguro
            AND p.cgarant = pcgarant
            AND p.cpregun = pcpregun
            AND p.nriesgo = pnriesgo
            AND p.sseguro = g.sseguro
            AND p.nriesgo = g.nriesgo
            AND p.cgarant = g.cgarant
            AND p.nmovimi = g.nmovimi
            AND g.ffinefe IS NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN 1000005;
      -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
      WHEN NO_DATA_FOUND THEN
         RETURN 120135;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 101919;
   END f_get_pregungaranseg;

-- Fin bug 10757

   -- ini Bug 0011914 - 20/11/2009 - JMF
   /************************************************************************************
       FF_BUSCAPREGUNSEG: Busca respuesta de una pregunta de póliza
       Primero por fecha, sino por movimiento, sino busca el último mov.
       13/11/2009: JMF bug 0011914
   *************************************************************************************/
   FUNCTION ff_buscapregunseg(
      p_seg IN NUMBER,
      p_rie IN NUMBER,
      p_pre IN NUMBER,
      p_mov IN NUMBER,
      p_fec IN DATE DEFAULT NULL)
      RETURN VARCHAR2 IS
      vobject        VARCHAR2(500) := 'PAC_PREGUNTAS.FF_BUSCAPREGUNSEG';
      vparam         VARCHAR2(500)
         := 'parámetros - s=' || p_seg || ' r=' || p_rie || ' p=' || p_pre || ' m=' || p_mov
            || 'f=' || p_fec;
      vpasexec       NUMBER(5);
      v_tiptexto     NUMBER(1);
      --v_ret          FLOAT;
      v_ret          pregunseg.trespue%TYPE;
   BEGIN
      vpasexec := 1;

      SELECT DECODE(ctippre, 4, 1, 5, 1, 0)
        INTO v_tiptexto
        FROM codipregun
       WHERE cpregun = p_pre;

      IF p_fec IS NOT NULL THEN
         vpasexec := 2;

         SELECT DECODE(v_tiptexto, 1, MAX(trespue), MAX(crespue))
           INTO v_ret
           FROM pregunseg a
          WHERE sseguro = p_seg
            AND nriesgo = p_rie
            AND cpregun = p_pre
            AND nmovimi = (SELECT MAX(c11.nmovimi)
                             FROM pregunseg c11
                            WHERE c11.sseguro = p_seg
                              AND c11.nriesgo = p_rie
                              AND c11.cpregun = p_pre
                              AND c11.nmovimi <= (SELECT MAX(b11.nmovimi)
                                                    FROM movseguro b11
                                                   WHERE b11.sseguro = p_seg
                                                     AND GREATEST(b11.fefecto, b11.femisio) <=
                                                                                          p_fec));
      ELSIF p_mov IS NOT NULL THEN
         vpasexec := 3;

         SELECT DECODE(v_tiptexto, 1, MAX(trespue), MAX(crespue))
           INTO v_ret
           FROM pregunseg a
          WHERE sseguro = p_seg
            AND nriesgo = p_rie
            AND cpregun = p_pre
            AND nmovimi = p_mov;
      ELSE
         vpasexec := 4;

         SELECT DECODE(v_tiptexto, 1, MAX(trespue), MAX(crespue))
           INTO v_ret
           FROM pregunseg a
          WHERE sseguro = p_seg
            AND nriesgo = p_rie
            AND cpregun = p_pre
            AND nmovimi = (SELECT MAX(b.nmovimi)
                             FROM pregunseg b
                            WHERE b.sseguro = p_seg
                              AND b.nriesgo = p_rie
                              AND b.cpregun = p_pre);
      END IF;

      vpasexec := 4;
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END ff_buscapregunseg;

   -- fin Bug 0011914 - 20/11/2009 - JMF

   -- ini Bug 0011914 - 20/11/2009 - JMF
   /************************************************************************************
       FF_BUSCAPREGUNPOLSEG: Busca respuesta de una pregunta de póliza
       Primero por fecha, sino por movimiento, sino busca el último mov.
       27/08/2009: JMF bug 0010893
       13/11/2009: JMF bug 0011914
   *************************************************************************************/
   FUNCTION ff_buscapregunpolseg(
      p_seg IN NUMBER,
      p_pre IN NUMBER,
      p_mov IN NUMBER,
      p_fec IN DATE DEFAULT NULL,
      p_tablas IN VARCHAR2 DEFAULT 'POL')
      RETURN FLOAT IS
      vobject        VARCHAR2(500) := 'PAC_PREGUNTAS.FF_BUSCAPREGUNPOLSEG';
      vparam         VARCHAR2(500)
           := 'parámetros - s=' || p_seg || ' p=' || p_pre || ' m=' || p_mov || ' f=' || p_fec;
      vpasexec       NUMBER(5);
      v_ret          FLOAT;
   BEGIN
      vpasexec := 1;
      IF p_tablas = 'POL' THEN
        --
        IF p_fec IS NOT NULL THEN
           vpasexec := 2;

           SELECT MAX(crespue)
             INTO v_ret
             FROM pregunpolseg a
            WHERE sseguro = p_seg
              AND cpregun = p_pre
              AND nmovimi = (SELECT MAX(c11.nmovimi)
                               FROM pregunpolseg c11
                              WHERE c11.sseguro = p_seg
                                AND c11.cpregun = p_pre
                                AND c11.nmovimi <= (SELECT MAX(b11.nmovimi)
                                                      FROM movseguro b11
                                                     WHERE b11.sseguro = p_seg
                                                       AND GREATEST(b11.fefecto, b11.femisio) <=
                                                                                            p_fec));
        ELSIF p_mov IS NOT NULL THEN
           vpasexec := 3;

           SELECT MAX(crespue)
             INTO v_ret
             FROM pregunpolseg a
            WHERE sseguro = p_seg
              AND cpregun = p_pre
              AND nmovimi = p_mov;
        ELSE
           vpasexec := 3;

           SELECT MAX(crespue)
             INTO v_ret
             FROM pregunpolseg a
            WHERE sseguro = p_seg
              AND cpregun = p_pre
              AND nmovimi = (SELECT MAX(b.nmovimi)
                               FROM pregunpolseg b
                              WHERE b.sseguro = a.sseguro);
        END IF;
        --
      ELSE
        --
        IF p_fec IS NOT NULL THEN
           vpasexec := 4;

           SELECT MAX(crespue)
             INTO v_ret
             FROM estpregunpolseg a
            WHERE sseguro = p_seg
              AND cpregun = p_pre
              AND nmovimi = (SELECT MAX(c11.nmovimi)
                               FROM estpregunpolseg c11
                              WHERE c11.sseguro = p_seg
                                AND c11.cpregun = p_pre
                                AND c11.nmovimi <= (SELECT MAX(b11.nmovimi)
                                                      FROM movseguro b11
                                                     WHERE b11.sseguro = p_seg
                                                       AND GREATEST(b11.fefecto, b11.femisio) <=
                                                                                            p_fec));
        ELSIF p_mov IS NOT NULL THEN
           vpasexec := 5;

           SELECT MAX(crespue)
             INTO v_ret
             FROM estpregunpolseg a
            WHERE sseguro = p_seg
              AND cpregun = p_pre
              AND nmovimi = p_mov;
        ELSE
           vpasexec := 6;

           SELECT MAX(crespue)
             INTO v_ret
             FROM estpregunpolseg a
            WHERE sseguro = p_seg
              AND cpregun = p_pre
              AND nmovimi = (SELECT MAX(b.nmovimi)
                               FROM estpregunpolseg b
                              WHERE b.sseguro = a.sseguro);
        END IF;
        --
      END IF;

      vpasexec := 7;
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END ff_buscapregunpolseg;

-- fin Bug 0011914 - 20/11/2009 - JMF

   /*************************************************************************
     Función que devuelve el valor respuesta de una pregunta de poliza
     asociada a un contrato.

       param  in     psseguro : Id. seguro
       param  in     pcpregun : Id. de pregunta
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcrespue : Valor de la respuesta a la pregunta
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   -- Bug 17105 - APD- 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
   FUNCTION f_get_pregunpolseg(
      psseguro IN seguros.sseguro%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      pcrespue OUT pregunpolseg.crespue%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
           := 'psseguro: ' || psseguro || ' pcpregun: ' || pcpregun || ' ptablas: ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_get_pregunpolseg';
      v_crespue      pregunpolseg.crespue%TYPE;
   BEGIN
      --Comprovació de paràmetres
      IF psseguro IS NULL
         OR pcpregun IS NULL
         OR ptablas IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT p.crespue
           INTO pcrespue
           FROM estpregunpolseg p
          WHERE p.sseguro = psseguro
            AND p.cpregun = pcpregun
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM estpregunpolseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.cpregun = p.cpregun);
      ELSE
         SELECT p.crespue
           INTO pcrespue
           FROM pregunpolseg p
          WHERE p.sseguro = psseguro
            AND p.cpregun = pcpregun
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM pregunpolseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.cpregun = p.cpregun);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN 1000005;
      WHEN NO_DATA_FOUND THEN
         RETURN 120135;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_get_pregunpolseg;

-- Fin Bug 17105

   /*************************************************************************
     Función que devuelve el valor respuesta de una pregunta de riesgo
     asociada a un contrato.

       param  in     psseguro : Id. seguro
       param  in     pnriesgo : Id. riesgo
       param  in     pcpregun : Id. de pregunta
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcrespue : Valor de la respuesta a la pregunta
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   -- Bug 17105 - APD- 27/12/2010 - APR - Ajustes producto GROUPLIFE (III)
   FUNCTION f_get_pregunseg(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN pregunseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      pcrespue OUT pregunseg.crespue%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' pcpregun: ' || pcpregun
            || ' ptablas: ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_get_pregunseg';
      v_crespue      pregunpolseg.crespue%TYPE;
   BEGIN
      --Comprovació de paràmetres
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pcpregun IS NULL
         OR ptablas IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT p.crespue
           INTO pcrespue
           FROM estpregunseg p
          WHERE p.sseguro = psseguro
            AND p.nriesgo = pnriesgo
            AND p.cpregun = pcpregun
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM estpregunseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.nriesgo = p.nriesgo
                                AND p2.cpregun = p.cpregun);
      ELSE
         SELECT p.crespue
           INTO pcrespue
           FROM pregunseg p
          WHERE p.sseguro = psseguro
            AND p.nriesgo = pnriesgo
            AND p.cpregun = pcpregun
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM pregunseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.nriesgo = p.nriesgo
                                AND p2.cpregun = p.cpregun);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN 1000005;
      WHEN NO_DATA_FOUND THEN
         RETURN 120135;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_get_pregunseg;

-- Fin Bug 17105
   FUNCTION f_get_pregungaranseg_v(
      psseguro IN seguros.sseguro%TYPE,
      pcgarant IN garanseg.cgarant%TYPE,
      pnriesgo IN garanseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      psproces IN NUMBER DEFAULT NULL
                                     --  FiBUG 20666-  01/2012 - JRH
   )
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_get_pregungaranseg_v';
      v_crespue      pregungaranseg.crespue%TYPE;
      v_numerr       NUMBER;
   BEGIN
      --Comprovació de paràmetres
      IF psseguro IS NULL
         OR pcgarant IS NULL
         OR pnriesgo IS NULL
         OR pcpregun IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Bug 20671 - APD - 17/01/2012 - se sustituye la select por la llamada a la
      -- funcion f_get_pregungaranseg ya que es la misma select
      v_numerr := f_get_pregungaranseg(psseguro, pcgarant, pnriesgo, pcpregun, ptablas,
                                       v_crespue, psproces);

      IF v_numerr <> 0 THEN
         RETURN NULL;
      END IF;

      -- fin Bug 20671 - APD - 17/01/2012
      RETURN v_crespue;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN NULL;
      -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_pregungaranseg_v;

   /*************************************************************************
     Función que devuelve el valor respuesta de una pregunta de tipo texto de poliza
     asociada a un contrato.

       param  in     psseguro : Id. seguro
       param  in     pcpregun : Id. de pregunta
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcrespue : Valor de la respuesta a la pregunta
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
   FUNCTION f_get_pregunpolseg_t(
      psseguro IN seguros.sseguro%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      ptrespue OUT pregunpolseg.trespue%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
           := 'psseguro: ' || psseguro || ' pcpregun: ' || pcpregun || ' ptablas: ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_get_pregunpolseg';
   BEGIN
      --Comprovació de paràmetres
      IF psseguro IS NULL
         OR pcpregun IS NULL
         OR ptablas IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT p.trespue
           INTO ptrespue
           FROM estpregunpolseg p
          WHERE p.sseguro = psseguro
            AND p.cpregun = pcpregun
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM estpregunpolseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.cpregun = p.cpregun);
      ELSE
         SELECT p.trespue
           INTO ptrespue
           FROM pregunpolseg p
          WHERE p.sseguro = psseguro
            AND p.cpregun = pcpregun
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM pregunpolseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.cpregun = p.cpregun);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN 1000005;
      WHEN NO_DATA_FOUND THEN
         RETURN 120135;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_get_pregunpolseg_t;

-- Fin Bug 19715
   FUNCTION f_get_pregunseg_t(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN pregunseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      ptrespue OUT pregunseg.trespue%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' pcpregun: ' || pcpregun
            || ' ptablas: ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_get_pregunseg_t';
      v_crespue      pregunpolseg.crespue%TYPE;
   BEGIN
      --Comprovació de paràmetres
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pcpregun IS NULL
         OR ptablas IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT p.trespue
           INTO ptrespue
           FROM estpregunseg p
          WHERE p.sseguro = psseguro
            AND p.nriesgo = pnriesgo
            AND p.cpregun = pcpregun
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM estpregunseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.nriesgo = p.nriesgo
                                AND p2.cpregun = p.cpregun);
      ELSE
         SELECT p.trespue
           INTO ptrespue
           FROM pregunseg p
          WHERE p.sseguro = psseguro
            AND p.nriesgo = pnriesgo
            AND p.cpregun = pcpregun
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM pregunseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.nriesgo = p.nriesgo
                                AND p2.cpregun = p.cpregun);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN 1000005;
      WHEN NO_DATA_FOUND THEN
         RETURN 120135;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_get_pregunseg_t;

   FUNCTION f_get_pregungaranseg_t(
      psseguro IN seguros.sseguro%TYPE,
      pcgarant IN garanseg.cgarant%TYPE,
      pnriesgo IN garanseg.nriesgo%TYPE,
      pcpregun IN preguntas.cpregun%TYPE,
      ptablas IN VARCHAR2,
      ptrespue OUT pregungaranseg.trespue%TYPE,
      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      psproces IN NUMBER DEFAULT NULL
                                     --  FiBUG 20666-  01/2012 - JRH
   )
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_get_pregungaranseg_t';
      v_trespue      pregungaranseg.trespue%TYPE;
   BEGIN
      --Comprovació de paràmetres
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptablas = 'EST' THEN
         SELECT p.trespue
           INTO ptrespue
           FROM estpregungaranseg p, estgaranseg g
          WHERE p.sseguro = psseguro
            AND p.cgarant = pcgarant
            AND p.cpregun = pcpregun
            AND p.nriesgo = pnriesgo
            AND p.sseguro = g.sseguro
            AND p.nriesgo = g.nriesgo
            AND p.cgarant = g.cgarant
            AND p.nmovimi = g.nmovimi
            AND g.ffinefe IS NULL;
      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      ELSIF ptablas = 'CAR' THEN
         SELECT p.trespue
           INTO ptrespue
           FROM pregungarancar p, garancar g
          WHERE p.sseguro = psseguro   --JRH De momento nos olvidamos del nmovimi / nmovii1
            AND p.cgarant = pcgarant
            AND p.cpregun = pcpregun
            AND p.nriesgo = pnriesgo
            AND p.sproces = psproces
            AND p.sseguro = g.sseguro
            AND p.nriesgo = g.nriesgo
            AND p.cgarant = g.cgarant
            --    AND p.finiefe = g.finiefe
            AND NVL(g.ndetgar, 0) = 0
            AND p.sproces = g.sproces;
      ELSIF ptablas = 'TMP' THEN
         SELECT p.trespue
           INTO ptrespue
           FROM pregungarancar p, tmp_garancar g
          WHERE p.sseguro = psseguro   --JRH De momento nos olvidamos del nmovimi / nmovii1
            AND p.cgarant = pcgarant
            AND p.cpregun = pcpregun
            AND p.nriesgo = pnriesgo
            AND p.sproces = psproces
            AND p.sseguro = g.sseguro
            AND p.nriesgo = g.nriesgo
            AND p.cgarant = g.cgarant
            AND NVL(g.ndetgar, 0) = 0
            -- AND p.finiefe = g.finiefe
            AND p.sproces = g.sproces;
      -- Fi BUG 20666-  01/2012 - JRH
      ELSE
         SELECT p.trespue
           INTO ptrespue
           FROM pregungaranseg p, garanseg g
          WHERE p.sseguro = psseguro
            AND p.cgarant = pcgarant
            AND p.cpregun = pcpregun
            AND p.nriesgo = pnriesgo
            AND p.sseguro = g.sseguro
            AND p.nriesgo = g.nriesgo
            AND p.cgarant = g.cgarant
            AND p.nmovimi = g.nmovimi
            AND g.ffinefe IS NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN 1000005;
      -- Bug 11075 - RSC - 08/09/2009 - APR - detalle de garantias
      WHEN NO_DATA_FOUND THEN
         RETURN 120135;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 101919;
   END f_get_pregungaranseg_t;

   /*************************************************************************
     Función que nos indica si una pregunta es de un plan

       param  in     pcpregun : Id. de pregunta
       param  in     psproduc  : ID del producto
       param  out    pesplan : 0- No pertenece 1 - pertenece
       return        : 0 todo OK
                       <> 0 algo KO

       Bug 27505/148732 - 19/07/2013 - AMC
   *************************************************************************/
   FUNCTION f_es_plan(
      pcpregun IN preguntas.cpregun%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pesplan OUT NUMBER)
      RETURN NUMBER IS
      vcount         NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'pcpregun: ' || pcpregun || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_es_plan';
   BEGIN
      SELECT COUNT(1)
        INTO vcount
        FROM pregunpro
       WHERE cpregun = pcpregun
         AND sproduc = psproduc
         AND cpretip = 3
         AND esccero = 1
         AND cnivel = 'R';

      IF vcount >= 1 THEN
         pesplan := 1;
      ELSE
         pesplan := 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_es_plan;

    /*************************************************************************
     Función que nos devuelve las respuestas de las preguntas tipo tabla

       param  in     pcpregun : Id. de pregunta
       param  in     psseguro  : ID del seguro
       param  out    prespuestas: sys_refcursor con las respuestas
       return        : 0 todo OK
                       <> 0 algo KO

       Bug 27923/151007 - 27/08/2013 - AMC
   *************************************************************************/
   FUNCTION f_respuestas_pregtabla(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2)
      RETURN VARCHAR2 IS
      numerr         NUMBER;
      vselect        VARCHAR2(1000);
   BEGIN
      IF ptablas = 'EST' THEN
         IF pcnivel = 'P' THEN
            vselect := 'select * from estpregunpolsegtab where sseguro = ' || psseguro
                       || ' and cpregun=' || pcpregun || ' and nmovimi=' || pnmovimi
                       || ' order by nlinea,ccolumna';
         ELSIF pcnivel = 'R' THEN
            vselect := 'select * from estpregunsegtab where sseguro = ' || psseguro
                       || ' and cpregun=' || pcpregun || ' and nmovimi=' || pnmovimi
                       || ' and nriesgo=' || pnriesgo || ' order by nlinea,ccolumna';
         ELSIF pcnivel = 'G' THEN
            vselect := 'select * from estpregungaransegtab where sseguro = ' || psseguro
                       || ' and nriesgo=' || pnriesgo || ' and cpregun=' || pcpregun
                       || ' and cgarant=' || pcgarant || ' and nmovimi=' || pnmovimi;
         END IF;
      ELSE
         IF pcnivel = 'P' THEN
            vselect := 'select * from pregunpolsegtab where sseguro = ' || psseguro
                       || ' and cpregun=' || pcpregun || ' and nmovimi=' || pnmovimi
                       || ' order by nlinea,ccolumna';
         ELSIF pcnivel = 'R' THEN
            vselect := 'select * from pregunsegtab where sseguro = ' || psseguro
                       || ' and cpregun=' || pcpregun || ' and nmovimi=' || pnmovimi
                       || ' and nriesgo=' || pnriesgo || ' order by nlinea,ccolumna';
         ELSIF pcnivel = 'G' THEN
            vselect := 'select * from pregungaransegtab where sseguro = ' || psseguro
                       || ' and nriesgo=' || pnriesgo || ' and cpregun=' || pcpregun
                       || ' and cgarant=' || pcgarant || ' and nmovimi=' || pnmovimi;
         END IF;
      END IF;

      RETURN vselect;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_preguntas.f_respuestas_pregtabla', 1,
                     'ptablas = ' || ptablas || ' psseguro = ' || psseguro || ' pnriesgo = '
                     || pnriesgo || ' pcpregun = ' || pcpregun || ' pnmovimi = ' || pnmovimi
                     || ' pcgarant = ' || pcgarant,
                     SQLERRM);
         RETURN NULL;
   END f_respuestas_pregtabla;

   FUNCTION f_traspaso_subtabs_seg(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pmodo IN VARCHAR2,
      pnlinea IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pcgarant IN NUMBER DEFAULT 0,
      pmens OUT NUMBER)
      RETURN NUMBER IS
      aux            NUMBER;
      aplanable      NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
         := 'ptablas: ' || ptablas || ' psseguro: ' || psseguro || ' pnmovimi: ' || pnmovimi
            || ' pcpregun: ' || pcpregun || ' pnriesgo: ' || pnriesgo || ' pcgarant: '
            || pcgarant || ' pnlinea: ' || pnlinea;
      vobject        VARCHAR2(200) := 'PAC_PREGUNTAS.f_traspaso_subtabs_seg';
      vcclas         VARCHAR2(200) := NULL;
      vnvals         VARCHAR2(200) := NULL;
      v_query        VARCHAR2(1000);
   BEGIN
      SELECT COUNT(*)
        INTO aplanable
        FROM preguntab_colum pc
       WHERE cpregun = pcpregun
         AND ctipcol NOT IN(1, 5);

      --Si para la pregunta hay alguna columna con tipo diferente de 1 o 5 (NUMBER), no hacemos aplanamiento
      IF aplanable = 0 THEN
         --Como la instrucción final la vamos a ejecutar a partir de un VARCHAR, vamos a guardar en vcclas y vnvals
         --las partes de dicha instrucción correspondientes a las columnas ccla's y nval's

         --Diferenciamos por pmodo y por ptablas
         IF pmodo = 'P' THEN   --Pólizas
            IF ptablas = 'EST' THEN
               --Haremos un INSERT,
               --por tanto en vcclas guardaremos una cadena del tipo -> 'x,y,null,null,null,z...'
               --y en vnvals-> 'x,y,null,z,null...'
               FOR idx IN 1 .. 10 LOOP
                  aux := 0;

                  --Claves (cclas)
                  FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                   FROM estpregunpolsegtab pt, preguntab_colum pc
                                  WHERE pt.cpregun = pc.cpregun
                                    AND pt.ccolumna = pc.ccolumn
                                    AND pc.cpregun = pcpregun
                                    AND pt.nmovimi = pnmovimi
                                    AND sseguro = psseguro
                                    AND nlinea = pnlinea
                                    AND(cclavevalor = 0
                                        OR cclavevalor IS NULL)
                               ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                     IF idx = regs.ccolumn THEN
                        IF regs.nvalor IS NOT NULL THEN
                           vcclas := vcclas || regs.nvalor || ',';
                           aux := 1;
                        ELSE
                           vcclas := vcclas || 'null,';
                           aux := 1;
                        END IF;
                     END IF;
                  END LOOP;

                  IF aux = 0 THEN
                     vcclas := vcclas || 'null,';
                  END IF;
               END LOOP;

               aux := 0;

               --Valores (nvals)
               FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                FROM estpregunpolsegtab pt, preguntab_colum pc
                               WHERE pt.cpregun = pc.cpregun
                                 AND pt.ccolumna = pc.ccolumn
                                 AND pc.cpregun = pcpregun
                                 AND pt.nmovimi = pnmovimi
                                 AND sseguro = psseguro
                                 AND nlinea = pnlinea
                                 AND cclavevalor = 1
                            ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                  IF regs.nvalor IS NOT NULL THEN
                     vnvals := vnvals || regs.nvalor;
                  ELSE
                     vnvals := vnvals || 'null';
                  END IF;

                  IF aux < 10 THEN
                     vnvals := vnvals || ',';
                  END IF;

                  aux := aux + 1;
               END LOOP;

               IF aux < 10 THEN
                  FOR idx IN aux .. 9 LOOP
                     IF idx < 9 THEN
                        vnvals := vnvals || 'null,';
                     ELSE
                        vnvals := vnvals || 'null';
                     END IF;
                  END LOOP;
               END IF;
            ELSE
               FOR idx IN 1 .. 10 LOOP
                  aux := 0;

                  FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                   FROM pregunpolsegtab pt, preguntab_colum pc
                                  WHERE pt.cpregun = pc.cpregun
                                    AND pt.ccolumna = pc.ccolumn
                                    AND pc.cpregun = pcpregun
                                    AND pt.nmovimi = pnmovimi
                                    AND sseguro = psseguro
                                    AND nlinea = pnlinea
                                    AND(cclavevalor = 0
                                        OR cclavevalor IS NULL)
                               ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                     IF idx = regs.ccolumn THEN
                        IF regs.nvalor IS NOT NULL THEN
                           vcclas := vcclas || regs.nvalor || ',';
                           aux := 1;
                        ELSE
                           vcclas := vcclas || 'null,';
                           aux := 1;
                        END IF;
                     END IF;
                  END LOOP;

                  IF aux = 0 THEN
                     vcclas := vcclas || 'null,';
                  END IF;
               END LOOP;

               aux := 0;

               FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                FROM pregunpolsegtab pt, preguntab_colum pc
                               WHERE pt.cpregun = pc.cpregun
                                 AND pt.ccolumna = pc.ccolumn
                                 AND pc.cpregun = pcpregun
                                 AND pt.nmovimi = pnmovimi
                                 AND sseguro = psseguro
                                 AND nlinea = pnlinea
                                 AND cclavevalor = 1
                            ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                  IF regs.nvalor IS NOT NULL THEN
                     vnvals := vnvals || regs.nvalor;
                  ELSE
                     vnvals := vnvals || 'null';
                  END IF;

                  IF aux < 10 THEN
                     vnvals := vnvals || ',';
                  END IF;

                  aux := aux + 1;
               END LOOP;

               IF aux < 10 THEN
                  FOR idx IN aux .. 9 LOOP
                     IF idx < 9 THEN
                        vnvals := vnvals || 'null,';
                     ELSE
                        vnvals := vnvals || 'null';
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         ELSIF pmodo = 'G' THEN   --Garantías
            IF ptablas = 'EST' THEN
               FOR idx IN 1 .. 10 LOOP
                  aux := 0;

                  FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                   FROM estpregungaransegtab pt, preguntab_colum pc
                                  WHERE pt.cpregun = pc.cpregun
                                    AND pt.ccolumna = pc.ccolumn
                                    AND pc.cpregun = pcpregun
                                    AND pt.nmovimi = pnmovimi
                                    AND sseguro = psseguro
                                    AND nlinea = pnlinea
                                    AND nriesgo = pnriesgo
                                    AND cgarant = pcgarant
                                    AND(cclavevalor = 0
                                        OR cclavevalor IS NULL)
                               ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                     IF idx = regs.ccolumn THEN
                        IF regs.nvalor IS NOT NULL THEN
                           vcclas := vcclas || regs.nvalor || ',';
                           aux := 1;
                        ELSE
                           vcclas := vcclas || 'null,';
                           aux := 1;
                        END IF;
                     END IF;
                  END LOOP;

                  IF aux = 0 THEN
                     vcclas := vcclas || 'null,';
                  END IF;
               END LOOP;

               aux := 0;

               FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                FROM estpregungaransegtab pt, preguntab_colum pc
                               WHERE pt.cpregun = pc.cpregun
                                 AND pt.ccolumna = pc.ccolumn
                                 AND pc.cpregun = pcpregun
                                 AND pt.nmovimi = pnmovimi
                                 AND sseguro = psseguro
                                 AND nlinea = pnlinea
                                 AND nriesgo = pnriesgo
                                 AND cgarant = pcgarant
                                 AND cclavevalor = 1
                            ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                  IF regs.nvalor IS NOT NULL THEN
                     vnvals := vnvals || regs.nvalor;
                  ELSE
                     vnvals := vnvals || 'null';
                  END IF;

                  IF aux < 10 THEN
                     vnvals := vnvals || ',';
                  END IF;

                  aux := aux + 1;
               END LOOP;

               IF aux < 10 THEN
                  FOR idx IN aux .. 9 LOOP
                     IF idx < 9 THEN
                        vnvals := vnvals || 'null,';
                     ELSE
                        vnvals := vnvals || 'null';
                     END IF;
                  END LOOP;
               END IF;
            ELSE   --ptablas!=EST
               FOR idx IN 1 .. 10 LOOP
                  aux := 0;

                  FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                   FROM pregungaransegtab pt, preguntab_colum pc
                                  WHERE pt.cpregun = pc.cpregun
                                    AND pt.ccolumna = pc.ccolumn
                                    AND pc.cpregun = pcpregun
                                    AND pt.nmovimi = pnmovimi
                                    AND sseguro = psseguro
                                    AND nlinea = pnlinea
                                    AND nriesgo = pnriesgo
                                    AND cgarant = pcgarant
                                    AND(cclavevalor = 0
                                        OR cclavevalor IS NULL)
                               ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                     IF idx = regs.ccolumn THEN
                        IF regs.nvalor IS NOT NULL THEN
                           vcclas := vcclas || regs.nvalor || ',';
                           aux := 1;
                        ELSE
                           vcclas := vcclas || 'null,';
                           aux := 1;
                        END IF;
                     END IF;
                  END LOOP;

                  IF aux = 0 THEN
                     vcclas := vcclas || 'null,';
                  END IF;
               END LOOP;

               aux := 0;

               FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                FROM pregungaransegtab pt, preguntab_colum pc
                               WHERE pt.cpregun = pc.cpregun
                                 AND pt.ccolumna = pc.ccolumn
                                 AND pc.cpregun = pcpregun
                                 AND pt.nmovimi = pnmovimi
                                 AND sseguro = psseguro
                                 AND nlinea = pnlinea
                                 AND nriesgo = pnriesgo
                                 AND cgarant = pcgarant
                                 AND cclavevalor = 1
                            ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                  IF regs.nvalor IS NOT NULL THEN
                     vnvals := vnvals || regs.nvalor;
                  ELSE
                     vnvals := vnvals || 'null';
                  END IF;

                  IF aux < 10 THEN
                     vnvals := vnvals || ',';
                  END IF;

                  aux := aux + 1;
               END LOOP;

               IF aux < 10 THEN
                  FOR idx IN aux .. 9 LOOP
                     IF idx < 9 THEN
                        vnvals := vnvals || 'null,';
                     ELSE
                        vnvals := vnvals || 'null';
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         ELSIF pmodo = 'R' THEN   --Riesgos
            IF ptablas = 'EST' THEN
               FOR idx IN 1 .. 10 LOOP
                  aux := 0;

                  FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                   FROM estpregunsegtab pt, preguntab_colum pc
                                  WHERE pt.cpregun = pc.cpregun
                                    AND pt.ccolumna = pc.ccolumn
                                    AND pc.cpregun = pcpregun
                                    AND pt.nmovimi = pnmovimi
                                    AND sseguro = psseguro
                                    AND nlinea = pnlinea
                                    AND nriesgo = pnriesgo
                                    AND(cclavevalor = 0
                                        OR cclavevalor IS NULL)
                               ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                     IF idx = regs.ccolumn THEN
                        IF regs.nvalor IS NOT NULL THEN
                           vcclas := vcclas || regs.nvalor || ',';
                           aux := 1;
                        ELSE
                           vcclas := vcclas || 'null,';
                           aux := 1;
                        END IF;
                     END IF;
                  END LOOP;

                  IF aux = 0 THEN
                     vcclas := vcclas || 'null,';
                  END IF;
               END LOOP;

               aux := 0;

               FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                FROM estpregunsegtab pt, preguntab_colum pc
                               WHERE pt.cpregun = pc.cpregun
                                 AND pt.ccolumna = pc.ccolumn
                                 AND pc.cpregun = pcpregun
                                 AND pt.nmovimi = pnmovimi
                                 AND sseguro = psseguro
                                 AND nlinea = pnlinea
                                 AND nriesgo = pnriesgo
                                 AND cclavevalor = 1
                            ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                  IF regs.nvalor IS NOT NULL THEN
                     vnvals := vnvals || regs.nvalor;
                  ELSE
                     vnvals := vnvals || 'null';
                  END IF;

                  IF aux < 10 THEN
                     vnvals := vnvals || ',';
                  END IF;

                  aux := aux + 1;
               END LOOP;

               IF aux < 10 THEN
                  FOR idx IN aux .. 9 LOOP
                     IF idx < 9 THEN
                        vnvals := vnvals || 'null,';
                     ELSE
                        vnvals := vnvals || 'null';
                     END IF;
                  END LOOP;
               END IF;
            ELSE   --ptablas!=EST
               FOR idx IN 1 .. 10 LOOP
                  aux := 0;

                  FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                   FROM pregunsegtab pt, preguntab_colum pc
                                  WHERE pt.cpregun = pc.cpregun
                                    AND pt.ccolumna = pc.ccolumn
                                    AND pc.cpregun = pcpregun
                                    AND pt.nmovimi = pnmovimi
                                    AND sseguro = psseguro
                                    AND nlinea = pnlinea
                                    AND nriesgo = pnriesgo
                                    AND(cclavevalor = 0
                                        OR cclavevalor IS NULL)
                               ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                     IF idx = regs.ccolumn THEN
                        IF regs.nvalor IS NOT NULL THEN
                           vcclas := vcclas || regs.nvalor || ',';
                           aux := 1;
                        ELSE
                           vcclas := vcclas || 'null,';
                           aux := 1;
                        END IF;
                     END IF;
                  END LOOP;

                  IF aux = 0 THEN
                     vcclas := vcclas || 'null,';
                  END IF;
               END LOOP;

               aux := 0;

               FOR regs IN (SELECT   pc.ccolumn, pt.nvalor
                                FROM pregunsegtab pt, preguntab_colum pc
                               WHERE pt.cpregun = pc.cpregun
                                 AND pt.ccolumna = pc.ccolumn
                                 AND pc.cpregun = pcpregun
                                 AND pt.nmovimi = pnmovimi
                                 AND sseguro = psseguro
                                 AND nlinea = pnlinea
                                 AND nriesgo = pnriesgo
                                 AND cclavevalor = 1
                            ORDER BY TO_NUMBER(ccolumna, '99') ASC) LOOP
                  IF regs.nvalor IS NOT NULL THEN
                     vnvals := vnvals || regs.nvalor;
                  ELSE
                     vnvals := vnvals || 'null';
                  END IF;

                  IF aux < 10 THEN
                     vnvals := vnvals || ',';
                  END IF;

                  aux := aux + 1;
               END LOOP;

               IF aux < 10 THEN
                  FOR idx IN aux .. 9 LOOP
                     IF idx < 9 THEN
                        vnvals := vnvals || 'null,';
                     ELSE
                        vnvals := vnvals || 'null';
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END IF;

         IF ptablas = 'EST' THEN
            v_query := 'INSERT INTO ESTSUBTABS_SEG_DET VALUES (' || psseguro || ','
                       || pnriesgo || ',' || pcgarant || ',' || pnmovimi || ',' || pcpregun
                       || ',' || pnlinea || ',' || vcclas || vnvals || ')';
         ELSE
            v_query := 'INSERT INTO SUBTABS_SEG_DET VALUES (' || psseguro || ',' || pnriesgo
                       || ',' || pcgarant || ',' || pnmovimi || ',' || pcpregun || ','
                       || pnlinea || ',' || vcclas || vnvals || ')';
         END IF;

         --Hacemos el insert
         EXECUTE IMMEDIATE v_query;
      --ELSE
        --Por tipo de los datos no se hace el aplanamiento, hay que devolver algun error?? o simplemente no se hace
        --RETURN XXXXXX; --return del numero de literal de error
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros incorrectos');
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_traspaso_subtabs_seg;
END pac_preguntas;

/

  GRANT EXECUTE ON "AXIS"."PAC_PREGUNTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PREGUNTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PREGUNTAS" TO "PROGRAMADORESCSI";
