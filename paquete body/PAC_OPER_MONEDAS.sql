CREATE OR REPLACE PACKAGE BODY pac_oper_monedas IS
/******************************************************************************
   NOMBRE:    PAC_OPER_MONEDAS
   PROPÓSITO: Funciones para realizar operaciones con monedas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/10/2011   JMP                1. 0018423: LCOL000 - Multimoneda - Creación del package
   2.0        17/04/2012   JMF                2. 0021897 LCOL_S001-SIN - Ajuste cambio moneda tras cierres (UAT 4208)
   3.0        02/08/2012   APD                3. 0023074: LCOL_T010-Tratamiento Gastos de Expedición
   4.0        25/04/2013   ECP                4. 0026771: LCOL_C001-QT 7114: Iaxis error al generar el listado de producci?n
   5.0        07/06/2013   AMF                5. La Fecha de Cambio, en la moneda de la instalación, siempre tiene que ser la fecha de generación del recibos
   6.0        04/02/2014   FAL                6. 0025537: RSA000 - Gestión de incidencias
   7.0        19/06/2015   VCG                7. AMA-209-Redondeo SRI
******************************************************************************/

   /*************************************************************************
    F_VDETRECIBOS_MONPOL
      Funcion que calcula los totales del recibo en la tabla VDETRECIBOS_MONPOL
      a partir de DETRECIBOS.ICONCEP_MONPOL.

      param in pnrecibo : número de recibo
      param in pmodo    : modo
      param in psproces : número de proceso
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_vdetrecibos_monpol(
      pnrecibo IN NUMBER,
      pmodo VARCHAR2,
      psproces NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      V_Ctipcoa      Recibos.Ctipcoa%Type;
      Pmoneda        Number;--AMA-209
      V_Cempres      Recibos.Cempres%Type;--AMA-209
      V_Sseguro      Recibos.Sseguro%Type;--AMA-209
      aux number;
   BEGIN
      IF pmodo IN('R', 'A', 'ANP', 'I', 'RRIE') THEN
         Begin
            Select Ctipcoa, Sseguro, Cempres
              INTO v_ctipcoa, v_sseguro, v_cempres
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 101902;   -- RECIBO NO ENCONTRADO EN RECIBOS
            WHEN OTHERS THEN
               RETURN 102367;   -- ERROR AL LEER DE LA TABLA RECIBOS
         End;

          --AMA-209-24/06/2016-VCG-REDONDEO SRI
         If Nvl(Pac_Parametros.F_Parempresa_N(V_Cempres, 'REDONDEO_SRI'), 0) > 0 Then
           Pmoneda:= Pac_Oper_Monedas.F_Monpol(V_Sseguro);
         BEGIN
            -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
            INSERT INTO vdetrecibos_monpol
                        (nrecibo, iprinet, irecext, iconsor, ireccon, iips, idgs, iarbitr,
                         ifng, irecfra, idtotec, idtocom, icombru, icomret, ipridev, idtoom,
                         iderreg, icomdev, iretdev, iocorec,   -- Se añade el campo que almacena otros conceptos recargo.
                                                            it1pri, it1dto, it1con, it1imp,
                         it1totr, it1rec, icednet, icedrex, icedcon, icedrco, icedips,
                         iceddgs, icedarb, icedfng, icedrfr, iceddte, iceddco, icedcbr,
                         icedcrt, icedpdv, iceddom, icedreg, icedcdv, icedrdv, it2pri, it2dto,
                         it2con, it2imp, it2totr, it2rec, itotpri, itotdto, itotcon, itotimp,
                         itotrec, itotalr, icombrui, icomreti, icomdevi, icomdrti, icombruc,
                         icomretc, icomdevc, icomdrtc, icomcia,   -- Se añade el campo que almacena la comision de la cia.
                                                               iimp_1, iimp_2, iimp_3, iimp_4
                                                                                             -- Ini 26771 --ECP-- 25/04/2013
                         ,
                         iconvoleoducto -- CONF-905
                         , iimp_5, iimp_6, iimp_7, iimp_8, -- CONF-905
                                       -- Fin 26771 --ECP-- 25/04/2013
                         iimp_9, iimp_10, iimp_11)
               SELECT   nrecibo, SUM(DECODE(cconcep, 0, iconcep_monpol, 0)) iprinet,   -- IMPORTES PARTE LOCAL
                        SUM(DECODE(cconcep, 1, iconcep_monpol, 0)) irecext,
                        SUM(DECODE(cconcep, 2, iconcep_monpol, 0)) iconsor,
                        Sum(Decode(Cconcep, 3, Iconcep_Monpol, 0)) Ireccon,
                        f_round(SUM(DECODE(cconcep, 4, iconcep_monpol, 0)), pmoneda) iips,
                        f_round(SUM(DECODE(cconcep, 5, iconcep_monpol, 0)), pmoneda) idgs,
                        f_round(SUM(DECODE(cconcep, 6, iconcep_monpol, 0)), pmoneda) iarbitr,
                        SUM(DECODE(cconcep, 7, iconcep_monpol, 0)) ifng,
                        f_round(SUM(DECODE(cconcep, 8, iconcep_monpol, 0)), pmoneda) irecfra,
                        SUM(DECODE(cconcep, 9, iconcep_monpol, 0)) idtotec,
                        SUM(DECODE(cconcep, 10, iconcep_monpol, 0)) idtocom,
                        SUM(DECODE(cconcep, 11, iconcep_monpol, 0)) icombru,
                        SUM(DECODE(cconcep, 12, iconcep_monpol, 0)) icomret,
                        SUM(DECODE(cconcep, 21, iconcep_monpol, 0)) ipridev,
                        SUM(DECODE(cconcep, 13, iconcep_monpol, 0)) idtoom,
                        f_round(SUM(DECODE(cconcep, 14, iconcep_monpol, 0)), pmoneda) iderreg,
                        SUM(DECODE(cconcep, 15, iconcep_monpol, 0)) icomdev,
                        SUM(DECODE(cconcep, 16, iconcep_monpol, 0)) iretdev,
                        SUM(DECODE(cconcep, 26, iconcep_monpol, 0)) iocorec,

--
                        (SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
                         +   -- CALCULO DE TOTALES LOCALES
                          SUM(DECODE(cconcep, 1, iconcep_monpol, 0))) it1pri,

--
                        SUM(DECODE(cconcep, 13, iconcep_monpol, 0)) it1dto,

--
                        (SUM(DECODE(cconcep, 2, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 3, iconcep_monpol, 0))) it1con,

--
                        (f_round(SUM(DECODE(cconcep, 4, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 5, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 6, iconcep_monpol, 0)), pmoneda)
                         + SUM(DECODE(cconcep, 7, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 86, iconcep_monpol, 0)), pmoneda)) it1imp,

--
                        (SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 1, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 2, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 3, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 4, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 5, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 6, iconcep_monpol, 0)), pmoneda)
                         + SUM(DECODE(cconcep, 7, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 8, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 14, iconcep_monpol, 0)), pmoneda)
                         - SUM(DECODE(cconcep, 13, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 86, iconcep_monpol, 0)), pmoneda)) it1totr,

--
                        (f_round(SUM(DECODE(cconcep, 8, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 14, iconcep_monpol, 0)), pmoneda)) it1rec,   -- BUG 27346-147180 - 20/06/2013 - AMC

--
                        SUM(DECODE(cconcep, 50, iconcep_monpol, 0)) icednet,   -- IMPORTES PARTE CEDIDA
                        SUM(DECODE(cconcep, 51, iconcep_monpol, 0)) icedrex,
                        SUM(DECODE(cconcep, 52, iconcep_monpol, 0)) icedcon,
                        SUM(DECODE(cconcep, 53, iconcep_monpol, 0)) icedrco,
                        f_round(SUM(DECODE(cconcep, 54, iconcep_monpol, 0)), pmoneda) icedips,
                        f_round(SUM(DECODE(cconcep, 55, iconcep_monpol, 0)), pmoneda) iceddgs,
                        f_round(SUM(DECODE(cconcep, 56, iconcep_monpol, 0)), pmoneda) icedarb,
                        SUM(DECODE(cconcep, 57, iconcep_monpol, 0)) icedfng,
                        f_round(SUM(DECODE(cconcep, 58, iconcep_monpol, 0)), pmoneda) icedrfr,
                        SUM(DECODE(cconcep, 59, iconcep_monpol, 0)) iceddte,
                        SUM(DECODE(cconcep, 60, iconcep_monpol, 0)) iceddco,
                        SUM(DECODE(cconcep, 61, iconcep_monpol, 0)) icedcbr,
                        SUM(DECODE(cconcep, 62, iconcep_monpol, 0)) icedcrt,
                        SUM(DECODE(cconcep, 71, iconcep_monpol, 0)) icedpdv,
                        SUM(DECODE(cconcep, 63, iconcep_monpol, 0)) iceddom,
                        f_round(SUM(DECODE(cconcep, 64, iconcep_monpol, 0)), pmoneda) icedreg,
                        SUM(DECODE(cconcep, 65, iconcep_monpol, 0)) icedcdv,
                        SUM(DECODE(cconcep, 66, iconcep_monpol, 0)) icedrdv,

--
                        (SUM(DECODE(cconcep, 50, iconcep_monpol, 0))
                         +   -- CALCULO DE TOTALES PARTE CEDIDA
                          SUM(DECODE(cconcep, 51, iconcep_monpol, 0))) it2pri,

--
                        SUM(DECODE(cconcep, 63, iconcep_monpol, 0)) it2dto,

--
                        (SUM(DECODE(cconcep, 52, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 53, iconcep_monpol, 0))) it2con,

--
                        (f_round(SUM(DECODE(cconcep, 54, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 55, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 56, iconcep_monpol, 0)), pmoneda)
                         + SUM(DECODE(cconcep, 57, iconcep_monpol, 0))) it2imp,

--
                        (SUM(DECODE(cconcep, 50, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 51, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 52, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 53, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 54, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 55, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 56, iconcep_monpol, 0)), pmoneda)
                         + SUM(DECODE(cconcep, 57, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 58, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 64, iconcep_monpol, 0)), pmoneda)
                         - SUM(DECODE(cconcep, 63, iconcep_monpol, 0))) it2totr,

--
                        (f_round(SUM(DECODE(cconcep, 58, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 64, iconcep_monpol, 0)), pmoneda)) it2rec,

--
                        0, 0, 0, 0, 0, 0,
                        (SUM(DECODE(cconcep, 17, iconcep_monpol, 0))) icombrui,   -- CALCULO DE IMPORTES DE COMISIONES INDIRECTAS
                        (SUM(DECODE(cconcep, 18, iconcep_monpol, 0))) icomreti,
                        (SUM(DECODE(cconcep, 19, iconcep_monpol, 0))) icomdevi,
                        (SUM(DECODE(cconcep, 20, iconcep_monpol, 0))) icomdrti,
                        (SUM(DECODE(cconcep, 22, iconcep_monpol, 0))) icombruc,   -- CALCULO DE IMPORTES DE COM. AGTE. COBRADOR
                        (SUM(DECODE(cconcep, 23, iconcep_monpol, 0))) icomretc,
                        (SUM(DECODE(cconcep, 24, iconcep_monpol, 0))) icomdevc,
                        (SUM(DECODE(cconcep, 25, iconcep_monpol, 0))) icomdrtc,
                        SUM(DECODE(cconcep, 30, iconcep_monpol, 0)) icomcia,   -- Se añade el campo que almacena la comision de la cia.
                        SUM(DECODE(cconcep, 32, iconcep_monpol, 0)) iimp_1,
                        SUM(DECODE(cconcep, 40, iconcep_monpol, 0)) iimp_2,
                        SUM(DECODE(cconcep, 41, iconcep_monpol, 0)) iimp_3,
                        SUM(DECODE(cconcep, 42, iconcep_monpol, 0)) iimp_4
                                                                          -- Ini 26771 --ECP-- 25/04/2013
                        ,
                        SUM(DECODE(cconcep, 43, iconcep_monpol, 0)) iconvoleoducto, -- Fin 26771 --ECP-- 25/04/2013
                        -- BUG CONF-905 inicio
                        SUM(DECODE(cconcep, 82, iconcep_monpol, 0)) iimp_5,
                        sum(decode(cconcep, 83, iconcep_monpol, 0)) iimp_6,
                        SUM(decode(cconcep, 85, iconcep_monpol, 0)) iimp_7,
                        SUM(DECODE(cconcep, 84, iconcep_monpol, 0)) iimp_8,
                        -- BUG CONF-905 Fin
                        sum(decode(cconcep, 33, iconcep_monpol, 0)) iimp_9,  -- BUG 1970 AP Retención en la fuente sobre comisión
                        SUM(decode(cconcep, 34, iconcep_monpol, 0)) iimp_10, -- BUG 1970 AP Retención por IVA sobre comisión
                        SUM(DECODE(cconcep, 35, iconcep_monpol, 0)) iimp_11  -- BUG 1970 AP Retención por ICA sobre comisión
               FROM     detrecibos
                  WHERE nrecibo = pnrecibo
               Group By Nrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 103469;   -- REBUT NO TROBAT A DETRECIBOS
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 9902738;   -- REGISTRE DUPLICAT A VDETRECIBOS_MONPOL
            WHEN OTHERS THEN
               RETURN 9902739;   -- ERROR A L' INSERIR A VDETRECIBOS_MONPOL
         End;

         Else
                  BEGIN
            -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
            INSERT INTO vdetrecibos_monpol
                        (nrecibo, iprinet, irecext, iconsor, ireccon, iips, idgs, iarbitr,
                         ifng, irecfra, idtotec, idtocom, icombru, icomret, ipridev, idtoom,
                         iderreg, icomdev, iretdev, iocorec,   -- Se añade el campo que almacena otros conceptos recargo.
                                                            it1pri, it1dto, it1con, it1imp,
                         it1totr, it1rec, icednet, icedrex, icedcon, icedrco, icedips,
                         iceddgs, icedarb, icedfng, icedrfr, iceddte, iceddco, icedcbr,
                         icedcrt, icedpdv, iceddom, icedreg, icedcdv, icedrdv, it2pri, it2dto,
                         it2con, it2imp, it2totr, it2rec, itotpri, itotdto, itotcon, itotimp,
                         itotrec, itotalr, icombrui, icomreti, icomdevi, icomdrti, icombruc,
                         icomretc, icomdevc, icomdrtc, icomcia,   -- Se añade el campo que almacena la comision de la cia.
                                                               iimp_1, iimp_2, iimp_3, iimp_4
                                                                                             -- Ini 26771 --ECP-- 25/04/2013
                         ,
                         iconvoleoducto
                                       -- Fin 26771 --ECP-- 25/04/2013
                         , iimp_5, iimp_6, iimp_7, iimp_8, -- CONF-905
                         iimp_9, iimp_10, iimp_11)
               SELECT   nrecibo, SUM(DECODE(cconcep, 0, iconcep_monpol, 0)) iprinet,   -- IMPORTES PARTE LOCAL
                        SUM(DECODE(cconcep, 1, iconcep_monpol, 0)) irecext,
                        SUM(DECODE(cconcep, 2, iconcep_monpol, 0)) iconsor,
                        SUM(DECODE(cconcep, 3, iconcep_monpol, 0)) ireccon,
                        SUM(DECODE(cconcep, 4, iconcep_monpol, 0)) iips,
                        SUM(DECODE(cconcep, 5, iconcep_monpol, 0)) idgs,
                        SUM(DECODE(cconcep, 6, iconcep_monpol, 0)) iarbitr,
                        SUM(DECODE(cconcep, 7, iconcep_monpol, 0)) ifng,
                        SUM(DECODE(cconcep, 8, iconcep_monpol, 0)) irecfra,
                        SUM(DECODE(cconcep, 9, iconcep_monpol, 0)) idtotec,
                        SUM(DECODE(cconcep, 10, iconcep_monpol, 0)) idtocom,
                        SUM(DECODE(cconcep, 11, iconcep_monpol, 0)) icombru,
                        SUM(DECODE(cconcep, 12, iconcep_monpol, 0)) icomret,
                        SUM(DECODE(cconcep, 21, iconcep_monpol, 0)) ipridev,
                        SUM(DECODE(cconcep, 13, iconcep_monpol, 0)) idtoom,
                        SUM(DECODE(cconcep, 14, iconcep_monpol, 0)) iderreg,
                        SUM(DECODE(cconcep, 15, iconcep_monpol, 0)) icomdev,
                        SUM(DECODE(cconcep, 16, iconcep_monpol, 0)) iretdev,
                        SUM(DECODE(cconcep, 26, iconcep_monpol, 0)) iocorec,

--
                        (SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
                         +   -- CALCULO DE TOTALES LOCALES
                          SUM(DECODE(cconcep, 1, iconcep_monpol, 0))) it1pri,

--
                        SUM(DECODE(cconcep, 13, iconcep_monpol, 0)) it1dto,

--
                        (SUM(DECODE(cconcep, 2, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 3, iconcep_monpol, 0))) it1con,

--
                        (SUM(DECODE(cconcep, 4, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 5, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 6, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 7, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 86, iconcep_monpol, 0))) it1imp, -- IAXIS-4153 - JLTS - 19/06/2019. Se adiciona el concepto 86

--
                        (SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 1, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 2, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 3, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 4, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 5, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 6, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 7, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 8, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 14, iconcep_monpol, 0))
                         - SUM(DECODE(cconcep, 13, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 86, iconcep_monpol, 0))) it1totr,

--
                        (SUM(DECODE(cconcep, 8, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 14, iconcep_monpol, 0))) it1rec,   -- BUG 27346-147180 - 20/06/2013 - AMC

--
                        SUM(DECODE(cconcep, 50, iconcep_monpol, 0)) icednet,   -- IMPORTES PARTE CEDIDA
                        SUM(DECODE(cconcep, 51, iconcep_monpol, 0)) icedrex,
                        SUM(DECODE(cconcep, 52, iconcep_monpol, 0)) icedcon,
                        SUM(DECODE(cconcep, 53, iconcep_monpol, 0)) icedrco,
                        SUM(DECODE(cconcep, 54, iconcep_monpol, 0)) icedips,
                        SUM(DECODE(cconcep, 55, iconcep_monpol, 0)) iceddgs,
                        SUM(DECODE(cconcep, 56, iconcep_monpol, 0)) icedarb,
                        SUM(DECODE(cconcep, 57, iconcep_monpol, 0)) icedfng,
                        SUM(DECODE(cconcep, 58, iconcep_monpol, 0)) icedrfr,
                        SUM(DECODE(cconcep, 59, iconcep_monpol, 0)) iceddte,
                        SUM(DECODE(cconcep, 60, iconcep_monpol, 0)) iceddco,
                        SUM(DECODE(cconcep, 61, iconcep_monpol, 0)) icedcbr,
                        SUM(DECODE(cconcep, 62, iconcep_monpol, 0)) icedcrt,
                        SUM(DECODE(cconcep, 71, iconcep_monpol, 0)) icedpdv,
                        SUM(DECODE(cconcep, 63, iconcep_monpol, 0)) iceddom,
                        SUM(DECODE(cconcep, 64, iconcep_monpol, 0)) icedreg,
                        SUM(DECODE(cconcep, 65, iconcep_monpol, 0)) icedcdv,
                        SUM(DECODE(cconcep, 66, iconcep_monpol, 0)) icedrdv,

--
                        (SUM(DECODE(cconcep, 50, iconcep_monpol, 0))
                         +   -- CALCULO DE TOTALES PARTE CEDIDA
                          SUM(DECODE(cconcep, 51, iconcep_monpol, 0))) it2pri,

--
                        SUM(DECODE(cconcep, 63, iconcep_monpol, 0)) it2dto,

--
                        (SUM(DECODE(cconcep, 52, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 53, iconcep_monpol, 0))) it2con,

--
                        (SUM(DECODE(cconcep, 54, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 55, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 56, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 57, iconcep_monpol, 0))) it2imp,

--
                        (SUM(DECODE(cconcep, 50, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 51, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 52, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 53, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 54, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 55, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 56, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 57, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 58, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 64, iconcep_monpol, 0))
                         - SUM(DECODE(cconcep, 63, iconcep_monpol, 0))) it2totr,

--
                        (SUM(DECODE(cconcep, 58, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 64, iconcep_monpol, 0))) it2rec,

--
                        0, 0, 0, 0, 0, 0,
                        (SUM(DECODE(cconcep, 17, iconcep_monpol, 0))) icombrui,   -- CALCULO DE IMPORTES DE COMISIONES INDIRECTAS
                        (SUM(DECODE(cconcep, 18, iconcep_monpol, 0))) icomreti,
                        (SUM(DECODE(cconcep, 19, iconcep_monpol, 0))) icomdevi,
                        (SUM(DECODE(cconcep, 20, iconcep_monpol, 0))) icomdrti,
                        (SUM(DECODE(cconcep, 22, iconcep_monpol, 0))) icombruc,   -- CALCULO DE IMPORTES DE COM. AGTE. COBRADOR
                        (SUM(DECODE(cconcep, 23, iconcep_monpol, 0))) icomretc,
                        (SUM(DECODE(cconcep, 24, iconcep_monpol, 0))) icomdevc,
                        (SUM(DECODE(cconcep, 25, iconcep_monpol, 0))) icomdrtc,
                        SUM(DECODE(cconcep, 30, iconcep_monpol, 0)) icomcia,   -- Se añade el campo que almacena la comision de la cia.
                        SUM(DECODE(cconcep, 32, iconcep_monpol, 0)) iimp_1,
                        SUM(DECODE(cconcep, 40, iconcep_monpol, 0)) iimp_2,
                        SUM(DECODE(cconcep, 41, iconcep_monpol, 0)) iimp_3,
                        SUM(DECODE(cconcep, 42, iconcep_monpol, 0)) iimp_4
                                                                          -- Ini 26771 --ECP-- 25/04/2013
                        ,
                        SUM(DECODE(cconcep, 43, iconcep_monpol, 0)) iconvoleoducto,
                        -- Fin 26771 --ECP-- 25/04/2013
                        -- BUG CONF-905 inicio
                        SUM(DECODE(cconcep, 82, iconcep_monpol, 0)) iimp_5,
                        SUM(DECODE(cconcep, 83, iconcep_monpol, 0)) iimp_6,
                        SUM(decode(cconcep, 85, iconcep_monpol, 0)) iimp_7,
                        SUM(DECODE(cconcep, 84, iconcep_monpol, 0)) iimp_8,
                        -- BUG CONF-905 Fin
                        SUM(decode(cconcep, 33, iconcep_monpol, 0)) iimp_9,  -- BUG 1970 AP Retención en la fuente sobre comisión
                        SUM(decode(cconcep, 34, iconcep_monpol, 0)) iimp_10, -- BUG 1970 AP Retención por IVA sobre comisión
                        SUM(DECODE(cconcep, 35, iconcep_monpol, 0)) iimp_11  -- BUG 1970 AP Retención por ICA sobre comisión
               FROM     detrecibos
                  WHERE nrecibo = pnrecibo
               GROUP BY nrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 103469;   -- REBUT NO TROBAT A DETRECIBOS
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 9902738;   -- REGISTRE DUPLICAT A VDETRECIBOS_MONPOL
            WHEN OTHERS THEN
               RETURN 9902739;   -- ERROR A L' INSERIR A VDETRECIBOS_MONPOL
         End;
         End If;

         IF v_ctipcoa = 1 THEN
            -- RECIBO ÚNICO
            UPDATE vdetrecibos_monpol   -- TOTAL SERA PARTE LOCAL + PARTE CEDIDA
               SET itotpri = it1pri + it2pri,
                   itotdto = it1dto + it2dto,
                   itotcon = it1con + it2con,
                   itotimp = it1imp + it2imp,
                   itotalr = it1totr + it2totr + iocorec,
                   itotrec = it1rec + it2rec
             WHERE nrecibo = pnrecibo;
         ELSE
            --  XCTIPCOA IS NULL O NO ES UN RECIBO UNICO
            UPDATE vdetrecibos_monpol   -- TOTAL SERA PARTE LOCAL
               SET itotpri = it1pri,
                   itotdto = it1dto,
                   itotcon = it1con,
                   itotimp = it1imp,
                   itotalr = it1totr + iocorec,
                   itotrec = it1rec
             WHERE nrecibo = pnrecibo;
         END IF;

         RETURN 0;
      ELSIF pmodo = 'P'
            OR pmodo = 'N'
            OR pmodo = 'PRIE' THEN
         Begin
            Select Ctipcoa, Sseguro, Cempres
              INTO v_ctipcoa, v_sseguro, v_cempres
              FROM reciboscar
             WHERE sproces = psproces
               AND nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 105304;   -- RECIBO NO ENCONTRADO EN RECIBOSCAR
            WHEN OTHERS THEN
               RETURN 105305;   -- ERROR AL LEER DE LA TABLA RECIBOSCAR
         End;

            --AMA-209-24/06/2016-VCG-REDONDEO SRI
         If Nvl(Pac_Parametros.F_Parempresa_N(V_Cempres, 'REDONDEO_SRI'), 0) > 0 Then
           Pmoneda:= pac_oper_monedas.f_monpol(v_sseguro);
         BEGIN
            -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
            INSERT INTO vdetreciboscar_monpol
                        (sproces, nrecibo, iprinet, irecext, iconsor, ireccon, iips, idgs,
                         iarbitr, ifng, irecfra, idtotec, idtocom, icombru, icomret, ipridev,
                         idtoom, iderreg, icomdev, iretdev, iocorec,   -- Se añade el campo que almacena otros conceptos recargo.
                                                                    it1pri, it1dto, it1con,
                         it1imp, it1totr, it1rec, icednet, icedrex, icedcon, icedrco, icedips,
                         iceddgs, icedarb, icedfng, icedrfr, iceddte, iceddco, icedcbr,
                         icedcrt, icedpdv, iceddom, icedreg, icedcdv, icedrdv, it2pri, it2dto,
                         it2con, it2imp, it2totr, it2rec, itotpri, itotdto, itotcon, itotimp,
                         itotrec, itotalr, icombrui, icomreti, icomdevi, icomdrti, icombruc,
                         icomretc, icomdevc, icomdrtc, icomcia,   -- Se añade el campo que almacena la comision de la cia.
                                                               iimp_1, iimp_2, iimp_3, iimp_4)
               SELECT   sproces, nrecibo, SUM(DECODE(cconcep, 0, iconcep_monpol, 0)) iprinet,   -- IMPORTES PARTE LOCAL
                        SUM(DECODE(cconcep, 1, iconcep_monpol, 0)) irecext,
                        SUM(DECODE(cconcep, 2, iconcep_monpol, 0)) iconsor,
                        Sum(Decode(Cconcep, 3, Iconcep_Monpol, 0)) Ireccon,
                        f_round(SUM(DECODE(cconcep, 4, iconcep_monpol, 0)), pmoneda) iips,
                        f_round(SUM(DECODE(cconcep, 5, iconcep_monpol, 0)), pmoneda) idgs,
                        f_round(SUM(DECODE(cconcep, 6, iconcep_monpol, 0)), pmoneda) iarbitr,
                        SUM(DECODE(cconcep, 7, iconcep_monpol, 0)) ifng,
                        f_round(SUM(DECODE(cconcep, 8, iconcep_monpol, 0)), pmoneda) irecfra,
                        SUM(DECODE(cconcep, 9, iconcep_monpol, 0)) idtotec,
                        SUM(DECODE(cconcep, 10, iconcep_monpol, 0)) idtocom,
                        SUM(DECODE(cconcep, 11, iconcep_monpol, 0)) icombru,
                        SUM(DECODE(cconcep, 12, iconcep_monpol, 0)) icomret,
                        SUM(DECODE(cconcep, 21, iconcep_monpol, 0)) ipridev,
                        SUM(DECODE(cconcep, 13, iconcep_monpol, 0)) idtoom,
                        f_round(SUM(DECODE(cconcep, 14, iconcep_monpol, 0)), pmoneda) iderreg,
                        SUM(DECODE(cconcep, 15, iconcep_monpol, 0)) icomdev,
                        SUM(DECODE(cconcep, 16, iconcep_monpol, 0)) iretdev,
                        SUM(DECODE(cconcep, 26, iconcep_monpol, 0)) iocorec,
                        (SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
                         +   -- CALCULO DE TOTALES LOCALES
                          SUM(DECODE(cconcep, 1, iconcep_monpol, 0))) it1pri,
                        SUM(DECODE(cconcep, 13, iconcep_monpol, 0)) it1dto,
                        (SUM(DECODE(cconcep, 2, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 3, iconcep_monpol, 0))) it1con,
                        (f_round(SUM(DECODE(cconcep, 4, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 5, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 6, iconcep_monpol, 0)), pmoneda)
                         + SUM(DECODE(cconcep, 7, iconcep_monpol, 0))) it1imp,
                        (SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 1, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 2, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 3, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 4, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 5, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 6, iconcep_monpol, 0)), pmoneda)
                         + SUM(DECODE(cconcep, 7, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 8, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 14, iconcep_monpol, 0)), pmoneda)
                         - SUM(DECODE(cconcep, 13, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 86, iconcep_monpol, 0)), pmoneda)) it1totr,
                        (f_round(SUM(DECODE(cconcep, 8, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 14, iconcep_monpol, 0)), pmoneda)) it1rec,   -- BUG 27346-147180 - 20/06/2013 - AMC
                        SUM(DECODE(cconcep, 50, iconcep_monpol, 0)) icednet,   -- IMPORTES PARTE CEDIDA
                        SUM(DECODE(cconcep, 51, iconcep_monpol, 0)) icedrex,
                        SUM(DECODE(cconcep, 52, iconcep_monpol, 0)) icedcon,
                        SUM(DECODE(cconcep, 53, iconcep_monpol, 0)) icedrco,
                        f_round(SUM(DECODE(cconcep, 54, iconcep_monpol, 0)), pmoneda) icedips,
                        f_round(SUM(DECODE(cconcep, 55, iconcep_monpol, 0)), pmoneda) iceddgs,
                        f_round(SUM(DECODE(cconcep, 56, iconcep_monpol, 0)), pmoneda) icedarb,
                        SUM(DECODE(cconcep, 57, iconcep_monpol, 0)) icedfng,
                        f_round(SUM(DECODE(cconcep, 58, iconcep_monpol, 0)), pmoneda) icedrfr,
                        SUM(DECODE(cconcep, 59, iconcep_monpol, 0)) iceddte,
                        SUM(DECODE(cconcep, 60, iconcep_monpol, 0)) iceddco,
                        SUM(DECODE(cconcep, 61, iconcep_monpol, 0)) icedcbr,
                        SUM(DECODE(cconcep, 62, iconcep_monpol, 0)) icedcrt,
                        SUM(DECODE(cconcep, 71, iconcep_monpol, 0)) icedpdv,
                        SUM(DECODE(cconcep, 63, iconcep_monpol, 0)) iceddom,
                        f_round(SUM(DECODE(cconcep, 64, iconcep_monpol, 0)), pmoneda) icedreg,
                        SUM(DECODE(cconcep, 65, iconcep_monpol, 0)) icedcdv,
                        SUM(DECODE(cconcep, 66, iconcep_monpol, 0)) icedrdv,
                        (SUM(DECODE(cconcep, 50, iconcep_monpol, 0))
                         +   -- CALCULO DE TOTALES PARTE CEDIDA
                          SUM(DECODE(cconcep, 51, iconcep_monpol, 0))) it2pri,
                        SUM(DECODE(cconcep, 63, iconcep_monpol, 0)) it2dto,
                        (SUM(DECODE(cconcep, 52, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 53, iconcep_monpol, 0))) it2con,
                        (f_round(SUM(DECODE(cconcep, 54, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 55, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 56, iconcep_monpol, 0)), pmoneda)
                         + SUM(DECODE(cconcep, 57, iconcep_monpol, 0))) it2imp,
                        (SUM(DECODE(cconcep, 50, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 51, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 52, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 53, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 54, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 55, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 56, iconcep_monpol, 0)), pmoneda)
                         + SUM(DECODE(cconcep, 57, iconcep_monpol, 0))
                         + f_round(SUM(DECODE(cconcep, 58, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 64, iconcep_monpol, 0)), pmoneda)
                         - SUM(DECODE(cconcep, 63, iconcep_monpol, 0))) it2totr,
                        (f_round(SUM(DECODE(cconcep, 58, iconcep_monpol, 0)), pmoneda)
                         + f_round(SUM(DECODE(cconcep, 64, iconcep_monpol, 0)), pmoneda)) it2rec,
                        0, 0, 0, 0, 0, 0,
                        (SUM(DECODE(cconcep, 17, iconcep_monpol, 0))) icombrui,   -- CALCULO DE IMPORTES DE COMISIONES INDIRECTAS
                        (SUM(DECODE(cconcep, 18, iconcep_monpol, 0))) icomreti,
                        (SUM(DECODE(cconcep, 19, iconcep_monpol, 0))) icomdevi,
                        (SUM(DECODE(cconcep, 20, iconcep_monpol, 0))) icomdrti,
                        (SUM(DECODE(cconcep, 22, iconcep_monpol, 0))) icombruc,   -- CALCULO DE IMPORTES DE COM. AGTE. COBRADOR
                        (SUM(DECODE(cconcep, 23, iconcep_monpol, 0))) icomretc,
                        (SUM(DECODE(cconcep, 24, iconcep_monpol, 0))) icomdevc,
                        (SUM(DECODE(cconcep, 25, iconcep_monpol, 0))) icomdrtc,
                        SUM(DECODE(cconcep, 30, iconcep_monpol, 0)) icomcia,   --  Se añade el campo que almacena la comision de la cia.
                        SUM(DECODE(cconcep, 32, iconcep_monpol, 0)) iimp_1,
                        SUM(DECODE(cconcep, 40, iconcep_monpol, 0)) iimp_2,
                        SUM(DECODE(cconcep, 41, iconcep_monpol, 0)) iimp_3,
                        SUM(DECODE(cconcep, 42, iconcep_monpol, 0)) iimp_4
                   FROM detreciboscar
                  WHERE sproces = psproces
                    AND nrecibo = pnrecibo
               GROUP BY sproces, nrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 103470;   -- REBUT NO TROBAT A DETRECIBOSCAR
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 9902864;   -- Registre duplicat a VDETRECIBOSCAR_MONPOL
            WHEN OTHERS THEN
               RETURN 9902865;   -- Error inserint a VDETRECIBOSCAR_MONPOL
         End;
         Else
            BEGIN
            -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
            INSERT INTO vdetreciboscar_monpol
                        (sproces, nrecibo, iprinet, irecext, iconsor, ireccon, iips, idgs,
                         iarbitr, ifng, irecfra, idtotec, idtocom, icombru, icomret, ipridev,
                         idtoom, iderreg, icomdev, iretdev, iocorec,   -- Se añade el campo que almacena otros conceptos recargo.
                                                                    it1pri, it1dto, it1con,
                         it1imp, it1totr, it1rec, icednet, icedrex, icedcon, icedrco, icedips,
                         iceddgs, icedarb, icedfng, icedrfr, iceddte, iceddco, icedcbr,
                         icedcrt, icedpdv, iceddom, icedreg, icedcdv, icedrdv, it2pri, it2dto,
                         it2con, it2imp, it2totr, it2rec, itotpri, itotdto, itotcon, itotimp,
                         itotrec, itotalr, icombrui, icomreti, icomdevi, icomdrti, icombruc,
                         icomretc, icomdevc, icomdrtc, icomcia,   -- Se añade el campo que almacena la comision de la cia.
                                                               iimp_1, iimp_2, iimp_3, iimp_4)
               SELECT   sproces, nrecibo, SUM(DECODE(cconcep, 0, iconcep_monpol, 0)) iprinet,   -- IMPORTES PARTE LOCAL
                        SUM(DECODE(cconcep, 1, iconcep_monpol, 0)) irecext,
                        SUM(DECODE(cconcep, 2, iconcep_monpol, 0)) iconsor,
                        SUM(DECODE(cconcep, 3, iconcep_monpol, 0)) ireccon,
                        SUM(DECODE(cconcep, 4, iconcep_monpol, 0)) iips,
                        SUM(DECODE(cconcep, 5, iconcep_monpol, 0)) idgs,
                        SUM(DECODE(cconcep, 6, iconcep_monpol, 0)) iarbitr,
                        SUM(DECODE(cconcep, 7, iconcep_monpol, 0)) ifng,
                        SUM(DECODE(cconcep, 8, iconcep_monpol, 0)) irecfra,
                        SUM(DECODE(cconcep, 9, iconcep_monpol, 0)) idtotec,
                        SUM(DECODE(cconcep, 10, iconcep_monpol, 0)) idtocom,
                        SUM(DECODE(cconcep, 11, iconcep_monpol, 0)) icombru,
                        SUM(DECODE(cconcep, 12, iconcep_monpol, 0)) icomret,
                        SUM(DECODE(cconcep, 21, iconcep_monpol, 0)) ipridev,
                        SUM(DECODE(cconcep, 13, iconcep_monpol, 0)) idtoom,
                        SUM(DECODE(cconcep, 14, iconcep_monpol, 0)) iderreg,
                        SUM(DECODE(cconcep, 15, iconcep_monpol, 0)) icomdev,
                        SUM(DECODE(cconcep, 16, iconcep_monpol, 0)) iretdev,
                        SUM(DECODE(cconcep, 26, iconcep_monpol, 0)) iocorec,
                        (SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
                         +   -- CALCULO DE TOTALES LOCALES
                          SUM(DECODE(cconcep, 1, iconcep_monpol, 0))) it1pri,
                        SUM(DECODE(cconcep, 13, iconcep_monpol, 0)) it1dto,
                        (SUM(DECODE(cconcep, 2, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 3, iconcep_monpol, 0))) it1con,
                        (SUM(DECODE(cconcep, 4, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 5, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 6, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 7, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 86, iconcep_monpol, 0))) it1imp, -- IAXIS-4153 - JLTS - 19/06/2019. Se adiciona el concepto 86
                        (SUM(DECODE(cconcep, 0, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 1, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 2, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 3, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 4, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 5, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 6, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 7, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 8, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 14, iconcep_monpol, 0))
                         - SUM(DECODE(cconcep, 13, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 86, iconcep_monpol, 0))) it1totr,
                        (SUM(DECODE(cconcep, 8, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 14, iconcep_monpol, 0))) it1rec,   -- BUG 27346-147180 - 20/06/2013 - AMC
                        SUM(DECODE(cconcep, 50, iconcep_monpol, 0)) icednet,   -- IMPORTES PARTE CEDIDA
                        SUM(DECODE(cconcep, 51, iconcep_monpol, 0)) icedrex,
                        SUM(DECODE(cconcep, 52, iconcep_monpol, 0)) icedcon,
                        SUM(DECODE(cconcep, 53, iconcep_monpol, 0)) icedrco,
                        SUM(DECODE(cconcep, 54, iconcep_monpol, 0)) icedips,
                        SUM(DECODE(cconcep, 55, iconcep_monpol, 0)) iceddgs,
                        SUM(DECODE(cconcep, 56, iconcep_monpol, 0)) icedarb,
                        SUM(DECODE(cconcep, 57, iconcep_monpol, 0)) icedfng,
                        SUM(DECODE(cconcep, 58, iconcep_monpol, 0)) icedrfr,
                        SUM(DECODE(cconcep, 59, iconcep_monpol, 0)) iceddte,
                        SUM(DECODE(cconcep, 60, iconcep_monpol, 0)) iceddco,
                        SUM(DECODE(cconcep, 61, iconcep_monpol, 0)) icedcbr,
                        SUM(DECODE(cconcep, 62, iconcep_monpol, 0)) icedcrt,
                        SUM(DECODE(cconcep, 71, iconcep_monpol, 0)) icedpdv,
                        SUM(DECODE(cconcep, 63, iconcep_monpol, 0)) iceddom,
                        SUM(DECODE(cconcep, 64, iconcep_monpol, 0)) icedreg,
                        SUM(DECODE(cconcep, 65, iconcep_monpol, 0)) icedcdv,
                        SUM(DECODE(cconcep, 66, iconcep_monpol, 0)) icedrdv,
                        (SUM(DECODE(cconcep, 50, iconcep_monpol, 0))
                         +   -- CALCULO DE TOTALES PARTE CEDIDA
                          SUM(DECODE(cconcep, 51, iconcep_monpol, 0))) it2pri,
                        SUM(DECODE(cconcep, 63, iconcep_monpol, 0)) it2dto,
                        (SUM(DECODE(cconcep, 52, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 53, iconcep_monpol, 0))) it2con,
                        (SUM(DECODE(cconcep, 54, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 55, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 56, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 57, iconcep_monpol, 0))) it2imp,
                        (SUM(DECODE(cconcep, 50, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 51, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 52, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 53, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 54, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 55, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 56, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 57, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 58, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 64, iconcep_monpol, 0))
                         - SUM(DECODE(cconcep, 63, iconcep_monpol, 0))) it2totr,
                        (SUM(DECODE(cconcep, 58, iconcep_monpol, 0))
                         + SUM(DECODE(cconcep, 64, iconcep_monpol, 0))) it2rec,
                        0, 0, 0, 0, 0, 0,
                        (SUM(DECODE(cconcep, 17, iconcep_monpol, 0))) icombrui,   -- CALCULO DE IMPORTES DE COMISIONES INDIRECTAS
                        (SUM(DECODE(cconcep, 18, iconcep_monpol, 0))) icomreti,
                        (SUM(DECODE(cconcep, 19, iconcep_monpol, 0))) icomdevi,
                        (SUM(DECODE(cconcep, 20, iconcep_monpol, 0))) icomdrti,
                        (SUM(DECODE(cconcep, 22, iconcep_monpol, 0))) icombruc,   -- CALCULO DE IMPORTES DE COM. AGTE. COBRADOR
                        (SUM(DECODE(cconcep, 23, iconcep_monpol, 0))) icomretc,
                        (SUM(DECODE(cconcep, 24, iconcep_monpol, 0))) icomdevc,
                        (SUM(DECODE(cconcep, 25, iconcep_monpol, 0))) icomdrtc,
                        SUM(DECODE(cconcep, 30, iconcep_monpol, 0)) icomcia,   --  Se añade el campo que almacena la comision de la cia.
                        SUM(DECODE(cconcep, 32, iconcep_monpol, 0)) iimp_1,
                        SUM(DECODE(cconcep, 40, iconcep_monpol, 0)) iimp_2,
                        SUM(DECODE(cconcep, 41, iconcep_monpol, 0)) iimp_3,
                        SUM(DECODE(cconcep, 42, iconcep_monpol, 0)) iimp_4
                   FROM detreciboscar
                  WHERE sproces = psproces
                    AND nrecibo = pnrecibo
               GROUP BY sproces, nrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 103470;   -- REBUT NO TROBAT A DETRECIBOSCAR
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 9902864;   -- Registre duplicat a VDETRECIBOSCAR_MONPOL
            WHEN OTHERS THEN
               RETURN 9902865;   -- Error inserint a VDETRECIBOSCAR_MONPOL
         End;
         end if;

         IF v_ctipcoa = 1 THEN
            -- RECIBO ÚNICO
            UPDATE vdetreciboscar_monpol   -- TOTAL SERA PARTE LOCAL + PARTE CEDIDA
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
            UPDATE vdetreciboscar_monpol   -- TOTAL SERA PARTE LOCAL
               SET itotpri = it1pri,
                   itotdto = it1dto,
                   itotcon = it1con,
                   itotimp = it1imp,
                   itotalr = it1totr + iocorec,
                   itotrec = it1rec
             WHERE sproces = psproces
               AND nrecibo = pnrecibo;
         END IF;

         RETURN 0;
      ELSE
         RAISE error_params;
      END IF;
   EXCEPTION
      WHEN error_params THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_VDETRECIBOS_MONPOL - pnrecibo: ' || pnrecibo || ', pmodo: ' || pmodo
                     || ', psproces: ' || psproces,
                     f_axis_literales(101901, 2));
         RETURN 101901;   -- Paso de parámetros incorrecto a la función
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 2,
                     'F_VDETRECIBOS_MONPOL - pnrecibo: ' || pnrecibo || ', pmodo: ' || pmodo
                     || ', psproces: ' || psproces,
                     f_axis_literales(140999, 2) || ': ' || SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_vdetrecibos_monpol;

   /*************************************************************************
    F_MONPOL
      Funcion que obtiene la moneda a nivel de póliza o la de la empresa en
      su defecto.

      param in psseguro : código de seguro
      return            : la moneda a nivel de póliza o la de la empresa en
                          su defecto
   *************************************************************************/
   FUNCTION f_monpol(psseguro NUMBER)
      RETURN NUMBER IS
      v_cmonpol      parempresas.nvalpar%TYPE;
   BEGIN
      SELECT NVL(cmoneda, pac_parametros.f_parempresa_n(cempres, 'MONEDAEMP'))
        INTO v_cmonpol
        FROM seguros
       WHERE sseguro = psseguro;

      RETURN v_cmonpol;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END f_monpol;

   /*************************************************************************
    F_MONCONTAB
      Funcion que obtiene la moneda de la contabilidad a partir de un código
      de seguro.

      param in psseguro : código de seguro
      return            : la moneda de la contabilidad
   *************************************************************************/
   FUNCTION f_moncontab(psseguro NUMBER)
      RETURN NUMBER IS
      v_cmoncon      parempresas.nvalpar%TYPE;
   BEGIN
      SELECT pac_parametros.f_parempresa_n(cempres, 'MONEDACONTAB')
        INTO v_cmoncon
        FROM seguros
       WHERE sseguro = psseguro;

      RETURN v_cmoncon;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END f_moncontab;

   /*************************************************************************
    F_MONRES
      Funcion que obtiene la moneda de la reserva de un siniestro, a partir del
      nº de siniestro o del nº de pago.

      param in pnsinies : número de siniestro
      param in psidepag : número de pago
      return            : la moneda de la reserva
   *************************************************************************/
   FUNCTION f_monres(pnsinies NUMBER, psidepag NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_nsinies      sin_siniestro.nsinies%TYPE;
      v_cmonres      productos.cdivisa%TYPE;
   BEGIN
      IF pnsinies IS NULL THEN
         SELECT nsinies
           INTO v_nsinies
           FROM sin_tramita_pago
          WHERE sidepag = psidepag;
      ELSE
         v_nsinies := pnsinies;
      END IF;

      SELECT p.cdivisa
        INTO v_cmonres
        FROM productos p, seguros s, sin_siniestro ss
       WHERE ss.nsinies = v_nsinies
         AND s.sseguro = ss.sseguro
         AND p.sproduc = s.sproduc;

      RETURN v_cmonres;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
   END f_monres;

   /*************************************************************************
    F_DATOS_CONTRAVAL
      Funcion que obtiene los datos necesarios para calcular los contravalores.

      param in psseguro : código de seguro
      param in pnrecibo : número de recibo
      param in pscontra : código de contrato reaseguro
      param in pfecha   : fecha máxima de cambio
      param in ptipomon : tipo moneda contravalor:
                          1 - póliza; 2 - empresa; 3 - contabilidad
      param out pitasa  : tasa a aplicar
      param out pfcambio: fecha de cambio a grabar
      param in pmodo    : modo
      param in psproces : número de proceso
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_datos_contraval(
      psseguro NUMBER,
      pnrecibo NUMBER,
      pscontra NUMBER,
      pfecha IN DATE,
      ptipomon IN NUMBER,
      pitasa OUT NUMBER,
      pfcambio OUT DATE,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_sseguro      seguros.sseguro%TYPE;
      v_cmonpol      eco_codmonedas.cmoneda%TYPE;
      v_cmonprod     eco_codmonedas.cmoneda%TYPE;
      v_cmoncia      eco_codmonedas.cmoneda%TYPE;
      v_cmoncon      eco_codmonedas.cmoneda%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cmonout      eco_codmonedas.cmoneda%TYPE;
   BEGIN
      IF pnrecibo IS NOT NULL THEN
         IF pmodo IN('A', 'ANP', 'H', 'I', 'R', 'RRIE') THEN
            SELECT sseguro
              INTO v_sseguro
              FROM recibos
             WHERE nrecibo = pnrecibo;
         ELSIF pmodo IN('N', 'P', 'PRIE') THEN
            SELECT sseguro
              INTO v_sseguro
              FROM reciboscar
             WHERE sproces = psproces
               AND nrecibo = pnrecibo;
         ELSE
            RAISE error_params;
         END IF;
      ELSIF psseguro IS NOT NULL THEN
         v_sseguro := psseguro;
      END IF;

      IF v_sseguro IS NOT NULL THEN
         SELECT pac_monedas.f_cmoneda_t(NVL(s.cmoneda,
                                            pac_parametros.f_parempresa_n(s.cempres,
                                                                          'MONEDAEMP'))),
                pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_divisa(p.cdivisa)), s.cempres
           INTO v_cmonpol,
                v_cmonprod, v_cempres
           FROM seguros s, productos p
          WHERE s.sseguro = v_sseguro
            AND p.sproduc = s.sproduc;
      ELSIF pscontra IS NOT NULL THEN
         SELECT cmoneda, cempres
           INTO v_cmonprod, v_cempres
           FROM codicontratos
          WHERE scontra = pscontra;
      ELSE
         RAISE error_params;
      END IF;

      v_cmoncia := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(v_cempres,
                                                                         'MONEDAEMP'));
      v_cmoncon := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(v_cempres,
                                                                         'MONEDACONTAB'));

      IF ptipomon = 1 THEN
         v_cmonout := v_cmonpol;
      ELSIF ptipomon = 2 THEN
         v_cmonout := v_cmoncia;
      ELSE
         v_cmonout := v_cmoncon;
      END IF;

      IF v_cmonprod = v_cmonout THEN
         pitasa := 1;
      ELSE
         pfcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonprod, v_cmonout, pfecha);

         IF pfcambio IS NULL THEN
            RETURN 9902592;   -- No se ha encontrado el tipo de cambio entre monedas
         END IF;

         pitasa := pac_eco_tipocambio.f_cambio(v_cmonprod, v_cmonout, pfcambio);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error_params THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_DATOS_CONTRAVAL - psseguro: ' || psseguro || ', pnrecibo: '
                     || pnrecibo || ', pscontra: ' || pscontra || ', pfecha: '
                     || TO_CHAR(pfecha, 'dd/mm/yyyy') || ', pmodo: ' || pmodo
                     || ', psproces: ' || psproces,
                     f_axis_literales(101901, 2));
         RETURN 101901;   -- Paso de parámetros incorrecto a la función
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 2,
                     'F_DATOS_CONTRAVAL - psseguro: ' || psseguro || ', pnrecibo: '
                     || pnrecibo || ', pscontra: ' || pscontra || ', pfecha: '
                     || TO_CHAR(pfecha, 'dd/mm/yyyy') || ', pmodo: ' || pmodo
                     || ', psproces: ' || psproces,
                     f_axis_literales(140999, 2) || ': ' || SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_datos_contraval;

   /*************************************************************************
    F_CONTRAVALORES_RECIBO
      Funcion que calcula los contravalores de un recibo.

      param in pnrecibo : número de recibo
      param in pmodo    : modo
      param in psproces : número de proceso
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_recibo(
      pnrecibo NUMBER,
      pmodo VARCHAR2,
      psproces NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_femisio      DATE;
      v_fcambio      DATE;
      v_max_fcambio  DATE;
      v_sseguro      seguros.sseguro%TYPE;
      v_error        axis_literales.slitera%TYPE;
      v_fmovdia      movrecibo.fmovdia%TYPE;
   BEGIN
      IF pmodo IN('A', 'ANP', 'H', 'I', 'R', 'RRIE') THEN
         SELECT MAX(fcambio)
           INTO v_max_fcambio
           FROM detrecibos
          WHERE nrecibo = pnrecibo;

         SELECT sseguro, femisio
           INTO v_sseguro, v_femisio
           FROM recibos
          WHERE nrecibo = pnrecibo;

         -- INI BUG 27088
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'REC_FCAMBIO_FMOVDIA'),
                0) = 1 THEN
            --
            SELECT TRUNC(fmovdia)
              INTO v_fmovdia
              FROM movrecibo
             WHERE nrecibo = pnrecibo
               AND cestrec = 0
               AND cestant = 0;

            --
            v_femisio := v_fmovdia;
            v_max_fcambio := v_fmovdia;
         --
         END IF;

         -- FIN BUG 27088
         v_error := f_datos_contraval(v_sseguro, NULL, NULL, NVL(v_max_fcambio, v_femisio), 1,
                                      v_itasa, v_fcambio, pmodo, psproces);

         IF v_error <> 0 THEN
            RETURN v_error;
         END IF;

         UPDATE detrecibos
            SET iconcep_monpol = DECODE(iconcep_monpol,
                                        NULL, f_round(iconcep * v_itasa, f_monpol(v_sseguro)),
                                        iconcep_monpol),
                fcambio = DECODE(fcambio, NULL, NVL(v_fcambio, v_femisio), fcambio)
          WHERE nrecibo = pnrecibo;
      ELSIF pmodo IN('N', 'P', 'PRIE') THEN
         SELECT MAX(fcambio)
           INTO v_max_fcambio
           FROM detreciboscar
          WHERE sproces = psproces
            AND nrecibo = pnrecibo;

         SELECT sseguro, femisio
           INTO v_sseguro, v_femisio
           FROM reciboscar
          WHERE sproces = psproces
            AND nrecibo = pnrecibo;

         v_error := f_datos_contraval(v_sseguro, NULL, NULL, NVL(v_max_fcambio, v_femisio), 1,
                                      v_itasa, v_fcambio, pmodo, psproces);

         IF v_error <> 0 THEN
            RETURN v_error;
         END IF;

         UPDATE detreciboscar
            SET iconcep_monpol = DECODE(iconcep_monpol,
                                        NULL, f_round(iconcep * v_itasa, f_monpol(v_sseguro)),
                                        iconcep_monpol),
                fcambio = DECODE(fcambio, NULL, NVL(v_fcambio, v_femisio), fcambio)
          WHERE sproces = psproces
            AND nrecibo = pnrecibo;
      ELSE
         RAISE error_params;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error_params THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_CONTRAVALORES_RECIBO - pnrecibo: ' || pnrecibo || ', pmodo: ' || pmodo
                     || ', psproces: ' || psproces,
                     f_axis_literales(101901, 2));
         RETURN 101901;   -- Paso de parámetros incorrecto a la función
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 2,
                     'F_CONTRAVALORES_RECIBO - pnrecibo: ' || pnrecibo || ', pmodo: ' || pmodo
                     || ', psproces: ' || psproces,
                     f_axis_literales(140999, 2) || ': ' || SQLERRM);
         RETURN 140999;   -- Error no controlado
   END f_contravalores_recibo;

   /*************************************************************************
    F_CONTRAVALORES_PROVMAT
      Funcion que calcula los contravalores de la tabla PROVMAT.

      param in psproces : código de proceso
      param in psseguro : código de seguro
      param in pnriesgo : número de riesgo
      param in pcgarant : código de garantía
      param in pfcalcul : fecha de cálculo
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_provmat(
      psproces NUMBER,
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      pfcalcul DATE)
      RETURN NUMBER IS
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_cmoncon      parempresas.nvalpar%TYPE;
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      v_error := f_datos_contraval(psseguro, NULL, NULL, pfcalcul, 3, v_itasa, v_fcambio);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      v_cmoncon := f_moncontab(psseguro);

      UPDATE provmat
         SET ipriini_moncon = f_round(ipriini * v_itasa, v_cmoncon),
             ivalact_moncon = f_round(ivalact * v_itasa, v_cmoncon),
             icapgar_moncon = f_round(icapgar * v_itasa, v_cmoncon),
             ipromat_moncon = f_round(ipromat * v_itasa, v_cmoncon),
             fcambio = NVL(v_fcambio, pfcalcul)
       WHERE sproces = psproces
         AND sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_CONTRAVALORES_PROVMAT - psproces: ' || psproces || ', psseguro: '
                     || psseguro || ', pnriesgo: ' || pnriesgo || ', pcgarant: ' || pcgarant
                     || ', pfcalcul: ' || pfcalcul,
                     SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_contravalores_provmat;

   /*************************************************************************
    F_CONTRAVALORES_RESERVA
      Funcion que calcula los contravalores de las tablas SIN_TRAMITA_RESERVA.

      param in pnsinies: número de siniestro
      param in pntramit: número de tramitación
      param in pctipres: tipo de reserva
      param in pnmovres: número de movimiento de la reserva
      param in pcgarant: código de garantía
      param in pfcambio: fecha cambio (si es vacio sera fecha del dia).
      return            : 0 (si todo correcto) o código de error
   -- Bug 0021897 - 17/04/2012 - JMF
   *************************************************************************/
   FUNCTION f_contravalores_reserva(
      pnsinies NUMBER,
      pntramit NUMBER,
      pctipres NUMBER,
      pnmovres NUMBER,
      pcgarant NUMBER DEFAULT NULL,
      pfcambio DATE DEFAULT NULL)
      RETURN NUMBER IS
      v_cmonres      sin_tramita_reserva.cmonres%TYPE;
      v_cmoncia_n    monedas.cmoneda%TYPE;
      v_cmoncia_t    monedas.cmonint%TYPE;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      -- Bug 0021897 - 17/04/2012 - JMF
      v_calfec       DATE;
   BEGIN
      SELECT cmonres, pac_parametros.f_parempresa_n(cempres, 'MONEDAEMP')
        INTO v_cmonres, v_cmoncia_n
        FROM sin_tramita_reserva r, sin_siniestro si, seguros s
       WHERE r.nsinies = pnsinies
         AND ntramit = pntramit
         AND ctipres = pctipres
         AND nmovres = pnmovres
         AND si.nsinies = r.nsinies
         AND s.sseguro = si.sseguro;

      -- Bug 0021897 - 17/04/2012 - JMF
      IF pfcambio IS NOT NULL THEN
         v_calfec := pfcambio;
      ELSE
         v_calfec := f_sysdate;
      END IF;

      v_cmoncia_t := pac_monedas.f_cmoneda_t(v_cmoncia_n);

      IF v_cmonres = v_cmoncia_t THEN
         v_itasa := 1;
      ELSE
         -- Bug 0021897 - 17/04/2012 - JMF
         v_fcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonres, v_cmoncia_t, v_calfec);

         IF v_fcambio IS NULL THEN
            RETURN 9902592;   -- No se ha encontrado el tipo de cambio entre monedas
         END IF;

         -- Bug 0021897 - 17/04/2012 - JMF
         v_itasa := pac_eco_tipocambio.f_cambio(v_cmonres, v_cmoncia_t, v_fcambio);
      END IF;

      -- Bug 0021897 - 17/04/2012 - JMF: fcambio = NVL(v_fcambio, TRUNC(v_calfec))
      UPDATE sin_tramita_reserva
         SET ireserva_moncia = f_round(ireserva * v_itasa, v_cmoncia_n),
             ipago_moncia = f_round(ipago * v_itasa, v_cmoncia_n),
             iingreso_moncia = f_round(iingreso * v_itasa, v_cmoncia_n),
             irecobro_moncia = f_round(irecobro * v_itasa, v_cmoncia_n),
             icaprie_moncia = f_round(icaprie * v_itasa, v_cmoncia_n),
             ipenali_moncia = f_round(ipenali * v_itasa, v_cmoncia_n),
             iprerec_moncia = f_round(iprerec * v_itasa, v_cmoncia_n),
             ifranq_moncia = f_round(ifranq * v_itasa, v_cmoncia_n),
             itotimp_moncia = f_round(itotimp * v_itasa, v_cmoncia_n),
             itotret_moncia = f_round(itotret * v_itasa, v_cmoncia_n),   -- 0024637/0147756:NSS:21/03/2014
             fcambio = NVL(v_fcambio, TRUNC(v_calfec))
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND ctipres = pctipres
         AND nmovres = pnmovres
         AND(pcgarant IS NULL
             OR cgarant = pcgarant);

      BEGIN
         FOR stpf IN (SELECT ireserva, ireservashw, iunidad, iunidadshw, ccesta
                        FROM sin_tramita_prereserva_fnd
                       WHERE nsinies = pnsinies
                         AND ntramit = pntramit) LOOP
            UPDATE sin_tramita_prereserva_fnd
               SET ireserva_moncia = f_round(stpf.ireserva * v_itasa, v_cmoncia_n),
                   ireservashw_moncia = f_round(stpf.ireservashw * v_itasa, v_cmoncia_n),
                   iunidad_moncia = f_round(stpf.iunidad * v_itasa, v_cmoncia_n),
                   iunidadshw_moncia = f_round(stpf.iunidadshw * v_itasa, v_cmoncia_n)
             WHERE nsinies = pnsinies
               AND ntramit = pntramit
               AND ccesta = stpf.ccesta;
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 140999;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_CONTRAVALORES_RESERVA - pnsinies: ' || pnsinies || ', pntramit: '
                     || pntramit || ', pctipres: ' || pctipres || ', pnmovres: ' || pnmovres,
                     SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_contravalores_reserva;

   /*************************************************************************
    F_CONTRAVALORES_PAGOSINI
      Funcion que calcula los contravalores de las tablas SIN_TRAMITA_PAGO y
      SIN_TRAMITA_PAGO_GAR.

      param in psidepag : identificador del pago
      parma in ptabla   : 1 - sin_tramita_pago; 2 - sin_tramita_pago_gar
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_pagosini(psidepag NUMBER, ptabla NUMBER)
      RETURN NUMBER IS
      v_sseguro      sin_siniestro.sseguro%TYPE;
      v_cmonpag      eco_codmonedas.cmoneda%TYPE;
      v_cmonres      eco_codmonedas.cmoneda%TYPE;
      v_fordpag      DATE;
      v_error        axis_literales.slitera%TYPE;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_cmonpag_n    monedas.cmoneda%TYPE;
      v_fcambio      DATE;
      w_cestpag      sin_tramita_movpago.cestpag%TYPE;   -- BUG 25537 - FAL - 04/02/2014
      w_cestval      sin_tramita_movpago.cestval%TYPE;   -- BUG 25537 - FAL - 04/02/2014
   BEGIN
      SELECT s.sseguro,
             NVL(sp.cmonpag,
                 pac_monedas.f_cmoneda_t(NVL(s.cmoneda,
                                             pac_parametros.f_parempresa_n(s.cempres,
                                                                           'MONEDAEMP')))),
             NVL(sp.cmonres, pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_divisa(p.cdivisa))),
             fordpag
        INTO v_sseguro,
             v_cmonpag,
             v_cmonres,
             v_fordpag
        FROM productos p, seguros s, sin_siniestro ss, sin_tramita_pago sp
       WHERE sp.sidepag = psidepag
         AND ss.nsinies = sp.nsinies
         AND s.sseguro = ss.sseguro
         AND p.sproduc = s.sproduc;

      IF v_cmonres = v_cmonpag THEN
         v_itasa := 1;
      ELSE
         -- BUG 25537 - FAL - 04/02/2014
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'CONTRAVALOR_ACTUAL'),
                0) = 1 THEN
            BEGIN
               SELECT cestpag, cestval
                 INTO w_cestpag, w_cestval
                 FROM sin_tramita_movpago
                WHERE sidepag = psidepag
                  AND nmovpag = (SELECT MAX(nmovpag)
                                   FROM sin_tramita_movpago
                                  WHERE sidepag = psidepag);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_cestpag := NVL(w_cestpag,0);
                  w_cestval := NVL(w_cestval,1);
            END;

            IF w_cestpag = 1
               AND w_cestval = 1 THEN
               v_fcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonres, v_cmonpag,
                                                                  f_sysdate);   -- si aceptado calcula contravalor a la fecha actual
            ELSIF w_cestpag = 0 THEN
               v_fcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonres, v_cmonpag,
                                                                  v_fordpag);   -- si pdte. calcula contravalor a la fecha fordpag (como siempre)
            ELSE
               RETURN 0;   -- no recalcular importes
            END IF;
         ELSE
            v_fcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonres, v_cmonpag,
                                                               v_fordpag);
         END IF;

         -- FI BUG 25537 - FAL - 04/02/2014
         IF v_fcambio IS NULL THEN
            RETURN 9902592;   -- No se ha encontrado el tipo de cambio entre monedas
         END IF;

         v_itasa := pac_eco_tipocambio.f_cambio(v_cmonres, v_cmonpag, v_fcambio);
      END IF;

      v_cmonpag_n := pac_monedas.f_cmoneda_n(v_cmonpag);

      IF ptabla = 1 THEN
         UPDATE sin_tramita_pago
            SET cmonres = NVL(cmonres, v_cmonres),
                cmonpag = NVL(cmonpag, v_cmonpag),
                isinretpag = f_round(isinret * v_itasa, v_cmonpag_n),
                iretencpag = f_round(iretenc * v_itasa, v_cmonpag_n),
                iivapag = f_round(iiva * v_itasa, v_cmonpag_n),
                isuplidpag = f_round(isuplid * v_itasa, v_cmonpag_n),
                ifranqpag = f_round(ifranq * v_itasa, v_cmonpag_n),
                iresrcmpag = f_round(iresrcm * v_itasa, v_cmonpag_n),
                iresredpag = f_round(iresred * v_itasa, v_cmonpag_n),
                ireteivapag = f_round(ireteiva * v_itasa, v_cmonpag_n),
                ireteicapag = f_round(ireteica * v_itasa, v_cmonpag_n),
                iicapag = f_round(iica * v_itasa, v_cmonpag_n),
                fcambio = NVL(v_fcambio, v_fordpag),
                iotrosgaspag = f_round(iotrosgas * v_itasa, v_cmonpag_n)    --IAXIS 4727 AABC contabilidad 
          WHERE sidepag = psidepag;
      ELSE
         UPDATE sin_tramita_pago_gar
            SET cmonres = NVL(cmonres, v_cmonres),
                cmonpag = NVL(cmonpag, v_cmonpag),
                isinretpag = f_round(isinret * v_itasa, v_cmonpag_n),
                iivapag = f_round(iiva * v_itasa, v_cmonpag_n),
                isuplidpag = f_round(isuplid * v_itasa, v_cmonpag_n),
                iretencpag = f_round(iretenc * v_itasa, v_cmonpag_n),
                ifranqpag = f_round(ifranq * v_itasa, v_cmonpag_n),
                iresrcmpag = f_round(iresrcm * v_itasa, v_cmonpag_n),
                iresredpag = f_round(iresred * v_itasa, v_cmonpag_n),
                ireteivapag = f_round(ireteiva * v_itasa, v_cmonpag_n),
                ireteicapag = f_round(ireteica * v_itasa, v_cmonpag_n),
                iicapag = f_round(iica * v_itasa, v_cmonpag_n),
                fcambio = NVL(v_fcambio, v_fordpag),
                iotrosgaspag = f_round(iotrosgas * v_itasa, v_cmonpag_n),   --IAXIS 4727 AABC contabilidad 
                ibaseipocpag = f_round(ibaseipocpag * v_itasa, v_cmonpag_n),
                iipoconsumopag = f_round(iipoconsumopag * v_itasa, v_cmonpag_n)
          WHERE sidepag = psidepag;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_CONTRAVALORES_PAGOSINI - psidepag: ' || psidepag || ', ptabla: '
                     || ptabla,
                     SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_contravalores_pagosini;

   /*************************************************************************
    F_UPDATE_CTASEGURO_MONPOL
      Funcion que actualiza los importes de contravalor en una o varias filas
      de CTASEGURO.

      param in psseguro : identificador del seguro
      param in pfcontab : fecha contable
      param in pnnumlin : número de línea
      param in pfvalmov : fecha valor
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_update_ctaseguro_monpol(
      psseguro NUMBER,
      pfcontab DATE,
      pnnumlin NUMBER,
      pfvalmov DATE DEFAULT NULL)
      RETURN NUMBER IS
      v_fvalmov      DATE;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_cmonpol      parempresas.nvalpar%TYPE;
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      IF pfvalmov IS NOT NULL THEN
         v_fvalmov := pfvalmov;
      ELSE
         SELECT fvalmov
           INTO v_fvalmov
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND fcontab = pfcontab
            AND nnumlin = pnnumlin;
      END IF;

      v_error := f_datos_contraval(psseguro, NULL, NULL, v_fvalmov, 1, v_itasa, v_fcambio);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      v_cmonpol := f_monpol(psseguro);

      UPDATE ctaseguro
         SET imovimi_monpol = f_round(imovimi * v_itasa, v_cmonpol),
             imovim2_monpol = f_round(imovim2 * v_itasa, v_cmonpol),
             fcambio = NVL(v_fcambio, v_fvalmov)
       WHERE sseguro = psseguro
         AND fcontab = pfcontab
         AND nnumlin = pnnumlin;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_UPDATE_CTASEGURO_MONPOL - psseguro: ' || psseguro || ', pfcontab: '
                     || pfcontab || ', pnnumlin: ' || pnnumlin || ', pfvalmov: ' || pfvalmov,
                     SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_update_ctaseguro_monpol;

   /*************************************************************************
    F_UPDATE_CTASEGURO_SHW_MONPOL
      Funcion que actualiza los importes de contravalor en una o varias filas
      de CTASEGURO_SHADOW.

      param in psseguro : identificador del seguro
      param in pfcontab : fecha contable
      param in pnnumlin : número de línea
      param in pfvalmov : fecha valor
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_update_ctaseguro_shw_monpol(
      psseguro NUMBER,
      pfcontab DATE,
      pnnumlin NUMBER,
      pfvalmov DATE DEFAULT NULL)
      RETURN NUMBER IS
      v_fvalmov      DATE;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_cmonpol      parempresas.nvalpar%TYPE;
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      IF pfvalmov IS NOT NULL THEN
         v_fvalmov := pfvalmov;
      ELSE
         SELECT fvalmov
           INTO v_fvalmov
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro
            AND fcontab = pfcontab
            AND nnumlin = pnnumlin;
      END IF;

      v_error := f_datos_contraval(psseguro, NULL, NULL, v_fvalmov, 1, v_itasa, v_fcambio);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      v_cmonpol := f_monpol(psseguro);

      UPDATE ctaseguro_shadow
         SET imovimi_monpol = f_round(imovimi * v_itasa, v_cmonpol),
             imovim2_monpol = f_round(imovim2 * v_itasa, v_cmonpol),
             fcambio = NVL(v_fcambio, v_fvalmov)
       WHERE sseguro = psseguro
         AND fcontab = pfcontab
         AND nnumlin = pnnumlin;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_UPDATE_CTASEGURO_SHW_MONPOL - psseguro: ' || psseguro
                     || ', pfcontab: ' || pfcontab || ', pnnumlin: ' || pnnumlin
                     || ', pfvalmov: ' || pfvalmov,
                     SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_update_ctaseguro_shw_monpol;

   /*************************************************************************
    F_CONTRAVALORES_PAGOSRENTA
      Funcion que calcula los contravalores de las tablas pagosrenta

      param in psrecren : identificador del pago de renta
      param in psseguro : identificador del seguro
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_pagosrenta(psrecren IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER IS
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_cmonpol      parempresas.nvalpar%TYPE;
      vseguro        seguros.sseguro%TYPE;
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      IF psseguro IS NULL THEN
         SELECT sseguro
           INTO vseguro
           FROM pagosrenta
          WHERE srecren = psrecren;
      ELSE
         vseguro := psseguro;
      END IF;

      v_error := f_datos_contraval(vseguro, NULL, NULL, f_sysdate, 3, v_itasa, v_fcambio);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      v_cmonpol :=
         pac_parametros.f_parempresa_n
                   (pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                          'IAX_EMPRESA'),
                    'MONEDACONTAB');

      UPDATE pagosrenta
         SET isinret_moncon = f_round(isinret * v_itasa, v_cmonpol),
             iretenc_moncon = f_round(iretenc * v_itasa, v_cmonpol),
             iconret_moncon = f_round(iconret * v_itasa, v_cmonpol),
             ibase_moncon = f_round(ibase * v_itasa, v_cmonpol),
             fcambio = v_fcambio
       WHERE srecren = psrecren;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_CONTRAVALORES_PAGOSRENTA - psseguro: ' || psseguro || ', psrecren: '
                     || psrecren,
                     SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_contravalores_pagosrenta;

   /*************************************************************************
    F_CONTRAVALORES_TMP_PAGOSRENTA
      Funcion que calcula los contravalores de las tablas pagosrenta

      param in psrecren : identificador del pago de renta
      param in psseguro : identificador del seguro
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_tmp_pagosrenta(
      pstmppare IN NUMBER,
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pffecpag IN DATE)
      RETURN NUMBER IS
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_cmonpol      parempresas.nvalpar%TYPE;
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      v_error := f_datos_contraval(psseguro, NULL, NULL, f_sysdate, 3, v_itasa, v_fcambio);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      v_cmonpol :=
         pac_parametros.f_parempresa_n
                   (pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                          'IAX_EMPRESA'),
                    'MONEDACONTAB');

      UPDATE tmp_pagosrenta
         SET isinret_moncon = f_round(isinret * v_itasa, v_cmonpol),
             iretenc_moncon = f_round(iretenc * v_itasa, v_cmonpol),
             iconret_moncon = f_round(iconret * v_itasa, v_cmonpol),
             ibase_moncon = f_round(ibase * v_itasa, v_cmonpol),
             fcambio = v_fcambio
       WHERE stmppare = pstmppare
         AND sseguro = psseguro
         AND sperson = psperson
         AND ffecpag = pffecpag;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_CONTRAVALORES_TMP_PAGOSRENTA - pstmppare: ' || pstmppare
                     || ', psseguro: ' || psseguro || 'psperson: ' || psperson || 'pffecpag: '
                     || pffecpag,
                     SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_contravalores_tmp_pagosrenta;

   /*************************************************************************
    F_CONTRAVALORES_PLANRENTASEXTR
      Funcion que calcula los contravalores de las tablas pagosrenta

      param in psseguro : identificador del seguro
      param in pnriesgo : número de riesgo
      param in pnmovimi : número de movimiento
      return            : 0 (si todo correcto) o código de error
   *************************************************************************/
   FUNCTION f_contravalores_planrentasextr(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_cmonpol      parempresas.nvalpar%TYPE;
      v_error        axis_literales.slitera%TYPE;
   BEGIN
      v_error := f_datos_contraval(psseguro, NULL, NULL, f_sysdate, 3, v_itasa, v_fcambio);

      IF v_error <> 0 THEN
         RETURN v_error;
      END IF;

      v_cmonpol :=
         pac_parametros.f_parempresa_n
                   (pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                          'IAX_EMPRESA'),
                    'MONEDACONTAB');

      UPDATE planrentasextra
         SET ipago_moncon = f_round(ipago * v_itasa, v_cmonpol),
             fcambio = v_fcambio
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPER_MONEDAS', 1,
                     'F_CONTRAVALORES_PAGOSRENTA - psseguro: ' || psseguro || ', pnriesgo: '
                     || pnriesgo || 'pnmovimi: ' || pnmovimi,
                     SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_contravalores_planrentasextr;
END pac_oper_monedas;
/
