--------------------------------------------------------
--  DDL for Package Body PAC_MERITA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MERITA" IS

vg_nmesven	NUMBER;
vg_nanyven	NUMBER;

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
FUNCTION f_anulacio_sense_efecte(pfefecto IN DATE, pfanulac IN DATE, pnrecibo IN NUMBER,
                                 pnperven IN NUMBER, pfmovdia_anula IN DATE , pfcierre IN DATE,
                                 pfcierre_ant IN DATE, panyven IN NUMBER, pmesven IN NUMBER)
         RETURN NUMBER IS
--------------------------------------------------------------------------------------
-- Retorna 1 si la anulacio és sense efecte i en el mateix periode de meritació
--------------------------------------------------------------------------------------
l_anulacio_sense_efecte NUMBER;
l_fmovdia DATE;
BEGIN

   IF pfmovdia_anula IS NULL THEN
      -- Busquem si existeix el moviment d'anulació
      BEGIN
         SELECT TRUNC(fmovdia) INTO l_fmovdia
         FROM MOVRECIBO
         WHERE nrecibo = pnrecibo
           AND cestrec = 2
           AND fmovfin IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_fmovdia := NULL;
         WHEN OTHERS THEN
            l_fmovdia := NULL;
      END;
   ELSE
      l_fmovdia := pfmovdia_anula;
   END IF;

   IF l_fmovdia IS NULL THEN
      l_anulacio_sense_efecte := 0;
   ELSE
      IF pfefecto = NVL(pfanulac, pfefecto-1) THEN
         IF pnperven = TO_NUMBER(panyven||LPAD(pmesven,2,'0')) AND
            l_fmovdia > pfcierre_ant AND l_fmovdia <= pfcierre THEN
            l_anulacio_sense_efecte := 1;
         ELSE
            l_anulacio_sense_efecte := 0;
         END IF;
      ELSE
         l_anulacio_sense_efecte := 0;
      END IF;
   END IF;

   RETURN l_anulacio_sense_efecte;
END f_anulacio_sense_efecte;

--------------------------------------------------------------------------------------
FUNCTION f_rebut_meritat(pcempres IN NUMBER, pnrecibo IN NUMBER,pmeritat OUT NUMBER)
           RETURN NUMBER IS
--------------------------------------------------------------------------------------
/* Retorna pmeritat = 1 si el rebut ha estat meritat
                    = 0 si el rebut no ha estat meritat */

  l_fcierre DATE;
  l_nperven NUMBER(6);

BEGIN

  BEGIN
     -- Últim periode tancat
     SELECT MAX(fcierre) INTO l_fcierre
     FROM CIERRES
     WHERE cempres = pcempres
       AND ctipo   = 6
       AND cestado = 1;

     IF l_fcierre IS NULL THEN
        l_fcierre := TO_DATE('31/12/2000','dd/mm/yyyy');
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN 105511;
  END;
  BEGIN
     SELECT nperven INTO l_nperven
     FROM RECIBOS
     WHERE nrecibo = pnrecibo;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN  102367;
  END;

  IF TO_DATE('01'||l_nperven,'dd/yyyy/mm') <= l_fcierre THEN
     pmeritat := 1;
  ELSE
     pmeritat := 0;
  END IF;

  RETURN 0;
END f_rebut_meritat;
------------------------------------------------------------------------------------------
FUNCTION f_fecha_calculo(pcempres IN  NUMBER, pmodo    IN  NUMBER,
                         pfperfin OUT DATE, pfcierre OUT DATE,
                         pnmesven OUT NUMBER, pnanyven OUT NUMBER)
         RETURN NUMBER IS
/********************************************************************************************
 Devuelve el mes y año para el cual hay que calcular la  meritación de cada empresa.
        pmodo = 1 ==> Proceso diario, por lo tanto, será el mes siguiente al último cierre
                      que tenemos en cierres
        pmodo = 2 ==> Cierre definitivo, por lo tanto, será el último cierre
                      que tenemos en CIERRES para el ctipo = 6 (Cierres de Meritacio).
*********************************************************************************************/
num_err  NUMBER := 0;

BEGIN
   IF pmodo =1 THEN
      BEGIN
         SELECT MAX(fperfin),MAX(fcierre), TO_NUMBER(TO_CHAR(MAX(fperfin),'mm')),
                TO_NUMBER(TO_CHAR(MAX(fperfin),'yyyy'))
         INTO pfperfin,pfcierre,pnmesven,
              pnanyven
         FROM CIERRES
         WHERE ctipo = 6
           AND cempres = pcempres
           AND cestado <> 1;
      EXCEPTION
         WHEN OTHERS THEN
            pfperfin := TO_DATE('31/01/2001','dd/mm/yyyy');
            pfcierre :=TO_DATE('31/01/2001','dd/mm/yyyy');
            pnmesven := 01;
            pnanyven := 2001;
      END;

     --  Si el histórico está vacío lo inicializaremos en el año 2001
     IF pfcierre IS NULL THEN
        pfperfin := TO_DATE('31/01/2001', 'dd/mm/yyyy');
        pfcierre := TO_DATE('31/01/2001', 'dd/mm/yyyy');
        pnmesven := 1;
        pnanyven := 2001;
     END IF;
   ELSIF pmodo = 2 THEN
     BEGIN
        SELECT MAX(fperfin),MAX(fcierre) ,TO_NUMBER(TO_CHAR(MAX(fperfin),'mm')),
            TO_NUMBER(TO_CHAR(MAX(fperfin),'yyyy'))
          INTO pfperfin, pfcierre,pnmesven,pnanyven
        FROM CIERRES
        WHERE ctipo = 6
          AND cempres = pcempres;
     EXCEPTION
        WHEN OTHERS THEN
           pfperfin := TO_DATE('31/01/2001', 'dd/mm/yyyy');
           pfcierre := TO_DATE('31/01/2001', 'dd/mm/yyyy');
           pnmesven := 1;
           pnanyven := 2001;
     END;
   END IF;

   RETURN num_err;
EXCEPTION
  WHEN OTHERS THEN
    num_err := 105511;  -- Error de lectura en CIERRES
    RETURN num_err;
END f_fecha_calculo;
----------------------------------------------------------------------------------------------


FUNCTION f_permerita(pctipo IN NUMBER,pfemisio IN DATE, pfefecto IN DATE,pcempres IN NUMBER)
RETURN NUMBER IS
/****************************************************************************
	F_PERMERITA: Calcula la fecha a la cual se imputa la meritación, según
		     las fechas de efecto, de emisión y de cierre del período
                     En las anulaciones, tabién depende de la fecha de emision,
                     no se pone directamente la fecha de efecto
                     Si el efecto es de un periodo cerrado, se imputa la venta
                     al último periodo sin cerrar.
                     pctipo Es el ctiprec de recibos
****************************************************************************/
	periodo		NUMBER;
	pfcierremes	DATE;

BEGIN
   IF pctipo = 9 THEN
      periodo := TO_NUMBER(TO_CHAR(pfemisio,'YYYYMM'));
   ELSE
     -- Obtenim quina és la última data de tancament TANCAT.
     BEGIN
        SELECT MAX(fcierre) INTO pfcierremes
        FROM CIERRES
        WHERE cempres = pcempres
          AND ctipo   = 6
          AND cestado = 1;
        IF pfcierremes IS NULL THEN
        	-- No hi ha cap tancament fet, per tant posem data d'efecte
        	periodo := TO_NUMBER(TO_CHAR(pfefecto,'YYYYMM'));
        ELSE
           IF pfefecto > pfcierremes THEN
              -- Si l'efecte és posterior a l'últim tancament, el periode de venda és el d'efecte
              periodo := TO_NUMBER(TO_CHAR(pfefecto,'YYYYMM'));
           ELSE
              -- si és anterior, es posa la data d'emissió
              periodo := TO_NUMBER(TO_CHAR(pfemisio,'YYYYMM'));
           END IF;
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
        	periodo := NULL;
     END;
  END IF;
  RETURN periodo;
END f_permerita;

-------------------------------------------------------------------------------------------
FUNCTION f_situac_recibo (pnrecibo IN NUMBER, pfestrec IN DATE,
  pcestrec IN OUT NUMBER) RETURN NUMBER  IS
-------------------------------------------------------------------------------------------
--	F_SITUAC_RECIBO: Obtener la situación de un recibo en una fecha determinada.
-------------------------------------------------------------------------------------------
err_num   NUMBER := 0;
xcestaux  NUMBER;
BEGIN
--dbms_output.put_line('situac_recibo');
   SELECT cestrec  INTO pcestrec
   FROM MOVRECIBO
   WHERE nrecibo = pnrecibo
     AND TRUNC(pfestrec) >= fmovini
     AND (TRUNC(pfestrec) < fmovfin OR fmovfin IS NULL);

--dbms_output.put_line('situac_recibo');
   RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    pcestrec := NULL;
    RETURN 104043;     -- Error al leer de MOVRECIBO
END f_situac_recibo;

---------------------------------------------------------------------------------------------
FUNCTION f_dades_zona(pcempres IN NUMBER, pctipemp IN NUMBER, psseguro IN NUMBER,
                      pfcierre IN DATE,   pcagente IN NUMBER,
                      wcoficina OUT NUMBER, wczona IN OUT NUMBER)
         RETURN NUMBER IS

num_err NUMBER;
l_data  DATE;
l_tipo  NUMBER;

BEGIN
--DBMS_OUTPUT.put_line(' tipo emp '||pctipemp);
   IF NVL(pctipemp,0) = 1  THEN
      wcoficina := pcagente;
      BEGIN
      --DBMS_OUTPUT.put_line(' vaig a select seguredcom '||psseguro||' '|| pfcierre);
         SELECT c06 INTO wczona
         FROM SEGUREDCOM
         WHERE sseguro = psseguro
           AND fmovfin IS NULL;
--DBMS_OUTPUT.put_line(' zona '||wczona);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            wczona := NULL;
         WHEN OTHERS THEN
            RETURN  108035           ;
      END;
   ELSE
      BEGIN
--DBMS_OUTPUT.put_line(' historico '||psseguro||' '|| pfcierre);
         SELECT coficin INTO wcoficina
         FROM HISTORICOOFICINAS
         WHERE sseguro = psseguro
           AND ffin IS NULL;
--DBMS_OUTPUT.put_line(' ofician '||wcoficina);
         l_tipo := 2;
         l_data := f_sysdate;
--DBMS_OUTPUT.put_line('busca padre ');
         wczona := NULL;
         num_err :=  F_BUSCAPADRE (pcempres ,wcoficina , l_tipo,
                                   l_data , wczona);
--DBMS_OUTPUT.put_line('busca padre '||num_err||' '||wczona);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            wcoficina := NULL;
            wczona    := NULL;
      END ;
   END IF;
   RETURN 0;
END f_dades_zona;

------------------------------------------------------------------------------------------
FUNCTION f_dades_pol(w_sseguro IN  NUMBER , wnpoliza  OUT NUMBER , wncertif OUT NUMBER,
                     wcramo    OUT NUMBER , wcmodali  OUT NUMBER , wctipseg OUT NUMBER,
                     wccolect  OUT NUMBER , wfefecto  OUT DATE   , wfanulac OUT DATE,
                     wctippag  OUT NUMBER , wccompani OUT NUMBER , text_error OUT VARCHAR2,
                     wsproduc  OUT NUMBER , wcactivi  OUT NUMBER , wcdivisa OUT NUMBER)
        RETURN NUMBER IS
------------------------------------------------------------------------------------------
      -- Obtenir dades de la pòlissa i producte
BEGIN
--dbms_output.put_line('dades_polissa');
   SELECT s.npoliza, s.ncertif, s.cramo  , s.cmodali,  s.ctipseg, s.ccolect,
          s.fefecto, s.fanulac, p.ctippag, NVL(s.ccompani, p.ccompani) ccompani, p.sproduc, s.cactivi,
          p.cdivisa
     INTO wnpoliza , wncertif,  wcramo,    wcmodali,   wctipseg,  wccolect ,
          wfefecto, wfanulac, wctippag ,wccompani , wsproduc, wcactivi, wcdivisa
   FROM  SEGUROS s, PRODUCTOS p
   WHERE s.sseguro = w_sseguro
     AND s.cramo   = p.cramo
     AND s.cmodali = p.cmodali
     AND s.ctipseg = p.ctipseg
     AND s.ccolect = p.ccolect;

--dbms_output.put_line('dades_polissa');
   RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
      text_error := 'SEG '||w_sseguro||' '||SQLERRM;
      RETURN 101919;
END f_dades_pol;

---------------------------------------------------------------------------------
FUNCTION f_merita_gar (pcramo IN NUMBER, pcmodali IN NUMBER, pctipseg IN NUMBER,
                       pccolect IN NUMBER,pcactivi IN NUMBER, pcgarant IN NUMBER)
        RETURN NUMBER IS
---------------------------------------------------------------------------------
num_err  NUMBER;
lcvalpar NUMBER;
BEGIN

   num_err := f_pargaranpro(pcramo, pcmodali, pctipseg ,
                            pccolect, pcactivi, pcgarant,
                           'GENVENTA', lcvalpar );
   IF num_err = 0 THEN
      RETURN NVL(lcvalpar,1);
   ELSE
      RETURN 1;
   END IF;
END f_merita_gar;

-----------------------------------------------------------------------------------
FUNCTION f_imports(pnrecibo IN NUMBER, psproduc IN NUMBER,pcramo IN NUMBER,
                   pcmodali IN NUMBER, pctipseg IN NUMBER,pccolect IN NUMBER,
                   pcactivi IN NUMBER,
                   witotalr   OUT NUMBER, wicombru OUT NUMBER, wicomcia  OUT NUMBER )

         RETURN NUMBER IS
----------------------------------------------------------------------------------------------
-- Cal tenir en compte que hi ha garanties que no generen venda com és el cas de les decenals
-- que tenen un primer rebut de bestreta que només merita la comissió
-- Per saber que el rebut es de bestreta, calculem la prima sense les garanties de bestreta
-- i si l'import es zero, agafarem només la comissió
-- En el cas del rebut definitiu, l'import te descomptada la bestreta, i no s'ha de descomptar
-- però en canvi si que s'ha de descomptar la comissió per queè ja l'hem meritat .
----------------------------------------------------------------------------------------------

   num_err       NUMBER;
   lcvalpar_prod NUMBER;
   lcvalpar      NUMBER;
   lprima        NUMBER;

BEGIN
   num_err := 0;


   -- Comprovem si el producte gestiona bestretes
   num_err := f_parproductos (psproduc , 'ANTICIPOS', lcvalpar_prod);
   IF num_err = 0 THEN

      IF NVL(lcvalpar_prod,0) = 1 THEN
         -- Si permet bestretes
         -- Obtindrem la prima del rebut sense la bestreta.
         -- Si es zero és que no hi ha prima per meritar

         -- Obtenim prima bruta del rebut :
         SELECT SUM(DECODE(CCONCEP, 0, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 1, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 2, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 3, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 4, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 5, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 6, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 7, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 8, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 14, ICONCEP, 0)) -
                SUM(DECODE(CCONCEP, 13, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 50, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 51, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 52, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 53, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 54, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 55, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 56, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 57, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 58, ICONCEP, 0)) +
                SUM(DECODE(CCONCEP, 64, ICONCEP, 0)) -
                SUM(DECODE(CCONCEP, 63, ICONCEP, 0))
         INTO witotalr
         FROM DETRECIBOS
         WHERE nrecibo = pnrecibo
           AND f_merita_gar(pcramo, pcmodali, pctipseg ,
                            pccolect ,pcactivi , cgarant) = 1 ;


         -- Meritem la comissió del rebut
            -- Si el Rebut només té bestreta, Meritem la comissió del rebut
            -- Si el rebut és el que conté prima definitiva Meritem la prima total,
            --   que ja és la calculada
            --   Meritem la comissió sense la part de la bestreta (es resta automàtic)
            --   Cal tenir en compte que la comissió de la bestreta estará en negatiu
            --   i per tant està restant.(Amb la prima al no tenir-la en compte, hem fet
            --   que no resti.
         BEGIN
            SELECT icombru,  icomcia
              INTO wicombru, wicomcia
            FROM VDETRECIBOS
            WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               witotalr:= 0;
               wicombru:= 0;
               wicomcia := 0;
               RETURN 0;
               -- num_err := 103920; Tret per culpa de la migració
         END;

      ELSE
         -- El producte no te bestretes, per tant es merita sempre tot
         BEGIN
            SELECT itotalr,  icombru,  icomcia
              INTO witotalr, wicombru, wicomcia
            FROM VDETRECIBOS
            WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               witotalr:= 0;
               wicombru:= 0;
               wicomcia := 0;
               RETURN 0;
               -- num_err := 103920; Tret per culpa de la migració
         END;
      END IF;
   END IF;
   RETURN num_err;
END f_imports;

---------------------------------------------------------------------------------------------
FUNCTION f_meritacio_generada (pmodo    IN NUMBER, pcempres IN NUMBER, pctipemp IN NUMBER,
                               pnmesven IN NUMBER, pnanyven IN NUMBER, psproces IN NUMBER,
                               pfperfin IN DATE,   pfcierre IN DATE,   pfcierre_ant IN DATE,
                               pfcalcul IN DATE,   pmoneda IN NUMBER,  text_error OUT VARCHAR2)
                             RETURN NUMBER IS
---------------------------------------------------------------------------------------------

lnpoliza               NUMBER;
lncertif               NUMBER;
lcramo                 NUMBER;
lcmodali               NUMBER;
lctipseg               NUMBER;
lccolect               NUMBER;
lctippag               NUMBER;
lccompani              NUMBER;
litotalr               NUMBER;
licombru               NUMBER;
licomcia               NUMBER;
lprima_meritada        NUMBER;
lprima_meritada_cia    NUMBER;
lprima_extornada       NUMBER;
lprima_extornada_cia   NUMBER;
lprima_merit_anul      NUMBER;
lprima_merit_anul_cia  NUMBER;
lprima_extorn_anul     NUMBER;
lprima_extorn_anul_cia NUMBER;
lfefecto  DATE;
lfvencim  DATE;
lfanulac  DATE;
num_err   NUMBER;
lsproduc  NUMBER;
lcactivi  NUMBER;
lcdivisa  NUMBER;
lsinefec  NUMBER;
lcomis_meritada             NUMBER;
lcomis_meritada_cia         NUMBER;
lcomis_extornada            NUMBER;
lcomis_extornada_cia        NUMBER;
lcomis_meritada_agen        NUMBER;
lcomis_meritada_cia_agen    NUMBER;
lcomis_extornada_agen       NUMBER;
lcomis_extornada_cia_agen   NUMBER;
lcomis_merit_anul           NUMBER;
lcomis_merit_anul_cia       NUMBER;
lcomis_extorn_anul          NUMBER;
lcomis_extorn_anul_cia      NUMBER;
lcomis_merit_anul_agen      NUMBER;
lcomis_merit_anul_cia_agen  NUMBER;
lcomis_extorn_anul_agen     NUMBER;
lcomis_extorn_anul_cia_agen NUMBER;
lczona                      NUMBER;
lcoficina                   NUMBER;
CURSOR c_rebuts_periode IS
   SELECT sseguro, nrecibo, nperven, ctiprec, femisio,fefecto,cgescob, 1 signe, femisio fmovdia, cagente
   FROM RECIBOS
   WHERE cempres = pcempres
     AND nperven = TO_NUMBER(pnanyven||LPAD(pnmesven,2,'0'))
     AND NVL(cestaux,0) = 0
 UNION
   SELECT r.sseguro, r.nrecibo, r.nperven, r.ctiprec, r.femisio, r.fefecto, r.cgescob, -1 signe, m.fmovdia, r.cagente
   FROM SEGUROS s,RECIBOS r, MOVRECIBO m
   WHERE s.sseguro = r.sseguro
     AND r.cempres = pcempres
     AND r.nrecibo = m.nrecibo
     AND TRUNC(m.fmovdia) > pfcierre_ant
     AND TRUNC(m.fmovdia) <= pfcierre
     AND m.cestrec = 2
     AND s.csituac = 0
     AND NVL(r.cestaux,0) = 0;

CURSOR c_anuls_periode IS
   SELECT r.sseguro, r.nrecibo, r.nperven, r.ctiprec, r.femisio, r.fefecto, r.cgescob, m.fmovdia, r.cagente
   FROM SEGUROS s, RECIBOS r, MOVRECIBO m
   WHERE s.sseguro = r.sseguro
     AND r.cempres = pcempres
     AND r.nrecibo = m.nrecibo
     AND TRUNC(m.fmovdia) > pfcierre_ant
     AND TRUNC(m.fmovdia) <= pfcierre
     AND m.cestrec = 2
--     AND m.fmovini <= pfperfin
--     AND ( m.fmovfin > pfperfin OR m.fmovfin IS NULL)
     AND s.csituac IN (2,3)
     AND NVL(r.cestaux,0) = 0;

BEGIN
   ----------------------------------------------------------------------------------------
   -- REBUTS DEL PERIODE
   ----------------------------------------------------------------------------------------
   FOR v_recper IN c_rebuts_periode LOOP

      -- Obtenir dades de la pòlissa i producte
      num_err := f_dades_pol(v_recper.sseguro, lnpoliza ,lncertif , lcramo   ,
                             lcmodali ,lctipseg ,lccolect , lfefecto, lfanulac,
                             lctippag ,lccompani, text_error, lsproduc, lcactivi,
                             lcdivisa );
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;


      num_err := f_dades_zona(pcempres, pctipemp, v_recper.sseguro, pfcierre,
                              v_recper.cagente, lcoficina, lczona);
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Obtenim les primes
      num_err := f_imports(v_recper.nrecibo, lsproduc ,lcramo ,
                           lcmodali, lctipseg,lccolect,lcactivi,
                           litotalr, licombru, licomcia);
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF NVL(v_recper.cgescob,1) = 2 THEN
         -- Gestiona el cobrament la compayia
         IF v_recper.ctiprec = 9 THEN
            -- Es un extorn i gestiona la cia
            lprima_meritada      := 0;
            lprima_meritada_cia  := 0;
            lprima_extornada     := 0;
            lprima_extornada_cia := NVL(litotalr,0);
            ---------------------------------
            --lcomis_agen          := 0;
            --lcomis_agen_extorn   := nvl(licombru,0);
            --lcomis_cia           := 0;
            --lcomis_cia_extorn    := nvl(licomcia,0);

            lcomis_meritada            := 0;
            lcomis_meritada_cia        := 0;
            lcomis_extornada           := 0;
            lcomis_extornada_cia       := NVL(licomcia,0);
            lcomis_meritada_agen       := 0;
            lcomis_meritada_cia_agen   := 0;
            lcomis_extornada_agen      := 0;
            lcomis_extornada_cia_agen  := NVL(licombru,0);

         ELSE
            -- NO es un extorn i gestiona la cia
            lprima_meritada      := 0;
            lprima_meritada_cia  := NVL(litotalr,0);
            lprima_extornada     := 0;
            lprima_extornada_cia := 0;
            ---------------------------------
            --lcomis_agen          := nvl(licombru,0);
            --lcomis_agen_extorn   := 0;
            --lcomis_cia           := nvl(licomcia,0);
            --lcomis_cia_extorn    := 0;

            lcomis_meritada            := 0;
            lcomis_meritada_cia        := NVL(licomcia,0);
            lcomis_extornada           := 0;
            lcomis_extornada_cia       := 0;
            lcomis_meritada_agen       := 0;
            lcomis_meritada_cia_agen   := NVL(licombru,0);
            lcomis_extornada_agen      := 0;
            lcomis_extornada_cia_agen  := 0;

         END IF;

      ELSE
         -- Gestiona el cobrament la Corredoria
         IF v_recper.ctiprec = 9 THEN
            -- Es un extorn i gestiona el cobrament la Corredoria
            lprima_meritada      := 0;
            lprima_meritada_cia  := 0;
            lprima_extornada     := NVL(litotalr,0);
            lprima_extornada_cia := 0;
            ---------------------------------
            --lcomis_agen          := 0;
            --lcomis_agen_extorn   := nvl(licombru,0);
            --lcomis_cia           := 0;
            --lcomis_cia_extorn    := nvl(licomcia,0);

            lcomis_meritada            := 0;
            lcomis_meritada_cia        := 0;
            lcomis_extornada           := NVL(licomcia,0);
            lcomis_extornada_cia       := 0;
            lcomis_meritada_agen       := 0;
            lcomis_meritada_cia_agen   := 0;
            lcomis_extornada_agen      := NVL(licombru,0);
            lcomis_extornada_cia_agen  := 0;

         ELSE
            -- NO es un extorn i gestiona el cobrament la Corredoria
            lprima_meritada      := NVL(litotalr,0);
            lprima_meritada_cia  := 0;
            lprima_extornada     := 0;
            lprima_extornada_cia := 0;
            ---------------------------------
            --lcomis_agen          := nvl(licombru,0);
            --lcomis_agen_extorn   := 0;
            --lcomis_cia           := nvl(licomcia,0);
            --lcomis_cia_extorn    := 0;

            lcomis_meritada            := NVL(licomcia,0);
            lcomis_meritada_cia        := 0;
            lcomis_extornada           := 0;
            lcomis_extornada_cia       := 0;
            lcomis_meritada_agen       := NVL(licombru,0);
            lcomis_meritada_cia_agen   := 0;
            lcomis_extornada_agen      := 0;
            lcomis_extornada_cia_agen  := 0;


         END IF;
      END IF;
      lprima_merit_anul      := 0;
      lprima_merit_anul_cia  := 0;
      lprima_extorn_anul     := 0;
      lprima_extorn_anul_cia := 0;
      --lcomis_agen_anul       := 0;
      --lcomis_agen_ext_anul   := 0;
      --lcomis_cia_anul        := 0;
      --lcomis_cia_ext_anul    := 0;

      lcomis_merit_anul      := 0;
      lcomis_merit_anul_cia  := 0;
      lcomis_extorn_anul     := 0;
      lcomis_extorn_anul_cia := 0;
      lcomis_merit_anul_agen       := 0;
      lcomis_merit_anul_cia_agen   := 0;
      lcomis_extorn_anul_agen := 0;
      lcomis_extorn_anul_cia_agen := 0;

      -- Comprovem si és anul.lació sense efecte. Només surtiràn als llistats de quadre, no
      -- als de meritació
      lsinefec := f_anulacio_sense_efecte(lfefecto, lfanulac, v_recper.nrecibo, v_recper.nperven, NULL,
                                 pfcierre, pfcierre_ant,pnanyven,pnmesven);

      BEGIN
        -- Comprovem el signe de la query que té a veure amb les anul.lacions de rebuts
        lprima_meritada      := lprima_meritada * v_recper.signe;
        lprima_meritada_cia  := lprima_meritada_cia * v_recper.signe;
        lprima_extornada     := lprima_extornada * v_recper.signe;
        lprima_extornada_cia := lprima_extornada_cia * v_recper.signe;
        ---------------------------------
        lcomis_meritada            := lcomis_meritada * v_recper.signe;
        lcomis_meritada_cia        := lcomis_meritada_cia * v_recper.signe;
        lcomis_extornada           := lcomis_extornada * v_recper.signe;
        lcomis_extornada_cia       := lcomis_extornada_cia * v_recper.signe;
        lcomis_meritada_agen       := lcomis_meritada_agen * v_recper.signe;
        lcomis_meritada_cia_agen   := lcomis_meritada_cia_agen * v_recper.signe;
        lcomis_extornada_agen      := lcomis_extornada_agen * v_recper.signe;
        lcomis_extornada_cia_agen  := lcomis_extornada_cia_agen * v_recper.signe;

        IF v_recper.nperven IS NULL THEN
           v_recper.nperven :=  f_permerita (0,v_recper.femisio , v_recper.fefecto,2);
        END IF;

        INSERT INTO MERITACION
              ( cempres,  fcierre,  fcalcul,    sproces,
                npoliza,  ncertif,   sseguro,   cramo,     cmodali,
                ctipseg,  ccolect,   nrecibo,   nperven,   ccompani,
                femisio,  czona,     coficina,
                prima_meritada,
                prima_meritada_cia,
                prima_extornada,
                prima_extornada_cia,
                prima_merit_anul,
                prima_merit_anul_cia,
                prima_extorn_anul,
                prima_extorn_anul_cia,
                fefecto, cdivisa, csinefec,
                comis_merit_anul,
                comis_merit_anul_cia,
                comis_extorn_anul,
                comis_extorn_anul_cia,
                comis_merit_anul_agen,
                comis_merit_anul_cia_agen,
                comis_extorn_anul_agen ,
                comis_extorn_anul_cia_agen,
                comis_meritada,
                comis_meritada_cia,
                comis_extornada,
                comis_extornada_cia,
                comis_meritada_agen,
                comis_meritada_cia_agen,
                comis_extornada_agen,
                comis_extornada_cia_agen
              )
         VALUES
               (pcempres,  pfcierre , pfcalcul ,        psproces        ,
                lnpoliza , lncertif , v_recper.sseguro ,        lcramo          , lcmodali ,
                lctipseg , lccolect , v_recper.nrecibo, v_recper.nperven, lccompani,
                v_recper.fmovdia,  lczona,     lcoficina,
                lprima_meritada,
                lprima_meritada_cia,
                lprima_extornada,
                lprima_extornada_cia,
                lprima_merit_anul,
                lprima_merit_anul_cia,
                lprima_extorn_anul,
                lprima_extorn_anul_cia,
                v_recper.fefecto,
                lcdivisa, lsinefec,
                lcomis_merit_anul,
                lcomis_merit_anul_cia,
                lcomis_extorn_anul,
                lcomis_extorn_anul_cia,
                lcomis_merit_anul_agen,
                lcomis_merit_anul_cia_agen,
                lcomis_extorn_anul_agen ,
                lcomis_extorn_anul_cia_agen,
                lcomis_meritada,
                lcomis_meritada_cia,
                lcomis_extornada,
                lcomis_extornada_cia,
                lcomis_meritada_agen,
                lcomis_meritada_cia_agen,
                lcomis_extornada_agen,
                lcomis_extornada_cia_agen
              );
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 109906;
            text_error := SQLERRM;
            RETURN num_err;
      END;
   END LOOP;
   ----------------------------------------------------------------------------------------
   -- ANUL.LACIONS DEL PERIODE
   ----------------------------------------------------------------------------------------
   FOR v_recanul IN c_anuls_periode LOOP

      -- Obtenir dades de la pòlissa i producte
      num_err := f_dades_pol(v_recanul.sseguro, lnpoliza ,lncertif , lcramo   ,
                             lcmodali ,lctipseg ,lccolect , lfefecto, lfanulac,
                             lctippag ,lccompani, text_error , lsproduc, lcactivi,
                             lcdivisa );

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_dades_zona(pcempres, pctipemp, v_recanul.sseguro, pfcierre,
                              v_recanul.cagente, lcoficina, lczona);
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Obtenim les primes

      num_err := f_imports(v_recanul.nrecibo, lsproduc ,lcramo ,
                           lcmodali, lctipseg,lccolect,lcactivi,
                           litotalr, licombru, licomcia);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF NVL(v_recanul.cgescob,1) = 2 THEN
         -- Gestiona el cobrament la compayia
         IF v_recanul.ctiprec = 9 THEN
            -- Es un extorn i gestiona la cia
            lprima_merit_anul      := 0;
            lprima_merit_anul_cia  := 0;
            lprima_extorn_anul     := 0;
            lprima_extorn_anul_cia := litotalr;
            ---------------------------------
--            lcomis_agen_anul       := 0;
--            lcomis_agen_ext_anul   := licombru;
--            lcomis_cia_anul        := 0;
--            lcomis_cia_ext_anul    := licomcia;
              lcomis_merit_anul      := 0;
              lcomis_merit_anul_cia  := 0;
              lcomis_extorn_anul     := 0;
              lcomis_extorn_anul_cia := licomcia;
              lcomis_merit_anul_agen        := 0;
              lcomis_merit_anul_cia_agen    := 0;
              lcomis_extorn_anul_agen := 0;
              lcomis_extorn_anul_cia_agen := licombru;

         ELSE
            -- NO es un extorn i gestiona la cia
            lprima_merit_anul      := 0;
            lprima_merit_anul_cia  := litotalr;
            lprima_extorn_anul     := 0;
            lprima_extorn_anul_cia := 0;
            ---------------------------------
--            lcomis_agen_anul       := licombru;
--            lcomis_agen_ext_anul   := 0;
--            lcomis_cia_anul        := licomcia;
--            lcomis_cia_ext_anul    := 0;
            lcomis_merit_anul      := 0;
            lcomis_merit_anul_cia  := licomcia;
            lcomis_extorn_anul     := 0;
            lcomis_extorn_anul_cia := 0;
            lcomis_merit_anul_agen := 0;
            lcomis_merit_anul_cia_agen := licombru;
            lcomis_extorn_anul_agen    := 0;
            lcomis_extorn_anul_cia_agen:= 0;

         END IF;
       ELSE
         -- Gestiona el cobrament la Corredoria
         IF v_recanul.ctiprec = 9 THEN
            -- Es un extorn i gestiona el cobrament la Corredoria
            lprima_merit_anul      := 0;
            lprima_merit_anul_cia  := 0;
            lprima_extorn_anul     := litotalr;
            lprima_extorn_anul_cia := 0;
            ---------------------------------
--            lcomis_agen_anul     := 0;
--            lcomis_agen_ext_anul := licombru;
--            lcomis_cia_anul      := 0;
--            lcomis_cia_extorn    := licomcia;
            lcomis_merit_anul      := 0;
            lcomis_merit_anul_cia  := 0;
            lcomis_extorn_anul     := licomcia;
            lcomis_extorn_anul_cia := 0;
            lcomis_merit_anul_agen := 0;
            lcomis_merit_anul_cia_agen := 0;
            lcomis_extorn_anul_agen    := licombru;
            lcomis_extorn_anul_cia_agen:= 0;

         ELSE
            -- NO es un extorn i gestiona el cobrament la Corredoria
            lprima_merit_anul      := litotalr;
            lprima_merit_anul_cia  := 0;
            lprima_extorn_anul     := 0;
            lprima_extorn_anul_cia := 0;
            ---------------------------------
--            lcomis_agen_anul      := licombru;
--            lcomis_agen_ext_anul  := 0;
--            lcomis_cia_anul       := licomcia;
--            lcomis_cia_ext_anul   := 0;
            lcomis_merit_anul      := licomcia;
            lcomis_merit_anul_cia  := 0;
            lcomis_extorn_anul     := 0;
            lcomis_extorn_anul_cia := 0;
            lcomis_merit_anul_agen := licombru;
            lcomis_merit_anul_cia_agen := 0;
            lcomis_extorn_anul_agen    := 0;
            lcomis_extorn_anul_cia_agen:= 0;

         END IF;
      END IF;

      lprima_meritada      := 0;
      lprima_meritada_cia  := 0;
      lprima_extornada     := 0;
      lprima_extornada_cia := 0;
--      lcomis_agen          := 0;
--      lcomis_agen_extorn   := 0;
--      lcomis_cia           := 0;
--      lcomis_cia_extorn    := 0;
      lcomis_meritada            := 0;
      lcomis_meritada_cia        := 0;
      lcomis_extornada           := 0;
      lcomis_extornada_cia       := 0;
      lcomis_meritada_agen       := 0;
      lcomis_meritada_cia_agen   := 0;
      lcomis_extornada_agen      := 0;
      lcomis_extornada_cia_agen  := 0;

      -- Comprovem si és anul.lació sense efecte. Només surtiràn als llistats de quadre, no
      -- als de meritació
      lsinefec := f_anulacio_sense_efecte(lfefecto, lfanulac, v_recanul.nrecibo, v_recanul.nperven, NULL,
                                 pfcierre, pfcierre_ant,pnanyven,pnmesven);

      IF v_recanul.nperven IS NULL THEN
         v_recanul.nperven :=  f_permerita (0,v_recanul.femisio , v_recanul.fefecto,2);
      END IF;

      BEGIN
         INSERT INTO MERITACION
              ( cempres,  fcierre,  fcalcul,    sproces,
                npoliza,  ncertif,   sseguro,   cramo,     cmodali,
                ctipseg,  ccolect,   nrecibo,   nperven,   ccompani,
                femisio,  czona,     coficina,
                prima_meritada,
                prima_meritada_cia,
                prima_extornada,
                prima_extornada_cia,
                prima_merit_anul,
                prima_merit_anul_cia,
                prima_extorn_anul,
                prima_extorn_anul_cia,
                fefecto, cdivisa, csinefec,
                comis_merit_anul,
                comis_merit_anul_cia,
                comis_extorn_anul,
                comis_extorn_anul_cia,
                comis_merit_anul_agen,
                comis_merit_anul_cia_agen,
                comis_extorn_anul_agen ,
                comis_extorn_anul_cia_agen,
                comis_meritada,
                comis_meritada_cia,
                comis_extornada,
                comis_extornada_cia,
                comis_meritada_agen,
                comis_meritada_cia_agen,
                comis_extornada_agen,
                comis_extornada_cia_agen
              )
         VALUES
               (pcempres,  pfcierre , pfcalcul ,          psproces        ,
                lnpoliza , lncertif , v_recanul.sseguro , lcramo          ,  lcmodali ,
                lctipseg , lccolect , v_recanul.nrecibo,  v_recanul.nperven, lccompani,
                v_recanul.fmovdia,  lczona,     lcoficina,
                lprima_meritada,
                lprima_meritada_cia,
                lprima_extornada,
                lprima_extornada_cia,
                lprima_merit_anul,
                lprima_merit_anul_cia,
                lprima_extorn_anul,
                lprima_extorn_anul_cia,
                v_recanul.fefecto,
                lcdivisa, lsinefec,
                lcomis_merit_anul,
                lcomis_merit_anul_cia,
                lcomis_extorn_anul,
                lcomis_extorn_anul_cia,
                lcomis_merit_anul_agen,
                lcomis_merit_anul_cia_agen,
                lcomis_extorn_anul_agen ,
                lcomis_extorn_anul_cia_agen,
                lcomis_meritada,
                lcomis_meritada_cia,
                lcomis_extornada,
                lcomis_extornada_cia,
                lcomis_meritada_agen,
                lcomis_meritada_cia_agen,
                lcomis_extornada_agen,
                lcomis_extornada_cia_agen
              );

      EXCEPTION
         WHEN OTHERS THEN
            num_err := 109906;
            text_error := SQLERRM;
            RETURN num_err;
      END;
   END LOOP;
   RETURN 0;

END f_meritacio_generada;
---------------------------------------------------------------------------------------------

FUNCTION f_calcul_meritacio(psproces IN NUMBER, pmodo IN NUMBER,  pcempres IN NUMBER,
                            pmoneda IN NUMBER,  pfperfin IN DATE, pfcierre IN DATE,
                            text_error OUT VARCHAR2)
         RETURN NUMBER IS
/*********************************************************************************************
   función principal para el cálculo de meritación
**********************************************************************************************/
 -- Si el pmodo es 2, entonces sólo seleccionará la empresa del cierre. Si no,
 -- selecciona todas las empresas
CURSOR c_empresas(pc_modo IN NUMBER) IS
  SELECT cempres, ctipemp
    FROM EMPRESAS
   WHERE cempres = DECODE(pc_modo,1,cempres,pcempres);

num_err               NUMBER;
ult_fcierre	          DATE;
v_fperfin             DATE;
v_fcierre             DATE;
v_NumRows             INTEGER;
BEGIN

--dbms_output.put_line('Bucle empresas ');

   -- Para cada empresa calculamos la meritacio desde el último cierre

   FOR emp IN c_empresas(pmodo) LOOP
       -- Inicializamos las variables
       vg_nmesven := 0;
       vg_nanyven := 0;
       v_fperfin := NULL;
       IF pmodo = 1 THEN
          -- Miramos para que año y mes hay que hacer el cálculo
          num_err := f_fecha_calculo(emp.cempres,pmodo,v_fperfin,v_fcierre,
                                     vg_nmesven, vg_nanyven);
          IF num_err <> 0 THEN
             RETURN num_err;
          END IF;
       ELSIF pmodo = 2 THEN
          v_fperfin  := pfperfin;
          v_fcierre  := pfcierre;
          vg_nmesven := TO_CHAR(pfperfin,'mm');
          vg_nanyven := TO_CHAR(pfperfin,'yyyy');
       END IF;

       -- La fecha del último cierre será la de periodo anterior a pfperfin
       BEGIN
          SELECT fcierre INTO ult_fcierre
          FROM CIERRES
          WHERE cempres = pcempres
            AND ctipo = 6
            AND fperfin = ADD_MONTHS(v_fperfin, -1);
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             ult_fcierre := ADD_MONTHS(v_fperfin, -1);
       END;
       COMMIT;
       SET TRANSACTION USE ROLLBACK SEGMENT ROLLBIG;

       DELETE FROM MERITACION
       WHERE cempres = emp.cempres
         AND fcierre = v_fperfin;

       COMMIT;
       SET TRANSACTION USE ROLLBACK SEGMENT ROLLBIG;

--dbms_output.put_line('ult cierre '||ult_fcierre );
       num_err := f_meritacio_generada(pmodo,emp.cempres, emp.ctipemp, vg_nmesven, vg_nanyven, psproces,
                                       v_fperfin, v_fcierre,ult_fcierre,f_sysdate,pmoneda,
                                       text_error);
--dbms_output.put_line('meritacio_generada '|| num_err );
       IF num_err <> 0 THEN
          RETURN num_err;
       END IF;

   END LOOP;
--dbms_output.put_line('Fi ');
   RETURN num_err;
END f_calcul_meritacio;


---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
PROCEDURE PROCESO_BATCH_CIERRE(pmodo IN NUMBER, pcempres IN NUMBER, pmoneda IN NUMBER,
                               pcidioma IN NUMBER,pfperfin IN DATE,pfcierre IN DATE,
                               pcerror OUT NUMBER, psproces OUT NUMBER, pfproces OUT DATE) IS
/*********************************************************************************************
  Proceso que lanzará todos los procesos de cierres (meritacio,...)
**********************************************************************************************/
num_err        NUMBER := 0;
text_error     VARCHAR2(500);
pnnumlin       NUMBER;
texto	         VARCHAR2(200);
indice_error   NUMBER := 0;
v_estado       NUMBER:= 0;
v_titulo       VARCHAR2(50);
llinia         NUMBER := 0;
BEGIN
  IF  pmodo = 1 THEN
      v_titulo := 'Proceso Cierre Diario';
  ELSE
      v_titulo := 'Proceso Cierre Mensual';
  END IF;

 --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
  num_err := f_procesini(F_USER,pcempres,'MERITACIÓN ',v_titulo,psproces);

--dbms_output.put_line('CaALCUL MERITACIÓ');

  num_err := F_CALCUL_MERITACIO(psproces,pmodo,pcempres,pmoneda,pfperfin,pfcierre,text_error);

--dbms_output.put_line('tORNA DE CALCUL MERITACIÓ '||NUM_ERR);

  IF num_err <> 0 THEN  -- hay errores
     num_err := f_proceslin(psproces, text_error, 0,llinia);
     pcerror := 1;
  ELSE
     pcerror := 0;
  END IF;
  num_err := f_procesfin(psproces, pcerror);
  pfproces := SYSDATE;
  IF num_err = 0 THEN
    COMMIT;
  END IF;
END proceso_batch_cierre;

/*FUNCTION actualiza_perven(pcempres IN NUMBER, pfperini IN DATE, pfperfin IN DATE)
        RETURN NUMBER IS
  num_err       NUMBER;
  l_fcierre_ant DATE;
  texto         VARCHAR2(100);

  CURSOR c_rea (wfperfin DATE, pfcierre_ant DATE) IS
     SELECT nrecibo
     FROM recibos
     WHERE fefecto < pfperfin + 1
       AND femisio > pfcierre_ant;

BEGIN
         num_err := 0;
         -- Reajustar el periode de meritació de vendes y rebuts
         -- busquem el tancament anterior per reajustar
         BEGIN
            SELECT fcierre INTO l_fcierre_ant
            FROM cierres
            WHERE cempres = pcempres
              AND ctipo = 6
              AND fperini = add_months(pfperini, -1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_fcierre_ant :=to_date('31/12/2000','dd/mm/yyyy');
         END;
         FOR v_rec IN c_rea (pfperfin, l_fcierre_ant) LOOP
            BEGIN
              UPDATE recibos
                 SET nperven = pac_merita.f_permerita(null, femisio, fefecto, cempres)
               WHERE nrecibo = v_rec.nrecibo;
              COMMIT;
            EXCEPTION
              WHEN OTHERS THEN
                 num_err := 108032;  --
            END;
         END LOOP;
   RETURN num_err;
END actualiza_perven;
*/

END;

/

  GRANT EXECUTE ON "AXIS"."PAC_MERITA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MERITA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MERITA" TO "PROGRAMADORESCSI";
