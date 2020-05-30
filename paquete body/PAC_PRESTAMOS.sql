--------------------------------------------------------
--  DDL for Package Body PAC_PRESTAMOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PRESTAMOS" AS
   /******************************************************************************
       NOMBRE:      PAC_PRESTAMOS
       PROPÓSITO:   Funciones para la gestión de los prestamos

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------------  ------------------------------------
       1.0        21/10/2009   APD             1. Creación del package.Bug 9204
       2.0        01/12/2011   DRA             2. 0019238: LCOL_T001- Prèstecs de pòlisses de vida
       3.0        24/01/2012   JMF             3. 0019238: LCOL_T001- Prèstecs de pòlisses de vida
       4.0        06/02/2012   JGR             4. 0021115: LCOL_A001-Rebuts no pagats i anticips II
       5.0        13/02/2012   JGR             5. 0021115: LCOL_A001-Rebuts no pagats i anticips III
       6.0        20/03/2012   JMC             6. 0021751: LCOL_T001-- Incidencies pantalles de prestecs
       7.0        11/07/2012   JGR<             7. 0022738: No se canceló la póliza 1541 despues de tres intetos de cobro no exitosos. - 0118685
       8.0        06/09/2012   MDS             8. 0023254: LCOL - qtrackers 4806 / 4808. Màxim dels prestecs.
       9.0        17/09/2011   MDS             9. 0023588: LCOL - Canvis pantalles de prestecs
      10.0        18/09/2012   MDS            10. 0023749: LCOL_T001-Autoritzaci? de prestecs
      11.0        27/09/2012   MDS            11. 0023821: LCOL_T001-Ajustar llistat prestecs pendents (qtracker 4364)
      12.0        01/10/2012   MDS            12. 0023772: LCOL_T001-Reversi? de prestecs
      13.0        01/10/2012   ASN            13. 0023746
      14.0        22/10/2012   MDS            14. 0024078: LCOL_F001-Din?mica comptable pr?stecs - Proc?s de tancament mensual
      15.0        05/11/2012   MDS            15. 0024553: LCOL_T001- qtracker 5348 - interessos prestecs anulats/cancelats/reversats
      16.0        03/12/2012   AMJ/JRV        16. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
      17.0        10/12/2012   MDS            17. 0025005: LCOL_T001-QT 4367 -Llistat polisses anulades amb prestecs
      18.0        01/02/2013   ECP            18. 0025971: LCOL_T001-QT 5575: Los prestamos en estado cancelado o anulados por reversion no deben
                                                           generar capital pendiente en la pantalla
      19.0        22/02/2013   AMJ            19.LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?  Ini
      20.0        06/03/2013   ECP            20. 0026231: LCOL_F002-CONTABILIZACION ANULACION PRESTAMO  Nota 139162
      21.0        15/03/2013   AMJ            21. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
      22.0        11/10/2013   MMM            22. 0028361: LCOL_F003-0009343: CIERRE DE PRESTAMOS NO TERMINARON QUEDARON EN CIERRES PROGRAMADOS
      23.0        12/11/2013   JDS            23. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
      24.0        28/03/2013   JSV            24. 0026981: LCOL_T001-Incidencies comptabilitat de prestecs
   ******************************************************************************/

   /*************************************************************************
      Funcion para obtener la fecha de alta de un prestamo
      param in p_ctapres  : Identificador del prestamo
      param out p_falta   :  Fecha de Alta del prestamo
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)pffecpag IN DATE,
   *************************************************************************/
   FUNCTION f_fecha_ult_prest(p_ctapres IN VARCHAR2, p_falta OUT DATE)
      RETURN NUMBER IS
   BEGIN
      -- Se hace la select de esta manera para que en el caso que no encuentre nada salte
      -- la exception no_data_found
      SELECT p.falta
        INTO p_falta
        FROM prestamos p
       WHERE p.ctapres = p_ctapres
         AND p.falta IN(SELECT MAX(falta)
                          FROM prestamos p1
                         WHERE p.ctapres = p1.ctapres);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'pac_prestamos.f_fecha_ult_prest', 1,
                     'p_ctapres = ' || p_ctapres, SQLCODE || ' - ' || SQLERRM);
         RETURN 40301;   -- Registro no encontrado
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_prestamos.f_fecha_ult_prest', 2,
                     'p_ctapres = ' || p_ctapres, SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_fecha_ult_prest;

   FUNCTION f_obtener_porcentaje(
      pfiniprest IN DATE,
      psproduc IN NUMBER,
      pctipoint IN NUMBER,   -- 1 (Interes),  2 (Interes de mora)
      pinteres OUT NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      --
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
         := 'pfiniprest=' || pfiniprest || ', psproduc=' || psproduc || ', pinteres='
            || pinteres;
      vobject        VARCHAR2(200) := 'PAC_PRESTAMOS.f_obtener_porcentaje';
      vnumerr        NUMBER := 0;
      v_clave        sgt_formulas.clave%TYPE;
   BEGIN
      SELECT DECODE(pctipoint, 1, cinteres, 2, cintdemo, cinteres)
        INTO v_clave
        FROM prestamoprod
       WHERE sproduc = psproduc;

      vpasexec := 2;
      vnumerr := pac_calculo_formulas.calc_formul(pfiniprest, psproduc, NULL, NULL, NULL, NULL,
                                                  v_clave, pinteres);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         COMMIT;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9902977;   -- Error al obtener porcentaje interes.
   END f_obtener_porcentaje;

   FUNCTION f_ins_prestamoseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfalta IN DATE,
      picapital IN NUMBER,
      pcmoneda IN VARCHAR2,
      pporcen IN NUMBER,
      pctipban IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
         := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pnmovimi=' || pnmovimi
            || ', pctapres=' || pctapres || ', pfiniprest=' || pfiniprest || ', pffinprest='
            || pffinprest || ', picapital=' || picapital || ', pcmoneda=' || pcmoneda
            || ', pporcen=' || pporcen || ', pctipban=' || pctipban;
      vobject        VARCHAR2(100) := 'PAC_PRESTAMOS.f_ins_prestamoseg';
   BEGIN
      INSERT INTO prestamoseg
                  (ctapres, sseguro, nmovimi, finiprest, ffinprest, pporcen,
                   nriesgo, ctipcuenta, ctipban, ctipimp, isaldo,
                   porcen, ilimite, icapmax, icapital,
                   cmoneda, icapaseg, falta,
                   descripcion)
           VALUES (pctapres, psseguro, NVL(pnmovimi, 1), pfiniprest, pffinprest, pporcen,
                   NVL(pnriesgo, 1), 8 /*Anticipo*/, pctipban, 1 /*Saldo*/, NULL /*isaldo*/,
                   NULL /*porcen*/, NULL /*ilimite*/, NULL /*icapmax*/, picapital,
                   pac_monedas.f_cmoneda_t(pcmoneda), NULL /*icapaseg*/, pfalta,   -- 06/02/2012 JGR 4. 0021115
                   -- pfiniprest, -- 06/02/2012 JGR 4. 0021115
                   NULL   /*descripcion*/
                       );

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_ins_prestamoseg;

   FUNCTION f_ins_prestamos(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      picapital IN NUMBER,
      pitasa IN NUMBER,
      pctipamort IN NUMBER,
      pctippres IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcforpag IN NUMBER,
      pcmoneda IN NUMBER,
      pcempres IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      v_icapini_moncia prestamos.icapini_moncia%TYPE;
      v_cmonemp_t    monedas.cmonint%TYPE;
      v_cmonprod_t   monedas.cmonint%TYPE;
      vitasa         NUMBER;
      vfcambio       DATE;
      vparam         tab_error.tdescrip%TYPE
            := 'pctapres=' || pctapres || ', pfalta=' || pfalta || ', picapital=' || picapital;
      vobject        VARCHAR2(200) := 'PAC_PRESTAMOS.f_ins_prestamos';
      num_err        NUMBER;
      psmovpres      NUMBER;
   BEGIN
      v_cmonprod_t := pac_monedas.f_cmoneda_t(pcmoneda);
      v_cmonemp_t := pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(pcempres,
                                                                           'MONEDAEMP'));
      vfcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonprod_t, v_cmonemp_t, pfalta);

      IF vfcambio IS NULL THEN
         RETURN 9902592;
      -- No se ha encontrado el tipo de cambio entre monedas
      END IF;

      IF picapital IS NULL THEN
         RETURN 101679;
      -- Falta el capital
      END IF;

      -- Fin Bug 25005 - MDS - 10/12/2012
      vitasa := pac_eco_tipocambio.f_cambio(v_cmonprod_t, v_cmonemp_t, vfcambio);
      v_icapini_moncia := f_round(picapital * vitasa,
                                  pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP'));

      INSERT INTO prestamos
                  (ctapres, icapini, ctipamort, ctipint, ctippres, falta,
                   fbaja, fcarpro, ilimite, cestado, itasa, ctipban, cbancar, cforpag,
                   icapini_moncia, fcambio)
           VALUES (pctapres, f_round(picapital, pcmoneda), pctipamort, 4, pctippres, pfalta,
                   NULL, NULL, NULL, 0, pitasa, pctipban, pcbancar, pcforpag,
                   v_icapini_moncia, vfcambio);

      num_err := pac_prestamos.f_mov_prestamos(pctapres, pfalta, 0, TRUNC(f_sysdate),
                                               psmovpres);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_ins_prestamos;

   /*************************************************************************
      Funcion para insertar las cuotas del prestamo
      param in pctapres      : Identificador del préstamo
      param in pfinipres     : Fecha de inicio del préstamo
      param in pffinprest    : Fecha de vencimiento del préstamo
      param in pfalta        : Fecha de registro en iAxis
      param in picapital     : Capital del préstamo
      param in pcforpag      : Número de cuotas por año
      param in ptasa         : Porcentaje de interés del préstamo
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_ins_prestcuadro(
      pctapres IN VARCHAR2,
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfalta IN DATE,
      picapital IN NUMBER,
      pcforpag IN NUMBER DEFAULT 12,
      ptasa IN NUMBER,
      pcmoneda IN NUMBER,
      pnmesdur IN NUMBER,
      pf1cuota IN DATE,
      pcempres IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
         := 'pctapres=' || pctapres || ', pfiniprest=' || pfiniprest || ', pffinprest='
            || pffinprest || ', pfalta=' || pfalta || ', picapital=' || picapital
            || ', pcforpag=' || pcforpag || ', ptasa=' || ptasa || ', pcmoneda=' || pcmoneda
            || ', pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_PRESTAMOS.f_ins_prestcuadro';
      vnumerr        NUMBER := 0;
      vamort         tab_amortiza;
      vind           NUMBER;
      vctipamo       prestamos.ctipamort%TYPE;
      v_cmonemp_t    monedas.cmonint%TYPE;
      v_cmonemp_n    monedas.cmoneda%TYPE;
      v_cmonprod_t   monedas.cmonint%TYPE;
      vitasa         NUMBER;
      vfcambio       DATE;
      vmaxnorden     NUMBER;
      vtotal_capital NUMBER;
   BEGIN
      ----pf1cuota es la fecha de vencimiento de la primera cuota
      vpasexec := 1;
      v_cmonprod_t := pac_monedas.f_cmoneda_t(pcmoneda);
      v_cmonemp_n := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      v_cmonemp_t := pac_monedas.f_cmoneda_t(v_cmonemp_n);
      vfcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonprod_t, v_cmonemp_t, pfalta);

      IF vfcambio IS NULL THEN
         RETURN 9902592;
      -- No se ha encontrado el tipo de cambio entre monedas
      END IF;

      vitasa := pac_eco_tipocambio.f_cambio(v_cmonprod_t, v_cmonemp_t, vfcambio);
      vpasexec := 2;

      SELECT ctipamort
        INTO vctipamo
        FROM prestamos
       WHERE ctapres = pctapres
         AND falta IN(SELECT MAX(falta)
                        FROM prestamos
                       WHERE ctapres = pctapres);

      vpasexec := 3;
      vnumerr := f_calcula_cuadro(pfiniprest, pffinprest, ADD_MONTHS(pf1cuota, -1), picapital,
                                  ptasa, NVL(pcforpag, 12), vctipamo, vamort, pnmesdur);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vpasexec := 4;
      vind := vamort.FIRST;

      SELECT NVL(MAX(norden), 0) + 1
        INTO vmaxnorden
        FROM prestcuadro
       WHERE ctapres = pctapres;

      vtotal_capital := 0;   -- BUG 24402 - MDS - 10/12/2012

      WHILE vind IS NOT NULL LOOP
         INSERT INTO prestcuadro
                     (ctapres, finicua, ffincua, fvencim,
                      icapital,
                      iinteres,
                      icappend, falta, fpago,
                      fefecto,
                      icapital_moncia,
                      iinteres_moncia,
                      icappend_moncia, fcambio,
                      norden)
              VALUES (pctapres, pfiniprest, NULL, vamort(vind).fvencim,
                      f_round(vamort(vind).icapital, pcmoneda),
                      f_round(vamort(vind).intereses, pcmoneda),
                      f_round(vamort(vind).icappend, pcmoneda), pfalta, NULL,
                      vamort(vind).fefecto,
                      f_round(vamort(vind).icapital * vitasa, v_cmonemp_n),
                      f_round(vamort(vind).intereses * vitasa, v_cmonemp_n),
                      f_round(vamort(vind).icappend * vitasa, v_cmonemp_n), vfcambio,
                      vmaxnorden);

         vtotal_capital := vtotal_capital + f_round(vamort(vind).icapital, pcmoneda);
         vind := vamort.NEXT(vind);
      END LOOP;

      UPDATE prestcuadro
         SET icapital = icapital + picapital - vtotal_capital
       WHERE ctapres = pctapres
         AND finicua = pfiniprest
         AND ffincua IS NULL
         AND norden = vmaxnorden
         AND fvencim = (SELECT MAX(fvencim)
                          FROM prestcuadro
                         WHERE ctapres = pctapres
                           AND finicua = pfiniprest
                           AND ffincua IS NULL
                           AND norden = vmaxnorden);

      UPDATE prestcuadro
         SET icapital = f_round(icapital * vitasa, v_cmonemp_n)
       WHERE ctapres = pctapres
         AND finicua = pfiniprest
         AND ffincua IS NULL
         AND norden = vmaxnorden
         AND fvencim = (SELECT MAX(fvencim)
                          FROM prestcuadro
                         WHERE ctapres = pctapres
                           AND finicua = pfiniprest
                           AND ffincua IS NULL
                           AND norden = vmaxnorden);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_ins_prestcuadro;

   /*************************************************************************
      Funcion para crear el pago del préstamo
      param in pctapres   : Identificador del préstamo
      param in pfefecto   : Fecha efecto del préstamo
      param in picapital  : Importe a pagar en el préstamo
      pcestpag in picapital: Estado que se debe actulizar el pago del préstamo
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_insert_prestamospago(
      pctapres IN VARCHAR2,
      pfefecto IN DATE,
      picapital IN NUMBER,
      pfalta IN DATE,
      pcmoneda IN NUMBER,
      pcempres IN NUMBER,
      pcestpag IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
         := 'pctapres=' || pctapres || ', pfefecto=' || pfefecto || ', picapital='
            || picapital || ', pfalta=' || pfalta;
      vobject        VARCHAR2(100) := 'PAC_PRESTAMOS.f_insert_prestamospago';
      vnumerr        NUMBER := 0;
      v_cmonemp_t    monedas.cmonint%TYPE;
      v_cmonemp_n    monedas.cmoneda%TYPE;
      v_cmonprod_t   monedas.cmonint%TYPE;
      vitasa         NUMBER;
      vfcambio       DATE;
      vnmovpag       NUMBER;
   BEGIN
      v_cmonprod_t := pac_monedas.f_cmoneda_t(pcmoneda);
      v_cmonemp_n := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      v_cmonemp_t := pac_monedas.f_cmoneda_t(v_cmonemp_n);
      vfcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonprod_t, v_cmonemp_t, pfefecto);

      IF vfcambio IS NULL THEN
         RETURN 9902592;
      -- No se ha encontrado el tipo de cambio entre monedas
      END IF;

      vitasa := pac_eco_tipocambio.f_cambio(v_cmonprod_t, v_cmonemp_t, vfcambio);

      INSERT INTO prestamopago
                  (ctapres, npago, fefecto, icapital, falta,
                   icapital_monpago, cmonpago, fcambio)
           VALUES (pctapres, 1, pfefecto, f_round(picapital, pcmoneda), pfalta,
                   f_round(picapital * vitasa, v_cmonemp_n), v_cmonemp_n, vfcambio);

-- Insertar movimiento del pago
      -- pnpago   : 1
      -- pcestpag : 2 -> pagado
      -- pcsubpag : null
      vpasexec := 2;
      vnumerr := f_mov_prestamopago(pctapres, 1, NVL(pcestpag, 0), NULL, pfefecto, vnmovpag);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_insert_prestamospago;

   /*************************************************************************
      Funcion para insertar los prestamos
      param in psseguro      : Identificador del seguro
      param in pnriesgo      : Identificador del riesgo
      param in pctapres      : Identificador del préstamo
      param in pfiniprest    : Fecha de inicio del préstamo
      param in pffinprest    : Fecha de vencimiento del préstamo
      param in pfalta        : Fecha de registro en iAxis
      param in picapital     : Capital del préstamo
      param in imoneda       : Moneda de gestión del préstamo
      param in pporcen       : Porcentaje de interés del préstamo
      param in pctipo        : Indicador de si el préstamo es automático o manual
      param in out pmensajes : Mensajes de Error
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_insertar_prestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfalta IN DATE,
      picapital IN NUMBER,
      pcmoneda IN NUMBER,
      pporcen IN NUMBER,
      pctipo IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pf1cuota IN DATE,
      pffecpag IN DATE,
      pcforpag IN NUMBER,
      pmodo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
         := SUBSTR('psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres='
                   || pctapres || ', pfiniprest=' || pfiniprest || ', pffinprest='
                   || pffinprest || ', pfecpag=' || pffecpag || ', picapital=' || picapital
                   || ', pcmoneda=' || pcmoneda || ', pporcen=' || pporcen || ', pctipo='
                   || pctipo || ', pctipban=' || pctipban,
                   1, 500);
      vobject        VARCHAR2(100) := 'PAC_PRESTAMOS.f_insertar_prestamo';
      vnumerr        NUMBER := 0;
      vctapres       prestamos.ctapres%TYPE;
      vctipamort     prestamoprod.ctipamort%TYPE;
      vctippres      prestamoprod.ctippres%TYPE;
      vcempres       seguros.cempres%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      vnmesdur       prestamoprod.nmesdur%TYPE;
   BEGIN
      -- validar la información del préstamo
      vnumerr := f_validar(pctapres, pfalta, picapital, f_sysdate, psseguro, pnriesgo,
                           pfiniprest, pmodo);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vpasexec := 1;

      -- obtener información del seguro
      SELECT s.cempres, s.sproduc
        INTO vcempres, vsproduc
        FROM seguros s
       WHERE s.sseguro = psseguro;

      vpasexec := 2;

      -- obtener información del préstamo
      SELECT nmesdur, ctipamort, ctippres
        INTO vnmesdur, vctipamort, vctippres
        FROM prestamoprod
       WHERE sproduc = vsproduc;

      IF pctipo IS NOT NULL THEN
         vctippres := pctipo;
      END IF;

      -- insertar el préstamo
      IF pctapres IS NULL THEN
         SELECT sctapres.NEXTVAL
           INTO vctapres
           FROM DUAL;
      ELSE
         vctapres := pctapres;
      END IF;

      vpasexec := 3;
      vnumerr := f_ins_prestamos(vctapres, pfalta, picapital, pporcen, vctipamort, vctippres,
                                 pctipban, pcbancar, pcforpag, pcmoneda, vcempres);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vpasexec := 4;
      vnumerr := f_ins_prestamoseg(psseguro, NVL(pnriesgo, 1), pnmovimi, vctapres, pfiniprest,
                                   pffinprest, pfalta, picapital, pcmoneda, pporcen, pctipban);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vpasexec := 5;
      vnumerr := f_ins_prestcuadro(vctapres, pfiniprest, pffinprest, pfalta, picapital, 12,
                                   pporcen, pcmoneda, vnmesdur, pf1cuota, vcempres);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_insertar_prestamo;

   /*************************************************************************
      Funcion para calcular el cuadro de amortización de un préstamo
      param in pfinipres     : Fecha de inicio del préstamo
      param in pffinprest    : Fecha de vencimiento del préstamo
      param in pfalta        : Fecha de registro en iAxis
      param in picapital     : Capital del préstamo
      param in ptasa         : Porcentaje de interés del préstamo
      param in pcforpag      : Número de cuotas por año
      param in pmodo         : Indicador método de cálculo
      param in/out pcuadro   :Estructura cin el cuadro de amortización
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_calcula_cuadro(
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfefecto IN DATE,
      picapital IN NUMBER,
      ptasa IN NUMBER,
      pcforpag IN NUMBER,
      pmodo IN NUMBER,
      pcuadro IN OUT tab_amortiza,
      pnmesdur IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
         := 'pfiniprest=' || pfiniprest || ', pffinprest=' || pffinprest || ', fefecto='
            || pfefecto || ', picapital=' || picapital || ', pcforpag=' || pcforpag
            || ', ptasa=' || ptasa || ', pmodo=' || pmodo || ', pnmesdur=' || pnmesdur;
      vobject        VARCHAR2(200) := 'PAC_PRESTAMOS.f_calcula_cuadro';
      vnumerr        NUMBER := 0;
      vfefecto       DATE;
      vfvencim       DATE;
      vinteresea     NUMBER;
      cinteres       NUMBER;
      cinteres_mensual NUMBER;
      vnum_cuotas    NUMBER;
      ccuota_fija    NUMBER;
      ccapital_pendiente NUMBER;
      vtotal_capital NUMBER;
   BEGIN
      ccapital_pendiente := picapital;
      vinteresea := ptasa;
      vnum_cuotas := pnmesdur;
      cinteres := ((POWER((1 +(vinteresea / 100)),(30 / 360)) - 1) * vnum_cuotas) * 100;
      cinteres_mensual := cinteres / 12;
      ccuota_fija := (ccapital_pendiente * cinteres_mensual / 100)
                     /(1 -(1 / POWER(1 + cinteres_mensual / 100, vnum_cuotas)));
      vpasexec := 3;
      vfefecto := pfefecto;
      --vfvencim := LAST_DAY(pfefecto);
      vfvencim := ADD_MONTHS(pfefecto, 1);
      vpasexec := 4;

      FOR x IN 1 .. vnum_cuotas LOOP
         pcuadro(x).fefecto := vfefecto;
         pcuadro(x).fvencim := vfvencim;
         pcuadro(x).ncuota := x;
         pcuadro(x).intereses := ccapital_pendiente * cinteres_mensual / 100;
         pcuadro(x).icapital := ccuota_fija - pcuadro(x).intereses;
         ccapital_pendiente := ccapital_pendiente - pcuadro(x).icapital;
         pcuadro(x).icappend := ccapital_pendiente;
         vfefecto := ADD_MONTHS(vfefecto, 1);
         --vfvencim := LAST_DAY(vfefecto);
         vfvencim := ADD_MONTHS(vfefecto, 1);
      END LOOP;

      -----ajustamos diferencia con la última cuota
      vtotal_capital := 0;

      FOR x IN 1 .. vnum_cuotas LOOP
         vtotal_capital := vtotal_capital + pcuadro(x).icapital;
      END LOOP;

      pcuadro(vnum_cuotas).icapital := pcuadro(vnum_cuotas).icapital + picapital
                                       - vtotal_capital;

      IF vnum_cuotas > 1 THEN
         pcuadro(vnum_cuotas - 1).icapital := pcuadro(vnum_cuotas - 1).icapital - picapital
                                              + vtotal_capital;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_calcula_cuadro;

   /*************************************************************************
      Funcion para anular el préstamo
      param in pctapres   : Identificador del préstamo
      param in pcestado   : Nuevo estado actual del préstamo
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_anulacion(pctapres IN VARCHAR2, pcestado IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE := 'pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_PRESTAMOS.f_anulacion';
      vnumerr        NUMBER := 0;
      vcestado       prestamos.cestado%TYPE;
      vfalta         prestamos.falta%TYPE;   -- Bug 23772 - MDS - 20/09/2012
      vsmovpres      NUMBER;   -- Bug 23772 - MDS - 20/09/2012
   BEGIN
      SELECT cestado, falta
        INTO vcestado, vfalta
        FROM prestamos
       WHERE ctapres = pctapres
         AND falta IN(SELECT MAX(falta)
                        FROM prestamos
                       WHERE ctapres = pctapres);

      -- transiciones correctas : 0-->2, 1-->2
      IF NOT(vcestado IN(0, 1)
             AND NVL(pcestado, 2) IN(2, 5)) THEN
         RETURN 9902974;
      ELSE
         RETURN f_mov_prestamos(pctapres, TRUNC(vfalta), pcestado, TRUNC(f_sysdate),
                                vsmovpres);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_anulacion;

   FUNCTION f_ins_prestamocuotas(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappen IN NUMBER,
      pfvencim IN DATE,
      pidpago IN NUMBER,
      pnlinea IN NUMBER,
      pfpago IN DATE,
      picapital IN NUMBER,
      piinteres IN NUMBER,
      pidemora IN NUMBER,
      pcmoneda IN NUMBER,
      picapital_moncia IN NUMBER,
      piinteres_moncia IN NUMBER,
      picappend_moncia IN NUMBER,
      pidemora_moncia IN NUMBER,
      pfcambio IN DATE,
      pnorden IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
         := 'pctapres=' || pctapres || ', pidpago=' || pidpago || ', picapital=' || picapital
            || ', pfpago=' || pfpago;
      vobject        VARCHAR2(200) := 'PAC_PRESTAMOS.f_ins_prestamocuotas';
      vnlinea        NUMBER;
      vnumerr        NUMBER;
      vmaxnorden     NUMBER;   -- BUG 23749 - MDS - 25/09/2012
   BEGIN
      IF pnorden IS NULL THEN
         SELECT NVL(MAX(norden), 0)
           INTO vmaxnorden
           FROM prestcuadro
          WHERE ctapres = pctapres
            AND finicua = pfinicua
            AND icappend = picappen;
      ELSE
         vmaxnorden := pnorden;
      END IF;

      INSERT INTO prestamocuotas
                  (ctapres, finicua, icappend, fvencim, idpago, nlinea, fpago,
                   icapital, iinteres, idemora, icapital_moncia, iinteres_moncia,
                   icappend_moncia, idemora_moncia, fcambio, norden)
           VALUES (pctapres, pfinicua, picappen, pfvencim, pidpago, pnlinea, pfpago,
                   picapital, piinteres, pidemora, picapital_moncia, piinteres_moncia,
                   picappend_moncia, pidemora_moncia, pfcambio, vmaxnorden);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_ins_prestamocuotas;

   FUNCTION f_get_cuadro_pendiente(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pprecua OUT prestcuadro%ROWTYPE,
      ptipo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
                                           := 'pctapres=' || pctapres || ', pfalta=' || pfalta;
      vobject        VARCHAR2(200) := 'PAC_PRESTAMOS.f_get_cuadro_pendiente';
      vfvencim       DATE;
   BEGIN
      IF ptipo = 0 THEN
         SELECT MIN(fvencim)
           INTO vfvencim
           FROM prestcuadro
          WHERE ctapres = pctapres
            AND ffincua IS NULL
            AND fpago IS NULL;

         IF vfvencim IS NULL THEN
            RETURN 0;
         END IF;

         vpasexec := 2;

         SELECT *
           INTO pprecua
           FROM prestcuadro
          WHERE ctapres = pctapres
            AND fvencim = vfvencim
            AND ffincua IS NULL
            AND fpago IS NULL;
      ELSE
         SELECT ADD_MONTHS(MAX(fvencim), 1)
           INTO vfvencim
           FROM prestcuadro
          WHERE ctapres = pctapres
            AND ffincua IS NULL
            AND fpago IS NOT NULL;

         IF vfvencim IS NOT NULL THEN
            vpasexec := 2;

            SELECT *
              INTO pprecua
              FROM prestcuadro
             WHERE ctapres = pctapres
               AND fvencim = vfvencim
               AND ffincua IS NULL
               AND fpago IS NOT NULL;
         ELSE
            vpasexec := 3;

            SELECT MIN(fvencim)
              INTO vfvencim
              FROM prestcuadro
             WHERE ctapres = pctapres
               AND ffincua IS NULL
               AND fpago IS NULL;

            SELECT *
              INTO pprecua
              FROM prestcuadro
             WHERE ctapres = pctapres
               AND fvencim = vfvencim
               AND ffincua IS NULL
               AND fpago IS NULL;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     vparam || ', vfvencim=' || vfvencim, SQLERRM);
         RETURN 9903542;
   END f_get_cuadro_pendiente;

   /*************************************************************************
      Funcion para crear las cuotas satisfechas
      param in pctapres   : Identificador del préstamo
      param in pidpago    : Identificador del pago
      param in pfpago     : Fecha efecto del pago
      param in picapital  : Importe del pago
      return              : 0 (todo Ok)
                            <> 0 (ha habido algun error)
   *************************************************************************/
   FUNCTION f_insert_cuota(
      pctapres IN VARCHAR2,
      pidpago IN NUMBER,
      pfpago IN DATE,
      picapital IN NUMBER,
      pfalta IN DATE,
      pcmoneda IN NUMBER,
      pcempres IN NUMBER,
      --26981/0171128
      pcestado IN NUMBER DEFAULT 4)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         tab_error.tdescrip%TYPE
         := 'pctapres=' || pctapres || ', pidpago=' || pidpago || ', picapital=' || picapital
            || ', pfpago=' || pfpago || ', pfalta=' || pfalta || ', pcmoneda=' || pcmoneda
            || ', pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_PRESTAMOS.f_insert_cuota';
      vnumerr        NUMBER := 0;

      TYPE tcuadro IS TABLE OF prestcuadro%ROWTYPE;

      vcuadro        tcuadro;
      vprecua        prestcuadro%ROWTYPE;
      v_cmonemp_t    monedas.cmonint%TYPE;
      v_cmonemp_n    monedas.cmoneda%TYPE;
      v_cmonprod_t   monedas.cmonint%TYPE;
      vitasa         NUMBER;
      vfcambio       DATE;
      ind            NUMBER;
--      vcappend       NUMBER;
--      vcappendpres   NUMBER;
--      vcontinua      NUMBER;
--      vfultvencim    DATE;
      vsproduc       productos.sproduc%TYPE;
      vsseguro       seguros.sseguro%TYPE;
      vinteres       NUMBER;
      vfinipres      DATE;
      vffinpres      DATE;
      vfinicua       DATE;
      vnmesdur       NUMBER;
      vndias         NUMBER;
      vintdemora     NUMBER;
      vintdemoradia  NUMBER;
--      vcapdemora     NUMBER;
--      vcapint        NUMBER;
      vcapital       NUMBER;
      vsmovcuo       NUMBER;
--      vicapital      NUMBER;
      viinteres      NUMBER;
      videmora       NUMBER;
      visaldo        NUMBER;
      vnlinea        NUMBER := 1;
      vcappend       NUMBER;
      vsmovpres      NUMBER;
      vfalta         DATE;
      vrecalcular_cuadro NUMBER;
      vvfinicua      DATE;
      vicapital_yp   NUMBER;
      viinteres_yp   NUMBER;
      videmora_yp    NUMBER;
      vfpago_yp      DATE;
      vfdemoraini    DATE;
      pnf1cuota      DATE;
      vtotprestamo   NUMBER;
--
   BEGIN
      vpasexec := 1;

      ---- Desde funciones de cobro on-line externas el campo pfalta puede venir mal informado
      ---- por este motivo la recuperamos de prestamos
      SELECT p.falta, ps.finiprest, ps.ffinprest
        INTO vfalta, vfinipres, vffinpres
        FROM prestamos p, prestamoseg ps
       WHERE p.ctapres = pctapres
         AND p.ctapres = ps.ctapres;

      -- Cuadro de vencimiento de cuadro de armortizacion
      SELECT s.sproduc, s.sseguro
        INTO vsproduc, vsseguro
        FROM prestamoseg p, seguros s
       WHERE s.sseguro = p.sseguro
         AND p.ctapres = pctapres;

      v_cmonprod_t := pac_monedas.f_cmoneda_t(pcmoneda);
      v_cmonemp_n := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      v_cmonemp_t := pac_monedas.f_cmoneda_t(v_cmonemp_n);
      vfcambio := pac_eco_tipocambio.f_fecha_max_cambio(v_cmonprod_t, v_cmonemp_t, vfalta);

      IF vfcambio IS NULL THEN
         RETURN 9902592;
      -- No se ha encontrado el tipo de cambio entre monedas
      END IF;

      vitasa := pac_eco_tipocambio.f_cambio(v_cmonprod_t, v_cmonemp_t, vfcambio);
      vpasexec := 2;

      -- se verifica si el prestamo esta cancelado. 0 - No cancelado /1 - Sí cancelado
      IF (pac_prestamos.f_prestamo_cancelado(pctapres, pfalta, pfpago) = 1) THEN
         RETURN 9905029;
      END IF;

      vtotprestamo := pac_prestamos.f_get_totalpend(pctapres, vfalta, pfpago, vsseguro, NULL,
                                                    NULL, NULL);

      IF picapital > vtotprestamo THEN
         RETURN 9905031;
      END IF;

      SELECT   *
      BULK COLLECT INTO vcuadro
          FROM prestcuadro
         WHERE ctapres = pctapres
           AND ffincua IS NULL
           AND fpago IS NULL
      ORDER BY fvencim ASC;

      visaldo := picapital;
      ind := vcuadro.FIRST;
      vpasexec := 3;

      WHILE ind IS NOT NULL LOOP
         IF vcuadro(ind).fvencim = pfpago
            AND visaldo > 0 THEN
            --Pago cuando toca
            vpasexec := 31;
            vnumerr := f_impcuota_yapagada(pctapres, vcuadro(ind).finicua,
                                           vcuadro(ind).icappend, vcuadro(ind).norden,
                                           vicapital_yp, viinteres_yp, videmora_yp, vfpago_yp);

            IF vcuadro(ind).icapital - vicapital_yp + vcuadro(ind).iinteres - viinteres_yp <=
                                                                                       visaldo THEN
               vcapital := vcuadro(ind).icapital - vicapital_yp;
               viinteres := vcuadro(ind).iinteres - viinteres_yp;
            ELSE
               IF vcuadro(ind).iinteres <= visaldo THEN
                  viinteres := vcuadro(ind).iinteres;
                  vcapital := visaldo - viinteres;
               ELSE
                  viinteres := visaldo;
                  vcapital := 0;
               END IF;
            END IF;

            --cubrimos cuota, creamos pago
            vnumerr := f_ins_prestamocuotas(pctapres, vcuadro(ind).finicua,
                                            vcuadro(ind).icappend, vcuadro(ind).fvencim,
                                            pidpago, vnlinea, pfpago, vcapital, viinteres, 0,
                                            pcmoneda, f_round(vcapital * vitasa, v_cmonemp_n),
                                            f_round(viinteres * vitasa, v_cmonemp_n),
                                            vcuadro(ind).icappend_moncia, 0,
                                            vcuadro(ind).fcambio, vcuadro(ind).norden);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            vnumerr := pac_prestamos.f_mov_prestamocuota(pctapres, vcuadro(ind).finicua,
                                                         vcuadro(ind).icappend,
                                                         vcuadro(ind).fvencim, pidpago,
                                                         vnlinea, pfpago, 0, vsmovcuo);
            vnumerr := pac_prestamos.f_mov_prestamocuota(pctapres, vcuadro(ind).finicua,
                                                         vcuadro(ind).icappend,
                                                         vcuadro(ind).fvencim, pidpago,
                                                         vnlinea, pfpago, 1, vsmovcuo);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            vnlinea := vnlinea + 1;

            IF vcapital + vicapital_yp = vcuadro(ind).icapital THEN
               UPDATE prestcuadro
                  SET fpago = pfpago
                WHERE ctapres = pctapres
                  AND finicua = vcuadro(ind).finicua
                  AND icappend = vcuadro(ind).icappend;
            END IF;

            visaldo := visaldo - vcapital - viinteres;
         ELSIF vcuadro(ind).fvencim > pfpago
               AND visaldo > 0 THEN
            --Avanzamos capital
            -- Como pagamos antes de vencimiento recalculamos los interes
            vpasexec := 32;
            viinteres := 0;
            -----viinteres := pac_prestamos.f_calc_interesco_total(pctapres, pfalta,
            -----                                                  TRUNC(f_sysdate), vfinipres,
            -----                                                  vsseguro);
            viinteres := pac_prestamos.f_calc_interesco_cuota(pctapres, pfalta, pfpago,
                                                              vsseguro, vcuadro(ind).fefecto,
                                                              vcuadro(ind).fvencim,
                                                              vcuadro(ind).iinteres);
            vnumerr := f_impcuota_yapagada(pctapres, vcuadro(ind).finicua,
                                           vcuadro(ind).icappend, vcuadro(ind).norden,
                                           vicapital_yp, viinteres_yp, videmora_yp, vfpago_yp);

            IF vcuadro(ind).icapital - vicapital_yp + viinteres - viinteres_yp <= visaldo THEN
               vcapital := vcuadro(ind).icapital - vicapital_yp;

               IF vcuadro(ind).fefecto < pfpago THEN
                  viinteres := viinteres - viinteres_yp;
               ELSE
                  viinteres := 0;
               END IF;
            ELSE
               IF vcuadro(ind).fefecto < pfpago THEN
                  viinteres := viinteres - viinteres_yp;
               ELSE
                  viinteres := 0;
               END IF;

               vcapital := visaldo - viinteres;

               IF vcapital < 0 THEN
                  vcapital := 0;
                  viinteres := visaldo;
               END IF;
            END IF;

            --cubrimos cuota, creamos pago
            vnumerr := f_ins_prestamocuotas(pctapres, vcuadro(ind).finicua,
                                            vcuadro(ind).icappend, vcuadro(ind).fvencim,
                                            pidpago, vnlinea, pfpago, vcapital, viinteres, 0,
                                            pcmoneda, f_round(vcapital * vitasa, v_cmonemp_n),
                                            f_round(viinteres * vitasa, v_cmonemp_n),
                                            vcuadro(ind).icappend_moncia, 0,
                                            vcuadro(ind).fcambio, vcuadro(ind).norden);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            vnumerr := pac_prestamos.f_mov_prestamocuota(pctapres, vcuadro(ind).finicua,
                                                         vcuadro(ind).icappend,
                                                         vcuadro(ind).fvencim, pidpago,
                                                         vnlinea, pfpago, 0, vsmovcuo);
            vnumerr := pac_prestamos.f_mov_prestamocuota(pctapres, vcuadro(ind).finicua,
                                                         vcuadro(ind).icappend,
                                                         vcuadro(ind).fvencim, pidpago,
                                                         vnlinea, pfpago, 1, vsmovcuo);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            vnlinea := vnlinea + 1;

            IF vcapital + vicapital_yp = vcuadro(ind).icapital THEN
               UPDATE prestcuadro
                  SET fpago = pfpago
                WHERE ctapres = pctapres
                  AND finicua = vcuadro(ind).finicua
                  AND icappend = vcuadro(ind).icappend;
            END IF;

            visaldo := visaldo - vcapital - viinteres;

            ---se tendrá que recalcular el cuadro de amortización
            IF vcapital > 0 THEN
               vrecalcular_cuadro := 1;
            END IF;
         ELSIF vcuadro(ind).fvencim < pfpago
               AND visaldo > 0 THEN
               --Pago fuera de plazo
            --obtenemos el interes de demora.
            vpasexec := 33;
            vnumerr := f_impcuota_yapagada(pctapres, vcuadro(ind).finicua,
                                           vcuadro(ind).icappend, vcuadro(ind).norden,
                                           vicapital_yp, viinteres_yp, videmora_yp, vfpago_yp);

            IF vfpago_yp IS NOT NULL THEN
               SELECT GREATEST(vfpago_yp, vcuadro(ind).fvencim)
                 INTO vfdemoraini
                 FROM DUAL;
            ELSE
               vfdemoraini := vcuadro(ind).fvencim;
            END IF;

            vnumerr := pac_prestamos.f_calc_demora_cuota_prorr(pcmoneda,
                                                               vcuadro(ind).icapital
                                                               - vicapital_yp,
                                                               vfinipres, vcuadro(ind).fvencim,
                                                               vsseguro, vsproduc, pfpago,
                                                               videmora);
            --Como minimo cubrimos los intereses de demora, podremos realizar pago
            viinteres := vcuadro(ind).iinteres;
            vcapital := 0;

            IF vcuadro(ind).icapital + viinteres + videmora - viinteres_yp - vicapital_yp <=
                                                                                        visaldo THEN
               vcapital := vcuadro(ind).icapital - vicapital_yp;
               viinteres := viinteres - viinteres_yp;
            ELSE
               ----vrecalcular_cuadro := 1;
               viinteres := viinteres - viinteres_yp;
               vcapital := visaldo - viinteres - videmora;

               IF vcapital < 0 THEN
                  vcapital := 0;

                  IF videmora >= visaldo THEN
                     videmora := visaldo;
                     viinteres := 0;
                  ELSE
                     viinteres := visaldo - videmora;
                  END IF;
               END IF;
            END IF;

            vnumerr := f_ins_prestamocuotas(pctapres, vcuadro(ind).finicua,
                                            vcuadro(ind).icappend, vcuadro(ind).fvencim,
                                            pidpago, vnlinea, pfpago, vcapital, viinteres,
                                            videmora, pcmoneda,
                                            f_round(vcapital * vitasa, v_cmonemp_n),
                                            f_round(viinteres * vitasa, v_cmonemp_n),
                                            vcuadro(ind).icappend_moncia,
                                            f_round(videmora * vitasa, v_cmonemp_n),
                                            vcuadro(ind).fcambio, vcuadro(ind).norden);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            vnumerr := pac_prestamos.f_mov_prestamocuota(pctapres, vcuadro(ind).finicua,
                                                         vcuadro(ind).icappend,
                                                         vcuadro(ind).fvencim, pidpago,
                                                         vnlinea, pfpago, 0, vsmovcuo);
            vnumerr := pac_prestamos.f_mov_prestamocuota(pctapres, vcuadro(ind).finicua,
                                                         vcuadro(ind).icappend,
                                                         vcuadro(ind).fvencim, pidpago,
                                                         vnlinea, pfpago, 1, vsmovcuo);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            vnlinea := vnlinea + 1;

            IF vcapital + vicapital_yp = vcuadro(ind).icapital THEN
               UPDATE prestcuadro
                  SET fpago = pfpago
                WHERE ctapres = pctapres
                  AND finicua = vcuadro(ind).finicua
                  AND icappend = vcuadro(ind).icappend;
            END IF;

            visaldo := visaldo -(vcapital + viinteres + videmora);
         END IF;

         --Siguiente Registro
         ind := vcuadro.NEXT(ind);
      END LOOP;

      vpasexec := 4;

      IF visaldo > 0 THEN
         vnumerr := f_get_cuadro_pendiente(pctapres, vfalta, vprecua, 0);
         --Nos queda algo de saldo, generamos pago con el saldo, y
         --nuevo cuadro por el capital pendiente de la última cuota pagada.
         vpasexec := 5;
         vnumerr := f_ins_prestamocuotas(pctapres, vprecua.finicua, vprecua.icappend,
                                         vprecua.fvencim, pidpago, vnlinea, pfpago, visaldo,
                                         0, 0, pcmoneda,
                                         f_round(visaldo * vitasa, v_cmonemp_n), 0,
                                         vprecua.icappend_moncia, 0, vprecua.fcambio,
                                         vcuadro(ind).norden);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;

         vpasexec := 6;
         ----Las cuotas quedan pagadas
         vnumerr := pac_prestamos.f_mov_prestamocuota(pctapres, vprecua.finicua,
                                                      vprecua.icappend, pfpago, pidpago,
                                                      vnlinea, pfpago, 0, vsmovcuo);
         vnumerr := pac_prestamos.f_mov_prestamocuota(pctapres, vprecua.finicua,
                                                      vprecua.icappend, pfpago, pidpago,
                                                      vnlinea, pfpago, 1, vsmovcuo);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;

         vrecalcular_cuadro := 1;
      END IF;

      --calcular el capital que queda por cubrir
      SELECT SUM(capital_inicial) - SUM(capital_pagado)
        INTO visaldo
        FROM (SELECT SUM(icapital) capital_inicial, 0 capital_pagado
                FROM prestcuadro
               WHERE ctapres = pctapres
                 AND ffincua IS NULL
              UNION
              SELECT 0 capital_inicial, SUM(pc.icapital) capital_pagado
                FROM prestamocuotas pc, prestcuadro pr
               WHERE pc.ctapres = pctapres
                 AND pr.ctapres = pc.ctapres
                 AND pr.finicua = pc.finicua
                 AND pr.icappend = pc.icappend
                 AND pr.norden = pc.norden
                 AND pr.ffincua IS NULL);

      IF vrecalcular_cuadro = 1
         AND visaldo <> 0 THEN
         --calcular la duración del nuevo cuadro.
         --vfinicua: fecha efecto de la primera cuota del nuevo cuadro
         --vvfinicua: fecha inicio del cuadro vigente que sera sustituido
         SELECT MIN(fefecto), MIN(finicua)
           INTO vfinicua, vvfinicua
           FROM prestcuadro
          WHERE ctapres = pctapres
            AND ffincua IS NULL;

         IF pfpago > vfinicua THEN
            SELECT MIN(fefecto)
              INTO vfinicua
              FROM prestcuadro
             WHERE ctapres = pctapres
               AND fefecto >= pfpago;
         END IF;

         SELECT MAX(fefecto)
           INTO vffinpres
           FROM prestcuadro
          WHERE ctapres = pctapres
            AND ffincua IS NULL;

         IF vfinicua IS NULL THEN
            vfinicua := vffinpres;
         END IF;

         vpasexec := 8;

         SELECT fvencim
           INTO pnf1cuota
           FROM prestcuadro
          WHERE ctapres = pctapres
            AND falta = vfalta
            AND finicua = vvfinicua
            AND fefecto = vfinicua
            AND ffincua IS NULL;

         vpasexec := 85;

         --En primer lugar cerramos el cuadro antiguo
         UPDATE prestcuadro
            SET ffincua = pfpago
          WHERE ctapres = pctapres
            AND finicua = vvfinicua;

         vpasexec := 9;

         --Procedemos a crear el nuevo cuadro.
          --Obtenemos el interes del prestamo
         SELECT itasa
           INTO vinteres
           FROM prestamos
          WHERE ctapres = pctapres
            AND falta = vfalta;

         --Obtenemos el numero de cuotas del nuevo cuadro
         vnumerr := f_difdata(vfinicua, vffinpres, 1, 2, vnmesdur);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;

         --Creamos el nuevo cuadro
          --Se cambia la fecha de inicio del cuadro.
         vnumerr := pac_prestamos.f_ins_prestcuadro(pctapres, pfpago, NULL, vfalta, visaldo,
                                                    12, vinteres, pcmoneda, vnmesdur + 1,
                                                    pnf1cuota, pcempres);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END IF;

      vpasexec := 10;
      -- comprobar capital pendiente
      vcappend := NVL(pac_prestamos.f_get_cappend(pctapres, vfalta, pfpago), 0);
      vpasexec := 11;

      -- si no queda capital pendiente, darlo por abonado
      IF vcappend = 0 THEN
         --26981/0171128 - INI
            /*vnumerr := pac_prestamos.f_mov_prestamos(pctapres, vfalta, 4, TRUNC(f_sysdate),
                                                     vsmovpres);
                                                     */
         vnumerr := pac_prestamos.f_anulacion(pctapres, pcestado);

         --26981/0171128 - FIN
         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_insert_cuota;

   FUNCTION f_get_cappend(pctapres IN VARCHAR2, pfalta IN DATE, pfefecto IN DATE)
      RETURN NUMBER IS
      vimporte       NUMBER := 0;
      vicapital_yp   NUMBER := 0;
      viinteres_yp   NUMBER := 0;
      videmora_yp    NUMBER := 0;
      vfpago_yp      DATE;
      vnumerr        NUMBER := 0;
   BEGIN
      ----Calculamos el capital pendiente: se necesitan todo el capital y no tan sólo
      ----a partir de la fecha de pfefecto
      IF (pac_prestamos.f_prestamo_cancelado(pctapres, pfalta, pfefecto) = 1) THEN
         vimporte := 0;
      ELSE
         FOR reg IN (SELECT *
                       FROM prestcuadro
                      WHERE ctapres = pctapres
                        AND TRUNC(falta) = TRUNC(pfalta)
                        AND ffincua IS NULL
                        AND fpago IS NULL) LOOP
            vnumerr := pac_prestamos.f_impcuota_yapagada(pctapres, reg.finicua, reg.icappend,
                                                         reg.norden, vicapital_yp,
                                                         viinteres_yp, videmora_yp, vfpago_yp);
            vimporte := vimporte + reg.icapital - vicapital_yp;
         END LOOP;
      END IF;

      RETURN vimporte;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_get_cappend', 0,
                     'Error al calcular el capital pendiente', SQLERRM);
         RETURN 0;
   END f_get_cappend;

   FUNCTION f_calc_demora_cuota(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER,
      pintdiames IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vpintdem       NUMBER;
      vsproduc       productos.sproduc%TYPE;
      num_err        NUMBER;
      vndias         NUMBER;
      vintdemoradia  NUMBER;
      vintdemorames  NUMBER;
   BEGIN
      IF pfecha <= pfvencim THEN
         pidemora := 0;
      ELSE
         IF psproduc IS NULL THEN
            SELECT sproduc
              INTO vsproduc
              FROM seguros
             WHERE sseguro = psseguro;
         ELSE
            vsproduc := psproduc;
         END IF;

         --obtenemos porcentaje demora
         num_err := pac_prestamos.f_obtener_porcentaje(pfvencim, vsproduc, 2, vpintdem);
         -----num_err := pac_prestamos.f_obtener_porcentaje(NVL(pforigen, pfvencim), vsproduc, 2, vpintdem);
         num_err := f_difdata(pfvencim, pfecha, 1, 3, vndias);

         IF pintdiames = 1 THEN
            --calculamos el interes demora diario
            vintdemoradia := ((((POWER((1 +(vpintdem / 100)),(30 / 360)) - 1) * 12) * 100)
                              / 12) /(ADD_MONTHS(pfvencim, 1) - pfvencim);
                             ----/(ADD_MONTHS(pfvencim, 1) - pfvencim);
            --calculamos el capital de demora
            pidemora := NVL(f_round(picapital *((vintdemoradia / 100) * vndias), pcmoneda), 0);
         ELSE
            vintdemorames := POWER(1 + vpintdem / 100, 1 / 12) - 1;
            pidemora := NVL(f_round(picapital * vintdemorames * vndias
                                    /(ADD_MONTHS(pfvencim, 1) - pfvencim),
                                    pcmoneda),
                            0);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calc_demora_cuota', 0,
                     'Error al calcular intereses de demora', SQLERRM);
         RETURN 9902977;
   END f_calc_demora_cuota;

   FUNCTION f_calc_interes(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pinteres OUT NUMBER,
      pctapres IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpinteres      NUMBER;
      vsproduc       productos.sproduc%TYPE;
      num_err        NUMBER;
      vndias         NUMBER;
      vinteresdia    NUMBER;
   BEGIN
      --obtenemos procetaje de interes
      IF pfecha <= pforigen THEN
         pinteres := 0;
      ELSIF pctapres IS NOT NULL THEN
         SELECT itasa
           INTO vpinteres
           FROM prestamos
          WHERE ctapres = pctapres;

         IF vpinteres IS NULL THEN
            num_err := f_obtener_porcentaje(pforigen, vsproduc, 1, vpinteres);
         END IF;
      ELSE
         IF psproduc IS NULL THEN
            SELECT sproduc
              INTO vsproduc
              FROM seguros
             WHERE sseguro = psseguro;
         ELSE
            vsproduc := psproduc;
         END IF;

         num_err := f_obtener_porcentaje(pforigen, vsproduc, 1, vpinteres);
      END IF;

      num_err := f_difdata(pforigen, pfecha, 1, 3, vndias);
      --calculamos el interes diario
      vinteresdia := ((((POWER((1 +(vpinteres / 100)),(30 / 360)) - 1) * 12) * 100) / 12) / 30;
      --calculamos el interes
      pinteres := NVL(f_round(picapital *((vinteresdia / 100) * vndias), pcmoneda), 0);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calc_interes', 0,
                     'Error en el calculo de los intereses diarios', SQLERRM);
         RETURN 9902977;
   END f_calc_interes;

   /*************************************************************************
       f_mov_prestamocuota
       Funcion para insertar movimiento en las cuotas del prestamo
       param in pctapres      : Identificador del préstamo
       param in pfinicua     : Versión del cuadro
       param in picappend    : capital pendiente
       param in pfvencim        : Fecha vencimiento de la cuota
       param in pidpago     : identificador del pago
       param in pnlinea      : identificador de la linea
       param out psmovcuo    : Secuencia movimiento cuota
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamocuota(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappend IN NUMBER,
      pfvencim IN DATE,
      pidpago IN NUMBER,
      pnlinea IN NUMBER,
      pfmovini IN DATE,
      pcestcuo IN NUMBER,
      psmovcuo OUT NUMBER)
      RETURN NUMBER IS
      vfmovini       DATE;
      vsmovcuo_ant   NUMBER;
      vcestant       NUMBER;
   BEGIN
      SELECT smovcuo.NEXTVAL
        INTO psmovcuo
        FROM DUAL;

      IF pfmovini IS NULL THEN
         vfmovini := TRUNC(f_sysdate);
      ELSE
         vfmovini := pfmovini;
      END IF;

      SELECT MAX(smovcuo)
        INTO vsmovcuo_ant
        FROM prestamomovcuotas
       WHERE ctapres = pctapres
         AND finicua = pfinicua
         AND icappend = picappend
         AND fvencim = pfvencim
         AND idpago = pidpago
         AND nlinea = pnlinea;

      IF vsmovcuo_ant IS NULL THEN   --Es el primer movimiento
         vcestant := pcestcuo;
      ELSE
         SELECT cestcuo
           INTO vcestant
           FROM prestamomovcuotas
          WHERE smovcuo = vsmovcuo_ant;

         UPDATE prestamomovcuotas
            SET fmovfin = vfmovini
          WHERE smovcuo = vsmovcuo_ant;
      END IF;

      INSERT INTO prestamomovcuotas
                  (smovcuo, ctapres, finicua, icappend, fvencim, idpago, nlinea,
                   cusuari, cestcuo, cestant, fmovini, fmovfin, fmovdia)
           VALUES (psmovcuo, pctapres, pfinicua, picappend, pfvencim, pidpago, pnlinea,
                   f_user, pcestcuo, vcestant, vfmovini, NULL, f_sysdate);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_mov_prestamocuota', 0,
                     'Error al crear movimiento cuota prestamo', SQLERRM);
         RETURN 9903532;
   END f_mov_prestamocuota;

   /*************************************************************************
       f_mov_prestamopago
       Funcion para insertar movimiento en el pago del prestamo
       param in pctapres      : Identificador del préstamo
       param in pnpago     : Versión del cuadro
       param in pcestpag    : capital pendiente
       param in pcsubpag        : Fecha vencimiento de la cuota
       param in pfefecto     : identificador del pago
       param out pnmovpag    : Número de movimiento del pago
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamopago(
      pctapres IN VARCHAR2,
      pnpago IN NUMBER,
      pcestpag IN NUMBER,
      pcsubpag IN NUMBER,
      pfefecto IN DATE,
      pnmovpag OUT NUMBER)
      RETURN NUMBER IS
      vcestpagant    NUMBER;
      vcsubpagant    NUMBER;
   BEGIN
      SELECT NVL(MAX(nmovpag), 0)
        INTO pnmovpag
        FROM prestamomovpago
       WHERE ctapres = pctapres
         AND npago = pnpago;

      IF pnmovpag = 0 THEN   --Es el primer movimiento
         pnmovpag := 1;
         vcestpagant := NULL;
         vcsubpagant := NULL;
      ELSE   --obtenemos la situación anterior
         SELECT cestpag, csubpag
           INTO vcestpagant, vcsubpagant
           FROM prestamomovpago
          WHERE ctapres = pctapres
            AND npago = pnpago
            AND nmovpag = pnmovpag;

         -- modificar movimiento anterior
         -- fmovfin <-- fmovini del movimiento nuevo
         UPDATE prestamomovpago
            SET fmovfin = TRUNC(GREATEST(NVL(pfefecto, f_sysdate), f_sysdate))
          WHERE ctapres = pctapres
            AND npago = pnpago
            AND nmovpag = pnmovpag;

         pnmovpag := pnmovpag + 1;
      END IF;

      INSERT INTO prestamomovpago
                  (ctapres, npago, nmovpag, cestpag, fefepag, cestval, fcontab, sproces,
                   cestpagant, csubpag, csubpagant,
                   fmovini, fmovfin, fmovdia)
           VALUES (pctapres, pnpago, pnmovpag, pcestpag, pfefecto, 0, NULL, NULL,
                   vcestpagant, pcsubpag, vcsubpagant,
                   TRUNC(GREATEST(NVL(pfefecto, f_sysdate), f_sysdate)), NULL, f_sysdate);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_mov_prestamopago', 0,
                     'Error al crear movimiento pago de prestamo', SQLERRM);
         ROLLBACK;
         RETURN 9903534;
   END f_mov_prestamopago;

   /*************************************************************************
        FUNCTION f_verif_pago_recb
        Verifica para una póliza si hay recibos pendientes para realizar un prestamo
        param in psseguro   : código de la poliza
        return             : 0 y -1 para porder calcular el prestamo en caso contrario devolverá el código del literal de error
   *************************************************************************/
   FUNCTION f_verif_pago_recb(psseguro IN NUMBER)
      RETURN NUMBER IS
      vpintdem       NUMBER;
      vsproduc       productos.sproduc%TYPE;
      retorno        NUMBER;
      vnanualidad    seguros.nanuali%TYPE;
      vfcarpro       seguros.fcarpro%TYPE;
      vfcaranu       seguros.fcaranu%TYPE;
      num_recpend    NUMBER;
   BEGIN
      SELECT nanuali, fcarpro, fcaranu
        INTO vnanualidad, vfcarpro, vfcaranu
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT COUNT(*)
        INTO num_recpend
        FROM movrecibo r
       WHERE r.nrecibo IN(SELECT nrecibo
                            FROM recibos
                           WHERE sseguro = psseguro)
         AND NVL(f_cestrec(r.nrecibo, TRUNC(f_sysdate)), 0) = 0;

      IF (vfcarpro < vfcaranu)
         AND(vnanualidad = 1) THEN
         retorno := 9904110;
      ELSIF (vfcarpro = vfcaranu)
            AND(vnanualidad = 1)
            AND(num_recpend > 0) THEN
         retorno := 9904110;
      ELSIF (vnanualidad > 1)
            AND(num_recpend > 0) THEN
         retorno := -1;
      ELSIF (vnanualidad >= 1)
            AND(num_recpend = 0) THEN
         retorno := 0;
      END IF;

      RETURN retorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_verif_pago_recb', 0,
                     'Error al obtener recibos pendientes: ', SQLERRM);
         RETURN 9902977;
   END f_verif_pago_recb;

   FUNCTION f_get_totalpend(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfefecto IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pcmoneda IN NUMBER,
      pfiniprest IN DATE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 0;
      vparam         tab_error.tdescrip%TYPE
         := SUBSTR('pctapres=' || pctapres || ', pfalta=' || pfalta || ', pfefecto='
                   || pfefecto || ', psseguro=' || psseguro || ', psproduc=' || psproduc
                   || ', pcmoneda=' || pcmoneda || ', pfiniprest=' || pfiniprest,
                   1, 500);
      vobject        VARCHAR2(100) := 'PAC_PRESTAMOS.f_get_totalpend';
      vnumerr        NUMBER := 0;
      vsseguro       NUMBER;
      vsproduc       NUMBER;
      vcmoneda       NUMBER;
      vfiniprest     DATE;
      videmora       NUMBER;
      vitotalpend    NUMBER := 0;
      vcappend       NUMBER;
      vinteres       NUMBER;
      v_prestamo_cancelado NUMBER := 0;   -- Bug 24553 - MDS - 05/11/2011
      vicapital_yp   NUMBER := 0;
      viinteres_yp   NUMBER := 0;
      videmora_yp    NUMBER := 0;
      vfpago_yp      DATE;
   BEGIN
      vpasexec := 1;

      -- control de parámetros obligatorios, el resto son opcionales
      IF pctapres IS NULL
         OR pfalta IS NULL
         OR pfefecto IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'Parámetros obligatorios');
         RETURN 0;
      END IF;

      vpasexec := 2;

      -- cálculo de los parámetros opcionales, para el caso de no venir informados
      SELECT   ps.sseguro, se.sproduc, DECODE(pd.cdivisa, 3, 1, pd.cdivisa) cmoneda,
               ps.finiprest
          INTO vsseguro, vsproduc, vcmoneda,
               vfiniprest
          FROM prestamos pr, prestamoseg ps, seguros se, productos pd
         WHERE pr.ctapres = pctapres
           AND TRUNC(pr.falta) = TRUNC(pfalta)
           AND pr.ctapres = ps.ctapres
           AND ps.sseguro = se.sseguro
           AND se.sproduc = pd.sproduc
      GROUP BY ps.sseguro, se.sproduc, DECODE(pd.cdivisa, 3, 1, pd.cdivisa), ps.finiprest;

      -- si los parámetros opcionales vienen informados coger éstos, sinó coger los calculados
      vsseguro := NVL(psseguro, vsseguro);
      vsproduc := NVL(psproduc, vsproduc);
      vcmoneda := NVL(pcmoneda, vcmoneda);
      vfiniprest := NVL(pfiniprest, vfiniprest);
      vpasexec := 3;
      -- Saber si el préstamo está cancelado a fecha de inicio de cálculo de intereses
      v_prestamo_cancelado := pac_prestamos.f_prestamo_cancelado(pctapres, TRUNC(pfalta),
                                                                 TRUNC(pfefecto));

      FOR reg IN (SELECT *
                    FROM prestcuadro
                   WHERE ctapres = pctapres
                     AND TRUNC(falta) = TRUNC(pfalta)
                     AND ffincua IS NULL
                     AND fpago IS NULL) LOOP
         -- si lo está el interés es 0 sinó calculado
         IF v_prestamo_cancelado = 1 THEN
            videmora := 0;
         ELSE
            vnumerr := pac_prestamos.f_impcuota_yapagada(pctapres, reg.finicua, reg.icappend,
                                                         reg.norden, vicapital_yp,
                                                         viinteres_yp, videmora_yp, vfpago_yp);
            vnumerr := pac_prestamos.f_calc_demora_cuota_prorr(vcmoneda,
                                                               reg.icapital - vicapital_yp,
                                                               vfiniprest, reg.fvencim,
                                                               vsseguro, vsproduc, pfefecto,
                                                               videmora);
         END IF;

         vitotalpend := vitotalpend + reg.icapital - vicapital_yp + NVL(videmora, 0);
      END LOOP;

      vpasexec := 4;
      vcappend := pac_prestamos.f_get_cappend(pctapres, TRUNC(pfalta), TRUNC(pfefecto));
      vpasexec := 5;

      -- si lo está el interés es 0 sinó calculado
      IF v_prestamo_cancelado = 1 THEN
         vinteres := 0;
      ELSE
         vinteres := pac_prestamos.f_calc_interesco_total(pctapres, pfalta, TRUNC(f_sysdate),
                                                          vfiniprest, vsseguro);
      END IF;

      vpasexec := 6;

      IF v_prestamo_cancelado = 1 THEN
         vitotalpend := 0;
      ELSE
         vitotalpend := vitotalpend + NVL(vinteres, 0);
      END IF;

      RETURN vitotalpend;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 0;
   END f_get_totalpend;

   /*************************************************************************
       f_mov_prestamos
       Función para insertar un movimiento de préstamos
       param in  pctapres  : Identificador del préstamo
       param in  pfalta    : Fecha de alta del préstamo
       param in  pcestado  : Nuevo estado actual del préstamo
       param in  pfmovini  : Fecha inicio de vigencia del nuevo estado
       param out psmovpres : Secuencia del nuevo movimiento
       return              : 0 (todo OK)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamos(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pcestado IN NUMBER,
      pfmovini IN DATE,
      psmovpres OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vparam         tab_error.tdescrip%TYPE
         := SUBSTR('pctapres=' || pctapres || ', pfalta=' || pfalta || ', pcestado='
                   || pcestado || ', pfmovini=' || pfmovini,
                   1, 500);
      vsmovpres      NUMBER;   -- secuencia del movimiento anterior
      vcestado       NUMBER;   -- estado del movimiento anterior
   BEGIN
      vtraza := 1;

      -- obtener datos del movimiento anterior
      BEGIN
         SELECT smovpres, cestado
           INTO vsmovpres, vcestado
           FROM mov_prestamos
          WHERE ctapres = pctapres
            AND falta = pfalta
            AND fmovfin IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- no hay movimiento anterior, es el primero
            vsmovpres := 0;
            vcestado := 0;
      END;

      vtraza := 2;

      -- crear nuevo movimiento
      -- cestant <-- cestado del movimiento anterior
      SELECT mov_prestamos_seq.NEXTVAL
        INTO psmovpres
        FROM DUAL;

      INSERT INTO mov_prestamos
                  (smovpres, ctapres, falta, cestado, cestant, fmovini, fmovfin, cusuari,
                   fmovdia)
           VALUES (psmovpres, pctapres, pfalta, pcestado, vcestado, pfmovini, NULL, f_user,
                   f_sysdate);

      vtraza := 3;

      -- modificar movimiento anterior
      -- fmovfin <-- fmovini del movimiento nuevo
      IF vsmovpres <> 0 THEN
         UPDATE mov_prestamos
            SET fmovfin = pfmovini
          WHERE smovpres = vsmovpres;
      END IF;

      vtraza := 4;

      -- modificar el préstamo
      -- cestado <-- nuevo estado actual
      UPDATE prestamos
         SET cestado = pcestado
       WHERE ctapres = pctapres
         AND falta = pfalta;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_mov_prestamos', vtraza, vparam,
                     SQLERRM);
         ROLLBACK;
         RETURN 9904218;
   END f_mov_prestamos;

   /*************************************************************************
       f_autorizar
       Función para autorizar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfautoriza  : Fecha de autorización del préstamo
       param in  pnmovimi    : Número de movimiento
       param in  pffecpag    : Fecha de efecto del préstamo
       param in  picapital   : Capital del préstamo
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_autorizar(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfautoriza IN DATE,
      pnmovimi IN NUMBER,
      pffecpag IN DATE,
      picapital IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vparam         tab_error.tdescrip%TYPE
         := SUBSTR('pctapres=' || pctapres || ', pfalta=' || pfalta || ', pfautoriza='
                   || pfautoriza,
                   1, 500);
      vsmovpres      NUMBER;
      vnumerr        NUMBER := 0;
      vsseguro       NUMBER;
      vsproduc       NUMBER;
      vcmoneda       NUMBER;
      vcempres       NUMBER;
      verror         NUMBER;
      vterminal      VARCHAR2(20);
      perror         VARCHAR2(2000);
      vnmovpag       NUMBER;
      vfalta         DATE;
   BEGIN
      vtraza := 0;
      vnumerr := pac_prestamos.f_fecha_ult_prest(pctapres, vfalta);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      ---
      vtraza := 1;
      -- validar la información del préstamo
      vnumerr := f_validar(pctapres, vfalta, picapital, pfautoriza);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vtraza := 2;

      -- autorizar e insertar el préstamo, ya que todo previamente es OK
      -- obtener información del préstamo
      SELECT   DECODE(pd.cdivisa, 3, 1, pd.cdivisa) cmoneda, se.cempres
          INTO vcmoneda, vcempres
          FROM prestamos pr, prestamoseg ps, seguros se, productos pd
         WHERE pr.ctapres = pctapres
           AND TRUNC(pr.falta) = TRUNC(vfalta)
           AND pr.ctapres = ps.ctapres
           AND ps.sseguro = se.sseguro
           AND se.sproduc = pd.sproduc
      GROUP BY DECODE(pd.cdivisa, 3, 1, pd.cdivisa), se.cempres;

      vtraza := 3;
      -- crear movimiento del préstamo, autorizado=1
      vnumerr := f_mov_prestamos(pctapres, vfalta, 1, pfautoriza, vsmovpres);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vtraza := 4;
      -- insertar el préstamo
      vnumerr := pac_prestamos.f_insert_prestamospago(pctapres, pffecpag, picapital, vfalta,
                                                      vcmoneda, vcempres, 1);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vtraza := 5;

      -- pago del préstamo
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) = 1 THEN
         DECLARE
            vtipopago      NUMBER;
            vemitido       NUMBER;
            vsinterf       NUMBER;
         BEGIN
            vtipopago := 6;
            verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
            verror := pac_con.f_emision_pagorec(vcempres, 1, vtipopago, pctapres,
                                                NVL(pnmovimi, 1), vterminal, vemitido,
                                                vsinterf, perror, f_user, NULL, NULL, NULL, 1);

            IF verror <> 0
               OR TRIM(perror) IS NOT NULL THEN
               IF verror = 0 THEN
                  verror := 151323;
               END IF;

               p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_autorizar', vtraza, vparam,
                           perror || ' ' || verror);
               RETURN verror;
            ELSE
               verror := f_mov_prestamopago(pctapres, 1, 9, NULL, pffecpag, vnmovpag);

               IF verror <> 0 THEN
                  RETURN verror;
               END IF;
            END IF;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_autorizar', vtraza, vparam, SQLERRM);
         RETURN 9904220;
   END f_autorizar;

   /*************************************************************************
       f_validar
       Función para validar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  picapital   : Capital del préstamo
       param in  pfvalida    : Fecha de validación del préstamo
       param in  psseguro    : Identificador de seguro
       param in  pnriesgo    : Identificador de riesgo
       param in  pfiniprest  : Fecha de inicio del préstamo
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_validar(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      picapital IN NUMBER,
      pfvalida IN DATE,
      psseguro IN NUMBER DEFAULT NULL,
      pnriesgo IN NUMBER DEFAULT 1,
      pfiniprest IN DATE DEFAULT NULL,
      pmodo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 0;
      vparam         tab_error.tdescrip%TYPE;
      vobject        VARCHAR2(100) := 'PAC_PRESTAMOS.f_validar';
      vnumerr        NUMBER := 0;
      vivalres       NUMBER;
      vpcolchon      NUMBER;
      viotrospre     NUMBER := 0;
      vvalidarecib   NUMBER;
      vnum_recpend   NUMBER;
      ves_migracion  NUMBER;
      v_anuali       NUMBER;
      ves_primeranyo NUMBER;
      vfefecto       seguros.fefecto%TYPE;
      vsproduc       productos.sproduc%TYPE;
      vcempres       seguros.cempres%TYPE;
      vsperson       tomadores.sperson%TYPE;
      vsseguro       seguros.sseguro%TYPE;
      vnriesgo       prestamoseg.nriesgo%TYPE;
      vcmoneda       NUMBER;
      vfiniprest     DATE;
      vinteres       NUMBER;
      videmora       NUMBER;
      vcappend       NUMBER;
      v_prestamo_cancelado NUMBER := 0;   -- Bug 24553 - MDS - 05/11/2011
   BEGIN
      vpasexec := 1;

      -- obtener información del préstamo
      IF pctapres IS NOT NULL THEN
         SELECT   ps.sseguro, ps.nriesgo, DECODE(pd.cdivisa, 3, 1, pd.cdivisa), ps.finiprest
             INTO vsseguro, vnriesgo, vcmoneda, vfiniprest
             FROM prestamos pr, prestamoseg ps, seguros se, productos pd
            WHERE pr.ctapres = pctapres
              AND TRUNC(pr.falta) = TRUNC(pfalta)
              AND pr.ctapres = ps.ctapres
              AND ps.sseguro = se.sseguro
              AND se.sproduc = pd.sproduc
         GROUP BY ps.sseguro, ps.nriesgo, DECODE(pd.cdivisa, 3, 1, pd.cdivisa), ps.finiprest;

         vpasexec := 2;

         -- obtener información del seguro
         SELECT s.fefecto, s.sproduc, s.cempres, t.sperson, s.sseguro
           INTO vfefecto, vsproduc, vcempres, vsperson, vsseguro
           FROM seguros s, tomadores t
          WHERE t.sseguro = s.sseguro
            AND nordtom = 1
            AND s.sseguro = vsseguro;
      ELSE
         vpasexec := 21;
         -- obtener información del seguro
         vsseguro := psseguro;
         vnriesgo := pnriesgo;
         vfiniprest := NVL(pfiniprest, TRUNC(f_sysdate));

         SELECT s.fefecto, s.sproduc, s.cempres, t.sperson, s.sseguro,
                DECODE(pd.cdivisa, 3, 1, pd.cdivisa)
           INTO vfefecto, vsproduc, vcempres, vsperson, vsseguro,
                vcmoneda
           FROM seguros s, tomadores t, productos pd
          WHERE t.sseguro = s.sseguro
            AND nordtom = 1
            AND s.sseguro = vsseguro
            AND s.sproduc = pd.sproduc;
      END IF;

      vpasexec := 22;

      IF vfiniprest < vfefecto THEN
         IF pmodo = 1 THEN
            RETURN 0;
         END IF;

         RETURN 9902886;
      END IF;

      -- Primas pagades vs prestecs
      vvalidarecib := 0;
      vvalidarecib := f_verif_pago_recb(vsseguro);

      IF (vvalidarecib > 0) THEN
         RETURN vvalidarecib;
      END IF;

      vpasexec := 3;

      -- averiguar número de recibo pendientes
      SELECT COUNT(*)
        INTO vnum_recpend
        FROM movrecibo r
       WHERE r.nrecibo IN(SELECT nrecibo
                            FROM recibos
                           WHERE sseguro = vsseguro)
         AND NVL(f_cestrec(r.nrecibo, TRUNC(f_sysdate)), 0) = 0;

      vpasexec := 4;

      IF vnum_recpend = 0
                         -- NO hay recibo pendientes
      THEN
         vivalres := pac_provmat_formul.f_calcul_formulas_provi(vsseguro, TRUNC(f_sysdate),
                                                                'IPROVRES');
      ELSE
         vpasexec := 5;
            -- SI hay recibo pendientes
         -- averiguar si se trata de una póliza de migración
         vnumerr := pac_seguros.f_es_migracion(vsseguro, 'SEG', ves_migracion);

         IF vnumerr <> 0 THEN
            IF pmodo = 1 THEN
               RETURN 0;
            END IF;

            RETURN vnumerr;
         END IF;

         vpasexec := 6;

         -- averiguar si es el primer año en IAXIS
         SELECT MONTHS_BETWEEN(f_sysdate, MIN(finiefe)) / 12
           INTO v_anuali
           FROM garanseg
          WHERE sseguro = vsseguro
            AND nmovimi = 1;

         IF v_anuali < 1 THEN
            ves_primeranyo := 1;
         ELSE
            ves_primeranyo := 0;
         END IF;

         vpasexec := 7;

         -- calcular la provisión
         IF ves_primeranyo = 1
            AND ves_migracion = 1 THEN
            -- primer año en iaxis, y la póliza es de migración
            vivalres := pac_propio.f_calc_prov_migrada(vsseguro, vnriesgo);
         ELSIF ves_primeranyo = 1
               AND ves_migracion = 0 THEN
            -- primer año en iaxis, y la póliza NO es de migración
            -- no permitir el préstamo
            IF pmodo = 1 THEN
               RETURN 0;
            END IF;

            RETURN 9904110;
         ELSIF ves_primeranyo = 0 THEN
            -- NO es el primer año en iaxis, y tanto da si la póliza es de migración o no
            vivalres :=
               pac_provmat_formul.f_calcul_formulas_provi(vsseguro,
                                                          TO_DATE(frenovacion(NULL, vsseguro,
                                                                              2)
                                                                  - 1,
                                                                  'yyyymmdd'),
                                                          'IPROVRES');
         END IF;
      END IF;

      IF NVL(vivalres, 0) <= 0 THEN
         IF pmodo = 1 THEN
            RETURN 0;
         END IF;

         RETURN 9903485;
      END IF;

      vpasexec := 8;
      vivalres := f_round(vivalres, vcmoneda);
      --Validacion. valor solicitado+importes otros prestamos <  valor rescate + colchon.
      --Obtenemos % del colchón
      vpcolchon := pac_parametros.f_parproducto_n(vsproduc, 'COLCHON_PREST');

      IF NVL(vpcolchon, 0) <= 0 THEN
         IF pmodo = 1 THEN
            RETURN 0;
         END IF;

         RETURN 111866;
      END IF;

      vpasexec := 9;
      viotrospre := 0;

      FOR x IN (SELECT   p.ctapres, p.falta, ps.finiprest
                    FROM prestamos p, prestamoseg ps
                   WHERE ps.ctapres = p.ctapres
                     AND ps.falta = p.falta
                     AND p.cestado = 1
                     AND ps.sseguro = vsseguro
                ORDER BY p.ctapres) LOOP
         -- Saber si el préstamo está cancelado a fecha de inicio de cálculo de intereses
         v_prestamo_cancelado := pac_prestamos.f_prestamo_cancelado(x.ctapres, x.falta,
                                                                    TRUNC(pfvalida));

         FOR reg IN (SELECT *
                       FROM prestcuadro
                      WHERE ctapres = x.ctapres
                        AND falta = x.falta
                        AND ffincua IS NULL
                        AND fpago IS NULL) LOOP
            -- si lo está el interés es 0 sinó calculado
            IF v_prestamo_cancelado = 1 THEN
               videmora := 0;
            ELSE
               vnumerr := pac_prestamos.f_calc_demora_cuota_prorr(vcmoneda, reg.icapital,
                                                                  vfiniprest, reg.fvencim,
                                                                  vsseguro, vsproduc,
                                                                  TRUNC(pfvalida), videmora);
            END IF;

            viotrospre := viotrospre + reg.icapital + NVL(videmora, 0);
         END LOOP;

         vcappend := pac_prestamos.f_get_cappend(x.ctapres, x.falta, TRUNC(pfvalida));

         -- si lo está el interés es 0 sinó calculado
         IF v_prestamo_cancelado = 1 THEN
            vinteres := 0;
         ELSE
            vinteres := pac_prestamos.f_calc_interesco_total(pctapres, pfalta,
                                                             TRUNC(f_sysdate), pfiniprest,
                                                             psseguro);
         END IF;

         viotrospre := viotrospre + NVL(vinteres, 0);
      END LOOP;

      vpasexec := 10;

      -- En el modo 1 es para saber el importe máximo por el que podremos hacer el prestamo
      IF pmodo = 1 THEN
         RETURN f_round(vivalres *(vpcolchon / 100), vcmoneda) - NVL(viotrospre, 0);
      END IF;

      IF picapital + NVL(viotrospre, 0) > f_round(vivalres *(vpcolchon / 100), vcmoneda) THEN
         RETURN 9903510;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

         IF pmodo = 1 THEN
            RETURN 0;
         END IF;

         RETURN 1000455;   -- Error no controlado.
   END f_validar;

   /*************************************************************************
      f_calc_interesco_prestamo
      Función que calcula los Intereses causados corrientes de un préstamo
      param in  pctapres    : Identificador del préstamo
      param in  pfalta      : Fecha de alta del préstamo
      param in  pfvalida    : Fecha de inicio de cálculo de intereses
      param in  psseguro    : Identificador de seguro
      param in  pfiniprest  : Fecha de inicio del préstamo
      param in  pmodo       : 0-NO tener en cuenta los intereses si cancelado, 1-SI tener en cuenta los intereses si cancelado
      return                : Intereses
   *************************************************************************/
   FUNCTION f_calc_interesco_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfvalida IN DATE,
      psseguro IN NUMBER,
      pfiniprest IN DATE,
      pmodo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vsproduc       productos.sproduc%TYPE;
      vcmoneda       productos.cdivisa%TYPE;
      num_err        NUMBER;
      vndias         NUMBER;
      vpinteres      NUMBER;   -- porcentage del interés
      vpinteresdia   NUMBER;   -- porcentage del interés diario
      vcappend       NUMBER;   -- capital pendiente
      vintereses     NUMBER;   -- intereses
      v_prestamo_cancelado NUMBER := 0;   -- Bug 24553 - MDS - 05/11/2012
   BEGIN
      -- Saber si el préstamo está cancelado a fecha de inicio de cálculo de intereses
      v_prestamo_cancelado := pac_prestamos.f_prestamo_cancelado(pctapres, pfalta, pfvalida);

      -- la fecha de inicio del cálculo de intereses tiene que ser mayor que la de inicio del préstamo
      -- y el préstamo no estar cancelado,
      -- pero si está cancelado, si pmodo=1 tener en cuenta los intereses
      IF (pfvalida <= pfiniprest)
         OR((v_prestamo_cancelado = 1)
            AND(pmodo = 0)) THEN
         vintereses := 0;
      ELSE
         -- obtener información del seguro
         SELECT s.sproduc, DECODE(pd.cdivisa, 3, 1, pd.cdivisa)
           INTO vsproduc, vcmoneda
           FROM seguros s, productos pd
          WHERE s.sseguro = psseguro
            AND s.sproduc = pd.sproduc;

         -- cálculo del porcentaje del interés
         ---num_err := f_obtener_porcentaje(pfiniprest, vsproduc, 1, vpinteres);
         SELECT itasa
           INTO vpinteres
           FROM prestamos
          WHERE ctapres = pctapres;

         IF vpinteres IS NULL THEN
            num_err := f_obtener_porcentaje(pfiniprest, vsproduc, 1, vpinteres);
         END IF;

         num_err := f_difdata(pfiniprest, pfvalida, 1, 3, vndias);
         -- cálculo del porcentaje del interés diario
         vpinteresdia := ((((POWER((1 +(vpinteres / 100)),(30 / 360)) - 1) * 12) * 100) / 12)
                         / 30;
         -- cálculo del capital pendiente
         vcappend := pac_prestamos.f_get_cappend(pctapres, pfalta, pfvalida);
         -- calculamos los intereses
         vintereses := NVL(f_round(vcappend *((vpinteresdia / 100) * vndias), vcmoneda), 0);
      END IF;

      COMMIT;
      RETURN vintereses;
   EXCEPTION
      WHEN OTHERS THEN
         COMMIT;
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calc_interesco_prestamo', 0,
                     'Error en el cálculo de los intereses corrientes', SQLERRM);
         RETURN 0;
   END f_calc_interesco_prestamo;

   /*************************************************************************
      f_calc_interesdm_prestamo
      Función que calcula los Intereses causados de mora de un préstamo
      param in  pctapres    : Identificador del préstamo
      param in  pfalta      : Fecha de alta del préstamo
      param in  pfvalida    : Fecha de inicio de cálculo de intereses
      param in  psseguro    : Identificador de seguro
      param in  pfiniprest  : Fecha de inicio del préstamo
      param in  pmodo       : 0-NO tener en cuenta los intereses si cancelado, 1-SI tener en cuenta los intereses si cancelado
      return                : Intereses
   *************************************************************************/
   FUNCTION f_calc_interesdm_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfvalida IN DATE,
      psseguro IN NUMBER,
      pfiniprest IN DATE,
      pmodo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vsproduc       productos.sproduc%TYPE;
      vcmoneda       productos.cdivisa%TYPE;
      num_err        NUMBER;
      vndias         NUMBER;
      videmora       NUMBER;
      vintereses     NUMBER;   -- intereses de mora
      v_prestamo_cancelado NUMBER := 0;   -- Bug 24553 - MDS - 05/11/2012
      vicapital_yp   NUMBER;
      viinteres_yp   NUMBER;
      videmora_yp    NUMBER;
      vfpago_yp      DATE;
   BEGIN
      -- Saber si el préstamo está cancelado a fecha de inicio de cálculo de intereses
      v_prestamo_cancelado := pac_prestamos.f_prestamo_cancelado(pctapres, pfalta, pfvalida);

      -- la fecha de inicio del cálculo de intereses tiene que ser mayor que la de inicio del préstamo
      -- y el préstamo no estar cancelado,
      -- pero si está cancelado, si pmodo=1 tener en cuenta los intereses
      IF (pfvalida <= pfiniprest)
         OR((v_prestamo_cancelado = 1)
            AND(pmodo = 0)) THEN
         vintereses := 0;
      ELSE
         -- obtener información del seguro
         SELECT s.sproduc, DECODE(pd.cdivisa, 3, 1, pd.cdivisa)
           INTO vsproduc, vcmoneda
           FROM seguros s, productos pd
          WHERE s.sseguro = psseguro
            AND s.sproduc = pd.sproduc;

         -- calculamos los intereses
         vintereses := 0;

         FOR reg IN (SELECT *
                       FROM prestcuadro
                      WHERE ctapres = pctapres
                        AND falta = pfalta
                        AND ffincua IS NULL
                        AND fpago IS NULL) LOOP
            num_err := pac_prestamos.f_impcuota_yapagada(pctapres, reg.finicua, reg.icappend,
                                                         reg.norden, vicapital_yp,
                                                         viinteres_yp, videmora_yp, vfpago_yp);
            num_err := pac_prestamos.f_calc_demora_cuota_prorr(vcmoneda,
                                                               reg.icapital - vicapital_yp,
                                                               pfiniprest, reg.fvencim,
                                                               psseguro, vsproduc,
                                                               TRUNC(pfvalida), videmora);
            vintereses := vintereses + NVL(videmora, 0);
         END LOOP;
      END IF;

      COMMIT;
      RETURN vintereses;
   EXCEPTION
      WHEN OTHERS THEN
         COMMIT;
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calc_interesdm_prestamo', 0,
                     'Error en el cálculo de los intereses de mora', SQLERRM);
         RETURN 0;
   END f_calc_interesdm_prestamo;

   FUNCTION f_calcul_formulas_provi(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pcampo IN VARCHAR2,
      pcgarant IN NUMBER DEFAULT NULL,
      pndetgar IN NUMBER DEFAULT NULL,
      psituac IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vprovi         NUMBER;
   BEGIN
      vprovi := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, pcampo, pcgarant,
                                                           pndetgar, psituac);
      COMMIT;
      RETURN vprovi;
   EXCEPTION
      WHEN OTHERS THEN
         COMMIT;
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calcul_formulas_provi', 0,
                     'Error en el cálculo de las provisiones', SQLERRM);
         RETURN 0;
   END f_calcul_formulas_provi;

   /*************************************************************************
       f_reversar_prestamo
       Función para reversar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfrechaza   : Fecha de reversión del préstamo
       param in  pnmovimi    : Número de movimiento
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_reversar_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfrechaza IN DATE,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vparam         tab_error.tdescrip%TYPE
         := SUBSTR('pctapres=' || pctapres || ', pfalta=' || pfalta || ', pfrechaza='
                   || pfrechaza,
                   1, 500);
      vcestado       prestamos.cestado%TYPE;
      vcestpag       prestamomovpago.cestpag%TYPE;
      vcestpagant    prestamomovpago.cestpagant%TYPE;
      vsmovpres      NUMBER;
      vnmovpag       NUMBER;
      vnumerr        NUMBER := 0;
      vcempres       NUMBER;
      verror         NUMBER;
      vterminal      VARCHAR2(20);
      perror         VARCHAR2(2000);
      vfalta         DATE;
   BEGIN
      vtraza := 0;
      vnumerr := pac_prestamos.f_fecha_ult_prest(pctapres, vfalta);
      ---
      vtraza := 1;

      -- validar la información del préstamo
      SELECT cestado
        INTO vcestado
        FROM prestamos pr
       WHERE pr.ctapres = pctapres
         AND TRUNC(pr.falta) = TRUNC(vfalta);

      -- el préstamo tiene que estar 1-Autorizado para poder ser reversado
      IF vcestado <> 1 THEN
         RETURN 9904271;
      END IF;

      vtraza := 2;

      -- validar información del último movimiento del pago
      SELECT cestpag, cestpagant
        INTO vcestpag, vcestpagant
        FROM prestamomovpago pm
       WHERE pm.ctapres = pctapres
         AND pm.npago = 1
         AND pm.fmovfin IS NULL;

      -- el último movimiento del pago del préstamo tiene que estar 0-Pendiente,0-Pendiente para poder ser reversado
      IF NOT(vcestpag IN(0, 1, 9)
             AND(vcestpagant IN(0, 1, 9)
                 OR vcestpagant IS NULL)) THEN
         RETURN 9904271;
      END IF;

      vtraza := 3;
      -- reversar el préstamo, ya que todo previamente es OK
      -- crear primer movimiento del préstamo, pendiente=0
      vnumerr := f_mov_prestamos(pctapres, vfalta, 0, pfrechaza, vsmovpres);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vtraza := 4;
      -- crear segundo movimiento del préstamo, cancelado=2
      vnumerr := f_mov_prestamos(pctapres, vfalta, 2, pfrechaza, vsmovpres);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vtraza := 5;
      -- crear movimiento del pago, anulado=8
      -- pnpago   : 1
      -- pcestpag : 8 -> anulado
      -- pcsubpag : null
      vnumerr := f_mov_prestamopago(pctapres, 1, 8, NULL, pfrechaza, vnmovpag);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vtraza := 6;

      -- obtener información del préstamo
      SELECT   se.cempres
          INTO vcempres
          FROM prestamos pr, prestamoseg ps, seguros se, productos pd
         WHERE pr.ctapres = pctapres
           AND TRUNC(pr.falta) = TRUNC(vfalta)
           AND pr.ctapres = ps.ctapres
           AND ps.sseguro = se.sseguro
           AND se.sproduc = pd.sproduc
      GROUP BY se.cempres;

      -- rechazo del préstamo
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) = 1 THEN
         DECLARE
            vtipopago      NUMBER;
            vemitido       NUMBER;
            vsinterf       NUMBER;
         BEGIN
            vtraza := 8;
            -- rechazar el préstamo
            vtipopago := 6;
            verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
            verror := pac_con.f_emision_pagorec(vcempres, 1, vtipopago, pctapres,
                                                NVL(pnmovimi, 1), vterminal, vemitido,
                                                vsinterf, perror, f_user, NULL, NULL, NULL, 1);

            IF verror <> 0
               OR TRIM(perror) IS NOT NULL THEN
               IF verror = 0 THEN
                  verror := 151323;
               END IF;

               p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_reversar_prestamo', vtraza,
                           vparam, perror || ' ' || verror);
               RETURN verror;
            END IF;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_reversar_prestamo', vtraza, vparam,
                     SQLERRM);
         RETURN 9904270;
   END f_reversar_prestamo;

   /*************************************************************************
    Devuelve el importe total en prestamos de una poliza (para calcular la penalizacion de la reserva)
    *************************************************************************/
   FUNCTION f_get_totalprest(psesion IN NUMBER, psseguro IN NUMBER, pfefecto IN NUMBER)
      RETURN NUMBER IS
      xfecha         DATE;
      tot_prestamo   NUMBER;
      total          NUMBER;
      vparam         tab_error.tdescrip%TYPE
                                       := 'psseguro=' || psseguro || ', pfefecto=' || pfefecto;
   BEGIN
      total := 0;

      SELECT TO_DATE(pfefecto, 'YYYYMMDD')
        INTO xfecha
        FROM DUAL;

      FOR i IN (SELECT p.ctapres, p.falta
                  FROM prestamos p, prestamoseg ps, mov_prestamos mp
                 WHERE ps.ctapres = p.ctapres
                   AND mp.ctapres = p.ctapres
                   AND mp.fmovfin IS NULL
                   AND mp.cestado = 1
                   AND ps.sseguro = psseguro) LOOP
         tot_prestamo := pac_prestamos.f_get_totalpend(i.ctapres, i.falta, xfecha, psseguro,
                                                       NULL, NULL, NULL);
         total := total + NVL(tot_prestamo, 0);
      END LOOP;

      RETURN total;
   END f_get_totalprest;

   FUNCTION f_permite_reversar(pctapres IN VARCHAR2, psepermite OUT NUMBER)
      RETURN NUMBER IS
      vcestado       prestamos.cestado%TYPE;
      vcestpag       prestamomovpago.cestpag%TYPE;
      vcestpagant    prestamomovpago.cestpagant%TYPE;
      vparam         tab_error.tdescrip%TYPE := 'pctapres= ' || pctapres;
      vtraza         NUMBER := 0;
   BEGIN
      vtraza := 1;
      psepermite := 0;

      IF pctapres IS NOT NULL THEN
         SELECT p.cestado
           INTO vcestado
           FROM prestamos p, prestamoseg ps
          WHERE p.ctapres = pctapres
            AND p.ctapres = ps.ctapres;

         IF vcestado = 1 THEN
            vtraza := 2;

            SELECT cestpag, cestpagant
              INTO vcestpag, vcestpagant
              FROM prestamomovpago
             WHERE ctapres = pctapres
               AND fmovfin IS NULL;

            -- el último movimiento del pago del préstamo tiene que estar 0-Pendiente,0-Pendiente para poder ser reversado
            IF NOT(vcestpag IN(0, 1, 9)
                   AND(vcestpagant IN(0, 1, 9)
                       OR vcestpagant IS NULL)) THEN
               RETURN 9904271;
            END IF;

            IF vcestpag IN(0, 1, 9) THEN
               psepermite := 1;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_permite_reversar', vtraza, vparam,
                     SQLERRM);
         RETURN 9904270;
   END f_permite_reversar;

   /*
     pmodo    :  modo : 1-Previo, sinó Real
     pmoneda  :  parámetro no necesario
     pcidioma :  idioma
     pfperini :  parámetro no necesario
     pfperfin :  fecha de vigencia de los préstamos
     pfcierre :  fecha de cálculo de capital pendiente, intereses y contravalores
     pcerror  :  error : 0-OK, 1-OK
     psproces :  código de proceso
     pfproces :  fecha del proceso
   */
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,   -- parámetro no necesario, utilizar la moneda de la póliza
      pcidioma IN NUMBER,
      pfperini IN DATE,   -- parámetro no necesario
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      --
      --    Proceso que lanzará el proceso de cierre de préstamos
      --
      num_err        NUMBER := 0;
      pnnumlin       NUMBER;
      conta_err      NUMBER := 0;
      v_titulo       VARCHAR2(50);
      vtraza         NUMBER := 0;
      vfcambio       DATE;
      vitasa         NUMBER;
      vcmoncon       parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');   -- moneda contable (numérico)
      vcmoncon_t     monedas.cmonint%TYPE := pac_monedas.f_cmoneda_t(vcmoncon);   -- moneda contable (texto)

      -- cursor de préstamos vigentes a fecha pfperfin
      CURSOR c_prestamos_cierre IS
         SELECT   pr.ctapres ctapres, TRUNC(pr.falta) falta, ps.sseguro, pr.cdivisa cmoneda,
                  pac_monedas.f_cmoneda_t(pr.cdivisa) cmoneda_t,
                  pac_prestamos.f_get_cappend(pr.ctapres, TRUNC(pr.falta),
                                              TRUNC(pfcierre)) capital,   -- Capital pendiente
                  pac_prestamos.f_calc_interesco_prestamo(pr.ctapres,
                                                          TRUNC(pr.falta),
                                                          TRUNC(pfcierre),
                                                          ps.sseguro,
                                                          TRUNC(ps.finiprest)) intcorrientes,   -- Intereses corrientes
                  pac_prestamos.f_calc_interesdm_prestamo(pr.ctapres,
                                                          TRUNC(pr.falta),
                                                          TRUNC(pfcierre),
                                                          ps.sseguro,
                                                          TRUNC(ps.finiprest)) intdemora   -- Intereses de mora
             FROM seguros s, productos pr, prestamoseg ps, prestamos pr, mov_prestamos mp
            WHERE s.cempres = NVL(pcempres, s.cempres)
              AND s.sseguro = ps.sseguro
              AND s.sproduc = pr.sproduc
              AND ps.ctapres = pr.ctapres
              AND TRUNC(ps.falta) = TRUNC(pr.falta)
              AND mp.ctapres = pr.ctapres
              AND TRUNC(mp.falta) = TRUNC(pr.falta)
              AND mp.cestado = 1
              AND TRUNC(mp.fmovini) <= TRUNC(pfperfin)
              AND(mp.fmovfin IS NULL
                  OR TRUNC(mp.fmovfin) > TRUNC(pfperfin))
         GROUP BY pr.ctapres, TRUNC(pr.falta), ps.sseguro, pr.cdivisa,
                  pac_monedas.f_cmoneda_t(pr.cdivisa), TRUNC(ps.finiprest);
   BEGIN
      v_titulo := 'Proceso de cierre de préstamos';
      vtraza := 1;
      -- Marcar inicio en la tabla PROCESOSCAB
      num_err := f_procesini(f_user, pcempres, 'CIERRE PRESTAMOS', v_titulo, psproces);
      vtraza := 2;

      IF num_err <> 0 THEN
         -- ha habido algún error en el marcaje del inicio del proceso
         vtraza := 3;
         pcerror := 1;
         conta_err := conta_err + 1;
         pnnumlin := NULL;
         num_err := f_proceslin(psproces,
                                SUBSTR('Cierre préstamos '
                                       || f_axis_literales(num_err, pcidioma),
                                       1, 120),
                                0, pnnumlin);
      ELSE
         vtraza := 4;
         pcerror := 0;

         -- Inicio del proceso
         -- borrado de las tablas
         IF pmodo = 1 THEN
            -- modo Previo
            DELETE FROM cierre_prestamos_previo cp
                  WHERE cp.fcalcul = pfperfin
                    AND cp.cempres = pcempres;
         ELSE
            -- modo Real
            DELETE FROM cierre_prestamos cp
                  WHERE cp.fcalcul = pfperfin
                    AND cp.cempres = pcempres;
         END IF;

         vtraza := 5;

         -- inserción de los registros
         FOR reg IN c_prestamos_cierre LOOP
            BEGIN
               vtraza := 6;

               -- cálculo de campos para contravalores
               --
               IF reg.cmoneda = vcmoncon THEN
                  -- la moneda contable es la misma que la del préstamo
                  vfcambio := pfcierre;
                  vitasa := 1;
               ELSE
                  -- la moneda contable es diferente a la del préstamo
                  vfcambio := pac_eco_tipocambio.f_fecha_max_cambio(reg.cmoneda_t, vcmoncon_t,
                                                                    pfcierre);

                  IF vfcambio IS NULL THEN
                     pcerror := 1;
                     conta_err := conta_err + 1;
                     pnnumlin := NULL;
                     num_err := f_proceslin(psproces,
                                            'Cierre préstamos ('
                                            || f_axis_literales(9902592, pcidioma) || ')',
                                            reg.sseguro, pnnumlin);
                  END IF;

                  vitasa := pac_eco_tipocambio.f_cambio(reg.cmoneda_t, vcmoncon_t, vfcambio);
               END IF;

               vtraza := 7;

               -- insert del registro
               --
               IF pmodo = 1 THEN
                  -- modo Previo
                  INSERT INTO cierre_prestamos_previo
                              (cempres, sproces, ctapres, falta, fcalcul,
                               sseguro, finteres, icapital,
                               icapital_moncon,
                               iintres,
                               iintres_moncon,
                               idemora,
                               idemora_moncon,
                               cmoneda, fcambio)
                       VALUES (pcempres, psproces, reg.ctapres, reg.falta, pfperfin,
                               reg.sseguro, pfcierre, reg.capital,
                               f_round(f_round(reg.capital, reg.cmoneda) * vitasa, vcmoncon),
                               reg.intcorrientes,
                               f_round(f_round(reg.intcorrientes, reg.cmoneda) * vitasa,
                                       vcmoncon),
                               reg.intdemora,
                               f_round(f_round(reg.intdemora, reg.cmoneda) * vitasa, vcmoncon),
                               reg.cmoneda, vfcambio);
               ELSE
                  -- modo Real
                  INSERT INTO cierre_prestamos
                              (cempres, sproces, ctapres, falta, fcalcul,
                               sseguro, finteres, icapital,
                               icapital_moncon,
                               iintres,
                               iintres_moncon,
                               idemora,
                               idemora_moncon,
                               cmoneda, fcambio)
                       VALUES (pcempres, psproces, reg.ctapres, reg.falta, pfperfin,
                               reg.sseguro, pfcierre, reg.capital,
                               f_round(f_round(reg.capital, reg.cmoneda) * vitasa, vcmoncon),
                               reg.intcorrientes,
                               f_round(f_round(reg.intcorrientes, reg.cmoneda) * vitasa,
                                       vcmoncon),
                               reg.intdemora,
                               f_round(f_round(reg.intdemora, reg.cmoneda) * vitasa, vcmoncon),
                               reg.cmoneda, vfcambio);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  pcerror := 1;
                  conta_err := conta_err + 1;
                  pnnumlin := NULL;
                  -- 22.0 - 11/10/2013 - MMM - 0028361: LCOL_F003-0009343: CIERRE DE PRESTAMOS NO TERMINARON - Inicio
                  --num_err := f_proceslin(psproces, 'Cierre préstamos (pmodo=' || pmodo || ')',
                  --                       reg.sseguro, pnnumlin);
                  num_err := f_proceslin(psproces,
                                         'Cierre préstamos (pmodo=' || pmodo || ') '
                                         || SQLERRM,
                                         reg.sseguro, pnnumlin);
            -- 22.0 - 11/10/2013 - MMM - 0028361: LCOL_F003-0009343: CIERRE DE PRESTAMOS NO TERMINARON - Fin
            END;
         END LOOP;
      END IF;

      vtraza := 8;
      -- 22.0 - 11/10/2013 - MMM - 0028361: LCOL_F003-0009343: CIERRE DE PRESTAMOS NO TERMINARON - Inicio
      -- Hacemos que el pcerror sea OK para que pueda acabar
      pcerror := 0;

      -- 22.0 - 11/10/2013 - MMM - 0028361: LCOL_F003-0009343: CIERRE DE PRESTAMOS NO TERMINARON - Fin

      -- control de errores
      IF pcerror = 0 THEN
         -- todo OK
         COMMIT;
      ELSE
         -- algún error
         ROLLBACK;
      END IF;

      vtraza := 7;
      -- Marcar fin en la tabla PROCESOSCAB
      num_err := f_procesfin(psproces, conta_err);
      pfproces := f_sysdate;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'CIERRE PRESTAMOS PROCESO =' || psproces, vtraza,
                     'when others del cierre =' || pfperfin, SQLERRM);
         pcerror := 1;
         pfproces := f_sysdate;
   END proceso_batch_cierre;

   /*************************************************************************
      f_prestamo_cancelado
      Función que indica si un préstamo está cancelado o no
      param in  pctapres    : Identificador del préstamo
      param in  pfalta      : Fecha de alta del préstamo
      param in  pfvalida    : Fecha de validación (inicio de cálculo de intereses)
      return                : 0 - No cancelado
                              1 - Sí cancelado
   *************************************************************************/
   FUNCTION f_prestamo_cancelado(pctapres IN VARCHAR2, pfalta IN DATE, pfvalida IN DATE)
      RETURN NUMBER IS
      v_prestamo_cancelado NUMBER := 0;
   BEGIN
      SELECT COUNT(1)
        INTO v_prestamo_cancelado
        FROM mov_prestamos
       WHERE ctapres = pctapres
         AND falta = pfalta
         AND cestado IN(2, 5)
         AND fmovini <= pfvalida
         AND(fmovfin IS NULL
             OR pfvalida < fmovfin);

      IF v_prestamo_cancelado > 0 THEN
         v_prestamo_cancelado := 1;
      END IF;

      RETURN v_prestamo_cancelado;
   END f_prestamo_cancelado;

   FUNCTION f_impcuota_yapagada(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappend IN NUMBER,
      pnorden IN NUMBER,
      picapital OUT NUMBER,
      piinteres OUT NUMBER,
      pidemora OUT NUMBER,
      pfpago OUT DATE)
      RETURN NUMBER IS
      vparam         tab_error.tdescrip%TYPE := 'pctapres= ' || pctapres;
      vtraza         NUMBER := 0;
   BEGIN
      SELECT NVL(SUM(icapital), 0), NVL(SUM(iinteres), 0), NVL(SUM(idemora), 0), MAX(fpago)
        INTO picapital, piinteres, pidemora, pfpago
        FROM prestamocuotas
       WHERE ctapres = pctapres
         AND finicua = pfinicua
         AND icappend = picappend
         AND norden = pnorden;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_impcuota_yapagada', vtraza, vparam,
                     SQLERRM);
         picapital := 0;
         piinteres := 0;
         pidemora := 0;
         RETURN 9904787;
   END f_impcuota_yapagada;

   FUNCTION f_calc_interesco_cuota(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfvalida IN DATE,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      pinterestot IN NUMBER,
      pmodo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vsproduc       productos.sproduc%TYPE;
      vcmoneda       productos.cdivisa%TYPE;
      num_err        NUMBER;
      vndias         NUMBER;
      vndias_tot     NUMBER;
      vndias_per     NUMBER;
      videmora       NUMBER;
      vintereses     NUMBER;
      vintereses_dia DATE;
      v_prestamo_cancelado NUMBER := 0;
   BEGIN
      v_prestamo_cancelado := pac_prestamos.f_prestamo_cancelado(pctapres, pfalta, pfvalida);

      IF (pfvalida <= pfefecto)
         OR((v_prestamo_cancelado = 1)
            AND(pmodo = 0)) THEN
         vintereses := 0;
      ELSE
         -- obtener información del seguro
         SELECT s.sproduc, DECODE(pd.cdivisa, 3, 1, pd.cdivisa)
           INTO vsproduc, vcmoneda
           FROM seguros s, productos pd
          WHERE s.sseguro = psseguro
            AND s.sproduc = pd.sproduc;

         -- calculamos los intereses
         num_err := f_difdata(pfefecto, pfvalida, 1, 3, vndias);
         num_err := f_difdata(pfefecto, pfvencim, 1, 3, vndias_tot);
         vintereses := f_round(pinterestot * vndias / vndias_tot, vcmoneda);
      END IF;

      COMMIT;
      RETURN vintereses;
   EXCEPTION
      WHEN OTHERS THEN
         COMMIT;
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calc_interesdm_prestamo', 0,
                     'Error en el cálculo de los intereses corrientes', SQLERRM);
         RETURN 0;
   END f_calc_interesco_cuota;

   --
   FUNCTION f_calc_interesco_total(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfvalida IN DATE,
      pfiniprest IN DATE,
      psseguro IN NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      vsproduc       productos.sproduc%TYPE;
      vcmoneda       productos.cdivisa%TYPE;
      num_err        NUMBER;
      vndias         NUMBER;
      vndias_per     NUMBER;
      videmora       NUMBER;
      vintereses_cuota NUMBER;
      vintereses_total NUMBER;
      v_prestamo_cancelado NUMBER := 0;

      TYPE tcuadro IS TABLE OF prestcuadro%ROWTYPE;

      vcuadro        tcuadro;
      i              NUMBER;
      vpasexec       NUMBER;
      vnumerr        NUMBER := 0;
      vicapital_yp   NUMBER;
      viinteres_yp   NUMBER;
      videmora_yp    NUMBER;
      vfpago_yp      DATE;
      vmodo          NUMBER := 0;
      vinteres_cuota NUMBER;
   BEGIN
      v_prestamo_cancelado := pac_prestamos.f_prestamo_cancelado(pctapres, pfalta, pfvalida);

      IF (pfvalida <= pfiniprest)
         OR((v_prestamo_cancelado = 1)
            AND(vmodo = 0)) THEN
         vintereses_total := 0;
      ELSE
         -- obtener información del seguro
         SELECT s.sproduc, DECODE(pd.cdivisa, 3, 1, pd.cdivisa)
           INTO vsproduc, vcmoneda
           FROM seguros s, productos pd
          WHERE s.sseguro = psseguro
            AND s.sproduc = pd.sproduc;

         vintereses_total := 0;

         SELECT   *
         BULK COLLECT INTO vcuadro
             FROM prestcuadro
            WHERE ctapres = pctapres
              AND ffincua IS NULL
              AND fpago IS NULL
         ORDER BY fvencim ASC;

         -- visaldo := picapital;
         i := vcuadro.FIRST;
         vpasexec := 3;

         WHILE i IS NOT NULL LOOP
            vnumerr := f_impcuota_yapagada(pctapres, vcuadro(i).finicua, vcuadro(i).icappend,
                                           vcuadro(i).norden, vicapital_yp, viinteres_yp,
                                           videmora_yp, vfpago_yp);

            IF vcuadro(i).fvencim <= pfvalida THEN
               vintereses_cuota := vcuadro(i).iinteres - viinteres_yp;
            ELSIF vcuadro(i).fefecto >= pfvalida THEN
               vintereses_cuota := 0;
            ELSE
               vintereses_cuota := f_calc_interesco_cuota(pctapres, pfalta, pfvalida,
                                                          psseguro, vcuadro(i).fefecto,
                                                          vcuadro(i).fvencim,
                                                          vcuadro(i).iinteres);
               vinteres_cuota := vinteres_cuota - viinteres_yp;
            END IF;

            vintereses_total := vintereses_total + vintereses_cuota;
            --Siguiente Registro
            i := vcuadro.NEXT(i);
         END LOOP;
      END IF;

      RETURN vintereses_total;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calc_interesdm_prestamo', 0,
                     'Error en el cálculo de los intereses de mora', SQLERRM);
         RETURN 0;
   END f_calc_interesco_total;

   FUNCTION f_calc_demora_cuota_prorr(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER)
      RETURN NUMBER IS
      vsproduc       productos.sproduc%TYPE;
      num_err        NUMBER;
      videmora_par   NUMBER;
      videmora_per   NUMBER;
      vffinperiodo   DATE;
      vfiniperiodo   DATE;
      vfcota_per     DATE;
      vfcota_per2    DATE;
   BEGIN
      IF pfecha <= pfvencim THEN
         pidemora := 0;
      ELSE
         IF psproduc IS NULL THEN
            SELECT sproduc
              INTO vsproduc
              FROM seguros
             WHERE sseguro = psseguro;
         ELSE
            vsproduc := psproduc;
         END IF;

         vfiniperiodo := pfvencim;
         vffinperiodo := ADD_MONTHS(vfiniperiodo, 1);
         pidemora := 0;

         LOOP
            SELECT LEAST(LAST_DAY(vfiniperiodo), pfecha)
              INTO vfcota_per
              FROM DUAL;

            num_err := pac_prestamos.f_calc_demora_cuota(pcmoneda, picapital, vfiniperiodo,
                                                         vfiniperiodo, psseguro, psproduc,
                                                         vfcota_per, videmora_per);
              ----                                           vffinperiodo, videmora_per);
            ----videmora_par := videmora_per /(vffinperiodo - vfiniperiodo)
            ----                *(vfcota_per - vfiniperiodo);
            ----pidemora := pidemora + f_round(videmora_par, pcmoneda);
            pidemora := pidemora + videmora_per;

            IF vfcota_per < pfecha THEN
               SELECT LEAST(vffinperiodo, pfecha)
                 INTO vfcota_per2
                 FROM DUAL;

               num_err := pac_prestamos.f_calc_demora_cuota(pcmoneda, picapital,
                                                            vfcota_per + 1, vfcota_per + 1,
                                                            psseguro, psproduc,
                                                            vfcota_per2 + 1, videmora_per);
               ----videmora_par := videmora_per /(ADD_MONTHS(vfcota_per, 1) - vfcota_per)
               ----                *(vfcota_per2 - vfcota_per);
               pidemora := pidemora + f_round(videmora_per, pcmoneda);
            END IF;

            vfiniperiodo := vffinperiodo;
            vffinperiodo := ADD_MONTHS(vfiniperiodo, 1);
            EXIT WHEN vfiniperiodo >= pfecha
                  OR num_err <> 0;
         END LOOP;

         IF num_err <> 0 THEN
            pidemora := 0;
            p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calc_demora_cuota_prorr', 0,
                        'Error al calcular intereses de demora: ' || num_err, NULL);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_calc_demora_cuota_prorr', 0,
                     'Error al calcular intereses de demora', SQLERRM);
         RETURN 9902977;
   END f_calc_demora_cuota_prorr;

   FUNCTION f_impcuota_yapagada_moncia(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappend IN NUMBER,
      pnorden IN NUMBER,
      picapital OUT NUMBER,
      piinteres OUT NUMBER,
      pidemora OUT NUMBER,
      pfpago OUT DATE)
      RETURN NUMBER IS
      vparam         tab_error.tdescrip%TYPE := 'pctapres= ' || pctapres;
      vtraza         NUMBER := 0;
   BEGIN
      SELECT NVL(SUM(icapital_moncia), 0), NVL(SUM(iinteres_moncia), 0),
             NVL(SUM(idemora_moncia), 0), MAX(fpago)
        INTO picapital, piinteres,
             pidemora, pfpago
        FROM prestamocuotas
       WHERE ctapres = pctapres
         AND finicua = pfinicua
         AND icappend = picappend
         AND norden = pnorden;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PRESTAMOS.f_impcuota_yapagada', vtraza, vparam,
                     SQLERRM);
         picapital := 0;
         piinteres := 0;
         pidemora := 0;
         RETURN 9904787;
   END f_impcuota_yapagada_moncia;
END pac_prestamos;

/

  GRANT EXECUTE ON "AXIS"."PAC_PRESTAMOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTAMOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTAMOS" TO "PROGRAMADORESCSI";
