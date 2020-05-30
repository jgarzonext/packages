--------------------------------------------------------
--  DDL for Function F_BUSCA_PCOMISI_CONCEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCA_PCOMISI_CONCEP" (
   psseguro IN NUMBER,
   pcgarant IN NUMBER,
   pcconcep IN NUMBER,
   pcmodcom IN NUMBER,
   pfecha IN DATE,
   pcomdir IN NUMBER DEFAULT 0,
   ppcomisi OUT NUMBER,
   pttabla IN VARCHAR2 DEFAULT NULL,
   pccomisi IN NUMBER DEFAULT NULL,
   pcagente IN NUMBER DEFAULT NULL,
   psproduc IN NUMBER DEFAULT NULL,
   pcactivi IN NUMBER DEFAULT NULL,
   pnanuali IN NUMBER DEFAULT NULL)
   RETURN NUMBER IS
   /******************************************************************************
      NOMBRE:     F_PCOMISI_CONCEP
      PROPÓSITO:  Función que encuentra el desglose de la comisión de una Agente

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0                                     Creación de la función
   ******************************************************************************/
   num_error      NUMBER := 0;
   vobj           VARCHAR2(200) := 'f_busca_pcomisi_concep';
   vpas           NUMBER(4) := 1;
   vpar           VARCHAR2(500)
      := SUBSTR('psseguro : ' || psseguro || ' - pcgarant  : ' || pcgarant
                || ' - pcgarant  : ' || pcgarant || ' - pcconcep  : ' || pcconcep
                || ' - pcmodcom  : ' || pcmodcom || ' - pfecha  : '
                || TO_CHAR(pfecha, 'dd/mm/yyyy') || ' - pcomdir : ' || pcomdir
                || ' - pttabla : ' || pttabla || ' - pccomisi: ' || pccomisi
                || ' - pcagente  : ' || pcagente || ' - psproduc: ' || psproduc
                || ' - pcactivi  : ' || pcactivi || ' - pnanuali: ' || pnanuali,
                1, 500);
   --
   vn_pcomisi     comisionprod.pcomisi%TYPE;
   vn_ctipcom     seguros.ctipcom%TYPE;
   vn_cagente     seguros.cagente%TYPE;
   vn_cactivi     seguros.cactivi%TYPE;
   vn_sproduc     seguros.sproduc%TYPE;
   vn_nanuali     seguros.nanuali%TYPE;
   vn_ccomisi_dire agentes.ccomisi%TYPE;
   vn_ccomisi_indi agentes.ccomisi%TYPE;
   vn_ccomisi     agentes.ccomisi%TYPE;
   vn_cempres     seguros.cempres%TYPE;
--
BEGIN
   vpas := 100;

   IF pttabla = 'EST' THEN
      BEGIN
         vpas := 110;

         SELECT NVL(pcagente, cagente), NVL(pcactivi, cactivi), NVL(psproduc, sproduc),
                NVL(pnanuali, nanuali), cempres
           INTO vn_cagente, vn_cactivi, vn_sproduc,
                vn_nanuali, vn_cempres
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100500;   -- sseguro no encontrado
      END;
   ELSIF pttabla = 'SOL' THEN
      BEGIN
         vpas := 120;

         SELECT NVL(pcagente, cagente), NVL(pcactivi, cactivi), NVL(psproduc, sproduc),
                NVL(pnanuali, 1), f_empres
           INTO vn_cagente, vn_cactivi, vn_sproduc,
                vn_nanuali, vn_cempres
           FROM solseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100500;   -- sseguro no encontrado
      END;
   ELSE
      BEGIN
         vpas := 130;

         SELECT NVL(pcagente, cagente), NVL(pcactivi, cactivi), NVL(psproduc, sproduc),
                NVL(pnanuali, nanuali), cempres
           INTO vn_cagente, vn_cactivi, vn_sproduc,
                vn_nanuali, vn_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100500;   -- sseguro no encontrado
      END;
   END IF;

   --
   IF pcagente IS NULL THEN
      IF pcomdir <> 0 THEN   -- InDirecta
         vpas := 140;
         vn_cagente := pac_redcomercial.f_busca_padre(vn_cempres, vn_cagente, NULL,
                                                      TRUNC(f_sysdate));
      END IF;
   END IF;

   --
   IF pccomisi IS NULL THEN
      BEGIN
         vpas := 150;

         SELECT ccomisi
           INTO vn_ccomisi
           FROM comisionvig_agente
          WHERE cagente = vn_cagente
            AND ccomind = pcomdir
            AND pfecha BETWEEN finivig AND NVL(ffinvig, TO_DATE('31122999', 'DDMMYYYY'));
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;   -- sseguro no encontrado
      END;
   ELSE
      vn_ccomisi := pccomisi;
   END IF;

   --
   BEGIN
      vpas := 160;

      SELECT pcomisi
        INTO ppcomisi
        FROM comisiongar_concep cg
       WHERE sproduc = vn_sproduc
         AND cactivi = vn_cactivi
         AND cgarant = pcgarant
         AND ccomisi = vn_ccomisi
         AND cmodcom = pcmodcom
         AND cconcepto = pcconcep
         AND NVL(vn_nanuali, 1) BETWEEN ninialt AND nfinalt
         AND finivig = (SELECT finivig
                          FROM comisionvig
                         WHERE ccomisi = vn_ccomisi
                           AND cestado = 2
                           AND TRUNC(pfecha) BETWEEN finivig AND NVL(ffinvig, TRUNC(pfecha)));
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            vpas := 170;

            SELECT pcomisi
              INTO ppcomisi
              FROM comisionacti_concep ca
             WHERE sproduc = vn_sproduc
               AND cmodcom = pcmodcom
               AND ccomisi = vn_ccomisi
               AND cactivi = vn_cactivi
               AND cconcepto = pcconcep
               AND NVL(vn_nanuali, 1) BETWEEN ninialt AND nfinalt
               AND finivig = (SELECT finivig
                                FROM comisionvig
                               WHERE ccomisi = vn_ccomisi
                                 AND cestado = 2
                                 AND TRUNC(pfecha) BETWEEN finivig AND NVL(ffinvig,
                                                                           TRUNC(pfecha)));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  vpas := 180;

                  SELECT pcomisi
                    INTO ppcomisi
                    FROM comisionprod_concep cp
                   WHERE sproduc = vn_sproduc
                     AND cmodcom = pcmodcom
                     AND ccomisi = vn_ccomisi
                     AND cconcepto = pcconcep
                     AND NVL(vn_nanuali, 1) BETWEEN ninialt AND nfinalt
                     AND finivig = (SELECT finivig
                                      FROM comisionvig
                                     WHERE ccomisi = vn_ccomisi
                                       AND cestado = 2
                                       AND TRUNC(pfecha) BETWEEN finivig
                                                             AND NVL(ffinvig, TRUNC(pfecha)));
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 0;   -- Comissió inexistent
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                                 || 'error = ' || 103216);
                     RETURN 103216;
               END;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 103628);
               RETURN 103628;   -- Error al llegir la taula COMISIONACTI
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'error = '
                     || 110824);
         RETURN 110824;   -- Error leyendo la tabla COMISIONGAR
   END;

   --
   RETURN 0;
--
END f_busca_pcomisi_concep;

/

  GRANT EXECUTE ON "AXIS"."F_BUSCA_PCOMISI_CONCEP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCA_PCOMISI_CONCEP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCA_PCOMISI_CONCEP" TO "PROGRAMADORESCSI";
