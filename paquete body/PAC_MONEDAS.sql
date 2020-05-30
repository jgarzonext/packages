--------------------------------------------------------
--  DDL for Package Body PAC_MONEDAS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MONEDAS IS
/***********************************************************************
  PAC_MONEDAS
    Aquest paquet està preparat per gestionar les funcions relacionades amb la taula MONEDAS

   REVISIONS:
   Ver        Data              Autor             Descripció
   ---------  ----------        ---------------  ----------------------------------
   1.0        30/04/2008        MSR              Creación del package (BUG9902).
   2.0        26/10/2011        JMP              0018423: LCOL000 - Multimoneda
   2.1        28/01/2013        RDD              0025864: LCOL_F002-Valores con decimales en Resultado de Contabilidad Diaria
   3.0        23/05/2019        ECP              IAXIS-3592.Proceso de terminación por no pago
***********************************************************************/-- MSR Gener 2008
 --    Aquest paquet està preparat per gestionar les funcions relacionades amb la taula MONEDAS
 --

   -- Variables per desar la darrera moneda i utilitzada i els seus decimals
   --   Això es fa perquè quan es crida per una moneda, habitualment les seguents crides són per la mateixa
   --   per tant si ho tenim guardat no cal tornar a accedir a la base de dades
   vg_cmoneda     monedas.cmoneda%TYPE;
   vg_ndecima     monedas.ndecima%TYPE;

/***********************************************************************
 -- FUNCIÓ: Decimals
 -- Torna el nombre de decimals d'una divisa
 --   Paràmetres
 --     p_cMoneda       Codi de la moneda de la qual volem els decimals a que s'han d'arrodonir el imports
 --                     NOTA: No s'hauria de passar la mondea NULL, en cas que es faci, tornarà 2 decimals.
 --
 --   Exemple d'ús
 --     import_arrodonit := ROUND( import, PAC_MONEDAS.DECIMALS(moneda));
 --    o per la moneda per defecte
 --     import_arrodonit := ROUND( import, PAC_MONEDAS.DECIMALS);
 --   o encara més curt per la moneda per defecte
 --     import_arrodonit := ROUND( import );
***********************************************************************/
   FUNCTION decimals(p_cmoneda IN monedas.cmoneda%TYPE DEFAULT moneda_inst)
      RETURN monedas.ndecima%TYPE IS
   BEGIN
   --IAXIS-3592. --ECP -- 23/05/2019
      IF p_cmoneda = moneda_inst THEN
         IF decimals_inst IS NULL THEN
            BEGIN
               SELECT ndecima
                 INTO decimals_inst
                 FROM monedas
                WHERE cmoneda = moneda_inst
                  AND cidioma = f_parinstalacion_n('IDIOMARTF');
            EXCEPTION
               WHEN OTHERS THEN
                  decimals_inst := 0;
            END;
         END IF;
--IAXIS-3592. --ECP -- 23/05/2019
         RETURN decimals_inst;   -- Si demanen la moneda per defecte, ja tenim el seus decimals
      ELSIF p_cmoneda = vg_cmoneda THEN
         NULL;   -- Si tornen a demanar la darrera divisa, ja tenim el seus decimals a g_ndecima
      ELSE
         vg_cmoneda := p_cmoneda;
         vg_ndecima := 2;   -- Per defecte 2 decimals si la divisa no està definida

         -- MSR Nota : No valido que tingui els mateixos decimals a totes les definicions de la moneda per cada idioma
         FOR r IN (SELECT ndecima
                     FROM monedas
                    WHERE cmoneda = p_cmoneda) LOOP
            vg_ndecima := r.ndecima;
         END LOOP;
      END IF;

      RETURN vg_ndecima;
   END decimals;

   /***********************************************************************
      F_ROUND: Redondeamos el importe pasado segun la moneda. En caso de no
               pasar moneda se usará la de la instalación.
      REVISIONS:
      Ver        Data        Autor             Descripció
      ---------  ----------  ---------------  ----------------------------------
      1.0        30/04/2008  MSR               Incorporació de l'antiga funció F_ROUND a dins un package.
   ***********************************************************************/

   --   Exemple d'ús
   --     import_arrodonit := ROUND( import, PAC_MONEDAS.DECIMALS(moneda));
   --    o per la moneda per defecte
   --     import_arrodonit := ROUND( import, PAC_MONEDAS.DECIMALS);
   --   o encara més curt per la moneda per defecte
   --     import_arrodonit := ROUND( import );
   FUNCTION f_round(
      p_import IN NUMBER,
      p_moneda IN NUMBER
            DEFAULT NULL,   -- No es pot definir DEFAULT PAC_MONEDAS.Moneda_Inst per problemes de compatibilitat amb el Reports i Forms
            p_decimal IN NUMBER DEFAULT 0
                        )
      RETURN NUMBER IS
   BEGIN
      -- Arrodonim ald decimals de p_moneda i si aquesta és NULL als de la moneda per defecete
      RETURN ROUND(p_import, decimals(NVL(p_moneda, moneda_inst))+p_decimal);
   END f_round;

-- BUG 18423 - 26/10/2011 - JMP - LCOL000 - Multimoneda
/*************************************************************************
   FUNCTION f_cmoneda_t
   Convierte el código de moneda numérico a su código alfanumérico.
   pcmoneda             : Código numérico de la moneda
   return               : El código alfanumérico de la moneda
*************************************************************************/
   FUNCTION f_cmoneda_t(pcmoneda NUMBER)
      RETURN VARCHAR2 IS
      v_cmonint      monedas.cmonint%TYPE;

      CURSOR c_monedas IS
         SELECT cmonint
           FROM monedas
          WHERE cmoneda = pcmoneda
            and cidioma = pac_md_common.f_get_cxtidioma;
   BEGIN
      OPEN c_monedas;

      FETCH c_monedas
       INTO v_cmonint;

      CLOSE c_monedas;

      RETURN v_cmonint;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_monedas%ISOPEN THEN
            CLOSE c_monedas;
         END IF;

         RETURN NULL;
   END f_cmoneda_t;

/*************************************************************************
   FUNCTION f_cmoneda_n
   Convierte el código de moneda alfanumérico a su código numérico.
   pcmoneda             : Código alfanumérico de la moneda
   return               : El código numérico de la moneda
*************************************************************************/
   FUNCTION f_cmoneda_n(pcmoneda VARCHAR2)
      RETURN NUMBER IS
      v_cmoneda      monedas.cmoneda%TYPE;

      CURSOR c_monedas IS
         SELECT cmoneda
           FROM monedas
          WHERE cmonint = pcmoneda
            and cidioma = pac_md_common.f_get_cxtidioma;
   BEGIN
      OPEN c_monedas;

      FETCH c_monedas
       INTO v_cmoneda;

      CLOSE c_monedas;

      RETURN v_cmoneda;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_monedas%ISOPEN THEN
            CLOSE c_monedas;
         END IF;

         RETURN NULL;
   END f_cmoneda_n;

-- FIN BUG 18423 - 26/10/2011 - JMP - LCOL000 - Multimoneda

   -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
/*************************************************************************
   FUNCTION f_moneda_divisa
   Obtiene la moneda correspondiente a la divisa
   pcdivisa             : Código de moneda asociado a la divisa
   return               : El código de la moneda
*************************************************************************/
   FUNCTION f_moneda_divisa(pcdivisa IN NUMBER)
      RETURN NUMBER IS
      vcmoneda       codidivisa.cmoneda%TYPE;
   BEGIN
      SELECT cmoneda
        INTO vcmoneda
        FROM codidivisa
       WHERE cdivisa = pcdivisa;

      RETURN vcmoneda;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN moneda_inst;   -- si no encuentro la moneda, devuelvo la moneda de instalación
   END f_moneda_divisa;

/*************************************************************************
   FUNCTION f_moneda_divisa
   Obtiene la moneda correspondiente a la divisa
   pcdivisa             : Código de moneda asociado a la divisa
   return               : El código de la moneda
*************************************************************************/
   FUNCTION f_moneda_producto(psproduc IN NUMBER)
      RETURN NUMBER IS
      vcmoneda       codidivisa.cmoneda%TYPE;
   BEGIN
      SELECT div.cmoneda
        INTO vcmoneda
        FROM codidivisa div, productos prod
       WHERE div.cdivisa = prod.cdivisa
         AND prod.sproduc = psproduc;

      RETURN vcmoneda;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN moneda_inst;   -- si no encuentro la moneda, devuelvo la moneda de instalación
   END f_moneda_producto;

-- FIN BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
   FUNCTION f_moneda_seguro(ptablas IN VARCHAR2, psseguro IN NUMBER)
      RETURN NUMBER IS
      vcmoneda       codidivisa.cmoneda%TYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT seg.cmoneda
           INTO vcmoneda
           FROM estseguros seg
          WHERE seg.sseguro = psseguro;
      ELSE
         SELECT seg.cmoneda
           INTO vcmoneda
           FROM seguros seg
          WHERE seg.sseguro = psseguro;
      END IF;

      RETURN vcmoneda;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MONEDAS.f_moneda_seguro', 99,
                     'ptablas=' || ptablas || ', psseguro=' || psseguro, SQLERRM);
         RETURN NULL;
   END f_moneda_seguro;

   FUNCTION f_moneda_producto_char(psproduc IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN f_cmoneda_t(f_moneda_producto(psproduc));
   END f_moneda_producto_char;

   FUNCTION f_moneda_seguro_char(ptablas IN VARCHAR2, psseguro IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN f_cmoneda_t(f_moneda_seguro(ptablas, psseguro));
   END f_moneda_seguro_char;
BEGIN
   -- MSR Nota : No valido que tingui els mateixos decimals a totes les definicions de la moneda per cada idioma
   -- Moneda de la instal·lació per defecte
   FOR r IN (SELECT ndecima
               FROM monedas
              WHERE cmoneda = moneda_inst) LOOP
      decimals_inst := r.ndecima;
      EXIT;
   END LOOP;
END pac_monedas;

/
