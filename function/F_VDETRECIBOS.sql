--------------------------------------------------------
--  DDL for Function F_VDETRECIBOS
--------------------------------------------------------
CREATE OR REPLACE FUNCTION f_vdetrecibos(
  pmodo IN VARCHAR2,
   pnrecibo IN NUMBER,
   psproces IN NUMBER DEFAULT 0)
   RETURN NUMBER IS
/* ******************************************************************
 ALLIBADM. OMPLE LA TAULA VDETRECIBOS O
 VDETRECIBOSCAR, SEGONS EL PMODO ('P' O 'R' O 'A').

      Ver        Fecha        Autor             Descripción
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creación de la función.
      2.0        XX/XX/XXXX   XXX     2. Se añade el campo que almacena la comision de la cia (ICOMCIA).
      3.0        26/10/2011   JMP     3. 0018423: LCOL000 - Multimoneda
      4.0        02/08/2012   APD     4. 0023074: LCOL_T010-Tratamiento Gastos de Expedición
      5.0        13/02/2013    FAL    5. 0025988: LCOL_C004: Realizar desarrollo Convenio Liberty web
      6.0        26/03/2013   JGR     6. 0026562: LCOL_A005-Incidencias en las liquidaciones de comisiones con co-corretaje y coaseguro
      7.0        22/11/2013   MMM     7. 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051
      8.0        07/02/2014   KBR     8. 0030041: POSCOA API Renovacion cartera genera error
      9.0        19/01/2020   JLTS    8. IAXIS-3264: Baja de amparos.
   ******************************************************************/
   xctipcoa       NUMBER;
   xcempres       recibos.cempres%TYPE;
   error          axis_literales.slitera%TYPE;
   -- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Inicio
   xsmovrec       NUMBER;
   xfemisio       DATE;
   xfefecto       DATE;
   xfmovim        DATE;
-- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Fin
   --Bug 31135  Variabñes para ctacliente
   xsseguro       NUMBER;
   xnmovimi       NUMBER;
   xtotalr        NUMBER;
   xsproduc       NUMBER;
   num_err        NUMBER;
   v_seqcaja      NUMBER;
   xctiprec       NUMBER;
------
   vccobban       recibos.ccobban%TYPE;   -- Bug 37070 MMS 20150915
   vcagente       recibos.cagente%TYPE;   -- Bug 37070 MMS 20150915
   vsmovagr       movrecibo.smovagr%TYPE := 0;   -- Bug 37070 MMS 20150915
   vsmovrec       movrecibo.smovrec%TYPE;
   vnliqmen       NUMBER := NULL;   -- Bug 37070 MMS 20150915
   Vnliqlin       Number := Null;   -- Bug 37070 MMS 20150915
   pmoneda        Number;--AMA-209
   -- INI -IAXIS-3264 -19/01/2020
   v_iconcep_monpol_aux detrecibos.iconcep_monpol%TYPE;
   vssolicit      estseguros.sseguro%TYPE;

   -- FIN -IAXIS-3264 -19/01/2020
Begin
--- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim 'RRIE')
   IF pmodo IN('R', 'A', 'ANP', 'I', 'RRIE') THEN
      BEGIN
         -- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Inicio
         SELECT r.ctipcoa, r.cempres, r.femisio, r.fefecto, r.sseguro, nmovimi, sproduc,
                r.ctiprec
           INTO xctipcoa, xcempres, xfemisio, xfefecto, xsseguro, xnmovimi, xsproduc,
                xctiprec
           FROM recibos r, seguros s
          WHERE r.sseguro = s.sseguro
            AND nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101902;   -- RECIBO NO ENCONTRADO EN RECIBOS
         WHEN OTHERS THEN
            RETURN 102367;   -- ERROR AL LEER DE LA TABLA RECIBOS
      END;

      --AMA-209-24/06/2016-VCG-REDONDEO SRI
      If Nvl(Pac_Parametros.F_Parempresa_N(Xcempres, 'REDONDEO_SRI'), 0) > 0 Then
       Pmoneda:= Pac_Monedas.F_Moneda_Producto(Xsproduc);
      BEGIN
         -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
         INSERT INTO vdetrecibos
                     (nrecibo, iprinet, irecext, iconsor, ireccon, iips, idgs, iarbitr, ifng,
                      irecfra, idtotec, idtocom, icombru, icomret, ipridev, idtoom, iderreg,
                      icomdev, iretdev, iocorec,   -- Se añade el campo que almacena otros conceptos recargo.
                                                it1pri, it1dto, it1con, it1imp, it1totr,
                      it1rec, icednet, icedrex, icedcon, icedrco, icedips, iceddgs, icedarb,
                      icedfng, icedrfr, iceddte, iceddco, icedcbr, icedcrt, icedpdv, iceddom,
                      icedreg, icedcdv, icedrdv, it2pri, it2dto, it2con, it2imp, it2totr,
                      it2rec, itotpri, itotdto, itotcon, itotimp, itotrec, itotalr, icombrui,
                      icomreti, icomdevi, icomdrti, icombruc, icomretc, icomdevc, icomdrtc,
                      icomcia,   -- Se añade el campo que almacena la comision de la cia.
                              iimp_1, iimp_2, iimp_3, iimp_4, iconvoleoducto, iimp_5, iimp_6, iimp_7, iimp_8, -- CONF-905
                      iimp_9, iimp_10, iimp_11 )
            SELECT   nrecibo, SUM(DECODE(cconcep, 0, iconcep, 0)) iprinet,   -- IMPORTES PARTE LOCAL
                     SUM(DECODE(cconcep, 1, iconcep, 0)) irecext,
                     SUM(DECODE(cconcep, 2, iconcep, 0)) iconsor,
                     Sum(Decode(Cconcep, 3, Iconcep, 0)) Ireccon,
                     f_round(SUM(DECODE(cconcep, 4, iconcep, 0)), pmoneda) iips,
                     f_round(SUM(DECODE(cconcep, 5, iconcep, 0)), pmoneda) idgs,
                     f_round(SUM(DECODE(cconcep, 6, iconcep, 0)), pmoneda) iarbitr,
                     SUM(DECODE(cconcep, 7, iconcep, 0)) ifng,
                     f_round(SUM(DECODE(cconcep, 8, iconcep, 0)), pmoneda) irecfra,
                     SUM(DECODE(cconcep, 9, iconcep, 0)) idtotec,
                     SUM(DECODE(cconcep, 10, iconcep, 0)) idtocom,
                     SUM(DECODE(cconcep, 11, iconcep, 0)) icombru,
                     SUM(DECODE(cconcep, 12, iconcep, 0)) icomret,
                     SUM(DECODE(cconcep, 21, iconcep, 0)) ipridev,
                     SUM(DECODE(cconcep, 13, iconcep, 0)) idtoom,
                     f_round(SUM(DECODE(cconcep, 14, iconcep, 0)), pmoneda) iderreg,
                     SUM(DECODE(cconcep, 15, iconcep, 0)) icomdev,
                     SUM(DECODE(cconcep, 16, iconcep, 0)) iretdev,
                     SUM(DECODE(cconcep, 26, iconcep, 0)) iocorec,

--
                     (SUM(DECODE(cconcep, 0, iconcep, 0)) +   -- CALCULO DE TOTALES LOCALES
                                                           SUM(DECODE(cconcep, 1, iconcep, 0)))
                                                                                       it1pri,

--
                     SUM(DECODE(cconcep, 13, iconcep, 0)) it1dto,

--
                     (SUM(DECODE(cconcep, 2, iconcep, 0)) + SUM(DECODE(cconcep, 3, iconcep, 0)))
                                                                                       it1con,

--
                     (f_round(SUM(DECODE(cconcep, 4, iconcep, 0)), pmoneda) + f_round(SUM(DECODE(cconcep, 5, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 6, iconcep, 0)), pmoneda)
                      + SUM(DECODE(cconcep, 7, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 86,iconcep, 0)), pmoneda)   -- 6. 0026562
                                                            ) it1imp,

--
                     (SUM(DECODE(cconcep, 0, iconcep, 0)) + SUM(DECODE(cconcep, 1, iconcep, 0))
                      + SUM(DECODE(cconcep, 2, iconcep, 0))
                      + SUM(DECODE(cconcep, 3, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 4, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 5, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 6, iconcep, 0)), pmoneda)
                      + SUM(DECODE(cconcep, 7, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 8, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 14, iconcep, 0)), pmoneda)
                      - SUM(DECODE(cconcep, 13, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 86, iconcep, 0)), pmoneda)) it1totr,

--
                     (f_round(SUM(DECODE(cconcep, 8, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 14, iconcep, 0)), pmoneda)) it1rec,   -- Bug 27346-147180 - 20/06/2012 - AMC

--
                     SUM(DECODE(cconcep, 50, iconcep, 0)) icednet,   -- IMPORTES PARTE CEDIDA
                     SUM(DECODE(cconcep, 51, iconcep, 0)) icedrex,
                     SUM(DECODE(cconcep, 52, iconcep, 0)) icedcon,
                     SUM(DECODE(cconcep, 53, iconcep, 0)) icedrco,
                     f_round(SUM(DECODE(cconcep, 54, iconcep, 0)), pmoneda) icedips,
                     f_round(SUM(DECODE(cconcep, 55, iconcep, 0)), pmoneda) iceddgs,
                     f_round(SUM(DECODE(cconcep, 56, iconcep, 0)), pmoneda) icedarb,
                     SUM(DECODE(cconcep, 57, iconcep, 0)) icedfng,
                     f_round(SUM(DECODE(cconcep, 58, iconcep, 0)), pmoneda) icedrfr,
                     SUM(DECODE(cconcep, 59, iconcep, 0)) iceddte,
                     SUM(DECODE(cconcep, 60, iconcep, 0)) iceddco,
                     SUM(DECODE(cconcep, 61, iconcep, 0)) icedcbr,
                     SUM(DECODE(cconcep, 62, iconcep, 0)) icedcrt,
                     SUM(DECODE(cconcep, 71, iconcep, 0)) icedpdv,
                     SUM(DECODE(cconcep, 63, iconcep, 0)) iceddom,
                     f_round(SUM(DECODE(cconcep, 64, iconcep, 0)), pmoneda) icedreg,
                     SUM(DECODE(cconcep, 65, iconcep, 0)) icedcdv,
                     SUM(DECODE(cconcep, 66, iconcep, 0)) icedrdv,

--
                     (SUM(DECODE(cconcep, 50, iconcep, 0))
                      +   -- CALCULO DE TOTALES PARTE CEDIDA
                       SUM(DECODE(cconcep, 51, iconcep, 0))) it2pri,

--
                     SUM(DECODE(cconcep, 63, iconcep, 0)) it2dto,

--
                     (SUM(DECODE(cconcep, 52, iconcep, 0))
                      + SUM(DECODE(cconcep, 53, iconcep, 0))) it2con,

--
                     (f_round(SUM(DECODE(cconcep, 54, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 55, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 56, iconcep, 0)), pmoneda)
                      + SUM(DECODE(cconcep, 57, iconcep, 0))) it2imp,

--
                     (SUM(DECODE(cconcep, 50, iconcep, 0))
                      + SUM(DECODE(cconcep, 51, iconcep, 0))
                      + SUM(DECODE(cconcep, 52, iconcep, 0))
                      + SUM(DECODE(cconcep, 53, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 54, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 55, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 56, iconcep, 0)), pmoneda)
                      + SUM(DECODE(cconcep, 57, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 58, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 64, iconcep, 0)), pmoneda)
                      - SUM(DECODE(cconcep, 63, iconcep, 0))) it2totr,

--
                     (f_round(SUM(DECODE(cconcep, 58, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 64, iconcep, 0)), pmoneda)) it2rec,

--
                     0, 0, 0, 0, 0, 0,(SUM(DECODE(cconcep, 17, iconcep, 0))) icombrui,   -- CALCULO DE IMPORTES DE COMISIONES INDIRECTAS
                     (SUM(DECODE(cconcep, 18, iconcep, 0))) icomreti,
                     (SUM(DECODE(cconcep, 19, iconcep, 0))) icomdevi,
                     (SUM(DECODE(cconcep, 20, iconcep, 0))) icomdrti,
                     (SUM(DECODE(cconcep, 22, iconcep, 0))) icombruc,   -- CALCULO DE IMPORTES DE COM. AGTE. COBRADOR
                     (SUM(DECODE(cconcep, 23, iconcep, 0))) icomretc,
                     (SUM(DECODE(cconcep, 24, iconcep, 0))) icomdevc,
                     (SUM(DECODE(cconcep, 25, iconcep, 0))) icomdrtc,
                     SUM(DECODE(cconcep, 30, iconcep, 0)) icomcia,   -- Se añade el campo que almacena la comision de la cia.
                     SUM(DECODE(cconcep, 32, iconcep, 0)) iimp_1,
                     SUM(DECODE(cconcep, 40, iconcep, 0)) iimp_2,
                     SUM(DECODE(cconcep, 41, iconcep, 0)) iimp_3,
                     SUM(DECODE(cconcep, 42, iconcep, 0)) iimp_4,
                     SUM(DECODE(cconcep, 43, iconcep, 0)) iconvoleoducto,   -- BUG 25988 - FAL - 13/02/2013
                     -- BUG CONF-905 inicio
                     SUM(DECODE(cconcep, 82, iconcep, 0)) iimp_5,
                     SUM(DECODE(cconcep, 83, iconcep, 0)) iimp_6,
                     SUM(DECODE(cconcep, 85, iconcep, 0)) iimp_7,
                     SUM(DECODE(cconcep, 84, iconcep, 0)) iimp_8,
                     -- BUG CONF-905 Fin
                     SUM(decode(cconcep, 33, iconcep, 0)) iimp_9,  -- BUG 1970 AP Retención en la fuente sobre comisión
                     SUM(decode(cconcep, 34, iconcep, 0)) iimp_10, -- BUG 1970 AP Retención por IVA sobre comisión
                     SUM(DECODE(cconcep, 35, iconcep, 0)) iimp_11  -- BUG 1970 AP Retención por ICA sobre comisión
                FROM detrecibos
               WHERE nrecibo = pnrecibo
            GROUP BY nrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103469;   -- REBUT NO TROBAT A DETRECIBOS
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 103471;   -- REGISTRE DUPLICAT A VDETRECIBOS
         WHEN OTHERS THEN
            RETURN 103473;   -- ERROR A L' INSERIR A VDETRECIBOS
      End;
      Else
       BEGIN
         -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
         INSERT INTO vdetrecibos
                     (nrecibo, iprinet, irecext, iconsor, ireccon, iips, idgs, iarbitr, ifng,
                      irecfra, idtotec, idtocom, icombru, icomret, ipridev, idtoom, iderreg,
                      icomdev, iretdev, iocorec,   -- Se añade el campo que almacena otros conceptos recargo.
                                                it1pri, it1dto, it1con, it1imp, it1totr,
                      it1rec, icednet, icedrex, icedcon, icedrco, icedips, iceddgs, icedarb,
                      icedfng, icedrfr, iceddte, iceddco, icedcbr, icedcrt, icedpdv, iceddom,
                      icedreg, icedcdv, icedrdv, it2pri, it2dto, it2con, it2imp, it2totr,
                      it2rec, itotpri, itotdto, itotcon, itotimp, itotrec, itotalr, icombrui,
                      icomreti, icomdevi, icomdrti, icombruc, icomretc, icomdevc, icomdrtc,
                      icomcia,   -- Se añade el campo que almacena la comision de la cia.
                              iimp_1, iimp_2, iimp_3, iimp_4, iconvoleoducto, iimp_5, iimp_6, iimp_7, iimp_8,
                      iimp_9, iimp_10, iimp_11 )
            SELECT   nrecibo, SUM(DECODE(cconcep, 0, iconcep, 0)) iprinet,   -- IMPORTES PARTE LOCAL
                     SUM(DECODE(cconcep, 1, iconcep, 0)) irecext,
                     SUM(DECODE(cconcep, 2, iconcep, 0)) iconsor,
                     SUM(DECODE(cconcep, 3, iconcep, 0)) ireccon,
                     SUM(DECODE(cconcep, 4, iconcep, 0)) iips,
                     SUM(DECODE(cconcep, 5, iconcep, 0)) idgs,
                     SUM(DECODE(cconcep, 6, iconcep, 0)) iarbitr,
                     SUM(DECODE(cconcep, 7, iconcep, 0)) ifng,
                     SUM(DECODE(cconcep, 8, iconcep, 0)) irecfra,
                     SUM(DECODE(cconcep, 9, iconcep, 0)) idtotec,
                     SUM(DECODE(cconcep, 10, iconcep, 0)) idtocom,
                     SUM(DECODE(cconcep, 11, iconcep, 0)) icombru,
                     SUM(DECODE(cconcep, 12, iconcep, 0)) icomret,
                     SUM(DECODE(cconcep, 21, iconcep, 0)) ipridev,
                     SUM(DECODE(cconcep, 13, iconcep, 0)) idtoom,
                     SUM(DECODE(cconcep, 14, iconcep, 0)) iderreg,
                     SUM(DECODE(cconcep, 15, iconcep, 0)) icomdev,
                     SUM(DECODE(cconcep, 16, iconcep, 0)) iretdev,
                     SUM(DECODE(cconcep, 26, iconcep, 0)) iocorec,

--
                     (SUM(DECODE(cconcep, 0, iconcep, 0)) +   -- CALCULO DE TOTALES LOCALES
                                                           SUM(DECODE(cconcep, 1, iconcep, 0)))
                                                                                       it1pri,

--
                     SUM(DECODE(cconcep, 13, iconcep, 0)) it1dto,

--
                     (SUM(DECODE(cconcep, 2, iconcep, 0)) + SUM(DECODE(cconcep, 3, iconcep, 0)))
                                                                                       it1con,

--
                     (SUM(DECODE(cconcep, 4, iconcep, 0)) + SUM(DECODE(cconcep, 5, iconcep, 0))
                      + SUM(DECODE(cconcep, 6, iconcep, 0))
                      + SUM(DECODE(cconcep, 7, iconcep, 0))
                      + SUM(DECODE(cconcep, 86, iconcep, 0))   -- 6. 0026562
                                                            ) it1imp,

--
                     (SUM(DECODE(cconcep, 0, iconcep, 0)) + SUM(DECODE(cconcep, 1, iconcep, 0))
                      + SUM(DECODE(cconcep, 2, iconcep, 0))
                      + SUM(DECODE(cconcep, 3, iconcep, 0))
                      + SUM(DECODE(cconcep, 4, iconcep, 0))
                      + SUM(DECODE(cconcep, 5, iconcep, 0))
                      + SUM(DECODE(cconcep, 6, iconcep, 0))
                      + SUM(DECODE(cconcep, 7, iconcep, 0))
                      + SUM(DECODE(cconcep, 8, iconcep, 0))
                      + SUM(DECODE(cconcep, 14, iconcep, 0))
                      - SUM(DECODE(cconcep, 13, iconcep, 0))
                      + SUM(DECODE(cconcep, 86, iconcep, 0))) it1totr,

--
                     (SUM(DECODE(cconcep, 8, iconcep, 0))
                      + SUM(DECODE(cconcep, 14, iconcep, 0))) it1rec,   -- Bug 27346-147180 - 20/06/2012 - AMC

--
                     SUM(DECODE(cconcep, 50, iconcep, 0)) icednet,   -- IMPORTES PARTE CEDIDA
                     SUM(DECODE(cconcep, 51, iconcep, 0)) icedrex,
                     SUM(DECODE(cconcep, 52, iconcep, 0)) icedcon,
                     SUM(DECODE(cconcep, 53, iconcep, 0)) icedrco,
                     SUM(DECODE(cconcep, 54, iconcep, 0)) icedips,
                     SUM(DECODE(cconcep, 55, iconcep, 0)) iceddgs,
                     SUM(DECODE(cconcep, 56, iconcep, 0)) icedarb,
                     SUM(DECODE(cconcep, 57, iconcep, 0)) icedfng,
                     SUM(DECODE(cconcep, 58, iconcep, 0)) icedrfr,
                     SUM(DECODE(cconcep, 59, iconcep, 0)) iceddte,
                     SUM(DECODE(cconcep, 60, iconcep, 0)) iceddco,
                     SUM(DECODE(cconcep, 61, iconcep, 0)) icedcbr,
                     SUM(DECODE(cconcep, 62, iconcep, 0)) icedcrt,
                     SUM(DECODE(cconcep, 71, iconcep, 0)) icedpdv,
                     SUM(DECODE(cconcep, 63, iconcep, 0)) iceddom,
                     SUM(DECODE(cconcep, 64, iconcep, 0)) icedreg,
                     SUM(DECODE(cconcep, 65, iconcep, 0)) icedcdv,
                     SUM(DECODE(cconcep, 66, iconcep, 0)) icedrdv,

--
                     (SUM(DECODE(cconcep, 50, iconcep, 0))
                      +   -- CALCULO DE TOTALES PARTE CEDIDA
                       SUM(DECODE(cconcep, 51, iconcep, 0))) it2pri,

--
                     SUM(DECODE(cconcep, 63, iconcep, 0)) it2dto,

--
                     (SUM(DECODE(cconcep, 52, iconcep, 0))
                      + SUM(DECODE(cconcep, 53, iconcep, 0))) it2con,

--
                     (SUM(DECODE(cconcep, 54, iconcep, 0))
                      + SUM(DECODE(cconcep, 55, iconcep, 0))
                      + SUM(DECODE(cconcep, 56, iconcep, 0))
                      + SUM(DECODE(cconcep, 57, iconcep, 0))) it2imp,

--
                     (SUM(DECODE(cconcep, 50, iconcep, 0))
                      + SUM(DECODE(cconcep, 51, iconcep, 0))
                      + SUM(DECODE(cconcep, 52, iconcep, 0))
                      + SUM(DECODE(cconcep, 53, iconcep, 0))
                      + SUM(DECODE(cconcep, 54, iconcep, 0))
                      + SUM(DECODE(cconcep, 55, iconcep, 0))
                      + SUM(DECODE(cconcep, 56, iconcep, 0))
                      + SUM(DECODE(cconcep, 57, iconcep, 0))
                      + SUM(DECODE(cconcep, 58, iconcep, 0))
                      + SUM(DECODE(cconcep, 64, iconcep, 0))
                      - SUM(DECODE(cconcep, 63, iconcep, 0))) it2totr,

--
                     (SUM(DECODE(cconcep, 58, iconcep, 0))
                      + SUM(DECODE(cconcep, 64, iconcep, 0))) it2rec,

--
                     0, 0, 0, 0, 0, 0,(SUM(DECODE(cconcep, 17, iconcep, 0))) icombrui,   -- CALCULO DE IMPORTES DE COMISIONES INDIRECTAS
                     (SUM(DECODE(cconcep, 18, iconcep, 0))) icomreti,
                     (SUM(DECODE(cconcep, 19, iconcep, 0))) icomdevi,
                     (SUM(DECODE(cconcep, 20, iconcep, 0))) icomdrti,
                     (SUM(DECODE(cconcep, 22, iconcep, 0))) icombruc,   -- CALCULO DE IMPORTES DE COM. AGTE. COBRADOR
                     (SUM(DECODE(cconcep, 23, iconcep, 0))) icomretc,
                     (SUM(DECODE(cconcep, 24, iconcep, 0))) icomdevc,
                     (SUM(DECODE(cconcep, 25, iconcep, 0))) icomdrtc,
                     SUM(DECODE(cconcep, 30, iconcep, 0)) icomcia,   -- Se añade el campo que almacena la comision de la cia.
                     SUM(DECODE(cconcep, 32, iconcep, 0)) iimp_1,
                     SUM(DECODE(cconcep, 40, iconcep, 0)) iimp_2,
                     SUM(DECODE(cconcep, 41, iconcep, 0)) iimp_3,
                     SUM(DECODE(cconcep, 42, iconcep, 0)) iimp_4,
                     SUM(DECODE(cconcep, 43, iconcep, 0)) iconvoleoducto,   -- BUG 25988 - FAL - 13/02/2013
                     -- BUG CONF-905 inicio
                     SUM(DECODE(cconcep, 82, iconcep, 0)) iimp_5,
                     SUM(DECODE(cconcep, 83, iconcep, 0)) iimp_6,
                     SUM(DECODE(cconcep, 85, iconcep, 0)) iimp_7,
                     SUM(DECODE(cconcep, 84, iconcep, 0)) iimp_8,
                     -- BUG CONF-905 Fin
                     SUM(decode(cconcep, 33, iconcep, 0)) iimp_9,  -- BUG 1970 AP Retención en la fuente sobre comisión
                     SUM(decode(cconcep, 34, iconcep, 0)) iimp_10, -- BUG 1970 AP Retención por IVA sobre comisión
                     SUM(DECODE(cconcep, 35, iconcep, 0)) iimp_11  -- BUG 1970 AP Retención por ICA sobre comisión
                FROM detrecibos
               WHERE nrecibo = pnrecibo
            GROUP BY nrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103469;   -- REBUT NO TROBAT A DETRECIBOS
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 103471;   -- REGISTRE DUPLICAT A VDETRECIBOS
         WHEN OTHERS THEN
            RETURN 103473;   -- ERROR A L' INSERIR A VDETRECIBOS
      End;
      END IF;

      IF xctipcoa = 1 THEN
         -- RECIBO ÚNICO
         UPDATE vdetrecibos   -- TOTAL SERA PARTE LOCAL + PARTE CEDIDA
            SET itotpri = it1pri + it2pri,
                itotdto = it1dto + it2dto,
                itotcon = it1con + it2con,
                itotimp = it1imp + it2imp,
                itotalr = it1totr + it2totr + iocorec,
                itotrec = it1rec + it2rec
          WHERE nrecibo = pnrecibo;
      ELSE
         --  XCTIPCOA IS NULL O NO ES UN RECIBO UNICO
         UPDATE vdetrecibos   -- TOTAL SERA PARTE LOCAL
            SET itotpri = it1pri,
                itotdto = it1dto,
                itotcon = it1con,
                itotimp = it1imp,
                itotalr = it1totr + iocorec,
                itotrec = it1rec
          WHERE nrecibo = pnrecibo;
      END IF;

      -- BUG 18423 - 26/10/2011 - JMP - LCOL000 - Multimoneda
      IF NVL(pac_parametros.f_parempresa_n(xcempres, 'MULTIMONEDA'), 0) = 1 THEN

           error := pac_oper_monedas.f_contravalores_recibo(pnrecibo, pmodo);

           IF error <> 0 THEN
             RETURN error;
           END IF;

         error := pac_oper_monedas.f_vdetrecibos_monpol(pnrecibo, pmodo);

         IF error <> 0 THEN
           RETURN error;
         END IF;
      END IF;

      -- FIN BUG 18423 - 26/10/2011 - JMP - LCOL000 - Multimoneda

      -- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Inicio
      -- Si el recibo tiene coaseguro llamamos a F_INSCTACOAS
      IF NVL(xctipcoa, 0) > 0 THEN
         BEGIN
            SELECT smovrec
              INTO xsmovrec
              FROM movrecibo
             WHERE nrecibo = pnrecibo
               AND fmovfin IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_vdetrecibos  num_recibo = ' || pnrecibo,
                           NULL, 'WHEN OTHERS RETURN 104043', SQLERRM);
               RETURN 104043;
         END;

         IF xfemisio < xfefecto THEN
            xfmovim := xfefecto;
         ELSE
            xfmovim := xfemisio;
         END IF;

         error := f_insctacoas(pnrecibo, 0, xcempres, xsmovrec, xfmovim);

         IF error <> 0 THEN
            RETURN error;
         END IF;
      END IF;   -- Del IF que mira si tiene coaseguro

      IF f_cestrec(pnrecibo, NULL) = 0
         AND xctiprec != 5 THEN   --etm
         --Bug 31135  Módulo de cobranza  se implementa aquí para eliminar de
         IF NVL(f_parproductos_v(xsproduc, 'HAYCTACLIENTE'), 0) = 1 THEN
            SELECT itotalr
              INTO xtotalr
              FROM vdetrecibos
             WHERE nrecibo = pnrecibo;

            IF xtotalr <> 0 THEN
               num_err := pac_ctacliente.f_ins_movrecctacli(xcempres, xsseguro, xnmovimi,
                                                            pnrecibo);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         ELSIF NVL(f_parproductos_v(xsproduc, 'HAYCTACLIENTE'), 0) = 2 THEN
            SELECT itotalr
              INTO xtotalr
              FROM vdetrecibos
             WHERE nrecibo = pnrecibo;

            IF xtotalr <> 0 THEN
               num_err := pac_ctacliente.f_apunte_spl(xcempres, xsseguro, xnmovimi, pnrecibo);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               IF xctiprec = 9
                  AND NVL(pac_parametros.f_parempresa_n(xcempres, 'CAJA_COBRA_RECEXT'), 0) = 1 THEN
                  SELECT ccobban, cagente, greatest(femisio,fefecto)
                    INTO vccobban, vcagente, xfmovim
                    FROM recibos
                   WHERE nrecibo = pnrecibo;   -- Bug 37070 MMS 20150915

                  num_err := f_movrecibo(pnrecibo, 1, f_sysdate, NULL, vsmovagr, vnliqmen,
                                         vnliqlin, xfmovim, vccobban, NULL, NULL, vcagente);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  num_err := pac_ctacliente.f_apunte_pago_spl(pcempres => xcempres,
                                                              psseguro => xsseguro,
                                                              pimporte => xtotalr,
                                                              pseqcaja => v_seqcaja);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            END IF;

            num_err := pac_ctacliente.f_apunte_pago_spl(pcempres => xcempres,
                                                        psseguro => xsseguro, pimporte => 0,
                                                        pseqcaja => v_seqcaja);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      ----Bug 31135
      RETURN 0;
      -- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Fin
-- ******************************
-- * CARTERA O NUEVA PRODUCCION *
-- ******************************
   ELSIF pmodo = 'P'
         OR pmodo = 'N'
         OR pmodo = 'PRIE' THEN
      Begin
         -- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Inicio
         Select Ctipcoa, Cempres, Femisio, Fefecto, Sseguro
           INTO xctipcoa, xcempres, xfemisio, xfefecto, xsseguro
           --SELECT ctipcoa, cempres
           --  INTO xctipcoa, xcempres
           -- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Fin
         FROM   reciboscar
          WHERE sproces = psproces
            AND nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 105304;   -- RECIBO NO ENCONTRADO EN RECIBOSCAR
         WHEN OTHERS THEN
            RETURN 105305;   -- ERROR AL LEER DE LA TABLA RECIBOSCAR
      End;

      --AMA-209-24/06/2016-VCG-REDONDEO SRI
      If Nvl(Pac_Parametros.F_Parempresa_N(xcempres, 'REDONDEO_SRI'), 0) > 0 Then
           Pmoneda:= pac_oper_monedas.f_monpol(xsseguro);
      BEGIN
         -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
         INSERT INTO vdetreciboscar
                     (sproces, nrecibo, iprinet, irecext, iconsor, ireccon, iips, idgs,
                      iarbitr, ifng, irecfra, idtotec, idtocom, icombru, icomret, ipridev,
                      idtoom, iderreg, icomdev, iretdev, iocorec,   -- Se añade el campo que almacena otros conceptos recargo.
                                                                 it1pri, it1dto, it1con,
                      it1imp, it1totr, it1rec, icednet, icedrex, icedcon, icedrco, icedips,
                      iceddgs, icedarb, icedfng, icedrfr, iceddte, iceddco, icedcbr, icedcrt,
                      icedpdv, iceddom, icedreg, icedcdv, icedrdv, it2pri, it2dto, it2con,
                      it2imp, it2totr, it2rec, itotpri, itotdto, itotcon, itotimp, itotrec,
                      itotalr, icombrui, icomreti, icomdevi, icomdrti, icombruc, icomretc,
                      icomdevc, icomdrtc, icomcia,   -- Se añade el campo que almacena la comision de la cia.
                                                  iimp_1, iimp_2, iimp_3, iimp_4,
                      iconvoleoducto)
            SELECT   sproces, nrecibo, SUM(DECODE(cconcep, 0, iconcep, 0)) iprinet,   -- IMPORTES PARTE LOCAL
                     SUM(DECODE(cconcep, 1, iconcep, 0)) irecext,
                     SUM(DECODE(cconcep, 2, iconcep, 0)) iconsor,
                     Sum(Decode(Cconcep, 3, Iconcep, 0)) Ireccon,
                     f_round(SUM(DECODE(cconcep, 4, iconcep, 0)), pmoneda) iips,
                     f_round(SUM(DECODE(cconcep, 5, iconcep, 0)), pmoneda) idgs,
                     f_round(SUM(DECODE(cconcep, 6, iconcep, 0)), pmoneda) iarbitr,
                     SUM(DECODE(cconcep, 7, iconcep, 0)) ifng,
                     f_round(SUM(DECODE(cconcep, 8, iconcep, 0)), pmoneda) irecfra,
                     SUM(DECODE(cconcep, 9, iconcep, 0)) idtotec,
                     SUM(DECODE(cconcep, 10, iconcep, 0)) idtocom,
                     SUM(DECODE(cconcep, 11, iconcep, 0)) icombru,
                     SUM(DECODE(cconcep, 12, iconcep, 0)) icomret,
                     SUM(DECODE(cconcep, 21, iconcep, 0)) ipridev,
                     SUM(DECODE(cconcep, 13, iconcep, 0)) idtoom,
                     f_round(SUM(DECODE(cconcep, 14, iconcep, 0)), pmoneda) iderreg,
                     SUM(DECODE(cconcep, 15, iconcep, 0)) icomdev,
                     SUM(DECODE(cconcep, 16, iconcep, 0)) iretdev,
                     SUM(DECODE(cconcep, 26, iconcep, 0)) iocorec,
                     (SUM(DECODE(cconcep, 0, iconcep, 0)) +   -- CALCULO DE TOTALES LOCALES
                                                           SUM(DECODE(cconcep, 1, iconcep, 0)))
                                                                                       it1pri,
                     SUM(DECODE(cconcep, 13, iconcep, 0)) it1dto,
                     (SUM(DECODE(cconcep, 2, iconcep, 0)) + SUM(DECODE(cconcep, 3, iconcep, 0)))
                                                                                       it1con,
                     (f_round(Sum(Decode(Cconcep, 4, Iconcep, 0)), pmoneda)
                     + f_round(SUM(DECODE(cconcep, 5, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 6, iconcep, 0)), pmoneda)
                      + SUM(DECODE(cconcep, 7, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 86, iconcep, 0)), pmoneda)   -- 6. 0026562
                                                            ) it1imp,
                     (SUM(DECODE(cconcep, 0, iconcep, 0)) + SUM(DECODE(cconcep, 1, iconcep, 0))
                      + SUM(DECODE(cconcep, 2, iconcep, 0))
                      + SUM(DECODE(cconcep, 3, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 4, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 5, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 6, iconcep, 0)), pmoneda)
                      + SUM(DECODE(cconcep, 7, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 8, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 14, iconcep, 0)), pmoneda)
                      - SUM(DECODE(cconcep, 13, iconcep, 0))
                      + f_round(Sum(Decode(Cconcep, 86, Iconcep, 0)), pmoneda)) It1totr,
                     (f_round(SUM(DECODE(cconcep, 8, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 14, iconcep, 0)), pmoneda)) it1rec,   -- BUG 27346-147180 - 20/06/2013 - AMC
                     SUM(DECODE(cconcep, 50, iconcep, 0)) icednet,   -- IMPORTES PARTE CEDIDA
                     SUM(DECODE(cconcep, 51, iconcep, 0)) icedrex,
                     SUM(DECODE(cconcep, 52, iconcep, 0)) icedcon,
                     SUM(DECODE(cconcep, 53, iconcep, 0)) icedrco,
                     f_round(SUM(DECODE(cconcep, 54, iconcep, 0)), pmoneda) icedips,
                     f_round(SUM(DECODE(cconcep, 55, iconcep, 0)), pmoneda) iceddgs,
                     f_round(SUM(DECODE(cconcep, 56, iconcep, 0)), pmoneda) icedarb,
                     SUM(DECODE(cconcep, 57, iconcep, 0)) icedfng,
                     f_round(SUM(DECODE(cconcep, 58, iconcep, 0)), pmoneda) icedrfr,
                     SUM(DECODE(cconcep, 59, iconcep, 0)) iceddte,
                     SUM(DECODE(cconcep, 60, iconcep, 0)) iceddco,
                     SUM(DECODE(cconcep, 61, iconcep, 0)) icedcbr,
                     SUM(DECODE(cconcep, 62, iconcep, 0)) icedcrt,
                     SUM(DECODE(cconcep, 71, iconcep, 0)) icedpdv,
                     SUM(DECODE(cconcep, 63, iconcep, 0)) iceddom,
                     f_round(SUM(DECODE(cconcep, 64, iconcep, 0)), pmoneda) icedreg,
                     SUM(DECODE(cconcep, 65, iconcep, 0)) icedcdv,
                     SUM(DECODE(cconcep, 66, iconcep, 0)) icedrdv,
                     (SUM(DECODE(cconcep, 50, iconcep, 0))
                      +   -- CALCULO DE TOTALES PARTE CEDIDA
                       SUM(DECODE(cconcep, 51, iconcep, 0))) it2pri,
                     SUM(DECODE(cconcep, 63, iconcep, 0)) it2dto,
                     (SUM(DECODE(cconcep, 52, iconcep, 0))
                      + SUM(DECODE(cconcep, 53, iconcep, 0))) it2con,
                     (f_round(SUM(DECODE(cconcep, 54, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 55, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 56, iconcep, 0)), pmoneda)
                      + SUM(DECODE(cconcep, 57, iconcep, 0))) it2imp,
                     (SUM(DECODE(cconcep, 50, iconcep, 0))
                      + SUM(DECODE(cconcep, 51, iconcep, 0))
                      + SUM(DECODE(cconcep, 52, iconcep, 0))
                      + SUM(DECODE(cconcep, 53, iconcep, 0))
                      + SUM(DECODE(cconcep, 54, iconcep, 0))
                      + SUM(DECODE(cconcep, 55, iconcep, 0))
                      + SUM(DECODE(cconcep, 56, iconcep, 0))
                      + SUM(DECODE(cconcep, 57, iconcep, 0))
                      + f_round(SUM(DECODE(cconcep, 58, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 64, iconcep, 0)), pmoneda)
                      - SUM(DECODE(cconcep, 63, iconcep, 0))) it2totr,
                     (f_round(SUM(DECODE(cconcep, 58, iconcep, 0)), pmoneda)
                      + f_round(SUM(DECODE(cconcep, 64, iconcep, 0)), pmoneda)) it2rec,
                     0, 0, 0, 0, 0, 0,(SUM(DECODE(cconcep, 17, iconcep, 0))) icombrui,   -- CALCULO DE IMPORTES DE COMISIONES INDIRECTAS
                     (SUM(DECODE(cconcep, 18, iconcep, 0))) icomreti,
                     (SUM(DECODE(cconcep, 19, iconcep, 0))) icomdevi,
                     (SUM(DECODE(cconcep, 20, iconcep, 0))) icomdrti,
                     (SUM(DECODE(cconcep, 22, iconcep, 0))) icombruc,   -- CALCULO DE IMPORTES DE COM. AGTE. COBRADOR
                     (SUM(DECODE(cconcep, 23, iconcep, 0))) icomretc,
                     (SUM(DECODE(cconcep, 24, iconcep, 0))) icomdevc,
                     (SUM(DECODE(cconcep, 25, iconcep, 0))) icomdrtc,
                     SUM(DECODE(cconcep, 30, iconcep, 0)) icomcia,   --  Se añade el campo que almacena la comision de la cia.
                     SUM(DECODE(cconcep, 32, iconcep, 0)) iimp_1,
                     SUM(DECODE(cconcep, 40, iconcep, 0)) iimp_2,
                     SUM(DECODE(cconcep, 41, iconcep, 0)) iimp_3,
                     SUM(DECODE(cconcep, 42, iconcep, 0)) iimp_4,
                     SUM(DECODE(cconcep, 43, iconcep, 0)) iconvoleoducto   -- BUG 25988 - FAL - 13/02/2013
                FROM detreciboscar
               WHERE sproces = psproces
                 AND nrecibo = pnrecibo
            GROUP BY sproces, nrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103470;   -- REBUT NO TROBAT A DETRECIBOSCAR
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 103472;   -- REGISTRE DUPLICAT A VDETRECIBOSCAR
         WHEN OTHERS THEN
            RETURN 103474;   -- ERROR A L' INSERIR A VDETRECIBOSCAR
      End;
      Else
      BEGIN
         -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
         INSERT INTO vdetreciboscar
                     (sproces, nrecibo, iprinet, irecext, iconsor, ireccon, iips, idgs,
                      iarbitr, ifng, irecfra, idtotec, idtocom, icombru, icomret, ipridev,
                      idtoom, iderreg, icomdev, iretdev, iocorec,   -- Se añade el campo que almacena otros conceptos recargo.
                                                                 it1pri, it1dto, it1con,
                      it1imp, it1totr, it1rec, icednet, icedrex, icedcon, icedrco, icedips,
                      iceddgs, icedarb, icedfng, icedrfr, iceddte, iceddco, icedcbr, icedcrt,
                      icedpdv, iceddom, icedreg, icedcdv, icedrdv, it2pri, it2dto, it2con,
                      it2imp, it2totr, it2rec, itotpri, itotdto, itotcon, itotimp, itotrec,
                      itotalr, icombrui, icomreti, icomdevi, icomdrti, icombruc, icomretc,
                      icomdevc, icomdrtc, icomcia,   -- Se añade el campo que almacena la comision de la cia.
                                                  iimp_1, iimp_2, iimp_3, iimp_4,
                      iconvoleoducto)
            SELECT   sproces, nrecibo, SUM(DECODE(cconcep, 0, iconcep, 0)) iprinet,   -- IMPORTES PARTE LOCAL
                     SUM(DECODE(cconcep, 1, iconcep, 0)) irecext,
                     SUM(DECODE(cconcep, 2, iconcep, 0)) iconsor,
                     SUM(DECODE(cconcep, 3, iconcep, 0)) ireccon,
                     SUM(DECODE(cconcep, 4, iconcep, 0)) iips,
                     SUM(DECODE(cconcep, 5, iconcep, 0)) idgs,
                     SUM(DECODE(cconcep, 6, iconcep, 0)) iarbitr,
                     SUM(DECODE(cconcep, 7, iconcep, 0)) ifng,
                     SUM(DECODE(cconcep, 8, iconcep, 0)) irecfra,
                     SUM(DECODE(cconcep, 9, iconcep, 0)) idtotec,
                     SUM(DECODE(cconcep, 10, iconcep, 0)) idtocom,
                     SUM(DECODE(cconcep, 11, iconcep, 0)) icombru,
                     SUM(DECODE(cconcep, 12, iconcep, 0)) icomret,
                     SUM(DECODE(cconcep, 21, iconcep, 0)) ipridev,
                     SUM(DECODE(cconcep, 13, iconcep, 0)) idtoom,
                     SUM(DECODE(cconcep, 14, iconcep, 0)) iderreg,
                     SUM(DECODE(cconcep, 15, iconcep, 0)) icomdev,
                     SUM(DECODE(cconcep, 16, iconcep, 0)) iretdev,
                     SUM(DECODE(cconcep, 26, iconcep, 0)) iocorec,
                     (SUM(DECODE(cconcep, 0, iconcep, 0)) +   -- CALCULO DE TOTALES LOCALES
                                                           SUM(DECODE(cconcep, 1, iconcep, 0)))
                                                                                       it1pri,
                     SUM(DECODE(cconcep, 13, iconcep, 0)) it1dto,
                     (SUM(DECODE(cconcep, 2, iconcep, 0)) + SUM(DECODE(cconcep, 3, iconcep, 0)))
                                                                                       it1con,
                     (SUM(DECODE(cconcep, 4, iconcep, 0)) + SUM(DECODE(cconcep, 5, iconcep, 0))
                      + SUM(DECODE(cconcep, 6, iconcep, 0))
                      + SUM(DECODE(cconcep, 7, iconcep, 0))
                      + SUM(DECODE(cconcep, 86, iconcep, 0))   -- 6. 0026562
                                                            ) it1imp,
                     (SUM(DECODE(cconcep, 0, iconcep, 0))
                      + SUM(DECODE(cconcep, 2, iconcep, 0))
                      + SUM(DECODE(cconcep, 3, iconcep, 0))
                      + SUM(DECODE(cconcep, 4, iconcep, 0))
                      + SUM(DECODE(cconcep, 5, iconcep, 0))
                      + SUM(DECODE(cconcep, 6, iconcep, 0))
                      + SUM(DECODE(cconcep, 7, iconcep, 0))
                      + SUM(DECODE(cconcep, 8, iconcep, 0))
                      + SUM(DECODE(cconcep, 14, iconcep, 0))
                      - SUM(DECODE(cconcep, 13, iconcep, 0))
                      + SUM(DECODE(cconcep, 86, iconcep, 0))) it1totr,
                     (SUM(DECODE(cconcep, 8, iconcep, 0))
                      + SUM(DECODE(cconcep, 14, iconcep, 0))) it1rec,   -- BUG 27346-147180 - 20/06/2013 - AMC
                     SUM(DECODE(cconcep, 50, iconcep, 0)) icednet,   -- IMPORTES PARTE CEDIDA
                     SUM(DECODE(cconcep, 51, iconcep, 0)) icedrex,
                     SUM(DECODE(cconcep, 52, iconcep, 0)) icedcon,
                     SUM(DECODE(cconcep, 53, iconcep, 0)) icedrco,
                     SUM(DECODE(cconcep, 54, iconcep, 0)) icedips,
                     SUM(DECODE(cconcep, 55, iconcep, 0)) iceddgs,
                     SUM(DECODE(cconcep, 56, iconcep, 0)) icedarb,
                     SUM(DECODE(cconcep, 57, iconcep, 0)) icedfng,
                     SUM(DECODE(cconcep, 58, iconcep, 0)) icedrfr,
                     SUM(DECODE(cconcep, 59, iconcep, 0)) iceddte,
                     SUM(DECODE(cconcep, 60, iconcep, 0)) iceddco,
                     SUM(DECODE(cconcep, 61, iconcep, 0)) icedcbr,
                     SUM(DECODE(cconcep, 62, iconcep, 0)) icedcrt,
                     SUM(DECODE(cconcep, 71, iconcep, 0)) icedpdv,
                     SUM(DECODE(cconcep, 63, iconcep, 0)) iceddom,
                     SUM(DECODE(cconcep, 64, iconcep, 0)) icedreg,
                     SUM(DECODE(cconcep, 65, iconcep, 0)) icedcdv,
                     SUM(DECODE(cconcep, 66, iconcep, 0)) icedrdv,
                     (SUM(DECODE(cconcep, 50, iconcep, 0))
                      +   -- CALCULO DE TOTALES PARTE CEDIDA
                       SUM(DECODE(cconcep, 51, iconcep, 0))) it2pri,
                     SUM(DECODE(cconcep, 63, iconcep, 0)) it2dto,
                     (SUM(DECODE(cconcep, 52, iconcep, 0))
                      + SUM(DECODE(cconcep, 53, iconcep, 0))) it2con,
                     (SUM(DECODE(cconcep, 54, iconcep, 0))
                      + SUM(DECODE(cconcep, 55, iconcep, 0))
                      + SUM(DECODE(cconcep, 56, iconcep, 0))
                      + SUM(DECODE(cconcep, 57, iconcep, 0))) it2imp,
                     (SUM(DECODE(cconcep, 50, iconcep, 0))
                      + SUM(DECODE(cconcep, 51, iconcep, 0))
                      + SUM(DECODE(cconcep, 52, iconcep, 0))
                      + SUM(DECODE(cconcep, 53, iconcep, 0))
                      + SUM(DECODE(cconcep, 54, iconcep, 0))
                      + SUM(DECODE(cconcep, 55, iconcep, 0))
                      + SUM(DECODE(cconcep, 56, iconcep, 0))
                      + SUM(DECODE(cconcep, 57, iconcep, 0))
                      + SUM(DECODE(cconcep, 58, iconcep, 0))
                      + SUM(DECODE(cconcep, 64, iconcep, 0))
                      - SUM(DECODE(cconcep, 63, iconcep, 0))) it2totr,
                     (SUM(DECODE(cconcep, 58, iconcep, 0))
                      + SUM(DECODE(cconcep, 64, iconcep, 0))) it2rec,
                     0, 0, 0, 0, 0, 0,(SUM(DECODE(cconcep, 17, iconcep, 0))) icombrui,   -- CALCULO DE IMPORTES DE COMISIONES INDIRECTAS
                     (SUM(DECODE(cconcep, 18, iconcep, 0))) icomreti,
                     (SUM(DECODE(cconcep, 19, iconcep, 0))) icomdevi,
                     (SUM(DECODE(cconcep, 20, iconcep, 0))) icomdrti,
                     (SUM(DECODE(cconcep, 22, iconcep, 0))) icombruc,   -- CALCULO DE IMPORTES DE COM. AGTE. COBRADOR
                     (SUM(DECODE(cconcep, 23, iconcep, 0))) icomretc,
                     (SUM(DECODE(cconcep, 24, iconcep, 0))) icomdevc,
                     (SUM(DECODE(cconcep, 25, iconcep, 0))) icomdrtc,
                     SUM(DECODE(cconcep, 30, iconcep, 0)) icomcia,   --  Se añade el campo que almacena la comision de la cia.
                     SUM(DECODE(cconcep, 32, iconcep, 0)) iimp_1,
                     SUM(DECODE(cconcep, 40, iconcep, 0)) iimp_2,
                     SUM(DECODE(cconcep, 41, iconcep, 0)) iimp_3,
                     SUM(DECODE(cconcep, 42, iconcep, 0)) iimp_4,
                     SUM(DECODE(cconcep, 43, iconcep, 0)) iconvoleoducto   -- BUG 25988 - FAL - 13/02/2013
                FROM detreciboscar
               WHERE sproces = psproces
                 AND nrecibo = pnrecibo
            GROUP BY sproces, nrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103470;   -- REBUT NO TROBAT A DETRECIBOSCAR
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 103472;   -- REGISTRE DUPLICAT A VDETRECIBOSCAR
         WHEN OTHERS THEN
            Return 103474;   -- ERROR A L' INSERIR A VDETRECIBOSCAR
      END;
      End If;


      IF xctipcoa = 1 THEN
         -- RECIBO ÚNICO
         UPDATE vdetreciboscar   -- TOTAL SERA PARTE LOCAL + PARTE CEDIDA
            SET itotpri = it1pri + it2pri,
                itotdto = it1dto + it2dto,
                itotcon = it1con + it2con,
                itotimp = it1imp + it2imp,
                itotalr = it1totr + it2totr + iocorec,
                itotrec = it1rec + it2rec
          WHERE sproces = psproces
            AND nrecibo = pnrecibo;
      ELSE
         --  XCTIPCOA IS NULL O NO ES UN RECIBO UNICO
         UPDATE vdetreciboscar   -- TOTAL SERA PARTE LOCAL
            SET itotpri = it1pri,
                itotdto = it1dto,
                itotcon = it1con,
                itotimp = it1imp,
                itotalr = it1totr + iocorec,
                itotrec = it1rec
          WHERE sproces = psproces
            AND nrecibo = pnrecibo;
      END IF;

      -- BUG 18423 - 30/11/2011 - JMP - LCOL000 - Multimoneda
      IF NVL(pac_parametros.f_parempresa_n(xcempres, 'MULTIMONEDA'), 0) = 1 THEN
         error := pac_oper_monedas.f_contravalores_recibo(pnrecibo, pmodo, psproces);

         IF error <> 0 THEN
            RETURN error;
         END IF;

         error := pac_oper_monedas.f_vdetrecibos_monpol(pnrecibo, pmodo, psproces);

         IF error <> 0 THEN
            RETURN error;
         END IF;
      END IF;

      -- FIN BUG 18423 - 30/11/2011 - JMP - LCOL000 - Multimoneda

      -- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Inicio
      -- Si el recibo tiene coaseguro llamamos a F_INSCTACOAS
      /* KBR: Bug 30041 07/02/2014
      --No se debe hacer insert en CTACOASEGURO para un PREVIO
      IF NVL(xctipcoa, 0) > 0 THEN
         BEGIN
            SELECT smovrec
              INTO xsmovrec
              FROM movrecibo
             WHERE nrecibo = pnrecibo
               AND fmovfin IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_vdetrecibos  num_recibo = ' || pnrecibo,
                           NULL, 'WHEN OTHERS RETURN 104043', SQLERRM);
               RETURN 104043;
         END;

         IF xfemisio < xfefecto THEN
            xfmovim := xfefecto;
         ELSE
            xfmovim := xfemisio;
         END IF;

         error := f_insctacoas(pnrecibo, 0, xcempres, xsmovrec, xfmovim);

         IF error <> 0 THEN
            RETURN error;
         END IF;
      END IF;   -- Del IF que mira si tiene coaseguro
      */

      -- 7.0 - 22/11/2013 - MMM - 0028986: LCOL_A004-Qtracker: 10043, 10046, 10051 - Fin
      RETURN 0;
   ELSE
      RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
   END IF;
END f_vdetrecibos;

/
