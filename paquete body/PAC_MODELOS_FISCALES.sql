--------------------------------------------------------
--  DDL for Package Body PAC_MODELOS_FISCALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MODELOS_FISCALES" AS
/******************************************************************************
   NAME:       pac_modelos_fiscales
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/11/2010    RSC             1. Created this package body.
   2.0        30/11/2010    ETM             2. 0016875: 2010: Modelos 190 - 111  Se añaden nuevas funciones--
   3.0        12/09/2012    APD             3. 0022996: MDP_F001-Fiscalidad - crear el modelo 7
   4.0        18/06/2013    dlF             4. 0023886: Modelo 347. Contemplar (operaciones con terceros)
   5.0        30/09/2013    dlF             5. 0028221: Errores DEC MOD 7 DGS
   6.0        31/01/2014    dlF             6. 0028221: Errores DEC MOD 7 DGS SINIESTROS
******************************************************************************/
   e_param_error  EXCEPTION;

   FUNCTION f_valida_alfabetico(ptexto IN VARCHAR2)
      RETURN VARCHAR2 IS
      i              NUMBER;
      car            VARCHAR2(1);
      vtexto         VARCHAR2(200);

      FUNCTION f_caracter_valido(car IN VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         IF (65 <= ASCII(car)
             AND ASCII(car) <= 90)
            OR ASCII(car) = 32
            OR ASCII(car) = 39
            OR ASCII(car) = 44
            OR ASCII(car) = 45
            OR ASCII(car) = 46
            OR ASCII(car) = 180
            OR ASCII(car) = 199
            OR ASCII(car) = 209 THEN
            RETURN 0;
         ELSE
            RETURN 1;
         END IF;
      END f_caracter_valido;
   BEGIN
      vtexto := UPPER(TRIM(ptexto));
      vtexto := TRANSLATE(vtexto, 'óÓòÒöÖôÔáÁàÀäÄÀÂéÉèÈëËêÊíÍìÌïÏîÎúÚùÙüÜûÛ' || CHR(9) || '.',
                          'oOoOoOoOaAaAaAAAeEeEeEeEiIiIiIiIuUuUuUuU');

      -- Eliminamos 2 espacios en blanco y los pasamos a uno solo
      WHILE INSTR(vtexto, '  ') > 0 LOOP   -- Hi ha 2 espais a '  '
         vtexto := REPLACE(vtexto, '  ', ' ');
      END LOOP;

      i := 1;

      WHILE i < LENGTH(vtexto) LOOP
         car := SUBSTR(vtexto, i, 1);

         IF f_caracter_valido(car) <> 0 THEN   -- caracter no valido
            vtexto := REPLACE(vtexto, car, '-');
         END IF;

         i := i + 1;
      END LOOP;

      RETURN TRIM(vtexto);
   END f_valida_alfabetico;

   FUNCTION f_valida_alfabeticonum(ptexto IN VARCHAR2)
      RETURN VARCHAR2 IS
      i              NUMBER;
      car            VARCHAR2(1);
      vtexto         VARCHAR2(200);

      FUNCTION f_caracter_valido(car IN VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         IF (48 <= ASCII(car)
             AND ASCII(car) <= 57)
            OR(65 <= ASCII(car)
               AND ASCII(car) <= 90)
            OR ASCII(car) = 32
            OR ASCII(car) = 39
            OR ASCII(car) = 44
            OR ASCII(car) = 45
            OR ASCII(car) = 46
            OR ASCII(car) = 180
            OR ASCII(car) = 199
            OR ASCII(car) = 209 THEN
            RETURN 0;
         ELSE
            RETURN 1;
         END IF;
      END f_caracter_valido;
   BEGIN
      vtexto := UPPER(TRIM(ptexto));
      vtexto := TRANSLATE(vtexto, 'óÓòÒöÖôÔáÁàÀäÄÀÂéÉèÈëËêÊíÍìÌïÏîÎúÚùÙüÜûÛ' || CHR(9) || '.',
                          'oOoOoOoOaAaAaAAAeEeEeEeEiIiIiIiIuUuUuUuU');

      -- Eliminamos 2 espacios en blanco y los pasamos a uno solo
      WHILE INSTR(vtexto, '  ') > 0 LOOP   -- Hi ha 2 espais a '  '
         vtexto := REPLACE(vtexto, '  ', ' ');
      END LOOP;

      i := 1;

      WHILE i < LENGTH(vtexto) LOOP
         car := SUBSTR(vtexto, i, 1);

         IF f_caracter_valido(car) <> 0 THEN   -- caracter no valido
            vtexto := REPLACE(vtexto, car, '-');
         END IF;

         i := i + 1;
      END LOOP;

      RETURN TRIM(vtexto);
   END f_valida_alfabeticonum;

   FUNCTION f_valida_alfanumerico(ptexto IN VARCHAR2)
      RETURN VARCHAR2 IS
      i              NUMBER;
      car            VARCHAR2(1);
      vtexto         VARCHAR2(200);

      FUNCTION f_caracter_valido(car IN VARCHAR2)
         RETURN NUMBER IS
      BEGIN
         IF (48 <= ASCII(car)
             AND ASCII(car) <= 57)
            OR(65 <= ASCII(car)
               AND ASCII(car) <= 90)
            OR ASCII(car) = 32
            OR ASCII(car) = 38
            OR ASCII(car) = 39
            OR ASCII(car) = 44
            OR ASCII(car) = 45
            OR ASCII(car) = 46
            OR ASCII(car) = 47
            OR ASCII(car) = 58
            OR ASCII(car) = 59
            OR ASCII(car) = 95
            OR ASCII(car) = 180
            OR ASCII(car) = 199
            OR ASCII(car) = 209 THEN
            RETURN 0;
         ELSE
            RETURN 1;
         END IF;
      END f_caracter_valido;
   BEGIN
      vtexto := UPPER(TRIM(ptexto));
      vtexto := TRANSLATE(vtexto, 'óÓòÒöÖôÔáÁàÀäÄÀÂéÉèÈëËêÊíÍìÌïÏîÎúÚùÙüÜûÛ' || CHR(9) || '.',
                          'oOoOoOoOaAaAaAAAeEeEeEeEiIiIiIiIuUuUuUuU');

      -- Eliminamos 2 espacios en blanco y los pasamos a uno solo
      WHILE INSTR(vtexto, '  ') > 0 LOOP   -- Hi ha 2 espais a '  '
         vtexto := REPLACE(vtexto, '  ', ' ');
      END LOOP;

      i := 1;

      WHILE i < LENGTH(vtexto) LOOP
         car := SUBSTR(vtexto, i, 1);

         IF f_caracter_valido(car) <> 0 THEN   -- caracter no valido
            vtexto := REPLACE(vtexto, car, '-');
         END IF;

         i := i + 1;
      END LOOP;

      RETURN TRIM(vtexto);
   END f_valida_alfanumerico;

   PROCEDURE p_concat_file_fismod345(lpath IN VARCHAR2, pfile1 IN VARCHAR2, pfile2 IN VARCHAR2) IS
      vsfile1        UTL_FILE.file_type;
      vsfile2        UTL_FILE.file_type;
      vsfile3        UTL_FILE.file_type;
      vnewline       VARCHAR2(500);
      -- Numero de declarados
      vdeclarados_pp NUMBER;
      vdeclarados_aho NUMBER;
      -- Importe total de las aportaciones
      vtotal_pp      NUMBER;
      vtotal_aho     NUMBER;
      randomid       NUMBER;
   BEGIN
      vsfile1 := UTL_FILE.fopen(lpath, pfile1, 'a');
      vsfile2 := UTL_FILE.fopen(lpath, pfile2, 'r');

      IF UTL_FILE.is_open(vsfile2) THEN
         -- Descartamos la primera linea
         UTL_FILE.get_line(vsfile2, vnewline);

         -- Obtenemos el numero de declarados
         SELECT SUBSTR(vnewline, 136, 9)
           INTO vdeclarados_pp
           FROM DUAL;

         -- Importe total de las aportaciones
         SELECT SUBSTR(vnewline, 145, 15)
           INTO vtotal_pp
           FROM DUAL;

         LOOP
            BEGIN
               UTL_FILE.get_line(vsfile2, vnewline);

               IF vnewline IS NULL THEN
                  EXIT;
               END IF;

               UTL_FILE.put_line(vsfile1, vnewline);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  EXIT;
            END;
         END LOOP;
      END IF;

      UTL_FILE.fclose(vsfile1);
      UTL_FILE.fclose(vsfile2);

      -- Debemos modificar la primera linea del fichero destino (Ahorro)
      SELECT ABS(DBMS_RANDOM.random)
        INTO randomid
        FROM DUAL;

      vsfile1 := UTL_FILE.fopen(lpath, pfile1, 'r');
      vsfile3 := UTL_FILE.fopen(lpath, 'dummy_fiscal_' || randomid || '.txt', 'w');

      IF UTL_FILE.is_open(vsfile1) THEN
         -- Obtenemos la primera linea (Ahorro)
         UTL_FILE.get_line(vsfile1, vnewline);

         -- Obtenemos el numero de declarados
         SELECT SUBSTR(vnewline, 136, 9)
           INTO vdeclarados_aho
           FROM DUAL;

         -- Importe total de las aportaciones
         SELECT SUBSTR(vnewline, 145, 15)
           INTO vtotal_aho
           FROM DUAL;

         UTL_FILE.put_line(vsfile3,
                           SUBSTR(vnewline, 1, 135)
                           || LPAD((vdeclarados_pp + vdeclarados_aho), 9, '0')
                           || LPAD((vtotal_pp + vtotal_aho), 15, '0')
                           || SUBSTR(vnewline, 160, 250));

         LOOP
            BEGIN
               UTL_FILE.get_line(vsfile1, vnewline);

               IF vnewline IS NULL THEN
                  EXIT;
               END IF;

               UTL_FILE.put_line(vsfile3, vnewline);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  EXIT;
            END;
         END LOOP;
      END IF;

      UTL_FILE.fclose(vsfile1);
      UTL_FILE.fclose(vsfile3);
      vsfile1 := UTL_FILE.fopen(lpath, pfile1, 'w');
      vsfile3 := UTL_FILE.fopen(lpath, 'dummy_fiscal_' || randomid || '.txt', 'r');

      IF UTL_FILE.is_open(vsfile3) THEN
         LOOP
            BEGIN
               UTL_FILE.get_line(vsfile3, vnewline);

               IF vnewline IS NULL THEN
                  EXIT;
               END IF;

               UTL_FILE.put_line(vsfile1, vnewline);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  EXIT;
            END;
         END LOOP;
      END IF;

      UTL_FILE.fclose(vsfile1);
      UTL_FILE.fclose(vsfile3);
      --utl_file.fremove(lpath, 'dummy_fiscal_'||randomid||'.txt'); -- no tenemos permisos para borrar
      vsfile1 := UTL_FILE.fopen(lpath, 'dummy_fiscal_' || randomid || '.txt', 'w');
      UTL_FILE.put_line(vsfile1, '');
      UTL_FILE.fclose(vsfile1);
   END p_concat_file_fismod345;

   FUNCTION f_modelos_planes(pmodelo IN VARCHAR2, pany IN NUMBER)
      RETURN NUMBER IS
      CURSOR cobro IS
         SELECT DISTINCT spersonp, sseguro, cramo, cmodali, ctipseg, ccolect
                    FROM fis_detcierrecobro   --Aportaciones Mod.345
                   WHERE pfiscal = pany
                     AND cramo IN(1, 2, 3, 4, 5, 6, 7, 10)
                ORDER BY spersonp, sseguro;

      CURSOR cobro_emaya IS
         SELECT DISTINCT spersonp, sseguro, cramo, cmodali, ctipseg, ccolect
                    FROM fis_detcierrecobro
                   --Aportaciones del Promotor EMAYA  Mod.345
         WHERE           pfiscal = pany
                     AND cramo = 10
                     AND cmodali = 2
                     AND ctipseg = 1
                     AND ccolect = 0
                ORDER BY spersonp, sseguro;

      CURSOR pago(pcramo IN NUMBER, pcmodali IN NUMBER, pctipseg IN NUMBER, pccolect IN NUMBER) IS
         SELECT DISTINCT spersonp, sfiscab, cramo, cmodali, ctipseg, ccolect   --sseguro,
                    FROM fis_detcierrepago   --Prestaciones  Mod.190
                   WHERE pfiscal = pany
                     AND cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect
                ORDER BY spersonp;

      CURSOR c_rete IS
         SELECT DISTINCT cramo, cmodali, ctipseg, ccolect
                    FROM fis_detcierrepago   --Retenedores Mod.190
                   WHERE pfiscal = pany
                     AND cramo IN(1, 2, 3, 4, 5, 6, 7, 10)
                ORDER BY cramo, cmodali, ctipseg, ccolect;

      --   vsperson       NUMBER;
      vcobropart     NUMBER;
      vcobroprom     NUMBER;
      --   vpagbruto      NUMBER;
      --   vpagresrcm     NUMBER;
      --   vpagresred     NUMBER;
      --   vpagbase       NUMBER;
      --   vpagretenc     NUMBER;
      vnif           personas.nnumnif%TYPE;
      vnifminusv     empresas.nnumnif%TYPE;
      vnombre        VARCHAR2(100);
      vanynacimi     personas.nnumnif%TYPE;
      vnomplan       planpensiones.tnompla%TYPE;
      --   vplan          VARCHAR2(10);
      vfondo         fonpensiones.ccodfon%TYPE;
      vciffondo      personas.nnumnif%TYPE;
      vlinea         VARCHAR2(2000);
      fitxer         UTL_FILE.file_type;
      lpath          VARCHAR2(100);
      vspermin       riesgos.spermin%TYPE;
      vpagoretenc    fis_detcierrepago.iretenc%TYPE;
      vpagoreduc     fis_detcierrepago.iresred%TYPE;
       --   vpagoimporte   NUMBER;
      --    vconting       NUMBER;
       --   vsituac        NUMBER;
      --    vnifcon        VARCHAR2(9);
      --    vfechijo       VARCHAR2(4);
      --    vgradohijo     NUMBER;
      vnifconyuge    fis_irpfpp.nnifcon%TYPE;
      vgradodisc     fis_irpfpp.cgradop%TYPE;
      --    vdescont       VARCHAR2(100);
      --    vdessituac     VARCHAR2(100);
      --    vdesgrado      VARCHAR2(100);
      --    vdesgradoh     VARCHAR2(100);
      --num_err        NUMBER;
      vsituacfam     fis_irpfpp.csitfam%TYPE;
      vspersonemp    empresas.sperson%TYPE;
      vdeclarant     empresas.tempres%TYPE;
      vnifdecla      empresas.nnumnif%TYPE;
      vtperson       NUMBER;
      vtimporte      NUMBER;
      --    vaportprom     NUMBER;
      vnifreten      personas.nnumnif%TYPE;
      vrepresentante VARCHAR2(9);
      vnomreten      planpensiones.tnompla%TYPE;
      vpercepesp     VARCHAR2(44);
      vprolon        fis_irpfpp.prolon%TYPE;
      vmovgeo        fis_irpfpp.rmovgeo%TYPE;
      vgastos        NUMBER;
      vipension      fis_irpfpp.ipension%TYPE;
      vianuhijos     fis_irpfpp.ianuhijos%TYPE;
      vpercepcion    fis_detcierrepago.ibruto%TYPE;
      xnnum          NUMBER;
      vmenor3        fis_irpfpp.ndecmen25%TYPE;
      vmenor3ent     fis_irpfpp.ntdem25en%TYPE;
      vmenorresto    VARCHAR2(2);
      vmenorent      VARCHAR2(2);
      vdisg1         VARCHAR2(2);
      vdisg1ent      VARCHAR2(2);
      vdisg3         VARCHAR2(2);
      vdisg3ent      VARCHAR2(2);
      vdisg2         VARCHAR2(2);
      vdisg2ent      VARCHAR2(2);
      vascmenor75    NUMBER;
      vascmenor75ent NUMBER;
      vascmayor75    NUMBER;
      vascmayor75ent NUMBER;
      vascdisg1      NUMBER;
      vascdisg1ent   NUMBER;
      vascdisg3      NUMBER;
      vascdisg3ent   NUMBER;
      vascdisg2      NUMBER;
      vascdisg2ent   NUMBER;
      vcontacto      VARCHAR2(49) := '971228440FLEIXAS ANTON ANTONIO';
      vjust          VARCHAR2(13);
      vjustant       VARCHAR2(13) := '0';
      vtotalpercep   NUMBER;
      vtotalretenc   NUMBER;
      vreg           NUMBER;
      vsigno         VARCHAR2(1);
      vespacios      VARCHAR2(75) := RPAD(NVL(NULL, ' '), 75, ' ');
      --vesp345                varchar2(90):=rpad(nvl(null,' '),90,' '); -- RSC 22/12/2008
      vesp345        VARCHAR2(320) := RPAD(NVL(NULL, ' '), 320, ' ');
      -- RSC 22/12/2008
      vtidenti       personas.tidenti%TYPE;
      vtarresid      targresid.tarresid%TYPE;
   BEGIN
      --lpath := f_parinstalacion_t('INFORMES');
      lpath := f_parinstalacion_t('PATH_FASES');

      IF pmodelo = '345' THEN
         fitxer := UTL_FILE.fopen(lpath, 'Modelo345-' || TO_CHAR(pany) || '.txt', 'w');
      ELSIF pmodelo = '190' THEN
         fitxer := UTL_FILE.fopen(lpath, 'Modelo190-' || TO_CHAR(pany) || '.txt', 'w');
      END IF;

      IF pmodelo = '345' THEN
         -------------------            FICHERO 345 GENERAL    -------------------
         --Cabecera del fichero 345 GENERAL
         SELECT e.sperson, SUBSTR(LPAD(e.nnumnif, 9, ' '), 1, 9),
                RPAD(REPLACE(UPPER(e.tempres), 'Ñ', CHR(209)), 40, ' ')
           INTO vspersonemp, vnifdecla,
                vdeclarant
           FROM fis_cabcierre f, empresas e
          WHERE nanyo = pany
            AND f.cempres = e.cempres;

         SELECT COUNT(DISTINCT spersonp)
           INTO vtperson
           FROM fis_detcierrecobro
          WHERE pfiscal = pany;

         SELECT SUM(NVL(iaporpart, 0) + NVL(iaporprom, 0) + NVL(iaporprima, 0))
           INTO vtimporte
           FROM fis_detcierrecobro
          WHERE pfiscal = pany;

         --Inserción cabecera
         vjust := '3450000000001';
         vlinea := '1' || pmodelo || pany || vnifdecla || vdeclarant || 'T'
                   || RPAD(vcontacto, 49, ' ') || vjust || '  ' || LPAD(vjustant, 13, '0')
                   || LPAD(vtperson, 9, '0') || LPAD(vtimporte * 100, 15, '0') || vesp345
                   || '                     ';
         UTL_FILE.put_line(fitxer, vlinea);

         FOR x IN cobro LOOP
            SELECT SUM(NVL(iaporpart, 0)), SUM(NVL(iaporprom, 0) + NVL(iaporprima, 0))
              INTO vcobropart, vcobroprom
              FROM fis_detcierrecobro
             WHERE pfiscal = pany
               AND sseguro = x.sseguro;

            vrepresentante := LPAD(NVL(vrepresentante, ' '), 9, ' ');

            BEGIN
               SELECT SUBSTR(LPAD(nnumnif, 9, ' '), 1, 9),
                      SUBSTR
                         (RPAD
                             (REPLACE
                                     (REPLACE(REPLACE(REPLACE(REPLACE(UPPER(tapelli) || ' '
                                                                      || UPPER(tnombre),
                                                                      'Ñ', CHR(209)),
                                                              'Ç', CHR(199)),
                                                      '#', CHR(209)),
                                              'ª', ' '),
                                      ' . ', ' '),
                              40, ' '),
                          1, 40),
                      NVL(TO_CHAR(fnacimi, 'yyyy'), 0), tidenti
                 INTO vnif,
                      vnombre,
                      vanynacimi, vtidenti
                 FROM personas
                WHERE sperson = x.spersonp;

               vnombre := REPLACE(vnombre, ' . ', ' ');

               IF vtidenti = 3 THEN   -- Pasaporte
                  BEGIN
                     SELECT tarresid
                       INTO vtarresid
                       FROM targresid
                      WHERE sperson = x.spersonp;

                     vnif := SUBSTR(LPAD(vtarresid, 9, ' '), 1, 9);
                  EXCEPTION
                     WHEN OTHERS THEN   -- Targeta de residencia no encontrada.
                        NULL;
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  vnif := RPAD(NVL(vnif, ' '), 9, ' ');
                  vanynacimi := '0000';
                  vnombre := RPAD(NVL(vnombre, ' '), 40, ' ');
            END;

            SELECT spermin
              INTO vspermin
              FROM riesgos
             WHERE sseguro = x.sseguro;

            IF vspermin IS NOT NULL THEN
               BEGIN
                  SELECT SUBSTR(LPAD(nnumnif, 9, ' '), 1, 9)
                    INTO vnifminusv
                    FROM personas
                   WHERE sperson = vspermin;
               EXCEPTION
                  WHEN OTHERS THEN
                     vnifminusv := RPAD(NVL(vnifminusv, ' '), 9, ' ');
               END;
            ELSE
               vnifminusv := RPAD(NVL(vnifminusv, ' '), 9, ' ');
            END IF;

            BEGIN
               SELECT SUBSTR(RPAD(tnompla, 40, ' '), 1, 40), LPAD(f.ccodfon, 3, '0'),
                      SUBSTR(LPAD(ps.nnumnif, 9, ' '), 1, 9)
                 INTO vnomplan, vfondo,
                      vciffondo
                 FROM proplapen p, planpensiones pl, fonpensiones f, personas ps
                WHERE p.sproduc = (SELECT sproduc
                                     FROM productos
                                    WHERE cramo = x.cramo
                                      AND cmodali = x.cmodali
                                      AND ctipseg = x.ctipseg
                                      AND ccolect = x.ccolect)
                  AND p.ccodpla = pl.ccodpla
                  AND f.ccodfon = pl.ccodfon
                  AND ps.sperson = f.sperson;
            EXCEPTION
               WHEN OTHERS THEN
                  vnomplan := RPAD(NVL(vnomplan, ' '), 40, ' ');
                  vfondo := '000';
                  vciffondo := RPAD(NVL(vciffondo, ' '), 9, ' ');
            END;

            IF vcobropart <> 0 THEN
               --Aportaciones Partícipe
               vlinea := '2345' || pany || vnifdecla || vnif || vrepresentante || vnombre
                         || LPAD(vanynacimi, 4, '0') || '07A00' || vnifminusv
                         || LPAD((100 * vcobropart), 13, '0') || vnomplan || vfondo || '  '
                         || vciffondo || SUBSTR(vesp345, 1, 9) || RPAD('0', 20, '0')
                         || SUBSTR(vesp345, 10, LENGTH(vesp345));
               UTL_FILE.put_line(fitxer, vlinea);
            END IF;

            IF vcobroprom <> 0 THEN
               --Aportaciones Promotor
               vlinea := '2345' || pany || vnifdecla || vnif || vrepresentante || vnombre
                         || LPAD(vanynacimi, 4, '0') || '07B00' || vnifminusv
                         || LPAD((100 * vcobroprom), 13, '0') || vnomplan || vfondo || '  '
                         || vciffondo || SUBSTR(vesp345, 1, 9) || RPAD('0', 20, '0')
                         || SUBSTR(vesp345, 10, LENGTH(vesp345));
               UTL_FILE.put_line(fitxer, vlinea);
            END IF;

            vcobropart := 0;
            vcobroprom := 0;
            vnifminusv := NULL;
            vnif := NULL;
            vnombre := NULL;
            vanynacimi := NULL;
            vnomplan := NULL;
            vfondo := NULL;
            vciffondo := NULL;
         END LOOP;

         UTL_FILE.fclose(fitxer);
         -------------------            FICHERO 345 EMAYA    -------------------
         fitxer := UTL_FILE.fopen(lpath, 'M345EMA-' || TO_CHAR(pany) || '.txt', 'w');

         --Cabecera del fichero 345 EMAYA
         SELECT SUBSTR(LPAD(nnumnif, 9, ' '), 1, 9),
                RPAD(REPLACE(UPPER(tapelli), 'Ñ', CHR(209)), 40, ' ')
           INTO vnifdecla,
                vdeclarant
           FROM personas
          WHERE sperson = 800;

         SELECT COUNT(DISTINCT spersonp)
           INTO vtperson
           FROM fis_detcierrecobro
          WHERE pfiscal = pany
            AND cramo = 10
            AND cmodali = 2
            AND ctipseg = 1
            AND ccolect = 0;

         SELECT SUM(NVL(iaporprom, 0) + NVL(iaporprima, 0))
           INTO vtimporte
           FROM fis_detcierrecobro
          WHERE pfiscal = pany
            AND cramo = 10
            AND cmodali = 2
            AND ctipseg = 1
            AND ccolect = 0;

         --Inserción cabecera
         vjust := '3450000000001';
         vlinea := '1' || pmodelo || pany || vnifdecla || vdeclarant || 'D'
                   || RPAD('971774302SASTRE BARCELO CRISTOFOL', 49, ' ') || vjust || '  '
                   || LPAD(vjustant, 13, '0') || LPAD(vtperson, 9, '0')
                   || LPAD(vtimporte * 100, 15, '0') || vesp345 || '                     ';
         UTL_FILE.put_line(fitxer, vlinea);

         FOR y IN cobro_emaya LOOP
            SELECT SUM(NVL(iaporprom, 0) + NVL(iaporprima, 0))
              INTO vcobroprom
              FROM fis_detcierrecobro
             WHERE pfiscal = pany
               AND sseguro = y.sseguro;

            vrepresentante := LPAD(NVL(vrepresentante, ' '), 9, ' ');

            BEGIN
               SELECT SUBSTR(LPAD(nnumnif, 9, ' '), 1, 9),
                      SUBSTR
                         (RPAD
                             (REPLACE
                                     (REPLACE(REPLACE(REPLACE(REPLACE(UPPER(tapelli) || ' '
                                                                      || UPPER(tnombre),
                                                                      'Ñ', CHR(209)),
                                                              'Ç', CHR(199)),
                                                      '#', CHR(209)),
                                              'ª', ' '),
                                      ' . ', ' '),
                              40, ' '),
                          1, 40),
                      NVL(TO_CHAR(fnacimi, 'yyyy'), 0), tidenti
                 INTO vnif,
                      vnombre,
                      vanynacimi, vtidenti
                 FROM personas
                WHERE sperson = y.spersonp;

               IF vtidenti = 3 THEN
                  BEGIN
                     SELECT tarresid
                       INTO vtarresid
                       FROM targresid
                      WHERE sperson = y.spersonp;

                     vnif := SUBSTR(LPAD(vtarresid, 9, ' '), 9, ' ');
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  vnif := RPAD(NVL(vnif, ' '), 9, ' ');
                  vanynacimi := '0000';
                  vnombre := RPAD(NVL(vnombre, ' '), 40, ' ');
            END;

            vnifminusv := RPAD(NVL(vnifminusv, ' '), 9, ' ');

            BEGIN
               SELECT SUBSTR(RPAD(tnompla, 40, ' '), 1, 40), LPAD(f.ccodfon, 3, '0'),
                      SUBSTR(LPAD(ps.nnumnif, 9, ' '), 1, 9)
                 INTO vnomplan, vfondo,
                      vciffondo
                 FROM proplapen p, planpensiones pl, fonpensiones f, personas ps
                WHERE p.sproduc = (SELECT sproduc
                                     FROM productos
                                    WHERE cramo = 10
                                      AND cmodali = 2
                                      AND ctipseg = 1
                                      AND ccolect = 0)
                  AND p.ccodpla = pl.ccodpla
                  AND f.ccodfon = pl.ccodfon
                  AND ps.sperson = f.sperson;
            EXCEPTION
               WHEN OTHERS THEN
                  vnomplan := RPAD(NVL(vnomplan, ' '), 40, ' ');
                  vfondo := '000';
                  vciffondo := RPAD(NVL(vciffondo, ' '), 9, ' ');
            END;

            IF vcobroprom <> 0 THEN
               --Aportaciones Promotor
               vlinea := '2345' || pany || vnifdecla || vnif || vrepresentante || vnombre
                         || LPAD(vanynacimi, 4, '0') || '07C01' || vnifminusv
                         || LPAD((100 * vcobroprom), 13, '0') || vnomplan || vfondo || '  '
                         || vciffondo || SUBSTR(vesp345, 1, 9) || RPAD('0', 20, '0')
                         || SUBSTR(vesp345, 10, LENGTH(vesp345));
               UTL_FILE.put_line(fitxer, vlinea);
            END IF;

            vcobroprom := 0;
            vnifminusv := NULL;
            vnif := NULL;
            vnombre := NULL;
            vanynacimi := NULL;
            vnomplan := NULL;
            vfondo := NULL;
            vciffondo := NULL;
         END LOOP;
      ELSIF pmodelo = '190' THEN   --    MODELO 190
         -------------------            FICHERO 190          -------------------
         FOR reten IN c_rete LOOP
            --Linea del retenedor
            SELECT SUBSTR(LPAD(ps.nnumnif, 9, ' '), 1, 9),
                   SUBSTR(RPAD(tnompla, 40, ' '), 1, 40)
              INTO vnifreten,
                   vnomreten
              FROM proplapen p, planpensiones pl, fonpensiones f, personas ps
             WHERE p.sproduc = (SELECT sproduc
                                  FROM productos
                                 WHERE cramo = reten.cramo
                                   AND cmodali = reten.cmodali
                                   AND ctipseg = reten.ctipseg
                                   AND ccolect = reten.ccolect)
               AND p.ccodpla = pl.ccodpla
               AND f.ccodfon = pl.ccodfon
               AND ps.sperson = f.sperson;

            vjust := '1700703511315';

            SELECT COUNT(DISTINCT(spersonp))
              INTO vreg
              FROM fis_detcierrepago
             WHERE cramo = reten.cramo
               AND cmodali = reten.cmodali
               AND ctipseg = reten.ctipseg
               AND ccolect = reten.ccolect;

            SELECT SUM(NVL(ibruto, 0)), SUM(NVL(iretenc, 0))
              INTO vtotalpercep, vtotalretenc
              FROM fis_detcierrepago
             WHERE cramo = reten.cramo
               AND cmodali = reten.cmodali
               AND ctipseg = reten.ctipseg
               AND ccolect = reten.ccolect;

            IF vtotalpercep < 0 THEN
               vsigno := 'N';
            ELSE
               vsigno := ' ';
            END IF;

            vlinea := '1' || pmodelo || pany || vnifreten || vnomreten || 'D'
                      || RPAD(vcontacto, 49, ' ') || vjust || '  ' || LPAD(vjustant, 13, '0')
                      || LPAD(vreg, 9, '0') || vsigno || LPAD((100 * vtotalpercep), 15, '0')
                      || LPAD((100 * vtotalretenc), 15, '0') || vespacios;
            UTL_FILE.put_line(fitxer, vlinea);

            FOR pag IN pago(reten.cramo, reten.cmodali, reten.ctipseg, reten.ccolect) LOOP
               SELECT SUM(NVL(iretenc, 0)), SUM(NVL(iresred, 0)), SUM(NVL(ibruto, 0))
                 INTO vpagoretenc, vpagoreduc, vpercepcion
                 FROM fis_detcierrepago
                WHERE spersonp = pag.spersonp
                  AND cramo = pag.cramo
                  AND cmodali = pag.cmodali
                  AND ctipseg = pag.ctipseg
                  AND ccolect = pag.ccolect;

               vgastos := 0;
               vrepresentante := LPAD(NVL(vrepresentante, ' '), 9, ' ');
               vpercepesp := LPAD(NVL(vpercepesp, ' '), 44, '0');

               IF vpercepcion < 0 THEN
                  vsigno := 'N';
               ELSE
                  vsigno := ' ';
               END IF;

               BEGIN
                  SELECT SUBSTR(LPAD(nnumnif, 9, ' '), 1, 9),
                         SUBSTR(RPAD(tapelli || ' ' || tnombre, 40, ' '), 1, 40),
                         TO_CHAR(fnacimi, 'yyyy')
                    INTO vnif,
                         vnombre,
                         vanynacimi
                    FROM personas p
                   WHERE p.sperson = pag.spersonp;
               EXCEPTION
                  WHEN OTHERS THEN
                     vnif := RPAD(NVL(vnif, ' '), 40, ' ');
                     vanynacimi := '0000';
                     vnombre := RPAD(NVL(vnombre, ' '), 40, ' ');
               END;

               --Graba en la tabla FIS_IRPFPP
               pk_fis_hacienda.carga_fis_irpf(NULL, pag.spersonp, pany, pag.sfiscab, xnnum);

               SELECT SUBSTR(RPAD(NVL(nnifcon, ' '), 9, ' '), 1, 9), NVL(cgradop, '0'),
                      NVL(csitfam, 3), NVL(prolon, '0'), NVL(rmovgeo, '0'),
                      NVL(ipension, '0'), NVL(ianuhijos, '0'),
                      NVL(TO_NUMBER(SUBSTR(ndecmen25, 2, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(ntdem25en, 2, 1)), 0),
                      LPAD(NVL(TO_NUMBER(SUBSTR(ndecmen25, 3, 2)), 0)
                           + NVL(TO_NUMBER(SUBSTR(ndecmen25, 5, 2)), 0),
                           2, '0'),
                      LPAD(NVL(TO_NUMBER(SUBSTR(ntdem25en, 3, 2)), 0)
                           + NVL(TO_NUMBER(SUBSTR(ntdem25en, 5, 2)), 0),
                           2, '0'),
                      LPAD(NVL(TO_NUMBER(SUBSTR(ndecdisca, 1, 2)), 0), 2, '0'),
                      LPAD(NVL(TO_NUMBER(SUBSTR(ntdedisen, 1, 2)), 0), 2, '0'),
                      LPAD(NVL(TO_NUMBER(SUBSTR(ndecdisca, 5, 2)), 0), 2, '0'),
                      LPAD(NVL(TO_NUMBER(SUBSTR(ntdedisen, 5, 2)), 0), 2, '0'),
                      LPAD(NVL(TO_NUMBER(SUBSTR(ndecdisca, 3, 2)), 0), 2, '0'),
                      LPAD(NVL(TO_NUMBER(SUBSTR(ntdedisen, 3, 2)), 0), 2, '0'),
                      NVL(TO_NUMBER(SUBSTR(nascendie, 1, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(ntascenen, 1, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(nascendie, 2, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(ntascenen, 2, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(nascdisca, 1, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(ntasdisen, 1, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(nascdisca, 3, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(ntasdisen, 3, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(nascdisca, 2, 1)), 0),
                      NVL(TO_NUMBER(SUBSTR(ntasdisen, 2, 1)), 0)
                 INTO vnifconyuge, vgradodisc,
                      vsituacfam, vprolon, vmovgeo,
                      vipension, vianuhijos,
                      vmenor3,
                      vmenor3ent,
                      vmenorresto,
                      vmenorent,
                      vdisg1,
                      vdisg1ent,
                      vdisg3,
                      vdisg3ent,
                      vdisg2,
                      vdisg2ent,
                      vascmenor75,
                      vascmenor75ent,
                      vascmayor75,
                      vascmayor75ent,
                      vascdisg1,
                      vascdisg1ent,
                      vascdisg3,
                      vascdisg3ent,
                      vascdisg2,
                      vascdisg2ent
                 FROM fis_irpfpp
                WHERE sfiscab = pag.sfiscab
                  AND sperson = pag.spersonp;

               vlinea := '2190' || pany || vnifreten || vnif || vrepresentante || vnombre
                         || '07B02' || vsigno || LPAD((100 * vpercepcion), 13, '0')
                         || LPAD((100 * vpagoretenc), 13, '0') || ' ' || vpercepesp
                         || vanynacimi || vsituacfam || vnifconyuge || vgradodisc || '0'
                         || vprolon || vmovgeo || LPAD((100 * vpagoreduc), 13, '0')
                         || LPAD((100 * vgastos), 13, '0') || LPAD((100 * vipension), 13, '0')
                         || LPAD((100 * vianuhijos), 13, '0') || vmenor3 || vmenor3ent
                         || vmenorresto || vmenorent || vdisg1 || vdisg1ent || vdisg3
                         || vdisg3ent || vdisg2 || vdisg2ent || vascmenor75 || vascmenor75ent
                         || vascmayor75 || vascmayor75ent || vascdisg1 || vascdisg1ent
                         || vascdisg3 || vascdisg3ent || vascdisg2 || vascdisg2ent;
               UTL_FILE.put_line(fitxer, vlinea);
               vpagoretenc := 0;
               vpagoreduc := 0;
               vpercepcion := 0;
               vnif := NULL;
               vnombre := NULL;
               vanynacimi := NULL;
            END LOOP;

            vtotalpercep := 0;
            vtotalretenc := 0;
         END LOOP;
      END IF;

      UTL_FILE.fclose(fitxer);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Generación fichero modelo ' || pmodelo, NULL,
                     'Error en la generación del fichero modelo ' || pmodelo, SQLERRM);
         RETURN 1;
   END;

   PROCEDURE p_modelos_aho_rentas188(
      pmodelo IN VARCHAR2,
      pany IN NUMBER,
      pcempres IN NUMBER,
      pcsoporte IN VARCHAR2,
      fitxer IN UTL_FILE.file_type) IS
      vcpaisfiscal   personas.cpais%TYPE;
      vlinea         VARCHAR2(500);
      vlinea1        VARCHAR2(500);
      vlinea2        VARCHAR2(500);
      vsseguro       NUMBER;
      vrepresentante VARCHAR2(14);
      do_nothing     EXCEPTION;
   BEGIN
      BEGIN
         SELECT cpais
           INTO vcpaisfiscal
           FROM empresas e, personas p
          WHERE e.sperson = p.sperson
            AND e.cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            vcpaisfiscal := NULL;
      END;

      SELECT   pmodelo || '|' || pcempres || '|' || LPAD(SUM(signe_pos), 9, '0') || '|'
               || LPAD(SUM(base * signe_pos) * 100, 15, '0')
               ||   --Concatenem directament
                 LPAD(SUM(importe * signe_pos) * 100, 15, '0') || LPAD(SUM(signe_neg), 9, '0')
               || LPAD(SUM(base * signe_neg) *(-100), 15, '0') || '|' || TO_CHAR(pmodelo + 1)
          INTO vlinea
          FROM (SELECT   c.cempres, d.spersonp sperson, SUM(iresrcm) base, SUM
                                                                              (iresrcm)
                                                                                       importe,
                         DECODE(csigbase, 'P', 1, 0) signe_pos,
                         DECODE(csigbase, 'P', 0, 1) signe_neg
                    FROM fis_cabcierre c, fis_detcierrepago d, fis_modhacienda m, seguros s
                   WHERE d.sfiscab = c.sfiscab
                     AND iresrcm != 0
                     AND c.nanyo = pany
                     AND m.modhacienda = pmodelo
                     AND m.cramo = d.cramo
                     AND NVL(d.cpaisret, vcpaisfiscal) = vcpaisfiscal
                     -- Residentes en España
                     AND d.sseguro = s.sseguro
                     AND s.cagrpro IN(2, 10, 21)   -- (*)
                     AND d.ctipo <> 'SIN'
                GROUP BY c.cempres, d.spersonp, d.sseguro, d.csigbase)
      GROUP BY cempres;

      SELECT '1' || pac_util.splitt(vlinea, 1, '|') || pany || LPAD(e.nnumnif, 9, '0')
             || RPAD(e.tempres, 40, ' ') || pcsoporte
             || (SELECT LPAD(NVL(MAX(c.tvalcon), '0'), 9, '0')
                   FROM personas p, contactos c
                  WHERE p.spercon = c.sperson
                    AND p.sperson = e.sperson
                    AND ctipcon = 1)
             || (SELECT REPLACE
                           (REPLACE
                               (REPLACE
                                   (REPLACE
                                       (REPLACE
                                           (REPLACE
                                               (REPLACE
                                                   (REPLACE
                                                       (UPPER
                                                           (RPAD
                                                               (NVL(MAX(RTRIM(p2.tapelli)
                                                                        || ' ' || p2.tnombre),
                                                                    ' '),
                                                                40, ' ')),
                                                        'À', 'A'),
                                                    'Á', 'A'),
                                                'É', 'E'),
                                            'È', 'E'),
                                        'Í', 'I'),
                                    'Ò', 'O'),
                                'Ó', 'O'),
                            'Ú', 'U')
                   FROM personas p, personas p2
                  WHERE p.spercon = p2.sperson
                    AND p.sperson = e.sperson)
             || RPAD(pac_util.splitt(vlinea, 5, '|'), 13, '0') || RPAD(' ', 2, ' ')
             || LPAD('0', 13, '0') || pac_util.splitt(vlinea, 3, '|')
             || RPAD(pac_util.splitt(vlinea, 4, '|'), 15, '0')
             || DECODE(pac_util.splitt(vlinea, 1, '|'),
                       345, LPAD(' ', 24, ' '),
                       LPAD('0', 24, '0'))
             || DECODE(pac_util.splitt(vlinea, 1, '|'),
                       188,(LPAD('0', 15, '0') || LPAD(' ', 52, ' ')),
                       LPAD(' ', 67, ' '))
        INTO vlinea1
        FROM empresas e
       WHERE e.cempres = pac_util.splitt(vlinea, 2, '|');

      UTL_FILE.put_line(fitxer, vlinea1);

      FOR regs IN
         ((SELECT   pmodelo || '|' || c.cempres || '|' || d.spersonp || '|'
                    || d.sperson1 || '|' || DECODE(d.csigbase, 'N', 'N', ' ')
                    || LPAD(ABS(SUM(NVL(iresrcm, 0))) * 100, 12, '0')
                    ||   -- RENTAS O RENDIMIENTOS DEL CAPITAL MOBILIARIO
                      DECODE
                         (NVL(f_parproductos_v(f_sproduc_ret(d.cramo, d.cmodali, d.ctipseg,
                                                             d.ccolect),
                                               'TIPO_LIMITE'),
                              0),
                          1, ' ' || LPAD('0', 12, '0'),
                          DECODE
                              (d.ctipo,
                               'VTO', DECODE(SIGN(NVL((SUM(NVL(d.pconsum_ircm, 0))
                                                       - SUM(NVL(d.pconsum_ireduc, 0))
                                                       - SUM(NVL(d.pconsum_ireg_transcomp, 0))),
                                                      0)),
                                             -1, 'N',
                                             ' ')
                                || LPAD
                                     (ABS(NVL(ROUND((SUM(NVL(d.pconsum_ircm, 0))
                                                     - SUM(NVL(d.pconsum_ireduc, 0))
                                                     - SUM(NVL(d.pconsum_ireg_transcomp, 0))),
                                                    2),
                                              0))
                                      * 100,
                                      12, '0'),
                               'RTO', DECODE(SIGN(NVL((SUM(NVL(d.pconsum_ircm, 0))
                                                       - SUM(NVL(d.pconsum_ireduc, 0))
                                                       - SUM(NVL(d.pconsum_ireg_transcomp, 0))),
                                                      0)),
                                             -1, 'N',
                                             ' ')
                                || LPAD
                                     (ABS(NVL(ROUND((SUM(NVL(d.pconsum_ircm, 0))
                                                     - SUM(NVL(d.pconsum_ireduc, 0))
                                                     - SUM(NVL(d.pconsum_ireg_transcomp, 0))),
                                                    2),
                                              0))
                                      * 100,
                                      12, '0'),
                               ' ' || LPAD('0', 12, '0')))
                    ||   -- Información adicional
                      LPAD(ABS(SUM(NVL(iresred, 0))) * 100, 13, '0')
                    || DECODE(SIGN(SUM(NVL(iresrcm, 0)) - SUM(NVL(iresred, 0))), -1, 'N', ' ')
                    || LPAD(ABS(SUM(NVL(iresrcm, 0)) - SUM(NVL(iresred, 0))) * 100, 12, '0')
                    ||   -- RSC 08/01/2009 El RCM Neto
                      DECODE(d.csigbase, 'N', '0000', LPAD(MAX(NVL(pretenc, 0)) * 100, 4, '0'))
                    || DECODE(d.csigbase,
                              'N', '0000000000000',
                              LPAD(SUM(NVL(iretenc, 0)) * 100, 13, '0'))
                    || '0000'
                    || DECODE(NVL(f_parproductos_v(f_sproduc_ret(d.cramo, d.cmodali, d.ctipseg,
                                                                 d.ccolect),
                                                   'TIPO_LIMITE'),
                                  0),
                              1, DECODE(d.csigbase,
                                        'N', ' ',
                                        DECODE(NVL(iresred, 0), 0, ' ', 'B')),
                              DECODE(NVL((SUM(NVL(d.pconsum_ircm, 0))
                                          - SUM(NVL(d.pconsum_ireduc, 0))
                                          - SUM(NVL(d.pconsum_ireg_transcomp, 0))),
                                         0),
                                     0, ' ',
                                     'A'))
                    || '|' || d.sseguro || '|' || d.nnumnifp || '|' || d.nnumnif1 || '|'
                    || d.ctipo linea
               FROM fis_cabcierre c, fis_detcierrepago d, fis_modhacienda m,
                    seguros s   --, PRIMAS_CONSUMIDAS p
              WHERE d.sfiscab = c.sfiscab
                AND iresrcm != 0
                AND c.nanyo = pany
                AND m.modhacienda = pmodelo
                AND m.cramo = d.cramo
                AND NVL(d.cpaisret, vcpaisfiscal) = vcpaisfiscal
                AND d.sseguro = s.sseguro
                AND s.cagrpro IN(2, 10, 21)   -- (*)
           --and p.sseguro (+) = s.sseguro
           GROUP BY c.cempres, d.spersonp, d.sperson1, d.sseguro, d.csigbase, m.cramo, iresred,
                    d.sseguro, d.nnumnifp, d.nnumnif1, d.ctipo /*d.ctipcap, d.sidepag*/,
                    d.cramo, d.cmodali, d.ctipseg, d.ccolect)
          ORDER BY d.sseguro, d.spersonp, d.sperson1) LOOP
         BEGIN
            vsseguro := TO_NUMBER(pac_util.splitt(regs.linea, 6, '|'));
            -- Obtención del representante -----------------------------------------
            vrepresentante := LPAD(NVL(pac_util.splitt(regs.linea, 8, '|'), ' '), 9, ' ');

            -- RSC 16/12/2008 ---------
            IF NVL(pac_util.splitt(regs.linea, 9, '|'), '') = 'SIN' THEN
               RAISE do_nothing;
            END IF;

----------------------------
            BEGIN
               SELECT '2' || pac_util.splitt(regs.linea, 1, '|') || pany
                      || LPAD(e.nnumnif, 9, '0')
                      || DECODE(pac_util.splitt(regs.linea, 7, '|'),
                                NULL, LPAD(NVL(pac_util.splitt(regs.linea, 7, '|'), ' '), 9,
                                           ' '),
                                LPAD(NVL(pac_util.splitt(regs.linea, 7, '|'), '0'), 9, '0'))
                      || vrepresentante
                      || RPAD(f_valida_alfabetico(p.tapelli) || ' '
                              || f_valida_alfabetico(p.tnombre),
                              40, ' ')
                      || LPAD(NVL(DECODE(d.cprovin, 999, 7, NULL, 7, d.cprovin), '0'), 2, '0')
                      || '1' || RPAD(pac_util.splitt(regs.linea, 5, '|'), 172, ' ')
                 INTO vlinea2
                 FROM empresas e, personas p, direcciones d, asegurados a
                WHERE e.cempres = pac_util.splitt(regs.linea, 2, '|')
                  AND p.sperson = pac_util.splitt(regs.linea, 3, '|')
                  AND d.sperson(+) = p.sperson
                  AND a.sperson = p.sperson
                  AND d.cdomici = a.cdomici
                  AND a.sseguro = vsseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT '2' || pac_util.splitt(regs.linea, 1, '|') || pany
                         || LPAD(e.nnumnif, 9, '0')
                         || DECODE(pac_util.splitt(regs.linea, 7, '|'),
                                   NULL, LPAD(NVL(pac_util.splitt(regs.linea, 7, '|'), ' '), 9,
                                              ' '),
                                   LPAD(NVL(pac_util.splitt(regs.linea, 7, '|'), '0'), 9, '0'))
                         || vrepresentante
                         || RPAD(f_valida_alfabetico(p.tapelli) || ' '
                                 || f_valida_alfabetico(p.tnombre),
                                 40, ' ')
                         || LPAD(NVL(DECODE(d.cprovin, 999, 7, NULL, 7, d.cprovin), '0'), 2,
                                 '0') || '1'
                         || RPAD(pac_util.splitt(regs.linea, 5, '|'), 172, ' ')
                    INTO vlinea2
                    FROM empresas e, personas p, direcciones d
                   WHERE e.cempres = pac_util.splitt(regs.linea, 2, '|')
                     AND p.sperson = pac_util.splitt(regs.linea, 3, '|')
                     AND d.sperson(+) = p.sperson
                     AND d.cdomici(+) = 1;
            END;

            UTL_FILE.put_line(fitxer, vlinea2);
         EXCEPTION
            WHEN do_nothing THEN
               NULL;
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Generación fichero modelo ' || pmodelo, NULL,
                     'Error en la generación del fichero modelo ' || pmodelo, SQLERRM);
   END p_modelos_aho_rentas188;

   PROCEDURE p_modelos_aho_rentas347(
      pmodelo IN VARCHAR2,
      pany IN NUMBER,
      pcempres IN NUMBER,
      pcsoporte IN VARCHAR2,
      fitxer IN UTL_FILE.file_type) IS
      --vcpaisfiscal   NUMBER;
      vlinea         VARCHAR2(500);
      vlinea1        VARCHAR2(500);
      vlinea2        VARCHAR2(500);
      vsseguro       NUMBER;
      vrepresentante VARCHAR2(14);
      vcpais         NUMBER;
      do_nothing     EXCEPTION;
   BEGIN
      SELECT   pmodelo || '|' || pcempres || '|' || LPAD(COUNT(sperson), 9, '0') || '|'
               || LPAD(SUM(importe) * 100, 15, '0') || '|' || '347'
          INTO vlinea
          FROM (SELECT   c.cempres, d.spersonp sperson,
                         SUM(ROUND(NVL(iimporte, 0), 2) + ROUND(NVL(ibaseimp, 0), 2)
                             + ROUND(NVL(iconsorcio, 0), 2) + ROUND(NVL(iclea, 0), 2)
                             + ROUND(NVL(iips, 0), 2)) importe
                    FROM fis_cabcierre c, fis_detcierrecobro d, fis_modhacienda m, seguros s
                   WHERE d.sfiscab = c.sfiscab
                     AND c.nanyo = pany
                     AND m.modhacienda = pmodelo
                     AND m.cramo = d.cramo
                     AND d.sseguro = s.sseguro
                     AND s.cagrpro IN(2, 10, 21)   -- (*)
                GROUP BY c.cempres, d.spersonp, d.sseguro, d.cpaisret, d.sperson1
                  HAVING SUM(ROUND(NVL(iimporte, 0), 2) + ROUND(NVL(ibaseimp, 0), 2)
                             + ROUND(NVL(iconsorcio, 0), 2) + ROUND(NVL(iclea, 0), 2)
                             + ROUND(NVL(iips, 0), 2)) > k_umbral_347
                UNION ALL
                SELECT   c.cempres, d.spersonp sperson, SUM(ibruto) importe
                    FROM fis_cabcierre c, fis_detcierrepago d, seguros s
                   WHERE d.sfiscab = c.sfiscab
                     AND c.nanyo = pany
                     AND d.sseguro = s.sseguro
                     AND s.cagrpro IN(2, 10, 21)   -- (*)
                     AND d.ctipo <> 'SIN'
                     -- Controlamos que el destinatario sea diferente que el tomador de la poliza
                     AND d.spersonp NOT IN(SELECT t.sperson
                                             FROM tomadores t
                                            WHERE t.sseguro = d.sseguro)
                GROUP BY c.cempres, d.spersonp, d.sseguro, d.cpaisret, d.sperson1
                  HAVING NVL(SUM(ibruto), 0) > k_umbral_347)
      GROUP BY cempres;

      SELECT '1' || pmodelo || pany || LPAD(e.nnumnif, 9, '0') || RPAD(e.tempres, 40, ' ')
             || pcsoporte
             || (SELECT LPAD(NVL(MAX(c.tvalcon), '0'), 9, '0')
                   FROM personas p, contactos c
                  WHERE p.spercon = c.sperson
                    AND p.sperson = e.sperson
                    AND ctipcon = 1)
             || (SELECT REPLACE
                           (REPLACE
                               (REPLACE
                                   (REPLACE
                                       (REPLACE
                                           (REPLACE
                                               (REPLACE
                                                   (REPLACE
                                                       (UPPER
                                                           (RPAD
                                                               (NVL(MAX(RTRIM(p2.tapelli)
                                                                        || ' ' || p2.tnombre),
                                                                    ' '),
                                                                40, ' ')),
                                                        'À', 'A'),
                                                    'Á', 'A'),
                                                'É', 'E'),
                                            'È', 'E'),
                                        'Í', 'I'),
                                    'Ò', 'O'),
                                'Ó', 'O'),
                            'Ú', 'U')
                   FROM personas p, personas p2
                  WHERE p.spercon = p2.sperson
                    AND p.sperson = e.sperson)
             || RPAD(pmodelo, 13, '0') || RPAD(' ', 2, ' ') || LPAD('0', 13, '0')
             || pac_util.splitt(vlinea, 3, '|')
             || RPAD(pac_util.splitt(vlinea, 4, '|'), 15, '0') ||
                                                                 --LPAD(' ',67,' ')) -- Ajustes por cambios en el modelo 2008
                                                                 RPAD('0', 9, '0')
             || RPAD('0', 15, '0') || LPAD(' ', 207, ' ') || LPAD(' ', 9, ' ')
             ||   -- NIF del representane
               LPAD(' ', 101, ' ')
        INTO vlinea1
        FROM empresas e
       WHERE e.cempres = pcempres;

      UTL_FILE.put_line(fitxer, vlinea1);

      FOR regs IN ((SELECT   pmodelo || '|' || c.cempres || '|' || d.spersonp || '|'
                             || 'B'
                             || LPAD(SUM(ROUND(NVL(iimporte, 0), 2)
                                         + ROUND(NVL(ibaseimp, 0), 2)
                                         + ROUND(NVL(iconsorcio, 0), 2)
                                         + ROUND(NVL(iclea, 0), 2)
                                         + ROUND(NVL(iips, 0), 2))
                                     * 100,
                                     15, '0')
                             || '|' || d.sseguro || '|' || d.cpaisret || '|'
                             || d.sperson1 || '|' || d.nnumnifp || '|' || d.nnumnif1
                             || '|' || NULL linea
                        FROM fis_cabcierre c, fis_detcierrecobro d, fis_modhacienda m,
                             seguros s
                       WHERE d.sfiscab = c.sfiscab
                         AND c.nanyo = pany
                         AND m.modhacienda = pmodelo
                         AND m.cramo = d.cramo
                         AND d.sseguro = s.sseguro
                         AND s.cagrpro IN(2, 10, 21)   -- (*)
                    GROUP BY c.cempres, d.spersonp, d.sseguro, d.cpaisret, d.sperson1,
                             d.nnumnifp, d.nnumnif1
                      HAVING SUM(NVL(iimporte, 0) + NVL(ibaseimp, 0) + NVL(iconsorcio, 0)
                                 + NVL(iclea, 0) + NVL(iips, 0)) > k_umbral_347
                    UNION ALL
                    SELECT   '347' || '|' || c.cempres || '|' || d.spersonp || '|'
                             || 'B' || LPAD(SUM(d.ibruto) * 100, 15, '0') || '|'
                             || d.sseguro || '|' || d.cpaisret || '|' || d.sperson1
                             || '|' || d.nnumnifp || '|' || d.nnumnif1 || '|' || d.ctipo linea
                        FROM fis_cabcierre c, fis_detcierrepago d, seguros s
                       WHERE d.sfiscab = c.sfiscab
                         AND c.nanyo = pany
                         AND d.sseguro = s.sseguro
                         AND s.cagrpro IN(2, 10, 21)   -- (*)
                         -- Controlamos que el destinatario sea diferente que el tomador de la poliza
                         AND d.spersonp NOT IN(SELECT t.sperson
                                                 FROM tomadores t
                                                WHERE t.sseguro = d.sseguro)
                    GROUP BY c.cempres, d.spersonp, d.sseguro, d.cpaisret, d.sperson1,
                             d.nnumnifp, d.nnumnif1, d.ctipo
                      HAVING NVL(SUM(ibruto), 0) > k_umbral_347)) LOOP
         BEGIN
            vsseguro := TO_NUMBER(pac_util.splitt(regs.linea, 5, '|'));
            vcpais := TO_NUMBER(pac_util.splitt(regs.linea, 6, '|'));

            IF vcpais IS NULL THEN
               vcpais := 999;
            END IF;

            -- RSC 16/12/2008 ---------
            IF NVL(pac_util.splitt(regs.linea, 10, '|'), '') = 'SIN' THEN
               RAISE do_nothing;
            END IF;

----------------------------

            -- Obtención del representante -----------------------------------------
            vrepresentante := LPAD(NVL(pac_util.splitt(regs.linea, 9, '|'), ' '), 9, ' ');

            BEGIN
               SELECT '2' || pmodelo || pany || LPAD(e.nnumnif, 9, '0')
                      ||
                        --LPAD(p.nnumnif,9,'0')                    ||
                        DECODE(pac_util.splitt(regs.linea, 8, '|'),
                               NULL, LPAD(NVL(pac_util.splitt(regs.linea, 8, '|'), ' '), 9,
                                          ' '),
                               LPAD(NVL(pac_util.splitt(regs.linea, 8, '|'), '0'), 9, '0'))
                      || vrepresentante
                      || RPAD(f_valida_alfabetico(p.tapelli) || ' '
                              || f_valida_alfabetico(p.tnombre),
                              40, ' ')
                      || 'D'
                      || LPAD(NVL(DECODE(vcpais,
                                         42, DECODE(d.cprovin, 999, 7, NULL, 7, d.cprovin),
                                         999, DECODE(d.cprovin, 999, 7, NULL, 7, d.cprovin),
                                         99),
                                  '0'),
                              2, '0')
                      || RPAD(DECODE(pp.codisoiban, 'QU', ' ', 'ES', ' ', pp.codisoiban), 3,
                              ' ') || pac_util.splitt(regs.linea, 4, '|') || 'X '
                      ||
                        --RPAD(' ',151,' ')
                        LPAD('0', 15, '0') ||   -- “Importes percibidos en metálico” (2008)
                                             LPAD('0', 15, '0')
                      ||
                        -- “Importe percibido por transmisiones de inmuebles sujetos a IVA” (2008)
                        RPAD(' ', 371, ' ')   --  BLANCOS
                 INTO vlinea2
                 FROM empresas e, personas p, direcciones d, paises pp, asegurados a
                WHERE e.cempres = pcempres
                  AND p.sperson = TO_NUMBER(pac_util.splitt(regs.linea, 3, '|'))
                  AND d.sperson(+) = p.sperson
                  AND a.sperson = p.sperson
                  AND d.cdomici = a.cdomici
                  AND a.sseguro = vsseguro
                  AND pp.cpais = vcpais;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT '2' || pmodelo || pany || LPAD(e.nnumnif, 9, '0')
                         ||
                           --LPAD(p.nnumnif,9,'0')                    ||
                           DECODE(pac_util.splitt(regs.linea, 8, '|'),
                                  NULL, LPAD(NVL(pac_util.splitt(regs.linea, 8, '|'), ' '), 9,
                                             ' '),
                                  LPAD(NVL(pac_util.splitt(regs.linea, 8, '|'), '0'), 9, '0'))
                         || vrepresentante
                         || RPAD(f_valida_alfabetico(p.tapelli) || ' '
                                 || f_valida_alfabetico(p.tnombre),
                                 40, ' ')
                         || 'D'
                         || LPAD(NVL(DECODE(vcpais,
                                            42, DECODE(d.cprovin, 999, 7, NULL, 7, d.cprovin),
                                            999, DECODE(d.cprovin, 999, 7, NULL, 7, d.cprovin),
                                            99),
                                     '0'),
                                 2, '0')
                         || RPAD(DECODE(pp.codisoiban, 'QU', ' ', 'ES', ' ', pp.codisoiban), 3,
                                 ' ')
                         || pac_util.splitt(regs.linea, 4, '|') || 'X ' ||
                                                                          --RPAD(' ',151,' ')
                                                                          LPAD('0', 15, '0')
                         ||   -- “Importes percibidos en metálico” (2008)
                           LPAD('0', 15, '0') ||
                                                -- “Importe percibido por transmisiones de inmuebles sujetos a IVA” (2008)
                                                RPAD(' ', 371, ' ')   --  BLANCOS
                    INTO vlinea2
                    FROM empresas e, personas p, direcciones d, paises pp
                   WHERE e.cempres = pcempres
                     AND p.sperson = TO_NUMBER(pac_util.splitt(regs.linea, 3, '|'))
                     AND d.sperson(+) = p.sperson
                     AND d.cdomici(+) = 1
                     AND pp.cpais = vcpais;
            END;

            UTL_FILE.put_line(fitxer, vlinea2);
         EXCEPTION
            WHEN do_nothing THEN
               NULL;
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Generación fichero modelo ' || pmodelo, NULL,
                     'Error en la generación del fichero modelo ' || pmodelo, SQLERRM);
   END;

   PROCEDURE p_modelos_aho_rentas345(
      pmodelo IN VARCHAR2,
      pany IN NUMBER,
      pcempres IN NUMBER,
      pcsoporte IN VARCHAR2,
      fitxer IN UTL_FILE.file_type) IS
      --vcpaisfiscal   NUMBER;
      vlinea         VARCHAR2(500);
      vlinea1        VARCHAR2(500);
      vlinea2        VARCHAR2(500);
      --vsseguro       NUMBER;
      --vrepresentante VARCHAR2(14);
      --vcpais         NUMBER;
      do_nothing     EXCEPTION;
   --vsproduc       NUMBER;
   BEGIN
      SELECT   '345' || '|' || pcempres || '|' || LPAD(COUNT(DISTINCT sperson), 9, '0') || '|'
               || LPAD(SUM(importe) * 100, 15, '0') || '|' || '344'
          INTO vlinea
          FROM (SELECT   c.cempres, d.spersonp sperson, SUM(iimporte) importe
                    FROM fis_cabcierre c, fis_detcierrecobro d, fis_modhacienda m
                   WHERE d.sfiscab = c.sfiscab
                     AND c.nanyo = pany
                     AND m.modhacienda = '345'
                     AND m.cramo = d.cramo
                GROUP BY c.cempres, d.spersonp
                  HAVING NVL(SUM(iimporte), 0) <> 0)
      GROUP BY pcempres;

      SELECT '1' || pmodelo || pany || LPAD(e.nnumnif, 9, '0') || RPAD(e.tempres, 40, ' ')
             || pcsoporte
             || (SELECT LPAD(NVL(MAX(c.tvalcon), '0'), 9, '0')
                   FROM personas p, contactos c
                  WHERE p.spercon = c.sperson
                    AND p.sperson = e.sperson
                    AND ctipcon = 1)
             || (SELECT REPLACE
                           (REPLACE
                               (REPLACE
                                   (REPLACE
                                       (REPLACE
                                           (REPLACE
                                               (REPLACE
                                                   (REPLACE
                                                       (UPPER
                                                           (RPAD
                                                               (NVL(MAX(RTRIM(p2.tapelli)
                                                                        || ' ' || p2.tnombre),
                                                                    ' '),
                                                                40, ' ')),
                                                        'À', 'A'),
                                                    'Á', 'A'),
                                                'É', 'E'),
                                            'È', 'E'),
                                        'Í', 'I'),
                                    'Ò', 'O'),
                                'Ó', 'O'),
                            'Ú', 'U')
                   FROM personas p, personas p2
                  WHERE p.spercon = p2.sperson
                    AND p.sperson = e.sperson)
             || RPAD(pmodelo, 13, '0') || RPAD(' ', 2, ' ') || LPAD('0', 13, '0')
             || pac_util.splitt(vlinea, 3, '|')
             || RPAD(pac_util.splitt(vlinea, 4, '|'), 15, '0') || LPAD(' ', 341, ' ')
        INTO vlinea1
        FROM empresas e
       WHERE e.cempres = pcempres;

      UTL_FILE.put_line(fitxer, vlinea1);

      FOR regs IN
         (SELECT   '345' || '|' || c.cempres || '|' || d.spersonp || '|'
                   || LPAD(ABS(SUM(d.iimporte)) * 100, 13, '0') || '|'
                   || DECODE
                            (NVL(f_parproductos_v(f_sproduc_ret(d.cramo, d.cmodali, d.ctipseg,
                                                                d.ccolect),
                                                  'PRESTACION'),
                                 0),
                             1, 'H',
                             0, DECODE(NVL(f_parproductos_v(f_sproduc_ret(d.cramo, d.cmodali,
                                                                          d.ctipseg, d.ccolect),
                                                            'TIPO_LIMITE'),
                                           0),
                                       1, 'I',
                                       ' '))
                   || '|' || d.sseguro || '|' || d.cpaisret || '|' || d.sperson1 || '|'
                   || d.nnumnifp || '|' || d.nnumnif1 || '|'
                   || f_sproduc_ret(d.cramo, d.cmodali, d.ctipseg, d.ccolect) linea
              FROM fis_cabcierre c, fis_detcierrecobro d, fis_modhacienda m
             WHERE d.sfiscab = c.sfiscab
               AND c.nanyo = pany
               AND m.modhacienda = '345'
               AND m.cramo = d.cramo
          GROUP BY c.cempres, d.spersonp, d.sseguro, d.cramo, d.cmodali, d.ctipseg, d.ccolect,
                   d.cpaisret, d.sperson1, d.nnumnifp, d.nnumnif1
            HAVING NVL(SUM(iimporte), 0) <> 0) LOOP
         /*
             -- RSC 14/01/2008 Nota: Actualmente estamos poniendo la provincia
              del tomador. Si esto entrara para dos cabezas se tendría que ver
              que pasa ya que observo que no se graba el CDOMICI del otro
              asegurado.
         */
         SELECT '2' || pmodelo || pany || LPAD(e.nnumnif, 9, '0')
                || DECODE(pac_util.splitt(regs.linea, 9, '|'),
                          NULL, LPAD(NVL(pac_util.splitt(regs.linea, 9, '|'), ' '), 9, ' '),
                          LPAD(NVL(pac_util.splitt(regs.linea, 9, '|'), '0'), 9, '0'))
                || LPAD(NVL(pac_util.splitt(regs.linea, 10, '|'), ' '), 9, ' ')
                || RPAD(pac_modelos_fiscales.f_valida_alfabetico(pd.tapelli1 || ' '
                                                                 || pd.tapelli2)
                        || ' ' || pac_modelos_fiscales.f_valida_alfabetico(pd.tnombre),
                        40, ' ')
                || TO_CHAR(p.fnacimi, 'yyyy')
                || LPAD(NVL(DECODE(NVL(TO_NUMBER(pac_util.splitt(regs.linea, 7, '|')), 999),
                                   42, DECODE(d.cprovin, 999, 8, NULL, 8, d.cprovin),
                                   110, DECODE(d.cprovin, 999, 8, NULL, 8, d.cprovin),
                                   999, DECODE(d.cprovin, 999, 8, NULL, 8, d.cprovin),
                                   99),
                            '0'),
                        2, '0')
                || pac_util.splitt(regs.linea, 5, '|')
                || DECODE(pac_util.splitt(regs.linea, 5, '|'), 'I', '06', '00')
                || RPAD(' ', 9, ' ') || pac_util.splitt(regs.linea, 4, '|')
                || RPAD(' ', 54, ' ') || LPAD(' ', 9, ' ')
                || DECODE(pac_util.splitt(regs.linea, 5, '|'),
                          'I', LPAD((SELECT fval
                                       FROM (SELECT   TO_CHAR(pa.fvalmov, 'YYYYMMDD') fval,
                                                      pa.nnumlin
                                                 FROM primas_aportadas pa
                                                WHERE pa.sseguro =
                                                         TO_NUMBER
                                                                  (pac_util.splitt(regs.linea,
                                                                                   6, '|'))
                                                  AND pa.iprima >
                                                        (SELECT NVL(SUM(ircm), 0)
                                                           FROM primas_consumidas
                                                          WHERE sseguro = pa.sseguro
                                                            AND nnumlin = pa.nnumlin)
                                                  AND ROWNUM = 1
                                             ORDER BY pa.nnumlin ASC)),
                                    8, '0'),
                          '00000000')
                || DECODE
                     (pac_util.splitt(regs.linea, 5, '|'),
                      'I', LPAD
                         (ABS
                             (NVL
                                 (pac_limites_ahorro.ff_calcula_importe
                                     (f_parproductos_v
                                                      (TO_NUMBER(pac_util.splitt(regs.linea,
                                                                                 11, '|')),
                                                       'TIPO_LIMITE'),
                                      p.sperson),
                                  0))
                          * 100,
                          12, '0'),
                      LPAD('0', 12, '0'))
                || RPAD(' ', 311, ' ')
           INTO vlinea2
           FROM empresas e, per_personas p, per_detper pd, per_direcciones d, seguros s,
                tomadores t
          WHERE e.cempres = NVL(pcempres, 1)
            AND p.sperson = TO_NUMBER(pac_util.splitt(regs.linea, 3, '|'))
            AND p.sperson = pd.sperson
            AND pd.cagente = ff_agente_cpervisio(s.cagente)
            AND d.sperson = t.sperson
            --AND d.cagente = pd.cagente
            AND s.sseguro = TO_NUMBER(pac_util.splitt(regs.linea, 6, '|'))
            AND s.sseguro = t.sseguro
            AND d.cdomici(+) = t.cdomici;

         UTL_FILE.put_line(fitxer, vlinea2);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Generación fichero modelo ' || pmodelo, NULL,
                     'Error en la generación del fichero modelo ' || pmodelo, SQLERRM);
   END;

   PROCEDURE p_modelos_aho_rentas296(
      pmodelo IN VARCHAR2,
      pany IN NUMBER,
      pcempres IN NUMBER,
      pcsoporte IN VARCHAR2,
      fitxer IN UTL_FILE.file_type) IS
      vcpaisfiscal   NUMBER;
      vlinea         VARCHAR2(500);
      vlinea1        VARCHAR2(500);
      vlinea2        VARCHAR2(500);
      vsseguro       NUMBER;
      vrepresentante VARCHAR2(14);
      vcpais         NUMBER;
      vcpertip       VARCHAR2(1);
      do_nothing     EXCEPTION;
   BEGIN
      BEGIN
         SELECT cpais
           INTO vcpaisfiscal
           FROM empresas e, personas p
          WHERE e.sperson = p.sperson
            AND e.cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            vcpaisfiscal := NULL;
      END;

      SELECT   pmodelo || '|' || pcempres || '|' || LPAD(SUM(signe_pos), 9, '0') || '|'
               || LPAD(DECODE(SIGN(SUM(base)), -1, 'N', ' '), 1, ' ')
               ||   --Concatenem directament
                 LPAD(SUM(base) * 100, 14, '0') || LPAD(SUM(iretenc) *(100), 15, '0')
               ||   -- Ingresos a cuenta
                 LPAD(SUM(iretenc) *(100), 15, '0') || '|' ||   -- Ingresos a cuenta ingresados
                                                             TO_CHAR(pmodelo + 1)
          INTO vlinea
          FROM (SELECT   c.cempres, d.spersonp sperson, SUM(iresrcm) base, SUM
                                                                              (iretenc)
                                                                                       iretenc,
                         DECODE(csigbase, 'P', 1, 0) signe_pos,
                         DECODE(csigbase, 'P', 0, 1) signe_neg
                    FROM fis_cabcierre c, fis_detcierrepago d, fis_modhacienda m, seguros s
                   WHERE d.sfiscab = c.sfiscab
                     AND iresrcm != 0
                     AND c.nanyo = pany
                     AND m.modhacienda = pmodelo
                     AND m.cramo = d.cramo
                     AND NVL(d.cpaisret, vcpaisfiscal) <> vcpaisfiscal
                     -- No residentes en España
                     AND d.sseguro = s.sseguro
                     AND s.cagrpro IN(2, 10, 21)   -- (*)
                     AND d.ctipo <> 'SIN'
                GROUP BY c.cempres, d.spersonp, d.sseguro, d.csigbase)
      GROUP BY cempres;

      SELECT '1' || pac_util.splitt(vlinea, 1, '|') || pany || LPAD(e.nnumnif, 9, '0')
             || RPAD(e.tempres, 40, ' ') || pcsoporte
             || (SELECT LPAD(NVL(MAX(c.tvalcon), '0'), 9, '0')
                   FROM personas p, contactos c
                  WHERE p.spercon = c.sperson
                    AND p.sperson = e.sperson
                    AND ctipcon = 1)
             || (SELECT REPLACE
                           (REPLACE
                               (REPLACE
                                   (REPLACE
                                       (REPLACE
                                           (REPLACE
                                               (REPLACE
                                                   (REPLACE
                                                       (UPPER
                                                           (RPAD
                                                               (NVL(MAX(RTRIM(p2.tapelli)
                                                                        || ' ' || p2.tnombre),
                                                                    ' '),
                                                                40, ' ')),
                                                        'À', 'A'),
                                                    'Á', 'A'),
                                                'É', 'E'),
                                            'È', 'E'),
                                        'Í', 'I'),
                                    'Ò', 'O'),
                                'Ó', 'O'),
                            'Ú', 'U')
                   FROM personas p, personas p2
                  WHERE p.spercon = p2.sperson
                    AND p.sperson = e.sperson)
             || RPAD(pac_util.splitt(vlinea, 5, '|'), 13, '0') || RPAD(' ', 2, ' ')
             || LPAD('0', 13, '0') || pac_util.splitt(vlinea, 3, '|')
             || pac_util.splitt(vlinea, 4, '|') ||
                                                  --LPAD(' ',61,' ')
                                                  LPAD(' ', 201, ' ') || LPAD(' ', 9, ' ')
             ||   -- NIF del representante legal
               LPAD(' ', 101, ' ')
        INTO vlinea1
        FROM empresas e
       WHERE e.cempres = pac_util.splitt(vlinea, 2, '|');

      UTL_FILE.put_line(fitxer, vlinea1);

      FOR regs IN ((SELECT   pmodelo || '|' || c.cempres || '|' || d.spersonp || '|'
                             || d.sperson1 || '|' || DECODE(d.csigbase, 'N', 'N', ' ')
                             || LPAD(ABS(SUM(NVL(iresrcm, 0))) * 100, 12, '0')
                             || LPAD(MAX(NVL(pretenc, 0)) * 100, 4, '0')
                             || LPAD(SUM(NVL(iretenc, 0)) * 100, 13, '0') || '|'
                             || d.sseguro || '|' || d.cpaisret || '|'
                             || TO_CHAR(d.fpago, 'DDMMYYYY') || '|' || d.nnumnifp || '|'
                             || d.nnumnif1 || '|' || d.ctipo linea
                        FROM fis_cabcierre c, fis_detcierrepago d, fis_modhacienda m,
                             seguros s
                       WHERE d.sfiscab = c.sfiscab
                         AND iresrcm != 0
                         AND c.nanyo = pany
                         AND m.modhacienda = pmodelo
                         AND m.cramo = d.cramo
                         AND NVL(d.cpaisret, vcpaisfiscal) <> vcpaisfiscal
                         -- No residentes en España
                         AND d.sseguro = s.sseguro
                         AND s.cagrpro IN(2, 10, 21)   -- (*)
                    GROUP BY c.cempres, d.spersonp, d.sperson1, d.sseguro, d.csigbase, m.cramo,
                             iresred, d.sseguro, d.cpaisret, d.fpago, d.nnumnifp, d.nnumnif1,
                             d.ctipo)) LOOP
         BEGIN
            vsseguro := TO_NUMBER(pac_util.splitt(regs.linea, 6, '|'));
            vcpais := TO_NUMBER(pac_util.splitt(regs.linea, 7, '|'));

            IF vcpais IS NULL THEN
               vcpais := 999;
            END IF;

            -- Obtención del representante
            vrepresentante := LPAD(NVL(pac_util.splitt(regs.linea, 10, '|'), ' '), 9, ' ');

            -- RSC 16/12/2008 ---------
            IF NVL(pac_util.splitt(regs.linea, 9, '|'), '') = 'SIN' THEN
               RAISE do_nothing;
            END IF;

----------------------------

            -- Persona Fisica o Juridica
            BEGIN
               SELECT DECODE(cpertip, 1, 'F', NULL, 'F', 'J')
                 INTO vcpertip
                 FROM personas
                WHERE sperson = TO_NUMBER(pac_util.splitt(regs.linea, 3, '|'));
            EXCEPTION
               WHEN OTHERS THEN
                  vcpertip := 'F';
            END;

            BEGIN
               SELECT '2' || pac_util.splitt(regs.linea, 1, '|') || pany
                      || LPAD(e.nnumnif, 9, '0')
                      || DECODE(pac_util.splitt(regs.linea, 9, '|'),
                                NULL, LPAD(NVL(pac_util.splitt(regs.linea, 9, '|'), ' '), 9,
                                           ' '),
                                LPAD(NVL(pac_util.splitt(regs.linea, 9, '|'), '0'), 9, '0'))
                      || RPAD(vrepresentante, 9, ' ') || LPAD(vcpertip, 1, ' ')
                      || RPAD(f_valida_alfabetico(p.tapelli) || ' '
                              || f_valida_alfabetico(p.tnombre),
                              40, ' ')
                      ||
                        --LPAD('0',12,'0')||     -- Codigo de extrangero
                        --RPAD(DECODE(pp.codisoiban,'QU',' ','ES',' ', pp.codisoiban),3,' ')                ||
                        LPAD(' ', 14, ' ') || LPAD(pac_util.splitt(regs.linea, 8, '|'), 8, '0')
                      || 'D' ||
                                --'L'||
                      '12' ||   -- Cambios 2008
                             '01' || pac_util.splitt(regs.linea, 5, '|') || ' ' || '0'
                      || LPAD(' ', 12, ' ') || '0' || ' ' || LPAD(' ', 21, ' ')
                      || LPAD('0', 56, '0')
                      ||
                        --lpad(' ',24,' ')
                        LPAD(f_valida_alfabeticonum(SUBSTR(REPLACE(d.tdomici, '/', ''), 1, 49)),
                             50, ' ')
                      ||   -- 227-276
                        LPAD(' ', 40, ' ')
                      ||   -- 277-316 COMPLEMENTO DEL DOMICILIO
                        LPAD(f_valida_alfabetico(SUBSTR(po.tpoblac, 1, 29)), 30, ' ')
                      ||   -- 317-346 POBLACIÓN/CIUDAD
                        LPAD(pr.tprovin, 30, ' ')
                      ||   -- 347-376 PROVINCIA/REGIÓN/ESTADO
                        DECODE(d.cpostal, NULL, LPAD(' ', 10, ' '), LPAD(d.cpostal, 10, ' '))
                      ||   -- 377-386           CÓDIGO POSTAL
                        RPAD(DECODE(pp2.codisoiban, 'QU', ' ', pp2.codisoiban), 2, ' ')
                      ||   --387-388           CÓDIGO PAÍS
                        LPAD(' ', 44, ' ') || LPAD(' ', 20, ' ')
                      ||   -- NIF EN EL PAÍS DE RESIDENCIA FISCAL
                        DECODE(vcpertip,
                               'F', LPAD(TO_CHAR(p.fnacimi, 'ddmmyyyy'), 8, '0'),
                               LPAD('0', 8, '0'))
                      ||   -- 453-460 FECHA DE NACIMIENTO
                        LPAD(' ', 37, ' ')
                      ||   -- Ciudad de nacimiento
                        RPAD(DECODE(pp.codisoiban, 'QU', ' ', 'ES', ' ', pp.codisoiban), 3,
                             ' ')
                 INTO vlinea2
                 FROM empresas e, personas p, direcciones d, asegurados a, paises pp,
                      poblaciones po, provincias pr, paises pp2
                WHERE e.cempres = TO_NUMBER(pac_util.splitt(regs.linea, 2, '|'))
                  AND p.sperson = TO_NUMBER(pac_util.splitt(regs.linea, 3, '|'))
                  AND d.sperson(+) = p.sperson
                  AND a.sperson = p.sperson
                  AND d.cdomici = a.cdomici
                  AND pp.cpais = vcpais
                  AND a.sseguro = vsseguro
                  AND d.cpoblac = po.cpoblac
                  AND d.cprovin = po.cprovin
                  AND po.cprovin = pr.cprovin
                  AND pr.cpais = pp2.cpais;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT '2' || pac_util.splitt(regs.linea, 1, '|') || pany
                         || LPAD(e.nnumnif, 9, '0')
                         ||
                           --LPAD(p.nnumnif,9,'0')||
                           --LPAD(NVL(PAC_UTIL.Splitt (regs.linea,9,'|'),'0'),9,'0')||
                           DECODE(pac_util.splitt(regs.linea, 9, '|'),
                                  NULL, LPAD(NVL(pac_util.splitt(regs.linea, 9, '|'), ' '), 9,
                                             ' '),
                                  LPAD(NVL(pac_util.splitt(regs.linea, 9, '|'), '0'), 9, '0'))
                         || RPAD(vrepresentante, 9, ' ') || LPAD(vcpertip, 1, ' ')
                         || RPAD(f_valida_alfabetico(p.tapelli) || ' '
                                 || f_valida_alfabetico(p.tnombre),
                                 40, ' ')
                         ||
                           --LPAD('0',12,'0')||     -- Codigo de extrangero
                           --RPAD(DECODE(pp.codisoiban,'QU',' ','ES',' ', pp.codisoiban),3,' ') ||
                           LPAD(pac_util.splitt(regs.linea, 8, '|'), 8, '0') || 'D' ||
                                                                                       --'L' ||
                         '12' ||   -- Cambios 2008
                                '01' || pac_util.splitt(regs.linea, 5, '|') || ' ' || '0'
                         || LPAD(' ', 12, ' ') || '0' || ' ' || LPAD(' ', 21, ' ')
                         || LPAD('0', 56, '0')
                         ||
                           --lpad(' ',24,' ')
                           LPAD(f_valida_alfabeticonum(SUBSTR(REPLACE(d.tdomici, '/', ''), 1,
                                                              49)),
                                50, ' ')
                         ||   -- 227-276
                           LPAD(' ', 40, ' ')
                         ||   -- 277-316 COMPLEMENTO DEL DOMICILIO
                           LPAD(f_valida_alfabetico(SUBSTR(po.tpoblac, 1, 29)), 30, ' ')
                         ||   -- 317-346 POBLACIÓN/CIUDAD
                           LPAD(pr.tprovin, 30, ' ')
                         ||   -- 347-376 PROVINCIA/REGIÓN/ESTADO
                           DECODE(d.cpostal,
                                  NULL, LPAD(' ', 10, ' '),
                                  LPAD(d.cpostal, 10, ' '))
                         ||   -- 377-386           CÓDIGO POSTAL
                           RPAD(DECODE(pp2.codisoiban, 'QU', ' ', pp2.codisoiban), 2, ' ')
                         ||   --387-388           CÓDIGO PAÍS
                           LPAD(' ', 44, ' ') || LPAD(' ', 20, ' ')
                         ||   -- NIF EN EL PAÍS DE RESIDENCIA FISCAL
                           LPAD(TO_CHAR(p.fnacimi, 'ddmmyyyy'), 8, '0') ||   -- 453-460 FECHA DE NACIMIENTO
                                                                          LPAD(' ', 37, ' ')
                         ||   -- Ciudad de nacimiento
                           RPAD(DECODE(pp.codisoiban, 'QU', ' ', 'ES', ' ', pp.codisoiban), 3,
                                ' ')
                    INTO vlinea2
                    FROM empresas e, personas p, direcciones d, paises pp, poblaciones po,
                         provincias pr, paises pp2
                   WHERE e.cempres = TO_NUMBER(pac_util.splitt(regs.linea, 2, '|'))
                     AND p.sperson = TO_NUMBER(pac_util.splitt(regs.linea, 3, '|'))
                     AND d.sperson(+) = p.sperson
                     AND d.cdomici(+) = 1
                     AND pp.cpais = vcpais
                     AND d.cpoblac = po.cpoblac
                     AND d.cprovin = po.cprovin
                     AND po.cprovin = pr.cprovin
                     AND pr.cpais = pp2.cpais;
            END;

            UTL_FILE.put_line(fitxer, vlinea2);
         EXCEPTION
            WHEN do_nothing THEN
               NULL;
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Generación fichero modelo ' || pmodelo, NULL,
                     'Error en la generación del fichero modelo ' || pmodelo, SQLERRM);
   END;

   PROCEDURE p_modelos_aho_rentas190(
      pmodelo IN VARCHAR2,
      pany IN NUMBER,
      pcempres IN NUMBER,
      pcsoporte IN VARCHAR2,
      fitxer IN UTL_FILE.file_type) IS
      vlinea         VARCHAR2(500);
      vlinea1        VARCHAR2(500);
      vlinea2        VARCHAR2(500);
      -- vsseguro       NUMBER;
     --  vrepresentante VARCHAR2(14);
     --  vfnacimi       VARCHAR2(4);
     --  vcsitfam       NUMBER;
    --   vnifconyuge    VARCHAR2(9);
    --   vgradoinval    NUMBER;
     --  vprolon        NUMBER;
      -- vrmovgeo       NUMBER;
     --  vipension      NUMBER;
    --   vianuhijos     NUMBER;
    --   vmenor         NUMBER;
    --   vmenor_entero  NUMBER;
   --    vresto         NUMBER;
   --    vresto_entero  NUMBER;
   --    vminusval_1    NUMBER;
   --    vminusval_1_entero NUMBER;
   --    vminusval_3    NUMBER;
   --    vminusval_3_entero NUMBER;
   --    vminusval_2    NUMBER;
   --    vminusval_2_entero NUMBER;
    --   vmenor75       NUMBER;
    --   vmenor75_entero NUMBER;
    --   vmayor75       NUMBER;
    --   vmayor75_entero NUMBER;
    --   vminusmayor_1  NUMBER;
    --   vminusmayor_1_entero NUMBER;
    --   vminusmayor_2  NUMBER;
    --   vminusmayor_2_entero NUMBER;
    --   vminusmayor_3  NUMBER;
    --   vminusmayor_3_entero NUMBER;
    --   vcpertip       VARCHAR2(1);
    --   vcpaisfiscal   NUMBER;
   BEGIN
      SELECT   pmodelo || '|' || pcempres || '|'
               || LPAD(SUM(signe_pos) + SUM(signe_neg), 9, '0') || '|'
               || LPAD(DECODE(SIGN(SUM(ibruto)), -1, 'N', ' '), 1, ' ')
               ||   --Concatenem directament
                 LPAD(SUM(ibruto) * 100, 15, '0') || LPAD(SUM(iretenc) * 100, 15, '0')
          INTO vlinea
          FROM (SELECT   c.cempres, d.spersonp sperson, SUM(NVL(ibruto, 0)) ibruto,
                         SUM(NVL(iretenc, 0)) iretenc, DECODE(csigbase, 'P', 1, 0) signe_pos,
                         DECODE(csigbase, 'P', 0, 1) signe_neg
                    FROM fis_cabcierre c, fis_detcierrepago d, fis_modhacienda m, seguros s,
                         empresas e, per_detper p
                   WHERE d.sfiscab = c.sfiscab
                     AND iresrcm != 0
                     AND c.nanyo = pany
                     AND m.modhacienda = pmodelo
                     AND m.cramo = d.cramo
                     AND NVL(d.cpaisret, p.cpais) = p.cpais
                     -- Residentes en España
                     AND d.sseguro = s.sseguro
                     AND s.cagrpro IN(2, 10, 21)
                     AND e.sperson = p.sperson
                     AND e.cempres = NVL(pcempres, 1)
                GROUP BY c.cempres, d.spersonp, d.sseguro, d.csigbase)
      GROUP BY cempres;

      SELECT '1' || pac_util.splitt(vlinea, 1, '|') || pany || LPAD(e.nnumnif, 9, '0')
             || RPAD(e.tempres, 40, ' ') || pcsoporte
             || (SELECT LPAD(NVL(MAX(c.tvalcon), '0'), 9, '0')
                   FROM personas p, contactos c
                  WHERE p.spercon = c.sperson
                    AND p.sperson = e.sperson
                    AND ctipcon = 1)
             || (SELECT REPLACE
                           (REPLACE
                               (REPLACE
                                   (REPLACE
                                       (REPLACE
                                           (REPLACE
                                               (REPLACE
                                                   (REPLACE
                                                       (UPPER
                                                           (RPAD
                                                               (NVL(MAX(RTRIM(p2.tapelli)
                                                                        || ' ' || p2.tnombre),
                                                                    ' '),
                                                                40, ' ')),
                                                        'À', 'A'),
                                                    'Á', 'A'),
                                                'É', 'E'),
                                            'È', 'E'),
                                        'Í', 'I'),
                                    'Ò', 'O'),
                                'Ó', 'O'),
                            'Ú', 'U')
                   FROM personas p, personas p2
                  WHERE p.spercon = p2.sperson
                    AND p.sperson = e.sperson)
             || RPAD(0, 13, '0') || RPAD(' ', 2, ' ') || LPAD('0', 13, '0')
             || pac_util.splitt(vlinea, 3, '|') || pac_util.splitt(vlinea, 4, '|')
             || LPAD(' ', 62, ' ') || LPAD(' ', 13, ' ')   -- A cumplimentar por AEAT
        INTO vlinea1
        FROM empresas e
       WHERE e.cempres = pac_util.splitt(vlinea, 2, '|');

      UTL_FILE.put_line(fitxer, vlinea1);

      FOR regs IN ((SELECT   pmodelo || '|' || c.cempres || '|' || d.spersonp || '|'
                             || d.sperson1 || '|' || DECODE(d.csigbase, 'N', 'N', ' ')
                             ||   -- Percepciones dinerarias
                               LPAD(ABS(SUM(NVL(ibruto, 0))) * 100, 13, '0')
                             || LPAD(ABS(SUM(NVL(iretenc, 0))) * 100, 13, '0')
                             || DECODE(NULL, 'N', 'N', ' ') ||   -- Percepciones en especie
                                                              LPAD('0', 13, '0')
                             ||   -- Valoración
                               LPAD('0', 13, '0') ||   -- INGRESOS A CUENTA EFECTUADOS
                                                    LPAD('0', 13, '0') || '|'
                             ||   -- INGRESOS A CUENTA REPERCUTIDOS
                               d.sseguro || '|'
                             || LPAD(ABS(SUM(NVL(iresred, 0))) * 100, 13, '0') || '|'
                             || d.nnumnifp || '|' || d.nnumnif1 linea
                        FROM fis_cabcierre c, fis_detcierrepago d, fis_modhacienda m,
                             seguros s, empresas e, per_detper p
                       WHERE d.sfiscab = c.sfiscab
                         AND iresrcm != 0
                         AND c.nanyo = pany
                         AND m.modhacienda = pmodelo
                         AND m.cramo = d.cramo
                         AND NVL(d.cpaisret, p.cpais) = p.cpais
                         AND d.sseguro = s.sseguro
                         AND s.cagrpro IN(2, 10, 21)   -- (*)
                         AND e.sperson = p.sperson
                         AND e.cempres = NVL(pcempres, 1)
                    GROUP BY c.cempres, d.spersonp, d.sperson1, d.sseguro, d.csigbase, m.cramo,
                             iresred, d.sseguro, d.nnumnifp, d.nnumnif1)
                   ORDER BY d.sseguro, d.spersonp, d.sperson1) LOOP
         SELECT '2' || pac_util.splitt(regs.linea, 1, '|') || pany || LPAD(e.nnumnif, 9, '0')
                || DECODE(pac_util.splitt(regs.linea, 8, '|'),
                          NULL, LPAD(NVL(pac_util.splitt(regs.linea, 8, '|'), ' '), 9, ' '),
                          LPAD(NVL(pac_util.splitt(regs.linea, 8, '|'), '0'), 9, '0'))
                || LPAD(NVL(pac_util.splitt(regs.linea, 9, '|'), ' '), 9, ' ')
                || RPAD(pac_modelos_fiscales.f_valida_alfabetico(pd.tapelli1 || ' '
                                                                 || pd.tapelli2)
                        || ' ' || pac_modelos_fiscales.f_valida_alfabetico(pd.tnombre),
                        40, ' ')
                || LPAD(NVL(DECODE(d.cprovin, 999, 8, NULL, 8, d.cprovin), '0'), 2, '0') || 'B'
                ||   --- Clave
                  '02' ||   --- SubClave
                         RPAD(pac_util.splitt(regs.linea, 5, '|'), 67, ' ')
                || RPAD('0', 4, '0') ||   -- Ejercicio devengo
                                       LPAD('0', 1, '0')
                ||   -- Ceuta o Melilla
                  pac_modelos_fiscales.f_global_irpfpersonas
                                                      (TO_NUMBER(pac_util.splitt(regs.linea, 3,
                                                                                 '|')),
                                                       TO_NUMBER(pac_util.splitt(regs.linea, 6,
                                                                                 '|')),
                                                       pany,
                                                       pac_util.splitt(regs.linea, 7, '|'))
                || pac_modelos_fiscales.f_global_irpfdescendientes
                                                      (TO_NUMBER(pac_util.splitt(regs.linea, 3,
                                                                                 '|')),
                                                       TO_NUMBER(pac_util.splitt(regs.linea, 6,
                                                                                 '|')),
                                                       pany)
                || pac_modelos_fiscales.f_global_irpfmayores
                                                      (TO_NUMBER(pac_util.splitt(regs.linea, 3,
                                                                                 '|')),
                                                       TO_NUMBER(pac_util.splitt(regs.linea, 6,
                                                                                 '|')),
                                                       pany)
           INTO vlinea2
           FROM empresas e, per_personas p, per_detper pd, per_direcciones d, seguros s,
                tomadores t
          WHERE e.cempres = pac_util.splitt(regs.linea, 2, '|')
            AND p.sperson = TO_NUMBER(pac_util.splitt(regs.linea, 3, '|'))
            AND p.sperson = pd.sperson
            AND pd.cagente = ff_agente_cpervisio(s.cagente)
            AND d.sperson = t.sperson
            --AND d.cagente = pd.cagente  -- Si no comento esto me encuentro con problemas
            AND s.sseguro = TO_NUMBER(pac_util.splitt(regs.linea, 6, '|'))
            AND s.sseguro = t.sseguro
            AND d.cdomici(+) = t.cdomici;

         UTL_FILE.put_line(fitxer, vlinea2);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Generación fichero modelo ' || pmodelo, NULL,
                     'Error en la generación del fichero modelo ' || pmodelo, SQLERRM);
   END;

   FUNCTION f_datos_irpfpersonas(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pdato IN VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      vfnacimi       VARCHAR2(4);
      vcsitfam       per_irpf.csitfam%TYPE;
      vnifconyuge    per_irpf.cnifcon%TYPE;
      vgradoinval    per_irpf.cgrado%TYPE;
      vprolon        per_irpf.prolon%TYPE;
      vrmovgeo       per_irpf.rmovgeo%TYPE;
      vipension      per_irpf.ipension%TYPE;
      vianuhijos     per_irpf.ianuhijos%TYPE;
      vresultado     VARCHAR2(40);
      vcagente       seguros.cagente%TYPE;
      vpersona       personas%ROWTYPE;
      vresult        NUMBER;
   BEGIN
      BEGIN
         -- Bug 17005 - RSC - 15/12/2010
         IF psseguro IS NOT NULL THEN
            -- Fin Bug 17005
            SELECT cagente
              INTO vcagente
              FROM seguros
             WHERE sseguro = psseguro;
         -- Bug 17005 - RSC - 15/12/2010
         ELSE
            vcagente := pcagente;
         END IF;

         -- Fin Bug 17005
         vresult := pac_persona.f_get_dadespersona(psperson, vcagente, vpersona);

         -- Bug 16732 - RSC - 16/11/2010 - 2010: Modelos 190 - 111
         IF vpersona.fnacimi IS NOT NULL THEN
            -- Fin Bug 16732
            vfnacimi := TO_CHAR(vpersona.fnacimi, 'yyyy');
         -- Bug 16732 - RSC - 16/11/2010 - 2010: Modelos 190 - 111
         ELSE
            vfnacimi := '0000';
         END IF;

         -- Fin Bug 16732

         -- Bug 17005 - RSC - 15/12/2010
         IF psseguro IS NOT NULL THEN
            -- Fin Bug 17005
            BEGIN
               SELECT NVL(p.csitfam, 3), p.cnifcon, NVL(p.cgrado, 0), NVL(p.prolon, 0),
                      NVL(p.rmovgeo, 0), NVL(p.ipension, 0), NVL(p.ianuhijos, 0)
                 INTO vcsitfam, vnifconyuge, vgradoinval, vprolon,
                      vrmovgeo, vipension, vianuhijos
                 FROM per_irpf p, seguros s
                WHERE p.sperson = psperson
                  AND p.cagente = ff_agente_cpervisio(s.cagente)
                  AND s.sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  vcsitfam := 3;   -- Otras situaciones
                  vnifconyuge := NULL;
                  vgradoinval := 0;
                  vprolon := 0;
                  vrmovgeo := 0;
                  vipension := 0;
                  vianuhijos := 0;
            END;
         -- Bug 17005 - RSC - 15/12/2010
         ELSE
            BEGIN
               SELECT NVL(p.csitfam, 3), p.cnifcon, NVL(p.cgrado, 0), NVL(p.prolon, 0),
                      NVL(p.rmovgeo, 0), NVL(p.ipension, 0), NVL(p.ianuhijos, 0)
                 INTO vcsitfam, vnifconyuge, vgradoinval, vprolon,
                      vrmovgeo, vipension, vianuhijos
                 FROM per_irpf p
                WHERE p.sperson = psperson
                  AND p.cagente = vcagente;
            EXCEPTION
               WHEN OTHERS THEN
                  vcsitfam := 3;   -- Otras situaciones
                  vnifconyuge := NULL;
                  vgradoinval := 0;
                  vprolon := 0;
                  vrmovgeo := 0;
                  vipension := 0;
                  vianuhijos := 0;
            END;
         END IF;
      -- Fin Bug 17005
      EXCEPTION
         WHEN OTHERS THEN
            vcsitfam := 3;   -- Otras situaciones
            vnifconyuge := NULL;
            vgradoinval := 0;
            vprolon := 0;
            vrmovgeo := 0;
            vipension := 0;
            vianuhijos := 0;
      END;

      CASE pdato
         WHEN 'fnacimi' THEN   -- Siguente dia habil
            vresultado := vfnacimi;
         WHEN 'csitfam' THEN
            vresultado := LPAD(TO_CHAR(vcsitfam), 1, 0);
         WHEN 'nifconyuge' THEN
            vresultado := vnifconyuge;

            SELECT DECODE(vresultado,
                          NULL, LPAD(NVL(vresultado, ' '), 9, ' '),
                          LPAD(NVL(vresultado, '0'), 9, '0'))
              INTO vresultado
              FROM DUAL;
         WHEN 'gradoinval' THEN
            vresultado := LPAD(TO_CHAR(vgradoinval), 1, '0');
         WHEN 'prolon' THEN
            vresultado := LPAD(TO_CHAR(vprolon), 1, '0');
         WHEN 'rmovgeo' THEN
            vresultado := LPAD(TO_CHAR(vrmovgeo), 1, '0');
         WHEN 'ipension' THEN
            vresultado := LPAD(TO_CHAR(vipension), 13, '0');
         WHEN 'ianuhijos' THEN
            vresultado := LPAD(TO_CHAR(vianuhijos), 13, '0');
         ELSE
            vresultado := NULL;
      END CASE;

      RETURN vresultado;
   END f_datos_irpfpersonas;

   FUNCTION f_datos_irpfdescendientes(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pdato IN VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      vmenor         NUMBER := 0;
      vmenor_entero  NUMBER := 0;
      vresto         NUMBER := 0;
      vresto_entero  NUMBER := 0;
      vminusval_1    NUMBER := 0;
      vminusval_1_entero NUMBER := 0;
      vminusval_3    NUMBER := 0;
      vminusval_3_entero NUMBER := 0;
      vminusval_2    NUMBER := 0;
      vminusval_2_entero NUMBER := 0;
      vresultado     VARCHAR2(40);
   BEGIN
      -- Bug 17005 - RSC - 15/12/2010
      IF psseguro IS NOT NULL THEN
         -- Fin Bug 17005
         FOR regs2 IN (SELECT p.sperson, p.fnacimi, p.cgrado, p.center
                         FROM per_irpfdescen p, seguros s
                        WHERE p.sperson = psperson
                          AND s.sseguro = psseguro
                          AND p.cagente = ff_agente_cpervisio(s.cagente)) LOOP
            -- HIJOS Y OTROS DESCENDIENTES
            IF fedad(NULL, TO_NUMBER(TO_CHAR(regs2.fnacimi, 'yyyymmdd')),
                     TO_NUMBER(pany || '1231'), 1) < 3 THEN
               vmenor := vmenor + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vmenor_entero := vmenor_entero + 1;
               END IF;
            ELSE
               vresto := vresto + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vresto_entero := vresto_entero + 1;
               END IF;
            END IF;

            --  HIJOS Y OTROS DESCENDIENTES CON DISCAPACIDAD
            IF regs2.cgrado = 1 THEN   -- Valor fijo 688 (Igual o sup. 33% y inf. 65%)
               vminusval_1 := vminusval_1 + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vminusval_1_entero := vminusval_1_entero + 1;
               END IF;
            ELSIF regs2.cgrado = 3 THEN   -- Valor fijo 688 (>=33% <65% con Mov. Reducida)
               vminusval_3 := vminusval_3 + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vminusval_3_entero := vminusval_3_entero + 1;
               END IF;
            ELSIF regs2.cgrado = 2 THEN   -- Valor fijo 688 (Igual o superior al 65%)
               vminusval_2 := vminusval_2 + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vminusval_2_entero := vminusval_2_entero + 1;
               END IF;
            END IF;
         END LOOP;
      -- Bug 17005 - RSC - 15/12/2010
      ELSE
         FOR regs2 IN (SELECT p.sperson, p.fnacimi, p.cgrado, p.center
                         FROM per_irpfdescen p
                        WHERE p.sperson = psperson
                          AND p.cagente = pcagente) LOOP
            -- HIJOS Y OTROS DESCENDIENTES
            IF fedad(NULL, TO_NUMBER(TO_CHAR(regs2.fnacimi, 'yyyymmdd')),
                     TO_NUMBER(pany || '1231'), 1) < 3 THEN
               vmenor := vmenor + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vmenor_entero := vmenor_entero + 1;
               END IF;
            ELSE
               vresto := vresto + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vresto_entero := vresto_entero + 1;
               END IF;
            END IF;

            --  HIJOS Y OTROS DESCENDIENTES CON DISCAPACIDAD
            IF regs2.cgrado = 1 THEN   -- Valor fijo 688 (Igual o sup. 33% y inf. 65%)
               vminusval_1 := vminusval_1 + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vminusval_1_entero := vminusval_1_entero + 1;
               END IF;
            ELSIF regs2.cgrado = 3 THEN   -- Valor fijo 688 (>=33% <65% con Mov. Reducida)
               vminusval_3 := vminusval_3 + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vminusval_3_entero := vminusval_3_entero + 1;
               END IF;
            ELSIF regs2.cgrado = 2 THEN   -- Valor fijo 688 (Igual o superior al 65%)
               vminusval_2 := vminusval_2 + 1;

               IF NVL(regs2.center, 0) = 1 THEN
                  vminusval_2_entero := vminusval_2_entero + 1;
               END IF;
            END IF;
         END LOOP;
      END IF;

      -- Fin Bug 17005
      CASE pdato
         WHEN 'menor' THEN   -- Siguente dia habil
            vresultado := LPAD(TO_CHAR(vmenor), 1, '0');
         WHEN 'menor_entero' THEN
            vresultado := LPAD(TO_CHAR(vmenor_entero), 1, '0');
         WHEN 'resto' THEN
            vresultado := LPAD(TO_CHAR(vresto), 2, '0');
         WHEN 'resto_entero' THEN
            vresultado := LPAD(TO_CHAR(vresto_entero), 2, '0');
         WHEN 'minusval_1' THEN
            vresultado := LPAD(TO_CHAR(vminusval_1), 2, '0');
         WHEN 'minusval_1_entero' THEN
            vresultado := LPAD(TO_CHAR(vminusval_1_entero), 2, '0');
         WHEN 'minusval_3' THEN
            vresultado := LPAD(TO_CHAR(vminusval_3), 2, '0');
         WHEN 'minusval_3_entero' THEN
            vresultado := LPAD(TO_CHAR(vminusval_3_entero), 2, '0');
         WHEN 'minusval_2' THEN
            vresultado := LPAD(TO_CHAR(vminusval_2), 2, '0');
         WHEN 'minusval_2_entero' THEN
            vresultado := LPAD(TO_CHAR(vminusval_2_entero), 2, '0');
         ELSE
            vresultado := NULL;
      END CASE;

      RETURN vresultado;
   END f_datos_irpfdescendientes;

   FUNCTION f_datos_irpfmayores(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pdato IN VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      vmenor75       NUMBER := 0;
      vmenor75_entero NUMBER := 0;
      vmayor75       NUMBER := 0;
      vmayor75_entero NUMBER := 0;
      vminusmayor_1  NUMBER := 0;
      vminusmayor_1_entero NUMBER := 0;
      vminusmayor_2  NUMBER := 0;
      vminusmayor_2_entero NUMBER := 0;
      vminusmayor_3  NUMBER := 0;
      vminusmayor_3_entero NUMBER := 0;
      vresultado     VARCHAR2(40);
   BEGIN
      -- Bug 17005 - RSC - 15/12/2010
      IF psseguro IS NOT NULL THEN
         -- Fin Bug 17005
         FOR regs3 IN (SELECT p.sperson, p.fnacimi, p.cgrado, p.crenta, p.nviven
                         FROM per_irpfmayores p, seguros s
                        WHERE p.sperson = psperson
                          AND s.sseguro = psseguro
                          AND p.cagente = ff_agente_cpervisio(s.cagente)) LOOP
            -- ASCENDIENTES
            IF fedad(NULL, TO_NUMBER(TO_CHAR(regs3.fnacimi, 'yyyymmdd')),
                     TO_NUMBER(pany || '1231'), 1) < 75 THEN
               vmenor75 := vmenor75 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vmenor75_entero := vmenor75_entero + 1;
               END IF;
            ELSIF fedad(NULL, TO_NUMBER(TO_CHAR(regs3.fnacimi, 'yyyymmdd')),
                        TO_NUMBER(pany || '1231'), 1) >= 75 THEN
               vmayor75 := vmayor75 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vmayor75_entero := vmayor75_entero + 1;
               END IF;
            END IF;

            --   ASCENDIENTES CON DISCAPACIDAD
            IF regs3.cgrado = 1 THEN   -- Valor fijo 688 (Igual o sup. 33% y inf. 65%)
               vminusmayor_1 := vminusmayor_1 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vminusmayor_1_entero := vminusmayor_1_entero + 1;
               END IF;
            ELSIF regs3.cgrado = 3 THEN   -- Valor fijo 688 (>=33% <65% con Mov. Reducida)
               vminusmayor_3 := vminusmayor_3 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vminusmayor_3_entero := vminusmayor_3_entero + 1;
               END IF;
            ELSIF regs3.cgrado = 2 THEN   -- Valor fijo 688 (Igual o superior al 65%)
               vminusmayor_2 := vminusmayor_2 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vminusmayor_2_entero := vminusmayor_2_entero + 1;
               END IF;
            END IF;
         END LOOP;
      -- Bug 17005 - RSC - 15/12/2010
      ELSE
         FOR regs3 IN (SELECT p.sperson, p.fnacimi, p.cgrado, p.crenta, p.nviven
                         FROM per_irpfmayores p
                        WHERE p.sperson = psperson
                          AND p.cagente = pcagente) LOOP
            -- ASCENDIENTES
            IF fedad(NULL, TO_NUMBER(TO_CHAR(regs3.fnacimi, 'yyyymmdd')),
                     TO_NUMBER(pany || '1231'), 1) < 75 THEN
               vmenor75 := vmenor75 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vmenor75_entero := vmenor75_entero + 1;
               END IF;
            ELSIF fedad(NULL, TO_NUMBER(TO_CHAR(regs3.fnacimi, 'yyyymmdd')),
                        TO_NUMBER(pany || '1231'), 1) >= 75 THEN
               vmayor75 := vmayor75 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vmayor75_entero := vmayor75_entero + 1;
               END IF;
            END IF;

            --   ASCENDIENTES CON DISCAPACIDAD
            IF regs3.cgrado = 1 THEN   -- Valor fijo 688 (Igual o sup. 33% y inf. 65%)
               vminusmayor_1 := vminusmayor_1 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vminusmayor_1_entero := vminusmayor_1_entero + 1;
               END IF;
            ELSIF regs3.cgrado = 3 THEN   -- Valor fijo 688 (>=33% <65% con Mov. Reducida)
               vminusmayor_3 := vminusmayor_3 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vminusmayor_3_entero := vminusmayor_3_entero + 1;
               END IF;
            ELSIF regs3.cgrado = 2 THEN   -- Valor fijo 688 (Igual o superior al 65%)
               vminusmayor_2 := vminusmayor_2 + 1;

               IF regs3.nviven IS NULL
                  OR regs3.nviven = 0 THEN
                  vminusmayor_2_entero := vminusmayor_2_entero + 1;
               END IF;
            END IF;
         END LOOP;
      END IF;

      -- Fin bug 17005
      CASE pdato
         WHEN 'menor75' THEN   -- Siguente dia habil
            vresultado := LPAD(TO_CHAR(vmenor75), 1, '0');
         WHEN 'menor75_entero' THEN
            vresultado := LPAD(TO_CHAR(vmenor75_entero), 1, '0');
         WHEN 'mayor75' THEN
            vresultado := LPAD(TO_CHAR(vmayor75), 1, '0');
         WHEN 'mayor75_entero' THEN
            vresultado := LPAD(TO_CHAR(vmayor75_entero), 1, '0');
         WHEN 'minusmayor_1' THEN
            vresultado := LPAD(TO_CHAR(vminusmayor_1), 1, '0');
         WHEN 'minusmayor_1_entero' THEN
            vresultado := LPAD(TO_CHAR(vminusmayor_1_entero), 1, '0');
         WHEN 'minusmayor_3' THEN
            vresultado := LPAD(TO_CHAR(vminusmayor_3), 1, '0');
         WHEN 'minusmayor_3_entero' THEN
            vresultado := LPAD(TO_CHAR(vminusmayor_3_entero), 1, '0');
         WHEN 'minusmayor_2' THEN
            vresultado := LPAD(TO_CHAR(vminusmayor_2), 1, '0');
         WHEN 'minusmayor_2_entero' THEN
            vresultado := LPAD(TO_CHAR(vminusmayor_2_entero), 1, '0');
         ELSE
            vresultado := NULL;
      END CASE;

      RETURN vresultado;
   END f_datos_irpfmayores;

   FUNCTION f_global_irpfpersonas(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      preducciones IN VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_modelos_fiscales.f_datos_irpfpersonas(psperson, psseguro, pany, 'fnacimi',
                                                       pcagente)
             ||   -- Año de nacimiento del perceptor
               pac_modelos_fiscales.f_datos_irpfpersonas(psperson, psseguro, pany, 'csitfam',
                                                         pcagente)
             ||   -- Situación familiar
               pac_modelos_fiscales.f_datos_irpfpersonas(psperson, psseguro, pany,
                                                         'nifconyuge', pcagente)
             ||   -- NIF del conyuge
               pac_modelos_fiscales.f_datos_irpfpersonas(psperson, psseguro, pany,
                                                         'gradoinval', pcagente)
             ||   -- Grado de invalidez
               LPAD('0', 1, '0')
             ||   -- Contrato ("del trabajador") o relación (solo para clave A)
               pac_modelos_fiscales.f_datos_irpfpersonas(psperson, psseguro, pany, 'prolon',
                                                         pcagente)
             ||   -- PROLONGACIÓN ACTIVIDAD LABORAL (solo para clave A)
               pac_modelos_fiscales.f_datos_irpfpersonas(psperson, psseguro, pany, 'rmovgeo',
                                                         pcagente)
             ||   -- MOVILIDAD GEOGRÁFICA (solo para clave A)
               preducciones ||
                              -- REDUCCIONES APLICABLES (de momento vamos a poner ceros aqui)
                              LPAD('0', 13, '0')
             ||   -- GASTOS DEDUCIBLES
               pac_modelos_fiscales.f_datos_irpfpersonas(psperson, psseguro, pany, 'ipension',
                                                         pcagente)
             ||   -- PENSIONES COMPENSATORIAS
               pac_modelos_fiscales.f_datos_irpfpersonas(psperson, psseguro, pany, 'ianuhijos',
                                                         pcagente));   -- ANUALIDADES POR ALIMENTOS
   END f_global_irpfpersonas;

   FUNCTION f_global_irpfdescendientes(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany, 'menor',
                                                            pcagente)
             ||   -- Numero de hijos < 3 años
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'menor_entero', pcagente)
             ||   -- Numero de hijos < 3 años por entero
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'resto', pcagente)
             ||   -- Numero de hijos >= 3 años
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'resto_entero', pcagente)
             ||   -- Numero de hijos >= 3 años por entero
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'minusval_1', pcagente)
             ||   -- Numero de minusvalidos (Igual o sup. 33% y inf. 65%)
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'minusval_1_entero', pcagente)
             ||
               -- Numero de minusvalidos por entero (Igual o sup. 33% y inf. 65%)
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'minusval_3', pcagente)
             ||   -- Numero de minusvalidos (>=33% <65% con Mov. Reducida)
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'minusval_3_entero', pcagente)
             ||
               -- Numero de minusvalidos por entero (>=33% <65% con Mov. Reducida)
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'minusval_2', pcagente)
             ||   -- Numero de minusvalidos (Igual o superior al 65%)
               pac_modelos_fiscales.f_datos_irpfdescendientes(psperson, psseguro, pany,
                                                              'minusval_2_entero', pcagente));   -- Numero de minusvalidos por entero (Igual o superior al 65%)
   END f_global_irpfdescendientes;

   FUNCTION f_global_irpfmayores(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN(pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany, 'menor75',
                                                      pcagente)
             ||   -- Ascendientes menores de 75 años
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany,
                                                        'menor75_entero', pcagente)
             ||   -- Ascendientes menores de 75 años por entero
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany, 'mayor75',
                                                        pcagente)
             ||   -- Ascendientes mayores de 75 años
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany,
                                                        'mayor75_entero', pcagente)
             ||   -- Ascendientes mayores de 75 años por entero
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany,
                                                        'minusmayor_1', pcagente)
             ||   -- Ascendientes minusvalidos (Igual o sup. 33% y inf. 65%)
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany,
                                                        'minusmayor_1_entero', pcagente)
             ||
               -- Ascendientes minusvalidos (Igual o sup. 33% y inf. 65%) por entero
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany,
                                                        'minusmayor_3', pcagente)
             ||   -- Ascendientes minusvalidos (>=33% <65% con Mov. Reducida)
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany,
                                                        'minusmayor_3_entero', pcagente)
             ||
               -- Ascendientes minusvalidos (>=33% <65% con Mov. Reducida) por entero
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany,
                                                        'minusmayor_2', pcagente)
             ||   -- Ascendientes minusvalidos (Igual o superior al 65%)
               pac_modelos_fiscales.f_datos_irpfmayores(psperson, psseguro, pany,
                                                        'minusmayor_2_entero', pcagente));
   END f_global_irpfmayores;

   FUNCTION f_modelos_aho_rentas(
      pmodelo IN VARCHAR2,
      pany IN NUMBER,
      pcempres IN NUMBER,
      pcsoporte IN VARCHAR2)
      RETURN NUMBER IS
      /**************************************************************************
          Generación de los modelos de FISCALIDAD para los productos de Ahorro,
          Rentas y Unit Linked.

          Los modelos a declarar son:
              - modelo 190 – prestaciones PPA
              - modelo 188 - prestaciones (rescates/vencimientos/rentas/siniestros invalidez)
                            de todos los productos ahorro, rentas, unit linked y riesgo
              - modelo 347 - operaciones con terceros
              - modelo 345 - Aportaciones PPA / PIAS
              - modelo 296 - rescates/vencimientos Euroterm 16 (IRPF no residentes)

         -- RSC 26/11/2008
      **************************************************************************/
      lpath          VARCHAR2(100);
      fitxer         UTL_FILE.file_type;
   BEGIN
      lpath := f_parinstalacion_t('PATH_FASES');
      fitxer := UTL_FILE.fopen(lpath,
                               'Modelo_Aho_Ren_' || pmodelo || '-' || TO_CHAR(pany) || '.txt',
                               'w');

      IF pmodelo = '188' THEN
         /********************************************************************
             Prestaciones (rescates/vencimientos/rentas/siniestros invalidez)
             de todos los productos ahorro, rentas, unit linked y riesgo
             (Excluimos PPA)
          *********************************************************************/
         p_modelos_aho_rentas188(pmodelo, pany, pcempres, pcsoporte, fitxer);
      ELSIF pmodelo = '347' THEN
         /*****************************
            Operaciones con terceros
         ******************************/
         p_modelos_aho_rentas347(pmodelo, pany, pcempres, pcsoporte, fitxer);
      ELSIF pmodelo = '345' THEN
         /*******************************************************
            Operaciones con terceros de aportaciones PPA + PIAS
         ********************************************************/
         p_modelos_aho_rentas345(pmodelo, pany, pcempres, pcsoporte, fitxer);
      ELSIF pmodelo = '296' THEN
         /********************************************************
           Rescates/Vencimientos Euroterm 16 (IRPF no residentes)
         ********************************************************/
         p_modelos_aho_rentas296(pmodelo, pany, pcempres, pcsoporte, fitxer);
      ELSIF pmodelo = '190' THEN
         /*****************************************
               PPA (Igual que 188 pero solo PPA)
         ******************************************/
         p_modelos_aho_rentas190(pmodelo, pany, pcempres, pcsoporte, fitxer);
      END IF;

      UTL_FILE.fclose(fitxer);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Generación fichero modelo ' || pmodelo, NULL,
                     'Error en la generación del fichero modelo ' || pmodelo, SQLERRM);
         RETURN 1;
   END f_modelos_aho_rentas;

   /*INI-->BUG 16875 - 30/11/2010 - 00016875: 2010: Modelos 190 - 111  Se aÃ±aden nuevas funciones*/
   FUNCTION f_datos_irpfdescen_hijo(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnorden IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_center       per_irpfdescen.center%TYPE;
   BEGIN
      BEGIN
         -- Bug 17005 - RSC - 15/12/2010
         IF psseguro IS NOT NULL THEN
            -- Fin bug 17005
            SELECT NVL(p.center, 2)
              INTO v_center
              FROM per_irpfdescen p, seguros s
             WHERE p.sperson = psperson
               AND s.sseguro = psseguro
               AND p.norden = pnorden
               AND p.cagente = ff_agente_cpervisio(s.cagente);
         -- Bug 17005 - RSC - 15/12/2010
         ELSE
            SELECT NVL(p.center, 2)
              INTO v_center
              FROM per_irpfdescen p
             WHERE p.sperson = psperson
               AND p.norden = pnorden
               AND p.cagente = ff_agente_cpervisio(pcagente);
         END IF;
      -- Fin Bug 17005
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
      END;

      IF v_center = 1 THEN
         RETURN 1;
      ELSIF v_center = 0 THEN
         RETURN 2;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_modelos_fiscales.f_datos_irpfdescen_hijo', NULL,
                     'Error en f_datos_irpfdescen_hijo ' || psperson || ' psseguro: '
                     || psseguro || ' pnorden: ' || pnorden,
                     SQLERRM);
         RETURN 0;
   END f_datos_irpfdescen_hijo;

/*FIN-->BUG 16875 - 30/11/2010 - 00016875: 2010: Modelos 190 - 111  Se aÃ±aden nuevas funciones*/

   -- Bug 22996 - APD - 25/07/2012 - se crea la funcion
/******************************************************************************
--FUNCTION f_modelo_7_primas
--retorna la select del Modelo fiscal 7: Control de la provision para prestaciones - Primas

   PARAM
    1.   pfini. Fecha inicio del periodo. Obligatorio.
    2.   pffin. Fecha fin del periodo. Obligatorio.
    3.   pcempres. Identificador de la empresa. Obligatorio.
     RETORNA
     VARCHAR2 CON LA SELECT

******************************************************************************/
   FUNCTION f_modelo_7_primas(pfini IN DATE, pffin IN DATE, pcempres IN NUMBER)
      RETURN VARCHAR2 IS
      vobject        VARCHAR2(500) := 'pac_modelos_fiscales.f_modelo_7_primas';
      vparam         VARCHAR2(4000)
                        := 'pfini=' || pfini || ' pffin=' || pffin || ' pcempres=' || pcempres;
      vpasexec       NUMBER(5) := 1;
      --vnumerr                       NUMBER(8) := 0;
      vsquery        VARCHAR2(4000) := NULL;
      --vlinea                        VARCHAR2(32000);

      -- Bug 25870 - 18-VI-2013 - dlF - AGM900 - Nuevo producto sobreprecio 2013
      vcramo         seguros.cramo%TYPE;
      vtramo         ramos.tramo%TYPE;
      vtproducto     titulopro.ttitulo%TYPE;   --definicion errornea de la variable
      -- fin Bug 25870 - 18-VI-2013 - dlF -
      vprimas_devengadas NUMBER;
      vprimas_anuladas NUMBER;
      vprimas_anuladas_ant NUMBER;
      vprovision_inicial NUMBER;
      vprovision_final NUMBER;
      vpolizas_inicio NUMBER;
      vpolizas_emitidas NUMBER;
      vpolizas_anuladas NUMBER;
      vpolizas_cierre NUMBER;

      CURSOR c_primas IS
         (SELECT   x.ramo cramo, ff_desramo(x.ramo, f_usu_idioma) tramo,
                   f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 1,
                                   f_usu_idioma) tproducto,
                   SUM(primas_devengadas) primas_devengadas,
                   SUM(primas_anuladas) primas_anuladas,
                   SUM(primas_anuladas_ant) primas_anuladas_ant,
                   SUM(provision_inicial) provision_inicial,
                   SUM(provision_final) provision_final, SUM(polizas_inicio) polizas_inicio,
                   SUM(polizas_emitidas) polizas_emitidas,
                   SUM(polizas_anuladas) polizas_anuladas, SUM(polizas_cierre) polizas_cierre
              FROM (
                    -- Primas devengadas del periodo-------------------------------------------------------------------
                    (SELECT   ramo, producto, SUM(primas_devengadas) primas_devengadas,
                              0 primas_anuladas, 0 primas_anuladas_ant, 0 provision_inicial,
                              0 provision_final, 0 polizas_inicio, 0 polizas_emitidas,
                              0 polizas_anuladas, 0 polizas_cierre
                         FROM (   -- Primas por recibo emision( NO EXTORNOS) del perido -----------------------------------
                               SELECT   h.cramo ramo, h.sproduc producto,
                                        SUM(NVL(prima_deven, 0)) primas_devengadas
                                   FROM his_cuadre02 h, seguros s
                                  WHERE s.sseguro = h.sseguro
                                    AND s.cempres = pcempres
                                    AND h.fconta BETWEEN pfini AND pffin
                               GROUP BY h.cramo, h.sproduc, nrecibo
                                 HAVING SUM(NVL(prima_deven, 0)) > 0
                               UNION ALL
                               -- ANULACION de Primas por recibo de extorno emitidos en el perido ---------------------
                               SELECT   h.cramo ramo, h.sproduc producto,

                                        --h.prima_deven primas_anuladas
                                        ABS(SUM(NVL(h.prima_deven, 0)))
                                   FROM his_cuadre06 h, seguros s
                                  WHERE s.cempres = pcempres
                                    AND s.sseguro = h.sseguro
                                    AND h.fconta BETWEEN pfini AND pffin
                                    AND h.fefecto >= pfini
                               GROUP BY h.cramo, h.sproduc, nrecibo
                                 HAVING SUM(NVL(h.prima_deven, 0)) < 0
                               UNION ALL
                               -- ANULACION de Primas por recibo de extorno emitidos en perido anterior ----------------
                               SELECT   h.cramo ramo, h.sproduc producto,

                                        --h.prima_deven primas_anuladas
                                        ABS(SUM(NVL(h.prima_deven, 0)))
                                   FROM his_cuadre005 h, seguros s
                                  WHERE s.cempres = pcempres
                                    AND s.sseguro = h.sseguro
                                    AND h.fconta BETWEEN pfini AND pffin
                                    AND h.fefecto < pfini
                               GROUP BY h.cramo, h.sproduc, nrecibo
                                 HAVING SUM(NVL(h.prima_deven, 0)) < 0)
                     GROUP BY ramo, producto)
                    UNION

                    -- Primas anuladas del periodo-------------------------------------------------------------------
                    (SELECT   ramo, producto, 0 primas_devengadas,
                              SUM(NVL(primas_anuladas, 0)) primas_anuladas,
                              0 primas_anuladas_ant, 0 provision_inicial, 0 provision_final,
                              0 polizas_inicio, 0 polizas_emitidas, 0 polizas_anuladas,
                              0 polizas_cierre
                         FROM (   -- Primas por recibo de EXTORNOS del perido ------------------------------------------
                               SELECT   h.cramo ramo, h.sproduc producto,
                                        ABS(SUM(NVL(h.prima_deven, 0))) primas_anuladas
                                   FROM his_cuadre02 h, seguros s
                                  WHERE s.cempres = pcempres
                                    AND s.sseguro = h.sseguro
                                    AND h.fconta BETWEEN pfini AND pffin
                               GROUP BY h.cramo, h.sproduc, nrecibo
                                 HAVING SUM(NVL(h.prima_deven, 0)) < 0
                               UNION ALL
                               -- ANULACION de Primas por recibo emitidos en el periodo -----------------------------
                               SELECT   h.cramo ramo, h.sproduc producto,

                                        --h.prima_deven primas_anuladas
                                        SUM(NVL(h.prima_deven, 0))
                                   FROM his_cuadre06 h, seguros s
                                  WHERE s.cempres = pcempres
                                    AND s.sseguro = h.sseguro
                                    AND h.fconta BETWEEN pfini AND pffin
                                    AND h.fefecto >= pfini
                               GROUP BY h.cramo, h.sproduc, nrecibo
                                 HAVING SUM(NVL(h.prima_deven, 0)) > 0)
                     GROUP BY ramo, producto)
                    UNION

                    -- Primas anuladas de periodos anteriores--------------------------------------------------------
                    (SELECT   ramo, producto, 0 primas_devengadas, 0 primas_anuladas,
                              SUM(NVL(primas_anuladas_ant, 0)) primas_anuladas_ant,
                              0 provision_inicial, 0 provision_final, 0 polizas_inicio,
                              0 polizas_emitidas, 0 polizas_anuladas, 0 polizas_cierre
                         FROM (
                               -- ANULACION de Primas por recibo emitidos en perido anterior ------------------------
                               SELECT   h.cramo ramo, h.sproduc producto,

                                        --h.prima_deven primas_anuladas
                                        SUM(NVL(h.prima_deven, 0)) primas_anuladas_ant
                                   FROM his_cuadre005 h, seguros s
                                  WHERE s.cempres = pcempres
                                    AND s.sseguro = h.sseguro
                                    AND h.fconta BETWEEN pfini AND pffin
                                    AND h.fefecto < pfini
                               GROUP BY h.cramo, h.sproduc, nrecibo
                                 HAVING SUM(NVL(h.prima_deven, 0)) > 0
                               UNION ALL
                               -- ANULACION de Primas por recibo emitidos en el periodo anterior --------------------
                               SELECT   h.cramo ramo, h.sproduc producto,

                                        --h.prima_deven primas_anuladas
                                        SUM(NVL(h.prima_deven, 0)) primas_anuladas_ant
                                   FROM his_cuadre06 h, seguros s
                                  WHERE s.cempres = pcempres
                                    AND s.sseguro = h.sseguro
                                    AND h.fconta BETWEEN pfini AND pffin
                                    AND h.fefecto < pfini
                               GROUP BY h.cramo, h.sproduc, nrecibo
                                 HAVING SUM(NVL(h.prima_deven, 0)) > 0)
                     GROUP BY ramo, producto)
                    UNION

                    -- Provision final (PPNC al cierre del periodo)--------------------------------------------------
                    (SELECT   p.cramo ramo, p.sproduc producto, 0 primas_devengadas,
                              0 primas_anuladas, 0 primas_anuladas_ant, 0 provision_inicial,
                              SUM(NVL(p.iprincs, 0)) provision_final, 0 polizas_inicio,
                              0 polizas_emitidas, 0 polizas_anuladas, 0 polizas_cierre
                         FROM ppnc p
                        WHERE p.cempres = pcempres
                          AND p.fcalcul = (SELECT MAX(p1.fcalcul)
                                             FROM ppnc p1
                                            WHERE p1.cempres = p.cempres
                                              AND p1.fcalcul <= pffin)
                     GROUP BY p.cramo, p.sproduc)
                    UNION

                    -- Nº de Polizas al inicio del periodo-----------------------------------------------------------
                    (SELECT   s.cramo ramo, s.sproduc producto, 0 primas_devengadas,
                              0 primas_anuladas, 0 primas_anuladas_ant, 0 provision_inicial,
                              0 provision_final, COUNT(s.sseguro) polizas_inicio,
                              0 polizas_emitidas, 0 polizas_anuladas, 0 polizas_cierre
                         FROM seguros s
                        WHERE s.cempres = pcempres
                          AND(f_situacion_v(s.sseguro, pfini - 1) = 1
                              OR(f_situacion_v(s.sseguro, pfini - 1) = 3
                                 AND s.csituac = 0))
                     GROUP BY s.cramo, s.sproduc)
                    UNION

                    -- Nº de Polizas emitidas en el periodo----------------------------------------------------------
                    (SELECT   s.cramo ramo, s.sproduc producto, 0 primas_devengadas,
                              0 primas_anuladas, 0 primas_anuladas_ant, 0 provision_inicial,
                              0 provision_final, 0 polizas_inicio,
                              COUNT(s.sseguro) polizas_emitidas, 0 polizas_anuladas,
                              0 polizas_cierre
                         FROM seguros s, movseguro m
                        WHERE s.cempres = pcempres
                          AND s.sseguro = m.sseguro
                          AND m.nmovimi = (SELECT MAX(m2.nmovimi)
                                             FROM movseguro m2
                                            WHERE m.sseguro = m2.sseguro
                                              AND m2.cmovseg = 0
                                              AND GREATEST(TRUNC(m2.femisio),
                                                           TRUNC(m2.fefecto)) >= pfini
                                              AND GREATEST(TRUNC(m2.femisio),
                                                           TRUNC(m2.fefecto)) <= pffin)
                     GROUP BY s.cramo, s.sproduc)
                    UNION

                    -- Nº de Polizas anuladas en el periodo----------------------------------------------------------
                    (SELECT   s.cramo ramo, s.sproduc producto, 0 primas_devengadas,
                              0 primas_anuladas, 0 primas_anuladas_ant, 0 provision_inicial,
                              0 provision_final, 0 polizas_inicio, 0 polizas_emitidas,
                              COUNT(s.sseguro) polizas_anuladas, 0 polizas_cierre
                         FROM seguros s, movseguro m
                        WHERE s.cempres = pcempres
                          AND s.sseguro = m.sseguro
                          AND m.nmovimi = (SELECT MAX(m2.nmovimi)
                                             FROM movseguro m2
                                            WHERE m.sseguro = m2.sseguro
                                              AND GREATEST(TRUNC(m2.femisio),
                                                           TRUNC(m2.fefecto)) >= pfini
                                              AND GREATEST(TRUNC(m2.femisio),
                                                           TRUNC(m2.fefecto)) <= pffin)
                          AND s.csituac != 4
                          AND m.cmovseg = 3
                     GROUP BY s.cramo, s.sproduc)
                    UNION

                    -- Nº de Polizas al final del periodo------------------------------------------------------------
                    (SELECT   s.cramo ramo, s.sproduc producto, 0 primas_devengadas,
                              0 primas_anuladas, 0 primas_anuladas_ant, 0 provision_inicial,
                              0 provision_final, 0 polizas_inicio, 0 polizas_emitidas,
                              0 polizas_anuladas, COUNT(s.sseguro) polizas_cierre
                         FROM seguros s
                        WHERE s.cempres = pcempres
                          AND(f_situacion_v(s.sseguro, pffin) = 1
                              OR(f_situacion_v(s.sseguro, pffin) = 3
                                 AND s.csituac = 0))
                     GROUP BY s.cramo, s.sproduc)) x,
                   codiram c,
                   productos p
             WHERE c.cempres = pcempres
               AND c.cramo = p.cramo
               AND c.cramo = x.ramo
               AND p.sproduc = x.producto
          GROUP BY x.ramo, p.cramo, p.cmodali, p.ctipseg, p.ccolect);
   BEGIN
      -- comprobar campos obligatorios
      IF pfini IS NULL
         OR pffin IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      OPEN c_primas;

      vpasexec := 3;

      LOOP
         FETCH c_primas
          INTO vcramo, vtramo, vtproducto, vprimas_devengadas, vprimas_anuladas,
               vprimas_anuladas_ant, vprovision_inicial, vprovision_final, vpolizas_inicio,
               vpolizas_emitidas, vpolizas_anuladas, vpolizas_cierre;

         EXIT WHEN c_primas%NOTFOUND;

         IF vsquery IS NULL THEN
            vsquery := 'SELECT ' || vcramo || ', ' || CHR(39) || vtramo || CHR(39) || ', '
                       || CHR(39) || vtproducto || CHR(39) || ', ' || 'to_number('''
                       || vprimas_devengadas || ''')' || ', ' || 'to_number('''
                       || vprimas_anuladas || ''')' || ', ' || 'to_number('''
                       || vprimas_anuladas_ant || ''')' || ', ' || 'to_number('''
                       || vprovision_inicial || ''')' || ', ' || 'to_number('''
                       || vprovision_final || ''')' || ', ' || vpolizas_inicio || ', '
                       || vpolizas_emitidas || ', ' || vpolizas_anuladas || ', '
                       || vpolizas_cierre || ' from dual';
         ELSE
            vsquery := vsquery || ' UNION SELECT ' || vcramo || ', ' || CHR(39) || vtramo
                       || CHR(39) || ', ' || CHR(39) || vtproducto || CHR(39) || ', '
                       || 'to_number(''' || vprimas_devengadas || ''')' || ', '
                       || 'to_number(''' || vprimas_anuladas || ''')' || ', '
                       || 'to_number(''' || vprimas_anuladas_ant || ''')' || ', '
                       || 'to_number(''' || vprovision_inicial || ''')' || ', '
                       || 'to_number(''' || vprovision_final || ''')' || ', '
                       || vpolizas_inicio || ', ' || vpolizas_emitidas || ', '
                       || vpolizas_anuladas || ', ' || vpolizas_cierre || ' from dual';
         END IF;
      END LOOP;

      vpasexec := 4;

      CLOSE c_primas;

      IF vsquery IS NULL THEN
         vsquery := 'SELECT null from dual';
      END IF;

      vpasexec := 5;
      RETURN vsquery;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ');

         IF vsquery IS NULL THEN
            vsquery := 'SELECT null from dual';
         END IF;

         RETURN vsquery;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

         IF c_primas%ISOPEN THEN
            CLOSE c_primas;
         END IF;

         IF vsquery IS NULL THEN
            vsquery := 'SELECT null from dual';
         END IF;

         RETURN vsquery;
   END f_modelo_7_primas;

-- fin Bug 22996 - APD - 25/07/2012

   -- Bug 22996 - APD - 25/07/2012 - se crea la funcion
/******************************************************************************
--FUNCTION f_modelo_7_siniestros
--retorna la select del Modelo fiscal 7: Control de la provision para prestaciones - Siniestros

   PARAM
    1.   pfini. Fecha inicio del periodo. Obligatorio.
    2.   pffin. Fecha fin del periodo. Obligatorio.
    3.   pcempres. Identificador de la empresa. Obligatorio.
     RETORNA
     VARCHAR2 CON LA SELECT

******************************************************************************/
   FUNCTION f_modelo_7_siniestros(pfini IN DATE, pffin IN DATE, pcempres IN NUMBER)
      RETURN VARCHAR2 IS
      vobject        VARCHAR2(500) := 'pac_modelos_fiscales.f_modelo_7_siniestros';
      vparam         VARCHAR2(4000)
                        := 'pfini=' || pfini || ' pffin=' || pffin || ' pcempres=' || pcempres;
      vpasexec       NUMBER(5) := 1;
      --vnumerr                       NUMBER(8) := 0;
      vsquery        VARCHAR2(32000) := NULL;
      --vlinea                        VARCHAR2(32000);
      vcramo         seguros.cramo%TYPE;
      -- Bug 25870 - 18-VI-2013 - dlF - AGM900 - Nuevo producto sobreprecio 2013
      vtramo         ramos.tramo%TYPE;
      vtproducto     titulopro.ttitulo%TYPE;   --definicion errornea de la variable
      -- fin Bug 25870 - 18-VI-2013 - dlF -
      vnum_sin_pp    NUMBER := 0;
      vpagos_ini_sin_pp NUMBER := 0;
      vprov_ini_sin_pp NUMBER := 0;
      vpagos_fin_sin_pp NUMBER := 0;
      vprov_fin_sin_pp NUMBER := 0;
      vnum_sin_pc_con_pagos NUMBER := 0;
      vnum_sin_pc_sin_pagos NUMBER := 0;
      vpagos_ini_sin_pc NUMBER := 0;
      vprov_ini_sin_pc NUMBER := 0;
      vpagos_fin_sin_pc NUMBER := 0;
      vnum_sin_op    NUMBER := 0;
      vpagos_fin_sin_op NUMBER := 0;
      vprov_fin_sin_op NUMBER := 0;
      vnum_sin_oc_con_pagos NUMBER := 0;
      vnum_sin_oc_sin_pagos NUMBER := 0;
      vprov_ini_sin_oc NUMBER := 0;
      vpagos_fin_sin_oc NUMBER := 0;
      vnum_sin_op1   NUMBER := 0;
      vpagos_fin_sin_op1 NUMBER := 0;
      vprov_fin_sin_op1 NUMBER := 0;
      vnum_sin_oc1_con_pagos NUMBER := 0;
      vnum_sin_oc1_sin_pagos NUMBER := 0;
      vpagos_fin_sin_oc1 NUMBER := 0;
      vibnr_inicial  NUMBER := 0;
      vibnr_final    NUMBER := 0;

      CURSOR c_siniestros IS
         SELECT   x.ramo cramo, ff_desramo(x.ramo, 2) tramo,
                  f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 1, 2) tproducto,

                  --PROV. SINIESTROS PTES. CIERRE YYYY Y PTES. AL cierre nº trimestre YYYY----------------------------
                  SUM(num_sin_pp) num_sin_pp, SUM(pagos_ini_sin_pp) pagos_ini_sin_pp,
                  SUM(prov_ini_sin_pp) prov_ini_sin_pp, SUM(pagos_fin_sin_pp)
                                                                             pagos_fin_sin_pp,
                  SUM(prov_fin_sin_pp) prov_fin_sin_pp,

                  --SINIESTROS PTES AL CIERRE EJERCICIO Y TERMINADOS EN EL PERIODO------------------------------------
                  SUM(num_sin_pc_con_pagos) num_sin_pc_con_pagos,
                  SUM(num_sin_pc_sin_pagos) num_sin_pc_sin_pagos,
                  SUM(pagos_ini_sin_pc) pagos_ini_sin_pc, SUM(prov_ini_sin_pc)
                                                                              prov_ini_sin_pc,
                  SUM(pagos_fin_sin_pc) pagos_fin_sin_pc,
                                                         --OCURRIDOS EN EL PERIODO---------------------------------------------------------------------------
                                                         SUM(num_sin_op) num_sin_op,
                  SUM(pagos_fin_sin_op) pagos_fin_sin_op, SUM(prov_fin_sin_op)
                                                                              prov_fin_sin_op,
                  SUM(num_sin_oc_con_pagos) num_sin_oc_con_pagos,
                  SUM(num_sin_oc_sin_pagos) num_sin_oc_sin_pagos,
                  SUM(pagos_fin_sin_oc) pagos_fin_sin_oc,
--SINIESTROS PENDIENTES DE DECLARACIÓN / PENDIENTES A CIERRE PERIODO / TERMINADOS EN EL PERIODO-----
----------------------------------------------------------------------------------------------------
--AGM ha validado el listado y nos confirma que según BOE, estos valores no son calculados----------
--y que deben rellenarse a mano - BUG 28221: Errores DEC MOD 7 DGS ---------------------------------
/*
0                          prov_ini_sin_oc,
0                          num_sin_op1,
0                          pagos_fin_sin_op1,
0                          prov_fin_sin_op1,
0                          num_sin_oc1_con_pagos,
0                          num_sin_oc1_sin_pagos,
0                          pagos_fin_sin_oc1,
*/
--/*
                                                         SUM(prov_ini_sin_oc) prov_ini_sin_oc,
                  SUM(num_sin_op1) num_sin_op1, SUM(pagos_fin_sin_op1) pagos_fin_sin_op1,
                  SUM(prov_fin_sin_op1) prov_fin_sin_op1,
                  SUM(num_sin_oc1_con_pagos) num_sin_oc1_con_pagos,
                  SUM(num_sin_oc1_sin_pagos) num_sin_oc1_sin_pagos,
                  SUM(pagos_fin_sin_oc1) pagos_fin_sin_oc1,
                                                           --*/
                                                           SUM(ibnr_inicial) ibnr_inicial,
                  SUM(ibnr_final) ibnr_final
             FROM (
                   -- siniestros pendientes al comienzo del periodo y que continuan pendientes al cierre del periodo--
                   SELECT   s.cramo ramo, s.sproduc producto,
                                                             --PROV. SINIESTROS PTES. CIERRE YYYY Y PTES. AL cierre nº trimestre YYYY------------------
                                                             COUNT(sn.nsinies) num_sin_pp,
                            SUM(DECODE(stp1.ctippag,
                                       8, NVL(stp1.isinret, 0),
                                       2, NVL(stp1.isinret, 0),
                                       3, 0 - NVL(stp1.isinret, 0),
                                       7, 0 - NVL(stp1.isinret, 0),
                                       0)) pagos_ini_sin_pp,
                            SUM(NVL(p1.ipplpsd, 0)) prov_ini_sin_pp,
                            SUM(DECODE(stp2.ctippag,
                                       8, NVL(stp2.isinret, 0),
                                       2, NVL(stp2.isinret, 0),
                                       3, 0 - NVL(stp2.isinret, 0),
                                       7, 0 - NVL(stp2.isinret, 0),
                                       0)) pagos_fin_sin_pp,
                            SUM(NVL(p2.ipplpsd, 0)) prov_fin_sin_pp,
                                                                    --SINIESTROS PTES AL CIERRE EJERCICIO Y TERMINADOS EN EL PERIODO--------------------------
                            0 num_sin_pc_con_pagos, 0 num_sin_pc_sin_pagos, 0 pagos_ini_sin_pc,
                            0 prov_ini_sin_pc, 0 pagos_fin_sin_pc,
                                                                  --OCURRIDOS EN EL PERIODO-----------------------------------------------------------------
                            0 num_sin_op, 0 pagos_fin_sin_op, 0 prov_fin_sin_op,
                            0 num_sin_oc_con_pagos, 0 num_sin_oc_sin_pagos, 0 pagos_fin_sin_oc,

                            --SINIESTROS PENDIENTES DE DECLARACIÓN
                            --PENDIENTES A CIERRE PERIODO / TERMINADOS EN EL PERIODO----------------------------------
                            0 prov_ini_sin_oc, 0 num_sin_op1, 0 pagos_fin_sin_op1,
                            0 prov_fin_sin_op1, 0 num_sin_oc1_con_pagos,
                            0 num_sin_oc1_sin_pagos, 0 pagos_fin_sin_oc1, 0 ibnr_inicial,
                            0 ibnr_final
                       FROM seguros s,
                            sin_siniestro sn,
                            sin_movsiniestro sm,
                            (SELECT stp3.nsinies, stp3.isinret, stp3.ctippag
                               FROM sin_tramita_pago stp3, sin_tramita_movpago stmp3
                              WHERE stp3.sidepag = stmp3.sidepag
                                AND stmp3.nmovpag =
                                      (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = stmp3.sidepag
                                          AND TRUNC(fefepag) < pfini)
                                AND stp3.ctippag IN(2, 7)
                                AND stmp3.cestpag = 2) stp1,
                            (SELECT stp3.nsinies, stp3.isinret, stp3.ctippag
                               FROM sin_tramita_pago stp3, sin_tramita_movpago stmp3
                              WHERE stp3.sidepag = stmp3.sidepag
                                AND stmp3.nmovpag =
                                      (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = stmp3.sidepag
                                          AND TRUNC(fefepag) >= pfini
                                          AND TRUNC(fefepag) <= pffin)
                                AND stp3.ctippag IN(2, 7)
                                AND stmp3.cestpag = 2) stp2,
                            ptpplp p1,
                            ptpplp p2
                      WHERE sn.sseguro = s.sseguro
                        AND s.cempres = pcempres
                        AND sn.nsinies = sm.nsinies
                        AND sm.cestsin IN(0, 4)
                        AND sm.nmovsin = (SELECT MAX(nmovsin)
                                            FROM sin_movsiniestro sm2
                                           WHERE sm.nsinies = sm2.nsinies
                                             AND festsin <= pfini)
                        --Siniestros pendientes al inicio del año
                        AND EXISTS(SELECT '1'
                                     FROM sin_movsiniestro sm2
                                    WHERE sm.nsinies = sm2.nsinies
                                      AND sm2.cestsin IN(0, 4)
                                      AND sm2.nmovsin =
                                            (SELECT MAX(sm3.nmovsin)
                                               FROM sin_movsiniestro sm3
                                              WHERE sm2.nsinies = sm3.nsinies
                                                AND festsin <= pffin))
                        --siguen pendientes hasta pfecha
                        AND p1.fcalcul = (SELECT MAX(p.fcalcul)
                                            FROM ppnc p
                                           WHERE p.cempres = p1.cempres
                                             AND p.fcalcul <= pfini)
                        AND p1.cempres = s.cempres
                        AND p1.nsinies = sn.nsinies
                        AND p2.fcalcul = (SELECT MAX(p.fcalcul)
                                            FROM ppnc p
                                           WHERE p.cempres = p2.cempres
                                             AND p.fcalcul <= pffin)
                        AND p2.cempres = s.cempres
                        AND p2.nsinies = sn.nsinies
                        AND stp1.nsinies(+) = sn.nsinies
                        AND stp2.nsinies(+) = sn.nsinies
                   GROUP BY s.cramo, s.sproduc
                   UNION
                   --SINIESTROS PTES AL CIERRE EJERCICIO Y TERMINADOS EN EL PERIODO
                   -- siniestros pendientes al comienzo del periodo y que han sido cerrados al cierre del periodo
                   SELECT   ramo, producto,
                                           --PROV. SINIESTROS PTES. CIERRE YYYY Y PTES. AL cierre nº trimestre YYYY
                            0 num_sin_pp, 0 pagos_ini_sin_pp, 0 prov_ini_sin_pp,
                            0 pagos_fin_sin_pp, 0 prov_fin_sin_pp,

                            --SINIESTROS PTES AL CIERRE EJERCICIO Y TERMINADOS EN EL PERIODO----------------------------
                            SUM(num_sin_pc_con_pagos) num_sin_pc_con_pagos,
                            SUM(num_sin_pc_sin_pagos) num_sin_pc_sin_pagos,
                            SUM(pagos_ini_sin_pc) pagos_ini_sin_pc,
                            SUM(prov_ini_sin_pc) prov_ini_sin_pc,
                            SUM(pagos_fin_sin_pc) pagos_fin_sin_pc,
                                                                   --OCURRIDOS EN EL PERIODO-------------------------------------------------------------------
                            0 num_sin_op, 0 pagos_fin_sin_op, 0 prov_fin_sin_op,
                            0 num_sin_oc_con_pagos, 0 num_sin_oc_sin_pagos, 0 pagos_fin_sin_oc,

                            --SINIESTROS PENDIENTES DE DECLARACIÓN
                            --PENDIENTES A CIERRE PERIODO / TERMINADOS EN EL PERIODO------------------------------------
                            0 prov_ini_sin_oc, 0 num_sin_op1, 0 pagos_fin_sin_op1,
                            0 prov_fin_sin_op1, 0 num_sin_oc1_con_pagos,
                            0 num_sin_oc1_sin_pagos, 0 pagos_fin_sin_oc1, 0 ibnr_inicial,
                            0 ibnr_final
                       FROM (
                             --SE REALIZA DISTINCT, POR RAMO, PRODUCTO, POLIZA, SINIESTRO, PARA QUE NO SUME LOS REGISTROS DUPLICADOS, POR ANULACIONES
                             SELECT DISTINCT s.cramo ramo, s.sproduc producto,
                                             s.npoliza poliza, sn.nsinies siniestro,
                                             CASE
                                                WHEN CASE
                                                       WHEN stp2.ctippag IN
                                                                   (8, 2) THEN NVL
                                                                                 (stp2.isinret,
                                                                                  0)
                                                       WHEN stp1.ctippag IN
                                                                   (8, 2) THEN -NVL
                                                                                   (stp2.isinret,
                                                                                    0)
                                                       ELSE 0
                                                    END = 0 THEN 0
                                                ELSE 1
                                             END num_sin_pc_con_pagos,
                                             CASE
                                                WHEN CASE
                                                       WHEN stp2.ctippag IN
                                                                   (8, 2) THEN NVL
                                                                                 (stp2.isinret,
                                                                                  0)
                                                       WHEN stp1.ctippag IN
                                                                   (8, 2) THEN -NVL
                                                                                   (stp2.isinret,
                                                                                    0)
                                                       ELSE 0
                                                    END = 0 THEN 1
                                                ELSE 0
                                             END num_sin_pc_sin_pagos,
                                             CASE
                                                WHEN stp1.ctippag IN(8, 2) THEN NVL
                                                                                  (stp1.isinret,
                                                                                   0)
                                                WHEN stp1.ctippag IN(8, 2) THEN -NVL
                                                                                    (stp1.isinret,
                                                                                     0)
                                                ELSE 0
                                             END pagos_ini_sin_pc,

                                             --NVL(p1.ipplpsd, 0)                                   prov_ini_sin_pc,
                                             NVL
                                                ((SELECT NVL(ptp.ipplpsd, 0)
                                                    FROM ptpplp ptp
                                                   WHERE ptp.cempres =
                                                                      pcempres
                                                     AND ptp.nsinies = sn.nsinies
                                                     AND ptp.fcalcul =
                                                           LAST_DAY
                                                              (ADD_MONTHS
                                                                       (TRUNC(TRUNC(pffin,
                                                                                    'Year')
                                                                              - 1,
                                                                              'Year'),
                                                                        11))),
                                                 0) prov_ini_sin_pc,
                                             CASE
                                                WHEN stp2.ctippag IN(8, 2) THEN NVL
                                                                                  (stp2.isinret,
                                                                                   0)
                                                WHEN stp1.ctippag IN(8, 2) THEN -NVL
                                                                                    (stp2.isinret,
                                                                                     0)
                                                ELSE 0
                                             END pagos_fin_sin_pc
                                        FROM seguros s,
                                             sin_siniestro sn,
                                             sin_siniestro sn1,
                                             sin_movsiniestro sm,
                                             sin_movsiniestro sm1,

                                             --Sumatoria de PAGOS realizados en el PERIODO ANTERIOR de siniestros
                                             --pendientes en el PERIODO ANTERIOR y terminado en el PERIODO ACTUAL----------------
                                             (SELECT stp3.nsinies, stp3.isinret, stp3.ctippag
                                                FROM sin_tramita_pago stp3,
                                                     sin_tramita_movpago stmp3
                                               WHERE stp3.sidepag = stmp3.sidepag
                                                 AND stmp3.nmovpag =
                                                       (SELECT MAX(nmovpag)
                                                          FROM sin_tramita_movpago
                                                         WHERE sidepag = stmp3.sidepag
                                                           AND TRUNC(fefepag) < pfini)
                                                 AND stp3.ctippag IN(2, 7)
                                                 AND stmp3.cestpag = 2) stp1,

                                             --Sumatoria de PAGOS realizados en el PERIODO ACTUAL de siniestros
                                             --pendientes en el PERIODO ANTERIOR y terminado en el PERIODO ACTUAL----------------
                                             (SELECT stp3.nsinies, stp3.isinret, stp3.ctippag
                                                FROM sin_tramita_pago stp3,
                                                     sin_tramita_movpago stmp3
                                               WHERE stp3.sidepag = stmp3.sidepag
                                                 AND stmp3.nmovpag =
                                                       (SELECT MAX(nmovpag)
                                                          FROM sin_tramita_movpago
                                                         WHERE sidepag = stmp3.sidepag
                                                           AND TRUNC(fefepag) >= pfini
                                                           AND TRUNC(fefepag) <= pffin)
                                                 AND stp3.ctippag IN(2, 7)
                                                 AND stmp3.cestpag = 2) stp2   --,
                                       --ptpplp p1
                             WHERE           s.cempres = pcempres
                                         AND sn1.sseguro = s.sseguro
                                         --Siniestros pendientes al CIERRE del PERIODO ANTERIOR----------------------------------
                                         AND sn1.nsinies = sm1.nsinies
                                         AND sm1.cestsin IN(0, 4)
                                         AND sm1.nmovsin =
                                               (SELECT MAX(nmovsin)
                                                  FROM sin_movsiniestro sm2
                                                 WHERE sm1.nsinies = sm2.nsinies
                                                   AND festsin <= pfini)
                                         --Siniestros finalizados en el PERIODO -------------------------------------------------
                                         AND EXISTS(
                                               SELECT '1'
                                                 FROM sin_movsiniestro sm2
                                                WHERE sm2.nsinies = sm1.nsinies
                                                  AND sm2.cestsin IN(1, 2, 3)
                                                  AND sm2.nmovsin =
                                                        (SELECT MAX(sm3.nmovsin)
                                                           FROM sin_movsiniestro sm3
                                                          WHERE sm2.nsinies = sm3.nsinies
                                                            AND festsin <= pffin))
-----------------------------------------------------------------------------------------
                                         AND stp1.nsinies(+) = sn1.nsinies
                                         AND stp2.nsinies(+) = sn.nsinies
                                         --Siniestros pendientes al CIERRE del PERIODO ANTERIOR----------------------------------
                                         AND sn.sseguro = s.sseguro
                                         AND sn.nsinies = sm.nsinies
                                         AND sm.cestsin IN(0, 4)
                                         AND sm.nmovsin =
                                               (SELECT MAX(nmovsin)
                                                  FROM sin_movsiniestro sm2
                                                 WHERE sm.nsinies = sm2.nsinies
                                                   AND festsin <= pfini)
                                         --Siniestros finalizados en el PERIDO---------------------------------------------------
                                         AND EXISTS(
                                               SELECT '1'
                                                 FROM sin_movsiniestro sm2
                                                WHERE sm2.nsinies = sm.nsinies
                                                  AND sm2.cestsin IN(1, 2, 3)
                                                  AND sm2.nmovsin =
                                                        (SELECT MAX(sm3.nmovsin)
                                                           FROM sin_movsiniestro sm3
                                                          WHERE sm2.nsinies = sm3.nsinies
                                                            AND festsin <= pffin))
--Cerrado a pfecha----------------------------------------------------------------------
/*
AND p1.fcalcul = (SELECT MAX(p.fcalcul)
                    FROM ppnc p
                   WHERE p.cempres = p1.cempres
                     AND p.fcalcul <= pfini )
AND p1.cempres = s.cempres
AND p1.nsinies = sn1.nsinies
*/
                            )
                   GROUP BY ramo, producto
                   UNION
                   --OCURRIDOS EN EL PERIODO
                   -- siniestros ocurridos en el periodo y que continuan pendientes al cierre del periodo
                   SELECT   ramo, producto,
                                           --PROV. SINIESTROS PTES. CIERRE YYYY Y PTES. AL cierre nº trimestre YYYY
                            0 num_sin_pp, 0 pagos_ini_sin_pp, 0 prov_ini_sin_pp,
                            0 pagos_fin_sin_pp, 0 prov_fin_sin_pp,
                                                                  --SINIESTROS PTES AL CIERRE EJERCICIO Y TERMINADOS EN EL PERIODO----------------------------
                            0 num_sin_pc_con_pagos, 0 num_sin_pc_sin_pagos, 0 pagos_ini_sin_pc,
                            0 prov_ini_sin_pc, 0 pagos_fin_sin_pc,
                                                                  --OCURRIDOS EN EL PERIODO-------------------------------------------------------------------
                                                                  COUNT(num_sin_op) num_sin_op,
                            SUM(pagos_fin_sin_op) pagos_fin_sin_op,
                            SUM(prov_fin_sin_op) prov_fin_sin_op, 0 num_sin_oc_con_pagos,
                            0 num_sin_oc_sin_pagos, 0 pagos_fin_sin_oc,
                                                                       --SINIESTROS PENDIENTES DE DECLARACIÓN
                                                                       --PENDIENTES A CIERRE PERIODO / TERMINADOS EN EL PERIODO------------------------------------
                            0 prov_ini_sin_oc, 0 num_sin_op1, 0 pagos_fin_sin_op1,
                            0 prov_fin_sin_op1, 0 num_sin_oc1_con_pagos,
                            0 num_sin_oc1_sin_pagos, 0 pagos_fin_sin_oc1, 0 ibnr_inicial,
                            0 ibnr_final
                       FROM (SELECT s.cramo ramo, s.sproduc producto, sn.nsinies num_sin_op,
                                    CASE
                                       WHEN stp2.ctippag IN(8, 2) THEN NVL
                                                                         (stp2.isinret,
                                                                          0)
                                       WHEN stp2.ctippag IN(8, 2) THEN -NVL
                                                                           (stp2.isinret,
                                                                            0)
                                       ELSE 0
                                    END pagos_fin_sin_op,

                                    -- NVL(p2.ipplpsd, 0)                 prov_fin_sin_op
                                    NVL
                                       ((SELECT NVL(ptp.ipplpsd, 0)
                                           FROM ptpplp ptp
                                          WHERE ptp.cempres = pcempres
                                            AND ptp.nsinies = sn.nsinies
                                            AND ptp.fcalcul =
                                                  LAST_DAY(ADD_MONTHS(TRUNC(TRUNC(pffin,
                                                                                  'Year'),
                                                                            'Year'),
                                                                      11))),
                                        0) prov_fin_sin_op
                               FROM seguros s,
                                    sin_siniestro sn,
                                    sin_movsiniestro sm,
                                    (SELECT stp3.nsinies, stp3.isinret, stp3.ctippag
                                       FROM sin_tramita_pago stp3, sin_tramita_movpago stmp3
                                      WHERE stp3.sidepag = stmp3.sidepag
                                        AND stmp3.nmovpag =
                                              (SELECT MAX(nmovpag)
                                                 FROM sin_tramita_movpago
                                                WHERE sidepag = stmp3.sidepag
                                                  AND TRUNC(fefepag) BETWEEN pfini AND pffin)
                                        AND stp3.ctippag IN(2, 7)
                                        AND stmp3.cestpag = 2) stp2
                              --  ptpplp p2
                             WHERE  sn.sseguro = s.sseguro
                                AND s.cempres = pcempres
                                AND sn.nsinies = sm.nsinies
                                AND TRUNC(sn.fsinies) BETWEEN pfini AND pffin
                                --Siniestros ocurridos en el periodo----------------------------------------------------
                                AND sm.cestsin IN(0, 4)
                                AND sm.nmovsin = (SELECT MAX(nmovsin)
                                                    FROM sin_movsiniestro sm2
                                                   WHERE sm.nsinies = sm2.nsinies
                                                     AND festsin <= pffin)
                                  --Siniestros pendientes al cierre del periodo-----------------------------------------
                                --  AND p2.fcalcul = ( SELECT MAX(p.fcalcul)
                                 --                      FROM ppnc p
                                  --                    WHERE p.cempres = p2.cempres
                                 --                       AND p.fcalcul <= pffin
                                 --                  )
                                 -- AND p2.cempres = s.cempres
                                 -- AND p2.nsinies = sn.nsinies
                                AND stp2.nsinies(+) = sn.nsinies)
                   GROUP BY ramo, producto
                   UNION
                   -- siniestros ocurridos en el periodo y que han sido cerrados al cierre del periodo----------------
                   SELECT   ramo, producto,
--------------------------------------------------------------------------------------------
                            0 num_sin_pp, 0 pagos_ini_sin_pp, 0 prov_ini_sin_pp,
                            0 pagos_fin_sin_pp, 0 prov_fin_sin_pp,
--------------------------------------------------------------------------------------------
                            0 num_sin_pc_con_pagos, 0 num_sin_pc_sin_pagos, 0 pagos_ini_sin_pc,
                            0 prov_ini_sin_pc, 0 pagos_fin_sin_pc,
--------------------------------------------------------------------------------------------
                            0 num_sin_op, 0 pagos_fin_sin_op, 0 prov_fin_sin_op,
                            SUM(CASE
                                   WHEN num_sin_oc_con_pagos >= 1 THEN 1
                                   ELSE 0
                                END) num_sin_oc_con_pagos,
                            SUM(CASE
                                   WHEN num_sin_oc_sin_pagos >= 1 THEN 1
                                   ELSE 0
                                END) num_sin_oc_sin_pagos,
                            SUM(pagos_fin_sin_oc) pagos_fin_sin_oc,
--------------------------------------------------------------------------------------------
                            0 prov_ini_sin_oc, 0 num_sin_op1, 0 pagos_fin_sin_op1,
                            0 prov_fin_sin_op1, 0 num_sin_oc1_con_pagos,
                            0 num_sin_oc1_sin_pagos, 0 pagos_fin_sin_oc1,
--------------------------------------------------------------------------------------------
                            0 ibnr_inicial, 0 ibnr_final
                       FROM (SELECT   s.cramo ramo, s.sproduc producto, sn.nsinies siniestro,
                                      SUM
                                         (CASE
                                             WHEN CASE
                                                    WHEN stp2.ctippag IN
                                                                   (8, 2) THEN NVL
                                                                                 (stp2.isinret,
                                                                                  0)
                                                    WHEN stp2.ctippag IN
                                                                   (8, 2) THEN -NVL
                                                                                   (stp2.isinret,
                                                                                    0)
                                                    ELSE 0
                                                 END = 0 THEN 0
                                             ELSE 1
                                          END) num_sin_oc_con_pagos,
                                      SUM
                                         (CASE
                                             WHEN CASE
                                                    WHEN stp2.ctippag IN
                                                                   (8, 2) THEN NVL
                                                                                 (stp2.isinret,
                                                                                  0)
                                                    WHEN stp2.ctippag IN
                                                                   (8, 2) THEN -NVL
                                                                                   (stp2.isinret,
                                                                                    0)
                                                    ELSE 0
                                                 END = 0 THEN 1
                                             ELSE 0
                                          END) num_sin_oc_sin_pagos,
                                      SUM
                                         (CASE
                                             WHEN stp2.ctippag IN(8, 2) THEN NVL
                                                                               (stp2.isinret,
                                                                                0)
                                             WHEN stp2.ctippag IN(8, 2) THEN -NVL
                                                                                 (stp2.isinret,
                                                                                  0)
                                             ELSE 0
                                          END) pagos_fin_sin_oc
                                 FROM seguros s,
                                      sin_siniestro sn,
                                      sin_movsiniestro sm,

                                      --Sumatoria de PAGOS realizados en el PERIODO ACTUAL de siniestros
                                      --terminado en el PERIODO ACTUAL----------------------------------------------------
                                      (SELECT stp3.nsinies, stp3.isinret, stp3.ctippag
                                         FROM sin_tramita_pago stp3, sin_tramita_movpago stmp3
                                        WHERE stp3.sidepag = stmp3.sidepag
                                          AND stmp3.nmovpag =
                                                (SELECT MAX(nmovpag)
                                                   FROM sin_tramita_movpago
                                                  WHERE sidepag = stmp3.sidepag
                                                    AND TRUNC(fefepag) BETWEEN pfini AND pffin)
                                          AND stp3.ctippag IN(2, 7)
                                          AND stmp3.cestpag = 2) stp2
 ------------------------------------------------------------------------------------
-- ptpplp p1
                             WHERE    s.cempres = pcempres
                                  AND sn.sseguro = s.sseguro
                                  --Siniestros TERMINADOS en el PERIODO --------------------------------------------------
                                  AND sm.nsinies = sn.nsinies
                                  AND TRUNC(sn.fsinies) BETWEEN pfini AND pffin
                                  AND sm.cestsin IN(1, 2, 3)
                                  AND sm.nmovsin =
                                        (SELECT MAX(nmovsin)
                                           FROM sin_movsiniestro sm2
                                          WHERE sm2.nsinies = sn.nsinies
                                            AND festsin BETWEEN pfini AND pffin)
                                  --Siniestros finalizados en el PERIODO -------------------------------------------------
                                  AND EXISTS(SELECT '1'
                                               FROM sin_movsiniestro sm2
                                              WHERE sm2.nsinies = sn.nsinies
                                                AND sm2.cestsin IN(1, 2, 3)
                                                AND sm2.nmovsin =
                                                      (SELECT MAX(sm3.nmovsin)
                                                         FROM sin_movsiniestro sm3
                                                        WHERE sm3.nsinies = sm2.nsinies
                                                          AND festsin BETWEEN pfini AND pffin))
------------------------------------------------------------------------------
                                  AND stp2.nsinies(+) = sn.nsinies
                             --  AND p1.cempres = s.cempres
                              -- AND p1.nsinies = sn.nsinies
                              -- AND p1.fcalcul = (SELECT MAX(p.fcalcul)
                               --                    FROM ppnc p
                               --                   WHERE p.cempres = p1.cempres
                               --                     AND p.fcalcul <= pffin)
                             GROUP BY s.cramo, s.sproduc, sn.nsinies)
                   GROUP BY ramo, producto
                   UNION
                   --SINIESTROS PENDIENTES DE DECLARACIÓN / PENDIENTES A CIERRE PERIODO / TERMINADOS EN EL PERIODO
                   -- siniestros ocurridos antes del periodo  y registrados en el periodo
                   -- y que continuan pendientes al cierre del periodo------------------------------------------------
                   SELECT   s.cramo ramo, s.sproduc producto, 0 num_sin_pp, 0 pagos_ini_sin_pp,
                            0 prov_ini_sin_pp, 0 pagos_fin_sin_pp, 0 prov_fin_sin_pp,
                            0 num_sin_pc_con_pagos, 0 num_sin_pc_sin_pagos, 0 pagos_ini_sin_pc,
                            0 prov_ini_sin_pc, 0 pagos_fin_sin_pc, 0 num_sin_op,

                            /*
                            pendientes de declarar, no pueden SUMAR
                            COUNT(sn.nsinies)                    num_sin_op,
                            */
                            /*
                            SUM(DECODE(stp2.ctippag,
                                       8, NVL(stp2.isinret, 0),
                                       2, NVL(stp2.isinret, 0),
                                       3, 0 - NVL(stp2.isinret, 0),
                                       7, 0 - NVL(stp2.isinret, 0),
                                       0)) pagos_fin_sin_op,
                            */
                            0 pagos_fin_sin_op, 0 prov_fin_sin_op, 0 num_sin_oc_con_pagos,
                            0 num_sin_oc_sin_pagos, 0 prov_ini_sin_oc, 0 pagos_fin_sin_oc,
                            COUNT(sn.nsinies) num_sin_op1,
                            SUM(DECODE(stp2.ctippag,
                                       8, NVL(stp2.isinret, 0),
                                       2, NVL(stp2.isinret, 0),
                                       3, 0 - NVL(stp2.isinret, 0),
                                       7, 0 - NVL(stp2.isinret, 0),
                                       0)) pagos_fin_sin_op1,
                            SUM(NVL(p2.ipplpsd, 0)) prov_fin_sin_op1, 0 num_sin_oc1_con_pagos,
                            0 num_sin_oc1_sin_pagos, 0 pagos_fin_sin_oc1, 0 ibnr_inicial,
                            0 ibnr_final
                       FROM seguros s,
                            sin_siniestro sn,
                            sin_movsiniestro sm,
                            (SELECT stp3.nsinies, stp3.isinret, stp3.ctippag
                               FROM sin_tramita_pago stp3, sin_tramita_movpago stmp3
                              WHERE stp3.sidepag = stmp3.sidepag
                                AND stmp3.nmovpag =
                                      (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = stmp3.sidepag
                                          AND TRUNC(fefepag) >= pfini
                                          AND TRUNC(fefepag) <= pffin)
                                AND stp3.ctippag IN(2, 7)
                                AND stmp3.cestpag = 2) stp2,
                            ptpplp p2
                      WHERE sn.sseguro = s.sseguro
                        AND s.cempres = pcempres
                        AND sn.nsinies = sm.nsinies
                        AND TRUNC(sn.fsinies) < pffin
                        --Siniestros ocurridos antes del periodo
                        AND TRUNC(sn.falta) >= pfini
                        AND TRUNC(sn.falta) <= pffin
                        -- siniestros registrados en el periodo
                        AND sm.cestsin IN(0, 4)
                        AND sm.nmovsin = (SELECT MAX(nmovsin)
                                            FROM sin_movsiniestro sm2
                                           WHERE sm.nsinies = sm2.nsinies
                                             AND festsin <= pffin)
                        --Siniestros pendientes al cierre del periodo
                        AND p2.fcalcul = (SELECT MAX(p.fcalcul)
                                            FROM ppnc p
                                           WHERE p.cempres = p2.cempres
                                             AND p.fcalcul <= pffin)
                        AND p2.cempres = s.cempres
                        AND p2.nsinies = sn.nsinies
                        AND stp2.nsinies(+) = sn.nsinies
                   GROUP BY s.cramo, s.sproduc
                   UNION
                   -- siniestros ocurridos antes del periodo  y registrados en el periodo
                   -- y que han sido cerrados al cierre del periodo---------------------------------------------------
                   SELECT   s.cramo ramo, s.sproduc producto, 0 num_sin_pp, 0 pagos_ini_sin_pp,
                            0 prov_ini_sin_pp, 0 pagos_fin_sin_pp, 0 prov_fin_sin_pp,
                            0 num_sin_pc_con_pagos, 0 num_sin_pc_sin_pagos, 0 pagos_ini_sin_pc,
                            0 prov_ini_sin_pc, 0 pagos_fin_sin_pc, 0 num_sin_op,
                            0 pagos_fin_sin_op, 0 prov_fin_sin_op, 0 num_sin_oc_con_pagos,
                            0 num_sin_oc_sin_pagos, 0 prov_ini_sin_oc, 0 pagos_fin_sin_oc,
                            0 num_sin_op1, 0 pagos_fin_sin_op1, 0 prov_fin_sin_op1,
                            COUNT(sn1.nsinies) num_sin_oc1_con_pagos,
                            COUNT(sn.nsinies) num_sin_oc1_sin_pagos,
                            SUM(DECODE(stp2.ctippag,
                                       8, NVL(stp2.isinret, 0),
                                       2, NVL(stp2.isinret, 0),
                                       3, 0 - NVL(stp2.isinret, 0),
                                       7, 0 - NVL(stp2.isinret, 0),
                                       0)) pagos_fin_sin_oc1,
                            0 ibnr_inicial, 0 ibnr_final
                       FROM seguros s,
                            sin_siniestro sn,
                            sin_movsiniestro sm,
                            sin_siniestro sn1,
                            sin_movsiniestro sm1,
                            (SELECT stp3.nsinies, stp3.isinret, stp3.ctippag
                               FROM sin_tramita_pago stp3, sin_tramita_movpago stmp3
                              WHERE stp3.sidepag = stmp3.sidepag
                                AND stmp3.nmovpag =
                                      (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = stmp3.sidepag
                                          AND TRUNC(fefepag) >= pfini
                                          AND TRUNC(fefepag) <= pffin)
                                AND stp3.ctippag IN(2, 7)
                                AND stmp3.cestpag = 2) stp2,
                            ptpplp p1
                      WHERE sn1.sseguro = s.sseguro
                        AND s.cempres = pcempres
                        AND sn1.nsinies = sm1.nsinies
                        AND TRUNC(sn1.fsinies) < pffin
                        --Siniestros ocurridos antes del periodo------------------------------------------------------
                        AND TRUNC(sn1.falta) >= pfini
                        AND TRUNC(sn1.falta) <= pffin
                        -- siniestros registrados en el periodo
                        AND sm1.cestsin = 1
                        AND sm1.nmovsin = (SELECT MAX(nmovsin)
                                             FROM sin_movsiniestro sm2
                                            WHERE sm1.nsinies = sm2.nsinies
                                              AND festsin <= pffin)
                        --Siniestros cerrados al final periodo--------------------------------------------------------
                        AND p1.fcalcul = (SELECT MAX(p.fcalcul)
                                            FROM ppnc p
                                           WHERE p.cempres = p1.cempres
                                             AND p.fcalcul <= pfini)
                        AND p1.cempres = s.cempres
                        AND p1.nsinies = sn1.nsinies
                        AND stp2.nsinies(+) = sn1.nsinies
                        AND sn.sseguro = s.sseguro
                        AND sn.nsinies = sm.nsinies
                        AND TRUNC(sn.fsinies) < pffin
                        --Siniestros ocurridos antes del periodo------------------------------------------------------
                        AND TRUNC(sn.falta) >= pfini
                        AND TRUNC(sn.falta) <= pffin
                        -- siniestros registrados en el periodo-------------------------------------------------------
                        AND sm.cestsin = 1
                        AND sm.nmovsin = (SELECT MAX(nmovsin)
                                            FROM sin_movsiniestro sm2
                                           WHERE sm.nsinies = sm2.nsinies
                                             AND festsin <= pffin)
                        --Siniestros cerrados al final periodo--------------------------------------------------------
                        AND NOT EXISTS(SELECT '1'
                                         FROM sin_tramita_pago stp
                                        WHERE stp.nsinies = sn.nsinies
                                          AND stp.ctippag = 2)
                   GROUP BY s.cramo, s.sproduc
                   UNION
-- IBNR Inicial------------------------------------------------------------------------------------
                   SELECT   s.cramo ramo, s.sproduc producto, 0 num_sin_pp, 0 pagos_ini_sin_pp,
                            0 prov_ini_sin_pp, 0 pagos_fin_sin_pp, 0 prov_fin_sin_pp,
                            0 num_sin_pc_con_pagos, 0 num_sin_pc_sin_pagos, 0 pagos_ini_sin_pc,
                            0 prov_ini_sin_pc, 0 pagos_fin_sin_pc, 0 num_sin_op,
                            0 pagos_fin_sin_op, 0 prov_fin_sin_op, 0 num_sin_oc_con_pagos,
                            0 num_sin_oc_sin_pagos, 0 prov_ini_sin_oc, 0 pagos_fin_sin_oc,
                            0 num_sin_op1, 0 pagos_fin_sin_op1, 0 prov_fin_sin_op1,
                            0 num_sin_oc1_con_pagos, 0 num_sin_oc1_sin_pagos,
                            0 pagos_fin_sin_oc1, SUM(NVL(i.iibnrsd, 0)) ibnr_inicial,
                            0 ibnr_final
                       FROM ibnr i, seguros s
                      WHERE s.cempres = pcempres
                        AND s.cempres = i.cempres
                        AND s.sseguro = i.sseguro
                        AND i.fcalcul = (SELECT MAX(i1.fcalcul)
                                           FROM ibnr i1
                                          WHERE i1.cempres = i.cempres
                                            AND i1.fcalcul <= pfini)
                   GROUP BY s.cramo, s.sproduc
                   UNION
-- IBNR Final--------------------------------------------------------------------------------------
                   SELECT   s.cramo ramo, s.sproduc producto, 0 num_sin_pp, 0 pagos_ini_sin_pp,
                            0 prov_ini_sin_pp, 0 pagos_fin_sin_pp, 0 prov_fin_sin_pp,
                            0 num_sin_pc_con_pagos, 0 num_sin_pc_sin_pagos, 0 pagos_ini_sin_pc,
                            0 prov_ini_sin_pc, 0 pagos_fin_sin_pc, 0 num_sin_op,
                            0 pagos_fin_sin_op, 0 prov_fin_sin_op, 0 num_sin_oc_con_pagos,
                            0 num_sin_oc_sin_pagos, 0 prov_ini_sin_oc, 0 pagos_fin_sin_oc,
                            0 num_sin_op1, 0 pagos_fin_sin_op1, 0 prov_fin_sin_op1,
                            0 num_sin_oc1_con_pagos, 0 num_sin_oc1_sin_pagos,
                            0 pagos_fin_sin_oc1, 0 ibnr_inicial,
                            SUM(NVL(i.iibnrsd, 0)) ibnr_final
                       FROM ibnr i, seguros s
                      WHERE s.cempres = pcempres
                        AND s.cempres = i.cempres
                        AND s.sseguro = i.sseguro
                        AND i.fcalcul = (SELECT MAX(i1.fcalcul)
                                           FROM ibnr i1
                                          WHERE i1.cempres = i.cempres
                                            AND i1.fcalcul <= pffin)
                   GROUP BY s.cramo, s.sproduc) x,
                  codiram c,
                  productos p
            WHERE c.cempres = pcempres
              AND c.cramo = p.cramo
              AND c.cramo = x.ramo
              AND p.sproduc = x.producto
         GROUP BY x.ramo, p.cramo, p.cmodali, p.ctipseg, p.ccolect;
   BEGIN
      -- comprobar campos obligatorios
      IF pfini IS NULL
         OR pffin IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      OPEN c_siniestros;

      vpasexec := 3;

      LOOP
         FETCH c_siniestros
          INTO vcramo, vtramo, vtproducto,
                                          --PROV. SINIESTROS PTES. CIERRE YYYY Y PTES. AL cierre nº trimestre YYYY----------------------------
                                          vnum_sin_pp, vpagos_ini_sin_pp, vprov_ini_sin_pp,
               vpagos_fin_sin_pp, vprov_fin_sin_pp,
                                                   --SINIESTROS PTES AL CIERRE EJERCICIO Y TERMINADOS EN EL PERIODO------------------------------------
                                                   vnum_sin_pc_con_pagos,
               vnum_sin_pc_sin_pagos, vpagos_ini_sin_pc, vprov_ini_sin_pc, vpagos_fin_sin_pc,

               --OCURRIDOS EN EL PERIODO---------------------------------------------------------------------------
               vnum_sin_op, vpagos_fin_sin_op, vprov_fin_sin_op, vnum_sin_oc_con_pagos,
               vnum_sin_oc_sin_pagos, vpagos_fin_sin_oc,
                                                        --SINIESTROS PENDIENTES DE DECLARACIÓN / PENDIENTES A CIERRE PERIODO / TERMINADOS EN EL PERIODO
                                                        vprov_ini_sin_oc, vnum_sin_op1,
               vpagos_fin_sin_op1, vprov_fin_sin_op1, vnum_sin_oc1_con_pagos,
               vnum_sin_oc1_sin_pagos, vpagos_fin_sin_oc1, vibnr_inicial, vibnr_final;

         EXIT WHEN c_siniestros%NOTFOUND;

         IF vsquery IS NULL THEN
            vsquery := 'SELECT ' || vcramo || ', ' || CHR(39) || vtramo || CHR(39) || ', '
                       || CHR(39) || vtproducto || CHR(39) || ', ' ||
                                                                      --PROV. SINIESTROS PTES. CIERRE YYYY Y PTES. AL cierre nº trimestre YYYY
                       'to_number(''' || vnum_sin_pp || ''')' || ', ' || 'to_number('''
                       || vpagos_ini_sin_pp || ''')' || ', ' || 'to_number('''
                       || vprov_ini_sin_pp || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_pp || ''')' || ', ' || 'to_number('''
                       || vprov_fin_sin_pp || ''')' || ', ' ||
                                                               --SINIESTROS PTES AL CIERRE EJERCICIO Y TERMINADOS EN EL PERIODO
                       'to_number(''' || vnum_sin_pc_con_pagos || ''')' || ', '
                       || 'to_number(''' || vnum_sin_pc_sin_pagos || ''')' || ', '
                       || 'to_number(''' || vpagos_ini_sin_pc || ''')' || ', '
                       || 'to_number(''' || vprov_ini_sin_pc || ''')' || ', '
                       || 'to_number(''' || vpagos_fin_sin_pc || ''')' || ', '
                       ||
                          --OCURRIDOS EN EL PERIODO
                       'to_number(''' || vnum_sin_op || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_op || ''')' || ', ' || 'to_number('''
                       || vprov_fin_sin_op || ''')' || ', ' || 'to_number('''
                       || vnum_sin_oc_con_pagos || ''')' || ', ' || 'to_number('''
                       || vnum_sin_oc_sin_pagos || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_oc || ''')' || ', ' ||
                                                                --SINIESTROS PENDIENTES DE DECLARACIÓN / PENDIENTES A CIERRE PERIODO / TERMINADOS EN EL PERIODO
                       'to_number(''' || vprov_ini_sin_oc || ''')' || ', ' || 'to_number('''
                       || vnum_sin_op1 || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_op1 || ''')' || ', ' || 'to_number('''
                       || vprov_fin_sin_op1 || ''')' || ', ' || 'to_number('''
                       || vnum_sin_oc1_con_pagos || ''')' || ', ' || 'to_number('''
                       || vnum_sin_oc1_sin_pagos || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_oc1 || ''')' || ', ' || 'to_number('''
                       || vibnr_inicial || ''')' || ', ' || 'to_number(''' || vibnr_final
                       || ''')' || ' from dual';
         ELSE
            vsquery := vsquery || ' UNION ' || 'SELECT ' || vcramo || ', ' || CHR(39)
                       || vtramo || CHR(39) || ', ' || CHR(39) || vtproducto || CHR(39)
                       || ', ' ||
                                  --PROV. SINIESTROS PTES. CIERRE YYYY Y PTES. AL cierre nº trimestre YYYY
                       'to_number(''' || vnum_sin_pp || ''')' || ', ' || 'to_number('''
                       || vpagos_ini_sin_pp || ''')' || ', ' || 'to_number('''
                       || vprov_ini_sin_pp || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_pp || ''')' || ', ' || 'to_number('''
                       || vprov_fin_sin_pp || ''')' || ', ' ||
                                                               --SINIESTROS PTES AL CIERRE EJERCICIO Y TERMINADOS EN EL PERIODO
                       'to_number(''' || vnum_sin_pc_con_pagos || ''')' || ', '
                       || 'to_number(''' || vnum_sin_pc_sin_pagos || ''')' || ', '
                       || 'to_number(''' || vpagos_ini_sin_pc || ''')' || ', '
                       || 'to_number(''' || vprov_ini_sin_pc || ''')' || ', '
                       || 'to_number(''' || vpagos_fin_sin_pc || ''')' || ', '
                       ||
                          --OCURRIDOS EN EL PERIODO
                       'to_number(''' || vnum_sin_op || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_op || ''')' || ', ' || 'to_number('''
                       || vprov_fin_sin_op || ''')' || ', ' || 'to_number('''
                       || vnum_sin_oc_con_pagos || ''')' || ', ' || 'to_number('''
                       || vnum_sin_oc_sin_pagos || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_oc || ''')' || ', ' ||
                                                                --SINIESTROS PENDIENTES DE DECLARACIÓN / PENDIENTES A CIERRE PERIODO / TERMINADOS EN EL PERIODO
                       'to_number(''' || vprov_ini_sin_oc || ''')' || ', ' || 'to_number('''
                       || vnum_sin_op1 || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_op1 || ''')' || ', ' || 'to_number('''
                       || vprov_fin_sin_op1 || ''')' || ', ' || 'to_number('''
                       || vnum_sin_oc1_con_pagos || ''')' || ', ' || 'to_number('''
                       || vnum_sin_oc1_sin_pagos || ''')' || ', ' || 'to_number('''
                       || vpagos_fin_sin_oc1 || ''')' || ', ' || 'to_number('''
                       || vibnr_inicial || ''')' || ', ' || 'to_number(''' || vibnr_final
                       || ''')' || ' from dual';
         END IF;
      END LOOP;

      vpasexec := 4;

      CLOSE c_siniestros;

      IF vsquery IS NULL THEN
         vsquery := 'SELECT null from dual';
      END IF;

      vpasexec := 5;
      RETURN vsquery;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS ');

         IF vsquery IS NULL THEN
            vsquery := 'SELECT null from dual';
         END IF;

         RETURN vsquery;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

         IF c_siniestros%ISOPEN THEN
            CLOSE c_siniestros;
         END IF;

         IF vsquery IS NULL THEN
            vsquery := 'SELECT null from dual';
         END IF;

         RETURN vsquery;
   END f_modelo_7_siniestros;
-- fin Bug 22996 - APD - 25/07/2012
END pac_modelos_fiscales;

/

  GRANT EXECUTE ON "AXIS"."PAC_MODELOS_FISCALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MODELOS_FISCALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MODELOS_FISCALES" TO "PROGRAMADORESCSI";
