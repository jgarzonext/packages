--------------------------------------------------------
--  DDL for Package Body PK_TRANSFERENCIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_TRANSFERENCIAS" AS
/******************************************************************************
   NOM:       pk_transferencias

   REVISIONS:
   Ver        Fecha       Au617tor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0                           Creación del package.
   2.0        20/04/2009  DRA    0009693: CRE - Generación de fichero de transferencias
   3.0        22/05/2009  ICV    0010110: CRE066 - Modificación formulario de pago de rentas
   3.0        07/05/2009  SBG    0008217: CRE - REEMBOLSOS: Generació de transferències
   4.0        02/06/2009  ETM    0010266: CRE - cuenta de abono en pólizas de salud y bajas, no recuperaba bien la cuenta CARGO
   5.0        19/05/2009  DRA    0009693: CRE - Generación de fichero de transferencias
   6.0        15/06/2009  DRA    0010442: CRE - Modificación Texto en pk_transferencias
   7.0        01/07/2009  DRA    0010604: Nuevo control Reembolsos - Pago Retenido
   8.0        30/06/2009  DRA    0010581: CRE - Error en la generació automàtica de pagaments de sinistres, i la posterior generació de transferències
   9.0        14/07/2009  DCT    0010612: CRE - Error en la generació de pagaments automàtics.
                                 Canviar vista personas por tablas personas y añadir filtro de visión de agente
  10.0        29/07/2009  APD    0010775: Modificación fichero de transferencias para reembolsos
  11.0        10/09/2009  JRB    0011102: CRE - Procés de transferències de reemborsaments
  12.0        14/09/2009  DRA    0011119: CRE - Incidencia en generación de fichero de transferencias
  13.0        02/10/2009  XVM    0011285: CRE - Transferencias de reembolsos
  14.0        03/11/2011  JMF    0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
  15.0        08/10/2013  DEV,HRE 0028462: LCOL_T001-Cambio dimensionn NPOLIZA, NCERTIF
******************************************************************************/
   FUNCTION f_insert_remesas(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      psremisesion IN NUMBER,   -- Identificador de la sesion de inserciones de la remesa
      pprestacion IN NUMBER DEFAULT 0,
      tipproceso IN NUMBER DEFAULT 0,   --tipProceso: 0-todos 1- Rentas 2- recibos 3- siniestros 4-Reembolsos
      pagrup IN NUMBER DEFAULT NULL,   --Agrupación
      pcausasin IN NUMBER DEFAULT NULL   --En el caso de siniestros, la causa del siniestro
                                      )
      RETURN NUMBER IS
      /*
        {CURSOR RENTAS }
      */
      CURSOR c_rentas IS
         SELECT /*+ CHOSSE */
                pagosrenta.sseguro, pagosrenta.sperson, pagosrenta.srecren,
                pagosrenta.nctacor, pagosrenta.ffecpag,
                pagosrenta.isinret - pagosrenta.iretenc vimport, pagosrenta.ctipban
           FROM pagosrenta, seguros
          WHERE pagosrenta.fremesa IS NULL
            AND pprestacion IN(0, 2)
            ---  añadimos el filtro por tipo de proceso
            AND tipproceso IN(0, 1)
            --- añadimos el filtro por agrupación
            AND seguros.sseguro = pagosrenta.sseguro
            AND((pagrup IS NULL)
                OR(seguros.cagrpro = pagrup
                   AND pagrup IS NOT NULL))
            AND pagosrenta.srecren IN(SELECT movpagren.srecren
                                        FROM movpagren
                                       WHERE movpagren.cestrec = 0
                                         AND movpagren.fmovfin IS NULL
                                         AND TO_CHAR(movpagren.fmovini, 'YYYYMMDD') <=
                                                  TO_CHAR(ADD_MONTHS(f_sysdate, 1), 'YYYYMMDD'));   --JRH IMP (Es así)?

       /*
        {CURSOR RECIBOS }
      */
      CURSOR c_recibos(pcempres IN NUMBER) IS
         SELECT recibos.nrecibo, seguros.sseguro, recibos.cbancar, recibos.ctipban,
                6 catribu   -- extornos de anulaciones de aportaciones
           FROM recibos, seguros
          WHERE recibos.cestimp = 7   -- pte. de transferir
            AND recibos.cempres = NVL(pcempres, f_parinstalacion_n('EMPRESADEF'))
            AND recibos.ctiprec IN(9, 13)   -- extorno, retorno (bug 0019791)
            AND EXISTS(SELECT ctaseguro.nrecibo
                         FROM ctaseguro
                        WHERE ctaseguro.nrecibo = recibos.nrecibo)
            ---  añadimos el filtro por tipo de proceso
            AND tipproceso IN(0, 2)
            ---  añadimos el filtro por agrupación
            AND seguros.sseguro = recibos.sseguro
            AND((pagrup IS NULL)
                OR(seguros.cagrpro = pagrup
                   AND pagrup IS NOT NULL))
            --
            AND pprestacion = 0
         UNION
         SELECT r.nrecibo, seguros.sseguro, r.cbancar, r.ctipban, 5 catribu   -- extornos
           FROM recibos r, movrecibo m, seguros
          WHERE r.nrecibo = m.nrecibo
            AND r.cestimp = 7   -- pdte. de transferir
            AND r.cempres = NVL(pcempres, f_parinstalacion_n('EMPRESADEF'))
            AND r.ctiprec IN(9, 13)   -- extorno, retorno (bug 0019791)
            AND m.cestrec = 0   -- pendiente
            AND r.fefecto <= TRUNC(f_sysdate)
            AND m.fmovfin IS NULL
            ---  añadimos el filtro por tipo de proceso
            AND tipproceso IN(0, 2)
            ---  añadimos el filtro por agrupación
            AND seguros.sseguro = r.sseguro
            AND((pagrup IS NULL)
                OR(seguros.cagrpro = pagrup
                   AND pagrup IS NOT NULL))
            --
            AND pprestacion = 0;

      --- añadimos el filtro por pagos de prestaciones

      /*
        {CURSOR SINIESTROS }
      */-- Pagos Pendientes sin transferir de domiciliación bancario y transferencia
      CURSOR c_pagos IS
         SELECT /*+ CHOOSE */
                pagosini.ROWID, pagosini.nsinies, pagosini.isinret, c.catribu,
                pagosini.iretenc, pagosini.sidepag, siniestros.sseguro, pagosini.fordpag,
                siniestros.ccausin
           FROM pagosini, siniestros, codicausin c, seguros
          WHERE pagosini.nsinies = siniestros.nsinies
            AND siniestros.ccausin = c.ccausin
            AND seguros.sseguro = siniestros.sseguro
            AND pagosini.cestpag = 1
            AND(pagosini.ctransf = 1
                OR pagosini.ctransf IS NULL)
            AND pagosini.ctippag = 2
            -- Estaba en la pantalla de sa nostra
            AND pagosini.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                          FROM pagosini pp
                                         WHERE nsinies = pagosini.nsinies
                                           AND cestpag <> 8)
            -- Estaba en la pantalla de sa nostra
            AND pagosini.cforpag = 2
            ---  añadimos el filtro por  tipo de proceso
            AND tipproceso IN(0, 3)
            ---  añadimos el filtro por causa del siniestro
            AND((pcausasin IS NULL)
                OR(siniestros.ccausin = pcausasin
                   AND pcausasin IS NOT NULL))
            --- añadimos el filtro por agrupación
            AND((pagrup IS NULL)
                OR(seguros.cagrpro = pagrup
                   AND pagrup IS NOT NULL))
            --- añadimos el filtro por pagos de prestaciones
            AND((catribu = 10
                 AND pprestacion = 1)
                OR(catribu <> 10
                   AND pprestacion = 0));

      /*
        {CURSOR REEMBOLSOS }
      */-- Pagos Pendientes sin transferir de domiciliación bancario y transferencia
      -- Bug 10775 - APD - 29/07/2009 - Modificación fichero de transferencias para reembolsos
      -- se añade en el cursor c_reembolsos las tablas reembfact, reembactosfac ya que quieren
      -- los reembolsos desglosados por actos
      -- se añaden los reembolsos complementarios (se añade la union con los ipagocomp)
      CURSOR c_reembolsos IS
         SELECT 11 AS tipo_transfer, sseguro, cbancar, ctipban, raf.nreemb, sperson, raf.nfact,
                raf.nlinea, ipago importe, 1 ctipo
           -- BUG 8217 - 07/05/2009 - SBG - Canviem itot per ipago i afegim la condició
           -- de pprestacion = 3
         FROM   reembolsos r, reembfact rf, reembactosfac raf
          WHERE r.nreemb = rf.nreemb
            AND rf.nreemb = raf.nreemb
            AND rf.nfact = raf.nfact
            AND rf.fbaja IS NULL
            AND raf.fbaja IS NULL
            AND raf.ftrans IS NULL
            AND raf.cerror = 0   -- BUG10604:DRA:01/07/2009
            AND NVL(raf.ipago, 0) >
                   0   --BUG 11102 - 10/09/2009 - JRB - Se obliga a que el importe sea mayor de 0.
            AND pprestacion = 3
            -- FINAL BUG 8217 - 07/05/2009 - SBG
            AND tipproceso IN(0, 4)
            AND r.cestado NOT IN(0, 4, 5)   -- 0 = Gestion oficinas, 4 = Anulado, 5 = Rechazado
         UNION ALL
         SELECT 11 AS tipo_transfer, sseguro, cbancar, ctipban, raf.nreemb, sperson, raf.nfact,
                raf.nlinea, ipagocomp importe, 2 ctipo
           -- BUG 8217 - 07/05/2009 - SBG - Canviem itot per ipago i afegim la condició
           -- de pprestacion = 3
         FROM   reembolsos r, reembfact rf, reembactosfac raf
          WHERE r.nreemb = rf.nreemb
            AND rf.nreemb = raf.nreemb
            AND rf.nfact = raf.nfact
            AND rf.fbaja IS NULL
            AND raf.fbaja IS NULL
            AND raf.ftranscomp IS NULL
            AND NVL(raf.ipagocomp, 0) >
                   0   --BUG 11102 - 10/09/2009 - JRB - Se obliga a que el importe sea mayor de 0.
            AND raf.cerror = 0   -- BUG10604:DRA:01/07/2009
            AND pprestacion = 3
            -- FINAL BUG 8217 - 07/05/2009 - SBG
            AND tipproceso IN(0, 4)
            AND r.cestado NOT IN(0, 4, 5);   -- 0 = Gestion oficinas, 4 = Anulado, 5 = Rechazado

      -- BUG10604:DRA:01/07/2009:Fi
      -- Bug 10775 - APD - 29/07/2009 - Fin Modificación fichero de transferencias para reembolsos
      w_control      NUMBER;
      w_salida       seguros.cbancar%TYPE;   --  21-10-2011 JGR 0018944
      --    estat         BOOLEAN;
      w_cempres      seguros.cempres%TYPE;   --       w_cempres      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_valor        VARCHAR2(3);
      w_ttexto       VARCHAR2(80);
      w_cerror       NUMBER;
      w_error        NUMBER;
      w_sproces      NUMBER;
      --  verror       NUMBER;
      num_err        NUMBER;
      w_secuencia    remesas.sremesa%TYPE;   --       w_secuencia    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_producto     seguros.sproduc%TYPE;   --       w_producto     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_fecha        remesas.fabono%TYPE;   --       w_fecha        DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_import       vdetrecibos.itotalr%TYPE;   --       w_import       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_scuecar      seguros.cbancar%TYPE;   --  21-10-2011 JGR 0018944
      w_cabono       seguros.cbancar%TYPE;   --  21-10-2011 JGR 0018944
      w_ctipban      seguros.ctipban%TYPE;   --  21-10-2011 JGR 0018944
      w_ctipban_abono seguros.ctipban%TYPE;   --  21-10-2011 JGR 0018944
      v_sperson      tomadores.sperson%TYPE;   --       v_sperson      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pobliga        remesas.cobliga%TYPE := 0;   --       pobliga        NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ccobban      seguros.ccobban%TYPE;   -- BUG9693:DRA:19/05/2009
      -- wcatribu     NUMBER;
      v_error_ccc    NUMBER := 0;   -- BUG10581:DRA:30/06/2009
      v_error_proc   NUMBER := 0;   -- BUG10581:DRA:01/07/2009
      v_sidepag      remesas.sidepag%TYPE;
   BEGIN
/********************************************************************
    COMENÇO AMB LA SELECCIÓ DE TOTES LES TRANSFERÈNCIES PENDENTS
********************************************************************/
      w_cerror := 0;

      --if tipProceso<>0 then --Si seleccionamos todos , pantalla lo deamos a 0, sino lo dejamos preparado para hacer la transferencia via batch
      --   pobliga:=1;
      --end if;
      IF pprestacion IS NULL THEN
         RETURN 180656;
      END IF;

      IF tipproceso IS NULL THEN
         RETURN 180656;
      END IF;

      IF pcausasin IS NOT NULL
         AND NVL(tipproceso, 0) <> 3 THEN
         RETURN 180656;
      END IF;

      BEGIN
         w_fecha := f_sysdate;

         --Modifico el camp ccausin(codigo de transferencia)
         UPDATE remesas
            SET ccausin = 0,
                cimpres = 0;

/********************************************************************
                         RENTAs
 ********************************************************************/
         FOR reg IN c_rentas LOOP
            num_err := 0;

            --Seleccionem la sequencia per el numero de la remesa
            SELECT sremesa.NEXTVAL
              INTO w_secuencia
              FROM DUAL;

            --Seleccionem el codi del producte i el codi de la compte corrent
            BEGIN
               w_producto := NULL;

               SELECT ctacargoproducto.sproduc, ctacargos.ccc,   -- BUG9693:DRA:17/06/2009
                      NULL   -- BUG9693:DRA:19/05/2009:Aquí dejamos NULL porque no nos fiamos del ccobban de SEGUROS
                 INTO w_producto, w_scuecar,
                      v_ccobban   -- BUG9693:DRA:19/05/2009
                 FROM seguros, ctacargoproducto, ctacargos
                WHERE seguros.sseguro = reg.sseguro
                  AND seguros.sproduc = ctacargoproducto.sproduc
                  AND ctacargoproducto.catribu = 2
                  AND ctacargos.scuecar = ctacargoproducto.scuecar;   -- BUG9693:DRA:17/06/2009
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     SELECT s.sproduc, c.ncuenta, c.ctipban,
                            c.ccobban   -- BUG9693:DRA:19/05/2009
                       INTO w_producto, w_scuecar, w_ctipban,
                            v_ccobban   -- BUG9693:DRA:19/05/2009
                       FROM seguros s, cobbancario c
                      WHERE s.sseguro = reg.sseguro
                        AND c.ccobban = s.ccobban;
                  EXCEPTION
                     WHEN OTHERS THEN
                        BEGIN
                           SELECT s.sproduc, c.ncuenta, c.ctipban,
                                  c.ccobban   -- BUG9693:DRA:19/05/2009
                             INTO w_producto, w_scuecar, w_ctipban,
                                  v_ccobban   -- BUG9693:DRA:19/05/2009
                             FROM seguros s, cobbancario c, cobbancariosel cs
                            WHERE s.sseguro = reg.sseguro
                              AND s.cramo = NVL(cs.cramo, s.cramo)
                              AND s.cmodali = NVL(cs.cmodali, s.cmodali)
                              AND s.ctipseg = NVL(cs.ctipseg, s.ctipseg)
                              AND s.ccolect = NVL(cs.ccolect, s.ccolect)
                              AND c.ccobban = cs.ccobban
                              AND cs.norden IN   --> Seleccionamos las + prioritaria
                                              (SELECT MIN(x.norden)
                                                 FROM cobbancario y, cobbancariosel x
                                                WHERE s.cramo = NVL(x.cramo, s.cramo)
                                                  AND s.cmodali = NVL(x.cmodali, s.cmodali)
                                                  AND s.ctipseg = NVL(x.ctipseg, s.ctipseg)
                                                  AND s.ccolect = NVL(x.ccolect, s.ccolect)
                                                  AND y.ccobban = x.ccobban
                                                  AND y.cbaja = 0);
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS', 1,
                                          'Error buscando COBBANCARIOSEL para seguro ='
                                          || reg.sseguro,
                                          SQLERRM);
                              RETURN 152055;
                        END;
                  END;
            END;

            -- EL CABONO ES REG.NCTACOR
            -- EL CATRIBU ES CATRIBU = 2 PER QUE SÓN RENTAS ORDRE DE PRIOTITAT
            SELECT cempres
              INTO w_cempres
              FROM seguros
             WHERE sseguro = reg.sseguro;

            IF (w_cempres = pcempres
                AND num_err <> -1
                AND reg.vimport > 0) THEN
               BEGIN
                  INSERT INTO remesas
                              (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
                               nrentas, cabono, iimport, ctipban_abono,
                               sseguro, catribu, sproduc, fabono, nremesa, ftransf, ccausin,
                               cimpres, cempres,
                               sperson, cobliga, sremsesion, ccobban)   -- BUG9693:DRA:19/05/2009
                       VALUES (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL,
                               reg.srecren, reg.nctacor, reg.vimport, reg.ctipban,
                               reg.sseguro, 2, w_producto, w_fecha,   --JRH IMP Ponemos la fecha del día como fecha de abono reg.ffecpag
                                                                   NULL, NULL, 0,
                               0, NVL(pcempres, f_parinstalacion_n('EMPRESADEF')),
                               reg.sperson, pobliga, psremisesion, v_ccobban);   -- BUG9693:DRA:19/05/2009

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'alctr1000', w_secuencia,
                                 'error al insertar REMESAS de rentas, sseguro = '
                                 || reg.sseguro,
                                 SQLERRM);
                     num_err := -1;
                     v_error_proc := 109388;   -- BUG10581:DRA:01/07/2009
               END;
            END IF;
         END LOOP;

/********************************************************************
                         RECIBOS
 ********************************************************************/
         FOR reg IN c_recibos(pcempres) LOOP
            num_err := 0;

            BEGIN
               SELECT sremesa.NEXTVAL
                 INTO w_secuencia
                 FROM DUAL;

               w_producto := NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := -1;
            END;

            BEGIN
               w_producto := NULL;

               SELECT productos.sproduc, ctacargos.ccc, ctacargos.ctipban,
                      NULL   -- BUG9693:DRA:19/05/2009:Aquí dejamos NULL porque no nos fiamos del ccobban de SEGUROS
                 INTO w_producto, w_scuecar, w_ctipban,
                      v_ccobban   -- BUG9693:DRA:19/05/2009
                 FROM seguros, productos, ctacargos
                WHERE seguros.sseguro = reg.sseguro
                  AND seguros.sproduc = productos.sproduc
                  AND ctacargos.scuecar = productos.scuecar;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     w_producto := NULL;

                     SELECT s.sproduc, c.ncuenta, c.ctipban,
                            c.ccobban   -- BUG9693:DRA:19/05/2009
                       INTO w_producto, w_scuecar, w_ctipban,
                            v_ccobban   -- BUG9693:DRA:19/05/2009
                       FROM seguros s, cobbancario c, cobbancariosel cs
                      WHERE s.sseguro = reg.sseguro
                        AND s.cramo = NVL(cs.cramo, s.cramo)
                        AND s.cmodali = NVL(cs.cmodali, s.cmodali)
                        AND s.ctipseg = NVL(cs.ctipseg, s.ctipseg)
                        AND s.ccolect = NVL(cs.ccolect, s.ccolect)
                        AND c.ccobban = cs.ccobban
                        AND cs.norden IN   --> Seleccionamos las + prioritaria
                                        (SELECT MIN(x.norden)
                                           FROM cobbancario y, cobbancariosel x
                                          WHERE s.cramo = NVL(x.cramo, s.cramo)
                                            AND s.cmodali = NVL(x.cmodali, s.cmodali)
                                            AND s.ctipseg = NVL(x.ctipseg, s.ctipseg)
                                            AND s.ccolect = NVL(x.ccolect, s.ccolect)
                                            AND y.ccobban = x.ccobban
                                            AND y.cbaja = 0);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS', 2,
                                    'Error buscando COBBANCARIOSEL para seguro ='
                                    || reg.sseguro,
                                    SQLERRM);
                        RETURN 152055;
                  END;
            END;

            --Seleccionem l'import total per rebuts
            BEGIN
               w_import := NULL;

               SELECT itotalr
                 INTO w_import
                 FROM vdetrecibos
                WHERE nrecibo = reg.nrecibo;
            EXCEPTION
               WHEN OTHERS THEN
                  -- Error, el producte no té informat la compte corrent de càrrec
                  num_err := -1;
            END;

            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM tomadores
                WHERE sseguro = reg.sseguro
                  AND nordtom = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := -1;
            END;

            IF (num_err <> -1
                AND w_import > 0) THEN
               BEGIN
                  --Inserim un rebut
                  INSERT INTO remesas
                              (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
                               cabono, iimport, ctipban_abono, sseguro, catribu,
                               sproduc, fabono, nremesa, ftransf, ccausin, cimpres,
                               cempres, sperson,
                               cobliga, sremsesion,   --JRH IMP SPERSON
                                                   ccobban)   -- BUG9693:DRA:19/05/2009
                       VALUES (w_secuencia, w_scuecar, w_ctipban, reg.nrecibo, NULL, NULL,
                               reg.cbancar, w_import, reg.ctipban, reg.sseguro, reg.catribu,
                               w_producto, w_fecha, NULL, NULL, 0, 0,
                               NVL(pcempres, f_parinstalacion_n('EMPRESADEF')), v_sperson,
                               pobliga, psremisesion, v_ccobban);   -- BUG9693:DRA:19/05/2009

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'alctr1000', w_secuencia,
                                 'error al insertar REMESAS (de recibos) para nrecibo '
                                 || reg.nrecibo,
                                 SQLERRM);
                     -- Error, el producte no té informat la compte corrent de càrrec
                     num_err := -1;
                     v_error_proc := 109388;   -- BUG10581:DRA:01/07/2009
               END;
            END IF;
         END LOOP;

/********************************************************************
                         SINIESTROS
 ********************************************************************/
         FOR reg IN c_pagos LOOP
            num_err := 0;

            SELECT sremesa.NEXTVAL
              INTO w_secuencia
              FROM DUAL;

            --
            BEGIN
               w_producto := NULL;

               SELECT productos.sproduc, ctacargos.ccc, ctacargos.ctipban,
                      NULL   -- BUG9693:DRA:19/05/2009:Aquí dejamos NULL porque no nos fiamos del ccobban de SEGUROS
                 INTO w_producto, w_scuecar, w_ctipban,
                      v_ccobban   -- BUG9693:DRA:17/06/2009
                 FROM seguros, productos, ctacargos
                WHERE seguros.sseguro = reg.sseguro
                  AND seguros.sproduc = productos.sproduc
                  AND ctacargos.scuecar = productos.scuecar;
            EXCEPTION
               WHEN OTHERS THEN
                  -- BUSCAMOS LA CUENTA DE CARGO Y EL PRODUCTO .
                  BEGIN
                     w_producto := NULL;

                     SELECT seguros.sproduc, cobbancario.ncuenta, cobbancario.ctipban,
                            cobbancario.ccobban   -- BUG9693:DRA:17/06/2009
                       INTO w_producto, w_scuecar, w_ctipban,
                            v_ccobban   -- BUG9693:DRA:17/06/2009
                       FROM seguros, cobbancario, cobbancariosel
                      WHERE seguros.sseguro = reg.sseguro
                        AND seguros.cramo = NVL(cobbancariosel.cramo, seguros.cramo)
                        AND seguros.cmodali = NVL(cobbancariosel.cmodali, seguros.cmodali)
                        AND seguros.ctipseg = NVL(cobbancariosel.ctipseg, seguros.ctipseg)
                        AND seguros.ccolect = NVL(cobbancariosel.ccolect, seguros.ccolect)
                        AND cobbancario.ccobban = cobbancariosel.ccobban
                        AND cobbancariosel.norden IN   --> Seleccionamos las + prioritaria
                                                    (
                              SELECT MIN(x.norden)
                                FROM cobbancario y, cobbancariosel x
                               WHERE seguros.cramo = NVL(x.cramo, seguros.cramo)
                                 AND seguros.cmodali = NVL(x.cmodali, seguros.cmodali)
                                 AND seguros.ctipseg = NVL(x.ctipseg, seguros.ctipseg)
                                 AND seguros.ccolect = NVL(x.ccolect, seguros.ccolect)
                                 AND y.ccobban = x.ccobban
                                 AND y.cbaja = 0);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS', 3,
                                    'Error buscando COBBANCARIOSEL para seguro ='
                                    || reg.sseguro,
                                    SQLERRM);
                        RETURN 152055;
                  END;
            END;

            --Seleccionem el CABONO per sinistres(ccausin)
            BEGIN
               w_cabono := NULL;
               w_ctipban_abono := NULL;

               SELECT destinatarios.cbancar, destinatarios.ctipban
                 INTO w_cabono, w_ctipban_abono
                 FROM destinatarios, pagosini
                WHERE destinatarios.sperson = pagosini.sperson
                  AND destinatarios.nsinies = pagosini.nsinies
                  AND pagosini.ctipdes = destinatarios.ctipdes
                  AND pagosini.sidepag = reg.sidepag
                  AND cbancar IS NOT NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(seguros.cbancar, 0), seguros.ctipban
                       INTO w_cabono, w_ctipban_abono
                       FROM seguros
                      WHERE seguros.sseguro = reg.sseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        w_cabono := LPAD(0, 20, '0');
                  END;
               WHEN OTHERS THEN
                  w_ttexto := f_axis_literales(110039, pcidioma);
                  w_error := f_proceslin(w_sproces, w_ttexto, reg.sseguro, w_cerror);
            END;

            --importe para siniestros.
            w_import := 0;
            w_import := NVL(reg.isinret, 0) - NVL(reg.iretenc, 0);

            BEGIN
               SELECT cempres
                 INTO w_cempres
                 FROM seguros
                WHERE sseguro = reg.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  w_cempres := -1;
            END;

            BEGIN
               w_cabono := REPLACE(w_cabono, '*', '0');
               v_error_ccc := f_ccc(w_cabono, w_ctipban_abono, w_control, w_salida);

               -- BUG10581:DRA:30/06/2009:Inici
               IF v_error_ccc <> 0 THEN
                  w_cabono := NULL;
                  w_salida := NULL;
                  p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS', 1,
                              'error al buscar F_CCC, sseguro = ' || reg.sseguro
                              || ' ctipban-cabono: ' || w_ctipban_abono || '-' || w_cabono,
                              'Error F_CCC: ' || v_error_ccc);
                  RETURN 120130;
               END IF;

               -- BUG10581:DRA:30/06/2009:Fi
               w_cabono := w_salida;
            EXCEPTION
               WHEN OTHERS THEN
                  --w_cabono := LPAD (w_cabono, 20, '0');
                  -- BUG10581:DRA:30/06/2009:Inici
                  w_cabono := NULL;
                  w_salida := NULL;
                  p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS', 2,
                              'error inesperado al buscar F_CCC, sseguro = ' || reg.sseguro
                              || ' ctipban-cabono: ' || w_ctipban_abono || '-' || w_cabono,
                              SQLERRM);
                  RETURN 120130;
            -- BUG10581:DRA:30/06/2009:Fi
            END;

            BEGIN
               SELECT sperson
                 INTO v_sperson
                 FROM pagosini
                WHERE sidepag = reg.sidepag;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := -1;
            END;

            IF (w_cempres = NVL(pcempres, f_parinstalacion_n('EMPRESADEF'))
                AND num_err = 0
                AND w_import > 0) THEN
               BEGIN
                  INSERT INTO remesas
                              (sremesa, ccc, ctipban, nrecibo, nsinies,
                               sidepag, cabono, ctipban_abono, iimport, sseguro,
                               catribu, sproduc, fabono, nremesa, ftransf, ccausin, cimpres,
                               cempres, sperson,
                               cobliga, sremsesion,   --JRH IMP SPERSON
                                                   ccobban)   -- BUG9693:DRA:19/05/2009
                       VALUES (w_secuencia, w_scuecar, w_ctipban, NULL, reg.nsinies,
                               reg.sidepag, w_cabono, w_ctipban_abono, w_import, reg.sseguro,
                               reg.catribu, w_producto, w_fecha, NULL, NULL, 0, 0,
                               NVL(pcempres, f_parinstalacion_n('EMPRESADEF')), v_sperson,
                               pobliga, psremisesion, v_ccobban);   -- BUG9693:DRA:19/05/2009

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'alctr1000', w_secuencia,
                                 'error al insertar REMESAS de siniestros, sseguro = '
                                 || reg.sseguro,
                                 SQLERRM);
                     num_err := -1;
                     v_error_proc := 109388;   -- BUG10581:DRA:01/07/2009
               END;
            END IF;
         END LOOP;

/********************************************************************
                         REEMBOLSOS
 ********************************************************************/
         FOR reg IN c_reembolsos LOOP
            num_err := 0;

            --Seleccionem la sequencia per el numero de la remesa
            SELECT sremesa.NEXTVAL
              INTO w_secuencia
              FROM DUAL;

            --Seleccionem el codi del producte i el codi de la compte corrent
            BEGIN
               w_producto := NULL;

               SELECT sproduc, cempres
                 INTO w_producto, w_cempres
                 FROM seguros
                WHERE seguros.sseguro = reg.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS', 1,
                              'Error buscando COBBANCARIOSEL para seguro =' || reg.sseguro,
                              SQLERRM);
                  RETURN 152055;
            END;

            --ETM INI
             -- BUG 0010266: ETM: 02-06-2009 --INI
            BEGIN
               w_producto := NULL;

               SELECT productos.sproduc, ctacargos.ccc, ctacargos.ctipban,
                      NULL   -- BUG9693:DRA:17/06/2009
                 INTO w_producto, w_scuecar, w_ctipban,
                      v_ccobban   -- BUG9693:DRA:17/06/2009
                 FROM seguros, productos, ctacargos
                WHERE seguros.sseguro = reg.sseguro
                  AND seguros.sproduc = productos.sproduc
                  AND ctacargos.scuecar = productos.scuecar;
            EXCEPTION
               WHEN OTHERS THEN
                  -- BUSCAMOS LA CUENTA DE CARGO Y EL PRODUCTO .
                  BEGIN
                     w_producto := NULL;

                     SELECT seguros.sproduc, cobbancario.ncuenta, cobbancario.ctipban,
                            cobbancario.ccobban   -- BUG9693:DRA:17/06/2009
                       INTO w_producto, w_scuecar, w_ctipban,
                            v_ccobban   -- BUG9693:DRA:17/06/2009
                       FROM seguros, cobbancario, cobbancariosel
                      WHERE seguros.sseguro = reg.sseguro
                        AND seguros.cramo = NVL(cobbancariosel.cramo, seguros.cramo)
                        AND seguros.cmodali = NVL(cobbancariosel.cmodali, seguros.cmodali)
                        AND seguros.ctipseg = NVL(cobbancariosel.ctipseg, seguros.ctipseg)
                        AND seguros.ccolect = NVL(cobbancariosel.ccolect, seguros.ccolect)
                        AND cobbancario.ccobban = cobbancariosel.ccobban
                        AND cobbancariosel.norden IN   --> Seleccionamos las + prioritaria
                                                    (
                              SELECT MIN(x.norden)
                                FROM cobbancario y, cobbancariosel x
                               WHERE seguros.cramo = NVL(x.cramo, seguros.cramo)
                                 AND seguros.cmodali = NVL(x.cmodali, seguros.cmodali)
                                 AND seguros.ctipseg = NVL(x.ctipseg, seguros.ctipseg)
                                 AND seguros.ccolect = NVL(x.ccolect, seguros.ccolect)
                                 AND y.ccobban = x.ccobban
                                 AND y.cbaja = 0);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS', 3,
                                    'Error buscando COBBANCARIOSEL para seguro ='
                                    || reg.sseguro,
                                    SQLERRM);
                        RETURN 152055;
                  END;
            END;

            --BUG 0010266: ETM: 02-06-2009 --FIN
            IF (w_cempres = pcempres
                AND num_err <> -1
                AND reg.importe > 0) THEN
               BEGIN
                  -- BUG10604:DRA:0/07/2009:Inici
                  SELECT NVL(MAX(sidepag) + 1, 0)
                    INTO v_sidepag
                    FROM remesas
                   WHERE nsinies = reg.nreemb;

                  -- BUG10604:DRA:0/07/2009:Fi
                  INSERT INTO remesas
                              (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag, nrentas,
                               cabono, iimport, ctipban_abono, sseguro,
                               catribu, sproduc, fabono, nremesa, ftransf, ccausin, cimpres,
                               cempres, sperson,
                               cobliga, sremsesion, ccobban,   -- BUG9693:DRA:19/05/2009
                                                            nreemb, nfact,
                               nlinea, ctipo)
                       VALUES (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL, NULL,
                               reg.cbancar, reg.importe, reg.ctipban, reg.sseguro,
                               reg.tipo_transfer, w_producto, w_fecha,   --JRH IMP Ponemos la fecha del día como fecha de abono reg.ffecpag,
                                                                      NULL, NULL, 0, 0,
                               NVL(pcempres, f_parinstalacion_n('EMPRESADEF')), reg.sperson,
                               pobliga, psremisesion, v_ccobban,   -- BUG9693:DRA:19/05/2009
                                                                reg.nreemb, reg.nfact,
                               reg.nlinea, reg.ctipo);   -- Bug 10775 - APD- se añaden los campos NREEMB, NFACT, NLINEA
                                                         -- y CTIPO en la tabla REMESAS

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'alctr1000', w_secuencia,
                                 'error al insertar REMESAS de reembolsos, sseguro = '
                                 || reg.sseguro,
                                 SQLERRM);
                     num_err := -1;
                     v_error_proc := 109388;   -- BUG10581:DRA:01/07/2009
               END;
            END IF;
         END LOOP;
      --FORMS_DDL ('COMMIT');
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pk_transferencias.f_insert_remesas', 1,
                        'error no controlado', SQLERRM);
            RETURN 140999;
      END;

      RETURN 0;
   END f_insert_remesas;

   FUNCTION insertar_ctaseguro(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcfeccob IN NUMBER,
      --vienen de fmovcta
      pfmovini IN DATE,
      pfmovdia IN DATE DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      --  DRA. De moment, no té importancia el que vingui
      -- pel pfvalmov. En el camp de CTASEGURO, grabem la data efecte (xfefecto).
      --
      -- Modifiquem la forma d'insertar, fent que la data de contabilitzacio
      -- del moviment sigui la data de creacio del rebut, de forma que
      -- es contabilitzi correctament el cas d'un cobrament d'un rebut que ens
      -- arriba despres del seu "tancament"
      -- Si els imports són 0, tornem sense fer rès
      --  pcfeccob = 1, les dates son les fmovini
      aux_fmovdia    DATE;
      encontrado     NUMBER;
      lffecmov       DATE;
      lffvalmov      DATE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
      v_sproduc      seguros.sproduc%TYPE;   --       v_sproduc      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER;
   BEGIN
      --  INSERT INTO informes_err VALUES ( 'f_movcta: Entramos');

      --  Si els imports són 0, tornem sense fer rès
      IF NVL(pimovimi, 0) = 0
         AND NVL(pimovimi2, 0) = 0 THEN
         RETURN 0;
      END IF;

      lffecmov := pffecmov;
      lffvalmov := pffvalmov;

      IF pcfeccob IS NULL THEN
         aux_fmovdia := NVL(pfmovdia, f_sysdate);
      ELSIF pcfeccob = 0 THEN
         aux_fmovdia := NVL(pfmovdia, f_sysdate);
         lffecmov := TRUNC(f_sysdate);
         lffvalmov := TRUNC(f_sysdate);
      ELSE   -- NP cal posar les dates de movrecibo
         lffecmov := pfmovini;
         aux_fmovdia := NVL(pfmovdia, f_sysdate);
         lffvalmov := lffecmov;
      END IF;

      num_err := pac_ctaseguro.f_insctaseguro(psseguro, aux_fmovdia, pnnumlin, TRUNC(lffecmov),
                                              TRUNC(lffvalmov), pcmovimi, pimovimi, pimovimi2,
                                              pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec,
                                              NULL, 'R', NULL, NULL, NULL, NULL, psrecren);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END;

      --  - Quan estem tractant una aportació periòdica o extraordiària
      -- actualitzem la provisió matemàtica de l'assegurança. También en el caso de
        -- anulación de aportación (51)
      --JRH Añadimos el movimiento 10
      IF pcmovimi IN(1, 2, 10, 51, 53)
         AND NVL(f_parproductos_v(v_sproduc, 'SALDO_AE'), 0) = 1 THEN
         --         num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, lffvalmov,'R',NULL);
            -- num_err := Pac_Ctaseguro.F_inscta_prov_cap (psseguro, TRUNC(lffvalmov),'R',NULL);
         num_err := pac_ctaseguro.f_inscta_prov_cap(psseguro, TRUNC(f_sysdate), 'R', NULL);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN 104879;   -- Registre duplicat a CTASEGURO
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_movcta', 1,
                     'Error incontrolado al insertar en CTASEGURO-CTASEGURO_LIBRETA', SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END insertar_ctaseguro;

   FUNCTION insertar_ctaseguro_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcfeccob IN NUMBER,
      --vienen de fmovcta
      pfmovini IN DATE,
      pfmovdia IN DATE DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      --  DRA. De moment, no té importancia el que vingui
      -- pel pfvalmov. En el camp de CTASEGURO, grabem la data efecte (xfefecto).
      --
      -- Modifiquem la forma d'insertar, fent que la data de contabilitzacio
      -- del moviment sigui la data de creacio del rebut, de forma que
      -- es contabilitzi correctament el cas d'un cobrament d'un rebut que ens
      -- arriba despres del seu "tancament"
      -- Si els imports són 0, tornem sense fer rès
      --  pcfeccob = 1, les dates son les fmovini
      aux_fmovdia    DATE;
      encontrado     NUMBER;
      lffecmov       DATE;
      lffvalmov      DATE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
      v_sproduc      seguros.sproduc%TYPE;   --       v_sproduc      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER;
   BEGIN
      --  INSERT INTO informes_err VALUES ( 'f_movcta: Entramos');

      --  Si els imports són 0, tornem sense fer rès
      IF NVL(pimovimi, 0) = 0
         AND NVL(pimovimi2, 0) = 0 THEN
         RETURN 0;
      END IF;

      lffecmov := pffecmov;
      lffvalmov := pffvalmov;

      IF pcfeccob IS NULL THEN
         aux_fmovdia := NVL(pfmovdia, f_sysdate);
      ELSIF pcfeccob = 0 THEN
         aux_fmovdia := NVL(pfmovdia, f_sysdate);
         lffecmov := TRUNC(f_sysdate);
         lffvalmov := TRUNC(f_sysdate);
      ELSE   -- NP cal posar les dates de movrecibo
         lffecmov := pfmovini;
         aux_fmovdia := NVL(pfmovdia, f_sysdate);
         lffvalmov := lffecmov;
      END IF;

      num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, aux_fmovdia, pnnumlin,
                                                  TRUNC(lffecmov), TRUNC(lffvalmov), pcmovimi,
                                                  pimovimi, pimovimi2, pnrecibo, pccalint,
                                                  pcmovanu, pnsinies, psmovrec, NULL, 'R',
                                                  NULL, NULL, NULL, NULL, psrecren);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END;

      --  - Quan estem tractant una aportació periòdica o extraordiària
      -- actualitzem la provisió matemàtica de l'assegurança. También en el caso de
        -- anulación de aportación (51)
      --JRH Añadimos el movimiento 10
      IF pcmovimi IN(1, 2, 10, 51, 53)
         AND NVL(f_parproductos_v(v_sproduc, 'SALDO_AE'), 0) = 1 THEN
         num_err := pac_ctaseguro.f_inscta_prov_cap_shw(psseguro, TRUNC(f_sysdate), 'R', NULL);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         RETURN 104879;   -- Registre duplicat a CTASEGURO
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_movcta', 1,
                     'Error incontrolado al insertar en CTASEGURO-CTASEGURO_LIBRETA_SHW',
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END insertar_ctaseguro_shw;

   FUNCTION f_transferir(
      pcempres IN NUMBER,
      psremisesion IN NUMBER,   -- Identificador de la sesion de inserciones de la remesa
      pnremesa OUT NUMBER)
      RETURN NUMBER IS
      w_error        NUMBER;
      w_sequence     remesas.nremesa%TYPE;   --       w_sequence     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_tipoemp      empresas.ctipemp%TYPE;   --       w_tipoemp      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_mes          NUMBER;
      w_anyo         NUMBER;
      w_ccobban      recibos.ccobban%TYPE;   --       w_ccobban      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_cagente      recibos.cagente%TYPE;   --       w_cagente      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_data         movrecibo.fmovini%TYPE;   --       w_data         DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_moviment     NUMBER;
      w_nliqmen      NUMBER;
      w_pnliqlin     NUMBER;
      num_err        NUMBER;
      w_smovpag      movpagren.smovpag%TYPE;   --       w_smovpag      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcontapagados  NUMBER;
      vcontapagos    NUMBER;
      vnsinies       siniestros.nsinies%TYPE;   --       vnsinies       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcramo         siniestros.cramo%TYPE;   --       vcramo         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vestsin        siniestros.cestsin%TYPE;   --       vestsin        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcontapend     NUMBER;
      vcontacexp     NUMBER;
      vexistrecibo   NUMBER;
      vexistsini     NUMBER;
      vexistrenta    NUMBER;
      v_cfeccob      productos.cfeccob%TYPE;

      CURSOR c_remesas(pcempres IN NUMBER) IS
         -- Bug 10775 - APD - se añaden los campos NREEMB, NFACT, NLINEA y CTIPO al cursor
         SELECT remesas.nrecibo, remesas.sidepag, remesas.nsinies, remesas.sseguro, catribu,
                remesas.ftransf, remesas.sperson, remesas.nrentas, remesas.nreemb,
                remesas.nfact, remesas.nlinea, remesas.ctipo, remesas.sproduc
           FROM remesas
          WHERE ccausin = 1
            AND sremsesion = psremisesion
            AND(nremesa IS NULL
                OR ftransf IS NULL);
   BEGIN
      BEGIN
         SELECT COUNT(1)
           INTO w_error
           FROM remesas
          WHERE cempres = pcempres
            AND sremsesion = psremisesion
            AND(ftransf IS NULL
                OR nremesa IS NULL)
            AND cobliga = 1;
      END;

      IF w_error = 0 THEN
         p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS.F_TRANSFERIR', 1,
                     'NO SE ENCONTRARON REMESAS', 'Sesión Remesa :' || psremisesion);
         RETURN 120135;   --> No hay seleccionado ningún registro.
      END IF;

      SELECT snremesa.NEXTVAL
        INTO w_sequence
        FROM DUAL;

      pnremesa := w_sequence;

      UPDATE remesas
         SET ccausin = 1,
             nremesa = w_sequence
       WHERE cempres = pcempres
         AND sremsesion = psremisesion
         AND(ftransf IS NULL
             OR nremesa IS NULL)
         AND cobliga = 1;

      SELECT TO_CHAR(f_sysdate, 'YYYY'), TO_CHAR(f_sysdate, 'MM')
        INTO w_anyo, w_mes
        FROM DUAL;

      -- GENERAMOS LOS MOVIMIENTOS
      SELECT ctipemp
        INTO w_tipoemp
        FROM empresas
       WHERE cempres = pcempres;

---------------------
      FOR reg IN c_remesas(NVL(pcempres, f_parinstalacion_n('EMPRESADEF'))) LOOP
         IF (reg.nrecibo IS NOT NULL) THEN
            SELECT COUNT(*)
              INTO vexistrecibo
              FROM remesas
             WHERE nrecibo = reg.nrecibo
               AND ftransf IS NOT NULL
               AND nremesa IS NOT NULL;   -- recibo ya transferido

            IF vexistrecibo = 0 THEN
               -- Recibos
               BEGIN
                  UPDATE recibos
                     SET cestimp = 8   -- transferido
                   WHERE nrecibo = reg.nrecibo;

                  SELECT ccobban, cagente
                    INTO w_ccobban, w_cagente
                    FROM recibos
                   WHERE nrecibo = reg.nrecibo;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PK_TRANFERENCIAS.F_TRANSFERIR', 1,
                                 'ERROR UPDATE O SELECT RECIBOS', SQLERRM);
                     RETURN 109997;
               END;

               IF reg.catribu = 5 THEN   -- extorno NO anulación de aportación
                  BEGIN
                     SELECT fmovini
                       INTO w_data
                       FROM movrecibo
                      WHERE nrecibo = reg.nrecibo
                        AND cestrec = 0
                        AND fmovfin IS NULL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        w_data := f_sysdate;
                  END;

                  -- HEM DE GENERAR EL MOVIMENT DE REBUT F_MOVRECIBO
                  w_moviment := 0;
                  w_nliqmen := NULL;
                  w_pnliqlin := NULL;

                  BEGIN
                     IF (w_data >= f_sysdate) THEN
                        num_err := f_movrecibo(reg.nrecibo, 01, NULL, NULL, w_moviment,
                                               w_nliqmen, w_pnliqlin, w_data, w_ccobban,
                                               f_delega(reg.sseguro, w_data), NULL, w_cagente);
                     ELSE
                        num_err := f_movrecibo(reg.nrecibo, 01, NULL, NULL, w_moviment,
                                               w_nliqmen, w_pnliqlin, f_sysdate, w_ccobban,
                                               f_delega(reg.sseguro, f_sysdate), NULL,
                                               w_cagente);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PK_TRANFERENCIAS.F_TRANSFERIR', 2,
                                    'ERROR EN F_MOVRECIBO', SQLERRM);
                        RETURN 109997;
                  END;
               END IF;
            ELSE
               RETURN 180800;   -- Existen recibos ya transferidos en su selección. Refrescar busqueda de Transferencias.
            END IF;
         ELSIF(reg.sidepag IS NOT NULL
               AND reg.catribu <> 11)   -- BUG10631:DRA:06/07/2009
                                     THEN
            SELECT s.nsinies, s.cramo, s.cestsin
              INTO vnsinies, vcramo, vestsin
              FROM siniestros s, pagosini p
             WHERE p.sidepag = reg.sidepag
               AND p.nsinies = s.nsinies;

            SELECT COUNT(*)
              INTO vexistsini
              FROM remesas
             WHERE sidepag = reg.sidepag
               AND nsinies = vnsinies
               AND ftransf IS NOT NULL
               AND nremesa IS NOT NULL;   -- pago de siniestros ya transferido

            IF vexistsini = 0 THEN
               BEGIN
                  UPDATE pagosinitrami
                     SET cestpag = 2,
                         fefepag = f_sysdate
                   WHERE pagosinitrami.sidepag = reg.sidepag;

                  -- Siniestros
                  UPDATE pagosini
                     SET ctransf = 2,
                         ctransfer = 2,
                         cestpag = 2,
                         fefepag = f_sysdate
                   WHERE pagosini.sidepag = reg.sidepag;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PK_TRANFERENCIAS.F_TRANSFERIR', 3,
                                 'ERROR UPDATE PAGOSINI O PAGOSINITRAMI', SQLERRM);
                     RETURN 109997;
               END;

               IF vestsin <> 1 THEN   -- El siniestro no está ya finalizado
                  -- Si todos los pagos pendientes, no anulados, de un siniestro han
                  -- sido pagados y tiene la opcion cierre de expediente marcada,
                  -- entonces finalizamos el siniestro
                  SELECT COUNT(*)
                    INTO vcontapend
                    FROM pagosini
                   WHERE nsinies = vnsinies
                     AND ctippag = 2
                     AND cestpag NOT IN(2, 8)
                     AND pagosini.sidepag NOT IN(
                                              SELECT NVL(pp.spganul, 0)
                                                FROM pagosini pp
                                               WHERE nsinies = pagosini.nsinies
                                                 AND cestpag <> 8);

                  IF vcontapend = 0 THEN
                     SELECT COUNT(*)
                       INTO vcontacexp
                       FROM pagosini
                      WHERE nsinies = vnsinies
                        AND cptotal = 1
                        AND cestpag = 2
                        AND pagosini.sidepag NOT IN(
                                              SELECT NVL(pp.spganul, 0)
                                                FROM pagosini pp
                                               WHERE nsinies = pagosini.nsinies
                                                 AND cestpag <> 8)
                        AND ctippag = 2;

                     IF vcontacexp >= 1 THEN   -- tiene al menos 1 pago con cierre expediente, de tipo pago, en estado pagado
                                               -- y que no tengan pagos de anulación de pago
                        -- Finaliza siniestro: pac_sin.f_finalizar_sini
                        num_err := pac_sin.f_finalizar_sini(vnsinies, 1, vcramo || '01',
                                                            TRUNC(f_sysdate), 100832,
                                                            f_idiomauser);

                        IF num_err <> 0 THEN
                           RETURN 109997;
                        END IF;
                     END IF;
                  END IF;
               END IF;
----------------------------------------------------------------------------------------
            ELSE
               RETURN 180799;   -- Existen pagos de siniestros ya transferidos en su selección. Refrescar busqueda de Transferencias.
            END IF;
         ELSIF reg.catribu = 2 THEN
            SELECT COUNT(*)
              INTO vexistrenta
              FROM remesas
             WHERE sperson = reg.sperson
               AND nrentas = reg.nrentas
               AND ftransf IS NOT NULL
               AND nremesa IS NOT NULL;   -- pago de renta ya transferido

            IF vexistrenta = 0 THEN
               BEGIN
                  SELECT MAX(smovpag) + 1
                    INTO w_smovpag
                    FROM movpagren
                   WHERE srecren = reg.nrentas;

                  DECLARE
                     v_fecefec      DATE;
                     xnnumlin       NUMBER;
                     xnnumlinshw    NUMBER;
                     vimporte       NUMBER;
                     w_data         movrecibo.fmovini%TYPE;
                  BEGIN
                     BEGIN
                        SELECT TRUNC(fmovini)
                          INTO w_data
                          FROM movpagren
                         WHERE srecren = reg.nrentas
                           AND fmovfin IS NULL
                           AND cestrec = 0;
                     EXCEPTION
                        WHEN OTHERS THEN
                           w_data := f_sysdate;
                     END;

                     INSERT INTO movpagren
                                 (srecren, smovpag, cestrec,
                                  fmovini, fmovfin, fefecto)
                          VALUES (reg.nrentas, w_smovpag, 1,
                                  TRUNC(GREATEST(w_data, f_sysdate)), NULL, f_sysdate);

                     UPDATE pagosrenta
                        SET nremesa = w_sequence,
                            fremesa = f_sysdate
                      WHERE srecren = reg.nrentas;

                     UPDATE movpagren   --JRH IMP Yo creo que se debe actualizar la fecha del anterior movimiento
                        SET fmovfin = TRUNC(GREATEST(w_data, f_sysdate))
                      WHERE srecren = reg.nrentas
                        AND smovpag = w_smovpag - 1;

                     SELECT TRUNC(ffecefe), isinret
                       INTO v_fecefec, vimporte
                       FROM pagosrenta
                      WHERE srecren = reg.nrentas;

                     SELECT MAX(nnumlin)
                       INTO xnnumlin
                       FROM ctaseguro
                      WHERE sseguro = reg.sseguro;

                     IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                        SELECT MAX(nnumlin)
                          INTO xnnumlinshw
                          FROM ctaseguro_shadow
                         WHERE sseguro = reg.sseguro;
                     END IF;

                     --Ini Bug.: 10110 - ICV - 22/05/2009 - CRE066 - Modificación formulario de pago de rentas
                     BEGIN
                        SELECT cfeccob
                          INTO v_cfeccob
                          FROM productos
                         WHERE sproduc = reg.sproduc;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_cfeccob := NULL;
                     END;

                     --Fi Bug.:10110
                     num_err := insertar_ctaseguro(reg.sseguro, f_sysdate,
                                                   NVL(xnnumlin + 1, 1), f_sysdate, f_sysdate,
                                                   53, vimporte, NULL, NULL,   --En lugar del recibo
                                                   0, 0, NULL, NULL, v_cfeccob,

                                                   --vienen de fmovcta
                                                   GREATEST(w_data, f_sysdate), f_sysdate,
                                                   reg.nrentas);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                        num_err := insertar_ctaseguro_shw(reg.sseguro, f_sysdate,
                                                          NVL(xnnumlinshw + 1, 1), f_sysdate,
                                                          f_sysdate, 53, vimporte, NULL, NULL,   --En lugar del recibo
                                                          0, 0, NULL, NULL, v_cfeccob,

                                                          --vienen de fmovcta
                                                          GREATEST(w_data, f_sysdate),
                                                          f_sysdate, reg.nrentas);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PK_TRANFERENCIAS.F_TRANSFERIR', 4,
                                    'ERROR IMPOSIBLE DEFINIR ORIGEN', SQLERRM);
                        RETURN 109997;
                  END;
               END;
            ELSE
               RETURN 180798;   -- Existen pagos de rentas ya transferidos en su selección. Refrescar busqueda de Transferencias.
            END IF;
         ELSIF reg.catribu = 11 THEN
            -- BUG10604:DRA:02/07/2009:Inici
            -- Si es un reembolso, el marcarem com transferit
            -- Bug 10775 - APD - 29/07/2009 - Modificación fichero de transferencias para reembolsos
            -- se añaden los campos nreemb, nfact, nlinea y ctipo a la llamada a la funcion f_act_reembacto
            num_err := pk_transferencias.f_act_reembacto(reg.nreemb, pnremesa, f_sysdate,
                                                         reg.nfact, reg.nlinea, reg.ctipo);

            IF num_err <> 0 THEN
               RETURN 180831;
            END IF;
         -- BUG10604:DRA:02/07/2009:Fi
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PK_TRANFERENCIAS.F_TRANSFERIR', 5,
                     'error no controlado', SQLERRM);
         RETURN 109997;
   END f_transferir;

   FUNCTION f_generacion_fichero(pnremesa IN NUMBER)
      RETURN NUMBER IS
      w_fichero      UTL_FILE.file_type;
      w_rutaout      VARCHAR2(100);
      w_nomfichero   VARCHAR2(100);
      w_prelinea     VARCHAR2(80);
      w_linea        VARCHAR2(1000);
      w_benefici     VARCHAR2(12);
      w_nombre       VARCHAR2(100);
      w_tempres      empresas.tempres%TYPE;   --       w_tempres      VARCHAR2(200); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_tdomici      direcciones.tdomici%TYPE;   --       w_tdomici      VARCHAR2(40); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_tipo         VARCHAR2(30);
      w_mes          VARCHAR2(15);
      w_grupo        seguros.cbancar%TYPE := '0';   --  21-10-2011 JGR 0018944
      w_tpoblac      poblaciones.tpoblac%TYPE;   --       w_tpoblac      VARCHAR2(40); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_nnumnif      cobbancario.nnumnif%TYPE;   --       w_nnumnif      VARCHAR2(10); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_total        NUMBER;
      w_cuantos      NUMBER;
      w_bruto        NUMBER;
      w_empresa      NUMBER := 0;
      w_cpostal      codpostal.cpostal%TYPE;
      w_cpoblac      NUMBER;
      w_cprovin      NUMBER;
      num_err        NUMBER;
      concep         VARCHAR2(1);
      tipo           VARCHAR2(30);
      linea          VARCHAR2(80);
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;

      CURSOR remesa IS
         SELECT   *
             FROM remesas
            WHERE nremesa = pnremesa
         ORDER BY cempres, ccc, sproduc, sseguro;
   BEGIN
      w_rutaout := f_parinstalacion_t('TRANSFERENCIAS');
      -- Bucle para cada pago.
      w_total := 0;
      w_cuantos := 0;

      FOR r IN remesa LOOP
         --message ( 'ini loop ' || :c_trans );pause;
         IF r.cobliga = 1 THEN
            IF w_grupo <> r.ccc
               AND w_cuantos > 0
               AND w_grupo <> 0 THEN
               -- TOTALES
               w_linea := '0856' || RPAD(w_nnumnif, 10, ' ') || '            ' || '   '
                          || TO_CHAR(w_total * 100, 'FM000000000000')
                          || TO_CHAR(w_cuantos, 'FM00000000')
                          || TO_CHAR(w_cuantos * 4 + 5, 'FM0000000000');
               UTL_FILE.put_line(w_fichero, SUBSTR(w_linea, 1, 72));
               -- Cerramos el fichero
               UTL_FILE.fclose(w_fichero);
               w_total := 0;
               w_cuantos := 0;
            END IF;

            IF w_empresa <> r.cempres THEN
               -- datos de la empresa
               BEGIN
                  w_empresa := r.cempres;

                  SELECT e.tempres, d.tdomici, cpostal, cpoblac, cprovin
                    INTO w_tempres, w_tdomici, w_cpostal, w_cpoblac, w_cprovin
                    FROM empresas e, direcciones d
                   WHERE e.cempres = r.cempres
                     AND d.sperson = e.sperson
                     AND d.cdomici = (SELECT MIN(cdomici)
                                        FROM direcciones dd
                                       WHERE dd.sperson = d.sperson);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS.f_generacion_fichero',
                                 1,
                                 'ERROR AL LEER EMPRESAS O DIRECCIONES PARA EMPRESA = '
                                 || r.cempres,
                                 SQLERRM);
                     RETURN 120135;
               END;

               BEGIN
                  SELECT tpoblac
                    INTO w_tpoblac
                    FROM poblaciones
                   WHERE cpoblac = w_cpoblac
                     AND cprovin = w_cprovin;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PK_TRANSFERENCIAS.f_generacion_fichero',
                                 1,
                                 'ERROR AL LEER TABLA POBLACIONES PARA PROVINCIA = '
                                 || w_cprovin || ' POBLACION = ' || w_cpoblac,
                                 SQLERRM);
                     RETURN 120135;
               END;
            END IF;

            IF w_grupo <> r.ccc THEN
               w_grupo := r.ccc;
               w_nomfichero := f_parinstalacion_t('FILE_TRANS');

               IF w_nomfichero IS NULL THEN
                  w_nomfichero := 'CSB34_' || r.ccc || '_' || TO_CHAR(f_sysdate, 'DDMMYYYY')
                                  || '_' || TO_CHAR(f_sysdate, 'hh24') || '_'
                                  || TO_CHAR(f_sysdate, 'mi') || '_'
                                  || TO_CHAR(f_sysdate, 'ss') || '.TXT';
               END IF;

               BEGIN
                  SELECT b.nnumnif
                    INTO w_nnumnif
                    FROM cobbancariosel a, cobbancario b, seguros s, productos p
                   WHERE b.cbaja = 0
                     AND a.ccobban = b.ccobban
                     AND s.sseguro = r.sseguro
                     AND p.sproduc = s.sproduc
                     AND NVL(a.cramo, p.cramo) = p.cramo
                     AND NVL(a.ctipseg, p.ctipseg) = p.ctipseg
                     AND NVL(a.cmodali, p.cmodali) = p.cmodali
                     AND NVL(a.ccolect, p.ccolect) = p.ccolect
                     AND b.ncuenta = r.ccc
                     AND(b.ccobban = r.ccobban
                         OR r.ccobban IS NULL);   -- BUG9693:DRA:19/05/2009
               EXCEPTION
                  WHEN OTHERS THEN
                     SELECT DISTINCT nnumnif
                                INTO w_nnumnif
                                FROM cobbancario
                               WHERE ncuenta = r.ccc;
               END;

               w_fichero := UTL_FILE.fopen(w_rutaout, w_nomfichero, 'W');
               /*
                {calculo de los registros de  cabecera 4 lineas de cabcera obligatorias
                 1.- Fechas y cuentas de cargo
                 2.- nombre del ordenante
                 3.- direccion del ordenante
                 4.- plaza del ordenante
                 }
               */
               -- {prefijo de la cabecera : 03(obligatorio) + 56(indica euros ) + nif cobrador + 6_ }
               w_prelinea := '0356' || RPAD(w_nnumnif, 10, ' ') || '            ';
               /*
               {linea 1= prefijo cab + 001+fecha envio + fecha orden + entidad destino + oficina destino +
               ccuenta cargo+detalle de cargo+3_+dc cuenta cargo
               */
               w_linea := w_prelinea || '001' || TO_CHAR(f_sysdate, 'DDMMYY')
                          -- Fecha de Envio del Fichero
                          || TO_CHAR(f_sysdate, 'DDMMYY')
                          -- Fecha de EMisión de las ordenes
                          || SUBSTR(LPAD(r.ccc, 20, '0'), 1, 4)   -- Banco
                          || SUBSTR(LPAD(r.ccc, 20, '0'), 5, 4)   -- Oficina
                          || SUBSTR(LPAD(r.ccc, 20, '0'), 11, 10)   -- Cuenta
                          || '1'   -- Detalle del cargo.
                                || '   '   -- libre
                                        || SUBSTR(LPAD(r.ccc, 20, '0'), 9, 2);
               -- Dígito Control
               UTL_FILE.put_line(w_fichero, RPAD(w_linea, 72, ' '));
                                                       --> Primera linea cabecera
               /*
               linea 2 = prefijo cab + 002 + nombre ordenante(36)+7_
               */
               w_linea := w_prelinea || '002' || w_tempres;
               UTL_FILE.put_line(w_fichero, RPAD(w_linea, 72, ' '));
                                                       --> Segunda linea cabecera
               /*
               linea 3 = prefijo cab + 003 + domicilio ordenante(36)+7_
               */
               w_linea := w_prelinea || '003' || w_tdomici;
               UTL_FILE.put_line(w_fichero, RPAD(w_linea, 72, ' '));
                                                       --> Tercera linea cabecera
               /*
               linea 4 = prefijo cab + 004 + plaza ordenante (36)+7_
               */
               w_linea := w_prelinea || '004' || LPAD(w_cpostal, 4, '0') || '-' || w_tpoblac;
               UTL_FILE.put_line(w_fichero, RPAD(w_linea, 72, ' '));
            --> Tercera linea cabecera
            END IF;

            w_cuantos := w_cuantos + 1;
            w_total := w_total + r.iimport;
            w_nombre := NULL;
            w_benefici := NULL;
            w_bruto := NULL;
            w_mes := NULL;

            IF r.catribu IN(5, 6) THEN
               -- extornos y anulaciones de aprotación
               BEGIN
                  --Bug10612 - 14/07/2009 - DCT (canviar vista personas)
                  --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
                  SELECT cagente, cempres
                    INTO vagente_poliza, vcempres
                    FROM seguros
                   WHERE sseguro = r.sseguro;

                  SELECT SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20) || ','
                         || SUBSTR(d.tnombre, 0, 20),
                         RPAD(p.nnumide, 12, ' '), r.iimport, TO_CHAR(re.femisio, 'FMMONTH')
                    INTO w_nombre,
                         w_benefici, w_bruto, w_mes
                    FROM per_personas p, per_detper d, recibos re, riesgos ri
                   WHERE re.nrecibo = r.nrecibo
                     AND re.sseguro = ri.sseguro
                     AND NVL(re.nriesgo, 1) = ri.nriesgo
                     AND ri.sperson = p.sperson
                     AND d.sperson = p.sperson
                     AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
               /*SELECT tapelli1 || ' ' || tapelli2 || ',' || tnombre,
                      RPAD(nnumnif, 12, ' '), r.iimport,
                      TO_CHAR(recibos.femisio, 'FMMONTH')
                 INTO w_nombre,
                      w_benefici, w_bruto,
                      w_mes
                 FROM personas, recibos, riesgos
                WHERE recibos.nrecibo = r.nrecibo
                  AND recibos.sseguro = riesgos.sseguro
                  AND NVL(recibos.nriesgo, 1) = riesgos.nriesgo
                  AND riesgos.sperson = personas.sperson;*/

               --FI Bug10612 - 14/07/2009 - DCT (canviar vista personas)
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     p_tab_error
                         (f_sysdate, f_user, 'PK_TRANSFERENCIAS.f_generacion_fichero', 1,
                          'ERROR AL LEER TABLAS PERSONAS, RECIBOS, RIESGOS PARA RECIBO = '
                          || r.nrecibo,
                          SQLERRM);
                     RETURN 120135;
               END;
            ELSE
               BEGIN
                  --Bug10612 - 14/07/2009 - DCT (canviar vista personas)
                  --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
                  SELECT cagente, cempres
                    INTO vagente_poliza, vcempres
                    FROM seguros
                   WHERE sseguro = r.sseguro;

                  SELECT SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20) || ','
                         || SUBSTR(d.tnombre, 0, 20),
                         RPAD(p.nnumide, 12, ' '), pa.iimpsin, TO_CHAR(pa.fordpag, 'FMMONTH')
                    INTO w_nombre,
                         w_benefici, w_bruto, w_mes
                    FROM per_personas p, per_detper d, pagosini pa
                   WHERE pa.sidepag = r.sidepag
                     AND pa.sperson = p.sperson
                     AND d.sperson = p.sperson
                     AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
               /*SELECT tapelli1 || ' ' || tapelli2 || ',' || tnombre,
                       RPAD(nnumnif, 12, ' '), iimpsin, TO_CHAR(fordpag, 'FMMONTH')
                  INTO w_nombre,
                       w_benefici, w_bruto, w_mes
                  FROM personas, pagosini
                 WHERE pagosini.sidepag = r.sidepag
                   AND pagosini.sperson = personas.sperson;*/

               --FI Bug10612 - 14/07/2009 - DCT (canviar vista personas)
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        --Bug10612 - 14/07/2009 - DCT (canviar vista personas)
                        SELECT SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20)
                               || ',' || SUBSTR(d.tnombre, 0, 20),
                               RPAD(p.nnumide, 12, ' '), pa.iconret,
                               TO_CHAR(pa.ffecpag, 'FMMONTH')
                          INTO w_nombre,
                               w_benefici, w_bruto,
                               w_mes
                          FROM per_personas p, per_detper d, pagosrenta pa
                         WHERE pa.srecren = r.nrentas
                           AND pa.sperson = p.sperson
                           AND d.sperson = p.sperson
                           AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate,
                                                               vcempres);
                     /*SELECT tapelli1 || ' ' || tapelli2 || ',' || tnombre,
                           RPAD(nnumnif, 12, ' '), iconret, TO_CHAR(ffecpag, 'FMMONTH')
                      INTO w_nombre,
                           w_benefici, w_bruto, w_mes
                      FROM personas, pagosrenta p
                     WHERE p.srecren = r.nrentas
                       AND p.sperson = personas.sperson;*/

                     --FI Bug10612 - 14/07/2009 - DCT (canviar vista personas)
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           RETURN 120135;
                     END;
               END;
            END IF;

            /*
            {calculo de los registros de  beneficiario,2 registros obligatorios
              1.- Datos del abono : cuenta, importe (Obli.)
              2.- Datos del beneficiario(Obli.)
              3.- Concepto de la transferencia(Opc.)
            }
            */
            -- {prefijo de la beneficiario : 06(obligatorio) + 56(indica euros ) + nif cobrador + nif beneficiario }
            w_prelinea := '0656' || RPAD(w_nnumnif, 10, ' ') || w_benefici;

            /*
              linea 1 = prefijo bene + 010 + importe + cod. banco + ofic. bancaria + cuenta corriente +
                        1 (gastos a cuenta del ordenante) + 8 (concepto pension)+2_+dc cuenta
            */
            IF r.catribu IN(6, 8, 9, 10) THEN
               concep := 8;   -- pensión
            ELSE
               concep := 9;   --otros conceptos;
            END IF;

            w_linea := w_prelinea || '010' || TO_CHAR(r.iimport * 100, 'FM000000000000')
                       || SUBSTR(LPAD(r.cabono, 20, '0'), 1, 4)
                       || SUBSTR(LPAD(r.cabono, 20, '0'), 5, 4)
                       || SUBSTR(LPAD(r.cabono, 20, '0'), 11, 10) || '1' || concep || '  '
                       || SUBSTR(LPAD(r.cabono, 20, '0'), 9, 2);
            UTL_FILE.put_line(w_fichero, w_linea);
            /*
              linea 2 = prefijo bene + 011 + Nombre del beneficiario
            */-- Segunda linea del pago 2/4
            w_linea := w_prelinea || '011' || w_nombre;
            UTL_FILE.put_line(w_fichero, SUBSTR(w_linea, 1, 72));

             -- Segunda linea del pago 3/4
            /*
              linea 2 = prefijo bene + 016 + concepto (texto libre)
            */
            IF r.catribu = 8 THEN
               w_tipo := 'TRASPASO DE SALIDA';
            ELSIF r.catribu = 10 THEN
               w_tipo := 'PREST. ' || w_mes;
            ELSE
               w_tipo := 'DEVOLUCIÓN';
               num_err := f_desvalorfijo(701, 1, r.catribu, w_tipo);
            END IF;

            w_linea := w_prelinea || '016' || w_tipo || ' '
                       || TO_CHAR(w_bruto, 'FM999G999G990D00') || ' Euros';
            UTL_FILE.put_line(w_fichero, SUBSTR(w_linea, 1, 72));
            /*
              linea 4 = prefijo bene + 017 + concepto de la trasnferencia(ttexto libre)
            */
            w_linea := RPAD(w_prelinea || '017', 72, '=');
            UTL_FILE.put_line(w_fichero, SUBSTR(w_linea, 1, 72));
         END IF;
      /* va arriba
      IF     w_grupo <> r.ccc
         AND w_cuantos > 0 THEN
         -- TOTALES
         w_linea :=
            '0856' || RPAD (w_nnumnif, 10, ' ') || '            ' || '   '
            || TO_CHAR (w_total * 100, 'FM000000000000')
            || TO_CHAR (w_cuantos, 'FM00000000')
            || TO_CHAR (w_cuantos * 3 + 5, 'FM0000000000');
         UTL_FILE.PUT_LINE (w_fichero, SUBSTR (w_linea, 1, 72));
         -- Cerramos el fichero
         UTL_FILE.FCLOSE (w_fichero);
         w_total := 0;
         w_cuantos := 0;
      END IF;*/
      END LOOP;

      IF w_cuantos > 0 THEN
         -- TOTALES
         w_linea := '0856' || RPAD(w_nnumnif, 10, ' ') || '            ' || '   '
                    || TO_CHAR(w_total * 100, 'FM000000000000')
                    || TO_CHAR(w_cuantos, 'FM00000000')
                    || TO_CHAR(w_cuantos * 4 + 5, 'FM0000000000');
         UTL_FILE.put_line(w_fichero, SUBSTR(w_linea, 1, 72));
         UTL_FILE.fclose(w_fichero);
      END IF;

      IF UTL_FILE.is_open(w_fichero) THEN
         UTL_FILE.fclose(w_fichero);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Transferencias.f_genera_fichero', 1,
                     'error no controlado', SQLERRM);
         RETURN 140999;   --error no controlado
   END f_generacion_fichero;

   --JTS
   FUNCTION f_generacion_fichero_iban(pnremesa IN NUMBER)
      RETURN NUMBER IS
      w_fichero      UTL_FILE.file_type;
      w_rutaout      VARCHAR2(100);
      w_nomfichero   VARCHAR2(100);
      w_cuantos      NUMBER;
      w_linia        VARCHAR2(250);
      --
      --xmonedainst    eco_codmonedas.cmoneda%TYPE := pac_monedas.obtener_moneda_defecto;
      isomonedainst  monedas.ciso4217n%TYPE;   --       isomonedainst  VARCHAR2(3); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_ident_emi    VARCHAR2(4);
      w_cdoment      VARCHAR2(4);
      w_cempres      cobbancario.cdoment%TYPE;   --       w_cempres      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_tempres      empresas.tempres%TYPE;   --       w_tempres      VARCHAR2(40); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_cereceptora  VARCHAR2(2);
      w_decima       NUMBER(2);
      w_npoliza      NUMBER;   -- Bug 28462 - 08/10/2013 - HRE - Cambio de dimension SSEGURO
      w_ncertif      NUMBER;   -- Bug 28462 - 04/10/2013 - DEV - la precisión debe ser NUMBER
      w_codisnip     VARCHAR2(50);
      w_tnombre      VARCHAR2(50);
      w_toficina     VARCHAR2(50);
      w_diroficina   VARCHAR2(50);
      w_poblac       VARCHAR2(50);
      w_numcuenta    VARCHAR2(50);
      w_codipaisiso  VARCHAR2(2);
      w_cidioma      NUMBER;
      w_sperson      NUMBER;
      w_cdomici      NUMBER;
      w_tiplin1      VARCHAR2(100);
      w_tiplin2      VARCHAR2(100);
      w_tiplin3      VARCHAR2(100);
      w_total        NUMBER;   --NUMBER(12, 2) := 0;
      --
      d_avui         DATE;
      num_err        NUMBER;
      concep         VARCHAR2(1);
      tipo           VARCHAR2(30);
      linea          VARCHAR2(80);
      v_grupoccc     remesas.ccc%TYPE := '0';   -- BUG9693:DRA:20/04/2009
      vagente_poliza agentes.cagente%TYPE;
      vcempres       empresas.cempres%TYPE;
      w_ncass        reembfact.ncass%TYPE;
      w_nfact_cli    reembfact.nfact_cli%TYPE;
      w_nfactext     reembfact.nfactext%TYPE;
      w_facto        reembactosfac.facto%TYPE;

      CURSOR remesa IS
         SELECT   *
             FROM remesas
            WHERE nremesa = pnremesa
         ORDER BY cempres, ccc, sproduc, sseguro;
   BEGIN
      d_avui := f_sysdate;
      w_rutaout := f_parinstalacion_t('TRANSFERENCIAS');
      w_cuantos := 0;

      BEGIN
         SELECT ciso4217n
           INTO isomonedainst
           FROM monedas
          WHERE cmoneda = f_parinstalacion_n('MONEDAINST')
            AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 101916;   -- Error en la BD (MONEDA NO PERMITIDA)
      --raise others;
      END;

      FOR r IN remesa LOOP
         IF r.cobliga = 1 THEN
            -- BUG9693:DRA:20/04/2009:Inici
            IF v_grupoccc <> r.ccc THEN
               IF w_cuantos > 0 THEN
                  w_linia := '4' || w_ident_emi || w_cereceptora || TO_CHAR(d_avui, 'ddmmrr')
                             || 'A' || isomonedainst   --iso de moneda
                             || LPAD(TO_CHAR(w_total * 100), 14, '0')   --import total
                             || LPAD(w_cuantos, 5, '0')   --Nro documents
                             || LPAD(' ', 92, ' ');   --Espais
                  UTL_FILE.put_line(w_fichero, w_linia);
                  UTL_FILE.fclose(w_fichero);
               END IF;

               w_cuantos := 0;
               w_total := 0;
               v_grupoccc := r.ccc;
            END IF;

            -- BUG9693:DRA:20/04/2009:Fi

            --Registre 1
            IF w_cuantos = 0 THEN
               -- BUG9693:DRA:20/04/2009:Inici
               w_nomfichero := 'CSB34_' || r.ccc || '_' || TO_CHAR(f_sysdate, 'DDMMYYYY')
                               || '_' || TO_CHAR(f_sysdate, 'hh24') || '_'
                               || TO_CHAR(f_sysdate, 'mi') || '_' || TO_CHAR(f_sysdate, 'ss')
                               || '.TXT';
               -- BUG9693:DRA:20/04/2009:Fi
               w_fichero := UTL_FILE.fopen(w_rutaout, w_nomfichero, 'W');

               BEGIN
                  SELECT DISTINCT LPAD(tsufijo, 4, '0'), cdoment, cempres
                             INTO w_ident_emi, w_cdoment, w_cempres
                             FROM cobbancario
                            WHERE ncuenta = r.ccc
                              AND cempres = r.cempres   -- BUG9693:DRA:29/04/2009
                              AND cbaja = 0
                              AND(ccobban = r.ccobban
                                  OR r.ccobban IS NULL);   -- BUG9693:DRA:19/05/2009
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'pk_transferencias.f_genera_fichero_iban',
                                 111, 'CCC: ' || r.ccc, SQLERRM);
                     w_ident_emi := '  ';
                     w_cdoment := '  ';
                     w_cempres := '  ';
               END;

               num_err := f_desempresa(w_cempres, NULL, w_tempres);
               w_linia := '1' || w_ident_emi || LPAD(w_cdoment, 2, '0')
                          || TO_CHAR(d_avui, 'ddmmrr') || RPAD(w_tempres, 30, ' ') || 'A'
                          || RPAD(isomonedainst, 3, '0') || TO_CHAR(d_avui, 'ddmmrr') || 'T'
                          || RPAD(SUBSTR(r.ccc, 1, 24), 24, ' ') || LPAD(' ', 39, ' ')
                          || TO_CHAR(d_avui, 'rr') || LPAD(r.nremesa, 5, '0') || 'A010';
               UTL_FILE.put_line(w_fichero, w_linia);
            END IF;

            --Registre 2
            /*SELECT npoliza, ncertif
              INTO w_npoliza, w_npoliza
              FROM seguros
             WHERE sseguro = r.sseguro;*/
            num_err := f_nomrecibo(r.sseguro, w_tnombre, w_cidioma, w_sperson, w_cdomici);
            num_err := f_direccion(1, w_sperson, w_cdomici, 1, w_tiplin1, w_tiplin2, w_tiplin3);

            BEGIN
               --Bug10612 - 14/07/2009 - DCT (canviar vista personas)
               --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
               SELECT cagente, cempres
                 INTO vagente_poliza, vcempres
                 FROM seguros
                WHERE sseguro = r.sseguro;

               SELECT NVL(codisoiban, '  ')
                 INTO w_codipaisiso
                 FROM per_detper pd, paises p
                WHERE p.cpais = pd.cpais
                  AND pd.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
                  AND pd.sperson = w_sperson;
            EXCEPTION
               WHEN OTHERS THEN
                  w_codipaisiso := '  ';
            END;

            BEGIN
               -- BUG 8217 - 07/05/2009 - SBG - Afegim un NVL perquè si és nul,
               -- desquadra el fitxer
               SELECT NVL(snip, ' ')
                 -- FINAL BUG 8217 - 07/05/2009 - SBG
               INTO   w_codisnip
                 FROM per_personas
                WHERE sperson = w_sperson;
            EXCEPTION
               WHEN OTHERS THEN
                  w_codisnip := '  ';
            END;

            IF w_tiplin1 IS NULL THEN
               w_tiplin1 := ' ';
            END IF;

            IF w_tiplin2 IS NULL THEN
               w_tiplin2 := ' ';
            END IF;

            w_cereceptora := RPAD(SUBSTR(r.cabono, 7, 2), 2, '0');
            w_linia := '2' || w_ident_emi
                                         /*|| LPAD (w_npoliza, 10, ' ')
                                         || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
                       || RPAD(w_codisnip, 14, ' ') || RPAD(SUBSTR(w_tnombre, 1, 30), 30, ' ')
                       || RPAD(SUBSTR(w_tiplin1, 1, 30), 30, ' ')
                       || RPAD(SUBSTR(w_tiplin2, 1, 20), 20, ' ')
                       || w_codipaisiso   --codipais iso
                                       || 'C' || LPAD(TO_CHAR(r.iimport * 100), 12, '0')
                       || w_cereceptora || '  '   --Sucursal (opcional)
                       || '01'   --Número de registres de tipus 3
                       || ' '   --Tipus document, no significatiu
                             || LPAD(' ', 7, ' ');   --Espais
            UTL_FILE.put_line(w_fichero, w_linia);
            w_total := w_total + r.iimport;
            --Registre 2D
            w_linia := '2' || w_ident_emi
                                         /*|| LPAD (w_npoliza, 10, ' ')
                                         || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
                       || RPAD(w_codisnip, 14, ' ') || ' '   --Despeses a carrec del beneficiari?
                       || RPAD(r.cabono, 34, ' ')   -- BUG11119:DRA:16/09/2009
                       || LPAD(' ', 30, ' ')
                                            --Nom ordenant si es diferent del registre 1
                       || LPAD(' ', 35, ' ')   --Motiu del pagament
                       || LPAD(' ', 8, ' ')   --Espais
                                           || 'D';   --Tipus registre 2
            UTL_FILE.put_line(w_fichero, w_linia);
            --Registre 2E
            /*SELECT descripcion
              INTO w_tempres
              FROM cobbancario
             WHERE ncuenta = r.cabono AND cbaja = 0;*/
            num_err := f_domibanc_poliza(r.sseguro, w_tempres, w_toficina, w_diroficina,
                                         w_poblac, w_numcuenta);

            BEGIN
               SELECT NVL(ppp.codisoiban, '  ')
                 INTO w_codipaisiso
                 FROM paises ppp, provincias p, poblaciones pp
                WHERE ppp.cpais = p.cpais
                  AND pp.cprovin = p.cprovin
                  AND UPPER(pp.tpoblac) = UPPER(w_poblac)
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  w_codipaisiso := '  ';
            END;

            IF w_codipaisiso != 'AD'
               AND w_codipaisiso != '  ' THEN
               w_linia := '2' || w_ident_emi
                                            /*|| LPAD (w_npoliza, 10, ' ')
                                            || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
                          || RPAD(w_codisnip, 14, ' ')
                          || RPAD(w_tempres, 35, ' ')   --Nom banc beneficiari
                          || RPAD(w_diroficina, 35, ' ')   --Adrça banc beneficiari
                          || RPAD(w_poblac, 27, ' ')   --Poblacio ban beneficiari
                          || LPAD(' ', 8, ' ')   --Codi CHIPS
                          || LPAD(w_codipaisiso, 2, ' ')   --Codi pais banc beneficiari
                          || LPAD(' ', 1, ' ')   --Espais
                                              || 'E';   --Tipus registre 2
               UTL_FILE.put_line(w_fichero, w_linia);
            END IF;

            --Registre 3
            -- Bug 10775 - APD - 30/07/2009 - Modificación fichero de transferencias para reembolsos
            -- en el apartado de texto libre debe aparecer la siguiente informacion si catribu = 11:
            --    MALALT:XXXXXXX           FULL:XXXXXXXXXXXXXX NPAGAM:XXXXXXX
            --                             DATA      PAGAR
            --    NATURALESA ACTE          ACTE      IMPORT
            --    DESPESA SANITARIA      XX-XX-XX    XXXXX
            IF r.catribu = 11 THEN
               BEGIN
                  SELECT rf.ncass, rf.nfact_cli, rf.nfactext, raf.facto
                    INTO w_ncass, w_nfact_cli, w_nfactext, w_facto
                    FROM reembfact rf, reembactosfac raf
                   WHERE rf.nreemb = raf.nreemb
                     AND rf.nfact = raf.nfact
                     AND raf.nreemb = r.nreemb
                     AND raf.nfact = r.nfact
                     AND raf.nlinea = r.nlinea;
               EXCEPTION
                  WHEN OTHERS THEN
                     w_ncass := NULL;
                     w_nfact_cli := NULL;
                     w_nfactext := NULL;
                     w_facto := NULL;
               END;

               w_linia :=
                  '3' || w_ident_emi || RPAD(w_codisnip, 14, ' ')
                  || '01'   -- BUG11119:DRA:14/09/2009
                  || RPAD
                       (RPAD
                           (UPPER
                                 (f_axis_literales(9002043,
                                                   NVL(w_cidioma,
                                                       pac_md_common.f_get_cxtidioma)))   -- Malalt
                            || w_ncass,
                            21, ' ')
                        || RPAD
                             (UPPER
                                   (f_axis_literales(100855,
                                                     NVL(w_cidioma,
                                                         pac_md_common.f_get_cxtidioma)))   -- Full
                              || w_nfact_cli,
                              24, ' ')
                        || RPAD
                             (UPPER
                                 (f_axis_literales(9002044,
                                                   NVL(w_cidioma,
                                                       pac_md_common.f_get_cxtidioma)))   -- N.Pagam
                              || w_nfactext,
                              33, ' '),
                        78, ' ')   --Format lliure
                  || RPAD(' ', 29, ' ');   --Espais
               UTL_FILE.put_line(w_fichero, w_linia);
               w_linia :=
                  '3' || w_ident_emi || RPAD(w_codisnip, 14, ' ')
                  || '02'   -- BUG11119:DRA:14/09/2009
                  || RPAD
                       (RPAD(' ', 26, ' ')
                        || RPAD
                             (UPPER
                                   (f_axis_literales(100562,
                                                     NVL(w_cidioma,
                                                         pac_md_common.f_get_cxtidioma)))   -- Data
                              || ' ' || ' ',
                              26, ' ')
                        || RPAD
                             (UPPER
                                  (f_axis_literales(9002045,
                                                    NVL(w_cidioma,
                                                        pac_md_common.f_get_cxtidioma)))   -- Pagar
                              || ' ' || ' ',
                              26, ' '),
                        78, ' ')   --Format lliure
                  || RPAD(' ', 29, ' ');   --Espais
               UTL_FILE.put_line(w_fichero, w_linia);
               w_linia :=
                  '3' || w_ident_emi || RPAD(w_codisnip, 14, ' ')
                  || '03'   -- BUG11119:DRA:14/09/2009
                  || RPAD
                       (RPAD
                           (UPPER
                               (f_axis_literales(9002046,
                                                 NVL(w_cidioma, pac_md_common.f_get_cxtidioma)))   -- Naturalesa Acte
                            || ' ' || ' ',
                            26, ' ')
                        || RPAD
                             (UPPER
                                   (f_axis_literales(9000456,
                                                     NVL(w_cidioma,
                                                         pac_md_common.f_get_cxtidioma)))   -- Acte
                              || ' ' || ' ',
                              26, ' ')
                        || RPAD
                             (UPPER
                                 (f_axis_literales(100563,
                                                   NVL(w_cidioma,
                                                       pac_md_common.f_get_cxtidioma)))   -- Import
                              || ' ' || ' ',
                              26, ' '),
                        78, ' ')   --Format lliure
                  || RPAD(' ', 29, ' ');   --Espais
               UTL_FILE.put_line(w_fichero, w_linia);
               w_linia :=
                  '3' || w_ident_emi || RPAD(w_codisnip, 14, ' ')
                  || '04'   -- BUG11119:DRA:14/09/2009
                  || RPAD
                       (RPAD
                           (UPPER
                               (f_axis_literales(9002047,
                                                 NVL(w_cidioma, pac_md_common.f_get_cxtidioma)))   -- Despesa Sanitaria
                            || ' ' || ' ',
                            26, ' ')
                        || RPAD(TO_CHAR(w_facto, 'dd-mm-yy'), 26, ' ')   --fecha
                        || RPAD(LTRIM(TO_CHAR(r.iimport, '999G990D00')), 26, ' ')   -- importe
                                                                                 ,
                        78, ' ')   --Format lliure
                  || RPAD(' ', 29, ' ');   --Espais
               UTL_FILE.put_line(w_fichero, w_linia);
            -- Bug 10775 - APD - 30/07/2009 - Fin Modificación fichero de transferencias para reembolsos
            ELSE
               w_linia :=
                  '3' || w_ident_emi
                                    /*|| LPAD (w_npoliza, 10, ' ')
                                    || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
                  || RPAD(w_codisnip, 14, ' ') || '01'   -- BUG11119:DRA:14/09/2009
                  --|| RPAD('Abonament al seu compte s/factura num. ' || r.nsinies, 78, ' ')   --Format lliure
                  || RPAD
                       (f_axis_literales
                                 (9001804, NVL(w_cidioma, pac_md_common.f_get_cxtidioma))   -- BUG10442:DRA:15/06/2009
                        || ' ' || NVL(r.nsinies, r.nrecibo),   --MCA 27/11/2009
                        78, ' ')   --Format lliure
                  || RPAD(' ', 29, ' ');   --Espais
               UTL_FILE.put_line(w_fichero, w_linia);
            END IF;

            w_cuantos := w_cuantos + 1;
         END IF;
      END LOOP;

      --Registre 4
      IF w_cuantos > 0 THEN
         w_linia := '4' || w_ident_emi || w_cereceptora || TO_CHAR(d_avui, 'ddmmrr') || 'A'
                    || isomonedainst   --iso de moneda
                    || LPAD(TO_CHAR(w_total * 100), 14, '0')   --import total
                    || LPAD(w_cuantos, 5, '0')   --Nro documents
                                              || LPAD(' ', 92, ' ');   --Espais
         UTL_FILE.put_line(w_fichero, w_linia);
         UTL_FILE.fclose(w_fichero);
      END IF;

      IF UTL_FILE.is_open(w_fichero) THEN
         UTL_FILE.fclose(w_fichero);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF UTL_FILE.is_open(w_fichero) THEN
            UTL_FILE.fclose(w_fichero);
         END IF;

         p_tab_error(f_sysdate, f_user, 'pk_transferencias.f_genera_fichero_iban', 1,
                     'error no controlado', SQLERRM);
         RETURN 140999;   --error no controlado
   END f_generacion_fichero_iban;

   FUNCTION f_generar_fichero(pnremesa IN NUMBER, p_formato VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      /* como cada instalacion crea en el recibo las descripciones
        y las lineas que le parece, encapsulamos la generación
        del fichero en el PAC_PROPIO*/
      IF LOWER(p_formato) != 'iban' THEN
         num_err := f_generacion_fichero(pnremesa);
      ELSE
         num_err := f_generacion_fichero_iban(pnremesa);
      END IF;

      RETURN num_err;
   END f_generar_fichero;

   FUNCTION f_traspasar_rentas(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      ptipoproceso IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER IS
      coderr         NUMBER;
      excep          EXCEPTION;
      pnremesa       NUMBER;
      vsremisesion   remesas.sremsesion%TYPE;   --NUMBER;
   BEGIN
      IF (pcempres IS NULL)
         OR(pcidioma IS NULL) THEN
         coderr := 140974;
         RAISE excep;
      END IF;

      UPDATE remesas
         SET ccausin = 0,
             cimpres = 0;

      --BORRAR MOVIMIENTOS NO TRANSFERIDOS, PARA INICIALIZAR
      DELETE FROM remesas
            WHERE nremesa IS NULL
              AND ftransf IS NULL;

      --Seleccionem la sequencia per el numero de la remesa
      SELECT sremeses.NEXTVAL
        INTO vsremisesion
        FROM DUAL;

      --Insertamos las rentas pedtes. en tabla remesas
      coderr := f_insert_remesas(pcempres, pcidioma, vsremisesion, 0, 1);   --tipProceso: 0-todos 1- Rentas 2- recibos 3- siniestros

      IF coderr <> 0 THEN
         RAISE excep;
      END IF;

      --Ponemos cobliga a 1 para que sean procesados los registros de REMESAS en el siguiente proceso que los inserta en CTASEGURO
      UPDATE remesas
         SET remesas.cobliga = 1
       WHERE cempres = pcempres
         AND sremsesion = vsremisesion
         AND(ftransf IS NULL
             OR nremesa IS NULL)
         AND EXISTS(SELECT 1
                      FROM seguros
                     WHERE seguros.sseguro = remesas.sseguro
                       AND((seguros.sproduc = psproduc
                            AND psproduc IS NOT NULL)
                           OR(psproduc IS NULL)));

      --Transferimos a CTASEGURO
      coderr := f_transferir(pcempres, vsremisesion, pnremesa);

      IF coderr <> 0 THEN
         RAISE excep;
      END IF;

      --generamos el fichero
      coderr := f_generar_fichero(pnremesa);

      IF coderr <> 0 THEN
         RAISE excep;
      END IF;

      UPDATE remesas
         SET ccausin = 0,
             ftransf = f_sysdate,
             cimpres = 1,
             sremsesion = NULL
       WHERE ccausin = 1
         AND sremsesion = vsremisesion;

      --Inicializamos de nuevo la tabla
      BEGIN
         DELETE FROM remesas
               WHERE nremesa IS NULL
                 AND ftransf IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN excep THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pk_Transferencias.f_traspasar_rentas', 1,
                     'error  controlado', coderr);
         RETURN coderr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pk_Transferencias.f_traspasar_rentas', 1,
                     'error no controlado', SQLERRM);
         RETURN 140999;
   END f_traspasar_rentas;

   FUNCTION f_traspasar_venc_renta(pcempres IN NUMBER, pcidioma IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      coderr         NUMBER;
      excep          EXCEPTION;
      pnremesa       NUMBER;
      vsremisesion   remesas.sremsesion%TYPE;   /*  NUMBER;  */
   BEGIN
      IF (pcempres IS NULL)
         OR(pcidioma IS NULL) THEN
         coderr := 140974;
         RAISE excep;
      END IF;

      UPDATE remesas
         SET ccausin = 0,
             cimpres = 0;

      --BORRAR MOVIMIENTOS NO TRANSFERIDOS, PARA INICIALIZAR
      DELETE FROM remesas
            WHERE nremesa IS NULL
              AND ftransf IS NULL;

      --  Seleccionem la sequencia per el numero de la remesa
      SELECT sremeses.NEXTVAL
        INTO vsremisesion
        FROM DUAL;

      --Insertamos las rentas pedtes. en tabla remesas
      -->codErr:=f_insert_remesas (pcempres ,pcidioma , 0, 3,10,3); --tipProceso: 3- siniestros
      coderr := f_insert_remesas(pcempres, pcidioma, vsremisesion, 0, 3, 10, 3);   --tipProceso: 3- siniestros

      IF coderr <> 0 THEN   --10 rentas y el 3 causa sini vencimientos
         RAISE excep;
      END IF;

      --Ponemos cobliga a 1 para que sean procesados los registros de REMESAS en el siguiente proceso que los inserta en CTASEGURO
      UPDATE remesas
         SET remesas.cobliga = 1
       WHERE cempres = pcempres
         AND sremsesion = vsremisesion
         AND(ftransf IS NULL
             OR nremesa IS NULL)
         AND EXISTS(SELECT 1
                      FROM seguros
                     WHERE seguros.sseguro = remesas.sseguro
                       AND((seguros.sproduc = psproduc
                            AND psproduc IS NOT NULL)
                           OR(psproduc IS NULL)));

      --Transferimos a CTASEGURO
      coderr := f_transferir(pcempres, vsremisesion, pnremesa);

      IF coderr <> 0 THEN
         RAISE excep;
      END IF;

      --generamos el fichero
      coderr := f_generar_fichero(pnremesa);

      IF coderr <> 0 THEN
         RAISE excep;
      END IF;

      UPDATE remesas
         SET ccausin = 0,
             ftransf = f_sysdate,
             cimpres = 1,
             sremsesion = NULL
       WHERE ccausin = 1
         AND sremsesion = vsremisesion;

      --Inicializamos de nuevo la tabla
      BEGIN
         DELETE FROM remesas
               WHERE nremesa IS NULL
                 AND ftransf IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN excep THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pk_Transferencias.f_traspasar_rentas', 1,
                     'error  controlado', coderr);
         RETURN coderr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'Pk_Transferencias.f_traspasar_rentas', 1,
                     'error no controlado', SQLERRM);
         RETURN 140999;
   END f_traspasar_venc_renta;

   -- BUG10604:DRA:02/07/2009:Inici
   /*************************************************************************
    FUNCTION f_act_reembacto
    Actualitza els reembolsos marcant-los com transferits
    param in p_nreemb    : código del reembolso
    return             : NUMBER
   *************************************************************************/
   FUNCTION f_act_reembacto(
      p_nreemb IN NUMBER,
      p_sremesa IN NUMBER,
      p_ftrans IN DATE,
      p_nfact IN NUMBER,
      p_nlinea IN NUMBER,
      p_ctipo IN NUMBER)
      RETURN NUMBER IS
      --
      v_cestado      reembolsos.cestado%TYPE;
      v_numlin       NUMBER;
   BEGIN
      IF p_ctipo = 1 THEN   -- Pago Normal
         UPDATE reembactosfac
            SET ftrans = p_ftrans,
                nremesa = p_sremesa   --BUG11285-XVM-02102009
          WHERE nreemb = p_nreemb
            AND nfact = p_nfact
            AND nlinea = p_nlinea;

         SELECT cestado
           INTO v_cestado
           FROM reembolsos
          WHERE nreemb = p_nreemb;

         SELECT COUNT(1)
           INTO v_numlin
           FROM reembactosfac
          WHERE nreemb = p_nreemb
            AND ftrans IS NULL
            AND nremesa IS NULL;

         -- Bug 10775 - APD - 03/08/2009 - si el estado del reembolso es Aceptado o Gestión compañia
         -- y no queda ningún acto por transferir, se marca el reembolso como transferido
         IF (v_cestado = 2   -- Aceptado
             OR v_cestado = 1)   -- Gestión compañía
            AND NVL(v_numlin, 0) = 0 THEN
            -- Si no queda ningún acto por transferir marcamos al reembolso como transferido
            -- Si el reembolso estaba aceptado también se marca como transferido
            UPDATE reembolsos
               SET cestado = 3,
                   festado = p_ftrans
             WHERE nreemb = p_nreemb;
         END IF;
      ELSIF p_ctipo = 2 THEN   -- Pago Complemento
         UPDATE reembactosfac
            SET ftranscomp = p_ftrans,
                nremesacomp = p_sremesa   --BUG11285-XVM-02102009
          WHERE nreemb = p_nreemb
            AND nfact = p_nfact
            AND nlinea = p_nlinea;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Transferencias.f_act_reembacto', 1,
                     'error no controlado. reemb: ' || p_nreemb || '. p_sremesa: '
                     || p_sremesa,
                     SQLERRM);
         RETURN 140999;   --error no controlado
   END f_act_reembacto;
-- BUG10604:DRA:02/07/2009:Fi
END pk_transferencias;

/

  GRANT EXECUTE ON "AXIS"."PK_TRANSFERENCIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TRANSFERENCIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TRANSFERENCIAS" TO "PROGRAMADORESCSI";
