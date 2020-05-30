--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS_ALLIANZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS_ALLIANZ" IS
   /******************************************************************************
      NOMBRE:      PAC_CARGAS_ALLIANZ
      PROPÓSITO: Funciones para la gestión de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        07/06/2010   FAL              1. Creación del package.
      2.0        09/06/2010   JMF              2. 0014856: CRT002 - Carga de polizas y recibos ALLIANZ
      3.0        29/06/2010   DRA              3. 0016130: CRT - Error informando el codigo de proceso en carga
      4.0        11/10/2010   FAL              4. 0014888: CRT002 - Carga de polizas,recibos y siniestros Allianz
      5.0        18/10/2010   FAL              5. 0016324: CRT - Configuracion de las cargas
      6.0        29/10/2010   FAL              6. 0016525 CRT002 - Incidencias en cargas (primera carga inicial)
      7.0        27/12/2010   JMP              7. 0017008: GRC - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nº de póliza
      8.0        19/01/2011   ICV              8. 0017155: CRT003 - Informar estado actualizacion compañia
      9.0        02/03/2011   FAL              9. 0017569: CRT - Interfases y gestión personas
     10.0        13/03/2014   AQ              10. 0030186: CRT904-Error el la carga de Allianz por cambio de normativa SEPA
     11.0        24/04/2014   FAL             11. 0027642: RSA102 - Producto Tradicional
   ******************************************************************************/

   /*************************************************************************
         1.0.0.0.0 f_ejecutar_carga
      1.1.0.0.0 ....f_ejecutar_carga_fichero
      1.1.1.0.0 ........f_lee_fichero
      1.2.0.0.0 ....f_ejecutar_carga_proceso
      1.2.1.0.0 ........f_alta_poliza.............(ALTA)
      1.2.2.0.0 ........f_alta_poliza_seg.........(ALTA)
      1.2.3.0.0 ........f_modi_poliza.............(MODI)
      1.2.4.0.0 ........f_baja_poliza.............(BAJA)
      1.0.0.0.0 f_REC_ejecutarcarga
      1.1.0.0.0 ....f_REC_ejecutarcargafichero
      1.1.1.0.0 ........f_REC_leefichero
   *************************************************************************/

   /*************************************************************************
          Procedimiento que guarda logs en las diferentes tablas.
       param p_tabobj in : tab_error tobjeto
       param p_tabtra in : tab_error ntraza
       param p_tabdes in : tab_error tdescrip
       param p_taberr in : tab_error terror
       param p_propro in : PROCESOSLIN sproces
       param p_protxt in : PROCESOSLIN tprolin
       devuelve número o null si existe error.
   *************************************************************************/
   PROCEDURE p_genera_logs(
      p_tabobj IN VARCHAR2,
      p_tabtra IN NUMBER,
      p_tabdes IN VARCHAR2,
      p_taberr IN VARCHAR2,
      p_propro IN NUMBER,
      p_protxt IN VARCHAR2) IS
      vnnumlin       NUMBER;
      vnum_err       NUMBER;
   BEGIN
      IF p_tabobj IS NOT NULL
         AND p_tabtra IS NOT NULL THEN
         p_tab_error(f_sysdate, f_user, p_tabobj, p_tabtra, SUBSTR(p_tabdes, 1, 500),
                     SUBSTR(p_taberr, 1, 2500));
      END IF;

      IF p_propro IS NOT NULL
         AND p_protxt IS NOT NULL THEN
         vnnumlin := NULL;
         vnum_err := f_proceslin(p_propro, SUBSTR(p_protxt, 1, 120), 1, vnnumlin);
      END IF;
   END p_genera_logs;

   /*************************************************************************
             Función que marca linea que tratamos con un estado.
          param p_pro in : proceso
          param p_lin in : linea
          param p_tip in : tipo
          param p_est in : estado
          param p_val in : validado
          param p_seg in : seguro
          devuelve número o null si existe error.
      *************************************************************************/
   FUNCTION p_marcalinea(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_tip IN VARCHAR2,
      p_est IN NUMBER,
      p_val IN NUMBER,
      p_seg IN NUMBER,
      -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
      p_id_ext IN VARCHAR2,
      -- Fi Bug 14888
      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
      p_ncarg IN NUMBER,
      -- Fi Bug 16324
      p_sin IN NUMBER DEFAULT NULL,
      p_tra IN NUMBER DEFAULT NULL,
      p_per IN NUMBER DEFAULT NULL,
      p_rec IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.P_MARCALINEA';
      num_err        NUMBER;
      vtipo          NUMBER;
      num_lin        NUMBER;
      num_aux        NUMBER;
   BEGIN
      IF p_tip = 'ALTA' THEN
         vtipo := 0;
      ELSIF p_tip = 'ALTA_SIN'
            OR p_tip = 'MODI_SIN' THEN
         vtipo := 1;
      ELSIF p_tip = 'ALTA_REC'
            OR p_tip = 'MODI_REC' THEN
         vtipo := 2;
      ELSE
         vtipo := 0;
      END IF;

      num_err :=
         pac_gestion_procesos.f_set_carga_ctrl_linea
               (p_pro, p_lin, vtipo, p_lin, p_tip, p_est, p_val, p_seg,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                p_id_ext,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                p_ncarg,   -- Fi Bug 16324
                p_sin, p_tra, p_per, p_rec);

      IF num_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' t=' || p_tip || ' EST=' || p_est
                       || ' v=' || p_val || ' s=' || p_seg,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' e=' || p_est);
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalinea;

   /*************************************************************************
                                    Función que marca el error de la linea que tratamos.
          param p_pro in : proceso
          param p_lin in : linea
          param p_ner in : numero error
          param p_tip in : tipo
          param p_cod in : codigo
          param p_men in : mensaje
          devuelve número o null si existe error.
      *************************************************************************/
   FUNCTION p_marcalineaerror(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_ner IN NUMBER,
      p_tip IN NUMBER,
      p_cod IN NUMBER,
      p_men IN VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.P_MARCALINEAERROR';
      num_err        NUMBER;
   BEGIN
      num_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_pro, p_lin, p_ner, p_tip,
                                                                   p_cod, p_men);

      IF num_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' n=' || p_ner || ' t=' || p_tip
                       || ' c=' || p_cod || ' m=' || p_men,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' c=' || p_cod);
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalineaerror;

   /*************************************************************************
                                    Función que devuelve una fecha,
          si la conversión de char a fecha es correcta.
          param p_txt    IN  : caracter a convertir
          param p_for    IN  : formato fecha a convertir
          devuelve fecha o null si existe error.
      *************************************************************************/
   FUNCTION converteix_charadate(p_txt IN VARCHAR2, p_for IN VARCHAR2)
      RETURN DATE IS
      d_ret          DATE;
   BEGIN
      BEGIN
         d_ret := TO_DATE(p_txt, p_for);
      EXCEPTION
         WHEN OTHERS THEN
            d_ret := NULL;
      END;

      RETURN d_ret;
   END converteix_charadate;

   /*************************************************************************
             Función que da correspondencia valor de la empresa en la interface con axis.
          param in p_cod : código a buscar
          param in p_emp : código valor de la empresa
          return : código valor de axis
      *************************************************************************/
   FUNCTION f_buscavalor(p_cod IN VARCHAR2, p_emp IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_ret          int_codigos_emp.cvalaxis%TYPE;
   BEGIN
      SELECT MAX(cvalaxis)
        INTO v_ret
        FROM int_codigos_emp
       WHERE cempres = k_empresaaxis
         AND ccodigo = p_cod
         AND cvalemp = p_emp;

      RETURN v_ret;
   END;

   -- Bug 0017569 - FAL - 11/02/2011 - CRT - Interfases y gestión personas
   /*************************************************************************
        Función que da de alta la persona en Host
          param in x : registro tipo int_polizas_ALLIANZ
          param in psinterf: id interfase obtenido en la busqueda persona host
          return : 0 si ha ido bien
    *************************************************************************/
   FUNCTION f_alta_persona_host(
      x IN OUT int_polizas_allianz%ROWTYPE,
      psinterf IN int_mensajes.sinterf%TYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_ALTA_PERSONA_HOST';
      vtraza         NUMBER := 0;
      wsperson       per_personas.sperson%TYPE;
      vcterminal     usuarios.cterminal%TYPE;
      werror         VARCHAR2(2000);
      wsinterf       NUMBER;
      num_err        NUMBER := 0;
      wcont_pers     NUMBER := 0;
      wnnumnif       per_personas.nnumide%TYPE;
      err_busca_pers EXCEPTION;
      err_alta_host  EXCEPTION;
   BEGIN
      wcont_pers := 0;

      SELECT COUNT(*)
        INTO wcont_pers
        FROM int_datos_persona
       WHERE sinterf = psinterf;   -- Buscar si recuperado de host con psinterf de busqueda

      IF wcont_pers = 0 THEN   -- No existe en Host. Se tiene que dar de alta en host.
         wsperson := NULL;

         BEGIN
            SELECT sperson
              INTO wsperson
              FROM per_personas
             WHERE nnumide = x.nif_tomador;
         EXCEPTION
            WHEN OTHERS THEN
               wnnumnif := x.nif_tomador;
               RAISE err_busca_pers;
         END;

         IF wsperson IS NOT NULL THEN
            wsinterf := NULL;
            num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, wsperson,
                                              vcterminal, wsinterf, werror,
                                              pac_md_common.f_get_cxtusuario);

            IF num_err <> 0 THEN
               pterror := werror;
               RAISE err_alta_host;
            END IF;
         END IF;

         IF x.nif_tomador <> x.nif_propietario THEN
            wsperson := NULL;

            BEGIN
               SELECT sperson
                 INTO wsperson
                 FROM per_personas
                WHERE nnumide = x.nif_propietario;
            EXCEPTION
               WHEN OTHERS THEN
                  wnnumnif := x.nif_propietario;
                  RAISE err_busca_pers;
            END;

            IF wsperson IS NOT NULL THEN
               wsinterf := NULL;
               num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, wsperson,
                                                 vcterminal, wsinterf, werror,
                                                 pac_md_common.f_get_cxtusuario);

               IF num_err <> 0 THEN
                  pterror := werror;
                  RAISE err_alta_host;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN err_busca_pers THEN
         pac_cargas_allianz.p_genera_logs
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
         IF werror LIKE '%ORA-00001%' THEN
            -- no genere log por PK violada en mi_posible_cliente
            RETURN 0;
         END IF;

         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error en alta host',
                                          ' Error: ' || werror || '; sinterf: ' || wsinterf
                                          || '; sperson = ' || wsperson || ' (' || x.proceso
                                          || '-' || x.nlinea || ')',
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

   /*************************************************************************
             Función que da de alta póliza en las SEG
          param in x : registro tipo int_polizas_ALLIANZ
          return : 1 si ha habido error
                   2 si ha habido warning
                   4 si ha ido bien
      *************************************************************************/
   FUNCTION f_alta_poliza_seg(
      x IN OUT int_polizas_allianz%ROWTYPE,
      psinterf IN int_mensajes.sinterf%TYPE)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_ALTA_POLIZA_SEG';
      v_i            BOOLEAN := FALSE;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
      verrorgrab     EXCEPTION;
      vtraza         NUMBER := 0;
      vtiperr        NUMBER := NULL;
      vsseguro       NUMBER;
      terror         VARCHAR2(3000);
      warning_alta_host BOOLEAN := FALSE;
      v_cagente      seguros.cagente%TYPE;
      v_fcarnet      DATE;
   BEGIN
      vtraza := 100;
      pac_mig_axis.p_migra_cargas(x.nlinea, 'C', x.ncarga, 'DEL');
      --Cargamos las SEG para la póliza (ncarga)
      vtraza := 110;

      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 200;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         v_i := TRUE;
         vtraza := 201;
         vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 151840, reg.incid);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         vtiperr := 1;
      END LOOP;

      IF NOT v_i THEN
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = x.ncarga
                        AND tipo = 'W') LOOP   --Miramos si han habido warnings.
            vtraza := 202;

            BEGIN
               SELECT sseguro
                 INTO vsseguro
                 FROM mig_seguros
                WHERE ncarga = x.ncarga;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --JRH IMP de momento
            END;

            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 2, 1, vsseguro,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza,   -- Fi Bug 14888
                               -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga   -- Fi Bug 16324
                           );

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;

            vtraza := 203;
            vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, reg.incid);

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;

            -- Fi Bug 0017569
            v_i := TRUE;
         END LOOP;

         vtiperr := 2;
      END IF;

      IF NOT v_i THEN
         --Esto quiere decir que no ha habido ningún error (lo indicamos también).
         vtraza := 204;

         BEGIN
            SELECT sseguro
              INTO vsseguro
              FROM mig_seguros
             WHERE ncarga = x.ncarga;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --JRH IMP de momento
         END;

         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, vsseguro,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
         vnum_err := f_alta_persona_host(x, psinterf, terror);

         IF vnum_err <> 0 THEN
            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 2, 1, vsseguro,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza,   -- Fi Bug 14888
                               -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga   -- Fi Bug 16324
                           );

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;

            vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, terror);

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;
         END IF;

         -- Fi Bug 0017569
         vtiperr := 4;
      END IF;

--
-- Doy de alta los carnets
      BEGIN
         SELECT cagente
           INTO v_cagente
           FROM seguros
          WHERE sseguro = vsseguro;
      EXCEPTION
         WHEN OTHERS THEN
            v_cagente := k_agente;
      END;

      FOR reg_per IN (SELECT sperson, nnumide
                        FROM per_personas
                       WHERE nnumide IN(x.nif_tomador, x.nif_propietario)) LOOP
         BEGIN
            -- buscamos el tipo de carnet si no encontramos podemos por defecto el b1
            IF reg_per.nnumide = x.nif_tomador THEN
               v_fcarnet := TO_DATE(x.fh_carnet_tomador, 'DD/MM/YYYY');
            ELSE
               v_fcarnet := TO_DATE(x.fh_carnet_propietario, 'DD/MM/YYYY');
            END IF;

            INSERT INTO per_autcarnet
                        (sperson, cagente, ctipcar, fcarnet, cdefecto)
                 VALUES (reg_per.sperson, ff_agente_cpervisio(v_cagente), 99, v_fcarnet, 0);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;   -- ya tenemos el carnet
            WHEN OTHERS THEN
               pac_cargas_allianz.p_genera_logs(vobj, vtraza, SQLCODE,
                                                'Error insertado carnets ' || x.poliza,
                                                x.proceso,
                                                'Error insertado carnets ' || x.poliza);
         END;
      END LOOP;

-- FIN CARNETS
      IF vtiperr IN(4, 2) THEN
         BEGIN
            UPDATE seguros
               SET cpolcia = x.poliza
             WHERE sseguro = vsseguro;
         EXCEPTION
            WHEN OTHERS THEN
               pac_cargas_allianz.p_genera_logs(vobj, vtraza, SQLCODE,
                                                'Error al guardar cpolcia ' || x.poliza,
                                                x.proceso,
                                                'Error al guardar cpolcia ' || x.poliza);
         END;
      END IF;

      RETURN vtiperr;   --Devolvemos el tipo error que ha habido
   EXCEPTION
      WHEN verrorgrab THEN
         RETURN 10;
      WHEN OTHERS THEN
         RETURN 10;
   END f_alta_poliza_seg;

   /***************************************************************************
                           FUNCTION f_next_carga
      Asigna número de carga
         return         : Número de carga
   ***************************************************************************/
   FUNCTION f_next_carga
      RETURN NUMBER IS
      v_seq          NUMBER;
   BEGIN
      SELECT sncarga.NEXTVAL
        INTO v_seq
        FROM DUAL;

      RETURN v_seq;
   END f_next_carga;

   /***************************************************************************
         FUNCTION f_ins_mig_logs_emp
      Inserta registro en la tabla de logs de las cargas de las tablas APRA a
      tablas MIG
         param in pncarga : número de carga
         param in pmig_pk : valor primary key del registro de APRA
         param in ptipo   : tipo log (E=error, I=Información, W-Warning)
         param in ptexto  : Texto log
         return           : código error
   ***************************************************************************/
   FUNCTION f_ins_mig_logs_emp(
      pncarga IN NUMBER,
      pmig_pk IN VARCHAR2,
      ptipo IN VARCHAR2,
      ptexto IN VARCHAR2,
      pseq OUT NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      SELECT sseqlogmig.NEXTVAL
        INTO pseq
        FROM DUAL;

      INSERT INTO mig_logs_emp
                  (ncarga, seqlog, fecha, mig_pk, tipo, incid)
           VALUES (pncarga, pseq, f_sysdate, pmig_pk, ptipo, ptexto);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_ins_mig_logs_emp;

   -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
   /*************************************************************************
    Funcion que recupera la persona en Host
        param in x: registro tratado tipo int_polizas_allianz
        param in p_tomador: indica si hay q recuperar el tomador o el propietario: tomador(0), propietario(1)
        param out reg_datos_pers: registro datos persona Host
        param out reg_datos_dir: registro datos direccion Host
        param out reg_datos_contac: registro datos contacto Host
        param out reg_datos_cc: registro datos cuenta Host
        return : 0 si ha ido bien
    *************************************************************************/
   FUNCTION f_busca_person_host(
      x IN int_polizas_allianz%ROWTYPE,
      p_tomador IN NUMBER,
      reg_datos_pers OUT int_datos_persona%ROWTYPE,
      reg_datos_dir OUT int_datos_direccion%ROWTYPE,
      reg_datos_contac OUT int_datos_contacto%ROWTYPE,
      reg_datos_cc OUT int_datos_cuenta%ROWTYPE,
      psinterf IN OUT int_mensajes.sinterf%TYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_BUSCA_PERSON_HOST';
      vtraza         NUMBER := 0;
      num_err        NUMBER;
      vcterminal     usuarios.cterminal%TYPE;
      werror         VARCHAR2(2000);
      womasdatos     NUMBER;
      pmasdatos      NUMBER;
      wcont_pers     NUMBER;
      wsperson       per_personas.sperson%TYPE;
      wnnunnif       int_polizas_allianz.nif_tomador%TYPE;
      err_busca_pers_host EXCEPTION;
   BEGIN
      psinterf := NULL;
      num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF p_tomador = 0 THEN   -- recuperar persona tomador en host
         wnnunnif := x.nif_tomador;
      ELSE   -- recuperar persona propietario en host
         wnnunnif := x.nif_propietario;
      END IF;

      num_err :=
         pac_con.f_busqueda_persona(pac_md_common.f_get_cxtempresa,   -- pempresa IN NUMBER,
                                    NULL,   -- x.nif_tomador,   -- psip IN VARCHAR2,
                                    NULL,   --v_mig_personas.ctipide,   -- pctipdoc IN NUMBER,
                                    wnnunnif,   -- ptdocidentif IN VARCHAR2,
                                    NULL,   --x.nom_tomador,   -- ptnombre IN VARCHAR2,
                                    vcterminal,   -- pterminal IN VARCHAR2,
                                    pmasdatos,   -- pmasdatos IN NUMBER,
                                    womasdatos,   -- pomasdatos OUT NUMBER,
                                    psinterf,   -- psinterf IN OUT NUMBER,
                                    werror, NULL,   -- pcognom1 IN VARCHAR2 DEFAULT NULL,
                                    NULL,   -- pcognom2 IN VARCHAR2 DEFAULT NULL,
                                    pac_md_common.f_get_cxtusuario);   -- pusuario IN VARCHAR2

      IF num_err <> 0 THEN
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error al buscar persona en host',
                                          'Error: ' || werror || ';sinterf = ' || psinterf
                                          || '; nif = ' || wnnunnif || ' (' || x.proceso
                                          || '-' || x.nlinea || ')',
                                          x.proceso,
                                          'Error al buscar persona en host: ' || werror
                                          || '; nif = ' || wnnunnif || ' (' || x.proceso
                                          || '-' || x.nlinea || ')');
         pterror := werror;
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
            p_tab_error(f_sysdate, f_user, 'f_busca_person_host', 666,
                        'recuperado de host. nif: ' || wnnunnif || ' - (' || x.proceso || '-'
                        || x.nlinea || ')',
                        'reg_datos_pers. sip-tdocidentif-csexo-fnacimi-ctipdoc-sinterf: '
                        || reg_datos_pers.sip || '-' || reg_datos_pers.tdocidentif || '-'
                        || reg_datos_pers.csexo || '-' || reg_datos_pers.fnacimi || '-'
                        || reg_datos_pers.ctipdoc || '-' || reg_datos_pers.sinterf);
*/
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
/*
               p_tab_error(f_sysdate, f_user, 'duplicado f_BUSCA_person_host', 666,
                           'DUPLICADO. nif: ' || wnnunnif || ' -sinterf: ' || psinterf,
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
                           'recuperado de host. nif: ' || wnnunnif || ' - (' || x.proceso
                           || '-' || x.nlinea || ')',
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

      RETURN 0;
   EXCEPTION
      WHEN err_busca_pers_host THEN
--         p_tab_error(f_sysdate, f_user, 'f_busca_person_host', 666,
--                     'no encuentra persona en host. nif: ' || wnnunnif || ' -sinterf: '
--                     || psinterf,
--                     '(' || x.proceso || '-' || x.nlinea || ')');
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'No encuentra persona en host',
                                          'sinterf = ' || psinterf || '; nif = ' || wnnunnif
                                          || ' (' || x.proceso || '-' || x.nlinea || ')',
                                          x.proceso,
                                          'No encuentra persona en host' || ';sinterf = '
                                          || psinterf || '; nif = ' || wnnunnif || ' ('
                                          || x.proceso || '-' || x.nlinea || ')');
             --num_err := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL,x.poliza, x.ncarga);
--             num_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145,
--                                  'Error recuperando persona de Host. nif: '
--                                  || wnnunnif || ' - sinterf: ' || psinterf || ' - ('
--                                  || x.proceso || '-' || x.nlinea || ')');
         RETURN 0;
      WHEN OTHERS THEN
         pac_cargas_allianz.p_genera_logs(vobj, vtraza,
                                          'Error no controlado al buscar persona en Host'
                                          || SQLERRM,
                                          'sinterf = ' || psinterf || '; nif = ' || wnnunnif
                                          || ' (' || x.proceso || '-' || x.nlinea || ')',
                                          x.proceso,
                                          'Error no controlado' || SQLERRM || ';sinterf = '
                                          || psinterf || '; nif = ' || wnnunnif || ' ('
                                          || x.proceso || '-' || x.nlinea || ')');
         pterror := 'Error no controlado al buscar persona en Host' || SQLERRM;
         RETURN 1;
   END f_busca_person_host;

   -- Fi Bug 17569

   /*************************************************************************
             procedimiento que da de alta póliza en las mig
          param in x : registro tipo INT_POLIZAS_ALLIANZ
      *************************************************************************/
   FUNCTION f_alta_poliza(
      x IN OUT int_polizas_allianz%ROWTYPE,
      pterror IN OUT VARCHAR2,
      psinterf OUT int_mensajes.sinterf%TYPE)
      -- Bug 0016324. FAL. 26/10/2010. Añadimos desc. error OUT para asignarle sqlerrm cuando sale por when others (normalmente registra errores sobre las tablas mig)
   RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_ALTA_POLIZA';
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      errdatos       EXCEPTION;
      codpostal_no_def EXCEPTION;
      --Tablas nivel póliza
      v_mig_personas mig_personas%ROWTYPE;
      v_mig_personas2 mig_personas%ROWTYPE;
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_movseg   mig_movseguro%ROWTYPE;
      ------      v_mig_agensegu mig_agensegu%ROWTYPE;
      v_mig_ase      mig_asegurados%ROWTYPE;
      v_mig_rie      mig_riesgos%ROWTYPE;
      v_mig_ren_aho  mig_seguros_ren_aho%ROWTYPE;
      v_mig_cla      mig_clausuesp%ROWTYPE;
      v_mig_pre      mig_pregunseg%ROWTYPE;
      v_mig_gar      mig_garanseg%ROWTYPE;
      v_mig_pre      mig_pregungaranseg%ROWTYPE;
      v_mig_pregunseg mig_pregunseg%ROWTYPE;
      vcdomici       NUMBER;
      vcdomici_aseg  NUMBER;
      verror         VARCHAR2(1000);
      cerror         VARCHAR2(1000);
      vpersonas      NUMBER;
      var_productos  productos%ROWTYPE;
      vtraza         NUMBER;
      linea          NUMBER := 0;
      v_warning      BOOLEAN := FALSE;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_rowid_ini    ROWID;
      pid            VARCHAR2(200);
      v_mig_benef    mig_clausuesp%ROWTYPE;
      vagente        NUMBER := 1;   --JRH IMP
      v_mig_seg_ulk  mig_seguros_ulk%ROWTYPE;
      b_warning      BOOLEAN;
      waux           NUMBER;
      w_asig_primera_gar BOOLEAN;
      -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
      num_err        NUMBER;
      reg_dat_pers   int_datos_persona%ROWTYPE;
      reg_dat_dir    int_datos_direccion%ROWTYPE;
      reg_dat_contac int_datos_contacto%ROWTYPE;
      reg_dat_cc     int_datos_cuenta%ROWTYPE;
   -- Fi Bug 17569
   BEGIN
      vtraza := 1000;
      cerror := 0;
      pid := x.nlinea;
      b_warning := FALSE;
      vtraza := 1005;

      SELECT ROWID
        INTO v_rowid_ini
        FROM int_polizas_allianz
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      --Inicializamos la cabecera de la carga
      vtraza := 1010;
      v_ncarga := f_next_carga;
      x.ncarga := v_ncarga;
      -- Bug 0016324. FAL. 26/10/2010. Asignamos v_ncarga antes de posible error para registrarlo en la linea de carga
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Pólizas', v_seq);
      vtraza := 1015;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, pid, 'OK');

      vtraza := 1020;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_ALLIANZ', 'MIG_PERSONAS', 0);

      vtraza := 1025;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_ALLIANZ', 'MIG_SEGUROS', 1);

      vtraza := 1030;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_ALLIANZ', 'MIG_MOVSEGURO', 2);

      vtraza := 1035;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_ALLIANZ', 'MIG_AGENSEGU', 4);

      --UPDATE mig_logs_emp --JRH IMP
      --  SET ncarga = v_ncarga
      --  WHERE ncarga = 0
      --   AND seqlog = v_seq;
      vtraza := 1040;
      v_mig_personas.ncarga := v_ncarga;
      v_mig_personas.cestmig := 1;

      IF x.nif_tomador IS NULL THEN
         verror := 'Error en identificador';
         cerror := 110888;
         RAISE errdatos;
      END IF;

      -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
      -- Buscar persona tomador en Host
      reg_dat_pers := NULL;
      reg_dat_dir := NULL;
      reg_dat_contac := NULL;
      reg_dat_cc := NULL;
      num_err := f_busca_person_host(x, 0, reg_dat_pers, reg_dat_dir, reg_dat_contac,
                                     reg_dat_cc, psinterf, pterror);

      IF num_err <> 0
         AND pterror IS NOT NULL THEN
         SELECT sseqlogmig2.NEXTVAL
           INTO v_seq
           FROM DUAL;

         INSERT INTO mig_logs_axis
                     (ncarga, seqlog, fecha, mig_pk, tipo,
                      incid)
              VALUES (v_ncarga, v_seq, f_sysdate, v_ncarga || '/' || x.poliza, 'W',
                      'Busqueda persona en Host: ' || pterror);
      END IF;

      -- Fi Bug 0017569
      vtraza := 1045;
      v_mig_personas.mig_pk := v_ncarga || '/' || x.nif_tomador;
      v_mig_personas.idperson := 0;
      v_mig_personas.snip := x.nif_tomador;
      vtraza := 1050;

      BEGIN
         SELECT TO_NUMBER(SUBSTR(x.nif_tomador, 1, 1))
           INTO waux
           FROM DUAL;

         v_mig_personas.ctipide := 1;
      EXCEPTION
         WHEN OTHERS THEN
            IF SUBSTR(x.nif_tomador, 1, 1) = 'X' THEN
               v_mig_personas.ctipide := 8;
            ELSE
               v_mig_personas.ctipide := 2;
            END IF;
      END;

      v_mig_personas.ctipide := NVL(reg_dat_pers.ctipdoc, v_mig_personas.ctipide);
      -- Bug 0017569
      --v_mig_personas.ctipide := 27;   -- NIF carga fichero (detvalor 672).
      v_mig_personas.nnumide := x.nif_tomador;
      v_mig_personas.cestper := 0;
      v_mig_personas.cpertip := NVL(reg_dat_pers.ctipper, 1);
      v_mig_personas.swpubli := 0;
      vtraza := 1055;
      --IF x.sexo IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      --v_mig_personas.csexper := x.sexo;
      v_mig_personas.csexper := NVL(reg_dat_pers.csexo, NULL);   -- Bug 0017569
      vtraza := 1060;

      --IF x.fecnac IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      IF x.fh_nacimiento_tomador IS NOT NULL THEN
         --v_mig_personas.fnacimi := TO_DATE(x.fh_nacimiento_tomador, 'dd/mm/yyyy');
         v_mig_personas.fnacimi := NVL(TO_CHAR(TO_DATE(reg_dat_pers.fnacimi, 'yyyy-mm-dd'),
                                               'dd/mm/yyyy'),
                                       TO_DATE(x.fh_nacimiento_tomador, 'dd/mm/yyyy'));
      -- Bug 0017569
      ELSE
         v_mig_personas.fnacimi := NVL(TO_CHAR(TO_DATE(reg_dat_pers.fnacimi, 'yyyy-mm-dd'),
                                               'dd/mm/yyyy'),
                                       NULL);
      END IF;

      vtraza := 1065;

      IF x.cod_banco = 3081 THEN
         --v_mig_personas.cagente :=
         v_mig_personas.cagente := NVL(ff_agente_cpervisio(x.ofic_banco), k_agente);
         v_mig_seg.cagente := x.ofic_banco;
      ELSE
         --v_mig_personas.cagente := 9999;
         v_mig_personas.cagente := k_agente;
         v_mig_seg.cagente := k_agente;
      END IF;

      v_mig_personas.cagente := NVL(reg_dat_pers.cagente, v_mig_personas.cagente);
      -- Bug 0017569
      v_mig_seg.cagente := NVL(reg_dat_pers.cagente, v_mig_seg.cagente);   -- Bug 0017569
      vtraza := 1070;

      IF x.nom_tomador IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Nombre tomador',
                       'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                       x.proceso,
                       'Nombre tomador Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                       || ')');
         x.nom_tomador := ' ';
      END IF;

      vtraza := 1075;
      --IF x.nombre IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      vtraza := 1080;
      v_mig_personas.tapelli1 := NVL(reg_dat_pers.tapelli1, x.nom_tomador);   -- Bug 0017569
      v_mig_personas.tapelli2 := NVL(reg_dat_pers.tapelli2, NULL);   -- Bug 0017569
      v_mig_personas.tnombre := NVL(reg_dat_pers.tnombre, NULL);   -- Bug 0017569
      -- Direccion Particular
      v_mig_personas.ctipdir := NVL(reg_dat_dir.ctipdir, 1);   -- Bug 0017569
      v_mig_personas.tnomvia := NVL(reg_dat_dir.tnomvia, x.dom_tomador);   -- Bug 0017569
      v_mig_personas.nnumvia := NVL(reg_dat_dir.nnumvia, NULL);   -- Bug 0017569
      v_mig_personas.tcomple := NULL;
      v_mig_personas.cpais := NVL(reg_dat_pers.cpais, k_paisdefaxis);   -- Bug 0017569
      v_mig_personas.cnacio := NVL(reg_dat_pers.cnacioni, k_paisdefaxis);   -- Bug 0017569
      vtraza := 1085;

      IF x.cpostal_tomador IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Código postal',
                       'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                       x.proceso,
                       'Código postal Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                       || ')');
         v_mig_personas.cpostal := NULL;
      ELSE
         v_mig_personas.cpostal := LPAD(x.cpostal_tomador, 5, '0');
      END IF;

      v_mig_personas.cpostal := NVL(reg_dat_dir.cpostal, v_mig_personas.cpostal);
      -- Bug 0017569
      vtraza := 1090;
      --IF x.provin IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      --BEGIN
      --   SELECT cprovin
      --     INTO v_mig_personas.cprovin
      --     FROM provincias
      --    WHERE cpais = v_mig_personas.cpais
      --      AND UPPER(tprovin) = UPPER(x.provin);
      --EXCEPTION
      --   WHEN OTHERS THEN
      --      RAISE errdatos;
      --END;
      vtraza := 1095;

      IF x.localidad_tomador IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'localidad',
                       'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                       x.proceso,
                       'localidad Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')');
         v_mig_personas.cprovin := NULL;
         v_mig_personas.cpoblac := NULL;
      ELSE
         DECLARE
            v_localidad    VARCHAR2(200);

            CURSOR c1 IS
               SELECT DISTINCT b.cprovin, b.cpoblac
                          FROM codpostal c, poblaciones b, provincias a
                         WHERE a.cpais = v_mig_personas.cpais
                           AND b.cprovin = a.cprovin
                           AND(UPPER(b.tpoblac) LIKE UPPER(v_localidad))
                           AND c.cpostal = LPAD(x.cpostal_tomador, 5, '0')
                           AND c.cprovin = a.cprovin
                           AND c.cpoblac = b.cpoblac
                      ORDER BY 1, 2;
         BEGIN
            vtraza := 1100;
            v_localidad := RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.localidad_tomador), 'ÁÉÍÓÚ',
                                                       'AEIOU'))),
                                 '.');
            vtraza := 1105;

            OPEN c1;

            FETCH c1
             INTO v_mig_personas.cprovin, v_mig_personas.cpoblac;

            IF c1%NOTFOUND THEN
               CLOSE c1;

               BEGIN
                  SELECT DISTINCT cprovin
                             INTO v_mig_personas.cprovin
                             FROM codpostal
                            WHERE cpostal = LPAD(x.cpostal_tomador, 5, '0');

                  vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                               v_mig_personas.cprovin,
                                                               LPAD(x.cpostal_tomador, 5, '0'),
                                                               v_mig_personas.cpoblac);

                  IF vnum_err <> 0 THEN
                     b_warning := TRUE;
                     p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                   'no definido ' || ' (' || x.proceso || '-' || x.nlinea
                                   || '-' || x.localidad_tomador || '-' || x.cpostal_tomador
                                   || ')',
                                   x.proceso,
                                   'localidad cod_postal no definido ' || ' (' || x.proceso
                                   || '-' || x.nlinea || '-' || x.localidad_tomador || '-'
                                   || x.cpostal_tomador || ')');
                     v_mig_personas.cprovin := NULL;
                     v_mig_personas.cpoblac := NULL;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     BEGIN
                        SELECT SUBSTR(LPAD(x.cpostal_tomador, 5, '0'), 1, 2)
                          INTO v_mig_personas.cprovin
                          FROM DUAL;

                        vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                                     v_mig_personas.cprovin,
                                                                     LPAD(x.cpostal_tomador, 5,
                                                                          '0'),
                                                                     v_mig_personas.cpoblac);

                        IF vnum_err <> 0 THEN
                           b_warning := TRUE;
                           p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                         'no definido ' || ' (' || x.proceso || '-'
                                         || x.nlinea || '-' || x.localidad_tomador || '-'
                                         || x.cpostal_tomador || ')',
                                         x.proceso,
                                         'localidad cod_postal no definido ' || ' ('
                                         || x.proceso || '-' || x.nlinea || '-'
                                         || x.localidad_tomador || '-' || x.cpostal_tomador
                                         || ')');
                           v_mig_personas.cprovin := NULL;
                           v_mig_personas.cpoblac := NULL;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           b_warning := TRUE;
                           p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                         'no definido ' || ' (' || x.proceso || '-'
                                         || x.nlinea || '-' || x.localidad_tomador || '-'
                                         || x.cpostal_tomador || ')',
                                         x.proceso,
                                         'localidad cod_postal no definido ' || ' ('
                                         || x.proceso || '-' || x.nlinea || '-'
                                         || x.localidad_tomador || '-' || x.cpostal_tomador
                                         || ')');
                           v_mig_personas.cprovin := NULL;
                           v_mig_personas.cpoblac := NULL;
                     END;
               END;
            ELSE
               CLOSE c1;
            END IF;
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona la EXCEPTION
         EXCEPTION
            WHEN OTHERS THEN
               IF c1%ISOPEN THEN
                  CLOSE c1;
               END IF;
         END;
      END IF;

      v_mig_personas.cprovin := NVL(reg_dat_dir.cprovin, v_mig_personas.cprovin);
      -- Bug 0017569
      v_mig_personas.cpoblac := NVL(reg_dat_dir.cpoblac, v_mig_personas.cpoblac);
      -- Bug 0017569
      vtraza := 1110;
      --IF x.oficina IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      v_mig_personas.cidioma := NVL(reg_dat_pers.cidioma, k_idiomaaaxis);   -- Bug 0017569
      -- ini Bug 0014185 - JMF - 25/05/2010
      --Segundo Identificador
      --IF x.nif_partic IS NOT NULL THEN
      --   v_mig_personas.ctipide2 := 16;   -- NIF Empresa mare Angola
      --   v_mig_personas.nnumide2 := x.nif_partic;
      --END IF;
      -- fin Bug 0014185 - JMF - 25/05/2010

      -- ini Bug 0014185 - JMF - 25/05/2010
      -- Telefono contacto
      vtraza := 1115;

      IF x.tlf_tomador IS NOT NULL THEN
         v_mig_personas.tnumtel := x.tlf_tomador;
      END IF;

      IF reg_dat_contac.ctipcon = 1 THEN
         v_mig_personas.tnumtel := NVL(reg_dat_contac.tvalcon, v_mig_personas.tnumtel);
      -- Bug 0017569
      END IF;

      -- Telefono movil
      --IF x.telmovil2 IS NOT NULL THEN
      --   v_mig_personas.tnummov := x.telmovil2;
      --v_mig_personas.tnumfax := x.TELMOVIL2;
      --END IF;
      -- fin Bug 0014185 - JMF - 25/05/2010
      vtraza := 1120;

      INSERT INTO mig_personas
           VALUES v_mig_personas
        RETURNING ROWID
             INTO v_rowid;

      vtraza := 1125;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 0, v_mig_personas.mig_pk);

      -- FAL. Si tomador <> propietario -> insertar como asegurado. 1º insertar como persona
      IF x.nif_tomador <> x.nif_propietario THEN
         v_mig_personas2.ncarga := v_ncarga;
         v_mig_personas2.cestmig := 1;

         IF x.nif_propietario IS NULL THEN
            verror := 'Error en identificador';
            cerror := 110888;
            RAISE errdatos;
         END IF;

         -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
         -- Buscar persona propietario en Host
         reg_dat_pers := NULL;
         reg_dat_dir := NULL;
         reg_dat_contac := NULL;
         reg_dat_cc := NULL;
         num_err := f_busca_person_host(x, 1, reg_dat_pers, reg_dat_dir, reg_dat_contac,
                                        reg_dat_cc, psinterf, pterror);

         IF num_err <> 0
            AND pterror IS NOT NULL THEN
            SELECT sseqlogmig2.NEXTVAL
              INTO v_seq
              FROM DUAL;

            INSERT INTO mig_logs_axis
                        (ncarga, seqlog, fecha, mig_pk, tipo,
                         incid)
                 VALUES (v_ncarga, v_seq, f_sysdate, v_ncarga || '/' || x.poliza, 'W',
                         'Busqueda persona en Host: ' || pterror);
         END IF;

         -- Fi Bug 0017569
         v_mig_personas2.mig_pk := v_ncarga || '/' || x.nif_propietario;
         v_mig_personas2.idperson := 0;
         v_mig_personas2.snip := x.nif_propietario;

         BEGIN
            SELECT TO_NUMBER(SUBSTR(x.nif_propietario, 1, 1))
              INTO waux
              FROM DUAL;

            v_mig_personas2.ctipide := 1;
         EXCEPTION
            WHEN OTHERS THEN
               IF SUBSTR(x.nif_propietario, 1, 1) = 'X' THEN
                  v_mig_personas2.ctipide := 8;
               ELSE
                  v_mig_personas2.ctipide := 2;
               END IF;
         END;

         v_mig_personas2.ctipide := NVL(reg_dat_pers.ctipdoc, v_mig_personas2.ctipide);
         -- Bug 0017569
            --v_mig_personas2.ctipide := 27;   -- NIF carga fichero (detvalor 672).
         v_mig_personas2.nnumide := x.nif_propietario;
         v_mig_personas2.cestper := 0;
         v_mig_personas2.cpertip := NVL(reg_dat_pers.ctipper, 1);
         v_mig_personas2.swpubli := 0;
         --IF x.sexo IS NULL THEN
         --   RAISE errdatos;
         --END IF;
         --v_mig_personas2.csexper := x.sexo;
         v_mig_personas2.csexper := NVL(reg_dat_pers.csexo, NULL);   -- Bug 0017569

         --IF x.fecnac IS NULL THEN
         --   RAISE errdatos;
         --END IF;
         IF x.fh_nacimiento_propietario IS NOT NULL THEN
            v_mig_personas2.fnacimi := NVL(TO_CHAR(TO_DATE(reg_dat_pers.fnacimi, 'yyyy-mm-dd'),
                                                   'dd/mm/yyyy'),
                                           TO_DATE(x.fh_nacimiento_propietario, 'dd/mm/yyyy'));
         -- Bug 0017569
         ELSE
            v_mig_personas2.fnacimi := NVL(TO_CHAR(TO_DATE(reg_dat_pers.fnacimi, 'yyyy-mm-dd'),
                                                   'dd/mm/yyyy'),
                                           NULL);   -- Bug 0017569
         END IF;

         IF x.cod_banco = 3081 THEN
            --v_mig_personas2.cagente := x.OFIC_BANCO
            v_mig_personas2.cagente := NVL(ff_agente_cpervisio(x.ofic_banco), k_agente);
         ELSE
            --v_mig_personas2.cagente := 9999;
            v_mig_personas2.cagente := k_agente;
         END IF;

         v_mig_personas2.cagente := NVL(reg_dat_pers.cagente, v_mig_personas2.cagente);

         -- Bug 0017569
         IF x.nom_propietario IS NULL THEN
            b_warning := TRUE;
            p_genera_logs(vobj, vtraza, 'Nombre asegurado',
                          'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                          x.proceso,
                          'Nombre asegurado Campo vacio ' || ' (' || x.proceso || '-'
                          || x.nlinea || ')');
            x.nom_propietario := ' ';
         END IF;

         --IF x.nombre IS NULL THEN
         --   RAISE errdatos;
         --END IF;
         v_mig_personas2.tapelli1 := NVL(reg_dat_pers.tapelli1, x.nom_propietario);
         -- Bug 0017569
         v_mig_personas2.tapelli2 := NVL(reg_dat_pers.tapelli2, NULL);   -- Bug 0017569
         v_mig_personas2.tnombre := NVL(reg_dat_pers.tnombre, NULL);   -- Bug 0017569
         -- Direccion Particular
         v_mig_personas2.ctipdir := NVL(reg_dat_dir.ctipdir, 1);   -- Bug 0017569
         v_mig_personas2.tnomvia := NVL(reg_dat_dir.tnomvia, x.dom_propietario);
         -- Bug 0017569
         v_mig_personas2.nnumvia := NVL(reg_dat_dir.nnumvia, NULL);   -- Bug 0017569
         v_mig_personas2.tcomple := NULL;
         v_mig_personas2.cpais := NVL(reg_dat_pers.cpais, k_paisdefaxis);   -- Bug 0017569
         v_mig_personas2.cnacio := NVL(reg_dat_pers.cnacioni, k_paisdefaxis);   -- Bug 0017569

         IF x.cpostal_propietario IS NULL THEN
            b_warning := TRUE;
            p_genera_logs(vobj, vtraza, 'Código postal',
                          'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                          x.proceso,
                          'Código postal Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                          || ')');
            v_mig_personas2.cpostal := NULL;
         ELSE
            v_mig_personas2.cpostal := LPAD(x.cpostal_propietario, 5, '0');
         END IF;

         v_mig_personas2.cpostal := NVL(reg_dat_dir.cpostal, v_mig_personas2.cpostal);

         -- Bug 0017569
         IF x.localidad_propietario IS NULL THEN
            b_warning := TRUE;
            p_genera_logs(vobj, vtraza, 'localidad',
                          'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                          x.proceso,
                          'localidad Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                          || ')');
            v_mig_personas2.cprovin := NULL;
            v_mig_personas2.cpoblac := NULL;
         ELSE
            DECLARE
               v_localidad_aseg VARCHAR2(200);

               CURSOR c1 IS
                  SELECT DISTINCT b.cprovin, b.cpoblac   -- pac_cargas_asefa
                             FROM codpostal c, poblaciones b, provincias a
                            WHERE a.cpais = v_mig_personas2.cpais
                              AND b.cprovin = a.cprovin
                              AND(UPPER(b.tpoblac) LIKE UPPER(v_localidad_aseg))
                              AND c.cpostal = LPAD(x.cpostal_propietario, 5, '0')
                              AND c.cprovin = a.cprovin
                              AND c.cpoblac = b.cpoblac
                         ORDER BY 1, 2;
            BEGIN
               v_localidad_aseg :=
                  RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.localidad_propietario), 'ÁÉÍÓÚ',
                                              'AEIOU'))),
                        '.');

               OPEN c1;

               FETCH c1
                INTO v_mig_personas2.cprovin, v_mig_personas2.cpoblac;

               IF c1%NOTFOUND THEN
                  CLOSE c1;

                  BEGIN
                     SELECT DISTINCT cprovin
                                INTO v_mig_personas2.cprovin
                                FROM codpostal
                               WHERE cpostal = LPAD(x.cpostal_propietario, 5, '0');

                     vnum_err :=
                        pac_int_online.f_crear_poblacion(v_localidad_aseg,
                                                         v_mig_personas2.cprovin,
                                                         LPAD(x.cpostal_propietario, 5, '0'),
                                                         v_mig_personas2.cpoblac);

                     IF vnum_err <> 0 THEN
                        b_warning := TRUE;
                        p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                      'no definido ' || ' (' || x.proceso || '-' || x.nlinea
                                      || '-' || x.localidad_propietario || '-'
                                      || x.cpostal_propietario || ')',
                                      x.proceso,
                                      'localidad cod_postal no definido ' || ' (' || x.proceso
                                      || '-' || x.nlinea || '-' || x.localidad_propietario
                                      || '-' || x.cpostal_propietario || ')');
                        v_mig_personas2.cprovin := NULL;
                        v_mig_personas2.cpoblac := NULL;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        BEGIN
                           SELECT SUBSTR(LPAD(x.cpostal_propietario, 5, '0'), 1, 2)
                             INTO v_mig_personas2.cprovin
                             FROM DUAL;

                           vnum_err :=
                              pac_int_online.f_crear_poblacion(v_localidad_aseg,
                                                               v_mig_personas2.cprovin,
                                                               LPAD(x.cpostal_propietario, 5,
                                                                    '0'),
                                                               v_mig_personas2.cpoblac);

                           IF vnum_err <> 0 THEN
                              b_warning := TRUE;
                              p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                            'no definido ' || ' (' || x.proceso || '-'
                                            || x.nlinea || '-' || x.localidad_propietario
                                            || '-' || x.cpostal_propietario || ')',
                                            x.proceso,
                                            'localidad cod_postal no definido ' || ' ('
                                            || x.proceso || '-' || x.nlinea || '-'
                                            || x.localidad_propietario || '-'
                                            || x.cpostal_propietario || ')');
                              v_mig_personas2.cprovin := NULL;
                              v_mig_personas2.cpoblac := NULL;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                              b_warning := TRUE;
                              p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                            'no definido ' || ' (' || x.proceso || '-'
                                            || x.nlinea || '-' || x.localidad_propietario
                                            || '-' || x.cpostal_propietario || ')',
                                            x.proceso,
                                            'localidad cod_postal no definido ' || ' ('
                                            || x.proceso || '-' || x.nlinea || '-'
                                            || x.localidad_propietario || '-'
                                            || x.cpostal_propietario || ')');
                              v_mig_personas2.cprovin := NULL;
                              v_mig_personas2.cpoblac := NULL;
                        END;
                  END;
               ELSE
                  CLOSE c1;
               END IF;
            -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona la EXCEPTION
            EXCEPTION
               WHEN OTHERS THEN
                  IF c1%ISOPEN THEN
                     CLOSE c1;
                  END IF;
            END;
         END IF;

         v_mig_personas2.cprovin := NVL(reg_dat_dir.cprovin, v_mig_personas2.cprovin);
         -- Bug 0017569
         v_mig_personas2.cpoblac := NVL(reg_dat_dir.cpoblac, v_mig_personas2.cpoblac);
         -- Bug 0017569
            --IF x.oficina IS NULL THEN
            --   RAISE errdatos;
            --END IF;
         v_mig_personas2.cidioma := NVL(reg_dat_pers.cidioma, k_idiomaaaxis);   -- Bug 0017569
         -- ini Bug 0014185 - JMF - 25/05/2010

         -- Telefono contacto
         vtraza := 1115;

         IF x.tlf_propietario IS NOT NULL THEN
            v_mig_personas2.tnumtel := x.tlf_propietario;
         END IF;

         IF reg_dat_contac.ctipcon = 1 THEN
            v_mig_personas2.tnumtel := NVL(reg_dat_contac.tvalcon, v_mig_personas2.tnumtel);
         -- Bug 0017569
         END IF;

         -- Telefono movil
         --IF x.telmovil2 IS NOT NULL THEN
         --   v_mig_personas2.tnummov := x.telmovil2;
         --v_mig_personas2.tnumfax := x.TELMOVIL2;
         --END IF;
         -- fin Bug 0014185 - JMF - 25/05/2010
         INSERT INTO mig_personas
              VALUES v_mig_personas2
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 0, v_mig_personas2.mig_pk);
      END IF;

      v_mig_seg.mig_pk := v_ncarga || '/' || x.poliza;
      v_mig_seg.mig_fk := v_mig_personas.mig_pk;
      -- v_mig_seg.cagente := v_mig_personas.cagente;
      v_mig_seg.csituac := 0;
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
      vtraza := 1130;
      v_mig_seg.fefecto := TO_DATE(x.fh_efecto, 'DD/MM/RRRR');

      IF v_mig_seg.fefecto IS NULL THEN
         verror := 'Fecha efecto no es fecha: ' || x.fh_efecto || ' (dd/mm/aaaa)';
         verror := verror || '. Editar linea, modificar fecha efecto y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1135;
      -- IF x.forma_pag IS NULL THEN
      --  RAISE errdatos;
      --  END IF;
      vtraza := 1140;
      v_mig_seg.cforpag := pac_cargas_allianz.f_buscavalor('CRT_FORMAPAGO',
                                                           SUBSTR(x.forma_de_pago, 1, 1));

      IF v_mig_seg.cforpag IS NULL THEN
         verror := 'Forma de pago no definida: ' || x.forma_de_pago || ' (CRT_FORMAPAGO)';
         verror := verror || '. Editar linea, modificar forma de pago y reprocesar.';
         cerror := 140704;
         RAISE errdatos;
      END IF;

      vtraza := 1145;

      DECLARE
         v_cramo        seguros.cramo%TYPE;
         v_cempres      codiram.cempres%TYPE;
      BEGIN
         v_mig_seg.sproduc := pac_cargas_allianz.f_buscavalor('CRT_PRODALLIANZ', x.ramo);

         IF v_mig_seg.sproduc IS NULL THEN
            verror := 'falta producto para: ' || v_cramo || ' - ' || x.ramo || ' - '
                      || x.poliza;
            cerror := 104347;
            RAISE errdatos;
         END IF;

         SELECT p.cramo, ccompani, cempres
           INTO v_cramo, v_mig_seg.ccompani, v_cempres
           FROM productos p, codiram c
          WHERE sproduc = v_mig_seg.sproduc
            AND c.cramo = p.cramo;

         -- v_cramo := pac_cargas_ALLIANZ.f_buscavalor('CRT_RAMOALLIANZ', x.RAMO);
         --  IF v_cramo IS NULL THEN
         --     verror := 'int_codigos_emp no definido: ' || x.ramo || ' (CRT_RAMOALLIANZ)';
         --     cerror := 9002109;
         --     RAISE errdatos;
         --  END IF;
         vtraza := 1150;
         /*
                  SELECT MIN(b.sproduc)
           INTO v_mig_seg.sproduc
           FROM productos b, codiram a
          WHERE a.cempres = k_empresaaxis
            AND a.cramo = v_cramo
            AND b.cramo = a.cramo
            AND b.cactivo = 1;
         */

         --joan pedent asigno el del producte.
         vtraza := 1155;
         -- BUG 17008 - 27/12/2010 - JMP - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nº de póliza
         -- v_mig_seg.npoliza := f_contador('02', v_cramo);
         v_mig_seg.npoliza := pac_propio.f_contador2(v_cempres, '02', v_cramo);
         v_mig_seg.ncertif := 0;
      END;

      vtraza := 1160;
      v_mig_seg.creafac := 0;   --Revisar
      -- FAL. Recupera actividad de la tabla de conversion
      -- v_mig_seg.cactivi := 0;
      v_mig_seg.cactivi := pac_cargas_allianz.f_buscavalor('CRT_ACTIVALLIANZ', x.ramo);
      -- FAL. Recupera actividad de la tabla de conversion

      --BUG 10395 - 11/06/2009 - JMC - Inicializamos cobrador bancario
      v_mig_seg.ccobban := NULL;
      vtraza := 1165;
      --FIN BUG 10395 - 11/06/2009 - JMC
      v_mig_seg.ctipcoa := 0;
      v_mig_seg.ctiprea := 0;
      v_mig_seg.ctipcom := 0;   --Habitual
      vtraza := 1170;
      vtraza := 1175;

      IF x.duracion = 'ANUAL' THEN   -- FAL. 11/11/2010
         -- v_mig_seg.fvencim := NULL;
         IF x.fh_anulacion IS NOT NULL
            AND TO_DATE(x.fh_anulacion, 'dd/mm/rrrr') > f_sysdate THEN
            -- ojo es una anulación a futuro
            v_mig_seg.fvencim := TO_DATE(x.fh_anulacion, 'DD/MM/RRRR');
         -- esta vigente pero se tiene que anular en el futuro
         ELSE
            v_mig_seg.fvencim := NULL;
         END IF;
      ELSE
         v_mig_seg.fvencim := TO_DATE(x.fh_vencimiento, 'dd/mm/rrrr');

         IF x.fh_vencimiento IS NOT NULL
            AND v_mig_seg.fvencim IS NULL THEN
            verror := 'Fecha vencimiento no es fecha: ' || x.fh_vencimiento || ' (dd-mm-aaaa)';
            verror := verror || '. Editar linea, modificar fecha vencimiento y reprocesar';
            cerror := 1000135;
            RAISE errdatos;
         END IF;
      END IF;

      vtraza := 1180;
      v_mig_seg.femisio := TO_DATE(x.fh_emision, 'DD/MM/RRRR');   -- v_mig_seg.fefecto;
      v_mig_seg.iprianu := 0;   --JRH IMP
      vtraza := 1185;
      v_mig_seg.cidioma := k_idiomaaaxis;
      v_mig_seg.creteni := 0;
      v_mig_seg.sciacoa := NULL;
      v_mig_seg.pparcoa := NULL;
      v_mig_seg.npolcoa := NULL;
      v_mig_seg.nsupcoa := NULL;
      v_mig_seg.pdtocom := NULL;
      v_mig_seg.ncuacoa := NULL;
      v_mig_seg.cempres := k_empresaaxis;
      --  v_mig_seg.ccompani := NULL;
      --v_mig_seg.ctipcob := 1;   -- JRH IMP Caja
      vtraza := 1190;
      v_mig_seg.crevali := 0;
      v_mig_seg.prevali := 0;
      v_mig_seg.irevali := 0;
      vtraza := 1195;

      IF NVL(x.cod_banco, 0) = 0 THEN
         v_mig_seg.ctipban := NULL;
         v_mig_seg.cbancar := NULL;
      ELSE
         vtraza := 1200;
         v_mig_seg.ctipban := 1;
         v_mig_seg.cbancar := LTRIM(TO_CHAR(x.cod_banco, '0999'))
                              || LTRIM(TO_CHAR(x.ofic_banco, '0999'))
                              || LTRIM(TO_CHAR(x.dig_control, '09'))
                              || LTRIM(TO_CHAR(x.cta_banco, '0999999999'));
         vtraza := 1205;

         DECLARE
            n_control      NUMBER;
            v_salida       VARCHAR2(50);
         BEGIN
            --10.  AQ
            cerror := f_ccc(TO_NUMBER(x.iban), 2, n_control, v_salida);   -- 10. Check IBAN

            IF x.iban IS NOT NULL
               AND cerror = 0 THEN
               v_mig_seg.cbancar := x.iban;
            ELSE
               -- FI 10. AQ
               cerror := f_ccc(TO_NUMBER(v_mig_seg.cbancar), 1, n_control, v_salida);

               IF cerror <> 0 THEN
                  b_warning := TRUE;
                  p_genera_logs(vobj, vtraza, 'cuenta cobro',
                                'no válida ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                                x.proceso,
                                'cuenta cobro no válida ' || ' (' || x.proceso || '-'
                                || x.nlinea || ')');
                  v_mig_seg.ctipban := NULL;
                  v_mig_seg.cbancar := NULL;
                  cerror := 0;
               END IF;
            END IF;
         END;
      END IF;

      vtraza := 1210;

      IF NVL(x.cod_banco, 0) = 0 THEN   -- FAL. 11/11/2010
         v_mig_seg.ctipcob := 1;
      ELSE
         v_mig_seg.ctipcob := 2;
      END IF;

      v_mig_seg.casegur := 1;
      --Revisar de momento pongo especificar, en caso de ser igual al tomador poner 1
      v_mig_seg.nsuplem := 0;
      v_mig_seg.sseguro := 0;
      v_mig_seg.sperson := 0;
      vtraza := 1200;
      vcdomici := 1;

      SELECT COUNT(*)
        INTO vpersonas
        FROM per_personas m
       WHERE m.nnumide = x.nif_tomador;

      vtraza := 1205;

      SELECT NVL(MIN(cdomici), 1)
        INTO vcdomici
        FROM per_direcciones p, per_personas m
       WHERE m.nnumide = x.nif_tomador
         AND p.sperson = m.sperson;

      -- FAL. Si tomador <> propietario -> recupera cdomici del propietario
      IF x.nif_tomador <> x.nif_propietario THEN
         SELECT NVL(MIN(cdomici), 1)
           INTO vcdomici_aseg
           FROM per_direcciones p, per_personas m
          WHERE m.nnumide = x.nif_propietario
            AND p.sperson = m.sperson;
      END IF;

      v_mig_seg.crecfra := 0;
      vtraza := 1210;
      --vnum_err := f_calc_fechas_cartera(v_mig_seg, var_productos);   --JRH IMP

      -- IF vnum_err <> 0 THEN
      --  RAISE errdatos;
      --END IF;
      --v_mig_seg.npolini := x.poliza;
      --jlb 28/04/2011
      --v_mig_seg.npolini := x.poliza_reemp; -- se tiene que crear una pregunta
      --
      v_mig_seg.mig_fk := v_mig_personas.mig_pk;
      vtraza := 1215;

      SELECT *
        INTO var_productos
        FROM productos
       WHERE sproduc = v_mig_seg.sproduc;

      vtraza := 1220;
      --v_mig_seg.ccobban := f_buscacobban(var_productos.cramo, var_productos.cmodali,
      --                                   var_productos.ctipseg, var_productos.ccolect,
      --                                   v_mig_seg.cagente, v_mig_seg.cbancar,
      --                                   v_mig_seg.ctipban, vnum_err);

      --IF vnum_err <> 0 THEN
      --   RAISE errdatos;
      --END IF;
      v_mig_seg.ccobban := NULL;   --JRH de momento
      v_mig_seg.cestmig := 1;
      v_mig_seg.ncarga := v_ncarga;
      vtraza := 1225;

      -- BUSCO LA POLIZA de NOTA INFORMATIVA
      UPDATE    seguros seg
            SET csituac = 16
          WHERE sproduc = v_mig_seg.sproduc
            AND csituac = 14
            AND sseguro IN(SELECT tom.sseguro
                             FROM tomadores tom, per_personas per
                            WHERE per.sperson = tom.sperson
                              AND per.nnumide = x.nif_tomador)
            AND ROWNUM = 1
      RETURNING npoliza, cagente, sseguro
           INTO v_mig_seg.npolini, v_mig_seg.cagente, v_mig_movseg.sseguro;

      --actualizo la primera nota informativa, y marco la nueva poliza con el agente, y la poliza origen
      vtraza := 1227;

      INSERT INTO mig_seguros
           VALUES v_mig_seg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 1, v_mig_seg.mig_pk);

      vtraza := 1230;

      IF v_mig_movseg.sseguro IS NOT NULL THEN
         BEGIN
            SELECT cusumov, fmovimi
              INTO v_mig_movseg.cusumov, v_mig_movseg.fmovimi
              FROM movseguro
             WHERE sseguro = v_mig_movseg.sseguro
               AND nmovimi = 1;
         EXCEPTION
            WHEN OTHERS THEN
               v_mig_movseg.cusumov := NULL;
               v_mig_movseg.fmovimi := NVL(v_mig_seg.femisio, v_mig_seg.fefecto);
         END;
      ELSE
         v_mig_movseg.cusumov := f_user;
         v_mig_movseg.fmovimi := NVL(v_mig_seg.femisio, v_mig_seg.fefecto);
      END IF;

      --Movseguro
      v_mig_movseg.sseguro := 0;
      v_mig_movseg.nmovimi := 1;
      v_mig_movseg.cmotmov := 100;
      v_mig_movseg.fefecto := v_mig_seg.fefecto;
      -- v_mig_movseg.fmovimi := v_mig_seg.femisio;
      v_mig_movseg.mig_pk := v_mig_seg.mig_pk || '/' || '1';
      v_mig_movseg.mig_fk := v_mig_seg.mig_pk;
      v_mig_movseg.cestmig := 1;
      v_mig_movseg.ncarga := v_ncarga;
      vtraza := 1235;

      INSERT INTO mig_movseguro
           VALUES v_mig_movseg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 2, v_mig_movseg.mig_pk);

      vtraza := 1240;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_ALLIANZ', 'MIG_ASEGURADOS', 5);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_ALLIANZ', 'MIG_RIESGOS', 6);

      vtraza := 1245;
      v_mig_ase.sseguro := 0;
      v_mig_ase.sperson := 0;
      v_mig_ase.norden := 1;   --JRH IMP
      vtraza := 1250;
      v_mig_ase.ffecini := v_mig_seg.fefecto;
      v_mig_ase.ffecfin := NULL;
      v_mig_ase.ffecmue := NULL;   --Revisar
      --v_mig_ase.mig_fk := x.asnumnif;
      v_mig_ase.mig_pk := v_mig_seg.mig_pk;

      -- FAL. Asigna como asegurado el propietario en lugar del tomador
      IF x.nif_propietario <> x.nif_tomador THEN
         v_mig_ase.mig_fk := v_mig_personas2.mig_pk;
      ELSE
         v_mig_ase.mig_fk := v_mig_seg.mig_fk;
      END IF;

      v_mig_ase.mig_fk2 := v_mig_seg.mig_pk;
      v_mig_ase.cestmig := 1;
      v_mig_ase.ncarga := v_ncarga;

      -- FAL. Asigna cdomici del propietario en lugar del tomador si son distintos
      IF x.nif_propietario <> x.nif_tomador THEN
         v_mig_ase.cdomici := vcdomici_aseg;
      ELSE
         v_mig_ase.cdomici := vcdomici;
      END IF;

      vtraza := 1255;

      INSERT INTO mig_asegurados
           VALUES v_mig_ase
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 5, v_mig_ase.mig_pk);

      vtraza := 1260;
      ---
      v_mig_rie.nriesgo := 1;
      v_mig_rie.sseguro := 0;
      v_mig_rie.nmovima := 1;
      v_mig_rie.fefecto := v_mig_seg.fefecto;   --JRH IMP
      v_mig_rie.sperson := NULL;
      v_mig_rie.nmovimb := NULL;
      v_mig_rie.fanulac := NULL;

      --      v_mig_rie.tnatrie := 'Número asegurados ' || x.num_asegurados;  -- Nº DE ASEGURADOS ???? NO ESTA EN INT_POLIZAS_ALLIANZ
      IF x.riesgo IS NOT NULL THEN
         v_mig_rie.tnatrie := x.riesgo;
      END IF;

      vtraza := 1265;
      v_mig_rie.mig_pk := v_mig_seg.mig_pk;
      --v_mig_rie.mig_fk := x.asnumnif;
      v_mig_rie.mig_fk := v_mig_seg.mig_fk;
      v_mig_rie.mig_fk2 := v_mig_seg.mig_pk;
      v_mig_rie.cestmig := 1;
      v_mig_rie.ncarga := v_ncarga;
      vtraza := 1270;

      INSERT INTO mig_riesgos
           VALUES v_mig_rie
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 6, v_mig_rie.mig_pk);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_ALLIANZ', 'MIG_GARANSEG', 8);

      vtraza := 1275;
      w_asig_primera_gar := FALSE;

      FOR reg IN (SELECT *
                    FROM garanpro
                   WHERE sproduc = v_mig_seg.sproduc
                     AND cactivi = v_mig_seg.cactivi) LOOP
         DECLARE
            n_garaxis      NUMBER;

            PROCEDURE p_capit(p_gar IN VARCHAR2, p_cap IN NUMBER) IS
               v_seq          NUMBER;
            BEGIN
               vtraza := 1285;

               /*-- FAL. Se comenta esto pq no llega capital y no asignaria primas, y primas si que llegan  -- int_polizas_allianz
                      IF NVL(p_cap, 0) <> 0 THEN  -- Si existe capital, comprobamos si existe garantia definida.
               */
               IF p_gar IS NOT NULL THEN   --FAL. Si no esta informado la desc. garantia-> nada
                  vtraza := 1290;
                  n_garaxis := pac_cargas_allianz.f_buscavalor('CRT_GRANTIAALLIANZ', p_gar);

                  IF n_garaxis IS NULL THEN
                     --b_warning := TRUE;
                     p_genera_logs(vobj, vtraza, 'capital_' || p_gar,
                                   'capital sin garantia' || ' (' || x.proceso || '-'
                                   || x.nlinea || ')',
                                   x.proceso,
                                   'capital_' || p_gar || ' capital sin garantia ' || ' ('
                                   || x.proceso || '-' || x.nlinea || ')');

                     -- FAL. Genera warning si garantia no definida.
                     SELECT sseqlogmig2.NEXTVAL
                       INTO v_seq
                       FROM DUAL;

                     INSERT INTO mig_logs_axis
                                 (ncarga, seqlog, fecha,
                                  mig_pk, tipo,
                                  incid)
                          VALUES (v_ncarga, v_seq, f_sysdate,
                                  -- Bug 0016525. 29/10/2010. FAL
                                  --v_mig_gar.mig_pk
                                  v_mig_movseg.mig_pk || '/' || reg.cgarant,
                                                                             -- Fi Bug 0016525
                                  'W',
                                  'Garantia no esta definida: ' || p_gar);

                     -- FAL. Genera warning si garantia no definida.
                     verror := 'Garantia no definida (ramo - garantia): (' || x.ramo || '-'
                               || p_gar || ') (CRT_GRANTIAALLIANZ)';
                     cerror := 9001108;
                     RAISE errdatos;
                  ELSE
                     -- Asignamos las primas a su garantia correspondiente.
                     IF reg.cgarant = n_garaxis THEN
                        v_mig_gar := NULL;
                        v_mig_gar.mig_fk := v_mig_movseg.mig_pk;
                        v_mig_gar.cestmig := 1;
                        v_mig_gar.cgarant := reg.cgarant;
                        v_mig_gar.ncarga := v_ncarga;
                        v_mig_gar.nriesgo := 1;
                        v_mig_gar.nmovimi := v_mig_movseg.nmovimi;
                        v_mig_gar.nmovima := 1;
                        v_mig_gar.sseguro := 0;
                        vtraza := 1280;
                        v_mig_gar.mig_pk := v_mig_movseg.mig_pk || '/' || reg.cgarant;
                        v_mig_gar.icapital := 0;
                        -- Si es la garantia que tratamos, asignamos el capital.
                        vtraza := 1295;

                        IF NOT w_asig_primera_gar THEN
                           v_mig_gar.iprianu := NVL(x.prima_neta_s1, 0)
                                                + NVL(x.prima_neta_s2, 0)
                                                + NVL(x.prima_neta_s3, 0);
                           w_asig_primera_gar := TRUE;
                        ELSE
                           v_mig_gar.iprianu := 0;
                        END IF;

                        -- FAL. Se suman las primas de los subramos s1,s2 y s3. Sólo 1 de la primas de los subramos tiene valor != 0
                        v_mig_gar.irecarg := NULL;
                        v_mig_gar.icapital := p_cap;
                        vtraza := 1315;
                        v_mig_gar.precarg := 0;
                        v_mig_gar.iextrap := 0;
                        v_mig_gar.ipritar := 0;   --NVL(pprimaanu, 0);
                        v_mig_gar.crevali := 0;
                        v_mig_gar.prevali := 0;
                        v_mig_gar.irevali := 0;
                        v_mig_gar.pdtocom := 0;
                        v_mig_gar.idtocom := 0;
                        v_mig_gar.finiefe := v_mig_seg.fefecto;
                        v_mig_gar.ffinefe := NULL;
                        vtraza := 1320;

                        INSERT INTO mig_garanseg
                             VALUES v_mig_gar
                          RETURNING ROWID
                               INTO v_rowid;

                        INSERT INTO mig_pk_emp_mig
                             VALUES (0, v_ncarga, 8, v_mig_gar.mig_pk);
                     END IF;
                  END IF;
               END IF;
            END;
         BEGIN
            vtraza := 1310;
            p_capit(UPPER(x.desc_cober_c1), x.valor_cober_c1);
            p_capit(UPPER(x.desc_cober_c2), x.valor_cober_c2);
            p_capit(UPPER(x.desc_cober_c3), x.valor_cober_c3);
            p_capit(UPPER(x.desc_cober_c4), x.valor_cober_c4);
            p_capit(UPPER(x.desc_cober_c5), x.valor_cober_c5);
            p_capit(UPPER(x.desc_cober_c6), x.valor_cober_c6);
            p_capit(UPPER(x.desc_cober_c7), x.valor_cober_c7);
            p_capit(UPPER(x.desc_cober_c8), x.valor_cober_c8);
         END;
      END LOOP;

      vtraza := 1325;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_ALLIANZ', 'MIG_PREGUNSEG', 9);

      FOR reg IN (SELECT *
                    FROM pregunpro
                   WHERE sproduc = v_mig_seg.sproduc) LOOP
         v_mig_pregunseg := NULL;
         v_mig_pregunseg.ncarga := v_ncarga;
         v_mig_pregunseg.cestmig := 1;
         v_mig_pregunseg.sseguro := 0;
         v_mig_pregunseg.mig_fk := v_mig_seg.mig_pk;

         CASE reg.cpregun
            WHEN 7906 THEN
               v_mig_pregunseg.mig_pk := '7906:' || v_mig_seg.mig_pk;
               v_mig_pregunseg.nriesgo := 1;
               v_mig_pregunseg.cpregun := 7906;
               --v_mig_pregunseg.crespue :=
                 --  TO_NUMBER(TO_CHAR(TO_DATE(x.fh_carnet_propietario, 'dd/mm/yyyy'),
                   --                  'yyyymmdd'));
               v_mig_pregunseg.crespue := x.fh_carnet_propietario;
            WHEN 7925 THEN
               v_mig_pregunseg.mig_pk := '7925:' || v_mig_seg.mig_pk;
               v_mig_pregunseg.nriesgo := 1;
               v_mig_pregunseg.cpregun := 7925;
               v_mig_pregunseg.crespue := NULL;   -- es tipus bonificación no nos llega
            ELSE
               NULL;
         END CASE;

         v_mig_pregunseg.nmovimi := 0;

         IF v_mig_pregunseg.crespue IS NOT NULL THEN
            INSERT INTO mig_pregunseg
                 VALUES v_mig_pregunseg
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_rwd_emp_mig
                 VALUES (v_rowid_ini, v_ncarga, 9, v_rowid);

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 9, v_mig_pregunseg.mig_pk);
         ELSE
            IF NVL(reg.cpreobl, 0) = 1 THEN
               -- Bug 14888. FAL. 11/10/2010. Informar error pregunta obl. sin respuesta
               verror := 'Pregunta: ' || TO_CHAR(reg.cpregun);
               -- Bug 16324. FAL. 26/10/2010. Informar la pregunta obligatoria como desc. error
               cerror := 120307;
               -- Fi Bug 14888
               RAISE errdatos;
            END IF;
         END IF;
      END LOOP;

      vtraza := 1350;

      UPDATE int_polizas_allianz
         SET ncarga = v_ncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1355;
      x.ncarga := v_ncarga;
      COMMIT;

      IF b_warning THEN
         cerror := -2;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error ' || cerror, verror, x.proceso,
                                          'Error ' || cerror || ' ' || verror);
         pterror := verror;
         -- Bug 0016324. FAL. 26/10/2010. Informa desc. error para registrar linea de error y no aparezca un literal en el detalle->mensajes de la pnatalla resultado cargas
         RETURN cerror;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'ERROR ' || SQLCODE, SQLERRM,
                                          x.proceso, 'Error ' || SQLCODE || ' ' || SQLERRM);
         cerror := SQLCODE;   -- Bug 0016324. FAL. 26/10/2010. Devuelve sqlcode como error
         pterror := SQLERRM;
         -- Bug 0016324. FAL. 26/10/2010. Devuelve sqlerrm como desc. error;
         RETURN cerror;
   END f_alta_poliza;

   /*************************************************************************
                   procedimiento que genera anulación de póliza
          param in x : registro tipo INT_POLIZAS_ALLIANZ
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
   FUNCTION f_baja_poliza(x IN OUT int_polizas_allianz%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_BAJA_POLIZA';
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
      vtraza := 1020;
      n_pro := f_buscavalor('CRT_PRODALLIANZ', x.ramo);

      BEGIN
         SELECT sseguro
           INTO n_seg
           FROM seguros
          WHERE cpolcia = TO_CHAR(x.poliza)
            AND sproduc = n_pro;

         n_aux := 1;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            n_aux := 0;
            p_deserror := 'Más de una póliza compañia: ' || x.poliza;
            cerror := 100500;
            RAISE errdatos;
         WHEN OTHERS THEN
            n_aux := 0;
            p_deserror := 'Número póliza no existe: ' || x.poliza;
            cerror := 100500;
            RAISE errdatos;
      END;

      IF n_aux = 0 THEN
         p_deserror := 'Número póliza no existe: ' || x.poliza;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1040;
      -- FAL. Asigna fh_anulacion como fecha baja
      d_baj := TO_DATE(x.fh_anulacion, 'DD/MM/RRRR');

      IF d_baj IS NULL THEN
         p_deserror := 'Fecha anulación no es fecha: ' || x.fh_anulacion || ' (dd-mm-aaaa)';
         p_deserror := p_deserror || '. Editar linea, modificar fecha anulación y reprocesar';
         cerror := 102853;
         RAISE errdatos;
      END IF;

      vtraza := 1050;
      v_des2 := '';
      vtraza := 1070;

      SELECT tmotmov
        INTO v_des1
        FROM motmovseg
       WHERE cmotmov = k_motivoanula
         -- FAL. Provisional. Motivo anulacion 324 -- Anul·lació inmediata
         AND cidioma = k_idiomaaaxis;

      vtraza := 1080;
      cerror := pac_agensegu.f_set_datosapunte(NULL, n_seg, NULL, v_des1,
                                               f_axis_literales(100811, k_idiomaaaxis) || ' '
                                               || v_des1 || CHR(13) || CHR(13) || v_des2,
                                               6, 1, f_sysdate, f_sysdate, 0, 0);

      IF cerror <> 0 THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Agenda', 'código ' || cerror, x.proceso,
                       'Agenda: código ' || cerror);
         cerror := 0;
      END IF;

      vtraza := 1090;

      SELECT cagente, sproduc, csituac,
             npoliza   -- Bug 0016324. FAL. 18/10/2010  -- Bug 0016324. FAL. 26/10/2010
        INTO n_age, n_pro, w_csituac,
             wnpoliza   -- Fi Bug 0016324 -- Fi Bug 0016324
        FROM seguros
       WHERE sseguro = n_seg;

      -- Bug 0016324. FAL. 18/10/2010
      IF w_csituac <> 0 THEN   -- No permita anular poliza si ya lo está
         -- p_deserror := 'La póliza ' || TO_CHAR(wnpoliza) || ' no esta vigente';
          -- Bug 0016324. FAL. 26/10/2010. Informar el npoliza en la desc. error
         -- cerror := 101483;
         -- RAISE errdatos;
         p_deserror := 'La póliza ' || TO_CHAR(wnpoliza) || ' no esta vigente';
         -- Bug 0016324. FAL. 26/10/2010. Informar el npoliza en la desc. error
         cerror := 101483;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, n_seg,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
         --RAISE errdatos;
         RETURN 2;   -- marcalo como warning
      END IF;

      -- Fi Bug 0016324
      vtraza := 1100;
      cerror := pac_anulacion.f_anula_poliza(n_seg, k_motivoanula,
                                             f_parinstalacion_n('MONEDAINST'), d_baj, 0,
                                             -- pcextorn
                                             1,   -- Anular rebuts pendents
                                             n_age, rpend, rcob, n_pro, NULL,   -- pcnotibaja
                                             2, NULL);

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
                  (x.proceso, x.nlinea, x.tipo_oper, 4, 1, n_seg,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_baja_poliza;

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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.P_INICIAR_SUPLE';
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
      vtraza := 1062;
      p_est := NULL;
      cerror := pk_suplementos.f_inicializar_suplemento(p_seg, 'SUPLEMENTO', p_efe, 'BBDD',
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.P_FINALIZAR_SUPLE';
      vtraza         NUMBER;
      cerror         NUMBER;
      e_nosuple      EXCEPTION;
      errdatos       EXCEPTION;
      n_aux          NUMBER;
      indice         NUMBER;
      indice_e       NUMBER;
      indice_t       NUMBER;
      r_seg          seguros%ROWTYPE;
      pmensaje       VARCHAR2(500);   -- BUG 27642 - FAL - 24/04/2014
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
            p_tab_error(f_sysdate, f_user, 'PAC_CARGAS_ALLIANZ', 1,
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
                         r_seg.cidioma, indice, indice_e, indice_t, pmensaje,   -- BUG 27642 - FAL - 24/04/2014
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

   FUNCTION f_emitir_propuesta(p_seg IN NUMBER, p_des OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.f_emitir_propuesta';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      indice         NUMBER;
      indice_e       NUMBER;
      indice_t       NUMBER;
      r_seg          seguros%ROWTYPE;
      pmensaje       VARCHAR2(500);   -- BUG 27642 - FAL - 24/04/2014
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
      vtraza := 1096;
      p_emitir_propuesta(r_seg.cempres, r_seg.npoliza, r_seg.ncertif, r_seg.cramo,
                         r_seg.cmodali, r_seg.ctipseg, r_seg.ccolect, r_seg.cactivi, 1,
                         r_seg.cidioma, indice, indice_e, indice_t, pmensaje,   -- BUG 27642 - FAL - 24/04/2014
                         NULL, NULL, 1);

      IF indice_e <> 0
         OR indice < 1 THEN
         cerror := 151237;
         p_des := 'emision (' || indice_e || ')';
         RAISE errdatos;
      END IF;

      vtraza := 1098;
      RETURN 0;
   EXCEPTION
      WHEN errdatos THEN
         RETURN cerror;
   END f_emitir_propuesta;

   /*************************************************************************
                procedimiento que genera suplemento con modificacion de póliza
          param in x : registro tipo int_polizas_ALLIANZ
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
   FUNCTION f_modi_poliza(x IN OUT int_polizas_allianz%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_MODI_POLIZA';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_seg          seguros.sseguro%TYPE;
      n_pro          seguros.sproduc%TYPE;
      n_csituac      seguros.csituac%TYPE;
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
      --w_cambio_cc    NUMBER;
      wcnordban      per_ccc.cnordban%TYPE;
      -- FAL. 26/08/2011. Bug 0019231
      wfefecto       DATE;
      wsproduc       NUMBER;
      wcactivi       NUMBER;
      w_asig_primera_gar BOOLEAN;
      wiprianu       NUMBER;
      vnriesgo       riesgos.nriesgo%TYPE;
   -- Fi bug 0019231
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;

      IF pac_iax_produccion.poliza IS NULL
         OR pac_iax_produccion.poliza.det_poliza IS NULL THEN
         pac_iax_produccion.poliza := ob_iax_poliza();   --JRH Que no casque el preparar tarif
         pac_iax_produccion.poliza.det_poliza := ob_iax_detpoliza();
      END IF;

---------------------------------------------------------
-- VALIDAR CAMPOS CLAVE: Póliza, Certificado           --
---------------------------------------------------------
      vtraza := 1010;

      IF LTRIM(x.poliza) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      n_pro := f_buscavalor('CRT_PRODALLIANZ', x.ramo);

      BEGIN
         SELECT sseguro, sproduc, fefecto,
                                          -- MAX(f_vigente(sseguro, NULL, F_SYSDATE))  -- FAL. Polizas con vto informado en carga anterior no dejaba hacer supl. por no vigente.
                                          f_vigente(sseguro, NULL, x.fh_efecto),
                cagente   -- FAL. Se mira vigencia al efecto
                       , csituac
           INTO n_seg, n_pro, d_efe, n_vig,
                n_cagente, n_csituac
           FROM seguros
          WHERE cpolcia = TO_CHAR(x.poliza)
            AND sproduc = n_pro;
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      BEGIN
         IF (NVL(n_cagente, -1) <> NVL(TO_NUMBER(x.ofic_banco), -1)
             AND x.cod_banco = 3081) THEN
            -- si la oficina gestora es diferente al cargada en la póliza
            p_deserror := 'La póliza ' || TO_CHAR(x.poliza)
                          || ' ha cambiado de oficina. Anterior ' || n_cagente || ' por '
                          || x.ofic_banco;
            cerror := 9000815;
            n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF n_seg IS NULL THEN   --jlb, sino encuentro la poliza la busco si esta pendiente
         BEGIN
            SELECT seg.sseguro, sproduc, fefecto,
                                                 --f_vigente(seg.sseguro, NULL, x.fh_efecto)   -- FAL. Se mira vigencia al efecto
                   0,
                     -- es una poliza que se ha enviado y la estamos esperando
                     csituac, seg.cagente
              INTO n_seg, n_pro, d_efe, n_vig, n_csituac, n_cagente
              FROM seguros seg, tomadores tom, per_personas per
             WHERE fefecto = x.fh_efecto
               AND sproduc = n_pro
               AND tom.sseguro = seg.sseguro
               AND per.sperson = tom.sperson
               -- cualquier tomador con ese nif, esa fecha fecha, ese producto
               AND TRIM(BOTH '0' FROM per.nnumide) = TRIM(BOTH '0' FROM x.nif_tomador)
               AND cempres = k_empresaaxis
               AND cpolcia IS NULL
               AND ROWNUM = 1;   -- si existe mas deuna cojo la primera...

            -- si encuentro la poliza aqui significa que la tengo que eimtir primero
            IF n_csituac = 4 THEN
               cerror := f_emitir_propuesta(n_seg, p_deserror);

               IF cerror <> 0 THEN
                  p_deserror := 'Error emitiendo la póliza ' || x.poliza;
                  RAISE errdatos;
               END IF;
            ELSE
               p_deserror := 'Número póliza en estado incorrecto: ' || x.poliza;
               cerror := 100500;
               RAISE errdatos;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               n_seg := NULL;
               n_pro := NULL;
               d_efe := NULL;
               n_vig := NULL;
               n_csituac := NULL;
         END;
      END IF;

      IF n_seg IS NULL THEN
         p_deserror := 'Número póliza no existe: ' || x.poliza;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      --IF n_vig <> 0 THEN
      IF n_csituac IN(2, 3) THEN
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

      SELECT MAX(1)
        INTO n_aux
        FROM codiram a, productos b
       WHERE a.cempres = k_empresaaxis
         AND b.cramo = a.cramo
         AND b.sproduc = n_pro;

      IF n_aux IS NULL THEN
         p_deserror := 'Empresa no tiene producto: ' || n_pro;
         cerror := 9001709;
         RAISE errdatos;
      END IF;

      vtraza := 1025;
      d_sup := x.fh_efecto;

      IF d_sup IS NULL THEN
         p_deserror := 'Fecha efecto no es fecha: ' || x.fh_emision || ' (dd-mm-aaaa)';
         p_deserror := p_deserror || '. Editar linea, modificar fecha efecto y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

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

--------------------------------------------------------------------------
-- iniciar suple
--------------------------------------------------------------------------
--      n_aux := pac_contexto.f_inicializarctx(f_USER);   -- FAL. Obligado init. contexto pq en pk_suplementos.f_validar_permite_suplemento llamada a pac_cfg.f_get_user_accion_permitida con f_user. (f_user no da el usuario correcto siempre (a veces si, a veces no (si llega de un error)))
      vtraza := 1030;
      cerror := pac_cargas_allianz.p_iniciar_suple(n_seg, d_sup, k_motivomodif, n_est, n_mov,
                                                   p_deserror);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

--------------------------------------------------------------------------
-- modificacions
--------------------------------------------------------------------------
      vtraza := 1040;

      IF x.duracion = 'ANUAL' THEN   -- FAL. 11/11/2010
         --v_mig_seg.fvencim := NULL;   -- si es anual renovable lo pongo a nulo
         IF x.fh_anulacion IS NOT NULL
            AND TO_DATE(x.fh_anulacion, 'dd/mm/rrrr') > f_sysdate THEN
            -- ojo es una anulación a futuro
            d_aux := TO_DATE(x.fh_anulacion, 'DD/MM/RRRR');
         -- esta vigente pero se tiene que anular en el futuro
         ELSE
            d_aux := NULL;
         END IF;
      ELSE
         d_aux := TO_DATE(x.fh_vencimiento, 'DD/MM/RRRR');

         IF x.fh_vencimiento IS NOT NULL
            AND d_aux IS NULL THEN
            p_deserror := 'Fecha vencimiento no es fecha: ' || x.fh_vencimiento
                          || ' (dd-mm-aaaa)';
            p_deserror := p_deserror
                          || '. Editar linea, modificar fecha vencimiento y reprocesar';
            cerror := 1000135;
            RAISE errdatos;
         END IF;
      END IF;

      IF x.aplicacion = 0 THEN
         BEGIN
            UPDATE estseguros
               SET fvencim = d_aux   -- la recalculamos la fecha de vencimiento
             WHERE sseguro = n_est;
         --AND fvencim <> d_aux;
         EXCEPTION
            WHEN OTHERS THEN
               p_deserror := 'Error ' || SQLCODE || ' Vencimiento: '
                             || TO_CHAR(d_aux, 'dd-mm-yyyy');
               cerror := 104566;
               RAISE errdatos;
         END;
      ELSE
         -- si es una aplicación diferente anulamos ese riesgo
         --
          -- primero miro si el riesgo existe antes de insertarlo
         SELECT DECODE(x.aplicacion, 0, 1, x.aplicacion)
           INTO vnriesgo
           FROM DUAL;

         BEGIN
            SELECT nriesgo
              INTO vnriesgo
              FROM estriesgos
             WHERE sseguro = n_est
               AND nriesgo = vnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               INSERT INTO estassegurats
                           (sseguro, sperson, nriesgo, cdomici, ffecini, ffecfin, ffecmue,
                            norden)
                  SELECT sseguro, sperson, vnriesgo, cdomici, d_sup, ffecfin, ffecmue,
                         vnriesgo
                    FROM estassegurats
                   WHERE sseguro = n_est
                     AND norden = 1
                     AND nriesgo = 1;   -- copio el primer assegurado

               INSERT INTO estriesgos
                           (nriesgo, sseguro, nmovima, tnatrie, fefecto)
                    VALUES (vnriesgo, n_est, n_mov, x.riesgo, d_sup);

               -- flotas solo estos tienen datos
               INSERT INTO estautriesgos
                           (sseguro, nriesgo, nmovimi, cversion, triesgo)
                    VALUES (n_est, vnriesgo, n_mov, '99999999999', x.riesgo);
         END;

         UPDATE estriesgos
            SET fanulac = d_aux
          WHERE sseguro = n_est
            AND nriesgo = vnriesgo;

         UPDATE estassegurats
            SET ffecfin = d_aux
          WHERE sseguro = n_est
            AND nriesgo = vnriesgo
            AND norden = vnriesgo;
      END IF;

      --      END IF;
      vtraza := 1055;

      IF LTRIM(x.nif_tomador) IS NOT NULL THEN
         SELECT MAX(1)
           INTO n_aux
           FROM seguros a, tomadores b, per_personas c
          WHERE a.sseguro = n_seg
            AND b.sseguro = a.sseguro
            AND c.sperson = b.sperson
            AND c.nnumide = x.nif_tomador;

         IF n_aux IS NULL THEN
            b_warning := TRUE;
            v_deswarning := v_deswarning || ' ' || 'Tomador diferente  ' || x.nif_tomador;
         END IF;
      END IF;

      vtraza := 1060;

      IF NVL(x.cod_banco, 0) <> 0 THEN
         DECLARE
            v_cbancar      seguros.cbancar%TYPE;
            n_control      NUMBER;
            v_salida       VARCHAR2(50);
         BEGIN
            vtraza := 1065;
            --10.  AQ
            cerror := f_ccc(TO_NUMBER(x.iban), 2, n_control, v_salida);   -- 10. Check IBAN

            IF x.iban IS NOT NULL
               AND cerror = 0 THEN
               v_cbancar := x.iban;
            ELSE
               -- FI 10. AQ
               v_cbancar := LTRIM(TO_CHAR(x.cod_banco, '0999'))
                            || LTRIM(TO_CHAR(x.ofic_banco, '0999'))
                            || LTRIM(TO_CHAR(x.dig_control, '09'))
                            || LTRIM(TO_CHAR(x.cta_banco, '0999999999'));
               vtraza := 1070;
               cerror := f_ccc(TO_NUMBER(v_cbancar), 1, n_control, v_salida);

               IF cerror <> 0 THEN
                  p_deserror := 'Error ' || cerror || ' al validar cuenta bancaria: '
                                || v_cbancar;
                  cerror := 120130;
                  RAISE errdatos;
               END IF;
            END IF;

            vtraza := 1075;

            /*   w_cambio_cc := 0;

               SELECT COUNT(*)
                 INTO w_cambio_cc
                 FROM estseguros
                WHERE sseguro = n_est
                  AND cbancar <> v_cbancar
                  AND ctipban = 1;*/                                                                                                                                                                                                                          -- JLB no todos tienen ctipan = 1, lo hago por rowcount
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
                                 (sperson, cagente,
                                  ctipban, cbancar, fbaja, cdefecto, cusumov, fusumov, cnordban)
                          VALUES (tom.sperson, NVL(ff_agente_cpervisio(n_cagente), k_agente),
                                  1, v_cbancar, NULL, 0, f_user, f_sysdate, wcnordban);
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

      IF LTRIM(x.forma_de_pago) IS NOT NULL THEN
         DECLARE
            v_cforpag      seguros.cforpag%TYPE;
         BEGIN
            vtraza := 1085;
            v_cforpag := pac_cargas_allianz.f_buscavalor('CRT_FORMAPAGO',
                                                         SUBSTR(x.forma_de_pago, 1, 1));

            IF v_cforpag IS NULL THEN
               p_deserror := 'Forma de pago no definida: ' || x.forma_de_pago
                             || ' (CRT_FORMAPAGO)';
               p_deserror := p_deserror
                             || '. Editar linea, modificar forma de pago y reprocesar.';
               cerror := 140704;
               RAISE errdatos;
            END IF;

            vtraza := 1090;

            UPDATE estseguros
               SET cforpag = v_cforpag
             WHERE sseguro = n_est
               AND cforpag <> v_cforpag;
         EXCEPTION
            WHEN OTHERS THEN
               p_deserror := 'Error ' || SQLCODE || ' Cuenta forma pago: ' || x.forma_de_pago;
               cerror := 140704;
               RAISE errdatos;
         END;
      END IF;

      vtraza := 1095;

      -- FAL. 26/08/2011. Bug 0019231: CRT003 - Error en las cargas (no hace suplementos de garantias)
      -- Eliminamos garantias existentes
      SELECT DECODE(x.aplicacion, 0, 1, x.aplicacion)
        INTO vnriesgo
        FROM DUAL;

      DELETE      estgaranseg
            WHERE sseguro = n_est
              AND nriesgo = vnriesgo
              AND nmovimi = n_mov;

      -- FAL. 26/08/2011. recuperamos valores de seguros. Bug 0019231
      SELECT fefecto, sproduc, cactivi
        INTO wfefecto, wsproduc, wcactivi
        FROM estseguros
       WHERE sseguro = n_est;

      w_asig_primera_gar := FALSE;

      FOR reg IN (SELECT *
                    FROM garanpro
                   WHERE sproduc = wsproduc
                     AND cactivi = wcactivi) LOOP
         DECLARE
            n_garaxis      NUMBER;

            PROCEDURE p_capit(p_gar IN VARCHAR2, p_cap IN NUMBER) IS
               v_seq          NUMBER;
            BEGIN
               vtraza := 1285;

               IF p_gar IS NOT NULL THEN   --FAL. Si no esta informado la desc. garantia-> nada
                  vtraza := 1290;
                  n_garaxis := pac_cargas_allianz.f_buscavalor('CRT_GRANTIAALLIANZ', p_gar);

                  IF n_garaxis IS NULL THEN
                     p_deserror := 'Garantia no definida (ramo - garantia): (' || x.ramo
                                   || '-' || p_gar || ') (CRT_GRANTIAALLIANZ)';
                     cerror := 9001108;
                     RAISE errdatos;
                  ELSE
                     -- Asignamos las primas a su garantia correspondiente.
                     IF reg.cgarant = n_garaxis THEN
                        IF NOT w_asig_primera_gar THEN
                           wiprianu := NVL(x.prima_neta_s1, 0) + NVL(x.prima_neta_s2, 0)
                                       + NVL(x.prima_neta_s3, 0);
                           w_asig_primera_gar := TRUE;
                        ELSE
                           wiprianu := 0;
                        END IF;

                        -- FAL. 26/08/2011. Alta de las garantias que llegan. Bug 0019231
                        INSERT INTO estgaranseg
                                    (cgarant, nriesgo, nmovimi, sseguro, finiefe,
                                     norden, crevali, ctarifa, icapital, precarg, iextrap,
                                     iprianu, ffinefe, cformul, ctipfra, ifranqu,
                                     irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                                     itarifa, itarrea, ipritot, icaptot, ftarifa, crevalcar,
                                     cgasgar, pgasadq, pgasadm, pdtoint, idtoint, feprev,
                                     fpprev, percre, cmatch, tdesmat, pintfin, cref, cintref,
                                     pdif, pinttec, nparben, nbns, tmgaran, cderreg,
                                     ccampanya, nversio, nmovima, cageven, nfactor, nlinea,
                                     cfranq, nfraver, ngrpfra, ngrpgara, nordfra, pdtofra,
                                     cmotmov, finider, falta, ctarman, cobliga, ctipgar,
                                     itotanu)
                             VALUES (reg.cgarant, vnriesgo, n_mov, n_est, wfefecto,
                                     reg.norden, 0, NULL, p_cap, 0, 0,
                                     wiprianu, NULL, reg.cformul, reg.ctipfra, reg.ifranqu,
                                     NULL, 0, 0, 0, 0, 0,
                                     NULL, NULL, wiprianu, p_cap, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, reg.nparben, reg.nbns, NULL, reg.cderreg,
                                     NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL, reg.ctipgar,
                                     NULL);

                        vtraza := 1295;
                     END IF;
                  END IF;
               END IF;
            END;
         BEGIN
            vtraza := 1310;
            p_capit(UPPER(x.desc_cober_c1), x.valor_cober_c1);
            p_capit(UPPER(x.desc_cober_c2), x.valor_cober_c2);
            p_capit(UPPER(x.desc_cober_c3), x.valor_cober_c3);
            p_capit(UPPER(x.desc_cober_c4), x.valor_cober_c4);
            p_capit(UPPER(x.desc_cober_c5), x.valor_cober_c5);
            p_capit(UPPER(x.desc_cober_c6), x.valor_cober_c6);
            p_capit(UPPER(x.desc_cober_c7), x.valor_cober_c7);
            p_capit(UPPER(x.desc_cober_c8), x.valor_cober_c8);
         END;
      END LOOP;

      --actualizamos la tabla de solicitud de suplementos
      UPDATE sup_solicitud
         SET cestsup = 1
       WHERE sseguro = n_seg
         AND cestsup = 2;

--------------------------------------------------------------------------
-- finalitzar suple
--------------------------------------------------------------------------
      INSERT INTO estdetmovseguro
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                   tvalord, cpregun)
           VALUES (n_est, n_mov, k_motivomodif, 0, 0, NULL,
                   'Carga proceso ' || x.proceso || '/' || x.nlinea, 0);

      cerror := pac_cargas_allianz.p_finalizar_suple(n_est, n_mov, n_seg, p_deserror,
                                                     k_motivomodif, x.proceso, d_sup);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

---------------------------------------------------------
-- CONTROL FINAL                                       --
---------------------------------------------------------
      IF b_warning THEN
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, n_seg,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, n_seg,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
      END IF;

      RETURN 4;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (traza=' || vtraza || ') ' || SQLCODE
                       || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Resgistrar linea y error
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_modi_poliza;

   /*************************************************************************
                             procedimiento que ejecuta una carga (parte2 proceso).
          param in psproces   : Número proceso
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutar_carga_proceso(psproces IN NUMBER, p_cproces IN NUMBER)
      -- BUG16130:DRA:15/10/2010
   RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_EJECUTAR_CARGA_PROCESO';

      CURSOR polmigra(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_polizas_allianz a
            WHERE proceso = psproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.proceso
                                AND int_carga_ctrl_linea.nlinea = a.nlinea
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5))
         --Solo las no procesadas
         ORDER BY nlinea;

      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      -- BUG16130:DRA:29/09/2010:Inici
      e_errdatos     EXCEPTION;
      -- BUG16130:DRA:29/09/2010:Fi
      vterror        VARCHAR2(4000);
      -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
      -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
      wsinterf       int_mensajes.sinterf%TYPE;
   -- Fi 17569
   BEGIN
      vtraza := 0;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                          'Parámetro psproces obligatorio.', psproces,
                                          f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 1;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vtraza := 2;

      -- BUG16130:DRA:29/09/2010:Inici
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      -- BUG16130:DRA:29/09/2010:Fi
      vtraza := 4;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Falta fichero para proceso: ' || psproces);
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                 || v_tfichero || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;
      END IF;

      FOR x IN polmigra(psproces) LOOP
         --Leemos los registros de la tabla int no procesados OK
                  -- Bug 0016324. FAL. 18/10/2010
         IF NVL(vtiperr, 0) <> 1 THEN
            -- Fi Bug 0016324
            IF x.tipo_oper = 'ALTA' THEN   --Si es alta
               vtraza := 6;
               vterror := NULL;
               -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
               verror := f_alta_poliza(x, vterror, wsinterf);

               --Grabamos en las MIG  -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
               IF verror IN(0, -2) THEN   --Si ha ido bien o tenemos avisos.
                  IF verror = -2 THEN   -- Avisos.
                     vtraza := 7;
                     vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 2, 0, NULL,

                                              -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                              x.poliza,
                                              -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                              x.ncarga
                                                      -- Fi Bug 16324
                                );

                     IF vnum_err <> 0 THEN
                        --Si fallan esta funciones de gestión salimos del programa
                        RAISE errorini;   --Error que para ejecución
                     END IF;

                     vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 2, verror,
                                                   NVL(vterror, verror));

                     IF vnum_err <> 0 THEN
                        --Si fallan esta funciones de gestión salimos del programa
                        RAISE errorini;   --Error que para ejecución
                     END IF;

                     vavisfin := TRUE;
                     verror := 0;
                  END IF;

                  vtiperr := f_alta_poliza_seg(x, wsinterf);   --Grabamos en las SEG

                  IF vtiperr = 2 THEN
                     vavisfin := TRUE;
                  END IF;

                  IF x.fh_anulacion IS NOT NULL
                     AND(TO_DATE(x.fh_anulacion, 'dd/mm/yyyy') <= f_sysdate
                         AND vtiperr IN(4, 2)) THEN   -- 11/11/2010
                     vtiperr := f_baja_poliza(x, v_deserror);

                     IF vtiperr = 2 THEN
                        vavisfin := TRUE;
                     END IF;
                  END IF;

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF vtiperr NOT IN(0, 4, 2) THEN
                     IF k_para_carga <> 1 THEN
                        vtiperr := 4;   -- para que continue con la siguiente linea.
                     ELSE
                        vtiperr := 1;   -- para la carga
                     END IF;
                  END IF;
               -- Fi Bug 0016324
               ELSE   --Si ha ido mal el paso a las MIG lo indicamos con el error orbtenido
                  -- Bug 0016324. FAL. 18/10/2010
                  vtiperr := 1;
                  -- Fi Bug 0016324
                  vtraza := 70;
                  vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 1, 0, NULL,

                                           -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                           x.poliza,
                                           -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                           x.ncarga
                                                   -- Fi Bug 16324
                             );

                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  vtraza := 72;
                  vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,
                                                NVL(vterror, verror));

                  -- Bug 0016324. FAL. 26/10/2010. Registra la desc. error si informada. en caso contrario el literal verror
                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  verrorfin := TRUE;
                  COMMIT;

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF k_para_carga <> 1 THEN
                     -- Fi Bug 0016324
                     vtiperr := 4;   -- todo bien, para que continue con la siguiente linea.
                  -- Bug 0016324. FAL. 18/10/2010.
                  END IF;
               -- Fi Bug 0016324
               END IF;
            ELSIF x.tipo_oper = 'MODI' THEN
               vtiperr := f_modi_poliza(x, v_deserror);

               IF vtiperr = 2 THEN
                  vavisfin := TRUE;
               END IF;

               IF x.fh_anulacion IS NOT NULL
                  AND(TO_DATE(x.fh_anulacion, 'dd/mm/yyyy') <= f_sysdate
                      AND vtiperr IN(4, 2)) THEN   -- 11/11/2010
                  vtiperr := f_baja_poliza(x, v_deserror);

                  IF vtiperr = 2 THEN
                     vavisfin := TRUE;
                  END IF;
               END IF;

               -- Bug 0016324. FAL. 18/10/2010.d
               IF vtiperr NOT IN(4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     vtiperr := 1;   -- para la carga
                  END IF;
               END IF;
            -- Fi Bug 0016324
            ELSIF x.tipo_oper = 'BAJA' THEN
               vtiperr := f_baja_poliza(x, v_deserror);

               IF vtiperr = 2 THEN
                  vavisfin := TRUE;
               END IF;

               -- Bug 0016324. FAL. 18/10/2010.d
               IF vtiperr NOT IN(4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     vtiperr := 1;   -- para la carga
                  END IF;
               END IF;
            -- Fi Bug 0016324
            END IF;

            IF vtiperr = 1 THEN   --Ha habido error
               verrorfin := TRUE;
            ELSIF vtiperr = 2 THEN   -- Es un warning
               vavisfin := TRUE;
            ELSIF vtiperr = 4 THEN   --Ha ido bien.
               NULL;
            ELSE
               RAISE errorini;   --Error que para ejecución(funciones de gestión)
            END IF;

            COMMIT;
         -- Bug 0016324. FAL. 18/10/2010
         ELSIF vtiperr = 1
               AND k_para_carga = 1 THEN
            vtiperr := 1;
            vcoderror := 151541;
            --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                       f_sysdate, f_sysdate,
                                                                       vtiperr, p_cproces,

                                                                       -- BUG16130:DRA:29/09/2010
                                                                       vcoderror, NULL);

            IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
               vnnumlin := NULL;
               vnum_err := f_proceslin(psproces,
                                       f_axis_literales(180856, k_idiomaaaxis) || ':'
                                       || v_tfichero || ' : ' || vnum_err,
                                       1, vnnumlin);
               RAISE errorini;   --Error que para ejecución
            END IF;

            COMMIT;
            RETURN 0;
         --RAISE vsalir;
         END IF;
      -- Fi Bug 0016324
      END LOOP;

      vtiperr := 4;
      vcoderror := NULL;

      IF vavisfin THEN
         vtiperr := 2;
         vcoderror := 700145;
      END IF;

      IF verrorfin THEN
         vtiperr := 1;
         vcoderror := 151541;
      END IF;

      --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero, NULL,
                                                                 f_sysdate, vtiperr, p_cproces,

                                                                 -- BUG16130:DRA:29/09/2010
                                                                 vcoderror, NULL);
      vtraza := 51;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      vtraza := 52;

      --Bug.:17155
      IF vtiperr IN(4, 2) THEN
         vnum_err := pac_gestion_procesos.f_set_carga_fichero(29, v_tfichero, 1, f_sysdate);

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_fichero');
            vnnumlin := NULL;
            vnum_err := f_proceslin(psproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':'
                                    || v_tfichero || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecución
         END IF;
      --Fi Bug.: 17155
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                          psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza,
                                          'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                          'Error:' || 'Insertando estados registros',
                                          psproces,
                                          f_axis_literales(108953, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || 'errorini');
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM,
                                          psproces,
                                          f_axis_literales(103187, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    151541, SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_allianz.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                           || ' : ' || vnum_err);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_ejecutar_carga_proceso;

   /*************************************************************************
                                                                                         procedimiento que lee el fichero
          param in p_nombre   : Nombre fichero
          param in p_path   : Nuombre path
          param in psproces   : Número proceso
          param in   out pdeserror   : mensaje de error
      *************************************************************************/
   PROCEDURE f_lee_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      pdeserror OUT VARCHAR2,
      psproces IN NUMBER) IS
      v_line         VARCHAR2(4000);
      v_indice       NUMBER(1) := 0;
      v_npoliza      VARCHAR2(20);
      v_ncertif      seguros.ncertif%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_nrecibo      recibos.nrecibo%TYPE;
      v_nombre       personas.tbuscar%TYPE;
      v_importe      NUMBER;
      v_fcobro       recibos.fefecto%TYPE;
      v_ind          NUMBER;
      v_ind2         NUMBER;
      num_err        NUMBER;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(1) := NULL;
      vobj           VARCHAR2(200) := 'pac_cargas_ALLIANZ.f_lee_fichero';
      registro       int_polizas_allianz%ROWTYPE;
      lsmovagr       NUMBER := 0;
      lnliqmen       NUMBER := NULL;
      lnliqlin       NUMBER := NULL;
      v_empresa      VARCHAR2(100);
      v_producto     VARCHAR2(100);
      v_cobrador     VARCHAR2(100);
      v_ccrebut      VARCHAR2(100);
      v_tipo         VARCHAR2(100);
      v_fvencim      recibos.fvencim%TYPE;
      v_cccobrador   VARCHAR2(100);
      e_object_error EXCEPTION;
      vlinea         NUMBER := 0;
      vtipo          NUMBER;
      v_numerr       NUMBER;
      errgrabarprov  EXCEPTION;
      vcont          NUMBER := 0;
      v_map          map_cabecera.cmapead%TYPE := 'C0030';   -- Carga Polizas ALLIANZ
      v_sec          NUMBER;
      p_txt          VARCHAR2(3000);
      waux           NUMBER;
   BEGIN
      v_pasexec := 0;
      pdeserror := NULL;
      v_pasexec := 1;

      IF p_nombre IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':p_nombre';
         RAISE e_object_error;
      END IF;

      IF p_path IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':p_path';
         RAISE e_object_error;
      END IF;

      IF psproces IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':psproces';
         RAISE e_object_error;
      END IF;

      v_pasexec := 2;
      pac_map.p_carga_parametros_fichero(v_map, psproces, p_nombre, 0);
      -- un 99 en lugar de un 0 y provoca debugar
      v_pasexec := 3;
      v_numerr := pac_map.carga_map(v_map, v_sec);
      p_txt := '0208 map=' || v_map || ' sec=' || v_sec || ' numerr=' || v_numerr
               || ' p_nombre=' || p_nombre;

      IF v_numerr <> 0 THEN
         RAISE errgrabarprov;
      END IF;

      -- Bug 0016324. FAL. 18/10/2010.
      UPDATE int_polizas_allianz
         SET proceso = psproces
       WHERE sinterf = psproces;

      COMMIT;

      DECLARE
         v_tipo         int_polizas_allianz.tipo_oper%TYPE;

         CURSOR c1 IS
            SELECT ROWID, nlinea, poliza, TO_DATE(fh_anulacion, 'dd/mm/yyyy') fh_anulacion,
                   TO_DATE(fh_efecto, 'dd/mm/yyyy') fh_efecto, ramo, nif_tomador, proceso,
                   aplicacion, ncarga
              -- Fi Bug 16324
            FROM   int_polizas_allianz
             WHERE proceso = psproces;
      BEGIN
         FOR f1 IN c1 LOOP
            v_pasexec := 5;

            BEGIN
               v_sproduc := f_buscavalor('CRT_PRODALLIANZ', f1.ramo);

               BEGIN
                  SELECT 1
                    INTO waux
                    FROM seguros
                   WHERE cpolcia = TO_CHAR(f1.poliza)
                     AND sproduc = v_sproduc;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- si no existe con la poliza la busco por producto,fefecto, tomador
                     SELECT 1
                       INTO waux
                       FROM seguros seg, tomadores tom, per_personas per
                      WHERE fefecto = f1.fh_efecto
                        AND sproduc = v_sproduc
                        AND tom.sseguro = seg.sseguro
                        AND seg.cpolcia IS NULL
                        AND per.sperson = tom.sperson
                        -- cualquier tomador con ese nif, esa fecha fecha, ese producto
                        AND TRIM(BOTH '0' FROM per.nnumide) =
                                                             TRIM(BOTH '0' FROM f1.nif_tomador)
                        --AND csituac <> 14
                        AND csituac = 4   -- FAL - 8/11/2011 - Bug 0020084
                        AND ROWNUM = 1;
               END;

               IF f1.fh_anulacion IS NULL THEN
                  v_tipo := 'MODI';
               ELSE
                  IF f1.fh_anulacion <= f_sysdate THEN   -- 11/11/2010
                     v_tipo := 'BAJA';
                  ELSE
                     v_tipo := 'MODI';
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  IF f1.aplicacion IN(0, 1) THEN
                     v_tipo := 'ALTA';
                  ELSE
                     v_tipo := 'MODI';   -- si la aplicaicon es >1 ya ha tenido que llegar la póliza
                  END IF;
            END;

            -- Fi bug 0016324
            v_pasexec := 6;
            -- Marcar como pendiente.
            v_numerr :=
               p_marcalinea
                  (psproces, f1.nlinea, v_tipo, 3, 0, NULL,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   f1.poliza,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   f1.ncarga   -- Fi Bug 16324
                            );

            IF v_numerr <> 0 THEN
               RAISE errgrabarprov;
            END IF;

            v_pasexec := 7;

            UPDATE int_polizas_allianz
               SET tipo_oper = v_tipo
             WHERE ROWID = f1.ROWID;
         END LOOP;
      EXCEPTION
         WHEN errgrabarprov THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, 108953, vobj);
            pdeserror := f_axis_literales(108953, k_idiomaaaxis) || ':' || vobj;
            RAISE e_object_error;
         WHEN OTHERS THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
            pdeserror := f_axis_literales(105133, k_idiomaaaxis) || ':' || vlinea || '    '
                         || f_axis_literales(1000136, k_idiomaaaxis) || ':'
                         || TO_NUMBER(v_pasexec + 1) || ' ' || SQLERRM;
            RAISE e_object_error;
      END;

      v_pasexec := 8;
      COMMIT;
   EXCEPTION
      WHEN e_object_error THEN
         ROLLBACK;

         IF pdeserror IS NULL THEN
            pdeserror := f_axis_literales(108953, k_idiomaaaxis);
         END IF;

         NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pdeserror := f_axis_literales(103187, k_idiomaaaxis) || SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
   END f_lee_fichero;

   /*************************************************************************
                                                         procedimiento que ejecuta una carga (parte1 fichero)
          param in p_nombre   : Nombre fichero
          param in p_path   : Nuombre path
          param out psproces   : Número proceso
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutar_carga_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_EJECUTAR_CARGA_FICHERO';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      sentencia      VARCHAR2(32000);
      vfichero       UTL_FILE.file_type;
      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER;
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      vsinproc       BOOLEAN := TRUE;   --Indica si tenemos o no proceso
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_context      VARCHAR2(200);
      -- BUG16130:DRA:29/09/2010:Inici
      e_errdatos     EXCEPTION;
   -- BUG16130:DRA:29/09/2010:Fi
   BEGIN
      vtraza := 0;
      v_context := f_parinstalacion_t('CONTEXT_USER');
      -- vnum_err := pac_contexto.f_inicializarctx(f_USER);
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_ALLIANZ', p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecución
      END IF;

      psproces := v_sproces;
      vtraza := 1;

      -- BUG16130:DRA:29/09/2010:Inici
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      -- BUG16130:DRA:29/09/2010:Fi
      vtraza := 11;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                 f_sysdate, NULL, 3, p_cproces,

                                                                 -- BUG16130:DRA:29/09/2010
                                                                 NULL, NULL);
      vtraza := 12;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      COMMIT;
      vtraza := 2;
      f_lee_fichero(p_nombre, p_path, vdeserror, v_sproces);
      vtraza := 3;

      IF vdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    NULL, vdeserror);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecución
         END IF;

         vtraza := 52;
         COMMIT;   --Guardamos la tabla temporal int
         RAISE vsalir;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                          psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                     'Error:' || 'Insertando estados registros');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(108953, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || 'errorini',
                                 1, vnnumlin);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         --coderr := SQLCODE;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || SQLERRM || ' en :' || 1,
                     'Error:' || SQLERRM);
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(103187, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || SQLERRM,
                                 1, vnnumlin);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    151541, SQLERRM);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_ejecutar_carga_fichero;

   /*************************************************************************
                      procedimiento que ejecuta una carga
          param in p_nombre   : Nombre fichero
          param in p_path   : Nuombre path
          param in  out psproces   : Número proceso (informado para recargar proceso).
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_EJECUTAR_CARGA';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;   -- FAL - 07707/2011 - Bug 0019991
   BEGIN
      vtraza := 0;

      -- Bug 0016324. FAL. 18/10/2010
      SELECT NVL(cpara_error, 0)
        INTO k_para_carga
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      -- Fi Bug 0016324
      IF psproces IS NULL THEN
         vnum_err := pac_cargas_allianz.f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces,

                                                                 -- BUG16130:DRA:15/10/2010
                                                                 psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_allianz.f_ejecutar_carga_proceso(psproces, p_cproces);

      -- BUG16130:DRA:15/10/2010
      IF vnum_err <> 0 THEN
         RAISE vsalir;
      END IF;

      -- Bug 14888. FAL. 11/10/2010. Informar autriesgos.triesgo
      vnum_err := f_migra_autriesgos;
      -- Fi Bug 14888

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
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN 1;
   END f_ejecutar_carga;

   /*************************************************************************
                procedimiento que da de alta recibo en las mig
          param in x : registro tipo INT_RECIBOS_ALLIANZ
      *************************************************************************/
   FUNCTION f_altarecibo_mig(x IN OUT int_recibos_allianz%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_ALTARECIBO_MIG';
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      errdatos       EXCEPTION;
      --Tablas
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_rec      mig_recibos%ROWTYPE;
      v_mig_recdet   mig_detrecibos%ROWTYPE;
      verror         VARCHAR2(1000);
      cerror         NUMBER;
      vtraza         NUMBER;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_rowid_ini    ROWID;
      pid            VARCHAR2(200);
      b_warning      BOOLEAN;
      v_creccia      int_recibos_allianz.creccia%TYPE;
      v_cpolcia      seguros.cpolcia%TYPE;
      n_aux          NUMBER;
      n_seg          seguros.sseguro%TYPE;
      n_pro          seguros.sproduc%TYPE;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      --      p_deserror := NULL;
      pid := x.nlinea;
      b_warning := FALSE;
      vtraza := 1005;

      SELECT ROWID
        INTO v_rowid_ini
        FROM int_recibos_allianz
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      --Inicializamos la cabecera de la carga
      vtraza := 1010;
      v_ncarga := f_next_carga;
      x.ncarga := v_ncarga;
      -- Bug 0016324. FAL. 26/10/2010. Asignamos v_ncarga antes de posible error para registrarlo en la linea de carga
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Recibos', v_seq);
      vtraza := 1015;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, pid, 'OK');

-------------------- Valida ---------------------
      vtraza := 1025;
      v_creccia := x.num_recibo;
      vtraza := 1030;
      n_pro := f_buscavalor('CRT_PRODALLIANZ', x.ramo);

      BEGIN
         SELECT COUNT('1')
           INTO n_aux
           FROM recibos reb, seguros seg
          WHERE creccia = TO_CHAR(v_creccia)
            AND seg.sproduc = n_pro
            AND seg.sseguro = reb.sseguro
            AND seg.cpolcia = TO_CHAR(x.poliza)
            AND seg.cempres = k_empresaaxis;
      EXCEPTION
         WHEN OTHERS THEN
            n_aux := 0;
      END;

      IF n_aux > 0 THEN
         verror := 'Ya existe recibo cia: ' || v_creccia || '/' || k_empresaaxis;
         cerror := 102367;
         RAISE errdatos;
      END IF;

      vtraza := 1035;

      BEGIN
         SELECT sproduc, sseguro
           INTO n_pro, n_seg
           FROM seguros
          WHERE cpolcia = TO_CHAR(x.poliza)
            AND sproduc = n_pro;   -- int_polizas_allianz
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      IF n_seg IS NULL THEN
         verror := 'No existe póliza: ' || x.poliza;
         cerror := 140897;
         RAISE errdatos;
      END IF;

      vtraza := 1040;
/*      SELECT COUNT(1)
                                           INTO n_aux
        FROM productos a, codiram b
       WHERE a.sproduc = n_pro
         --    AND a.cactivo = 1
         AND b.cramo = a.cramo
         AND b.cempres = k_empresaaxis;
      IF n_aux = 0 THEN
         verror := 'No permitido para empresa/producto: ' || k_empresaaxis || '/' || n_pro;
         cerror := 102705;
         RAISE errdatos;
      END IF;
*/
-------------------- INICI ---------------------
-------------------- INICI ---------------------
-------------------- INICI ---------------------
      vtraza := 1045;

      -- Informamos fechas para que no carge seguros,
      -- aunque lo necesitamos para foreign de recibos.
      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab, finides, ffindes)
           VALUES (v_ncarga, 'INT_RECIBOS_ALLIANZ', 'MIG_SEGUROS', 0, f_sysdate, f_sysdate);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RECIBOS_ALLIANZ', 'MIG_RECIBOS', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RECIBOS_ALLIANZ', 'MIG_DETRECIBOS', 2);

      vtraza := 1050;
      -- Necesitamos informar mig_seguros para join con mig_recibos
      v_mig_rec.mig_pk := v_ncarga || '/' || x.creccia;
      vtraza := 1055;

      SELECT v_ncarga ncarga, -1 cestmig, v_mig_rec.mig_pk mig_pk, v_mig_rec.mig_pk mig_fk,
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
       WHERE sseguro = n_seg;

      vtraza := 1060;

      INSERT INTO mig_seguros
           VALUES v_mig_seg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

--------------------------------------------------------------------------
-- recibos
--------------------------------------------------------------------------
      v_mig_rec.ncarga := v_ncarga;
      v_mig_rec.cestmig := 1;
      v_mig_rec.mig_fk := v_mig_rec.mig_pk;
      vtraza := 1065;
      v_mig_rec.fefecto := TO_DATE(x.fh_efecto, 'dd/mm/yyyy');

      IF v_mig_rec.fefecto IS NULL THEN
         verror := 'Fecha efecto no es fecha: ' || x.fh_efecto || ' (dd/mm/aaaa)';
         verror := verror || '. Editar linea, modificar fecha efecto y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1070;
      v_mig_rec.fvencim := TO_DATE(x.fh_vencimiento, 'dd/mm/yyyy');

      IF v_mig_rec.fvencim IS NULL THEN
         verror := 'Fecha efecto no es fecha: ' || x.fh_vencimiento || ' (dd/mm/aaaa)';
         verror := verror || '. Editar linea, modificar fecha vencimiento y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1075;
      v_mig_rec.femisio := TO_DATE(x.fh_emision, 'dd/mm/yyyy');
      v_mig_rec.ctiprec := pac_cargas_allianz.f_buscavalor('CRT_TIPORECIBOALLIANZ',
                                                           x.procedencia);
      --      v_mig_rec.ctiprec := 3;   -- Suponemos que son cartera

      --      v_mig_rec.cforpag := pac_cargas_allianz.f_buscavalor('CRT_FORMAPAGO', SUBSTR(x.FORMA_DE_PAGO,1,1));

      -- busco el max moviment mateix efecte.
      vtraza := 1080;

      SELECT MAX(nmovimi)
        INTO n_aux
        FROM movseguro
       WHERE sseguro = n_seg
         AND fefecto = v_mig_rec.fefecto;

      IF n_aux IS NULL THEN
         vtraza := 1085;

         SELECT MAX(nmovimi)
           INTO n_aux
           FROM movseguro
          WHERE sseguro = n_seg;

         IF n_aux IS NULL THEN
            verror := 'Seguro: ' || n_seg;
            cerror := 104348;
            RAISE errdatos;
         END IF;
      END IF;

      v_mig_rec.nmovimi := n_aux;
      vtraza := 1090;
      v_mig_rec.cestrec := pac_cargas_allianz.f_buscavalor('CRT_ESTADORECIBOALLIANZ',
                                                           x.estado_recibo);

      IF v_mig_rec.cestrec IS NULL THEN
         verror := 'Estado del recibo no definido: ' || x.estado_recibo
                   || ' (CRT_ESTADORECIBOALLIANZ)';
         verror := verror || '. Editar linea, modificar estado recibo y reprocesar.';
         cerror := 101915;
         RAISE errdatos;
      END IF;

      vtraza := 1100;
      v_mig_rec.sseguro := n_seg;

      INSERT INTO mig_recibos
           VALUES v_mig_rec
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 1, v_mig_rec.mig_pk);

--------------------------------------------------------------------------
-- detalle recibos
--------------------------------------------------------------------------

      -- Importes del recibo
      vtraza := 1110;

      DECLARE
         v_rie          riesgos.nriesgo%TYPE;
         v_gar          garanpro.cgarant%TYPE;

         CURSOR c_gar IS
            SELECT   cgarant
                FROM garanpro
               WHERE sproduc = n_pro
                 AND ctipgar = 2
            ORDER BY norden;

         PROCEDURE crea_detalle(p_concep IN NUMBER, p_import IN NUMBER) IS   -- detrecibos
         BEGIN
            vtraza := 1120;
            v_mig_recdet.ncarga := v_ncarga;
            v_mig_recdet.cestmig := 1;
            v_mig_recdet.mig_pk := v_mig_rec.mig_pk || '-' || LTRIM(TO_CHAR(p_concep, '09'));
            v_mig_recdet.mig_fk := v_mig_rec.mig_pk;
            v_mig_recdet.cconcep := p_concep;
            v_mig_recdet.cgarant := v_gar;
            v_mig_recdet.nriesgo := v_rie;
            v_mig_recdet.iconcep := p_import;
            v_mig_recdet.nmovima := 1;
            vtraza := 1125;

            INSERT INTO mig_detrecibos
                 VALUES v_mig_recdet
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 2, v_mig_recdet.mig_pk);
         END;
      BEGIN
         -- Por defecto primer riesgo.
         vtraza := 1130;

         SELECT MIN(nriesgo)
           INTO v_rie
           FROM riesgos
          WHERE sseguro = n_seg
            AND fanulac IS NULL;

         -- Por defecto busco la primera garantia que sea obligatoria.
         vtraza := 1135;

         OPEN c_gar;

         FETCH c_gar
          INTO v_gar;

         CLOSE c_gar;

         vtraza := 1140;
         crea_detalle(00, ABS(x.prima_neta_s1 + x.prima_neta_s2 + x.prima_neta_s3));
         --> 00-Prima Neta
         crea_detalle(01,
                      ABS(x.recargo_externo_s1 + x.recargo_externo_s2 + x.recargo_externo_s3));
         --> 01-Recargo externo
         crea_detalle(02, ABS(x.consorcio_s1 + x.consorcio_s2 + x.consorcio_s3));
         --> 02-Consorcio
            --crea_detalle(04, x.importe_tasas);   --> 04-Impuesto IPS
         crea_detalle(11, ABS(x.comision_bruta_s1 + x.comision_bruta_s2 + x.comision_bruta_s3));
         --> 11-Comisión bruta
         crea_detalle(10, ABS(x.bonificacion_s1 + x.bonificacion_s2 + x.bonificacion_s3));
         --> 10-Dto.comercial
         crea_detalle(12, ABS(x.irpf_s1 + x.irpf_s2 + x.irpf_s3));   --> 12-Retención
         --crea_detalle(26, x.resto_impuestos_s1 + x.resto_impuestos_s2 + x.resto_impuestos_s3);
         --> 26-Otros conceptos Recargos
         crea_detalle(4,
                      ABS(x.resto_impuestos_s1 + x.resto_impuestos_s2 + x.resto_impuestos_s3));
      --> 4-impuestos ips
      -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos, incluyendo EXCEPTION
      EXCEPTION
         WHEN OTHERS THEN
            IF c_gar%ISOPEN THEN
               CLOSE c_gar;
            END IF;
      END;

-------------------- FINAL ---------------------
-------------------- FINAL ---------------------
-------------------- FINAL ---------------------
      vtraza := 1145;

      -- actualizo las fechas del seguro fcarpro,fcarant, fcaranu
      IF v_mig_rec.ctiprec IN(0, 3) THEN
         UPDATE seguros
            SET   --fcarpro = v_mig_rec.fvencim,
                  --fcarant = v_mig_rec.fefecto,
               fcarpro = GREATEST(fcarpro, v_mig_rec.fvencim),
               fcarant = GREATEST(NVL(fcarant, v_mig_rec.fefecto), v_mig_rec.fefecto),
               -- fcaranu = GREATEST(fcaranu,
                 --                  TO_DATE(TO_CHAR(fcaranu, 'DDMM')
                   --                        || TO_CHAR(v_mig_rec.fvencim, 'YYYY'),
                     --                      'DDMMYYYY'))
               fcaranu =
                  GREATEST
                     (fcaranu,
                      TO_DATE
                         (TO_CHAR(v_mig_rec.fvencim, 'DD')
                          || TO_CHAR
                                   (ADD_MONTHS(fefecto,
                                               12
                                               * ABS(CEIL(MONTHS_BETWEEN(v_mig_rec.fvencim,
                                                                         fefecto)
                                                          / 12))),
                                    'MMYYYY'),
                          'DDMMYYYY'))
          WHERE sseguro = n_seg;
      END IF;

      vtraza := 1147;

      UPDATE int_recibos_allianz
         SET ncarga = v_ncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1150;
      x.ncarga := v_ncarga;
      COMMIT;

      IF b_warning THEN
         cerror := -2;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         p_deserror := verror;
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error ' || cerror, verror, x.proceso,
                                          'Error ' || cerror || ' ' || verror);
         RETURN cerror;
      WHEN OTHERS THEN
         p_deserror := SQLCODE || ' ' || SQLERRM;
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'ERROR ' || SQLCODE, p_deserror,
                                          x.proceso, 'Error ' || p_deserror);
         RETURN cerror;
   END f_altarecibo_mig;

   /*************************************************************************
          Función que da de alta recibo en las SEG
          param in x : registro tipo int_recibos_allianz
          return : 1 si ha habido error
                   2 si ha habido warning
                   4 si ha ido bien
      *************************************************************************/
   FUNCTION f_altarecibo_seg(x IN OUT int_recibos_allianz%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_ALTARECIBO_SEG';
      v_i            BOOLEAN := FALSE;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
      verrorgrab     EXCEPTION;
      vtraza         NUMBER := 0;
      vtiperr        NUMBER;
      vnrecibo       NUMBER;
   BEGIN
      vtraza := 100;
      p_deserror := NULL;
      pac_mig_axis.p_migra_cargas(x.nlinea, 'C', x.ncarga, 'DEL');
      --Cargamos las SEG para la póliza (ncarga)
      vtraza := 110;

      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 200;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_recibo,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            p_deserror := 'Error al marcar linea con error';
            RAISE verrorgrab;
         END IF;

         v_i := TRUE;
         vtraza := 201;
         vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 151840, reg.incid);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            p_deserror := 'Error al marcar detalle linea con error';
            RAISE verrorgrab;
         END IF;

         vtiperr := 1;
      END LOOP;

      IF NOT v_i THEN
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = x.ncarga
                        AND tipo = 'W') LOOP   --Miramos si han habido warnings.
            vtraza := 202;

            BEGIN
               SELECT nrecibo
                 INTO vnrecibo
                 FROM mig_recibos
                WHERE ncarga = x.ncarga;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;   --JRH IMP de momento
            END;

            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.num_recibo,   -- Fi Bug 14888
                                   -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga,   -- Fi Bug 16324
                   NULL, NULL, NULL, vnrecibo);

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               p_deserror := 'Error al marcar linea con aviso';
               RAISE verrorgrab;
            END IF;

            vtraza := 203;
            vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, reg.incid);

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               p_deserror := 'Error al marcar detalle linea con aviso';
               RAISE verrorgrab;
            END IF;

            v_i := TRUE;
         END LOOP;

         vtiperr := 2;
      END IF;

      IF NOT v_i THEN
         --Esto quiere decir que no ha habido ningún error (lo indicamos también).
         vtraza := 204;

         BEGIN
            SELECT nrecibo
              INTO vnrecibo
              FROM mig_recibos
             WHERE ncarga = x.ncarga;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --JRH IMP de momento
         END;

         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_recibo,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                NULL, NULL, NULL, vnrecibo);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            p_deserror := 'Error al marcar linea con estado correcto';
            RAISE verrorgrab;
         END IF;

         BEGIN
            UPDATE recibos
               SET creccia = TO_CHAR(x.creccia)
             WHERE nrecibo = vnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               pac_cargas_allianz.p_genera_logs(vobj, vtraza, SQLCODE,
                                                'Error al guardar creccia ' || x.creccia,
                                                x.proceso,
                                                'Error al guardar creccia ' || x.creccia);
         END;

         vtiperr := 4;
      END IF;

      RETURN vtiperr;   --Devolvemos el tipo error que ha habido
   EXCEPTION
      WHEN verrorgrab THEN
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error ' || vnum_err, p_deserror,
                                          x.proceso,
                                          'Error ' || vnum_err || ' ' || p_deserror);
         RETURN 10;
      WHEN OTHERS THEN
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error ' || SQLCODE, SQLERRM,
                                          x.proceso, 'Error ' || SQLCODE || ' ' || SQLERRM);
         RETURN 10;
   END f_altarecibo_seg;

   /*************************************************************************
                               procedimiento que genera movimientos recibo
          param in x : registro tipo int_recibos_allianz
          param p_deserror out: Descripción del error si existe.
          Devuelve TIPOERROR ( 1-Ha habido error, 2-Es un warning, 4-Ha ido bien, x-Error incontrolado).
          --
          Para modificar una póliza, los siguientes campos son obligatorios:
          - póliza cia
          - fecha efecto (se toma como fecha operacion).
          - estado recibo.
          --
      *************************************************************************/
   FUNCTION f_modi_recibo(x IN OUT int_recibos_allianz%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_MODI_RECIBO';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      mismoestado    EXCEPTION;
      n_rec          recibos.nrecibo%TYPE;
      d_sup          movrecibo.fmovini%TYPE;
      n_estrecact    movrecibo.cestrec%TYPE;   -- Estat actual
      n_estrecnou    movrecibo.cestrec%TYPE;   -- Estat nou
      n_ultmov       movseguro.nmovimi%TYPE;   -- Ultimo movimiento
      --v_sproduc      seguros.sproduc%TYPE;
      n_cdelega      recibos.cdelega%TYPE;
      n_aux1         NUMBER;
      n_aux2         NUMBER;
      n_aux3         NUMBER;
      n_pro          seguros.sproduc%TYPE;
      n_aux          NUMBER;
      d_efe          seguros.fefecto%TYPE;
      n_vig          NUMBER;
      n_est          estseguros.sseguro%TYPE;
      n_mov          movseguro.nmovimi%TYPE;
      d_aux          DATE;
      n_perest       esttomadores.sperson%TYPE;
      n_cagente      seguros.cagente%TYPE;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      v_cmodifi      NUMBER;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
---------------------------------------------------------
-- VALIDAR CAMPOS CLAVE: Recibo cia.                   --
---------------------------------------------------------
      vtraza := 1010;

      IF LTRIM(x.creccia) IS NULL THEN
         p_deserror := 'Número recibo cia sin informar';
         cerror := 101731;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      n_pro := f_buscavalor('CRT_PRODALLIANZ', x.ramo);

      SELECT nrecibo
        INTO n_rec
        FROM recibos reb, seguros seg
       WHERE reb.creccia = TO_CHAR(x.creccia)
         AND seg.sseguro = reb.sseguro
         AND seg.sproduc = n_pro
         AND seg.cpolcia = TO_CHAR(x.poliza)
         AND seg.cempres = k_empresaaxis;

      IF n_rec IS NULL THEN
         p_deserror := 'Número recibo cia no existe: ' || x.creccia || '/' || k_empresaaxis;
         cerror := 101731;
         RAISE errdatos;
      END IF;

      --bug.: 18838 - ICV - 27/06/2011 - Se comprueba que no se haya modificado ya el estado del recibo.
      SELECT cmodifi
        INTO v_cmodifi
        FROM recibos
       WHERE nrecibo = n_rec;

      IF NVL(v_cmodifi, 0) IN(2, 9) THEN
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_recibo,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                NULL, NULL, NULL, n_rec);

         IF n_aux <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145,
                                    f_axis_literales(9902152, k_idiomaaaxis) || ' Nº: '
                                    || x.num_recibo);

         IF n_aux <> 0 THEN
            RAISE errdatos;
         END IF;

         RETURN 2;   --warning
      END IF;

      --Fi Bug.: 18838
      vtraza := 1020;
      vtraza := 1025;
      d_sup := TO_DATE(x.fh_efecto, 'dd/mm/yyyy');

      IF d_sup IS NULL THEN
         p_deserror := 'Fecha efecto no es fecha: ' || x.fh_efecto || ' (dd-mm-aaaa)';
         p_deserror := p_deserror || '. Editar linea, modificar fecha efecto y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      IF x.estado_recibo IS NULL THEN
         p_deserror := 'Estado recibo no existe: ' || x.estado_recibo;
         p_deserror := p_deserror || '. Editar linea, modificar estado recibo y reprocesar';
         cerror := 101915;
         RAISE errdatos;
      END IF;

      n_estrecnou := pac_cargas_allianz.f_buscavalor('CRT_ESTADORECIBOALLIANZ',
                                                     x.estado_recibo);

      IF n_estrecnou IS NULL THEN
         p_deserror := 'Estado de recibo no definido: ' || x.estado_recibo
                       || ' (CRT_ESTADORECIBOALLIANZ)';
         p_deserror := p_deserror || '. Editar linea, modificar estado recibo y reprocesar.';
         cerror := 101915;
         RAISE errdatos;
      END IF;

--------------------------------------------------------------------------
-- modificacions
--------------------------------------------------------------------------
      vtraza := 1040;

      SELECT NVL(MAX(b.nmovimi), 1), MAX(a.cdelega)
        INTO n_ultmov, n_cdelega
        FROM movseguro b, recibos a
       WHERE b.cmovseg = 2   -- último movimiento cartera.
         AND b.sseguro = a.sseguro
         AND a.nrecibo = n_rec;

      SELECT GREATEST(NVL(MAX(fmovini), d_sup), d_sup)
        INTO d_sup
        FROM movrecibo
       WHERE nrecibo = n_rec;

      -- Buscar estado actual...
      -- n_estrecact := f_estrec(n_rec);
      n_estrecact := f_cestrec(n_rec, d_sup);
      -- FAL. Uso f_cestrec. f_estrec no devuelve nada si no esta en movrecibo
      n_aux1 := 0;   -- smovagr

      IF n_estrecnou = 1 THEN
-- Cobrar -------------------------------------
         IF n_estrecact = 1 THEN
            p_deserror := 'Recibo ya esta cobrado';
            cerror := 9000878;
            --RAISE errdatos;
            RAISE mismoestado;
         ELSIF n_estrecact IS NULL
               OR n_estrecact = 2 THEN
            -- Si no existe o esta anulado,
            -- creamos movimiento pendiente.
            cerror := f_movrecibo(n_rec, 0, NULL, n_ultmov, n_aux1, n_aux2, n_aux3, d_sup,
                                  NULL, n_cdelega, NULL, NULL);

            IF cerror <> 0 THEN
               p_deserror := 'Error al crear estado pendiente: ' || cerror;
               RAISE errdatos;
            END IF;
         END IF;

         -- Cobramos
         cerror := f_movrecibo(n_rec, 1, NULL, NULL, n_aux1, n_aux2, n_aux3, d_sup, NULL,
                               n_cdelega, NULL, NULL);

         IF cerror <> 0 THEN
            p_deserror := 'Error al crear estado cobrado: ' || cerror;
            RAISE errdatos;
         END IF;
      ELSIF n_estrecnou = 2 THEN
-- Anular -------------------------------------
         IF n_estrecact = 2 THEN
            p_deserror := 'Recibo ya esta anulado';
            cerror := 101910;
            --RAISE errdatos;
            RAISE mismoestado;
         ELSIF n_estrecact IS NULL
               OR n_estrecact = 1 THEN
            -- Si no existe o esta cobrado,
            -- creamos movimiento pendiente.
            cerror := f_movrecibo(n_rec, 0, NULL, NULL, n_aux1, n_aux2, n_aux3, d_sup, NULL,
                                  n_cdelega, NULL, NULL);

            IF cerror <> 0 THEN
               p_deserror := 'Error al crear estado pendiente: ' || cerror;
               RAISE errdatos;
            END IF;
         END IF;

         -- Anulamos
         cerror := f_movrecibo(n_rec, 2, d_sup, 2, n_aux1, n_aux2, n_aux3, d_sup, NULL,
                               n_cdelega, 0, NULL);

         IF cerror <> 0 THEN
            p_deserror := 'Error al crear estado cobrado: ' || cerror;
            RAISE errdatos;
         END IF;
      END IF;

---------------------------------------------------------
-- CONTROL FINAL                                       --
---------------------------------------------------------
      IF b_warning THEN
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_recibo,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                NULL, NULL, NULL, n_rec);

         IF n_aux <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, v_deswarning);

         IF n_aux <> 0 THEN
            RAISE errdatos;
         END IF;

         cerror := 2;   -- WARNING
      ELSE
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_recibo,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                NULL, NULL, NULL, n_rec);
         cerror := 4;   -- ok
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN mismoestado THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_recibo,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                NULL, NULL, NULL, n_rec);

         IF n_aux <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
         RETURN 2;   -- WARNING
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_recibo,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         cerror := SQLCODE;
         p_deserror := x.proceso || '-' || x.nlinea || '-' || vtraza || ' ' || SQLCODE || ' '
                       || SQLERRM;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_recibo,   -- Fi Bug 14888
                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         RETURN 10;   -- Error incontrolado
   END f_modi_recibo;

   /*************************************************************************
                             procedimiento que ejecuta una carga (parte2 proceso). RECIBOS
          param in psproces   : Número proceso
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_rec_ejecutarcargaproceso(psproces IN NUMBER, p_cproces IN NUMBER)
      -- BUG16130:DRA:15/10/2010
   RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_REC_EJECUTARCARGAPROCESO';

      CURSOR polmigra(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_recibos_allianz a
            WHERE proceso = psproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.proceso
                                AND int_carga_ctrl_linea.nlinea = a.nlinea
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5))
         --Solo las no procesadas
         ORDER BY nlinea;

      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      -- BUG16130:DRA:29/09/2010:Inici
      e_errdatos     EXCEPTION;
   -- BUG16130:DRA:29/09/2010:Fi
   BEGIN
      vtraza := 0;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                          'Parámetro psproces obligatorio.', psproces,
                                          f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 1;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vtraza := 2;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Falta fichero para proceso: ' || psproces);
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                 || v_tfichero || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;
      END IF;

      -- BUG16130:DRA:29/09/2010:Inici
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      -- BUG16130:DRA:29/09/2010:Fi
      vtraza := 4;

      FOR x IN polmigra(psproces) LOOP
         --Leemos los registros de la tabla int no procesados OK
                  -- Bug 0016324. FAL. 18/10/2010
         IF NVL(vtiperr, 0) <> 1 THEN
            -- Fi Bug 0016324
            IF x.tipo_oper = 'ALTA_REC' THEN   --Si es alta
               vtraza := 6;
               verror := f_altarecibo_mig(x, v_deserror);   --Grabamos en las MIG

               IF verror IN(0, -2) THEN   --Si ha ido bien o tenemos avisos.
                  IF verror = -2 THEN   -- Avisos.
                     vtraza := 7;
                     vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 2, 0, NULL,

                                              -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                              x.num_recibo,
                                              -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                              x.ncarga
                                                      -- Fi Bug 16324
                                );

                     IF vnum_err <> 0 THEN
                        --Si fallan esta funciones de gestión salimos del programa
                        RAISE errorini;   --Error que para ejecución
                     END IF;

                     verror := 0;
                  END IF;

                  vtiperr := f_altarecibo_seg(x, v_deserror);   --Grabamos en las SEG

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF vtiperr NOT IN(0, 4, 2) THEN
                     IF k_para_carga <> 1 THEN
                        vtiperr := 4;   -- para que continue con la siguiente linea.
                     ELSE
                        vtiperr := 1;   -- para la carga
                     END IF;
                  END IF;
               -- Fi Bug 0016324
               ELSE   --Si ha ido mal el paso a las MIG lo indicamos con el error orbtenido
                  -- Bug 0016324. FAL. 18/10/2010
                  vtiperr := 1;
                  -- Fi Bug 0016324
                  vtraza := 70;
                  vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 1, 0, NULL,

                                           -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                           x.num_recibo,
                                           -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                           x.ncarga
                                                   -- Fi Bug 16324
                             );

                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  vtraza := 72;
                  vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,
                                                NVL(v_deserror, verror));

                  -- Bug 0016324. FAL. 26/10/2010. Registra la desc. error si informada. en caso contrario el literal verror
                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  verrorfin := TRUE;
                  COMMIT;

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF k_para_carga <> 1 THEN
                     -- Fi Bug 0016324
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  -- Bug 0016324. FAL. 18/10/2010.
                  END IF;
               -- Fi Bug 0016324
               END IF;
            ELSIF x.tipo_oper = 'MODI_REC' THEN
               vtiperr := f_modi_recibo(x, v_deserror);

               IF vtiperr = 0 THEN
                  vtiperr := 4;
               -- Bug 0016324. FAL. 18/10/2010.
               --ELSE
               --   vtiperr := 2;
               -- Fi Bug 0016324
               END IF;

               -- Bug 0016324. FAL. 18/10/2010.
               IF vtiperr NOT IN(4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     vtiperr := 1;   -- para la carga
                  END IF;
               END IF;
            -- Fi Bug 0016324
            END IF;

            IF vtiperr = 1 THEN   --Ha habido error
               verrorfin := TRUE;
            ELSIF vtiperr = 2 THEN   -- Es un warning
               vavisfin := TRUE;
            ELSIF vtiperr = 4 THEN   --Ha ido bien.
               NULL;
            ELSE
               RAISE errorini;   --Error que para ejecución(funciones de gestión)
            END IF;

            COMMIT;
         -- Bug 0016324. FAL. 18/10/2010
         ELSIF vtiperr = 1
               AND k_para_carga = 1 THEN
            vtiperr := 1;
            vcoderror := 151541;
            --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                       f_sysdate, f_sysdate,
                                                                       vtiperr, p_cproces,

                                                                       -- BUG16130:DRA:29/09/2010
                                                                       vcoderror, NULL);

            IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
               vnnumlin := NULL;
               vnum_err := f_proceslin(psproces,
                                       f_axis_literales(180856, k_idiomaaaxis) || ':'
                                       || v_tfichero || ' : ' || vnum_err,
                                       1, vnnumlin);
               RAISE errorini;   --Error que para ejecución
            END IF;

            COMMIT;
            RETURN 0;
         --RAISE vsalir;
         END IF;
      -- Fi Bug 0016324
      END LOOP;

      vtiperr := 4;
      vcoderror := NULL;

      IF vavisfin THEN
         vtiperr := 2;
         vcoderror := 700145;
      END IF;

      IF verrorfin THEN
         vtiperr := 1;
         vcoderror := 151541;
      END IF;

      --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                 f_sysdate, f_sysdate, vtiperr,
                                                                 p_cproces,
                                                                 -- BUG16130:DRA:29/09/2010
                                                                 vcoderror, NULL);
      vtraza := 51;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      --Bug.:17155
      IF vtiperr IN(4, 2) THEN
         vnum_err := pac_gestion_procesos.f_set_carga_fichero(29, v_tfichero, 2, f_sysdate);

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_fichero');
            vnnumlin := NULL;
            vnum_err := f_proceslin(psproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':'
                                    || v_tfichero || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecución
         END IF;
      --Fi Bug.: 17155
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                          psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza,
                                          'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                          'Error:' || 'Insertando estados registros',
                                          psproces,
                                          f_axis_literales(108953, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || 'errorini');
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM,
                                          psproces,
                                          f_axis_literales(103187, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    151541, SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_allianz.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                           || ' : ' || vnum_err);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_rec_ejecutarcargaproceso;

   /*************************************************************************
                                                                                         procedimiento que lee el fichero RECIBOS
          param in p_nombre   : Nombre fichero
          param in p_path   : Nuombre path
          param in psproces   : Número proceso
          param in   out pdeserror   : mensaje de error
      *************************************************************************/
   PROCEDURE f_rec_leefichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      pdeserror OUT VARCHAR2,
      psproces IN NUMBER) IS
      v_line         VARCHAR2(4000);
      v_indice       NUMBER(1) := 0;
      v_npoliza      VARCHAR2(20);
      v_ncertif      seguros.ncertif%TYPE;
      v_nrecibo      recibos.nrecibo%TYPE;
      v_nombre       personas.tbuscar%TYPE;
      v_importe      NUMBER;
      v_fcobro       recibos.fefecto%TYPE;
      v_ind          NUMBER;
      v_ind2         NUMBER;
      num_err        NUMBER;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(1) := NULL;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_ALLIANZ.F_REC_LEEFICHERO';
      registro       int_polizas_allianz%ROWTYPE;
      lsmovagr       NUMBER := 0;
      lnliqmen       NUMBER := NULL;
      lnliqlin       NUMBER := NULL;
      v_empresa      VARCHAR2(100);
      v_producto     VARCHAR2(100);
      v_cobrador     VARCHAR2(100);
      v_ccrebut      VARCHAR2(100);
      v_tipo         VARCHAR2(100);
      v_fvencim      recibos.fvencim%TYPE;
      v_cccobrador   VARCHAR2(100);
      e_object_error EXCEPTION;
      vlinea         NUMBER := 0;
      vtipo          NUMBER;
      v_numerr       NUMBER;
      errgrabarprov  EXCEPTION;
      vcont          NUMBER := 0;
      v_map          map_cabecera.cmapead%TYPE := 'C0031';   -- Carga Recibos ALLIANZ
      v_sec          NUMBER;
      p_txt          VARCHAR2(3000);
   BEGIN
      v_pasexec := 0;
      pdeserror := NULL;
      v_pasexec := 1;

      IF p_nombre IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':p_nombre';
         RAISE e_object_error;
      END IF;

      IF p_path IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':p_path';
         RAISE e_object_error;
      END IF;

      IF psproces IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':psproces';
         RAISE e_object_error;
      END IF;

      v_pasexec := 2;
      pac_map.p_carga_parametros_fichero(v_map, psproces, p_nombre, 0);
      v_pasexec := 3;
      v_numerr := pac_map.carga_map(v_map, v_sec);

      IF v_numerr <> 0 THEN
         RAISE errgrabarprov;
      END IF;

      -- Bug 0016324. FAL. 18/10/2010.
      UPDATE int_recibos_allianz
         SET proceso = psproces
       WHERE sinterf = psproces;

      COMMIT;

      DECLARE
         v_tipo         int_recibos_allianz.tipo_oper%TYPE;

         CURSOR c1 IS
            SELECT ROWID, nlinea, poliza, num_recibo, num_recibo creccia,
                                                                         -- Bug 0016324. FAL. 18/10/2010.
                                                                         proceso,
                                                                                 -- Fi bug 0016324
                                                                                                                                                               -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                                                                 ncarga
              -- Fi Bug 16324
            FROM   int_recibos_allianz
             WHERE proceso = psproces;
      BEGIN
         FOR f1 IN c1 LOOP
            v_pasexec := 5;

            -- Si existeix a rebuts es una modificació.
            SELECT MAX('MODI_REC')
              INTO v_tipo
              FROM recibos
             WHERE creccia = TO_CHAR(f1.creccia)
               AND cempres = k_empresaaxis;

            IF v_tipo IS NULL THEN
               v_tipo := 'ALTA_REC';
            END IF;

            -- Fi bug 0016324
            v_pasexec := 6;
            -- Marcar como pendiente.
            v_numerr :=
               p_marcalinea
                  (psproces, f1.nlinea, v_tipo, 3, 0, NULL,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   f1.num_recibo,   -- Fi Bug 14888
                                    -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   f1.ncarga   -- Fi Bug 16324
                            );

            IF v_numerr <> 0 THEN
               RAISE errgrabarprov;
            END IF;

            v_pasexec := 7;

            UPDATE int_recibos_allianz
               SET tipo_oper = v_tipo,
                   creccia = TO_CHAR(f1.creccia)
             WHERE ROWID = f1.ROWID;
         END LOOP;
      EXCEPTION
         WHEN errgrabarprov THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, 108953, vobj);
            pdeserror := f_axis_literales(108953, k_idiomaaaxis) || ':' || vobj;
            RAISE e_object_error;
         WHEN OTHERS THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
            pdeserror := f_axis_literales(105133, k_idiomaaaxis) || ':' || vlinea || '    '
                         || f_axis_literales(1000136, k_idiomaaaxis) || ':'
                         || TO_NUMBER(v_pasexec + 1) || ' ' || SQLERRM;
            RAISE e_object_error;
      END;

      v_pasexec := 8;
      COMMIT;
   EXCEPTION
      WHEN e_object_error THEN
         ROLLBACK;

         IF pdeserror IS NULL THEN
            pdeserror := f_axis_literales(108953, k_idiomaaaxis);
         END IF;

         NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pdeserror := f_axis_literales(103187, k_idiomaaaxis) || SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
   END f_rec_leefichero;

   /*************************************************************************
                                                         procedimiento que ejecuta una carga (parte1 fichero) RECIBOS
          param in p_nombre   : Nombre fichero
          param in p_path   : Nuombre path
          param out psproces   : Número proceso
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_rec_ejecutarcargafichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_REC_EJECUTARCARGAFICHERO';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      sentencia      VARCHAR2(32000);
      vfichero       UTL_FILE.file_type;
      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER;
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      vsinproc       BOOLEAN := TRUE;   --Indica si tenemos o no proceso
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      -- BUG16130:DRA:29/09/2010:Inici
      e_errdatos     EXCEPTION;
   -- BUG16130:DRA:29/09/2010:Fi
   BEGIN
      vtraza := 0;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_ALLIANZ_REC', p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecución
      END IF;

      psproces := v_sproces;
      vtraza := 1;

      -- BUG16130:DRA:29/09/2010:Inici
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      -- BUG16130:DRA:29/09/2010:Fi
      vtraza := 11;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                 f_sysdate, NULL, 3, p_cproces,

                                                                 -- BUG16130:DRA:29/09/2010
                                                                 NULL, NULL);
      vtraza := 12;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      COMMIT;
      vtraza := 2;
      f_rec_leefichero(p_nombre, p_path, vdeserror, v_sproces);
      vtraza := 3;

      IF vdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    NULL, vdeserror);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecución
         END IF;

         vtraza := 52;
         COMMIT;   --Guardamos la tabla temporal int
         RAISE vsalir;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                          psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                     'Error:' || 'Insertando estados registros');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(108953, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || 'errorini',
                                 1, vnnumlin);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         --coderr := SQLCODE;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || SQLERRM || ' en :' || 1,
                     'Error:' || SQLERRM);
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(103187, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || SQLERRM,
                                 1, vnnumlin);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    151541, SQLERRM);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_rec_ejecutarcargafichero;

   /*************************************************************************
                      procedimiento que ejecuta una carga RECIBOS
          param in p_nombre   : Nombre fichero
          param in p_path   : Nuombre path
          param in  out psproces   : Número proceso (informado para recargar proceso).
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_rec_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_REC_EJECUTARCARGA';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;   -- FAL - 07707/2011 - Bug 0019991
   BEGIN
      vtraza := 0;

      -- Bug 0016324. FAL. 18/10/2010
      SELECT NVL(cpara_error, 0)
        INTO k_para_carga
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      -- Fi Bug 0016324
      IF psproces IS NULL THEN
         vnum_err := pac_cargas_allianz.f_rec_ejecutarcargafichero(p_nombre, p_path,
                                                                   p_cproces,
                                                                   -- BUG16130:DRA:15/10/2010
                                                                   psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_allianz.f_rec_ejecutarcargaproceso(psproces, p_cproces);

      -- BUG16130:DRA:15/10/2010
      IF vnum_err <> 0 THEN
         RAISE vsalir;
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
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN 1;
   END f_rec_ejecutarcarga;

   ---- SINIESTROS ----

   /*************************************************************************
          procedimiento que lee el fichero SINIESTRO
       param in p_nombre   : Nombre fichero
       param in p_path   : Nuombre path
       param in psproces   : Número proceso
       param in   out pdeserror   : mensaje de error
   *************************************************************************/
   PROCEDURE f_sin_leefichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      pdeserror OUT VARCHAR2,
      psproces IN NUMBER) IS
      v_line         VARCHAR2(4000);
      v_indice       NUMBER(1) := 0;
      v_npoliza      VARCHAR2(20);
      v_ncertif      seguros.ncertif%TYPE;
      v_nrecibo      recibos.nrecibo%TYPE;
      v_nombre       personas.tbuscar%TYPE;
      v_importe      NUMBER;
      v_fcobro       recibos.fefecto%TYPE;
      v_ind          NUMBER;
      v_ind2         NUMBER;
      num_err        NUMBER;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(1) := NULL;
      vobj           VARCHAR2(200) := 'PAC_CARGAS_ALLIANZ.F_SIN_LEEFICHERO';
      registro       int_polizas_allianz%ROWTYPE;
      lsmovagr       NUMBER := 0;
      lnliqmen       NUMBER := NULL;
      lnliqlin       NUMBER := NULL;
      v_empresa      VARCHAR2(100);
      v_producto     VARCHAR2(100);
      v_cobrador     VARCHAR2(100);
      v_ccrebut      VARCHAR2(100);
      v_tipo         VARCHAR2(100);
      v_fvencim      recibos.fvencim%TYPE;
      v_cccobrador   VARCHAR2(100);
      e_object_error EXCEPTION;
      vlinea         NUMBER := 0;
      vtipo          NUMBER;
      v_numerr       NUMBER;
      errgrabarprov  EXCEPTION;
      vcont          NUMBER := 0;
      v_map          map_cabecera.cmapead%TYPE := 'C0032';   -- Carga Siniestros ALLIANZ
      v_sec          NUMBER;
   BEGIN
      v_pasexec := 0;
      pdeserror := NULL;
      v_pasexec := 1;

      IF p_nombre IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':p_nombre';
         RAISE e_object_error;
      END IF;

      IF p_path IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':p_path';
         RAISE e_object_error;
      END IF;

      IF psproces IS NULL THEN
         pdeserror := f_axis_literales(103835, k_idiomaaaxis) || ':psproces';
         RAISE e_object_error;
      END IF;

      v_pasexec := 2;
      pac_map.p_carga_parametros_fichero(v_map, psproces, p_nombre, 0);
      v_pasexec := 3;
      v_numerr := pac_map.carga_map(v_map, v_sec);

      IF v_numerr <> 0 THEN
         RAISE errgrabarprov;
      END IF;

      -- Bug 0016324. FAL. 18/10/2010.
      UPDATE int_siniestros_allianz
         SET proceso = psproces
       WHERE sinterf = psproces;

      COMMIT;

      DECLARE
         v_tipo         int_siniestros_allianz.tipo_oper%TYPE;

         CURSOR c1 IS
            SELECT ROWID, nlinea, poliza, num_siniestro, num_siniestro csincia,
                                                                               -- Bug 0016324. FAL. 18/10/2010.
                                                                               proceso,

                   -- Fi bug 0016324
                   -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   ncarga
              -- Fi Bug 16324
            FROM   int_siniestros_allianz
             WHERE proceso = psproces;
      BEGIN
         FOR f1 IN c1 LOOP
            v_pasexec := 5;

            -- Si existeix a sin_siniestros_referencias es una modificació.
            -- SELECT MAX('MODI_SIN')
            --   INTO v_tipo
            --    FROM sin_siniestro_referencias si
            --  WHERE si.ctipref = 1
            --     AND si.trefext = f1.csincia;
            SELECT MAX('MODI_SIN')
              INTO v_tipo
              FROM sin_siniestro SIN, seguros seg
             WHERE SIN.nsincia = TO_CHAR(f1.csincia)
               AND seg.sseguro = SIN.sseguro
               AND seg.cpolcia = TO_CHAR(f1.poliza);

            IF v_tipo IS NULL THEN
               v_tipo := 'ALTA_SIN';
            END IF;

            -- Fi bug 0016324
            v_pasexec := 6;
            -- Marcar como pendiente.
            v_numerr :=
               p_marcalinea
                  (psproces, f1.nlinea, v_tipo, 3, 0, NULL,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   f1.num_siniestro,   -- Fi Bug 14888
                                       -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   f1.ncarga   -- Fi Bug 16324
                            );

            IF v_numerr <> 0 THEN
               RAISE errgrabarprov;
            END IF;

            v_pasexec := 7;

            UPDATE int_siniestros_allianz
               SET tipo_oper = v_tipo,
                   csincia = f1.csincia
             WHERE ROWID = f1.ROWID;
         END LOOP;
      EXCEPTION
         WHEN errgrabarprov THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, 108953, vobj);
            pdeserror := f_axis_literales(108953, k_idiomaaaxis) || ':' || vobj;
            RAISE e_object_error;
         WHEN OTHERS THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
            pdeserror := f_axis_literales(105133, k_idiomaaaxis) || ':' || vlinea || '    '
                         || f_axis_literales(1000136, k_idiomaaaxis) || ':'
                         || TO_NUMBER(v_pasexec + 1) || ' ' || SQLERRM;
            RAISE e_object_error;
      END;

      v_pasexec := 8;
      COMMIT;
   EXCEPTION
      WHEN e_object_error THEN
         ROLLBACK;

         IF pdeserror IS NULL THEN
            pdeserror := f_axis_literales(108953, k_idiomaaaxis);
         END IF;

         NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pdeserror := f_axis_literales(103187, k_idiomaaaxis) || SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
   END f_sin_leefichero;

   /*************************************************************************
                                                         procedimiento que da de alta recibo en las mig
          param in x : registro tipo INT_RECIBOS_ALLIANZ
      *************************************************************************/
   FUNCTION f_altasiniestro_mig(
      x IN OUT int_siniestros_allianz%ROWTYPE,
      pterror IN OUT VARCHAR2)
      -- Bug 0016324. FAL. 26/10/2010. Añadimos desc. error OUT para asignarle sqlerrm cuando sale por when others (normalmente registra errores sobre las tablas mig)
   RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_ALTASINIESTRO_MIG';
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      errdatos       EXCEPTION;
      --Tablas
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_sin      mig_sin_siniestro%ROWTYPE;
      v_mig_smv      mig_sin_movsiniestro%ROWTYPE;
      v_mig_tra      mig_sin_tramitacion%ROWTYPE;
      v_mig_trm      mig_sin_tramita_movimiento%ROWTYPE;
      v_mig_res      mig_sin_tramita_reserva%ROWTYPE;
      v_mig_tpa      mig_sin_tramita_pago%ROWTYPE;
      v_mig_per      mig_personas%ROWTYPE;
      v_mig_tmp      mig_sin_tramita_movpago%ROWTYPE;
      v_mig_tpg      mig_sin_tramita_pago_gar%ROWTYPE;
      v_cunitra      VARCHAR2(250);
      v_ctramit      VARCHAR2(250);
      v_sperson      per_personas.sperson%TYPE;
      v_norden       NUMBER := 1;
      verror         VARCHAR2(1000);
      cerror         NUMBER;
      vtraza         NUMBER;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_rowid_ini    ROWID;
      pid            VARCHAR2(200);
      b_warning      BOOLEAN;
      v_csincia      VARCHAR2(250);
      n_aux          NUMBER;
      n_seg          seguros.sseguro%TYPE;
      n_pro          seguros.sproduc%TYPE;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      pid := x.nlinea;
      b_warning := FALSE;
      vtraza := 1005;

      SELECT ROWID
        INTO v_rowid_ini
        FROM int_siniestros_allianz
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      --Inicializamos la cabecera de la carga
      vtraza := 1010;
      v_ncarga := f_next_carga;
      x.ncarga := v_ncarga;
      -- Bug 0016324. FAL. 26/10/2010. Asignamos v_ncarga antes de posible error para registrarlo en la linea de carga
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Siniestros', v_seq);
      vtraza := 1015;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, pid, 'OK');

-------------------- Valida ---------------------
      vtraza := 1025;
      v_csincia := x.num_siniestro;
      x.csincia := v_csincia;
      vtraza := 1030;
      n_pro := f_buscavalor('CRT_PRODALLIANZ', x.ramo);

      BEGIN
         SELECT sseguro, sproduc
           INTO n_seg, n_pro
           FROM seguros
          WHERE cpolcia = TO_CHAR(x.poliza)
            AND cempres = k_empresaaxis
            AND sproduc = n_pro;
      EXCEPTION
         WHEN OTHERS THEN
            n_pro := NULL;
            n_seg := NULL;
      END;

      vtraza := 1035;

       /* SELECT MAX(sproduc)
                INTO n_pro
          FROM seguros
         WHERE sseguro = n_seg;
      */
      IF n_seg IS NULL THEN
         verror := 'No existe póliza del recibo cia: ' || v_csincia || ' seg: ' || n_seg;
         cerror := 140897;
         RAISE errdatos;
      END IF;

-------------------- INICI ---------------------
      vtraza := 1045;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SEGUROS', 0);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SIN_SINIESTRO', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SIN_TRAMITACION', 2);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SIN_TRAMITA_MOVIMIENTO', 3);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SIN_MOVSINIESTRO', 4);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SIN_TRAMITA_RESERVA', 5);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_PERSONAS', 6);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SIN_TRAMITA_PAGO', 7);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SIN_TRAMITA_MOVPAGO', 8);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_SINIESTROS_ALLIANZ', 'MIG_SIN_TRAMITA_PAGO_GAR', 9);

      vtraza := 1050;
      v_mig_sin.mig_pk := v_ncarga || '/' || x.csincia;
      --v_mig_sin.mig_fk := v_csincia;
      v_mig_sin.mig_fk := v_ncarga || '/' || x.csincia;
      v_mig_sin.ncarga := v_ncarga;
      v_mig_sin.cestmig := 1;
      -- Necesitamos informar mig_seguros para join con mig_sin_siniestros
      vtraza := 1055;

      SELECT v_ncarga ncarga, -4 cestmig,
                                         -- v_csincia mig_pk,  -- jlb
                                         v_mig_sin.mig_pk mig_pk,
                                                                 --v_mig_sin.mig_pk mig_fk,
                                                                 v_mig_sin.mig_fk mig_fk,
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
       WHERE sseguro = n_seg;

      vtraza := 1060;

      INSERT INTO mig_seguros
           VALUES v_mig_seg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

      vtraza := 1065;
      --Información de sin siniestro
      v_mig_sin.nriesgo := 1;
      v_mig_sin.sseguro := v_mig_seg.sseguro;
      v_mig_sin.nsinies := 0;   --Lo calcula despues la función de pac_mig_axis
      v_mig_sin.fsinies := TO_DATE(TRIM(x.fh_siniestro), 'dd/mm/yyyy');
      v_mig_sin.fnotifi := TO_DATE(TRIM(x.fh_siniestro), 'dd/mm/yyyy');
      v_mig_sin.tsinies := x.causa || '-' || x.descr_siniestro;
      v_mig_sin.cusualt := f_user;
      v_mig_sin.falta := f_sysdate;

      IF v_mig_sin.fsinies IS NULL THEN
         verror := 'Fecha de siniestro nula : ' || x.num_siniestro;
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1070;

      SELECT MAX(nmovimi)
        INTO n_aux
        FROM movseguro
       WHERE sseguro = n_seg
         AND fefecto <= v_mig_sin.fsinies
         AND cmovseg <> 52;

      v_mig_sin.nmovimi := n_aux;
      vtraza := 1075;

      IF v_mig_sin.nmovimi IS NULL THEN
         verror := 'No se encuentra el movimiento para la fecha : ' || x.num_siniestro;
         cerror := 104348;
         RAISE errdatos;
      END IF;

      vtraza := 1080;

      INSERT INTO mig_sin_siniestro
           VALUES v_mig_sin
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 1, v_mig_sin.mig_pk);

      --SIN_TRAMITACION
      vtraza := 1090;
      v_mig_tra.ncarga := v_ncarga;
      v_mig_tra.cestmig := 1;
      v_mig_tra.mig_pk := v_ncarga || '/' || x.csincia || '/' || 0;
      v_mig_tra.mig_fk := v_ncarga || '/' || x.csincia;
      v_mig_tra.nsinies := 0;   --Lo  de sin_siniestro el pac_mig_axis
      v_mig_tra.ntramit := 0;
      v_mig_tra.ctramit := 0;
      v_mig_tra.cinform := 1;
      v_mig_tra.cusualt := f_user;
      v_mig_tra.falta := f_sysdate;

      INSERT INTO mig_sin_tramitacion
           VALUES v_mig_tra
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 2, v_mig_tra.mig_pk);

      vtraza := 1100;
      --SIN_TRAMITA_MOVIMIENTO
      vtraza := 1110;
      v_mig_trm.ncarga := v_ncarga;
      v_mig_trm.cestmig := 1;
      v_mig_trm.mig_pk := v_ncarga || '/' || x.csincia || '/' || 0;
      v_mig_trm.mig_fk := v_mig_tra.mig_pk;
      v_mig_trm.nsinies := 0;   --Lo  de sin_siniestro el pac_mig_axis
      v_mig_trm.ntramit := 0;
      v_mig_trm.nmovtra := 0;
      vtraza := 1115;
      cerror := pac_siniestros.f_get_unitradefecte(k_empresaaxis, v_cunitra, v_ctramit);

      IF cerror <> 0 THEN
         verror := 'Error recuperando los tramitadores para la empresa : ' || k_empresaaxis;
         RAISE errdatos;
      END IF;

      v_mig_trm.cunitra := v_cunitra;
      v_mig_trm.ctramitad := v_ctramit;
      -- v_mig_trm.cesttra := pac_cargas_allianz.f_buscavalor('CRT_ESTADOSIN', x.estadosiniestro);
      v_mig_trm.cesttra := 0;   -- FAL. No llega estado siniestro. Suponemos 'abierto'
      vtraza := 1120;
      /*
                                           IF v_mig_trm.cesttra IS NULL THEN
               verror := 'int_codigos_emp no definido: ' || x.estadosiniestro || ' (CRT_ESTADOSIN)';
               cerror := 140704;
               RAISE errdatos;
            END IF;
      */
      v_mig_trm.csubtra := 0;
      v_mig_trm.festtra := v_mig_sin.fsinies;
      vtraza := 1125;
      v_mig_trm.cusualt := f_user;
      v_mig_trm.falta := f_sysdate;

      INSERT INTO mig_sin_tramita_movimiento
           VALUES v_mig_trm
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 3, v_mig_trm.mig_pk);

      --SIN_MOVSINIESTRO
      vtraza := 1130;
      v_mig_smv.ncarga := v_ncarga;
      v_mig_smv.cestmig := 1;
      v_mig_smv.mig_pk := v_ncarga || '/' || x.csincia || '/' || 0;
      v_mig_smv.mig_fk := v_mig_sin.mig_pk;
      v_mig_smv.nsinies := 0;   --Lo recupera en el pac_mig_axis
      v_mig_smv.nmovsin := 0;
      --v_mig_smv.cestsin := v_mig_trm.cesttra;
      v_mig_smv.cestsin := 0;
      -- lo abrimos en estado pendiente, si esta cerrado marcaremos un nuevo movieminto
      v_mig_smv.festsin := v_mig_sin.fsinies;
      v_mig_smv.cunitra := v_mig_trm.cunitra;
      v_mig_smv.ctramitad := v_mig_trm.ctramitad;
      vtraza := 1135;
      v_mig_smv.cusualt := f_user;
      v_mig_smv.falta := f_sysdate;

      INSERT INTO mig_sin_movsiniestro
           VALUES v_mig_smv
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 4, v_mig_smv.mig_pk);

      -- si esta cerrado
      IF x.fh_termino IS NOT NULL THEN
         v_mig_smv.cestsin := 1;
         v_mig_smv.festsin := TO_DATE(TRIM(x.fh_termino), 'dd/mm/yyyy');
         v_mig_smv.mig_pk := v_ncarga || '/' || x.csincia || '/' || 1;
         v_mig_smv.nmovsin := 1;   -- este es el de anulación

         INSERT INTO mig_sin_movsiniestro
              VALUES v_mig_smv
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (1, v_ncarga, 4, v_mig_smv.mig_pk);
      END IF;

      --SIN_TRAMITA_RESERVA
      vtraza := 1140;
      v_mig_res.ncarga := v_ncarga;
      v_mig_res.cestmig := 1;
      v_mig_res.cestmig := 1;
      v_mig_res.mig_pk := v_ncarga || '/' || x.csincia || '/' || 0;
      v_mig_res.mig_fk := v_mig_tra.mig_pk;
      v_mig_res.nsinies := 0;
      v_mig_res.ntramit := v_mig_tra.ntramit;
      v_mig_res.nmovres := 0;
      v_mig_res.ctipres := 1;   --Indemni
      v_mig_res.ccalres := 0;
      v_mig_res.fmovres := v_mig_sin.fsinies;
      v_mig_res.cmonres := 'EUR';
      --      v_mig_res.ireserva := NVL(TRIM(x.totalprovisiones), 0);
      --      v_mig_res.ireserva := NVL(TRIM(x.pagos_netos), 0); -- FAL. int_siniestros_allianz. El importe de la reserva no viene ??? Asigno pagos_netos d momento
      v_mig_res.ireserva := 0;
      -- FAL. No viene importe reserva en fich sini allianz. Asigno 0 de momento
      v_mig_res.cusualt := f_user;
      v_mig_res.falta := f_sysdate;

      INSERT INTO mig_sin_tramita_reserva
           VALUES v_mig_res
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 5, v_mig_res.mig_pk);

      --MIG_PERSONA cargamos mig_personas por las joins que hay con mig_tramita_pago
      vtraza := 1150;

      BEGIN
         SELECT sperson
           INTO v_sperson
           FROM seguros s, asegurados a
          WHERE s.sseguro = n_seg
            AND a.sseguro = s.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            verror := 'No se encuentra el Asegurado de la póliza: ' || n_seg;
            cerror := 9001086;
            RAISE errdatos;
      END;

      v_mig_per.ncarga := v_ncarga;
      v_mig_per.cestmig := -4;
      v_mig_per.mig_pk := v_ncarga || '/' || x.csincia || '/' || v_sperson;
      v_mig_per.idperson := v_sperson;
      v_mig_per.ctipide := 0;
      v_mig_per.cestper := 0;
      v_mig_per.cpertip := 0;
      v_mig_per.swpubli := 0;
      v_mig_per.tapelli1 := ' ';

      INSERT INTO mig_personas
           VALUES v_mig_per
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 6, v_mig_per.mig_pk);

      v_norden := 1;
      --SIN_TRAMITA_PAGO JLB que insert siempre aunque sea 0
      --     IF NVL(TRIM(x.pagos_netos), 0) <> 0 THEN
      --Parte de pagos
      vtraza := 1150;
      v_mig_tpa.ncarga := v_ncarga;
      v_mig_tpa.cestmig := 1;
      --carga - csincia - pago
      v_mig_tpa.mig_pk := v_ncarga || '/' || x.csincia || '/' || 2;
      v_mig_tpa.mig_fk2 := v_mig_tra.mig_pk;
      v_mig_tpa.mig_fk := v_mig_per.mig_pk;
      v_mig_tpa.sidepag := 0;
      v_mig_tpa.nsinies := 0;
      v_mig_tpa.ntramit := v_mig_tra.ntramit;
      v_mig_tpa.ctipdes := 1;
      v_mig_tpa.ctippag := 2;
      v_mig_tpa.cconpag := 1;   --Indemni
      v_mig_tpa.sperson := v_mig_per.idperson;
      v_mig_tpa.ccauind := 0;   --otros
      v_mig_tpa.cforpag := 2;   --Pago
      v_mig_tpa.isinret := NVL(TRIM(x.pagos_netos), 0);
      v_mig_tpa.cusualt := f_user;
      v_mig_tpa.falta := f_sysdate;

      INSERT INTO mig_sin_tramita_pago
           VALUES v_mig_tpa
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 7, v_mig_tpa.mig_pk);

      vtraza := 1160;
      --MIG_SIN_TRAMITA_MOVPAGO
      v_mig_tmp.ncarga := v_ncarga;
      v_mig_tmp.cestmig := 1;
      v_mig_tmp.mig_pk := v_ncarga || '/' || x.csincia || '/' || 2;
      v_mig_tmp.mig_fk := v_mig_tpa.mig_pk;
      v_mig_tmp.sidepag := 0;
      v_mig_tmp.nmovpag := 0;
      v_mig_tmp.cestpag := 1;
      v_mig_tmp.fefepag := v_mig_sin.fsinies;
      v_mig_tmp.cestval := 1;   -- Validado
      v_mig_tmp.cusualt := f_user;
      v_mig_tmp.falta := f_sysdate;

      INSERT INTO mig_sin_tramita_movpago
           VALUES v_mig_tmp
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 8, v_mig_tmp.mig_pk);

      vtraza := 1170;
      --MIG_SIN_TRAMITA_PAGO_GAR
      v_mig_tpg.ncarga := v_ncarga;
      v_mig_tpg.cestmig := 1;
      v_mig_tpg.mig_pk := v_ncarga || '/' || x.csincia || '/' || 2;
      v_mig_tpg.mig_fk := v_mig_tpa.mig_pk;
      v_mig_tpg.sidepag := 0;
      v_mig_tpg.ctipres := v_mig_res.ctipres;
      v_mig_tpg.nmovres := v_mig_res.nmovres;
      v_mig_tpg.cusualt := f_user;
      v_mig_tpg.falta := f_sysdate;
      v_mig_tpg.norden := v_norden + 1;

      INSERT INTO mig_sin_tramita_pago_gar
           VALUES v_mig_tpg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 9, v_mig_tpg.mig_pk);

      --      END IF;

      ---Parte de Recobros
      --      IF NVL(TRIM(x.totalrecobros), 0) = 0 THEN       -- FAL. No llegan importe recobro en fich sini allianz. asigno 0 de momento
      --Parte de pagos
      vtraza := 1180;
      v_mig_tpa.ncarga := v_ncarga;
      v_mig_tpa.cestmig := 1;
      --carga - csincia - pago
      v_mig_tpa.mig_pk := v_ncarga || '/' || x.csincia || '/' || 7;
      v_mig_tpa.mig_fk2 := v_mig_tra.mig_pk;
      v_mig_tpa.mig_fk := v_mig_per.mig_pk;
      v_mig_tpa.sidepag := 0;
      v_mig_tpa.nsinies := 0;
      v_mig_tpa.ntramit := v_mig_tra.ntramit;
      v_mig_tpa.ctipdes := 1;
      v_mig_tpa.ctippag := 7;
      v_mig_tpa.cconpag := 1;   --Indemni
      v_mig_tpa.sperson := v_mig_per.idperson;
      v_mig_tpa.ccauind := 0;   --otros
      v_mig_tpa.cforpag := 7;   --Recobro
      --         v_mig_tpa.isinret := NVL(TRIM(x.totalrecobros), 0);      -- FAL. No llegan importe recobro en fich sini allianz. asigno 0 de momento
      v_mig_tpa.isinret := 0;
      v_mig_tpa.cusualt := f_user;
      v_mig_tpa.falta := f_sysdate;

      INSERT INTO mig_sin_tramita_pago
           VALUES v_mig_tpa
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 7, v_mig_tpa.mig_pk);

      vtraza := 1190;
      --MIG_SIN_TRAMITA_MOVPAGO
      v_mig_tmp.ncarga := v_ncarga;
      v_mig_tmp.cestmig := 1;
      v_mig_tmp.mig_pk := v_ncarga || '/' || x.csincia || '/' || 7;
      v_mig_tmp.mig_fk := v_mig_tpa.mig_pk;
      v_mig_tmp.sidepag := 0;
      v_mig_tmp.nmovpag := 0;
      v_mig_tmp.cestpag := 1;
      v_mig_tmp.fefepag := v_mig_sin.fsinies;
      v_mig_tmp.cestval := 1;   -- Validado.
      v_mig_tmp.cusualt := f_user;
      v_mig_tmp.falta := f_sysdate;

      INSERT INTO mig_sin_tramita_movpago
           VALUES v_mig_tmp
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 8, v_mig_tmp.mig_pk);

      vtraza := 1200;
      --MIG_SIN_TRAMITA_PAGO_GAR
      v_mig_tpg.ncarga := v_ncarga;
      v_mig_tpg.cestmig := 1;
      v_mig_tpg.mig_pk := v_ncarga || '/' || x.csincia || '/' || 7;
      v_mig_tpg.mig_fk := v_mig_tpa.mig_pk;
      v_mig_tpg.sidepag := 0;
      v_mig_tpg.ctipres := v_mig_res.ctipres;
      v_mig_tpg.nmovres := v_mig_res.nmovres;
      v_mig_tpg.cusualt := f_user;
      v_mig_tpg.falta := f_sysdate;
      v_mig_tpg.norden := v_norden + 1;

      INSERT INTO mig_sin_tramita_pago_gar
           VALUES v_mig_tpg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 9, v_mig_tpg.mig_pk);

      -- END IF;            -- FAL. No llegan importe recobro en fich sini allianz. asigno 0 de momento
      vtraza := 1210;

-------------------- FINAL ---------------------
      UPDATE int_siniestros_allianz
         SET ncarga = v_ncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1220;
      x.ncarga := v_ncarga;
      COMMIT;

      IF b_warning THEN
         cerror := -2;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error ' || cerror, verror, x.proceso,
                                          'Error ' || cerror || ' ' || verror);
         pterror := verror;
         -- Bug 0016324. FAL. 26/10/2010. Informa desc. error para registrar linea de error y no aparezca un literal en el detalle->mensajes de la pnatalla resultado cargas
         RETURN cerror;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'ERROR ' || SQLCODE, SQLERRM,
                                          x.proceso, 'Error ' || SQLCODE || ' ' || SQLERRM);
         cerror := SQLCODE;   -- Bug 0016324. FAL. 26/10/2010. Devuelve sqlcode como error
         pterror := SQLERRM;
         -- Bug 0016324. FAL. 26/10/2010. Devuelve sqlerrm como desc. error;
         RETURN cerror;
   END f_altasiniestro_mig;

   /*************************************************************************
                   procedimiento que genera movimientos siniestro
          param in x : registro tipo int_recibos_ALLIANZ
          param p_deserror out: Descripción del error si existe.
          Devuelve TIPOERROR ( 1-Ha habido error, 2-Es un warning, 4-Ha ido bien, x-Error incontrolado).
          --
          Para modificar una póliza, los siguientes campos son obligatorios:
          - póliza cia
          - fecha efecto (se toma como fecha operacion).
          - estado recibo.
          --
      *************************************************************************/
   FUNCTION f_modi_siniestro(
      x IN OUT int_siniestros_allianz%ROWTYPE,
      p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_MODI_SINIESTRO';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_sin          sin_siniestro.nsinies%TYPE;
      v_cesttranou   sin_tramita_movimiento.cesttra%TYPE;
      v_cesttraant   sin_tramita_movimiento.cesttra%TYPE;
      v_nmovtra      sin_tramita_movimiento.nmovtra%TYPE;
      v_cunitra      sin_tramita_movimiento.cunitra%TYPE;
      v_ctramit      sin_tramita_movimiento.ctramitad%TYPE;
      v_nmovsin      sin_movsiniestro.nmovsin%TYPE;
      v_isinret      sin_tramita_pago.isinret%TYPE;
      n_pro          seguros.sproduc%TYPE;
      v_fsinies      DATE;
      n_aux          NUMBER;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      v_sseguro      seguros.sseguro%TYPE;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
---------------------------------------------------------
-- VALIDAR CAMPOS CLAVE: Recibo cia.                   --
---------------------------------------------------------
      vtraza := 1010;

      IF LTRIM(x.csincia) IS NULL THEN
         p_deserror := 'Número Siniestro cia sin informar';
         cerror := 101731;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      n_pro := f_buscavalor('CRT_PRODALLIANZ', x.ramo);
      vtraza := 1016;

      SELECT nsinies, SIN.sseguro
        INTO n_sin, v_sseguro
        FROM sin_siniestro SIN, seguros seg
       WHERE nsincia = TO_CHAR(x.csincia)
         AND seg.sseguro = SIN.sseguro
         AND seg.cpolcia = TO_CHAR(x.poliza)
         AND seg.sproduc = n_pro
         AND seg.cempres = k_empresaaxis;

      IF n_sin IS NULL THEN
         p_deserror := 'Número Siniestro cia no existe: ' || x.csincia;
         cerror := 101731;
         RAISE errdatos;
      END IF;

      vtraza := 1020;

      SELECT MAX(nmovtra)
        INTO v_nmovtra
        FROM sin_tramita_movimiento
       WHERE nsinies = n_sin;

      vtraza := 1025;

      IF v_nmovtra IS NULL THEN
         p_deserror := 'Número de movimiento de tramitación no existe para cia: ' || x.csincia;
         cerror := 9001443;
         RAISE errdatos;
      END IF;

      --v_cesttranou := pac_cargas_asefa.f_buscavalor('CRT_ESTADOSIN', x.estadosiniestro); -- FAL.  No llega estado sini. Asigno 'abierto'
      v_cesttranou := 0;

      IF x.fh_termino IS NOT NULL THEN
         v_cesttranou := 1;
         v_fsinies := TO_DATE(TRIM(x.fh_termino), 'dd/mm/yyyy');
      ELSE
         v_cesttranou := 0;
         v_fsinies := TO_DATE(TRIM(x.fh_siniestro), 'dd/mm/yyyy');
      END IF;

      vtraza := 1030;

      SELECT cesttra
        INTO v_cesttraant
        FROM sin_tramita_movimiento s
       WHERE nsinies = n_sin
         AND nmovtra = v_nmovtra;

      --IF v_cesttranou = v_cesttraant THEN
      IF v_cesttranou <> v_cesttraant THEN
         --  p_deserror := 'El siniestro ya está en este estado cesttra:' || v_cesttraant;
         --  cerror := 805692;
         --  RAISE errdatos;
         --END IF;
         cerror := pac_siniestros.f_get_unitradefecte(k_empresaaxis, v_cunitra, v_ctramit);

         IF cerror <> 0 THEN
            p_deserror := 'Error recuperando los tramitadores para la empresa : '
                          || k_empresaaxis;
            RAISE errdatos;
         END IF;

         --Sin Tramita movimiento
         INSERT INTO sin_tramita_movimiento
                     (nsinies, ntramit, nmovtra, cunitra, ctramitad, cesttra, csubtra,
                      festtra, cusualt, falta)
              VALUES (n_sin, 0,(v_nmovtra + 1), v_cunitra, v_ctramit, v_cesttranou, 0,
                      v_fsinies, f_user, f_sysdate);

         --sin movsiniestro
         SELECT MAX(nmovsin)
           INTO v_nmovsin
           FROM sin_movsiniestro
          WHERE nsinies = n_sin;

         vtraza := 1025;

         IF v_nmovsin IS NULL THEN
            p_deserror := 'Número de movimiento de siniestro no existe para cia: '
                          || x.csincia;
            cerror := 9001443;
            RAISE errdatos;
         END IF;

         INSERT INTO sin_movsiniestro
                     (nsinies, nmovsin, cestsin, festsin, ccauest, cunitra,
                      ctramitad, cusualt, falta)
              VALUES (n_sin, v_nmovsin + 1, v_cesttranou, v_fsinies, NULL, v_cunitra,
                      v_ctramit, f_user, f_sysdate);
      END IF;

      -- actualizo los pagos JLB
      --IF NVL(TRIM(x.pagos_netos), 0) <> 0 THEN
      --Parte de pagos
      SELECT NVL(SUM(isinret), 0)
        INTO v_isinret
        FROM sin_tramita_pago
       WHERE nsinies = n_sin;

      IF NVL(v_isinret, 0) <> NVL(TRIM(x.pagos_netos), 0) THEN
         UPDATE sin_tramita_pago
            SET isinret = NVL(TRIM(x.pagos_netos), 0),
                cusualt = f_user,
                falta = f_sysdate
          WHERE nsinies = n_sin;
      END IF;

      -- actualizo causa y motivo
      UPDATE sin_siniestro
         SET tsinies = x.causa || '-' || x.descr_siniestro
       WHERE nsinies = n_sin;

---------------------------------------------------------
-- CONTROL FINAL                                       --
---------------------------------------------------------
      IF b_warning THEN
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, v_sseguro,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_siniestro,   -- Fi Bug 14888
                                   -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                n_sin, NULL, NULL, NULL);

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
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, v_sseguro,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_siniestro,   -- Fi Bug 14888
                                   -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                n_sin, NULL, NULL, NULL);
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_siniestro,   -- Fi Bug 14888
                                   -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (traza=' || vtraza || ') ' || SQLCODE
                       || ' ' || SQLERRM;
         RETURN 10;   -- Error incontrolado
   END f_modi_siniestro;

   /*************************************************************************
                             Función que da de alta siniestro en las SEG
          param in x : registro tipo int_SINIESTRO_ALLIANZ
          return : 1 si ha habido error
                   2 si ha habido warning
                   4 si ha ido bien
      *************************************************************************/
   FUNCTION f_altasiniestro_seg(x IN OUT int_siniestros_allianz%ROWTYPE)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_altasiniestro_SEG';
      v_i            BOOLEAN := FALSE;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
      verrorgrab     EXCEPTION;
      vtraza         NUMBER := 0;
      vtiperr        NUMBER;
      vnsinies       sin_siniestro.nsinies%TYPE;
      vsrefext       sin_siniestro_referencias.srefext%TYPE;
      vccompani      seguros.ccompani%TYPE;
      vsseguro       seguros.sseguro%TYPE;
   BEGIN
      vtraza := 100;
      pac_mig_axis.p_migra_cargas(x.nlinea, 'C', x.ncarga, 'DEL');
      --Cargamos las SEG para la póliza (ncarga)
      vtraza := 110;

      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 200;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_siniestro,   -- Fi Bug 14888
                                   -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         v_i := TRUE;
         vtraza := 201;
         vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 151840, reg.incid);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         vtiperr := 1;
      END LOOP;

      BEGIN
         SELECT nsinies
           INTO vnsinies
           FROM mig_sin_siniestro
          WHERE ncarga = x.ncarga;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;   --JRH IMP de momento
      END;

      IF NOT v_i THEN
         SELECT seg.ccompani, seg.sseguro
           INTO vccompani, vsseguro
           FROM seguros seg, sin_siniestro SIN
          WHERE SIN.nsinies = vnsinies
            AND seg.sseguro = SIN.sseguro;

         UPDATE sin_siniestro
            SET nsincia = TO_CHAR(x.csincia),
                ccompani = vccompani
          WHERE nsinies = vnsinies;
      END IF;

      IF NOT v_i THEN
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = x.ncarga
                        AND tipo = 'W') LOOP   --Miramos si han habido warnings.
            vtraza := 202;
            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 2, 1, vsseguro,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.num_siniestro,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga,   -- Fi Bug 16324
                   vnsinies, NULL, NULL, NULL);

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;

            vtraza := 203;
            vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, reg.incid);

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;

            v_i := TRUE;
         END LOOP;

         vtiperr := 2;
      END IF;

      IF NOT v_i THEN
         --Esto quiere decir que no ha habido ningún error (lo indicamos también).
         vtraza := 204;

         BEGIN
            vtraza := 500;
            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 4, 1, vsseguro,
                   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.num_siniestro,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga,   -- Fi Bug 16324
                   vnsinies, NULL, NULL, NULL);

            IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
               RAISE verrorgrab;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               pac_cargas_allianz.p_genera_logs(vobj, vtraza, SQLCODE,
                                                'Error al guardar csincia ' || x.csincia,
                                                x.proceso,
                                                'Error al guardar csincia ' || x.csincia);
         END;

         vtiperr := 4;
      END IF;

      RETURN vtiperr;   --Devolvemos el tipo error que ha habido
   EXCEPTION
      WHEN verrorgrab THEN
         RETURN 10;
      WHEN OTHERS THEN
         RETURN 10;
   END f_altasiniestro_seg;

   /*************************************************************************
                            procedimiento que ejecuta una carga (parte1 fichero) SINIESTRO
       param in p_nombre   : Nombre fichero
       param in p_path   : Nuombre path
       param out psproces   : Número proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutarcargafichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_SIN_EJECUTARCARGAFICHERO';
      linea          NUMBER := 0;
      pcarga         NUMBER;
      sentencia      VARCHAR2(32000);
      vfichero       UTL_FILE.file_type;
      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      v_sproces      NUMBER;
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      vsinproc       BOOLEAN := TRUE;   --Indica si tenemos o no proceso
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      -- BUG16130:DRA:29/09/2010:Inici
      e_errdatos     EXCEPTION;
   -- BUG16130:DRA:29/09/2010:Fi
   BEGIN
      vtraza := 0;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_ALLIANZ_SIN', p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecución
      END IF;

      psproces := v_sproces;
      vtraza := 1;

      -- BUG16130:DRA:29/09/2010:Inici
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || REPLACE(vobj, 'PRO', '');
         RAISE e_errdatos;
      END IF;

      -- BUG16130:DRA:29/09/2010:Fi
      vtraza := 4;
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                 f_sysdate, NULL, 3, p_cproces,

                                                                 -- BUG16130:DRA:29/09/2010
                                                                 NULL, NULL);
      vtraza := 1;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      COMMIT;
      vtraza := 2;
      f_sin_leefichero(p_nombre, p_path, vdeserror, v_sproces);
      vtraza := 3;

      IF vdeserror IS NOT NULL THEN
         --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    NULL, vdeserror);
         vtraza := 51;

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;   --Error que para ejecución
         END IF;

         vtraza := 52;
         COMMIT;   --Guardamos la tabla temporal int
         RAISE vsalir;
      ELSE
         vnum_err := pac_gestion_procesos.f_set_carga_fichero(29, p_nombre, 3, f_sysdate);

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            v_deserror := 'Error llamando a pac_gestion_procesos.f_set_carga_fichero';
            RAISE errorini;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                          psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || 'ErrorIni' || ' en :' || 1,
                     'Error:' || 'Insertando estados registros');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(108953, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || 'errorini',
                                 1, vnnumlin);
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         --coderr := SQLCODE;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 'Error:' || SQLERRM || ' en :' || 1,
                     'Error:' || SQLERRM);
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(103187, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || SQLERRM,
                                 1, vnnumlin);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    151541, SQLERRM);
         vtraza := 51;

         IF vnum_err <> 0 THEN
            --RAISE ErrGrabarProv;
            p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                        'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
            vnnumlin := NULL;
            vnum_err := f_proceslin(v_sproces,
                                    f_axis_literales(180856, k_idiomaaaxis) || ':' || p_nombre
                                    || ' : ' || vnum_err,
                                    1, vnnumlin);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_sin_ejecutarcargafichero;

   /*************************************************************************
                   procedimiento que ejecuta una carga (parte2 proceso). SINIESTRO
       param in psproces   : Número proceso
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutarcargaproceso(psproces IN NUMBER, p_cproces IN NUMBER)
      -- BUG16130:DRA:15/10/2010
   RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_SIN_EJECUTARCARGAPROCESO';

      CURSOR polmigra(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_siniestros_allianz a
            WHERE proceso = psproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.proceso
                                AND int_carga_ctrl_linea.nlinea = a.nlinea
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5))
         --Solo las no procesadas
         ORDER BY nlinea;

      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      vnnumlin       NUMBER;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      -- BUG16130:DRA:29/09/2010:Inici
      e_errdatos     EXCEPTION;
      -- BUG16130:DRA:29/09/2010:Fi
      vterror        VARCHAR2(4000);
   -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
   BEGIN
      vtraza := 0;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                          'Parámetro psproces obligatorio.', psproces,
                                          f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 1;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vtraza := 2;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Falta fichero para proceso: ' || psproces);
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                 || v_tfichero || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;
      END IF;

      -- BUG16130:DRA:29/09/2010:Inici
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         vdeserror := 'cfg_files falta proceso: ' || REPLACE(vobj, 'PRO', '');
         RAISE e_errdatos;
      END IF;

      -- BUG16130:DRA:29/09/2010:Fi
      vtraza := 4;

      FOR x IN polmigra(psproces) LOOP
         --Leemos los registros de la tabla int no procesados OK
                  -- Bug 0016324. FAL. 18/10/2010
         IF NVL(vtiperr, 0) <> 1 THEN
            -- Fi Bug 0016324
            IF x.tipo_oper = 'ALTA_SIN' THEN   --Si es alta
               vtraza := 6;
               vterror := NULL;
               -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
               verror := f_altasiniestro_mig(x, vterror);

               --Grabamos en las MIG  -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
               IF verror IN(0, -2) THEN   --Si ha ido bien o tenemos avisos.
                  IF verror = -2 THEN   -- Avisos.
                     vtraza := 7;
                     vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 2, 0, NULL,

                                              -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                              x.num_siniestro,
                                              -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                              x.ncarga
                                                      -- Fi Bug 16324
                                );

                     IF vnum_err <> 0 THEN
                        --Si fallan esta funciones de gestión salimos del programa
                        RAISE errorini;   --Error que para ejecución
                     END IF;

                     verror := 0;
                  END IF;

------------------
                  vtiperr := f_altasiniestro_seg(x);   --Grabamos en las SEG

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF vtiperr NOT IN(0, 4, 2) THEN
                     IF k_para_carga <> 1 THEN
                        vtiperr := 4;   -- para que continue con la siguiente linea.
                     ELSE
                        vtiperr := 1;   -- para la carga
                     END IF;
                  END IF;
               -- Fi Bug 0016324
               ELSE   --Si ha ido mal el paso a las MIG lo indicamos con el error orbtenido
                  -- Bug 0016324. FAL. 18/10/2010
                  vtiperr := 1;
                  -- Fi Bug 0016324
                  vtraza := 70;
                  vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 1, 0, NULL,

                                           -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                           x.num_siniestro,
                                           -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                           x.ncarga
                                                   -- Fi Bug 16324
                             );

                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  vtraza := 72;
                  vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,
                                                NVL(vterror, verror));

                  -- Bug 0016324. FAL. 26/10/2010. Registra la desc. error si informada. en caso contrario el literal verror
                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  verrorfin := TRUE;
                  COMMIT;

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF k_para_carga <> 1 THEN
                     -- Fi Bug 0016324
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  -- Bug 0016324. FAL. 18/10/2010.
                  END IF;
               -- Fi Bug 0016324
               END IF;
            ELSIF x.tipo_oper = 'MODI_SIN' THEN
               vtiperr := f_modi_siniestro(x, v_deserror);

               IF vtiperr = 0 THEN
                  vtiperr := 4;
               -- Bug 0016324. FAL. 18/10/2010.
               --ELSE
               --   vtiperr := 2;
               -- Fi Bug 0016324
               END IF;

               -- Bug 0016324. FAL. 18/10/2010.d
               IF vtiperr NOT IN(4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     vtiperr := 1;   -- para la carga
                  END IF;
               END IF;
            -- Fi Bug 0016324
            END IF;

            IF vtiperr = 1 THEN   --Ha habido error
               verrorfin := TRUE;
            ELSIF vtiperr = 2 THEN   -- Es un warning
               vavisfin := TRUE;
            ELSIF vtiperr = 4 THEN   --Ha ido bien.
               NULL;
            ELSE
               RAISE errorini;   --Error que para ejecución(funciones de gestión)
            END IF;

            COMMIT;
         -- Bug 0016324. FAL. 18/10/2010
         ELSIF vtiperr = 1
               AND k_para_carga = 1 THEN
            vtiperr := 1;
            vcoderror := 151541;
            --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                       f_sysdate, f_sysdate,
                                                                       vtiperr, p_cproces,

                                                                       -- BUG16130:DRA:29/09/2010
                                                                       vcoderror, NULL);

            IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
               p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
               vnnumlin := NULL;
               vnum_err := f_proceslin(psproces,
                                       f_axis_literales(180856, k_idiomaaaxis) || ':'
                                       || v_tfichero || ' : ' || vnum_err,
                                       1, vnnumlin);
               RAISE errorini;   --Error que para ejecución
            END IF;

            --Bug.:17155
            IF vtiperr IN(4, 2) THEN
               vnum_err := pac_gestion_procesos.f_set_carga_fichero(29, v_tfichero, 2,
                                                                    f_sysdate);

               IF vnum_err <> 0 THEN
                  --Si fallan esta funciones de gestión salimos del programa
                  p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                              'Error llamando a pac_gestion_procesos.f_set_carga_fichero');
                  vnnumlin := NULL;
                  vnum_err := f_proceslin(psproces,
                                          f_axis_literales(180856, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || vnum_err,
                                          1, vnnumlin);
                  RAISE errorini;   --Error que para ejecución
               END IF;
            --Fi Bug.: 17155
            END IF;

            COMMIT;
            RETURN 0;
         --RAISE vsalir;
         END IF;
      -- Fi Bug 0016324
      END LOOP;

      vtiperr := 4;
      vcoderror := NULL;

      IF vavisfin THEN
         vtiperr := 2;
         vcoderror := 700145;
      END IF;

      IF verrorfin THEN
         vtiperr := 1;
         vcoderror := 151541;
      END IF;

      --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                 f_sysdate, f_sysdate, vtiperr,
                                                                 p_cproces,
                                                                 -- BUG16130:DRA:29/09/2010
                                                                 vcoderror, NULL);
      vtraza := 51;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
         vnnumlin := NULL;
         vnum_err := f_proceslin(psproces,
                                 f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror,
                                          psproces, 'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         pac_cargas_allianz.p_genera_logs(vobj, vtraza,
                                          'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                          'Error:' || 'Insertando estados registros',
                                          psproces,
                                          f_axis_literales(108953, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || 'errorini');
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_allianz.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM,
                                          psproces,
                                          f_axis_literales(103187, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    f_sysdate, NULL, 1,
                                                                    p_cproces,
                                                                    -- BUG16130:DRA:29/09/2010
                                                                    151541, SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_allianz.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                           || ' : ' || vnum_err);
            RAISE errorini;
         END IF;

         COMMIT;
         RETURN 1;
   END f_sin_ejecutarcargaproceso;

   /*************************************************************************
                                                                                       procedimiento que ejecuta una carga SINIESTROS
        param in p_nombre   : Nombre fichero
        param in p_path   : Nuombre path
        param in  out psproces   : Número proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
    *************************************************************************/
   FUNCTION f_sin_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_ALLIANZ.F_SIN_EJECUTARCARGA';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;   -- FAL - 07707/2011 - Bug 0019991
   BEGIN
      vtraza := 0;

      -- Bug 0016324. FAL. 18/10/2010
      SELECT NVL(cpara_error, 0)
        INTO k_para_carga
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      -- Fi Bug 0016324
      IF psproces IS NULL THEN
         vnum_err := pac_cargas_allianz.f_sin_ejecutarcargafichero(p_nombre, p_path,
                                                                   p_cproces,
                                                                   -- BUG16130:DRA:15/10/2010
                                                                   psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_allianz.f_sin_ejecutarcargaproceso(psproces, p_cproces);

      -- BUG16130:DRA:15/10/2010
      IF vnum_err <> 0 THEN
         RAISE vsalir;
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
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         RETURN 1;
   END f_sin_ejecutarcarga;

   -- Bug 14888. FAL. 11/10/2010. Informar autriesgos.triesgo
   FUNCTION f_migra_autriesgos
      RETURN NUMBER IS
   BEGIN
      FOR reg IN (SELECT s.sseguro, r.nriesgo, r.tnatrie
                    FROM seguros s, productos p, riesgos r
                   WHERE s.cramo = p.cramo
                     AND s.cmodali = p.cmodali
                     AND s.ctipseg = p.ctipseg
                     AND s.ccolect = p.ccolect
                     AND p.cobjase = 5
                     AND s.sseguro = r.sseguro) LOOP
         BEGIN
            INSERT INTO autriesgos
                        (sseguro, nriesgo, nmovimi, cversion, ctipmat, cmatric, cuso,
                         csubuso, fmatric, nkilometros, cvehnue, ivehicu, npma, ntara,
                         ccolor, nbastid, nplazas, cgaraje, cusorem, cremolque, triesgo)
                 VALUES (reg.sseguro, reg.nriesgo, 1, '99999999999', NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, reg.tnatrie);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      COMMIT;
      RETURN 0;
   END;
-- Fig Bug 14888
END pac_cargas_allianz;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_ALLIANZ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_ALLIANZ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_ALLIANZ" TO "PROGRAMADORESCSI";
