--------------------------------------------------------
--  DDL for Function F_ATRAS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ATRAS2" (
   psproces IN NUMBER,
   pfinici IN DATE,
   pmotiu IN NUMBER,
   pmoneda IN NUMBER,
   pcodi IN NUMBER,
   ptipo IN NUMBER,
   psseguro IN NUMBER DEFAULT NULL)
   RETURN NUMBER IS
/***********************************************************************
   F_ATRAS2: Aquesta funci¿ permet crear moviments d'anul.laci¿
                de cessions a CESIONESREA.
                Aquests moviments est¿n originats per el canvi d'un
                facultatiu o per el canvi d'un c¿mul...
                Si es canvi de facultatiu, els par¿metres d'entrada son
                n¿ de facultatiu(a pcodi) + tipus = 2 (a ptipo).
                Si es canvi de c¿mul, els par¿metres d'entrada son
                n¿ de c¿mul(a pcodi) + tipus = 3 (a ptipo).
                Els tipus o motius de moviment anul.lables son:
                    01 - regularitzaci¿
                    03 - nova producci¿
                    04 - suplement
                    05 - cartera
                    09 - rehabilitaci¿
                    40 - allargament de renovaci¿ (cap al futur)
                Els tipus o motius que es crean son:
                    08 - anul.laci¿ per regularitzaci¿
   psseguro que no s'ha de recalcular
***********************************************************************
   NOMBRE:       F_ATRAS2

   PROP¿SITO:  Crear moviments d'anul.laci¿ de cessions a CESIONESREA

   REVISIONES:

   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ----------------------------------------
   3.0        23/02/2009  JGR              evitar que w_dias_origen sea 0 (divisor)
   4.0        16/09/2009  FAL              0011100: CRE046 - Revisi¿n de cesionesrea. Substituir crida f_round_forpag per f_round
   5.0        25/05/2013  LCF              0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
   6.0        16/10/2013  MMM              0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision
   7.0        28/07/2014  DCT              0032363: LCOL_PROD-QT 0013676: La solicitud de poliza No 30063906 hizo cesion sin haber sido emitida y en estado anulada
   8.0        04/09/2014  DFD              0028056:NOTA 82706 QT_8672 extraprima en caso de suplemento.
   9.0        09/11/2016 HRE               9. CONF-294: manejo de detalle por garantia
***********************************************************************/
   codi_error     NUMBER := 0;
   w_dias         NUMBER;
   w_dias_origen  NUMBER;
   w_icesion      cesionesrea.icesion%TYPE;   -- bug 25803
   w_ipritarrea   cesionesrea.ipritarrea%TYPE;   -- bug 25803
   w_iextrea      cesionesrea.iextrea%TYPE;   -- bug 30326
   w_idtosel      cesionesrea.idtosel%TYPE;   -- bug 25803
   w_scesrea      cesionesrea.scesrea%TYPE;   -- bug 25803
   avui           DATE;
   w_finici       cesionesrea.fefecto%TYPE;   -- bug 25803
   lnmovigen      cesionesrea.nmovigen%TYPE;   -- bug 25803
   lcforpag       seguros.cforpag%TYPE;   -- bug 25803
   lsproduc       seguros.sproduc%TYPE;   -- bug 25803
   lsseguro_ant   seguros.sseguro%TYPE;   -- bug 25803
   w_sdetcesrea   det_cesionesrea.sdetcesrea%TYPE; --BUG CONF-294  Fecha (09/11/2016) - HRE

   CURSOR cur_movim IS
      SELECT   *
          FROM cesionesrea
         WHERE ((sfacult = pcodi
                 AND ptipo = 2)
                OR(scumulo = pcodi
                   AND ptipo = 3))
           AND(cgenera = 01
               OR cgenera = 03
               OR cgenera = 04
               OR cgenera = 05
               OR cgenera = 09
               OR cgenera = 40)
           AND fefecto <= pfinici   --BUG 32363 - 25/07/2014
           AND fvencim > pfinici
           AND(fanulac > pfinici
               OR fanulac IS NULL)
           AND(fregula > pfinici
               OR fregula IS NULL)
           AND(sseguro <> psseguro
               OR psseguro IS NULL)
      ORDER BY scesrea;   --bug: 21186  ETM 01/02/2012

      --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
      CURSOR cur_detalle_rea(pscesrea NUMBER) IS
         SELECT *
           FROM det_cesionesrea
          WHERE scesrea = pscesrea;
      --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE
BEGIN
   lsseguro_ant := -1;
   avui := f_sysdate;

   FOR regmovim IN cur_movim LOOP
      IF lsseguro_ant <> regmovim.sseguro THEN
         lsseguro_ant := regmovim.sseguro;

         BEGIN
            SELECT NVL(MAX(nmovigen), 0) + 1
              INTO lnmovigen
              FROM cesionesrea
             WHERE sseguro = regmovim.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               lnmovigen := 1;
         END;

         BEGIN
            -- obtenim forma de pagament
            SELECT cforpag, sproduc
              INTO lcforpag, lsproduc
              FROM seguros
             WHERE sseguro = regmovim.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101919;
         END;
      END IF;

      IF regmovim.fefecto <= pfinici THEN
         w_finici := pfinici;
      ELSE
         w_finici := regmovim.fefecto;
      END IF;

      BEGIN
         UPDATE cesionesrea
            SET fregula = w_finici
          WHERE scesrea = regmovim.scesrea;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            codi_error := 104738;
            RETURN(codi_error);
         WHEN OTHERS THEN
            codi_error := 104739;
            RETURN(codi_error);
      END;

      -- 6.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
      --codi_error := f_difdata(regmovim.fefecto, regmovim.fvencim, 1, 3, w_dias_origen);
      codi_error := f_difdata(regmovim.fefecto, regmovim.fvencim, 3, 3, w_dias_origen);

      -- 6.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
      IF codi_error <> 0 THEN
         RETURN(codi_error);
      END IF;

      -- 6.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
      --codi_error := f_difdata(w_finici, regmovim.fvencim, 1, 3, w_dias);
      codi_error := f_difdata(w_finici, regmovim.fvencim, 3, 3, w_dias);

      -- 6.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
      IF codi_error <> 0 THEN
         RETURN(codi_error);
      END IF;

      IF w_dias_origen = 0 THEN
         w_icesion := 0;
         w_ipritarrea := 0;
         w_idtosel := 0;
      ELSE
         w_icesion := -1 * regmovim.icesion * w_dias / w_dias_origen;
         w_ipritarrea := -1 * regmovim.ipritarrea * w_dias / w_dias_origen;
         w_idtosel := -1 * regmovim.idtosel * w_dias / w_dias_origen;
      END IF;

-- BUG 11100 - 16/09/2009 - FAL - Substituir crida f_round_forpag per f_round
      /*
      w_icesion := f_round_forpag(w_icesion, lcforpag, pmoneda, lsproduc);
      w_ipritarrea := f_round_forpag(w_ipritarrea, lcforpag, pmoneda, lsproduc);
      w_idtosel := f_round_forpag(w_idtosel, lcforpag, pmoneda, lsproduc);
      */
      w_icesion := f_round(w_icesion, pmoneda);
      w_ipritarrea := f_round(w_ipritarrea, pmoneda);
      w_idtosel := f_round(w_idtosel, pmoneda);
--FI BUG 11100 - 16/09/2009 ¿ FAL

      -- Bug 30326 - 12/09/2014 - DF: extraprima en caso de suplemento Inicio
      w_iextrea := f_round((regmovim.iextrea * w_dias) / w_dias_origen, pmoneda);

      -- Bug 30326 - 12/09/2014 - DF: extraprima en caso de suplemento Fin
      SELECT scesrea.NEXTVAL
        INTO w_scesrea
        FROM DUAL;

      BEGIN
         INSERT INTO cesionesrea
                     (scesrea, ncesion, icesion, icapces,
                      sseguro, nversio, scontra, ctramo,
                      sfacult, nriesgo, icomisi, icomreg,
                      scumulo, cgarant, spleno, ccalif1,
                      ccalif2, nmovimi, fefecto, fvencim,
                      pcesion, sproces, cgenera, fgenera, ipritarrea, idtosel,
                      psobreprima, cdetces, fanulac,
                      fregula, nmovigen, ipleno, icapaci,
                      iextrea, itarifrea)
              VALUES (w_scesrea, regmovim.ncesion, w_icesion, regmovim.icapces,
                      regmovim.sseguro, regmovim.nversio, regmovim.scontra, regmovim.ctramo,
                      regmovim.sfacult, regmovim.nriesgo, regmovim.icomisi, regmovim.icomreg,
                      regmovim.scumulo, regmovim.cgarant, regmovim.spleno, regmovim.ccalif1,
                      regmovim.ccalif2, regmovim.nmovimi, w_finici, regmovim.fvencim,
                      regmovim.pcesion, psproces, pmotiu, avui, w_ipritarrea, w_idtosel,
                      regmovim.psobreprima, regmovim.cdetces, regmovim.fanulac,
                      regmovim.fregula, lnmovigen, regmovim.ipleno, regmovim.icapaci,
                      -w_iextrea, regmovim.itarifrea);
--          post;


               --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
         FOR rg_detalle_rea IN cur_detalle_rea(regmovim.scesrea) LOOP
            SELECT sdetcesrea.NEXTVAL
              INTO w_sdetcesrea
              FROM DUAL;

            INSERT INTO det_cesionesrea(scesrea, sdetcesrea, sseguro, nmovimi, ptramo, cgarant, icesion, icapces,
                                        pcesion, psobreprima, iextrap , iextrea , ipritarrea , itarifrea, icomext,
                                        ccompani, falta, cusualt, fmodifi, cusumod, cdepura, fefecdema,
                                        nmovidep, sperson)

            VALUES (w_scesrea, w_sdetcesrea, rg_detalle_rea.sseguro, rg_detalle_rea.nmovimi, rg_detalle_rea.ptramo,
                    rg_detalle_rea.cgarant, -rg_detalle_rea.icesion, rg_detalle_rea.icapces, rg_detalle_rea.pcesion,
                    rg_detalle_rea.psobreprima, rg_detalle_rea.iextrap , -rg_detalle_rea.iextrea , -rg_detalle_rea.ipritarrea ,
                    rg_detalle_rea.itarifrea, -rg_detalle_rea.icomext,rg_detalle_rea.ccompani, rg_detalle_rea.falta,
                    rg_detalle_rea.cusualt, f_sysdate, f_user, rg_detalle_rea.cdepura, rg_detalle_rea.fefecdema,
                    rg_detalle_rea.nmovidep, rg_detalle_rea.sperson);
         END LOOP;
         --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE

      EXCEPTION
         WHEN OTHERS THEN
            codi_error := 104740;
            RETURN(codi_error);
      END;
   END LOOP;

   RETURN(codi_error);
END f_atras2;

/

  GRANT EXECUTE ON "AXIS"."F_ATRAS2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ATRAS2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ATRAS2" TO "PROGRAMADORESCSI";
