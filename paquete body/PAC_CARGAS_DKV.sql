--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS_DKV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS_DKV" IS
   /******************************************************************************
      NOMBRE:      PAC_CARGAS_DKV
      PROPÓSITO: Funciones para la gestión de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        07/06/2010   FAL              1. Creación del package.
      2.0        09/06/2010   JMF              2. 0014856: CRT002 - Carga de polizas y recibos DKV
      3.0        29/06/2010   DRA              3. 0016130: CRT - Error informando el codigo de proceso en carga
      4.0        13/10/2010   FAL              4. 0014888: CRT002 - Carga de polizas,recibos y siniestros
      5.0        18/10/2010   FAL              5. 0016324: CRT - Configuracion de las cargas
      6.0        29/10/2010   FAL              6. 0016525 CRT002 - Incidencias en cargas (primera carga inicial)
      7.0        27/12/2010   JMP              7. 0017008: GRC - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nº de póliza
      8.0        19/01/2011   ICV              8. 0017155: CRT003 - Informar estado actualizacion compañia
      9.0        19/01/2011   FAL              9. 0017282: CRT002 - DKV cargar un asegurado genérico
     10.0        02/03/2011   FAL             10. 0017569: CRT - Interfases y gestión personas
     11.0        30/04/2014   FAL             11. 0027642: RSA102 - Producto Tradicional
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
      1.2.0.0.0 ....f_REC_ejecutarcargaproceso
      1.2.1.0.0 ........f_altarecibo_mig..........(ALTA)
      1.2.1.0.0 ........f_altarecibo_seg..........(ALTA)
      1.2.1.0.0 ........f_modi_recibo.............(MODI)
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.P_MARCALINEA';
      num_err        NUMBER;
      vtipo          NUMBER;
      num_lin        NUMBER;
      num_aux        NUMBER;
   BEGIN
      IF p_tip = 'ALTA' THEN
         vtipo := 0;
      ELSIF p_tip = 'ALTA_REC'
            OR p_tip = 'MODI_REC' THEN
         vtipo := 2;
      ELSE
         vtipo := 0;
      END IF;

      num_err :=
         pac_gestion_procesos.f_set_carga_ctrl_linea
            (p_pro, p_lin, vtipo, p_lin, p_tip, p_est, p_val, p_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.P_MARCALINEAERROR';
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
          param in x : registro tipo int_polizas_DKV
          param in psinterf: id interfase obtenido en la busqueda persona host
          return : 0 si ha ido bien
    *************************************************************************/
   FUNCTION f_alta_persona_host(
      x IN OUT int_polizas_dkv%ROWTYPE,
      psinterf IN int_mensajes.sinterf%TYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_ALTA_PERSONA_HOST';
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
             WHERE nnumide = x.dni_tomador;
         EXCEPTION
            WHEN OTHERS THEN
               wnnumnif := x.dni_tomador;
               RAISE err_busca_pers;
         END;

         wsinterf := NULL;
         num_err := pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, wsperson,
                                           vcterminal, wsinterf /*psinterf*/, werror,
                                           pac_md_common.f_get_cxtusuario);

         IF num_err <> 0 THEN
            pterror := werror;
            RAISE err_alta_host;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN err_busca_pers THEN
         pac_cargas_dkv.p_genera_logs
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

         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error en alta host',
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

   /*************************************************************************
                Función que da de alta póliza en las SEG
          param in x : registro tipo int_polizas_dkv
          return : 1 si ha habido error
                   2 si ha habido warning
                   4 si ha ido bien
      *************************************************************************/
   FUNCTION f_alta_poliza_seg(
      x IN OUT int_polizas_dkv%ROWTYPE,
      psinterf IN int_mensajes.sinterf%TYPE)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_ALTA_POLIZA_SEG';
      v_i            BOOLEAN := FALSE;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
      verrorgrab     EXCEPTION;
      vtraza         NUMBER := 0;
      vtiperr        NUMBER;
      vsseguro       NUMBER;
      w_sproduc      NUMBER;
      w_pregnumasegdef NUMBER;
      terror         VARCHAR2(3000);
      warning_alta_host BOOLEAN := FALSE;
   BEGIN
      vtraza := 100;
      pac_mig_axis.p_migra_cargas(x.nlinea, 'C', x.ncarga, 'DEL');   --Cargamos las SEG para la póliza (ncarga)
      vtraza := 110;

      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 200;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
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
         BEGIN
            SELECT sseguro, sproduc
              INTO vsseguro, w_sproduc
              FROM mig_seguros
             WHERE ncarga = x.ncarga;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;   --JRH IMP de momento
         END;

         -- Bug 0017282. FAL. 19/01/2011.
         w_pregnumasegdef := 0;

         SELECT COUNT(*)
           INTO w_pregnumasegdef
           FROM pregunpro
          WHERE sproduc = w_sproduc
            AND cpregun = 7102;

         IF w_pregnumasegdef > 0 THEN
            UPDATE asegurados
               SET sperson = k_aseg_gen_sin_detallar
             WHERE sseguro = vsseguro;

            UPDATE riesgos
               SET sperson = k_aseg_gen_sin_detallar
             WHERE sseguro = vsseguro;
         END IF;

         -- Fi Bug 17282
         BEGIN
            UPDATE seguros
               SET cpolcia = x.cpolcia
             WHERE sseguro = vsseguro;
         EXCEPTION
            WHEN OTHERS THEN
               pac_cargas_dkv.p_genera_logs(vobj, vtraza, SQLCODE,
                                            'Error al guardar cpolcia ' || x.cpolcia,
                                            x.proceso,
                                            'Error al guardar cpolcia ' || x.cpolcia);
         END;
      END IF;

      IF NOT v_i THEN
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = x.ncarga
                        AND tipo = 'W') LOOP   --Miramos si han habido warnings.
            vtraza := 202;
            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 2, 1, vsseguro,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.num_poliza_dkv,   -- Fi Bug 14888
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

            -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
            vnum_err := f_alta_persona_host(x, psinterf, terror);

            IF vnum_err <> 0 THEN
               vnum_err :=
                  p_marcalinea
                     (x.proceso, x.nlinea, x.tipo_oper, 2, 1, vsseguro,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      x.num_poliza_dkv,   -- Fi Bug 14888
                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      x.ncarga   -- Fi Bug 16324
                              );

               IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
                  RAISE verrorgrab;
               END IF;

               IF NOT warning_alta_host THEN
                  vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, terror);

                  IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
                     RAISE verrorgrab;
                  END IF;

                  warning_alta_host := TRUE;
               END IF;
            END IF;

            -- Fi Bug 0017569
            v_i := TRUE;
         END LOOP;

         vtiperr := 2;
      END IF;

      IF NOT v_i THEN   --Esto quiere decir que no ha habido ningún error (lo indicamos también).
         vtraza := 204;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, vsseguro,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
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
                  (x.proceso, x.nlinea, x.tipo_oper, 2, 1, vsseguro,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.num_poliza_dkv,   -- Fi Bug 14888
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
        param in x: registro tratado tipo int_polizas_dkv
        param out reg_datos_pers: registro datos persona Host
        param out reg_datos_dir: registro datos direccion Host
        param out reg_datos_contac: registro datos contacto Host
        param out reg_datos_cc: registro datos cuenta Host
        return : 0 si ha ido bien
    *************************************************************************/
   FUNCTION f_busca_person_host(
      x IN int_polizas_dkv%ROWTYPE,
      reg_datos_pers OUT int_datos_persona%ROWTYPE,
      reg_datos_dir OUT int_datos_direccion%ROWTYPE,
      reg_datos_contac OUT int_datos_contacto%ROWTYPE,
      reg_datos_cc OUT int_datos_cuenta%ROWTYPE,
      psinterf IN OUT int_mensajes.sinterf%TYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_BUSCA_PERSON_HOST';
      vtraza         NUMBER := 0;
      num_err        NUMBER;
      vcterminal     usuarios.cterminal%TYPE;
      werror         VARCHAR2(2000);
      womasdatos     NUMBER;
      pmasdatos      NUMBER;
      wcont_pers     NUMBER;
      wsperson       per_personas.sperson%TYPE;
      wnnunnif       int_polizas_dkv.dni_tomador%TYPE;
      err_busca_pers_host EXCEPTION;
   BEGIN
      num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);
      wnnunnif := x.dni_tomador;
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
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error al buscar persona en host',
                                      'Error: ' || werror || ';sinterf = ' || psinterf
                                      || '; nif = ' || wnnunnif || ' (' || x.proceso || '-'
                                      || x.nlinea || ')',
                                      x.proceso,
                                      'Error al buscar persona en host: ' || werror
                                      || '; nif = ' || wnnunnif || ' (' || x.proceso || '-'
                                      || x.nlinea || ')');
         RETURN num_err;
      ELSE
         --   COMMIT;
          --  COMMIT;

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
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'No encuentra persona en host',
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
         pac_cargas_dkv.p_genera_logs(vobj, vtraza,
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
          param in x : registro tipo INT_POLIZAS_DKV
      *************************************************************************/
   FUNCTION f_alta_poliza(
      x IN OUT int_polizas_dkv%ROWTYPE,
      p_deserror IN OUT VARCHAR2,
      psinterf OUT int_mensajes.sinterf%TYPE)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_ALTA_POLIZA';
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      errdatos       EXCEPTION;
      --Tablas nivel póliza
      v_mig_personas mig_personas%ROWTYPE;
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
      p_deserror := NULL;

      SELECT ROWID
        INTO v_rowid_ini
        FROM int_polizas_dkv
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      --Inicializamos la cabecera de la carga
      vtraza := 1010;
      v_ncarga := f_next_carga;
      x.ncarga := v_ncarga;   -- Bug 0016324. FAL. 26/10/2010. Asignamos v_ncarga antes de posible error para registrarlo en la linea de carga
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Pólizas', v_seq);
      vtraza := 1015;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, pid, 'OK');

      vtraza := 1020;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_DKV', 'MIG_PERSONAS', 0);

      vtraza := 1025;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_DKV', 'MIG_SEGUROS', 1);

      vtraza := 1030;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_DKV', 'MIG_MOVSEGURO', 2);

      vtraza := 1035;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_DKV', 'MIG_AGENSEGU', 4);

      --UPDATE mig_logs_emp --JRH IMP
      -- --   SET ncarga = v_ncarga
      --  WHERE ncarga = 0
      --   AND seqlog = v_seq;
      vtraza := 1040;
      v_mig_personas.ncarga := v_ncarga;
      v_mig_personas.cestmig := 1;

      IF x.dni_tomador IS NULL THEN
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
      num_err := f_busca_person_host(x, reg_dat_pers, reg_dat_dir, reg_dat_contac, reg_dat_cc,
                                     psinterf, p_deserror);

      IF num_err <> 0
         AND p_deserror IS NOT NULL THEN
         SELECT sseqlogmig2.NEXTVAL
           INTO v_seq
           FROM DUAL;

         INSERT INTO mig_logs_axis
                     (ncarga, seqlog, fecha, mig_pk, tipo,
                      incid)
              VALUES (v_ncarga, v_seq, f_sysdate, v_ncarga || '/' || x.nlinea, 'W',
                      'Busqueda persona en Host: ' || p_deserror);
      END IF;

      -- Fi Bug 0017569
      vtraza := 1045;
      v_mig_personas.mig_pk := v_ncarga || '/' || x.dni_tomador;
      v_mig_personas.idperson := 0;
      v_mig_personas.snip := x.dni_tomador;
      vtraza := 1050;
      v_mig_personas.ctipide := 27;   -- NIF carga fichero (detvalor 672).
      v_mig_personas.ctipide := NVL(reg_dat_pers.ctipdoc, v_mig_personas.ctipide);   -- Bug 0017569
      v_mig_personas.nnumide := x.dni_tomador;
      v_mig_personas.cestper := 0;
      v_mig_personas.cpertip := NVL(reg_dat_pers.ctipper, 1);
      v_mig_personas.swpubli := 0;
      vtraza := 1055;
      --IF x.sexo IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      --v_mig_personas.csexper := x.sexo;
      v_mig_personas.csexper := NULL;
      v_mig_personas.csexper := NVL(reg_dat_pers.csexo, NULL);   -- Bug 0017569
      vtraza := 1060;
      --IF x.fecnac IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      --v_mig_personas.fnacimi := TO_DATE(x.fecnac, 'YYYYMMDD');
      v_mig_personas.fnacimi := NULL;
      v_mig_personas.fnacimi := NVL(TO_CHAR(TO_DATE(reg_dat_pers.fnacimi, 'yyyy-mm-dd'),
                                            'dd/mm/yyyy'),
                                    v_mig_personas.fnacimi);   -- Bug 0017569  int_datos_persona
      vtraza := 1065;

      IF x.banco_de_cobro = 3081 THEN
         v_mig_personas.cagente := ff_agente_cpervisio(x.agencia_banco_de_cobro);
      ELSE
         v_mig_personas.cagente := NVL(ff_agente_cpervisio(k_agentedefec), k_agentedefec);
      END IF;

          /*  SELECT MAX(a.cagente)
                  INTO v_mig_personas.cagente
            FROM redcomercial a, agentes b
            WHERE a.cagente = v_mig_personas.cagente
                  AND a.cempres = k_empresaaxis
                  AND b.cagente = a.cagente;
      */
      IF v_mig_personas.cagente IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Código agente',
                       'No definido ' || ' (' || x.banco_de_cobro || '-'
                       || x.agencia_banco_de_cobro || ')',
                       x.proceso,
                       'Código agente No definido ' || ' (' || x.banco_de_cobro || '-'
                       || x.agencia_banco_de_cobro || ')');
         v_mig_personas.cagente := NVL(ff_agente_cpervisio(k_agentedefec), k_agentedefec);
      END IF;

      --v_mig_personas.cagente := NVL(reg_dat_pers.cagente, v_mig_personas.cagente);   -- Bug 0017569
      vtraza := 1070;

      IF x.nombre_tomador IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Nombre tomador',
                       'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                       x.proceso,
                       'Nombre tomador Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                       || ')');
         x.nombre_tomador := ' ';
      END IF;

      vtraza := 1075;
      --IF x.nombre IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      vtraza := 1080;
      v_mig_personas.tapelli1 := x.nombre_tomador;
      v_mig_personas.tapelli2 := NULL;
      v_mig_personas.tnombre := NULL;
      -- Direccion Particular
      v_mig_personas.ctipdir := 1;
      v_mig_personas.tnomvia := x.domicilio;
      v_mig_personas.nnumvia := NULL;
      v_mig_personas.tcomple := NULL;
      v_mig_personas.cpais := k_paisdefaxis;
      v_mig_personas.cnacio := k_paisdefaxis;
      -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
      v_mig_personas.tapelli1 := NVL(reg_dat_pers.tapelli1, v_mig_personas.tapelli1);
      v_mig_personas.tapelli2 := NVL(reg_dat_pers.tapelli2, v_mig_personas.tapelli2);
      v_mig_personas.tnombre := NVL(reg_dat_pers.tnombre, v_mig_personas.tnombre);
      -- Direccion Particular
      v_mig_personas.ctipdir := NVL(reg_dat_dir.ctipdir, v_mig_personas.ctipdir);
      v_mig_personas.tnomvia := NVL(reg_dat_dir.tnomvia, v_mig_personas.tnomvia);
      v_mig_personas.nnumvia := NVL(reg_dat_dir.nnumvia, v_mig_personas.nnumvia);
      v_mig_personas.tcomple := NULL;
      v_mig_personas.cpais := NVL(reg_dat_pers.cpais, v_mig_personas.cpais);
      v_mig_personas.cnacio := NVL(reg_dat_pers.cnacioni, v_mig_personas.cnacio);
      -- Fi Bug 17569
      vtraza := 1085;

      IF x.cod_postal IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Código postal',
                       'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                       x.proceso,
                       'Código postal Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                       || ')');
         v_mig_personas.cpostal := NULL;
      ELSE
         v_mig_personas.cpostal := LPAD(x.cod_postal, 5, '0');
      END IF;

      v_mig_personas.cpostal := NVL(reg_dat_dir.cpostal, v_mig_personas.cpostal);   -- Bug 0017569
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

      IF x.localidad IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'localidad',
                       'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                       x.proceso,
                       'localidad Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')');
         v_mig_personas.cprovin := NULL;
         v_mig_personas.cpoblac := NULL;
      ELSE
         DECLARE
            v_localidad    VARCHAR2(20);

            CURSOR c1 IS
               SELECT   b.cprovin, b.cpoblac
                   FROM codpostal c, poblaciones b, provincias a
                  WHERE a.cpais = v_mig_personas.cpais
                    AND b.cprovin = a.cprovin
                    AND UPPER(b.tpoblac) LIKE UPPER(v_localidad)
                    AND c.cpostal = LPAD(x.cod_postal, 5, '0')
                    AND c.cprovin = a.cprovin
                    AND c.cpoblac = b.cpoblac
               ORDER BY 1, 2;
         BEGIN
            vtraza := 1100;
            v_localidad := RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.localidad), 'ÁÉÍÓÚ', 'AEIOU'))),
                                 '.');
            vtraza := 1105;

            OPEN c1;

            FETCH c1
             INTO v_mig_personas.cprovin, v_mig_personas.cpoblac;

            --  IF c1%NOTFOUND THEN
            --      b_warning := TRUE;
            --      p_genera_logs(vobj, vtraza, 'localidad cod_postal',
            --                   'no definido ' || ' (' || x.proceso || '-' || x.nlinea || ')',
            --                   x.proceso,
            --                   'localidad cod_postal no definido ' || ' (' || x.proceso || '-'
            --                   || x.nlinea || ')');
            --    v_mig_personas.cprovin := NULL;
            ---     v_mig_personas.cpoblac := NULL;
            --  END IF;

            --   CLOSE c1;
            IF c1%NOTFOUND THEN
               CLOSE c1;

               BEGIN
                  SELECT SUBSTR(LPAD(x.cod_postal, 5, 0), 1, 2)
                    INTO v_mig_personas.cprovin
                    FROM DUAL;

                  vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                               v_mig_personas.cprovin,
                                                               LPAD(x.cod_postal, 5, '0'),
                                                               v_mig_personas.cpoblac);
               EXCEPTION
                  WHEN OTHERS THEN
                     -- Bug 0016525.03/11/2010.FAL
                     BEGIN
                        SELECT SUBSTR(LPAD(x.cod_postal, 5, '0'), 1, 2)
                          INTO v_mig_personas.cprovin
                          FROM DUAL;

                        vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                                     v_mig_personas.cprovin,
                                                                     LPAD(x.cod_postal, 5, '0'),
                                                                     v_mig_personas.cpoblac);

                        IF vnum_err <> 0 THEN
                           b_warning := TRUE;
                           p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                         'no definido ' || ' (' || x.proceso || '-'
                                         || x.nlinea || '-' || x.localidad || '-'
                                         || x.cod_postal || ')',
                                         x.proceso,
                                         'localidad cod_postal no definido ' || ' ('
                                         || x.proceso || '-' || x.nlinea || '-' || x.localidad
                                         || '-' || x.cod_postal || ')');
                           v_mig_personas.cprovin := NULL;
                           v_mig_personas.cpoblac := NULL;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           b_warning := TRUE;
                           p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                         'no definido ' || ' (' || x.proceso || '-'
                                         || x.nlinea || '-' || x.localidad || '-'
                                         || x.cod_postal || ')',
                                         x.proceso,
                                         'localidad cod_postal no definido ' || ' ('
                                         || x.proceso || '-' || x.nlinea || '-' || x.localidad
                                         || '-' || x.cod_postal || ')');
                           v_mig_personas.cprovin := NULL;
                           v_mig_personas.cpoblac := NULL;
                     END;
               /*
                                                         b_warning := TRUE;
               p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                             'no definido ' || ' (' || x.proceso || '-' || x.nlinea || '-' || x.localidad || '-' || x.cod_postal
                             || ')',
                             x.proceso,
                             'localidad cod_postal no definido ' || ' (' || x.proceso
                             || '-' || x.nlinea || '-' || x.localidad || '-' || x.cod_postal || ')');
               v_mig_personas.cprovin := NULL;
               v_mig_personas.cpoblac := NULL;
               */
               -- Fi Bug 0016525
               END;
            ELSE
               CLOSE c1;
            END IF;
         -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
         EXCEPTION
            WHEN OTHERS THEN
               IF c1%ISOPEN THEN
                  CLOSE c1;
               END IF;
         END;
      END IF;

      v_mig_personas.cprovin := NVL(reg_dat_dir.cprovin, v_mig_personas.cprovin);   -- Bug 0017569
      v_mig_personas.cpoblac := NVL(reg_dat_dir.cpoblac, v_mig_personas.cpoblac);   -- Bug 0017569
      vtraza := 1110;
      --IF x.oficina IS NULL THEN
      --   RAISE errdatos;
      --END IF;
      v_mig_personas.cidioma := k_idiomaaaxis;
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

      IF x.telefono IS NOT NULL THEN
         v_mig_personas.tnumtel := x.telefono;
      END IF;

      IF reg_dat_contac.ctipcon = 1 THEN
         v_mig_personas.tnumtel := NVL(reg_dat_contac.tvalcon, v_mig_personas.tnumtel);   -- Bug 0017569
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

      v_mig_seg.mig_pk := v_ncarga || '/' || x.nlinea;
      v_mig_seg.mig_fk := v_mig_personas.mig_pk;

      --v_mig_seg.cagente       := v_mig_personas.cagente;
      IF x.banco_de_cobro = 3081 THEN
         v_mig_seg.cagente := x.agencia_banco_de_cobro;
      ELSE
         v_mig_seg.cagente := k_agentenoban;
      END IF;

      vtraza := 1127;

      SELECT MAX(a.cagente)
        INTO v_mig_seg.cagente
        FROM agentes a
       WHERE a.cagente = v_mig_seg.cagente;

      IF v_mig_seg.cagente IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Código agente',
                       'No definido ' || ' (' || x.banco_de_cobro || '-'
                       || x.agencia_banco_de_cobro || ')',
                       x.proceso,
                       'Código agente No definido ' || ' (' || x.banco_de_cobro || '-'
                       || x.agencia_banco_de_cobro || ')');
         v_mig_seg.cagente := k_agentenoban;   -- reasigno un agente 9999
      END IF;

      v_mig_seg.csituac := 0;
      vtraza := 1130;
      v_mig_seg.fefecto := converteix_charadate(LTRIM(TO_CHAR(x.dia_efecto, '09'))
                                                || LTRIM(TO_CHAR(x.mes_efecto, '09'))
                                                || LTRIM(TO_CHAR(x.anyo_efecto, '0999')),
                                                'ddmmyyyy');

      IF v_mig_seg.fefecto IS NULL THEN
         verror := 'Fecha efecto no es fecha: ' || x.dia_efecto || '-' || x.mes_efecto || '-'
                   || x.anyo_efecto || ' (dd-mm-aaaa)';
         verror := verror || '. Editar linea, modificar fecha efecto y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1135;
      -- IF x.forma_pag IS NULL THEN
      --  RAISE errdatos;
      --  END IF;
      vtraza := 1140;
      v_mig_seg.cforpag := pac_cargas_dkv.f_buscavalor('CRT_FORMAPAGO', x.periodo_de_cobro);

      IF v_mig_seg.cforpag IS NULL THEN
         verror := 'Forma de pago no definida: ' || x.periodo_de_cobro || ' (CRT_FORMAPAGO)';
         verror := verror || '. Editar linea, modificar forma de pago y reprocesar.';
         cerror := 140704;
         RAISE errdatos;
      END IF;

      vtraza := 1145;

      DECLARE
         v_cramo        seguros.cramo%TYPE;
         v_valaxis      int_codigos_emp.cvalaxis%TYPE;
         n_pos          NUMBER;
         v_cempres      codiram.cempres%TYPE;
      BEGIN
         v_valaxis := pac_cargas_dkv.f_buscavalor('CRT_PRODUCTOACTDKV',
                                                  LTRIM(TO_CHAR(x.ramo_dkv, '099')));

         IF v_valaxis IS NULL THEN
            verror := 'Producto no definido: ' || LTRIM(TO_CHAR(x.ramo_dkv, '099'))
                      || ' (CRT_PRODUCTOACTDKV)';
            cerror := 9002109;
            RAISE errdatos;
         END IF;

         SELECT INSTR(v_valaxis, '/')
           INTO n_pos
           FROM DUAL;

         IF n_pos = 0 THEN
            v_mig_seg.sproduc := v_valaxis;
            v_mig_seg.cactivi := 0;
         ELSE
            SELECT SUBSTR(v_valaxis, 1, n_pos - 1), SUBSTR(v_valaxis, n_pos + 1)
              INTO v_mig_seg.sproduc, v_mig_seg.cactivi
              FROM DUAL;
         END IF;

         vtraza := 1150;

         /*  SELECT MIN(a.cramo)
                 INTO v_cramo
           FROM productos b, codiram a
           WHERE a.cempres = k_empresaaxis
                 AND b.cramo = a.cramo
             --    AND b.cactivo = 1
                 AND b.sproduc = v_mig_seg.sproduc;
           */
         SELECT p.cramo, ccompani, cempres
           INTO v_cramo, v_mig_seg.ccompani, v_cempres
           FROM productos p, codiram c
          WHERE sproduc = v_mig_seg.sproduc
            AND c.cramo = p.cramo;

                 /* IF v_cramo IS NULL THEN
                              verror := 'falta producto activo para: ' || v_mig_seg.sproduc || ' - ' || x.
                               ramo_dkv;
                     cerror := 104347;
                     RAISE errdatos;
                  END IF;
         */
                 -- Asigno el del producte.
         vtraza := 1155;
         -- BUG 17008 - 27/12/2010 - JMP - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nº de póliza
         -- v_mig_seg.npoliza := f_contador('02', v_cramo);
         v_mig_seg.npoliza := pac_propio.f_contador2(v_cempres, '02', v_cramo);
         v_mig_seg.ncertif := 0;
      END;

      vtraza := 1160;
      v_mig_seg.creafac := 0;   --Revisar
      --BUG 10395 - 11/06/2009 - JMC - Inicializamos cobrador bancario
      v_mig_seg.ccobban := NULL;
      vtraza := 1165;
      --FIN BUG 10395 - 11/06/2009 - JMC
      v_mig_seg.ctipcoa := 0;
      v_mig_seg.ctiprea := 0;
      v_mig_seg.ctipcom := 0;   --Habitual
      vtraza := 1170;
      vtraza := 1175;
       /* -- jlb de momento no tengo claro para que vale la fecha de vencimiento
                                            IF x.dia_vencmto = 0
            AND x.mes_vencmto = 0
            AND x.anyo_vencmto = 0 THEN
                v_mig_seg.fvencim := NULL;
         ELSE
            v_mig_seg.fvencim := converteix_charadate(LTRIM(TO_CHAR(x.dia_vencmto, '09')) ||
                                                      LTRIM(TO_CHAR(x.mes_vencmto, '09')) ||
                                                      LTRIM(TO_CHAR(x.anyo_vencmto, '0999')),
                                                      'ddmmyyyy');
            IF v_mig_seg.fvencim IS NULL THEN
               verror := 'Vencimiento no es fecha: ' || x.dia_vencmto || '-' || x.mes_vencmto ||
                         '-' || x.anyo_vencmto || ' (dd-mm-aaaa)';
               cerror := 1000135;
               RAISE errdatos;
            END IF;
         END IF;
      */
      vtraza := 1180;
      v_mig_seg.femisio := v_mig_seg.fefecto;
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
      --v_mig_seg.ccompani      := NULL;
      --v_mig_seg.ctipcob := 1;   -- JRH IMP Caja
      vtraza := 1190;
      v_mig_seg.crevali := 0;
      v_mig_seg.prevali := 0;
      v_mig_seg.irevali := 0;
      vtraza := 1195;

      IF NVL(x.banco_de_cobro, 0) = 0 THEN
         v_mig_seg.ctipban := NULL;
         v_mig_seg.cbancar := NULL;
         v_mig_seg.ctipcob := 1;
      ELSE
         vtraza := 1200;
         v_mig_seg.ctipban := 1;
         v_mig_seg.cbancar := LTRIM(TO_CHAR(x.banco_de_cobro, '0999'))
                              || LTRIM(TO_CHAR(x.agencia_banco_de_cobro, '0999'))
                              || LTRIM(TO_CHAR(x.digitos_control_cta_cobro, '09'))
                              || LTRIM(TO_CHAR(x.cta_cte_de_cobro, '0999999999'));
         vtraza := 1205;
         v_mig_seg.ctipcob := 2;

         DECLARE
            n_control      NUMBER;
            v_salida       VARCHAR2(50);
         BEGIN
            cerror := f_ccc(TO_NUMBER(v_mig_seg.cbancar), 1, n_control, v_salida);

            IF cerror <> 0 THEN
               b_warning := TRUE;
               p_genera_logs(vobj, vtraza, 'cuenta cobro',
                             'no válida ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                             x.proceso,
                             'cuenta cobro no válida ' || ' (' || x.proceso || '-' || x.nlinea
                             || ')');
               v_mig_seg.ctipban := NULL;
               v_mig_seg.cbancar := NULL;
               cerror := 0;
            END IF;
         END;
      END IF;

      vtraza := 1210;
      -- v_mig_seg.ctipcob       := 1;
      v_mig_seg.casegur := 1;   --Revisar de momento pongo especificar, en caso de ser igual al tomador poner 1
      --v_mig_seg.nsuplem := 0;
      v_mig_seg.nsuplem := x.n_suplemento;
      v_mig_seg.sseguro := 0;
      v_mig_seg.sperson := 0;
      vtraza := 1200;
      -- vcdomici                := 1;
      vtraza := 1205;

      SELECT NVL(MIN(cdomici), 1)
        INTO vcdomici
        FROM per_direcciones p, per_personas m
       WHERE m.nnumide = x.dni_tomador
         AND p.sperson = m.sperson;

      v_mig_seg.crecfra := 0;
      vtraza := 1210;
      --vnum_err := f_calc_fechas_cartera(v_mig_seg, var_productos);   --JRH IMP
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
                              AND per.nnumide = x.dni_tomador)
            AND ROWNUM = 1
      RETURNING npoliza, cagente, sseguro
           INTO v_mig_seg.npolini, v_mig_seg.cagente, v_mig_movseg.sseguro;   --actualizo la primera nota informativa

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
      --  v_mig_movseg.fmovimi := v_mig_seg.femisio;
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
           VALUES (v_ncarga, 'INT_POLIZAS_DKV', 'MIG_ASEGURADOS', 5);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_DKV', 'MIG_RIESGOS', 6);

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
      v_mig_ase.mig_fk := v_mig_seg.mig_fk;
      v_mig_ase.mig_fk2 := v_mig_seg.mig_pk;
      v_mig_ase.cestmig := 1;
      v_mig_ase.ncarga := v_ncarga;
      v_mig_ase.cdomici := vcdomici;
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
      v_mig_rie.tnatrie := 'Número asegurados ' || x.num_asegurados;

      IF x.clave_de_riesgo IS NOT NULL THEN
         v_mig_rie.tnatrie := v_mig_rie.tnatrie || '. Clave riesgo ' || x.clave_de_riesgo;
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
           VALUES (v_ncarga, 'INT_POLIZAS_DKV', 'MIG_GARANSEG', 8);

      vtraza := 1275;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
      DECLARE
         n_garaxis      NUMBER;

         PROCEDURE p_capit(p_gar IN VARCHAR2, p_cap IN NUMBER) IS
         BEGIN
            vtraza := 1280;
            --  IF NVL(p_cap, 0) <> 0 THEN
            -- Si existe capital, comprobamos si existe garantia definida.
            vtraza := 1285;
            n_garaxis := pac_cargas_dkv.f_buscavalor('CRT_GRANTIADKV',
                                                     LTRIM(TO_CHAR(x.ramo_dkv, '099'))
                                                     || p_gar);

            IF n_garaxis IS NULL THEN
               /* -- inserto garantias para todas las garantias definidas en los productos
                           b_warning := TRUE;
               p_genera_logs(vobj, vtraza, 'capital_' || p_gar, 'capital sin garantia' ||
                             ' (' || x.proceso || '-' || x.nlinea || ')', x.proceso,
                             'capital_' || p_gar || ' capital sin garantia ' || ' (' || x.
                             proceso || '-' || x.nlinea || ')');
                */
               NULL;   -- jlb sino encuenta nulo.
            ELSE
               -- Valores genericos
               v_mig_gar := NULL;
               v_mig_gar.mig_fk := v_mig_movseg.mig_pk;
               v_mig_gar.cestmig := 1;
               v_mig_gar.cgarant := n_garaxis;
               v_mig_gar.ncarga := v_ncarga;
               v_mig_gar.nriesgo := 1;
               v_mig_gar.nmovimi := v_mig_movseg.nmovimi;
               v_mig_gar.nmovima := 1;
               v_mig_gar.sseguro := 0;
               vtraza := 1290;
               v_mig_gar.mig_pk := v_mig_movseg.mig_pk || '/' || n_garaxis;
               v_mig_gar.icapital := 0;
               -- Si es la garantia que tratamos, asignamos el capital.
               vtraza := 1295;
               v_mig_gar.icapital := p_cap;

               -- Asignamos las primas a la primera garantia por defecto.
               IF p_gar = '01' THEN
                  vtraza := 1300;
                  v_mig_gar.iprianu := NVL(x.importe_prima_neta_anual, 0);
                  v_mig_gar.irecarg := NVL(x.importe_tasas_anual, 0)
                                       + NVL(x.importe_consorcio_anual, 0);
                  v_mig_gar.ipritar := v_mig_gar.iprianu - v_mig_gar.irecarg;
               ELSE
                  v_mig_gar.iprianu := 0;
                  v_mig_gar.irecarg := 0;
                  v_mig_gar.ipritar := 0;
               END IF;

               vtraza := 1315;
               v_mig_gar.precarg := 0;
               v_mig_gar.iextrap := 0;
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
         -- END IF;
         END;
      BEGIN
         vtraza := 1330;
         p_capit('01', x.capital_garantia_01);
         p_capit('02', x.capital_garantia_02);
         p_capit('03', x.capital_garantia_03);
         p_capit('04', x.capital_garantia_04);
         p_capit('05', x.capital_garantia_05);
         p_capit('06', x.capital_garantia_06);
         p_capit('07', x.capital_garantia_07);
         p_capit('08', x.capital_garantia_08);
         p_capit('09', x.capital_garantia_09);
         p_capit('10', x.capital_garantia_10);
      END;

      vtraza := 1335;
      vtraza := 1340;

      ------
      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_POLIZAS_DKV', 'MIG_PREGUNSEG', 9);

      ------      FOR reg IN (SELECT *
      ------                    FROM pregunpro
      ------                   WHERE sproduc = v_mig_seg.sproduc) LOOP
      v_mig_pregunseg := NULL;
      v_mig_pregunseg.ncarga := v_ncarga;
      v_mig_pregunseg.cestmig := 1;
      v_mig_pregunseg.sseguro := 0;
      v_mig_pregunseg.mig_fk := v_mig_seg.mig_pk;
      -- Solo tenemos la pregunta de nº de asegurados en la carga
      v_mig_pregunseg.mig_pk := '7102:' || v_mig_seg.mig_pk;
      --v_mig_pregunseg.nriesgo := 1;
      v_mig_pregunseg.cpregun := 7102;
      v_mig_pregunseg.crespue := x.num_asegurados;
      ------         CASE reg.cpregun
      ------            WHEN 810 THEN
      ------               v_mig_pregunseg.mig_pk := '810:' || v_mig_seg.mig_pk;
      ------               v_mig_pregunseg.nriesgo := 1;
      ------               v_mig_pregunseg.cpregun := 810;
      ------               v_mig_pregunseg.crespue := x.salario;
      ------            WHEN 811 THEN
      ------               v_mig_pregunseg.mig_pk := '811:' || v_mig_seg.mig_pk;
      ------               v_mig_pregunseg.nriesgo := 1;
      ------               v_mig_pregunseg.cpregun := 811;
      ------               v_mig_pregunseg.crespue := x.pctcontri;
      ------            WHEN 812 THEN
      ------               v_mig_pregunseg.mig_pk := '812:' || v_mig_seg.mig_pk;
      ------               v_mig_pregunseg.nriesgo := 1;
      ------               v_mig_pregunseg.cpregun := 812;
      ------               v_mig_pregunseg.crespue := x.fecaltemp;
      ------            WHEN 813 THEN
      ------               v_mig_pregunseg.mig_pk := '813:' || v_mig_seg.mig_pk;
      ------               v_mig_pregunseg.nriesgo := 1;
      ------               v_mig_pregunseg.cpregun := 813;
      ------               v_mig_pregunseg.crespue := x.fecjub;
      ------            WHEN 814 THEN
      ------               v_mig_pregunseg.mig_pk := '814:' || v_mig_seg.mig_pk;
      ------               v_mig_pregunseg.nriesgo := 1;
      ------               v_mig_pregunseg.cpregun := 814;
      ------               v_mig_pregunseg.crespue := x.tieder;
      ------            WHEN 815 THEN
      ------               v_mig_pregunseg.mig_pk := '815:' || v_mig_seg.mig_pk;
      ------               v_mig_pregunseg.nriesgo := 1;
      ------               v_mig_pregunseg.cpregun := 815;
      ------               v_mig_pregunseg.crespue := x.importe_renta;
      ------            ELSE
      ------               NULL;
      ------         END CASE;
      ------
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
      ------         ELSE
      ------
      ------            IF NVL(reg.cpreobl, 0) = 1 THEN
      ------               RAISE errdatos;
      ------            END IF;
      END IF;

      ------      END LOOP;
      vtraza := 1350;

      UPDATE int_polizas_dkv
         SET ncarga = v_ncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1355;
      x.ncarga := v_ncarga;
      COMMIT;

      IF b_warning THEN
         cerror := -2;
      END IF;

      p_deserror := NULL;
      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         p_deserror := verror;
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error ' || cerror, verror, x.proceso,
                                      'Error ' || cerror || ' ' || verror);
         RETURN cerror;
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := SQLCODE || ' ' || SQLERRM;
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'ERROR ' || SQLCODE, SQLERRM, x.proceso,
                                      'Error ' || SQLCODE || ' ' || SQLERRM);
         RETURN SQLCODE;
   END f_alta_poliza;

   /*************************************************************************
                      procedimiento que genera anulación de póliza
          param in x : registro tipo INT_POLIZAS_DKV
          param p_deserror out: Descripción del error si existe.
          Devuelve TIPOERROR ( 1-Ha habido error, 2-Es un warning, 4-Ha ido bien, x-Error incontrolado).
          --
          Para modificar una póliza, los siguientes campos son obligatorios:
          - póliza cia
          - fecha baja
          - motivo baja
          --
      *************************************************************************/
   FUNCTION f_baja_poliza(x IN OUT int_polizas_dkv%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_BAJA_POLIZA';
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
      d_efe          DATE;
      n_vig          NUMBER;
      wnpoliza       NUMBER;   -- Bug 0016324. FAL. 26/10/2010
      v_valaxis      int_codigos_emp.cvalaxis%TYPE;
      n_pos          NUMBER;
      whaywarnings   NUMBER := 0;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
---------------------------------------------------------
-- VALIDAR CAMPOS CLAVE: Póliza                        --
---------------------------------------------------------
      vtraza := 1010;

      IF LTRIM(x.cpolcia) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 107573;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      v_valaxis := pac_cargas_dkv.f_buscavalor('CRT_PRODUCTOACTDKV',
                                               LTRIM(TO_CHAR(x.ramo_dkv, '099')));

      SELECT INSTR(v_valaxis, '/')
        INTO n_pos
        FROM DUAL;

      IF n_pos = 0 THEN
         n_pro := v_valaxis;
      --v_mig_seg.cactivi := 0;
      ELSE
         SELECT SUBSTR(v_valaxis, 1, n_pos - 1)   --, SUBSTR(v_valaxis, n_pos + 1)
           INTO n_pro   --, v_mig_seg.cactivi
           FROM DUAL;
      END IF;

      BEGIN
         SELECT sseguro, sproduc, fefecto, cagente, f_vigente(sseguro, NULL, f_sysdate),
                npoliza
           INTO n_seg, n_pro, d_efe, n_age, n_vig,
                wnpoliza   -- Bug 0016324. FAL. 26/10/2010
           FROM seguros
          WHERE cpolcia = x.cpolcia
            AND sproduc = n_pro
            AND cempres = k_empresaaxis;
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      IF n_seg IS NULL THEN
         p_deserror := 'Número póliza no existe: ' || x.cpolcia;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      IF n_vig <> 0 THEN
         p_deserror := 'La póliza ' || TO_CHAR(wnpoliza) || ' no esta vigente';   -- Bug 0016324. FAL. 26/10/2010. Informar el npoliza en la desc. error
         cerror := 101483;
         --RAISE errdatos;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
                                    -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
         RETURN 2;   -- aviso pero continua la carga
      END IF;

      vtraza := 1020;
        /*    SELECT MAX(1)
                              INTO n_aux
            FROM codiram a, productos b
            WHERE a.cempres = k_empresaaxis
                  AND b.cramo = a.cramo
                  AND b.sproduc = n_pro;
            IF n_aux IS NULL THEN
               p_deserror := 'Modificación no permitida para empresa/producto: ' || k_empresaaxis
                             || '/' || n_pro;
               cerror     := 9001709;
               RAISE errdatos;
            END IF;
      */
      vtraza := 1040;
      d_baj := converteix_charadate(LTRIM(TO_CHAR(x.dia_baja, '09'))
                                    || LTRIM(TO_CHAR(x.mes_baja, '09'))
                                    || LTRIM(TO_CHAR(x.anyo_baja, '0999')),
                                    'ddmmyyyy');

      IF d_baj IS NULL THEN
         p_deserror := 'Fecha baja no es fecha: ' || x.dia_baja || '-' || x.mes_baja || '-'
                       || x.anyo_baja || ' (dd-mm-aaaa)';
         p_deserror := p_deserror || '. Editar linea, modificar fecha baja y reprocesar';
         cerror := 102853;
         RAISE errdatos;
      END IF;

      vtraza := 1050;
      v_des2 := '';

      IF x.motivo_baja IS NULL THEN
         p_deserror := 'Motivo baja es obligatorio.';
         cerror := 103218;
         RAISE errdatos;
      ELSE
         vtraza := 1060;

         SELECT MAX(cvalemp)
           INTO v_des2
           FROM int_codigos_emp
          WHERE cempres = k_empresaaxis
            AND ccodigo = 'CRT_MOTBAJAS'
            AND SUBSTR(cvalemp, 1, LENGTH(x.motivo_baja)) = x.motivo_baja;

         IF v_des2 IS NULL THEN
            p_deserror := 'Motivo no definido CRT_MOTBAJAS: ' || x.motivo_baja;
            cerror := 103218;
            RAISE errdatos;
         END IF;
      END IF;

      vtraza := 1070;

      SELECT tmotmov
        INTO v_des1
        FROM motmovseg
       WHERE cmotmov = k_motivoanula
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
      vtraza := 1100;
      cerror := pac_anulacion.f_anula_poliza(n_seg, k_motivoanula,
                                             f_parinstalacion_n('MONEDAINST'), d_baj, 0,   -- pcextorn
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
                  (x.proceso, x.nlinea, x.tipo_oper, 4, 1, n_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.num_poliza_dkv,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.P_INICIAR_SUPLE';
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
         p_des := 'permite suplemento (s=' || p_seg || ' e=' || p_efe || ' m=' || p_mot || ')'
                  || ' ' || f_axis_literales(cerror, k_idiomaaaxis);

         IF cerror = 103308 THEN
            p_des := p_des || '.Editar linea, modificar fecha suplemento y reprocesar linea';
         END IF;

         RAISE errdatos;
      END IF;

      vtraza := 1061;
      vtraza := 1062;
      p_est := NULL;
      cerror := pk_suplementos.f_inicializar_suplemento(p_seg, 'SUPLEMENTO', p_efe, 'BBDD',
                                                        '*', p_mot, p_est, p_mov);

      IF cerror <> 0 THEN
         p_des := 'inicializar suplemento (s=' || p_seg || ' e=' || p_efe || ' m=' || p_mot
                  || ')' || ' ' || f_axis_literales(cerror, k_idiomaaaxis);
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.P_FINALIZAR_SUPLE';
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
            p_tab_error(f_sysdate, f_user, 'PAC_CARGAS_DKV', 1,
                        'Error insertando en pds_estsegurosupl', SQLERRM);
      END;

      vtraza := 1094;
      cerror := pk_suplementos.f_grabar_suplemento_poliza(p_est, p_mov);

      IF cerror <> 0 THEN
         p_des := 'error grabar suplemento '
                  || NVL(f_axis_literales(cerror, k_idiomaaaxis), cerror);
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
         p_des := 'error emision ' || NVL(f_axis_literales(indice_e, k_idiomaaaxis), indice_e);
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.f_emitir_propuesta';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
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
      vtraza := 1096;
      p_emitir_propuesta(r_seg.cempres, r_seg.npoliza, r_seg.ncertif, r_seg.cramo,
                         r_seg.cmodali, r_seg.ctipseg, r_seg.ccolect, r_seg.cactivi, 1,
                         r_seg.cidioma, indice, indice_e, indice_t, pmensaje,   -- BUG 27642 - FAL - 30/04/2014
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
          param in x : registro tipo int_polizas_dkv
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
   FUNCTION f_modi_poliza(x IN OUT int_polizas_dkv%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_MODI_POLIZA';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_seg          seguros.sseguro%TYPE;
      n_pro          seguros.sproduc%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
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
      v_valaxis      int_codigos_emp.cvalaxis%TYPE;
      n_pos          NUMBER;
      --w_cambio_cc    NUMBER;
      wcnordban      NUMBER;
      -- FAL. 26/08/2011. Bug 0019231
      wfefecto       DATE;
      wsproduc       NUMBER;
      wcactivi       NUMBER;
      wiprianu       NUMBER;
      wipritar       NUMBER;
      wirecarg       NUMBER;
      wnorden        NUMBER;
      wcformul       NUMBER;
      wctipfra       NUMBER;
      wifranqu       NUMBER;
      wnparben       NUMBER;
      wnbns          NUMBER;
      wcderreg       NUMBER;
      wctipgar       NUMBER;
   -- Fi bug 0019231
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
---------------------------------------------------------
-- VALIDAR CAMPOS CLAVE: Póliza, Certificado           --
---------------------------------------------------------
      vtraza := 1010;

      IF LTRIM(x.cpolcia) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      v_valaxis := pac_cargas_dkv.f_buscavalor('CRT_PRODUCTOACTDKV',
                                               LTRIM(TO_CHAR(x.ramo_dkv, '099')));

      SELECT INSTR(v_valaxis, '/')
        INTO n_pos
        FROM DUAL;

      IF n_pos = 0 THEN
         v_sproduc := v_valaxis;
      --v_mig_seg.cactivi := 0;
      ELSE
         SELECT SUBSTR(v_valaxis, 1, n_pos - 1)   --, SUBSTR(v_valaxis, n_pos + 1)
           INTO v_sproduc   --, v_mig_seg.cactivi
           FROM DUAL;
      END IF;

      BEGIN
         SELECT sseguro, sproduc, fefecto, f_vigente(sseguro, NULL, f_sysdate), cagente,
                csituac
           INTO n_seg, n_pro, d_efe, n_vig, n_cagente,
                n_csituac
           FROM seguros
          WHERE cpolcia = x.cpolcia
            AND sproduc = v_sproduc
            AND cempres = k_empresaaxis;

         BEGIN
            IF (NVL(n_cagente, -1) <> NVL(TO_NUMBER(x.agencia_banco_de_cobro), -1)
                AND x.banco_de_cobro = 3081) THEN   -- si la oficina gestora es diferente al cargada en la póliza
               p_deserror := 'La póliza ' || TO_CHAR(x.cpolcia)
                             || ' ha cambiado de oficina. Anterior ' || n_cagente || ' por '
                             || x.agencia_banco_de_cobro;
               cerror := 9000815;
               n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      IF n_seg IS NULL THEN
         d_efe := converteix_charadate(LTRIM(TO_CHAR(x.dia_efecto, '09'))
                                       || LTRIM(TO_CHAR(x.mes_efecto, '09'))
                                       || LTRIM(TO_CHAR(x.anyo_efecto, '0999')),
                                       'ddmmyyyy');

         BEGIN
            SELECT seg.sseguro, sproduc, fefecto, 0,
                   seg.cagente   -- f_vigente(seg.sseguro, NULL, f_sysdate)
                              -- esta póliza deberia estar en propuesta de alta
            ,      csituac
              INTO n_seg, n_pro, d_efe, n_vig,
                   n_cagente, n_csituac
              FROM seguros seg, tomadores tom, per_personas per
             WHERE fefecto = d_efe
               AND sproduc = v_sproduc
               AND tom.sseguro = seg.sseguro
               AND per.sperson =
                     tom.sperson   -- cualquier tomador con ese nif, esa fecha fecha, ese producto
               AND TRIM(BOTH '0' FROM per.nnumide) = TRIM(BOTH '0' FROM x.dni_tomador)
               AND cpolcia IS NULL
               AND cempres = k_empresaaxis
               AND ROWNUM = 1;

            -- si encuentro la poliza aqui significa que la tengo que eimtir primero
            IF n_csituac = 4 THEN
               cerror := f_emitir_propuesta(n_seg, p_deserror);

               IF cerror <> 0 THEN
                  p_deserror := 'Error emitiendo la póliza ' || x.cpolcia;
                  RAISE errdatos;
               END IF;
            ELSE
               p_deserror := 'Número póliza en estado incorrecto: ' || x.cpolcia;
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

         IF n_seg IS NULL THEN
            p_deserror := 'Número póliza no existe: ' || x.cpolcia;
            cerror := 100500;
            RAISE errdatos;
         END IF;
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
      vtraza := 1025;
      d_sup := converteix_charadate(LTRIM(TO_CHAR(x.dia_suplemento, '09'))
                                    || LTRIM(TO_CHAR(x.mes_suplemento, '09'))
                                    || LTRIM(TO_CHAR(x.anyo_suplemento, '0999')),
                                    'ddmmyyyy');

      IF d_sup IS NULL THEN
         p_deserror := 'Fecha suplemento no es fecha: ' || x.dia_suplemento || '-'
                       || x.mes_suplemento || '-' || x.anyo_suplemento || ' (dd-mm-aaaa)';
         p_deserror := p_deserror || '. Editar linea, modificar fecha suplemento y reprocesar';
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, p_deserror);
         b_warning := TRUE;

         --cerror := 1000135;
         -- RAISE errdatos;
         SELECT MAX(fefecto)
           INTO d_sup
           FROM movseguro
          WHERE sseguro = n_seg;
      END IF;

      IF d_sup < d_efe THEN
         p_deserror := 'Suplemento: ' || TO_CHAR(d_sup, 'dd-mm-yyyy')
                       || ' inferior a efecto póliza: ' || TO_CHAR(d_efe, 'dd-mm-yyyy');
         --cerror := 180386;
         --RAISE errdatos;
         d_sup := d_efe;   -- que lo haga a fefecto
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, p_deserror);
         b_warning := TRUE;

         IF n_aux <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

--------------------------------------------------------------------------
-- iniciar suple
--------------------------------------------------------------------------
      vtraza := 1030;
      cerror := pac_cargas_dkv.p_iniciar_suple(n_seg, d_sup, k_motivomodif, n_est, n_mov,
                                               p_deserror);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

--------------------------------------------------------------------------
-- modificacions
--------------------------------------------------------------------------
      vtraza := 1040;

      BEGIN
         UPDATE estseguros
            SET tnatrie = 'Número asegurados ' || x.num_asegurados,
                nsuplem = x.n_suplemento
          WHERE sseguro = n_est;
      EXCEPTION
         WHEN OTHERS THEN
            p_deserror := 'Error ' || SQLCODE || ' Número asegurados: ' || x.num_asegurados;
            cerror := 104566;
            RAISE errdatos;
      END;

      vtraza := 1045;
        /*  JLB - de momento no tengo clara la fecha de vencimiento para que vale y como usarla
                IF (LTRIM(x.dia_vencmto) || LTRIM(x.mes_vencmto) || LTRIM(x.anyo_vencmto) IS NOT NULL)
             AND(NOT (x.dia_vencmto = 0
                      AND x.mes_vencmto = 0
                      AND x.anyo_vencmto = 0)) THEN
             d_aux  := converteix_charadate(LTRIM(TO_CHAR(x.dia_vencmto, '09')) || LTRIM(TO_CHAR(
                                            x.mes_vencmto, '09')) || LTRIM(TO_CHAR(x.anyo_vencmto
                                            , '0999')), 'ddmmyyyy');
             IF d_aux IS NULL THEN
                p_deserror := 'Vencimiento no es fecha: ' || x.dia_vencmto || '-' || x.
                              mes_vencmto || '-' || x.anyo_vencmto || ' (dd-mm-aaaa)';
                cerror     := 1000135;
                RAISE errdatos;
             END IF;
             vtraza := 1050;
             BEGIN
                UPDATE estseguros
                SET fvencim  = d_aux
                WHERE sseguro = n_est
                      AND fvencim <> d_aux;
             EXCEPTION
                WHEN OTHERS THEN
                   p_deserror := 'Error ' || SQLCODE || ' Vencimiento: ' || TO_CHAR(d_aux,
                                 'dd-mm-yyyy');
                   cerror     := 104566;
                   RAISE errdatos;
             END;
          END IF;
      */
      vtraza := 1055;
      vtraza := 1060;

      IF NVL(x.banco_de_cobro, 0) <> 0 THEN
         DECLARE
            v_cbancar      seguros.cbancar%TYPE;
            n_control      NUMBER;
            v_salida       VARCHAR2(50);
         BEGIN
            vtraza := 1065;
            v_cbancar := LTRIM(TO_CHAR(x.banco_de_cobro, '0999'))
                         || LTRIM(TO_CHAR(x.agencia_banco_de_cobro, '0999'))
                         || LTRIM(TO_CHAR(x.digitos_control_cta_cobro, '09'))
                         || LTRIM(TO_CHAR(x.cta_cte_de_cobro, '0999999999'));
            vtraza := 1070;
            cerror := f_ccc(TO_NUMBER(v_cbancar), 1, n_control, v_salida);

            IF cerror <> 0 THEN
               p_deserror := 'Error ' || cerror || ' al validar cuenta bancaria: '
                             || v_cbancar;
               cerror := 120130;
               RAISE errdatos;
            END IF;

            vtraza := 1075;

                       /* w_cambio_cc := 0;

                        SELECT COUNT(*)
                          INTO w_cambio_cc
                          FROM estseguros
                         WHERE sseguro = n_est
                           AND cbancar <> v_cbancar
                           AND ctipban = 1;
            */
            UPDATE estseguros
               SET cbancar = v_cbancar,
                   ctipban = 1,
                   ctipcob = 2
             WHERE sseguro = n_est;

            --AND nvl(cbancar,-1) <> v_cbancar;
            IF SQL%ROWCOUNT > 0 THEN
               FOR tom IN (SELECT sperson
                             FROM tomadores tom
                            WHERE sseguro = n_seg
                              AND NOT EXISTS(SELECT 1
                                               FROM per_ccc ccc
                                              WHERE tom.sperson = ccc.sperson
                                                AND ccc.cbancar = v_cbancar)) LOOP
                  BEGIN
                     SELECT NVL(MAX(cnordban), 0) + 1
                       INTO wcnordban
                       FROM per_ccc
                      WHERE sperson = tom.sperson;

                     IF wcnordban <= 99 THEN
                        INSERT INTO per_ccc
                                    (sperson,
                                     cagente, ctipban,
                                     cbancar, fbaja, cdefecto, cusumov, fusumov, cnordban)
                             VALUES (tom.sperson,
                                     NVL(ff_agente_cpervisio(n_cagente), k_agentedefec), 1,
                                     v_cbancar, NULL, 0, f_user, f_sysdate, wcnordban);
                     END IF;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
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

      IF LTRIM(x.periodo_de_cobro) IS NOT NULL THEN
         DECLARE
            v_cforpag      seguros.cforpag%TYPE;
         BEGIN
            vtraza := 1085;
            v_cforpag := pac_cargas_dkv.f_buscavalor('CRT_FORMAPAGO', x.periodo_de_cobro);

            IF v_cforpag IS NULL THEN
               p_deserror := 'Forma de pago no definida: ' || x.periodo_de_cobro
                             || ' (CRT_FORMAPAGO)';
               p_deserror := p_deserror
                             || '. Editar linea, modificar forma de pago y reprocesar';
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
               p_deserror := 'Error ' || SQLCODE || ' Cuenta forma pago: '
                             || x.periodo_de_cobro;
               cerror := 140704;
               RAISE errdatos;
         END;
      END IF;

      vtraza := 1095;

      -- FAL. 26/08/2011. Bug 0019231: CRT003 - Error en las cargas (no hace suplementos de garantias)
      -- Eliminamos garantias existentes
      DELETE      estgaranseg
            WHERE sseguro = n_est
              AND nmovimi = n_mov;

      -- FAL. 26/08/2011. recuperamos valores de seguros. Bug 0019231
      SELECT fefecto, sproduc, cactivi
        INTO wfefecto, wsproduc, wcactivi
        FROM estseguros
       WHERE sseguro = n_est;

      DECLARE
         n_garaxis      NUMBER;

         PROCEDURE p_capit(p_gar IN VARCHAR2, p_cap IN NUMBER) IS
         BEGIN
            vtraza := 1280;
            --  IF NVL(p_cap, 0) <> 0 THEN
            -- Si existe capital, comprobamos si existe garantia definida.
            vtraza := 1285;
            n_garaxis := pac_cargas_dkv.f_buscavalor('CRT_GRANTIADKV',
                                                     LTRIM(TO_CHAR(x.ramo_dkv, '099'))
                                                     || p_gar);

            IF n_garaxis IS NULL THEN
               /* -- inserto garantias para todas las garantias definidas en los productos
                           b_warning := TRUE;
               p_genera_logs(vobj, vtraza, 'capital_' || p_gar, 'capital sin garantia' ||
                             ' (' || x.proceso || '-' || x.nlinea || ')', x.proceso,
                             'capital_' || p_gar || ' capital sin garantia ' || ' (' || x.
                             proceso || '-' || x.nlinea || ')');
                */
               NULL;   -- jlb sino encuenta nulo.
            ELSE
               -- Asignamos las primas a la primera garantia por defecto.
               IF p_gar = '01' THEN
                  vtraza := 1300;
                  wiprianu := NVL(x.importe_prima_neta_anual, 0);
                  wirecarg := NVL(x.importe_tasas_anual, 0)
                              + NVL(x.importe_consorcio_anual, 0);
                  wipritar := wiprianu - wirecarg;
               ELSE
                  wiprianu := 0;
                  wirecarg := 0;
                  wipritar := 0;
               END IF;

               -- FAL. 26/08/2011. Recuperamos valores de la garantia. Bug 0019231
               SELECT norden, cformul, ctipfra, ifranqu, nparben, nbns, cderreg,
                      ctipgar
                 INTO wnorden, wcformul, wctipfra, wifranqu, wnparben, wnbns, wcderreg,
                      wctipgar
                 FROM garanpro
                WHERE sproduc = wsproduc
                  AND cactivi = wcactivi
                  AND cgarant = n_garaxis;

               -- FAL. 26/08/2011. Alta de las garantias que llegan. Bug 0019231
               INSERT INTO estgaranseg
                           (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                            ctarifa, icapital, precarg, iextrap, iprianu, ffinefe, cformul,
                            ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                            irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, crevalcar,
                            cgasgar, pgasadq, pgasadm, pdtoint, idtoint, feprev, fpprev,
                            percre, cmatch, tdesmat, pintfin, cref, cintref, pdif, pinttec,
                            nparben, nbns, tmgaran, cderreg, ccampanya, nversio, nmovima,
                            cageven, nfactor, nlinea, cfranq, nfraver, ngrpfra, ngrpgara,
                            nordfra, pdtofra, cmotmov, finider, falta, ctarman, cobliga,
                            ctipgar, itotanu)
                    VALUES (n_garaxis, 1, n_mov, n_est, wfefecto, wnorden, 0,
                            NULL, p_cap, 0, 0, wiprianu, NULL, wcformul,
                            wctipfra, wifranqu, wirecarg, wipritar, 0, 0, 0,
                            0, NULL, NULL, wiprianu, p_cap, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                            wnparben, wnbns, NULL, wcderreg, NULL, NULL, 1,
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                            wctipgar, NULL);
            END IF;
         -- END IF;
         END;
      BEGIN
         vtraza := 1330;
         p_capit('01', x.capital_garantia_01);
         p_capit('02', x.capital_garantia_02);
         p_capit('03', x.capital_garantia_03);
         p_capit('04', x.capital_garantia_04);
         p_capit('05', x.capital_garantia_05);
         p_capit('06', x.capital_garantia_06);
         p_capit('07', x.capital_garantia_07);
         p_capit('08', x.capital_garantia_08);
         p_capit('09', x.capital_garantia_09);
         p_capit('10', x.capital_garantia_10);
      END;

      -- FAL. 26/08/2011. El update ya no es necesario. Bug 0019231
      /*
      DECLARE
         n_garaxis      NUMBER;
         marcado        BOOLEAN;

         PROCEDURE p_capit(p_gar IN VARCHAR2, p_cap IN NUMBER) IS
            n_pri          NUMBER;
            n_rec          NUMBER;
            n_tot          NUMBER;
            n_gar2         NUMBER;
         BEGIN
            IF p_gar IS NOT NULL THEN   --FAL. Si no esta informado la desc. garantia-> nada
               n_garaxis := pac_cargas_dkv.f_buscavalor('CRT_GRANTIADKV',
                                                        LTRIM(TO_CHAR(x.ramo_dkv, '099'))
                                                        || p_gar);

               IF n_garaxis IS NULL THEN
                  --p_deserror := 'int_codigos_emp no definido: ' || LTRIM(TO_CHAR(x.ramo_dkv,
                  --               '099')) || p_gar || ' (CRT_GRANTIADKV)';
                  --cerror     := 9001108;
                  --RAISE errdatos;
                  -- jlb actualizo todo
                  NULL;
               ELSE
                  -- Si existe prima neta, entiendo que modifican los importes de las primas.
                  IF NOT marcado THEN
                     n_pri := NVL(x.importe_prima_neta_anual, 0);
                     n_rec := NVL(x.importe_tasas_anual, 0)
                              + NVL(x.importe_consorcio_anual, 0);
                     n_tot := NVL(x.importe_prima_total_anual, 0);

                     UPDATE estgaranseg
                        SET iprianu = n_pri,
                            irecarg = n_rec,
                            --ipritot = n_tot
                            ipritar = n_pri,
                            ipritot = n_pri,
                            icapital = p_cap,
                            icaptot = p_cap
                      WHERE sseguro = n_est
                        AND cgarant = n_garaxis
                        AND nmovimi = n_mov;

                     --AND finiefe IS NULL;
                     marcado := TRUE;
                  ELSE
                     -- Si es la garantia que tratamos, asignamos el capital.
                     UPDATE estgaranseg
                        SET icapital = p_cap,
                            icaptot = p_cap
                      WHERE sseguro = n_est
                        AND cgarant = n_garaxis
                        AND nmovimi = n_mov;
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_deserror := 'Error ' || SQLCODE || ' Capital: ' || p_cap || ' garantia: '
                             || n_garaxis;
               cerror := 9001108;
               RAISE errdatos;
         END;
      BEGIN
         marcado := FALSE;
         p_capit('01', x.capital_garantia_01);
         p_capit('02', x.capital_garantia_02);
         p_capit('03', x.capital_garantia_03);
         p_capit('04', x.capital_garantia_04);
         p_capit('05', x.capital_garantia_05);
         p_capit('06', x.capital_garantia_06);
         p_capit('07', x.capital_garantia_07);
         p_capit('08', x.capital_garantia_08);
         p_capit('09', x.capital_garantia_09);
         p_capit('10', x.capital_garantia_10);
      END;
      */

      --------------------------------------------------------------------------
-- finalitzar suple
--------------------------------------------------------------------------
      vtraza := 1100;

      INSERT INTO estdetmovseguro
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                   tvalord, cpregun)
           VALUES (n_est, n_mov, k_motivomodif, 0, 0, NULL,
                   'Carga proceso ' || x.proceso || '/' || x.nlinea, 0);

      vtraza := 1110;

      UPDATE estpregunpolseg
         SET crespue = x.num_asegurados
       WHERE cpregun = 7102
         AND sseguro = n_est
         AND nmovimi = n_mov;

      vtraza := 1115;

      --actualizamos la tabla de solicitud de suplementos
      UPDATE sup_solicitud
         SET cestsup = 1
       WHERE sseguro = n_seg
         AND cestsup = 2;

      vtraza := 1116;
/*      INSERT INTO estdetmovseguro
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                   tvalord, cpregun)
           VALUES (n_est, n_mov, k_motivomodif, 0, 0, NULL,
                   'Carga proceso ' || x.proceso || '/' || x.nlinea, 0);*/
      vtraza := 1117;
      cerror := p_finalizar_suple(n_est, n_mov, n_seg, p_deserror, k_motivomodif, x.proceso,
                                  d_sup);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

      vtraza := 1120;

---------------------------------------------------------
-- CONTROL FINAL                                       --
---------------------------------------------------------
      IF b_warning THEN
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, n_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
                                    -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF n_aux <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         IF v_deswarning IS NOT NULL THEN
            n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, v_deswarning);

            IF n_aux <> 0 THEN
               RAISE errdatos;
            END IF;
         END IF;
      ELSE
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, n_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
                                    -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
      END IF;

      RETURN 4;   -- Correcto
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
                                    -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (traza=' || vtraza || '- n_est='
                       || n_est || ' ) ' || SQLCODE || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.num_poliza_dkv,   -- Fi Bug 14888
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
   FUNCTION f_ejecutar_carga_proceso(psproces IN NUMBER, p_cproces IN NUMBER)   -- BUG16130:DRA:15/10/2010
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_EJECUTAR_CARGA_PROCESO';

      CURSOR polmigra(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_polizas_dkv a
            WHERE proceso = psproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.proceso
                                AND int_carga_ctrl_linea.nlinea = a.nlinea
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5))   --Solo las no procesadas
         ORDER BY nlinea;

      vtraza         NUMBER := 0;
      verror         NUMBER;
      vdeserror      VARCHAR2(1000);
      e_errdatos     EXCEPTION;
      e_salir        EXCEPTION;
      errorini       EXCEPTION;   --Indica error grabando estados.--Error que para ejecución
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
      verrorfin      BOOLEAN := FALSE;
      vavisfin       BOOLEAN := FALSE;
      vtiperr        NUMBER;
      vcoderror      NUMBER;
      n_imp          NUMBER;
      v_deserror     int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero     int_carga_ctrl.tfichero%TYPE;
      -- n_cfg_cproceso cfg_files.cproceso%TYPE;   -- BUG16130:DRA:15/10/2010:Inici
         -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
      wsinterf       int_mensajes.sinterf%TYPE;
   -- Fi 17569
   BEGIN
      vtraza := 0;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         v_deserror := 'Parámetro psproces obligatorio.';
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, v_deserror, NULL,
                                      NULL);
         RAISE e_salir;
      END IF;

      vtraza := 3;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         v_deserror := 'Falta fichero para proceso: ' || psproces;
         RAISE e_errdatos;
      END IF;

      vtraza := 6;

      -- BUG16130:DRA:15/10/2010:Inici
      -- SELECT MAX(cproceso)
      --   INTO n_cfg_cproceso
      --   FROM cfg_files
      --  WHERE cempres = k_empresaaxis
      --    AND cactivo = 1
      --    AND UPPER(tproceso) = RTRIM(vobj, '_PROCESO');
      -- BUG16130:DRA:15/10/2010:Fi
      IF p_cproces IS NULL THEN
         vnum_err := 9901092;
         v_deserror := 'cfg_files falta proceso: ' || vobj;
         RAISE e_errdatos;
      END IF;

      vtraza := 9;

      FOR x IN polmigra(psproces) LOOP   --Leemos los registros de la tabla int no procesados OK
         -- Bug 0016324. FAL. 18/10/2010
         IF NVL(vtiperr, 0) <> 1 THEN
            -- Fi Bug 0016324
            IF x.tipo_oper = 'ALTA' THEN   --Si es alta
               vtraza := 12;
               verror := f_alta_poliza(x, v_deserror, wsinterf);

               IF verror IN(0, -2) THEN   --Si ha ido bien o tenemos avisos.
                  IF verror = -2 THEN   -- Avisos.
                     vtraza := 15;
                     vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 2, 0, NULL,

                                              -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                              x.num_poliza_dkv,
                                              -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                              x.ncarga
                                                      -- Fi Bug 16324
                                );

                     IF vnum_err <> 0 THEN
                        v_deserror := 'Falta marcar linea estado aviso';
                        RAISE e_errdatos;
                     END IF;

                     vavisfin := TRUE;
                     verror := 0;
                  END IF;

                  vtraza := 18;
                  vtiperr := f_alta_poliza_seg(x, wsinterf);

                  IF vtiperr = 2 THEN
                     vavisfin := TRUE;
                  END IF;

                  IF LTRIM(x.motivo_baja) IS NOT NULL
                     AND vtiperr IN(4, 2) THEN   -- 11/11/2010
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
                  vtraza := 21;
                  vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 1, 0, NULL,

                                           -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                           x.num_poliza_dkv,
                                           -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                           x.ncarga
                                                   -- Fi Bug 16324
                             );

                  IF vnum_err <> 0 THEN
                     v_deserror := 'Falta marcar linea estado error';
                     RAISE e_errdatos;
                  END IF;

                  vtraza := 24;
                  vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,
                                                v_deserror);

                  IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
                     v_deserror := 'Falta marcar ' || verror || ' ' || v_deserror;
                     RAISE e_errdatos;
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
            ELSIF x.tipo_oper = 'MODI' THEN
               vtraza := 27;
               vtiperr := f_modi_poliza(x, v_deserror);

               IF vtiperr = 2 THEN
                  vavisfin := TRUE;
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
            ELSIF x.tipo_oper = 'BAJA' THEN
               vtraza := 30;
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
            ELSIF x.tipo_oper = 'NADA' THEN
               vtraza := 31;
               vtiperr := 2;
               vnum_err := p_marcalinea(psproces, x.nlinea, x.tipo_oper, 2, 0, NULL,

                                        -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                        x.num_poliza_dkv,
                                        -- Fi Bug 14888
                                        -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                        x.ncarga
                                                -- Fi Bug 16324
                          );

               IF vnum_err <> 0 THEN
                  v_deserror := 'Falta marcar linea estado error';
                  RAISE e_errdatos;
               END IF;

               vtraza := 24;
               v_deserror := 'La línea no necesita tratamiento';
               vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 2, verror, v_deserror);

               IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
                  v_deserror := 'Falta marcar ' || verror || ' ' || v_deserror;
                  RAISE e_errdatos;
               END IF;
            END IF;

            IF vtiperr = 1 THEN   --Ha habido error
               verrorfin := TRUE;
            ELSIF vtiperr = 2 THEN   -- Es un warning
               vavisfin := TRUE;
            ELSIF vtiperr = 4 THEN   --Ha ido bien.
               NULL;
            ELSE
               vnum_err := vtiperr;
               RAISE e_errdatos;   --Error que para ejecución(funciones de gestión)
            END IF;

            vtraza := 33;
            COMMIT;
         -- Bug 0016324. FAL. 18/10/2010
         ELSIF vtiperr = 1
               AND k_para_carga = 1 THEN
            vtiperr := 1;
            vcoderror := 151541;
            --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
            vnum_err :=
               pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (psproces, v_tfichero, f_sysdate,
                                                          f_sysdate, vtiperr, p_cproces,   -- BUG16130:DRA:29/09/2010
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
      vtraza := 36;
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero, f_sysdate,
                                                        f_sysdate, vtiperr, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        vcoderror, NULL);

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         v_deserror := 'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera';
         RAISE e_errdatos;
      END IF;

      --Bug.:17155
      IF vtiperr IN(4, 2) THEN
         vnum_err := pac_gestion_procesos.f_set_carga_fichero(32, v_tfichero, 1, f_sysdate);

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            v_deserror := 'Error llamando a pac_gestion_procesos.f_set_carga_fichero';
            RAISE e_errdatos;
         END IF;
      END IF;

      --Fi Bug.: 17155
      vtraza := 39;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         RETURN 1;
      WHEN e_errdatos THEN
         ROLLBACK;
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, v_deserror,
                                      psproces, 'Error:' || vnum_err || ' ' || v_deserror);
         COMMIT;
         RETURN 1;
      -- Bug 0016324. FAL. 18/10/2010
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         pac_cargas_dkv.p_genera_logs(vobj, vtraza,
                                      'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                      'Error:' || 'Insertando estados registros', psproces,
                                      f_axis_literales(108953, k_idiomaaaxis) || ':'
                                      || v_tfichero || ' : ' || 'errorini');
         COMMIT;
         RETURN 1;
      -- Fi Bug 0016324
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                      f_axis_literales(103187, k_idiomaaaxis) || ':'
                                      || v_tfichero || ' : ' || SQLERRM);
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (psproces, v_tfichero, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          151541, SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_dkv.p_genera_logs
                          (vobj, vtraza, vnum_err,
                           'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                           psproces,
                           f_axis_literales(180856, k_idiomaaaxis) || ':' || v_tfichero
                           || ' : ' || vnum_err);
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
      v_nrecibo      recibos.nrecibo%TYPE;
      v_nombre       personas.tbuscar%TYPE;
      v_importe      NUMBER;
      v_fcobro       recibos.fefecto%TYPE;
      v_ind          NUMBER;
      v_ind2         NUMBER;
      num_err        NUMBER;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(1) := NULL;
      vobj           VARCHAR2(200) := 'pac_cargas_dkv.f_lee_fichero';
      registro       int_polizas_dkv%ROWTYPE;
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
      v_map          map_cabecera.cmapead%TYPE := 'C0010';   -- Carga Polizas DKV
      v_sec          NUMBER;
      v_valaxis      int_codigos_emp.cvalaxis%TYPE;
      vnsuplem       seguros.nsuplem%TYPE;
      n_pos          NUMBER;
      vfefecto       seguros.fefecto%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
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
      v_pasexec := 3;
      v_numerr := pac_map.carga_map(v_map, v_sec);

      IF v_numerr <> 0 THEN
         RAISE errgrabarprov;
      END IF;

      -- Bug 0016324. FAL. 18/10/2010.
      UPDATE int_polizas_dkv
         SET proceso = psproces
       WHERE sinterf = psproces;

      COMMIT;

      DECLARE
         v_tipo         int_polizas_dkv.tipo_oper%TYPE;

         CURSOR c1 IS
            SELECT ROWID, nlinea, n_suplemento, motivo_baja,
                   LPAD(sucursal_dkv, 3, '0') || LPAD(oficina_dkv, 2, '0')
                   || LPAD(ramo_dkv, 3, '0') || LPAD(num_poliza_dkv, 5, '0')
                   || LPAD(orden_poliza, 5, '0') polcia,
                   num_poliza_dkv, ramo_dkv,
                                            -- Bug 0016324. FAL. 18/10/2010.
                                            proceso,
                                                    -- Fi bug 0016324
                                                    -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                                    ncarga, dni_tomador,
                   LTRIM(TO_CHAR(dia_efecto, '09'))
                   || LTRIM(TO_CHAR(mes_efecto, '09'))
                   || LTRIM(TO_CHAR(anyo_efecto, '0999')) fefecto,
                   dia_suplemento dia_suplemento
              -- Fi Bug 16324
            FROM   int_polizas_dkv
             WHERE proceso = psproces;
      BEGIN
         FOR f1 IN c1 LOOP
            v_pasexec := 5;
            v_valaxis := pac_cargas_dkv.f_buscavalor('CRT_PRODUCTOACTDKV',
                                                     LTRIM(TO_CHAR(f1.ramo_dkv, '099')));

            SELECT INSTR(v_valaxis, '/')
              INTO n_pos
              FROM DUAL;

            IF n_pos = 0 THEN
               v_sproduc := v_valaxis;
            ELSE
               SELECT SUBSTR(v_valaxis, 1, n_pos - 1)   --, SUBSTR(v_valaxis, n_pos + 1)
                 INTO v_sproduc   --, v_mig_seg.cactivi
                 FROM DUAL;
            END IF;

            BEGIN
               BEGIN
                  SELECT 1, nsuplem
                    INTO waux, vnsuplem
                    FROM seguros
                   WHERE cpolcia = f1.polcia
                     AND sproduc = v_sproduc
                     AND cempres = k_empresaaxis;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN   -- si no existe con la poliza la busco por producto,fefecto, tomador
                     vfefecto := converteix_charadate(f1.fefecto, 'ddmmyyyy');

                     SELECT 1, nsuplem
                       INTO waux, vnsuplem
                       FROM seguros seg, tomadores tom, per_personas per
                      WHERE fefecto = vfefecto
                        AND sproduc = v_sproduc
                        AND tom.sseguro = seg.sseguro
                        AND cpolcia IS NULL
                        AND per.sperson =
                              tom.sperson   -- cualquier tomador con ese nif, esa fecha fecha, ese producto
                        AND TRIM(BOTH '0' FROM per.nnumide) =
                                                             TRIM(BOTH '0' FROM f1.dni_tomador)
                        --AND csituac <> 14
                        AND csituac = 4   -- FAL - 8/11/2011 - Bug 0020084
                        AND ROWNUM = 1;
               END;

               IF waux = 0 THEN
                  v_tipo := 'ALTA';
               ELSIF waux = 1 THEN
                  IF LTRIM(f1.motivo_baja) IS NOT NULL THEN
                     v_tipo := 'BAJA';
                  ELSE
                     IF (f1.dia_suplemento <> 0
                         AND(NVL(vnsuplem, 0) < NVL(f1.n_suplemento, 0))) THEN   --tenemos que mirar en n_suplemento
                        v_tipo := 'MODI';
                     ELSE
                        -- hacemos una ultima comprobación
                        SELECT COUNT('1')
                          INTO waux
                          FROM (SELECT capital_garantia_01, capital_garantia_02,
                                       capital_garantia_03, capital_garantia_04,
                                       capital_garantia_05, capital_garantia_06,
                                       capital_garantia_07, capital_garantia_08,
                                       capital_garantia_09, capital_garantia_10,
                                       importe_prima_neta_anual, importe_tasas_anual,
                                       importe_consorcio_anual, importe_prima_total_anual
                                  FROM int_polizas_dkv
                                 WHERE proceso = psproces
                                   AND nlinea = f1.nlinea
                                MINUS
                                SELECT capital_garantia_01, capital_garantia_02,
                                       capital_garantia_03, capital_garantia_04,
                                       capital_garantia_05, capital_garantia_06,
                                       capital_garantia_07, capital_garantia_08,
                                       capital_garantia_09, capital_garantia_10,
                                       importe_prima_neta_anual, importe_tasas_anual,
                                       importe_consorcio_anual, importe_prima_total_anual
                                  FROM int_polizas_dkv
                                 WHERE proceso = (SELECT MAX(proceso)
                                                    FROM int_polizas_dkv
                                                   WHERE cpolcia = f1.polcia
                                                     AND proceso <> psproces)
                                   AND cpolcia = f1.polcia);

                        IF waux = 0 THEN
                           v_tipo := 'NADA';
                        ELSE
                           v_tipo := 'MODI';
                        END IF;
                     END IF;
                  END IF;
               END IF;
            /*   IF f1.n_suplemento = 0
                                                      AND LTRIM(f1.motivo_baja) IS NULL THEN
                  v_tipo := 'ALTA';
               ELSIF f1.n_suplemento > 0
                     AND LTRIM(f1.motivo_baja) IS NULL THEN
                  v_tipo := 'MODI';
               ELSIF LTRIM(f1.motivo_baja) IS NOT NULL THEN
                  v_tipo := 'BAJA';
               ELSE
                  v_tipo := NULL;
               END IF;
            */
            EXCEPTION
               WHEN OTHERS THEN
                  v_tipo := 'ALTA';
            END;

            -- Fi bug 0016324
            v_pasexec := 6;
            -- Marcar como pendiente.
            v_numerr :=
               p_marcalinea
                  (psproces, f1.nlinea, v_tipo, 3, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   f1.num_poliza_dkv,   -- Fi Bug 14888
                                        -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   f1.ncarga   -- Fi Bug 16324
                            );

            IF v_numerr <> 0 THEN
               RAISE errgrabarprov;
            END IF;

            v_pasexec := 7;

            UPDATE int_polizas_dkv
               SET tipo_oper = v_tipo,
                   cpolcia = f1.polcia
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_EJECUTAR_CARGA_FICHERO';
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
   -- n_cfg_cproceso cfg_files.cproceso%TYPE;   -- BUG16130:DRA:15/10/2010
   BEGIN
      vtraza := 0;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_DKV', p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecución
      END IF;

      vtraza := 1;

      -- BUG16130:DRA:15/10/2010:Inici
      -- SELECT MAX(cproceso)
      --   INTO n_cfg_cproceso
      --   FROM cfg_files
      --  WHERE cempres = k_empresaaxis
      --    AND cactivo = 1
      --    AND UPPER(tproceso) = RTRIM(vobj, '_FICHERO');
      -- BUG16130:DRA:15/10/2010:Fi
      IF p_cproces IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, 103778,
                     'cfg_files falta proceso: ' || vobj);
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(103778, k_idiomaaaxis) || ': '
                                 || 'cfg_files falta proceso: ' || vobj,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      psproces := v_sproces;
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre, f_sysdate, NULL,
                                                        3, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        NULL, NULL);
      vtraza := 2;

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
      vtraza := 3;
      f_lee_fichero(p_nombre, p_path, vdeserror, v_sproces);
      vtraza := 4;

      IF vdeserror IS NOT NULL THEN   --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_sproces, p_nombre, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
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
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_sproces, p_nombre, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_EJECUTAR_CARGA';
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
         vnum_err :=
            pac_cargas_dkv.f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                                    psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_dkv.f_ejecutar_carga_proceso(psproces, p_cproces);   -- BUG16130:DRA:15/10/2010

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
   END f_ejecutar_carga;

   /*************************************************************************
                                                                                                                                                                        procedimiento que da de alta recibo en las mig
          param in x : registro tipo INT_RECIBOS_DKV
      *************************************************************************/
   FUNCTION f_altarecibo_mig(x IN OUT int_recibos_dkv%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_ALTARECIBO_MIG';
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
      v_creccia      int_recibos_dkv.creccia%TYPE;
      v_cpolcia      seguros.cpolcia%TYPE;
      n_aux          NUMBER;
      n_seg          seguros.sseguro%TYPE;
      n_pro          seguros.sproduc%TYPE;
      v_valaxis      int_codigos_emp.cvalaxis%TYPE;
      n_pos          NUMBER;
   BEGIN
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      pid := x.nlinea;
      b_warning := FALSE;
      vtraza := 1005;

      SELECT ROWID
        INTO v_rowid_ini
        FROM int_recibos_dkv
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      --Inicializamos la cabecera de la carga
      vtraza := 1010;
      v_ncarga := f_next_carga;
      x.ncarga := v_ncarga;   -- Bug 0016324. FAL. 26/10/2010. Asignamos v_ncarga antes de posible error para registrarlo en la linea de carga
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Recibos', v_seq);
      vtraza := 1015;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, pid, 'OK');

-------------------- Valida ---------------------
      vtraza := 1025;
      v_creccia := LPAD(x.sucursal_dkv, 3, '0') || LPAD(x.oficina_dkv, 2, '0')
                   || LPAD(x.ramo_dkv, 3, '0') || LPAD(x.numero_de_recibo, 5, '0')
                   || LPAD(x.orden_recibo, 5, '0');
      vtraza := 1030;

      SELECT COUNT(1)
        INTO n_aux
        FROM recibos
       WHERE creccia = v_creccia
         AND cempres = k_empresaaxis;

      IF n_aux > 0 THEN
         verror := 'Ya existe recibo cia: ' || v_creccia || '/' || k_empresaaxis;
         cerror := 102367;
         RAISE errdatos;
      END IF;

      vtraza := 1035;
      v_cpolcia := LPAD(x.sucursal_dkv, 3, '0') || LPAD(x.oficina_dkv, 2, '0')
                   || LPAD(x.ramo_dkv, 3, '0') || LPAD(x.num_poliza_dkv, 5, '0')
                   || LPAD(x.orden_poliza_dkv, 5, '0');
      -- n_pro := pac_cargas_dkv.f_buscavalor('CRT_PRODUCTOACTDKV', LTRIM(TO_CHAR
      --                                                   (x.ramo_dkv, '099')));
      v_valaxis := pac_cargas_dkv.f_buscavalor('CRT_PRODUCTOACTDKV',
                                               LTRIM(TO_CHAR(x.ramo_dkv, '099')));

      SELECT INSTR(v_valaxis, '/')
        INTO n_pos
        FROM DUAL;

      IF n_pos = 0 THEN
         n_pro := v_valaxis;
      --v_mig_seg.cactivi := 0;
      ELSE
         SELECT SUBSTR(v_valaxis, 1, n_pos - 1)   --, SUBSTR(v_valaxis, n_pos + 1)
           INTO n_pro   --, v_mig_seg.cactivi
           FROM DUAL;
      END IF;

      BEGIN
         SELECT sproduc, sseguro
           INTO n_pro, n_seg
           FROM seguros
          WHERE cpolcia = v_cpolcia
            AND sproduc = n_pro
            AND cempres = k_empresaaxis;
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      IF n_seg IS NULL THEN
         verror := 'No existe póliza: ' || v_cpolcia;
         cerror := 140897;
         RAISE errdatos;
      END IF;

      vtraza := 1040;
    /*  SELECT COUNT(1)
                         INTO n_aux
      FROM productos a, codiram b
      WHERE a.sproduc = n_pro
            --AND a.cactivo = 1
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
           VALUES (v_ncarga, 'INT_RECIBOS_DKV', 'MIG_SEGUROS', 0, f_sysdate, f_sysdate);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RECIBOS_DKV', 'MIG_RECIBOS', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RECIBOS_DKV', 'MIG_DETRECIBOS', 2);

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
      v_mig_rec.fefecto := converteix_charadate(LTRIM(TO_CHAR(x.dia_efecto_rbo, '09'))
                                                || LTRIM(TO_CHAR(x.mes_efecto_rbo, '09'))
                                                || LTRIM(TO_CHAR(x.anyo_efecto_rbo, '0999')),
                                                'ddmmyyyy');

      IF v_mig_rec.fefecto IS NULL THEN
         verror := 'Fecha efecto no es fecha: ' || x.dia_efecto_rbo || '-' || x.mes_efecto_rbo
                   || '-' || x.anyo_efecto_rbo || ' (dd-mm-aaaa)';
         verror := verror || '. Editar linea, modificar fecha efecto recibo y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1070;
      v_mig_rec.fvencim := converteix_charadate(LTRIM(TO_CHAR(x.dia_vto_rbo, '09'))
                                                || LTRIM(TO_CHAR(x.mes_vto_rbo, '09'))
                                                || LTRIM(TO_CHAR(x.anyo_vto_rbo, '0999')),
                                                'ddmmyyyy');

      IF v_mig_rec.fvencim IS NULL THEN
         verror := 'Fecha vencimiento recibo no es fecha: ' || x.dia_vto_rbo || '-'
                   || x.mes_vto_rbo || '-' || x.anyo_vto_rbo || ' (dd-mm-aaaa)';
         verror := verror || '. Editar linea, modificar fecha vto. recibo y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1075;
      v_mig_rec.femisio := v_mig_rec.fefecto;
      v_mig_rec.ctiprec := 3;   -- Suponemos que son cartera
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
      v_mig_rec.cestrec := pac_cargas_dkv.f_buscavalor('CRT_ESTADORECIBO', x.estado_de_recibo);

      IF v_mig_rec.cestrec IS NULL THEN
         verror := 'Estado de recibo no definido: ' || x.estado_de_recibo
                   || ' (CRT_ESTADORECIBO)';
         verror := verror || '. Editar linea, modificar estado recibo y reprocesar';
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

         PROCEDURE crea_detalle(p_concep IN NUMBER, p_import IN NUMBER) IS
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
         crea_detalle(00, ABS(x.importe_prima_neta));   --> 00-Prima Neta
         crea_detalle(02, ABS(x.importe_consorcio));   --> 02-Consorcio
         crea_detalle(04, ABS(x.importe_tasas));   --> 04-Impuesto IPS
         crea_detalle(11, ABS(x.importe_comision));   --> 11-Comisión bruta
         crea_detalle(26, ABS(x.importe_talones_salud));   --> 26-Otros conceptos Recargos
      -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
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
      UPDATE seguros
         SET fcarpro = GREATEST(fcarpro, v_mig_rec.fvencim + 1),
             fcarant = GREATEST(NVL(fcarant, v_mig_rec.fefecto), v_mig_rec.fefecto),
             fcaranu = GREATEST(fcaranu,
                                TO_DATE(TO_CHAR(fcaranu, 'DDMM')
                                        || TO_CHAR(v_mig_rec.fvencim, 'YYYY'),
                                        'DDMMYYYY'))
       WHERE sseguro = n_seg;

      vtraza := 1147;

      UPDATE int_recibos_dkv
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
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error ' || cerror, verror, x.proceso,
                                      'Error ' || cerror || ' ' || verror);
         RETURN cerror;
      WHEN OTHERS THEN
         p_deserror := SQLCODE || ' ' || SQLERRM;
         ROLLBACK;
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'ERROR ' || SQLCODE, p_deserror,
                                      x.proceso, 'Error ' || p_deserror);
         RETURN cerror;
   END f_altarecibo_mig;

   /*************************************************************************
                      Función que da de alta recibo en las SEG
          param in x : registro tipo int_recibos_dkv
          return : 1 si ha habido error
                   2 si ha habido warning
                   4 si ha ido bien
      *************************************************************************/
   FUNCTION f_altarecibo_seg(x IN OUT int_recibos_dkv%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_ALTARECIBO_SEG';
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
      pac_mig_axis.p_migra_cargas(x.nlinea, 'C', x.ncarga, 'DEL');   --Cargamos las SEG para la póliza (ncarga)
      vtraza := 110;

      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 200;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.numero_de_recibo,   -- Fi Bug 14888
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
                  (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.numero_de_recibo,   -- Fi Bug 14888
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

      IF NOT v_i THEN   --Esto quiere decir que no ha habido ningún error (lo indicamos también).
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
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.numero_de_recibo,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                NULL, NULL, NULL, vnrecibo);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            p_deserror := 'Error al marcar linea con estado correcto';
            RAISE verrorgrab;
         END IF;

         BEGIN
            UPDATE recibos
               SET creccia = x.creccia
             WHERE nrecibo = vnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               pac_cargas_dkv.p_genera_logs(vobj, vtraza, SQLCODE,
                                            'Error al guardar creccia ' || x.creccia,
                                            x.proceso,
                                            'Error al guardar creccia ' || x.creccia);
         END;

         vtiperr := 4;
      END IF;

      RETURN vtiperr;   --Devolvemos el tipo error que ha habido
   EXCEPTION
      WHEN verrorgrab THEN
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error ' || vnum_err, p_deserror,
                                      x.proceso, 'Error ' || vnum_err || ' ' || p_deserror);
         RETURN 10;
      WHEN OTHERS THEN
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error ' || SQLCODE, SQLERRM, x.proceso,
                                      'Error ' || SQLCODE || ' ' || SQLERRM);
         RETURN 10;
   END f_altarecibo_seg;

   /*************************************************************************
                                                    procedimiento que genera movimientos recibo
          param in x : registro tipo int_recibos_dkv
          param p_deserror out: Descripción del error si existe.
          Devuelve TIPOERROR ( 1-Ha habido error, 2-Es un warning, 4-Ha ido bien, x-Error incontrolado).
          --
          Para modificar una póliza, los siguientes campos son obligatorios:
          - póliza cia
          - fecha efecto (se toma como fecha operacion).
          - estado recibo.
          --
      *************************************************************************/
   FUNCTION f_modi_recibo(x IN OUT int_recibos_dkv%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_MODI_RECIBO';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      mismoestado    EXCEPTION;
      n_rec          recibos.nrecibo%TYPE;
      d_sup          movrecibo.fmovini%TYPE;
      n_estrecact    movrecibo.cestrec%TYPE;   -- Estat actual
      n_estrecnou    movrecibo.cestrec%TYPE;   -- Estat nou
      n_ultmov       movseguro.nmovimi%TYPE;   -- Ultimo movimiento
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

      BEGIN
         SELECT nrecibo
           INTO n_rec
           FROM recibos
          WHERE creccia = x.creccia
            AND cempres = k_empresaaxis;
      EXCEPTION
         WHEN OTHERS THEN
            n_rec := NULL;
      END;

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
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.numero_de_recibo,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga,   -- Fi Bug 16324
                NULL, NULL, NULL, n_rec);

         IF n_aux <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145,
                                    f_axis_literales(9902152, k_idiomaaaxis) || ' Nº: '
                                    || x.numero_de_recibo);

         IF n_aux <> 0 THEN
            RAISE errdatos;
         END IF;

         RETURN 2;   --warning
      END IF;

      vtraza := 1020;
      vtraza := 1025;
      d_sup := converteix_charadate(LTRIM(TO_CHAR(x.dia_efecto_rbo, '09'))
                                    || LTRIM(TO_CHAR(x.mes_efecto_rbo, '09'))
                                    || LTRIM(TO_CHAR(x.anyo_efecto_rbo, '0999')),
                                    'ddmmyyyy');

      IF d_sup IS NULL THEN
         p_deserror := 'Fecha efecto no es fecha: ' || x.dia_efecto_rbo || '-'
                       || x.mes_efecto_rbo || '-' || x.anyo_efecto_rbo || ' (dd-mm-aaaa)';
         p_deserror := p_deserror
                       || '. Editar linea, modificar fecha efecto recibo y reprocesar';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      IF x.estado_de_recibo IS NULL THEN
         p_deserror := 'Estado recibo no existe: ' || x.estado_de_recibo;
         cerror := 101915;
         RAISE errdatos;
      END IF;

      n_estrecnou := pac_cargas_dkv.f_buscavalor('CRT_ESTADORECIBO', x.estado_de_recibo);

      IF n_estrecnou IS NULL THEN
         p_deserror := 'Estado de recibo no definido: ' || x.estado_de_recibo
                       || ' (CRT_ESTADORECIBO)';
         p_deserror := p_deserror || '. Editar linea, modificar estado recibo y reporcesar';
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
      n_estrecact := f_estrec(n_rec);
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
            p_deserror := 'Error al crear estado anulado: ' || cerror;
            RAISE errdatos;
         END IF;
      END IF;

---------------------------------------------------------
-- CONTROL FINAL                                       --
---------------------------------------------------------
      IF b_warning THEN
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.numero_de_recibo,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.numero_de_recibo,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.numero_de_recibo,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.numero_de_recibo,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.numero_de_recibo,   -- Fi Bug 14888
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
   FUNCTION f_rec_ejecutarcargaproceso(psproces IN NUMBER, p_cproces IN NUMBER)   -- BUG16130:DRA:15/10/2010
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_REC_EJECUTARCARGAPROCESO';

      CURSOR polmigra(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_recibos_dkv a
            WHERE proceso = psproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.proceso
                                AND int_carga_ctrl_linea.nlinea = a.nlinea
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5))   --Solo las no procesadas
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
   -- n_cfg_cproceso cfg_files.cproceso%TYPE;   -- BUG16130:DRA:15/10/2010
   BEGIN
      vtraza := 0;
      v_deserror := NULL;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                      'Parámetro psproces obligatorio.', NULL, NULL);
         RAISE vsalir;
      END IF;

      vtraza := 1;

      SELECT MIN(tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      IF v_tfichero IS NULL THEN
         vnum_err := 9901092;
         v_deserror := 'Falta fichero para proceso: ' || psproces;
         RAISE errorini;
      END IF;

      vtraza := 2;

      -- BUG16130:DRA:15/10/2010:Inici
      -- SELECT MAX(cproceso)
      --   INTO n_cfg_cproceso
      --   FROM cfg_files
      --  WHERE cempres = k_empresaaxis
      --    AND cactivo = 1
      --    AND UPPER(tproceso) = RTRIM(vobj, 'PROCESO');
      -- BUG16130:DRA:15/10/2010:Fi
      IF p_cproces IS NULL THEN
         vnum_err := 103778;
         v_deserror := 'cfg_files falta proceso: ' || vobj;
         RAISE errorini;   --Error que para ejecución
      END IF;

      FOR x IN polmigra(psproces) LOOP   --Leemos los registros de la tabla int no procesados OK
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

                                              -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                              x.numero_de_recibo,
                                              -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                              x.ncarga
                                                      -- Fi Bug 16324
                                );

                     IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa0
                        v_deserror := 'Marcar linea aviso';
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

                                           -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                           x.numero_de_recibo,
                                           -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                           x.ncarga
                                                   -- Fi Bug 16324
                             );

                  IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
                     v_deserror := 'Marcar linea error';
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  vtraza := 72;
                  vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,
                                                v_deserror);

                  IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
                     v_deserror := 'Marcar detalle linea error';
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
               v_deserror := 'Tipo error no esperado ' || vtiperr;
               RAISE errorini;   --Error que para ejecución(funciones de gestión)
            END IF;

            COMMIT;
         -- Bug 0016324. FAL. 18/10/2010
         ELSIF vtiperr = 1
               AND k_para_carga = 1 THEN
            vtiperr := 1;
            vcoderror := 151541;
            --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
            vnum_err :=
               pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (psproces, v_tfichero, f_sysdate,
                                                          f_sysdate, vtiperr, p_cproces,   -- BUG16130:DRA:29/09/2010
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
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero, f_sysdate,
                                                        f_sysdate, vtiperr, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        vcoderror, NULL);
      vtraza := 51;

      IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
         v_deserror := 'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera';
         RAISE errorini;
      END IF;

      --Bug.:17155
      IF vtiperr IN(4, 2) THEN
         vnum_err := pac_gestion_procesos.f_set_carga_fichero(32, v_tfichero, 2, f_sysdate);

         IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
            v_deserror := 'Error llamando a pac_gestion_procesos.f_set_carga_fichero';
            RAISE errorini;
         END IF;
      END IF;

      --Fi Bug.: 17155
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN vsalir THEN
         NULL;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, v_deserror,
                                      psproces,
                                      f_axis_literales(108953, k_idiomaaaxis) || ':'
                                      || v_tfichero || ' : ' || 'errorini');
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_dkv.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                      f_axis_literales(103187, k_idiomaaaxis) || ':'
                                      || v_tfichero || ' : ' || SQLERRM);
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (psproces, v_tfichero, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                          151541, SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_dkv.p_genera_logs
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
      vobj           VARCHAR2(200) := 'PAC_CARGAS_DKV.F_REC_LEEFICHERO';
      registro       int_polizas_dkv%ROWTYPE;
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
      v_map          map_cabecera.cmapead%TYPE := 'C0011';   -- Carga Recibos DKV
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
      UPDATE int_recibos_dkv
         SET proceso = psproces
       WHERE sinterf = psproces;

      COMMIT;

      DECLARE
         v_tipo         int_recibos_dkv.tipo_oper%TYPE;

         CURSOR c1 IS
            SELECT ROWID, nlinea, numero_de_recibo,
                   LPAD(sucursal_dkv, 3, '0') || LPAD(oficina_dkv, 2, '0')
                   || LPAD(ramo_dkv, 3, '0') || LPAD(numero_de_recibo, 7, '0')
                   || LPAD(orden_recibo, 2, '0') creccia,

                   -- Bug 0016324. FAL. 18/10/2010.
                   proceso,
                           -- Fi bug 0016324
                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                           ncarga
              -- Fi Bug 16324
            FROM   int_recibos_dkv
             WHERE proceso = psproces;
      BEGIN
         FOR f1 IN c1 LOOP
            v_pasexec := 5;

            -- Si existeix a rebuts es una modificació.
            SELECT MAX('MODI_REC')
              INTO v_tipo
              FROM recibos
             WHERE creccia = f1.creccia
               AND cempres = k_empresaaxis;

            IF v_tipo IS NULL THEN
               v_tipo := 'ALTA_REC';
            END IF;

            -- Fi bug 0016324
            v_pasexec := 6;
            -- Marcar como pendiente.
            v_numerr :=
               p_marcalinea
                  (psproces, f1.nlinea, v_tipo, 3, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   f1.numero_de_recibo,   -- Fi Bug 14888
                                          -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   f1.ncarga   -- Fi Bug 16324
                            );

            IF v_numerr <> 0 THEN
               RAISE errgrabarprov;
            END IF;

            v_pasexec := 7;

            UPDATE int_recibos_dkv
               SET tipo_oper = v_tipo,
                   creccia = f1.creccia
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_REC_EJECUTARCARGAFICHERO';
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
   -- n_cfg_cproceso cfg_files.cproceso%TYPE;  -- BUG16130:DRA:15/10/2010
   BEGIN
      vtraza := 0;
      vsinproc := TRUE;
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_DKV_REC', p_nombre, v_sproces);

      IF vnum_err <> 0 THEN
         RAISE errorini;   --Error que para ejecución
      END IF;

      vtraza := 1;

      -- BUG16130:DRA:15/10/2010:Inici
      -- SELECT MAX(cproceso)
      --   INTO n_cfg_cproceso
      --   FROM cfg_files
      --  WHERE cempres = k_empresaaxis
      --    AND cactivo = 1
      --    AND UPPER(tproceso) = RTRIM(vobj, 'FICHERO');
      -- BUG16130:DRA:15/10/2010:Fi
      IF p_cproces IS NULL THEN
         vnum_err := 103778;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'cfg_files falta proceso: ' || vobj);
         vnnumlin := NULL;
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ': '
                                 || 'cfg_files falta proceso: ' || vobj,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      psproces := v_sproces;
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera(v_sproces, p_nombre, f_sysdate, NULL,
                                                        3, p_cproces,   -- BUG16130:DRA:29/09/2010
                                                        NULL, NULL);
      vtraza := 2;

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
      vtraza := 3;
      f_rec_leefichero(p_nombre, p_path, vdeserror, v_sproces);
      vtraza := 4;

      IF vdeserror IS NOT NULL THEN   --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
         vtraza := 5;
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_sproces, p_nombre, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
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
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera
                                                         (v_sproces, p_nombre, f_sysdate,
                                                          NULL, 1, p_cproces,   -- BUG16130:DRA:29/09/2010
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_DKV.F_REC_EJECUTARCARGA';
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
         vnum_err :=
            pac_cargas_dkv.f_rec_ejecutarcargafichero(p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                                      psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_dkv.f_rec_ejecutarcargaproceso(psproces, p_cproces);   -- BUG16130:DRA:15/10/2010

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
END pac_cargas_dkv;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_DKV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_DKV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_DKV" TO "PROGRAMADORESCSI";
