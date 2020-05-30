--------------------------------------------------------
--  DDL for Function F_INSDETREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INSDETREC" (
   recibo IN NUMBER,
   concepto IN NUMBER,
   importe IN NUMBER,
   porcent IN NUMBER,
   garantia IN NUMBER,
   riesgo IN NUMBER,
   xctipcoa IN NUMBER,
   pcageven IN NUMBER DEFAULT NULL,
   pnmovima IN NUMBER DEFAULT 1,
   poragloc IN NUMBER DEFAULT 0,
   psseguro IN NUMBER DEFAULT 0,
   pccomisi IN NUMBER DEFAULT 1,
   importe_monpol IN NUMBER DEFAULT NULL,   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   pfcambio IN DATE DEFAULT NULL,   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   pcmonpol IN NUMBER DEFAULT NULL,   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   pmoneda IN NUMBER DEFAULT NULL)   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
   RETURN NUMBER IS
/****************************************************************************
   F_INSDETREC : Insertar un registro en la tabla de detrecibos.
   ALLIBADM - Gestión de datos referentes a los recibos
    funcion que inserta un registro a detrecibos
                 teniendo en cuenta si es coaseguro cedido, aceptado o no.
                 Esta funcion es llamada por f_detrecibo_coa
    se añaden los parametros psseguro y poragloc
                 para el calculo especial de las comisiones y retenciones.
                 poragloc : El porcentaje del agente en nuestra compañia
   Si nos llega un nuevo importe para un concepto de ese
                 riesgo, garantía lo sumamos.
    Cambios para grabar dos campos mas de la tabla DETRECIBOS
      Modificamos las selects para que vaya por nmovima
/******************************************************************************
      NOMBRE:       F_INSDETREC
   PROPÓSITO:    Insertar un registro en la tabla de detrecibos.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????  ???                1. Creación del package.
   2.0        22/11/2011  JMP                2. 0018423: LCOL000 - Multimoneda
   3.0        22/04/2013  AVT                3. 0026755: LCOL_A004-Qtracker: 7266 (iAxis F3A UAT_PILOTO): ERROR EN EMISI?N CON COASEGURO CEDIDO
   4.0        18/10/2013  KBR                4. 0009163: Esta generando la cartera con una diferencia de pesos en vida Grupo
   5.0        16/12/2013  RCL                5. 0029387: LCOL_T020-Qtracker: 0010543 y 0010544
****************************************************************************/
   ximplocal      NUMBER;
   ximpcedid      NUMBER;
   decimals       NUMBER := 0;
   xcedido        NUMBER;
   xncuacoa       seguros.ncuacoa%TYPE;
   ximporte       NUMBER;
   xconcepto      NUMBER;
   w_error        VARCHAR2(4000);
   xcageven       NUMBER;
   xnmovima       NUMBER;
   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   ximplocal_monpol NUMBER;
   ximpcedid_monpol NUMBER;
   xcedido_monpol NUMBER;
   ximporte_monpol NUMBER;
-- FIN BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda

   --Bug 27424/148948 - 17/07/2013 - AMC
   vsproduc       NUMBER;
   vcactivi       NUMBER;
   vsseguro       NUMBER;
   v_no_cede_coa  NUMBER;
--Fi Bug 27424/148948 - 17/07/2013 - AMC
   xmoneda        NUMBER;   --BUG 29387/161365 - RCL - 13/12/2013
   vcempres       NUMBER;
   xmonedamonpol  NUMBER;
BEGIN
   IF f_parinstalacion_n('AGTEVENTA') = 0 THEN
      xcageven := NULL;
      xnmovima := 1;
   ELSE
      xcageven := pcageven;
      xnmovima := pnmovima;
   END IF;

   --Bug 27424/148948 - 17/07/2013 - AMC
   IF psseguro <> 0 THEN
      SELECT sproduc, cactivi, cempres
        INTO vsproduc, vcactivi, vcempres
        FROM seguros
       WHERE sseguro = psseguro;
   ELSE
      SELECT sseguro
        INTO vsseguro
        FROM recibos
       WHERE nrecibo = recibo;

      SELECT sproduc, cactivi, cempres
        INTO vsproduc, vcactivi, vcempres
        FROM seguros
       WHERE sseguro = vsseguro;
   END IF;

   v_no_cede_coa := NVL(pac_parametros.f_pargaranpro_n(vsproduc, vcactivi, garantia,
                                                       'NO_CEDE_COASEGURO'),
                        0);   -- para excluir el importe de las garanías que  NO CEDEN AL COASEGURO

   --Inici - BUG 29387/161365 - RCL - 13/12/2013
   IF pmoneda = 0 THEN
      --Si pmoneda es 0, recuperamos la moneda del producto.
      xmoneda := pac_monedas.f_moneda_producto(vsproduc);
   ELSE
      xmoneda := pmoneda;
   END IF;

   xmonedamonpol := pcmonpol;

   --Fi - BUG 29387/161365 - RCL - 13/12/2013

   --Fi Bug 27424/148948 - 17/07/2013 - AMC
   -- 23183 AVT 31/10/2012 només per Coassegurança cedida
   -- IF xctipcoa != 0 THEN
   IF xctipcoa IN(1, 2)   --THEN
      AND v_no_cede_coa = 0 THEN
      -- Se trata de un coaseguro
      ximplocal := (importe * porcent) / 100;   -- es un porcentaje

      --28559 KBR 18/10/2013
      IF concepto IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
         AND NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0) <> 0 THEN
         ximplocal := f_round(ximplocal, xmoneda,
                              NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0));
      ELSE
         ximplocal := f_round(ximplocal, xmoneda);   -- BUG 29387/161365 - RCL - 13/12/2013
      END IF;

      ximplocal_monpol := (importe_monpol * porcent) / 100;   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda

      --28559 KBR 18/10/2013
      IF concepto IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
         AND NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0) <> 0 THEN
         ximplocal_monpol := f_round(ximplocal_monpol, xmonedamonpol,
                                     NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                       'REDONDEO_SRI'),
                                         0));
      ELSE
         ximplocal_monpol := f_round(ximplocal_monpol, xmonedamonpol);
      END IF;

      IF f_escomision(concepto) = 0 THEN
         -- No se trata de la comision bruta ni de la retencion
         ximpcedid := NVL(importe, 0) - NVL(ximplocal, 0);
         ximpcedid_monpol := importe_monpol - ximplocal_monpol;   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
      ELSE
         -- Se trata de la comision bruta o de la retencion
           -- Calculamos el importe total cedido
         xcedido := NVL(importe, 0) - NVL(ximplocal, 0);
         xcedido_monpol := importe_monpol - ximplocal_monpol;   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
         -- Calculamos la comision del agente
         ximplocal := (ximplocal * poragloc) / 100;
         ximplocal_monpol := (ximplocal_monpol * poragloc) / 100;   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda

         BEGIN
            SELECT NVL(ncuacoa, 0)
              INTO xncuacoa
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_insdetrec', 1,
                           ' psseguro = ' || psseguro || ' xcedido = ' || xcedido
                           || ' xcedido_monpol = ' || xcedido_monpol || ' ximplocal = '
                           || ximplocal || ' ximplocal_monpol = ' || ximplocal_monpol
                           || ' poragloc = ' || poragloc || ' importe_monpol  = '
                           || importe_monpol || ' importe = ' || importe,
                           SQLERRM);
               RETURN 101919;   -- Error al leer de la tabla SEGUROS
         END;

         BEGIN
            -- Calculamos la suma de las comisiones del agente por cada compañia
            SELECT SUM(NVL(xcedido *(pcesion / 100)
                           *(DECODE(ccuacoa, 1, poragloc, pcomcoa) / 100),
                           0)),
                   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
                   SUM(xcedido_monpol *(pcesion / 100)
                       *(DECODE(ccuacoa, 1, poragloc, pcomcoa) / 100))
              -- FIN BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
            INTO   ximpcedid,
                   ximpcedid_monpol   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
              FROM seguros s, agentes a, coacedido c
             WHERE s.sseguro = c.sseguro
               AND s.cagente = a.cagente
               AND c.sseguro = psseguro
               AND c.ncuacoa = xncuacoa;

            ximpcedid := ximpcedid;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_insdetrec', 2,
                           ' psseguro = ' || psseguro || ' xcedido = ' || xcedido
                           || ' xcedido_monpol = ' || xcedido_monpol || ' ximplocal = '
                           || ximplocal || ' ximplocal_monpol = ' || ximplocal_monpol
                           || ' poragloc = ' || poragloc || ' importe_monpol  = '
                           || importe_monpol || ' importe = ' || importe,
                           SQLERRM);
               RETURN 105582;   -- Error al leer de la tabla COACEDIDO
         END;
      END IF;

      --BUG 29387 - 13/01/2014 - RCL
      IF concepto IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
         AND NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0) <> 0 THEN
         ximpcedid := f_round(NVL(ximpcedid, 0), xmoneda,
                              NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0));
      ELSE
         ximpcedid := f_round(NVL(ximpcedid, 0), xmoneda);
      END IF;

      --BUG 29387 - 13/01/2014 - RCL
      IF concepto IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
         AND NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0) <> 0 THEN
         ximpcedid_monpol := f_round(ximpcedid_monpol, xmoneda,
                                     NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                       'REDONDEO_SRI'),
                                         0));
      ELSE
         ximpcedid_monpol := f_round(ximpcedid_monpol, xmoneda);
      END IF;
   ELSE
      -- Es un seguro normal
      IF f_escomision(concepto) = 0 THEN
         -- No se trata de la comision bruta ni de la retencion
         IF concepto IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
            AND NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0) <> 0 THEN
            ximplocal := f_round(importe, xmoneda,
                                 NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'),
                                     0));
            ximplocal_monpol := f_round(importe_monpol,
                                        NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                          'REDONDEO_SRI'),
                                            0));
         ELSE
            ximplocal := f_round(importe, xmoneda);
            ximplocal_monpol := f_round(importe_monpol, xmonedamonpol);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
         END IF;
      --24/12/2013 se redondea según moneda aunq no tenga coaseguro
      ELSE
         -- Se trata de la comision bruta o de la retencion
           -- Calculamos la comision del agente
         IF concepto IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
            AND NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0) <> 0 THEN
            ximplocal := f_round((importe * poragloc) / 100, xmoneda,
                                 NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'),
                                     0));
            ximplocal_monpol := f_round((importe_monpol * poragloc) / 100, xmonedamonpol,
                                        NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                          'REDONDEO_SRI'),
                                            0));
         ELSE
            ximplocal := f_round((importe * poragloc) / 100, xmoneda);
            ximplocal_monpol := f_round((importe_monpol * poragloc) / 100, xmonedamonpol);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
         END IF;
      END IF;
   END IF;

   -- Coaseguro aceptado o seguro normal: Grabamos un unico registro
   ximporte := NVL(ximplocal, 0);
   xconcepto := concepto;
   --28559 KBR 18/10/2013
   ximporte_monpol := ximplocal_monpol;

   --28559 KBR 18/10/2013
   --ximporte := f_round(ximporte, pmoneda);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
   --ximporte_monpol := f_round(ximplocal_monpol, pcmonpol);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   --28559 KBR 18/10/2013
   BEGIN
      INSERT INTO detrecibos
                  (nrecibo, cconcep, iconcep, cgarant, nriesgo, cageven, nmovima,
                   iconcep_monpol, fcambio)   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
           VALUES (recibo, xconcepto, ximporte, garantia, riesgo, xcageven, xnmovima,
                   ximporte_monpol, pfcambio);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN   -- Registro ya existe. Le sumamos el nuevo importe.
            UPDATE detrecibos
               SET iconcep = iconcep + ximporte,
                   iconcep_monpol = iconcep_monpol + ximporte_monpol
             WHERE nrecibo = recibo
               AND cconcep = xconcepto
               AND cgarant = garantia
               AND nriesgo = riesgo
               AND nmovima = xnmovima;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_insdetrec', 3,
                           ' psseguro = ' || psseguro || ' xconcepto = ' || xconcepto
                           || ' garantia = ' || garantia || ' riesgo = ' || riesgo
                           || ' xnmovima = ' || xnmovima || ' ximporte = ' || ximporte
                           || ' ximporte_monpol  = ' || ximporte_monpol || ' recibo = '
                           || recibo,
                           SQLERRM);
               RETURN 104377;   -- Error al actualizar DETRECIBOS
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_insdetrec', 4,
                     ' psseguro = ' || psseguro || ' xconcepto = ' || xconcepto
                     || ' garantia = ' || garantia || ' riesgo = ' || riesgo || ' xnmovima = '
                     || xnmovima || ' ximporte = ' || ximporte || ' ximporte_monpol  = '
                     || ximporte_monpol || ' recibo = ' || recibo,
                     SQLERRM);
         RETURN 103513;   -- Error a l' inserir a DETRECIBOS
   END;

-- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
   IF (xctipcoa = 1
       OR xctipcoa = 2)
      AND porcent < 100
      AND v_no_cede_coa = 0 THEN
      -- Coaseguro cedido: Grabamos dos registros por concepto
      -- Sumamos 50 por la nomenclatura tomada de que los conceptos cedidos
      -- son el mismo codigo mas 50.
      ximporte := NVL(ximpcedid, 0);
      xconcepto := concepto + 50;
      --28559 KBR 18/10/2013
      ximporte_monpol := ximpcedid_monpol;

      --28559 KBR 18/10/2013
      --ximporte := f_round(ximporte, pmoneda);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
      --ximporte_monpol := f_round(ximpcedid_monpol, pcmonpol);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
      --28559 KBR 18/10/2013
      BEGIN
         INSERT INTO detrecibos
                     (nrecibo, cconcep, iconcep, cgarant, nriesgo, cageven, nmovima,
                      iconcep_monpol, fcambio)   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
              VALUES (recibo, xconcepto, ximporte, garantia, riesgo, xcageven, xnmovima,
                      ximporte_monpol, pfcambio);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            BEGIN   -- Registro ya existe. Le sumamos el nuevo importe.
               UPDATE detrecibos
                  SET iconcep = iconcep + ximporte,
                      iconcep_monpol = iconcep_monpol + ximporte_monpol
                WHERE nrecibo = recibo
                  AND cconcep = xconcepto
                  AND cgarant = garantia
                  AND nriesgo = riesgo
                  AND nmovima = xnmovima;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'f_insdetrec', 5,
                              ' psseguro = ' || psseguro || ' xconcepto = ' || xconcepto
                              || ' garantia = ' || garantia || ' riesgo = ' || riesgo
                              || ' xnmovima = ' || xnmovima || ' ximporte = ' || ximporte
                              || ' ximporte_monpol  = ' || ximporte_monpol || ' recibo = '
                              || recibo,
                              SQLERRM);
                  RETURN 104377;   -- Error al actualizar DETRECIBOS
            END;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_insdetrec', 6,
                        ' psseguro = ' || psseguro || ' xconcepto = ' || xconcepto
                        || ' garantia = ' || garantia || ' riesgo = ' || riesgo
                        || ' xnmovima = ' || xnmovima || ' ximporte = ' || ximporte
                        || ' ximporte_monpol  = ' || ximporte_monpol || ' recibo = ' || recibo,
                        SQLERRM);
            RETURN 103513;   -- Error a l' inserir a DETRECIBOS
      END;
   END IF;

   RETURN 0;
END f_insdetrec;

/

  GRANT EXECUTE ON "AXIS"."F_INSDETREC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSDETREC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSDETREC" TO "PROGRAMADORESCSI";
