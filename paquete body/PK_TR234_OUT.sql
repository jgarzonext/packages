--------------------------------------------------------
--  DDL for Package Body PK_TR234_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_TR234_OUT" IS
   /*****************************************************************************
      NOMBRE:     PK_TR234_OUT
      PROPÓSITO:

      REVISIONES:
      Ver        Fecha        Autor            Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0        15/01/2010   JLB              1. Creación del package
       2.0        18/03/2010   FAL              2. 0013153: CEM - Nombres de ficheros generados por AXIS
       3.0        29/09/2010   FAL              3. 0015904: CEM - Nomenclatura fitxer N234
       4.0        05/10/2010   RSC              4. 0016227: CEM - Norma 234: Si longitud de ledades de persona (nom + cognoms) > 36 no genera resultat al fitxer.
       5.0        14/10/2010   SRA              5. 0016323: CEM - Q234 transferenias traspasos salidas externas (Porcentaje aportaciones posteriores 2006)
       6.0        12/11/2010   RSC              6. 0016678: GENERACIÓN 234 SALIDAS NO LO HACE BIEN
       7.0        16/11/2010   RSC              7. 0016720: Traspasos: No carga la compañia destino correctamente
       8.0        18/11/2010   RSC              8. 0016747: GENERACIÓN 234 SALIDAS NO LO HACE BIEN
       9.0        12/01/2011   JMP              9. 0017245: Habilitar proceso rechazar solicitudes
      10.0        16/01/2013   NMM           10.25376: CALI - Revisión de incidencias implantación del módulo de traspasos
   ******************************************************************************/
   FUNCTION busca_aportants(vsseguro IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN 0;
   END busca_aportants;

   ---
   FUNCTION busca_embarg(vsseguro IN NUMBER)
      RETURN BOOLEAN IS
      xbloqpig       NUMBER(1);
      nerror         NUMBER(10);
      nnumlin        NUMBER;
      ttexto         VARCHAR2(200);
   BEGIN
      xbloqpig := f_bloquea_pignorada(vsseguro, f_sysdate);
      ttexto := f_axis_literales(9901088, f_idiomauser);
      nerror := f_proceslin(vsproces, ttexto || ' ' || xbloqpig, vsseguro, nnumlin);

      IF xbloqpig = 0 THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END;

   ---
   PROCEDURE obrir(pcinout IN NUMBER, pfhasta IN DATE) IS
      nnumlin        NUMBER;
      nerror         NUMBER;
      ttexto         VARCHAR2(200);
   BEGIN
      ----
      IF c_generar%ISOPEN THEN
         CLOSE c_generar;
      END IF;

      OPEN c_generar(pcinout, pfhasta);

      ----
      noperacions := 0;
      nregistres := 0;
      stransfers := 0;
      ---
      sortir := FALSE;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_tr234_out.obrir', 1, 'When others.',
                     SQLERRM || ' ' || SQLCODE);

         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_generar%ISOPEN THEN
            CLOSE c_generar;
         END IF;

         nnumlin := NULL;
         ttexto := f_axis_literales(1000455, f_idiomauser);
         nerror := f_proceslin(vsproces, ttexto || ' ' || SQLCODE, 1, nnumlin);
         sortir := TRUE;
   END obrir;

   ----
   PROCEDURE acabar(vsproces IN NUMBER) IS
      nerror         NUMBER := 0;
   BEGIN
      nerror := f_procesfin(vsproces, nerror);

      IF c_generar%ISOPEN THEN
         CLOSE c_generar;
      END IF;
   -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_tr234_out.acabar', 1, 'When others.',
                     SQLERRM || ' ' || SQLCODE);

         IF c_generar%ISOPEN THEN
            CLOSE c_generar;
         END IF;
   END acabar;

   ----
   PROCEDURE llegir(vsproces IN NUMBER) IS
      nerror         NUMBER(8) := 0;
      nnumlin        NUMBER(8) := NULL;
      xtext          VARCHAR2(100) := NULL;
      --   gestdest NUMBER(6);
      --   gestorig NUMBER(6);
      --   fonsdest NUMBER(6);
      --   fonsorig NUMBER(6);
      --   pladest NUMBER(6);
      --   plaorig NUMBER(6);
      rechazo_solicitud EXCEPTION;
      anulado        EXCEPTION;
      agrupacion     NUMBER;
      ptdc234        NUMBER;
      psproduc       NUMBER;
      error          NUMBER;
      ttexto         VARCHAR2(200);
      -- Bug 19425 - RSC - 26/10/2011 - CIV998-Activar la nova gestio de traspassos
      v_cempres      seguros.cempres%TYPE;
   -- Fin Bug 19425
   BEGIN
      ncerror := 0;
      nport := nport + 1;

      FETCH c_generar
       INTO r_generar;

      IF c_generar%FOUND THEN
         BEGIN
            inicialitzar;


            ----
            -- traspas.clau_oper := r_GENERAR.clauoper;
            IF (r_generar.cinout = 1
                AND r_generar.cestado IN(1, 2)) THEN
               traspas.clau_oper := 1;
            ELSIF(r_generar.cinout = 2
                  AND r_generar.cestado IN(6, 8)) THEN
               traspas.clau_oper := 2;
            ELSIF(r_generar.cinout = 2
                  AND r_generar.cestado IN(3, 4)) THEN
               traspas.clau_oper := 3;
            END IF;



            /*********************
                        ---- jamr - Si el seguro es nulo es que es un rechazo de solicitud
                        ----        y tenemos que hacer otro proceso en el RAISE
                        IF r_GENERAR.STDC is NOT null THEN
                          RAISE RECHAZO_SOLICITUD;
                        END IF;
            *******************/
            -----
            -- BUG 17245 - 12/01/2011 - JMP - Si no tenemos el SSEGURO, informamos los datos que nos llegan del fichero ya que no los
            --                                podemos obtener de otra manera
            IF r_generar.sseguro IS NULL THEN
               traspas.numidsol := r_generar.numidsol;
               traspas.tnomsol := r_generar.tnomsol;
               traspas.nifgori := r_generar.nifgori;
               traspas.cdgsgori := r_generar.cdgsgori;
               traspas.cdgsppori := r_generar.cdgsppori;
               traspas.niffpori := r_generar.niffpori;
               traspas.cdgsfpori := r_generar.cdgsfpori;
               traspas.nrbe := r_generar.nrbe;
            -- FI BUG 17245 - 12/01/2011 - JMP
            ELSE
               SELECT cagrpro, sproduc
                 INTO agrupacion, psproduc
                 FROM seguros
                WHERE sseguro = r_generar.sseguro;

               error := f_parproductos(psproduc, 'TDC234', ptdc234);

               IF agrupacion = 11 THEN
                  SELECT p.tnompla
                    INTO xnompla
                    FROM proplapen pr, planpensiones p, seguros s
                   WHERE s.sseguro = r_generar.sseguro
                     AND pr.sproduc = s.sproduc
                     AND p.ccodpla = pr.ccodpla;
               ELSIF NVL(ptdc234, 0) = 1 THEN
                  SELECT t.ttitulo
                    INTO xnompla
                    FROM seguros s, titulopro t
                   WHERE s.cramo = t.cramo
                     AND s.cmodali = t.cmodali
                     AND s.ctipseg = t.ctipseg
                     AND s.ccolect = t.ccolect
                     AND t.cidioma = s.cidioma
                     AND s.sseguro = r_generar.sseguro;
               END IF;
            END IF;

            ----
            --traspas.clau_oper := r_GENERAR.clauoper;
            IF traspas.clau_oper = 1 THEN   ---sol·licitut
               bapabe := TRUE;
               batransfer := FALSE;
               baiplapen := FALSE;
               baiprest := FALSE;
               bteembarg := FALSE;
               bminusv := FALSE;
               bidrec := FALSE;
            ELSIF traspas.clau_oper = 2 THEN   ---sol refusada o demorada
               ----Ja estarà a la taula
               --traspas.motiu_refusa := r_GENERAR.motiu;
               traspas.motiu_refusa := NULL;   -- JLB - pendiente
               bapabe := FALSE;
               batransfer := FALSE;
               baiplapen := FALSE;
               baiprest := FALSE;
               bteembarg := FALSE;
               bminusv := FALSE;
               bidrec := FALSE;
            ELSIF traspas.clau_oper = 3 THEN   ---transferència
               transfer.clau_inici := 1;
               transfer.data_emi_dev := '000000';
               transfer.motiu_devo := 0;
               bapabe := TRUE;
               batransfer := TRUE;
               baiplapen := TRUE;
               baiprest := FALSE;
               bteembarg := FALSE;
               bminusv := FALSE;
               bidrec := FALSE;
            ELSIF traspas.clau_oper = 4 THEN   ---transferència rebutjada
               -----Falta determinar com es farà o quan es produirà i on.
               -----Potser només passa a nivell de dipositària i aleshores per l'axis
               -----és un cas que no es produirà mia
               transfer.data_emi_dev := '000000';
               transfer.motiu_devo := 0;
               bapabe := FALSE;
               batransfer := TRUE;
               baiplapen := FALSE;
               baiprest := FALSE;
               bteembarg := FALSE;
               bminusv := FALSE;
               bidrec := FALSE;
            END IF;

            --IF r_GENERAR.clauoper IN (2,4) AND r_GENERAR.motiu IS NULL THEN
            IF traspas.clau_oper IN(2, 4)
               AND r_generar.cmotrod IS NULL THEN
               vnerror := 140998;
               RAISE errorcontrolat;
            END IF;

            --IF r_GENERAR.clauoper IN (1,2) THEN
            IF traspas.clau_oper IN(1, 2) THEN

               DBMS_OUTPUT.PUT_LINE ( 'ANTES DE INSERTAR AÑO ' ||r_generar.stras);
               SELECT cinout, ccodpla, ccompani, cbancar, cestado, ctiptras,
                      ctiptras, iimporte, iimptemp, iimpanu, fantigi, nparpla, nporcen,   -- SPRESTAPLAN, SPERSON,
                      nparret, srefc234, 1,
                 -----, CTIPREN, CTIPCAP, FPROPAG, CPERIOD, CREVAL, CTIPREV, FPROREV, PREVALO, IREVALO, NREVANU
                      -- ALBERTO NUEVOS CAMPOS
                      numaport,
                      ccobroreduc,
                      anyoreduc,
                      ccobroactual,
                      anyoactual,
                      importeacumact,
                      nvl(anyoaport,to_number(TO_CHAR(trasplainout.fvalor,'YY'))) ,
                      fvalor
               INTO   traspas.sentit, xpla, xppa, xcbancar, xcestado, traspas.tipus,
                      xtiptras, xiimporte, xiimptemp, xiimpanu, xfantigi, xnparpla, xnporcen,   --xSPRESTAPLAN, xSPERSON,
                      xnparret_tr, xrefc234, traspas.partobene,
                      platransf.numaport,
                      platransf.ccobroreduc,
                      platransf.anyoreduc,
                      platransf.ccobroactual,
                      platransf.anyoactual,
                      platransf.importeacumact,
                      platransf.anyoaport  ,
                      platransf.fvalor
                 -- JLB
                 --
               FROM   trasplainout
                WHERE stras = r_generar.stras;
                               DBMS_OUTPUT.PUT_LINE ( 'DESPUES DE INSERTAR AÑO ');
            --ELSIF r_GENERAR.clauoper IN (3,4) THEN
            ELSIF traspas.clau_oper IN(3, 4) THEN

               DBMS_OUTPUT.PUT_LINE ( 'pase3:' || r_generar.stras  );
               SELECT t.stras, t.cinout, ccodpla, ccompani, t.cbancar, t.cestado,
                      t.ctiptras, t.ctiptras, t.iimporte, t.iimptemp, t.iimpanu, t.fantigi,
                      t.nparpla, t.nporcen,   -- T.SPRESTAPLAN, T.SPERSON,
                                           c.nsinies, c.sidepag, c.imovimi, c.fvalmov,
                      t.nparret, srefc234, 1,
                 --T.CPARBEN, porcenirpf
                 ----, CTIPREN, CTIPCAP, FPROPAG, CPERIOD, CREVAL, CTIPREV, FPROREV, PREVALO, IREVALO, NREVANU
                      -- ALBERTO NUEVOS CAMPOS
                      numaport,
                      ccobroreduc,
                      anyoreduc,
                      ccobroactual,
                      anyoactual,
                      importeacumact,
                      nvl(anyoaport,to_number(to_char(t.fvalor,'YY'))),
                      t.fvalor
               INTO   r_generar.stras, traspas.sentit, xpla, xppa, xcbancar, xcestado,
                      traspas.tipus, xtiptras, xiimporte, xiimptemp, xiimpanu, xfantigi,
                      xnparpla, xnporcen,   --xSPRESTAPLAN, xSPERSON,
                                         xnsinies, xsidepag, ximovimi, xfvalmov,
                      xnparret_tr, xrefc234, traspas.partobene,

                      platransf.numaport,
                      platransf.ccobroreduc,
                      platransf.anyoreduc,
                      platransf.ccobroactual,
                      platransf.anyoactual,
                      platransf.importeacumact,
                      platransf.anyoaport  ,
                      platransf.fvalor
                 --,  xPORCENIRPF
               FROM   ctaseguro c, trasplainout t
                WHERE c.sseguro = t.sseguro
                  -- AND trunc(c.fvalmov) = trunc(r_GENERAR.fvalmov)
                  AND TRUNC(c.fcontab) = TRUNC(t.fcontab)
                  AND t.stras = r_generar.stras
                  AND t.nnumlin = c.nnumlin;
               DBMS_OUTPUT.PUT_LINE ( 'pase3 fin');
            END IF;

            IF r_generar.sseguro IS NOT NULL THEN   -- BUG 17245 - 12/01/2011 - JMP
               ----Mirem si esta en situació de cobrament
               ----o si ha estat en situació de cobrament
               DECLARE
                  xnisinies      NUMBER(3) := 0;
               BEGIN
                  SELECT COUNT(nsinies)
                    INTO xnisinies
                    FROM sin_siniestro
                   WHERE sseguro = r_generar.sseguro
                     AND ccausin IN(12, 13);

                  ----Ha de cobrar o ha cobrat
                  traspas.partobene := 2;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ----Ni ha de cobrar ni ha cobrat
                     traspas.partobene := 1;
               END;
            END IF;

            ---- de moment semppre particep
            traspas.partobene := 1;

            DECLARE
               xcomerc        NUMBER(1);
               ppadgs         VARCHAR2(10);
            BEGIN
               IF xpla IS NOT NULL THEN
                  SELECT ccomerc
                    INTO xcomerc
                    FROM planpensiones
                   WHERE ccodpla = xpla;
               ELSIF xppa IS NOT NULL THEN   --PPA
                  SELECT 0, coddgs
                    INTO xcomerc, ppadgs
                    FROM aseguradoras
                   WHERE ccodaseg = xppa;

                  IF ppadgs IS NULL
                     AND NVL(xcomerc, 0) <> 1 THEN
                     RAISE noespotenviar;
                  END IF;
               END IF;

               IF xcomerc = 1 THEN
                  RAISE nosenvia;
               END IF;
            END;

            ----DADES GENERALS-------------------
            -----si transferencia o traspas total registre 202 només s'informa el tipus
            -----de traspas
            --IF r_GENERAR.clauoper = 3 AND traspas.tipus = 1 THEN
            IF traspas.clau_oper = 3
               AND traspas.tipus = 1 THEN
               traspas.tipus_imp := 0;
               traspas.import := 0;
               traspas.PERCENT := 0;
               traspas.partic := 0;
            ELSIF traspas.tipus = 2 THEN   ---es parcial.
               SELECT DECODE(NVL(xiimptemp, 0),
                             0, DECODE(NVL(xnparpla, 0),
                                       0, DECODE(NVL(xnporcen, 0), 0, 0, 2),
                                       3),
                             1)
                 INTO traspas.tipus_imp
                 FROM DUAL;

               IF traspas.tipus_imp = 1 THEN
                  traspas.import := xiimptemp;
                  traspas.PERCENT := 0;
                  traspas.partic := 0;
               ELSIF traspas.tipus_imp = 2 THEN
                  traspas.import := 0;
                  traspas.PERCENT := xnporcen;
                  traspas.partic := 0;
               ELSIF traspas.tipus_imp = 3 THEN
                  traspas.import := 0;
                  traspas.PERCENT := 0;
                  traspas.partic := xnparpla;
               END IF;
            ELSE
               traspas.tipus_imp := 0;
               traspas.import := 0;
               traspas.PERCENT := 0;
               traspas.partic := 0;
            END IF;

            /* JLB - lo recupero directamente si recalcularlo
              gestdest := NULL;
              gestorig := NULL;
              fonsdest := NULL;
              fonsorig := NULL;
              pladest  := NULL;
              plaorig  := NULL;
            */
            IF traspas.sentit = 1 THEN   ----Entrada: només seran solicitus que fem
               ----origen: pla extern; desti: pla de CS
               --Si la solicitud no está pendent de confirmar
               -- no enviem la solicitut.
               IF xcestado = 5 THEN
                  RAISE anulado;
               END IF;

               IF xpla IS NOT NULL THEN
                  SELECT g.sperson, g.coddgs, f.sperson,
                         f.coddgs, NVL(r.cbancar, f.cbancar),
                         SUBSTR(NVL(r.cbancar, f.cbancar), 1, 4), p.coddgs
                    INTO origen.gestora.sperson, origen.gestora.dgsfp, origen.fons.sperson,
                         origen.fons.dgsfp, origen.fons.ccc,
                         origen.fons.nrbe, origen.pla.dgsfp
                    FROM planpensiones p, fonpensiones f, gestoras g, relfondep r
                   WHERE p.ccodpla = xpla
                     AND f.ccodfon = p.ccodfon
                     AND r.ccodfon(+) = f.ccodfon
                     AND r.ctrasp(+) = 1
                     AND g.ccodges = f.ccodges;
               ELSIF xppa IS NOT NULL THEN   -- ppa
                  ---Si no tenim dades de ASEGURADORAS_PLANES
                  ---agafem les daes d'ASEGURADORAS
                  SELECT g.sperson, g.coddgs, g.sperson,
                         NVL(p.coddgs, g.coddgs), NVL(r.cbancar, g.cbancar), g.ccodban,
                         NVL(p.coddgs, g.coddgs)   --'NPPA' Bug 25376-XVM-29/07/13
                    INTO origen.gestora.sperson, origen.gestora.dgsfp, origen.fons.sperson,
                         origen.fons.dgsfp, origen.fons.ccc, origen.fons.nrbe,
                         origen.pla.dgsfp
                    FROM aseguradoras_planes p, aseguradoras g, relasegdep r
                   WHERE p.ccodaseg(+) = g.ccodaseg
                     AND g.ccodaseg = r.ccodaseg(+)
                     AND r.ctrasp(+) = 1
                     AND g.ccodaseg = xppa;

                  v_nppa1 := 1;
               END IF;

               SELECT nnumide
                 INTO origen.gestora.nif
                 FROM per_personas
                WHERE sperson = origen.gestora.sperson;

               SELECT nnumide
                 INTO origen.fons.nif
                 FROM per_personas
                WHERE sperson = origen.fons.sperson;

               IF agrupacion = 11 THEN   --pp
                  SELECT g.sperson, g.coddgs, f.sperson,
                         f.coddgs, NVL(r.cbancar, f.cbancar),
                         SUBSTR(NVL(r.cbancar, f.cbancar), 1, 4), p.coddgs
                    INTO desti.gestora.sperson, desti.gestora.dgsfp, desti.fons.sperson,
                         desti.fons.dgsfp, desti.fons.ccc,
                         desti.fons.nrbe, desti.pla.dgsfp
                    FROM planpensiones p, fonpensiones f, gestoras g, seguros se, proplapen pr,
                         relfondep r
                   WHERE f.ccodfon = p.ccodfon
                     AND g.ccodges = f.ccodges
                     AND p.ccodpla = pr.ccodpla
                     AND pr.sproduc = se.sproduc
                     AND r.ccodfon(+) = f.ccodfon
                     AND r.ctrasp(+) = 1
                     AND se.sseguro = r_generar.sseguro;
               ELSIF agrupacion = 2 THEN   -- ppa
                  SELECT g.sperson, g.coddgs, g.sperson,
                         NVL(p.coddgs, g.coddgs), NVL(r.cbancar, g.cbancar),
                         SUBSTR(NVL(r.cbancar, g.cbancar), 1, 4),
                         NVL(p.coddgs, g.coddgs)   --'NPPA' Bug 25376-XVM-29/07/13
                    INTO desti.gestora.sperson, desti.gestora.dgsfp, desti.fons.sperson,
                         desti.fons.dgsfp, desti.fons.ccc,
                         desti.fons.nrbe,
                         desti.pla.dgsfp
                    FROM aseguradoras_planes p, aseguradoras g, seguros se, proplapen pr,
                         relasegdep r
                   WHERE se.sseguro = r_generar.sseguro
                     AND se.sproduc = pr.sproduc
                     AND pr.ccodpla = p.ccodaseg
                     AND r.ccodaseg(+) = g.ccodaseg
                     AND r.ctrasp(+) = 1
                     AND p.ccodaseg = g.ccodaseg;

                  v_nppa2 := 1;
               END IF;

               SELECT nnumide
                 INTO desti.gestora.nif
                 FROM per_personas
                WHERE sperson = desti.gestora.sperson;

               SELECT nnumide
                 INTO desti.fons.nif
                 FROM per_personas
                WHERE sperson = desti.fons.sperson;

               IF origen.fons.ccc IS NULL THEN
                  vnerror := 140996;
                  RAISE errorcontrolat;
               END IF;
            ELSIF traspas.sentit = 2 THEN   ----Sortida: traspassos que hem acceptat

                        DBMS_OUTPUT.PUT_LINE ( 'pase4:');
               ----o sol·licituts que rebutgem
               ----origen: pla de CS; desti: pla extern
               IF xpla IS NOT NULL THEN
                  SELECT g.sperson, g.coddgs, f.sperson,
                         f.coddgs, NVL(r.cbancar, f.cbancar),
                         SUBSTR(NVL(r.cbancar, f.cbancar), 1, 4), p.coddgs
                    INTO desti.gestora.sperson, desti.gestora.dgsfp, desti.fons.sperson,
                         desti.fons.dgsfp, desti.fons.ccc,
                         desti.fons.nrbe, desti.pla.dgsfp
                    FROM planpensiones p, fonpensiones f, gestoras g, relfondep r
                   WHERE p.ccodpla = xpla
                     AND f.ccodfon = p.ccodfon
                     AND r.ccodfon(+) = f.ccodfon
                     AND r.ctrasp(+) = 1
                     AND g.ccodges = f.ccodges;
               ELSIF xppa IS NOT NULL THEN   -- ppa
                  SELECT g.sperson, g.coddgs, g.sperson,
                         NVL(p.coddgs, g.coddgs), NVL(r.cbancar, g.cbancar), g.ccodban,
                         NVL(p.coddgs, g.coddgs)   --'NPPA' Bug 25376-XVM-29/07/13
                    INTO desti.gestora.sperson, desti.gestora.dgsfp, desti.fons.sperson,
                         desti.fons.dgsfp, desti.fons.ccc, desti.fons.nrbe,
                         desti.pla.dgsfp
                    FROM aseguradoras_planes p, aseguradoras g, relasegdep r
                   WHERE p.ccodaseg = g.ccodaseg
                     AND r.ccodaseg(+) = g.ccodaseg
                     AND r.ctrasp(+) = 1
                     AND p.ccodaseg = xppa;

                  v_nppa2 := 1;
               END IF;

               IF (xpla IS NOT NULL
                   OR xppa IS NOT NULL) THEN   -- BUG 17245 - 12/01/2011 - JMP
                  SELECT nnumide
                    INTO desti.gestora.nif
                    FROM per_personas
                   WHERE sperson = desti.gestora.sperson;

                  SELECT nnumide
                    INTO desti.fons.nif
                    FROM per_personas
                   WHERE sperson = desti.fons.sperson;
               END IF;

               IF r_generar.sseguro IS NOT NULL THEN   -- BUG 17245 - 12/01/2011 - JMP
                  IF agrupacion = 11 THEN   --ppa
                     SELECT g.sperson, g.coddgs,
                            f.sperson, f.coddgs, NVL(r.cbancar, f.cbancar),
                            SUBSTR(NVL(r.cbancar, f.cbancar), 1, 4), p.coddgs
                       INTO origen.gestora.sperson, origen.gestora.dgsfp,
                            origen.fons.sperson, origen.fons.dgsfp, origen.fons.ccc,
                            origen.fons.nrbe, origen.pla.dgsfp
                       FROM planpensiones p, fonpensiones f, gestoras g, seguros se,
                            proplapen pr, relfondep r
                      WHERE f.ccodfon = p.ccodfon
                        AND g.ccodges = f.ccodges
                        AND p.ccodpla = pr.ccodpla
                        AND pr.sproduc = se.sproduc
                        AND r.ccodfon(+) = f.ccodfon
                        AND r.ctrasp(+) = 1
                        AND se.sseguro = r_generar.sseguro;
                  ELSIF agrupacion = 2 THEN
                     SELECT g.sperson, g.coddgs,
                            g.sperson, NVL(p.coddgs, g.coddgs), NVL(r.cbancar, g.cbancar),
                            SUBSTR(NVL(r.cbancar, g.cbancar), 1, 4),
                            NVL(p.coddgs, g.coddgs)   --'NPPA' Bug 25376-XVM-29/07/13
                       INTO origen.gestora.sperson, origen.gestora.dgsfp,
                            origen.fons.sperson, origen.fons.dgsfp, origen.fons.ccc,
                            origen.fons.nrbe,
                            origen.pla.dgsfp
                       FROM aseguradoras_planes p, aseguradoras g, seguros se, proplapen pr,
                            relasegdep r
                      WHERE se.sseguro = r_generar.sseguro
                        AND se.sproduc = pr.sproduc
                        AND pr.ccodpla = p.ccodaseg
                        AND r.ccodaseg(+) = g.ccodaseg
                        AND r.ctrasp(+) = 1
                        AND p.ccodaseg = g.ccodaseg;

                     v_nppa1 := 1;
                  END IF;

                  SELECT nnumide
                    INTO origen.gestora.nif
                    FROM per_personas
                   WHERE sperson = origen.gestora.sperson;

                  SELECT nnumide
                    INTO origen.fons.nif
                    FROM per_personas
                   WHERE sperson = origen.fons.sperson;
               END IF;

               IF desti.fons.ccc IS NULL THEN
                  vnerror := 140996;
                  RAISE errorcontrolat;
               END IF;
            END IF;

            DBMS_OUTPUT.PUT_LINE ( 'pase5:');
            IF traspas.clau_oper = 1 THEN   ---solicitut: Tots els de Caixa ho admeten
               desti.pla.indprecap := 1;
               desti.pla.indpreren := 1;
               desti.pla.indpremix := 1;
            END IF;

            IF xrefc234 IS NULL THEN
               xrefc234 := TO_CHAR(f_sysdate, 'yymmdd') || LPAD(r_generar.stras, 7, '0');
            END IF;

            traspas.referoper := xrefc234;
            -----LPAD(r_generar.stras, 13, '0');

            ----DADES GENERALS-------------------
            ----BENEFICIARIS/PARTICEPS-----------
            --Quan operació sigui 3:
            --En cas de traspassar un beneficiari que no és l'assegurat
            --les dades del beneficiari es corregiran a l'informar les dades
            --de la prestació
            partoben.aporpostsn := 'N';
            partoben.porconpost := NVL(xporcenirpf, 0);
            partoben.porecopost := 0;

            -- BUG 17245 - 12/01/2011 - JMP - En caso de rechazo, si SSEGURO es nulo informamos los datos a partir de la tabla TRASPLAINOUT
            IF traspas.clau_oper IN(1, 2, 3) THEN
               IF traspas.clau_oper = 2
                  AND r_generar.sseguro IS NULL THEN
                  partoben.assnif := traspas.numidsol;
                  partoben.assnoms := SUBSTR(traspas.tnomsol, 1, 36);
                  origen.gestora.nif := SUBSTR(traspas.nifgori, 1, 9);
                  origen.gestora.dgsfp := traspas.cdgsgori;
                  origen.pla.dgsfp := traspas.cdgsppori;
                  origen.fons.nif := SUBSTR(traspas.niffpori, 1, 9);
                  origen.fons.dgsfp := traspas.cdgsfpori;
                  origen.fons.nrbe := traspas.nrbe;
               ELSE
                  -- Bug 16227 - RSC - 05/10/2010 - CEM - Norma 234: Si longitud de ledades de persona (nom + cognoms)
                  -- > 36 no genera resultat al fitxer. (añadimos el SUBSTR)
                  SELECT pe.sperson, LPAD(nnumide, 9, '0'),
                         SUBSTR(f_nombre(pe.sperson, 1, seg.cagente), 1, 36)
                    INTO xsperson_ass, partoben.assnif,
                         partoben.assnoms
                    FROM per_personas pe, riesgos ri, seguros seg
                   WHERE ri.sseguro = r_generar.sseguro
                     AND seg.sseguro = ri.sseguro
                     AND ri.nriesgo = 1
                     AND pe.sperson = ri.sperson;
               -- Fin Bug 16227
               END IF;
            END IF;

            -- FIN BUG 17245 - 12/01/2011 - JMP
                        DBMS_OUTPUT.PUT_LINE ( 'pase6:');
            IF traspas.clau_oper IN(1, 3) THEN
               IF NVL(traspas.partobene, 1) = 1 THEN   --es particep
                  IF traspas.clau_oper = 1 THEN
                     ----partoben.tipusdret := 1;
                     ----Com que ATCA no envia si és partícep o beneficari
                     ----sempre enviarem drets econòmics i consolidats.
                     partoben.tipusdret := 3;
                     partoben.formacobr := 1;
                  ELSIF traspas.clau_oper = 3 THEN
                     partoben.tipusdret := 1;
                     partoben.formacobr := 0;
                  END IF;

                  bidrec := FALSE;

                  IF NVL(xporcenirpf, 0) > 0 THEN
                     partoben.aporpostsn := 'S';
                     partoben.porconpost := NVL(xporcenirpf, 0) * 100;
                     partoben.porecopost := 0;
                  END IF;
               ELSIF traspas.partobene = 2 THEN   --es beneficiari
                  ----A xprestaplan tenim: quan clau_oper sigui 3, la prestació que traspassem
                  ----Quan clau_oper és 1 la prestació que demanem que ens traspassin, encara
                  ----no la tenim entrada (no hi ha registres a PRESTAPLAN). La informació de
                  ----la prestació està definida a TRASPLAINOUT (segons informació del client).
                  ----En el fitxer només cal informar però de si té particiapcions retingudes.
                  IF traspas.clau_oper = 3 THEN
                     partoben.formacobr := 1;
                     partoben.tipusdret := 2;

                     IF NVL(xporcenirpf, 0) > 0 THEN
                        partoben.aporpostsn := 'S';
                        partoben.porconpost := 0;
                        partoben.porecopost := xporcenirpf * 100;
                     END IF;

                     bidrec := TRUE;
                  ELSE   ---solicitut
                     bidrec := FALSE;
                  END IF;

                  IF traspas.clau_oper = 1 THEN   ----En les sol·licituts sempre es demanarà tots 2
                     partoben.tipusdret := 3;
                  END IF;
               /********************************
               IF partoben.tipusdret IN (2, 3) THEN
                  DECLARE
                     xctipcap       NUMBER(2);
                  BEGIN
                     SELECT DISTINCT (ctipcap)
                                INTO xctipcap
                                FROM trasplapresta
                               WHERE stras = r_generar.stras;

                     SELECT DECODE(xctipcap, 1, 2, 2, 3, 1, 1)
                       INTO partoben.formacobr
                       FROM DUAL;
                  EXCEPTION
                     WHEN TOO_MANY_ROWS THEN
                        partoben.formacobr := 1;
                     WHEN NO_DATA_FOUND THEN
                        partoben.formacobr := 1;
                  END;
               ELSE
                  partoben.formacobr := 0;
               END IF;
               *********************/
               END IF;
            END IF;

            ----BENEFICIARIS/PARTICEPS-----------
            ----TRANSFERÈNCIA--------------------
            IF traspas.clau_oper IN(3, 4) THEN
               ---- jr. comentat per més endavant al desenvolupar PLANS de PENSIÓ
               -----xvnparpla := f_valor_participlan(xfvalmov, r_generar.sseguro, tdiv);

               -- Bug 19425 - RSC - 26/10/2011 - CIV998-Activar la nova gestio de traspassos
               SELECT cempres
                 INTO v_cempres
                 FROM seguros
                WHERE sseguro = r_generar.sseguro;

               IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
                  -- Fin Bug 19425
                  SELECT SUBSTR(cbancar, 1, 4), SUBSTR(cbancar, 5, 4)
                    INTO transfer.ent_benef, transfer.ofic_benef
                    FROM destinatarios
                   WHERE nsinies = xnsinies
                     AND ctipdes = 1;
               ELSE
                  SELECT SUBSTR(cbancar, 1, 4), SUBSTR(cbancar, 5, 4)
                    INTO transfer.ent_benef, transfer.ofic_benef
                    FROM sin_tramita_destinatario
                   WHERE nsinies = xnsinies
                     AND ntramit = 0
                     AND ctipdes = 5;
               END IF;

               BEGIN
                  SELECT SUBSTR(cb.ncuenta, 1, 4), SUBSTR(cb.ncuenta, 5, 4),
                         SUBSTR(cb.ncuenta, 9, 2), SUBSTR(cb.ncuenta, 11, 10)
                    INTO transfer.entitat_ord, transfer.ofic_ord,
                         transfer.dctrl_ord, transfer.compte_ord
                    FROM seguros s, cobbancario cb
                   WHERE s.sseguro = r_generar.sseguro
                     AND cb.ccobban = s.ccobban;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     transfer.entitat_ord := NULL;
                     transfer.ofic_ord := NULL;
                     transfer.dctrl_ord := NULL;
                     transfer.compte_ord := NULL;
               END;

               BEGIN
                  IF traspas.clau_oper = 3 THEN
                     SELECT TO_CHAR(TRUNC(ftransf), 'DDMMYYY')
                       INTO transfer.data_emi
                       FROM remesas
                      WHERE sidepag = xsidepag
                        AND nsinies = xnsinies;

                     transfer.data_emi_dev := '000000';
                  ELSIF traspas.clau_oper = 4 THEN
                     SELECT TO_CHAR(TRUNC(ftransf), 'DDMMYYY')
                       INTO transfer.data_emi_dev
                       FROM remesas
                      WHERE sidepag = xsidepag
                        AND nsinies = xnsinies;

                     transfer.data_emi := transfer.data_emi_dev;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     IF traspas.clau_oper = 3 THEN
                        transfer.data_emi_dev := '000000';
                        transfer.data_emi := TO_CHAR(f_sysdate, 'DDMMYY');
                     ELSIF traspas.clau_oper = 4 THEN
                        transfer.data_emi_dev := TO_CHAR(f_sysdate, 'DDMMYY');
                        transfer.data_emi := TO_CHAR(f_sysdate, 'DDMMYY');
                     END IF;
               END;

               IF traspas.partobene = 2 THEN
                  transfer.importeco := ximovimi;
               ELSE
                  transfer.importeco := 0;   ----import a ctaseguro
               END IF;

               transfer.import := ximovimi;   ----import a ctaseguro
               stransfers := stransfers + ximovimi;
            END IF;

            ----TRANSFERÈNCIA--------------------

            ----ALTRES DADES DEL PLA TRASPASSAT---
            IF traspas.clau_oper = 3 THEN
               ------Primera aportació
               platransf.data_pr_aport := '000000';

               SELECT TO_CHAR(MIN(dia), 'DDMMYY')
                 INTO platransf.data_pr_aport
                 FROM (SELECT fantigi dia
                         FROM trasplainout
                        WHERE sseguro = r_generar.sseguro
                          AND cinout IN
                                (1, 2)   -- Bug 16720 - RSC - 16/11/2010 - Traspasos: No carga la compañia destino correctamente
                          AND cestado = 4
                       UNION ALL
                       SELECT fvalmov dia
                         FROM ctaseguro
                        WHERE sseguro = r_generar.sseguro
                          AND cmovimi IN(1, 2));

               IF platransf.data_pr_aport IS NULL THEN
                  SELECT TO_CHAR(fefecto, 'DDMMYY')
                    INTO platransf.data_pr_aport
                    FROM seguros
                   WHERE sseguro = r_generar.sseguro;
               END IF;

               ---Altres contingències = participacions retingudes
               platransf.ind_dc_ac := 2;
               platransf.dc_altres_con := 0;

               IF traspas.partobene = 2
                  AND partoben.tipusdret = 3 THEN
                  platransf.ind_dc_ac := 1;
                  platransf.dc_altres_con := ROUND(xvnparpla * xnparret_tr, 2);
               END IF;

               ----Aportacions d'aquest any
               platransf.ind_aport_any := 2;
               platransf.aport_any := 0;

               -- Bug 16678 - RSC - 12/11/2010 - GENERACIÓN 234 SALIDAS NO LO HACE BIEN
               IF xiimpanu IS NULL
                  OR xiimpanu = 0 THEN
                  -- Fin Bug 16678
                  SELECT NVL(SUM(DECODE(cmovimi, 51, -imovimi, imovimi)), 0)
                    INTO platransf.aport_any
                    FROM ctaseguro
                   WHERE sseguro = r_generar.sseguro
                     AND cmovimi IN(1, 2, 51)
                     AND TO_CHAR(fvalmov, 'yyyy') = TO_CHAR(platransf.fvalor, 'yyyy')
                      AND ctipapor<>'PR';
               -- Bug 16678 - RSC - 12/11/2010 - GENERACIÓN 234 SALIDAS NO LO HACE BIEN
               ELSE
                  platransf.aport_any := xiimpanu;
               END IF;

               -- Fin Bug 16678

               -- Fin bug 16678
               IF platransf.aport_any <> 0 THEN
                  platransf.ind_aport_any := 1;
               END IF;

               platransf.ind_contr_pr_any := 2;   ----Aportacions del promotor
               -- alberto
                    SELECT NVL(SUM(DECODE(cmovimi, 51, -imovimi, imovimi)), 0)
                    INTO platransf.contr_pr_any
                    FROM ctaseguro
                   WHERE sseguro = r_generar.sseguro
                     AND cmovimi IN(1, 2, 51)
                     AND CTIPAPOR='PR'
                     AND TO_CHAR(fvalmov, 'yyyy') = TO_CHAR(platransf.fvalor, 'yyyy');

               IF nvl(platransf.contr_pr_any,0) > 0 then
                              platransf.ind_contr_pr_any := 2;   ----Aportacions del promotor
               END IF;

               platransf.contr_pr_any := 0;
               platransf.ind_compl_tras := 1;   -----Complement de traspàs
               ----EMBARGAT-------------------------
               ----jrv.14.01.2010.Suposem que no té embargaments
               bteembarg := busca_embarg(r_generar.sseguro);
               bteembarg := FALSE;

               IF NOT bteembarg THEN
                  eembarg.autoritat := NULL;
                  eembarg.data_com := NULL;
                  eembarg.id_demanda := NULL;
                  platransf.ind_embarg := 0;
               ELSE
                  platransf.ind_embarg := 0;

                  FOR reg IN (SELECT *
                                FROM bloqueoseg
                               WHERE sseguro = r_generar.sseguro
                                 AND cmotmov IN(261, 262)
                                 AND ffinal IS NULL) LOOP
                     platransf.ind_embarg := platransf.ind_embarg + 1;
                     pk_tr234_out.embarg(platransf.ind_embarg).nembarg := platransf.ind_embarg;
                     pk_tr234_out.embarg(platransf.ind_embarg).autoritat :=
                                                                     SUBSTR(reg.ttexto, 1, 35);
                     pk_tr234_out.embarg(platransf.ind_embarg).data_com := reg.finicio;
                     pk_tr234_out.embarg(platransf.ind_embarg).id_demanda :=
                                                                    SUBSTR(reg.ttexto, 36, 27);
                  END LOOP;
               END IF;

               ----EMBARGAT-------------------------

               ----A FAVOR DE MINUSVALIDS------------
               ---jrv.14.01.2010. Desactivem minusvalids
               platransf.n_aport_minus := 0;
               platransf.ind_apor_am := 1;
               platransf.dc_apor_am := 0;
               platransf.data_minus := NULL;
               /***********************
               IF platransf.ind_minus = 2 THEN
                  platransf.n_aport_minus := busca_aportants(r_GENERAR.SSEGURO);
                  IF platransf.n_aport_minus <> 0 THEN
                     bMINUSV := TRUE;
                     platransf.ind_apor_am := 1;
                     platransf.dc_apor_am := 0;
                     FOR i IN 1..platransf.n_aport_minus LOOP
                        aporamnv(i).num_aportant := i;
                        aporamnv(i).dc_aporta_totals := 0;
                        ----
                        aporamnv(i).ind_aporta_any := 2;
                        aporamnv(i).aporta_any := 0;
                        IF aporamnv(i).aporta_any <> 0 THEN
                           aporamnv(i).ind_aporta_any := 1;
                        END IF;
                        ----
                        aporamnv(i).nomtot_aportant := NULL;
                        aporamnv(i).nif_aportant := NULL;
                     END LOOP;
                  END IF;
               END IF;
               **********************/
               ----A FAVOR DE MINUSVALIDS------------

               ----INFORMACIONS PRESTACIONS----------
               ----jrv.14.01.2010. Desactivem prestacions
               platransf.ind_part_scobr := 1;
               platransf.dr_econ_traspassat := 0;
               /*
               DECLARE
                  xnisinies NUMBER(3) := 0;
               BEGIN
                  SELECT COUNT(ss.NSINIES)
                  INTO xnisinies
                  FROM sin_siniestro ss, sin_movsiniestro sm
                  WHERE ss.sseguro = r_generar.sseguro
                  AND ss.nsinies = sm.nsinies
                  AND ss.ccausin in (12, 13);
                  platransf.ind_part_scobr := 2;  ---Situació de cobrament
               EXCEPTION
                  WHEN TOO_MANY_ROWS THEN
                     platransf.ind_part_scobr := 2;  ---Situació de cobrament
                  WHEN NO_DATA_FOUND THEN
                     platransf.ind_part_scobr := 1;  ---No Situació de cobrament
               END;
               DECLARE
                  xmodif NUMBER(3) := 0;
               BEGIN
                  SELECT COUNT(ss.NSINIES)
                  INTO xmodif
                  FROM sin_siniestro ss, sin_movsiniestro sm
                  WHERE ss.sseguro = r_generar.sseguro
                  AND ss.ccausin in (12, 13)
                  AND ss.nsinies = sm.nsinies
                  AND TO_CHAR(sm.FESTSIN, 'YYYY') = TRUNC(f_sysdate, 'YYYY');
                  IF xmodif IS NOT NULL THEN
                     prest.ind_modprest_any := 2;
                  ELSE
                     prest.ind_modprest_any := 1;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     prest.ind_modprest_any := 1;
               END;

               -----DE MOMENT HA COBRAT EN CAPITAL SEMPRE
               prest.ind_bencobrat_encap := 1;
               ---- CALDRIA CALCULAR-LA
               ----prest.any_pag_mesantic := to_char(......,'yyyy');
               prest.any_pag_mesantic := '';
               */
               i := 0;
               /*****************
               FOR reg IN (
                  -----OBERTES
                  SELECT ******
                  FROM sin_siniestro ss, sin_movsiniestro sm
                  WHERE ss.sseguro = r_generar.sseguro
                  AND ss.ccausin in (12, 13)
                  AND ss.nsnies = sm.nsnies
                  AND TO_CHAR(sm.FESTSIN, 'YYYY') = TRUNC(f_sysdate, 'YYYY');
               ) LOOP
                  i := i + 1;
                  prestau(i).nforma_cobr := i;
                  prestau(i).ind_forma_cobr := 1;
                  prestau(i).ind_tip_cobr := 1;
                  prestau(i).import_cap := reg.importe;
                  prestau(i).import_ren := 0;
                  prestau(i).tipus_reval := 0;
                  prestau(i).data_abon_cap := TO_CHAR(reg.finicio,'ddmmyy');
                  prestau(i).data_propera_renda := '000000';
                  prestau(i).data_ultima_renda := '000000';
                  prestau(i).periode_renda := 0;
                  prestau(i).tipus_reval := 0;
                  prestau(i).reval := 0;
                  prestau(i).mes_reval := '00';
               END LOOP;
               prest.num_forma_cobr := i;
               */
               prest.num_forma_cobr := 0;

               IF prest.num_forma_cobr = 0 THEN
                  baiprest := FALSE;
               ELSE
                  baiprest := TRUE;
               END IF;


                         DBMS_OUTPUT.PUT_LINE ( 'pase8:');
               -- ALBERTO - LLENAMOS TRABLA TRASPLAAPORTACIONES y platransf

               i := 0;
               FOR reg IN (SELECT *
                                FROM TRASPLAAPORTACIONES T
                               WHERE T.STRAS = r_generar.stras
                               ORDER BY faporta
                     ) LOOP
                     i := i +1;
                     ttrasplaaportaciones(i).stras := reg.stras;
                     ttrasplaaportaciones(i).naporta := reg.naporta;
                     ttrasplaaportaciones(i).faporta := reg.faporta;
                     ttrasplaaportaciones(i).cprocedencia := reg.cprocedencia;
                     ttrasplaaportaciones(i).ctipoderecho := reg.ctipoderecho;
                     ttrasplaaportaciones(i).importe_ant := reg.importe_ant;
                     ttrasplaaportaciones(i).importe_post := reg.importe_post;

               END LOOP;
                        DBMS_OUTPUT.PUT_LINE ( 'pase9:');
            ----INFORMACIONS PRESTACIONS----------
            END IF;

            ----ALTRES DADES DEL PLA TRASPASSAT---
            ----Si tot ha anat bé una operació més
            noperacions := noperacions + 1;
            ncerror := 1;

            -----
            UPDATE trasplainout
               SET srefc234 = xrefc234
             WHERE stras = r_generar.stras;
         --         END IF;
         EXCEPTION
            WHEN rechazo_solicitud THEN
               NULL;
            WHEN noespotenviar THEN
               nnumlin := NULL;
               ttexto := f_axis_literales(9901080, f_idiomauser);
               nerror := f_proceslin(vsproces, xnompla || ': ' || ' ' || ttexto,
                                     r_generar.sseguro, nnumlin);
               ncerror := -1;
            WHEN nosenvia THEN
               nnumlin := NULL;
               ttexto := f_axis_literales(9901081, f_idiomauser);
               nerror := f_proceslin(vsproces, xnompla || ': ' || ' ' || ttexto,
                                     r_generar.sseguro, nnumlin);
               ncerror := -1;
            WHEN errorcontrolat THEN
               xtext := literal(vnerror);
               nnumlin := NULL;
               ttexto := f_axis_literales(9901082, f_idiomauser);
               nerror := f_proceslin(vsproces,
                                     xnompla || ': ' || ' ' || ttexto || ' ' || xtext,
                                     r_generar.sseguro, nnumlin);
               ncerror := 1;
            WHEN anulado THEN
               xtext := literal(vnerror);
               nnumlin := NULL;
               ttexto := f_axis_literales(9901083, f_idiomauser);
               nerror := f_proceslin(vsproces,
                                     xnompla || ': ' || ' ' || ttexto || ' ' || xtext,
                                     r_generar.sseguro, nnumlin);
               ncerror := -1;
            WHEN OTHERS THEN
               vnerror := 140999;
               xtext := literal(vnerror);
               nnumlin := NULL;
               nerror := f_proceslin(vsproces,
                                     SUBSTR(xnompla || ':' || xtext || '-' || SQLERRM, 1, 120),
                                     NVL(r_generar.sseguro, 0), nnumlin);
               ncerror := 140999;
         END;
      ELSE
         sortir := TRUE;
      END IF;
   END llegir;

   ---
   PROCEDURE inicialitzar IS
   BEGIN
      vnerror := 0;
      transfer.clau_inici := 0;
      transfer.data_emi_dev := '000000';
      transfer.motiu_devo := 0;
      transfer.entitat_ord := 0;
      transfer.ofic_ord := 0;
      transfer.dctrl_ord := NULL;
      transfer.compte_ord := NULL;
      transfer.import := 0;
      transfer.importeco := 0;
      transfer.ent_benef := NULL;
      transfer.ofic_benef := NULL;
      traspas.clau_oper := 0;
      traspas.motiu_refusa := 0;
      traspas.sentit := 0;
      traspas.tipus := 0;
      traspas.tipus_imp := 0;
      traspas.import := 0;
      traspas.PERCENT := 0;
      traspas.partic := 0;
      -- BUG 17245 - 12/01/2011 - JMP
      traspas.numidsol := NULL;
      traspas.tnomsol := NULL;
      traspas.nifgori := NULL;
      traspas.cdgsgori := NULL;
      traspas.cdgsppori := NULL;
      traspas.niffpori := NULL;
      traspas.cdgsfpori := NULL;
      traspas.nrbe := NULL;
      -- FIN BUG 17245 - 12/01/2011 - JMP
      origen.gestora.sperson := NULL;
      origen.gestora.nif := NULL;
      origen.gestora.dgsfp := NULL;
      origen.fons.sperson := NULL;
      origen.fons.nif := NULL;
      origen.fons.dgsfp := NULL;
      origen.fons.ccc := NULL;
      origen.pla.dgsfp := NULL;
      origen.pla.indprecap := 1;
      origen.pla.indpreren := 1;
      origen.pla.indpremix := 1;
      origen.pla.polppa := NULL;
      desti.gestora.sperson := NULL;
      desti.gestora.nif := NULL;
      desti.gestora.dgsfp := NULL;
      desti.fons.sperson := NULL;
      desti.fons.nif := NULL;
      desti.fons.dgsfp := NULL;
      desti.fons.ccc := NULL;
      desti.pla.dgsfp := NULL;
      desti.pla.indprecap := 1;
      desti.pla.indpreren := 1;
      desti.pla.indpremix := 1;
      desti.pla.polppa := NULL;
      partoben.tipusdret := 0;
      partoben.assnif := NULL;
      partoben.assnoms := NULL;
      partoben.formacobr := 0;
      eembarg.autoritat := NULL;
      eembarg.data_com := NULL;
      eembarg.id_demanda := NULL;
      platransf.ind_embarg := 0;
      platransf.n_aport_minus := 0;
      platransf.data_pr_aport := NULL;
      platransf.ind_minus := 1;
      platransf.ind_dc_ac := 2;
      platransf.ind_part_scobr := 1;
      platransf.ind_apor_am := 0;
      platransf.dc_apor_am := 0;
      platransf.ind_aport_any := 2;
      platransf.ind_contr_pr_any := 2;
      platransf.ind_compl_tras := 1;
      platransf.aport_any := 0;
      platransf.contr_pr_any := 0;
      platransf.dc_altres_con := 0;
      platransf.dr_econ_traspassat := 0;
      platransf.ncontin_prod := 0;
      -- ALBERTO actualizamos nuevo campo
      platransf.numaport := NULL;
      platransf.ccobroreduc  := NULL;
      platransf.anyoreduc    := NULL;
      platransf.ccobroactual := NULL;
      platransf.anyoactual   := NULL;
      platransf.importeacumact := NULL;
      platransf.anyoaport := NULL;
      --ALBERTO inicializamos nueva tabla
      ttrasplaaportaciones.DELETE;


      aporamnv.DELETE;
      eaporamnv.num_aportant := 0;
      eaporamnv.nif_aportant := NULL;
      eaporamnv.dc_aporta_totals := 0;
      eaporamnv.ind_aporta_any := 0;
      eaporamnv.aporta_any := 0;
      eaporamnv.nomtot_aportant := NULL;
      prest.num_forma_cobr := 0;
      prest.ind_modprest_any := 0;
      prest.ind_bencobrat_encap := 0;
      prest.any_pag_mesantic := NULL;
      prest.ind_conting := 0;
      prest.data_conting := NULL;
      prestau.DELETE;
      eprestau.nforma_cobr := 0;
      eprestau.ind_forma_cobr := 0;
      eprestau.ind_tip_cobr := 0;
      eprestau.import_cap := 0;
      eprestau.import_ren := 0;
      eprestau.imp_cons_rfm := 0;
      eprestau.ind_benef_te_benef_esp := 0;
      eprestau.data_abon_cap := '000000';
      eprestau.data_propera_renda := '000000';
      eprestau.data_ultima_renda := '000000';
      eprestau.periode_renda := 0;
      eprestau.tipus_reval := 0;
      eprestau.reval := 0;
      eprestau.mes_reval := '00';
   END inicialitzar;

   ---
   PROCEDURE escr_apmin(nindex IN NUMBER) IS
   BEGIN
      eaporamnv := aporamnv(nindex);
   END escr_apmin;

   ---
   PROCEDURE escr_prest(nindex IN NUMBER) IS
   BEGIN
      eprestau := prestau(nindex);
   END escr_prest;

   ---
   FUNCTION insertar_registro(pregistro IN registro)
      RETURN NUMBER IS
      vnerror        NUMBER(10);
      vnnumlin       NUMBER;
      ttexto         VARCHAR2(200);
   BEGIN

      INSERT INTO tdc234_out_det
                  (sproces, stras, codreg, cndato,
                   nlinea, campo_a, campo_b, campo_c,
                   campo_c1, campo_c2, campo_d,
                   campo_d1, campo_d2, campo_e,
                   campo_f1, campo_f2, campo_f3,
                   campo_f4, campo_f5, campo_f6,
                   campo_f7, campo_f8, campo_f9,
                   campo_f10, campo_f11, campo_f12,
                   campo_f13, campo_g, campo_g1,
                   campo_g2)
           VALUES (pregistro.sproces, pregistro.stras, pregistro.codreg, pregistro.cndato,
                   pregistro.nlinea, pregistro.campo_a, pregistro.campo_b, pregistro.campo_c,
                   pregistro.campo_c1, pregistro.campo_c2, pregistro.campo_d,
                   pregistro.campo_d1, pregistro.campo_d2, pregistro.campo_e,
                   pregistro.campo_f1, pregistro.campo_f2, pregistro.campo_f3,
                   pregistro.campo_f4, pregistro.campo_f5, pregistro.campo_f6,
                   pregistro.campo_f7, pregistro.campo_f8, pregistro.campo_f9,
                   pregistro.campo_f10, pregistro.campo_f11, pregistro.campo_f12,
                   pregistro.campo_f13, pregistro.campo_g, pregistro.campo_g1,
                   pregistro.campo_g2);

      RETURN 0;
   -- exception when others then .--falta control de errores
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE ( SQLERRM || SQLCODE );
         ttexto := f_axis_literales(9901084, f_idiomauser);
         vnerror := f_proceslin(vsproces, ttexto || SQLCODE, 1, vnnumlin, 1);
         RETURN -1;
   END insertar_registro;

   ---
   FUNCTION generar_n234(psproces OUT NUMBER, pcinout IN NUMBER, pfhasta IN DATE)
      RETURN NUMBER IS
      v_registro     registro;
      nerror         NUMBER(5);
      v_dato         NUMBER(12);
      vnerror        NUMBER(10);
      vnnumlin       NUMBER;
      error          EXCEPTION;
      ABORT          EXCEPTION;
      nnumlin        NUMBER;
      ttexto         VARCHAR2(200);
      v_sproduc      NUMBER;
   BEGIN
      DBMS_OUTPUT.PUT_LINE ( 'inicio: ' || NcERROR);
      obrir(pcinout, pfhasta);
      DBMS_OUTPUT.PUT_LINE ( '1inicio: ' || NcERROR);
      llegir(vsproces);
      DBMS_OUTPUT.PUT_LINE ( '2inicio: ' || NcERROR);
      psproces := vsproces;   -- valor de vuelta
      --cabecera
      v_registro := NULL;
      v_registro.sproces := vsproces;
      v_registro.stras := 0;
      v_registro.codreg := '21';
      v_registro.cndato := '000';
      v_registro.nlinea := 1;
      v_registro.campo_a := '21';
      v_registro.campo_b := '56';
      v_registro.campo_e := '000';
      v_registro.campo_f1 := 1;   -- FIchero generado por la entidad gestora NOTA

      --Bug 25376-XVM-29/07/13
      SELECT sproduc
        INTO v_sproduc
        FROM parproductos
       WHERE cparpro = 'TDC234_IN'
         AND ROWNUM = 1;

      SELECT pp.nnumide, LPAD(a.ccodban, 4, '0')
        INTO nif_entitat_gestora, entitat_dipositaria
        FROM proplapen p, aseguradoras a, per_personas pp
       WHERE sproduc = v_sproduc
         AND p.ccodpla = a.ccodaseg
         AND a.sperson = pp.sperson;

      v_registro.campo_f2 := nif_entitat_gestora;   --origen.gestora.nif;   NOTA
      v_registro.campo_f3 := entitat_dipositaria;   --origen.gestora.dgsfp; NOTA
      v_registro.campo_f4 := TO_CHAR(f_sysdate, 'DDMMYY');
      v_registro.campo_f5 := ordre_fitxer;


      DBMS_OUTPUT.PUT_LINE ( 'antes insertar: ' || NcERROR);
      nerror := insertar_registro(v_registro);

      DBMS_OUTPUT.PUT_LINE ( 'NERROR ' || NERROR);
      IF nerror <> 0 THEN
         RAISE ABORT;
      END IF;

      --
      WHILE(c_generar%FOUND) LOOP   -- si ha habido un resgistro
         DBMS_OUTPUT.PUT_LINE ( 'entramos al bucle: ' || NcERROR);
         IF ncerror = 1 THEN
            BEGIN
               -- registro 23
               --  201
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';   -- mismo que A
               v_registro.cndato := '201';   -- mismo que E
               v_registro.nlinea := 1;   -- linea
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '201';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;
               -- informacion particular 201
               v_registro.campo_f1 := traspas.clau_oper;

               IF v_registro.campo_f1 = 2 THEN
                  v_registro.campo_f2 := r_generar.cmotrod;
               ELSE
                  v_registro.campo_f2 := '00';
               END IF;

               IF v_registro.campo_f1 = 3 THEN
                  v_registro.campo_f3 := '1';
               ELSE
                  v_registro.campo_f3 := '0';
               END IF;

               IF v_registro.campo_f1 = 4 THEN
                  v_registro.campo_f4 := '??????';
                  v_registro.campo_f5 := r_generar.cmotrod;
               ELSE
                  v_registro.campo_f4 := '000000';
                  v_registro.campo_f5 := '00';
               END IF;

               IF v_registro.campo_f3 <> 2 THEN
                  v_registro.campo_f6 := traspas.referoper;   --lpad(r_GENERAR.stras,13,'0');
               END IF;

               --
               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- registro 23
               --  202
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';
               v_registro.cndato := '202';
               v_registro.nlinea := 1;
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '202';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;
               v_registro.campo_f1 := r_generar.ctiptras;

               IF v_registro.campo_f1 = 2 THEN
                  v_registro.campo_f2 := r_generar.ctiptrassol;
               ELSE
                  v_registro.campo_f2 := '0';
               END IF;

               IF v_registro.campo_f2 = 1 THEN
                  v_registro.campo_f3 := LPAD(NVL(r_generar.iimptemp, 0) * 100, 12, '0');
               ELSE
                  v_registro.campo_f3 := '000000000000';
               END IF;

               IF v_registro.campo_f2 = 2 THEN
                  v_registro.campo_f4 := LPAD(NVL(r_generar.nporcen, 0) * 1000, 5, '0');
               ELSE
                  v_registro.campo_f4 := '00000';
               END IF;

               IF v_registro.campo_f2 = 3 THEN
                  v_registro.campo_f5 := LPAD(NVL(r_generar.nparpla, 0) * 100000000, 14, '0');
               ELSE
                  v_registro.campo_f5 := '00000000000000';
               END IF;

               --Bug 25376-XVM-09/05/2013.Inicio
               --AGG (Nota: 0153113) Incidencia 0025376
               --Se eliminan los campos f6, f7 y f8
               /*IF pcinout = 1 THEN
                  v_registro.campo_f6 := '1';   -- Capital
                  v_registro.campo_f7 := '2';   -- Renta Financiera
                  v_registro.campo_f8 := '2';   -- Renta Financiera + Capital
               ELSIF pcinout = 2 THEN
                  v_registro.campo_f6 := r_generar.admitcap;   -- Capital
                  v_registro.campo_f7 := r_generar.admitren;   -- Renta Financiera
                  v_registro.campo_f8 := r_generar.admitrencap;   -- Renta Financiera + Capital
               END IF;*/
               v_registro.campo_f6 := ' ';   -- Capital
               v_registro.campo_f7 := ' ';   -- Renta Financiera
               v_registro.campo_f8 := ' ';   -- Renta Financiera + Capital
               --Bug 25376-XVM-09/05/2013.Fin
               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- registro 23
               --  203
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';
               v_registro.cndato := '203';
               v_registro.nlinea := 1;
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '203';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;
               v_registro.campo_f1 := desti.fons.ccc;
               v_registro.campo_f2 := origen.fons.nrbe;
               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- registro 23
               --  204
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';
               v_registro.cndato := '204';
               v_registro.nlinea := 1;
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '204';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;
               v_registro.campo_f1 := origen.gestora.nif;
               v_registro.campo_f2 := origen.gestora.dgsfp;
               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- registro 23
               -- 205
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';
               v_registro.cndato := '205';
               v_registro.nlinea := 1;
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '205';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;

               --AGG Incidenia 0023576/0154797  10/10/2013
               --En el caso de que el ORIGEN sea un Plan de Previsión Asegurado, contendrá siempre el literal NPPA.
               IF (v_nppa1 = 1) THEN
                  v_registro.campo_f1 := 'NPPA';
               ELSE
                  v_registro.campo_f1 := origen.pla.dgsfp;
               END IF;

               v_registro.campo_f2 := '';

               --IF v_registro.campo_f1 = 'NPPA' THEN
               IF v_nppa1 = 1 THEN
                  --BUG 0025376/0156167 16/10/2013 - AGG
                  IF r_generar.sseguro IS NOT NULL THEN   -- BUG 17245 - 12/01/2011 - JMP
                     SELECT npoliza
                       INTO v_registro.campo_f2
                       FROM seguros
                      WHERE sseguro = r_generar.sseguro;
                  END IF;
               ELSE
                  IF r_generar.tpolext IS NOT NULL THEN
                     v_registro.campo_f2 := r_generar.tpolext;
                  END IF;
               END IF;

               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- registro 23
               -- 206
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';
               v_registro.cndato := '206';
               v_registro.nlinea := 1;
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '206';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;
               v_registro.campo_f1 := origen.fons.nif;
               v_registro.campo_f2 := origen.fons.dgsfp;
               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- registro 23
               -- 207
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';
               v_registro.cndato := '207';
               v_registro.nlinea := 1;
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '207';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;
               v_registro.campo_f1 := desti.gestora.nif;
               v_registro.campo_f2 := desti.gestora.dgsfp;
               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- registro 23
               -- 208
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';
               v_registro.cndato := '208';
               v_registro.nlinea := 1;
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '208';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;
               v_registro.campo_f1 := desti.pla.dgsfp;

               --AGG Incidenia 0023576/0154797  10/10/2013
               --En el caso de que el DESTINO sea un Plan de Previsión Asegurado, contendrá siempre el literal NPPA.
               --Lo que había antes del cambio es solo la parte del else
               IF (v_nppa2 = 1) THEN
                  v_registro.campo_f1 := 'NPPA';
               ELSE
                  v_registro.campo_f1 := desti.pla.dgsfp;
               END IF;

               v_registro.campo_f2 := '';

               --IF v_registro.campo_f1 = 'NPPA' THEN
               IF v_nppa2 = 1 THEN
                  IF r_generar.sseguro IS NOT NULL THEN   -- BUG 17245 - 12/01/2011 - JMP
                     SELECT npoliza   /*JGM: Quitamos el certificado || '-' || ncertif */
                       INTO v_registro.campo_f2
                       FROM seguros
                      WHERE sseguro = r_generar.sseguro;
                  END IF;
               ELSE
                  IF r_generar.tpolext IS NOT NULL THEN
                     v_registro.campo_f2 := r_generar.tpolext;
                  END IF;
               END IF;

               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- registro 23
               -- 209
               v_registro := NULL;
               v_registro.sproces := vsproces;
               v_registro.stras := r_generar.stras;
               v_registro.codreg := '23';
               v_registro.cndato := '209';
               v_registro.nlinea := 1;
               v_registro.campo_a := '23';
               v_registro.campo_b := '56';
               v_registro.campo_c1 := origen.gestora.nif;
               v_registro.campo_d1 := desti.gestora.nif;
               v_registro.campo_e := '209';
               --AGG (Nota: 0153113) Incidencia 0025376
               --v_registro.campo_g2 := entitat_dipositaria;
               v_registro.campo_g2 := origen.fons.nrbe;
               v_registro.campo_f1 := desti.fons.nif;
               v_registro.campo_f2 := desti.fons.dgsfp;
               nerror := insertar_registro(v_registro);

               IF nerror <> 0 THEN
                  RAISE error;
               END IF;

               -- Datos del titular registro 24
               --IF traspas.clau_oper IN(1, 2, 3) THEN   -- BUG 17245 - 12/01/2011 - JMP - Generamos también estos registros para la clave 2
               --Bug 25376-XVM-09/05/2013
               IF traspas.clau_oper IN(1, 3)
                                            -- OR (pcinout = 2 AND traspas.clau_oper IN (2))
               THEN   -- BUG 17245 - 12/01/2011 - JMP - Generamos también estos registros para la clave 2
                  --
                  -- registro 24
                  -- 210
                  v_registro := NULL;
                  v_registro.sproces := vsproces;
                  v_registro.stras := r_generar.stras;
                  v_registro.codreg := '24';
                  v_registro.cndato := '210';
                  v_registro.nlinea := 1;
                  v_registro.campo_a := '24';
                  v_registro.campo_b := '56';
                  v_registro.campo_c1 := origen.gestora.nif;
                  v_registro.campo_d1 := desti.gestora.nif;
                  v_registro.campo_e := '210';
                  --AGG (Nota: 0153113) Incidencia 0025376
                  --v_registro.campo_g2 := entitat_dipositaria;
                  v_registro.campo_g2 := origen.fons.nrbe;

                  IF traspas.clau_oper = 1 THEN
                     v_registro.campo_f1 := r_generar.ctipder;
                  ELSE
                     v_registro.campo_f1 := 1;
                  END IF;

                  -- alberto - informamos nuevo campo f2
                  IF traspas.clau_oper in ( 2,3 ) AND prest.ind_conting NOT IN ( 5,7 ) THEN
                    v_registro.campo_f2 := platransf.numaport; -- ENVIAR APORTACIONES
                  END IF;


                  v_registro.campo_f3 := partoben.assnif;

                  --
                  IF v_registro.campo_f1 IN(2, 3) THEN
                     v_registro.campo_f4 := '01';
                  ELSE
                     v_registro.campo_f4 := '00';
                  END IF;

                  --
                  IF traspas.clau_oper = 3 THEN
                     IF NVL(r_generar.porcpos2006, 0) > 0 THEN
                        v_registro.campo_f5 := 'S';
                     ELSE
                        v_registro.campo_f5 := 'N';
                     END IF;
                  ELSE
                     -- Bug 0016323 - SRA - 14/10/2010: en caso de que el porcentaje de aportaciones posteriores al 2006
                     -- sea igual a NULL o 0, se debe marcar el campo F4 del registro 210 con un 'N' (hasta ahora se hacía con un blanco).
                     v_registro.campo_f5 := ' ';
                  END IF;

                  IF v_registro.campo_f1 IN(1, 3)
                     AND traspas.clau_oper = 3
                     AND v_registro.campo_f5 = 'S' THEN
                     v_registro.campo_f6 := LPAD(NVL(r_generar.porcpos2006, 0) * 100, 5, '0');
                  ELSE
                     v_registro.campo_f6 := '00000';
                  END IF;

                  -- if v_registro.campo_f1 in (2,3) and traspas.clau_oper = 3 and v_registro.campo_F4 = 'S' then
                  --v_registro.campo_f6 := '';
                  --else
                  -- Bug 0016323 - SRA - 14/10/2010: si campo_f1 in (2, 3) aplicamos a campo_f6 el mismo cálculo que a campo_f5
                  IF v_registro.campo_f1 IN(2, 3)
                     AND traspas.clau_oper = 3
                     AND v_registro.campo_f5 = 'S' THEN
                     v_registro.campo_f7 := LPAD(NVL(r_generar.porcpos2006, 0) * 100, 5, '0');
                  ELSE
                     v_registro.campo_f7 := '00000';   -- de momento no tenemos derechos económicos
                  END IF;

                  v_registro.campo_f8 := '3';
                  --end if;
                  nerror := insertar_registro(v_registro);

                  IF nerror <> 0 THEN
                     RAISE error;
                  END IF;

                  -- registro 24
                  -- 211
                  v_registro := NULL;
                  v_registro.sproces := vsproces;
                  v_registro.stras := r_generar.stras;
                  v_registro.codreg := '24';
                  v_registro.cndato := '211';
                  v_registro.nlinea := 1;
                  v_registro.campo_a := '24';
                  v_registro.campo_b := '56';
                  v_registro.campo_c1 := origen.gestora.nif;
                  v_registro.campo_d1 := desti.gestora.nif;
                  v_registro.campo_e := '211';
                  --AGG (Nota: 0153113) Incidencia 0025376
                  --v_registro.campo_g2 := entitat_dipositaria;
                  v_registro.campo_g2 := origen.fons.nrbe;
                  v_registro.campo_f1 := partoben.assnoms;
                  nerror := insertar_registro(v_registro);

                  IF nerror <> 0 THEN
                     RAISE error;
                  END IF;
               --
               END IF;

               -- Datos de transferencia   26
               IF traspas.clau_oper IN(3, 4) THEN
                  -- registro 26
                  -- 215
                  v_registro := NULL;
                  v_registro.sproces := vsproces;
                  v_registro.stras := r_generar.stras;
                  v_registro.codreg := '26';
                  v_registro.cndato := '215';
                  v_registro.nlinea := 1;
                  v_registro.campo_a := '26';
                  v_registro.campo_b := '56';
                  v_registro.campo_c1 := origen.gestora.nif;
                  v_registro.campo_d1 := desti.gestora.nif;
                  v_registro.campo_e := '215';
                  --AGG (Nota: 0153113) Incidencia 0025376
                  --v_registro.campo_g2 := entitat_dipositaria;
                  v_registro.campo_g2 := origen.fons.nrbe;
                  v_registro.campo_f1 := transfer.data_emi;
                  v_registro.campo_f2 := NVL(transfer.entitat_ord, '0000');
                  v_registro.campo_f3 := NVL(transfer.ofic_ord, '    ');

                  IF traspas.clau_oper = 3 THEN   --
                     --v_registro21/000/F1=1 -- siempre es 1,

                     -- Bug 15627 - RSC - 03/08/2010 - Q234  TRANSFERENCIA SALIDA DE PPA A PPI
                     --v_registro.campo_f4 := r_generar.cbancar;
                     SELECT c.ncuenta
                       INTO v_registro.campo_f4
                       FROM seguros s, cobbancario c
                      WHERE s.sseguro = r_generar.sseguro
                        AND s.ccobban = c.ccobban;
                  -- Fin Bug 15627
                  END IF;

                  nerror := insertar_registro(v_registro);

                  IF nerror <> 0 THEN
                     RAISE error;
                  END IF;

                  --
                  --
                  -- registro 26
                  -- 216
                  v_registro := NULL;
                  v_registro.sproces := vsproces;
                  v_registro.stras := r_generar.stras;
                  v_registro.codreg := '26';
                  v_registro.cndato := '216';
                  v_registro.nlinea := 1;
                  v_registro.campo_a := '26';
                  v_registro.campo_b := '56';
                  v_registro.campo_c1 := origen.gestora.nif;
                  v_registro.campo_d1 := desti.gestora.nif;
                  v_registro.campo_e := '216';
                  --AGG (Nota: 0153113) Incidencia 0025376
                  --v_registro.campo_g2 := entitat_dipositaria;
                  v_registro.campo_g2 := origen.fons.nrbe;
                  v_registro.campo_f1 := TO_CHAR(transfer.import * 100, 'fm099999999999');
                  v_registro.campo_f2 := transfer.ent_benef;
                  v_registro.campo_f3 := transfer.ofic_benef;
                  nerror := insertar_registro(v_registro);

                  IF nerror <> 0 THEN
                     RAISE error;
                  END IF;
               END IF;

               -- Registro 27
               IF traspas.clau_oper = 3 THEN
                  -- Informacion del plan de pensiones o del plan de previsión asegurado.
                  -- registro 27
                  -- 225
                  v_registro := NULL;
                  v_registro.sproces := vsproces;
                  v_registro.stras := r_generar.stras;
                  v_registro.codreg := '27';
                  v_registro.cndato := '225';
                  v_registro.nlinea := 1;
                  v_registro.campo_a := '27';
                  v_registro.campo_b := '56';
                  v_registro.campo_c1 := origen.gestora.nif;
                  v_registro.campo_d1 := desti.gestora.nif;
                  v_registro.campo_e := '225';
                  --AGG (Nota: 0153113) Incidencia 0025376
                  --v_registro.campo_g2 := entitat_dipositaria;
                  v_registro.campo_g2 := origen.fons.nrbe;
                  v_registro.campo_f1 := platransf.ind_embarg;   --0
                  v_registro.campo_f2 := platransf.n_aport_minus;
                  v_registro.campo_f3 := platransf.data_pr_aport;
                  v_registro.campo_f4 := platransf.ind_minus;

                  IF v_registro.campo_f4 = 2 THEN
                     v_registro.campo_f5 := TO_CHAR(platransf.data_minus, 'DDMMYY');
                  ELSE
                     v_registro.campo_f5 := '000000';
                  END IF;

                  v_registro.campo_f6 := platransf.ind_dc_ac;   ---Altres contingències = participacions retingudes;

                  IF v_registro.campo_f6 = 1 THEN
                     v_registro.campo_f7 := platransf.dc_altres_con;
                  ELSE
                     v_registro.campo_f7 := '0';
                  END IF;

                  v_registro.campo_f8 := platransf.ind_part_scobr;

                  --
                  IF v_registro.campo_f4 = 2 THEN
                     v_registro.campo_f9 := platransf.ind_apor_am;
                  ELSE
                     v_registro.campo_f9 := '0';
                  END IF;

                  --
                  IF v_registro.campo_f7 = 2 THEN
                     v_registro.campo_f10 := platransf.dc_apor_am;
                  ELSE
                     v_registro.campo_f10 := '0';
                  END IF;

                  v_registro.campo_f11 := platransf.ind_aport_any;
                  v_registro.campo_f12 := platransf.ind_contr_pr_any;
                  v_registro.campo_f13 := platransf.ind_compl_tras;
                  nerror := insertar_registro(v_registro);

                  IF nerror <> 0 THEN
                     RAISE error;
                  END IF;

                  --
                  -- registro 27
                  -- 226
                  v_registro := NULL;
                  v_registro.sproces := vsproces;
                  v_registro.stras := r_generar.stras;
                  v_registro.codreg := '27';
                  v_registro.cndato := '226';
                  v_registro.nlinea := 1;
                  v_registro.campo_a := '27';
                  v_registro.campo_b := '56';
                  v_registro.campo_c1 := origen.gestora.nif;
                  v_registro.campo_d1 := desti.gestora.nif;
                  v_registro.campo_e := '226';
                  --AGG (Nota: 0153113) Incidencia 0025376
                  --v_registro.campo_g2 := entitat_dipositaria;
                  v_registro.campo_g2 := origen.fons.nrbe;

                  IF platransf.ind_aport_any = 1 THEN
                     -- Bug 16747 - RSC - 18/11/2010 GENERACIÓN 234 SALIDAS NO LO HACE BIEN
                     v_registro.campo_f1 := LPAD(NVL(platransf.aport_any, 0) * 100, 7, '0');
                  -- Fin Bug 16747
                  ELSE
                     v_registro.campo_f1 := '0';
                  END IF;

                  --
                  IF platransf.ind_contr_pr_any = 1 THEN
                     v_registro.campo_f2 := platransf.contr_pr_any;
                  ELSE
                     v_registro.campo_f2 := '0';
                  END IF;

                  --
                  IF platransf.ind_dc_ac = 1 THEN
                     v_registro.campo_f3 := platransf.dc_altres_con;
                  ELSE
                     v_registro.campo_f3 := '0';
                  END IF;

                  IF r_generar.ctipder IN(2, 3) THEN
                     v_registro.campo_f4 := platransf.dr_econ_traspassat;
                  ELSE
                     v_registro.campo_f4 := '0';
                  END IF;

                  -- albert - nuevo campo F5 (
                  IF platransf.ind_aport_any = 1 OR platransf.ind_contr_pr_any = 1 THEN
                     v_registro.campo_f5 := platransf.anyoaport;
                  ELSE
                     v_registro.campo_f5 := '0';
                  END IF;


                  nerror := insertar_registro(v_registro);

                  IF nerror <> 0 THEN
                     RAISE error;
                  END IF;

                  -- alberto - informamos nuevo campo f2
                  -- Registro 227
                  IF traspas.clau_oper in ( 2,3 ) AND prest.ind_conting NOT IN ( 5,7 ) THEN
                     FOR i IN 1 .. platransf.numaport LOOP
                        -- 227
                        --
                        v_registro := NULL;
                        v_registro.sproces := vsproces;
                        v_registro.stras := r_generar.stras;
                        v_registro.codreg := '27';
                        v_registro.cndato := '227';
                        v_registro.nlinea := i;
                        v_registro.campo_a := '27';
                        v_registro.campo_b := '56';
                        v_registro.campo_c1 := origen.gestora.nif;
                        v_registro.campo_d1 := desti.gestora.nif;
                        v_registro.campo_e := '227';
                        v_registro.campo_f1 := i;
                        v_registro.campo_f2 := TO_CHAR(pk_tr234_out.ttrasplaaportaciones(i).faporta,'DDMMYYYY');
                        v_registro.campo_f3 := pk_tr234_out.ttrasplaaportaciones(i).cprocedencia;
                        v_registro.campo_f4 := pk_tr234_out.ttrasplaaportaciones(i).ctipoderecho;
                        v_registro.campo_f5 := TO_CHAR(pk_tr234_out.ttrasplaaportaciones(i).importe_post * 100, 'fm0999999999');
                        v_registro.campo_f6 := TO_CHAR(pk_tr234_out.ttrasplaaportaciones(i).importe_ant * 100, 'fm0999999999');
                        v_registro.campo_g2 := origen.fons.nrbe;
                        nerror := insertar_registro(v_registro);

                        IF nerror <> 0 THEN
                           RAISE error;
                        END IF;
                     END LOOP;
                  END IF;

                  -- Alberto
                  -- Registro 228
                  -- Detalle
                  -- Informacion del plan de pensiones o del plan de previsión asegurado.
                  IF traspas.clau_oper in ( 2,3 ) AND prest.ind_conting NOT IN ( 5,7 ) THEN
                     -- Registro 27
                     -- 228
                     --
                     v_registro := NULL;
                     v_registro.sproces := vsproces;
                     v_registro.stras := r_generar.stras;
                     v_registro.codreg := '27';
                     v_registro.cndato := '228';
                     v_registro.nlinea := 1;
                     v_registro.campo_a := '27';
                     v_registro.campo_b := '56';
                     v_registro.campo_c1 := origen.gestora.nif;
                     v_registro.campo_d1 := desti.gestora.nif;
                     v_registro.campo_e := '228';
                     v_registro.campo_f1 := platransf.ccobroreduc;
                     v_registro.campo_f2 := platransf.anyoreduc;
                     v_registro.campo_f3 := platransf.ccobroactual;
                     v_registro.campo_f4 := platransf.anyoactual;
                     v_registro.campo_f5 := TO_CHAR(platransf.importeacumact * 100, 'fm0999999999');
                     v_registro.campo_g2 := origen.fons.nrbe;
                     nerror := insertar_registro(v_registro);

                     IF nerror <> 0 THEN
                        RAISE error;
                     END IF;


                  --
                  END IF;

                  -- Registro 27
                  -- Detalle
                  -- Informacion del plan de pensiones o del plan de previsión asegurado.
                  IF platransf.n_aport_minus > 0 THEN
                     -- Registro 27
                     -- 230
                     --
                     v_registro := NULL;
                     v_registro.sproces := vsproces;
                     v_registro.stras := r_generar.stras;
                     v_registro.codreg := '27';
                     v_registro.cndato := '230';
                     v_registro.nlinea := 1;
                     v_registro.campo_a := '27';
                     v_registro.campo_b := '56';
                     v_registro.campo_c1 := origen.gestora.nif;
                     v_registro.campo_d1 := desti.gestora.nif;
                     v_registro.campo_e := '230';
                     --AGG (Nota: 0153113) Incidencia 0025376
                     --v_registro.campo_g2 := entitat_dipositaria;
                     v_registro.campo_g2 := origen.fons.nrbe;
                     nerror := insertar_registro(v_registro);

                     IF nerror <> 0 THEN
                        RAISE error;
                     END IF;

                     -- Registro 27
                     -- 231
                     v_registro := NULL;
                     v_registro.sproces := vsproces;
                     v_registro.stras := r_generar.stras;
                     v_registro.codreg := '27';
                     v_registro.cndato := '231';
                     v_registro.nlinea := 1;
                     v_registro.campo_a := '27';
                     v_registro.campo_b := '56';
                     v_registro.campo_c1 := origen.gestora.nif;
                     v_registro.campo_d1 := desti.gestora.nif;
                     v_registro.campo_e := '231';
                     --AGG (Nota: 0153113) Incidencia 0025376
                     --v_registro.campo_g2 := entitat_dipositaria;
                     v_registro.campo_g2 := origen.fons.nrbe;
                     nerror := insertar_registro(v_registro);

                     IF nerror <> 0 THEN
                        RAISE error;
                     END IF;
                  --
                  END IF;

                  -- Registro 27
                  -- 240
                  -- Información del plan con derechos economicos o con provision matemática por contingencia acaecida
                  ----prestacions desactivades
                  IF r_generar.ctipder = 99 THEN
                     ----IF r_generar.ctipder IN (2, 3) THEN
                     -- Registro 27
                     -- 240
                     v_registro := NULL;
                     v_registro.sproces := vsproces;
                     v_registro.stras := r_generar.stras;
                     v_registro.codreg := '27';
                     v_registro.cndato := '240';
                     v_registro.nlinea := 1;
                     v_registro.campo_a := '27';
                     v_registro.campo_b := '56';
                     v_registro.campo_c1 := origen.gestora.nif;
                     v_registro.campo_d1 := desti.gestora.nif;
                     v_registro.campo_e := '240';
                     --AGG (Nota: 0153113) Incidencia 0025376
                     --v_registro.campo_g2 := entitat_dipositaria;
                     v_registro.campo_g2 := origen.fons.nrbe;
                     v_registro.campo_f1 := NVL(prest.num_forma_cobr, '00');
                     v_registro.campo_f2 := '';
                     v_registro.campo_f3 := prest.ind_bencobrat_encap;
                     v_registro.campo_f4 := prest.any_pag_mesantic;
                     v_registro.campo_f5 := prest.ind_conting;
                     v_registro.campo_f6 := TO_CHAR(prest.data_conting, 'DDMMYYYY');
                     v_registro.campo_f7 := '?';

                     IF v_registro.campo_f7 = 1 THEN
                        v_registro.campo_f8 := '??????';
                     ELSE
                        v_registro.campo_f8 := '000000';
                     END IF;

                     nerror := insertar_registro(v_registro);

                     IF nerror <> 0 THEN
                        RAISE error;
                     END IF;
                  --
                  END IF;

                  -- Registro 27
                  -- 245 y 246
                  -- Información del Plan de Pensiones o Plan de Prevision Asegurado
                  IF platransf.ind_embarg > 0 THEN
                     -- Registro 27
                     FOR i IN 1 .. platransf.ind_embarg LOOP
                        -- 245
                        --
                        v_registro := NULL;
                        v_registro.sproces := vsproces;
                        v_registro.stras := r_generar.stras;
                        v_registro.codreg := '27';
                        v_registro.cndato := '245';
                        v_registro.nlinea := 1;
                        v_registro.campo_a := '27';
                        v_registro.campo_b := '56';
                        v_registro.campo_c1 := origen.gestora.nif;
                        v_registro.campo_d1 := desti.gestora.nif;
                        v_registro.campo_e := '245';
                        v_registro.campo_f1 := pk_tr234_out.embarg(i).nembarg;
                        v_registro.campo_f2 := pk_tr234_out.embarg(i).autoritat;
                        --AGG (Nota: 0153113) Incidencia 0025376
                        --v_registro.campo_g2 := entitat_dipositaria;
                        v_registro.campo_g2 := origen.fons.nrbe;
                        nerror := insertar_registro(v_registro);

                        IF nerror <> 0 THEN
                           RAISE error;
                        END IF;

                        -- Registro 27
                        -- 231
                        v_registro := NULL;
                        v_registro.sproces := vsproces;
                        v_registro.stras := r_generar.stras;
                        v_registro.codreg := '27';
                        v_registro.cndato := '246';
                        v_registro.nlinea := 1;
                        v_registro.campo_a := '27';
                        v_registro.campo_b := '56';
                        v_registro.campo_c1 := origen.gestora.nif;
                        v_registro.campo_d1 := desti.gestora.nif;
                        v_registro.campo_e := '246';
                        v_registro.campo_f1 := pk_tr234_out.embarg(i).nembarg;
                        v_registro.campo_f2 := TO_CHAR(pk_tr234_out.embarg(i).data_com,
                                                       'DDMMYYYY');
                        v_registro.campo_f3 := pk_tr234_out.embarg(i).id_demanda;
                        --AGG (Nota: 0153113) Incidencia 0025376
                        --v_registro.campo_g2 := entitat_dipositaria;
                        v_registro.campo_g2 := origen.fons.nrbe;
                        nerror := insertar_registro(v_registro);

                        IF nerror <> 0 THEN
                           RAISE error;
                        END IF;
                     END LOOP;
                  --
                  END IF;

                  -- Registro 28
                  -- 250 y 251
                  -- Información de las prestaciones del beneficiario
                  IF prest.num_forma_cobr <> 0
                     AND traspas.clau_oper = 3 THEN
                     -- Registro 28
                     -- 250
                     --
                     v_registro := NULL;
                     v_registro.sproces := vsproces;
                     v_registro.stras := r_generar.stras;
                     v_registro.codreg := '28';
                     v_registro.cndato := '250';
                     v_registro.nlinea := 1;
                     v_registro.campo_a := '28';
                     v_registro.campo_b := '56';
                     v_registro.campo_c1 := origen.gestora.nif;
                     v_registro.campo_d1 := desti.gestora.nif;
                     v_registro.campo_e := '250';
                     --AGG (Nota: 0153113) Incidencia 0025376
                     --v_registro.campo_g2 := entitat_dipositaria;
                     v_registro.campo_g2 := origen.fons.nrbe;
                     nerror := insertar_registro(v_registro);

                     IF nerror <> 0 THEN
                        RAISE error;
                     END IF;

                     -- Registro 28
                     -- 251
                     --
                     v_registro := NULL;
                     v_registro.sproces := vsproces;
                     v_registro.stras := r_generar.stras;
                     v_registro.codreg := '28';
                     v_registro.cndato := '251';
                     v_registro.nlinea := 1;
                     v_registro.campo_a := '28';
                     v_registro.campo_b := '56';
                     v_registro.campo_c1 := origen.gestora.nif;
                     v_registro.campo_d1 := desti.gestora.nif;
                     v_registro.campo_e := '251';
                     --AGG (Nota: 0153113) Incidencia 0025376
                     --v_registro.campo_g2 := entitat_dipositaria;
                     v_registro.campo_g2 := origen.fons.nrbe;
                     nerror := insertar_registro(v_registro);

                     IF nerror <> 0 THEN
                        RAISE error;
                     END IF;
                  END IF;
               -- Fin registros
               END IF;

               COMMIT;   --grabo la transación;
            --
            EXCEPTION
               WHEN error THEN
                  ttexto := f_axis_literales(9901085, f_idiomauser);
                  vnerror := f_proceslin(vsproces, ttexto, 1, vnnumlin, 1);
                  ROLLBACK;
               WHEN OTHERS THEN
                  ttexto := f_axis_literales(9000464, f_idiomauser);
                  vnerror := f_proceslin(vsproces, ttexto || ' ' || SQLERRM, 1, vnnumlin, 1);
                  ttexto := f_axis_literales(1000455, f_idiomauser);
                  vnerror := f_proceslin(vsproces, ttexto, 1, vnnumlin, 1);
                  ROLLBACK;
            END;
         ELSE
            ttexto := f_axis_literales(9901086, f_idiomauser);
            vnerror := f_proceslin(vsproces, ttexto || v_registro.stras, 1, vnnumlin, 1);
         END IF;   -- error ncerror;

         llegir(vsproces);
      END LOOP;

      --Pie
      v_registro := NULL;
      v_registro.sproces := vsproces;
      v_registro.stras := 0;
      v_registro.codreg := '29';
      v_registro.cndato := '999';
      v_registro.nlinea := 1;
      v_registro.campo_a := '29';
      v_registro.campo_b := '56';
      v_registro.campo_e := '999';

      --Bug 25376-XVM-29/07/13
      SELECT sproduc
        INTO v_sproduc
        FROM parproductos
       WHERE cparpro = 'TDC234_IN'
         AND ROWNUM = 1;

      SELECT pp.nnumide, LPAD(a.ccodban, 4, '0')
        INTO nif_entitat_gestora, entitat_dipositaria
        FROM proplapen p, aseguradoras a, per_personas pp
       WHERE sproduc = v_sproduc
         AND p.ccodpla = a.ccodaseg
         AND a.sperson = pp.sperson;

      v_registro.campo_f1 := nif_entitat_gestora;   --origen.gestora.nif;   NOTA
      v_registro.campo_f2 := entitat_dipositaria;   --origen.gestora.dgsfp; NOTA
      v_registro.campo_f3 := noperacions;

      SELECT NVL(COUNT('X'), 0) + 1
        INTO v_dato
        FROM tdc234_out_det
       WHERE sproces = vsproces;

      v_registro.campo_f4 := v_dato;

      SELECT SUM(NVL(campo_f1, 0))
        INTO v_dato
        FROM tdc234_out_det
       WHERE sproces = vsproces
         AND codreg = 26
         AND cndato = 216;

      v_registro.campo_f5 := v_dato;   -- select tabla para saber el numero de envio NOTA
      nerror := insertar_registro(v_registro);

      IF nerror <> 0 THEN
         RAISE ABORT;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ttexto := f_axis_literales(1000455, f_idiomauser);
         vnerror := f_proceslin(vsproces, ttexto || SQLCODE, 1, vnnumlin, 1);
         RETURN -1;
   END generar_n234;

   FUNCTION f_generar_fichero(
      pcinout IN NUMBER,
      pfhasta IN DATE,
      ptnomfich IN OUT VARCHAR2,
      pnfichero IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      xretval        VARCHAR2(30);
      nretval        NUMBER;
      xruta          parinstalacion.tvalpar%TYPE;
      pcmapead       VARCHAR2(200) := '281';
      pdebug         NUMBER := 99;
      nerror         NUMBER(8);
      nnumlin        NUMBER(8);
      maxfitxers     EXCEPTION;
      ttexto         VARCHAR2(200);
      pcconruta      NUMBER := pcinout;   --NMM.2013.01.16.Bug 25376
   --
   BEGIN
      data_fitxer := TRUNC(f_sysdate);
      vsproces := NULL;   --crear un nuevo proceso
      vempresa := pac_md_common.f_get_cxtempresa;

      IF vsproces IS NULL THEN
         ttexto := f_axis_literales(9901089, f_idiomauser);

         IF pcinout = 1 THEN
            nerror := f_procesini(f_user, vempresa, 'N234IN', ttexto, vsproces);
         ELSE
            nerror := f_procesini(f_user, vempresa, 'N234OUT', ttexto, vsproces);
         END IF;
      END IF;

      IF pnfichero IS NULL THEN
         -- FAL. Ini Bug 0015904
         SELECT COUNT(*) + 1   -- NVL(MAX(nfichero), 0) + 1
           -- FAL. Fin Bug 0015904
         INTO   ordre_fitxer
           FROM tdc234_out
          WHERE TRUNC(fenvio) = data_fitxer;
      ELSE
         ordre_fitxer := pnfichero;
      END IF;

      IF ordre_fitxer = 10 THEN
         RAISE maxfitxers;
      END IF;

      BEGIN
         nretval := pk_tr234_out.generar_n234(vsproces, pcinout, pfhasta);
      END;

      -- Bug 0013153 - FAL - 18/03/2010 - Recuperar nombre fichero especifico si existe. Ó el standard de iAXIS si no definido.

      -----pcinout: entrada o sortida
      /*
      IF pcinout = 1 THEN
         ptnomfich := 'RAXIS_Q234_ENT' || TO_CHAR(f_sysdate, 'DDMMYYY_HH24MISS') || '.TXT';
      ELSIF pcinout = 2 THEN
         ptnomfich := 'RAXIS_Q234_SOR_' || TO_CHAR(f_sysdate, 'DDMMYYY_HH24MISS') || '.TXT';
      END IF;
      */
      IF pcinout = 1 THEN
         ptnomfich := pac_nombres_ficheros.f_nom_tras_ent(vsproces, ordre_fitxer);
      ELSIF pcinout = 2 THEN
         ptnomfich := pac_nombres_ficheros.f_nom_tras_sal(vsproces, ordre_fitxer);
      END IF;

      IF ptnomfich = '-1' THEN
         RETURN 9901092;
      END IF;

      --ptnomfich := '_' || ptnomfich;
      ptnomfich := ptnomfich;
      -- Fi Bug 0013153
      -- NMM.2013.01.16.Bug 25376
      xretval := pac_map.f_genera_map(pcmapead, vsproces, ptnomfich, pdebug, pcconruta);
      COMMIT;

      UPDATE trasplainout
         SET cenvio = 1
       WHERE stras IN(SELECT stras
                        FROM tdc234_out_det
                       WHERE sproces = vsproces
                         AND cndato = 201);

      INSERT INTO tdc234_out
                  (stdc234out, fenvio, nfichero, tfichero, stras, sseguro, cestado, stdc)
         SELECT seq_sstdc234out.NEXTVAL, data_fitxer, ordre_fitxer, LTRIM(ptnomfich, '_'),
                tt.stras, tt.sseguro, tt.cestado, NULL
           FROM tdc234_out_det t, trasplainout tt
          WHERE t.sproces = vsproces
            AND t.stras = tt.stras
            AND t.cndato = 201;

     DELETE      tdc234_out_det
           WHERE sproces = vsproces;

      COMMIT;

      IF xretval LIKE '0|%' THEN
         nerror := f_procesfin(vsproces, 0);

         --Bug 25376-XVM-30/05/2013
         IF pcinout = 1 THEN
            xruta := pac_parametros.f_parinstalacion_t('N234_S');
         --    UTL_FILE.frename(f_parinstalacion_t('N234_I'), ptnomfich,
         --                     f_parinstalacion_t('N234_I'), LTRIM(ptnomfich, '_'));
         ELSE
            xruta := pac_parametros.f_parinstalacion_t('N234_C');
         --    UTL_FILE.frename(f_parinstalacion_t('N234'), ptnomfich,
         --                     f_parinstalacion_t('N234'), LTRIM(ptnomfich, '_'));
         END IF;

         --Bug 25376-XVM-30/05/2013
         ptnomfich := xruta || '\' || LTRIM(ptnomfich, '_');
         RETURN 0;
      ELSE
         nerror := f_procesfin(vsproces, 1);
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN maxfitxers THEN
         nnumlin := NULL;
         ttexto := f_axis_literales(9901087, f_idiomauser);
         nerror := f_proceslin(vsproces, ttexto, 1, nnumlin);
         nerror := f_procesfin(vsproces, 2);
         RETURN 1;
      WHEN OTHERS THEN
         ttexto := f_axis_literales(1000455, f_idiomauser);
         nerror := f_proceslin(vsproces, ttexto || ' ' || SQLCODE, 1, nnumlin);
         nerror := f_procesfin(vsproces, 3);
         RETURN 1;
   END f_generar_fichero;
END;

/

  GRANT EXECUTE ON "AXIS"."PK_TR234_OUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TR234_OUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TR234_OUT" TO "PROGRAMADORESCSI";
