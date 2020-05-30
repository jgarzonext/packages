--------------------------------------------------------
--  DDL for Package Body PAC_COBFALL_DGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_COBFALL_DGS" IS
/***********************************************************************************
 30-06-2009. CSI

  REVISIONES:
   Ver        Fecha        Autor             Descripci򬋊   ---------  ----------  ---------------  ------------------------------------
    1.0       ??/??/????   ???              1. Creaci򬟤el patch
    2.0       30/06/2009   DRA              2. 0010474: IAX - Eliminar PAC_PROCESOS_BATCH
    3.0       08/07/2009   DCT              3. 0010612: CRE - Error en la generaci񟣥 pagaments autom�cs.
                                            Canviar vista personas por tablas personas y a𠣩r filtro de visi򬟤e agente
*******************************************************************************************/
   fichero        UTL_FILE.file_type;
   proces         NUMBER;
   numerr         NUMBER := 0;
   numlin         NUMBER := 0;
   retval         NUMBER;

   TYPE movimiento IS RECORD(
      tiposeguro     VARCHAR2(58) := '<res:tipoSeguro>Resto seguros</res:tipoSeguro>',
      tipoasegurado  VARCHAR2(58) := '<res:tipoAsegurado>nominado</res:tipoAsegurado>',
      tipoasiento    VARCHAR2(58) := '<res:tipoAsiento>@</res:tipoAsiento>',
      referenciacontrato VARCHAR2(67) := '<res:referenciaContrato>@</res:referenciaContrato>',
      tipocobertura  VARCHAR2(58) := '<res:tipoCobertura>Vida</res:tipoCobertura>',
      nombreasegurado VARCHAR2(93) := '<res:nombreAsegurado>@</res:nombreAsegurado>',
      apellidoasegurado1 VARCHAR2(93) := '<res:apellidoAsegurado1>@</res:apellidoAsegurado1>',
      apellidoasegurado2 VARCHAR2(93) := '<res:apellidoAsegurado2>@</res:apellidoAsegurado2>',
      tipodocumento  VARCHAR2(108) := '<res:tipoDocumento>@</res:tipoDocumento>',
      iniciocobertura VARCHAR2(53) := '<res:inicioCobertura>@</res:inicioCobertura>',
      fincobertura   VARCHAR2(47) := '<res:finCobertura>@</res:finCobertura>',
      txtincidencia  VARCHAR2(58)
   );

   /*
   DESCR: Substitueix el caracters especials pel format UTF-8
   */
   FUNCTION to_utf8(pvalor VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN CONVERT(pvalor, 'UTF8');
   END to_utf8;

   FUNCTION init_movimiento
      RETURN movimiento IS
      f              movimiento;
   BEGIN
      RETURN f;
   END init_movimiento;

   /*
   DESCR: Monta el tag xml amb el valor
   */
   FUNCTION substituir(etiqueta VARCHAR2, valor VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN REPLACE(etiqueta, '@', valor);
   END substituir;

   /*
   DESCR: Junta fitxers al fitxer generat per SIS
   */
   PROCEDURE p_acumular_fichero(pnomfich VARCHAR2) IS
      fichext        UTL_FILE.file_type;
      path_in        VARCHAR2(100);
      registro       VARCHAR2(1000);
   BEGIN
      path_in := f_parinstalacion_t('PATH_DEVOL');
      fichext := UTL_FILE.fopen(path_in, pnomfich, 'r');

      LOOP
         BEGIN
            UTL_FILE.get_line(fichext, registro);
            UTL_FILE.put_line(fichero, to_utf8(registro));
         EXCEPTION
            WHEN UTL_FILE.read_error THEN
               numlin := NULL;
               retval := f_proceslin(proces,
                                     'Error acumular fichero ' || pnomfich || ' '
                                     || SUBSTR(SQLERRM, 1, 75),
                                     0, numlin, 1);
               numerr := numerr + 1;
               EXIT;
            WHEN NO_DATA_FOUND THEN
               EXIT;
         END;
      END LOOP;

      -- BUG10474:DRA:30/06/2009:Inici
      -- pac_procesos_batch.p_copia_ficheros(path_in, pnomfich, path_in, 'xml', proces, 'S');
      -- BUG10474:DRA:30/06/2009:Fi
      UTL_FILE.fclose(fichext);
      numlin := NULL;
      retval := f_proceslin(proces, 'Fin lectura fichero ' || pnomfich || ' OK', 0, numlin, 2);
   EXCEPTION
      WHEN OTHERS THEN
         numlin := NULL;

         IF SQLCODE != -29238 THEN
            retval := f_proceslin(proces, 'Fichero no encontrada ' || pnomfich, 0, numlin, 2);
         ELSE
            retval := f_proceslin(proces,
                                  'Error fichero ' || pnomfich || ' '
                                  || SUBSTR(SQLERRM, 1, 90),
                                  0, numlin, 1);
            numerr := numerr + 1;
         END IF;
   END p_acumular_fichero;

   /*
   DESCR: Escriu el registre en el fitxer, crida a la funcio UTF8 per
     controlar els caracters especial.
   */
   PROCEDURE escribir_fichero(mov movimiento) IS
      registro       VARCHAR2(1000);
      mov_orig       movimiento;
   BEGIN
      registro := '<res:movimiento>' || mov.tiposeguro || mov.tipoasegurado || mov.tipoasiento
                  || mov.referenciacontrato || mov.tipocobertura || mov.nombreasegurado
                  || mov.apellidoasegurado1;

      IF mov.apellidoasegurado2 != mov_orig.apellidoasegurado2 THEN
         registro := registro || mov.apellidoasegurado2;
      END IF;

      registro := registro || mov.tipodocumento || mov.iniciocobertura;

      IF mov.fincobertura != mov_orig.fincobertura THEN
         registro := registro || mov.fincobertura;
      END IF;

      registro := registro || '</res:movimiento>';
      UTL_FILE.put_line(fichero, to_utf8(registro));
   END escribir_fichero;

   /*
   DESCR: Cap?era del fitxer XML
   */
   PROCEDURE grabar_cabecera(fecha_ini IN DATE, fecha_fin IN DATE) IS
      cadena         VARCHAR2(1000);
   BEGIN
      UTL_FILE.put_line(fichero, '<?xml version="1.0" encoding="UTF-8" ?>');
      UTL_FILE.put_line
             (fichero,
              '<res:comunicacionEntidad xmlns:res="http://rscf.mjusticia.es/xml/RESEVITypes">');
      UTL_FILE.put_line(fichero, '<res:identificacionFichero>');
      UTL_FILE.put_line(fichero, '<res:tipoDeEnvio>Envio Periodico</res:tipoDeEnvio>');
      cadena := '<res:fechaInicioPeriodo>' || TO_CHAR(fecha_ini, 'YYYY-MM-DD')
                || ' </res:fechaInicioPeriodo><res:fechaFinPeriodo>';
      cadena := cadena || TO_CHAR(fecha_fin, 'YYYY-MM-DD')
                || '</res:fechaFinPeriodo></res:identificacionFichero>';
      UTL_FILE.put_line(fichero, cadena);
      cadena :=
         '<res:entidadAseguradora><res:claveAdministrativa>C0643</res:claveAdministrativa><res:CIF>A07289531</res:CIF>';
      cadena :=
         cadena
         || '<res:denominacionSocial> COMPA?A DE SEGUROS DE VIDA S.A</res:denominacionSocial>';
      cadena :=
         cadena
         || '<res:domicilioSocial>domiciliacion</res:domicilioSocial><res:poblacion>poblacion</res:poblacion>';
      cadena :=
         cadena
         || '<res:provincia>provincia</res:provincia><res:codigoPostal>XXXX</res:codigoPostal>';
      cadena := cadena || '<res:pais>PAIS</res:pais><res:numFax>FAX</res:numFax>';
      cadena :=
         cadena
         || '<res:correoElectronico>seg_vida_y_pensiones@assegurances.es</res:correoElectronico>';
      cadena := cadena || '</res:entidadAseguradora>';
      UTL_FILE.put_line(fichero, to_utf8(cadena));
      UTL_FILE.put_line(fichero, '<res:movimientos>');
   END grabar_cabecera;

   /*
   DESCR: Recupera i monta les dades a enviar
   */
   FUNCTION enviar_asegurados(
      psseguro NUMBER,
      ptipoasiento VARCHAR2,
      tipoenv NUMBER,
      psperson NUMBER)
      RETURN NUMBER IS
      mov            movimiento;
      continuar      BOOLEAN;
      qq_envios      NUMBER := 0;
   BEGIN
      --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
      FOR reg IN (SELECT p.nnumide nnumnif, SUBSTR(d.tnombre, 0, 20) tnombre,
                         SUBSTR(d.tapelli1, 0, 40) tapelli1,
                         SUBSTR(d.tapelli2, 0, 20) tapelli2, p.fnacimi, a.ffecini, a.ffecfin,
                         p.ctipide tidenti, s.cramo, s.cmodali, s.fefecto, s.fcaranu,
                         s.npoliza, s.ncertif, s.fanulac
                    FROM per_personas p, per_detper d, asegurados a, seguros s
                   WHERE p.sperson = a.sperson
                     AND a.sseguro = s.sseguro
                     AND s.sseguro = psseguro
                     AND a.sperson = NVL(psperson, a.sperson)
                     AND p.ctipide IN(1, 3, 4)
                     AND d.sperson = p.sperson
                     AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)) LOOP
         /*FOR reg IN (SELECT p.nnumnif, p.tnombre, p.tapelli1, p.tapelli2, p.fnacimi, a.ffecini,
                            a.ffecfin, p.tidenti, s.cramo, s.cmodali, s.fefecto, s.fcaranu,
                            s.npoliza, s.ncertif, s.fanulac
                       FROM personas p, asegurados a, seguros s
                      WHERE p.sperson = a.sperson
                        AND a.sseguro = s.sseguro
                        AND s.sseguro = psseguro
                        AND a.sperson = NVL(psperson, a.sperson)
                        AND p.tidenti IN(1, 3, 4)) LOOP*/
         -- FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
         mov := init_movimiento;

         IF reg.cramo = 23
            AND reg.cmodali = 1 THEN   -- TAR (anual renovable)
            mov.iniciocobertura := substituir(mov.iniciocobertura,
                                              TO_CHAR(reg.fefecto, 'YYYY-MM-DD'));

            IF tipoenv IN(1, 2, 3) THEN
               mov.fincobertura := substituir(mov.fincobertura,
                                              TO_CHAR(reg.fcaranu, 'YYYY-MM-DD'));
            ELSE
               mov.fincobertura := substituir(mov.fincobertura,
                                              TO_CHAR(reg.fanulac, 'YYYY-MM-DD'));
            END IF;

            continuar := TRUE;
         ELSIF reg.cramo = 23
               AND reg.cmodali = 2 THEN   -- Sepelio
            IF fedad(NULL, TO_CHAR(reg.fnacimi, 'YYYYMMDD'),
                     TO_CHAR(TRUNC(SYSDATE), 'YYYYMMDD'), 1) >= 15 THEN
               IF reg.ffecini < ADD_MONTHS(reg.fnacimi, 12 * 15) THEN
                  mov.iniciocobertura :=
                     substituir(mov.iniciocobertura,
                                TO_CHAR(LAST_DAY(ADD_MONTHS(reg.fnacimi, 12 * 15)) + 1,
                                        'YYYY-MM-DD'));
               ELSE
                  mov.iniciocobertura := substituir(mov.iniciocobertura,
                                                    TO_CHAR(reg.ffecini, 'YYYY-MM-DD'));
               END IF;

               IF tipoenv = 4 THEN
                  mov.fincobertura := substituir(mov.fincobertura,
                                                 TO_CHAR(reg.ffecfin, 'YYYY-MM-DD'));
               ELSIF tipoenv = 5 THEN
                  mov.fincobertura := substituir(mov.fincobertura,
                                                 TO_CHAR(reg.fanulac, 'YYYY-MM-DD'));
               END IF;

               continuar := TRUE;
            ELSE
               continuar := FALSE;
            END IF;
         END IF;

         IF continuar THEN
            mov.referenciacontrato := substituir(mov.referenciacontrato,
                                                 reg.npoliza || '/' || reg.ncertif);
            mov.nombreasegurado := substituir(mov.nombreasegurado, UPPER(reg.tnombre));
            mov.apellidoasegurado1 := substituir(mov.apellidoasegurado1, UPPER(reg.tapelli1));
            mov.tipoasiento := substituir(mov.tipoasiento, ptipoasiento);

            IF TRIM(reg.tapelli2) != '.'
               AND LENGTH(TRIM(reg.tapelli2)) > 0 THEN
               mov.apellidoasegurado2 := substituir(mov.apellidoasegurado2,
                                                    UPPER(reg.tapelli2));
            END IF;

            IF reg.tidenti = 1 THEN
               mov.tipodocumento := substituir(mov.tipodocumento,
                                               '<res:NIF>' || reg.nnumnif || '</res:NIF>');
            ELSIF reg.tidenti = 3 THEN
               mov.tipodocumento := substituir(mov.tipodocumento,
                                               '<res:Pasaporte>' || reg.nnumnif
                                               || '</res:Pasaporte>');
            ELSIF reg.tidenti = 4 THEN
               mov.tipodocumento := substituir(mov.tipodocumento,
                                               '<res:TarjetaResidencia>' || reg.nnumnif
                                               || '</res:TarjetaResidencia>');
            ELSE
               mov.tipodocumento := substituir(mov.tipodocumento,
                                               '<res:Desconocido>' || reg.nnumnif
                                               || '</res:Desconocido>');
            END IF;

            qq_envios := qq_envios + 1;
            escribir_fichero(mov);
         END IF;
      END LOOP;

      RETURN qq_envios;
   END enviar_asegurados;

    /*
   DESCR: Genera fitxer de SIS i adjunta els fitxers externs
   */
   PROCEDURE p_enviar_fichero(
      fecha_ini IN DATE,
      fecha_fin IN DATE,
      pfichhost IN VARCHAR2,
      pfichext IN VARCHAR2,
      pnomfich OUT VARCHAR2,
      pproces OUT NUMBER) IS
      CURSOR mov_dgs IS
         (SELECT e.s_cobfall_dgs, e.sseguro, e.sperson, e.ctipenv, e.cmotmov, e.fenvio,
                 s.npoliza, s.ncertif
            FROM envio_cobfall_dgs e, seguros s
           WHERE e.sseguro = s.sseguro
             AND e.fenvio >= fecha_ini
             AND e.fenvio <= fecha_fin
             AND e.procesado = 0
             AND e.fenviado IS NULL)
         ORDER BY e.sseguro ASC, e.cmotmov ASC;

      path_out       VARCHAR2(100);
      aux            NUMBER(1);
   BEGIN
      retval := f_procesini(f_user, 1, 'PAC_COBFALL_DGS.ENV', 'ENVIO SEMANAL DGS COB.FALL',
                            pproces);
      proces := pproces;
      path_out := f_parinstalacion_t('PATH_FASES');
      pnomfich := 'CONTRATOS_RIESGO_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '.xml';
      fichero := UTL_FILE.fopen(path_out, pnomfich, 'w', 32000);
      grabar_cabecera(fecha_ini, fecha_fin);

      FOR dgs IN mov_dgs LOOP
         aux := 0;

         IF dgs.ctipenv IN(1, 2)   -- Altes
                                THEN
            IF dgs.cmotmov = 100   -- Alta p??sa
                                THEN
               aux := enviar_asegurados(dgs.sseguro, 'Inscripción', dgs.ctipenv, NULL);
            ELSE
               aux := enviar_asegurados(dgs.sseguro, 'Inscripción', dgs.ctipenv, dgs.sseguro);
            END IF;
         ELSIF dgs.ctipenv = 3   -- Modificacions
                              THEN
            aux := enviar_asegurados(dgs.sseguro, 'Modificación', dgs.ctipenv, NULL);
         ELSIF dgs.ctipenv = 4   -- Baixes assegurat
                              THEN
            aux := enviar_asegurados(dgs.sseguro, 'Cancelación', dgs.ctipenv, dgs.sperson);
         ELSIF dgs.ctipenv = 5   -- Baixa polissa
                              THEN
            IF f_situacion_v(dgs.sseguro, dgs.fenvio) != 1 THEN
               aux := enviar_asegurados(dgs.sseguro, 'Cancelación', dgs.ctipenv, NULL);
            END IF;
         END IF;

         IF aux = 0 THEN
            numlin := NULL;
            retval := f_proceslin(pproces,
                                  'Contrato no enviado ' || dgs.npoliza || '-' || dgs.ncertif,
                                  dgs.sseguro, numlin, 2);
         END IF;

         UPDATE envio_cobfall_dgs
            SET fenviado = DECODE(LEAST(aux, 1), 1, fecha_fin),
                procesado = 1
          WHERE s_cobfall_dgs = dgs.s_cobfall_dgs;
      END LOOP;

      COMMIT;

      IF pfichhost IS NOT NULL THEN
         p_acumular_fichero(pfichhost);
      END IF;

      IF pfichext IS NOT NULL THEN
         p_acumular_fichero(pfichext);
      END IF;

      UTL_FILE.put_line(fichero, '</res:movimientos></res:comunicacionEntidad>');
      UTL_FILE.fclose(fichero);
      numlin := NULL;
      retval := f_proceslin(pproces, 'Fichero genera OK. ' || pnomfich, 0, numlin, 4);
      retval := f_procesfin(pproces, numerr);
   END p_enviar_fichero;

   /*
   DESCR: Grava els moviments fets a movseguro i asegurados per despres enviar.
   */
   PROCEDURE p_grabar_movimiento(psseguro IN NUMBER, pfefecto IN DATE, pcmotmov IN NUMBER) IS
      v_sproduc      productos.sproduc%TYPE;
      v_ctipenv      NUMBER(1);
      v_cobfall      NUMBER(15);
      v_emitido      NUMBER(1);
      v_sperson      NUMBER(10);
      v_tratar       NUMBER(2);
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT ctipenv
        INTO v_ctipenv
        FROM mov_cobfall_dgs
       WHERE sproduc = v_sproduc
         AND cmotmov = pcmotmov;

      IF v_ctipenv = 4 THEN
         SELECT COUNT(1)
           INTO v_tratar
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecfin = pfefecto;

         IF v_tratar = 0 THEN
            v_ctipenv := 5;
         END IF;
      END IF;

      IF v_ctipenv = 2 THEN
         FOR aseg IN (SELECT sperson
                        FROM asegurados
                       WHERE sseguro = psseguro
                         AND ffecini = pfefecto) LOOP
            SELECT s_cobfall_dgs.NEXTVAL
              INTO v_cobfall
              FROM DUAL;

            INSERT INTO envio_cobfall_dgs
                        (s_cobfall_dgs, sseguro, fenvio, cmotmov, ctipenv, procesado, sperson)
                 VALUES (v_cobfall, psseguro, pfefecto, pcmotmov, v_ctipenv, 0, aseg.sperson);
         END LOOP;
      ELSIF v_ctipenv = 4 THEN
         FOR aseg IN (SELECT sperson
                        FROM asegurados
                       WHERE sseguro = psseguro
                         AND ffecfin = pfefecto) LOOP
            SELECT s_cobfall_dgs.NEXTVAL
              INTO v_cobfall
              FROM DUAL;

            INSERT INTO envio_cobfall_dgs
                        (s_cobfall_dgs, sseguro, fenvio, cmotmov, ctipenv, procesado, sperson)
                 VALUES (v_cobfall, psseguro, pfefecto, pcmotmov, v_ctipenv, 0, aseg.sperson);
         END LOOP;
      ELSE
         SELECT s_cobfall_dgs.NEXTVAL
           INTO v_cobfall
           FROM DUAL;

         INSERT INTO envio_cobfall_dgs
                     (s_cobfall_dgs, sseguro, fenvio, cmotmov, ctipenv, procesado)
              VALUES (v_cobfall, psseguro, pfefecto, pcmotmov, v_ctipenv, 0);
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END p_grabar_movimiento;
END pac_cobfall_dgs;

/

  GRANT EXECUTE ON "AXIS"."PAC_COBFALL_DGS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COBFALL_DGS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COBFALL_DGS" TO "PROGRAMADORESCSI";
