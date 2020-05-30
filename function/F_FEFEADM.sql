--------------------------------------------------------
--  DDL for Function F_FEFEADM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "AXIS"."F_FEFEADM" (
/******************************************************************************
   NOMBRE:       f_fefeadm
   PROPÓSITO:  Función de Fecha de efecto a nivel administrativo

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/06/2010   ICV              1. 0015238: Controlar el último dia del mes correctamente en el cálculo de la FEFEADM
   2.0        24/10/2011   MDS              2. 0019291: ENSA102-Comisión Reguladora
   3.0        25/11/2011   JGR              3. 0020037: Parametrización de Devoluciones
   4.0        20/06/2012   APD              4. 0022084: LCOL_A003-Consulta de recibos - Fase 2
   5.0        13/11/2019   DFR              5. IAXIS-7179: ERROR EN LA INSERCIÓN DEL EXTORNO
******************************************************************************/
   pfmovdia IN DATE,
   pcestrec IN NUMBER,
   pcestant IN NUMBER,
   pfmovini IN DATE,
   pnrecibo IN NUMBER,
   psmovrec IN NUMBER,
   pctipcob IN NUMBER,
   pfefeadm OUT DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
   w_ctiprec      recibos.ctiprec%TYPE;
   w_ctiprec_ant  recibos.ctiprec%TYPE;
   w_empresa      recibos.cempres%TYPE;
   mp             VARCHAR2(6);   -- Mes abierto en   Producción
   minmesabierto_pro DATE;
   maxmesabierto_pro DATE;
   ma             VARCHAR2(6);   -- Mes abierto en   Administración
   minmesabierto_adm DATE;
   maxmesabierto_adm DATE;
   dm             VARCHAR2(6);   -- Mes del          Movimiento
   vm             VARCHAR2(6);   -- Mes VALIDEZ      Movimiento
   fefeadmant     DATE;   -- fefeadm del movimiento anterior
   vfefecto       DATE;
   ve             VARCHAR2(6);   -- Mes del          Efecto
   --
   vctipcob       NUMBER(3);   -- Bug 0020010 - 08/11/2011 - JMF
--
BEGIN
   --
   BEGIN
      SELECT DECODE(pctipcob, NULL, NULL, 1, 1, 0, 0, 0)
        INTO vctipcob
        FROM DUAL;
   EXCEPTION
      WHEN OTHERS THEN
         vctipcob := pctipcob;
   END;

   --
   -- OBTENCION DATOS RECIBO ***************************************
   -- TIPO DE RECIBO
   BEGIN
      SELECT ctiprec, cempres, fefecto
        INTO w_ctiprec, w_empresa, vfefecto
        FROM recibos
       WHERE nrecibo = pnrecibo;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

--Si es retorno y el original es cartera,prevalece cartera.
   IF w_ctiprec = 13 THEN
      BEGIN
         SELECT r.ctiprec
           INTO w_ctiprec_ant
           FROM recibos r, rtn_recretorno rt
          WHERE rt.nrecretorno = pnrecibo
            AND r.nrecibo = rt.nrecibo;

         IF w_ctiprec_ant = 3 THEN
            w_ctiprec := w_ctiprec_ant;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;

   -- Obtiene la fefeadm del movimiento anterior para evitar asignar una inferior
   BEGIN
      SELECT m.fefeadm
        INTO fefeadmant
        FROM movrecibo m
       WHERE m.smovrec = (SELECT MAX(m2.smovrec)
                            FROM movrecibo m2
                           WHERE m2.nrecibo = pnrecibo
                             AND m2.smovrec < psmovrec);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fefeadmant := NULL;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   -- FECHAS DE PRODUCCIÓN
   -- Primer día del mes abiero PRODUCCIÓN
   BEGIN
      SELECT MAX(fperfin) + 1
        INTO minmesabierto_pro
        FROM cierres
       WHERE ctipo = 7
         AND fcierre <= TRUNC(pfmovdia)
         AND cestado = 1
         AND cempres = w_empresa;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   -- Último día del mes abierto PRODUCCIÓN
   BEGIN
      SELECT LAST_DAY(MAX(fperfin) + 1)
        INTO maxmesabierto_pro
        FROM cierres
       WHERE ctipo = 7
         AND fcierre <= TRUNC(pfmovdia)
         AND cestado = 1
         AND cempres = w_empresa;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   -- Mes abierto en PRODUCCIÓN.
   SELECT TO_CHAR(maxmesabierto_pro, 'YYYYMM')
     INTO mp
     FROM DUAL;

   -- FECHAS DE ADMINISTRACIÓN
   -- Primer día del mes abiero ADMINISTRACIÓN
   BEGIN
      SELECT MAX(fperfin) + 1
        INTO minmesabierto_adm
        FROM cierres
       WHERE ctipo = 8
         AND fcierre <= TRUNC(pfmovdia)
         AND cestado = 1
         AND cempres = w_empresa;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   -- Último día del mes abierto PRODUCCIÓN
   BEGIN
      SELECT LAST_DAY(MAX(fperfin) + 1)
        INTO maxmesabierto_adm
        FROM cierres
       WHERE ctipo = 8
         AND fcierre <= TRUNC(pfmovdia)
         AND cestado = 1
         AND cempres = w_empresa;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   -- Mes abierto en ADMINISTRACIÓN
   SELECT TO_CHAR(minmesabierto_adm, 'YYYYMM')
     INTO ma
     FROM DUAL;

   -- FECHAS DE MOVIMIENTO
   -- Mes del MOVIMIENTO
   SELECT TO_CHAR(pfmovdia, 'YYYYMM')
     INTO dm
     FROM DUAL;

   -- Mes del INICIO VALIDEZ MOVIMIENTO
   SELECT TO_CHAR(pfmovini, 'YYYYMM')
     INTO vm
     FROM DUAL;

   --Mes del efecto
   SELECT TO_CHAR(vfefecto, 'YYYYMM')
     INTO ve
     FROM DUAL;

   -- CALCULA DE LA FEFEADM DEL MOVIMIENTO ****************************
   -- Bug 22084 - APD - 20/06/2012 - se añade el ctiprec = 14 (v.f. 8)
   -- Bug 0022701 - 03/09/2012 - JMF: añado 13, 15 (v.f. 8)
   IF (pcestrec = 0
       AND pcestant = 0
       AND w_ctiprec IN(0, 1, 4, 9, 10, 14, 13, 15, 99)) THEN -- IAXIS-7179 13/11/2019 Se añade el tipo dummy 99
      -- Si es un rebut de NOVA PRODUCCIO ****************************
      IF ve < mp THEN
         pfefeadm := minmesabierto_pro;
      ELSE
         pfefeadm := TRUNC(vfefecto);
      END IF;
   ELSIF(pcestrec = 0
         AND pcestant = 0
         AND w_ctiprec = 3) THEN
      -- Si es un rebut de CARTERA ************************************
      IF vm < mp THEN   --Se modifica la condición a 03/10/2012 - 23814 / 124925
         pfefeadm := minmesabierto_pro;
      ELSE
         pfefeadm := pfmovini;
      END IF;
   -- Bug 019291 - 24/10/2011 - MDS - ENSA102-Comisión Reguladora
   -- tener en cuenta también los tipos de recibo 11 y 12
   ELSIF w_ctiprec IN(5, 11, 12) THEN
      -- Si es un rebut de COMISSIONS ****************************
      pfefeadm := TRUNC(vfefecto);
   ELSIF((pcestrec IN(1, 3)
          AND pcestant IN(0, 3)
          AND NVL(vctipcob, 1) = 1)
         OR(pcestrec = 0
            --AND pcestant = 1
            AND pcestant IN(1, 3)   --> 3.0 25/11/2011 JGR 20037: Parametrización de Devoluciones
            AND NVL(vctipcob, 1) = 1)) THEN
      -- MOVIMIENTOS AUTOMATICOS: DOMICILIACIONES Y DEVOLUCIONES *********
      IF dm < ma THEN
         pfefeadm := GREATEST(NVL(minmesabierto_adm, fefeadmant), fefeadmant);
      ELSIF dm = ma THEN
         pfefeadm := GREATEST(pfmovdia, fefeadmant);
      ELSE
         pfefeadm := GREATEST(NVL(maxmesabierto_adm, fefeadmant), fefeadmant);
      END IF;

      -- Control para no asignar una fecha anterior a la del anterior movimiento
      IF pfefeadm < fefeadmant THEN
         p_tab_error(f_sysdate, f_user, 'F_FEFEADM', 1,
                     'pnrecibo=' || pnrecibo || ' movrecibo=' || psmovrec || ' pfefeadm='
                     || pfefeadm || ' pfefeadmant=' || fefeadmant,
                     SQLERRM);
         RETURN 2;
      END IF;
   ELSIF (pcestrec IN(1, 3)
          AND pcestant IN(0, 3)
          AND NVL(vctipcob, 1) = 0)
         OR(pcestrec = 0
            --AND pcestant = 1
            AND pcestant IN(1, 3)   --> 3.0 25/11/2011 JGR 20037: Parametrización de Devoluciones
            --AND NVL(vctipcob, 1) = 0)
            AND NVL(vctipcob, 1) != 1)   --> 3.0 25/11/2011 JGR 20037: Parametrización de Devoluciones
         OR(pcestrec = 0
            AND pcestant = 2) THEN
      -- MOVIMIENTOS MANUALES. COBRO, DESCOBRO Y DESANULACION **********
      IF vm <> ma THEN
         pfefeadm := GREATEST(minmesabierto_adm, fefeadmant);
      ELSE
         pfefeadm := GREATEST(pfmovini, fefeadmant);
      END IF;
   ELSIF(pcestrec = 2
         AND pcestant IN(0, 3)) THEN
      -- MOVIMIENTO MANUAL DE ANULACION ***********************************
      IF dm <> ma THEN
         pfefeadm := GREATEST(minmesabierto_adm, fefeadmant);
      ELSE
         pfefeadm := GREATEST(pfmovdia, fefeadmant);
      END IF;
   ELSE
      pfefeadm := NULL;
      RETURN 3;
   END IF;

   RETURN 0;
END f_fefeadm;

/

  GRANT EXECUTE ON "AXIS"."F_FEFEADM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FEFEADM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FEFEADM" TO "PROGRAMADORESCSI";
