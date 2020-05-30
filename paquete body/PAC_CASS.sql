--------------------------------------------------------
--  DDL for Package Body PAC_CASS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CASS" AS
   /******************************************************************************
      NOM:    PAC_CASS
      PROPÓSIT: Especificació del paquet de les funcions i procediments
                per a la càrrega de fitxers de la CASS.
      REVISIONS:
      Ver        Data        Autor             Descripció
      ---------  ----------  ---------------  ------------------------------------
      1.0        14/08/2008  XVM              1. Creación del package.
      2.0        04/12/2008  SBOU             2. Modificacions + P_CARGA
      3.0        26/05/2009  APD              6. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                 función pac_seguros.ff_get_actividad
      4.0        02/06/2009  ETM              4. bug 0010266: CRE - cuenta de abono en pólizas de salud y bajas
      5.0        01/06/2009  NMM              5. 8072: CRE012 - Pruebas de carga de ficheros de reembolsos.
      6.0        01/07/2009  DRA              6. 0010604: Nuevo control Reembolsos - Pago Retenido
      7.0        06/07/2009  DRA              7. 0010631: CRE - Modificaciónes modulo de reembolsos
      8.0        01/07/2009  NMM              8. 10682: CRE - Modificaciones para módulo de reembolsos.
      9.0        04/07/2009  DRA              9. 0010704: CRE - Traspaso de facturas para reembolso con mismo Nº Hoja CASS
      10.0       22/07/2009  DRA              10.0010761: CRE - Reembolsos
      11.0       09/09/2009  NMM              11.11085: CRE - Carga de la CASS
      12.0       02/10/2009  XVM              12.0011285: CRE - Transferencias de reembolsos
      13.0       06/10/2009  DRA              13.0011190: CRE- Modificaciones en módulo de reembolsos.
      14.0       02/11/2009  DRA              14.0011629: CRE - incidencia pac_cass.f_comprova_full
      15.0       27/11/2009  MCA              15.0012025: CRE - Error al recuperar cuenta de abono en determinados casos
      16.0       27/11/2009  MCA              16.0011978: CRE - Incidencia en generación de reembolsos
      17.0       28/01/2010  NMM              17.12813: CRE201 - Reembolsos: Cambios en rutina de recuperación de pólizas.
      18.0       10/03/2010  DRA              18.0012676: CRE201 - Consulta de reembolsos - Ocultar descripción de Acto y otras mejoras
      19.0       29/03/2010  DRA              19.0013927: CRE049 - Control cambio de estado reembolso
      20.0       22/04/2010  DRA              20.0014227: CRE201 - Modificaciones reembolsos
      21.0       11/08/2010  SMF              21. 0015711: AGA003 - standaritzación del pac_cass
      22.0       25/06/2013  RCL              22. 0024697: Canvi mida camp sseguro
   ******************************************************************************/

   /*************************************************************************
     Determina quins arxius de càrrega són els que cal processar, els llegeix
     i els marca com a llegits.
   *************************************************************************/
   PROCEDURE p_carga IS
      v_path         VARCHAR2(200) := f_parinstalacion_t('PATH_CARGA');
      v_nom          VARCHAR2(100);
      v_fitxer       UTL_FILE.file_type;
      v_error        NUMBER;
      vsproces       NUMBER;
      w_error        NUMBER;
   --
   BEGIN
      -- 21. 0015711: AGA003 - standaritzación del pac_cass (se cambia empresa 1 por empresa por defecto)
      v_error := f_procesini(f_user, f_parinstalacion_n('EMPRESADEF'), 'PAC_CASS',
                             'Package carga CASS', vsproces);

      -- Mantis 8072.01/06/2009.NMM.Pruebas de carga de ficheros de reembolsos
      FOR i IN 1 .. 9 LOOP
         v_nom := 'ASSE_' || i || '.txt';   -- Mantis 8072.01/06/2009.fi.

         BEGIN
            v_fitxer := UTL_FILE.fopen(v_path, v_nom, 'R');

            IF UTL_FILE.is_open(v_fitxer) THEN
               UTL_FILE.fclose(v_fitxer);
               p_lee(v_path, v_nom, vsproces);
            END IF;
         EXCEPTION
            WHEN UTL_FILE.invalid_operation THEN
               NULL;
         END;
      END LOOP;
   --
   EXCEPTION
      WHEN OTHERS THEN
         -- Finalitzem el procés amb el codi d'error.
         w_error := f_procesfin(vsproces, SQLCODE);
   --
   END p_carga;

   /*************************************************************************
     Rutina de lectura del fitxer extern que permet gravar les dades en les taules
     cass i cassdet_01.
     param in P_PATH : Path fitxer
     param in P_NOMBRE : Nom fitxer
     param in PSPROCES : Nº procés
   *************************************************************************/
   PROCEDURE p_lee(p_path IN VARCHAR2, p_nombre IN VARCHAR2, psproces IN NUMBER) IS
      v_nombre       VARCHAR2(200) := p_path || '\' || p_nombre;
      n_linerr       NUMBER;
      v_sseguro      cassdet_01.sseguro%TYPE;   --       v_sseguro      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nriesgo      cassdet_01.nriesgo%TYPE;   --       v_nriesgo      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_sperson      NUMBER;
      v_cgarant      NUMBER;
      FINAL          NUMBER := 0;
      final_det      NUMBER := 0;
      tipo_registro  VARCHAR2(2);
      tipo_prestacion VARCHAR2(4);
      fin            UTL_FILE.file_type;
      linea          VARCHAR2(300);
      empresa        usuarios.cempres%TYPE;   --       empresa        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      nprolin        NUMBER;
      v_linact       cassdet_01.nlinea%TYPE := 0;   --       v_linact       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_agr_salud    VARCHAR2(20);
      v_ccompani     cass.ccompani%TYPE;   --       v_ccompani     VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_fremesa      cass.fremesa%TYPE;   --       v_fremesa      VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nremesa      cass.nremesa%TYPE := 1;   --       v_nremesa      VARCHAR2(20) := 1; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ctipo        cass.ctipo%TYPE;   --       v_ctipo        VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cclas        cass.cclas%TYPE;   --       v_cclas        VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_desclas      cass.desclas%TYPE;   --       v_desclas      VARCHAR2(80); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cassase      cassdet_01.ncass_ase%TYPE;   --       v_cassase      VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cassbene     cassdet_01.ncass_bene%TYPE;   --       v_cassbene     VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nombene      cassdet_01.nom_bene%TYPE;   --       v_nombene      VARCHAR2(80); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_npagament    cassdet_01.npago%TYPE;   --       v_npagament    VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nfull        cassdet_01.nhoja%TYPE;   --       v_nfull        VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nlinies      cassdet_01.nlin%TYPE;   --       v_nlinies      VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idfulle      cassdet_01.cidenti%TYPE;   --       v_idfulle      VARCHAR2(30); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ndetpagament cassdet_01.nlindet%TYPE;   --       v_ndetpagament VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cnatu        cassdet_01.cacto%TYPE;   --       v_cnatu        VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_desnatu      cassdet_01.tacto%TYPE;   --       v_desnatu      VARCHAR2(80); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_facte        cassdet_01.facto%TYPE := 1;   --       v_facte        VARCHAR2(20) := 1; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_quantitat    cassdet_01.nacto%TYPE;   --       v_quantitat    VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_tarifacass   cassdet_01.itarcass%TYPE;   --       v_tarifacass   VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_percent      cassdet_01.preemb%TYPE;   --       v_percent      VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_imppagament  cassdet_01.impcass%TYPE;   --       v_imppagament  VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_metge        cassdet_01.convenc%TYPE;   --       v_metge        VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ltexto         VARCHAR2(2000);
      num_err        NUMBER;
      pcidioma       NUMBER := 1;
      semafor        BOOLEAN;
      campos         pac_facturas.t_campos
               := pac_facturas.t_campos('a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a');
      v_num_linia    NUMBER := 0;
      --
      w_hiha_error   BOOLEAN := FALSE;
      w_error        NUMBER;
      w_dades_contracte_incorrectes BOOLEAN := FALSE;
      v_nom_sense_txt VARCHAR2(200);
      --
      PRAGMA AUTONOMOUS_TRANSACTION;
----------------------------  p_lee    --------------------------------------
   BEGIN
      BEGIN
         SELECT cempres
           INTO empresa
           FROM usuarios
          WHERE cusuari = f_user;
      END;

      -- abrir fichero
      n_linerr := 1030;
      fin := pac_facturas.abrir(v_nombre, 'r');

--------------------------------------------------------------------------
      WHILE FINAL = 0 LOOP
         BEGIN
            n_linerr := 1080;
            UTL_FILE.get_line(fin, linea);
            v_num_linia := v_num_linia + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               FINAL := 1;
         END;

         tipo_registro := SUBSTR(linea, 1, 1);
         tipo_prestacion := SUBSTR(linea, 23, 4);

         IF tipo_registro = '1' THEN
            IF tipo_prestacion = '0001' THEN
               --Línia de capçalera de prestació de reemborsament de despeses médiques
               pac_facturas.desplegar_fijo(linea, pac_facturas.cabecera, campos);
               v_ccompani := campos(2);
               v_fremesa := campos(3);
               v_nremesa := campos(4);
               v_ctipo := campos(5);
               v_cclas := campos(6);
               v_desclas := campos(7);

               --Insertem la capçalera (CASS)
               INSERT INTO cass
                           (ccompani, fremesa, nremesa, ctipo, cclas, desclas,
                            fcarga)
                    VALUES (v_ccompani, v_fremesa, v_nremesa, v_ctipo, v_cclas, v_desclas,
                            f_sysdate);

               v_linact := 0;
               semafor := TRUE;
            ELSE
               semafor := FALSE;
            END IF;
         ELSIF tipo_registro = '2'
               AND semafor THEN
            --Línia de detall: Capçalera de pagament
            pac_facturas.desplegar_fijo(linea, pac_facturas.detaller2, campos);
            v_cassase := campos(2);
            v_cassbene := campos(3);
            v_nombene := campos(4);
            v_npagament := campos(5);
            v_nfull := campos(6);
            v_nlinies := campos(7);
            v_idfulle := campos(8);
         ELSIF tipo_registro = '3'
               AND semafor THEN
            v_linact := v_linact + 1;
            --Línia de detall: Detall de pagament de prestació
            pac_facturas.desplegar_fijo(linea, pac_facturas.detaller3, campos);
            v_ndetpagament := campos(2);
            v_cnatu := campos(3);
            v_desnatu := campos(4);
            v_facte := campos(5);
            v_quantitat := campos(6);
            v_tarifacass := campos(7);
            v_percent := campos(8);
            v_imppagament := campos(9);
            v_metge := campos(10);
            num_err := f_datos_contrato(v_cassbene, v_facte, v_nremesa, psproces, v_sseguro,
                                        v_nriesgo, v_cgarant, v_sperson, v_agr_salud);

            IF num_err <> 0 THEN
               -- Detectem si hi ha error, però continuem el procés.
               num_err := f_proceslin(psproces,
                                      'NºCASS:' || v_cassbene || ' NºLINEA:' || v_linact,
                                      v_nremesa, nprolin);
               w_dades_contracte_incorrectes := TRUE;
            END IF;

            --
            BEGIN
               INSERT INTO cassdet_01
                           (nremesa, nlinea, ncass_ase, ncass_bene, nom_bene,
                            npago, nhoja, nlin, cidenti, nlindet,
                            cacto, tacto, facto, nacto, itarcass,
                            preemb, impcass, convenc, sseguro, nriesgo,
                            cgarant, agr_salud, sperson)
                    VALUES (v_nremesa, v_linact, v_cassase, v_cassbene, v_nombene,
                            v_npagament, v_nfull, v_nlinies, v_idfulle, v_ndetpagament,
                            v_cnatu, v_desnatu, v_facte, v_quantitat, v_tarifacass,
                            v_percent, v_imppagament, v_metge, v_sseguro, v_nriesgo,
                            v_cgarant, v_agr_salud, v_sperson);
            EXCEPTION
               WHEN OTHERS THEN
                  -- Detectem si hi ha error, però continuem el procés.
                  w_hiha_error := TRUE;
            END;
         END IF;
--------------------------------------------------------------------------
      END LOOP;

      --
      COMMIT;
      UTL_FILE.fclose(fin);

      -- Si es produeix algun error al recuperar dades de la funció f_datos_contrato.
      IF w_dades_contracte_incorrectes = TRUE THEN
         BEGIN
            p_enviar_correo(f_parinstalacion_t('MAIL_ENVIO'), f_parinstalacion_t('MAILERRTO'),
                            'Càrrega CASS(No respondre)', NULL,
                            'ERROR DADES CONTRACTE CASS - '
                            || TO_CHAR(f_sysdate, 'DD/MM/YYYY HH24:MI:SS'),
                            'Nom fitxer: ' || v_nombre
                            || ' Error al recuperar dades del contracte. sproces=' || psproces);   -- BUG10604:DRA:01/07/2009
         EXCEPTION
            WHEN OTHERS THEN
               -- BUG10604:DRA:01/07/2009:Inici
               p_tab_error(f_sysdate, f_user, 'pac_cass.p_lee', 1,
                           SUBSTR('Error al recuperar dades del contracte. sproces='
                                  || psproces,
                                  1, 500),
                           SQLERRM);
         -- BUG10604:DRA:01/07/2009:Fi
         END;

         -- Finalitzem el procés amb el codi d'error a PROCESOSCAB.
         w_error := f_procesfin(psproces, 101);
      END IF;

      -- Es controla si hi ha hagut algun error insertant el detall a la taula cassdet_01.
      IF w_hiha_error = FALSE THEN
         v_nom_sense_txt := RTRIM(v_nombre, '.txt');
         UTL_FILE.frename(p_path, v_nombre, p_path,
                          v_nom_sense_txt || '_' || TO_CHAR(f_sysdate(), 'RRRRMMDD') || '_'
                          || TO_CHAR(f_sysdate(), 'HH24MISS') || '.CGD',
                          TRUE);
      ELSE
         v_nom_sense_txt := RTRIM(v_nombre, '.txt');
         UTL_FILE.frename(p_path, v_nombre, p_path,
                          v_nom_sense_txt || '_' || TO_CHAR(f_sysdate(), 'RRRRMMDD') || '_'
                          || TO_CHAR(f_sysdate(), 'HH24:MI:SS') || '.BAD',
                          TRUE);

         BEGIN
            p_enviar_correo(f_parinstalacion_t('MAIL_ENVIO'), f_parinstalacion_t('MAILERRTO'),
                            'Càrrega CASS(No respondre)', NULL,
                            'ERROR CÀRREGA CASS - '
                            || TO_CHAR(f_sysdate, 'DD/MM/YYYY HH24:MI:SS'),
                            'Nom fitxer: ' || v_nombre || '. sproces=' || psproces);   -- BUG10604:DRA:01/07/2009
         EXCEPTION
            WHEN OTHERS THEN
               -- BUG10604:DRA:01/07/2009:Inici
               p_tab_error(f_sysdate, f_user, 'pac_cass.p_lee', 2,
                           SUBSTR('Nom fitxer: ' || v_nombre || '. sproces=' || psproces, 1,
                                  500),
                           SQLERRM);
         -- BUG10604:DRA:01/07/2009:Fi
         END;

         -- Finalitzem el procés amb el codi d'error a PROCESOSCAB.
         w_error := f_procesfin(psproces, 102);
      END IF;

      -- Controlem el procés de generació de reemborsament.
      IF f_genera_reemb(v_nremesa, psproces) <> 0 THEN
         ltexto := 'NOM FITXER:' || CHR(10) || p_nombre || CHR(10) || CHR(10) || 'DATA:'
                   || CHR(10) || TO_CHAR(f_sysdate, 'DD/MM/YYYY HH24:MI') || CHR(10)
                   || CHR(10) || 'ERROR:' || CHR(10)
                   || '4.-GENERACIÓ REEMBORSAMENTS AUTOMÀTICS' || CHR(10) || CHR(10)
                   || 'USUARI:' || CHR(10) || f_user;

         BEGIN
            p_enviar_correo(f_parinstalacion_t('MAIL_ENVIO'), f_parinstalacion_t('MAILERRTO'),
                            'Càrrega CASS(No respondre)', NULL,
                            'ERROR GENERA REEMBORSAMENT - '
                            || TO_CHAR(f_sysdate, 'DD/MM/YYYY HH24:MI:SS'),
                            ltexto || '. sproces=' || psproces);   -- BUG10604:DRA:01/07/2009
         EXCEPTION
            WHEN OTHERS THEN
               -- BUG10604:DRA:01/07/2009:Inici
               p_tab_error(f_sysdate, f_user, 'pac_cass.p_lee', 3,
                           SUBSTR(ltexto || '. sproces=' || psproces, 1, 500), SQLERRM);
         -- BUG10604:DRA:01/07/2009:Fi
         END;

         -- Finalitzem el procés amb el codi d'error a PROCESOSCAB. ( Hi ha hagut algun error)
         w_error := f_procesfin(psproces, 103);
      ELSE
         -- Finalitzem el procés.
         UPDATE procesoscab
            SET fprofin = f_sysdate()
          WHERE sproces = psproces;
      END IF;
------------------------------  p_lee    ------------------------------------
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         UTL_FILE.fclose(fin);
         UTL_FILE.frename(p_path, v_nombre, p_path,
                          v_nombre || '_' || TO_CHAR(f_sysdate(), 'RRRRMMDD') || '.BAD', TRUE);
         num_err := f_proceslin(psproces, 'ERROR P_LEE:' || SQLERRM, v_nremesa, nprolin);
         -- Finalitzem el procés amb el codi d'error a PROCESOSCAB.
         w_error := f_procesfin(psproces, 104);
-----------------------------------------------------------------------
         ltexto := '3.-NOM FITXER:' || CHR(10) || p_nombre || CHR(10) || CHR(10) || 'LÍNIA:'
                   || CHR(10) || linea || CHR(10) || CHR(10) || 'ERROR:' || CHR(10) || SQLERRM
                   || CHR(10) || CHR(10) || 'USUARI:' || CHR(10) || f_user;

         BEGIN
            p_enviar_correo(f_parinstalacion_t('MAIL_ENVIO'), f_parinstalacion_t('MAILERRTO'),
                            'Càrrega CASS(No respondre)', NULL,
                            'ERROR CÀRREGA CASS - '
                            || TO_CHAR(f_sysdate, 'DD/MM/YYYY HH24:MI:SS'),
                            ltexto || '. sproces=' || psproces);   -- BUG10604:DRA:01/07/2009
         EXCEPTION
            WHEN OTHERS THEN
               -- BUG10604:DRA:01/07/2009:Inici
               p_tab_error(f_sysdate, f_user, 'pac_cass.p_lee', 4,
                           SUBSTR(ltexto || '. sproces=' || psproces, 1, 500), SQLERRM);
         -- BUG10604:DRA:01/07/2009:Fi
         END;
----------------------------  p_lee    --------------------------------------
   END p_lee;

   /*************************************************************************
     Rutina per recuperar les dades d'un contracte.
     param in  pcassbene  : Número CASS del beneficiari.
     param in  pfacto     : Data de l¿acte, format AAAAMMDD.
     param in  pnremesa   : Nº remesa
     param in  psproces   : Nº procés
     param out psseguro   : Número de seguro.
     param out pnriesgo   : Número risc.
     param out pcgarant   : Códi garantia
     param out psperson   : Id. persona
     param out pagr_salud :
   *************************************************************************/
   -- Bug 8072.MCA.26/06/2009.CRE012 - Pruebas de carga de ficheros de reembolsos.
   FUNCTION f_datos_contrato(
      pcassbene IN VARCHAR2,
      pfacto IN VARCHAR2,
      pnremesa IN VARCHAR2,
      psproces IN NUMBER,
      psseguro IN OUT NUMBER,
      pnriesgo IN OUT NUMBER,
      pcgarant IN OUT NUMBER,
      psperson IN OUT NUMBER,
      pagr_salud IN OUT VARCHAR2)
      RETURN NUMBER IS
      vsseguro       NUMBER;
      nprolin        NUMBER;
      num_err        NUMBER;
      --
      w_error        NUMBER;
      v_sproduc      seguros.sproduc%TYPE;   --       v_sproduc      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   --
   BEGIN
      -- Bug 9685 - APD - 26/05/2009 - en lugar de coger la actividad de la tabla seguros,
      -- llamar a la función pac_seguros.ff_get_actividad
      -- Bug 11176 - 21/09/2009 - AMC - Se incluye el csituac 5
      BEGIN
         SELECT r.sseguro, r.nriesgo, g.cgarant, r.sperson, s.sproduc
           INTO psseguro, pnriesgo, pcgarant, psperson, v_sproduc
           FROM pregunseg e, garanseg g, seguros s, riesgos r
          WHERE e.trespue = pcassbene
            AND e.cpregun = 530
            AND e.sseguro = r.sseguro
            AND e.nriesgo = r.nriesgo
            AND s.sseguro = r.sseguro
            AND g.sseguro = r.sseguro
            AND g.nriesgo = r.nriesgo
            AND g.nmovimi = e.nmovimi
            AND g.nmovimi = (SELECT MAX(nmovimi)
                               FROM garanseg g2
                              WHERE g2.sseguro = g.sseguro
                                AND g2.nriesgo = g.nriesgo
                                AND g2.cgarant = g.cgarant
                                AND TRUNC(g2.finiefe) <= TO_DATE(pfacto, 'YYYYMMDD'))
            AND g.cgarant = 80   --Garantía de reembolso
            AND pac_productos.f_essalud(NULL, s.sseguro) =
                  1   -- 11/08/2010  SMF              21. 0015711: AGA003 - standaritzación del pac_cass
            AND s.csituac IN(0, 5)   --vigente, propuesta de suplemento
            -- Mantis 10682.01/07/2009.S'elimina exception i afegeix condició.i.
            AND(r.fanulac IS NULL   -- BUG13927:DRA:21/04/2010:Volvemos a dejarla igual
                OR TO_DATE(pfacto, 'YYYYMMDD') < r.fanulac);   -- Mantis 10682.f.
      --
      EXCEPTION
         -- bug 12813.NMM.i.
         WHEN TOO_MANY_ROWS THEN
            SELECT MIN(r.sseguro)
              INTO psseguro
              FROM pregunseg e, garanseg g, seguros s, riesgos r
             WHERE e.trespue = pcassbene
               AND e.cpregun = 530
               AND e.sseguro = r.sseguro
               AND e.nriesgo = r.nriesgo
               AND s.sseguro = r.sseguro
               AND g.sseguro = r.sseguro
               AND g.nriesgo = r.nriesgo
               AND g.nmovimi = e.nmovimi
               AND g.nmovimi = (SELECT MAX(nmovimi)
                                  FROM garanseg g2
                                 WHERE g2.sseguro = g.sseguro
                                   AND g2.nriesgo = g.nriesgo
                                   AND g2.cgarant = g.cgarant
                                   AND TRUNC(g2.finiefe) <= TO_DATE(pfacto, 'YYYYMMDD'))
               AND g.cgarant = 80
               AND pac_productos.f_essalud(NULL, s.sseguro) =
                     1   -- 11/08/2010  SMF              21. 0015711: AGA003 - standaritzación del pac_cass
               AND s.csituac IN(0, 5)
               AND(r.fanulac IS NULL   -- BUG13927:DRA:21/04/2010:Volvemos a dejarla igual
                   OR TO_DATE(pfacto, 'YYYYMMDD') < r.fanulac)
               AND TRUNC(s.fefecto) <= TO_DATE(pfacto, 'YYYYMMDD');

            --
            SELECT r.nriesgo, g.cgarant, r.sperson, s.sproduc
              INTO pnriesgo, pcgarant, psperson, v_sproduc
              FROM pregunseg e, garanseg g, seguros s, riesgos r
             WHERE e.trespue = pcassbene
               AND e.cpregun = 530
               AND e.sseguro = r.sseguro
               AND e.nriesgo = r.nriesgo
               AND s.sseguro = r.sseguro
               AND g.sseguro = r.sseguro
               AND g.nriesgo = r.nriesgo
               AND g.nmovimi = e.nmovimi
               AND g.nmovimi = (SELECT MAX(nmovimi)
                                  FROM garanseg g2
                                 WHERE g2.sseguro = g.sseguro
                                   AND g2.nriesgo = g.nriesgo
                                   AND g2.cgarant = g.cgarant
                                   AND TRUNC(g2.finiefe) <= TO_DATE(pfacto, 'YYYYMMDD'))
               AND g.cgarant = 80
               AND pac_productos.f_essalud(NULL, s.sseguro) =
                     1   -- 11/08/2010  SMF              21. 0015711: AGA003 - standaritzación del pac_cass
               AND s.csituac IN(0, 5)
               AND(r.fanulac IS NULL   -- BUG13927:DRA:21/04/2010:Volvemos a dejarla igual
                   OR TO_DATE(pfacto, 'YYYYMMDD') < r.fanulac)
               AND r.sseguro = psseguro;   -- Mantis 12813.f.
         --
         WHEN OTHERS THEN
            psseguro := NULL;
            pnriesgo := NULL;
            pcgarant := NULL;
            psperson := NULL;
            pagr_salud := NULL;
            RETURN(1000452);
      END;

      --Se encuentra la agrupación
      SELECT f_parproductos_v(v_sproduc, 'AGR_SALUD') agr_salud
        INTO pagr_salud
        FROM DUAL;

      -- Bug 9685 - APD - 26/05/2009 - fin
      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         psseguro := NULL;
         pnriesgo := NULL;
         pcgarant := NULL;
         psperson := NULL;
         pagr_salud := NULL;
         RETURN(1000452);
   END f_datos_contrato;

   -- Bug 8072.MCA.26/06/2009.FIN.
   /***********************************************************************
      Comprova si el full electrònic ja existeix en algun reemb. anterior
      param in premesa: Número de remessa
   ***********************************************************************/
   FUNCTION f_comprova_full(
      p_full_elec IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nreemb OUT NUMBER,
      p_nfact OUT NUMBER)
      RETURN NUMBER IS
      v_sseguro      reembolsos.sseguro%TYPE;   --       v_sseguro      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nriesgo      reembolsos.nriesgo%TYPE;   --       v_nriesgo      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER;
   BEGIN
      -- BUG11629:DRA:02/11/2009: Inici
      SELECT r1.nreemb
        INTO p_nreemb
        FROM reembolsos r, reembfact r1
       WHERE r.nreemb = r1.nreemb
         AND r.cestado NOT IN(4, 5)
         AND r1.nfact_cli = p_full_elec
         AND r1.fbaja IS NULL
         AND ROWNUM = 1;

      SELECT TO_NUMBER(SUBSTR(MAX(nfact), 7))
        INTO p_nfact
        FROM reembfact r2
       WHERE r2.nreemb = p_nreemb;

      -- BUG11629:DRA:02/11/2009: Fi
      SELECT sseguro, nriesgo
        INTO v_sseguro, v_nriesgo
        FROM reembolsos
       WHERE nreemb = p_nreemb;

      IF (v_sseguro <> p_sseguro)
         OR(v_nriesgo <> p_nriesgo) THEN
         p_nfact := 0;
         num_err := pac_reembolsos.ff_contador_reembolsos(p_sseguro, p_nreemb);
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_nfact := 0;
         num_err := pac_reembolsos.ff_contador_reembolsos(p_sseguro, p_nreemb);
         RETURN num_err;
   END f_comprova_full;

   /***********************************************************************
      Rutina de creació dels reemborsaments corresponents a partir de
      cass i cassdet_01.
      param in PREMESA  : Nº remesa
      param in PSPROCES : Nº procés
   ***********************************************************************/
   FUNCTION f_genera_reemb(premesa IN VARCHAR2, psproces IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_fact IS
         SELECT   sperson, sseguro, nriesgo, cgarant, agr_salud, ncass_ase, ncass_bene, nhoja,
                  0 convenc, npago   -- BUG14227:DRA:22/04/2010
             FROM cassdet_01
            WHERE nremesa = premesa
              AND sseguro IS NOT NULL
         GROUP BY sperson, sseguro, nriesgo, cgarant, agr_salud, ncass_ase, ncass_bene, nhoja,
                  npago;

      -- BUG 8072.MCA.26/06/2009.INI.
      CURSOR c_actos(
         psperson IN NUMBER,
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pcgarant IN NUMBER,
         pagr_salud IN VARCHAR2,
         pncass_asse IN VARCHAR2,
         pncass_bene IN VARCHAR2,
         pnhoja IN VARCHAR2,
         pnpago IN VARCHAR2)   -- BUG14227:DRA:22/04/2010
                            IS
         -- BUG 11197 - 21/09/2009 - AMC - Modificaciones en la select del cursor nacto y itarcass
         SELECT   RTRIM(cacto) cacto, facto, (SUM(nacto / 100)) / COUNT(8) nacto,
                  (SUM(itarcass / 100)) / COUNT(8) itarcass, SUM(preemb / 100) preemb,
                  SUM(impcass / 100) impcass
             FROM cassdet_01
            WHERE nremesa = premesa
              AND sperson = psperson
              AND sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND agr_salud = pagr_salud
              AND ncass_ase = pncass_asse
              AND ncass_bene = pncass_bene
              AND nhoja = pnhoja
              AND npago = pnpago   -- BUG14227:DRA:22/04/2010
         GROUP BY RTRIM(cacto), facto;   -- BUG10761:DRA:22/07/2009

      -- BUG 8072.MCA.26/06/2009.FIN.
      pnreemb        reembolsos.nreemb%TYPE;   --       pnreemb        NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cbancar      seguros.cbancar%TYPE;   --       v_cbancar      VARCHAR2(24); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ctipban      seguros.ctipban%TYPE;   --       v_ctipban      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      nfact          NUMBER(2) := 0;
      v_impregalo    actos_garanpro.impregalo%TYPE;   --       v_impregalo    NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ipago        reembactosfac.cerror%TYPE;   --       v_ipago        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nfact        reembfact.nfact%TYPE;   --       v_nfact        VARCHAR2(10); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_smancont     NUMBER;
      v_cerror       VARCHAR2(1);
      num_err        NUMBER;
      vpabonado      actos_garanpro.pabonado%TYPE;
      v_error_actos  BOOLEAN := FALSE;
      nprolin        NUMBER;
      v_pas          VARCHAR2(100);
      v_error        NUMBER(2) := 0;
      -- bug 0010266: etm : 02-06-2009--INI
      v_movimi       NUMBER(4);
      -- bug 0010266: etm : 02-06-2009--FIN
      --
      w_error        NUMBER;
      num_err2       reembactosfac.cerror%TYPE;   --       num_err2       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      msg_error      VARCHAR2(300);
      --
      v_exists_reemb BOOLEAN;   -- BUG10631:DRA:06/07/2009
      v_cacto        actos_garanpro.cacto%TYPE;   --       v_cacto        VARCHAR2(10);   -- BUG10631:DRA:06/07/2009 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Mantis 10682.NMM.01/07/2009.i.
      w_nriesgo      riesgos.nriesgo%TYPE;
      w_ncass_ase    cassdet_01.ncass_ase%TYPE;   -- Mantis 10682.NMM.01/07/2009.f.
      -- MCA 15/07/2009
      v_sproduc      seguros.sproduc%TYPE;   --       v_sproduc      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cpregun      NUMBER;
      ----
      v_numlin       NUMBER;   -- BUG10761:DRA:22/07/2009
      w_fremesa      cass.fremesa%TYPE;   -- Bug 11085.NMM.09/09/2009.
      w_nremesa      cass.nremesa%TYPE;
   --
   BEGIN
--------------------------------------------------------------------------
      FOR reg_fac IN c_fact LOOP
         BEGIN
            v_pas := 'Comprovació full electrònic';
            v_exists_reemb := TRUE;   -- BUG10631:DRA:06/07/2009
            num_err := f_comprova_full(reg_fac.nhoja, reg_fac.sseguro, reg_fac.nriesgo,
                                       pnreemb, nfact);

            IF num_err = 0 THEN
               SELECT MAX(nmovimi)
                 INTO v_movimi
                 FROM movseguro
                WHERE sseguro = reg_fac.sseguro;

               IF nfact = 0 THEN
                  -- bug 0010266: etm : 02-06-2009--INI
                  --
                  v_pas := 'Comprovació Resposta Preg 9000-9001';

                  --esta respondida la pregun
                  BEGIN
                     SELECT crespue
                       INTO v_ctipban
                       FROM pregunpolseg
                      WHERE sseguro = reg_fac.sseguro
                        AND cpregun = 9000
                        AND nmovimi = (SELECT MAX(p2.nmovimi)
                                         FROM pregunpolseg p2
                                        WHERE p2.sseguro = reg_fac.sseguro
                                          AND p2.cpregun = 9000);   --12025  MCA 27/11/2009  v_movimi;

                     SELECT trespue
                       INTO v_cbancar
                       FROM pregunpolseg
                      WHERE sseguro = reg_fac.sseguro
                        AND cpregun = 9001
                        AND nmovimi = (SELECT MAX(p2.nmovimi)
                                         FROM pregunpolseg p2
                                        WHERE p2.sseguro = reg_fac.sseguro
                                          AND p2.cpregun = 9001);   --12025  MCA 27/11/2009  v_movimi;
                  EXCEPTION
                     WHEN OTHERS THEN
                        -- bug 0010266: etm : 02-06-2009--FIN
                        SELECT cbancar, ctipban
                          INTO v_cbancar, v_ctipban
                          FROM seguros
                         WHERE sseguro = reg_fac.sseguro;
                  END;

                  v_pas := 'Insert Reembolsos';
                  v_exists_reemb := FALSE;   -- BUG10631:DRA:06/07/2009

                  INSERT INTO reembolsos
                              (nreemb, sseguro, nriesgo, cgarant,
                               agr_salud, sperson, cestado, festado, cbancar,
                               ctipban, falta, cusualta, corigen)
                       VALUES (pnreemb, reg_fac.sseguro, reg_fac.nriesgo, reg_fac.cgarant,
                               reg_fac.agr_salud, reg_fac.sperson, 2, f_sysdate, v_cbancar,
                               v_ctipban, f_sysdate, f_user, 0);
               END IF;

               nfact := nfact + 1;
               v_nfact := TO_CHAR(f_sysdate, 'yyyymm') || TO_CHAR(nfact);
               v_pas := 'Inserció factures';

               --MCA 15/07/2009
               SELECT sproduc
                 INTO v_sproduc
                 FROM seguros
                WHERE sseguro = reg_fac.sseguro;

               IF v_sproduc = 258 THEN   --Pregunta Relación con el titular
                  v_cpregun := 540;
               ELSE
                  v_cpregun := 505;
               END IF;

               -----
               -- Bug 10682.01/07/2009.NMM.Carregar NCASS_ASE del titular de la pòlissa.i.
               SELECT p.nriesgo
                 INTO w_nriesgo
                 FROM pregunseg p
                WHERE p.cpregun = v_cpregun
                  AND p.crespue = 0
                  AND p.sseguro = reg_fac.sseguro
                  AND p.nmovimi = (SELECT MAX(p2.nmovimi)
                                     FROM pregunseg p2
                                    WHERE p2.sseguro = reg_fac.sseguro
                                      --    AND p.nriesgo = p2.nriesgo   -- falla si hi ha dos titulars ex sseguro 69975
                                      AND p2.cpregun = v_cpregun);   --  11978 MCA 27/11/2009  v_movimi;

               --
               SELECT p.trespue
                 INTO w_ncass_ase
                 FROM pregunseg p
                WHERE p.cpregun = 530
                  AND p.sseguro = reg_fac.sseguro
                  AND p.nmovimi = (SELECT MAX(p2.nmovimi)
                                     FROM pregunseg p2
                                    WHERE p2.sseguro = reg_fac.sseguro
                                      AND p2.nriesgo = w_nriesgo
                                      AND p2.cpregun = 530)   -- 11978  MCA 27/11/2009  v_movimi
                  AND p.nriesgo = w_nriesgo;

               -- Bug 11085.NMM.09/09/2009.i.
               SELECT fremesa, nremesa
                 INTO w_fremesa, w_nremesa
                 FROM cass
                WHERE nremesa = premesa;

               -- Bug 11085.f.
               INSERT INTO reembfact
                           (nreemb, nfact, nfact_cli, ncass_ase, ncass,
                            facuse, ffactura, impfact, ctipofac, cimpresion,   -- BUG10704:DRA:14/07/2009
                                                                            falta,
                            cusualta, corigen, nfactext)   -- BUG11190:DRA:06/10/2009     -- BUG14227:DRA:22/04/2010
                    VALUES (pnreemb, v_nfact, reg_fac.nhoja, w_ncass_ase, reg_fac.ncass_bene,
                            f_sysdate, TO_DATE(w_fremesa, 'YYYYMMDD'),   -- Bug 11085.NMM.09/09/2009.
                                                                      0, 1, 'N',   -- BUG10704:DRA:14/07/2009
                                                                                f_sysdate,
                            f_user, 0, reg_fac.npago);   -- BUG11190:DRA:06/10/2009   -- BUG14227:DRA:22/04/2010

-- Bug 10682.f.
-----------------------------------------------------------------
               FOR reg_act IN c_actos(reg_fac.sperson, reg_fac.sseguro, reg_fac.nriesgo,
                                      reg_fac.cgarant, reg_fac.agr_salud, reg_fac.ncass_ase,
                                      reg_fac.ncass_bene, reg_fac.nhoja, reg_fac.npago) LOOP
                  -- BUG10631:DRA:06/07/2009:Inici
                  v_pas := 'SELECT cacto';

                  BEGIN
                     SELECT cacto
                       INTO v_cacto
                       FROM actos_garanpro
                      WHERE cacto = UPPER(reg_act.cacto)
                        AND fvigencia <= TO_DATE(reg_act.facto, 'YYYYMMDD')
                        AND(ffinvig IS NULL
                            OR ffinvig > TO_DATE(reg_act.facto, 'YYYYMMDD'))
                        AND agr_salud = TO_NUMBER(reg_fac.agr_salud)
                        AND cgarant = reg_fac.cgarant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_cacto := 'DES';
                  END;

                  -- BUG10631:DRA:06/07/2009:Fi
                  v_pas := 'SELECT impregalo, pabonado';

                  SELECT impregalo, pabonado
                    INTO v_impregalo, vpabonado
                    FROM actos_garanpro
                   WHERE cacto = v_cacto   -- BUG10631:DRA:06/07/2009
                     AND fvigencia <= TO_DATE(reg_act.facto, 'YYYYMMDD')
                     AND(ffinvig IS NULL
                         OR ffinvig > TO_DATE(reg_act.facto, 'YYYYMMDD'))
                     AND agr_salud = TO_NUMBER(reg_fac.agr_salud)
                     AND cgarant = reg_fac.cgarant;

                  SELECT smancont.NEXTVAL
                    INTO v_smancont
                    FROM DUAL;

                  -- BUG 8072.MCA.26/06/2009.INI.
                  IF reg_fac.agr_salud = '2' THEN   --Crèdit Salut. como máximo se complementa hasta un 25 % tarifa CASS
                     IF ROUND((reg_act.impcass / reg_act.itarcass) * 100) <> reg_act.preemb THEN
                        IF ROUND((reg_act.impcass / reg_act.itarcass) * 100) >= 75 THEN
                           v_ipago := reg_act.nacto *(reg_act.itarcass - reg_act.impcass);
                        ELSE
                           v_ipago := reg_act.nacto *(reg_act.itarcass * 0.25);
                        END IF;
                     ELSE
                        IF reg_act.preemb >= 75 THEN
                           v_ipago := reg_act.nacto *(reg_act.itarcass - reg_act.impcass);
                        ELSE
                           v_ipago := reg_act.nacto *(reg_act.itarcass * 0.25);
                        END IF;
                     END IF;
                  ELSE   --PIAM
                     v_ipago := reg_act.nacto *(reg_act.itarcass - reg_act.impcass);
                  END IF;

                  -- BUG 8072.MCA.26/06/2009.FIN.
                  v_pas := 'Inserció línies';

                  -- BUG10761:DRA:22/07/2009:Inici
                  SELECT MAX(nlinea) + 1
                    INTO v_numlin
                    FROM reembactosfac
                   WHERE nreemb = pnreemb
                     AND nfact = v_nfact;

                  -- BUG10761:DRA:22/07/2009:Fi
                  INSERT INTO reembactosfac
                              (nreemb, nfact, nlinea, cacto, nacto,
                               facto, itarcass,
                               preemb, icass, itot, iextra,
                               ipago, iahorro, cerror, fbaja, falta, ftrans, cusualta,
                               corigen, nremesa, ctipo)   -- BUG10704:DRA:14/07/2009
                       --BUG11285-XVM-02102009
                  VALUES      (pnreemb, v_nfact, NVL(v_numlin, 1),   -- BUG10761:DRA:22/07/2009
                                                                  v_cacto, reg_act.nacto,
                               TO_DATE(reg_act.facto, 'YYYYMMDD'), reg_act.itarcass,
                               reg_act.preemb, reg_act.impcass, reg_act.itarcass, v_impregalo,
                               v_ipago, NULL, 0, NULL, f_sysdate, NULL, f_user,
                               0, NULL, reg_fac.convenc);   -- BUG10704:DRA:14/07/2009

-----------------------------------------------------------------
                  v_pas := 'Validació reemb.';
                  num_err2 :=
                     pac_control_reembolso.f_validareemb
                                                     (reg_fac.convenc, reg_fac.sseguro,
                                                      reg_fac.nriesgo, reg_fac.cgarant,
                                                      reg_fac.sperson, reg_fac.agr_salud,
                                                      v_cacto,   -- BUG10631:DRA:06/07/2009
                                                      reg_act.nacto,
                                                      TO_DATE(reg_act.facto, 'YYYYMMDD'),
                                                      reg_act.itarcass, pnreemb, v_nfact,
                                                      NVL(v_numlin, 1),   -- BUG10761:DRA:22/07/2009
                                                      v_smancont, reg_fac.nhoja, NULL);

                  IF num_err2 > 0 THEN
                     v_error_actos := TRUE;
                  END IF;

                  -- BUG10631:DRA:06/07/2009:Inici
                  -- Si se ha reaprovechado un reembolso, se ponen su actos a cerror = 100
                  IF v_exists_reemb
                     AND num_err2 = 0 THEN
                     num_err2 := 100;
                     v_error_actos := TRUE;
                  END IF;

                  -- BUG10631:DRA:06/07/2009:Fi

                  --Actualización del tipo de error si no ha pasado alguna validación
                  UPDATE reembactosfac
                     SET cerror = num_err2
                   WHERE nreemb = pnreemb
                     AND nfact = v_nfact
                     AND nlinea = NVL(v_numlin, 1);   -- BUG10761:DRA:22/07/2009
               END LOOP;

               IF v_error_actos = TRUE THEN
                  -- posem l'estat del reemborsament a Gestió companyia
                  v_pas := 'Actualització reemb.';

                  UPDATE reembolsos
                     SET cestado = 1
                   WHERE nreemb = pnreemb;
               END IF;

               -- jgm - BUG 10949 - 18/08/2009
               v_error_actos := FALSE;
            END IF;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               p_tab_error(f_sysdate, f_user, 'F_GENERA', 1, 'ERROR: ' || SQLERRM,
                           'nreemb: ' || pnreemb || ' nfact: ' || v_nfact);
               msg_error := SUBSTR('Error:' || v_pas || ':' || reg_fac.sseguro || ':'
                                   || reg_fac.nriesgo || ':' || reg_fac.sperson || '.',
                                   1, 120);
               w_error := f_proceslin(psproces, msg_error, premesa, nprolin);
               v_error := -1;
         END;
--------------------------------------------------------------------------
      END LOOP;

      RETURN(v_error);
   END f_genera_reemb;
END pac_cass;

/

  GRANT EXECUTE ON "AXIS"."PAC_CASS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CASS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CASS" TO "PROGRAMADORESCSI";
