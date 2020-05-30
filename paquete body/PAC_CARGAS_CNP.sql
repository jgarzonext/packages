--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS_CNP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS_CNP" IS
   /******************************************************************************
      NOMBRE:    pac_cargas_cnp
      PROPÓSITO: Funciones para la gestión de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        14/07/2010   JMF              1. 0015490: CRT002 - Carga de polizas,recibos, siniestros CNP
      2.0        29/09/2010   DRA              2. 0016130: CRT - Error informando el codigo de proceso en carga
      3.0        13/10/2010   FAL              4. 0014888: CRT002 - Carga de polizas,recibos y siniestros Allianz
      4.0        18/10/2010   FAL              5. 0016324: CRT - Configuracion de las cargas
      5.0        03/11/2010   FAL              5. 0016525: CRT002 - Incidencias en cargas (primera carga inicial)
      6.0        18/11/2010   FAL              6. 0016696: CRT002 - Revisar producto y carga fichero inverplus CNP
      7.0        19/01/2011   ICV              7. 0017155: CRT003 - Informar estado actualizacion compañia
      8.0        02/03/2011   FAL              8. 0017569: CRT - Interfases y gestión personas
      9.0        15/12/2011   JMP              9. 0018423: LCOL705 - Multimoneda
     10.0        30/04/2014   FAL             10. 0027642: RSA102 - Producto Tradicional
   ******************************************************************************/

   /*************************************************************************
         1.0.0.0.0 f_ejecutarcarga_PP
      1.1.0.0.0 ....f_ejecutarcarga_PPFIC
      1.1.1.0.0 ........f_lee_fichero
      1.2.0.0.0 ....f_ejecutarcarga_PPPRO
      1.2.1.0.0 ........f_altapoliza_mig.........(ALTA)
   *************************************************************************/

   /*************************************************************************
          Procedimiento que guarda logs en tablas tab_error y procesoslin.
       param p_ttabobj in : tab_error tobjeto
       param p_ntabtra in : tab_error ntraza
       param p_ttabdes in : tab_error tdescrip
       param p_ttaberr in : tab_error terror
       param p_npropro in : PROCESOSLIN sproces
       param p_tprotxt in : PROCESOSLIN tprolin
   *************************************************************************/
   PROCEDURE p_genera_logs(
      p_ttabobj IN VARCHAR2,
      p_ntabtra IN NUMBER,
      p_ttabdes IN VARCHAR2,
      p_ttaberr IN VARCHAR2,
      p_npropro IN NUMBER,
      p_tprotxt IN VARCHAR2) IS
      v_nnumlin      NUMBER;
      v_nnumerr      NUMBER;
   BEGIN
      IF p_ttabobj IS NOT NULL
         AND p_ntabtra IS NOT NULL THEN
         p_tab_error(f_sysdate, f_user, p_ttabobj, p_ntabtra, SUBSTR(p_ttabdes, 1, 500),
                     SUBSTR(p_ttaberr, 1, 2500));
      END IF;

      IF p_npropro IS NOT NULL
         AND p_tprotxt IS NOT NULL THEN
         v_nnumlin := NULL;
         v_nnumerr := f_proceslin(p_npropro, SUBSTR(p_tprotxt, 1, 120), 1, v_nnumlin);
      END IF;
   END p_genera_logs;

   /*************************************************************************
             Función que marca linea que tratamos con un estado.
          param p_nsproces   in : proceso
          param p_nlinea     in : linea
          param p_ttipo      in : tipo
          param p_nestado    in : estado
          param p_nvalidado  in : validado
          param p_sseguro    in : seguro
          param p_nsiniestro in : siniestro
          param p_ntramite   in : tramite
          param p_sperson    in : persona
          param p_nrecibo    in : recibo
          devuelve número o null si existe error.
      *************************************************************************/
   FUNCTION p_marcalinea(
      p_nsproces IN NUMBER,
      p_nlinea IN NUMBER,
      p_ttipo IN VARCHAR2,
      p_nestado IN NUMBER,
      p_nvalidado IN NUMBER,
      p_sseguro IN NUMBER,
      -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
      p_id_ext IN VARCHAR2,
      -- Fi Bug 14888
      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
      p_ncarg IN NUMBER,
      -- Fi Bug 16324
      p_nsiniestro IN NUMBER DEFAULT NULL,
      p_ntramite IN NUMBER DEFAULT NULL,
      p_sperson IN NUMBER DEFAULT NULL,
      p_nrecibo IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_CNP.P_MARCALINEA';
      v_nnumerr      NUMBER := 0;
      v_ntipo        NUMBER;
   BEGIN
      IF p_ttipo = 'ALTA' THEN
         v_ntipo := 0;
      ELSE
         v_ntipo := 0;
      END IF;

      v_nnumerr :=
         pac_gestion_procesos.f_set_carga_ctrl_linea
            (p_nsproces, p_nlinea, v_ntipo, p_nlinea, p_ttipo, p_nestado, p_nvalidado,
             p_sseguro,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
             p_id_ext,   -- Fi Bug 14888
                         -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
             p_ncarg,   -- Fi Bug 16324
             p_nsiniestro, p_ntramite, p_sperson, p_nrecibo);

      IF v_nnumerr <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(v_tobjeto, 1, v_nnumerr,
                       'p=' || p_nsproces || ' l=' || p_nlinea || ' t=' || p_ttipo || ' EST='
                       || p_nestado || ' v=' || p_nvalidado || ' s=' || p_sseguro,
                       p_nsproces,
                       'Error ' || v_nnumerr || ' l=' || p_nlinea || ' e=' || p_nestado);
         v_nnumerr := 1;
      END IF;

      RETURN v_nnumerr;
   END p_marcalinea;

   /*************************************************************************
                                      Función que marca el error de la linea que tratamos.
          param p_ssproces in : proceso
          param p_nlinea   in : linea
          param p_nnumerr  in : numero error
          param p_ntipo    in : tipo
          param p_ncodigo  in : codigo
          param p_tmensaje in : mensaje
          devuelve número o null si existe error.
      *************************************************************************/
   FUNCTION p_marcalineaerror(
      p_ssproces IN NUMBER,
      p_nlinea IN NUMBER,
      p_nnumerr IN NUMBER,
      p_ntipo IN NUMBER,
      p_ncodigo IN NUMBER,
      p_tmensaje IN VARCHAR2)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_CNP.P_MARCALINEAERROR';
      v_nnumerr      NUMBER := 0;
   BEGIN
      v_nnumerr := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_ssproces, p_nlinea,
                                                                     p_nnumerr, p_ntipo,
                                                                     p_ncodigo, p_tmensaje);

      IF v_nnumerr <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(v_tobjeto, 1, v_nnumerr,
                       'p=' || p_ssproces || ' l=' || p_nlinea || ' n=' || p_nnumerr || ' t='
                       || p_ntipo || ' c=' || p_ncodigo || ' m=' || p_tmensaje,
                       p_ssproces,
                       'Error ' || v_nnumerr || ' l=' || p_nlinea || ' c=' || p_ncodigo);
         v_nnumerr := 1;
      END IF;

      RETURN v_nnumerr;
   END p_marcalineaerror;

   /*************************************************************************
                                      Función que devuelve una fecha,
          si la conversión de char a fecha es correcta.
          param p_ttexto      IN  : caracter a convertir
          param p_tformato    IN  : formato fecha a convertir
          devuelve fecha o null si existe error.
      *************************************************************************/
   FUNCTION converteix_charadate(p_ttexto IN VARCHAR2, p_tformato IN VARCHAR2)
      RETURN DATE IS
      v_fret         DATE;
   BEGIN
      BEGIN
         v_fret := TO_DATE(p_ttexto, p_tformato);
      EXCEPTION
         WHEN OTHERS THEN
            v_fret := NULL;
      END;

      RETURN v_fret;
   END converteix_charadate;

   /*************************************************************************
             Función que devuelve un número,
          si la conversión de char a numerco es correcta.
          param pt_txt    IN  : caracter a convertir
          devuelve número o null si existe error.
      *************************************************************************/
   FUNCTION converteix_charanum(p_ttxt IN VARCHAR2)
      RETURN NUMBER IS
      v_nret         NUMBER;
   BEGIN
      BEGIN
         v_nret := TO_NUMBER(p_ttxt);
      EXCEPTION
         WHEN OTHERS THEN
            v_nret := NULL;
      END;

      RETURN v_nret;
   END converteix_charanum;

   /*************************************************************************
             Función que da correspondencia valor de la empresa en la interface con axis.
          param in p_tcodigo : código a buscar
          param in p_tvalemp : código valor de la empresa
          return : código valor de axis (nulo si no existe)
      *************************************************************************/
   FUNCTION f_buscavalor(p_tcodigo IN VARCHAR2, p_tvalemp IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_vret         int_codigos_emp.cvalaxis%TYPE;
   BEGIN
      SELECT MAX(cvalaxis)
        INTO v_vret
        FROM int_codigos_emp
       WHERE cempres = vg_nempresaaxis
         AND ccodigo = p_tcodigo
         AND cvalemp = p_tvalemp;

      RETURN v_vret;
   END f_buscavalor;

   /***************************************************************************
         FUNCTION f_next_carga
      Asigna número de carga
         return         : Número de carga
   ***************************************************************************/
   FUNCTION f_next_carga
      RETURN NUMBER IS
      v_nseq         NUMBER;
   BEGIN
      SELECT sncarga.NEXTVAL
        INTO v_nseq
        FROM DUAL;

      RETURN v_nseq;
   END f_next_carga;

   /***************************************************************************
         FUNCTION f_ins_mig_logs_emp
      Inserta registro en la tabla de logs de las cargas de las tablas APRA a
      tablas MIG
         param in p_ncarga : número de carga
         param in p_tmigpk : valor primary key del registro de APRA
         param in p_ttipo  : tipo log (E=error, I=Información, W-Warning)
         param in p_ttexto  : Texto log
         return           : código error
   ***************************************************************************/
   FUNCTION f_ins_mig_logs_emp(
      p_ncarga IN NUMBER,
      p_tmigpk IN VARCHAR2,
      p_ttipo IN VARCHAR2,
      p_ttexto IN VARCHAR2,
      p_nseq OUT NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      SELECT sseqlogmig.NEXTVAL
        INTO p_nseq
        FROM DUAL;

      INSERT INTO mig_logs_emp
                  (ncarga, seqlog, fecha, mig_pk, tipo, incid)
           VALUES (p_ncarga, p_nseq, f_sysdate, p_tmigpk, p_ttipo, p_ttexto);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_ins_mig_logs_emp;

   /*************************************************************************
         Proceso que controla y junta el texto de una clausula (para altas y suples).
      param p_tide IN : identificador beneficiario
      param p_tnom IN : nombre beneficiario
      param p_tpar IN : participacion beneficiario
      param p_ttexto IN OUT: devuelve texto de la clausula
      *************************************************************************/
   PROCEDURE p_textoclausula(
      p_tide IN VARCHAR2,
      p_tnom IN VARCHAR2,
      p_tpar IN VARCHAR2,
      p_ttexto IN OUT VARCHAR2) IS
      v_nmaxtxt      NUMBER := 2000;   -- Longitud máxima texto clausula
      v_tsep         VARCHAR2(1) := '#';   -- Separador texto clausula
   BEGIN
      IF p_tide || p_tnom || p_tpar IS NOT NULL THEN   -- si viene algo
         IF p_ttexto IS NOT NULL THEN
            p_ttexto := p_ttexto || CHR(10);
         END IF;

         IF LENGTH(p_ttexto || p_tide || v_tsep || p_tnom || v_tsep || p_tpar) > v_nmaxtxt THEN
            NULL;
         ELSE
            p_ttexto := p_ttexto || p_tide || v_tsep || p_tnom || v_tsep || p_tpar;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_ttexto := NULL;
   END p_textoclausula;

   -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
   /*************************************************************************
    Funcion que recupera la persona en Host
        param in x: registro tratado tipo int_polizas_cnp
        param out reg_datos_pers: registro datos persona Host
        param out reg_datos_dir: registro datos direccion Host
        param out reg_datos_contac: registro datos contacto Host
        param out reg_datos_cc: registro datos cuenta Host
        return : 0 si ha ido bien
    *************************************************************************/
   FUNCTION f_busca_person_host(
      x IN int_polizas_cnp%ROWTYPE,
      reg_datos_pers OUT int_datos_persona%ROWTYPE,
      reg_datos_dir OUT int_datos_direccion%ROWTYPE,
      reg_datos_contac OUT int_datos_contacto%ROWTYPE,
      reg_datos_cc OUT int_datos_cuenta%ROWTYPE,
      psinterf IN OUT int_mensajes.sinterf%TYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CNP.F_BUSCA_PERSON_HOST';
      vtraza         NUMBER := 0;
      num_err        NUMBER;
      vcterminal     usuarios.cterminal%TYPE;
      werror         VARCHAR2(2000);
      womasdatos     NUMBER;
      pmasdatos      NUMBER;
      wcont_pers     NUMBER;
      wsperson       per_personas.sperson%TYPE;
      err_busca_pers_host EXCEPTION;
   BEGIN
      IF x.campo01 = '02' THEN
         num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);
         num_err :=
            pac_con.f_busqueda_persona
                                  (pac_md_common.f_get_cxtempresa,   -- pempresa IN NUMBER,
                                   NULL,   -- x.nif_tomador,   -- psip IN VARCHAR2,
                                   NULL,   --v_mig_personas.ctipide,   -- pctipdoc IN NUMBER,
                                   LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0'),   -- ptdocidentif IN VARCHAR2,
                                   NULL,   --x.nom_tomador,   -- ptnombre IN VARCHAR2,
                                   vcterminal,   -- pterminal IN VARCHAR2,
                                   pmasdatos,   -- pmasdatos IN NUMBER,
                                   womasdatos,   -- pomasdatos OUT NUMBER,
                                   psinterf,   -- psinterf IN OUT NUMBER,
                                   werror, NULL,   -- pcognom1 IN VARCHAR2 DEFAULT NULL,
                                   NULL,   -- pcognom2 IN VARCHAR2 DEFAULT NULL,
                                   pac_md_common.f_get_cxtusuario);   -- pusuario IN VARCHAR2

         IF num_err <> 0 THEN
            pac_cargas_cnp.p_genera_logs(vobj, vtraza, 'Error al buscar persona en host',
                                         'Error: ' || werror || ';sinterf = ' || psinterf
                                         || '; nif = '
                                         || LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0') || ' ('
                                         || x.proceso || '-' || x.nlinea || ')',
                                         x.proceso,
                                         'Error al buscar persona en host: ' || werror
                                         || '; nif = '
                                         || LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0') || ' ('
                                         || x.proceso || '-' || x.nlinea || ')');
            RETURN num_err;
         ELSE
            COMMIT;

            -- Recupera datos de Host si existe
            BEGIN
               SELECT *
                 INTO reg_datos_pers
                 FROM int_datos_persona
                WHERE sinterf = psinterf;
/*
               p_tab_error
                          (f_sysdate, f_user, 'f_busca_person_host', 666,
                           'recuperado de host. nif: ' || LPAD(LTRIM(x.campo23, '0'), 9, '0')
                           || ' - (' || x.proceso || '-' || x.nlinea || ')',
                           'reg_datos_pers. sip-tdocidentif-csexo-fnacimi-ctipdoc-sinterf: '
                           || reg_datos_pers.sip || '-' || reg_datos_pers.tdocidentif || '-'
                           || reg_datos_pers.csexo || '-' || reg_datos_pers.fnacimi || '-'
                           || reg_datos_pers.ctipdoc || '-' || reg_datos_pers.sinterf);
*/
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
/*
                  p_tab_error(f_sysdate, f_user, 'duplicado f_BUSCA_person_host', 666,
                              'DUPLICADO. nif: ' || LPAD(LTRIM(x.campo23, '0'), 9, '0')
                              || ' -sinterf: ' || psinterf,
                              '(' || x.proceso || '-' || x.nlinea || ')');
*/
                  BEGIN
                     SELECT *
                       INTO reg_datos_pers
                       FROM int_datos_persona
                      WHERE sinterf = psinterf
                        AND sip NOT LIKE '%mcp';
/*
                     p_tab_error
                          (f_sysdate, f_user, 'f_busca_person_host del duplicado', 666,
                           'recuperado de host. nif: ' || LPAD(LTRIM(x.campo23, '0'), 9, '0')
                           || ' - (' || x.proceso || '-' || x.nlinea || ')',
                           'reg_datos_pers. sip-tdocidentif-csexo-fnacimi-ctipdoc-sinterf: '
                           || reg_datos_pers.sip || '-' || reg_datos_pers.tdocidentif || '-'
                           || reg_datos_pers.csexo || '-' || reg_datos_pers.fnacimi || '-'
                           || reg_datos_pers.ctipdoc || '-' || reg_datos_pers.sinterf);
*/
                  EXCEPTION
                     WHEN OTHERS THEN
                        RAISE err_busca_pers_host;
                  END;
               WHEN NO_DATA_FOUND THEN
                  RAISE err_busca_pers_host;
            END;

            BEGIN
               SELECT *
                 INTO reg_datos_dir
                 FROM int_datos_direccion
                WHERE sinterf = psinterf;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            BEGIN
               SELECT *
                 INTO reg_datos_contac
                 FROM int_datos_contacto
                WHERE sinterf = psinterf;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            BEGIN
               SELECT *
                 INTO reg_datos_cc
                 FROM int_datos_cuenta
                WHERE sinterf = psinterf;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN err_busca_pers_host THEN
--         p_tab_error(f_sysdate, f_user, 'f_busca_person_host', 666,
--                     'no encuentra persona en host. nif: ' || wnnunnif || ' -sinterf: '
--                     || psinterf,
--                     '(' || x.proceso || '-' || x.nlinea || ')');
         pac_cargas_cnp.p_genera_logs(vobj, vtraza, 'No encuentra persona en host',
                                      'sinterf = ' || psinterf || '; nif = '
                                      || LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0') || ' ('
                                      || x.proceso || '-' || x.nlinea || ')',
                                      x.proceso,
                                      'No encuentra persona en host' || ';sinterf = '
                                      || psinterf || '; nif = '
                                      || LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0') || ' ('
                                      || x.proceso || '-' || x.nlinea || ')');
             --num_err := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL,x.poliza, x.ncarga);
--             num_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145,
--                                  'Error recuperando persona de Host. nif: '
--                                  || wnnunnif || ' - sinterf: ' || psinterf || ' - ('
--                                  || x.proceso || '-' || x.nlinea || ')');
         RETURN 0;
      WHEN OTHERS THEN
         pac_cargas_cnp.p_genera_logs(vobj, vtraza,
                                      'Error no controlado al buscar persona en Host'
                                      || SQLERRM,
                                      'sinterf = ' || psinterf || '; nif = '
                                      || LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0') || ' ('
                                      || x.proceso || '-' || x.nlinea || ')',
                                      x.proceso,
                                      'Error no controlado' || SQLERRM || ';sinterf = '
                                      || psinterf || '; nif = '
                                      || LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0') || ' ('
                                      || x.proceso || '-' || x.nlinea || ')');
         pterror := 'Error no controlado al buscar persona en Host' || SQLERRM;
         RETURN 1;
   END f_busca_person_host;

   -- Fi Bug 17569

   -- Bug 0017569 - FAL - 11/02/2011 - CRT - Interfases y gestión personas
   /*************************************************************************
        Función que da de alta la persona en Host
          param in x : registro tipo int_polizas_CNP
          param in psinterf: id interfase obtenido en la busqueda persona host
          return : 0 si ha ido bien
    *************************************************************************/
   FUNCTION f_alta_persona_host(
      x IN OUT int_polizas_cnp%ROWTYPE,
      psinterf IN int_mensajes.sinterf%TYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CNP.F_ALTA_PERSONA_HOST';
      vtraza         NUMBER := 0;
      wsperson       per_personas.sperson%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      werror         VARCHAR2(2000);
      wsinterf       NUMBER;
      num_err        NUMBER;
      wcont_pers     NUMBER;
      wnnumnif       per_personas.nnumide%TYPE;
      err_busca_pers EXCEPTION;
      err_alta_host  EXCEPTION;
   BEGIN
      IF x.campo01 = '02' THEN
         wcont_pers := 0;

         SELECT COUNT(*)
           INTO wcont_pers
           FROM int_datos_persona
          WHERE sinterf = psinterf;

         IF wcont_pers = 0 THEN   -- No existe en Host. Se tiene que dar de alta en host.
            wsperson := NULL;

            BEGIN
               SELECT sperson
                 INTO wsperson
                 FROM per_personas
                WHERE nnumide = LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0');
            EXCEPTION
               WHEN OTHERS THEN
                  wnnumnif := x.campo23;
                  RAISE err_busca_pers;
            END;

            wsinterf := NULL;
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, wsperson,
                                              vcterminal, wsinterf /*psinterf*/, werror,
                                              pac_md_common.f_get_cxtusuario);

            IF num_err <> 0 THEN
               RAISE err_alta_host;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN err_busca_pers THEN
         pac_cargas_cnp.p_genera_logs
                                    (vobj, vtraza, SQLCODE,
                                     'Error al recuperar persona en Alta Host; nnumide = '
                                     || wnnumnif || ' (' || x.proceso || '-' || x.nlinea
                                     || ')',
                                     x.proceso,
                                     'Error al recuperar persona en Alta Host; nnumide = '
                                     || wnnumnif || ' (' || x.proceso || '-' || x.nlinea
                                     || ')');
         --num_err := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL, x.poliza, x.ncarga);
         --num_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, 'Error al recuperar persona en Alta Host; nnumide = '|| wnnumnif || ' - ('|| x.proceso || '-' || x.nlinea || ')');
         RETURN 0;
      WHEN err_alta_host THEN
         IF werror LIKE '%ORA-00001%' THEN   -- no genere log por PK violada en mi_posible_cliente
            RETURN 0;
         END IF;

         pac_cargas_cnp.p_genera_logs(vobj, vtraza, 'Error en alta host',
                                      ' Error: ' || werror || '; sinterf: ' || wsinterf
                                      || '; sperson = ' || wsperson || ' (' || x.proceso || '-'
                                      || x.nlinea || ')',
                                      x.proceso,
                                      'Error en alta host: ' || werror || '; sperson = '
                                      || wsperson || ' (' || x.proceso || '-' || x.nlinea
                                      || ')');
         --num_err := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL, x.poliza, x.ncarga);
         --num_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, 'Error en alta host: '||werror||' sperson = '|| wsperson||' sinterf = '||wsinterf|| ' - ('|| x.proceso || '-' || x.nlinea || ')');
         pterror := werror || '; sinterf: ' || wsinterf || '; sperson = ' || wsperson;
         RETURN 2;
      WHEN OTHERS THEN
         pterror := 'Error no controlado an alta persona en Host' || SQLERRM;
         RETURN 1;
   END f_alta_persona_host;

   -- Fi Bug 17569

   -- 15490/88884 - FAL. 04/07/2011. Generar recibo para traspasos de entrada y generar siniestro para traspasos de salida.
   /*************************************************************************
      Funcion que crea un siniestro en sin_siniestro --a partir del registro tipo int_polizas_cnp. Es un siniestro con un pago.
      Si ppagado es true lo abre paga y cierra (siniestros de ahorro), sii n olo deja en valoración abierto.
      param  x in out: Registro tipo int_polizas_cnp.
      param  p_n_seg in : Es el sseguro de lap´póliza
      param p_tipo_oper : Rescate,..
      param pimporte in : Importe
      param psidepag  out  : Pago de siniestro
      ppagado BOOLEAN in default true: Indica si el siniestro está pagado cerrado.
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION f_crea_siniestro(
      x IN OUT int_polizas_cnp%ROWTYPE,
      p_n_seg IN NUMBER,
      p_causin IN NUMBER,
      p_motsin IN NUMBER,
      pimporte IN NUMBER,
      pncarga IN NUMBER,
      p_toperacion IN VARCHAR2,
      pdsidepag OUT NUMBER,
      ppagado IN BOOLEAN DEFAULT TRUE,
      pctipcap IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      v_mig_seg      mig_seguros%ROWTYPE;
      --Sin_siniestro
      v_mig_siniestros mig_sin_siniestro%ROWTYPE;
      --Sin_movsiniestro
      v_mig_movsin   mig_sin_movsiniestro%ROWTYPE;
      v_cont_movsin  NUMBER := 0;
      --Sin_tramitacion
      v_mig_tramit   mig_sin_tramitacion%ROWTYPE;
      --Sin_tramita_movimiento
      v_mig_tramit_mov mig_sin_tramita_movimiento%ROWTYPE;
      v_cont_movtra  NUMBER := 0;
      --SIN_TRAMITA_RESERVA
      v_mig_tramit_res mig_sin_tramita_reserva%ROWTYPE;
      v_mig_personas mig_personas%ROWTYPE;
      v_nmov_res     NUMBER := 0;
      v_imp_total_res NUMBER := 0;
      v_nmov_pago    NUMBER := 0;
      --SIN_TRAMITA_PAGO_GAR
      v_mig_tramit_pago_g mig_sin_tramita_pago_gar%ROWTYPE;
      v_nmov_pago_g  NUMBER := 0;
      --SIN_TRAMITA_PAGO
      v_mig_tramit_pago mig_sin_tramita_pago%ROWTYPE;
      --SIN_TRAMITA_PAGO_MOV
      v_mig_tramit_movpago mig_sin_tramita_movpago%ROWTYPE;
      v_mig_tramit_dest mig_sin_tramita_dest%ROWTYPE;
      v_sidepag      NUMBER := 0;
      v_cgarant      NUMBER;
      vcontmov       NUMBER;
      vtraza         NUMBER;
      vn_mov         NUMBER;
      errdatos       EXCEPTION;
      vimporte       NUMBER;
      vmot           NUMBER;
      p_deserror     VARCHAR2(200);
--      v_ncarga       NUMBER;
      vnum_err       NUMBER;
      v_seq          NUMBER;
      vcerror        NUMBER;
      v_rowid        ROWID;
      vn_aux         NUMBER;
      vccausin       NUMBER;
      vcmotsin       NUMBER;
      visinret       NUMBER;
      vtipomovulk    NUMBER;
      vbucle         NUMBER := 0;
      vnerror        NUMBER;
      vacumpercent   NUMBER := 0;
      xidistrib      NUMBER := 0;
      vacumrounded   NUMBER := 0;
      viuniact       NUMBER;
      vvalorf        DATE;
      hi_hac         NUMBER;
      vestado        VARCHAR2(200);
      vnsinies       sin_siniestro.nsinies%TYPE;
      vccompani      seguros.ccompani%TYPE;
      wfechmov       DATE;
      v_importeretencion NUMBER;
   BEGIN
      --Inicializamos la cabecera de la carga
      vtraza := 1500;

      IF p_n_seg IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetro seguro nulo al crear siniestro';
         RAISE errdatos;
      END IF;

      IF p_causin IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetro causa nulo al crear siniestro';
         RAISE errdatos;
      END IF;

      IF p_motsin IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetro motivo nulo al crear siniestro';
         RAISE errdatos;
      END IF;

      IF pimporte IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetro importe nulo al crear siniestro';
         RAISE errdatos;
      END IF;

      vtraza := 1505;
--      v_ncarga := f_next_carga;  -- se pasa por parametro
      vnum_err := f_ins_mig_logs_emp(pncarga, 'Inicio', 'I', 'Carga Siniestro', v_seq);
      vtraza := 1520;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (pncarga, vg_nempresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
      vtraza := 1525;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SEGUROS', 0);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_PERSONAS', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_SINIESTRO', 2);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_MOVSINIESTRO', 3);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_TRAMITACION', 4);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_TRAMITA_MOVIMIENTO', 5);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_TRAMITA_RESERVA', 6);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_TRAMITA_PAGO_GAR', 7);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_TRAMITA_PAGO', 8);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_TRAMITA_MOVPAGO', 9);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SIN_TRAMITA_DEST', 10);

      vtraza := 1530;
      v_mig_siniestros.ncarga := pncarga;
      v_mig_siniestros.cestmig := 1;
      --v_mig_siniestros.mig_pk := pncarga || '-' || x.poliza_participe || '-' || x.producto;
      v_mig_siniestros.mig_pk := pncarga || '-' || x.nlinea || '/1';
      v_mig_siniestros.mig_fk := v_mig_siniestros.mig_pk;
      v_mig_siniestros.nsinies := 0;   --JRH IMPx.sinieann || x.sinienum;
      v_mig_siniestros.sseguro := 0;
      v_mig_siniestros.nriesgo := 1;
      v_mig_siniestros.nmovimi := 0;
/*
      IF TO_DATE(x.fec_anulacion, 'dd/mm/rrrr') BETWEEN TO_DATE(x.fec_inicio_periodo,
                                                                'dd/mm/rrrr')
                                                    AND TO_DATE(x.fec_fin_periodo,
                                                                'dd/mm/rrrr') THEN
         v_mig_siniestros.fsinies := NVL(TO_DATE(x.fec_anulacion, 'dd/mm/rrrr'),
                                         TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'));
      ELSE
         v_mig_siniestros.fsinies := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');   --JRH IMP Mirar donde viene
      END IF;
*/
      wfechmov := converteix_charadate(x.campo07, 'yyyymmdd');
      v_mig_siniestros.fsinies := wfechmov;

      IF v_mig_siniestros.fsinies IS NULL THEN
         p_deserror := 'Fecha de inicio de periodo nula';
         vcerror := 1000135;
         RAISE errdatos;
      END IF;

      v_mig_siniestros.fnotifi := v_mig_siniestros.fsinies;
      v_mig_siniestros.ccausin := p_causin;
      v_mig_siniestros.cmotsin := p_motsin;
      v_mig_siniestros.cevento := NULL;
      v_mig_siniestros.cculpab := NULL;
      v_mig_siniestros.creclama := NULL;
      v_mig_siniestros.nasegur := NULL;
      v_mig_siniestros.cmeddec := NULL;
      v_mig_siniestros.ctipdec := NULL;
      v_mig_siniestros.tnomdec := NULL;
      v_mig_siniestros.tape1dec := NULL;
      v_mig_siniestros.tape2dec := NULL;
      v_mig_siniestros.tteldec := NULL;

      BEGIN
         SELECT tmotsin
           INTO v_mig_siniestros.tsinies
           FROM sin_desmotcau
          WHERE ccausin = p_causin
            AND cmotsin = p_motsin
            AND cidioma = vg_nidiomaaxis;
      EXCEPTION
         WHEN OTHERS THEN
            v_mig_siniestros.tsinies := 'SINIESTRO';
      END;

      v_mig_siniestros.cusualt := f_user;
      v_mig_siniestros.falta := f_sysdate;
      v_mig_siniestros.cusumod := NULL;
      v_mig_siniestros.fmodifi := NULL;
      v_mig_siniestros.ncuacoa := NULL;
      v_mig_siniestros.nsincoa := NULL;
      -- Necesitamos informar mig_seguros para join con mig_ctaseguro
      vtraza := 1540;

      SELECT pncarga ncarga, -4 cestmig, v_mig_siniestros.mig_pk mig_pk,
             v_mig_siniestros.mig_pk mig_fk, cagente, npoliza, ncertif,
             fefecto, creafac, cactivi, ctiprea,
             cidioma, cforpag, cempres, sproduc,
             casegur, nsuplem, sseguro, 0 sperson,
             ccompani
        INTO v_mig_seg.ncarga, v_mig_seg.cestmig, v_mig_seg.mig_pk,
             v_mig_seg.mig_fk, v_mig_seg.cagente, v_mig_seg.npoliza, v_mig_seg.ncertif,
             v_mig_seg.fefecto, v_mig_seg.creafac, v_mig_seg.cactivi, v_mig_seg.ctiprea,
             v_mig_seg.cidioma, v_mig_seg.cforpag, v_mig_seg.cempres, v_mig_seg.sproduc,
             v_mig_seg.casegur, v_mig_seg.nsuplem, v_mig_seg.sseguro, v_mig_seg.sperson,
             vccompani
        FROM seguros
       WHERE sseguro = p_n_seg;

      vtraza := 1550;

/*
      whaybenef:= 0;
      begin
        select count(*) into whaybenef
        from int_polizas_cnp
        where campo05 = x.campo05 and
              campo01 = '03' and
              campo03 = x.campo03;
      exception
        when others then
            whaybenef:= 0;
      end;
*/

      /*
            IF p_causin = 1
               AND p_motsin IN(0, 4)
               AND x.beneficiario IS NOT NULL THEN   --En caso de fallec. damos de alta el beneficiario JRH IMP (mirar estos motivos), o pasar por parámetro el tipo de destinatario
               v_mig_personas.ncarga := pncarga;
               v_mig_personas.cestmig := 1;
               v_mig_personas.mig_pk := v_mig_siniestros.mig_pk;
               v_mig_personas.idperson := 0;
               v_mig_personas.ctipide := 1;   --JRH IMP
               v_mig_personas.cestper := 0;   --JRH IMP
               v_mig_personas.cpertip := 0;
               v_mig_personas.swpubli := 0;
               v_mig_personas.tapelli1 := SUBSTR(x.beneficiario, 1, 40);
            ELSE
      */
      SELECT pncarga ncarga, -4 cestmig, v_mig_siniestros.mig_pk mig_pk,
             p.sperson, p.ctipide, p.cestper,
             1, p.swpubli, d.tapelli1
        INTO v_mig_personas.ncarga, v_mig_personas.cestmig, v_mig_personas.mig_pk,
             v_mig_personas.idperson, v_mig_personas.ctipide, v_mig_personas.cestper,
             v_mig_personas.cpertip, v_mig_personas.swpubli, v_mig_personas.tapelli1
        FROM asegurados a, per_personas p, per_detper d
       WHERE a.sseguro = p_n_seg
         AND a.norden = 1
         AND p.sperson = a.sperson
         AND d.cagente = ff_agente_cpervisio(v_mig_seg.cagente)
         AND d.sperson = p.sperson;   --En caso de que no sea el asegurado tendríamos que ver si nos lo envían

--      END IF;
      vtraza := 1575;

      SELECT MAX(nmovimi)
        INTO vn_mov
        FROM movseguro m
       WHERE m.sseguro = p_n_seg
         AND m.cmovseg <> 52;

      v_mig_siniestros.nmovimi := vn_mov;

      IF vn_mov IS NULL THEN
         p_deserror := 'Número movimiento(recibo) no existe: ' || p_n_seg;
         vcerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1580;

      INSERT INTO mig_seguros
           VALUES v_mig_seg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 0, v_mig_seg.mig_pk);

      INSERT INTO mig_personas
           VALUES v_mig_personas
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 1, v_mig_personas.mig_pk);

      vtraza := 1590;

      INSERT INTO mig_sin_siniestro
           VALUES v_mig_siniestros
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 2, v_mig_siniestros.mig_pk);

/*********************************************************
*********************************************************
mig_sin_movsiniestro
*********************************************************
*********************************************************
*********************************************************/

      --ALTA
      vtraza := 1600;
      v_cont_movsin := v_cont_movsin + 1;   ----Será 1
      v_mig_movsin := NULL;
      v_mig_movsin.ncarga := pncarga;
      v_mig_movsin.cestmig := 1;
      v_mig_movsin.mig_pk := v_mig_siniestros.mig_pk || '|' || v_cont_movsin;
      v_mig_movsin.mig_fk := v_mig_siniestros.mig_pk;
      v_mig_movsin.nsinies := 0;
      v_mig_movsin.nmovsin := v_cont_movsin;
      v_mig_movsin.cestsin := 0;
      v_mig_movsin.festsin := v_mig_siniestros.fsinies;
      v_mig_movsin.ccauest := NULL;
      v_mig_movsin.cunitra := '0';
      v_mig_movsin.ctramitad := '0';
      v_mig_movsin.cusualt := f_user;
      v_mig_movsin.falta := v_mig_siniestros.fsinies;
      vtraza := 1610;

      INSERT INTO mig_sin_movsiniestro
           VALUES v_mig_movsin
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 3, v_mig_movsin.mig_pk);

      --COBRO
      IF ppagado THEN
         vtraza := 1600;
         v_cont_movsin := v_cont_movsin + 1;
         v_mig_movsin := NULL;
         v_mig_movsin.ncarga := pncarga;
         v_mig_movsin.cestmig := 1;
         v_mig_movsin.mig_pk := v_mig_siniestros.mig_pk || '|' || v_cont_movsin;
         v_mig_movsin.mig_fk := v_mig_siniestros.mig_pk;
         v_mig_movsin.nsinies := 0;
         v_mig_movsin.nmovsin := v_cont_movsin;
         v_mig_movsin.cestsin := 1;
         v_mig_movsin.festsin := v_mig_siniestros.fsinies;
         v_mig_movsin.ccauest := NULL;
         v_mig_movsin.cunitra := '0';
         v_mig_movsin.ctramitad := '0';
         v_mig_movsin.cusualt := f_user;
         v_mig_movsin.falta := v_mig_siniestros.falta;
         vtraza := 1620;

         INSERT INTO mig_sin_movsiniestro
              VALUES v_mig_movsin
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, pncarga, 3, v_mig_movsin.mig_pk);
      END IF;

/*********************************************************
*********************************************************
Tramitacion
*********************************************************
*********************************************************
*********************************************************/
      v_mig_tramit := NULL;
      v_mig_tramit.ncarga := pncarga;
      v_mig_tramit.cestmig := 1;
      v_mig_tramit.mig_pk := v_mig_siniestros.mig_pk || ':' || 0;
      v_mig_tramit.mig_fk := v_mig_siniestros.mig_pk;
      v_mig_tramit.nsinies := 0;
      v_mig_tramit.ntramit := 0;   --JRH ?
      v_mig_tramit.ctramit := 0;
      v_mig_tramit.ctcausin := NULL;   --3?? - JRH IMP
      v_mig_tramit.cinform := 0;
      v_mig_tramit.cusualt := f_user;
      v_mig_tramit.falta := v_mig_siniestros.falta;   --JRH
      v_mig_tramit.cusumod := NULL;
      v_mig_tramit.fmodifi := NULL;
      vtraza := 1630;

      INSERT INTO mig_sin_tramitacion
           VALUES v_mig_tramit
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 4, v_mig_tramit.mig_pk);

/*********************************************************
*********************************************************
MIG_SIN_TRAMITA_MOVIMIENTO
*********************************************************
*********************************************************
*********************************************************/
      v_mig_tramit_mov := NULL;
      v_mig_tramit_mov.ncarga := pncarga;
      v_mig_tramit_mov.cestmig := 1;
      --SINIEANN|SINIENUM|NTRAMIT|NMOVTRA
      v_mig_tramit_mov.mig_pk := v_mig_tramit.mig_pk || ':' || v_cont_movtra;
      v_mig_tramit_mov.mig_fk := v_mig_tramit.mig_pk;
      v_mig_tramit_mov.nsinies := 0;
      v_mig_tramit_mov.ntramit := 0;
      v_mig_tramit_mov.nmovtra := v_cont_movtra;
      v_mig_tramit_mov.cunitra := '0';
      v_mig_tramit_mov.ctramitad := '0';
      v_mig_tramit_mov.cesttra := 0;
      v_mig_tramit_mov.csubtra := 0;
      v_mig_tramit_mov.festtra := v_mig_siniestros.fsinies;
      v_mig_tramit_mov.cusualt := f_user;
      v_mig_tramit_mov.falta := v_mig_siniestros.falta;
      vtraza := 1640;

      INSERT INTO mig_sin_tramita_movimiento
           VALUES v_mig_tramit_mov
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 5, v_mig_tramit_mov.mig_pk);

      IF ppagado THEN
--Siniestro cerrado
         vtraza := 1650;
         v_mig_tramit_mov := NULL;
         v_mig_tramit_mov.ncarga := pncarga;
         v_mig_tramit_mov.cestmig := 1;
         v_cont_movtra := v_cont_movtra + 1;   --Será 1
         --SINIEANN|SINIENUM|NTRAMIT|NMOVTRA
         v_mig_tramit_mov.mig_pk := v_mig_tramit.mig_pk || ':' || v_cont_movtra;
         v_mig_tramit_mov.mig_fk := v_mig_tramit.mig_pk;
         v_mig_tramit_mov.nsinies := 0;
         v_mig_tramit_mov.ntramit := 0;
         v_mig_tramit_mov.nmovtra := v_cont_movtra;
         v_mig_tramit_mov.cunitra := '0';
         v_mig_tramit_mov.ctramitad := '0';   --JRH IMP
         v_mig_tramit_mov.cesttra := 2;
         v_mig_tramit_mov.csubtra := 10;   --JRH IMP Esto esta bien?
         v_mig_tramit_mov.festtra := v_mig_siniestros.fsinies;
         v_mig_tramit_mov.cusualt := f_user;
         v_mig_tramit_mov.falta := v_mig_siniestros.falta;
         vtraza := 1660;

         INSERT INTO mig_sin_tramita_movimiento
              VALUES v_mig_tramit_mov
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, pncarga, 5, v_mig_tramit_mov.mig_pk);
      END IF;

/*********************************************************
*********************************************************
MIG_SIN_TRAMITA_RESERVA
*********************************************************
*********************************************************/
      SELECT cgarant
        INTO v_cgarant
        FROM garanpro
       WHERE sproduc = v_mig_seg.sproduc
         AND ROWNUM = 1;   -- --JRH IMP Como la sacamos

      vtraza := 1670;
      v_nmov_res := v_nmov_res + 1;
      v_mig_tramit_res := NULL;
      v_mig_tramit_res.ncarga := pncarga;
      v_mig_tramit_res.cestmig := 1;
      v_mig_tramit_res.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit || ':'
                                 || 1 || ':' || v_nmov_res;
      v_mig_tramit_res.mig_fk := v_mig_tramit.mig_pk;
      v_mig_tramit_res.nsinies := 0;
      v_mig_tramit_res.ntramit := v_mig_tramit.ntramit;
      v_mig_tramit_res.ctipres := 1;
      v_mig_tramit_res.nmovres := v_nmov_res;
      v_mig_tramit_res.cgarant := v_cgarant;
      v_mig_tramit_res.ccalres := 0;
      v_mig_tramit_res.fmovres := v_mig_siniestros.fsinies;   --JHR ??
      v_mig_tramit_res.cmonres := 'EUR';
      v_importeretencion := converteix_charanum(x.campo11) / 100;
      v_mig_tramit_res.ireserva := pimporte + NVL(v_importeretencion, 0);
      v_mig_tramit_res.ipago := NULL;
      v_mig_tramit_res.iingreso := NULL;
      v_mig_tramit_res.irecobro := NULL;
      v_mig_tramit_res.icaprie := pimporte + NVL(v_importeretencion, 0);
      v_mig_tramit_res.ipenali := NULL;
      v_mig_tramit_res.iingreso := NULL;
      v_mig_tramit_res.iingreso := NULL;
      --v_mig_tramit_res.fresini := x.efectann;
      --v_mig_tramit_res.fresfin := NULL;
      v_mig_tramit_res.fultpag := NULL;
      v_mig_tramit_res.sidepag := NULL;
      v_mig_tramit_res.sproces := NULL;
      v_mig_tramit_res.fcontab := NULL;
      v_mig_tramit_res.cusualt := f_user;
      v_mig_tramit_res.falta := v_mig_siniestros.falta;   --JHR ??
      v_mig_tramit_res.cusumod := NULL;
      v_mig_tramit_res.fmodifi := NULL;
      vtraza := 1680;

      INSERT INTO mig_sin_tramita_reserva
           VALUES v_mig_tramit_res
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 6, v_mig_tramit_res.mig_pk);

      IF ppagado THEN
--Si se ha pagado
         v_nmov_res := v_nmov_res + 1;
         v_mig_tramit_res := NULL;
         v_mig_tramit_res.ncarga := pncarga;
         v_mig_tramit_res.cestmig := 1;
         vtraza := 1690;
         v_mig_tramit_res.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                    || ':' || 1 || ':' || v_nmov_res;
         v_mig_tramit_res.mig_fk := v_mig_tramit.mig_pk;
         v_mig_tramit_res.nsinies := 0;
         v_mig_tramit_res.ntramit := v_mig_tramit.ntramit;
         v_mig_tramit_res.ctipres := 1;
         v_mig_tramit_res.nmovres := v_nmov_res;
         v_mig_tramit_res.cgarant := v_cgarant;
         v_mig_tramit_res.ccalres := 0;
         v_mig_tramit_res.fmovres := v_mig_siniestros.fsinies;
         v_mig_tramit_res.cmonres := 'EUR';
         v_mig_tramit_res.ireserva := 0;
         v_mig_tramit_res.ipago := pimporte + NVL(v_importeretencion, 0);
         v_mig_tramit_res.iingreso := NULL;
         v_mig_tramit_res.irecobro := NULL;
         v_mig_tramit_res.icaprie := pimporte + NVL(v_importeretencion, 0);
         v_mig_tramit_res.ipenali := NULL;
         v_mig_tramit_res.iingreso := NULL;
         v_mig_tramit_res.iingreso := NULL;
         --v_mig_tramit_res.fresini := x.efectann;
         --v_mig_tramit_res.fresfin := NULL;
         v_mig_tramit_res.fultpag := NULL;
         v_mig_tramit_res.sidepag := NULL;
         v_mig_tramit_res.sproces := NULL;
         v_mig_tramit_res.fcontab := NULL;
         v_mig_tramit_res.cusualt := f_user;
         v_mig_tramit_res.falta := v_mig_siniestros.falta;
         v_mig_tramit_res.cusumod := NULL;
         v_mig_tramit_res.fmodifi := NULL;
         vtraza := 1700;

         INSERT INTO mig_sin_tramita_reserva
              VALUES v_mig_tramit_res
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, pncarga, 6, v_mig_tramit_res.mig_pk);

/*********************************************************
*********************************************************
 v_mig_tramit_pago_g
*********************************************************
*********************************************************
*********************************************************/
--si se ha pagado
         vtraza := 1720;
         v_sidepag := v_sidepag + 1;
         v_mig_tramit_pago_g := NULL;
         v_mig_tramit_pago_g.ncarga := pncarga;
         v_mig_tramit_pago_g.cestmig := 1;
         v_mig_tramit_pago_g.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                       || ':' || 1 || ':' || v_nmov_res || ':' || v_sidepag;
         --NSINIES+NTRAMIT
         v_mig_tramit_pago_g.mig_fk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                       || ':' || v_sidepag;
         v_mig_tramit_pago_g.sidepag := v_sidepag;
         v_mig_tramit_pago_g.ctipres := 1;
         v_mig_tramit_pago_g.norden := v_sidepag;
         v_mig_tramit_pago_g.nmovres := v_nmov_res;
         v_mig_tramit_pago_g.cgarant := v_cgarant;
         v_mig_tramit_pago_g.fperini := NULL;
         v_mig_tramit_pago_g.fperfin := NULL;
         v_mig_tramit_pago_g.cmonres := NULL;
         v_mig_tramit_pago_g.isinret := pimporte + NVL(v_importeretencion, 0);   --JRH IMP De momento un parámetro
--         v_mig_tramit_pago_g.iretenc := NVL(x.imp_presta_pens_retenciones, 0);   --JRH IMP Mirar donde viene   int_rga
         v_mig_tramit_pago_g.iretenc := NVL(v_importeretencion, 0);   --JRH IMP Mirar donde viene   int_rga
         v_mig_tramit_pago_g.iiva := 0;
         v_mig_tramit_pago_g.isuplid := NULL;
         v_mig_tramit_pago_g.ifranq := 0;
         v_mig_tramit_pago_g.iresrcm := NULL;
         v_mig_tramit_pago_g.cmonpag := NULL;
         v_mig_tramit_pago_g.isinretpag := NULL;
         v_mig_tramit_pago_g.iivapag := NULL;
         v_mig_tramit_pago_g.isuplidpag := NULL;
         v_mig_tramit_pago_g.iretencpag := NULL;
         v_mig_tramit_pago_g.ifranqpag := NULL;
         v_mig_tramit_pago_g.iresrcmpag := NULL;
         v_mig_tramit_pago_g.iresredpag := NULL;
         v_mig_tramit_pago_g.fcambio := NULL;
         v_mig_tramit_pago_g.pretenc := 0;   --JRH IMP c.iirpfpor;
         v_mig_tramit_pago_g.piva := NULL;
         v_mig_tramit_pago_g.cusualt := f_user;
         v_mig_tramit_pago_g.falta := v_mig_siniestros.fsinies;
         v_mig_tramit_pago_g.cusumod := NULL;
         v_mig_tramit_pago_g.fmodifi := NULL;
         vtraza := 1730;

         INSERT INTO mig_sin_tramita_pago_gar
              VALUES v_mig_tramit_pago_g
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, pncarga, 7, v_mig_tramit_pago_g.mig_pk);

/*********************************************************
*********************************************************
 mig_sin_tramita_pago
*********************************************************
*********************************************************
*********************************************************/
--si se ha pagado
         v_mig_tramit_pago := NULL;
         v_mig_tramit_pago.ncarga := pncarga;
         v_mig_tramit_pago.cestmig := 1;
         v_mig_tramit_pago.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                     || ':' || v_mig_tramit_pago_g.sidepag;
         v_mig_tramit_pago.mig_fk := v_mig_personas.mig_pk;
         --Buscamos la mig_pk de personas
         v_mig_tramit_pago.mig_fk2 := v_mig_tramit.mig_pk;
         v_mig_tramit_pago.sidepag := 0;
         v_mig_tramit_pago.nsinies := '0';
         v_mig_tramit_pago.ntramit := v_mig_tramit.ntramit;
         v_mig_tramit_pago.sperson := 0;
         vtraza := 1740;

         IF p_causin = 1
            AND p_motsin IN(0, 4) THEN
            v_mig_tramit_pago.ctipdes := 6;   --JRH IMP
         ELSE
            v_mig_tramit_pago.ctipdes := 1;   --JRH IMP
         END IF;

         v_mig_tramit_pago.ctippag := 2;
         v_mig_tramit_pago.cconpag := 1;
         v_mig_tramit_pago.ccauind := 0;
         v_mig_tramit_pago.cforpag := 1;
         v_mig_tramit_pago.fordpag := v_mig_siniestros.fsinies;
         v_mig_tramit_pago.ctipban := NULL;
         v_mig_tramit_pago.cbancar := NULL;
         v_mig_tramit_pago.cmonres := NULL;
         v_mig_tramit_pago.isinret := pimporte + NVL(v_importeretencion, 0);   --JRH IMP De momento parámetro
         v_mig_tramit_pago.iretenc := NVL(v_importeretencion, 0);   --JRH IMP ?
         v_mig_tramit_pago.iiva := NULL;
         v_mig_tramit_pago.isuplid := NULL;
         v_mig_tramit_pago.ifranq := NULL;
         v_mig_tramit_pago.iresrcm := NULL;
         v_mig_tramit_pago.iresred := NULL;
         v_mig_tramit_pago.cmonpag := NULL;
         v_mig_tramit_pago.isinretpag := NULL;
         v_mig_tramit_pago.iretencpag := NULL;
         v_mig_tramit_pago.iivapag := NULL;
         v_mig_tramit_pago.isuplidpag := NULL;
         v_mig_tramit_pago.ifranqpag := NULL;
         v_mig_tramit_pago.iresrcmpag := NULL;
         v_mig_tramit_pago.iresredpag := NULL;
         v_mig_tramit_pago.fcambio := NULL;
         v_mig_tramit_pago.nfacref := NULL;
         v_mig_tramit_pago.ffacref := NULL;
         v_mig_tramit_pago.cusualt := f_user;
         v_mig_tramit_pago.falta := v_mig_siniestros.falta;
         v_mig_tramit_pago.cusumod := NULL;
         v_mig_tramit_pago.fmodifi := NULL;
         v_mig_tramit_pago.ctransfer := NULL;
         vtraza := 1750;

         INSERT INTO mig_sin_tramita_pago
              VALUES v_mig_tramit_pago
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, pncarga, 8, v_mig_tramit_pago.mig_pk);

/*********************************************************
*********************************************************
 mig_sin_tramita_movpago
*********************************************************
*********************************************************
*********************************************************/
         v_nmov_pago := v_nmov_pago + 1;
         v_mig_tramit_movpago := NULL;
         v_mig_tramit_movpago.ncarga := pncarga;
         v_mig_tramit_movpago.cestmig := 1;
         v_mig_tramit_movpago.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                        || ':' || v_mig_tramit_pago_g.sidepag || ':'
                                        || v_nmov_pago;
         v_mig_tramit_movpago.mig_fk := v_mig_tramit_pago.mig_pk;   --v_mig_tramit.mig_pk || ':'
         --|| v_mig_tramit_pago_g.sidepag;
         v_mig_tramit_movpago.sidepag := v_mig_tramit_pago_g.sidepag;
         v_mig_tramit_movpago.nmovpag := v_nmov_pago;
         v_mig_tramit_movpago.cestpag := 0;
         v_mig_tramit_movpago.fefepag := v_mig_siniestros.falta;
         v_mig_tramit_movpago.cestval := 0;
         v_mig_tramit_movpago.fcontab := NULL;
         v_mig_tramit_movpago.sproces := NULL;
         v_mig_tramit_movpago.cusualt := f_user;
         v_mig_tramit_movpago.falta := v_mig_siniestros.falta;

         INSERT INTO mig_sin_tramita_movpago
              VALUES v_mig_tramit_movpago
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, pncarga, 9, v_mig_tramit_movpago.mig_pk);

         vtraza := 1760;
--Si se paga
         v_nmov_pago := v_nmov_pago + 1;
         v_mig_tramit_movpago := NULL;
         v_mig_tramit_movpago.ncarga := pncarga;
         v_mig_tramit_movpago.cestmig := 1;
         v_mig_tramit_movpago.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                        || ':' || v_mig_tramit_pago_g.sidepag || ':'
                                        || v_nmov_pago;
         v_mig_tramit_movpago.mig_fk := v_mig_tramit_pago.mig_pk;   --v_mig_tramit.mig_pk || ':'
         -- || v_mig_tramit_pago_g.sidepag;
         v_mig_tramit_movpago.sidepag := v_mig_tramit_pago_g.sidepag;
         v_mig_tramit_movpago.nmovpag := v_nmov_pago;
         v_mig_tramit_movpago.cestpag := 1;
         v_mig_tramit_movpago.fefepag := v_mig_siniestros.falta;
         v_mig_tramit_movpago.cestval := 1;
         v_mig_tramit_movpago.fcontab := NULL;
         v_mig_tramit_movpago.sproces := NULL;
         v_mig_tramit_movpago.cusualt := f_user;
         v_mig_tramit_movpago.falta := v_mig_siniestros.falta;
         vtraza := 1770;

         INSERT INTO mig_sin_tramita_movpago
              VALUES v_mig_tramit_movpago
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, pncarga, 9, v_mig_tramit_movpago.mig_pk);
      END IF;

      IF NVL(v_mig_personas.idperson, 0) <> 0 THEN
         v_mig_tramit_dest := NULL;
         v_mig_tramit_dest.ncarga := pncarga;
         v_mig_tramit_dest.cestmig := 1;
         v_mig_tramit_dest.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                     || ':' || 'D' || ':' || '1';
         v_mig_tramit_dest.mig_fk := v_mig_tramit.mig_pk;   --v_mig_tramit.mig_pk || ':'
         -- || v_mig_tramit_pago_g.sidepag;
         v_mig_tramit_dest.nsinies := 0;
         v_mig_tramit_dest.ntramit := v_mig_tramit.ntramit;
         v_mig_tramit_dest.sperson := v_mig_personas.idperson;
         v_mig_tramit_dest.ctipdes := NVL(v_mig_tramit_pago.ctipdes, 1);
         v_mig_tramit_dest.cpagdes := 1;
         v_mig_tramit_dest.cusualt := f_user;
         v_mig_tramit_dest.falta := v_mig_siniestros.falta;
         v_mig_tramit_dest.ctipban := NULL;
         v_mig_tramit_dest.cbancar := NULL;
         v_mig_tramit_dest.pasigna := 100;
         v_mig_tramit_dest.ctipcap := pctipcap;
         vtraza := 1770;

         INSERT INTO mig_sin_tramita_dest
              VALUES v_mig_tramit_dest
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, pncarga, 10, v_mig_tramit_dest.mig_pk);
      END IF;

/*********************************************************
*********************************************************
Generación
*********************************************************
*********************************************************
*********************************************************/
      UPDATE int_polizas_cnp
         SET ncarga = pncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1730;
      x.ncarga := pncarga;
      --   COMMIT;
      --TRASPASAMOS A LAS REALES
      pac_mig_axis.p_migra_cargas(x.nlinea, 'C', x.ncarga, 'DEL');
      vtraza := 1740;

      --Cargamos las SEG para la póliza (ncarga)
      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 1640;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                TO_NUMBER(x.campo05),   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         vtraza := 1780;
         vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 151840, reg.incid);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         vtraza := 1790;
         p_deserror := 'Fallo al cargar el siniestro';
         vcerror := 108953;
         RAISE errdatos;
      END LOOP;

      vtraza := 1800;

      BEGIN
         SELECT nsinies
           INTO vnsinies
           FROM mig_sin_siniestro
          WHERE ncarga = x.ncarga;

         UPDATE sin_siniestro
            SET ccompani = vccompani
          WHERE nsinies = vnsinies;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   --JRH IMP de momento
      END;

      vtraza := 1900;

      IF ppagado THEN
         SELECT MAX(sidepag)
           INTO pdsidepag
           FROM sin_siniestro s, sin_tramita_pago p
          WHERE s.sseguro = p_n_seg
            AND p.nsinies = s.nsinies
            AND NOT EXISTS(SELECT 1
                             FROM ctaseguro c
                            WHERE c.nsinies = p.nsinies
                              AND c.sseguro = s.sseguro);   --Partimos de que no estará creado

         vtraza := 1810;

         IF pdsidepag IS NULL THEN
            p_deserror := 'Fallo al cargar el pago';
            vcerror := 108953;   --Revisar errores
            RAISE errdatos;
         END IF;
      END IF;

      vtraza := 1820;
      RETURN 0;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         vn_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                TO_NUMBER(x.campo05),   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, vcerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (traza=' || vtraza || ') ' || SQLCODE
                       || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         vn_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                TO_NUMBER(x.campo05),   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_crea_siniestro;

   FUNCTION f_crea_recibo(
      x IN OUT int_polizas_cnp%ROWTYPE,
      p_nseg IN NUMBER,
      p_imprecibo IN NUMBER,
      p_impcomisi IN NUMBER,
      p_tiporec IN NUMBER,
      pncarga IN NUMBER,
      p_toperacion IN VARCHAR2,
      p_nrecibo OUT NUMBER,
      p_recanulac IN NUMBER DEFAULT NULL,
      p_cestado_rec IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vnum_err       NUMBER;
      v_seq          NUMBER;
      v_mig_rec      mig_recibos%ROWTYPE;
      n_mov          NUMBER;
      v_mig_seg      mig_seguros%ROWTYPE;
      vagrpro        NUMBER;
      vcramo         seguros.cramo%TYPE;
      v_fec_efecto   DATE;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      v_rowid        ROWID;
      v_sproduc      productos.sproduc%TYPE;
      v_mig_recdet   mig_detrecibos%ROWTYPE;
      v_i            BOOLEAN := FALSE;
      vtraza         NUMBER;
      v_nrecibo      NUMBER;
      n_aux          NUMBER;
      p_deserror     VARCHAR2(1000);
      v_importeretencion NUMBER;
      v_naux         NUMBER;
   BEGIN
         --Inicializamos la cabecera de la carga
--         v_ncarga := f_next_carga;
      vnum_err := f_ins_mig_logs_emp(pncarga, 'Inicio', 'I', 'Carga Recibos', v_seq);
      vtraza := 1120;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (pncarga, vg_nempresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
      vtraza := 1125;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SEGUROS', 0);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_RECIBOS', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_DETRECIBOS', 2);

      vtraza := 1130;
      --v_mig_rec.mig_pk := pncarga || '-' || x.poliza_participe || '-' || x.producto;
      v_mig_rec.mig_pk := pncarga || '-' || x.nlinea || '/1';
      v_mig_rec.mig_fk := v_mig_rec.mig_pk;
      v_mig_rec.ncarga := pncarga;
      v_mig_rec.cestmig := 1;
      --jlb -- por defecto que sea el que llega --v_mig_rec.ctiprec := NULL;
      v_mig_rec.ctiprec := p_tiporec;
      -- Necesitamos informar mig_seguros para join con mig_recibos
      vtraza := 1135;

      SELECT pncarga ncarga, -4 cestmig, v_mig_rec.mig_pk mig_pk, v_mig_rec.mig_pk mig_fk,
             cagente, npoliza, ncertif, fefecto,
             creafac, cactivi, ctiprea, cidioma,
             cforpag, cempres, sproduc, casegur,
             nsuplem, sseguro, 0 sperson, cagrpro, cramo
        INTO v_mig_seg.ncarga, v_mig_seg.cestmig, v_mig_seg.mig_pk, v_mig_seg.mig_fk,
             v_mig_seg.cagente, v_mig_seg.npoliza, v_mig_seg.ncertif, v_mig_seg.fefecto,
             v_mig_seg.creafac, v_mig_seg.cactivi, v_mig_seg.ctiprea, v_mig_seg.cidioma,
             v_mig_seg.cforpag, v_mig_seg.cempres, v_mig_seg.sproduc, v_mig_seg.casegur,
             v_mig_seg.nsuplem, v_mig_seg.sseguro, v_mig_seg.sperson, vagrpro, vcramo
        FROM seguros
       WHERE sseguro = p_nseg;

      vtraza := 1140;

      SELECT MAX(nmovimi)
        INTO n_mov
        FROM movseguro m
       WHERE m.sseguro = p_nseg
         AND m.cmovseg <> 52;

      IF n_mov IS NULL THEN
         p_deserror := 'Número movimiento(recibo) no existe: ' || x.campo05;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1143;

      INSERT INTO mig_seguros
           VALUES v_mig_seg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 0, v_mig_seg.mig_pk);

      vtraza := 1145;
      --SI ES UN RECIBO DE ANULACIÓN JUGAMOS CON LA FECHA DE ANULACIÓN
/*
         IF p_recanulac IS NOT NULL
            AND x.fec_anulacion IS NOT NULL THEN
            v_fec_efecto := x.fec_anulacion;
         ELSE
             /*Cosas a mirar para fechas y tipo movimiento*/
            /* Si prima_anualizada <> suma(iprianu) garanseg y no está en periodo de renovación me creo que es un
               suplemento. Cojo fecha inicio del periodo.
               Sino es una cartera y cojo dia efecto / mes año del periodo
               Al generar el recibo si el último movimiento no es de cartera marco el recibo como suplemento

               Revisando descubrimos que la fecha de efecto es la fecha de última renovación
               */

      /*
            SELECT SUM(NVL(iprianu, 0))
              INTO v_iprianu
              FROM garanseg g
             WHERE sseguro = n_seg
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM garanseg g2
                               WHERE g2.sseguro = g.sseguro);

            IF NVL(x.prima_neta_anualizada, 0) <> v_iprianu
               AND TO_CHAR(TO_DATE(x.fec_efecto, 'dd/mm/rrrr'), 'mm') <>
                                     TO_CHAR(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'), 'mm') THEN
               v_fec_efecto := x.fec_inicio_periodo;

               --Si decidimos que es un suplemento marcamos tipo de recibo suplemento.
               IF p_tiporec <> 9 THEN
                  --v_mig_rec.ctiprec := 1;
                  v_mig_rec.ctiprec := 3;   -- ya no hay suplementos todo es cartera
               END IF;
            ELSE
               nmeses := CEIL(MONTHS_BETWEEN(x.fec_inicio_periodo,
                                             NVL(x.fec_efecto, x.fec_contratacion)));
               v_fec_efecto := ADD_MONTHS(NVL(x.fec_efecto, x.fec_contratacion), nmeses);
            /*v_fec_efecto := TO_DATE(TO_CHAR(TO_DATE(x.fec_efecto, 'dd/mm/rrrr'), 'dd/')
                                    || TO_CHAR(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'),
                                               'mm/rrrr'),
                                    'dd/mm/rrrr');*/
/*            END IF;
         END IF;
*/
      v_fec_efecto := converteix_charadate(LTRIM(x.campo07), 'yyyymmdd');
/*
         --ICV CONSIDERACIÓN DE APORT EXTRA
         IF   --x.tipo_oper = 'MODI' -- SIEMPRE INDEPENDIENTE DE MODI
              --AND
            NVL(x.importe_emitidos_prod, 0) <> 0
            --JRH 17/02/2011
            --AND x.empresa IN(12, 13)
            --AND NVL(pac_mdpar_productos.f_get_parproducto('CUENTA_SEGURO', v_mig_seg.sproduc),
              --      0) = 1
            AND vcramo <> 82   -- vida riesgo
            AND vagrpro IN(2, 21)
            AND NVL(x.imp_aport_extraord_neta, 0) = 0 THEN   --JRH Antes no lo teníamos este campo
            --JRH 17/02/2011
            v_mig_rec.ctiprec := 4;
         END IF;
*/

      --v_mig_rec.fefecto := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'); ICV
      v_mig_rec.fefecto := TO_DATE(v_fec_efecto, 'dd/mm/rrrr');

      IF v_mig_rec.fefecto IS NULL THEN
         p_deserror := 'Fecha de efecto recibo nula';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1150;

            --CALCULAR APARTIR DE LA CFORPAG
           /* 0 - fefecto+1
      1 - add_months(fefectom,12)
      2 - add_months(fefecto,6)
      3 - add_months(fefecto,4)
      4 - add_months(fefecto,3)
      6 - add_months(fefecto,2)
      12 - add_months(fefecto,1)*/
      IF v_mig_seg.cforpag IS NULL THEN
         p_deserror := 'Forma de Pago no definida';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      IF v_mig_seg.cforpag = 0 THEN   --unica
         v_mig_rec.fvencim := TO_DATE(v_fec_efecto, 'dd/mm/rrrr');
      ELSIF v_mig_seg.cforpag = 1 THEN   --anual
         v_mig_rec.fvencim := ADD_MONTHS(TO_DATE(v_fec_efecto, 'dd/mm/rrrr'), 12);
      ELSIF v_mig_seg.cforpag = 2 THEN   --semestral
         v_mig_rec.fvencim := ADD_MONTHS(TO_DATE(v_fec_efecto, 'dd/mm/rrrr'), 6);
      ELSIF v_mig_seg.cforpag = 3 THEN   --cuatrimestral
         v_mig_rec.fvencim := ADD_MONTHS(TO_DATE(v_fec_efecto, 'dd/mm/rrrr'), 4);
      ELSIF v_mig_seg.cforpag = 4 THEN   --trimestral
         v_mig_rec.fvencim := ADD_MONTHS(TO_DATE(v_fec_efecto, 'dd/mm/rrrr'), 3);
      ELSIF v_mig_seg.cforpag = 6 THEN   --bimestral
         v_mig_rec.fvencim := ADD_MONTHS(TO_DATE(v_fec_efecto, 'dd/mm/rrrr'), 2);
      ELSIF v_mig_seg.cforpag = 12 THEN   --mensual
         v_mig_rec.fvencim := ADD_MONTHS(TO_DATE(v_fec_efecto, 'dd/mm/rrrr'), 1);
      END IF;

      --v_mig_rec.fvencim := TO_DATE(x.fec_fin_periodo, 'dd/mm/rrrr');
      IF v_mig_rec.fvencim IS NULL THEN
         p_deserror := 'Fecha de fin de periodo nula';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1155;
      v_mig_rec.femisio := v_mig_rec.fefecto;

      IF v_mig_rec.ctiprec IS NULL THEN
         IF NVL(p_recanulac, 0) = 0 THEN
            IF p_tiporec = 0 THEN
               IF n_mov = 1 THEN
                  v_mig_rec.ctiprec := 0;
               ELSE
                  --v_mig_rec.ctiprec := 1;
                  v_mig_rec.ctiprec := 3;
               END IF;
            ELSE
               v_mig_rec.ctiprec := 3;
            END IF;
         ELSE
            v_mig_rec.ctiprec := 9;
         END IF;
      END IF;

      v_mig_rec.nmovimi := n_mov;
      --v_mig_rec.cestrec := 1;
      v_mig_rec.cestrec := p_cestado_rec;
      v_mig_rec.sseguro := 0;

      INSERT INTO mig_recibos
           VALUES v_mig_rec
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 1, v_mig_rec.mig_pk);

      vtraza := 1160;
      vtraza := 1165;
      v_sproduc := pac_cargas_cnp.f_buscavalor('CRT_PRODUCTOCNPPLAN', x.campo03);

      DECLARE
         v_rie          riesgos.nriesgo%TYPE;
         v_gar          garanpro.cgarant%TYPE;

         CURSOR c_gar IS
            SELECT   cgarant
                FROM garanpro
               WHERE sproduc = v_sproduc
                 AND ctipgar = 2
            ORDER BY norden;

         PROCEDURE crea_detalle(p_concep IN NUMBER, p_import IN NUMBER) IS
         BEGIN
            vtraza := 1170;
            v_mig_recdet.ncarga := pncarga;
            v_mig_recdet.cestmig := 1;
            v_mig_recdet.mig_pk := v_mig_rec.mig_pk || '-' || LTRIM(TO_CHAR(p_concep, '09'));
            v_mig_recdet.mig_fk := v_mig_rec.mig_pk;
            v_mig_recdet.cconcep := p_concep;
            v_mig_recdet.cgarant := v_gar;
            v_mig_recdet.nriesgo := 1;
            v_mig_recdet.iconcep := ABS(p_import);
            v_mig_recdet.nmovima := 1;
            vtraza := 1175;

            INSERT INTO mig_detrecibos
                 VALUES v_mig_recdet
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, pncarga, 2, v_mig_recdet.mig_pk);
         END;
      BEGIN
         -- Por defecto primer riesgo.
         vtraza := 1180;

         OPEN c_gar;

         FETCH c_gar
          INTO v_gar;

         CLOSE c_gar;

         vtraza := 1185;
         v_importeretencion := converteix_charanum(x.campo11) / 100;
         v_naux := converteix_charanum(x.campo09);

         IF v_naux IS NULL THEN
            p_deserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
            cerror := 1000135;
            RAISE errdatos;
         ELSE
            v_naux := v_naux / 100;
         END IF;

         crea_detalle(00, NVL(ABS(v_naux), 0));   --> 00-Prima Neta
         crea_detalle(12, NVL(ABS(v_importeretencion), 0));   --> 12-Retencion
      --crea_detalle(11, ABS(p_impcomisi));   --> 11-Comisión bruta
      --crea_detalle(13, ABS(x.importe_descuento_om));   --> Descuento OM
      --crea_detalle(08, x.recargo);   --> 02-Consorcio
      --crea_detalle(04, x.impuestos);   --> 04-Impuesto IPS
      END;

-------------------- FINAL ---------------------
      vtraza := 1190;
      vtraza := 1193;

      UPDATE int_polizas_cnp
         SET ncarga = pncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1195;
      x.ncarga := pncarga;
      --   COMMIT;
      --TRASPASAMOS A LAS REALES
      pac_mig_axis.p_migra_cargas(x.nlinea, 'C', x.ncarga, 'DEL');

      --Cargamos las SEG para la póliza (ncarga)
      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 1200;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         v_i := TRUE;
         vtraza := 1201;
         vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 151840, reg.incid);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         p_deserror := 'Fallo al cargar el recibo';
         cerror := 108953;
         RAISE errdatos;
      END LOOP;

      SELECT MAX(nrecibo)
        INTO p_nrecibo
        FROM recibos r
       WHERE r.sseguro = p_nseg
         AND NOT EXISTS(SELECT '1'
                          FROM ctaseguro c
                         WHERE c.sseguro = r.sseguro
                           AND c.nrecibo = r.nrecibo);

      vtraza := 1199;
      RETURN 0;   --ok
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         pac_cargas_cnp.p_genera_logs('f_alta_recibos', vtraza, 'Error:' || cerror,
                                      'Parámetro ' || x.campo05 || '-' || ' seg:' || p_nseg,
                                      x.proceso, ' seg:' || p_nseg || '-' || SQLCODE);
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (traza=' || vtraza || ') ' || SQLCODE
                       || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END;   -- f_crea_recibo

   /*************************************************************************
      Funcion que inserta una renta en pagosrenta
      param  x in out: Registro tipo int_rga.
      param  p_n_seg in : Es el sseguro de lap´póliza
      param pimporte in : Importe de la renta
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION f_crea_renta(
      x IN OUT int_polizas_cnp%ROWTYPE,
      p_n_seg IN NUMBER,
      pimporte NUMBER,
      pncarga IN NUMBER,
      p_toperacion IN VARCHAR2,
      psrecren OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vn_mov         NUMBER;
      errdatos       EXCEPTION;
      vmot           NUMBER;
      p_deserror     VARCHAR2(200);
      --v_ncarga       NUMBER;
      vnum_err       NUMBER;
      v_seq          NUMBER;
      vcerror        NUMBER;
      v_rowid        ROWID;
      vn_aux         NUMBER;
      vnsinies       NUMBER;
      vccausin       NUMBER;
      vcmotsin       NUMBER;
      visinret       NUMBER;
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_pag      mig_pagosrenta%ROWTYPE;
      v_mig_ase      mig_asegurados%ROWTYPE;
      v_importeretencion NUMBER;
   BEGIN
      --Inicializamos la cabecera de la carga
      vtraza := 1500;

      IF p_n_seg IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetros nulos al migrar rentas';
         RAISE errdatos;
      END IF;

      IF pimporte IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetros nulos al migrar rentas';
         RAISE errdatos;
      END IF;

      vtraza := 1510;
      --v_ncarga := f_next_carga;
      vnum_err := f_ins_mig_logs_emp(pncarga, 'Inicio', 'I', 'Rentas', v_seq);
      vtraza := 1520;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (pncarga, vg_nempresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
      vtraza := 1525;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_SEGUROS', 0);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_ASEGURADOS', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (pncarga, 'INT_POLIZAS_CNP', 'MIG_PAGOSRENTA', 2);

      vtraza := 1530;
      v_mig_pag.mig_pk := pncarga || '-' || x.nlinea || '/1';
      v_mig_pag.mig_fk := pncarga || '-' || x.nlinea || '/1';
      v_mig_pag.sseguro := 0;
      vtraza := 3;
      v_mig_pag.ffecefe := converteix_charadate(LTRIM(x.campo07), 'yyyymmdd');
      vtraza := 1545;

      IF v_mig_pag.ffecefe IS NULL THEN
         p_deserror := 'Fecha de inicio de periodo nula';
         vcerror := 1000135;
         RAISE errdatos;
      END IF;

      v_importeretencion := converteix_charanum(x.campo11) / 100;
      v_mig_pag.ffecpag := v_mig_pag.ffecefe;
      v_mig_pag.isinret := pimporte + v_importeretencion;
      vtraza := 4;
      v_mig_pag.pretenc := 0;   --JRH IMP De momento
      v_mig_pag.iretenc := v_importeretencion;
      v_mig_pag.ibase := pimporte;
      vtraza := 5;
      v_mig_pag.iconret := v_mig_pag.isinret - v_mig_pag.iretenc;
      v_mig_pag.ncarga := pncarga;
      v_mig_pag.cestmig := 1;
      --SELECT sperson
      --  INTO v_mig_pag.sperson
      --  FROM mig_asegurados
      -- WHERE mig_asegurados.mig_pk = TRIM(x.protoc) || '/' || TRIM(x.poliz) || '/'
       --                              || TRIM(x.ord);
      v_mig_pag.sperson := 0;

      BEGIN
         SELECT cbancar, ctipban
           INTO v_mig_pag.nctacor, v_mig_pag.ctipban
           FROM seguros
          WHERE sseguro = p_n_seg;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      SELECT pncarga ncarga, -4 cestmig, v_mig_pag.mig_pk mig_pk, v_mig_pag.mig_pk mig_fk,
             cagente, npoliza, ncertif, fefecto,
             creafac, cactivi, ctiprea, cidioma,
             cforpag, cempres, sproduc, casegur,
             nsuplem, sseguro, 0 sperson
        INTO v_mig_seg.ncarga, v_mig_seg.cestmig, v_mig_seg.mig_pk, v_mig_seg.mig_fk,
             v_mig_seg.cagente, v_mig_seg.npoliza, v_mig_seg.ncertif, v_mig_seg.fefecto,
             v_mig_seg.creafac, v_mig_seg.cactivi, v_mig_seg.ctiprea, v_mig_seg.cidioma,
             v_mig_seg.cforpag, v_mig_seg.cempres, v_mig_seg.sproduc, v_mig_seg.casegur,
             v_mig_seg.nsuplem, v_mig_seg.sseguro, v_mig_seg.sperson
        FROM seguros
       WHERE sseguro = p_n_seg;

      vtraza := 1574;

      SELECT pncarga ncarga, -4 cestmig, v_mig_pag.mig_pk mig_pk, v_mig_pag.mig_pk mig_fk,
             v_mig_pag.mig_pk mig_fk2, norden, ffecini, sseguro,
             sperson
        INTO v_mig_ase.ncarga, v_mig_ase.cestmig, v_mig_ase.mig_pk, v_mig_ase.mig_fk,
             v_mig_ase.mig_fk2, v_mig_ase.norden, v_mig_ase.ffecini, v_mig_ase.sseguro,
             v_mig_ase.sperson
        FROM asegurados
       WHERE sseguro = p_n_seg
         AND norden = 1;   --JRH IMP De momento

      vtraza := 1575;

      SELECT MAX(nmovimi)
        INTO vn_mov
        FROM movseguro m
       WHERE m.sseguro = p_n_seg
         AND m.cmovseg <> 52;

      IF vn_mov IS NULL THEN
         p_deserror := 'Número movimiento(recibo) no existe: ' || p_n_seg;
         vcerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1580;

      INSERT INTO mig_seguros
           VALUES v_mig_seg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 0, v_mig_seg.mig_pk);

      vtraza := 1585;

      INSERT INTO mig_asegurados
           VALUES v_mig_ase
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 1, v_mig_ase.mig_pk);

      vtraza := 1590;

      INSERT INTO mig_pagosrenta
           VALUES v_mig_pag
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, pncarga, 2, v_mig_pag.mig_pk);

      UPDATE int_rga
         SET ncarga = pncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1620;
      x.ncarga := pncarga;
      --   COMMIT;
      --TRASPASAMOS A LAS REALES
      pac_mig_axis.p_migra_cargas(x.nlinea, 'C', x.ncarga, 'DEL');
      vtraza := 1630;

      --Cargamos las SEG para la póliza (ncarga)
      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 1640;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         vtraza := 1650;
         vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 151840, reg.incid);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         p_deserror := 'Fallo al cargar el recibo';
         vcerror := 108953;
         RAISE errdatos;
      END LOOP;

      vtraza := 1640;

      SELECT MAX(srecren)
        INTO psrecren
        FROM pagosrenta
       WHERE sseguro = p_n_seg
         AND NOT EXISTS(SELECT 1
                          FROM ctaseguro c
                         WHERE c.sseguro = pagosrenta.sseguro
                           AND c.srecren = pagosrenta.srecren);   --Recuperamos la renta generada no pagada

      IF psrecren IS NULL THEN
         p_deserror := 'Fallo al buscar renta generada';
         vcerror := 110610;
         RAISE errdatos;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         vn_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, vcerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (f_crea_renta traza=' || vtraza
                       || ') ' || SQLCODE || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         vn_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_crea_renta;   -- f_crea_renta

   -- Fi Bug 15490/88884

   /*************************************************************************
                                                              procedimiento que da de alta póliza en las mig
          param in     p_ssproces     : Número proceso
          param in     p_tcampo05     : Número certificado
          param in     p_toperacion   : Tipo de operacion.
          return : 1 si ha habido error
                   2 si ha habido warning
                   4 si ha ido todo bien
      *************************************************************************/
   FUNCTION f_altapoliza_mig(
      p_ssproces IN NUMBER,
      p_tcampo05 IN VARCHAR2,
      p_toperacion IN VARCHAR2,
      p_campo03 IN VARCHAR2,
      p_campo01 IN VARCHAR2)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_CNP.F_ALTAPOLIZA_MIG';
      v_ntraza       NUMBER := 0;
      v_nnumerr      NUMBER;
      --Tablas nivel póliza
      reg_migpersonas mig_personas%ROWTYPE;
      reg_migseg     mig_seguros%ROWTYPE;
      reg_migmovseg  mig_movseguro%ROWTYPE;
      reg_migase     mig_asegurados%ROWTYPE;
      reg_migrie     mig_riesgos%ROWTYPE;
      reg_miggar     mig_garanseg%ROWTYPE;
      reg_migbenef   mig_clausuesp%ROWTYPE;
      reg_migulk     mig_seguros_ulk%ROWTYPE;
      reg_migctaseguro mig_ctaseguro%ROWTYPE;
      reg_mig_ctaseguro_libreta mig_ctaseguro_libreta%ROWTYPE;
      --
      e_errdatos     EXCEPTION;
      v_nauxlog      NUMBER;
      v_ncarga       NUMBER;
      v_cdomici      per_direcciones.cdomici%TYPE;
      v_tdeserror    VARCHAR2(1000);
      reg_productos  productos%ROWTYPE;
      n_nlineaact    NUMBER := 0;
      v_rowid        ROWID;
      v_videntifica  int_polizas_cnp.campo04%TYPE;
      v_bwarning     BOOLEAN;
      v_naux         NUMBER;
      v_ffecvalces   tabvalces.fvalor%TYPE;
      v_ncesta       tabvalces.ccesta%TYPE;
      v_baux         BOOLEAN := FALSE;
      v_ntiperr      NUMBER;
      v_sseguro      seguros.sseguro%TYPE;
      werrorsalida   NUMBER;   -- Bug 16324. 26/10/2010.FAL. Si es error lo devuelva para q pare carga si parametrizado como parar carga
      vnum_err       NUMBER;
      w_mig_pk_ant   mig_clausuesp.mig_pk%TYPE := NULL;
      w_cont_clausuben NUMBER := 1;
      wcmovimi_orig  VARCHAR2(5);
      wcmovimi_det   VARCHAR2(5);
      wcmovimi       VARCHAR2(5);
      wlinea         NUMBER;
      wcharaux       VARCHAR2(1);
      -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
      num_err        NUMBER;
      reg_dat_pers   int_datos_persona%ROWTYPE;
      reg_dat_dir    int_datos_direccion%ROWTYPE;
      reg_dat_contac int_datos_contacto%ROWTYPE;
      reg_dat_cc     int_datos_cuenta%ROWTYPE;
      psinterf       int_mensajes.sinterf%TYPE;
      wfechmov       DATE;
      terror         VARCHAR2(3000);
      v_seq          NUMBER;
      warning_alta_host BOOLEAN := FALSE;
      wfnacimi       VARCHAR2(10);
      wanyo          VARCHAR2(4);
      wmes           VARCHAR2(2);
      wdia           VARCHAR2(2);
      n_seg          NUMBER;
      v_cforpag      NUMBER;
      vsidepag       NUMBER;
      v_nrecibo      NUMBER;

      -- Fi Bug 17569
      CURSOR cur_polizas IS
         SELECT   *
             FROM int_polizas_cnp a
            WHERE proceso = p_ssproces
              AND campo01 = p_campo01
              AND campo03 = p_campo03
              AND campo05 = p_tcampo05
         ORDER BY nlinea, campo01, campo02;

      vnsinies       sin_siniestro.nsinies%TYPE;
      vccausin       sin_siniestro.ccausin%TYPE;
      vcmotsin       sin_siniestro.cmotsin%TYPE;
      visinret       NUMBER;
      psrecren       pagosrenta.srecren%TYPE;
      wccausin       sin_siniestro.ccausin%TYPE;
      wcmotsin       sin_siniestro.cmotsin%TYPE;
      wcagente       seguros.cagente%TYPE;
      wsproduc       seguros.sproduc%TYPE;
      w_numsinis     NUMBER;
      wnsinies       siniestros.nsinies%TYPE;
      wfsinies       siniestros.fsinies%TYPE;
      wfalta         siniestros.falta%TYPE;
      wntramit       sin_tramita_reserva.ntramit%TYPE;
      wnmovres       sin_tramita_reserva.nmovres%TYPE;
      wsperson       per_personas.sperson%TYPE;
      v_importeretencion NUMBER;
      v_cgarant      NUMBER;
   BEGIN
      v_ntraza := 1000;
      v_nnumerr := 0;
      n_nlineaact := 0;
      v_bwarning := FALSE;
      -- Validar fecha valor de la cesta
      v_ntraza := 1001;

      SELECT   MAX(campo04)
          INTO v_videntifica
          FROM int_polizas_cnp
         WHERE proceso = p_ssproces
           AND campo01 = '01'
      ORDER BY nlinea;

      IF v_videntifica IS NULL THEN
         v_tdeserror := 'Falta fecha fichero hasta';
         v_nnumerr := 1000135;
         RAISE e_errdatos;
      ELSE
         v_ntraza := 1002;
         v_ffecvalces := converteix_charadate(v_videntifica, 'yyyymmdd');

         IF v_ffecvalces IS NULL THEN
            v_tdeserror := 'Fecha fichero hasta no es fecha: ' || v_videntifica
                           || ' (aaaammdd)';
            v_nnumerr := 1000135;
            RAISE e_errdatos;
         END IF;
      END IF;

      v_ntraza := 1005;

      SELECT   MIN(nlinea)
          INTO v_videntifica
          FROM int_polizas_cnp a
         WHERE proceso = p_ssproces
           AND campo01 = '02'
           AND campo05 = p_tcampo05
      ORDER BY nlinea;

      --Inicializamos la cabecera de la carga
      v_ntraza := 1010;
      v_ncarga := f_next_carga;
      v_nnumerr := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Pólizas', v_nauxlog);
      v_ntraza := 1015;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, vg_nempresaaxis, f_sysdate, f_sysdate, v_videntifica, 'OK');

      v_ntraza := 1020;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_PERSONAS', 0);

      v_ntraza := 1025;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_SEGUROS', 1);

      v_ntraza := 1030;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_MOVSEGURO', 2);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_SEGUROS_ULK', 3);

      v_ntraza := 1036;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_ASEGURADOS', 5);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_RIESGOS', 6);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_CLAUSUESP', 7);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_GARANSEG', 8);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_CTASEGURO', 9);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_CNP', 'MIG_CTASEGURO_LIBRETA', 9);

      reg_migpersonas := NULL;
      reg_migseg := NULL;
      reg_migmovseg := NULL;
      reg_migulk := NULL;
      reg_migase := NULL;
      reg_migrie := NULL;
      reg_migbenef := NULL;
      reg_miggar := NULL;
      reg_migctaseguro := NULL;
      reg_mig_ctaseguro_libreta := NULL;
      reg_productos := NULL;

      FOR x IN cur_polizas LOOP
         n_nlineaact := x.nlinea;

         IF x.campo01 = '02' THEN   -- CERTIFICADO
            -- Comprobar si existe el certificado.
            DECLARE
               n_proval       NUMBER;
               n_polval       seguros.cpolcia%TYPE;
               n_cerval       NUMBER;
            BEGIN
               n_proval := pac_cargas_cnp.f_buscavalor('CRT_PRODUCTOCNPPLAN', x.campo03);
               --n_polval := NVL(f_parproductos_v(n_proval, 'NPOLIZA_COLECTIVO'), 0);
               --n_cerval := x.campo05;
               n_polval := x.campo05;

               SELECT COUNT(1)
                 INTO v_naux
                 FROM seguros
                WHERE   --npoliza = n_polval
                        --AND ncertif = n_cerval;
                      cpolcia = LTRIM(n_polval, '0')
                  AND sproduc = n_proval
                  AND cempres = vg_nempresaaxis;

               IF v_naux > 0 THEN
                  v_tdeserror := 'Ya existe póliza: ' || n_polval;
                  v_nnumerr := 108959;
                  RAISE e_errdatos;
               END IF;
            END;

            v_ntraza := 1040;
            reg_migpersonas.ncarga := v_ncarga;

            IF x.campo23 IS NULL THEN   -- dni
               v_tdeserror := 'Error en identificador';
               v_nnumerr := 110888;
               RAISE e_errdatos;
            END IF;

            v_ntraza := 1045;
            reg_migpersonas.mig_pk := v_ncarga || '/'
                                      || LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0');
            reg_migpersonas.snip := LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0');
            v_ntraza := 1050;
            -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
            -- Buscar persona tomador en Host
            reg_dat_pers := NULL;
            reg_dat_dir := NULL;
            reg_dat_contac := NULL;
            reg_dat_cc := NULL;

            IF k_busca_host = 1 THEN   -- FAL. 28/06/2011. Parametrizar la busqueda de personas host
               num_err := f_busca_person_host(x, reg_dat_pers, reg_dat_dir, reg_dat_contac,
                                              reg_dat_cc, psinterf, terror);

               IF num_err <> 0
                  AND terror IS NOT NULL THEN
                  SELECT sseqlogmig2.NEXTVAL
                    INTO v_seq
                    FROM DUAL;

                  INSERT INTO mig_logs_axis
                              (ncarga, seqlog, fecha, mig_pk, tipo,
                               incid)
                       VALUES (v_ncarga, v_seq, f_sysdate, v_ncarga || '/' || x.nlinea, 'W',
                               'Busqueda persona en Host: ' || terror);
               END IF;
            END IF;

            -- reg_migpersonas.ctipide := 27;
            reg_migpersonas.ctipide := NVL(reg_dat_pers.ctipdoc, 27);   -- NIF carga fichero (detvalor 672)
            -- Fi Bug 0017569
            reg_migpersonas.nnumide := LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0');

            SELECT MAX(sperson)
              INTO v_naux
              FROM per_personas
             WHERE nnumide = reg_migpersonas.nnumide
               AND ctipide = reg_migpersonas.ctipide;

            IF v_naux IS NULL THEN
               -- Si no existe damos de alta.
               reg_migpersonas.cestmig := 1;
               reg_migpersonas.idperson := 0;
            ELSE
               -- Recuperamos sperson
               reg_migpersonas.cestmig := -1;
               reg_migpersonas.idperson := v_naux;
            END IF;

            IF x.campo15 = '1' THEN
               reg_migpersonas.cestper := 1;   -- Invalido
            ELSE
               reg_migpersonas.cestper := 0;
            END IF;

            reg_migpersonas.cestciv := NVL(pac_cargas_cnp.f_buscavalor('CRTESTCIVILCNP',
                                                                       x.campo21),
                                           0);
            reg_migpersonas.cestciv := NVL(reg_dat_pers.cestciv, reg_migpersonas.cestciv);   -- Bug 0017569
            reg_migpersonas.cpertip := 1;
            reg_migpersonas.cpertip := NVL(reg_dat_pers.ctipper, 1);   -- Bug 0017569
            reg_migpersonas.swpubli := 0;
            v_ntraza := 1055;

            IF x.campo20 = 0 THEN   -- Varon
               reg_migpersonas.csexper := 1;
            ELSIF x.campo20 = 1 THEN   -- Hembra
               reg_migpersonas.csexper := 2;
            ELSE
               reg_migpersonas.csexper := NULL;
            END IF;

            reg_migpersonas.csexper := NVL(reg_dat_pers.csexo, reg_migpersonas.csexper);   -- Bug 0017569
            v_ntraza := 1060;

            --reg_migpersonas.fnacimi := converteix_charadate(x.campo22, 'yyyymmdd');
            IF x.campo22 IS NOT NULL THEN
               wanyo := SUBSTR(x.campo22, 1, 4);
               wmes := SUBSTR(x.campo22, 5, 2);
               wdia := SUBSTR(x.campo22, 7, 2);
               wfnacimi := wdia || '/' || wmes || '/' || wanyo;
            ELSE
               wfnacimi := NULL;
            END IF;

            reg_migpersonas.fnacimi := NVL(TO_CHAR(TO_DATE(reg_dat_pers.fnacimi, 'yyyy-mm-dd'),
                                                   'dd/mm/yyyy'),
                                           wfnacimi);

            -- to_date(x.campo22,'rrrrmmdd'));
            -- converteix_charadate(x.campo22, 'rrrrmmdd'));   -- Bug 0017569
            IF reg_migpersonas.fnacimi IS NULL THEN
               v_tdeserror := 'Fecha nacimiento no es fecha: ' || x.campo22 || ' (aaaammdd)';
               v_tdeserror :=
                  v_tdeserror
                  || '. Editar linea, modificar fecha nacimiento (campo22) y reprocesar';
               v_nnumerr := 1000135;
               RAISE e_errdatos;
            END IF;

            IF x.campo08 IS NOT NULL THEN
               reg_migpersonas.fjubila := converteix_charadate(x.campo08, 'yyyymmdd');
            END IF;

            reg_migpersonas.fjubila := NVL(reg_dat_pers.fjubila, reg_migpersonas.fjubila);   -- Bug 0017569
            v_ntraza := 1065;
            reg_migpersonas.cagente := ff_agente_cpervisio(x.campo04);
            reg_migpersonas.cagente := NVL(reg_dat_pers.cagente, reg_migpersonas.cagente);   -- Bug 0017569

            /*  -- jlb
                                                SELECT MAX(a.cagente)
               INTO reg_migpersonas.cagente
               FROM redcomercial a, agentes b
              WHERE a.cagente = reg_migpersonas.cagente
                AND a.cempres = vg_nempresaaxis
                AND b.cagente = a.cagente;*/
            IF reg_migpersonas.cagente IS NULL THEN
               v_bwarning := TRUE;
               p_genera_logs(v_tobjeto, v_ntraza, 'Código agente',
                             'No definido ' || x.campo04 || ' (linea ' || x.nlinea || ')',
                             x.proceso,
                             'Código agente No definido ' || x.campo04 || ' (linea '
                             || x.nlinea || ')');
               v_nnumerr :=
                  p_marcalinea
                     (x.proceso, x.nlinea, p_toperacion, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      TO_NUMBER(x.campo05),   -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      x.ncarga   -- Fi Bug 16324
                              );
               v_nnumerr := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 100504,
                                              'oficina ' || x.campo04);
               v_nnumerr := 0;
               v_bwarning := FALSE;
               -- Buscar agente por defecto.
               /*  SELECT MAX(cagente)
                                  INTO reg_migpersonas.cagente
                   FROM redcomercial
                  WHERE cempres = vg_nempresaaxis
                    AND ctipage = 0
                    AND cpadre IS NULL;*/
               -- jlb
                --reg_migpersonas.cagente := NVL(ff_agente_cpervisio(9999), '9999');
               reg_migpersonas.cagente := NVL(ff_agente_cpervisio(k_agente), k_agente);
            END IF;

            v_ntraza := 1070;

            IF x.campo16 IS NULL THEN
               v_bwarning := TRUE;
               p_genera_logs(v_tobjeto, v_ntraza, 'Nombre participe',
                             'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                             x.proceso,
                             'Nombre participe Campo vacio ' || ' (' || x.proceso || '-'
                             || x.nlinea || ')');
               v_nnumerr :=
                  p_marcalinea
                     (x.proceso, x.nlinea, p_toperacion, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      TO_NUMBER(x.campo05),   -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      x.ncarga   -- Fi Bug 16324
                              );
               v_nnumerr := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 9000759,
                                              x.campo16);
               v_nnumerr := 0;
               v_bwarning := FALSE;
            END IF;

            v_ntraza := 1075;
            v_ntraza := 1080;
            reg_migpersonas.tapelli1 := NVL(reg_dat_pers.tapelli1, SUBSTR(x.campo16, 1, 60));   -- Bug 0017569
            reg_migpersonas.tapelli2 := NVL(reg_dat_pers.tapelli2, NULL);   -- Bug 0017569
            reg_migpersonas.tnombre := NVL(reg_dat_pers.tnombre, NULL);   -- Bug 0017569
            -- Direccion Particular
            reg_migpersonas.ctipdir := NVL(reg_dat_dir.ctipdir, 1);   -- Bug 0017569
            reg_migpersonas.tnomvia := NVL(reg_dat_dir.tnomvia, SUBSTR(x.campo17, 1, 40));   -- Bug 0017569
            reg_migpersonas.nnumvia := NVL(reg_dat_dir.nnumvia, NULL);   -- Bug 0017569
            reg_migpersonas.tcomple := NULL;

            -- Buscar pais por defecto.
            SELECT MAX(c.cpais)
              INTO reg_migpersonas.cpais
              FROM empresas a, per_detper c
             WHERE a.cempres = vg_nempresaaxis
               AND c.sperson = a.sperson;

            reg_migpersonas.cpais := NVL(reg_dat_pers.cpais, reg_migpersonas.cpais);   -- Bug 0017569
            reg_migpersonas.cnacio := reg_migpersonas.cpais;
            reg_migpersonas.cnacio := NVL(reg_dat_pers.cnacioni, reg_migpersonas.cnacio);   -- Bug 0017569
            v_ntraza := 1085;

            IF x.campo19 IS NULL THEN
               v_bwarning := TRUE;
               p_genera_logs(v_tobjeto, v_ntraza, 'Código postal',
                             'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                             x.proceso,
                             'Código postal Campo vacio ' || ' (' || x.proceso || '-'
                             || x.nlinea || ')');
               v_nnumerr :=
                  p_marcalinea
                     (x.proceso, x.nlinea, p_toperacion, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      TO_NUMBER(x.campo05),   -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      x.ncarga   -- Fi Bug 16324
                              );
               v_nnumerr := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 1000651,
                                              'cp=' || x.campo19);
               v_nnumerr := 0;
               v_bwarning := FALSE;
               reg_migpersonas.cpostal := NULL;
            ELSE
               reg_migpersonas.cpostal := x.campo19;
            END IF;

            reg_migpersonas.cpostal := NVL(reg_dat_dir.cpostal, reg_migpersonas.cpostal);   -- Bug 0017569
            v_ntraza := 1090;

            IF x.campo19 IS NULL
               OR x.campo18 IS NULL THEN
               v_bwarning := TRUE;
               p_genera_logs(v_tobjeto, v_ntraza, 'Municipio o Codigo postal,',
                             ' Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                             x.proceso,
                             'Municipio o Codigo postal, Campo vacio ' || ' (' || x.proceso
                             || '-' || x.nlinea || ')');
               v_nnumerr :=
                  p_marcalinea
                     (x.proceso, x.nlinea, p_toperacion, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      TO_NUMBER(x.campo05),   -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      x.ncarga   -- Fi Bug 16324
                              );
               v_nnumerr := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 102330,
                                              'cp=' || x.campo19 || ' pob=' || x.campo18);
               v_nnumerr := 0;
               v_bwarning := FALSE;
               reg_migpersonas.cprovin := NULL;
               reg_migpersonas.cpoblac := NULL;
            ELSE
               -- Bug 0016525.03/11/2010.FAL
               /*
                              DECLARE
                  v_localidad    VARCHAR2(20);
                  b_buscarotro   BOOLEAN;
                  CURSOR cur_poblacion IS
                     SELECT   b.cprovin, b.cpoblac
                         FROM provincias a, poblaciones b, codpostal c
                        WHERE a.cpais = reg_migpersonas.cpais
                          AND b.cprovin = a.cprovin
                          AND c.cprovin = a.cprovin
                          AND c.cpoblac = b.cpoblac
                          AND c.cpostal = x.campo19
                          AND UPPER(b.tpoblac) LIKE UPPER(v_localidad) || '%'
                     ORDER BY 1, 2;
               BEGIN
                  v_ntraza := 1100;
                  b_buscarotro := TRUE;
                  v_localidad := RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.campo18), 'ÁÉÍÓÚ',
                                                             'AEIOU'))),
                                       '.');
                  IF b_buscarotro THEN
                     --Primera vez.
                     v_ntraza := 1105;
                     OPEN cur_poblacion;
                     FETCH cur_poblacion
                      INTO reg_migpersonas.cprovin, reg_migpersonas.cpoblac;
                     IF cur_poblacion%FOUND THEN
                        b_buscarotro := FALSE;
                     END IF;
                     CLOSE cur_poblacion;
                  END IF;
                  IF b_buscarotro THEN
                     --Segunda oportunidad para buscar.
                     v_localidad := REPLACE(v_localidad, 'DE ', '');
                     v_localidad := REPLACE(v_localidad, 'LA ', '');
                     v_localidad := REPLACE(v_localidad, 'EL ', '');
                     v_localidad := REPLACE(v_localidad, 'LOS ', '');
                     v_localidad := REPLACE(v_localidad, '(', '');
                     v_localidad := REPLACE(v_localidad, ')', '');
                     v_ntraza := 1105;
                     OPEN cur_poblacion;
                     FETCH cur_poblacion
                      INTO reg_migpersonas.cprovin, reg_migpersonas.cpoblac;
                     IF cur_poblacion%FOUND THEN
                        b_buscarotro := FALSE;
                     END IF;
                     CLOSE cur_poblacion;
                  END IF;
                  IF b_buscarotro THEN
                     -- final
                     p_genera_logs(v_tobjeto, v_ntraza, 'localidad cod_postal',
                                   'no definido ' || ' (' || x.proceso || '-' || x.nlinea
                                   || ')',
                                   x.proceso,
                                   'localidad cod_postal no definido ' || ' (' || x.proceso
                                   || '-' || x.nlinea || ')');
                     v_nnumerr := p_marcalinea(x.proceso, x.nlinea, p_toperacion, 2, 0, NULL,
                                               -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                               to_number(x.campo05),
                                               -- Fi Bug 14888
                                               -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                               x.ncarga
                                                       -- Fi Bug 16324
                                 );
                     v_nnumerr := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 102330,
                                                    x.campo19 || ' ' || x.campo18);
                     v_nnumerr := 0;
                     reg_migpersonas.cprovin := NULL;
                     reg_migpersonas.cpoblac := NULL;
                  END IF;
               END;
               */
               DECLARE
                  v_localidad    VARCHAR2(200);

                  CURSOR c1 IS
                     SELECT DISTINCT b.cprovin, b.cpoblac
                                FROM codpostal c, poblaciones b, provincias a
                               WHERE a.cpais = reg_migpersonas.cpais
                                 AND b.cprovin = a.cprovin
                                 AND(UPPER(b.tpoblac) LIKE UPPER(v_localidad))
                                 AND c.cpostal = LPAD(x.campo19, 5, '0')
                                 AND c.cprovin = a.cprovin
                                 AND c.cpoblac = b.cpoblac
                            ORDER BY 1, 2;
               BEGIN
                  v_localidad := RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.campo18), 'ÁÉÍÓÚ',
                                                             'AEIOU'))),
                                       '.');

                  OPEN c1;

                  FETCH c1
                   INTO reg_migpersonas.cprovin, reg_migpersonas.cpoblac;

                  IF c1%NOTFOUND THEN
                     CLOSE c1;

                     BEGIN
                        SELECT DISTINCT cprovin
                                   INTO reg_migpersonas.cprovin
                                   FROM codpostal
                                  WHERE cpostal = x.campo19;

                        vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                                     reg_migpersonas.cprovin,
                                                                     x.campo19,
                                                                     reg_migpersonas.cpoblac);

                        IF vnum_err <> 0 THEN
                           p_genera_logs(v_tobjeto, v_ntraza, 'localidad cod_postal',
                                         'no definido ' || ' (' || x.proceso || '-'
                                         || x.nlinea || '-' || x.campo18 || '-' || x.campo19
                                         || ')',
                                         x.proceso,
                                         'localidad cod_postal no definido ' || ' ('
                                         || x.proceso || '-' || x.nlinea || '-' || x.campo18
                                         || '-' || x.campo19 || ')');
                           reg_migpersonas.cprovin := NULL;
                           reg_migpersonas.cpoblac := NULL;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           BEGIN
                              SELECT SUBSTR(LPAD(x.campo19, 5, '0'), 1, 2)
                                INTO reg_migpersonas.cprovin
                                FROM DUAL;

                              vnum_err :=
                                 pac_int_online.f_crear_poblacion(v_localidad,
                                                                  reg_migpersonas.cprovin,
                                                                  x.campo19,
                                                                  reg_migpersonas.cpoblac);

                              IF vnum_err <> 0 THEN
                                 p_genera_logs(v_tobjeto, v_ntraza, 'localidad cod_postal',
                                               'no definido ' || ' (' || x.proceso || '-'
                                               || x.nlinea || '-' || x.campo18 || '-'
                                               || x.campo19 || ')',
                                               x.proceso,
                                               'localidad cod_postal no definido ' || ' ('
                                               || x.proceso || '-' || x.nlinea || '-'
                                               || x.campo18 || '-' || x.campo19 || ')');
                                 reg_migpersonas.cprovin := NULL;
                                 reg_migpersonas.cpoblac := NULL;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_genera_logs(v_tobjeto, v_ntraza, 'localidad cod_postal',
                                               'no definido ' || ' (' || x.proceso || '-'
                                               || x.nlinea || '-' || x.campo18 || '-'
                                               || x.campo19 || ')',
                                               x.proceso,
                                               'localidad cod_postal no definido ' || ' ('
                                               || x.proceso || '-' || x.nlinea || '-'
                                               || x.campo18 || '-' || x.campo19 || ')');
                                 reg_migpersonas.cprovin := NULL;
                                 reg_migpersonas.cpoblac := NULL;
                           END;
                     END;
                  ELSE
                     CLOSE c1;
                  END IF;
               END;
            -- Fi Bug 0016525
            END IF;

            reg_migpersonas.cprovin := NVL(reg_dat_dir.cprovin, reg_migpersonas.cprovin);   -- Bug 0017569
            reg_migpersonas.cpoblac := NVL(reg_dat_dir.cpoblac, reg_migpersonas.cpoblac);   -- Bug 0017569
            v_ntraza := 1110;
            reg_migpersonas.cidioma := vg_nidiomaaxis;
            reg_migpersonas.cidioma := NVL(reg_dat_pers.cidioma, reg_migpersonas.cidioma);   -- Bug 0017569
            v_ntraza := 1120;

            IF x.campo28 IS NOT NULL THEN
               reg_migpersonas.ctipban := 1;
               reg_migpersonas.cbancar := LPAD(SUBSTR(RTRIM(LPAD(x.campo25, 6, '0')), -4), 4,
                                               '0')
                                          || LPAD(SUBSTR(RTRIM(LPAD(x.campo27, 6, '0')), -4),
                                                  4, '0')
                                          || x.campo29 || x.campo28;
            END IF;

            reg_migpersonas.ctipban := NVL(reg_dat_cc.ctipban, reg_migpersonas.ctipban);   -- Bug 0017569
            reg_migpersonas.cbancar := NVL(reg_dat_cc.cbancar, reg_migpersonas.cbancar);   -- Bug 0017569

            INSERT INTO mig_personas
                 VALUES reg_migpersonas
              RETURNING ROWID
                   INTO v_rowid;

            v_ntraza := 1125;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 0, reg_migpersonas.mig_pk);

--------------------------------------------------------------------
            reg_migseg.mig_pk := v_ncarga || '/' || x.nlinea;
            reg_migseg.mig_fk := reg_migpersonas.mig_pk;
            reg_migseg.cagente := NVL(x.campo04, '9999');   --reg_migpersonas.cagente;
            reg_migseg.csituac := 0;
            v_ntraza := 1130;
            reg_migseg.fefecto := converteix_charadate(LTRIM(x.campo07), 'yyyymmdd');

            IF reg_migseg.fefecto IS NULL THEN
               v_tdeserror := 'Fecha efecto no es fecha: ' || x.campo07 || ' (aaaammdd)';
               v_tdeserror := v_tdeserror
                              || '. Editar linea, modificar fecha efecto (campo07) y reprocesar';
               v_nnumerr := 1000135;
               RAISE e_errdatos;
            END IF;

            v_ntraza := 1140;
            reg_migseg.sproduc := pac_cargas_cnp.f_buscavalor('CRT_PRODUCTOCNPPLAN', x.campo03);

            SELECT cactivi
              INTO reg_migseg.cactivi
              FROM activiprod a, productos p
             WHERE a.cramo = p.cramo
               AND a.cmodali = p.cmodali
               AND a.ctipseg = p.ctipseg
               AND a.ccolect = p.ccolect
               AND p.sproduc = reg_migseg.sproduc;

            -- reg_migseg.cactivi := 0;
            BEGIN
               v_ntraza := 1150;

               SELECT *
                 INTO reg_productos
                 FROM productos
                WHERE sproduc = reg_migseg.sproduc;

               -- IF reg_productos.cactivo = 0 THEN
               --     v_tdeserror := 'falta producto activo para: ' || x.campo03;
               --     v_nnumerr := 104347;
               --      RAISE e_errdatos;
               --  END IF;
               v_ntraza := 1152;

               SELECT MIN(cramo)
                 INTO reg_productos.cramo
                 FROM codiram
                WHERE cempres = vg_nempresaaxis
                  AND cramo = reg_productos.cramo;

               IF reg_productos.cramo IS NULL THEN
                  v_tdeserror := 'falta producto activo para: ' || x.campo03;
                  v_nnumerr := 104347;
                  RAISE e_errdatos;
               END IF;
            END;

            -- Asigno número póliza del parametro
            v_ntraza := 1155;
            --reg_migseg.npoliza := NVL(f_parproductos_v(reg_migseg.sproduc, 'NPOLIZA_COLECTIVO'),
            --                        0);
            --reg_migseg.ncertif := to_number(x.campo05);
            reg_migseg.npoliza := 0;   -- jlb no son colectivos
            reg_migseg.ncertif := 0;

            IF TRIM(x.campo31) IS NULL THEN
               reg_migseg.cforpag := reg_productos.cpagdef;
            ELSE
               reg_migseg.cforpag := converteix_charanum(x.campo31);
            END IF;

            IF reg_migseg.cforpag IS NULL THEN
               v_tdeserror := 'forma pago no definida: ' || x.campo31;
               v_nnumerr := 140704;
               RAISE e_errdatos;
            END IF;

            v_ntraza := 1160;
            reg_migseg.creafac := 0;   --Revisar
            reg_migseg.ccobban := NULL;
            reg_migseg.ctipcoa := 0;
            reg_migseg.ctiprea := 0;
            reg_migseg.ctipcom := 0;   --Habitual
            v_ntraza := 1170;

            IF TRIM(x.campo09) IS NULL
               OR x.campo09 = '0'
               OR x.campo09 = '00000000' THEN
               reg_migseg.fvencim := NULL;
            ELSE
               reg_migseg.fvencim := converteix_charadate(x.campo09, 'yyyymmdd');

               IF reg_migseg.fvencim IS NULL THEN
                  v_tdeserror := 'Fecha vencimiento no es fecha: ' || x.campo09
                                 || ' (aaaammdd)';
                  v_tdeserror :=
                     v_tdeserror
                     || '. Editar linea, modificar fecha vencimiento (campo09) y reprocesar';
                  v_nnumerr := 1000135;
                  RAISE e_errdatos;
               END IF;
            END IF;

            v_ntraza := 1180;
            reg_migseg.femisio := reg_migseg.fefecto;
            reg_migseg.iprianu := 0;   --JRH IMP
            v_ntraza := 1185;
            reg_migseg.cidioma := vg_nidiomaaxis;
            reg_migseg.creteni := 0;
            reg_migseg.sciacoa := NULL;
            reg_migseg.pparcoa := NULL;
            reg_migseg.npolcoa := NULL;
            reg_migseg.nsupcoa := NULL;
            reg_migseg.pdtocom := NULL;
            reg_migseg.ncuacoa := NULL;
            reg_migseg.cempres := vg_nempresaaxis;

            --reg_migseg.ccompani := NULL;
            SELECT ccompani
              INTO reg_migseg.ccompani
              FROM productos
             WHERE sproduc = reg_migseg.sproduc;

            --reg_migseg.ctipcob := 1;   -- JRH IMP Caja
            v_ntraza := 1190;
            reg_migseg.crevali := 0;
            reg_migseg.prevali := 0;
            reg_migseg.irevali := 0;
            v_ntraza := 1195;
            reg_migseg.ctipban := reg_migpersonas.ctipban;
            reg_migseg.cbancar := reg_migpersonas.cbancar;
            v_ntraza := 1210;

            IF reg_migseg.cbancar IS NULL THEN
               reg_migseg.ctipcob := 1;
            ELSE
               reg_migseg.ctipcob := 2;
            END IF;

            reg_migseg.casegur := 1;
            --Revisar de momento pongo especificar, en caso de ser igual al tomador poner 1
            reg_migseg.nsuplem := 0;
            reg_migseg.sseguro := 0;
            reg_migseg.sperson := 0;
            v_ntraza := 1200;
            reg_migseg.crecfra := 0;
            v_ntraza := 1210;
            reg_migseg.mig_fk := reg_migpersonas.mig_pk;
            v_ntraza := 1220;
            reg_migseg.ccobban := NULL;   --JRH de momento
            reg_migseg.cestmig := 1;
            reg_migseg.ncarga := v_ncarga;
            v_ntraza := 1225;

            -- BUSCO LA POLIZA de NOTA INFORMATIVA
            UPDATE    seguros seg
                  SET csituac = 16
                WHERE sproduc = reg_migseg.sproduc
                  AND csituac = 14
                  AND sseguro IN(SELECT tom.sseguro
                                   FROM tomadores tom, per_personas per
                                  WHERE per.sperson = tom.sperson
                                    AND per.nnumide = reg_migpersonas.nnumide)
                  AND ROWNUM = 1
            RETURNING npoliza, cagente, sseguro
                 INTO reg_migseg.npolini, reg_migseg.cagente, reg_migmovseg.sseguro;   --actualizo la primera nota informativa

            v_ntraza := 1227;

            INSERT INTO mig_seguros
                 VALUES reg_migseg
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 1, reg_migseg.mig_pk);

--------------------------------------------------------------------
            v_ntraza := 1230;

            IF reg_migmovseg.sseguro IS NOT NULL THEN
               BEGIN
                  SELECT cusumov, fmovimi
                    INTO reg_migmovseg.cusumov, reg_migmovseg.fmovimi
                    FROM movseguro
                   WHERE sseguro = reg_migmovseg.sseguro
                     AND nmovimi = 1;
               EXCEPTION
                  WHEN OTHERS THEN
                     reg_migmovseg.cusumov := NULL;
                     reg_migmovseg.fmovimi := NVL(reg_migseg.femisio, reg_migseg.fefecto);
               END;
            ELSE
               reg_migmovseg.cusumov := f_user;
               reg_migmovseg.fmovimi := NVL(reg_migseg.femisio, reg_migseg.fefecto);
            END IF;

            --Movseguro
            reg_migmovseg.sseguro := 0;
            reg_migmovseg.nmovimi := 1;
            reg_migmovseg.cmotmov := 100;
            reg_migmovseg.fefecto := reg_migseg.fefecto;
            -- reg_migmovseg.fmovimi := reg_migseg.femisio;
            reg_migmovseg.mig_pk := reg_migseg.mig_pk || '/' || '1';
            reg_migmovseg.mig_fk := reg_migseg.mig_pk;
            reg_migmovseg.cestmig := 1;
            reg_migmovseg.ncarga := v_ncarga;
            v_ntraza := 1235;

            INSERT INTO mig_movseguro
                 VALUES reg_migmovseg
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 2, reg_migmovseg.mig_pk);

--------------------------------------------------------------------
            reg_migulk := NULL;
            reg_migulk.mig_pk := reg_migseg.mig_pk;
            reg_migulk.ncarga := v_ncarga;
            reg_migulk.cestmig := 1;
            reg_migulk.mig_fk := reg_migseg.mig_pk;
            reg_migulk.sseguro := 0;
            v_ntraza := 25;

            SELECT MAX(cmodinv)
              INTO reg_migulk.cmodinv
              FROM modinvfondo
             WHERE cramo = reg_productos.cramo
               AND cmodali = reg_productos.cmodali
               AND ctipseg = reg_productos.ctipseg
               AND ccolect = reg_productos.ccolect;

            IF reg_migulk.cmodinv IS NULL THEN
               v_tdeserror := 'Modelo inversión no definido para producto: '
                              || reg_productos.cramo || '-' || reg_productos.cmodali || '-'
                              || reg_productos.ctipseg || '-' || reg_productos.ccolect;
               v_nnumerr := 1000291;
               RAISE e_errdatos;
            END IF;

            INSERT INTO mig_seguros_ulk
                 VALUES reg_migulk
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 3, reg_migulk.mig_pk);

--------------------------------------------------------------------
            SELECT NVL(MIN(cdomici), 1)
              INTO v_cdomici
              FROM per_direcciones p, per_personas m
             WHERE m.nnumide = LPAD(LTRIM(TRIM(x.campo23), '0'), 9, '0')
               AND p.sperson = m.sperson;

            v_ntraza := 1245;
            reg_migase.sseguro := 0;
            reg_migase.sperson := 0;
            reg_migase.norden := 1;   --JRH IMP
            v_ntraza := 1250;
            reg_migase.ffecini := reg_migseg.fefecto;
            reg_migase.ffecfin := NULL;
            reg_migase.ffecmue := NULL;   --Revisar
            --reg_migase.mig_fk := x.asnumnif;
            reg_migase.mig_pk := reg_migseg.mig_pk;
            reg_migase.mig_fk := reg_migseg.mig_fk;
            reg_migase.mig_fk2 := reg_migseg.mig_pk;
            reg_migase.cestmig := 1;
            reg_migase.ncarga := v_ncarga;
            reg_migase.cdomici := v_cdomici;
            v_ntraza := 1255;

            INSERT INTO mig_asegurados
                 VALUES reg_migase
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 5, reg_migase.mig_pk);

--------------------------------------------------------------------
            v_ntraza := 1260;
            reg_migrie.nriesgo := 1;
            reg_migrie.sseguro := 0;
            reg_migrie.nmovima := 1;
            reg_migrie.fefecto := reg_migseg.fefecto;
            reg_migrie.sperson := NULL;
            reg_migrie.nmovimb := NULL;
            reg_migrie.fanulac := NULL;
            reg_migrie.tnatrie := NULL;
            v_ntraza := 1265;
            reg_migrie.mig_pk := reg_migseg.mig_pk;
            reg_migrie.mig_fk := reg_migseg.mig_fk;
            reg_migrie.mig_fk2 := reg_migseg.mig_pk;
            reg_migrie.cestmig := 1;
            reg_migrie.ncarga := v_ncarga;
            v_ntraza := 1270;

            INSERT INTO mig_riesgos
                 VALUES reg_migrie
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 6, reg_migrie.mig_pk);

--------------------------------------------------------------------
            FOR reg IN (SELECT *
                          FROM garanpro
                         WHERE sproduc = reg_migseg.sproduc) LOOP
               reg_miggar := NULL;
               reg_miggar.mig_fk := reg_migmovseg.mig_pk;
               reg_miggar.cestmig := 1;
               reg_miggar.cgarant := reg.cgarant;
               reg_miggar.ncarga := v_ncarga;
               reg_miggar.nriesgo := 1;
               reg_miggar.nmovimi := reg_migmovseg.nmovimi;
               reg_miggar.nmovima := 1;
               reg_miggar.sseguro := 0;
               v_ntraza := 35;
               reg_miggar.mig_pk := reg_migmovseg.mig_pk || '/' || reg.cgarant;
               reg_miggar.icapital := 0;
               reg_miggar.precarg := 0;
               reg_miggar.iextrap := 0;
               reg_miggar.iprianu := 0;
               reg_miggar.ipritar := 0;
               reg_miggar.crevali := 0;
               reg_miggar.prevali := 0;
               reg_miggar.irevali := 0;
               reg_miggar.irecarg := 0;
               reg_miggar.pdtocom := 0;
               reg_miggar.idtocom := 0;
               reg_miggar.finiefe := reg_migseg.fefecto;
               reg_miggar.ffinefe := NULL;
               v_ntraza := 36;

               INSERT INTO mig_garanseg
                    VALUES reg_miggar
                 RETURNING ROWID
                      INTO v_rowid;

               INSERT INTO mig_pk_emp_mig
                    VALUES (0, v_ncarga, 8, reg_miggar.mig_pk);
            END LOOP;
------------------------------------------------------------------------------------------------------------------------
         ELSIF x.campo01 = '03' THEN   -- BENEFICIARIO
            -- Bug 0016696. FAL. 18/11/2010. Si + de 1 beneficiario asigna mismo reg_migbenef.mig_pk para todos y da ORA-00001: restricción única (MIG_CLAUSUESP_PK) violada
            IF w_mig_pk_ant = reg_migmovseg.mig_pk THEN
               w_cont_clausuben := w_cont_clausuben + 1;
            ELSE
               w_cont_clausuben := 1;
            END IF;

            -- Fi Bug 0016696
            reg_migbenef := NULL;
            pac_cargas_cnp.p_textoclausula('Benef:' || x.campo09, TRIM(x.campo07),
                                           (x.campo12 / 10000) || '%', reg_migbenef.tclaesp);
            reg_migbenef.mig_pk := reg_migmovseg.mig_pk;   --|| '/'

            --|| LPAD(w_cont_clausuben, 2, '0');
            IF w_cont_clausuben = 1 THEN
               -- Inicio Crear clausulas --
               reg_migbenef.ncarga := v_ncarga;
               reg_migbenef.cestmig := 1;
               -- Bug 0016696. FAL. 18/11/2010. Si + de 1 beneficiario asigna mismo reg_migbenef.mig_pk para todos y da ORA-00001: restricción única (MIG_CLAUSUESP_PK) violada
               -- reg_migbenef.mig_pk := reg_migmovseg.mig_pk || '/' || LPAD(1, 2, '0');
               w_mig_pk_ant := reg_migmovseg.mig_pk;
               -- Fi Bug 0016696
               reg_migbenef.mig_fk := reg_migmovseg.mig_pk;   -- MIG_MOVSEGURO
               reg_migbenef.sseguro := 0;
               reg_migbenef.cclaesp := 1;
               --reg_migbenef.nordcla := 1; ---si bien varios

               -- Bug 0016696. FAL. 18/11/2010. Si + de 1 beneficiario asigna mismo reg_migbenef.mig_pk para todos y da ORA-00001: restricción única (MIG_CLAUSUESP_PK) violada
               --SELECT (COUNT('1') + 1)
               --  INTO reg_migbenef.nordcla
               --  FROM mig_clausuesp
               -- WHERE mig_pk = reg_migbenef.mig_pk;
               reg_migbenef.nordcla := w_cont_clausuben;
               -- Fi Bug 0016696
               reg_migbenef.nriesgo := 1;
               reg_migbenef.nmovimi := reg_migmovseg.nmovimi;
               reg_migbenef.finiclau := reg_migseg.fefecto;

               -- IF TRIM(REPLACE(reg_migbenef.tclaesp, CHR(10), '')) IS NOT NULL THEN
                --   NULL;
                --ELSE
                --   reg_migbenef.sclagen := reg_productos.sclaben;
                --END IF;
               INSERT INTO mig_clausuesp
                    VALUES reg_migbenef
                 RETURNING ROWID
                      INTO v_rowid;

               INSERT INTO mig_pk_emp_mig
                    VALUES (0, v_ncarga, 7, reg_migbenef.mig_pk);
            ELSE
               UPDATE mig_clausuesp
                  SET tclaesp = tclaesp || CHR(10) || reg_migbenef.tclaesp
                WHERE mig_pk = reg_migbenef.mig_pk;
            END IF;
-- Final Crear clausulas --
------------------------------------------------------------------------------------------------------------------------
         ELSIF x.campo01 = '04' THEN   -- FAMILIARES
            v_bwarning := TRUE;
            p_genera_logs(v_tobjeto, v_ntraza, 'Registro Familiares participe minusválido',
                          'no tratado ' || ' (' || x.campo02 || ')', x.proceso,
                          'Registro Familiares participe minusválido no tratado ' || ' ('
                          || x.campo02 || ')');
            v_nnumerr :=
               p_marcalinea
                  (x.proceso, x.nlinea, p_toperacion, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   TO_NUMBER(x.campo05),   -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga   -- Fi Bug 16324
                           );
            v_nnumerr := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 102903,
                                           'registro tipo 04-FAMILIARES no definido.');
            v_nnumerr := 0;
            v_bwarning := FALSE;
------------------------------------------------------------------------------------------------------------------------
-- Bug 0016696. FAL. 18/11/2010. implementacion registros tipo 05 . movimientos economicos
         ELSIF x.campo01 = '05' THEN   -- MOVIMIENTOS
            -- FAL. Inicio alta registro tipo 05
            -- FAL. El campo08(Código tipo movimiento) ,para el registro tipo 05, es lo que informaria ctaseguro.CMOVIMI
            -- FAL. Fin alta registro tipo 05

            --buscar cesta asignada al producto.
            SELECT MAX(c.ccodfon)
              INTO v_ncesta
              FROM proplapen b, planpensiones c
             WHERE b.sproduc = reg_productos.sproduc
               AND c.ccodpla = b.ccodpla;

            -- comprobar si existe valor para la fecha.
            SELECT COUNT(1)
              INTO v_naux
              FROM tabvalces d
             WHERE d.ccesta = v_ncesta
               AND d.fvalor = v_ffecvalces;

            IF v_naux = 0 THEN
               v_naux := converteix_charanum(x.campo15);

               IF v_naux IS NOT NULL THEN
                  v_naux := v_naux / 10000000;

                  -- Si no existe, creamos valor a partir datos fichero.
                  INSERT INTO tabvalces
                              (ccesta, fvalor, nparact, iuniact, ivalact, nparasi, igastos)
                       VALUES (v_ncesta, v_ffecvalces, 0, v_naux, 0, NULL, NULL);
               END IF;
            END IF;

            reg_migctaseguro.mig_pk := reg_migseg.mig_pk || '/' || x.campo02 || '/1';
            reg_migctaseguro.mig_fk := reg_migseg.mig_pk;
            reg_migctaseguro.ncarga := v_ncarga;
            reg_migctaseguro.cestmig := 1;
            --
            reg_migctaseguro.sseguro := 0;
            -- v_ffecvalces := converteix_charadate(x.campo07, 'yyyymmdd'); --Fecha valor movimiento. registro tipo 5 (mov.economicos)
            wfechmov := converteix_charadate(x.campo07, 'yyyymmdd');   --Fecha valor movimiento. registro tipo 5 (mov.economicos)
            reg_migctaseguro.fcontab := wfechmov;

            -- Bug 0015490. FAL. 15/02/2011
            SELECT NVL(MAX(nnumlin), 0) + 1
              INTO wlinea
              FROM mig_ctaseguro
             WHERE mig_pk LIKE reg_migseg.mig_pk || '%';

            reg_migctaseguro.nnumlin := wlinea;
            -- Fi Bug 0015490
            reg_migctaseguro.ffecmov := wfechmov;
            reg_migctaseguro.fvalmov := wfechmov;
            wcmovimi_orig := pac_cargas_cnp.f_buscavalor('CRT_TIPOMOVCNPPLAN', x.campo08);   -- Código tipo movimiento
            wcmovimi := SUBSTR(wcmovimi_orig, 1, INSTR(wcmovimi_orig, '-') - 1);
            wcmovimi_det := SUBSTR(wcmovimi_orig, INSTR(wcmovimi_orig, '-') + 1,
                                   LENGTH(wcmovimi_orig));
            reg_migctaseguro.cmovimi := TO_NUMBER(wcmovimi);
            reg_migctaseguro.imovim2 := NULL;
            reg_migctaseguro.ccalint := 0;
            reg_migctaseguro.nrecibo := NULL;
            reg_migctaseguro.nsinies := NULL;
            reg_migctaseguro.cmovanu := 0;
            reg_migctaseguro.smovrec := NULL;
            reg_migctaseguro.cesta := NULL;   -- v_ncesta;
            reg_migctaseguro.cestado := 1;
            reg_migctaseguro.fasign := NULL;
            reg_migctaseguro.nparpla := NULL;
            reg_migctaseguro.cestpar := NULL;
            reg_migctaseguro.iexceso := NULL;
            reg_migctaseguro.spermin := NULL;
            reg_migctaseguro.sidepag := NULL;
            reg_migctaseguro.ctipapor := NULL;
            reg_migctaseguro.srecren := NULL;
            reg_migctaseguro.imovimi := 0;
            reg_migctaseguro.nunidad := NULL;

            -- Bug 0015490. FAL. 15/02/2011
            SELECT SUBSTR(x.campo14, 1, 1)
              INTO wcharaux
              FROM DUAL;

            IF wcharaux = '-' THEN
               v_naux := converteix_charanum(SUBSTR(x.campo14, 2, LENGTH(x.campo14)));
            ELSE
               -- Numero unidades
               v_naux := converteix_charanum(x.campo14);
            END IF;

            IF v_naux IS NULL THEN
               v_tdeserror := 'Unidades con formato erroneo: ' || x.campo14 || ' (10,7)';
               v_nnumerr := 1000135;
               RAISE e_errdatos;
            ELSE
               v_naux := v_naux / 10000000;
               reg_migctaseguro.nunidad := v_naux;

               IF wcharaux = '-' THEN
                  reg_migctaseguro.nunidad := reg_migctaseguro.nunidad *(-1);
               END IF;
            END IF;

            reg_migctaseguro.nunidad := NULL;   -- para el mov. del concepto origen, cesta y unidades debe ser nulo
            -- Fi Bug 0015490

            -- Importe
            v_naux := converteix_charanum(x.campo09);

            IF v_naux IS NULL THEN
               v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
               v_nnumerr := 1000135;
               RAISE e_errdatos;
            ELSE
               v_naux := v_naux / 100;
               reg_migctaseguro.imovimi := v_naux;
            END IF;

            -- 15490/88884 - FAL. 04/07/2011. Generar recibo para traspasos de entrada y generar siniestro para traspasos de salida.
            IF TRIM(x.campo08) IN('L', 'SB', 'SO', 'ST', 'SF') THEN   -- TRASPASO SALIDA
               BEGIN
                  SELECT sseguro, cforpag
                    INTO n_seg, v_cforpag
                    FROM seguros
                   WHERE cpolcia = LTRIM(x.campo05, '0')
                     AND sproduc = reg_productos.sproduc;
               EXCEPTION
                  WHEN OTHERS THEN
                     n_seg := NULL;
               END;

               --vtraza := 1018;
               IF n_seg IS NULL THEN
                  v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
                  v_nnumerr := 100500;
                  RAISE e_errdatos;
               END IF;

               v_naux := converteix_charanum(x.campo09);

               IF v_naux IS NULL THEN
                  v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                  v_nnumerr := 1000135;
                  RAISE e_errdatos;
               ELSE
                  v_naux := v_naux / 100;
               END IF;

               IF x.campo08 IN('SF') THEN
                  wccausin := 7009;
                  wcmotsin := 0;
               ELSE
                  wccausin := 8;

                  IF x.campo08 IN('SB') THEN
                     wcmotsin := 2;
                  ELSE
                     wcmotsin := 1;
                  END IF;
               END IF;

               v_nnumerr := f_crea_siniestro(x, n_seg, wccausin, NVL(wcmotsin, 1),
                                             NVL(v_naux, 0), v_ncarga, p_toperacion, vsidepag);

               UPDATE int_polizas_cnp
                  SET ncarga = v_ncarga
                WHERE proceso = p_ssproces
                  AND campo01 NOT IN('01', '07')
                  AND campo05 = LTRIM(x.campo05, '0');

                  --v_ntraza := 1355;
               --   COMMIT;
               pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
               vnsinies := NULL;

               BEGIN
                  SELECT DISTINCT s.nsinies, s.ccausin, s.cmotsin, p.isinret
                             INTO vnsinies, vccausin, vcmotsin, visinret
                             FROM sin_tramita_pago p, sin_siniestro s
                            WHERE p.sidepag = vsidepag
                              AND s.nsinies = p.nsinies;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_tdeserror := 'Error en pago:' || vsidepag;
                     RAISE e_errdatos;
               END;

               --reg_migctaseguro.sidepag := vsidepag;  -- FAL - se comenta... error por constraint ctaseguro_pagosini_FK. En ningun lado se relacionan pagosini-ctaseguro por sidepag
               reg_migctaseguro.nsinies := vnsinies;
            ELSIF x.campo08 IN('AT', 'AO') THEN   -- TRASPASO ENTRADA
               v_naux := converteix_charanum(x.campo09);

               IF v_naux IS NULL THEN
                  v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                  v_nnumerr := 1000135;
                  RAISE e_errdatos;
               ELSE
                  v_naux := v_naux / 100;
               END IF;

               BEGIN
                  SELECT sseguro, cforpag
                    INTO n_seg, v_cforpag
                    FROM seguros
                   WHERE cpolcia = LTRIM(x.campo05, '0')
                     AND sproduc = reg_productos.sproduc;
               EXCEPTION
                  WHEN OTHERS THEN
                     n_seg := NULL;
               END;

               --vtraza := 1018;
               IF n_seg IS NULL THEN
                  v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
                  v_nnumerr := 100500;
                  RAISE e_errdatos;
               END IF;

               v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 10, v_ncarga, p_toperacion,
                                          v_nrecibo);   -- emito f_recibo

               IF v_nnumerr <> 0 THEN
                  RAISE e_errdatos;
               END IF;

               UPDATE int_polizas_cnp
                  SET ncarga = v_ncarga
                WHERE proceso = p_ssproces
                  AND campo01 NOT IN('01', '07')
                  AND campo05 = LTRIM(x.campo05, '0');

               --v_ntraza := 1355;
               --COMMIT;
               pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
               reg_migctaseguro.nrecibo := v_nrecibo;
            ELSIF x.campo08 IN('AP') THEN
               v_naux := converteix_charanum(x.campo09);

               IF v_naux IS NULL THEN
                  v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                  v_nnumerr := 1000135;
                  RAISE e_errdatos;
               ELSE
                  v_naux := v_naux / 100;
               END IF;

               BEGIN
                  SELECT sseguro, cforpag
                    INTO n_seg, v_cforpag
                    FROM seguros
                   WHERE cpolcia = LTRIM(x.campo05, '0')
                     AND sproduc = reg_productos.sproduc;
               EXCEPTION
                  WHEN OTHERS THEN
                     n_seg := NULL;
               END;

               --vtraza := 1018;
               IF n_seg IS NULL THEN
                  v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
                  v_nnumerr := 100500;
                  RAISE e_errdatos;
               END IF;

               v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 3, v_ncarga, p_toperacion,
                                          v_nrecibo);   -- emito f_recibo

               IF v_nnumerr <> 0 THEN
                  RAISE e_errdatos;
               END IF;

               UPDATE int_polizas_cnp
                  SET ncarga = v_ncarga
                WHERE proceso = p_ssproces
                  AND campo01 NOT IN('01', '07')
                  AND campo05 = LTRIM(x.campo05, '0');

               --v_ntraza := 1355;
               --COMMIT;
               pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
               reg_migctaseguro.nrecibo := v_nrecibo;
            ELSIF x.campo08 IN('AR') THEN   -- regulariacion aportacion. en funcion del signo extorno: 9 ó Aportació extraordinària: 4
               IF x.campo12 = '+' THEN
                  v_naux := converteix_charanum(x.campo09);

                  IF v_naux IS NULL THEN
                     v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                     v_nnumerr := 1000135;
                     RAISE e_errdatos;
                  ELSE
                     v_naux := v_naux / 100;
                  END IF;

                  BEGIN
                     SELECT sseguro, cforpag
                       INTO n_seg, v_cforpag
                       FROM seguros
                      WHERE cpolcia = LTRIM(x.campo05, '0')
                        AND sproduc = reg_productos.sproduc;
                  EXCEPTION
                     WHEN OTHERS THEN
                        n_seg := NULL;
                  END;

                  --vtraza := 1018;
                  IF n_seg IS NULL THEN
                     v_tdeserror := 'Número póliza(recibo) no existe4: '
                                    || LTRIM(x.campo05, '0');
                     v_nnumerr := 100500;
                     RAISE e_errdatos;
                  END IF;

                  v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 4, v_ncarga, p_toperacion,
                                             v_nrecibo);   -- emito f_recibo

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  UPDATE int_polizas_cnp
                     SET ncarga = v_ncarga
                   WHERE proceso = p_ssproces
                     AND campo01 NOT IN('01', '07')
                     AND campo05 = LTRIM(x.campo05, '0');

                  --v_ntraza := 1355;
                  --COMMIT;
                  pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
                  reg_migctaseguro.nrecibo := v_nrecibo;
               ELSE   -- extorno
                  v_naux := converteix_charanum(x.campo09);

                  IF v_naux IS NULL THEN
                     v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                     v_nnumerr := 1000135;
                     RAISE e_errdatos;
                  ELSE
                     v_naux := v_naux / 100;
                  END IF;

                  BEGIN
                     SELECT sseguro, cforpag
                       INTO n_seg, v_cforpag
                       FROM seguros
                      WHERE cpolcia = LTRIM(x.campo05, '0')
                        AND sproduc = reg_productos.sproduc;
                  EXCEPTION
                     WHEN OTHERS THEN
                        n_seg := NULL;
                  END;

                  --vtraza := 1018;
                  IF n_seg IS NULL THEN
                     v_tdeserror := 'Número póliza(recibo) no existe4: '
                                    || LTRIM(x.campo05, '0');
                     v_nnumerr := 100500;
                     RAISE e_errdatos;
                  END IF;

                  v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 9, v_ncarga, p_toperacion,
                                             v_nrecibo);   -- emito f_recibo

                  IF v_nnumerr <> 0 THEN
                     RAISE e_errdatos;
                  END IF;

                  UPDATE int_polizas_cnp
                     SET ncarga = v_ncarga
                   WHERE proceso = p_ssproces
                     AND campo01 NOT IN('01', '07')
                     AND campo05 = LTRIM(x.campo05, '0');

                  --v_ntraza := 1355;
                  --COMMIT;
                  pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
                  reg_migctaseguro.nrecibo := v_nrecibo;
               END IF;
            ELSIF x.campo08 IN('AA', 'AE') THEN
               v_naux := converteix_charanum(x.campo09);

               IF v_naux IS NULL THEN
                  v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                  v_nnumerr := 1000135;
                  RAISE e_errdatos;
               ELSE
                  v_naux := v_naux / 100;
               END IF;

               BEGIN
                  SELECT sseguro, cforpag
                    INTO n_seg, v_cforpag
                    FROM seguros
                   WHERE cpolcia = LTRIM(x.campo05, '0')
                     AND sproduc = reg_productos.sproduc;
               EXCEPTION
                  WHEN OTHERS THEN
                     n_seg := NULL;
               END;

               --vtraza := 1018;
               IF n_seg IS NULL THEN
                  v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
                  v_nnumerr := 100500;
                  RAISE e_errdatos;
               END IF;

               v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 4, v_ncarga, p_toperacion,
                                          v_nrecibo);   -- emito f_recibo

               IF v_nnumerr <> 0 THEN
                  RAISE e_errdatos;
               END IF;

               UPDATE int_polizas_cnp
                  SET ncarga = v_ncarga
                WHERE proceso = p_ssproces
                  AND campo01 NOT IN('01', '07')
                  AND campo05 = LTRIM(x.campo05, '0');

               --v_ntraza := 1355;
               --COMMIT;
               pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
               reg_migctaseguro.nrecibo := v_nrecibo;
            ELSIF x.campo08 IN('SN', 'SD', 'SG', 'SI', 'SJ', 'SS') THEN
               v_naux := converteix_charanum(x.campo09);
               wfechmov := converteix_charadate(x.campo07, 'yyyymmdd');

               IF v_naux IS NULL THEN
                  v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                  v_nnumerr := 1000135;
                  RAISE e_errdatos;
               ELSE
                  v_naux := v_naux / 100;
               END IF;

               BEGIN
                  SELECT sseguro, cforpag, cagente, sproduc
                    INTO n_seg, v_cforpag, wcagente, wsproduc
                    FROM seguros
                   WHERE cpolcia = LTRIM(x.campo05, '0')
                     AND sproduc = reg_productos.sproduc;
               EXCEPTION
                  WHEN OTHERS THEN
                     n_seg := NULL;
               END;

               --vtraza := 1018;
               IF n_seg IS NULL THEN
                  v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
                  v_nnumerr := 100500;
                  RAISE e_errdatos;
               END IF;

               v_nnumerr := f_crea_renta(x, n_seg, v_naux, v_ncarga, p_toperacion, psrecren);

               IF v_nnumerr <> 0 THEN
                  RAISE e_errdatos;
               END IF;

               IF x.campo08 IN('SN') THEN
                  wccausin := 13;
                  wcmotsin := 0;
               ELSIF x.campo08 IN('SG') THEN
                  wccausin := 7014;
                  wcmotsin := 0;
               ELSIF x.campo08 IN('SI') THEN
                  wccausin := 7010;
                  wcmotsin := 0;
               ELSIF x.campo08 IN('SJ') THEN
                  wccausin := 7008;
                  wcmotsin := 0;
               ELSIF x.campo08 IN('SD') THEN
                  wccausin := 7013;
                  wcmotsin := 0;
               ELSIF x.campo08 IN('SS') THEN
                  wccausin := 7008;
                  wcmotsin := 0;
               END IF;

               w_numsinis := 0;

               SELECT COUNT('*')
                 INTO w_numsinis
                 FROM sin_siniestro
                WHERE sseguro = n_seg
                  AND ccausin = wccausin;   --pago de renta

               IF w_numsinis = 0 THEN
                  v_ncarga := f_next_carga;
                  v_nnumerr := f_crea_siniestro(x, n_seg, wccausin, wcmotsin, NVL(v_naux, 0),
                                                v_ncarga, p_toperacion, vsidepag);
                  pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
               ELSE
                  SELECT MAX(nsinies)
                    INTO wnsinies
                    FROM sin_siniestro
                   WHERE sseguro = n_seg
                     AND ccausin = wccausin;   --pago de renta ;

                  SELECT fsinies, falta
                    INTO wfsinies, wfalta
                    FROM sin_siniestro
                   WHERE nsinies = wnsinies;

                  SELECT MAX(ntramit)
                    INTO wntramit
                    FROM sin_tramitacion
                   WHERE nsinies = wnsinies;

                  SELECT MAX(nmovres)
                    INTO wnmovres
                    FROM sin_tramita_reserva
                   WHERE nsinies = wnsinies
                     AND ntramit = wntramit;

                  -- jlb - 21452 -- si el siniestro se ha creado manualemente no ha insrtado reserva
                  SELECT cgarant
                    INTO v_cgarant
                    FROM garanpro
                   WHERE sproduc = wsproduc
                     AND ROWNUM = 1;

                  IF wnmovres IS NULL THEN
                     wnmovres := 1;

                     INSERT INTO sin_tramita_reserva
                                 (nsinies, ntramit, ctipres, nmovres, cgarant, ccalres,
                                  fmovres, cmonres, ireserva, ipago,
                                  icaprie, ipenali)
                          VALUES (wnsinies, wntramit, 1, wnmovres, v_cgarant, 0,
                                  wfechmov, 'EUR', 0, v_naux + NVL(v_importeretencion, 0),
                                  v_naux + NVL(v_importeretencion, 0), 0);
                  END IF;

                  SELECT p.sperson   --, p.ctipide, p.cestper, 1, p.swpubli, d.tapelli1
                    INTO wsperson
                    --v_mig_personas.idperson, v_mig_personas.ctipide,
                    --v_mig_personas.cestper, v_mig_personas.cpertip, v_mig_personas.swpubli, v_mig_personas.tapelli1
                  FROM   asegurados a, per_personas p, per_detper d
                   WHERE a.sseguro = n_seg
                     AND a.norden = 1
                     AND p.sperson = a.sperson
                     AND d.cagente = ff_agente_cpervisio(wcagente)
                     AND d.sperson = p.sperson;   --En caso de que no sea el asegurado tendríamos que ver si nos lo envían

                  SELECT sidepag.NEXTVAL
                    INTO vsidepag
                    FROM DUAL;

                  v_importeretencion := converteix_charanum(x.campo11) / 100;

                  INSERT INTO sin_tramita_pago
                              (sidepag, nsinies, ntramit, sperson, ctipdes, ctippag, cconpag,
                               ccauind, cforpag, fordpag, ctipban, cbancar, cmonres,
                               isinret,
                               iretenc, iiva, isuplid, ifranq, iresrcm, iresred, cmonpag,
                               isinretpag, iretencpag, iivapag, isuplidpag, ifranqpag,
                               iresrcmpag, iresredpag, fcambio, nfacref, ffacref, cusualt,
                               falta, cusumod, fmodifi, ctransfer, sproces)
                       VALUES (vsidepag, wnsinies, wntramit, wsperson, 1, 2, 1,
                               0, 1, wfechmov, NULL, NULL, NULL,
                               v_naux + NVL(v_importeretencion, 0),
                               NVL(v_importeretencion, 0), NULL, NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL, f_user,
                               wfalta, NULL, NULL, NULL, NULL);

                  INSERT INTO sin_tramita_movpago
                              (sidepag, nmovpag, cestpag, fefepag, cestval, fcontab, sproces,
                               cusualt, falta, cestpagant)
                       VALUES (vsidepag, 1, 0, wfechmov, 0, NULL, NULL,
                               f_user, wfalta, NULL);

                  INSERT INTO sin_tramita_movpago
                              (sidepag, nmovpag, cestpag, fefepag, cestval, fcontab, sproces,
                               cusualt, falta, cestpagant)
                       VALUES (vsidepag, 2, 1, wfechmov, 1, NULL, NULL,
                               f_user, wfalta, NULL);

                  INSERT INTO sin_tramita_pago_gar
                              (sidepag, ctipres, nmovres, cgarant, fperini, fperfin, cmonres,
                               isinret,
                               iretenc, iiva, isuplid, ifranq, iresrcm, iresred, cmonpag,
                               isinretpag, iivapag, isuplidpag, iretencpag, ifranqpag,
                               iresrcmpag, iresredpag, fcambio, pretenc, piva, cusualt, falta,
                               cusumod, fmodifi, cconpag, norden)
                       VALUES (vsidepag, 1, wnmovres, v_cgarant, NULL, NULL, NULL,
                               v_naux + NVL(v_importeretencion, 0),
                               NVL(v_importeretencion, 0), 0, NULL, 0, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, 0, NULL, f_user, wfsinies,
                               NULL, NULL, NULL, 1);
               END IF;

               UPDATE int_polizas_cnp
                  SET ncarga = v_ncarga
                WHERE proceso = p_ssproces
                  AND campo01 NOT IN('01', '07')
                  AND campo05 = LTRIM(x.campo05, '0');

               --v_ntraza := 1355;
               --COMMIT;
               pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

               BEGIN
                  SELECT DISTINCT s.nsinies, s.ccausin, s.cmotsin, p.isinret
                             INTO vnsinies, vccausin, vcmotsin, visinret
                             FROM sin_tramita_pago p, sin_siniestro s
                            WHERE p.sidepag = vsidepag
                              AND s.nsinies = p.nsinies;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_tdeserror := 'Error en pago:' || vsidepag;
                     RAISE e_errdatos;
               END;

               reg_migctaseguro.nsinies := vnsinies;
               reg_migctaseguro.srecren := psrecren;
            END IF;

-- JLB - 22/02/2012 - Creo entradas en trasplaninout
            DECLARE
               --
               vcinout        trasplainout.cinout%TYPE;
               vctiptras      trasplainout.ctiptras%TYPE;
               viimporte      trasplainout.iimporte%TYPE;
               vcexterno      trasplainout.cexterno%TYPE;
               vccodpla       trasplainout.ccodpla%TYPE;
               vtnompla       planpensiones.tnompla%TYPE;
            BEGIN
               IF TRIM(x.campo08) IN('L', 'AO', 'AT', 'SO', 'SB', 'ST') THEN
                  BEGIN
                     SELECT ccodpla, tnompla
                       INTO vccodpla, vtnompla
                       FROM planpensiones
                      WHERE ((TRIM(x.campo22) IS NULL
                              AND coddgs IS NULL)
                             OR(TRIM(x.campo22) IS NOT NULL
                                AND coddgs = TRIM(x.campo22)));
                  EXCEPTION
                     WHEN OTHERS THEN
                        v_tdeserror :=
                           'No se encuentra el plan de traspaso en PLANPENSIONES: '
                           || TRIM(x.campo22);
                        v_nnumerr := 9902327;
                        RAISE e_errdatos;
                  END;

                  IF TRIM(x.campo08) IN('L', 'SB', 'SO', 'ST') THEN
                     -- salida
                     vcinout := 2;
                  ELSE
                     -- entrada
                     vcinout := 1;
                  END IF;

                  IF TRIM(x.campo08) IN('L', 'SB') THEN
                     -- PARCIAL
                     vctiptras := 1;
                  ELSE
                     -- TOTAL
                     vctiptras := 2;
                  END IF;

                  IF TRIM(x.campo08) IN('L', 'AO', 'SO') THEN
                     -- interno
                     vcexterno := 0;
                  ELSE
                     --externo
                     vcexterno := 1;
                  END IF;

                  viimporte := converteix_charanum(x.campo09) / 100;

                  INSERT INTO trasplainout
                              (stras, cinout, sseguro, fsolici, ccodpla, cestado,
                               ctiptras, iimporte, iimptemp, nnumlin,
                               cexterno, fvalor, cusualta, festado, nsinies, fefecto, ctipder,
                               tmemo, ctiptrassol)
                       VALUES (stras.NEXTVAL, vcinout, n_seg, wfechmov, vccodpla, 4,
                               vctiptras, viimporte, viimporte, reg_migctaseguro.nnumlin,
                               vcexterno, wfechmov, f_user, wfechmov, vnsinies, wfechmov, 3,
                               vtnompla, 1);
               END IF;
            EXCEPTION
               WHEN e_errdatos THEN
                  RAISE e_errdatos;
               WHEN OTHERS THEN
                  v_tdeserror := 'Insertando en TRASPLAINOUT: ' || TRIM(x.campo22) || '-'
                                 || SQLERRM;
                  v_nnumerr := 108468;
                  RAISE e_errdatos;
            END;

-- FIN JLB  traspasos 22/02/2012

            -- Fi Bug 15490/88884
            IF reg_migctaseguro.nunidad <> 0
               OR reg_migctaseguro.imovimi <> 0 THEN
               INSERT INTO mig_ctaseguro
                    VALUES reg_migctaseguro
                 RETURNING ROWID
                      INTO v_rowid;

               INSERT INTO mig_pk_emp_mig
                    VALUES (0, v_ncarga, 8, reg_migctaseguro.mig_pk);
            END IF;

            -- ctaseguro_libreta
            reg_mig_ctaseguro_libreta.mig_pk := reg_migctaseguro.mig_pk;
            reg_mig_ctaseguro_libreta.mig_fk := reg_migseg.mig_pk;
            reg_mig_ctaseguro_libreta.ncarga := v_ncarga;
            reg_mig_ctaseguro_libreta.sseguro := 0;
            -- Bug 0015490. FAL. 15/02/2011
            reg_mig_ctaseguro_libreta.nnumlin := reg_migctaseguro.nnumlin;
            -- Fi Bug 0015490

            --reg_mig_ctaseguro_libreta.nnumlin := 1;
            reg_mig_ctaseguro_libreta.fcontab := wfechmov;
            reg_mig_ctaseguro_libreta.ccapgar := 0;
            reg_mig_ctaseguro_libreta.ccapfal := 0;
            reg_mig_ctaseguro_libreta.nmovimi := NULL;
            reg_mig_ctaseguro_libreta.sintbatch := NULL;
            reg_mig_ctaseguro_libreta.nnumlib := NULL;
            reg_mig_ctaseguro_libreta.npagina := NULL;
            reg_mig_ctaseguro_libreta.nlinea := NULL;
            reg_mig_ctaseguro_libreta.fimpres := NULL;
            reg_mig_ctaseguro_libreta.sreimpre := NULL;
            reg_mig_ctaseguro_libreta.igasext := NULL;
            reg_mig_ctaseguro_libreta.igasint := NULL;
            reg_mig_ctaseguro_libreta.cestmig := 1;

            INSERT INTO mig_ctaseguro_libreta
                 VALUES reg_mig_ctaseguro_libreta
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 8, reg_mig_ctaseguro_libreta.mig_pk);
/*  -- FAL. 01/07/2011. Se descarta insertar concepto detalle ctaseguro

            -- DETALLE ctaseguro
            reg_migctaseguro.mig_pk := reg_migseg.mig_pk || '/' || x.campo02 || '/2';
            reg_migctaseguro.mig_fk := reg_migseg.mig_pk;
            reg_migctaseguro.ncarga := v_ncarga;
            reg_migctaseguro.cestmig := 1;
            --
            reg_migctaseguro.sseguro := 0;
            reg_migctaseguro.fcontab := wfechmov;

            -- Bug 0015490. FAL. 15/02/2011
            SELECT NVL(MAX(nnumlin), 0) + 1
              INTO wlinea
              FROM mig_ctaseguro
             WHERE mig_pk LIKE reg_migseg.mig_pk || '%';

            reg_migctaseguro.nnumlin := wlinea;
            -- Fi Bug 0015490
            reg_migctaseguro.ffecmov := wfechmov;
            reg_migctaseguro.fvalmov := wfechmov;
            --reg_migctaseguro.cmovimi := TO_NUMBER(wcmovimi_det);
            reg_migctaseguro.cmovimi := TO_NUMBER(wcmovimi);
            reg_migctaseguro.imovim2 := NULL;
            reg_migctaseguro.ccalint := 0;
            reg_migctaseguro.nrecibo := NULL;
            reg_migctaseguro.nsinies := NULL;
            reg_migctaseguro.cmovanu := 0;
            reg_migctaseguro.smovrec := NULL;
            reg_migctaseguro.cesta := v_ncesta;
            reg_migctaseguro.cestado := 1;
            reg_migctaseguro.fasign := NULL;
            reg_migctaseguro.nparpla := NULL;
            reg_migctaseguro.cestpar := NULL;
            reg_migctaseguro.iexceso := NULL;
            reg_migctaseguro.spermin := NULL;
            reg_migctaseguro.sidepag := NULL;
            reg_migctaseguro.ctipapor := NULL;
            reg_migctaseguro.srecren := NULL;
            reg_migctaseguro.imovimi := 0;
            reg_migctaseguro.nunidad := 0;

            -- Bug 0015490. FAL. 15/02/2011
            SELECT SUBSTR(x.campo14, 1, 1)
              INTO wcharaux
              FROM DUAL;

            IF wcharaux = '-' THEN
               v_naux := converteix_charanum(SUBSTR(x.campo14, 2, LENGTH(x.campo14)));
            ELSE
               -- Numero unidades
               v_naux := converteix_charanum(x.campo14);
            END IF;

            IF v_naux IS NULL THEN
               v_tdeserror := 'Unidades con formato erroneo: ' || x.campo14 || ' (10,7)';
               v_nnumerr := 1000135;
               RAISE e_errdatos;
            ELSE
               v_naux := v_naux / 10000000;
               reg_migctaseguro.nunidad := v_naux;

               IF wcharaux = '-' THEN
                  reg_migctaseguro.nunidad := reg_migctaseguro.nunidad *(-1);
               END IF;
            END IF;

            -- Fi Bug 0015490

            -- Importe
            v_naux := converteix_charanum(x.campo09);

            IF v_naux IS NULL THEN
               v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
               v_nnumerr := 1000135;
               RAISE e_errdatos;
            ELSE
               v_naux := v_naux / 100;
               reg_migctaseguro.imovimi := v_naux;
            END IF;

            IF reg_migctaseguro.nunidad <> 0
               OR reg_migctaseguro.imovimi <> 0 THEN
               INSERT INTO mig_ctaseguro
                    VALUES reg_migctaseguro
                 RETURNING ROWID
                      INTO v_rowid;

               INSERT INTO mig_pk_emp_mig
                    VALUES (0, v_ncarga, 8, reg_migctaseguro.mig_pk);
            END IF;
       */
-- Fi Bug 0016696
------------------------------------------------------------------------------------------------------------------------
         ELSIF x.campo01 = '06' THEN   -- DERECHOS
            --buscar cesta asignada al producto.
            SELECT MAX(c.ccodfon)
              INTO v_ncesta
              FROM proplapen b, planpensiones c
             WHERE b.sproduc = reg_productos.sproduc
               AND c.ccodpla = b.ccodpla;

            -- comprobar si existe valor para la fecha.
            SELECT COUNT(1)
              INTO v_naux
              FROM tabvalces d
             WHERE d.ccesta = v_ncesta
               AND d.fvalor = v_ffecvalces;

            IF v_naux = 0 THEN
               v_naux := converteix_charanum(x.campo11);

               IF v_naux IS NOT NULL THEN
                  v_naux := v_naux / 10000000;

                  -- Si no existe, creamos valor a partir datos fichero.
                  INSERT INTO tabvalces
                              (ccesta, fvalor, nparact, iuniact, ivalact, nparasi, igastos)
                       VALUES (v_ncesta, v_ffecvalces, 0, v_naux, 0, NULL, NULL);
               END IF;
            END IF;

            reg_migctaseguro.mig_pk := reg_migseg.mig_pk || '/' || x.campo02;
            reg_migctaseguro.mig_fk := reg_migseg.mig_pk;
            reg_migctaseguro.ncarga := v_ncarga;
            reg_migctaseguro.cestmig := 1;
            --
            reg_migctaseguro.sseguro := 0;
            reg_migctaseguro.fcontab := v_ffecvalces;

            -- Bug 0015490. FAL. 15/02/2011
            SELECT NVL(MAX(nnumlin), 0) + 1
              INTO wlinea
              FROM mig_ctaseguro
             WHERE mig_pk LIKE reg_migseg.mig_pk || '%';

            reg_migctaseguro.nnumlin := wlinea;
            -- Fi Bug 0015490

            -- reg_migctaseguro.nnumlin := 0;   --1; FAL. Asigno 0 a ctaseguro.nnumlin para evitar ctaseguro_PK violada cuando vienen registros tipo 05 y 06
            reg_migctaseguro.ffecmov := v_ffecvalces;
            reg_migctaseguro.fvalmov := v_ffecvalces;
            reg_migctaseguro.cmovimi := 0;
            reg_migctaseguro.imovim2 := NULL;
            reg_migctaseguro.ccalint := 0;
            reg_migctaseguro.nrecibo := NULL;
            reg_migctaseguro.nsinies := NULL;
            reg_migctaseguro.cmovanu := 0;
            reg_migctaseguro.smovrec := NULL;
            reg_migctaseguro.cesta := v_ncesta;
            reg_migctaseguro.cestado := 1;
            reg_migctaseguro.fasign := NULL;
            reg_migctaseguro.nparpla := NULL;
            reg_migctaseguro.cestpar := NULL;
            reg_migctaseguro.iexceso := NULL;
            reg_migctaseguro.spermin := NULL;
            reg_migctaseguro.sidepag := NULL;
            reg_migctaseguro.ctipapor := NULL;
            reg_migctaseguro.srecren := NULL;
            reg_migctaseguro.imovimi := 0;
            reg_migctaseguro.nunidad := 0;
            -- Numero unidades
            v_naux := converteix_charanum(x.campo09);

            IF v_naux IS NULL THEN
               v_tdeserror := 'Unidades con formato erroneo: ' || x.campo09 || ' (10,7)';
               v_nnumerr := 1000135;
               RAISE e_errdatos;
            ELSE
               v_naux := v_naux / 10000000;
               reg_migctaseguro.nunidad := v_naux;
            END IF;

            -- Importe
            v_naux := converteix_charanum(x.campo10);

            IF v_naux IS NULL THEN
               v_tdeserror := 'importe con formato erroneo: ' || x.campo10 || ' (11,2)';
               v_nnumerr := 1000135;
               RAISE e_errdatos;
            ELSE
               v_naux := v_naux / 100;
               reg_migctaseguro.imovimi := v_naux;
            END IF;

            IF reg_migctaseguro.nunidad <> 0
               OR reg_migctaseguro.imovimi <> 0 THEN
               INSERT INTO mig_ctaseguro
                    VALUES reg_migctaseguro
                 RETURNING ROWID
                      INTO v_rowid;

               INSERT INTO mig_pk_emp_mig
                    VALUES (0, v_ncarga, 8, reg_migctaseguro.mig_pk);
            END IF;
------------------------------------------------------------------------------------------------------------------------
         ELSE
            v_bwarning := TRUE;
            p_genera_logs(v_tobjeto, v_ntraza, 'Tipo Registro',
                          'no definido ' || ' (' || x.campo01 || ')', x.proceso,
                          'Tipo Registro no definido ' || ' (' || x.campo01 || ')');
            v_nnumerr :=
               p_marcalinea
                  (x.proceso, x.nlinea, p_toperacion, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   TO_NUMBER(x.campo05),   -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga   -- Fi Bug 16324
                           );
            v_nnumerr := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 102903,
                                           'registro tipo ' || x.campo01 || ' no definido.');
            v_nnumerr := 0;
            v_bwarning := FALSE;
         END IF;
      END LOOP;

      v_ntraza := 1340;
      v_ntraza := 1350;

      UPDATE int_polizas_cnp
         SET ncarga = v_ncarga
       WHERE proceso = p_ssproces
         AND campo01 NOT IN('01', '07')
         AND campo05 = p_tcampo05;

      v_ntraza := 1355;
      --COMMIT;
--------------------------
--------------------------
--------------------------
-- LANZAMOS EL PROCESO  --
-- LANZAMOS EL PROCESO  --
-- LANZAMOS EL PROCESO  --
--------------------------
--------------------------
--------------------------
      pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

      --Cargamos las SEG para la póliza (ncarga)
      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = v_ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         v_ntraza := 200;
         v_nnumerr :=
            p_marcalinea
               (p_ssproces, v_videntifica, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                p_tcampo05,   -- Fi Bug 14888
                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                v_ncarga   -- Fi Bug 16324
                        );

         IF v_nnumerr <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            v_tdeserror := 'Falta marcar linea 1: ' || p_ssproces || '/' || v_videntifica;
            RAISE e_errdatos;
         END IF;

         v_baux := TRUE;
         v_ntraza := 201;
         v_nnumerr := p_marcalineaerror(p_ssproces, v_videntifica, NULL, 1, 151840, reg.incid);

         IF v_nnumerr <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            v_tdeserror := 'Falta marcar linea error 2: ' || p_ssproces || '/'
                           || v_videntifica;
            RAISE e_errdatos;
         END IF;

         v_ntiperr := 1;
      END LOOP;

      IF NOT v_baux THEN
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = v_ncarga
                        AND tipo = 'W') LOOP   --Miramos si han habido warnings.
            v_ntraza := 202;

            BEGIN
               SELECT sseguro
                 INTO v_sseguro
                 FROM mig_seguros
                WHERE ncarga = v_ncarga;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --JRH IMP de momento
            END;

            UPDATE seguros
               SET cpolcia = LTRIM(p_tcampo05, '0')   -- no guardamos los 0
             WHERE sseguro = v_sseguro;

            --commit;
            v_nnumerr :=
               p_marcalinea
                  (p_ssproces, v_videntifica, p_toperacion, 2, 1, v_sseguro,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   p_tcampo05,   -- Fi Bug 14888
                                 -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   v_ncarga   -- Fi Bug 16324
                           );

            IF v_nnumerr <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               v_tdeserror := ' : ' || p_ssproces || '/' || v_videntifica;
               RAISE e_errdatos;
            END IF;

            v_ntraza := 203;
            v_nnumerr := p_marcalineaerror(p_ssproces, v_videntifica, NULL, 2, 700145,
                                           reg.incid);

            IF v_nnumerr <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               v_tdeserror := 'Falta marcar linea error 3: ' || p_ssproces || '/'
                              || v_videntifica;
               RAISE e_errdatos;
            END IF;

            -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
            IF k_busca_host = 1 THEN   -- FAL. 28/06/2011. Parametrizar la busqueda de personas host
               FOR x IN cur_polizas LOOP
                  vnum_err := f_alta_persona_host(x, psinterf, terror);

                  IF vnum_err <> 0 THEN
                     vnum_err :=
                        p_marcalinea
                           (p_ssproces, v_videntifica, p_toperacion, 2, 1, v_sseguro,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                            p_tcampo05,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                            v_ncarga   -- Fi Bug 16324
                                    );

                     IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
                        v_tdeserror := ' : ' || p_ssproces || '/' || v_videntifica;
                        RAISE e_errdatos;
                     END IF;

                     IF NOT warning_alta_host THEN
                        vnum_err := p_marcalineaerror(p_ssproces, v_videntifica, NULL, 2,
                                                      700145, terror);

                        IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
                           v_tdeserror := ' : ' || p_ssproces || '/' || v_videntifica;
                           RAISE e_errdatos;
                        END IF;

                        warning_alta_host := TRUE;
                     END IF;
                  END IF;
               -- Fi Bug 0017569
               END LOOP;
            END IF;

            v_baux := TRUE;
         END LOOP;

         v_ntiperr := 2;
      END IF;

      IF NOT v_baux THEN
         --Esto quiere decir que no ha habido ningún error (lo indicamos también).
         v_ntraza := 204;

         BEGIN
            SELECT sseguro
              INTO v_sseguro
              FROM mig_seguros
             WHERE ncarga = v_ncarga;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --JRH IMP de momento
         END;

         UPDATE seguros
            SET cpolcia = LTRIM(p_tcampo05, '0')   -- ojo no guardamos los 0
          WHERE sseguro = v_sseguro;

         --commit;
         v_nnumerr :=
            p_marcalinea
               (p_ssproces, v_videntifica, p_toperacion, 4, 1, v_sseguro,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                p_tcampo05,   -- Fi Bug 14888
                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                v_ncarga   -- Fi Bug 16324
                        );

         IF v_nnumerr <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            v_tdeserror := 'Falta marcar linea 4: ' || p_ssproces || '/' || v_videntifica;
            RAISE e_errdatos;
         END IF;

         v_ntiperr := 4;

         -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
         IF k_busca_host = 1 THEN   -- FAL. 28/06/2011. Parametrizar la busqueda de personas host
            FOR x IN cur_polizas LOOP
               vnum_err := f_alta_persona_host(x, psinterf, terror);

               IF vnum_err <> 0 THEN
                  v_ntiperr := 2;
                  vnum_err :=
                     p_marcalinea
                        (p_ssproces, v_videntifica, p_toperacion, 2, 1, v_sseguro,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                         p_tcampo05,   -- Fi Bug 14888
                         -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                         v_ncarga   -- Fi Bug 16324
                                 );

                  IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
                     v_tdeserror := ' : ' || p_ssproces || '/' || v_videntifica;
                     RAISE e_errdatos;
                  END IF;

                  IF NOT warning_alta_host THEN
                     vnum_err := p_marcalineaerror(p_ssproces, v_videntifica, NULL, 2, 700145,
                                                   terror);

                     IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
                        v_tdeserror := ' : ' || p_ssproces || '/' || v_videntifica;
                        RAISE e_errdatos;
                     END IF;

                     warning_alta_host := TRUE;
                  END IF;
               END IF;
            -- Fi Bug 0017569
            END LOOP;
         END IF;
      END IF;

      RETURN v_ntiperr;   --Devolvemos el tipo error que ha habido
   EXCEPTION
      WHEN e_errdatos THEN
         ROLLBACK;
         werrorsalida := v_nnumerr;   -- Bug 16324. 26/10/2010.FAL. Si es error lo devuelva para q pare carga si parametrizado como parar carga
         pac_cargas_cnp.p_genera_logs(v_tobjeto, v_ntraza, 'Error ' || v_nnumerr, v_tdeserror,
                                      p_ssproces, 'Error ' || v_nnumerr || ' ' || v_tdeserror);
         v_nnumerr :=
            p_marcalinea
               (p_ssproces, n_nlineaact, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                p_tcampo05,   -- Fi Bug 14888
                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                v_ncarga   -- Fi Bug 16324
                        );
         v_nnumerr := p_marcalineaerror(p_ssproces, n_nlineaact, NULL, 1, NVL(v_nnumerr, 1),
                                        NVL(v_tdeserror, -1));
         COMMIT;
         -- Bug 16324. 26/10/2010.FAL. Si es error lo devuelva para q pare carga si parametrizado como parar carga
         --RETURN 4;   -- todo bien, para que continue con la siguiente linea.
         RETURN werrorsalida;
      -- Fi Bug 16324
      WHEN OTHERS THEN
         v_nnumerr := SQLCODE;
         v_tdeserror := SQLCODE || ' ' || SQLERRM;
         ROLLBACK;
         pac_cargas_cnp.p_genera_logs(v_tobjeto, v_ntraza, 'ERROR ' || v_nnumerr, v_tdeserror,
                                      p_ssproces, 'Error ' || v_tdeserror);
         v_nnumerr :=
            p_marcalinea
               (p_ssproces, n_nlineaact, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                p_tcampo05,   -- Fi Bug 14888
                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                v_ncarga   -- Fi Bug 16324
                        );
         v_nnumerr := p_marcalineaerror(p_ssproces, n_nlineaact, NULL, 1, v_nnumerr,
                                        v_tdeserror);
         COMMIT;
         -- Bug 16324. 26/10/2010.FAL. Si es error lo devuelva para q pare carga si parametrizado como parar carga
         --RETURN 4   -- todo bien, para que continue con la siguiente linea.
         RETURN SQLCODE;
   -- Fi Bug 16324
   END f_altapoliza_mig;

   -- Bug 0016696. FAL. 18/11/2010
   /*************************************************************************
             procedimiento que genera anulación de póliza
          param in x : registro tipo INT_POLIZAS_CNP
          param p_deserror out: Descripción del error si existe.
          Devuelve TIPOERROR ( 1-Ha habido error, 2-Es un warning, 4-Ha ido bien, x-Error incontrolado).
          --
          Para modificar una póliza, los siguientes campos son obligatorios:
          - póliza
          - certificado
          - identificador personas
          - fecha efecto de la operación
          --
      *************************************************************************/
   FUNCTION f_baja_poliza   -- (x IN OUT int_polizas_CNP%ROWTYPE, p_deserror IN OUT VARCHAR2)
                         (
      p_ssproces IN NUMBER,
      x IN OUT int_polizas_cnp%ROWTYPE,
      p_toperacion IN VARCHAR2,
      p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CNP.F_BAJA_POLIZA';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_per          NUMBER;
      n_aux          NUMBER;
      n_seg          NUMBER;
      d_baj          DATE;
      b_warning      BOOLEAN;
      rpend          pac_anulacion.recibos_pend;
      rcob           pac_anulacion.recibos_cob;
      n_age          seguros.cagente%TYPE;
      n_pro          seguros.sproduc%TYPE;
      n_pol          NUMBER;
      n_sit          NUMBER;
      n_sex          NUMBER;
      d_nac          DATE;
      v_des1         VARCHAR2(100);
      v_des2         VARCHAR2(100);
      w_csituac      NUMBER;   -- Bug 0016324. FAL. 18/10/2010
      wnpoliza       NUMBER;   -- Bug 0016324. FAL. 26/10/2010
      whaywarnings   NUMBER := 0;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
------------------------------------
-- VALIDAR CAMPOS CLAVE: Persona. --
------------------------------------

      /*
            IF x.nif_tomador IS NULL THEN
         p_deserror := 'Persona sin informar.';
         cerror := 100524;
         RAISE errdatos;
      END IF;
      */
      vtraza := 1010;
      n_pro := pac_cargas_cnp.f_buscavalor('CRT_PRODUCTOCNPPLAN', x.campo03);
      vtraza := 1020;

      BEGIN
         SELECT sseguro, cagente, sproduc, csituac, npoliza
           INTO n_seg, n_age, n_pro, w_csituac, wnpoliza
           FROM seguros
          WHERE cpolcia = LTRIM(x.campo05, '0')
            AND sproduc = n_pro
            AND cempres = vg_nempresaaxis;

         n_aux := 1;
      EXCEPTION
         WHEN OTHERS THEN
            n_aux := 0;
      END;

      IF n_aux = 0 THEN
         p_deserror := 'Número póliza no existe: ' || x.campo05;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1040;
      -- FAL. Asigna fh_anulacion como fecha baja
      d_baj := converteix_charadate(x.campo09, 'yyyymmdd');   -- TO_DATE(x.fh_anulacion, 'DD/MM/YYYY');

      IF d_baj IS NULL THEN
         p_deserror := 'Fecha baja no es fecha: ' || x.campo09 || ' (aaaammdd)';
         p_deserror := p_deserror
                       || '. Editar linea, modificar fecha baja (campo09) y reprocesar';
         cerror := 102853;
         RAISE errdatos;
      END IF;

      vtraza := 1050;
      v_des2 := '';
      vtraza := 1070;

      SELECT tmotmov   -- ctaseguro
        INTO v_des1
        FROM motmovseg
       WHERE cmotmov = k_motivoanula
         -- FAL. Provisional. Motivo anulacion 324 -- Anul·lació inmediata
         AND cidioma = vg_nidiomaaxis;

      vtraza := 1080;
      cerror := pac_agensegu.f_set_datosapunte(NULL, n_seg, NULL, v_des1,
                                               f_axis_literales(100811, vg_nidiomaaxis) || ' '
                                               || v_des1 || CHR(13) || CHR(13) || v_des2,
                                               6, 1, f_sysdate, f_sysdate, 0, 0);

      IF cerror <> 0 THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Agenda', 'código ' || cerror, x.proceso,
                       'Agenda: código ' || cerror);
         cerror := 0;
      END IF;

      vtraza := 1090;

      /*SELECT cagente, sproduc, csituac,
             npoliza   -- Bug 0016324. FAL. 18/10/2010  -- Bug 0016324. FAL. 26/10/2010
        INTO n_age, n_pro, w_csituac,
             wnpoliza   -- Fi Bug 0016324 -- Fi Bug 0016324
        FROM seguros
       WHERE sseguro = n_seg;
      */
      -- Bug 0016324. FAL. 18/10/2010
      IF w_csituac <> 0 THEN   -- No permita anular poliza si ya lo está
         p_deserror := 'La póliza ' || TO_CHAR(x.campo05) || ' no esta vigente';
         -- Bug 0016324. FAL. 26/10/2010. Informar el npoliza en la desc. error
         cerror := 101483;
         --RAISE errdatos;
         n_aux :=
            p_marcalinea
               (p_ssproces, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         cerror := 0;
      ELSE
         -- Fi Bug 0016324
         vtraza := 1100;
         cerror := pac_anulacion.f_anula_poliza(n_seg, k_motivoanula,
                                                f_parinstalacion_n('MONEDAINST'), d_baj, 0,   -- pcextorn
                                                1,   -- Anular rebuts pendents
                                                n_age, rpend, rcob, n_pro, NULL,   -- pcnotibaja
                                                2, NULL);
      END IF;

      IF cerror = 0 THEN
         -- Bug 0020573 - FAL - 16/12/2011
         --actualizamos la tabla de solicitud de suplementos
         UPDATE sup_solicitud
            SET cestsup = 1
          WHERE sseguro = n_seg
            AND cestsup = 2;

         -- Fi Bug 0020573

         -- Hemos realizado la baja
         vtraza := 1110;
         whaywarnings := 0;

         SELECT COUNT(*)
           INTO whaywarnings
           FROM mig_logs_axis
          WHERE ncarga = x.ncarga
            AND tipo = 'W';

         IF whaywarnings = 0 THEN
            n_aux :=
               p_marcalinea
                  (p_ssproces, x.nlinea, p_toperacion, 4, 1, n_seg,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.campo05,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga   -- Fi Bug 16324
                           );

            IF n_aux <> 0 THEN   -- Si fallan estas funciones de gestión salimos del programa
               RAISE errdatos;
            END IF;
         END IF;

         cerror := 4;   -- Todo bien
      ELSE
         -- No hemos hecho ningún suplemento.
         RAISE errdatos;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (p_ssproces, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := '(traza=' || vtraza || ') ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         n_aux :=
            p_marcalinea
               (p_ssproces, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(p_ssproces, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_baja_poliza;

   -- Fi Bug 0016696

   -- Bug 0016696. FAL. 18/11/2010
   /*************************************************************************
         Funcion que inicializa la primera parte (comun) de un suplemento.
      param p_seg in  : seguro tablas reales
      param p_efe in  : fecha efecto
      param p_mot in  : código motivo suplemento
      param p_est out : seguro tablas estudio
      param p_mov out : número movimiento
      param p_des out : descripción en caso de error
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION p_iniciar_suple(
      p_seg IN NUMBER,
      p_efe IN DATE,
      p_mot IN NUMBER,
      p_est OUT NUMBER,
      p_mov OUT NUMBER,
      p_des OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CNP.P_INICIAR_SUPLE';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
   BEGIN
      p_des := NULL;
--------------------------------------------------------------------------
-- iniciar suple
--------------------------------------------------------------------------
      vtraza := 1060;
      cerror := pk_suplementos.f_permite_suplementos(p_seg, p_efe, p_mot);

      IF cerror <> 0 THEN
         p_des := 'permite suplemento (s=' || p_seg || ' e=' || p_efe || ' m=' || p_mot || ')';

         IF cerror = 103308 THEN
            p_des := p_des || 'Editar linea, modificar fecha suplemento y reprocesar linea';
         END IF;

         RAISE errdatos;
      END IF;

      vtraza := 1061;
      /*cerror := pk_suplementos.f_permite_este_suplemento(p_seg, p_efe, p_mot);
            IF cerror <> 0 THEN
         p_des := 'permite este suplemento s=' || p_seg || ' e=' || p_efe || ' m=' || p_mot;
         RAISE errdatos;
      END IF;
      vtraza := 1062;*/
      p_est := NULL;
      cerror := pk_suplementos.f_inicializar_suplemento(p_seg, 'SUPLEMENTO', p_efe, 'BBDD',   -- pac_cargas_asefa
                                                        '*', p_mot, p_est, p_mov);

      IF cerror <> 0 THEN
         p_des := 'ini suplemento s=' || p_seg || ' e=' || p_efe || ' m=' || p_mot;
         RAISE errdatos;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN errdatos THEN
         RETURN cerror;
   END p_iniciar_suple;

   -- Fi Bug 0016696

   -- Bug 0016696. FAL. 18/11/2010
   /*************************************************************************
         Funcion que finaliza la parte final (comun) de un suplemento.
      param p_est out : seguro tablas estudio
      param p_mov out : número movimiento
      param p_seg in  : seguro tablas reales
      param p_des out : descripción en caso de error
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION p_finalizar_suple(
      p_est IN NUMBER,
      p_mov IN NUMBER,
      p_seg IN NUMBER,
      p_des OUT VARCHAR2,
      p_cmotmov IN NUMBER,
      pproceso IN NUMBER,
      pfsuplem IN DATE)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CNP.P_FINALIZAR_SUPLE';
      vtraza         NUMBER;
      cerror         NUMBER;
      e_nosuple      EXCEPTION;
      errdatos       EXCEPTION;
      n_aux          NUMBER;
      indice         NUMBER;
      indice_e       NUMBER;
      indice_t       NUMBER;
      r_seg          seguros%ROWTYPE;
      pmensaje       VARCHAR2(500);   -- BUG 27642 - FAL - 30/04/2014
   BEGIN
      p_des := NULL;
      vtraza := 1090;

      SELECT *
        INTO r_seg
        FROM seguros
       WHERE sseguro = p_seg;

--------------------------------------------------------------------------
-- finalitzar suple
--------------------------------------------------------------------------
      vtraza := 1092;

      BEGIN
         INSERT INTO pds_estsegurosupl
                     (sseguro, nmovimi, cmotmov, fsuplem, cestado)
              VALUES (p_est, p_mov, p_cmotmov, pfsuplem, 'X');
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;   --si ya existe es que están haciendo más suplementos
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_CARGAS_CNP', 1,
                        'Error insertando en pds_estsegurosupl', SQLERRM);
      END;

      vtraza := 1094;
      cerror := pk_suplementos.f_grabar_suplemento_poliza(p_est, p_mov);

      IF cerror <> 0 THEN
         p_des := 'grabar suplemento s=' || p_est || ' m=' || p_mov;
         RAISE errdatos;
      END IF;

      vtraza := 1096;
      p_emitir_propuesta(r_seg.cempres, r_seg.npoliza, r_seg.ncertif, r_seg.cramo,
                         r_seg.cmodali, r_seg.ctipseg, r_seg.ccolect, r_seg.cactivi, 1,
                         r_seg.cidioma, indice, indice_e, indice_t, pmensaje,   -- BUG 27642 - FAL - 30/04/2014
                         pproceso, NULL, 1);

      IF indice_e <> 0
         OR indice < 1 THEN
         cerror := 151237;
         p_des := 'emision (' || indice_e || ')';
         RAISE errdatos;
      END IF;

      vtraza := 1098;
      RETURN 0;
   EXCEPTION
      WHEN e_nosuple THEN
         RETURN -2;   -- Warning
      WHEN errdatos THEN
         RETURN cerror;
   END p_finalizar_suple;

   -- Fi Bug 0016696

   -- Bug 0016696. FAL. 18/11/2010
   /*************************************************************************
             procedimiento que genera suplemento con modificacion de póliza
          param in x : registro tipo int_polizas_CNP
          param p_deserror out: Descripción del error si existe.
          Devuelve TIPOERROR ( 1-Ha habido error, 2-Es un warning, 4-Ha ido bien, x-Error incontrolado).
          --
          Para modificar una póliza, los siguientes campos son obligatorios:
          - póliza
          - certificado
          - identificador personas
          - fecha efecto de la operación
          --
      *************************************************************************/
   FUNCTION f_modi_poliza(
      p_ssproces IN NUMBER,
      x IN OUT int_polizas_cnp%ROWTYPE,
      p_toperacion IN VARCHAR2,
      p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CNP.F_MODI_POLIZA';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_seg          seguros.sseguro%TYPE;
      n_pro          seguros.sproduc%TYPE;
      n_aux          NUMBER;
      d_efe          seguros.fefecto%TYPE;
      d_sup          movseguro.fefecto%TYPE;
      n_vig          NUMBER;
      n_est          estseguros.sseguro%TYPE;
      n_mov          movseguro.nmovimi%TYPE;
      d_aux          DATE;
      n_perest       esttomadores.sperson%TYPE;
      n_cagente      seguros.cagente%TYPE;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      wnnumlin       ctaseguro.nnumlin%TYPE;
      v_ctaseguro    ctaseguro%ROWTYPE;
      v_videntifica  int_polizas_cnp.campo04%TYPE;
      v_ffecvalces   tabvalces.fvalor%TYPE;
      v_tdeserror    VARCHAR2(1000);
      v_nnumerr      NUMBER;
      v_ncesta       tabvalces.ccesta%TYPE;
      v_naux         NUMBER;
      wcmovimi_orig  VARCHAR2(5);
      wcmovimi_det   VARCHAR2(5);
      wcmovimi       VARCHAR2(5);
      v_nauximporte  NUMBER;
      wcharaux       VARCHAR2(1);
/*
      CURSOR cur_polizas IS
         SELECT   *
             FROM int_polizas_cnp a
            WHERE proceso = p_ssproces
              AND campo01 NOT IN('01', '07')
              AND campo05 = x.campo05
         ORDER BY nlinea, campo01, campo02;
*/
      v_haysuplementos NUMBER;
      w_existebenefi NUMBER;
      wwtclaesp      clausuesp.tclaesp%TYPE;
      wsproduc       productos.sproduc%TYPE;
      v_cforpag      seguros.cforpag%TYPE;
      v_ncarga       NUMBER;
      vsidepag       NUMBER;
      v_nrecibo      NUMBER;
      vnsinies       sin_siniestro.nsinies%TYPE;
      vccausin       sin_siniestro.ccausin%TYPE;
      vcmotsin       sin_siniestro.cmotsin%TYPE;
      visinret       NUMBER;
      psrecren       pagosrenta.srecren%TYPE;
      wfechmov       DATE;
      --w_cambio_cc    NUMBER;
      wcnordban      per_ccc.cnordban%TYPE;
      wccausin       sin_siniestro.ccausin%TYPE;
      wcmotsin       sin_siniestro.cmotsin%TYPE;
      wcagente       seguros.cagente%TYPE;
      w_numsinis     NUMBER;
      wnsinies       siniestros.nsinies%TYPE;
      wfsinies       siniestros.fsinies%TYPE;
      wfalta         siniestros.falta%TYPE;
      wntramit       sin_tramita_reserva.ntramit%TYPE;
      wnmovres       sin_tramita_reserva.nmovres%TYPE;
      wsperson       per_personas.sperson%TYPE;
      v_importeretencion NUMBER;
      v_cgarant      NUMBER;
   BEGIN
      IF x.campo01 = '02' THEN
         -- antes de nada miro si hay algun cambio por realizar
         SELECT COUNT('x')
           INTO v_haysuplementos
           FROM (SELECT x.campo09, x.campo25, x.campo27, x.campo28, x.campo29,
                        NVL(TRIM(x.campo31), 0)   -- fvencim, cbancar, cforpag
                   FROM DUAL
                 MINUS
                 SELECT campo09, campo25, campo27, campo28, campo29, NVL(TRIM(campo31), 0)
                   FROM int_polizas_cnp
                  WHERE campo05 = x.campo05   -- pol.
                    AND campo03 = x.campo03   -- prod.
                    AND campo01 = x.campo01
                    AND proceso = (SELECT MAX(proceso)
                                     FROM int_polizas_cnp
                                    WHERE campo05 = x.campo05
                                      AND campo03 = x.campo03
                                      AND campo01 = x.campo01
                                      AND proceso < x.proceso));
      END IF;

/*
      --AND proceso <> x.proceso)); --> ICV CAMBIO A MENOR POR SI SE TIRA PARA ATRAS Y SE VUELVE A CARGA O ESTA UN FICHERO MAYOR EN INT_POLIZAS_CNP PERO AUN NO SE HAN CARGADO
      IF TO_CHAR(TO_DATE(x.fec_efecto, 'dd/mm/rrrr'), 'mm') =
                                     TO_CHAR(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'), 'mm')
         AND NVL(x.forma_pago, 0) <> 'U' THEN
         --Si estamos en el mes de última renovación es una cartera de renovación
         v_movcart := 1;
         v_haysuplementos := 1;
      END IF;
*/
      IF v_haysuplementos = 0
         AND x.campo01 = '02' THEN
         p_deserror := 'La póliza ' || TO_NUMBER(x.campo05) || ' no tiene modificaciones';
         cerror := 107804;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 2, 1, n_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
         RETURN 4;   -- marcalo como ok
      END IF;

-----------------------------------------------------------------------------------------------
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
---------------------------------------------------------
-- VALIDAR CAMPOS CLAVE: Póliza, Certificado           --
---------------------------------------------------------
      vtraza := 1010;

      IF LTRIM(x.campo05) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      n_pro := pac_cargas_cnp.f_buscavalor('CRT_PRODUCTOCNPPLAN', x.campo03);

      BEGIN
         SELECT sseguro, sproduc, fefecto, f_vigente(sseguro, NULL, f_sysdate), cagente
           INTO n_seg, n_pro, d_efe, n_vig, n_cagente
           FROM seguros
          WHERE cpolcia = LTRIM(x.campo05, '0')
            AND sproduc = n_pro
            AND cempres = vg_nempresaaxis;

         BEGIN
            IF (NVL(n_cagente, -1) <> NVL(TO_NUMBER(x.campo04), -1)) THEN   -- si la oficina gestora es diferente al cargada en la póliza
               p_deserror := 'La póliza ' || LTRIM(x.campo05, '0')
                             || ' ha cambiado de oficina. Anterior ' || n_cagente || ' por '
                             || TO_NUMBER(x.campo04);
               cerror := 9000815;
               n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
               cerror := NULL;
               p_deserror := NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      EXCEPTION
         WHEN OTHERS THEN
            BEGIN
               SELECT seg.sseguro, sproduc, fefecto, f_vigente(seg.sseguro, NULL, f_sysdate),
                      seg.cagente
                 INTO n_seg, n_pro, d_efe, n_vig,
                      n_cagente
                 FROM seguros seg, tomadores tom, per_personas per
                WHERE fefecto = TO_DATE(LTRIM(x.campo07), 'yyyymmdd')
                  AND sproduc = n_pro
                  AND tom.sseguro = seg.sseguro
                  AND per.sperson =
                        tom.sperson   -- cualquier tomador con ese nif, esa fecha fecha, ese producto
                  AND TRIM(BOTH '0' FROM per.nnumide) =
                         TRIM(BOTH '0' FROM TRIM(x.campo23))   -- lpad(ltrim(x.campo23,'0'),9,'0')
                  AND cempres = vg_nempresaaxis;
            EXCEPTION
               WHEN OTHERS THEN
                  n_seg := NULL;
                  n_pro := NULL;
                  d_efe := NULL;
                  n_vig := NULL;
            END;
      END;

      IF n_seg IS NULL THEN
         p_deserror := 'Número póliza no existe: ' || x.campo05;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      IF n_vig <> 0
         AND x.campo01 = '02' THEN   -- validar si vigente solo para regsitro campo01 = '02'
         -- FAL. 24/10/2011. Bug 19853 - Rehabilitacion de polizas
         cerror := pac_rehabilita.f_rehabilita(n_seg, 700, n_cagente, n_mov);

         IF cerror <> 0 THEN
            p_deserror := 'Error en la rehabilitación';
            cerror := 9001557;
            RAISE errdatos;
         ELSE
            COMMIT;
         END IF;
      --p_deserror := 'Póliza no esta vigente: ' || n_vig;
      --cerror := 120129;
      --RAISE errdatos;
      -- Fi Bug 19853 - Rehabilitacion de polizas
      END IF;

      vtraza := 1020;
      d_sup := converteix_charadate(LTRIM(x.campo07), 'yyyymmdd');

      IF x.campo01 = '02' THEN
         IF d_sup < d_efe THEN
            p_deserror := 'Suplemento: ' || TO_CHAR(d_sup, 'dd-mm-yyyy')
                          || ' inferior a efecto póliza: ' || TO_CHAR(d_efe, 'dd-mm-yyyy');
            --cerror := 180386;
            --RAISE errdatos;
            d_sup := d_efe;   -- que lo haga a fefecto
            n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, p_deserror);

            IF n_aux <> 0 THEN
               RAISE errdatos;
            END IF;
         END IF;
      END IF;

      --  FAL. Carga de movimientos economicos en la modificacion.
--      FOR reg IN cur_polizas LOOP
      IF x.campo01 = '05' THEN   -- MOV. ECONOMICOS
         SELECT   MAX(campo04)
             INTO v_videntifica
             FROM int_polizas_cnp
            WHERE proceso = p_ssproces
              AND campo01 = '01'
         ORDER BY nlinea;

         IF v_videntifica IS NULL THEN
            v_tdeserror := 'Falta fecha fichero hasta';
            v_nnumerr := 1000135;
            RAISE errdatos;
         ELSE
            vtraza := 1002;
            v_ffecvalces := converteix_charadate(v_videntifica, 'yyyymmdd');

            IF v_ffecvalces IS NULL THEN
               v_tdeserror := 'Fecha fichero hasta no es fecha: ' || v_videntifica
                              || ' (aaaammdd)';
               v_nnumerr := 1000135;
               RAISE errdatos;
            END IF;
         END IF;

         --buscar cesta asignada al producto.
         SELECT MAX(c.ccodfon)
           INTO v_ncesta
           FROM proplapen b, planpensiones c
          WHERE b.sproduc = n_pro
            AND c.ccodpla = b.ccodpla;

         -- comprobar si existe valor para la fecha.
         SELECT COUNT(1)
           INTO v_naux
           FROM tabvalces d
          WHERE d.ccesta = v_ncesta
            AND d.fvalor = v_ffecvalces;

         IF v_naux = 0 THEN
            v_naux := converteix_charanum(x.campo15);

            IF v_naux IS NOT NULL THEN
               v_naux := v_naux / 10000000;

               -- Si no existe, creamos valor a partir datos fichero.
               INSERT INTO tabvalces
                           (ccesta, fvalor, nparact, iuniact, ivalact, nparasi, igastos)
                    VALUES (v_ncesta, v_ffecvalces, 0, v_naux, 0, NULL, NULL);
            END IF;
         END IF;

         SELECT NVL(MAX(nnumlin), 0) + 1
           INTO wnnumlin
           FROM ctaseguro
          WHERE sseguro = n_seg;

         wcmovimi_orig := pac_cargas_cnp.f_buscavalor('CRT_TIPOMOVCNPPLAN', x.campo08);   -- Código tipo movimiento
         wcmovimi := SUBSTR(wcmovimi_orig, 1, INSTR(wcmovimi_orig, '-') - 1);
         wcmovimi_det := SUBSTR(wcmovimi_orig, INSTR(wcmovimi_orig, '-') + 1,
                                LENGTH(wcmovimi_orig));
         -- Importe
         v_nauximporte := converteix_charanum(x.campo09);

         IF v_nauximporte IS NULL THEN
            v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
            v_nnumerr := 1000135;
            RAISE errdatos;
         ELSE
            v_nauximporte := v_nauximporte / 100;
         END IF;

         -- implemenntar traspasos entrada - salida . crear recibo/siniestro sin usar las tablas MIG   ?????

         -- 15490/88884 - FAL. 04/07/2011. Generar recibo para traspasos de entrada y generar siniestro para traspasos de salida.
         wsproduc := pac_cargas_cnp.f_buscavalor('CRT_PRODUCTOCNPPLAN', x.campo03);

         IF TRIM(x.campo08) IN('L', 'SB', 'SO', 'ST', 'SF') THEN   -- TRASPADO SALIDA
            BEGIN
               SELECT sseguro, cforpag
                 INTO n_seg, v_cforpag
                 FROM seguros
                WHERE cpolcia = LTRIM(x.campo05, '0')
                  AND sproduc = wsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  n_seg := NULL;
            END;

            --vtraza := 1018;
            IF n_seg IS NULL THEN
               v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
               v_nnumerr := 100500;
               RAISE errdatos;
            END IF;

            v_naux := converteix_charanum(x.campo09);

            IF v_naux IS NULL THEN
               v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
               v_nnumerr := 1000135;
               RAISE errdatos;
            ELSE
               v_naux := v_naux / 100;
            END IF;

            v_ncarga := f_next_carga;
            vsidepag := NULL;

            IF x.campo08 IN('SF') THEN
               wccausin := 7009;
               wcmotsin := 0;
            ELSE
               wccausin := 8;

               IF x.campo08 IN('SB') THEN
                  wcmotsin := 2;
               ELSE
                  wcmotsin := 1;
               END IF;
            END IF;

            v_nnumerr := f_crea_siniestro(x, n_seg, wccausin, NVL(wcmotsin, 1), NVL(v_naux, 0),
                                          v_ncarga, p_toperacion, vsidepag);

            UPDATE int_polizas_cnp
               SET ncarga = v_ncarga
             WHERE proceso = p_ssproces
               AND campo01 NOT IN('01', '07')
               AND campo05 = LTRIM(x.campo05, '0');

            --v_ntraza := 1355;
            --COMMIT;
            pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
            vnsinies := NULL;

            BEGIN
               SELECT DISTINCT s.nsinies, s.ccausin, s.cmotsin, p.isinret
                          INTO vnsinies, vccausin, vcmotsin, visinret
                          FROM sin_tramita_pago p, sin_siniestro s
                         WHERE p.sidepag = vsidepag
                           AND s.nsinies = p.nsinies;
            EXCEPTION
               WHEN OTHERS THEN
                  v_tdeserror := 'Error en pago:' || vsidepag;
                  RAISE errdatos;
            END;
         ELSIF x.campo08 IN('AT', 'AO') THEN   -- TRASPASO ENTRADA
            v_naux := converteix_charanum(x.campo09);

            IF v_naux IS NULL THEN
               v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
               v_nnumerr := 1000135;
               RAISE errdatos;
            ELSE
               v_naux := v_naux / 100;
            END IF;

            BEGIN
               SELECT sseguro, cforpag
                 INTO n_seg, v_cforpag
                 FROM seguros
                WHERE cpolcia = LTRIM(x.campo05, '0')
                  AND sproduc = wsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  n_seg := NULL;
            END;

            --vtraza := 1018;
            IF n_seg IS NULL THEN
               v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
               v_nnumerr := 100500;
               RAISE errdatos;
            END IF;

            v_ncarga := f_next_carga;
            v_nrecibo := NULL;
            v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 10, v_ncarga, p_toperacion,
                                       v_nrecibo);   -- emito f_recibo

            UPDATE int_polizas_cnp
               SET ncarga = v_ncarga
             WHERE proceso = p_ssproces
               AND campo01 NOT IN('01', '07')
               AND campo05 = LTRIM(x.campo05, '0');

            --v_ntraza := 1355;
            --COMMIT;
            pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

            IF v_nnumerr <> 0 THEN
               RAISE errdatos;
            END IF;
         ELSIF x.campo08 IN('AP') THEN
            v_naux := converteix_charanum(x.campo09);

            IF v_naux IS NULL THEN
               v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
               v_nnumerr := 1000135;
               RAISE errdatos;
            ELSE
               v_naux := v_naux / 100;
            END IF;

            BEGIN
               SELECT sseguro, cforpag
                 INTO n_seg, v_cforpag
                 FROM seguros
                WHERE cpolcia = LTRIM(x.campo05, '0')
                  AND sproduc = wsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  n_seg := NULL;
            END;

            --vtraza := 1018;
            IF n_seg IS NULL THEN
               v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
               v_nnumerr := 100500;
               RAISE errdatos;
            END IF;

            v_ncarga := f_next_carga;
            v_nrecibo := NULL;
            v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 3, v_ncarga, p_toperacion,
                                       v_nrecibo);   -- emito f_recibo

            UPDATE int_polizas_cnp
               SET ncarga = v_ncarga
             WHERE proceso = p_ssproces
               AND campo01 NOT IN('01', '07')
               AND campo05 = LTRIM(x.campo05, '0');

            --v_ntraza := 1355;
            --COMMIT;
            pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

            IF v_nnumerr <> 0 THEN
               RAISE errdatos;
            END IF;
         ELSIF x.campo08 IN('AR') THEN   -- regulariacion aportacion. en funcion del signo extorno: 9 ó Aportació extraordinària: 4
            IF x.campo12 = '+' THEN
               v_naux := converteix_charanum(x.campo09);

               IF v_naux IS NULL THEN
                  v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                  v_nnumerr := 1000135;
                  RAISE errdatos;
               ELSE
                  v_naux := v_naux / 100;
               END IF;

               BEGIN
                  SELECT sseguro, cforpag
                    INTO n_seg, v_cforpag
                    FROM seguros
                   WHERE cpolcia = LTRIM(x.campo05, '0')
                     AND sproduc = wsproduc;
               EXCEPTION
                  WHEN OTHERS THEN
                     n_seg := NULL;
               END;

               --vtraza := 1018;
               IF n_seg IS NULL THEN
                  v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
                  v_nnumerr := 100500;
                  RAISE errdatos;
               END IF;

               v_ncarga := f_next_carga;
               v_nrecibo := NULL;
               v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 4, v_ncarga, p_toperacion,
                                          v_nrecibo);   -- emito f_recibo

               UPDATE int_polizas_cnp
                  SET ncarga = v_ncarga
                WHERE proceso = p_ssproces
                  AND campo01 NOT IN('01', '07')
                  AND campo05 = LTRIM(x.campo05, '0');

               --v_ntraza := 1355;
               --COMMIT;
               pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

               IF v_nnumerr <> 0 THEN
                  RAISE errdatos;
               END IF;
            ELSE
               v_naux := converteix_charanum(x.campo09);

               IF v_naux IS NULL THEN
                  v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                  v_nnumerr := 1000135;
                  RAISE errdatos;
               ELSE
                  v_naux := v_naux / 100;
               END IF;

               BEGIN
                  SELECT sseguro, cforpag
                    INTO n_seg, v_cforpag
                    FROM seguros
                   WHERE cpolcia = LTRIM(x.campo05, '0')
                     AND sproduc = wsproduc;
               EXCEPTION
                  WHEN OTHERS THEN
                     n_seg := NULL;
               END;

               --vtraza := 1018;
               IF n_seg IS NULL THEN
                  v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
                  v_nnumerr := 100500;
                  RAISE errdatos;
               END IF;

               v_ncarga := f_next_carga;
               v_nrecibo := NULL;
               v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 9, v_ncarga, p_toperacion,
                                          v_nrecibo);   -- emito f_recibo

               UPDATE int_polizas_cnp
                  SET ncarga = v_ncarga
                WHERE proceso = p_ssproces
                  AND campo01 NOT IN('01', '07')
                  AND campo05 = LTRIM(x.campo05, '0');

               --v_ntraza := 1355;
               --COMMIT;
               pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

               IF v_nnumerr <> 0 THEN
                  RAISE errdatos;
               END IF;
            END IF;
         ELSIF x.campo08 IN('AA', 'AE') THEN
            v_naux := converteix_charanum(x.campo09);

            IF v_naux IS NULL THEN
               v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
               v_nnumerr := 1000135;
               RAISE errdatos;
            ELSE
               v_naux := v_naux / 100;
            END IF;

            BEGIN
               SELECT sseguro, cforpag
                 INTO n_seg, v_cforpag
                 FROM seguros
                WHERE cpolcia = LTRIM(x.campo05, '0')
                  AND sproduc = wsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  n_seg := NULL;
            END;

            --vtraza := 1018;
            IF n_seg IS NULL THEN
               v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
               v_nnumerr := 100500;
               RAISE errdatos;
            END IF;

            v_ncarga := f_next_carga;
            v_nrecibo := NULL;
            v_nnumerr := f_crea_recibo(x, n_seg, v_naux, 0, 4, v_ncarga, p_toperacion,
                                       v_nrecibo);   -- emito f_recibo

            UPDATE int_polizas_cnp
               SET ncarga = v_ncarga
             WHERE proceso = p_ssproces
               AND campo01 NOT IN('01', '07')
               AND campo05 = LTRIM(x.campo05, '0');

            --v_ntraza := 1355;
            --COMMIT;
            pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

            IF v_nnumerr <> 0 THEN
               RAISE errdatos;
            END IF;
         ELSIF x.campo08 IN('SN', 'SD', 'SG', 'SI', 'SJ', 'SS') THEN
            v_naux := converteix_charanum(x.campo09);
            wfechmov := converteix_charadate(x.campo07, 'yyyymmdd');

            IF v_naux IS NULL THEN
               v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
               v_nnumerr := 1000135;
               RAISE errdatos;
            ELSE
               v_naux := v_naux / 100;
            END IF;

            BEGIN
               SELECT sseguro, cforpag, cagente
                 INTO n_seg, v_cforpag, wcagente
                 FROM seguros
                WHERE cpolcia = LTRIM(x.campo05, '0')
                  AND sproduc = wsproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  n_seg := NULL;
            END;

            --vtraza := 1018;
            IF n_seg IS NULL THEN
               v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
               v_nnumerr := 100500;
               RAISE errdatos;
            END IF;

            v_ncarga := f_next_carga;
            v_nnumerr := f_crea_renta(x, n_seg, v_naux, v_ncarga, p_toperacion, psrecren);

            IF v_nnumerr <> 0 THEN
               RAISE errdatos;
            END IF;

            pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

            IF x.campo08 IN('SN') THEN
               wccausin := 13;
               wcmotsin := 0;
            ELSIF x.campo08 IN('SG') THEN
               wccausin := 7014;
               wcmotsin := 0;
            ELSIF x.campo08 IN('SI') THEN
               wccausin := 7010;
               wcmotsin := 0;
            ELSIF x.campo08 IN('SJ') THEN
               wccausin := 7008;
               wcmotsin := 0;
            ELSIF x.campo08 IN('SD') THEN
               wccausin := 7013;
               wcmotsin := 0;
            ELSIF x.campo08 IN('SS') THEN
               wccausin := 7008;
               wcmotsin := 0;
            END IF;

            w_numsinis := 0;

            SELECT COUNT('*')
              INTO w_numsinis
              FROM sin_siniestro
             WHERE sseguro = n_seg
               AND ccausin = wccausin;

            IF w_numsinis = 0 THEN
               v_ncarga := f_next_carga;
               v_nnumerr := f_crea_siniestro(x, n_seg, wccausin, wcmotsin, NVL(v_naux, 0),
                                             v_ncarga, p_toperacion, vsidepag);
               pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
            ELSE
               SELECT MAX(nsinies)
                 INTO wnsinies
                 FROM sin_siniestro
                WHERE sseguro = n_seg
                  AND ccausin = wccausin;   -- realmente solo deberia haber uno

               SELECT fsinies, falta
                 INTO wfsinies, wfalta
                 FROM sin_siniestro
                WHERE nsinies = wnsinies;

               SELECT MAX(ntramit)
                 INTO wntramit
                 FROM sin_tramitacion
                WHERE nsinies = wnsinies;

               SELECT MAX(nmovres)
                 INTO wnmovres
                 FROM sin_tramita_reserva
                WHERE nsinies = wnsinies
                  AND ntramit = wntramit;

               -- jlb - 21452 -- si el siniestro se ha creado manualemente no ha insrtado reserva
               SELECT cgarant
                 INTO v_cgarant
                 FROM garanpro
                WHERE sproduc = wsproduc
                  AND ROWNUM = 1;

               IF wnmovres IS NULL THEN
                  wnmovres := 1;

                  INSERT INTO sin_tramita_reserva
                              (nsinies, ntramit, ctipres, nmovres, cgarant, ccalres, fmovres,
                               cmonres, ireserva, ipago,
                               icaprie, ipenali)
                       VALUES (wnsinies, wntramit, 1, wnmovres, v_cgarant, 0, wfechmov,
                               'EUR', 0, v_naux + NVL(v_importeretencion, 0),
                               v_naux + NVL(v_importeretencion, 0), 0);
               END IF;

               SELECT p.sperson   --, p.ctipide, p.cestper, 1, p.swpubli, d.tapelli1
                 INTO wsperson
                 --v_mig_personas.idperson, v_mig_personas.ctipide,
                 --v_mig_personas.cestper, v_mig_personas.cpertip, v_mig_personas.swpubli, v_mig_personas.tapelli1
               FROM   asegurados a, per_personas p, per_detper d
                WHERE a.sseguro = n_seg
                  AND a.norden = 1
                  AND p.sperson = a.sperson
                  AND d.cagente = ff_agente_cpervisio(wcagente)
                  AND d.sperson = p.sperson;   --En caso de que no sea el asegurado tendríamos que ver si nos lo envían

               SELECT sidepag.NEXTVAL
                 INTO vsidepag
                 FROM DUAL;

               v_importeretencion := converteix_charanum(x.campo11) / 100;

               INSERT INTO sin_tramita_pago
                           (sidepag, nsinies, ntramit, sperson, ctipdes, ctippag, cconpag,
                            ccauind, cforpag, fordpag, ctipban, cbancar, cmonres,
                            isinret, iretenc,
                            iiva, isuplid, ifranq, iresrcm, iresred, cmonpag, isinretpag,
                            iretencpag, iivapag, isuplidpag, ifranqpag, iresrcmpag,
                            iresredpag, fcambio, nfacref, ffacref, cusualt, falta, cusumod,
                            fmodifi, ctransfer, sproces)
                    VALUES (vsidepag, wnsinies, wntramit, wsperson, 1, 2, 1,
                            0, 1, wfechmov, NULL, NULL, NULL,
                            v_naux + NVL(v_importeretencion, 0), NVL(v_importeretencion, 0),
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, f_user, wfalta, NULL,
                            NULL, NULL, NULL);

               INSERT INTO sin_tramita_movpago
                           (sidepag, nmovpag, cestpag, fefepag, cestval, fcontab, sproces,
                            cusualt, falta, cestpagant)
                    VALUES (vsidepag, 1, 0, wfechmov, 0, NULL, NULL,
                            f_user, wfalta, NULL);

               INSERT INTO sin_tramita_movpago
                           (sidepag, nmovpag, cestpag, fefepag, cestval, fcontab, sproces,
                            cusualt, falta, cestpagant)
                    VALUES (vsidepag, 2, 1, wfechmov, 1, NULL, NULL,
                            f_user, wfalta, NULL);

               INSERT INTO sin_tramita_pago_gar
                           (sidepag, ctipres, nmovres, cgarant, fperini, fperfin, cmonres,
                            isinret, iretenc,
                            iiva, isuplid, ifranq, iresrcm, iresred, cmonpag, isinretpag,
                            iivapag, isuplidpag, iretencpag, ifranqpag, iresrcmpag,
                            iresredpag, fcambio, pretenc, piva, cusualt, falta, cusumod,
                            fmodifi, cconpag, norden)
                    VALUES (vsidepag, 1, wnmovres, v_cgarant, NULL, NULL, NULL,
                            v_naux + NVL(v_importeretencion, 0), NVL(v_importeretencion, 0),
                            0, NULL, 0, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, 0, NULL, f_user, wfsinies, NULL,
                            NULL, NULL, 1);
            END IF;

            UPDATE int_polizas_cnp
               SET ncarga = v_ncarga
             WHERE proceso = p_ssproces
               AND campo01 NOT IN('01', '07')
               AND campo05 = LTRIM(x.campo05, '0');

            --v_ntraza := 1355;
            --COMMIT;

            -- pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');
            BEGIN
               SELECT DISTINCT s.nsinies, s.ccausin, s.cmotsin, p.isinret
                          INTO vnsinies, vccausin, vcmotsin, visinret
                          FROM sin_tramita_pago p, sin_siniestro s
                         WHERE p.sidepag = vsidepag
                           AND s.nsinies = p.nsinies;
            EXCEPTION
               WHEN OTHERS THEN
                  v_tdeserror := 'Error en pago:' || vsidepag;
                  RAISE errdatos;
            END;
         -- reg_migctaseguro.nsinies := vnsinies;

         -- reg_migctaseguro.srecren := psrecren;

         /*
                     v_naux := converteix_charanum(x.campo09);

                     IF v_naux IS NULL THEN
                        v_tdeserror := 'importe con formato erroneo: ' || x.campo09 || ' (11,2)';
                        v_nnumerr := 1000135;
                        RAISE errdatos;
                     ELSE
                        v_naux := v_naux / 100;
                     END IF;

                     BEGIN
                        SELECT sseguro, cforpag
                          INTO n_seg, v_cforpag
                          FROM seguros
                         WHERE cpolcia = LTRIM(x.campo05, '0')
                           AND sproduc = wsproduc;
                     EXCEPTION
                        WHEN OTHERS THEN
                           n_seg := NULL;
                     END;

                     --vtraza := 1018;
                     IF n_seg IS NULL THEN
                        v_tdeserror := 'Número póliza(recibo) no existe4: ' || LTRIM(x.campo05, '0');
                        v_nnumerr := 100500;
                        RAISE errdatos;
                     END IF;

                     v_ncarga := f_next_carga;
                     psrecren := NULL;
                     v_nnumerr := f_crea_renta(x, n_seg, v_naux, v_ncarga, p_toperacion, psrecren);   -- emito f_recibo

                     UPDATE int_polizas_cnp
                        SET ncarga = v_ncarga
                      WHERE proceso = p_ssproces
                        AND campo01 NOT IN('01', '07')
                        AND campo05 = LTRIM(x.campo05, '0');

                     --v_ntraza := 1355;
                     COMMIT;
                     pac_mig_axis.p_migra_cargas(v_videntifica, 'C', v_ncarga, 'DEL');

                     IF v_nnumerr <> 0 THEN
                        RAISE errdatos;
                     END IF;
         */
         END IF;

         -- Fi Bug 15490/88884
         wfechmov := converteix_charadate(x.campo07, 'yyyymmdd');   --Fecha valor movimiento. registro tipo 5 (mov.economicos)

-- JLB - 22/02/2012 - Creo entradas en trasplaninout
         DECLARE
            --
            vcinout        trasplainout.cinout%TYPE;
            vctiptras      trasplainout.ctiptras%TYPE;
            viimporte      trasplainout.iimporte%TYPE;
            vcexterno      trasplainout.cexterno%TYPE;
            vccodpla       trasplainout.ccodpla%TYPE;
            vtnompla       planpensiones.tnompla%TYPE;
         BEGIN
            IF TRIM(x.campo08) IN('L', 'AO', 'AT', 'SO', 'SB', 'ST') THEN
               BEGIN
                  SELECT ccodpla, tnompla
                    INTO vccodpla, vtnompla
                    FROM planpensiones
                   WHERE ((TRIM(x.campo22) IS NULL
                           AND coddgs IS NULL)
                          OR(TRIM(x.campo22) IS NOT NULL
                             AND coddgs = TRIM(x.campo22)));
               EXCEPTION
                  WHEN OTHERS THEN
                     v_tdeserror :=
                        'No se encuentra el plan de traspaso en PLANPENSIONES: '
                        || TRIM(x.campo22);
                     v_nnumerr := 9902327;
                     RAISE errdatos;
               END;

               IF TRIM(x.campo08) IN('L', 'SB', 'SO', 'ST') THEN
                  -- salida
                  vcinout := 2;
               ELSE
                  -- entrada
                  vcinout := 1;
               END IF;

               IF TRIM(x.campo08) IN('L', 'SB') THEN
                  -- PARCIAL
                  vctiptras := 1;
               ELSE
                  -- TOTAL
                  vctiptras := 2;
               END IF;

               IF TRIM(x.campo08) IN('L', 'AO', 'SO') THEN
                  -- interno
                  vcexterno := 0;
               ELSE
                  --externo
                  vcexterno := 1;
               END IF;

               viimporte := converteix_charanum(x.campo09) / 100;

               INSERT INTO trasplainout
                           (stras, cinout, sseguro, fsolici, ccodpla, cestado, ctiptras,
                            iimporte, iimptemp, nnumlin, cexterno, fvalor, cusualta,
                            festado, nsinies, fefecto, ctipder, tmemo, ctiptrassol)
                    VALUES (stras.NEXTVAL, vcinout, n_seg, wfechmov, vccodpla, 4, vctiptras,
                            viimporte, viimporte, wnnumlin, vcexterno, wfechmov, f_user,
                            wfechmov, vnsinies, wfechmov, 3, vtnompla, 1);
            END IF;
         EXCEPTION
            WHEN errdatos THEN
               RAISE errdatos;
            WHEN OTHERS THEN
               v_tdeserror := 'Insertando en TRASPLAINOUT: ' || TRIM(x.campo22) || '-'
                              || SQLERRM;
               v_nnumerr := 108468;
               RAISE errdatos;
         END;

-- FIN JLB  traspasos 22/02/2012

         -- Bug 0015490. FAL. 15/02/2011
         SELECT SUBSTR(x.campo14, 1, 1)
           INTO wcharaux
           FROM DUAL;

         IF wcharaux = '-' THEN
            v_naux := converteix_charanum(SUBSTR(x.campo14, 2, LENGTH(x.campo14)));
         ELSE
            -- Numero unidades
            v_naux := converteix_charanum(x.campo14);
         END IF;

         IF v_naux IS NULL THEN
            v_tdeserror := 'Unidades con formato erroneo: ' || x.campo14 || ' (10,7)';
            v_nnumerr := 1000135;
            RAISE errdatos;
         ELSE
            v_naux := v_naux / 10000000;

            IF wcharaux = '-' THEN
               v_naux := v_naux *(-1);
            END IF;
         END IF;

         v_naux := NULL;   -- nº unidades solo se informa para saldos. campo01 = '06'

         -- Fi Bug 0015490
         IF v_nauximporte <> 0
            OR v_naux <> 0 THEN
            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                         imovimi, ccalint, imovim2, nrecibo, nsinies, cmovanu, smovrec,
                         cesta, nunidad, cestado, fasign, nparpla, cestpar, iexceso, spermin,
                         sidepag, ctipapor, srecren)
                 VALUES (n_seg, wfechmov, wnnumlin, wfechmov, wfechmov, TO_NUMBER(wcmovimi),
                         v_nauximporte, 0, NULL, v_nrecibo, vnsinies, NULL, NULL,
                         v_ncesta, v_naux, 1, NULL, NULL, NULL, NULL, NULL,   /*vsidepag*/
                         NULL, NULL, psrecren);   -- FAL - se comenta... error por constraint ctaseguro_pagosini_FK. En ningun lado se relacionan pagosini-ctaseguro por sidepag

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            --   IF NVL(pac_parametros.f_parempresa_n(vg_nempresaaxis, 'MULTIMONEDA'), 0) = 1 THEN
              --    cerror := pac_oper_monedas.f_update_ctaseguro_monpol(n_seg, wfechmov, wnnumlin,
                --                                                       wfechmov);

            -- IF cerror <> 0 THEN
                --   RAISE errdatos;
               -- END IF;
            -- END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            INSERT INTO ctaseguro_libreta
                        (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                         nnumlib, npagina, nlinea, fimpres, sreimpre, igasext, igasint)
                 VALUES (n_seg, wnnumlin, wfechmov, 0, 0, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL);
         /*   -- FAL. 1/7/2011. Se descarta insertar concepto detalle ctaseguro
         -- detalle ctaseguro
         SELECT NVL(MAX(nnumlin), 0) + 1
           INTO wnnumlin
           FROM ctaseguro
          WHERE sseguro = n_seg;

         INSERT INTO ctaseguro
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                      cmovimi, imovimi, ccalint, imovim2, nrecibo, nsinies, cmovanu,
                      smovrec, cesta, nunidad, cestado, fasign, nparpla, cestpar, iexceso,
                      spermin, sidepag, ctipapor, srecren)
              VALUES (n_seg, v_ffecvalces, wnnumlin, v_ffecvalces, v_ffecvalces,
                      TO_NUMBER(wcmovimi_det), v_nauximporte, 0, NULL, NULL, NULL, 0,
                      NULL, v_ncesta, v_naux, 1, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL);
         */
         END IF;
      ELSIF x.campo01 = '06' THEN   -- Derechos
         SELECT   MAX(campo04)
             INTO v_videntifica
             FROM int_polizas_cnp
            WHERE proceso = p_ssproces
              AND campo01 = '01'
         ORDER BY nlinea;

         IF v_videntifica IS NULL THEN
            v_tdeserror := 'Falta fecha fichero hasta';
            v_nnumerr := 1000135;
            RAISE errdatos;
         ELSE
            vtraza := 1002;
            v_ffecvalces := converteix_charadate(v_videntifica, 'yyyymmdd');

            IF v_ffecvalces IS NULL THEN
               v_tdeserror := 'Fecha fichero hasta no es fecha: ' || v_videntifica
                              || ' (aaaammdd)';
               v_nnumerr := 1000135;
               RAISE errdatos;
            END IF;
         END IF;

         --buscar cesta asignada al producto.
         SELECT MAX(c.ccodfon)
           INTO v_ncesta
           FROM proplapen b, planpensiones c
          WHERE b.sproduc = n_pro
            AND c.ccodpla = b.ccodpla;

         -- comprobar si existe valor para la fecha.
         SELECT COUNT(1)
           INTO v_naux
           FROM tabvalces d
          WHERE d.ccesta = v_ncesta
            AND d.fvalor = v_ffecvalces;

         IF v_naux = 0 THEN
            v_naux := converteix_charanum(x.campo11);

            IF v_naux IS NOT NULL THEN
               v_naux := v_naux / 10000000;

               -- Si no existe, creamos valor a partir datos fichero.
               INSERT INTO tabvalces
                           (ccesta, fvalor, nparact, iuniact, ivalact, nparasi, igastos)
                    VALUES (v_ncesta, v_ffecvalces, 0, v_naux, 0, NULL, NULL);
            END IF;
         END IF;

         SELECT NVL(MAX(nnumlin), 0) + 1
           INTO wnnumlin
           FROM ctaseguro
          WHERE sseguro = n_seg;

         -- Numero unidades
         v_naux := converteix_charanum(x.campo09);

         IF v_naux IS NULL THEN
            v_tdeserror := 'Unidades con formato erroneo: ' || x.campo09 || ' (10,7)';
            v_nnumerr := 1000135;
            RAISE errdatos;
         ELSE
            v_naux := v_naux / 10000000;
         END IF;

         -- Importe
         v_nauximporte := converteix_charanum(x.campo10);

         IF v_nauximporte IS NULL THEN
            v_tdeserror := 'importe con formato erroneo: ' || x.campo10 || ' (11,2)';
            v_nnumerr := 1000135;
            RAISE errdatos;
         ELSE
            v_nauximporte := v_nauximporte / 100;
         END IF;

         IF v_nauximporte <> 0
            OR v_naux <> 0 THEN
            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                         imovimi, ccalint, imovim2, nrecibo, nsinies, cmovanu, smovrec,
                         cesta, nunidad, cestado, fasign, nparpla, cestpar, iexceso, spermin,
                         sidepag, ctipapor, srecren)
                 VALUES (n_seg, v_ffecvalces, wnnumlin, v_ffecvalces, v_ffecvalces, 0,
                         v_nauximporte, 0, NULL, NULL, NULL, 0, NULL,
                         v_ncesta, v_naux, 1, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL);
           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         --  IF NVL(pac_parametros.f_parempresa_n(vg_nempresaaxis, 'MULTIMONEDA'), 0) = 1 THEN
           --   cerror := pac_oper_monedas.f_update_ctaseguro_monpol(n_seg, v_ffecvalces,
             --                                                      wnnumlin, v_ffecvalces);

         --IF cerror <> 0 THEN
                 -- RAISE errdatos;
              -- END IF;
           -- END IF;
         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         END IF;
      ELSIF x.campo01 = '02' THEN
--------------------------------------------------------------------------
-- iniciar suple
--------------------------------------------------------------------------
         vtraza := 1030;
         cerror := pac_cargas_cnp.p_iniciar_suple(n_seg, d_sup, k_motivomodif, n_est, n_mov,
                                                  p_deserror);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

      --------------------------------------------------------------------------
-- modificacions
--------------------------------------------------------------------------
/* vtraza := 1040;
       BEGIN
    UPDATE estseguros
       SET tnatrie = 'Número asegurados ' || x.num_asegurados
     WHERE sseguro = n_est;
 EXCEPTION
    WHEN OTHERS THEN
       p_deserror := 'Error ' || SQLCODE || ' Número asegurados: ' || x.num_asegurados;
       cerror := 104566;
       RAISE errdatos;
 END;*/
         vtraza := 1045;
         d_aux := converteix_charadate(TRIM(x.campo09), 'yyyymmdd');

         BEGIN
            UPDATE estseguros
               SET fvencim = d_aux
             WHERE sseguro = n_est;
         --AND fvencim <> d_aux;
         EXCEPTION
            WHEN OTHERS THEN
               p_deserror := 'Error ' || SQLCODE || ' Vencimiento: '
                             || TO_CHAR(d_aux, 'yyyymmdd');
               cerror := 104566;
               RAISE errdatos;
         END;

         vtraza := 1055;
         /*IF LTRIM(x.campo23) IS NOT NULL THEN
            SELECT MAX(1)
              INTO n_aux
              FROM seguros a, tomadores b, per_personas c
             WHERE a.sseguro = n_seg
               AND b.sseguro = a.sseguro
               AND c.sperson = b.sperson
               AND c.nnumide <> x.campo23;

            IF n_aux IS NULL THEN
               b_warning := TRUE;
               v_deswarning := v_deswarning || ' ' || 'Tomador diferente  ' || x.campo23;
            END IF;
         END IF;*/
         vtraza := 1060;

         IF NVL(TRIM(x.campo28), 0) <> 0 THEN
            DECLARE
               v_cbancar      seguros.cbancar%TYPE;
               n_control      NUMBER;
               v_salida       VARCHAR2(50);
            BEGIN
               vtraza := 1065;
               v_cbancar := LPAD(SUBSTR(RTRIM(LPAD(x.campo25, 6, '0')), -4), 4, '0')
                            || LPAD(SUBSTR(RTRIM(LPAD(x.campo27, 6, '0')), -4), 4, '0')
                            || x.campo29 || x.campo28;
               vtraza := 1070;
               cerror := f_ccc(TO_NUMBER(v_cbancar), 1, n_control, v_salida);

               IF cerror <> 0 THEN
                  p_deserror := 'Error ' || cerror || ' al validar cuenta bancaria: '
                                || v_cbancar;
                  cerror := 120130;
                  n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
                  cerror := NULL;
               -- RAISE errdatos;
               END IF;

               /*w_cambio_cc := 0;

               SELECT COUNT(*)
                 INTO w_cambio_cc
                 FROM estseguros
                WHERE sseguro = n_est
                  AND cbancar <> v_cbancar
                  AND ctipban = 1; */
               UPDATE estseguros
                  SET cbancar = v_cbancar,
                      ctipban = 1,
                      ctipcob = 2
                WHERE sseguro = n_est;

               --AND nvl(cbancar,-1) <> v_cbancar;
               IF SQL%ROWCOUNT > 0 THEN
                  FOR tom IN (SELECT sperson
                                FROM tomadores
                               WHERE sseguro = n_seg) LOOP
                     BEGIN
                        SELECT NVL(MAX(cnordban), 0) + 1
                          INTO wcnordban
                          FROM per_ccc
                         WHERE sperson = tom.sperson;

                        INSERT INTO per_ccc
                                    (sperson,
                                     cagente, ctipban,
                                     cbancar, fbaja, cdefecto, cusumov, fusumov, cnordban)
                             VALUES (tom.sperson,
                                     NVL(ff_agente_cpervisio(n_cagente), k_agente), 1,
                                     v_cbancar, NULL, 0, f_user, f_sysdate, wcnordban);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_deserror := 'Error ' || SQLCODE
                                         || ' insertando cuenta bancaria en persona: '
                                         || v_cbancar;
                           cerror := 9000777;   -- Error al grabar la cuenta de cargo.
                           RAISE errdatos;
                     END;
                  END LOOP;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_deserror := 'Error ' || SQLCODE || ' Cuenta bancaria: ' || v_cbancar;
                  cerror := 120130;
                  RAISE errdatos;
            END;
         ELSE
            UPDATE estseguros
               SET cbancar = NULL,
                   ctipban = NULL,
                   ctipcob = 1
             WHERE sseguro = n_est;
         END IF;

         vtraza := 1080;

         IF LTRIM(x.campo31) IS NOT NULL THEN
            DECLARE
               v_cforpag      seguros.cforpag%TYPE;
            BEGIN
               vtraza := 1085;
               v_cforpag := converteix_charanum(x.campo31);
               vtraza := 1090;

               UPDATE estseguros
                  SET cforpag = v_cforpag
                WHERE sseguro = n_est
                  AND cforpag <> v_cforpag;
            EXCEPTION
               WHEN OTHERS THEN
                  p_deserror := 'Error ' || SQLCODE || ' Cuenta forma pago: ' || x.campo31;
                  cerror := 140704;
                  RAISE errdatos;
            END;
         END IF;

         vtraza := 1095;

         UPDATE estgaranseg
            SET icapital = 0,
                iprianu = 0,
                ipritar = 0,
                ipritot = 0,
                icaptot = 0
          WHERE sseguro = n_est
            AND norden = 1
            AND ffinefe IS NULL;

         --actualizamos la tabla de solicitud de suplementos
         UPDATE sup_solicitud
            SET cestsup = 1
          WHERE sseguro = n_seg
            AND cestsup = 2;

      --   COMMIT;
--------------------------------------------------------------------------
-- finalitzar suple
--------------------------------------------------------------------------
         cerror := pac_cargas_cnp.p_finalizar_suple(n_est, n_mov, n_seg, p_deserror,
                                                    k_motivomodif, x.proceso, d_sup);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      ELSIF x.campo01 = '03' THEN   -- Beneficiarios
         SELECT COUNT(*)
           INTO w_existebenefi
           FROM clausuesp
          WHERE sseguro = n_seg;

         IF w_existebenefi = 0 THEN
            pac_cargas_cnp.p_textoclausula('Benef:' || x.campo09, TRIM(x.campo07),
                                           (x.campo12 / 10000) || '%', wwtclaesp);

            INSERT INTO clausuesp
                        (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
                         tclaesp, ffinclau, timagen)
                 VALUES (NVL(n_mov, 1), n_seg, 1, 1, 1, d_efe, NULL,
                         wwtclaesp, NULL, NULL);
         ELSE
            BEGIN
               SELECT 1
                 INTO w_existebenefi
                 FROM clausuesp
                WHERE sseguro = n_seg
                  AND tclaesp LIKE '%' || LTRIM(x.campo09, '0') || '%';
            EXCEPTION
               WHEN OTHERS THEN
                  pac_cargas_cnp.p_textoclausula('Benef:' || x.campo09, TRIM(x.campo07),
                                                 (x.campo12 / 10000) || '%', wwtclaesp);

                  UPDATE clausuesp
                     SET tclaesp = tclaesp || CHR(10) || wwtclaesp
                   WHERE sseguro = n_seg;
            END;
         END IF;
      END IF;

--      END LOOP;

      ---------------------------------------------------------
-- CONTROL FINAL                                       --
---------------------------------------------------------
      IF b_warning THEN
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 2, 1, n_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF n_aux <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, v_deswarning);

         IF n_aux <> 0 THEN
            RAISE errdatos;
         END IF;
      ELSE
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 4, 1, n_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
      END IF;

      RETURN NVL(cerror, 0);
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, NVL(cerror, v_nnumerr),
                                    NVL(p_deserror, v_tdeserror));
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || '-' || n_est || ' (traza=' || vtraza
                       || ') ' || SQLCODE || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, p_toperacion, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.campo05,   -- Fi Bug 14888
                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_modi_poliza;

   -- Fi Bug 0016696

   /*************************************************************************
          procedimiento que ejecuta una carga (parte2 proceso).
       param in p_ssproces   : Número proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutarcarga_pppro(p_ssproces IN NUMBER, p_cproces IN NUMBER)   -- BUG16130:DRA:15/10/2010
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_CNP.F_EJECUTARCARGA_PPPRO';
      v_ntraza       NUMBER := 0;
      v_nnumerr      NUMBER;
      e_salir        EXCEPTION;

      CURSOR cur_polizas(p_ssproces2 IN NUMBER) IS
         -- Abrimos los certificados como control, después buscamos todos los registros del fichero.
         SELECT   a.*
             FROM int_polizas_cnp a
            WHERE proceso = p_ssproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea b
                              WHERE b.sproces = a.proceso
                                AND b.nlinea = a.nlinea
                                AND b.cestado IN(2, 4, 5))   --Solo las no procesadas
              --AND campo01 = '02'
              AND campo01 NOT IN('01', '07')
         --AND nlinea IN(17952, 17953, 17954)  --  sproces 42610
         --AND nlinea IN(419, 420, 421)   --  sproces 42614
         ORDER BY nlinea, campo01;   -- registro tipo certificado

      v_toperacion   VARCHAR2(20);
      v_ssproduc     productos.sproduc%TYPE;
      --v_npoliza      seguros.npoliza%TYPE;
      v_npoliza      seguros.cpolcia%TYPE;
      e_errdatos     EXCEPTION;
      v_berrorproc   BOOLEAN := FALSE;
      v_bavisproc    BOOLEAN := FALSE;
      v_ntipoerror   NUMBER;
      v_nnumerrpol   NUMBER;
      v_nnumerrset   NUMBER;
      v_tdeserror    int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
   -- v_ncfgproceso  cfg_files.cproceso%TYPE;  -- BUG16130:DRA:15/10/2010
   BEGIN
      v_ntraza := 0;

      IF p_ssproces IS NULL THEN
         v_nnumerr := 9000505;
         v_tdeserror := 'Parámetro p_ssproces obligatorio.';
         pac_cargas_cnp.p_genera_logs(v_tobjeto, v_ntraza, 'Error:' || v_nnumerr, v_tdeserror,
                                      NULL, NULL);
         RAISE e_salir;
      END IF;

      v_ntraza := 3;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = p_ssproces;

      IF v_tfichero IS NULL THEN
         v_nnumerr := 9901092;
         v_tdeserror := 'Falta fichero para proceso: ' || p_ssproces;
         RAISE e_errdatos;
      END IF;

      v_ntraza := 6;

      -- BUG16130:DRA:15/10/2010:Inici
      -- SELECT MAX(cproceso)
      --   INTO v_ncfgproceso
      --   FROM cfg_files
      --  WHERE cempres = vg_nempresaaxis
      --    AND cactivo = 1
      --    AND UPPER(tproceso) = REPLACE(v_tobjeto, 'PRO', '');
      -- BUG16130:DRA:15/10/2010:Fi
      IF p_cproces IS NULL THEN
         v_nnumerr := 9901092;
         v_tdeserror := 'cfg_files falta proceso: ' || v_tobjeto;
         RAISE e_errdatos;
      END IF;

      v_ntraza := 9;

      FOR x IN cur_polizas(p_ssproces) LOOP   --Leemos los registros de la tabla int no procesados OK
         -- Bug 0016324. FAL. 18/10/2010
         IF NVL(v_ntipoerror, 0) <> 1 THEN
            -- Fi Bug 0016324
            v_toperacion := NULL;
            v_ssproduc := NULL;
            v_npoliza := NULL;
            v_nnumerrpol := 0;
            -- Primero de todo averiguamos que operación vamos a realizar.
            -- Producto
            v_ssproduc := pac_cargas_cnp.f_buscavalor('CRT_PRODUCTOCNPPLAN', x.campo03);

            IF v_ssproduc IS NULL THEN
               v_nnumerrpol := 104485;
               v_tdeserror := ' ' || x.campo03;
            ELSE
                -- parametro Póliza
               -- v_npoliza := NVL(f_parproductos_v(v_ssproduc, 'NPOLIZA_COLECTIVO'), 0);
               v_npoliza := x.campo05;   -- jlb no vamos por certificado

               IF v_npoliza = 0 THEN
                  v_nnumerrpol := 9900973;
                  v_tdeserror := ' para producto ' || v_ssproduc;
               ELSE
                  SELECT COUNT(1)
                    INTO v_nnumerrpol
                    FROM seguros
                   --WHERE npoliza = v_npoliza --jlb la buscamos
                     --AND ncertif = TO_NUMBER(x.campo05);
                  WHERE  cpolcia = LTRIM(v_npoliza, '0')
                     AND sproduc = v_ssproduc
                     AND cempres = vg_nempresaaxis;

                  IF v_nnumerrpol = 0 THEN
                     v_toperacion := 'ALTA';
                  ELSE
                     -- Bug 0016696. FAL. 18/11/2010
                     -- v_nnumerrpol := 103289;
                     -- v_tdeserror := ' póliza ' || v_npoliza ;
                     IF TRIM(x.campo09) IS NULL
                        OR x.campo09 = '0'
                        OR x.campo09 = '00000000' THEN
                        v_toperacion := 'MODI';
                     ELSE
                        v_toperacion := 'BAJA';
                     END IF;
                  -- Fi Bug 0016696
                  END IF;
               END IF;
            END IF;

            IF v_toperacion = 'BAJA'
               AND x.campo01 <> '02' THEN
               v_toperacion := 'MODI';
            END IF;

            IF v_toperacion = 'ALTA' THEN   --Si es alta
               v_ntraza := 12;
               v_ntipoerror := f_altapoliza_mig(p_ssproces, v_npoliza, v_toperacion,
                                                x.campo03, x.campo01);

               IF v_ntipoerror = 2 THEN
                  v_bavisproc := TRUE;
               END IF;

               IF v_ntipoerror = 1 THEN
                  v_berrorproc := TRUE;
               END IF;

               -- Bug 0016324. FAL. 18/10/2010.
               IF v_ntipoerror NOT IN(0, 4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     v_ntipoerror := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     v_ntipoerror := 1;   -- para la carga
                  END IF;
               END IF;

               -- Fi Bug 0016324
               IF NOT(TRIM(x.campo09) IS NULL
                      OR x.campo09 = '0'
                      OR x.campo09 = '00000000') THEN
                  v_ntipoerror := f_baja_poliza(p_ssproces, x, v_toperacion, v_tdeserror);

                  IF v_ntipoerror = 2 THEN
                     v_bavisproc := TRUE;
                  END IF;

                  IF v_ntipoerror = 1 THEN
                     v_berrorproc := TRUE;
                  END IF;

                  IF v_ntipoerror NOT IN(0, 4, 2) THEN
                     IF k_para_carga <> 1 THEN
                        v_ntipoerror := 4;   -- para que continue con la siguiente linea.
                     ELSE
                        v_ntipoerror := 1;   -- para la carga
                     END IF;
                  END IF;
               END IF;
            -- Bug 0016696. FAL. 18/11/2010
            ELSIF v_toperacion = 'MODI' THEN
               v_ntipoerror := f_modi_poliza(p_ssproces, x, v_toperacion, v_tdeserror);

               IF v_ntipoerror = 2 THEN
                  v_bavisproc := TRUE;
               END IF;

               IF v_ntipoerror = 1 THEN
                  v_berrorproc := TRUE;
               END IF;

               IF v_ntipoerror NOT IN(0, 4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     v_ntipoerror := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     v_ntipoerror := 1;   -- para la carga
                  END IF;
               END IF;
            ELSIF v_toperacion = 'BAJA' THEN
               v_ntipoerror := f_baja_poliza(p_ssproces, x, v_toperacion, v_tdeserror);

               IF v_ntipoerror = 2 THEN
                  v_bavisproc := TRUE;
               END IF;

               IF v_ntipoerror = 1 THEN
                  v_berrorproc := TRUE;
               END IF;

               IF v_ntipoerror NOT IN(0, 4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     v_ntipoerror := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     v_ntipoerror := 1;   -- para la carga
                  END IF;
               END IF;
            -- Fi Bug 0016696

            --Grabamos en las MIG
            END IF;

            IF v_ntipoerror = 1 THEN   --Ha habido error
               v_berrorproc := TRUE;
            ELSIF v_ntipoerror = 2 THEN   -- Es un warning
               v_bavisproc := TRUE;
            ELSIF v_ntipoerror IN(0, 4) THEN   --Ha ido bien.
               NULL;
            ELSE
               v_nnumerr := v_ntipoerror;
               RAISE e_errdatos;
            --Error que para ejecución(funciones de gestión)
            END IF;

            v_ntraza := 33;
            COMMIT;
         -- Bug 0016324. FAL. 18/10/2010
         ELSIF v_ntipoerror = 1
               AND k_para_carga = 1 THEN
            v_ntipoerror := 1;
            v_nnumerrset := 151541;
            --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
            v_ntraza := 36;
            v_nnumerr :=
               pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (p_ssproces, v_tfichero, f_sysdate,
                                                          f_sysdate, v_ntipoerror, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          v_nnumerrset, NULL);

            IF v_nnumerr <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
               v_tdeserror :=
                             'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera';
               RAISE e_errdatos;
            END IF;

            v_ntraza := 39;
            COMMIT;
            RETURN 0;
         END IF;
      -- Fi Bug 0016324
      END LOOP;

-------------------------------- final loop ------------------------------------
-------------------------------- final loop ------------------------------------
-------------------------------- final loop ------------------------------------
      v_ntipoerror := 4;
      v_nnumerrset := NULL;

      IF v_bavisproc THEN
         v_ntipoerror := 2;
         v_nnumerrset := 700145;
      END IF;

      IF v_berrorproc THEN
         v_ntipoerror := 1;
         v_nnumerrset := 151541;
      END IF;

      --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
      v_ntraza := 36;
      v_nnumerr :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(p_ssproces, v_tfichero, NULL,
                                                        f_sysdate, v_ntipoerror, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        v_nnumerrset, NULL);

      IF v_nnumerr <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         v_tdeserror := 'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera';
         RAISE e_errdatos;
      END IF;

      --Bug.:17155
      IF v_ntipoerror IN(4, 2) THEN
         v_nnumerr := pac_gestion_procesos.f_set_carga_fichero(33, v_tfichero, 1, f_sysdate);

         IF v_nnumerr <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            v_tdeserror := 'Error llamando a pac_gestion_procesos.f_set_carga_fichero';
            RAISE e_errdatos;
         END IF;
      --Fi Bug.: 17155
      END IF;

      v_ntraza := 39;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_cnp.p_genera_logs(v_tobjeto, v_ntraza, 'Error:' || v_nnumerr, v_tdeserror,
                                      p_ssproces, 'Error:' || v_nnumerr || ' ' || v_tdeserror);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_cnp.p_genera_logs(v_tobjeto, v_ntraza, 'Error:' || v_nnumerr, SQLERRM,
                                      p_ssproces,
                                      f_axis_literales(103187, vg_nidiomaaxis) || ':'
                                      || v_tfichero || ' : ' || SQLERRM);
         v_nnumerr :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (p_ssproces, v_tfichero, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          151541, SQLERRM);

         IF v_nnumerr <> 0 THEN
            pac_cargas_cnp.p_genera_logs
                          (v_tobjeto, v_ntraza, v_nnumerr,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           p_ssproces,
                           f_axis_literales(180856, vg_nidiomaaxis) || ':' || v_tfichero
                           || ' : ' || v_nnumerr);
         END IF;

         COMMIT;
         RETURN 1;
   END f_ejecutarcarga_pppro;

   /*************************************************************************
                                                                                          procedimiento que lee carga el fichero
          param in p_ssproces     : Número proceso
          param in p_tnomfitxer : Nombre fichero
          param in out p_tdeserror : mensaje de error
      *************************************************************************/
   PROCEDURE p_carga(p_ssproces IN NUMBER, p_tnomfitxer IN VARCHAR2, p_tdeserror OUT VARCHAR2) IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_CNP.P_CARGA';
      v_ntraza       NUMBER := 0;
      v_nnumerr      NUMBER;
      e_salir        EXCEPTION;
      v_tpath        VARCHAR2(100);
      v_cidfitxer    UTL_FILE.file_type;
      v_nnumlin      NUMBER;
      v_tlinia       VARCHAR2(32000);
      v_rowid        ROWID;
      reg_poliza     int_polizas_cnp%ROWTYPE;
      w_lastdigit    NUMBER;
      w_lastdigitchar VARCHAR2(1);
      w_lastdigitcharv2 VARCHAR2(1);
   BEGIN
      v_ntraza := 1;
      v_nnumlin := 0;
      v_tpath := f_parinstalacion_t('PATH_CARGA');
      v_ntraza := 3;
      v_cidfitxer := UTL_FILE.fopen(v_tpath, p_tnomfitxer, 'r', 32767);

      LOOP
         v_ntraza := 5;
         reg_poliza := NULL;

         BEGIN
            v_nnumlin := v_nnumlin + 1;
            UTL_FILE.get_line(v_cidfitxer, v_tlinia);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               UTL_FILE.fclose(v_cidfitxer);
               EXIT;
         END;

         v_ntraza := 7;
         reg_poliza.sinterf := p_ssproces;
         reg_poliza.proceso := p_ssproces;
         reg_poliza.cmapead := '0';
         reg_poliza.smapead := 0;
         reg_poliza.nlinea := v_nnumlin;
         reg_poliza.ncarga := NULL;
         reg_poliza.campo01 := SUBSTR(v_tlinia, 001, 02);

         IF reg_poliza.campo01 = '01' THEN
            v_ntraza := 9;
            reg_poliza.campo02 := SUBSTR(v_tlinia, 003, 02);
            reg_poliza.campo03 := SUBSTR(v_tlinia, 005, 08);
            reg_poliza.campo04 := SUBSTR(v_tlinia, 013, 08);
            reg_poliza.campo05 := SUBSTR(v_tlinia, 021, 08);
            reg_poliza.campo06 := SUBSTR(v_tlinia, 029, 05);
            reg_poliza.campo07 := SUBSTR(v_tlinia, 034, 30);
            reg_poliza.campo08 := SUBSTR(v_tlinia, 064, 02);
            reg_poliza.campo09 := SUBSTR(v_tlinia, 066, 05);
            reg_poliza.campo10 := SUBSTR(v_tlinia, 071, 04);
            reg_poliza.campo11 := SUBSTR(v_tlinia, 075, 40);
            reg_poliza.campo12 := SUBSTR(v_tlinia, 115, 40);
            reg_poliza.campo13 := SUBSTR(v_tlinia, 155, 40);
            reg_poliza.campo14 := SUBSTR(v_tlinia, 195, 40);
            reg_poliza.campo15 := SUBSTR(v_tlinia, 235, 40);
            reg_poliza.campo16 := SUBSTR(v_tlinia, 275, 40);
            reg_poliza.campo17 := SUBSTR(v_tlinia, 315, 40);
            reg_poliza.campo18 := SUBSTR(v_tlinia, 355, 06);
            reg_poliza.campo19 := SUBSTR(v_tlinia, 361, 06);
         ELSIF reg_poliza.campo01 = '02' THEN
            v_ntraza := 11;
            reg_poliza.campo02 := SUBSTR(v_tlinia, 003, 02);
            reg_poliza.campo03 := SUBSTR(v_tlinia, 005, 05);
            reg_poliza.campo04 := SUBSTR(v_tlinia, 010, 06);
            reg_poliza.campo05 := SUBSTR(v_tlinia, 016, 10);
            reg_poliza.campo06 := SUBSTR(v_tlinia, 026, 02);
            reg_poliza.campo07 := SUBSTR(v_tlinia, 028, 08);
            reg_poliza.campo08 := SUBSTR(v_tlinia, 036, 08);
            reg_poliza.campo09 := SUBSTR(v_tlinia, 044, 08);
            reg_poliza.campo10 := SUBSTR(v_tlinia, 052, 02);
            reg_poliza.campo11 := SUBSTR(v_tlinia, 054, 08);
            reg_poliza.campo12 := SUBSTR(v_tlinia, 062, 02);
            reg_poliza.campo13 := SUBSTR(v_tlinia, 064, 01);
            reg_poliza.campo14 := SUBSTR(v_tlinia, 065, 01);
            reg_poliza.campo15 := SUBSTR(v_tlinia, 066, 01);
            reg_poliza.campo16 := SUBSTR(v_tlinia, 067, 60);
            reg_poliza.campo17 := SUBSTR(v_tlinia, 127, 40);
            reg_poliza.campo18 := SUBSTR(v_tlinia, 167, 40);
            reg_poliza.campo19 := SUBSTR(v_tlinia, 207, 05);
            reg_poliza.campo20 := SUBSTR(v_tlinia, 212, 01);
            reg_poliza.campo21 := SUBSTR(v_tlinia, 213, 01);
            reg_poliza.campo22 := SUBSTR(v_tlinia, 214, 08);
            reg_poliza.campo23 := SUBSTR(v_tlinia, 222, 10);
            reg_poliza.campo24 := SUBSTR(v_tlinia, 232, 09);
            reg_poliza.campo25 := SUBSTR(v_tlinia, 241, 04);
            reg_poliza.campo26 := SUBSTR(v_tlinia, 245, 05);
            reg_poliza.campo27 := SUBSTR(v_tlinia, 250, 06);
            reg_poliza.campo28 := SUBSTR(v_tlinia, 256, 10);
            reg_poliza.campo29 := SUBSTR(v_tlinia, 266, 02);
            reg_poliza.campo30 := SUBSTR(v_tlinia, 268, 13);
            reg_poliza.campo31 := SUBSTR(v_tlinia, 281, 02);
            reg_poliza.campo32 := SUBSTR(v_tlinia, 283, 02);
            reg_poliza.campo33 := SUBSTR(v_tlinia, 285, 11);
            reg_poliza.campo34 := SUBSTR(v_tlinia, 296, 07);
            reg_poliza.campo35 := SUBSTR(v_tlinia, 303, 08);
            reg_poliza.campo36 := SUBSTR(v_tlinia, 311, 02);
         ELSIF reg_poliza.campo01 = '03' THEN
            v_ntraza := 13;
            reg_poliza.campo02 := SUBSTR(v_tlinia, 003, 02);
            reg_poliza.campo03 := SUBSTR(v_tlinia, 005, 05);
            reg_poliza.campo04 := SUBSTR(v_tlinia, 010, 06);
            reg_poliza.campo05 := SUBSTR(v_tlinia, 016, 10);
            reg_poliza.campo06 := SUBSTR(v_tlinia, 017, 02);
            reg_poliza.campo07 := SUBSTR(v_tlinia, 028, 60);
            reg_poliza.campo08 := SUBSTR(v_tlinia, 088, 08);
            reg_poliza.campo09 := SUBSTR(v_tlinia, 096, 10);
            reg_poliza.campo10 := SUBSTR(v_tlinia, 106, 01);
            reg_poliza.campo11 := SUBSTR(v_tlinia, 107, 01);
            reg_poliza.campo12 := SUBSTR(v_tlinia, 108, 07);
         ELSIF reg_poliza.campo01 = '04' THEN
            v_ntraza := 15;
            reg_poliza.campo02 := SUBSTR(v_tlinia, 003, 02);
            reg_poliza.campo03 := SUBSTR(v_tlinia, 005, 05);
            reg_poliza.campo04 := SUBSTR(v_tlinia, 010, 06);
            reg_poliza.campo05 := SUBSTR(v_tlinia, 016, 10);
            reg_poliza.campo06 := SUBSTR(v_tlinia, 017, 02);
            reg_poliza.campo07 := SUBSTR(v_tlinia, 028, 60);
            reg_poliza.campo08 := SUBSTR(v_tlinia, 088, 08);
            reg_poliza.campo09 := SUBSTR(v_tlinia, 096, 10);
            reg_poliza.campo10 := SUBSTR(v_tlinia, 106, 01);
            reg_poliza.campo11 := SUBSTR(v_tlinia, 107, 01);
         ELSIF reg_poliza.campo01 = '05' THEN
            v_ntraza := 17;
            reg_poliza.campo02 := SUBSTR(v_tlinia, 003, 02);
            reg_poliza.campo03 := SUBSTR(v_tlinia, 005, 05);
            reg_poliza.campo04 := SUBSTR(v_tlinia, 010, 06);
            reg_poliza.campo05 := SUBSTR(v_tlinia, 016, 10);
            reg_poliza.campo06 := SUBSTR(v_tlinia, 026, 02);
            reg_poliza.campo07 := SUBSTR(v_tlinia, 028, 08);
            reg_poliza.campo08 := SUBSTR(v_tlinia, 036, 02);
            reg_poliza.campo09 := SUBSTR(v_tlinia, 038, 13);
            reg_poliza.campo10 := SUBSTR(v_tlinia, 051, 13);
            reg_poliza.campo11 := SUBSTR(v_tlinia, 064, 13);
            reg_poliza.campo12 := SUBSTR(v_tlinia, 077, 01);
            reg_poliza.campo13 := SUBSTR(v_tlinia, 078, 02);

            -- Bug 0015490. FAL. 15/02/2011
            BEGIN
               SELECT TO_NUMBER(SUBSTR(v_tlinia, 96, 1))
                 INTO w_lastdigit
                 FROM DUAL;

               reg_poliza.campo14 := SUBSTR(v_tlinia, 080, 17);
            EXCEPTION
               WHEN OTHERS THEN
                  SELECT SUBSTR(v_tlinia, 96, 1)
                    INTO w_lastdigitchar
                    FROM DUAL;

                  SELECT DECODE(w_lastdigitchar,
                                'J', '1',
                                'K', '2',
                                'L', '3',
                                'M', '4',
                                'N', '5',
                                'O', '6',
                                'P', '7',
                                'Q', '8',
                                'R', '9',
                                '}', '0')
                    INTO w_lastdigitcharv2
                    FROM DUAL;

                  reg_poliza.campo14 := '-' || SUBSTR(v_tlinia, 080, 16) || w_lastdigitcharv2;
            END;

            -- Fi Bug 0015490
            reg_poliza.campo15 := SUBSTR(v_tlinia, 097, 17);
            reg_poliza.campo16 := SUBSTR(v_tlinia, 114, 17);
            reg_poliza.campo17 := SUBSTR(v_tlinia, 131, 40);
            reg_poliza.campo18 := SUBSTR(v_tlinia, 171, 13);
            reg_poliza.campo19 := SUBSTR(v_tlinia, 184, 13);
            reg_poliza.campo20 := SUBSTR(v_tlinia, 249, 05);
            reg_poliza.campo21 := SUBSTR(v_tlinia, 254, 05);
            reg_poliza.campo22 := SUBSTR(v_tlinia, 259, 05);
         ELSIF reg_poliza.campo01 = '06' THEN
            v_ntraza := 19;
            reg_poliza.campo02 := SUBSTR(v_tlinia, 003, 02);
            reg_poliza.campo03 := SUBSTR(v_tlinia, 005, 05);
            reg_poliza.campo04 := SUBSTR(v_tlinia, 010, 06);
            reg_poliza.campo05 := SUBSTR(v_tlinia, 016, 10);
            reg_poliza.campo06 := SUBSTR(v_tlinia, 026, 02);
            reg_poliza.campo07 := SUBSTR(v_tlinia, 028, 17);
            reg_poliza.campo08 := SUBSTR(v_tlinia, 045, 17);
            reg_poliza.campo09 := SUBSTR(v_tlinia, 062, 17);
            reg_poliza.campo10 := SUBSTR(v_tlinia, 079, 13);
            reg_poliza.campo11 := SUBSTR(v_tlinia, 092, 17);
            reg_poliza.campo12 := SUBSTR(v_tlinia, 109, 05);
            reg_poliza.campo13 := SUBSTR(v_tlinia, 114, 01);
         ELSIF reg_poliza.campo01 = '07' THEN
            v_ntraza := 21;
            reg_poliza.campo02 := SUBSTR(v_tlinia, 003, 02);
            reg_poliza.campo03 := SUBSTR(v_tlinia, 005, 05);
            reg_poliza.campo04 := SUBSTR(v_tlinia, 010, 05);
            reg_poliza.campo05 := SUBSTR(v_tlinia, 015, 06);
            reg_poliza.campo06 := SUBSTR(v_tlinia, 021, 17);
            reg_poliza.campo07 := SUBSTR(v_tlinia, 038, 17);
            reg_poliza.campo08 := SUBSTR(v_tlinia, 055, 17);
            reg_poliza.campo09 := SUBSTR(v_tlinia, 077, 17);
            reg_poliza.campo10 := SUBSTR(v_tlinia, 094, 17);
            reg_poliza.campo11 := SUBSTR(v_tlinia, 111, 05);
            reg_poliza.campo12 := SUBSTR(v_tlinia, 116, 01);
         ELSE
            NULL;
         END IF;

         v_ntraza := 23;

         IF reg_poliza.campo01 = 'ID' THEN
            NULL;
         ELSE
            INSERT INTO int_polizas_cnp
                 VALUES reg_poliza
              RETURNING ROWID
                   INTO v_rowid;
         END IF;

         v_ntraza := 25;

         IF MOD(v_nnumlin, 5000) = 0 THEN
            COMMIT;
         END IF;
      END LOOP;

      v_ntraza := 27;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tdeserror := f_axis_literales(103187, vg_nidiomaaxis) || SQLERRM;
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, SQLCODE, SQLERRM);
         UTL_FILE.fclose_all;
   END p_carga;

   /*************************************************************************
             procedimiento que lee el fichero
          param in p_tnombre   : Nombre fichero
          param in p_tpath   : Nuombre path
          param in p_ssproces   : Número proceso
          param in   out p_tdeserror   : mensaje de error
      *************************************************************************/
   PROCEDURE f_lee_fichero(
      p_tnombre IN VARCHAR2,
      p_tpath IN VARCHAR2,
      p_tdeserror OUT VARCHAR2,
      p_ssproces IN NUMBER) IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_CNP.F_LEE_FICHERO';
      v_ntraza       NUMBER := 0;
      v_nnumerr      NUMBER;
      e_object_error EXCEPTION;
      v_cmap         map_cabecera.cmapead%TYPE := NULL;
      --'C0050';   -- Carga planes pensiones CNP
      v_nsec         NUMBER;
   BEGIN
      v_ntraza := 0;
      p_tdeserror := NULL;
      v_ntraza := 1;

      IF p_tnombre IS NULL THEN
         p_tdeserror := f_axis_literales(103835, vg_nidiomaaxis) || ':p_tnombre';
         RAISE e_object_error;
      END IF;

      IF p_tpath IS NULL THEN
         p_tdeserror := f_axis_literales(103835, vg_nidiomaaxis) || ':p_tpath';
         RAISE e_object_error;
      END IF;

      IF p_ssproces IS NULL THEN
         p_tdeserror := f_axis_literales(103835, vg_nidiomaaxis) || ':p_ssproces';
         RAISE e_object_error;
      END IF;

      IF v_cmap IS NOT NULL THEN
         v_ntraza := 2;
         pac_map.p_carga_parametros_fichero(v_cmap, p_ssproces, p_tnombre, 0);
         v_ntraza := 3;
         -- Carga fichero mediante el map.
         v_nnumerr := pac_map.carga_map(v_cmap, v_nsec);

         IF v_nnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         v_ntraza := 4;
         -- Carga fichero directamente desde bbdd
         pac_cargas_cnp.p_carga(p_ssproces, p_tnombre, p_tdeserror);

         IF p_tdeserror IS NOT NULL THEN
            RAISE e_object_error;
         END IF;
      END IF;

      v_ntraza := 8;
      COMMIT;

---------------------------------
-- Validaciones generales fichero y trapaso a las int_ctrl_linea
---------------------------------
      DECLARE
         CURSOR c1(pc_lin IN VARCHAR2) IS
            SELECT   *
                FROM int_polizas_cnp
               WHERE proceso = p_ssproces
                 AND campo01 = pc_lin
            ORDER BY nlinea;

         n_cont         NUMBER;
         n_total        NUMBER;
         n_prod         productos.sproduc%TYPE;
         n_empfic       codiram.cempres%TYPE;
      BEGIN
         -- Cabecera
         n_cont := 0;
         v_ntraza := 81;

         -- Bug 0016324. FAL. 18/10/2010.
         --    FOR reg IN (SELECT ROWID, sinterf   -- Actualizo todas las lineas
         --                  FROM int_polizas_cnp
         --                WHERE sinterf = p_ssproces) LOOP
         --      UPDATE int_polizas_cnp
         --         SET proceso = reg.sinterf
         --       WHERE ROWID = reg.ROWID;
         --   END LOOP;

         -- Fi bug 0016324
         FOR f1 IN c1('01') LOOP
            n_cont := n_cont + 1;
            v_ntraza := 81;

            IF f1.campo10 <> '3081' THEN
               p_tdeserror := f_axis_literales(103187, vg_nidiomaaxis) || ' entidad '
                              || f1.campo10;
               RAISE e_object_error;
            END IF;

            v_ntraza := 82;
            n_prod := pac_cargas_cnp.f_buscavalor('CRT_PRODUCTOCNPPLAN', f1.campo06);
            v_ntraza := 83;

            SELECT MAX(b.cempres)
              INTO n_empfic
              FROM productos a, codiram b
             WHERE a.sproduc = n_prod
               AND b.cramo = a.cramo;

            IF NVL(n_empfic, -1) <> vg_nempresaaxis THEN
               p_tdeserror := f_axis_literales(104485, vg_nidiomaaxis) || ' ' || f1.campo06;
               RAISE e_object_error;
            END IF;
         END LOOP;

         v_ntraza := 84;

         IF n_cont = 0
            OR n_cont > 1 THEN
            p_tdeserror := f_axis_literales(151539, vg_nidiomaaxis) || ' ' || n_cont;
            RAISE e_object_error;
         END IF;

         -- Totales
         n_cont := 0;
         v_ntraza := 85;

         FOR f2 IN c1('07') LOOP
            n_cont := n_cont + 1;
            v_ntraza := 86;

            SELECT COUNT(DISTINCT campo05)
              INTO n_total
              FROM int_polizas_cnp
             WHERE proceso = p_ssproces
               AND campo01 NOT IN('01', '07');

            IF f2.campo04 <> n_total THEN
               p_tdeserror := 'Certificados ' || n_total || ' '
                              || f_axis_literales(1000529, vg_nidiomaaxis) || ' '
                              || f2.campo04;
               -- Bug 0016696. FAL. 18/11/2010. Genera warning si no coinciden nº certificados con linea totales campo04
               -- RAISE e_object_error;
               v_nnumerr :=
                  p_marcalinea
                     (f2.proceso, f2.nlinea, NULL, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      NULL,   -- Fi Bug 14888
                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      f2.ncarga   -- Fi Bug 16324
                               );
               v_nnumerr := p_marcalineaerror(f2.proceso, f2.nlinea, NULL, 2, 109369,
                                              p_tdeserror);
               p_tdeserror := NULL;   -- para que continue
            -- Fi Bug 0016696
            END IF;

            v_ntraza := 87;

            SELECT COUNT(1)
              INTO n_total
              FROM int_polizas_cnp
             WHERE proceso = p_ssproces;

            IF f2.campo05 <> n_total THEN
               p_tdeserror := 'Registros ' || n_total || ' '
                              || f_axis_literales(1000529, vg_nidiomaaxis) || ' '
                              || f2.campo05;
               -- Bug 0016696. FAL. 18/11/2010. Genera warning si no coinciden nº certificados con linea totales campo04
               -- RAISE e_object_error;
               v_nnumerr :=
                  p_marcalinea
                     (f2.proceso, f2.nlinea, NULL, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      NULL,   -- Fi Bug 14888
                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      f2.ncarga   -- Fi Bug 16324
                               );
               v_nnumerr := p_marcalineaerror(f2.proceso, f2.nlinea, NULL, 2, 109369,
                                              p_tdeserror);
               p_tdeserror := NULL;   -- para que continue
            -- Fi Bug 0016696
            END IF;
         END LOOP;

         v_ntraza := 88;

         IF n_cont = 0
            OR n_cont > 1 THEN
            p_tdeserror := f_axis_literales(1000176, vg_nidiomaaxis) || ' totales ' || n_cont;
            RAISE e_object_error;
         END IF;

         FOR f2 IN c1('02') LOOP
            v_nnumerr :=
               p_marcalinea
                  (p_ssproces, f2.nlinea, NULL,   -- v_tipo
                   3, 0, NULL,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   f2.campo05,   -- Fi Bug 14888
                                 -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   f2.ncarga   -- Fi Bug 16324
                            );

            IF v_nnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END LOOP;

         v_ntraza := 89;
      END;
   EXCEPTION
      WHEN e_object_error THEN
         ROLLBACK;
         p_tdeserror := v_ntraza || '-' || p_tdeserror;

         IF p_tdeserror IS NULL THEN
            p_tdeserror := f_axis_literales(108953, vg_nidiomaaxis);
         END IF;

         NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tdeserror := f_axis_literales(103187, vg_nidiomaaxis) || SQLERRM;
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, SQLCODE, SQLERRM);
   END f_lee_fichero;

   /*************************************************************************
                                                         procedimiento que ejecuta una carga (parte1 fichero) Plan Pensiones
          param in p_tnombre   : Nombre fichero
          param in p_tpath   : Nuombre path
          param out p_ssproces   : Número proceso
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutarcarga_ppfic(
      p_tnombre IN VARCHAR2,
      p_tpath IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      p_ssproces OUT NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_CNP.F_EJECUTARCARGA_PPFIC';
      v_ntraza       NUMBER := 0;
      v_nnumerr      NUMBER;
      e_salir        EXCEPTION;
      e_errorini     EXCEPTION;
      --Indica error grabando estados.--Error que para ejecución
      v_nsproces     NUMBER;
      -- v_ncfgproceso  cfg_files.cproceso%TYPE;  -- BUG16130:DRA:15/10/2010
      v_tdeserror    VARCHAR2(1000);
      v_nnumlin      NUMBER;
   BEGIN
      v_ntraza := 0;
      v_nnumerr := f_procesini(f_user, vg_nempresaaxis, 'CARGA_CNP_PP', p_tnombre, v_nsproces);

      IF v_nnumerr <> 0 THEN
         RAISE e_errorini;   --Error que para ejecución
      END IF;

      v_ntraza := 1;

      -- BUG16130:DRA:15/10/2010:Inici
      -- SELECT MAX(cproceso)
      --   INTO v_ncfgproceso
      --   FROM cfg_files
      --  WHERE cempres = vg_nempresaaxis
      --    AND cactivo = 1
      --    AND UPPER(tproceso) = REPLACE(v_tobjeto, 'FIC', '');
      IF p_cproces IS NULL THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, 103778,
                     'cfg_files falta proceso: ' || v_tobjeto);
         v_nnumerr := f_proceslin(v_nsproces,
                                  f_axis_literales(103778, vg_nidiomaaxis) || ': '
                                  || 'cfg_files falta proceso: ' || v_tobjeto,
                                  1, v_nnumlin);
         RAISE e_errorini;   --Error que para ejecución
      END IF;

      -- BUG16130:DRA:15/10/2010:Fi
      p_ssproces := v_nsproces;
      v_nnumerr :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_nsproces, p_tnombre, f_sysdate, NULL,
                                                        3, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        NULL, NULL);
      v_ntraza := 2;

      IF v_nnumerr <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_nnumerr,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         v_nnumerr := f_proceslin(v_nsproces,
                                  f_axis_literales(180856, vg_nidiomaaxis) || ':' || p_tnombre
                                  || ' : ' || v_nnumerr,
                                  1, v_nnumlin);
         RAISE e_errorini;   --Error que para ejecución
      END IF;

      COMMIT;
      v_ntraza := 3;
      f_lee_fichero(p_tnombre, p_tpath, v_tdeserror, v_nsproces);
      v_ntraza := 4;

      IF v_tdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         v_ntraza := 5;
         v_nnumerr :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_nsproces, p_tnombre, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          NULL, v_tdeserror);
         v_ntraza := 51;

         IF v_nnumerr <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_nnumerr,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            v_nnumlin := NULL;
            v_nnumerr := f_proceslin(v_nsproces,
                                     f_axis_literales(180856, vg_nidiomaaxis) || ':'
                                     || p_tnombre || ' : ' || v_nnumerr,
                                     1, v_nnumlin);
            RAISE e_errorini;   --Error que para ejecución
         END IF;

         v_ntraza := 52;
         COMMIT;   --Guardamos la tabla temporal int
         RAISE e_salir;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         NULL;
         RETURN 1;
      WHEN e_errorini THEN   --Error al insertar estados
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza,
                     'Error:' || 'e_errorini' || ' en :' || 1,
                     'Error:' || 'Insertando estados registros');
         v_nnumerr := f_proceslin(v_nsproces,
                                  f_axis_literales(108953, vg_nidiomaaxis) || ':' || p_tnombre
                                  || ' : ' || 'e_errorini',
                                  1, v_nnumlin);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         --coderr := SQLCODE;
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza,
                     'Error:' || SQLERRM || ' en :' || 1, 'Error:' || SQLERRM);
         v_nnumerr := f_proceslin(v_nsproces,
                                  f_axis_literales(103187, vg_nidiomaaxis) || ':' || p_tnombre
                                  || ' : ' || SQLERRM,
                                  1, v_nnumlin);
         v_nnumerr :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_nsproces, p_tnombre, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          151541, SQLERRM);
         v_ntraza := 51;

         IF v_nnumerr <> 0 THEN
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_nnumerr,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            v_nnumlin := NULL;
            v_nnumerr := f_proceslin(v_nsproces,
                                     f_axis_literales(180856, vg_nidiomaaxis) || ':'
                                     || p_tnombre || ' : ' || v_nnumerr,
                                     1, v_nnumlin);
         END IF;

         COMMIT;
         RETURN 1;
   END f_ejecutarcarga_ppfic;

   /*************************************************************************
                      procedimiento que ejecuta una carga Planes de Pensiones
          param in p_nombre   : Nombre fichero
          param in p_path   : Nuombre path
          param in  out psproces   : Número proceso (informado para recargar proceso).
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutarcarga_pp(
      p_tnombre IN VARCHAR2,
      p_tpath IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      p_ssproces IN OUT NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_CARGAS_CNP.F_EJECUTARCARGA_PP';
      v_ntraza       NUMBER := 0;
      v_nnumerr      NUMBER;
      e_salir        EXCEPTION;
      wlinerr        NUMBER := 0;   -- FAL - 07707/2011 - Bug 0019991
   BEGIN
      v_ntraza := 0;

      -- Bug 0016324. FAL. 18/10/2010
      SELECT NVL(cpara_error, 0), NVL(cbusca_host, 0)
        INTO k_para_carga, k_busca_host
        FROM cfg_files
       WHERE cempres = vg_nempresaaxis
         AND cproceso = p_cproces;

      -- Fi Bug 0016324
      IF p_ssproces IS NULL THEN
         v_nnumerr :=
            pac_cargas_cnp.f_ejecutarcarga_ppfic(p_tnombre, p_tpath, p_cproces,   -- BUG16130:DRA:15/10/2010
                                                 p_ssproces);

         IF v_nnumerr <> 0 THEN
            RAISE e_salir;
         END IF;
      END IF;

      v_ntraza := 1;
      v_nnumerr := pac_cargas_cnp.f_ejecutarcarga_pppro(p_ssproces, p_cproces);   -- BUG16130:DRA:15/10/2010

      IF v_nnumerr <> 0 THEN
         RAISE e_salir;
      ELSE
         UPDATE int_carga_ctrl
            SET ffin = f_sysdate
          WHERE sproces = p_ssproces;
      END IF;

      -- FAL - 07/11/2011 - Bug 0019991: marca el proceso como correcto cuando existen lineas erroneas
      wlinerr := 0;

      SELECT COUNT(DISTINCT nlinea)
        INTO wlinerr
        FROM int_carga_ctrl_linea
       WHERE sproces = p_ssproces
         AND cestado = 1;

      IF wlinerr > 0 THEN
         UPDATE int_carga_ctrl
            SET cestado = 1
          WHERE sproces = p_ssproces;

         COMMIT;
      END IF;

      -- Fi Bug 0019991
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         RETURN 1;
   END f_ejecutarcarga_pp;

   -- Bug 0015490. FAL. 15/02/2011
   /*************************************************************************
       procedimiento que ejecuta una carga mediante un job
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 9901606 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      mensajes       t_iax_mensajes;
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CNP.f_ejecutar_carga_job';
      vtraza         NUMBER := 0;
      v_tfichero     VARCHAR2(300) := p_path || '\' || p_nombre;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
   BEGIN
      IF psproces IS NULL THEN
         vmensaje := pac_jobs.f_ejecuta_job(NULL,
                                            'pac_cargas_cnp.p_ejecutar_carga(''' || p_nombre
                                            || ''',''' || p_path || ''',' || p_cproces || ');',
                                            NULL   --, mensajes
                                                );

         IF vmensaje > 0 THEN
            vnum_err :=
               pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero, f_sysdate,
                                                              f_sysdate, 1, p_cproces,
                                                              vmensaje,
                                                              f_axis_literales(vmensaje, 1));

            IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
               vnnumlin := NULL;
               vnum_err := f_proceslin(psproces,
                                       f_axis_literales(180856, vg_nidiomaaxis) || ':'
                                       || v_tfichero || ' : ' || vnum_err,
                                       1, vnnumlin);
               RETURN 1;
            END IF;

            --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vmensaje);
            RETURN 1;
         END IF;

         RETURN 9901606;
      ELSE
         vnum_err := f_ejecutarcarga_pp(p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                        psproces);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   END f_ejecutar_carga_job;

   PROCEDURE p_ejecutar_carga(p_nombre IN VARCHAR2, p_path IN VARCHAR2, p_cproces IN NUMBER) IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_CNP.P_EJECUTAR_CARGA';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      psproces       NUMBER;
      wlinerr        NUMBER := 0;   -- FAL - 07707/2011 - Bug 0019991
   BEGIN
      vnum_err :=
         pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(vg_nempresaaxis,
                                                                     'USER_BBDD'));
      vtraza := 0;

      -- Bug 0016324. FAL. 18/10/2010
      SELECT NVL(cpara_error, 0), NVL(cbusca_host, 0)
        INTO k_para_carga, k_busca_host
        FROM cfg_files
       WHERE cempres = vg_nempresaaxis
         AND cproceso = p_cproces;

      -- Fi Bug 0016324
      IF psproces IS NULL THEN
         vnum_err := pac_cargas_cnp.f_ejecutarcarga_ppfic(p_nombre, p_path, p_cproces,
                                                          psproces);
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_cnp.f_ejecutarcarga_pppro(psproces, p_cproces);

      IF vnum_err = 0 THEN
         UPDATE int_carga_ctrl
            SET ffin = f_sysdate
          WHERE sproces = psproces;

         COMMIT;
      END IF;

      -- FAL - 07/11/2011 - Bug 0019991: marca el proceso como correcto cuando existen lineas erroneas
      wlinerr := 0;

      SELECT COUNT(DISTINCT nlinea)
        INTO wlinerr
        FROM int_carga_ctrl_linea
       WHERE sproces = psproces
         AND cestado = 1;

      IF wlinerr > 0 THEN
         UPDATE int_carga_ctrl
            SET cestado = 1
          WHERE sproces = psproces;

         COMMIT;
      END IF;
   -- Fi Bug 0019991
   END p_ejecutar_carga;
-- Fi Bug 0015490
END pac_cargas_cnp;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_CNP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_CNP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_CNP" TO "PROGRAMADORESCSI";
