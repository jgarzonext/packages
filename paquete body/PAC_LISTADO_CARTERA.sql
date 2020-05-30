--------------------------------------------------------
--  DDL for Package Body PAC_LISTADO_CARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LISTADO_CARTERA" IS
/******************************************************************************
   NOMBRE:     PAC_LISTADO_CARTERA
   PROPÓSITO:  Funciones para la obtención de listados de cartera

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/10/2010   SRA             1. Bug 0016137: Creación del package.
   2.0        30/12/2010   ICV             2. 0016137: CRT003 - Carga fichero cartera -> Listado cartera
   3.0        08/11/2011   APD             3. 0019316: CRT - Adaptar pantalla de comisiones
******************************************************************************/

   /*************************************************************************
      f_compara_recibos_poliza                       : dado un número de seguro y una fecha de cartera, recupera datos del recibo correspondiente
                                                     : a ésta cartera y los compara con los del recibo de cartera anterior, obteniendo porcentajes
                                                     : de variación
      psseguro in seguro.sseguro%type                : identificador del seguro en AXIS
      pfechacartera in date                          : fecha que se toma como referencia para la comparación de carteras
      piprinet_ultimo out vdetrecibos.iprianet%type  : prima neta del recibo de cartera con fecha pfechacartera
      piprinet_anterior out vdetrecibos.iprianet%type: prima neta del recibo anterior a la cartera de pfechacartera
      piprinet_variacion out number                  : porcentaje de variación de la prima neta
      picombru_ultimo out vdetrecibos.icombru%type   : comisión bruta del recibo de cartera con fecha pfechacartera
      picombru_anterior out vdetrecibos.icombru%type : comisión bruta del recibo anterior a la cartera de pfechacartera
      picombru_variacion out number)                 : porcentaje de variación de la comisión bruta
      return number                                  : control de errores
   *************************************************************************/
   FUNCTION f_compara_recibos_poliza(
      psseguro IN seguros.sseguro%TYPE,
      pultrec IN recibos.nrecibo%TYPE,
      pefecultrec IN DATE,
      piprinet_ultimo IN NUMBER,
      picombru_ultimo IN NUMBER,
      pnrecibo_anterior OUT recibos.nrecibo%TYPE,
      pfefector_anterior OUT recibos.fefecto%TYPE,
      pfvencimr_anterior OUT recibos.fefecto%TYPE,
      piprinet_anterior OUT vdetrecibos.iprinet%TYPE,
      piprinet_variacion OUT NUMBER,
      picombru_anterior OUT vdetrecibos.icombru%TYPE,
      picombru_variacion OUT NUMBER,
      pcreccia_anterior OUT recibos.creccia%TYPE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_LISTADO_CARTERA.F_COMPARA_RECIBOS_POLIZA';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pultrec: ' || pultrec
            || ' - pefecultrec: ' || pefecultrec;
      vpasexec       NUMBER(5) := 0;
      vnumerr        NUMBER(8) := 0;
      /* vnmescartera   NUMBER;
       vnanyocartera  NUMBER;*/
      vefecto        DATE;
   BEGIN
      vpasexec := 1;

      BEGIN
         SELECT creccia, nrecibo, primarec, icombru,
                fefecto, fvencim
           INTO pcreccia_anterior, pnrecibo_anterior, piprinet_anterior, picombru_anterior,
                pfefector_anterior, pfvencimr_anterior
           FROM (SELECT   r.creccia, r.fefecto, r.fvencim, r.nrecibo, v.icombru,
                          v.itotpri - NVL(v.itotdto, 0) + NVL(v.itotrec, 0) primarec
                     FROM recibos r, vdetrecibos v
                    WHERE r.nrecibo = v.nrecibo(+)
                      AND(r.nrecibo != pultrec
                          OR pultrec IS NULL)
                      AND r.sseguro = psseguro
                      AND r.fefecto <= pefecultrec
                      -- nueva producción o renovación de cartera
                      AND r.ctiprec NOT IN(1)
                 ORDER BY r.fefecto DESC, r.nrecibo DESC)
          WHERE ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      vpasexec := 2;

      BEGIN
         piprinet_variacion :=(NVL(piprinet_ultimo, 0) - NVL(piprinet_anterior, 0));
         --                       / NVL(piprinet_anterior, 0);
         -- piprinet_variacion := piprinet_variacion * 100;
         -- piprinet_variacion := ROUND(piprinet_variacion, 2);
         vpasexec := 3;

         IF piprinet_ultimo IS NULL
            OR piprinet_anterior IS NULL THEN
            piprinet_variacion := 0;
         END IF;
      EXCEPTION
         WHEN ZERO_DIVIDE THEN
            piprinet_variacion := NULL;
      END;

      vpasexec := 5;

      BEGIN
         picombru_variacion :=(NVL(picombru_ultimo, 0) - NVL(picombru_anterior, 0));

                              -- / NVL(picombru_anterior, 0);
         --picombru_variacion := picombru_variacion * 100;
         --picombru_variacion := ROUND(picombru_variacion, 2);
         IF picombru_ultimo IS NULL THEN
            picombru_variacion := NULL;
         END IF;
      EXCEPTION
         WHEN ZERO_DIVIDE THEN
            picombru_variacion := NULL;
      END;

      vpasexec := 6;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLERRM);
         RETURN 9901529;
   END f_compara_recibos_poliza;

   -- BUG 0016137 - 04/10/2010 - SRA
   /*************************************************************************
      p_listado_carteras              : función que dada una fecha de cartera devuelve todas aquellas pólizas que
                                        1) estaban vigente en la fecha de renovación de cartera
                                        2) tienen recibos de nueva producción o de renovación en el mes pfechacartera
                                           o
                                           debían tener recibos de renovación en el mes pfechacartera pero estos no se han encontrado
      pccompani in companipro.ccompani%type: identificador de la compañía que oferta el producto en AXIS
      pfechacartera in date           : fecha que se toma como referencia para la comparación de carteras
      pquery out varchar2             : sentencia dinámica que devuelve el cursor con el listado de pólizas
   *************************************************************************/
   FUNCTION f_listado_carteras(
      pcempres IN seguros.cempres%TYPE,
      pccompani IN companipro.ccompani%TYPE,
      psproduc IN seguros.sproduc%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_listado_cartera.f_listado_polizas_carteras';
      vparam         VARCHAR2(500)
         := 'parámetros - pccompani: ' || pccompani || ' - pfdesde: ' || pfdesde
            || ' - pfhasta: ' || pfhasta;
      vpasexec       NUMBER(5) := 0;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vpasexec := 1;
      vpasexec := 2;
      pquery :=
         pquery
         || 'SELECT DISTINCT s.sseguro, s.npoliza, s.cpolcia, s.ccompani, s.cagente, to_char(s.fcarpro,''dd/mm/rrrr'') fcarpro, to_char(s.fcarant,''dd/mm/rrrr'') fcarant, s.csituac '
         || ' ,r.creccia, r.nrecibo, v.itotpri - nvl(v.itotdto, 0) + nvl(v.itotrec, 0) primarec, v.icombru, r.fefecto, r.fvencim, r.nmovimi, r.femisio, '
         || ' rank() over(partition by s.npoliza order by r.fefecto desc, r.nrecibo desc) as orden ';
      pquery := pquery || 'FROM seguros s, recibos r, vdetrecibos v ';
      pquery := pquery || 'WHERE 1 = 1 ';

      IF psproduc IS NOT NULL THEN
         pquery := pquery || 'AND s.sproduc = ' || psproduc || ' ';
      END IF;

      pquery := pquery || 'AND s.cempres = ' || pcempres || ' ';

      IF pccompani IS NOT NULL THEN
         pquery := pquery || 'AND EXISTS(';
         pquery := pquery || 'SELECT 1 ';
         pquery := pquery || 'FROM PRODUCTOS C ';
         pquery := pquery || 'WHERE C.SPRODUC = S.SPRODUC ';
         pquery := pquery || 'AND C.CCOMPANI = ' || pccompani || ')';
      END IF;

      vpasexec := 3;
      /*   JLB -- el problema es cuando pedimos carteras pasadas (anteriores a la última los recibos pasan a ser
           --  ilocalizables

          pquery := pquery || ' and s.fcarant >= to_date(' || CHR(39)
                   || TO_CHAR(pfdesde, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                   || CHR(39) || ')';
         pquery := pquery || ' and s.fcarant <= to_date(' || CHR(39)
                   || TO_CHAR(pfhasta, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                   || CHR(39) || ')';
         pquery := pquery || ' and r.fefecto >= to_date(' || CHR(39)
                   || TO_CHAR(pfdesde, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                   || CHR(39) || ')';
         pquery := pquery || ' and r.fefecto <= to_date(' || CHR(39)
                   || TO_CHAR(pfhasta, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                   || CHR(39) || ')';
         */-- jlb
      pquery := pquery || ' and r.femisio >= to_date(' || CHR(39)
                || TO_CHAR(pfdesde, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                || CHR(39) || ')';
      pquery := pquery || ' and r.femisio <= to_date(' || CHR(39)
                || TO_CHAR(pfhasta, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                || CHR(39) || ')';
      pquery := pquery || ' and r.sseguro = s.sseguro ';
      pquery := pquery || ' and r.ctiprec not in (1) ';
      pquery := pquery || ' and r.nrecibo = v.nrecibo ';
      pquery :=
         'SELECT sseguro, npoliza, cpolcia, ccompani, cagente, fcarpro, fcarant, csituac, creccia, nrecibo, primarec, icombru, fefecto, fvencim, nmovimi, femisio '
         || ' FROM (' || pquery || ') WHERE orden = 1 order by npoliza desc';
      vpasexec := 4;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLERRM);
         RETURN 9901529;
   END f_listado_carteras;

   /*************************************************************************
      f_listado_polizas_sincartera:     función que dada un rango de fechas devuelve todas aquellas pólizas que cumplen:
                                        1) están vigentes
                                        2) su fecha de próxima cartera está incluída en el rango de fechas, con lo que se considera que no han renovado cartera en ese rango
                                        3) o bien, aunque sí que cumplan 2), no se encuentra en AXIS el recibo de renovación correspondiente
      pccompani in companipro.ccompani%type: identificador de la compañía que oferta el producto en AXIS
      pfechacartera in date           : fecha que se toma como referencia para la comparación de carteras
      pquery out varchar2             : sentencia dinámica que devuelve el cursor con el listado de pólizas
   *************************************************************************/
   FUNCTION f_listado_polizas_sincartera(
      pcempres IN seguros.cempres%TYPE,
      pccompani IN companipro.ccompani%TYPE,
      psproduc IN seguros.sproduc%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_LISTADO_CARTERA.F_LISTADO_POLIZAS_SINCARTERA';
      vparam         VARCHAR2(500)
         := 'parámetros - pccompani: ' || pccompani || ' - pfdesde : ' || pfdesde
            || ' - pfhasta : ' || pfhasta;
      vpasexec       NUMBER(5) := 0;
      vnumerr        NUMBER(8) := 0;
      pquery1        VARCHAR2(4000);
      pquery2        VARCHAR2(4000);
   /* vnmescartera   NUMBER;
    vnanyocartera  NUMBER;*/
   BEGIN
      vpasexec := 1;
      -- Seleccionarmos pólizas vigentes cuya fecha de próxima cartera haya sido rebasada
      -- por el rango de fechas por el que estamos filtrados: pólizas que deberían haber renovado cartera y no lo han hecho
      pquery1 :=
         pquery1
         || 'SELECT DISTINCT s.sseguro, s.npoliza, s.cpolcia, s.ccompani, s.cagente, to_char(s.fcarpro,''dd/mm/rrrr'') fcarpro, to_char(s.fcarant,''dd/mm/rrrr'') fcarant, s.csituac '
         || ' , null creccia, null nrecibo, null primarec, null icombru, null fefecto, null fvencim, null nmovimi, null femision ';
      pquery1 := pquery1 || 'FROM seguros s ';
      pquery1 := pquery1 || 'WHERE f_vigente(s.sseguro, null, s.fcarpro+1) = 0 ';   -- doy un margen de un dia porque hay polizas que se anulan al dia siguiente

      IF psproduc IS NOT NULL THEN
         pquery1 := pquery1 || 'AND s.sproduc = ' || psproduc || ' ';
      END IF;

      pquery1 := pquery1 || 'AND s.cempres = ' || pcempres || ' ';

      IF pccompani IS NOT NULL THEN
         pquery1 := pquery1 || 'AND EXISTS(';
         pquery1 := pquery1 || 'SELECT 1 ';
         pquery1 := pquery1 || 'FROM productos C ';
         pquery1 := pquery1 || 'WHERE c.sproduc = s.sproduc ';
         pquery1 := pquery1 || 'AND c.ccompani = ' || pccompani || ')';
      END IF;

      vpasexec := 2;
      pquery1 := pquery1 || ' and s.fcarpro >= to_date(' || CHR(39)
                 || TO_CHAR(pfdesde, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                 || CHR(39) || ')';
      vpasexec := 3;
      pquery1 := pquery1 || ' and s.fcarpro <= to_date(' || CHR(39)
                 || TO_CHAR(pfhasta, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                 || CHR(39) || ')';
      pquery1 :=
         pquery1
         || 'and not exists(select r.nrecibo from recibos r where r.sseguro = s.sseguro '
         || ' and r.ctiprec != 1 '
         || ' AND r.fefecto BETWEEN add_months(s.fcarpro, -1) and add_months(s.fcarpro,1) '
         || ')';
      -- rango de cartera
      pquery1 :=
         pquery1
         || 'and not exists(select r.nrecibo from recibos r where r.sseguro = s.sseguro '
         || ' and r.ctiprec = 1 ' || ' AND r.fefecto BETWEEN s.fcarpro and s.fcarpro ' || ')';
      vpasexec := 4;
      -- Seleccionarmos pólizas vigentes que hayan renovado cartera en el rango de fechas seleccionado pero no tengan recibo de renovación
      -- en dicho rango de fechas
      pquery2 :=
         pquery2
         || 'SELECT s.sseguro, s.npoliza, s.cpolcia, s.ccompani, s.cagente, to_char(s.fcarpro,''dd/mm/rrrr'') fcarpro, to_char(s.fcarant,''dd/mm/rrrr'') fcarant, s.csituac '
         || ' , null creccia, null nrecibo, null primarec, null icombru, null fefecto, null fvencim, null nmovimi, null femision ';
      pquery2 := pquery2 || 'FROM seguros s ';
      pquery2 := pquery2 || 'WHERE f_vigente(s.sseguro, null, s.fcarpro+1) = 0 ';   -- doy un margen de un dia porque hay polizas que se anulan al dia siguiente
      vpasexec := 5;

      IF psproduc IS NOT NULL THEN
         pquery2 := pquery2 || 'AND s.sproduc = ' || psproduc || ' ';
      END IF;

      pquery2 := pquery2 || 'AND s.cempres = ' || pcempres || ' ';
      vpasexec := 6;

      IF pccompani IS NOT NULL THEN
         pquery2 := pquery2 || 'AND EXISTS(';
         pquery2 := pquery2 || 'SELECT 1 ';
         pquery2 := pquery2 || 'FROM productos C ';
         pquery2 := pquery2 || 'WHERE c.sproduc = s.sproduc ';
         pquery2 := pquery2 || 'AND c.ccompani = ' || pccompani || ')';
      END IF;

      vpasexec := 7;
      pquery2 := pquery2 || ' and s.fcarant >= to_date(' || CHR(39)
                 || TO_CHAR(pfdesde, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                 || CHR(39) || ')';
      pquery2 := pquery2 || ' and s.fcarant <= to_date(' || CHR(39)
                 || TO_CHAR(pfhasta, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
                 || CHR(39) || ')';
      pquery2 :=
         pquery2
         || 'and not exists(select r.nrecibo from recibos r where r.sseguro = s.sseguro '
         -- || ' and r.ctiprec != 1 ' || 'and r.fefecto between to_date(' || CHR(39)
         -- || TO_CHAR(pfdesde, 'dd/mm/yyyy') || CHR(39) || ',' || CHR(39) || 'dd/mm/rrrr'
         -- || CHR(39) || ') AND to_date(' || CHR(39) || TO_CHAR(pfhasta, 'dd/mm/yyyy') || CHR(39)
         -- || ',' || CHR(39) || 'dd/mm/rrrr' || CHR(39) || '))';
         || ' and r.ctiprec != 1 '
         || ' AND r.fefecto BETWEEN add_months(s.fcarant, -1) and add_months(s.fcarant,1) '
         || ')';
      pquery2 :=
         pquery2
         || 'and not exists(select r.nrecibo from recibos r where r.sseguro = s.sseguro '
         || ' and r.ctiprec = 1 ' || ' AND r.fefecto BETWEEN s.fcarant and s.fcarant ' || ')';
      pquery := pquery1 || ' UNION ' || pquery2;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLERRM);
         RETURN 9901529;
   END f_listado_polizas_sincartera;

   /*************************************************************************
      F_PCOMISI_CORREDURIA
      Funcion para calcular la comision de correduria.
      Es copia de la f_pcomisi a dia 08/11/2011
   ************************************************************************/
   -- Bug 19316 - APD - 08/11/2011 - se crea la funcion
   -- Se copia a partir de la f_pcomisi. A partir de 08/11/2011 los listados
   -- de cartera utilizaran esta funcion en vez de la f_pcomisi
   -- La manera de calcular la comision a partir del 08/11/2011 sera diferente
   FUNCTION f_pcomisi_correduria(
      psseguro IN NUMBER,
      pcmodcom IN NUMBER,
      pfretenc IN DATE,
      ppcomisi OUT NUMBER,
      ppretenc OUT NUMBER,
      pcagente IN NUMBER DEFAULT NULL,
      pcramo IN NUMBER DEFAULT NULL,
      pcmodali IN NUMBER DEFAULT NULL,
      pctipseg IN NUMBER DEFAULT NULL,
      pccolect IN NUMBER DEFAULT NULL,
      pcactivi IN NUMBER DEFAULT NULL,
      pcgarant IN NUMBER DEFAULT NULL,
      pttabla IN VARCHAR2 DEFAULT NULL,
      pfuncion IN VARCHAR2 DEFAULT 'CAR',
      pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_LISTADO_CARTERA.F_PCOMISI_CORREDURIA';
      num_error      NUMBER := 0;
      xctipcom       NUMBER := 0;
      xcagente       NUMBER := 0;
      xcramo         NUMBER := 0;
      xcmodali       NUMBER := 0;
      xctipseg       NUMBER := 0;
      xccolect       NUMBER := 0;
      xcactivi       NUMBER := 0;
      xcretenc       NUMBER := 0;
      xccomisi       NUMBER := 0;
      xnanuali       NUMBER;
      xgastoext      NUMBER;
      w_ccampanya    detcampanya.ccampanya%TYPE;
      w_nversio      detcampanya.nversio%TYPE;
      -- Bug 19873 - 25/10/2011 - JRH - 0019873: GIP003-Comisión de Cobro
      vcomisextra    NUMBER;

      -- Fi Bug 19873 - 25/10/2011
      FUNCTION f_gastext(ptablas IN VARCHAR2, psseguro IN NUMBER, pcgarant IN NUMBER)
         RETURN NUMBER IS
         xgastoext      NUMBER;
      BEGIN
         IF ptablas = 'EST' THEN
            BEGIN
               SELECT crespue
                 INTO xgastoext
                 FROM estpregungaranseg
                WHERE sseguro = psseguro
                  AND cgarant = pcgarant
                  AND cpregun = 551   --> Gastos Externos
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM estpregungaranseg
                                  WHERE sseguro = psseguro
                                    AND cgarant = pcgarant);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT crespue
                       INTO xgastoext
                       FROM estpregunseg
                      WHERE sseguro = psseguro
                        AND cpregun = 551   --> Gastos Externos
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM estpregunseg
                                        WHERE sseguro = psseguro);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT crespue
                             INTO xgastoext
                             FROM estpregunpolseg
                            WHERE sseguro = psseguro
                              AND cpregun = 551   --> Gastos Externos
                              AND nmovimi = (SELECT MAX(nmovimi)
                                               FROM estpregunpolseg
                                              WHERE sseguro = psseguro);
                        EXCEPTION
                           WHEN OTHERS THEN
                              xgastoext := NULL;
                        END;
                  END;
            END;
         ELSIF ptablas = 'SOL' THEN
            BEGIN
               SELECT crespue
                 INTO xgastoext
                 FROM solpregungaranseg
                WHERE ssolicit = psseguro
                  AND cgarant = pcgarant
                  AND cpregun = 551;   --> Gastos Externos
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT crespue
                       INTO xgastoext
                       FROM solpregunseg
                      WHERE ssolicit = psseguro
                        AND cpregun = 551   --> Gastos Externos
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM solpregunseg
                                        WHERE ssolicit = psseguro);
                  EXCEPTION
                     WHEN OTHERS THEN
                        xgastoext := NULL;
                  END;
            END;
         ELSE
            BEGIN
               SELECT crespue
                 INTO xgastoext
                 FROM pregungaranseg
                WHERE sseguro = psseguro
                  AND cgarant = pcgarant
                  AND cpregun = 551   --> Gastos Externos
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregungaranseg
                                  WHERE sseguro = psseguro
                                    AND cgarant = pcgarant);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT crespue
                       INTO xgastoext
                       FROM pregunseg
                      WHERE sseguro = psseguro
                        AND cpregun = 551   --> Gastos Externos
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM pregunseg
                                        WHERE sseguro = psseguro);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT crespue
                             INTO xgastoext
                             FROM pregunpolseg
                            WHERE sseguro = psseguro
                              AND cpregun = 551   --> Gastos Externos
                              AND nmovimi = (SELECT MAX(nmovimi)
                                               FROM pregunpolseg
                                              WHERE sseguro = psseguro);
                        EXCEPTION
                           WHEN OTHERS THEN
                              xgastoext := NULL;
                        END;
                  END;
            END;
         END IF;

         RETURN xgastoext;
      END f_gastext;

      -- Bug 19873 - 25/10/2011 - JRH - 0019873: GIP003-Comisión de Cobro
      FUNCTION f_comision_extra(ptablas IN VARCHAR2, psseguro IN NUMBER, pcgarant IN NUMBER)
         RETURN NUMBER IS
         vcomisextra    NUMBER;
      BEGIN
         IF ptablas = 'EST' THEN
            BEGIN
               SELECT crespue
                 INTO vcomisextra
                 FROM estpregungaranseg
                WHERE sseguro = psseguro
                  AND cgarant = pcgarant
                  AND cpregun = 9014   --> Comisión extra
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM estpregungaranseg
                                  WHERE sseguro = psseguro
                                    AND cgarant = pcgarant);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT crespue
                       INTO vcomisextra
                       FROM estpregunseg
                      WHERE sseguro = psseguro
                        AND cpregun = 9014   --> Comisión extra
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM estpregunseg
                                        WHERE sseguro = psseguro);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT crespue
                             INTO vcomisextra
                             FROM estpregunpolseg
                            WHERE sseguro = psseguro
                              AND cpregun = 9014   --> Comisión extra
                              AND nmovimi = (SELECT MAX(nmovimi)
                                               FROM estpregunpolseg
                                              WHERE sseguro = psseguro);
                        EXCEPTION
                           WHEN OTHERS THEN
                              vcomisextra := NULL;
                        END;
                  END;
            END;
         ELSIF ptablas = 'SOL' THEN
            BEGIN
               SELECT crespue
                 INTO vcomisextra
                 FROM solpregungaranseg
                WHERE ssolicit = psseguro
                  AND cgarant = pcgarant
                  AND cpregun = 9014;   --> Comisión extra
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT crespue
                       INTO vcomisextra
                       FROM solpregunseg
                      WHERE ssolicit = psseguro
                        AND cpregun = 9014   --> Comisión extra
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM solpregunseg
                                        WHERE ssolicit = psseguro);
                  EXCEPTION
                     WHEN OTHERS THEN
                        vcomisextra := NULL;
                  END;
            END;
         ELSE
            BEGIN
               SELECT crespue
                 INTO vcomisextra
                 FROM pregungaranseg
                WHERE sseguro = psseguro
                  AND cgarant = pcgarant
                  AND cpregun = 9014   --> Comisión extra
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregungaranseg
                                  WHERE sseguro = psseguro
                                    AND cgarant = pcgarant);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT crespue
                       INTO vcomisextra
                       FROM pregunseg
                      WHERE sseguro = psseguro
                        AND cpregun = 9014   --> Comisión extra
                        AND nmovimi = (SELECT MAX(nmovimi)
                                         FROM pregunseg
                                        WHERE sseguro = psseguro);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT crespue
                             INTO vcomisextra
                             FROM pregunpolseg
                            WHERE sseguro = psseguro
                              AND cpregun = 9014   --> Comisión extra
                              AND nmovimi = (SELECT MAX(nmovimi)
                                               FROM pregunpolseg
                                              WHERE sseguro = psseguro);
                        EXCEPTION
                           WHEN OTHERS THEN
                              vcomisextra := NULL;
                        END;
                  END;
            END;
         END IF;

         RETURN NVL(vcomisextra, 0);
      END f_comision_extra;

-- Fi Bug 19873 - 25/10/2011 - JRH

      -- ini Bug 0019682 - 26/10/2011 - JMF
      /*********************************************
      CALCULO COMISION HABITUAL
      *********************************************/
      FUNCTION f_local_comhabitual
         RETURN NUMBER IS
      BEGIN
         BEGIN
            --
            -- Si hay campañas recuperamos el % de la campaña. Si no existe, damos error
            --
            SELECT ccampanya, NVL(nversio, 0)
              INTO w_ccampanya, w_nversio
              FROM detcampanya
             WHERE cactivi = xcactivi
               AND cgarant = pcgarant
               AND sproduc IN(SELECT sproduc
                                FROM productos
                               WHERE cramo = xcramo
                                 AND cmodali = xcmodali
                                 AND ctipseg = xctipseg
                                 AND ccolect = xccolect)
               AND NVL(finicam, f_sysdate - 1) <= f_sysdate
               AND f_sysdate <= NVL(ffincam, f_sysdate + 1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_nversio := -1;
            WHEN OTHERS THEN
               w_nversio := -1;
         END;

         --
         -- Si hay una campaña informada, buscamos su comision
         --
         IF w_nversio >= 0 THEN
            BEGIN
               SELECT pcomisi
                 INTO ppcomisi
                 FROM comisioncamp
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ctipseg = xctipseg
                  AND ccolect = xccolect
                  AND cactivi = xcactivi
                  AND cgarant = pcgarant
                  AND ccomisi = xccomisi
                  AND cmodcom = pcmodcom
                  AND ccampanya = w_ccampanya
                  AND nversion = w_nversio;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 110986;
               WHEN OTHERS THEN
                  RETURN 110986;
            END;
         ELSE
            BEGIN
               SELECT pcomisi
                 INTO ppcomisi
                 FROM comisiongar cg
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ctipseg = xctipseg
                  AND ccolect = xccolect
                  AND cactivi = xcactivi
                  AND cgarant = pcgarant
                  AND ccomisi = xccomisi
                  AND cmodcom = pcmodcom
                  --Bug.: 18852 - 08/09/2011 - ICV
                  AND NVL(xnanuali, 1) BETWEEN ninialt AND nfinalt
                  AND EXISTS(SELECT finivig
                               FROM comisionvig
                              WHERE ccomisi = xccomisi
                                AND cestado = 2
                                AND cg.finivig <= NVL(ffinvig, TRUNC(pfecha))
                                AND TRUNC(pfecha) BETWEEN finivig AND NVL(ffinvig,
                                                                          TRUNC(pfecha)));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT pcomisi
                       INTO ppcomisi
                       FROM comisionacti ca
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cmodcom = pcmodcom
                        AND ccomisi = xccomisi
                        AND cactivi = xcactivi
                        --Bug.: 18852 - 08/09/2011 - ICV
                        AND NVL(xnanuali, 1) BETWEEN ninialt AND nfinalt
                        AND EXISTS(SELECT finivig
                                     FROM comisionvig
                                    WHERE ccomisi = xccomisi
                                      AND cestado = 2
                                      AND ca.finivig <= NVL(ffinvig, TRUNC(pfecha))
                                      AND TRUNC(pfecha) BETWEEN finivig
                                                            AND NVL(ffinvig, TRUNC(pfecha)));
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT pcomisi
                             INTO ppcomisi
                             FROM comisionprod cp
                            WHERE cramo = xcramo
                              AND cmodali = xcmodali
                              AND ctipseg = xctipseg
                              AND ccolect = xccolect
                              AND cmodcom = pcmodcom
                              AND ccomisi = xccomisi
                              --Bug.: 18852 - 08/09/2011 - ICV
                              AND NVL(xnanuali, 1) BETWEEN ninialt AND nfinalt
                              AND EXISTS(SELECT finivig
                                           FROM comisionvig
                                          WHERE ccomisi = xccomisi
                                            AND cestado = 2
                                            AND cp.finivig <= NVL(ffinvig, TRUNC(pfecha))
                                            AND TRUNC(pfecha) BETWEEN finivig
                                                                  AND NVL(ffinvig,
                                                                          TRUNC(pfecha)));
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              RETURN 100933;   -- Comissió inexistent
                           WHEN OTHERS THEN
                              RETURN 103216;
                        --Error al llegir la taula COMISIONPROD
                        END;
                     WHEN OTHERS THEN
                        RETURN 103628;   -- Error al llegir la taula COMISIONACTI
                  END;
               WHEN OTHERS THEN
                  RETURN 110824;   -- Error leyendo la tabla COMISIONGAR
            END;
         END IF;

         RETURN 0;
      END f_local_comhabitual;
-- fin Bug 0019682 - 26/10/2011 - JMF
   BEGIN
      IF pcmodcom IS NULL
         OR pfretenc IS NULL THEN
         RETURN 100900;
      -- se han entrado valores nulos en parámetros OBLIGATORIOS
      END IF;

      IF psseguro IS NOT NULL
         AND pfuncion = 'CAR' THEN
         BEGIN
            SELECT ctipcom, cagente, cramo, cmodali, ctipseg, ccolect, cactivi,
                   nanuali
              INTO xctipcom, xcagente, xcramo, xcmodali, xctipseg, xccolect, xcactivi,
                   xnanuali
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 100500;   -- sseguro no encontrado
         END;
      ELSIF pfuncion = 'TAR' THEN
         IF pttabla = 'EST' THEN
            BEGIN
               SELECT cagente, cramo, cmodali, ctipseg, ccolect, cactivi, nanuali
                 INTO xcagente, xcramo, xcmodali, xctipseg, xccolect, xcactivi, xnanuali
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 100500;
            END;
         ELSIF pttabla = 'SOL' THEN
            BEGIN
               SELECT cagente, cramo, cmodali, ctipseg, ccolect, cactivi, 1
                 INTO xcagente, xcramo, xcmodali, xctipseg, xccolect, xcactivi, xnanuali
                 FROM solseguros
                WHERE ssolicit = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 100500;
            END;
         END IF;
      ELSE
         xctipcom := 0;
         xcagente := pcagente;
         xcramo := pcramo;
         xcmodali := pcmodali;
         xccolect := pccolect;
         xctipseg := pctipseg;
         xcactivi := pcactivi;
         xnanuali := 1;
      END IF;

      -- CRE_145 - 22/07/2008
      -- Buscamos los posibles gastos externos modificados
      -- estos sustituirán a la comisión comercial a aplicar
      IF psseguro IS NOT NULL THEN
         IF pfuncion = 'CAR' THEN
            xgastoext := f_gastext('SEG', psseguro, pcgarant);
            vcomisextra := f_comision_extra('SEG', psseguro, pcgarant);
         ELSIF pfuncion = 'TAR' THEN
            IF pttabla = 'EST' THEN
               xgastoext := f_gastext('EST', psseguro, pcgarant);
               vcomisextra := f_comision_extra('EST', psseguro, pcgarant);
            ELSIF pttabla = 'SOL' THEN
               xgastoext := f_gastext('SOL', psseguro, pcgarant);
               vcomisextra := f_comision_extra('SOL', psseguro, pcgarant);
            END IF;
         END IF;
      END IF;

      BEGIN
         SELECT cretenc, ccomisi
           INTO xcretenc, xccomisi
           FROM agentes
          WHERE cagente = xcagente;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100504;   -- Agent inexistent
      END;

      IF xgastoext IS NOT NULL THEN   --> CRE_145 - Si existe gasto externo este será la comisión
         ppcomisi := xgastoext;
      ELSE
         IF xctipcom = 99 THEN   -- Forzada a 0
            ppcomisi := 0;
         ELSIF xctipcom = 0 THEN   -- La habitual
            -- ini Bug 0019682 - 26/10/2011 - JMF
            num_error := f_local_comhabitual;

            IF num_error <> 0 THEN
               RETURN num_error;
            END IF;
         -- fin Bug 0019682 - 26/10/2011 - JMF
         --ELSIF xctipcom = 90 THEN   --Comissió especial
         ELSIF xctipcom IN(90, 92) THEN   --Comissió especial  -- BUG 25214 - FAL - 25/01/2013
            -- ini Bug 0019682 - 26/10/2011 - JMF
            IF NVL(f_pargaranpro_v(xcramo, xcmodali, xctipseg, xccolect, xcactivi, pcgarant,
                                   'AFECTA_COMISESPECIAL'),
                   1) = 1 THEN
               -- Comision especial
               BEGIN
                  SELECT pcomisi
                    INTO ppcomisi
                    FROM comisionsegu
                   WHERE sseguro = psseguro
                     AND NVL(xnanuali, 1) BETWEEN ninialt AND nfinalt
                     AND cmodcom = pcmodcom
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM comisionsegu
                                     WHERE sseguro = psseguro);   -- Bug 30642/169851 - 20/03/2014 - AMC
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 100933;   -- Comissió inexistent
                  WHEN OTHERS THEN
                     RETURN 103627;   --Error al llegir la taula COMISIONSEGU
               END;
            ELSE
               -- Comision habitual
               num_error := f_local_comhabitual;

               IF num_error <> 0 THEN
                  RETURN num_error;
               END IF;
            END IF;
         -- fin Bug 0019682 - 26/10/2011 - JMF
         ELSE
            RETURN 100947;   -- valor no válido en SEGUROS (ctipcom)
         END IF;
      END IF;

   --JRH 11/2011 Lo he movido de sitio
-- Bug 19873 - 25/10/2011 - JRH - 0019873: GIP003-Comisión de Cobro
      ppcomisi := ppcomisi + NVL(vcomisextra, 0);

                                                 --Aquí está el tema, le añadimos una sobrecomisión
-- Fi Bug 19873 - 25/10/2011 - JRH
      BEGIN
         SELECT pretenc
           INTO ppretenc
           FROM retenciones
          WHERE cretenc = xcretenc
            AND TRUNC(pfretenc) >= TRUNC(finivig)
            AND TRUNC(pfretenc) < TRUNC(NVL(ffinvig, pfretenc + 1));

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100726;   -- retención no encontrada
      END;

      RETURN(0);
   END f_pcomisi_correduria;
END pac_listado_cartera;

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTADO_CARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADO_CARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTADO_CARTERA" TO "PROGRAMADORESCSI";
