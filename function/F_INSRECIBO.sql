--------------------------------------------------------
--  DDL for Function F_INSRECIBO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "AXIS"."F_INSRECIBO" (
   psseguro IN NUMBER,
   pcagente IN NUMBER,
   pfemisio IN DATE,
   pfefecto IN DATE,
   pfvencim IN DATE,
   pctiprec IN NUMBER,
   pnanuali IN NUMBER,
   pnfracci IN NUMBER,
   pccobban IN NUMBER,
   pcestimp IN NUMBER,
   pnriesgo IN NUMBER,
   pnrecibo IN OUT NUMBER,
   pmodo IN VARCHAR2,
   psproces IN NUMBER,
   pcmovimi IN NUMBER,
   pnmovimi IN NUMBER,
   pfmovini IN DATE,
   ptipo IN VARCHAR2 DEFAULT NULL,
   pcforpag IN NUMBER DEFAULT NULL,
-- Si es passen el par¿metres
   pcbancar IN VARCHAR2 DEFAULT NULL,
--  no s'agafen de seguros (dades de l'aportant)
   pttabla IN VARCHAR2 DEFAULT NULL,
   pfuncion IN VARCHAR2 DEFAULT 'CAR',
   pctipban IN NUMBER DEFAULT NULL,
   pcdomper IN NUMBER DEFAULT NULL,   -- BUG 21924 - MDS - 22/06/2012
   pcsubtiprec IN NUMBER DEFAULT NULL ) -- IAXIS-7179 13/11/2019
   RETURN NUMBER  IS
/****************************************************************************
   F_INSRECIBO : Insertar un registro en la tabla de recibos.
   A Gesti¿n de datos referentes a los recibos
    Controlar error de si f_contador retorna 0
   (quiere decir que nrecibo = 0 (error))
    Afegim les insercions en RECIBOSREDCOM
    Afegim el camp CDELEGA a la taula RECIBOS
    Afegim els par¿metres pnriesgo, psmovseg,
   i la funci¿ f_movrecibo.
   Segons el nou par¿metre pmodo, s' ha de
   grabar a la taula RECIBOS o RECIBOSCAR(es graba el nou par¿metre
   psproces).
   S' afegeix la funci¿ f_insrecibor, per a grabar
   les dades a la xarxa comercial.
   Per correduria s'informen els camps cestaux y cestimp.
   De la select principal, se recuperan ctipemp y cforpag.
   S'afegeix el nou mode ='H' per rehabilitaci¿ de riscos i
                 garanties.
    Traballi amb l'agent de venda i permeti digits control "00"
 Si P_CCOBBAN es nulo hac¿a que el RECIBOS.CESTIMP se grabara
      con un 1 de pendiente de imprimir, incluso cuando el recibo es bancario,
      corregida 1a select para que lo decida dependiendo el CCOBBAN que grabamos en el recibo.

  {Se a¿aden los parametros funcion y tabla para el calculo del primer recibo al tarifar,
   el parametro tabla indica a que tablas tiene que ir a buscar importes ('EST','SOL',NULLL),
   el parametro funci¿n indica si estoy tarifando (TAR) o en la cartera o previo de cartera (CAR)
  }
   Se a¿ade el ctipban (tipo de CCC) y se mofica la llamada a F_CCC

  Ver    Fecha       Autor  Descripci¿n
  -----  ----------  -----  -------------------------------------
   1.0   XX/XX/XXXX  XXX    1. Creaci¿n de la funci¿n.
   2.0   05/01/2012  JGR    2. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico
   3.0   16/01/2012  JGR    3. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico (correcci¿n)
   4.0   23/01/2012  JMF    4. 0020761 LCOL_A001- Quotes targetes
   5.0   21/06/2012  JGR    5. 0022082 LCOL_A003-Mantenimiento de matriculas -
   6.0   22/06/2012  MDS    6. 0021924: MDP - TEC - Nuevos campos en pantalla de Gesti¿n (Tipo de retribuci¿n, Domiciliar 1¿ recibo, Revalorizaci¿n franquicia)
   7.0   01/08/2012  FPG    7. 0023075: LCOL_T010-Figura del pagador
   8.0   06/08/2012  APD    8. 0022494: MDP_A001- Modulo de relacion de recibos
   9.0   20/11/2012  lcf    9. 0024753: MDP - Trazas en las funciones de generaci¿n de recibos cuando se produce error
  10.0   20/11/2012  JGR   10. 0025151: LCOL999-Redef. circuito prenotificaciones - 0139714
  11.0   13/05/2013  JGR   11. 0026956: Detectado que en algunos casos no agrupa bien los recibos de NOTIFIACIONES - 0144367
  12.0   18/06/2013  JGR   12. 0027366: Error en subestado de recibos al momento de emisi¿n de la p¿liza - QT-8129
  13.0   21/06/2013  JGR   13. 0027411: Error al generar m¿s de un n¿mero de matr¿cula - QT-8145 - Final
  14.0   16/10/2013  MMM   14. 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago
  15.0   28/11/2014  FAL   15. 0031135: Montar Entorno Colmena en VAL. 31135/0193251
  16.0   23/10/2019  DFR   16. IAXIS-4926: Anulación de póliza y movimientos con recibos abonados y Reversión de recaudos en recibos.
  17.0   13/11/2019  DFR   17. IAXIS-7179: ERROR EN LA INSERCIÓN DEL EXTORNO 
****************************************************************************/

   -- ini BUG 0020761 - 23/01/2012 - JMF
   vobj           VARCHAR2(200) := 'F_INSRECIBO';
   vpas           NUMBER := 1;
   vpar           VARCHAR2(500)
      := SUBSTR('s=' || psseguro || ' a=' || pcagente || ' emi=' || pfemisio || ' efe='
                || pfefecto || ' v=' || pfvencim || ' t=' || pctiprec || ' a=' || pnanuali
                || ' f=' || pnfracci || ' b=' || pccobban || ' i=' || pcestimp || ' r='
                || pnriesgo || ' n=' || pnrecibo || ' m=' || pmodo || ' p=' || psproces
                || ' c=' || pcmovimi || ' n=' || pnmovimi || ' m=' || pfmovini || ' t='
                || ptipo || ' f=' || pcforpag || ' b=' || pcbancar || ' t=' || pttabla
                || ' f=' || pfuncion || ' t=' || pctipban,
                1, 500);
   -- fin BUG 0020761 - 23/01/2012 - JMF
   error          NUMBER := 0;
   num_err        NUMBER := 0;
   xcagente       NUMBER;
   xnanuali       NUMBER;
   xnfracci       NUMBER;
   xccobban       NUMBER;
   xcestimp       NUMBER;
   xcempres       NUMBER;
   xsmovrec       NUMBER;
   xnliqmen       NUMBER;
   xcforpag       NUMBER;
   xcbancar       seguros.cbancar%TYPE;
   dummy          NUMBER;
   xnbancar       seguros.cbancar%TYPE;
   xnbancarf      seguros.cbancar%TYPE;
   xtbancar       seguros.cbancar%TYPE;
   xncuacoa       NUMBER;   -- Coaseguro
   xctipcoa       NUMBER;
   xcestaux       NUMBER;
   xcestsop       NUMBER;   -- generacion de soportes
   xfmovim        DATE;
   xnperven       NUMBER;
   xcdelega       NUMBER;
   xctipemp       NUMBER;
   xctippag       NUMBER;
   xccarpen       NUMBER;
   xcgescob       NUMBER;
   quants         NUMBER;
   xcperven       NUMBER;
   xcdelega2      NUMBER;
   xctipban       seguros.ctipban%TYPE;
   xctipcob       seguros.ctipcob%TYPE;   -- Bug 0020010 - 08/11/2011 - JMF
   xcbancob       NUMBER(1);
   xcmanual       NUMBER(1);
   -- Bug 7854 - 11/02/2009 - RSC - Recibo del certificado cero.
   xesccero       NUMBER := 0;
   -- Bug 9383 - 05/03/2009 - RSC - CRE - Unificaci¿n de recibos
   xsproduc       productos.sproduc%TYPE;
   xcerosseguro   seguros.sseguro%TYPE;
   xcerocagente   seguros.cagente%TYPE;
   xceroccobban   seguros.ccobban%TYPE;
   xcerocbancar   seguros.cbancar%TYPE;
   xceronbancar   seguros.cbancar%TYPE;
   xcerotbancar   seguros.cbancar%TYPE;
   xceroctipban   seguros.ctipban%TYPE;
   -- Bug 7854 - 11/02/2009 - RSC - Recibo del certificado cero.
   dummy1         NUMBER;
   dummy2         seguros.cbancar%TYPE;
   xncuotar       seguros.ncuotar%TYPE;   -- BUG 0020761 - 23/01/2012 - JMF
   -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - inicio
   xcexistepagador tomadores.cexistepagador%TYPE;
   xsperson_pagador per_personas.sperson%TYPE;
   xsperson_notif per_personas.sperson%TYPE;   -- 10. 0025151 - 0139714
-- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - fin

-- 13.0 0027411: Error al generar m¿s de un n¿mero de matr¿cula - QT-8145 - Inicial
-- 13.0 0027411: Se traslada esta funci¿n al PAC_PRENOTIFICACIONES

--   -- 2.0   05/01/2012  JGR    2. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico - Inicio
--   -- Las cuentas pendientes de prenotificar (matricular) han de generar RECIBOS.CESTIMP = 11 - Pendiente de prenotificaci¿n
--   FUNCTION f_cestimp_prenotif(
--      ppsseguro IN NUMBER,
--      pcempres IN NUMBER,
--      pcbancar IN VARCHAR2,
--      pctipban IN NUMBER,   -- 10. 0025151 - 0139714
--      psperson IN NUMBER,   -- 10. 0025151 - 0139714
--      pccobban IN NUMBER,
--      pcestimp IN OUT NUMBER)
--      RETURN NUMBER IS
--      vvalidada      NUMBER;
--      vcnotifi       NUMBER;
--      -- 9  0024753: MDP - Trazas en las funciones de generaci¿n de recibos cuando se produce error
--      vobj           VARCHAR2(200) := 'f_cestimp_prenotif';
--      vpas           NUMBER := 1;
--      vpar           VARCHAR2(500)
--         -- 10. 0025151 - 0139714 - Inicio
--      := SUBSTR('pcempres=' || pcempres || ' pcbancar=' || pcbancar || ' psseguro='
--                || psseguro || ' pctipban=' || pctipban || ' psperson=' || psperson
--                || ' pccobban=' || pccobban || ' pcestimp=' || pcestimp,
--                1, 500);
--         /*
--         := SUBSTR('n=' || pcempres || ' f=' || pcbancar || ' s=' || psseguro || ' g='
--                   || pccobban || ' pp=' || pcestimp,
--                   1, 500);
--         */
--      -- 10. 0025151 - 0139714 - Final
--      --9. 0024753: MDP - Trazas en las funciones de generaci¿n de recibos cuando se produce error
--      -- 10. 0025151 - 0139714 - Inicio
--      vctipcc        tipos_cuenta.ctipcc%TYPE;
--      vctipide       notificaciones.ctipide%TYPE;
--      vnnumide       notificaciones.nnumide%TYPE;
--   -- 10. 0025151 - 0139714 - Final
--   BEGIN
--      vpas := 100;

--      -- El recibo le toca inicialmente estar 4- pendiente de domiciliar
--      IF pcestimp = 4
--         AND pcbancar IS NOT NULL
--         AND pctipban IS NOT NULL   -- 10. 0025151 - 0139714
--                                 THEN
--         BEGIN
--            vpas := 110;

--            SELECT cnotifi
--              INTO vcnotifi
--              FROM cobbancario
--             WHERE ccobban = pccobban;

--            -- El cobrador bancario requiere prenotificaci¿n
--            IF vcnotifi = 1 THEN
--               vpas := 120;

--               -- 5. 0022082 LCOL_A003-Mantenimiento de matriculas - Inicio
--               /*
--               SELECT COUNT(1)
--                 INTO vvalidada
--                 FROM per_ccc p, tomadores t
--                WHERE p.cvalida = 4   -- Validada o matriculada
--                  AND p.cbancar = pcbancar
--                  AND p.sperson = t.sperson
--                  AND t.sseguro = ppsseguro;

--               -- La cuenta bancaria no est¿ validada
--               IF vvalidada = 0 THEN
--                  pcestimp := 11;   -- Pdte. prenotificaci¿n
--               END IF;
--               */
--               -- 10. 0025151: LCOL999-Redef. circuito prenotificaciones - 0139714 - Inicio
--               /*
--               SELECT NVL(MAX(cnotest), 0)
--                 INTO vvalidada
--                 FROM notificaciones n, seguros s
--                WHERE n.sseguro = psseguro
--                  AND s.sseguro = psseguro
--                  AND n.cbancar = pcbancar
--                  AND NVL(pac_redcomercial.f_busca_padre(n.cempres, n.cagente, NULL, NULL), 0) =
--                        NVL(pac_redcomercial.f_busca_padre(n.cempres, s.cagente, NULL, NULL),
--                            0);
--               */
--               -- 12. 0027366: Error en subestado de recibos al momento de emisi¿n de la p¿liza - QT-8129 - Inicio
--               /*
--                  SELECT ctipcc
--                    INTO vctipcc
--                    FROM tipos_cuenta
--                   WHERE ctipban = pctipban;
--               */
--               BEGIN
--                  SELECT ctipcc
--                    INTO vctipcc
--                    FROM tipos_cuenta
--                   WHERE ctipban = pctipban;
--               EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                     vctipcc := NULL;
--               END;

--               IF vctipcc IS NULL THEN
--                  RETURN 180928;   -- Error al buscar la descripci¿n de tipo o formato de cuenta ccc
--               END IF;

--               -- 12. 0027366: Error en subestado de recibos al momento de emisi¿n de la p¿liza - QT-8129 - Final
--               vpas := 130;

--               SELECT nnumide, ctipide
--                 INTO vnnumide, vctipide
--                 FROM per_personas
--                WHERE sperson = psperson;

--               vpas := 140;

--               -- 11. 0026956: Detectado que en algunos casos no agrupa bien los recibos de NOTIFICACIONES - 0144367 - Inicio
--               /*
--               SELECT NVL(MAX(cnotest), 0)
--                 INTO vvalidada
--                 FROM notificaciones n
--                WHERE (n.ctipcc = vctipcc
--                       OR n.ctipcc IS NULL)
--                  AND(n.ctipide = vctipide
--                      OR n.ctipide IS NULL)
--                  AND(n.nnumide = vnnumide
--                      OR n.nnumide IS NULL)
--                  AND n.cbancar = pcbancar;
--               */
--               BEGIN
--                  -- 12. 0027366: Error en subestado de recibos al momento de emisi¿n de la p¿liza - QT-8129 - Inicio
--                   /*
--                     SELECT DISTINCT 1
--                                INTO vvalidada
--                                FROM notificaciones n
--                               WHERE (n.ctipcc = vctipcc
--                                      OR n.ctipcc IS NULL)
--                                 AND(n.ctipide = vctipide
--                                     OR n.ctipide IS NULL)
--                                 AND(n.nnumide = vnnumide
--                                     OR n.nnumide IS NULL)
--                                 AND n.cbancar = pcbancar
--                                 AND n.cnotest = 0   --> Respuesta es OK
--                                 AND n.tfiledev IS NOT NULL;   --> Hay respuesta y bancaria
--                   */
--                  SELECT DISTINCT 1
--                             INTO vvalidada
--                             FROM notificaciones n
--                            WHERE n.ctipcc = vctipcc
--                              AND n.ctipide = vctipide
--                              AND n.nnumide = vnnumide
--                              AND n.cbancar = pcbancar
--                              AND n.cnotest = 0   --> Respuesta es OK
--                              AND n.tfiledev IS NOT NULL;   --> Hay respuesta y bancaria
--               -- 12. 0027366: Error en subestado de recibos al momento de emisi¿n de la p¿liza - QT-8129 - Final
--               EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                     pcestimp := 11;   -- Pendiente de prenotificaci¿n
--                  WHEN OTHERS THEN
--                     RETURN 9905554;   -- Error al leer el estado de la notificaci¿n
--               END;

--               vpas := 150;
--            -- 10. 0025151: LCOL999-Redef. circuito prenotificaciones - 0139714 - Fin
--            /*
--            IF vvalidada = 0 THEN
--               pcestimp := 11;   -- Pendiente de prenotificaci¿n
--            END IF;
--            */
--            -- 11. 0026956: Detectado que en algunos casos no agrupa bien los recibos de NOTIFICACIONES - 0144367 - Inicio

--            -- 5. 0022082 LCOL_A003-Mantenimiento de matriculas - Inicio
--            END IF;
--         EXCEPTION
--            WHEN OTHERS THEN
--               -- 6- 0024753: MDP - Trazas en las funciones de generaci¿n de recibos cuando se produce error
--               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
--                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
--                           || 'error = ' || 103941);
--               -- Error al leer la tabla COBBANCARIO
--               RETURN 103941;
--         END;
--      END IF;

--      RETURN 0;
--   END;
---- 2.0   05/01/2012  JGR    2. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico - Fi

-- 13.0 0027411: Error al generar m¿s de un n¿mero de matr¿cula - QT-8145 - Final
/*
    CURSOR c_rango_dian(vcagente NUMBER, vsproduc NUMBER) IS
      SELECT NCONTADOR, NRESOL FROM RANGO_DIAN
          WHERE CAGENTE = (SELECT C02 FROM ageredcom WHERE cagente = vcagente)
          AND   SPRODUC = xsproduc
          AND   CRAMO   = (SELECT CRAMO FROM PRODUCTOS WHERE SPRODUC = xsproduc)
		  AND F_SYSDATE BETWEEN FINIVIG AND FFINVIG;
*/
BEGIN
   vpas := 130;

   IF pttabla = 'SOL' THEN
      BEGIN
         vpas := 140;

         -- BUG 0020761 - 23/01/2012 - JMF : afegir ncuotar
         SELECT NVL(pcagente, s.cagente), DECODE(NVL(a.csoprec, 0), 0, 0, 1),   -- estado de soporte
                NVL(pcestimp, DECODE(a.csoprec, 2, 0, DECODE(pccobban, NULL, 1, 4))),
                -- est. de imp.
                s.cforpag, p.ctippag, p.ccarpen, 1 cempres, p.sproduc   -- RSC 04/03/2009
                                                                     , NULL
           INTO xcagente, xcestsop,
                xcestimp,
                xcforpag, xctippag, xccarpen, xcempres, xsproduc, xncuotar
           FROM agentes a, solseguros s, productos p
          WHERE s.ssolicit = psseguro
            AND a.cagente = s.cagente
            AND s.cramo = p.cramo
            AND s.cmodali = p.cmodali
            AND s.ctipseg = p.ctipseg
            AND s.ccolect = p.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903;   -- Asseguran¿a no trobada a SEGUROS
         WHEN OTHERS THEN
            ---
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || 101919);
            RETURN 101919;   -- Error al llegir de SEGUROS
      END;
   ELSIF pttabla = 'EST' THEN
      BEGIN
         vpas := 150;

         -- BUG 0020761 - 23/01/2012 - JMF : afegir ncuotar
         SELECT NVL(pcagente, s.cagente), NVL(pnanuali, s.nanuali), NVL(pnfracci, s.nfracci),
                NVL(pccobban, s.ccobban), DECODE(NVL(a.csoprec, 0), 0, 0, 1),   -- estado de soporte
                NVL(pcestimp, DECODE(a.csoprec, 2, 0, DECODE(pccobban, NULL, 1, 4))),
                -- est. de imp.
                s.cforpag, s.cbancar, s.ncuacoa, s.ctipcoa, s.cempres, e.ctipemp, p.ctippag,
                p.ccarpen,   --, s.cgescob
                          s.ctipban, s.ctipcob, p.sproduc   -- RSC 04/03/2009
                                                         , s.ncuotar
           INTO xcagente, xnanuali, xnfracci,
                xccobban, xcestsop,
                xcestimp,
                xcforpag, xcbancar, xncuacoa, xctipcoa, xcempres, xctipemp, xctippag,
                xccarpen,   --, xcgescob
                         xctipban, xctipcob, xsproduc, xncuotar
           FROM agentes a, estseguros s, empresas e, productos p
          WHERE s.sseguro = psseguro
            AND a.cagente = s.cagente
            AND e.cempres = s.cempres
            AND s.cramo = p.cramo
            AND s.cmodali = p.cmodali
            AND s.ctipseg = p.ctipseg
            AND s.ccolect = p.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903;   -- Asseguran¿a no trobada a SEGUROS
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || 101919);
            RETURN 101919;   -- Error al llegir de SEGUROS
      END;

      -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - inicio
      vpas := 155;
      xsperson_pagador := NULL;
      xsperson_notif := NULL;   -- 10. 0025151 - 0139714

      BEGIN
         SELECT NVL(t.cexistepagador, 0), sperson   -- 10. 0025151 - 0139714
           INTO xcexistepagador, xsperson_notif   -- 10. 0025151 - 0139714
           FROM esttomadores t
          WHERE t.sseguro = psseguro
            AND t.nordtom = (SELECT MIN(nordtom)
                             FROM esttomadores t2
                             WHERE t2.sseguro = t.sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 105111;   -- Tomador no encontrado en la tabla TOMADORES.
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || 105112);
            RETURN 105112;   -- Error al leer de la tabla TOMADORES.
      END;

      vpas := 156;

      IF xcexistepagador = 1 THEN
         BEGIN
            SELECT g.sperson
              INTO xsperson_pagador
              FROM estgescobros g
             WHERE g.sseguro = psseguro;

            xsperson_notif := xsperson_pagador;   -- 10. 0025151 - 0139714
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9904084;   -- Gestor de cobro / Pagador no encontrado en la tabla ESTGESCOBROS.
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 9904085);
               RETURN 9904085;   -- Error al leer en la tabla ESTGESCOBROS.
         END;
      END IF;
   -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - final
   ELSE
      BEGIN
         vpas := 160;

         -- BUG 0020761 - 23/01/2012 - JMF : afegir ncuotar
         SELECT NVL(pcagente, s.cagente), NVL(pnanuali, s.nanuali), NVL(pnfracci, s.nfracci),
                NVL(pccobban, s.ccobban), DECODE(NVL(a.csoprec, 0), 0, 0, 1),   -- estado de soporte
                NVL(pcestimp,
                    DECODE(a.csoprec, 2, 0, DECODE(NVL(pccobban, s.ccobban), NULL, 1, 4))),
                -- est. de imp.
                NVL(pcforpag, s.cforpag), NVL(pcbancar, s.cbancar), NVL(pctipban, s.ctipban),
                s.ncuacoa, s.ctipcoa, s.cempres, e.ctipemp, p.ctippag, p.ccarpen, s.ctipcob,
                p.sproduc   -- RSC 04/03/2009
                         , s.ncuotar
           INTO xcagente, xnanuali, xnfracci,
                xccobban, xcestsop,
                xcestimp,
                xcforpag, xcbancar, xctipban,
                xncuacoa, xctipcoa, xcempres, xctipemp, xctippag, xccarpen, xctipcob,
                xsproduc, xncuotar
           FROM agentes a, seguros s, empresas e, productos p
          WHERE s.sseguro = psseguro
            AND a.cagente = s.cagente
            AND e.cempres = s.cempres
            AND s.cramo = p.cramo
            AND s.cmodali = p.cmodali
            AND s.ctipseg = p.ctipseg
            AND s.ccolect = p.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903;   -- Asseguran¿a no trobada a SEGUROS
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || 101919);
            RETURN 101919;   -- Error al llegir de SEGUROS
      END;

      -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - inicio
      vpas := 165;
      xsperson_pagador := NULL;
      xsperson_notif := NULL;   -- 10. 0025151 - 0139714

      BEGIN
         SELECT NVL(t.cexistepagador, 0), sperson   -- 10. 0025151 - 0139714
           INTO xcexistepagador, xsperson_notif   -- 10. 0025151 - 0139714
           FROM tomadores t
          WHERE t.sseguro = psseguro
            AND t.nordtom = (SELECT MIN(nordtom)
                             FROM tomadores t2
                             WHERE t2.sseguro = t.sseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 105111;   -- Tomador no encontrado en la tabla TOMADORES.
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || 105112);
            RETURN 105112;   -- Error al leer de la tabla TOMADORES.
      END;

      vpas := 166;

      IF xcexistepagador = 1 THEN
         BEGIN
            SELECT g.sperson
              INTO xsperson_pagador
              FROM gescobros g
             WHERE g.sseguro = psseguro;

            xsperson_notif := xsperson_pagador;   -- 10. 0025151 - 0139714
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9904082;   -- Gestor de cobro / Pagador no encontrado en la tabla GESCOBROS.
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 9904083);
               RETURN 9904083;   -- Error al leer en la tabla GESCOBROS.
         END;
      END IF;
   -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - final
   END IF;

   -- Ini Bug 21924 - MDS - 20/06/2012
   IF pcdomper = 1 THEN
      xccobban := NULL;
      xcestimp := 1;
   END IF;

   -- Fin Bug 21924 - MDS - 20/06/2012
   vpas := 170;

   -- 2.0   05/01/2012  JGR    2. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico - Fin
   IF xctipcoa = 8 THEN   -- Es un coaseguro aceptado de recibo unico
      xcestimp := 0;   -- No debe imprimirse
   END IF;

   IF xctipcoa = 8
      OR xctipcoa = 9 THEN   -- Es un coaseguro aceptado
      xcestaux := 1;   -- Recibo retenido (por ser de coaseguro)
   ELSE
      xcestaux := 0;   -- Recibo v¿lido (¿til, en vigor)
   END IF;

   vpas := 180;

   -- Bug 9383 - 05/03/2009 - RSC - CRE - Unificaci¿n de recibos
   --BUG 14438 - JTS - 02/05/2010
   IF NVL(f_parproductos_v(xsproduc, 'RECUNIF'), 0) IN(1, 3) THEN   -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
      IF (pctiprec = 3
          AND NVL(ptipo, 'NO') = 'CERTIF0')   -- Recibos de cartera de certificado 0
         OR(NVL(f_parproductos_v(xsproduc, 'RECUNIF_NP'), 0) = 1
            AND NVL(ptipo, 'NO') = 'CERTIF0') THEN
         xcestaux := 2;
      END IF;
   END IF;

   --Fi BUG 14438
   vpas := 190;

   IF xcbancar IS NOT NULL THEN
      xnbancar := xcbancar;   --TO_NUMBER (xcbancar); JFD 01/10/2007
      --error       := f_ccc (xnbancar, dummy, xnbancarf);
      error := f_ccc(xnbancar, xctipban, dummy, xnbancarf);

      IF error = 0
         OR(error = 102493
            AND f_parinstalacion_n('DIGICTRL00') = 1) THEN
         --> Permite d¿gito control = '00'
         xtbancar := xcbancar;   ---LPAD (xnbancarf, 20, '0');JFD 01/10/2007
      ELSE
         RETURN error;
      END IF;
   END IF;

   -- Per correduria s'informen els camps cestaux y cestimp.
   -- Afegim el camp cgescob (1 - Cobra la corredoria, 2 - Cobra la cia)
   --                 Afegim el control de si cal que quedin pendents de validar els
   --                 rebuts de cartera (ccarpen = 0 NO, 1 Si)
   vpas := 200;

   IF NVL(xctipemp, 0) = 1 THEN   -- Correduria
      --
      -- Rebuts pendents de validar xccarpen : 0 - No , 1 - Cartera, 2 - NP i Cartera
      --
      IF (pctiprec <> 0)
         AND NVL(xccarpen, 0) <> 0 THEN
         xcestaux := 1;
      -- Pendent de validar amb la cia. els que no son nova producci¿
      ELSIF NVL(xccarpen, 0) = 2 THEN
         xcestaux := 1;   -- Pendent de validar amb la cia.
      ELSE
         xcestaux := 0;
      END IF;

      -- Bug 9383 - 05/03/2009 - RSC - CRE - Unificaci¿n de recibos
      vpas := 210;

      IF NVL(f_parproductos_v(xsproduc, 'RECUNIF'), 0) IN(1, 3) THEN   -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
         IF pctiprec = 3
            AND NVL(ptipo, 'NO') = 'CERTIF0' THEN   -- Recibos de cartera de certificado 0
            xcestaux := 2;
         END IF;
      END IF;

      --
      -- Gestio de cobrament ctippag : 3 - Gestiona la cia, 4 - Gest. Cia excepte 1¿ rebut
      --
      xcgescob := 1;   -- Gestiona Corredoria

      IF pctiprec = 0
         AND xctippag = 3 THEN   -- NP i gestiona la Cia
         xcestimp := 0;   -- No imprimible
         xcgescob := 2;   -- Gesti¿ de cobrament la cia
      END IF;

      IF (pctiprec <> 0)
         AND xctippag IN(3, 4) THEN   -- Cobra la cia.
         xcestimp := 0;
         xcgescob := 2;
      END IF;
   END IF;

   vpas := 220;
   xcdelega := f_delega(psseguro, pfefecto);

   -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrizaci¿n b¿sica producto Vida Individual Pagos Permanentes
   -- A¿adimos 'RRIE'
   IF pmodo = 'R'
      OR pmodo = 'A'
      OR pmodo = 'ANP'
      OR pmodo = 'H'
      OR pmodo = 'RRIE' THEN
      -- !!!! ---- SGA --------- controla si es una polissa provinent del estudis. no s'imprimeix
      IF pctiprec = 0 THEN
         quants := 0;

         BEGIN
            vpas := 230;

            SELECT COUNT(*)
              INTO quants
              FROM cnvpolizas
             WHERE sistema = 'ES'
               AND NVL(f_parinstalacion_t('CODIINST'), ' ') = 'SGA'
               AND sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               quants := 0;
         END;

         IF quants <> 0 THEN
            xcestimp := 0;   -- Es un estudi. No debe imprimirse.
         END IF;
      END IF;

-- !!! -------------------------------------------------------------------
      IF pnrecibo IS NULL
         OR pnrecibo = 0 THEN
         IF NVL(ptipo, 'NO') = 'SI' THEN
            -- Si esta variable esta informada significa que generamos los recibos con una
            -- secuencia "ficticia" por que luego en la emisi¿n de p¿lizas y despues de la cartera se pasar¿ un proceso
            -- que juntara todos los recibos por p¿liza colectiva en uno !

            -- BUG18054:DRA:23/03/2011:Inici
            vpas := 240;

            SELECT seq_nrectmp.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
/*
            IF xcempres = 24 THEN
                FOR var IN c_rango_dian(pcagente, xsproduc) LOOP
                  IF var.NCONTADOR IS NOT NULL THEN
                    pnrecibo := var.NCONTADOR;
                  END IF;

                  UPDATE rango_dian
                      SET NCONTADOR = pnrecibo+1
                     WHERE NRESOL =  var.NRESOL;

                END LOOP;
            END IF;

*/
            vpas := 250;

            INSERT INTO tmp_recibos
                        (sproces, nrecibo, sseguro)
                 VALUES (psproces, pnrecibo, psseguro);
            /****************************************************
            IF xcempres = 1 THEN
               SELECT seq_cont_aln_01.NEXTVAL
                 INTO pnrecibo
                 FROM DUAL;

               INSERT INTO tmp_recibos
                           (sproces, nrecibo, sseguro)
                    VALUES (psproces, pnrecibo, psseguro);
            ELSIF xcempres = 2 THEN
               SELECT seq_cont_aln_02.NEXTVAL
                 INTO pnrecibo
                 FROM DUAL;

               INSERT INTO tmp_recibos
                           (sproces, nrecibo, sseguro)
                    VALUES (psproces, pnrecibo, psseguro);
            ELSIF xcempres = 3 THEN
               SELECT seq_cont_aln_03.NEXTVAL
                 INTO pnrecibo
                 FROM DUAL;

               INSERT INTO tmp_recibos
                           (sproces, nrecibo, sseguro)
                    VALUES (psproces, pnrecibo, psseguro);
            ELSE
               SELECT seq_cont_04.NEXTVAL
                 INTO pnrecibo
                 FROM DUAL;

               INSERT INTO tmp_recibos
                           (sproces, nrecibo, sseguro)
                    VALUES (psproces, pnrecibo, psseguro);
            END IF;
            **************************************************/
         -- buscamos el n¿ de recibo seg¿n la empresa
         ELSE
            vpas := 260;
            pnrecibo := pac_adm.f_get_seq_cont(xcempres);


/*
             IF xcempres = 24 THEN
                FOR var IN c_rango_dian(pcagente, xsproduc) LOOP
                  IF var.NCONTADOR IS NOT NULL THEN
                    pnrecibo := var.NCONTADOR;
                  END IF;

                  UPDATE rango_dian
                      SET NCONTADOR = pnrecibo+1
                     WHERE NRESOL =  var.NRESOL;

                END LOOP;
            END IF;

            */
         /****************************************************
         IF xcempres = 1 THEN
            SELECT seq_cont_01.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         ELSIF xcempres = 2 THEN
            SELECT seq_cont_02.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         ELSIF xcempres = 3 THEN
            SELECT seq_cont_03.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         ELSIF xcempres = 4 THEN
            SELECT seq_cont_04.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         ELSIF xcempres = 5 THEN
            SELECT seq_cont_05.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         ELSIF xcempres = 6 THEN
            SELECT seq_cont_06.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         ELSIF xcempres = 7 THEN
            SELECT seq_cont_07.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         ELSIF xcempres = 8 THEN
            SELECT seq_cont_08.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         ELSE
            SELECT seq_cont_09.NEXTVAL
              INTO pnrecibo
              FROM DUAL;
         END IF;
         ********************************************/
         -- BUG18054:DRA:23/03/2011:Fi
         END IF;

         IF pnrecibo = 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || 102876);
            RETURN 102876;   -- N¿mero incorrecto de recibo devuelto
         END IF;   -- por el contador
      END IF;

      --  Segons el par instal.laci¿ , utilitzarem el peride de venda segons
      --  vendes o meritaci¿
      vpas := 270;
      xcperven := NVL(f_parinstalacion_n('PERMERITA'), 0);

      IF xcperven = 1 THEN
         vpas := 280;
         xnperven := pac_merita.f_permerita(pctiprec, pfemisio, pfefecto, xcempres);
      ELSE
         vpas := 290;
         xnperven := f_perventa(NULL, pfemisio, pfefecto, xcempres);
      END IF;

      --JTS 18/12/2008 APRA 8437
      BEGIN
         vpas := 300;

         SELECT nvalpar
           INTO xcbancob
           FROM parempresas
          WHERE cparam = 'CBANCOB'
            AND cempres = xcempres;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xcbancob := NULL;
            xcmanual := NULL;
      END;

      BEGIN
         -- Bug 10787 - APD - 24/07/2009 - se modifica la condici¿n IF ya que puede ser que
         -- el valor de la variable xcbancob sea 0 y no se quiere que entre en el IF
--         IF xcbancob IS NOT NULL THEN
         IF NVL(xcbancob, 0) = 1 THEN
            IF xcbancob = 1
               AND xctipcob = 2 THEN
               vpas := 310;

               SELECT cbancob
                 INTO xtbancar
                 FROM seg_cbancar
                WHERE sseguro = psseguro
                  --AND nmovimi = pnmovimi --BUG 9868 - 21/04/2009 - JTS
                  AND TRUNC(finiefe) <= TRUNC(pfefecto)
                  --BUG 12897 - 29/01/2010 - JMF
                  --AND NVL(TRUNC(ffinefe), TRUNC(pfefecto)) >= TRUNC(pfefecto);
                  AND NVL(TRUNC(ffinefe), TRUNC(pfefecto) + 1) > TRUNC(pfefecto);

               IF xtbancar IS NULL THEN
                  xcmanual := 1;
                  xcestimp := 1;   --BUG 9868 - 21/04/2009 - JTS
                  xccobban := NULL;
               ELSE
                  xcmanual := 2;
               END IF;
            ELSE
               xcmanual := 1;
               xcestimp := 1;   --BUG 9868 - 21/04/2009 - JTS
               xtbancar := NULL;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xcmanual := 1;
            xcestimp := 1;   --BUG 9868 - 21/04/2009 - JTS
            xtbancar := NULL;
            xccobban := NULL;
      END;

      --JTS
      vpas := 320;

      --  BUG 001248  MCA     28/12/2009
      --
      -- Bug 21924 - MDS - 20/06/2012
      -- a¿adir condici¿n OR (xctipcob = 2 AND pcdomper = 1)
      IF xctipcob = 4
         OR(xctipcob = 2
            AND pcdomper = 1) THEN   --Tipo de cobro Broker
         xcgescob := 3;   -- La gesti¿n del recibo es 'Gestiona Broker'
      ELSE
         xcgescob := NULL;
      END IF;

      --  Fin BUG 001248

      -- Bug 7854 y 8745 - 11/02/2009 - RSC - Adaptaci¿n iAxis a productos colectivos con certificados y
      -- Bug 5467 - 10/02/2009 - RSC - CRE - Desarrollo de sistema de copago
      IF NVL(ptipo, 'NO') = 'CERTIF0' THEN
         xesccero := 1;
         vpas := 330;

         -- Bug 9383 - 05/03/2009 - RSC -  CRE: Unificaci¿n de recibos
         SELECT s1.sseguro, s1.cagente, s1.ccobban, s1.cbancar, s1.ctipban,
                s1.ctipcob, t.sperson
           INTO xcerosseguro, xcerocagente, xceroccobban, xcerocbancar, xceroctipban,
                xctipcob,   -- BUG 31135/0193251 - FAL - 28/11/2014. Informar recibos.sperson con el tomador del Colectivo y tipo cobro con el del colectivo
                         xsperson_pagador
           FROM seguros s1, seguros s2, tomadores t
          WHERE s1.npoliza = s2.npoliza
            AND s1.ncertif = 0
            AND s2.sseguro = psseguro
            AND s1.sseguro = t.sseguro
            AND t.nordtom = (SELECT MIN(nordtom)
                             FROM tomadores t2
                             WHERE t2.sseguro = s1.sseguro);

         -- Bug 9383 - 05/03/2009 - RSC -  CRE: Unificaci¿n de recibos
         IF xcerocbancar IS NOT NULL THEN
            xceronbancar := xcerocbancar;
            vpas := 340;
            error := f_ccc(xceronbancar, xceroctipban, dummy1, dummy2);

            IF error = 0
               OR(error = 102493
                  AND f_parinstalacion_n('DIGICTRL00') = 1) THEN
               xcerotbancar := xcerocbancar;
            ELSE
               RETURN error;
            END IF;
         END IF;

         vpas := 350;
         -- 2.0   05/01/2012  JGR    2. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico - Inicio
         -- Averiguar si se ha de modificar el XCESTIMP del recibo para PRENOTIFICACIONES
         -- 13.0 0027411: Error al generar m¿s de un n¿mero de matr¿cula - QT-8145 - Inicial
         /*
         num_err := f_cestimp_prenotif(psseguro, xcempres, xcerotbancar,
                                       -- 10. 0025151 - 0139714 - Inicio
                                       xceroctipban, xsperson_notif,
                                       -- 10. 0025151 - 0139714 - Fin
                                       xceroccobban, xcestimp);
         */
         num_err := pac_prenotificaciones.f_cestimp_prenotif(xcerosseguro, xcerotbancar,
                                                             xceroctipban, xceroccobban,
                                                             xcestimp);

         -- 13.0 0027411: Error al generar m¿s de un n¿mero de matr¿cula - QT-8145 - Final
         IF num_err != 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || num_err);
            RETURN num_err;
         END IF;

         -- 2.0   05/01/2012  JGR    2. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico - Fin
         BEGIN
            -- Bug 10787 - APD - 24/07/2009 - Campo CTIPCOB a nivel de recibo
            -- se a¿ade el campo ctipcob en la tabla recibos
            -- se informa su valor con el valor que tenga en ese momento el
            -- campot ctipcob de la tabla seguros

            -- Bug 11905 - 12/11/2009 - RSC - CRE201- Error en el agente de recibos de tomador del colectivo
            -- Para el recibo del certificado 0 se debe grabar el agente del certificado N.
            -- BUG 0020761 - 23/01/2012 - JMF : afegir ncuotar
            -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - si tomadores.cexistepagador = 1 informar el sperson de gescobros en el recibo
            vpas := 360;

            INSERT INTO recibos
                        (nrecibo, sseguro, cagente, femisio, fefecto, fvencim,
                         ctiprec, cestaux, nanuali, nfracci, ccobban, cestimp,
                         cempres, cdelega, nriesgo, cforpag, cbancar, nmovimi,
                         ncuacoa, ctipcoa, cestsop, nperven, cgescob, ctipban,
                         cmanual, esccero, ctipcob, ncuotar, sperson)
                 VALUES (pnrecibo, psseguro, xcagente, pfemisio, pfefecto, pfvencim,
                         pctiprec, xcestaux, xnanuali, xnfracci, xceroccobban, xcestimp,
                         xcempres, xcdelega, pnriesgo, xcforpag, xcerotbancar, pnmovimi,
                         xncuacoa, xctipcoa, xcestsop, xnperven, xcgescob, xceroctipban,
                         xcmanual, xesccero, xctipcob, xncuotar, xsperson_pagador);
         -- Bug 10787 - APD - 24/07/2009 - fin Campo CTIPCOB a nivel de recibo
         -- Fin Bug 11905
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 102307;   -- Registre duplicat a RECIBOS
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 103847);
               RETURN 103847;   -- Error a l' inserir a RECIBOS
         END;
      ELSE
         -- 2.0   05/01/2012  JGR    2. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico - Inicio
         -- Averiguar si se ha de modificar el XCESTIMP del recibo para PRENOTIFICACIONES
         vpas := 370;
         -- 13.0 0027411: Error al generar m¿s de un n¿mero de matr¿cula - QT-8145 - Inicial
         /*
         num_err := f_cestimp_prenotif(psseguro, xcempres, xcbancar,
                                       -- 10. 0025151 - 0139714 - Inicio
                                       xctipban, xsperson_notif,
                                       -- 10. 0025151 - 0139714 - Fin
                                       xccobban, xcestimp);
         */
         num_err := pac_prenotificaciones.f_cestimp_prenotif(psseguro, xcbancar, xctipban,
                                                             xccobban, xcestimp);

         -- 13.0 0027411: Error al generar m¿s de un n¿mero de matr¿cula - QT-8145 - Final
         IF num_err != 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || num_err);
            RETURN num_err;
         END IF;

         -- 2.0   05/01/2012  JGR    2. 0019894/0102394: LCOL898 Interface Respuesta Cobros D¿bito autom¿tico - Fin
         BEGIN
            -- Bug 10787 - APD - 24/07/2009 - Campo CTIPCOB a nivel de recibo
            -- se a¿ade el campo ctipcob en la tabla recibos
            -- se informa su valor con el valor que tenga en ese momento el
            -- campot ctipcob de la tabla seguros
            -- BUG 0020761 - 23/01/2012 - JMF : afegir ncuotar
            -- FPG - 01-08-2012 - BUG 0023075: LCOL_T010-Figura del pagador - si tomadores.cexistepagador = 1 informar el sperson de gescobros en el recibo
            vpas := 380;

            INSERT INTO recibos
                        (nrecibo, sseguro, cagente, femisio, fefecto, fvencim,
                         ctiprec, cestaux, nanuali, nfracci, ccobban, cestimp,
                         cempres, cdelega, nriesgo, cforpag, cbancar, nmovimi,
                         ncuacoa, ctipcoa, cestsop, nperven, cgescob, ctipban,
                         cmanual, esccero, ctipcob, ncuotar, sperson, csubtiprec) -- IAXIS-4926 23/10/2019
                 VALUES (pnrecibo, psseguro, xcagente, pfemisio, pfefecto, pfvencim,
                         pctiprec, xcestaux, xnanuali, xnfracci, xccobban, xcestimp,
                         xcempres, xcdelega, pnriesgo, xcforpag, xtbancar, pnmovimi,
                         xncuacoa, xctipcoa, xcestsop, xnperven, xcgescob, xctipban,
                         xcmanual, 0, xctipcob, xncuotar, xsperson_pagador, NVL(pcsubtiprec, pctiprec)); -- IAXIS-7179 13/11/2019
         -- Bug 10787 - APD - 24/07/2009 - fin Campo CTIPCOB a nivel de recibo
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 102307;   -- Registre duplicat a RECIBOS
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 103847);
               RETURN 103847;   -- Error a l' inserir a RECIBOS
         END;
      END IF;

--------------------------------------------------------------------------

      -- Grabamos la redcomercial. Cuando se haya adaptado todo a seguredcom podr¿ eliminarse
      vpas := 390;
      num_err := f_insrecibor(pnrecibo, xcempres, xcagente, pfemisio);

      IF num_err = 0 THEN
         xsmovrec := 0;

         IF pfemisio < pfefecto THEN
            xfmovim := pfefecto;
         ELSE
            xfmovim := pfemisio;
         END IF;

         IF f_parinstalacion_n('AGTEVENTA') = 1 THEN
            xcdelega2 := xcagente;
         ELSE
            vpas := 400;
            xcdelega2 := f_delegacion(NULL, xcempres, xcagente, pfemisio);
         END IF;

         -- Damos de alta el movimiento
         vpas := 410;

         -- Bug 22494 - APD - 01/08/2012 - si el psproces est¿ informado, se le pasa el psproces
         -- a la funcion F_MOVRECIBO en el parametro psmovrec
         IF psproces IS NOT NULL
            AND psproces <> 0 THEN
            xsmovrec := psproces;
         END IF;

         -- fin Bug 22494 - APD - 01/08/2012
         num_err := f_movrecibo(pnrecibo, 0, NULL, pcmovimi, xsmovrec, xnliqmen, dummy,
                                xfmovim, xccobban, xcdelega2, NULL, NULL);

         -- 14.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Inicio
         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                        || 'error = ' || num_err);
         END IF;

         -- 14.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Fin
         RETURN num_err;
      ELSE
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'error = '
                     || num_err);
         RETURN num_err;
      END IF;
   ELSIF pmodo IN('P', 'PRIE') THEN
      vpas := 420;

      IF pnrecibo IS NOT NULL
         AND pnrecibo <> 0
         AND psproces IS NOT NULL
         AND psproces <> 0 THEN
         BEGIN
            INSERT INTO reciboscar
                        (sproces, nrecibo, sseguro, cagente, femisio, fefecto,
                         fvencim, ctiprec, cestaux, nanuali, nfracci, ccobban,
                         cestimp, cempres, cdelega, nriesgo, ncuacoa, ctipcoa,
                         cestsop, cgescob)
                 VALUES (psproces, pnrecibo, psseguro, xcagente, pfemisio, pfefecto,
                         pfvencim, pctiprec, xcestaux, xnanuali, xnfracci, xccobban,
                         xcestimp, xcempres, xcdelega, pnriesgo, xncuacoa, xctipcoa,
                         xcestsop, xcgescob);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 103355);
               RETURN 103355;   -- Registre duplicat a RECIBOSCAR
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 103848);
               RETURN 103848;   -- Error a l' inserir a RECIBOSCAR
         END;

         RETURN 0;
      ELSE
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'error = '
                     || 101901);
         RETURN 101901;   -- Pas incorrecte de par¿metres a la funci¿
      END IF;
   ELSIF pmodo = 'N' THEN
      vpas := 430;

      IF pnrecibo IS NOT NULL
         AND pnrecibo <> 0
         AND psproces IS NOT NULL
         AND psproces <> 0 THEN
         BEGIN
            INSERT INTO reciboscar
                        (sproces, nrecibo, sseguro, cagente, femisio, fefecto,
                         fvencim, ctiprec, cestaux, nanuali, nfracci, ccobban, cestimp,
                         cempres, cdelega, nriesgo, ncuacoa, ctipcoa, cestsop, cgescob)
                 VALUES (psproces, pnrecibo, psseguro, xcagente, f_sysdate, f_sysdate,
                         f_sysdate, 0, xcestaux, NULL, NULL, NULL, NULL,
                         xcempres, NULL, NULL, xncuacoa, xctipcoa, xcestsop, xcgescob);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 103355);
               RETURN 103355;   -- Registre duplicat a RECIBOSCAR
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || 'error = ' || 103848);
               RETURN 103848;   -- Error a l' inserir a RECIBOSCAR
         END;

         RETURN 0;
      ELSE
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'error = '
                     || 101901);
         RETURN 101901;   -- Pas incorrecte de par¿metres a la funci¿
      END IF;
   ELSE
      p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                  'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'error = '
                  || 101901);
      RETURN 101901;   -- Pas incorrecte de par¿metres a la funci¿
   END IF;
END f_insrecibo;

/

  GRANT EXECUTE ON "AXIS"."F_INSRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSRECIBO" TO "PROGRAMADORESCSI";
