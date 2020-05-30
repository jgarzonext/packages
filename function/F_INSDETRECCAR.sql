--------------------------------------------------------
--  DDL for Function F_INSDETRECCAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INSDETRECCAR" (
   proceso IN NUMBER,
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
   pmoneda IN NUMBER DEFAULT NULL)   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda)   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   RETURN NUMBER IS
/****************************************************************************
   F_INSDETRECCAR : INSERTAR UN REGISTRO EN LA TABLA DE DETRECIBOS.
   ALLIBADM - GESTIÓN DE DATOS REFERENTES A LOS RECIBOS
          FUNCION QUE INSERTA UN REGISTRO A DETRECIBOS
                 TENIENDO EN CUENTA SI ES COASEGURO CEDIDO, ACEPTADO O NO.
                 ESTA FUNCION ES LLAMADA POR F_DETRECIBO_COA
          SE AÑADEN LOS PARAMETROS PSSEGURO Y PORAGLOC
                 PARA EL CALCULO ESPECIAL DE LAS COMISIONES Y RETENCIONES.
                 PORAGLOC : EL PORCENTAJE DEL AGENTE EN NUESTRA COMPAÑIA
         SI NOS LLEGA UN NUEVO IMPORTE PARA UN CONCEPTO DE ESE
                 RIESGO, GARANTÍA LO SUMAMOS.
      CAMBIOS PARA GRABAR DOS NUEVOS CAMPOS EN DETRECIBOS
      AÑNADIMOS EL NMOVIMA A LOS UPDATES DE DETRECIBOS
/******************************************************************************
      NOMBRE:       F_INSDETREC
   PROPÓSITO:    Insertar un registro en la tabla de detrecibos.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????  ???                1. Creación del package.
   2.0        30/11/2011  JMP                2. 0018423: LCOL000 - Multimoneda
   3.0        31/10/2012  AVT                3. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   4.0        22/04/2013  AVT                4. 0026755: LCOL_A004-Qtracker: 7266 (iAxis F3A UAT_PILOTO): ERROR EN EMISI?N CON COASEGURO CEDIDO
   5.0        01/08/2013  JSV                5. 0027752: LCOL_A004-Qtracker: 0008346: ERROR EN LA APLICACION DE LA PRIMA
   6.0        20/08/2013  KBR                6. 0027752: LCOL_A004-Qtracker: 0008346: ERROR EN LA APLICACION DE LA PRIMA
   7.0        18/10/2013  KBR                4. 0009163: Esta generando la cartera con una diferencia de pesos en vida Grupo
*******************************************************************************/
   ximplocal      NUMBER;
   ximpcedid      NUMBER;
   decimals       NUMBER := 0;
   xcedido        NUMBER;
   xncuacoa       NUMBER;
   xconcepto      NUMBER;
   ximporte       NUMBER;
   xcageven       NUMBER;
   xnmovima       NUMBER;
   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   ximplocal_monpol NUMBER;
   ximpcedid_monpol NUMBER;
   xcedido_monpol NUMBER;
   ximporte_monpol NUMBER;
-- FIN BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda

   --Bug 0027752/0150236 - 01/08/2013 - JSV - INI
   vsproduc       NUMBER;
   vcactivi       NUMBER;
   vsseguro       NUMBER;
   v_no_cede_coa  NUMBER;
   xmoneda        NUMBER;   --BUG 29387/161365 - RCL - 13/12/2013
   vcempres       NUMBER;
   xmonedamonpol  NUMBER;
--Bug 0027752/0150236 - 01/08/2013 - JSV - FIN
BEGIN
   IF f_parinstalacion_n('AGTEVENTA') = 0 THEN
      xcageven := NULL;
      xnmovima := 1;
   ELSE
      xcageven := pcageven;
      xnmovima := pnmovima;
   END IF;

--Bug 0027752/0150236 - 01/08/2013 - JSV - INI
   IF psseguro <> 0 THEN
      SELECT sproduc, cactivi, cempres
        INTO vsproduc, vcactivi, vcempres
        FROM seguros
       WHERE sseguro = psseguro;
   ELSE
      SELECT sseguro
        INTO vsseguro
        FROM reciboscar
       WHERE nrecibo = recibo;

      SELECT sproduc, cactivi, cempres
        INTO vsproduc, vcactivi, vcempres
        FROM seguros
       WHERE sseguro = vsseguro;
   END IF;

   xmoneda := pmoneda;
   xmonedamonpol := pcmonpol;
   v_no_cede_coa := NVL(pac_parametros.f_pargaranpro_n(vsproduc, vcactivi, garantia,
                                                       'NO_CEDE_COASEGURO'),
                        0);   -- para excluir el importe de las garanías que  NO CEDEN AL COASEGURO

--Bug 0027752/0150236 - 01/08/2013 - JSV - FIN

   -- 23183 AVT 31/10/2012 només per Coassegurança cedida
   -- IF xctipcoa != 0 THEN
   IF xctipcoa IN(1, 2)   --THEN
      --Bug 0027752/0150236 - 01/08/2013 - JSV - INI
      AND v_no_cede_coa = 0 THEN
      --Bug 0027752/0150236 - 01/08/2013 - JSV - FIN

      -- SE TRATA DE UN COASEGURO
      --28559 KBR 21/10/2013
      --ximplocal := ROUND((importe * porcent) / 100, decimals);   -- ES UN PORCENTAJE
      IF concepto IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
         AND NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0) <> 0 THEN
         ximplocal := f_round((importe * porcent) / 100, xmoneda,
                              NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0));
      ELSE
         ximplocal := f_round((importe * porcent) / 100, xmoneda);
      END IF;

      ximplocal_monpol := (importe_monpol * porcent) / 100;   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda

      --28559 KBR 21/10/2013
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
         ximplocal := ximplocal * poragloc / 100;
         ximplocal_monpol := (ximplocal_monpol * poragloc) / 100;   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda

         BEGIN
            SELECT ncuacoa
              INTO xncuacoa
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101919;   -- ERROR AL LEER DE LA TABLA SEGUROS
         END;

         BEGIN
            -- CALCULAMOS LA SUMA DE LAS COMISIONES DEL AGENTE POR CADA COMPAÑIA
            SELECT SUM(xcedido *(pcesion / 100) *(DECODE(ccuacoa, 1, poragloc, pcomcoa) / 100)),
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

            IF concepto IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
               AND NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0) <> 0 THEN
               ximpcedid := f_round(ximpcedid, xmoneda,
                                    NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                      'REDONDEO_SRI'),
                                        0));
            ELSE
               ximpcedid := f_round(ximpcedid, xmoneda);
            END IF;
         -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105582;   -- ERROR AL LEER DE LA TABLA COACEDIDO
         END;
      END IF;
   ELSE
      -- ES UN SEGURO NORMAL
      IF f_escomision(concepto) = 0 THEN
         -- NO SE TRATA DE LA COMISION BRUTA NI DE LA RETENCION
         ximplocal := NVL(importe, 0);
         ximplocal_monpol := importe_monpol;   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
      ELSE
         -- SE TRATA DE LA COMISION BRUTA O DE LA RETENCION
           -- CALCULAMOS LA COMISION DEL AGENTE
         ximplocal := importe * poragloc / 100;
         ximplocal_monpol := (importe_monpol * poragloc) / 100;   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
      END IF;
   END IF;

   -- COASEGURO ACEPTADO O SEGURO NORMAL: GRABAMOS UN UNICO REGISTRO
   ximporte := NVL(ximplocal, 0);
   xconcepto := concepto;
   --28559 KBR 21/10/2013
   ximporte_monpol := ximplocal_monpol;

   --28559 KBR 21/10/2013
   --ximporte := f_round(ximporte, pmoneda);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
   --ximporte_monpol := f_round(ximplocal_monpol, pcmonpol);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   --28559 KBR 21/10/2013
   BEGIN
      INSERT INTO detreciboscar
                  (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo, cageven,
                   nmovima, iconcep_monpol, fcambio)   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
           VALUES (proceso, recibo, xconcepto, ximporte, garantia, riesgo, xcageven,
                   xnmovima, ximporte_monpol, pfcambio);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN   -- REGISTRO YA EXISTE. LE SUMAMOS EL NUEVO IMPORTE.
            UPDATE detreciboscar
               SET iconcep = iconcep + ximporte,
                   iconcep_monpol = iconcep_monpol + ximporte_monpol
             WHERE sproces = proceso
               AND nrecibo = recibo
               AND cconcep = xconcepto
               AND cgarant = garantia
               AND nriesgo = riesgo
               AND nmovima = xnmovima;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104378;   -- ERROR AL ACTUALIZAR DETRECIBOSCAR
         END;
      WHEN OTHERS THEN
         RETURN 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
   END;

-- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
   IF (xctipcoa = 1
       OR xctipcoa = 2)
      AND porcent < 100   --THEN
      --Bug 0027752/0150236 - 01/08/2013 - JSV - INI
      AND v_no_cede_coa = 0 THEN
      --Bug 0027752/0150236 - 01/08/2013 - JSV - FIN

      -- COASEGURO CEDIDO: GRABAMOS DOS REGISTROS POR CONCEPTO
      -- SUMAMOS 50 POR LA NOMENCLATURA TOMADA DE QUE LOS CONCEPTOS CEDIDOS
      -- SON EL MISMO CODIGO MAS 50.
      ximporte := NVL(ximpcedid, 0);
      xconcepto := concepto + 50;
      --28559 KBR 21/10/2013
      ximporte_monpol := ximpcedid_monpol;

      --28559 KBR 21/10/2013
      --ximporte := f_round(ximporte, pmoneda);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
      --ximporte_monpol := f_round(ximpcedid_monpol, pcmonpol);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
      --28559 KBR 21/10/2013
      BEGIN
         INSERT INTO detreciboscar
                     (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo, cageven,
                      nmovima, iconcep_monpol, fcambio)   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
              VALUES (proceso, recibo, xconcepto, ximporte, garantia, riesgo, xcageven,
                      xnmovima, ximporte_monpol, pfcambio);   -- BUG 18423 - 22/11/2011 - JMP - LCOL000 - Multimoneda
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            BEGIN   -- REGISTRO YA EXISTE. LE SUMAMOS EL NUEVO IMPORTE.
               UPDATE detreciboscar
                  SET iconcep = iconcep + ximporte,
                      iconcep_monpol = iconcep_monpol + ximporte_monpol
                WHERE sproces = proceso
                  AND nrecibo = recibo
                  AND cconcep = xconcepto
                  AND cgarant = garantia
                  AND nriesgo = riesgo
                  AND nmovima = xnmovima;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 104378;   -- ERROR AL ACTUALIZAR DETRECIBOSCAR
            END;
         WHEN OTHERS THEN
            RETURN 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
      END;
   END IF;

   RETURN 0;
END f_insdetreccar;

/

  GRANT EXECUTE ON "AXIS"."F_INSDETRECCAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSDETRECCAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSDETRECCAR" TO "PROGRAMADORESCSI";
