--------------------------------------------------------
--  DDL for Package Body PAC_RETORNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_RETORNO" AS
   /******************************************************************************
     NOMBRE:     pac_retorno
     PROPÓSITO:  Package para gestionar los retornos de convenios beneficiarios

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        03/09/2012   JMF             0022701: LCOL: Implementación de Retorno
     2.0        15/10/2012   JMF             0023965: LCOL: Anulación de póliza con Retorno
     3.0        24/10/2012   JMF             0024132 LCOL_C003-LCOL Resoldre incidncies en el manteniment de Retorno
     4.0        25/10/2012   DRA             0023853: LCOL - PRIMAS MÍNIMAS PACTADAS POR PÓLIZA Y POR COBRO
     5.0        16/11/2012   DRA             0024271: LCOL_T010-LCOL - SUPLEMENTO DE TRASLADO DE VIGENCIA
     6.0        28/11/2012   JMF             0024892 LCOL_C003-LCOL Q-trackers de Retornos
     7.0        11/12/2012   ECP             0025060: LCOL_C003-LCOL: Q-trackers de Retorno
     8.0        07/01/2013   DCT             0025357: LCOL_T020-LCOL-COA Nuevos conceptos Cuenta Coaseguro
     9.0        08/01/2013   JMF             0025580: LCOL_C003-LCOL: Parametrizar tomador en el convenio de retorno
    10.0        22/01/2013   JMF             0025815: LCOL: Cambios para Retorno seg?n reuni?n con Comercial
    11.0        08/02/2013   MAL             0025942: LCOL: Ajuste de q-trackers retorno
    12.0        18/02/2013   DRA             0026111: LCOL: Revisar Retorno en Colectivos
    13.0        20/02/2013   FAL             0025691: LCOL: Validaciones m?dulo de retornos
    14.0        28/02/2013   DRA             0026229: LCOL: Retorno sobre el recibo de Regularizaci?n de prima m?nima
    15.0        26/08/2013   DRA             0027994: LCOL: Incluir concepto de recargo fraccionamiento
    16.0        08/01/2014   MMS             0027417: POSRA300 - Configuracion Ramo Accidentes - Generacion Positiva
    17.0        05/02/2014   JSV             0029991: LCOL_T010-Revision incidencias qtracker (2014/02)
    18.0        17/02/2014   RCL             0029991: LCOL_T010-Revision incidencias qtracker (2014/02)
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   -- Esta función nos devuelve un VARCHAR2 con la lista de los convenios en función de una série de valores que recibe por parámetros.
   -- BUG 0025691 - 15/01/2013 - JMF: afegir sucursal i adn
   FUNCTION f_get_lstconvenios(
      pccodconv IN VARCHAR2,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      ptnombnf IN VARCHAR2,
      psucursal IN NUMBER,
      padnsuc IN NUMBER)
      RETURN VARCHAR2 IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_get_lstconvenios';
      vpar           VARCHAR2(500)
         := 'c=' || pccodconv || ' t=' || ptdesconv || ' i=' || pfinivig || ' f=' || pffinvig
            || ' r=' || pcramo || ' p=' || psproduc || ' a=' || pcagente || ' n=' || ptnombnf
            || ' s=' || psucursal || ' a=' || padnsuc;
      vquery         VARCHAR2(2000);
      v_auxnom       VARCHAR2(2000);
      num_err        NUMBER;
      v_ini          VARCHAR2(20);
      v_fin          VARCHAR2(20);
   BEGIN
      vpas := 100;
      /***************************
      -- anulat 19-09-12
      IF pccodconv IS NULL
         AND ptdesconv IS NULL
         AND pfinivig IS NULL
         AND pffinvig IS NULL
         AND pcramo IS NULL
         AND psproduc IS NULL
         AND pcagente IS NULL
         AND ptnombnf IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;
      ***************************/
      vpas := 110;
      vquery := 'SELECT c.* FROM RTN_MNTCONVENIO c where 1=1';

      IF pccodconv IS NOT NULL THEN
         vpas := 120;
         -- ini BUG 0025580 - 08/01/2013 - JMF
         -- vquery := vquery || ' and CCODCONV=' || CHR(39) || pccodconv || CHR(39);
         vquery := vquery || ' and CCODCONV like ' || CHR(39) || CHR(37) || pccodconv
                   || CHR(37) || CHR(39);
      -- fin BUG 0025580 - 08/01/2013 - JMF
      END IF;

      IF ptdesconv IS NOT NULL THEN
         vpas := 130;
         vquery := vquery || ' and lower(TDESCONV) like ' || CHR(39) || '%'
                   || LOWER(ptdesconv) || '%' || CHR(39);
      END IF;

      IF pfinivig IS NOT NULL THEN
         vpas := 140;
         v_ini := TO_CHAR(pfinivig, 'yyyymmdd');
         vquery := vquery || ' and FINIVIG >=' || 'to_date(' || CHR(39) || v_ini || CHR(39)
                   || ',''yyyymmdd'')';
      END IF;

      IF pffinvig IS NOT NULL THEN
         vpas := 150;
         v_fin := TO_CHAR(pffinvig, 'yyyymmdd');
         vquery := vquery || ' and FFINVIG <=' || 'to_date(' || CHR(39) || v_fin || CHR(39)
                   || ',''yyyymmdd'')';
      END IF;

      IF pcramo IS NOT NULL THEN
         vpas := 160;
         vquery := vquery || ' and exists (select 1 from RTN_MNTPRODCONVENIO a, productos b'
                   || ' where a.IDCONVENIO=c.IDCONVENIO and b.sproduc=a.sproduc'
                   || ' and b.cramo = ' || pcramo || ')';
      END IF;

      IF psproduc IS NOT NULL THEN
         vpas := 170;
         vquery := vquery || ' and exists (select 1 from RTN_MNTPRODCONVENIO a'
                   || ' where a.IDCONVENIO=c.IDCONVENIO and a.sproduc=' || psproduc || ')';
      END IF;

      IF pcagente IS NOT NULL THEN
         vpas := 180;
         vquery := vquery || ' and exists (select 1 from RTN_MNTAGECONVENIO a'
                   || ' where a.IDCONVENIO=c.IDCONVENIO and a.CAGENTE=' || pcagente || ')';
      END IF;

      IF ptnombnf IS NOT NULL THEN
         vpas := 190;
         num_err := f_strstd(ptnombnf, v_auxnom);
         vpas := 200;
         vquery := vquery || ' and exists (select 1 from RTN_MNTBENEFCONVENIO a, PERSONAS b'
                   || ' where a.IDCONVENIO=c.IDCONVENIO and b.sperson=a.sperson'
                   || ' and upper(b.tbuscar) like upper(''%' || v_auxnom || '%' || CHR(39)
                   || ')' || ')';
      END IF;

      -- BUG 0025691 - 15/01/2013 - JMF: afegir sucursal i adn
      IF psucursal IS NOT NULL
         OR padnsuc IS NOT NULL THEN
         vpas := 210;
         vquery := vquery || ' and    exists (select 1 from rtn_mntageconvenio g'
                   || '                where g.IDCONVENIO=c.IDCONVENIO'
                   || '                and   g.cagente in ('
                   || '                 SELECT r.cagente FROM redcomercial r'
                   || '                  WHERE fmovfin IS NULL'
                   || '                  START WITH cempres = '
                   || pac_md_common.f_get_cxtempresa || '                  AND   cagente = '
                   || NVL(padnsuc, psucursal)
                   || '                  CONNECT BY cpadre = PRIOR cagente'
                   || '                  AND cempres = PRIOR cempres' || '                )'
                   || ' )';
      END IF;

      vpas := 220;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_get_lstconvenios;

   -- Esta función nos devuelve un VARCHAR2 con los datos del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_datconvenio(pidconvenio IN NUMBER)
      RETURN VARCHAR2 IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_get_datconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      vquery         VARCHAR2(2000);
   BEGIN
      vpas := 100;

      IF pidconvenio IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- BUG 0025815 - 22/01/2013 - JMF
      vpas := 110;
      vquery :=
         'SELECT c.*, decode(c.sperson,null,null,F_NOMBRE(c.sperson, 3)) TNOMTOM, d.NNUMIDE'
         || ' FROM  RTN_MNTCONVENIO c, per_personas d' || ' where d.sperson(+)=c.sperson'
         || ' and   c.idconvenio = ' || pidconvenio;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_get_datconvenio;

   -- Esta función nos devuelve un VARCHAR2 con los datos del producto del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_prodconvenio(pidconvenio IN NUMBER, pcramo OUT NUMBER, ptramo OUT VARCHAR2)
      RETURN VARCHAR2 IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_get_prodconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      vquery         VARCHAR2(2000);
      vidioma        NUMBER;
   BEGIN
      vpas := 100;

      IF pidconvenio IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vidioma := f_usu_idioma;
      pcramo := NULL;
      ptramo := NULL;

      SELECT DECODE(COUNT(DISTINCT a.cramo), 1, MAX(a.cramo), NULL),
             DECODE(COUNT(DISTINCT a.cramo), 1, MAX(d.tramo), NULL)
        INTO pcramo,
             ptramo
        FROM productos a, rtn_mntprodconvenio c, ramos d
       WHERE a.sproduc = c.sproduc
         AND c.idconvenio = pidconvenio
         AND d.cramo = a.cramo
         AND d.cidioma = vidioma;

      vpas := 110;
      vquery :=
         'SELECT c.IDCONVENIO, c.SPRODUC, a.ttitulo TPRODUC'
         || ' FROM RTN_MNTPRODCONVENIO c, productos b, titulopro a' || ' WHERE c.idconvenio = '
         || pidconvenio || ' and   b.sproduc=c.sproduc'
         || ' and   a.cramo=b.cramo and a.cmodali=b.cmodali and a.ctipseg=b.ctipseg and a.ccolect=b.ccolect and a.cidioma=f_usu_idioma';
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_get_prodconvenio;

   -- Esta función nos devuelve un VARCHAR2 con los datos del agente del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_ageconvenio(pidconvenio IN NUMBER)
      RETURN VARCHAR2 IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_get_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      vquery         VARCHAR2(2000);
   BEGIN
      vpas := 100;

      IF pidconvenio IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;
      vquery :=
         'SELECT c.*, F_NOMBRE(b.sperson, 3) TNOMAGE FROM RTN_MNTAGECONVENIO c, agentes b'
         || ' WHERE c.idconvenio = ' || pidconvenio || ' and b.cagente=c.cagente';
      /*
      vquery := 'SELECT c.* FROM RTN_MNTAGECONVENIO c' || ' WHERE c.idconvenio = ' || pidconvenio;
      */
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_get_ageconvenio;

   -- Esta función nos devuelve un VARCHAR2 con los datos del beneficiario del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_benefconvenio(pidconvenio IN NUMBER)
      RETURN VARCHAR2 IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_get_benefconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      vquery         VARCHAR2(2000);
   BEGIN
      vpas := 100;

      IF pidconvenio IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;
      vquery := 'SELECT c.*, F_NOMBRE(c.sperson, 3) TNOMBEN FROM RTN_MNTBENEFCONVENIO c'
                || ' WHERE c.idconvenio = ' || pidconvenio;
      --vquery := 'SELECT c.* FROM RTN_MNTBENEFCONVENIO c' || ' WHERE c.idconvenio = ' || pidconvenio;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_get_benefconvenio;

   -- Esta función borra datos del agente del convenio
   FUNCTION f_del_ageconvenio(pidconvenio IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_del_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || pcagente;
      num_err        NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;

      IF pidconvenio IS NULL
         OR pcagente IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;

      DELETE FROM rtn_mntageconvenio
            WHERE idconvenio = pidconvenio
              AND cagente = pcagente;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         -- Error al borrar en la tabla retorno agente convenio.
         RETURN 9904154;
   END f_del_ageconvenio;

   -- Esta función borra datos del beneficiario del convenio
   FUNCTION f_del_benefconvenio(pidconvenio IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_del_benefconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' p=' || psperson;
      num_err        NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;

      IF pidconvenio IS NULL
         OR psperson IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;

      DELETE FROM rtn_mntbenefconvenio
            WHERE idconvenio = pidconvenio
              AND sperson = psperson;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         -- Error al borrar en la tabla retorno beneficiario convenio
         RETURN 9904155;
   END f_del_benefconvenio;

   -- Esta función actualiza datos convenio
   -- BUG 0025815 - 22/01/2013 - JMF: afegir sperson
   FUNCTION f_set_datconvenio(
      pidconvenio IN NUMBER,
      pccodconv IN VARCHAR2,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcuseraut IN VARCHAR2,
      psperson IN NUMBER,
      pidconvenio_out IN OUT NUMBER,
      pdirecpol IN NUMBER DEFAULT 0   -- BUG 0025691/0138159 - FAL - 20/02/2013
                                   )
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_set_datconvenio';
      vpar           VARCHAR2(500)
         := 'i=' || pidconvenio || ' c=' || pccodconv || ' t=' || ptdesconv || ' i='
            || pfinivig || ' f=' || pffinvig || ' u=' || pcuseraut || ' p=' || psperson
            || ' io=' || pidconvenio_out || 'd=' || pdirecpol;
      num_err        NUMBER;
      v_cuseraut     rtn_mntconvenio.cuseraut%TYPE;
   BEGIN
      num_err := 0;
      vpas := 100;

      IF pcuseraut IS NULL THEN
         v_cuseraut := f_user;
      ELSE
         v_cuseraut := pcuseraut;
      END IF;

      -- ini BUG 0024892 - 28/11/2012 - JMF
      IF pfinivig IS NOT NULL
         AND pffinvig IS NOT NULL THEN
         IF pfinivig > pffinvig THEN
            -- La fecha de inicio no puede ser posterior a la fecha final
            RETURN 110361;
         END IF;
      END IF;

      -- fin BUG 0024892 - 28/11/2012 - JMF
      IF pidconvenio IS NOT NULL THEN
         vpas := 109;
         num_err := f_hay_convenios_iguales(pidconvenio, pfinivig, pffinvig, NULL, NULL,
                                            psperson);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vpas := 110;

         UPDATE rtn_mntconvenio
            SET ccodconv = NVL(pccodconv, ccodconv),
                tdesconv = NVL(ptdesconv, tdesconv),
                cuseraut = v_cuseraut,
                finivig = NVL(pfinivig, finivig),
                ffinvig = NVL(pffinvig, ffinvig),
                sperson = psperson,
                direcpol = pdirecpol   -- BUG 0025691/0138159 - FAL - 20/02/2013
          WHERE idconvenio = pidconvenio;
      ELSE
         vpas := 120;

         SELECT NVL(MAX(idconvenio), 0) + 1
           INTO pidconvenio_out
           FROM rtn_mntconvenio;

         vpas := 130;

         INSERT INTO rtn_mntconvenio
                     (idconvenio, ccodconv, tdesconv, cuseraut, finivig, ffinvig,
                      sperson, direcpol)   -- BUG 0025691/0138159 - FAL - 20/02/2013
              VALUES (pidconvenio_out, pccodconv, ptdesconv, v_cuseraut, pfinivig, pffinvig,
                      psperson, pdirecpol);   -- BUG 0025691/0138159 - FAL - 20/02/2013
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         pidconvenio_out := NULL;
         RETURN 9904156;
   END f_set_datconvenio;

   -- Esta función actualiza datos producto convenio
   FUNCTION f_set_prodconvenio(pidconvenio IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_set_prodconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' p=' || psproduc;
      num_err        NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;
      num_err := f_valida_prodconvenio(pidconvenio, psproduc);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_hay_convenios_iguales(pidconvenio, NULL, NULL, psproduc);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- BUG 0024132 - 24/10/2012 - JMF
      BEGIN
         INSERT INTO rtn_mntprodconvenio
                     (idconvenio, sproduc)
              VALUES (pidconvenio, psproduc);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9904157;
   END f_set_prodconvenio;

   -- Esta función actualiza datos agente convenio
   FUNCTION f_set_ageconvenio(pidconvenio IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_set_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || pcagente;
      num_err        NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;
      num_err := f_valida_agenconvenio(pidconvenio, pcagente);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_hay_convenios_iguales(pidconvenio, NULL, NULL, NULL, pcagente);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      INSERT INTO rtn_mntageconvenio
                  (idconvenio, cagente)
           VALUES (pidconvenio, pcagente);

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9904158;
   END f_set_ageconvenio;

   -- Esta función actualiza datos beneficiario convenio
   -- BUG 0025580 - 08/01/2013 - JMF
   FUNCTION f_set_benefconvenio(pidconvenio IN NUMBER, psperson IN NUMBER, ppretorno IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vcont          NUMBER;   -- Bug 25060 -- ECP -- 11/12/2012
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_set_benefconvenio';
      vpar           VARCHAR2(500)
                             := 'i=' || pidconvenio || ' s=' || psperson || ' p=' || ppretorno;
      num_err        NUMBER;
      vtotal         NUMBER;
   BEGIN
      num_err := 0;

      -- BUG 25060  El porcentaje ha ser mayor a 0 y menor a 100
      IF ppretorno <= 0
         OR ppretorno >= 100 THEN
         RETURN 9904621;   --Porcentaje entre 0 y 100
      END IF;

      -- BUG 0024892 - 01/12/2012 - JMF
      -- validar que la suma de todos los beneficiarios no supere 100
      SELECT SUM(NVL(pretorno, 0)) + NVL(ppretorno, 0)
        INTO vtotal
        FROM rtn_mntbenefconvenio
       WHERE idconvenio = pidconvenio
         AND sperson <> psperson;

      IF NVL(vtotal, 0) >= 100 THEN
         RETURN 104808;
      END IF;

      BEGIN
         vpas := 100;

         INSERT INTO rtn_mntbenefconvenio
                     (idconvenio, sperson, pretorno)
              VALUES (pidconvenio, psperson, ppretorno);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            vpas := 110;

            UPDATE rtn_mntbenefconvenio
               SET pretorno = ppretorno
             WHERE idconvenio = pidconvenio
               AND sperson = psperson;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9904159;
   END f_set_benefconvenio;

   -- Esta función nos devolverá 0 ó 1 en función de si el seguro que se pasa por parámetro
   -- tiene información de beneficiarios de retorno grabada.
   FUNCTION f_tiene_retorno(
      pnsesion IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_tiene_retorno';
      vpar           VARCHAR2(500)
           := 'ses=' || pnsesion || ' s=' || psseguro || ' n=' || pnmovimi || ' t=' || ptablas;
      --
      vnumregs       NUMBER(8);
   BEGIN
      vpas := 100;

      IF ptablas = 'SEG' THEN
         /*SELECT COUNT(1)
           INTO vnumregs
           FROM rtn_convenio c
          WHERE c.sseguro = psseguro
            AND(c.nmovimi = pnmovimi
                OR(pnmovimi IS NULL
                   AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM rtn_convenio m
                                     WHERE m.sseguro = psseguro)));*/
         SELECT crespue
           INTO vnumregs
           FROM pregunpolseg p
          WHERE p.sseguro = psseguro
            AND cpregun = 4817
            AND(p.nmovimi = pnmovimi
                OR(pnmovimi IS NULL
                   AND p.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM pregunpolseg m
                                     WHERE m.sseguro = psseguro
                                       AND cpregun = 4817)));
      ELSE
         /*SELECT COUNT(1)
           INTO vnumregs
           FROM estrtn_convenio c
          WHERE c.sseguro = psseguro
            AND(c.nmovimi = pnmovimi
                OR(pnmovimi IS NULL
                   AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM estrtn_convenio m
                                     WHERE m.sseguro = psseguro)));*/
         SELECT crespue
           INTO vnumregs
           FROM estpregunpolseg p
          WHERE p.sseguro = psseguro
            AND cpregun = 4817
            AND(p.nmovimi = pnmovimi
                OR(pnmovimi IS NULL
                   AND p.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM estpregunpolseg m
                                     WHERE m.sseguro = psseguro
                                       AND cpregun = 4817)));
      END IF;

      IF vnumregs = 0 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 0;
   END f_tiene_retorno;

   -- Esta función realizará la generación de los recibos de retorno según el porcentaje
   -- de los diferentes beneficiarios grabados en la tabla RTN_CONVENIO, y en función del
   -- porcentaje asignado a cada uno.
   FUNCTION f_generar_retorno(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      psproces IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R',
      ptipo IN VARCHAR2 DEFAULT 'NO')
      RETURN NUMBER IS
      vpas           NUMBER := 1;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_generar_retorno';
      vpar           VARCHAR2(500)
         := 's=' || psseguro || ' n=' || pnmovimi || ' r=' || pnrecibo || ' p=' || psproces
            || ' m=' || pmodo;
      v_age          seguros.cagente%TYPE;
      v_pro          seguros.sproduc%TYPE;
      d_ini          DATE;
      d_fin          DATE;
      v_pol          seguros.npoliza%TYPE;
      v_numerr       NUMBER;
      v_idenew       rtn_mntconvenio.idconvenio%TYPE;
      v_cdomper      movseguro.cdomper%TYPE;
      v_ctiprec      recibos.ctiprec%TYPE;
      v_rec          recibos.nrecibo%TYPE;
      e_error_proc   EXCEPTION;
      xcestaux       NUMBER;
      xccobban       NUMBER;
      xcestimp       NUMBER;
      xcdelega       NUMBER;
      xcestsop       NUMBER;   -- generacion de soportes
      xcmanual       NUMBER(1);
      xnbancar       seguros.cbancar%TYPE;
      xnbancarf      seguros.cbancar%TYPE;
      xtbancar       seguros.cbancar%TYPE;
      dummy          NUMBER;
      xsmovrec       NUMBER;
      xnliqmen       NUMBER;
      xfmovim        DATE;
      v_ctipban      per_ccc.ctipban%TYPE;
      v_cbancar      per_ccc.cbancar%TYPE;
      xiprianu2      detrecibos.iconcep%TYPE;
      xploccoa       NUMBER;
      v_decimals     NUMBER := 0;
      xcmovimi       NUMBER;
      v_total        vdetrecibos.itotalr%TYPE;
      v_cuseraut     psucontrolseg.cusuaur%TYPE;
      xesccero       NUMBER(1);
      vsum85         NUMBER;
      vncertif       NUMBER;   --bug 29324/161385 - 16/12/2013 - AMC
      v_copago       pregunpolseg.crespue%TYPE;   -- BUG 27417 - MMS - 20140208
      vcuenta        NUMBER;   -- 29991/65385 - 05/02/2014

      CURSOR c_retrn(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
         SELECT c.sperson, c.nmovimi, c.pretorno
           FROM rtn_convenio c
          WHERE c.sseguro = pc_sseguro
            AND(c.nmovimi = pc_nmovimi
                OR(pc_nmovimi IS NULL
                   AND c.nmovimi = (SELECT MAX(m.nmovimi)
                                      FROM rtn_convenio m
                                     WHERE m.sseguro = pc_sseguro)));

      CURSOR cur_recibos(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER, pc_nrecibo IN NUMBER) IS
         SELECT   r.*, s.sproduc produc, s.cagente AGENT, s.ctipreb tipreb, s.fcaranu caranu,
                  s.cagrpro agrpro
             FROM recibos r, seguros s
            WHERE s.sseguro = pc_sseguro
              AND r.sseguro = s.sseguro
              AND(r.nmovimi = pc_nmovimi
                  OR pc_nmovimi IS NULL
                  OR pc_nrecibo IS NOT NULL)
              AND(r.nrecibo = pc_nrecibo
                  OR pc_nrecibo IS NULL)
              AND EXISTS(SELECT 1
                           FROM movrecibo m
                          WHERE m.nrecibo = r.nrecibo
                            AND m.cestrec = 0
                            AND m.fmovfin IS NULL)
              AND((NVL(r.cestaux, 0) IN(0, 2)   --BUG25357:DCT:07/01/2013:INICIO
                   AND r.ctipcoa <> 8)
                  OR(r.cestaux = 1
                     AND r.ctipcoa = 8))   --BUG25357:DCT:07/01/2013:FIN
              AND r.ctiprec NOT IN(13, 15)   -- BUG24271:DRA:16/11/2012
              AND NOT EXISTS(SELECT 1
                               FROM rtn_recretorno rtr
                              WHERE rtr.nrecibo = r.nrecibo)
         ORDER BY r.nrecibo;

      -- BUG 0025691 - 08/03/2013 - JMF: afegir 50,51
      CURSOR cur_detrecibos(pc_nrecibo IN NUMBER) IS
         SELECT   nriesgo, cgarant, cageven, nmovima, SUM(iconcep) iconcep
             FROM detrecibos
            WHERE nrecibo = pc_nrecibo
              AND cconcep IN(0, 8, 50, 58)   --Bug 27994 MCA incluir concepto de recargo fraccionamiento
         -- JLV Bug 31982, el retorno sólo ha de tener en cuenta la prima y el recargo de fraccionamiento
         GROUP BY nriesgo, cgarant, cageven, nmovima;
   BEGIN
      vpas := 1000;

      IF pmodo = 'R' THEN
         IF psseguro IS NOT NULL THEN
            vpas := 1010;

            --bug 29324/161385 - 16/12/2013 - AMC
            SELECT cagente, sproduc, fefecto, npoliza, fcaranu, ncertif
              INTO v_age, v_pro, d_ini, v_pol, d_fin, vncertif
              FROM seguros
             WHERE sseguro = psseguro;

            vpas := 1020;

            IF vncertif = 0 THEN
               SELECT COUNT(1)
                 INTO v_numerr
                 FROM rtn_mntageconvenio a, rtn_mntprodconvenio b, rtn_mntconvenio c
                WHERE b.idconvenio = a.idconvenio
                  AND c.idconvenio = b.idconvenio
                  AND a.cagente = v_age
                  AND b.sproduc = v_pro
                  AND d_ini BETWEEN c.finivig AND c.ffinvig
                  -- BUG 0025691/0138159 - FAL - 20/02/2013
                  -- BUG 0025691 - 08/03/2013 - JMF: AND c.direcpol = 0
                  AND(c.direcpol = 0
                      OR(c.direcpol = 1
                         AND c.ccodconv = 'POL-' || v_pol));   --bug 29324/161385 - 16/12/2013 - AMC

               -- FI BUG 0025691/0138159
               IF v_numerr = 0 THEN
                  -- No existe el convenio, lo creamos.

                  -- buscar usuario que autoriza.
                  vpas := 1030;

                  SELECT MAX(cusuaur)
                    INTO v_cuseraut
                    FROM psucontrolseg a
                   WHERE sseguro = psseguro
                     AND ccontrol = 526051
                     AND nmovimi = (SELECT MAX(b.nmovimi)
                                      FROM psucontrolseg b
                                     WHERE b.sseguro = a.sseguro
                                       AND b.ccontrol = a.ccontrol);

                  vpas := 1040;
                  -- BUG 0025815 - 22/01/2013 - JMF: afegir sperson
                  v_numerr :=
                     pac_retorno.f_set_datconvenio
                                               (NULL, 'POL-' || v_pol,

                                                --'Directo desde póliza', d_ini, d_fin,
                                                f_axis_literales(9905021, f_usu_idioma), d_ini,
                                                d_fin,   -- BUG 0025691/0138159 - FAL - 20/02/2013
                                                --v_cuseraut, NULL, v_idenew);
                                                v_cuseraut, NULL, v_idenew, 1);   -- BUG 0025691/0138159 - FAL - 20/02/2013

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1050;
                  v_numerr := pac_retorno.f_set_prodconvenio(v_idenew, v_pro);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1060;
                  v_numerr := pac_retorno.f_set_ageconvenio(v_idenew, v_age);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;

                  vpas := 1070;

                  FOR f1 IN c_retrn(psseguro, NULL) LOOP
                     vpas := 1080;
                     -- BUG 0025580 - 08/01/2013 - JMF  : afegir ctomador
                     v_numerr := pac_retorno.f_set_benefconvenio(v_idenew, f1.sperson,
                                                                 f1.pretorno);

                     IF NVL(v_numerr, 0) <> 0 THEN
                        RAISE e_error_proc;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         --Fi bug 29324/161385 - 16/12/2013 - AMC
         END IF;
      END IF;

      v_numerr := 0;
      vpas := 1100;

      FOR r_rec IN cur_recibos(psseguro, pnmovimi, pnrecibo) LOOP
         vpas := 1110;

-- 29991/65385 - 05/02/2014 - INI
         SELECT COUNT(0)
           INTO vcuenta
           FROM detrecibos
          WHERE nrecibo =
                   r_rec.nrecibo   --BUG 0029991/166347 - 17/02/2014 - RCL - Canvi pnrecibo per r_rec.NRECIBO
            AND cconcep IN(0, 4, 8, 50, 54, 58, 86);

         IF vcuenta > 0 THEN
-- 29991/65385 - 05/02/2014 - FIN
            SELECT MAX(cdomper)
              INTO v_cdomper
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            IF r_rec.ctiprec = 9 THEN
               v_ctiprec := 15;   -- Recobro del Retorno
            ELSE
               v_ctiprec := 13;
            END IF;

            xsmovrec := 0;
            vpas := 1120;

            FOR r_rtn IN c_retrn(psseguro, NULL) LOOP
               vpas := 1130;
               v_rec := pac_adm.f_get_seq_cont(r_rec.cempres);
               -- <BUSCAR LOS DATOS BANCARIOS POR DEFECTO DEL BENEFICIARIO>
               vpas := 1140;

               SELECT MAX(ctipban), MAX(cbancar)
                 INTO v_ctipban, v_cbancar
                 FROM per_ccc a
                WHERE sperson = r_rtn.sperson
                  AND cnordban = (SELECT MAX(b.cnordban)
                                    FROM per_ccc b
                                   WHERE b.sperson = r_rtn.sperson
                                     AND b.cdefecto = 1);

               IF v_cbancar IS NULL THEN
                  vpas := 1150;

                  SELECT MAX(ctipban), MAX(cbancar)
                    INTO v_ctipban, v_cbancar
                    FROM per_ccc a
                   WHERE sperson = r_rtn.sperson
                     AND cnordban = (SELECT MAX(b.cnordban)
                                       FROM per_ccc b
                                      WHERE b.sperson = r_rtn.sperson);
               END IF;

               xcestaux := 0;

               -- INI RLLF 18/01/2016 0038732: POS ADM Recaudo y Cartera Ramo Salud

               /*IF NVL(f_parproductos_v(v_pro, 'ADMITE_CERTIFICADOS'), 0) = 1
                  AND NVL(f_parproductos_v(v_pro, 'RECUNIF'), 0) IN(1, 3) THEN
                  -- BUG26111:DRA:18/02/2013: Si es reunifica ha de quedar amb CESTAUX=2
                  --AND pac_seguros.f_es_col_admin(psseguro) = 1
                  --AND pac_seguros.f_get_escertifcero(NULL, psseguro) = 0 THEN
                  -- BUG26111:DRA:18/02/2013:Fi
                  xcestaux := 2;
               END IF;*/
              xcestaux := r_rec.cestaux;
               -- FIN RLLF 18/01/2016 0038732: POS ADM Recaudo y Cartera Ramo Salud

               IF pmodo = 'R' THEN
                  IF v_cbancar IS NOT NULL THEN
                     vpas := 1160;
                     xnbancar := v_cbancar;
                     v_numerr := f_ccc(xnbancar, v_ctipban, dummy, xnbancarf);
                     vpas := 1170;

                     IF v_numerr = 0
                        OR(v_numerr = 102493
                           AND f_parinstalacion_n('DIGICTRL00') = 1) THEN
                        xtbancar := v_cbancar;
                     ELSE
                        RETURN v_numerr;
                     END IF;
                  END IF;

                  IF NVL(ptipo, 'NO') = 'CERTIF0' THEN
                     xesccero := 1;
                  ELSE
                     xesccero := 0;

                     -- Inicio BUG 27417 - MMS - 20140208
                     IF r_rec.tipreb = 4 THEN
                        BEGIN
                           SELECT p1.crespue
                             INTO v_copago
                             FROM pregunpolseg p1
                            WHERE p1.sseguro = psseguro
                              AND p1.cpregun = 535
                              AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                                  FROM pregunpolseg p2
                                                 WHERE p2.sseguro = p1.sseguro
                                                   AND p2.cpregun = p1.cpregun);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              v_copago := NULL;
                        END;

                        IF NVL(v_copago, 100) <> 0 THEN
                           xesccero := 1;
                        END IF;
                     END IF;
                  -- Fin BUG 27417 - MMS - 20140208
                  END IF;

                  BEGIN
                     vpas := 1180;

                     INSERT INTO recibos
                                 (nrecibo, sseguro, cagente, femisio,
                                  fefecto, fvencim, ctiprec, cestaux,
                                  nanuali, nfracci, ccobban, cestimp,
                                  cempres, cdelega, nriesgo, cforpag,
                                  cbancar, nmovimi, ncuacoa, ctipcoa,
                                  cestsop, nperven, cgescob, ctipban,
                                  cmanual, esccero, ctipcob, ncuotar,
                                  sperson)
                          VALUES (v_rec, psseguro, r_rec.cagente, r_rec.femisio,
                                  r_rec.fefecto, r_rec.fvencim, v_ctiprec, xcestaux,
                                  r_rec.nanuali, r_rec.nfracci, r_rec.ccobban, r_rec.cestimp,
                                  r_rec.cempres, r_rec.cdelega, r_rec.nriesgo, r_rec.cforpag,
                                  xtbancar, r_rec.nmovimi, r_rec.ncuacoa, r_rec.ctipcoa,
                                  r_rec.cestsop, r_rec.nperven, r_rec.cgescob, r_rec.ctipban,
                                  r_rec.cmanual, xesccero, r_rec.ctipcob, r_rec.ncuotar,
                                  r_rtn.sperson);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 102307;   -- Registre duplicat a RECIBOS
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    SQLCODE || ' - ' || SQLERRM);
                        RETURN 103847;   -- Error a l' inserir a RECIBOS
                  END;

                  --BUG 24187 - 22/10/2012 - JRB - Se inserta la relación del recibo con el retorno en la tabla rtn_recretorno
                  BEGIN
                     vpas := 1181;

                     INSERT INTO rtn_recretorno
                                 (nrecibo, nrecretorno)
                          VALUES (r_rec.nrecibo, v_rec);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 9904388;   -- Registre duplicat a RECIBOS
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    SQLCODE || ' - ' || SQLERRM);
                        RETURN 9904389;   -- Error a l' inserir a RECIBOS
                  END;

                  vpas := 1190;

                  IF f_sysdate < r_rec.fefecto THEN
                     xfmovim := r_rec.fefecto;
                  ELSE
                     xfmovim := f_sysdate;
                  END IF;

                  IF r_rec.agrpro = 2 THEN
                     xcmovimi := 2;   -- indica aportación periódica
                  ELSE
                     xcmovimi := NULL;
                  END IF;

                  SELECT fmovini
                    INTO xfmovim
                    FROM movrecibo
                   WHERE nrecibo = r_rec.nrecibo
                     AND fmovfin IS NULL;

                  vpas := 1200;
                  v_numerr := f_movrecibo(v_rec, 0, NULL, xcmovimi, xsmovrec, xnliqmen, dummy,
                                          xfmovim, r_rec.ccobban, r_rec.cdelega, NULL, NULL);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;
               ELSE
                  vpas := 1210;

                  INSERT INTO reciboscar
                              (sproces, nrecibo, sseguro, cagente, femisio,
                               fefecto, fvencim, ctiprec, cestaux,
                               nanuali, nfracci, ccobban, cestimp,
                               cempres, cdelega, nriesgo, ncuacoa,
                               ctipcoa, cestsop, cgescob)
                       VALUES (psproces, v_rec, psseguro, r_rec.cagente, f_sysdate,
                               r_rec.fefecto, r_rec.fvencim, v_ctiprec, xcestaux,
                               r_rec.nanuali, r_rec.nfracci, r_rec.ccobban, r_rec.cestimp,
                               r_rec.cempres, r_rec.cdelega, r_rec.nriesgo, r_rec.ncuacoa,
                               r_rec.ctipcoa, r_rec.cestsop, r_rec.cgescob);
               END IF;

               -- Buscamos el porcentaje local si es un coaseguro.
               vpas := 1220;

               IF r_rec.ctipcoa != 0 THEN
                  BEGIN
                     SELECT ploccoa
                       INTO xploccoa
                       FROM coacuadro
                      WHERE ncuacoa = r_rec.ncuacoa
                        AND sseguro = psseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 105447;
                  END;
               ELSE
                  xploccoa := NULL;
               END IF;

               vpas := 1230;

               SELECT MAX(pac_monedas.f_moneda_divisa(cdivisa))
                 INTO v_decimals
                 FROM seguros a, productos b
                WHERE a.sseguro = psseguro
                  AND b.sproduc = a.sproduc;

               vpas := 1240;

               SELECT MAX(itotalr)
                 INTO v_total
                 FROM vdetrecibos
                WHERE nrecibo = r_rec.nrecibo;

               vpas := 1250;

               FOR detrec IN cur_detrecibos(r_rec.nrecibo) LOOP
                  IF r_rtn.pretorno = 0 THEN
                     xiprianu2 := 0;
                  ELSE
                     vpas := 1260;
                      --Bug 29417/161655 - 18/12/2013 - AMC
                     /*IF v_ctiprec = 15 THEN
                        SELECT NVL(SUM(iconcep), 0)
                          INTO vsum85
                          FROM detrecibos
                         WHERE nrecibo = r_rec.nrecibo
                           AND cconcep = 85;

                        xiprianu2 := (detrec.iconcep + vsum85) *(r_rtn.pretorno / 100);
                     ELSE
                        xiprianu2 := detrec.iconcep *(r_rtn.pretorno / 100);
                     END IF;*/
                     xiprianu2 := detrec.iconcep *(r_rtn.pretorno / 100);
                  --Fi Bug 29417/161655 - 18/12/2013 - AMC
                  END IF;

                  vpas := 1270;
                  v_numerr := f_insdetrec(v_rec, 0, xiprianu2, xploccoa, detrec.cgarant,
                                          detrec.nriesgo, r_rec.ctipcoa, detrec.cageven,
                                          detrec.nmovima, 0, 0, 1, NULL, NULL, NULL,
                                          v_decimals);

                  IF NVL(v_numerr, 0) <> 0 THEN
                     RAISE e_error_proc;
                  END IF;
               END LOOP;

               vpas := 1280;
               v_numerr := f_vdetrecibos(pmodo, v_rec, psproces);

               IF NVL(v_numerr, 0) <> 0 THEN
                  RAISE e_error_proc;
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      vpas := 1290;
      RETURN v_numerr;
   EXCEPTION
      WHEN e_error_proc THEN
         IF c_retrn%ISOPEN THEN
            CLOSE c_retrn;
         END IF;

         IF cur_recibos%ISOPEN THEN
            CLOSE cur_recibos;
         END IF;

         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     v_numerr || ' ' || f_axis_literales(v_numerr, f_usu_idioma));
         RETURN v_numerr;
      WHEN OTHERS THEN
         IF c_retrn%ISOPEN THEN
            CLOSE c_retrn;
         END IF;

         IF cur_recibos%ISOPEN THEN
            CLOSE cur_recibos;
         END IF;

         IF cur_detrecibos%ISOPEN THEN
            CLOSE cur_detrecibos;
         END IF;

         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9904162;
   END f_generar_retorno;

   -- Buscar convenio del retorno
   -- BUG 0025815 - 22/01/2013 - JMF
   FUNCTION f_busca_convenioretorno(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pidconvenio IN OUT NUMBER,
      ptomador IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_busca_convenioretorno';
      vpar           VARCHAR2(500)
         := 's=' || psseguro || ' p=' || psproduc || ' e=' || pfefecto || ' a=' || pcagente
            || ' t=' || ptomador;
      v_numerr       NUMBER;
   BEGIN
      vpas := 100;
      pidconvenio := NULL;

      IF psseguro IS NULL
         OR psproduc IS NULL
         OR pfefecto IS NULL
         OR pcagente IS NULL THEN
         v_numerr := 1000644;
         RAISE NO_DATA_FOUND;
      END IF;

      -- ini BUG 0025580 - 08/01/2013 - JMF
      -- BUG 0025815 - 22/01/2013 - JMF
      BEGIN
         IF ptomador IS NOT NULL THEN
            -- No tenemos el tomador en las tablas y lo envian en el parametro
            -- Buscamos si el tomador esta en algun convenio
            SELECT c.idconvenio
              INTO pidconvenio
              FROM rtn_mntconvenio c, rtn_mntprodconvenio p, rtn_mntageconvenio a
             WHERE 1 = 1
               AND c.sperson = ptomador
               AND pfefecto BETWEEN c.finivig AND c.ffinvig
               AND p.idconvenio = c.idconvenio
               AND a.idconvenio = c.idconvenio
               AND p.sproduc = psproduc
               AND a.cagente = pcagente
               AND NVL(c.direcpol, 0) = 0;   -- BUG 0025691/0138159 - FAL - 20/02/2013
         ELSE
            -- Buscamos si el tomador esta en algun convenio
            SELECT c.idconvenio
              INTO pidconvenio
              FROM esttomadores t, estper_personas e, rtn_mntconvenio c, rtn_mntprodconvenio p,
                   rtn_mntageconvenio a
             WHERE p.idconvenio = c.idconvenio
               AND a.idconvenio = c.idconvenio
               AND pfefecto BETWEEN c.finivig AND c.ffinvig
               AND p.sproduc = psproduc
               AND a.cagente = pcagente
               AND c.sperson = e.spereal
               AND e.sperson = t.sperson
               AND t.sseguro = psseguro
               AND NVL(c.direcpol, 0) = 0;   -- BUG 0025691/0138159 - FAL - 20/02/2013
         END IF;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            -- Existen varios convenios para el tomador
            RETURN 9904756;
         WHEN OTHERS THEN
            -- Si no encuentra tomador, seguimos buscando
            pidconvenio := NULL;
      END;

      IF pidconvenio IS NULL THEN
         -- fin BUG 0025580 - 08/01/2013 - JMF
         BEGIN
            vpas := 110;

            -- BUG 0025815 - 22/01/2013 - JMF
            SELECT c.idconvenio
              INTO pidconvenio
              FROM rtn_mntconvenio c, rtn_mntprodconvenio p, rtn_mntageconvenio a
             WHERE p.idconvenio = c.idconvenio
               AND a.idconvenio = c.idconvenio
               AND pfefecto BETWEEN c.finivig AND c.ffinvig
               AND p.sproduc = psproduc
               AND a.cagente = pcagente
               AND c.sperson IS NULL
               AND NVL(c.direcpol, 0) = 0;   -- BUG 0025691/0138159 - FAL - 20/02/2013
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               -- Existen varios convenios definidos para el agente.
               RETURN 9904168;
            WHEN OTHERS THEN
               pidconvenio := NULL;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1000644;
   END f_busca_convenioretorno;

   -- Inicializará la información del retorno
   FUNCTION f_inicializa_retorno(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      psquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_inicializa_retorno';
      vpar           VARCHAR2(500)
         := 's=' || psseguro || ' n=' || pnmovimi || ' p=' || psproduc || ' e=' || pfefecto
            || ' a=' || pcagente;
      v_numerr       NUMBER;
      v_ide          rtn_mntconvenio.idconvenio%TYPE;

      CURSOR c2 IS
         SELECT *
           FROM rtn_mntbenefconvenio
          WHERE idconvenio = v_ide;
   BEGIN
      vpas := 100;

      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR psproduc IS NULL
         OR pfefecto IS NULL
         OR pcagente IS NULL THEN
         v_numerr := 1000644;
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 110;
      v_numerr := pac_retorno.f_busca_convenioretorno(psseguro, psproduc, pfefecto, pcagente,
                                                      v_ide);

      IF v_numerr <> 0 THEN
         RETURN v_numerr;
      END IF;

      IF v_ide IS NOT NULL THEN
         vpas := 120;

         FOR f2 IN c2 LOOP
            vpas := 130;

            BEGIN
               -- BUG 0023965 - 15/10/2012 - JMF: afegir idconvenio
               INSERT INTO estrtn_convenio
                           (sseguro, sperson, nmovimi, pretorno, idconvenio)
                    VALUES (psseguro, f2.sperson, pnmovimi, f2.pretorno, v_ide);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;
      END IF;

      vpas := 140;
      psquery := 'SELECT * FROM estrtn_convenio WHERE sseguro=' || psseguro;
      vpas := 150;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     v_numerr || ' ' || SQLCODE || '-' || SQLERRM);
         RETURN 1000644;
   END f_inicializa_retorno;

   -- Inicializará la información del retorno
   FUNCTION f_get_rtnconvenios(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psquery IN OUT VARCHAR2)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_get_rtnconvenios';
      vpar           VARCHAR2(500) := 's=' || psseguro || ' t=' || ptablas;
      v_tab          VARCHAR2(30);
   BEGIN
      vpas := 100;

      IF psseguro IS NULL THEN
         RETURN 0;
      END IF;

      vpas := 140;

      IF ptablas = 'SEG' THEN
         v_tab := 'rtn_convenio';
      ELSE
         v_tab := 'estrtn_convenio';
      END IF;

      vpas := 150;
      psquery := 'SELECT * FROM ' || v_tab || ' WHERE sseguro=' || psseguro;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1000644;
   END f_get_rtnconvenios;

   -- ini BUG 0024892 - 28/11/2012 - JMF
   -- Esta función realiza acciones sobre los campos obligatorios
   -- accion 0 = Validar si falta informacion obligatoria
   -- accion 1 = Borrar estructura del convenio.
   FUNCTION f_oblig_convenio(pidconvenio IN NUMBER, paccion IN NUMBER, presult IN OUT VARCHAR2)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_oblig_convenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || paccion;
      num_err        NUMBER;
      v_conta        NUMBER;
   BEGIN
      num_err := 0;
      vpas := 100;
      presult := NULL;

      IF pidconvenio IS NULL
         OR paccion IS NULL THEN
         RETURN 0;
      END IF;

      IF paccion = 0 THEN
         -- Solo validar si existen o no campos obligatorios que no estan informados
         vpas := 110;

         SELECT COUNT(1)
           INTO v_conta
           FROM rtn_mntbenefconvenio
          WHERE idconvenio = pidconvenio;

         IF v_conta = 0 THEN
            -- Falta informar un beneficiario
            presult := f_axis_literales(9904589, f_usu_idioma);
            RETURN 0;
         END IF;

         vpas := 120;

         SELECT COUNT(1)
           INTO v_conta
           FROM rtn_mntageconvenio
          WHERE idconvenio = pidconvenio;

         IF v_conta = 0 THEN
            -- Falta informar un agente
            presult := f_axis_literales(9904590, f_usu_idioma);
            RETURN 0;
         END IF;

         vpas := 130;

         SELECT COUNT(1)
           INTO v_conta
           FROM rtn_mntprodconvenio
          WHERE idconvenio = pidconvenio;

         IF v_conta = 0 THEN
            -- Falta informar un producto
            presult := f_axis_literales(9904591, f_usu_idioma);
            RETURN 0;
         END IF;
      ELSIF paccion = 1 THEN
         -- Borrar la estructura del convenio ya que esta incompleta
         vpas := 140;

         DELETE      rtn_mntbenefconvenio
               WHERE idconvenio = pidconvenio;

         vpas := 150;

         DELETE      rtn_mntageconvenio
               WHERE idconvenio = pidconvenio;

         vpas := 160;

         DELETE      rtn_mntprodconvenio
               WHERE idconvenio = pidconvenio;

         vpas := 170;

         DELETE      rtn_mntconvenio
               WHERE idconvenio = pidconvenio;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 9904156;
   END f_oblig_convenio;

   -- Esta función valida el producto del convenio: Devuelve 0 = ok, codigo error
   FUNCTION f_valida_prodconvenio(pidconvenio IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_valida_prodconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' p=' || psproduc;
      num_err        NUMBER;
      v_difer        NUMBER;
      v_ini          NUMBER;
      v_fin          NUMBER;
      v_igu          NUMBER;

      -- Buscamos el producto en otros convenios
      CURSOR c1 IS
         SELECT DISTINCT a.idconvenio
                    FROM rtn_mntprodconvenio a, rtn_mntconvenio b, rtn_mntconvenio c
                   WHERE a.sproduc = psproduc
                     AND a.idconvenio <> pidconvenio
                     AND b.idconvenio = a.idconvenio
                     AND c.idconvenio = pidconvenio
                     AND b.finivig BETWEEN c.finivig AND c.ffinvig
                     AND b.ffinvig BETWEEN c.finivig AND c.ffinvig;
   BEGIN
      v_difer := 1;

--------------------------------------------
-- Para saber si un convenio esta duplicado, tiene que coincidir toods los productos y todos los agentes
--------------------------------------------

      -- saber cuentos producos tiene el convenio inicial
      -- (es posible que el producto del parametro no este insertado en la tabla)
      SELECT COUNT(1) + 1
        INTO v_ini
        FROM rtn_mntprodconvenio
       WHERE idconvenio = pidconvenio
         AND sproduc <> psproduc;

      FOR f1 IN c1 LOOP
         SELECT MAX(DECODE(NVL(a.sperson, -1), NVL(b.sperson, -1), 1, 0))
           INTO v_igu
           FROM rtn_mntconvenio a, rtn_mntconvenio b
          WHERE a.idconvenio = pidconvenio
            AND b.idconvenio = f1.idconvenio
            AND NVL(a.direcpol, 0) = 0;   -- BUG 0025691/0138159 - FAL - 20/02/2013

         -- Si existen 2 convenios prod+agente iguales, pero con tomador distinto,
         -- se considera que los 2 convenios son diferetes
         IF v_igu = 1 THEN
            -- saber cuantos productos tiene el convenio a comparar
            SELECT COUNT(1)
              INTO v_fin
              FROM rtn_mntprodconvenio
             WHERE idconvenio = f1.idconvenio;

            -- saber cuantos productos son iguales
            SELECT COUNT(1)
              INTO v_igu
              FROM rtn_mntprodconvenio a, rtn_mntprodconvenio b
             WHERE a.idconvenio = pidconvenio
               AND b.idconvenio = f1.idconvenio
               AND b.sproduc = a.sproduc;

            -- Si el convenio a comparar tiene registros y todos son iguales, conitnuamos mirando agentes
            IF (v_fin = 1
                OR v_igu = v_ini) THEN
               -- mirar cuantos agentes tiene el convenio inicial
               SELECT COUNT(1)
                 INTO v_ini
                 FROM rtn_mntageconvenio a
                WHERE a.idconvenio = pidconvenio;

               -- mirar cuantos agentes coinciden en ambos convenios
               SELECT COUNT(1)
                 INTO v_igu
                 FROM rtn_mntageconvenio a, rtn_mntageconvenio b
                WHERE a.idconvenio = pidconvenio
                  AND b.idconvenio = f1.idconvenio
                  AND b.cagente = a.cagente;

               -- Si el convenio tiene agentes, y todos son iguales
               IF v_ini > 0
                  AND v_igu = v_ini THEN
                  v_difer := 0;
                  EXIT;
               END IF;
            ELSE
               -- diferentes
               NULL;
            END IF;
         END IF;
      END LOOP;

      IF v_difer = 0 THEN
         -- Existe convenio duplicado para el producto - Intermediario
         RETURN 9904794;
      ELSE
         RETURN 0;
      END IF;

      RETURN 0;
   END f_valida_prodconvenio;

   -- Esta función valida el agente del convenio: Devuelve 0 ok, codigo error
   FUNCTION f_valida_agenconvenio(pidconvenio IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_valida_agenconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || pcagente;
      num_err        NUMBER;
      v_difer        NUMBER;
      v_ini          NUMBER;
      v_fin          NUMBER;
      v_igu          NUMBER;

      -- Buscamos el producto en otros convenios
      CURSOR c1 IS
         SELECT DISTINCT a.idconvenio
                    FROM rtn_mntageconvenio a, rtn_mntconvenio b, rtn_mntconvenio c
                   WHERE a.cagente = pcagente
                     AND a.idconvenio <> pidconvenio
                     AND b.idconvenio = a.idconvenio
                     AND c.idconvenio = pidconvenio
                     AND b.finivig BETWEEN c.finivig AND c.ffinvig
                     AND b.ffinvig BETWEEN c.finivig AND c.ffinvig;
   BEGIN
      v_difer := 1;

--------------------------------------------
-- Para saber si un convenio esta duplicado, tiene que coincidir toods los productos y todos los agentes
--------------------------------------------

      -- saber cuentos agentes tiene el convenio inicial
      -- (es posible que el agente del parametro no este insertado en la tabla)
      SELECT COUNT(1) + 1
        INTO v_ini
        FROM rtn_mntageconvenio
       WHERE idconvenio = pidconvenio
         AND cagente <> pcagente;

      FOR f1 IN c1 LOOP
         SELECT MAX(DECODE(NVL(a.sperson, -1), NVL(b.sperson, -1), 1, 0))
           INTO v_igu
           FROM rtn_mntconvenio a, rtn_mntconvenio b
          WHERE a.idconvenio = pidconvenio
            AND b.idconvenio = f1.idconvenio
            AND NVL(a.direcpol, 0) = 0;   -- BUG 0025691/0138159 - FAL - 20/02/2013

         -- Si existen 2 convenios prod+agente iguales, pero con tomador distinto,
         -- se considera que los 2 convenios son diferetes
         IF v_igu = 1 THEN
            -- saber cuantos agentes tiene el convenio a comparar
            SELECT COUNT(1)
              INTO v_fin
              FROM rtn_mntageconvenio
             WHERE idconvenio = f1.idconvenio;

            -- saber cuantos agentes son iguales
            SELECT COUNT(1)
              INTO v_igu
              FROM rtn_mntageconvenio a, rtn_mntageconvenio b
             WHERE a.idconvenio = pidconvenio
               AND b.idconvenio = f1.idconvenio
               AND b.cagente = a.cagente;

            -- Si el convenio a comparar tiene registros y todos son iguales, conitnuamos mirando productos
            IF (v_fin = 1
                OR v_igu = v_ini) THEN
               -- mirar cuantos productos tiene el convenio inicial
               SELECT COUNT(1)
                 INTO v_ini
                 FROM rtn_mntprodconvenio a
                WHERE a.idconvenio = pidconvenio;

               -- mirar cuantos productos coinciden en ambos convenios
               SELECT COUNT(1)
                 INTO v_igu
                 FROM rtn_mntprodconvenio a, rtn_mntprodconvenio b
                WHERE a.idconvenio = pidconvenio
                  AND b.idconvenio = f1.idconvenio
                  AND b.sproduc = a.sproduc;

               -- Si el convenio tiene productos, y todos son iguales
               IF v_ini > 0
                  AND v_igu = v_ini THEN
                  v_difer := 0;
                  EXIT;
               END IF;
            ELSE
               -- diferentes
               NULL;
            END IF;
         END IF;
      END LOOP;

      IF v_difer = 0 THEN
         -- Existe convenio duplicado para el producto - Intermediario
         RETURN 9904794;
      ELSE
         RETURN 0;
      END IF;

      RETURN 0;
   END f_valida_agenconvenio;

   FUNCTION f_hay_convenios_iguales(
      pidconvenio IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pcpersona IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vcntperson     NUMBER;
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_valida_conve_iguales';
      vpar           VARCHAR2(500)
         := ' pidconvenio= ' || pidconvenio || ' pfinivig= ' || pfinivig || ' pffinvig= '
            || pffinvig || ' psproduc= ' || psproduc || ' pcagente= ' || pcagente;
      num_err        NUMBER;
      v_difer        NUMBER;
      v_ini          NUMBER;
      v_fin          NUMBER;
      v_igu          NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_difer
        FROM (SELECT   idconvenio, COUNT(1)
                  FROM ((SELECT   idconvenio
                             FROM rtn_mntconvenio conv,
                                  (SELECT finivig finivig, ffinvig ffinvig
                                     FROM rtn_mntconvenio
                                    WHERE idconvenio = pidconvenio
                                   UNION
                                   SELECT pfinivig, pffinvig
                                     FROM DUAL) actual
                            WHERE conv.idconvenio <> pidconvenio
                              AND(actual.finivig BETWEEN conv.finivig AND conv.ffinvig
                                  OR actual.ffinvig BETWEEN conv.finivig AND conv.ffinvig)
                              AND NVL(conv.direcpol, 0) =
                                                     0   -- BUG 0025691/0138159 - FAL - 20/02/2013
                         GROUP BY idconvenio)
                        UNION ALL
                        (SELECT   idconvenio
                             FROM rtn_mntprodconvenio pro
                            WHERE pro.idconvenio <> pidconvenio
                              AND pro.sproduc IN(
                                            SELECT pro2.sproduc
                                              FROM rtn_mntprodconvenio pro2
                                             WHERE pro2.idconvenio = pidconvenio
                                            UNION
                                            SELECT psproduc
                                              FROM DUAL)
                         GROUP BY idconvenio)
                        UNION ALL
                        (SELECT   idconvenio
                             FROM rtn_mntageconvenio age
                            WHERE age.idconvenio <> pidconvenio
                              AND age.cagente IN(
                                            SELECT age2.cagente
                                              FROM rtn_mntageconvenio age2
                                             WHERE age2.idconvenio = pidconvenio
                                            UNION
                                            SELECT pcagente
                                              FROM DUAL)
                         GROUP BY idconvenio))
              GROUP BY idconvenio
                HAVING COUNT(1) >= 3
              ORDER BY 1)
       WHERE ROWNUM = 1;

      IF v_difer IS NULL
         OR v_difer = 0 THEN
         RETURN 0;
      ELSE
         --Bug 26454/143814, JLV 08/05/2013 validar si el tomador es diferente
         -- Se trata de dos conveniso diferentes
         SELECT COUNT(1)
           INTO vcntperson
           FROM rtn_mntconvenio
          WHERE sperson IN(SELECT NVL(sperson, pcpersona)
                             FROM rtn_mntconvenio
                            WHERE idconvenio = pidconvenio);

         IF vcntperson > 1 THEN
            RETURN 9904794;
         ELSE
            RETURN 0;
         END IF;
      END IF;
   --9904794
   END f_hay_convenios_iguales;

   --Bug 29324/166247 - 18/02/2014 - AMC
   FUNCTION f_busca_convenioretorno_pol(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pidconvenio IN OUT NUMBER,
      pdonde OUT NUMBER,
      ptomador IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_RETORNO.f_busca_convenioretorno_pol';
      vpar           VARCHAR2(500)
         := 's=' || psseguro || ' p=' || psproduc || ' e=' || pfefecto || ' a=' || pcagente
            || ' t=' || ptomador;
      v_numerr       NUMBER;
      vfefecto       DATE;
      vnpoliza       NUMBER;
   BEGIN
      vpas := 100;
      pidconvenio := NULL;

      IF psseguro IS NULL
         OR psproduc IS NULL
         OR pfefecto IS NULL
         OR pcagente IS NULL THEN
         v_numerr := 1000644;
         RAISE NO_DATA_FOUND;
      END IF;

      BEGIN
         IF ptomador IS NOT NULL THEN
            -- No tenemos el tomador en las tablas y lo envian en el parametro
            -- Buscamos si el tomador esta en algun convenio
            SELECT c.idconvenio
              INTO pidconvenio
              FROM rtn_mntconvenio c, rtn_mntprodconvenio p, rtn_mntageconvenio a
             WHERE 1 = 1
               AND c.sperson = ptomador
               AND pfefecto BETWEEN c.finivig AND c.ffinvig
               AND p.idconvenio = c.idconvenio
               AND a.idconvenio = c.idconvenio
               AND p.sproduc = psproduc
               AND a.cagente = pcagente
               AND NVL(c.direcpol, 0) = 0;

            pdonde := 0;   --Retorno parametrizado
         ELSE
            -- Buscamos si el tomador esta en algun convenio
            SELECT c.idconvenio
              INTO pidconvenio
              FROM esttomadores t, estper_personas e, rtn_mntconvenio c, rtn_mntprodconvenio p,
                   rtn_mntageconvenio a
             WHERE p.idconvenio = c.idconvenio
               AND a.idconvenio = c.idconvenio
               AND pfefecto BETWEEN c.finivig AND c.ffinvig
               AND p.sproduc = psproduc
               AND a.cagente = pcagente
               AND c.sperson = e.spereal
               AND e.sperson = t.sperson
               AND t.sseguro = psseguro
               AND NVL(c.direcpol, 0) = 0;

            pdonde := 0;   --Retorno parametrizado
         END IF;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            -- Existen varios convenios para el tomador
            RETURN 9904756;
         WHEN OTHERS THEN
            -- Si no encuentra tomador, seguimos buscando
            pidconvenio := NULL;
      END;

      IF pidconvenio IS NULL THEN
         BEGIN
            vpas := 110;

            SELECT c.idconvenio
              INTO pidconvenio
              FROM rtn_mntconvenio c, rtn_mntprodconvenio p, rtn_mntageconvenio a
             WHERE p.idconvenio = c.idconvenio
               AND a.idconvenio = c.idconvenio
               AND pfefecto BETWEEN c.finivig AND c.ffinvig
               AND p.sproduc = psproduc
               AND a.cagente = pcagente
               AND c.sperson IS NULL
               AND NVL(c.direcpol, 0) = 0;

            pdonde := 0;   --Retorno parametrizado
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               -- Existen varios convenios definidos para el agente.
               RETURN 9904168;
            WHEN OTHERS THEN
               pidconvenio := NULL;
         END;
      END IF;

      IF pidconvenio IS NULL THEN
         BEGIN
            SELECT fefecto
              INTO vfefecto
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM movseguro
                               WHERE sseguro = psseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vfefecto := pfefecto;
         END;

         BEGIN
            SELECT npoliza
              INTO vnpoliza
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT npoliza
                 INTO vnpoliza
                 FROM estseguros
                WHERE sseguro = psseguro;
         END;

         BEGIN
            SELECT c.idconvenio
              INTO pidconvenio
              FROM rtn_mntconvenio c
             WHERE vfefecto BETWEEN c.finivig AND c.ffinvig
               AND ccodconv = 'POL-' || vnpoliza
               AND NVL(c.direcpol, 0) = 1;

            pdonde := 1;   --Retorno de poliza
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               -- Existen varios convenios definidos para el agente.
               RETURN 9904168;
            WHEN OTHERS THEN
               pidconvenio := NULL;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1000644;
   END f_busca_convenioretorno_pol;
END pac_retorno;

/

  GRANT EXECUTE ON "AXIS"."PAC_RETORNO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RETORNO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RETORNO" TO "PROGRAMADORESCSI";
